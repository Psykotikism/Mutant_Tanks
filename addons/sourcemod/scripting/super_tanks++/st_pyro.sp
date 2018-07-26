// Super Tanks++: Pyro Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Pyro Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bTankConfig[ST_MAXTYPES + 1];
bool g_bPyro[MAXPLAYERS + 1];
float g_flPyroBoost[ST_MAXTYPES + 1];
float g_flPyroBoost2[ST_MAXTYPES + 1];
int g_iPyroAbility[ST_MAXTYPES + 1];
int g_iPyroAbility2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Pyro Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
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
			g_bPyro[iPlayer] = false;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	g_bPyro[client] = false;
}

public void OnClientDisconnect(int client)
{
	g_bPyro[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPyro[iPlayer] = false;
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
			main ? (g_iPyroAbility[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", 0)) : (g_iPyroAbility2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", g_iPyroAbility[iIndex]));
			main ? (g_iPyroAbility[iIndex] = iSetCellLimit(g_iPyroAbility[iIndex], 0, 1)) : (g_iPyroAbility2[iIndex] = iSetCellLimit(g_iPyroAbility2[iIndex], 0, 1));
			main ? (g_flPyroBoost[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Boost", 1.0)) : (g_flPyroBoost2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Boost", g_flPyroBoost[iIndex]));
			main ? (g_flPyroBoost[iIndex] = flSetFloatLimit(g_flPyroBoost[iIndex], 0.1, 3.0)) : (g_flPyroBoost2[iIndex] = flSetFloatLimit(g_flPyroBoost2[iIndex], 0.1, 3.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Spawn(int client)
{
	int iPyroAbility = !g_bTankConfig[ST_TankType(client)] ? g_iPyroAbility[ST_TankType(client)] : g_iPyroAbility2[ST_TankType(client)];
	if (iPyroAbility == 1 && bIsTank(client))
	{
		CreateTimer(1.0, tTimerPyro, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

bool bIsPlayerFired(int client)
{
	if (GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONFIRE)
	{
		return true;
	}
	return false;
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerPyro(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iPyroAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iPyroAbility[ST_TankType(iTank)] : g_iPyroAbility2[ST_TankType(iTank)];
	if (iPyroAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bPyro[iTank] = false;
		return Plugin_Stop;
	}
	if (bIsTank(iTank))
	{
		float flPyroBoost = !g_bTankConfig[ST_TankType(iTank)] ? g_flPyroBoost[ST_TankType(iTank)] : g_flPyroBoost2[ST_TankType(iTank)];
		if (bIsPlayerFired(iTank) && !g_bPyro[iTank])
		{
			g_bPyro[iTank] = true;
			float flCurrentSpeed = GetEntPropFloat(iTank, Prop_Data, "m_flLaggedMovementValue");
			SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", flCurrentSpeed + flPyroBoost);
		}
		else if (g_bPyro[iTank])
		{
			g_bPyro[iTank] = false;
			float flCurrentSpeed = GetEntPropFloat(iTank, Prop_Data, "m_flLaggedMovementValue");
			SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", flCurrentSpeed - flPyroBoost);
		}
	}
	return Plugin_Continue;
}