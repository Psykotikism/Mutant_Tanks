// Super Tanks++: Fragile Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Fragile Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bFragile[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flFragileDuration[ST_MAXTYPES + 1];
float g_flFragileDuration2[ST_MAXTYPES + 1];
int g_iFragileAbility[ST_MAXTYPES + 1];
int g_iFragileAbility2[ST_MAXTYPES + 1];
int g_iFragileChance[ST_MAXTYPES + 1];
int g_iFragileChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Fragile Ability only supports Left 4 Dead 1 & 2.");
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
			g_bFragile[iPlayer] = false;
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
	g_bFragile[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bFragile[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bFragile[iPlayer] = false;
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
		if (ST_TankAllowed(victim) && IsPlayerAlive(victim) && g_bFragile[victim])
		{
			int iHealth = GetClientHealth(victim);
			if (damagetype & DMG_BULLET || damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
			{
				damage = damage * 5;
			}
			(iHealth > damage) ? SetEntityHealth(victim, iHealth - RoundFloat(damage)) : SetEntProp(victim, Prop_Send, "m_isIncapacitated", 1);
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
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
			main ? (g_iFragileAbility[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Enabled", 0)) : (g_iFragileAbility2[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Enabled", g_iFragileAbility[iIndex]));
			main ? (g_iFragileAbility[iIndex] = iSetCellLimit(g_iFragileAbility[iIndex], 0, 1)) : (g_iFragileAbility2[iIndex] = iSetCellLimit(g_iFragileAbility2[iIndex], 0, 1));
			main ? (g_iFragileChance[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Fragile Chance", 4)) : (g_iFragileChance2[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Fragile Chance", g_iFragileChance[iIndex]));
			main ? (g_iFragileChance[iIndex] = iSetCellLimit(g_iFragileChance[iIndex], 1, 9999999999)) : (g_iFragileChance2[iIndex] = iSetCellLimit(g_iFragileChance2[iIndex], 1, 9999999999));
			main ? (g_flFragileDuration[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Duration", 5.0)) : (g_flFragileDuration2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Duration", g_flFragileDuration[iIndex]));
			main ? (g_flFragileDuration[iIndex] = flSetFloatLimit(g_flFragileDuration[iIndex], 0.1, 9999999999.0)) : (g_flFragileDuration2[iIndex] = flSetFloatLimit(g_flFragileDuration2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iFragileAbility = !g_bTankConfig[ST_TankType(client)] ? g_iFragileAbility[ST_TankType(client)] : g_iFragileAbility2[ST_TankType(client)];
	int iFragileChance = !g_bTankConfig[ST_TankType(client)] ? g_iFragileChance[ST_TankType(client)] : g_iFragileChance2[ST_TankType(client)];
	if (iFragileAbility == 1 && GetRandomInt(1, iFragileChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bFragile[client])
	{
		g_bFragile[client] = true;
		float flFragileDuration = !g_bTankConfig[ST_TankType(client)] ? g_flFragileDuration[ST_TankType(client)] : g_flFragileDuration2[ST_TankType(client)];
		CreateTimer(flFragileDuration, tTimerStopFragile, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerStopFragile(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iFragileAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iFragileAbility[ST_TankType(iTank)] : g_iFragileAbility2[ST_TankType(iTank)];
	if (iFragileAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bFragile[iTank] = false;
		return Plugin_Stop;
	}
	if (ST_TankAllowed(iTank))
	{
		g_bFragile[iTank] = false;
	}
	return Plugin_Continue;
}