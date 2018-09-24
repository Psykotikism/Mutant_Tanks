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
float g_flVampireRange[ST_MAXTYPES + 1], g_flVampireRange2[ST_MAXTYPES + 1];
int g_iVampireAbility[ST_MAXTYPES + 1], g_iVampireAbility2[ST_MAXTYPES + 1], g_iVampireChance[ST_MAXTYPES + 1], g_iVampireChance2[ST_MAXTYPES + 1], g_iVampireHealth[ST_MAXTYPES + 1], g_iVampireHealth2[ST_MAXTYPES + 1], g_iVampireHit[ST_MAXTYPES + 1], g_iVampireHit2[ST_MAXTYPES + 1], g_iVampireHitMode[ST_MAXTYPES + 1], g_iVampireHitMode2[ST_MAXTYPES + 1], g_iVampireMessage[ST_MAXTYPES + 1], g_iVampireMessage2[ST_MAXTYPES + 1], g_iVampireRangeChance[ST_MAXTYPES + 1], g_iVampireRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
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
	if (strcmp(name, "st_clone", false) == 0)
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "st_clone", false) == 0)
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
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				if (iVampireHit(attacker) == 1 && GetRandomInt(1, iVampireChance(attacker)) == 1)
				{
					int iDamage = RoundToNearest(damage), iHealth = GetClientHealth(attacker), iNewHealth = iHealth + iDamage,
						iFinalHealth = (iNewHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth;
					SetEntityHealth(attacker, iFinalHealth);
					vVampireMessage(victim, attacker);
				}
			}
		}
		else if ((iVampireHitMode(victim) == 0 || iVampireHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				if (iVampireHit(victim) == 1 && GetRandomInt(1, iVampireChance(victim)) == 1)
				{
					int iHealth = GetClientHealth(attacker);
					SetEntityHealth(attacker, iHealth - 5);
					vVampireMessage(attacker, victim);
				}
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
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iVampireAbility[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Enabled", 0)) : (g_iVampireAbility2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Enabled", g_iVampireAbility[iIndex]));
			main ? (g_iVampireAbility[iIndex] = iClamp(g_iVampireAbility[iIndex], 0, 1)) : (g_iVampireAbility2[iIndex] = iClamp(g_iVampireAbility2[iIndex], 0, 1));
			main ? (g_iVampireMessage[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Message", 0)) : (g_iVampireMessage2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Message", g_iVampireMessage[iIndex]));
			main ? (g_iVampireMessage[iIndex] = iClamp(g_iVampireMessage[iIndex], 0, 3)) : (g_iVampireMessage2[iIndex] = iClamp(g_iVampireMessage2[iIndex], 0, 3));
			main ? (g_iVampireChance[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Chance", 4)) : (g_iVampireChance2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Chance", g_iVampireChance[iIndex]));
			main ? (g_iVampireChance[iIndex] = iClamp(g_iVampireChance[iIndex], 1, 9999999999)) : (g_iVampireChance2[iIndex] = iClamp(g_iVampireChance2[iIndex], 1, 9999999999));
			main ? (g_iVampireHealth[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Health", 100)) : (g_iVampireHealth2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Health", g_iVampireHealth[iIndex]));
			main ? (g_iVampireHealth[iIndex] = iClamp(g_iVampireHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iVampireHealth2[iIndex] = iClamp(g_iVampireHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_iVampireHit[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit", 0)) : (g_iVampireHit2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit", g_iVampireHit[iIndex]));
			main ? (g_iVampireHit[iIndex] = iClamp(g_iVampireHit[iIndex], 0, 1)) : (g_iVampireHit2[iIndex] = iClamp(g_iVampireHit2[iIndex], 0, 1));
			main ? (g_iVampireHitMode[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit Mode", 0)) : (g_iVampireHitMode2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit Mode", g_iVampireHitMode[iIndex]));
			main ? (g_iVampireHitMode[iIndex] = iClamp(g_iVampireHitMode[iIndex], 0, 2)) : (g_iVampireHitMode2[iIndex] = iClamp(g_iVampireHitMode2[iIndex], 0, 2));
			main ? (g_flVampireRange[iIndex] = kvSuperTanks.GetFloat("Vampire Ability/Vampire Range", 500.0)) : (g_flVampireRange2[iIndex] = kvSuperTanks.GetFloat("Vampire Ability/Vampire Range", g_flVampireRange[iIndex]));
			main ? (g_flVampireRange[iIndex] = flClamp(g_flVampireRange[iIndex], 1.0, 9999999999.0)) : (g_flVampireRange2[iIndex] = flClamp(g_flVampireRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iVampireRangeChance[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Range Chance", 16)) : (g_iVampireRangeChance2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Range Chance", g_iVampireRangeChance[iIndex]));
			main ? (g_iVampireRangeChance[iIndex] = iClamp(g_iVampireRangeChance[iIndex], 1, 9999999999)) : (g_iVampireRangeChance2[iIndex] = iClamp(g_iVampireRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iVampireAbility = !g_bTankConfig[ST_TankType(client)] ? g_iVampireAbility[ST_TankType(client)] : g_iVampireAbility2[ST_TankType(client)],
		iVampireRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iVampireChance[ST_TankType(client)] : g_iVampireChance2[ST_TankType(client)];
	if (iVampireAbility == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iVampireCount;
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		float flVampireRange = !g_bTankConfig[ST_TankType(client)] ? g_flVampireRange[ST_TankType(client)] : g_flVampireRange2[ST_TankType(client)];
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flVampireRange)
				{
					iVampireCount++;
				}
			}
		}
		if (iVampireCount > 0)
		{
			if (GetRandomInt(1, iVampireRangeChance) == 1)
			{
				int iHealth = GetClientHealth(client),
					iVampireHealth = !g_bTankConfig[ST_TankType(client)] ? (iHealth + g_iVampireHealth[ST_TankType(client)]) : (iHealth + g_iVampireHealth2[ST_TankType(client)]),
					iExtraHealth = (iVampireHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iVampireHealth,
					iExtraHealth2 = (iVampireHealth < iHealth) ? 1 : iVampireHealth,
					iRealHealth = (iVampireHealth >= 0) ? iExtraHealth : iExtraHealth2;
				SetEntityHealth(client, iRealHealth);
				if (iVampireMessage(client) == 2 || iVampireMessage(client) == 3)
				{
					char sTankName[MAX_NAME_LENGTH + 1];
					ST_TankName(client, sTankName);
					PrintToChatAll("%s %t", ST_PREFIX2, "Vampire2", sTankName);
				}
			}
		}
	}
}

stock void vVampireMessage(int client, int owner)
{
	if (iVampireMessage(owner) == 1 || iVampireMessage(owner) == 3)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(owner, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "Vampire", sTankName, client);
	}
}

stock int iVampireChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iVampireChance[ST_TankType(client)] : g_iVampireChance2[ST_TankType(client)];
}

stock int iVampireHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iVampireHit[ST_TankType(client)] : g_iVampireHit2[ST_TankType(client)];
}

stock int iVampireHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iVampireHitMode[ST_TankType(client)] : g_iVampireHitMode2[ST_TankType(client)];
}

stock int iVampireMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iVampireMessage[ST_TankType(client)] : g_iVampireMessage2[ST_TankType(client)];
}