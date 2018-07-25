// Super Tanks++: Panic Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Panic Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bPanic[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flPanicInterval[ST_MAXTYPES + 1];
float g_flPanicInterval2[ST_MAXTYPES + 1];
int g_iPanicAbility[ST_MAXTYPES + 1];
int g_iPanicAbility2[ST_MAXTYPES + 1];
int g_iPanicChance[ST_MAXTYPES + 1];
int g_iPanicChance2[ST_MAXTYPES + 1];
int g_iPanicHit[ST_MAXTYPES + 1];
int g_iPanicHit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Panic Ability only supports Left 4 Dead 1 & 2.");
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
			g_bPanic[iPlayer] = false;
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
	g_bPanic[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bPanic[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPanic[iPlayer] = false;
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
				vPanicHit(attacker);
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
			main ? (g_iPanicAbility[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", 0)) : (g_iPanicAbility2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", g_iPanicAbility[iIndex]));
			main ? (g_iPanicAbility[iIndex] = iSetCellLimit(g_iPanicAbility[iIndex], 0, 1)) : (g_iPanicAbility2[iIndex] = iSetCellLimit(g_iPanicAbility2[iIndex], 0, 1));
			main ? (g_iPanicChance[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Chance", 4)) : (g_iPanicChance2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Chance", g_iPanicChance[iIndex]));
			main ? (g_iPanicChance[iIndex] = iSetCellLimit(g_iPanicChance[iIndex], 1, 9999999999)) : (g_iPanicChance2[iIndex] = iSetCellLimit(g_iPanicChance2[iIndex], 1, 9999999999));
			main ? (g_iPanicHit[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit", 0)) : (g_iPanicHit2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit", g_iPanicHit[iIndex]));
			main ? (g_iPanicHit[iIndex] = iSetCellLimit(g_iPanicHit[iIndex], 0, 1)) : (g_iPanicHit2[iIndex] = iSetCellLimit(g_iPanicHit2[iIndex], 0, 1));
			main ? (g_flPanicInterval[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", 5.0)) : (g_flPanicInterval2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", g_flPanicInterval[iIndex]));
			main ? (g_flPanicInterval[iIndex] = flSetFloatLimit(g_flPanicInterval[iIndex], 0.1, 9999999999.0)) : (g_flPanicInterval2[iIndex] = flSetFloatLimit(g_flPanicInterval2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iPanicAbility = !g_bTankConfig[ST_TankType(client)] ? g_iPanicAbility[ST_TankType(client)] : g_iPanicAbility2[ST_TankType(client)];
	if (iPanicAbility == 1 && bIsTank(client) && !g_bPanic[client])
	{
		g_bPanic[client] = true;
		float flPanicInterval = !g_bTankConfig[ST_TankType(client)] ? g_flPanicInterval[ST_TankType(client)] : g_flPanicInterval2[ST_TankType(client)];
		CreateTimer(flPanicInterval, tTimerPanic, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void vPanicHit(int client)
{
	int iPanicChance = !g_bTankConfig[ST_TankType(client)] ? g_iPanicChance[ST_TankType(client)] : g_iPanicChance2[ST_TankType(client)];
	int iPanicHit = !g_bTankConfig[ST_TankType(client)] ? g_iPanicHit[ST_TankType(client)] : g_iPanicHit2[ST_TankType(client)];
	if (iPanicHit == 1 && GetRandomInt(1, iPanicChance) == 1 && bIsTank(client))
	{
		vPanic();
	}
}

void vPanic()
{
	int iDirector = CreateEntityByName("info_director");
	if (bIsValidEntity(iDirector))
	{
		DispatchSpawn(iDirector);
		AcceptEntityInput(iDirector, "ForcePanicEvent");
		AcceptEntityInput(iDirector, "Kill");
	}
}

public Action tTimerPanic(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bPanic[iTank] = false;
		return Plugin_Stop;
	}
	if (bIsTank(iTank))
	{
		vPanic();
	}
	return Plugin_Continue;
}