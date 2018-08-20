// Super Tanks++: Idle Ability
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Idle Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bIdle[MAXPLAYERS + 1], g_bIdled[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flIdleRange[ST_MAXTYPES + 1], g_flIdleRange2[ST_MAXTYPES + 1];
Handle g_hSDKIdlePlayer, g_hSDKSpecPlayer;
int g_iIdleAbility[ST_MAXTYPES + 1], g_iIdleAbility2[ST_MAXTYPES + 1],
	g_iIdleChance[ST_MAXTYPES + 1], g_iIdleChance2[ST_MAXTYPES + 1], g_iIdleHit[ST_MAXTYPES + 1],
	g_iIdleHit2[ST_MAXTYPES + 1], g_iIdleRangeChance[ST_MAXTYPES + 1],
	g_iIdleRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if ((evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2) || !IsDedicatedServer())
	{
		strcopy(error, err_max, "[ST++] Idle Ability only supports Left 4 Dead 1 & 2 Dedicated Servers.");
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
	g_bIdle[client] = false;
	g_bIdled[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iIdleChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iIdleChance[ST_TankType(attacker)] : g_iIdleChance2[ST_TankType(attacker)];
				int iIdleHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iIdleHit[ST_TankType(attacker)] : g_iIdleHit2[ST_TankType(attacker)];
				vIdleHit(victim, iIdleChance, iIdleHit);
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
			main ? (g_iIdleAbility[iIndex] = kvSuperTanks.GetNum("Idle Ability/Ability Enabled", 0)) : (g_iIdleAbility2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Ability Enabled", g_iIdleAbility[iIndex]));
			main ? (g_iIdleAbility[iIndex] = iSetCellLimit(g_iIdleAbility[iIndex], 0, 1)) : (g_iIdleAbility2[iIndex] = iSetCellLimit(g_iIdleAbility2[iIndex], 0, 1));
			main ? (g_iIdleChance[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Chance", 4)) : (g_iIdleChance2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Chance", g_iIdleChance[iIndex]));
			main ? (g_iIdleChance[iIndex] = iSetCellLimit(g_iIdleChance[iIndex], 1, 9999999999)) : (g_iIdleChance2[iIndex] = iSetCellLimit(g_iIdleChance2[iIndex], 1, 9999999999));
			main ? (g_iIdleHit[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Hit", 0)) : (g_iIdleHit2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Hit", g_iIdleHit[iIndex]));
			main ? (g_iIdleHit[iIndex] = iSetCellLimit(g_iIdleHit[iIndex], 0, 1)) : (g_iIdleHit2[iIndex] = iSetCellLimit(g_iIdleHit2[iIndex], 0, 1));
			main ? (g_flIdleRange[iIndex] = kvSuperTanks.GetFloat("Idle Ability/Idle Range", 150.0)) : (g_flIdleRange2[iIndex] = kvSuperTanks.GetFloat("Idle Ability/Idle Range", g_flIdleRange[iIndex]));
			main ? (g_flIdleRange[iIndex] = flSetFloatLimit(g_flIdleRange[iIndex], 1.0, 9999999999.0)) : (g_flIdleRange2[iIndex] = flSetFloatLimit(g_flIdleRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iIdleRangeChance[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Range Chance", 16)) : (g_iIdleRangeChance2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Range Chance", g_iIdleRangeChance[iIndex]));
			main ? (g_iIdleRangeChance[iIndex] = iSetCellLimit(g_iIdleRangeChance[iIndex], 1, 9999999999)) : (g_iIdleRangeChance2[iIndex] = iSetCellLimit(g_iIdleRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_afk") == 0)
	{
		int iPlayerId = event.GetInt("player");
		int iIdler = GetClientOfUserId(iPlayerId);
		g_bIdled[iIdler] = true;
	}
	else if (strcmp(name, "player_bot_replace") == 0)
	{
		int iSurvivorId = event.GetInt("player");
		int iSurvivor = GetClientOfUserId(iSurvivorId);
		int iBotId = event.GetInt("bot");
		int iBot = GetClientOfUserId(iBotId);
		if (bIsIdlePlayer(iBot, iSurvivor)) 
		{
			DataPack dpDataPack = new DataPack();
			CreateDataTimer(0.2, tTimerIdleFix, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
			dpDataPack.WriteCell(iSurvivorId);
			dpDataPack.WriteCell(iBotId);
			if (g_bIdle[iSurvivor])
			{
				g_bIdle[iSurvivor] = false;
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iIdleAbility = !g_bTankConfig[ST_TankType(client)] ? g_iIdleAbility[ST_TankType(client)] : g_iIdleAbility2[ST_TankType(client)];
		int iIdleRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iIdleChance[ST_TankType(client)] : g_iIdleChance2[ST_TankType(client)];
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
					vIdleHit(iSurvivor, iIdleRangeChance, iIdleAbility);
				}
			}
		}
	}
}

void vIdleHit(int client, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsHumanSurvivor(client) && !g_bIdle[client])
	{
		iGetHumanCount() > 1 ? FakeClientCommand(client, "go_away_from_keyboard") : SDKCall(g_hSDKIdlePlayer, client);
		if (bIsBotIdle(client))
		{
			g_bIdled[client] = true;
			g_bIdle[client] = true;
		}
	}
}

void vReset()
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

public Action tTimerIdleFix(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iBot = GetClientOfUserId(pack.ReadCell());
	if (!bIsValidClient(iSurvivor) || !IsPlayerAlive(iSurvivor) || !bIsValidClient(iBot) || !IsPlayerAlive(iSurvivor))
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