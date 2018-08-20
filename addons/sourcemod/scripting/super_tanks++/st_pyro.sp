// Super Tanks++: Pyro Ability
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Pyro Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flPyroBoost[ST_MAXTYPES + 1], g_flPyroBoost2[ST_MAXTYPES + 1], g_flRunSpeed[ST_MAXTYPES + 1],
	g_flRunSpeed2[ST_MAXTYPES + 1];
int g_iPyroAbility[ST_MAXTYPES + 1], g_iPyroAbility2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if ((evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2) || !IsDedicatedServer())
	{
		strcopy(error, err_max, "[ST++] Pyro Ability only supports Left 4 Dead 1 & 2 Dedicated Servers.");
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
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && IsPlayerAlive(victim))
		{
			int iPyroAbility = !g_bTankConfig[ST_TankType(victim)] ? g_iPyroAbility[ST_TankType(victim)] : g_iPyroAbility2[ST_TankType(victim)];
			float flPyroBoost = !g_bTankConfig[ST_TankType(victim)] ? g_flPyroBoost[ST_TankType(victim)] : g_flPyroBoost2[ST_TankType(victim)];
			float flRunSpeed = !g_bTankConfig[ST_TankType(victim)] ? g_flRunSpeed[ST_TankType(victim)] : g_flRunSpeed2[ST_TankType(victim)];
			if (damagetype & DMG_BURN && iPyroAbility == 1)
			{
				SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", flRunSpeed + flPyroBoost);
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
			main ? (g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", 1.0)) : (g_flRunSpeed2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", g_flRunSpeed[iIndex]));
			main ? (g_flRunSpeed[iIndex] = flSetFloatLimit(g_flRunSpeed[iIndex], 0.1, 3.0)) : (g_flRunSpeed2[iIndex] = flSetFloatLimit(g_flRunSpeed2[iIndex], 0.1, 3.0));
			main ? (g_iPyroAbility[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", 0)) : (g_iPyroAbility2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", g_iPyroAbility[iIndex]));
			main ? (g_iPyroAbility[iIndex] = iSetCellLimit(g_iPyroAbility[iIndex], 0, 1)) : (g_iPyroAbility2[iIndex] = iSetCellLimit(g_iPyroAbility2[iIndex], 0, 1));
			main ? (g_flPyroBoost[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Boost", 1.0)) : (g_flPyroBoost2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Boost", g_flPyroBoost[iIndex]));
			main ? (g_flPyroBoost[iIndex] = flSetFloatLimit(g_flPyroBoost[iIndex], 0.1, 3.0)) : (g_flPyroBoost2[iIndex] = flSetFloatLimit(g_flPyroBoost2[iIndex], 0.1, 3.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}