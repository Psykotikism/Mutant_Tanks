// Super Tanks++: Idle Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Idle Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bIdle[MAXPLAYERS + 1];
bool g_bIdled[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flIdleRange[ST_MAXTYPES + 1];
float g_flIdleRange2[ST_MAXTYPES + 1];
Handle g_hSDKIdlePlayer;
Handle g_hSDKSpecPlayer;
int g_iIdleAbility[ST_MAXTYPES + 1];
int g_iIdleAbility2[ST_MAXTYPES + 1];
int g_iIdleChance[ST_MAXTYPES + 1];
int g_iIdleChance2[ST_MAXTYPES + 1];
int g_iIdleHit[ST_MAXTYPES + 1];
int g_iIdleHit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Fling Ability only supports Left 4 Dead 1 & 2.");
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

public void OnPluginStart()
{
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::GoAwayFromKeyboard");
	g_hSDKIdlePlayer = EndPrepSDKCall();
	if (g_hSDKIdlePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer::GoAwayFromKeyboard\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SetHumanSpec");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	g_hSDKSpecPlayer = EndPrepSDKCall();
	if (g_hSDKSpecPlayer == null)
	{
		PrintToServer("%s Your \"SetHumanSpec\" signature is outdated.", ST_PREFIX);
	}
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bIdle[iPlayer] = false;
			g_bIdled[iPlayer] = false;
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
	g_bIdle[client] = false;
	g_bIdled[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bIdle[client] = false;
	g_bIdled[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bIdle[iPlayer] = false;
			g_bIdled[iPlayer] = false;
		}
	}
}

void vIsPluginAllowed()
{
	ST_PluginEnabled() ? vHookEvents(true) : vHookEvents(false);
}

void vHookEvents(bool hook)
{
	static bool hooked;
	if (hook && !hooked)
	{
		HookEvent("player_afk", eEventPlayerAFK, EventHookMode_Pre);
		HookEvent("player_bot_replace", eEventPlayerBotReplace);
		hooked = true;
	}
	else if (!hook && hooked)
	{
		UnhookEvent("player_afk", eEventPlayerAFK);
		UnhookEvent("player_bot_replace", eEventPlayerBotReplace);
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
				int iIdleHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iIdleHit[ST_TankType(attacker)] : g_iIdleHit2[ST_TankType(attacker)];
				vIdleHit(victim, attacker, iIdleHit);
			}
		}
	}
}

public Action eEventPlayerAFK(Event event, const char[] name, bool dontBroadcast)
{
	int iPlayerId = event.GetInt("player");
	int iIdler = GetClientOfUserId(iPlayerId);
	g_bIdled[iIdler] = true;
}

public Action eEventPlayerBotReplace(Event event, const char[] name, bool dontBroadcast)
{
	int iSurvivorId = event.GetInt("player");
	int iSurvivor = GetClientOfUserId(iSurvivorId);
	int iBotId = event.GetInt("bot");
	int iBot = GetClientOfUserId(iBotId);
	if (bIsIdlePlayer(iBot, iSurvivor)) 
	{
		vIdle(iSurvivor, iBot);
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
			main ? (g_iIdleAbility[iIndex] = kvSuperTanks.GetNum("Idle Ability/Ability Enabled", 0)) : (g_iIdleAbility2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Ability Enabled", g_iIdleAbility[iIndex]));
			main ? (g_iIdleAbility[iIndex] = iSetCellLimit(g_iIdleAbility[iIndex], 0, 1)) : (g_iIdleAbility2[iIndex] = iSetCellLimit(g_iIdleAbility2[iIndex], 0, 1));
			main ? (g_iIdleChance[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Chance", 4)) : (g_iIdleChance2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Chance", g_iIdleChance[iIndex]));
			main ? (g_iIdleChance[iIndex] = iSetCellLimit(g_iIdleChance[iIndex], 1, 9999999999)) : (g_iIdleChance2[iIndex] = iSetCellLimit(g_iIdleChance2[iIndex], 1, 9999999999));
			main ? (g_iIdleHit[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Hit", 0)) : (g_iIdleHit2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Hit", g_iIdleHit[iIndex]));
			main ? (g_iIdleHit[iIndex] = iSetCellLimit(g_iIdleHit[iIndex], 0, 1)) : (g_iIdleHit2[iIndex] = iSetCellLimit(g_iIdleHit2[iIndex], 0, 1));
			main ? (g_flIdleRange[iIndex] = kvSuperTanks.GetFloat("Idle Ability/Idle Range", 150.0)) : (g_flIdleRange2[iIndex] = kvSuperTanks.GetFloat("Idle Ability/Idle Range", g_flIdleRange[iIndex]));
			main ? (g_flIdleRange[iIndex] = flSetFloatLimit(g_flIdleRange[iIndex], 1.0, 9999999999.0)) : (g_flIdleRange2[iIndex] = flSetFloatLimit(g_flIdleRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		int iIdleAbility = !g_bTankConfig[ST_TankType(client)] ? g_iIdleAbility[ST_TankType(client)] : g_iIdleAbility2[ST_TankType(client)];
		float flIdleRange = !g_bTankConfig[ST_TankType(client)] ? g_flIdleRange[ST_TankType(client)] : g_flIdleRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flIdleRange)
				{
					vIdleHit(iSurvivor, client, iIdleAbility);
				}
			}
		}
	}
}

void vIdle(int client, int bot)
{
	DataPack dpDataPack;
	CreateDataTimer(0.2, tTimerIdleFix, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
	dpDataPack.WriteCell(GetClientUserId(client));
	dpDataPack.WriteCell(GetClientUserId(bot));
	if (g_bIdle[client])
	{
		g_bIdle[client] = false;
		vIdleWarp(bot);
	}
}

void vIdleHit(int client, int owner, int enabled)
{
	int iIdleChance = !g_bTankConfig[ST_TankType(owner)] ? g_iIdleChance[ST_TankType(owner)] : g_iIdleChance2[ST_TankType(owner)];
	if (enabled == 1 && GetRandomInt(1, iIdleChance) == 1 && bIsHumanSurvivor(client) && !g_bIdle[client])
	{
		if (iGetHumanCount() > 1)
		{
			FakeClientCommand(client, "go_away_from_keyboard");
		}
		else
		{
			vIdleWarp(client);
			SDKCall(g_hSDKIdlePlayer, client);
		}
		if (bIsBotIdle(client))
		{
			g_bIdled[client] = true;
			g_bIdle[client] = true;
		}
	}
}

void vIdleWarp(int client)
{
	float flCurrentOrigin[3];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!bIsSurvivor(iPlayer) || iPlayer == client)
		{
			continue;
		}
		GetClientAbsOrigin(iPlayer, flCurrentOrigin);
		TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
	}
}

int iGetBotSurvivor()
{
	for (int iBot = MaxClients; iBot >= 1; iBot--)
	{
		if (bIsBotSurvivor(iBot))
		{
			return iBot;
		}
	}
	return -1;
}

int iGetHumanCount()
{
	int iHumanCount;
	for (int iHuman = 1; iHuman <= MaxClients; iHuman++)
	{
		if (bIsHumanSurvivor(iHuman))
		{
			iHumanCount++;
		}
	}
	return iHumanCount;
}

int iGetIdleBot(int client)
{
	for (int iBot = 1; iBot <= MaxClients; iBot++)
	{
		if (iGetIdlePlayer(iBot) == client)
		{
			return iBot;
		}
	}
	return 0;
}

int iGetIdlePlayer(int client)
{
	if (bIsBotSurvivor(client))
	{
		char sClassname[12];
		GetEntityNetClass(client, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "SurvivorBot") == 0)
		{
			int iIdler = GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));
			if (iIdler > 0 && IsClientInGame(iIdler) && GetClientTeam(iIdler) == 1)
			{
				return iIdler;
			}
		}
	}
	return 0;
}

bool bHasIdlePlayer(int client)
{
	int iIdler = GetClientOfUserId(GetEntData(client, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID")));
	if (iIdler)
	{
		if (IsClientInGame(iIdler) && !IsFakeClient(iIdler) && (GetClientTeam(iIdler) != 2))
		{
			return true;
		}
	}
	return false;
}

bool bIsBotIdle(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && IsFakeClient(client) && bHasIdlePlayer(client);
}

bool bIsBotIdleSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && IsFakeClient(client) && !bHasIdlePlayer(client);
}

bool bIsBotSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && IsFakeClient(client);
}

bool bIsHumanSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && !IsFakeClient(client) && !bHasIdlePlayer(client) && !bIsPlayerIdle(client);
}

bool bIsIdlePlayer(int bot, int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(bot) == 2;
}

bool bIsPlayerIdle(int client)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!IsClientInGame(iPlayer) || GetClientTeam(iPlayer) != 2 || !IsFakeClient(iPlayer) || !bHasIdlePlayer(iPlayer))
		{
			continue;
		}
		int iIdler = GetClientOfUserId(GetEntData(iPlayer, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID")));
		if (iIdler == client)
		{
			return true;
		}
	}
	return false;
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerIdleFix(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iBot = GetClientOfUserId(pack.ReadCell());
	if (iSurvivor == 0 || iBot == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor) || !IsClientInGame(iBot) || !IsPlayerAlive(iSurvivor))
	{
		return Plugin_Stop;
	}
	if (GetClientTeam(iSurvivor) != 1 || iGetIdleBot(iSurvivor) || IsFakeClient(iSurvivor))
	{
		g_bIdled[iSurvivor] = false;
	}
	if (!bIsBotIdleSurvivor(iBot) || GetClientTeam(iBot) != 2)
	{
		iBot = iGetBotSurvivor();
	}
	if (iBot < 1)
	{
		g_bIdled[iSurvivor] = false;
	}
	if (g_bIdled[iSurvivor])
	{
		g_bIdled[iSurvivor] = false;
		SDKCall(g_hSDKSpecPlayer, iBot, iSurvivor);
		SetEntProp(iSurvivor, Prop_Send, "m_iObserverMode", 5);
	}
	return Plugin_Continue;
}