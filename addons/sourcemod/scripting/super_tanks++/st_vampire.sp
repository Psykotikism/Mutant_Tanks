// Super Tanks++: Vampire Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Vampire Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains health from hurting survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sVampireEffect[ST_MAXTYPES + 1][4], g_sVampireEffect2[ST_MAXTYPES + 1][4];

float g_flVampireRange[ST_MAXTYPES + 1], g_flVampireRange2[ST_MAXTYPES + 1];

int g_iVampireAbility[ST_MAXTYPES + 1], g_iVampireAbility2[ST_MAXTYPES + 1], g_iVampireChance[ST_MAXTYPES + 1], g_iVampireChance2[ST_MAXTYPES + 1], g_iVampireHealth[ST_MAXTYPES + 1], g_iVampireHealth2[ST_MAXTYPES + 1], g_iVampireHit[ST_MAXTYPES + 1], g_iVampireHit2[ST_MAXTYPES + 1], g_iVampireHitMode[ST_MAXTYPES + 1], g_iVampireHitMode2[ST_MAXTYPES + 1], g_iVampireMessage[ST_MAXTYPES + 1], g_iVampireMessage2[ST_MAXTYPES + 1], g_iVampireRangeChance[ST_MAXTYPES + 1], g_iVampireRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Vampire Ability only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iVampireHitMode(attacker) == 0 || iVampireHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				int iDamage = RoundToNearest(damage), iHealth = GetClientHealth(attacker), iNewHealth = iHealth + iDamage,
					iFinalHealth = (iNewHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth;
				vVampireHit(victim, attacker, iVampireChance(attacker), iVampireHit(attacker), 1, "1", iFinalHealth, 1);
			}
		}
		else if ((iVampireHitMode(victim) == 0 || iVampireHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				int iHealth = GetClientHealth(attacker);
				vVampireHit(attacker, victim, iVampireChance(victim), iVampireHit(victim), 1, "2", iHealth, 2);
			}
		}
	}
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iVampireAbility[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Enabled", 0);
				g_iVampireAbility[iIndex] = iClamp(g_iVampireAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Vampire Ability/Ability Effect", g_sVampireEffect[iIndex], sizeof(g_sVampireEffect[]), "123");
				g_iVampireMessage[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Message", 0);
				g_iVampireMessage[iIndex] = iClamp(g_iVampireMessage[iIndex], 0, 3);
				g_iVampireChance[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Chance", 4);
				g_iVampireChance[iIndex] = iClamp(g_iVampireChance[iIndex], 1, 9999999999);
				g_iVampireHealth[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Health", 100);
				g_iVampireHealth[iIndex] = iClamp(g_iVampireHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_iVampireHit[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit", 0);
				g_iVampireHit[iIndex] = iClamp(g_iVampireHit[iIndex], 0, 1);
				g_iVampireHitMode[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit Mode", 0);
				g_iVampireHitMode[iIndex] = iClamp(g_iVampireHitMode[iIndex], 0, 2);
				g_flVampireRange[iIndex] = kvSuperTanks.GetFloat("Vampire Ability/Vampire Range", 500.0);
				g_flVampireRange[iIndex] = flClamp(g_flVampireRange[iIndex], 1.0, 9999999999.0);
				g_iVampireRangeChance[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Range Chance", 16);
				g_iVampireRangeChance[iIndex] = iClamp(g_iVampireRangeChance[iIndex], 1, 9999999999);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iVampireAbility2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Enabled", g_iVampireAbility[iIndex]);
				g_iVampireAbility2[iIndex] = iClamp(g_iVampireAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Vampire Ability/Ability Effect", g_sVampireEffect2[iIndex], sizeof(g_sVampireEffect2[]), g_sVampireEffect[iIndex]);
				g_iVampireMessage2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Message", g_iVampireMessage[iIndex]);
				g_iVampireMessage2[iIndex] = iClamp(g_iVampireMessage2[iIndex], 0, 3);
				g_iVampireChance2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Chance", g_iVampireChance[iIndex]);
				g_iVampireChance2[iIndex] = iClamp(g_iVampireChance2[iIndex], 1, 9999999999);
				g_iVampireHealth2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Health", g_iVampireHealth[iIndex]);
				g_iVampireHealth2[iIndex] = iClamp(g_iVampireHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_iVampireHit2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit", g_iVampireHit[iIndex]);
				g_iVampireHit2[iIndex] = iClamp(g_iVampireHit2[iIndex], 0, 1);
				g_iVampireHitMode2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit Mode", g_iVampireHitMode[iIndex]);
				g_iVampireHitMode2[iIndex] = iClamp(g_iVampireHitMode2[iIndex], 0, 2);
				g_flVampireRange2[iIndex] = kvSuperTanks.GetFloat("Vampire Ability/Vampire Range", g_flVampireRange[iIndex]);
				g_flVampireRange2[iIndex] = flClamp(g_flVampireRange2[iIndex], 1.0, 9999999999.0);
				g_iVampireRangeChance2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Range Chance", g_iVampireRangeChance[iIndex]);
				g_iVampireRangeChance2[iIndex] = iClamp(g_iVampireRangeChance2[iIndex], 1, 9999999999);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Ability(int tank)
{
	int iVampireAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iVampireAbility[ST_TankType(tank)] : g_iVampireAbility2[ST_TankType(tank)],
		iVampireRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_iVampireChance[ST_TankType(tank)] : g_iVampireChance2[ST_TankType(tank)];
	if (iVampireAbility == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		float flVampireRange = !g_bTankConfig[ST_TankType(tank)] ? g_flVampireRange[ST_TankType(tank)] : g_flVampireRange2[ST_TankType(tank)];
		int iHealth = GetClientHealth(tank),
			iVampireHealth = !g_bTankConfig[ST_TankType(tank)] ? (iHealth + g_iVampireHealth[ST_TankType(tank)]) : (iHealth + g_iVampireHealth2[ST_TankType(tank)]),
			iExtraHealth = (iVampireHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iVampireHealth,
			iExtraHealth2 = (iVampireHealth < iHealth) ? 1 : iVampireHealth,
			iRealHealth = (iVampireHealth >= 0) ? iExtraHealth : iExtraHealth2;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flVampireRange)
				{
					vVampireHit(iSurvivor, tank, iVampireRangeChance, iVampireAbility, 2, "3", iRealHealth, 1);
				}
			}
		}
	}
}

static void vVampireHit(int survivor, int tank, int chance, int enabled, int message, const char[] mode, int health, int hit)
{
	if ((enabled == 1 || enabled == 3) && GetRandomInt(1, chance) == 1 && bIsSurvivor(survivor))
	{
		switch (hit)
		{
			case 1: SetEntityHealth(tank, health);
			case 2: SetEntityHealth(survivor, health - 5);
		}

		char sVampireEffect[4];
		sVampireEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sVampireEffect[ST_TankType(tank)] : g_sVampireEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sVampireEffect, mode);

		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(tank, sTankName);
		if ((message == 1 && iVampireMessage(tank) == message) || iVampireMessage(tank) == 3)
		{
			PrintToChatAll("%s %t", ST_PREFIX2, "Vampire", sTankName, survivor);
		}
		else if ((message == 2 && iVampireMessage(tank) == message) || iVampireMessage(tank) == 3)
		{
			PrintToChatAll("%s %t", ST_PREFIX2, "Vampire2", sTankName);
		}
	}
}

static int iVampireChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVampireChance[ST_TankType(tank)] : g_iVampireChance2[ST_TankType(tank)];
}

static int iVampireHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVampireHit[ST_TankType(tank)] : g_iVampireHit2[ST_TankType(tank)];
}

static int iVampireHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVampireHitMode[ST_TankType(tank)] : g_iVampireHitMode2[ST_TankType(tank)];
}

static int iVampireMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVampireMessage[ST_TankType(tank)] : g_iVampireMessage2[ST_TankType(tank)];
}