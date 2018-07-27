// Super Tanks++: Invert Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Invert Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bInvert[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flInvertDuration[ST_MAXTYPES + 1];
float g_flInvertDuration2[ST_MAXTYPES + 1];
float g_flInvertRange[ST_MAXTYPES + 1];
float g_flInvertRange2[ST_MAXTYPES + 1];
int g_iInvertAbility[ST_MAXTYPES + 1];
int g_iInvertAbility2[ST_MAXTYPES + 1];
int g_iInvertChance[ST_MAXTYPES + 1];
int g_iInvertChance2[ST_MAXTYPES + 1];
int g_iInvertHit[ST_MAXTYPES + 1];
int g_iInvertHit2[ST_MAXTYPES + 1];
int g_iInvertRangeChance[ST_MAXTYPES + 1];
int g_iInvertRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Invert Ability only supports Left 4 Dead 1 & 2.");
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
			g_bInvert[iPlayer] = false;
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
	g_bInvert[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bInvert[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bInvert[iPlayer] = false;
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
	if (bIsSurvivor(client) && g_bInvert[client])
	{
		vel[0] = -vel[0];
		if (buttons & IN_FORWARD)
		{
			buttons &= ~IN_FORWARD;
			buttons |= IN_BACK;
		}
		else if (buttons & IN_BACK)
		{
			buttons &= ~IN_BACK;
			buttons |= IN_FORWARD;
		}
		vel[1] = -vel[1];
		if (buttons & IN_MOVELEFT)
		{
			buttons &= ~IN_MOVELEFT;
			buttons |= IN_MOVERIGHT;
		}
		else if (buttons & IN_MOVERIGHT)
		{
			buttons &= ~IN_MOVERIGHT;
			buttons |= IN_MOVELEFT;
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
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
				int iInvertChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iInvertChance[ST_TankType(attacker)] : g_iInvertChance2[ST_TankType(attacker)];
				int iInvertHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iInvertHit[ST_TankType(attacker)] : g_iInvertHit2[ST_TankType(attacker)];
				vInvertHit(victim, attacker, iInvertChance, iInvertHit);
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
			main ? (g_iInvertAbility[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", 0)) : (g_iInvertAbility2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", g_iInvertAbility[iIndex]));
			main ? (g_iInvertAbility[iIndex] = iSetCellLimit(g_iInvertAbility[iIndex], 0, 1)) : (g_iInvertAbility2[iIndex] = iSetCellLimit(g_iInvertAbility2[iIndex], 0, 1));
			main ? (g_iInvertChance[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Chance", 4)) : (g_iInvertChance2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Chance", g_iInvertChance[iIndex]));
			main ? (g_iInvertChance[iIndex] = iSetCellLimit(g_iInvertChance[iIndex], 1, 9999999999)) : (g_iInvertChance2[iIndex] = iSetCellLimit(g_iInvertChance2[iIndex], 1, 9999999999));
			main ? (g_flInvertDuration[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Duration", 5.0)) : (g_flInvertDuration2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Duration", g_flInvertDuration[iIndex]));
			main ? (g_flInvertDuration[iIndex] = flSetFloatLimit(g_flInvertDuration[iIndex], 0.1, 9999999999.0)) : (g_flInvertDuration2[iIndex] = flSetFloatLimit(g_flInvertDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iInvertHit[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit", 0)) : (g_iInvertHit2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit", g_iInvertHit[iIndex]));
			main ? (g_iInvertHit[iIndex] = iSetCellLimit(g_iInvertHit[iIndex], 0, 1)) : (g_iInvertHit2[iIndex] = iSetCellLimit(g_iInvertHit2[iIndex], 0, 1));
			main ? (g_flInvertRange[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range", 150.0)) : (g_flInvertRange2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range", g_flInvertRange[iIndex]));
			main ? (g_flInvertRange[iIndex] = flSetFloatLimit(g_flInvertRange[iIndex], 1.0, 9999999999.0)) : (g_flInvertRange2[iIndex] = flSetFloatLimit(g_flInvertRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iInvertRangeChance[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Range Chance", 16)) : (g_iInvertRangeChance2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Range Chance", g_iInvertRangeChance[iIndex]));
			main ? (g_iInvertRangeChance[iIndex] = iSetCellLimit(g_iInvertRangeChance[iIndex], 1, 9999999999)) : (g_iInvertRangeChance2[iIndex] = iSetCellLimit(g_iInvertRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Death(int client)
{
	if (bIsTank(client))
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor) && g_bInvert[iSurvivor])
			{
				g_bInvert[iSurvivor] = false;
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		int iInvertAbility = !g_bTankConfig[ST_TankType(client)] ? g_iInvertAbility[ST_TankType(client)] : g_iInvertAbility2[ST_TankType(client)];
		int iInvertRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iInvertChance[ST_TankType(client)] : g_iInvertChance2[ST_TankType(client)];
		float flInvertRange = !g_bTankConfig[ST_TankType(client)] ? g_flInvertRange[ST_TankType(client)] : g_flInvertRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flInvertRange)
				{
					vInvertHit(iSurvivor, client, iInvertRangeChance, iInvertAbility);
				}
			}
		}
	}
}

void vInvertHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bInvert[client])
	{
		g_bInvert[client] = true;
		float flInvertDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flInvertDuration[ST_TankType(owner)] : g_flInvertDuration2[ST_TankType(owner)];
		CreateTimer(flInvertDuration, tTimerStopInvert, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerStopInvert(Handle timer, any userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (iSurvivor == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor))
	{
		g_bInvert[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bInvert[iSurvivor] = false;
	}
	return Plugin_Continue;
}