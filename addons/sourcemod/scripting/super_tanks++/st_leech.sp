// Super Tanks++: Leech Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Leech Ability",
	author = ST_AUTHOR,
	description = "The Super Tank leeches health off of survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bLeech[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sLeechEffect[ST_MAXTYPES + 1][4], g_sLeechEffect2[ST_MAXTYPES + 1][4];

float g_flLeechChance[ST_MAXTYPES + 1], g_flLeechChance2[ST_MAXTYPES + 1], g_flLeechDuration[ST_MAXTYPES + 1], g_flLeechDuration2[ST_MAXTYPES + 1], g_flLeechInterval[ST_MAXTYPES + 1], g_flLeechInterval2[ST_MAXTYPES + 1], g_flLeechRange[ST_MAXTYPES + 1], g_flLeechRange2[ST_MAXTYPES + 1], g_flLeechRangeChance[ST_MAXTYPES + 1], g_flLeechRangeChance2[ST_MAXTYPES + 1];

int g_iLeechAbility[ST_MAXTYPES + 1], g_iLeechAbility2[ST_MAXTYPES + 1], g_iLeechHit[ST_MAXTYPES + 1], g_iLeechHit2[ST_MAXTYPES + 1], g_iLeechHitMode[ST_MAXTYPES + 1], g_iLeechHitMode2[ST_MAXTYPES + 1], g_iLeechMessage[ST_MAXTYPES + 1], g_iLeechMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Leech Ability only supports Left 4 Dead 1 & 2.");

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

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bLeech[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iLeechHitMode(attacker) == 0 || iLeechHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vLeechHit(victim, attacker, flLeechChance(attacker), iLeechHit(attacker), 1, "1");
			}
		}
		else if ((iLeechHitMode(victim) == 0 || iLeechHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vLeechHit(attacker, victim, flLeechChance(victim), iLeechHit(victim), 1, "2");
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

				g_iLeechAbility[iIndex] = kvSuperTanks.GetNum("Leech Ability/Ability Enabled", 0);
				g_iLeechAbility[iIndex] = iClamp(g_iLeechAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Leech Ability/Ability Effect", g_sLeechEffect[iIndex], sizeof(g_sLeechEffect[]), "123");
				g_iLeechMessage[iIndex] = kvSuperTanks.GetNum("Leech Ability/Ability Message", 0);
				g_iLeechMessage[iIndex] = iClamp(g_iLeechMessage[iIndex], 0, 3);
				g_flLeechChance[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Chance", 33.3);
				g_flLeechChance[iIndex] = flClamp(g_flLeechChance[iIndex], 0.1, 100.0);
				g_flLeechDuration[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Duration", 5.0);
				g_flLeechDuration[iIndex] = flClamp(g_flLeechDuration[iIndex], 0.1, 9999999999.0);
				g_iLeechHit[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit", 0);
				g_iLeechHit[iIndex] = iClamp(g_iLeechHit[iIndex], 0, 1);
				g_iLeechHitMode[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit Mode", 0);
				g_iLeechHitMode[iIndex] = iClamp(g_iLeechHitMode[iIndex], 0, 2);
				g_flLeechInterval[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Interval", 1.0);
				g_flLeechInterval[iIndex] = flClamp(g_flLeechInterval[iIndex], 0.1, 9999999999.0);
				g_flLeechRange[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range", 150.0);
				g_flLeechRange[iIndex] = flClamp(g_flLeechRange[iIndex], 1.0, 9999999999.0);
				g_flLeechRangeChance[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range Chance", 15.0);
				g_flLeechRangeChance[iIndex] = flClamp(g_flLeechRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iLeechAbility2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Ability Enabled", g_iLeechAbility[iIndex]);
				g_iLeechAbility2[iIndex] = iClamp(g_iLeechAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Leech Ability/Ability Effect", g_sLeechEffect2[iIndex], sizeof(g_sLeechEffect2[]), g_sLeechEffect[iIndex]);
				g_iLeechMessage2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Ability Message", g_iLeechMessage[iIndex]);
				g_iLeechMessage2[iIndex] = iClamp(g_iLeechMessage2[iIndex], 0, 3);
				g_flLeechChance2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Chance", g_flLeechChance[iIndex]);
				g_flLeechChance2[iIndex] = flClamp(g_flLeechChance2[iIndex], 0.1, 100.0);
				g_flLeechDuration2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Duration", g_flLeechDuration[iIndex]);
				g_flLeechDuration2[iIndex] = flClamp(g_flLeechDuration2[iIndex], 0.1, 9999999999.0);
				g_iLeechHit2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit", g_iLeechHit[iIndex]);
				g_iLeechHit2[iIndex] = iClamp(g_iLeechHit2[iIndex], 0, 1);
				g_iLeechHitMode2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit Mode", g_iLeechHitMode[iIndex]);
				g_iLeechHitMode2[iIndex] = iClamp(g_iLeechHitMode2[iIndex], 0, 2);
				g_flLeechInterval2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Interval", g_flLeechInterval[iIndex]);
				g_flLeechInterval2[iIndex] = flClamp(g_flLeechInterval2[iIndex], 0.1, 9999999999.0);
				g_flLeechRange2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range", g_flLeechRange[iIndex]);
				g_flLeechRange2[iIndex] = flClamp(g_flLeechRange2[iIndex], 1.0, 9999999999.0);
				g_flLeechRangeChance2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range Chance", g_flLeechRangeChance[iIndex]);
				g_flLeechRangeChance2[iIndex] = flClamp(g_flLeechRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iLeechAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iLeechAbility[ST_TankType(tank)] : g_iLeechAbility2[ST_TankType(tank)];

		float flLeechRange = !g_bTankConfig[ST_TankType(tank)] ? g_flLeechRange[ST_TankType(tank)] : g_flLeechRange2[ST_TankType(tank)],
			flLeechRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flLeechRangeChance[ST_TankType(tank)] : g_flLeechRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flLeechRange)
				{
					vLeechHit(iSurvivor, tank, flLeechRangeChance, iLeechAbility, 2, "3");
				}
			}
		}
	}
}

static void vLeechHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bLeech[survivor])
	{
		g_bLeech[survivor] = true;

		float flLeechInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flLeechInterval[ST_TankType(tank)] : g_flLeechInterval2[ST_TankType(tank)];
		DataPack dpLeech;
		CreateDataTimer(flLeechInterval, tTimerLeech, dpLeech, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpLeech.WriteCell(GetClientUserId(survivor));
		dpLeech.WriteCell(GetClientUserId(tank));
		dpLeech.WriteCell(message);
		dpLeech.WriteCell(enabled);
		dpLeech.WriteFloat(GetEngineTime());

		char sLeechEffect[4];
		sLeechEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sLeechEffect[ST_TankType(tank)] : g_sLeechEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sLeechEffect, mode);

		if (iLeechMessage(tank) == message || iLeechMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Leech", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bLeech[iPlayer] = false;
		}
	}
}

static void vReset2(int survivor, int tank, int message)
{
	g_bLeech[survivor] = false;

	if (iLeechMessage(tank) == message || iLeechMessage(tank) == 3)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(tank, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "Leech2", sTankName, survivor);
	}
}

static float flLeechChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flLeechChance[ST_TankType(tank)] : g_flLeechChance2[ST_TankType(tank)];
}

static int iLeechHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iLeechHit[ST_TankType(tank)] : g_iLeechHit2[ST_TankType(tank)];
}

static int iLeechHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iLeechHitMode[ST_TankType(tank)] : g_iLeechHitMode2[ST_TankType(tank)];
}

static int iLeechMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iLeechMessage[ST_TankType(tank)] : g_iLeechMessage2[ST_TankType(tank)];
}

public Action tTimerLeech(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bLeech[iSurvivor])
	{
		g_bLeech[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iLeechChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iLeechChat);

		return Plugin_Stop;
	}

	int iLeechEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flLeechDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flLeechDuration[ST_TankType(iTank)] : g_flLeechDuration2[ST_TankType(iTank)];

	if (iLeechEnabled == 0 || (flTime + flLeechDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, iLeechChat);

		return Plugin_Stop;
	}

	int iSurvivorHealth = GetClientHealth(iSurvivor), iTankHealth = GetClientHealth(iTank), iNewHealth = iSurvivorHealth - 1, iNewHealth2 = iTankHealth + 1,
		iFinalHealth = (iNewHealth < 1) ? 1 : iNewHealth, iFinalHealth2 = (iNewHealth2 > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth2;
	SetEntityHealth(iSurvivor, iFinalHealth);
	SetEntityHealth(iTank, iFinalHealth2);

	return Plugin_Continue;
}