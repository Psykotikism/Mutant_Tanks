// Super Tanks++: Enforce Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Enforce Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bEnforce[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sEnforceSlot[ST_MAXTYPES + 1][6];
char g_sEnforceSlot2[ST_MAXTYPES + 1][6];
float g_flEnforceDuration[ST_MAXTYPES + 1];
float g_flEnforceDuration2[ST_MAXTYPES + 1];
float g_flEnforceRange[ST_MAXTYPES + 1];
float g_flEnforceRange2[ST_MAXTYPES + 1];
int g_iEnforceAbility[ST_MAXTYPES + 1];
int g_iEnforceAbility2[ST_MAXTYPES + 1];
int g_iEnforceChance[ST_MAXTYPES + 1];
int g_iEnforceChance2[ST_MAXTYPES + 1];
int g_iEnforceHit[ST_MAXTYPES + 1];
int g_iEnforceHit2[ST_MAXTYPES + 1];
int g_iEnforceRangeChance[ST_MAXTYPES + 1];
int g_iEnforceRangeChance2[ST_MAXTYPES + 1];
int g_iEnforceSlot[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Enforce Ability only supports Left 4 Dead 1 & 2.");
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
			g_bEnforce[iPlayer] = false;
			g_iEnforceSlot[iPlayer] = -1;
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
	g_bEnforce[client] = false;
	g_iEnforceSlot[client] = -1;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bEnforce[client] = false;
	g_iEnforceSlot[client] = -1;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bEnforce[iPlayer] = false;
			g_iEnforceSlot[iPlayer] = -1;
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

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!ST_PluginEnabled())
	{
		return Plugin_Continue;
	}
	if (bIsSurvivor(client) && g_bEnforce[client])
	{
		int iActiveWeapon = GetPlayerWeaponSlot(client, g_iEnforceSlot[client]);
		weapon = iActiveWeapon;
	}
	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iEnforceChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iEnforceChance[ST_TankType(attacker)] : g_iEnforceChance2[ST_TankType(attacker)];
				int iEnforceHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iEnforceHit[ST_TankType(attacker)] : g_iEnforceHit2[ST_TankType(attacker)];
				vEnforceHit(victim, attacker, iEnforceChance, iEnforceHit);
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
			main ? (g_iEnforceAbility[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Enabled", 0)) : (g_iEnforceAbility2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Enabled", g_iEnforceAbility[iIndex]));
			main ? (g_iEnforceAbility[iIndex] = iSetCellLimit(g_iEnforceAbility[iIndex], 0, 1)) : (g_iEnforceAbility2[iIndex] = iSetCellLimit(g_iEnforceAbility2[iIndex], 0, 1));
			main ? (g_iEnforceChance[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Chance", 4)) : (g_iEnforceChance2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Chance", g_iEnforceChance[iIndex]));
			main ? (g_iEnforceChance[iIndex] = iSetCellLimit(g_iEnforceChance[iIndex], 1, 9999999999)) : (g_iEnforceChance2[iIndex] = iSetCellLimit(g_iEnforceChance2[iIndex], 1, 9999999999));
			main ? (g_flEnforceDuration[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Duration", 5.0)) : (g_flEnforceDuration2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Duration", g_flEnforceDuration[iIndex]));
			main ? (g_flEnforceDuration[iIndex] = flSetFloatLimit(g_flEnforceDuration[iIndex], 0.1, 9999999999.0)) : (g_flEnforceDuration2[iIndex] = flSetFloatLimit(g_flEnforceDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iEnforceHit[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit", 0)) : (g_iEnforceHit2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit", g_iEnforceHit[iIndex]));
			main ? (g_iEnforceHit[iIndex] = iSetCellLimit(g_iEnforceHit[iIndex], 0, 1)) : (g_iEnforceHit2[iIndex] = iSetCellLimit(g_iEnforceHit2[iIndex], 0, 1));
			main ? (g_flEnforceRange[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range", 150.0)) : (g_flEnforceRange2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range", g_flEnforceRange[iIndex]));
			main ? (g_flEnforceRange[iIndex] = flSetFloatLimit(g_flEnforceRange[iIndex], 1.0, 9999999999.0)) : (g_flEnforceRange2[iIndex] = flSetFloatLimit(g_flEnforceRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iEnforceRangeChance[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Range Chance", 16)) : (g_iEnforceRangeChance2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Range Chance", g_iEnforceRangeChance[iIndex]));
			main ? (g_iEnforceRangeChance[iIndex] = iSetCellLimit(g_iEnforceRangeChance[iIndex], 1, 9999999999)) : (g_iEnforceRangeChance2[iIndex] = iSetCellLimit(g_iEnforceRangeChance2[iIndex], 1, 9999999999));
			main ? (kvSuperTanks.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot[iIndex], sizeof(g_sEnforceSlot[]), "12345")) : (kvSuperTanks.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot2[iIndex], sizeof(g_sEnforceSlot2[]), g_sEnforceSlot[iIndex]));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Death(int client)
{
	int iEnforceAbility = !g_bTankConfig[ST_TankType(client)] ? g_iEnforceAbility[ST_TankType(client)] : g_iEnforceAbility2[ST_TankType(client)];
	if (ST_TankAllowed(client) && iEnforceAbility == 1)
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor) && g_bEnforce[iSurvivor])
			{
				g_bEnforce[iSurvivor] = false;
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client))
	{
		int iEnforceAbility = !g_bTankConfig[ST_TankType(client)] ? g_iEnforceAbility[ST_TankType(client)] : g_iEnforceAbility2[ST_TankType(client)];
		int iEnforceRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iEnforceChance[ST_TankType(client)] : g_iEnforceChance2[ST_TankType(client)];
		float flEnforceRange = !g_bTankConfig[ST_TankType(client)] ? g_flEnforceRange[ST_TankType(client)] : g_flEnforceRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flEnforceRange)
				{
					vEnforceHit(iSurvivor, client, iEnforceRangeChance, iEnforceAbility);
				}
			}
		}
	}
}

void vEnforceHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bEnforce[client])
	{
		g_bEnforce[client] = true;
		char sNumbers = !g_bTankConfig[ST_TankType(owner)] ? g_sEnforceSlot[ST_TankType(owner)][GetRandomInt(0, strlen(g_sEnforceSlot[ST_TankType(owner)]) - 1)] : g_sEnforceSlot2[ST_TankType(owner)][GetRandomInt(0, strlen(g_sEnforceSlot2[ST_TankType(owner)]) - 1)];
		switch (sNumbers)
		{
			case '1': g_iEnforceSlot[client] = 0;
			case '2': g_iEnforceSlot[client] = 1;
			case '3': g_iEnforceSlot[client] = 2;
			case '4': g_iEnforceSlot[client] = 3;
			case '5': g_iEnforceSlot[client] = 4;
		}
		float flEnforceDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flEnforceDuration[ST_TankType(owner)] : g_flEnforceDuration2[ST_TankType(owner)];
		DataPack dpDataPack;
		CreateDataTimer(flEnforceDuration, tTimerStopEnforce, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerStopEnforce(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iEnforceAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iEnforceAbility[ST_TankType(iTank)] : g_iEnforceAbility2[ST_TankType(iTank)];
	if (iEnforceAbility == 0 || iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor))
	{
		g_bEnforce[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bEnforce[iSurvivor] = false;
	}
	return Plugin_Continue;
}