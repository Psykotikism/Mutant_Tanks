// Super Tanks++: Nullify Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Nullify Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bNullify[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flNullifyDuration[ST_MAXTYPES + 1];
float g_flNullifyDuration2[ST_MAXTYPES + 1];
float g_flNullifyRange[ST_MAXTYPES + 1];
float g_flNullifyRange2[ST_MAXTYPES + 1];
int g_iNullifyAbility[ST_MAXTYPES + 1];
int g_iNullifyAbility2[ST_MAXTYPES + 1];
int g_iNullifyChance[ST_MAXTYPES + 1];
int g_iNullifyChance2[ST_MAXTYPES + 1];
int g_iNullifyHit[ST_MAXTYPES + 1];
int g_iNullifyHit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Nullify Ability only supports Left 4 Dead 1 & 2.");
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
			g_bNullify[iPlayer] = false;
		}
	}
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnConfigsExecuted()
{
	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (IsMapValid(sMapName))
	{
		vIsPluginAllowed();
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bNullify[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bNullify[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bNullify[iPlayer] = false;
		}
	}
}

void vIsPluginAllowed()
{
	ST_PluginEnabled() ? vHookEvent(true) : vHookEvent(false);
}

void vHookEvent(bool hook)
{
	static bool hooked;
	if (hook && !hooked)
	{
		HookEvent("player_death", eEventPlayerDeath);
		hooked = true;
	}
	else if (!hook && hooked)
	{
		UnhookEvent("player_death", eEventPlayerDeath);
		hooked = false;
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
				int iNullifyHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iNullifyHit[ST_TankType(attacker)] : g_iNullifyHit2[ST_TankType(attacker)];
				vNullifyHit(victim, attacker, iNullifyHit);
			}
		}
		else if (bIsTank(victim) && bIsSurvivor(attacker) && g_bNullify[attacker])
		{
			damage = 0.0;
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action eEventPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iPlayer = GetClientOfUserId(iUserId);
	if (bIsTank(iPlayer))
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor) && g_bNullify[iSurvivor])
			{
				g_bNullify[iSurvivor] = false;
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
			main ? (g_iNullifyAbility[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", 0)) : (g_iNullifyAbility2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", g_iNullifyAbility[iIndex]));
			main ? (g_iNullifyAbility[iIndex] = iSetCellLimit(g_iNullifyAbility[iIndex], 0, 1)) : (g_iNullifyAbility2[iIndex] = iSetCellLimit(g_iNullifyAbility2[iIndex], 0, 1));
			main ? (g_iNullifyChance[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Chance", 4)) : (g_iNullifyChance2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Chance", g_iNullifyChance[iIndex]));
			main ? (g_iNullifyChance[iIndex] = iSetCellLimit(g_iNullifyChance[iIndex], 1, 9999999999)) : (g_iNullifyChance2[iIndex] = iSetCellLimit(g_iNullifyChance2[iIndex], 1, 9999999999));
			main ? (g_flNullifyDuration[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", 5.0)) : (g_flNullifyDuration2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", g_flNullifyDuration[iIndex]));
			main ? (g_flNullifyDuration[iIndex] = flSetFloatLimit(g_flNullifyDuration[iIndex], 0.1, 9999999999.0)) : (g_flNullifyDuration2[iIndex] = flSetFloatLimit(g_flNullifyDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iNullifyHit[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", 0)) : (g_iNullifyHit2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", g_iNullifyHit[iIndex]));
			main ? (g_iNullifyHit[iIndex] = iSetCellLimit(g_iNullifyHit[iIndex], 0, 1)) : (g_iNullifyHit2[iIndex] = iSetCellLimit(g_iNullifyHit2[iIndex], 0, 1));
			main ? (g_flNullifyRange[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", 150.0)) : (g_flNullifyRange2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", g_flNullifyRange[iIndex]));
			main ? (g_flNullifyRange[iIndex] = flSetFloatLimit(g_flNullifyRange[iIndex], 1.0, 9999999999.0)) : (g_flNullifyRange2[iIndex] = flSetFloatLimit(g_flNullifyRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		int iNullifyAbility = !g_bTankConfig[ST_TankType(client)] ? g_iNullifyAbility[ST_TankType(client)] : g_iNullifyAbility2[ST_TankType(client)];
		float flNullifyRange = !g_bTankConfig[ST_TankType(client)] ? g_flNullifyRange[ST_TankType(client)] : g_flNullifyRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flNullifyRange)
				{
					vNullifyHit(iSurvivor, client, iNullifyAbility);
				}
			}
		}
	}
}

void vNullifyHit(int client, int owner, int enabled)
{
	int iNullifyChance = !g_bTankConfig[ST_TankType(owner)] ? g_iNullifyChance[ST_TankType(owner)] : g_iNullifyChance2[ST_TankType(owner)];
	if (enabled == 1 && GetRandomInt(1, iNullifyChance) == 1 && bIsSurvivor(client) && !g_bNullify[client])
	{
		g_bNullify[client] = true;
		float flNullifyDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flNullifyDuration[ST_TankType(owner)] : g_flNullifyDuration2[ST_TankType(owner)];
		CreateTimer(flNullifyDuration, tTimerStopNullify, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action tTimerStopNullify(Handle timer, any userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (iSurvivor == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor))
	{
		g_bNullify[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bNullify[iSurvivor] = false;
	}
	return Plugin_Continue;
}