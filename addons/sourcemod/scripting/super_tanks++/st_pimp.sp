// Super Tanks++: Pimp Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Pimp Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bPimp[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flPimpRange[ST_MAXTYPES + 1];
float g_flPimpRange2[ST_MAXTYPES + 1];
int g_iPimpAbility[ST_MAXTYPES + 1];
int g_iPimpAbility2[ST_MAXTYPES + 1];
int g_iPimpAmount[ST_MAXTYPES + 1];
int g_iPimpAmount2[ST_MAXTYPES + 1];
int g_iPimpChance[ST_MAXTYPES + 1];
int g_iPimpChance2[ST_MAXTYPES + 1];
int g_iPimpCount[MAXPLAYERS + 1];
int g_iPimpDamage[ST_MAXTYPES + 1];
int g_iPimpDamage2[ST_MAXTYPES + 1];
int g_iPimpHit[ST_MAXTYPES + 1];
int g_iPimpHit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Pimp Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPimp[iPlayer] = false;
			g_iPimpCount[iPlayer] = 0;
		}
	}
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bPimp[client] = false;
	g_iPimpCount[client] = 0;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bPimp[client] = false;
	g_iPimpCount[client] = 0;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPimp[iPlayer] = false;
			g_iPimpCount[iPlayer] = 0;
		}
	}
}

void vLateLoad(bool late)
{
	if (late)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (bIsTank(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iPimpHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iPimpHit[ST_TankType(attacker)] : g_iPimpHit2[ST_TankType(attacker)];
				vPimpHit(victim, attacker, iPimpHit);
			}
		}
	}
}

public void ST_Configs(char[] savepath, int limit, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = 1; iIndex <= limit; iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iPimpAbility[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Enabled", 0)) : (g_iPimpAbility2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Enabled", g_iPimpAbility[iIndex]));
			main ? (g_iPimpAbility[iIndex] = iSetCellLimit(g_iPimpAbility[iIndex], 0, 1)) : (g_iPimpAbility2[iIndex] = iSetCellLimit(g_iPimpAbility2[iIndex], 0, 1));
			main ? (g_iPimpAmount[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Amount", 5)) : (g_iPimpAmount2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Amount", g_iPimpAmount[iIndex]));
			main ? (g_iPimpAmount[iIndex] = iSetCellLimit(g_iPimpAmount[iIndex], 1, 9999999999)) : (g_iPimpAmount2[iIndex] = iSetCellLimit(g_iPimpAmount2[iIndex], 1, 9999999999));
			main ? (g_iPimpChance[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Chance", 4)) : (g_iPimpChance2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Chance", g_iPimpChance[iIndex]));
			main ? (g_iPimpChance[iIndex] = iSetCellLimit(g_iPimpChance[iIndex], 1, 9999999999)) : (g_iPimpChance2[iIndex] = iSetCellLimit(g_iPimpChance2[iIndex], 1, 9999999999));
			main ? (g_iPimpDamage[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Damage", 1)) : (g_iPimpDamage2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Damage", g_iPimpDamage[iIndex]));
			main ? (g_iPimpDamage[iIndex] = iSetCellLimit(g_iPimpDamage[iIndex], 1, 9999999999)) : (g_iPimpDamage2[iIndex] = iSetCellLimit(g_iPimpDamage2[iIndex], 1, 9999999999));
			main ? (g_iPimpHit[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit", 0)) : (g_iPimpHit2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit", g_iPimpHit[iIndex]));
			main ? (g_iPimpHit[iIndex] = iSetCellLimit(g_iPimpHit[iIndex], 0, 1)) : (g_iPimpHit2[iIndex] = iSetCellLimit(g_iPimpHit2[iIndex], 0, 1));
			main ? (g_flPimpRange[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range", 150.0)) : (g_flPimpRange2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range", g_flPimpRange[iIndex]));
			main ? (g_flPimpRange[iIndex] = flSetFloatLimit(g_flPimpRange[iIndex], 1.0, 9999999999.0)) : (g_flPimpRange2[iIndex] = flSetFloatLimit(g_flPimpRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		int iPimpAbility = !g_bTankConfig[ST_TankType(client)] ? g_iPimpAbility[ST_TankType(client)] : g_iPimpAbility2[ST_TankType(client)];
		float flPimpRange = !g_bTankConfig[ST_TankType(client)] ? g_flPimpRange[ST_TankType(client)] : g_flPimpRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPimpRange)
				{
					vPimpHit(iSurvivor, client, iPimpAbility);
				}
			}
		}
	}
}

void vPimpHit(int client, int owner, int enabled)
{
	int iPimpChance = !g_bTankConfig[ST_TankType(owner)] ? g_iPimpChance[ST_TankType(owner)] : g_iPimpChance2[ST_TankType(owner)];
	if (enabled == 1 && GetRandomInt(1, iPimpChance) == 1 && bIsSurvivor(client) && !g_bPimp[client])
	{
		g_bPimp[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(0.5, tTimerPimp, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

public Action tTimerPimp(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iPimpAmount = !g_bTankConfig[ST_TankType(iTank)] ? g_iPimpAmount[ST_TankType(iTank)] : g_iPimpAmount2[ST_TankType(iTank)];
	int iPimpDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iPimpDamage[ST_TankType(iTank)] : g_iPimpDamage2[ST_TankType(iTank)];
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor) || g_iPimpCount[iSurvivor] >= iPimpAmount)
	{
		g_bPimp[iSurvivor] = false;
		g_iPimpCount[iSurvivor] = 0;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor) && g_iPimpCount[iSurvivor] < iPimpAmount)
	{
		SlapPlayer(iSurvivor, iPimpDamage, true);
		g_iPimpCount[iSurvivor]++;
	}
	return Plugin_Continue;
}