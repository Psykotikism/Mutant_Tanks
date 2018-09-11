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
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bLeech[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flLeechDuration[ST_MAXTYPES + 1], g_flLeechDuration2[ST_MAXTYPES + 1], g_flLeechInterval[ST_MAXTYPES + 1], g_flLeechInterval2[ST_MAXTYPES + 1], g_flLeechRange[ST_MAXTYPES + 1], g_flLeechRange2[ST_MAXTYPES + 1];
int g_iLeechAbility[ST_MAXTYPES + 1], g_iLeechAbility2[ST_MAXTYPES + 1], g_iLeechChance[ST_MAXTYPES + 1], g_iLeechChance2[ST_MAXTYPES + 1], g_iLeechHit[ST_MAXTYPES + 1], g_iLeechHit2[ST_MAXTYPES + 1], g_iLeechHitMode[ST_MAXTYPES + 1], g_iLeechHitMode2[ST_MAXTYPES + 1], g_iLeechRangeChance[ST_MAXTYPES + 1], g_iLeechRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
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

public void OnMapStart()
{
	vReset();
	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
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
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vLeechHit(victim, attacker, iLeechChance(attacker), iLeechHit(attacker));
			}
		}
		else if ((iLeechHitMode(victim) == 0 || iLeechHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vLeechHit(attacker, victim, iLeechChance(victim), iLeechHit(victim));
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
			main ? (g_iLeechAbility[iIndex] = kvSuperTanks.GetNum("Leech Ability/Ability Enabled", 0)) : (g_iLeechAbility2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Ability Enabled", g_iLeechAbility[iIndex]));
			main ? (g_iLeechAbility[iIndex] = iSetCellLimit(g_iLeechAbility[iIndex], 0, 1)) : (g_iLeechAbility2[iIndex] = iSetCellLimit(g_iLeechAbility2[iIndex], 0, 1));
			main ? (g_iLeechChance[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Chance", 4)) : (g_iLeechChance2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Chance", g_iLeechChance[iIndex]));
			main ? (g_iLeechChance[iIndex] = iSetCellLimit(g_iLeechChance[iIndex], 1, 9999999999)) : (g_iLeechChance2[iIndex] = iSetCellLimit(g_iLeechChance2[iIndex], 1, 9999999999));
			main ? (g_flLeechDuration[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Duration", 5.0)) : (g_flLeechDuration2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Duration", g_flLeechDuration[iIndex]));
			main ? (g_flLeechDuration[iIndex] = flSetFloatLimit(g_flLeechDuration[iIndex], 0.1, 9999999999.0)) : (g_flLeechDuration2[iIndex] = flSetFloatLimit(g_flLeechDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iLeechHit[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit", 0)) : (g_iLeechHit2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit", g_iLeechHit[iIndex]));
			main ? (g_iLeechHit[iIndex] = iSetCellLimit(g_iLeechHit[iIndex], 0, 1)) : (g_iLeechHit2[iIndex] = iSetCellLimit(g_iLeechHit2[iIndex], 0, 1));
			main ? (g_iLeechHitMode[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit Mode", 0)) : (g_iLeechHitMode2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit Mode", g_iLeechHitMode[iIndex]));
			main ? (g_iLeechHitMode[iIndex] = iSetCellLimit(g_iLeechHitMode[iIndex], 0, 2)) : (g_iLeechHitMode2[iIndex] = iSetCellLimit(g_iLeechHitMode2[iIndex], 0, 2));
			main ? (g_flLeechInterval[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Interval", 1.0)) : (g_flLeechInterval2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Interval", g_flLeechInterval[iIndex]));
			main ? (g_flLeechInterval[iIndex] = flSetFloatLimit(g_flLeechInterval[iIndex], 0.1, 9999999999.0)) : (g_flLeechInterval2[iIndex] = flSetFloatLimit(g_flLeechInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flLeechRange[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range", 150.0)) : (g_flLeechRange2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range", g_flLeechRange[iIndex]));
			main ? (g_flLeechRange[iIndex] = flSetFloatLimit(g_flLeechRange[iIndex], 1.0, 9999999999.0)) : (g_flLeechRange2[iIndex] = flSetFloatLimit(g_flLeechRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iLeechRangeChance[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Range Chance", 16)) : (g_iLeechRangeChance2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Range Chance", g_iLeechRangeChance[iIndex]));
			main ? (g_iLeechRangeChance[iIndex] = iSetCellLimit(g_iLeechRangeChance[iIndex], 1, 9999999999)) : (g_iLeechRangeChance2[iIndex] = iSetCellLimit(g_iLeechRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iLeechAbility = !g_bTankConfig[ST_TankType(client)] ? g_iLeechAbility[ST_TankType(client)] : g_iLeechAbility2[ST_TankType(client)],
			iLeechRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iLeechChance[ST_TankType(client)] : g_iLeechChance2[ST_TankType(client)];
		float flLeechRange = !g_bTankConfig[ST_TankType(client)] ? g_flLeechRange[ST_TankType(client)] : g_flLeechRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flLeechRange)
				{
					vLeechHit(iSurvivor, client, iLeechRangeChance, iLeechAbility);
				}
			}
		}
	}
}

stock void vLeechHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bLeech[client])
	{
		g_bLeech[client] = true;
		float flLeechInterval = !g_bTankConfig[ST_TankType(owner)] ? g_flLeechInterval[ST_TankType(owner)] : g_flLeechInterval2[ST_TankType(owner)];
		DataPack dpLeech = new DataPack();
		CreateDataTimer(flLeechInterval, tTimerLeech, dpLeech, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpLeech.WriteCell(GetClientUserId(client)), dpLeech.WriteCell(GetClientUserId(owner)), dpLeech.WriteCell(enabled), dpLeech.WriteFloat(GetEngineTime());
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bLeech[iPlayer] = false;
		}
	}
}

stock int iLeechChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iLeechChance[ST_TankType(client)] : g_iLeechChance2[ST_TankType(client)];
}

stock int iLeechHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iLeechHit[ST_TankType(client)] : g_iLeechHit2[ST_TankType(client)];
}

stock int iLeechHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iLeechHitMode[ST_TankType(client)] : g_iLeechHitMode2[ST_TankType(client)];
}

public Action tTimerLeech(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bLeech[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bLeech[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iLeechEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flLeechDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flLeechDuration[ST_TankType(iTank)] : g_flLeechDuration2[ST_TankType(iTank)];
	if (iLeechEnabled == 0 || (flTime + flLeechDuration) < GetEngineTime())
	{
		g_bLeech[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iSurvivorHealth = GetClientHealth(iSurvivor), iTankHealth = GetClientHealth(iTank), iNewHealth = iSurvivorHealth - 1, iNewHealth2 = iTankHealth + 1,
		iFinalHealth = (iNewHealth < 1) ? 1 : iNewHealth, iFinalHealth2 = (iNewHealth2 > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth2;
	SetEntityHealth(iSurvivor, iFinalHealth);
	SetEntityHealth(iTank, iFinalHealth2);
	return Plugin_Continue;
}