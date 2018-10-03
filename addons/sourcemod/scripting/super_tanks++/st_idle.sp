// Super Tanks++: Idle Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Idle Ability",
	author = ST_AUTHOR,
	description = "The Super Tank forces survivors to go idle.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bIdle[MAXPLAYERS + 1], g_bIdled[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sIdleEffect[ST_MAXTYPES + 1][4], g_sIdleEffect2[ST_MAXTYPES + 1][4];
float g_flIdleRange[ST_MAXTYPES + 1], g_flIdleRange2[ST_MAXTYPES + 1];
Handle g_hSDKIdlePlayer, g_hSDKSpecPlayer;
int g_iIdleAbility[ST_MAXTYPES + 1], g_iIdleAbility2[ST_MAXTYPES + 1], g_iIdleChance[ST_MAXTYPES + 1], g_iIdleChance2[ST_MAXTYPES + 1], g_iIdleHit[ST_MAXTYPES + 1], g_iIdleHit2[ST_MAXTYPES + 1], g_iIdleHitMode[ST_MAXTYPES + 1], g_iIdleHitMode2[ST_MAXTYPES + 1], g_iIdleMessage[ST_MAXTYPES + 1], g_iIdleMessage2[ST_MAXTYPES + 1], g_iIdleRangeChance[ST_MAXTYPES + 1], g_iIdleRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Idle Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");
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
	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				OnClientPutInServer(iPlayer);
			}
		}
		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
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
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iIdleHitMode(attacker) == 0 || iIdleHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vIdleHit(victim, attacker, iIdleChance(attacker), iIdleHit(attacker), 1, "1");
			}
		}
		else if ((iIdleHitMode(victim) == 0 || iIdleHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vIdleHit(attacker, victim, iIdleChance(victim), iIdleHit(victim), 1, "2");
			}
		}
	}
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iIdleAbility[iIndex] = kvSuperTanks.GetNum("Idle Ability/Ability Enabled", 0)) : (g_iIdleAbility2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Ability Enabled", g_iIdleAbility[iIndex]));
			main ? (g_iIdleAbility[iIndex] = iClamp(g_iIdleAbility[iIndex], 0, 1)) : (g_iIdleAbility2[iIndex] = iClamp(g_iIdleAbility2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Idle Ability/Ability Effect", g_sIdleEffect[iIndex], sizeof(g_sIdleEffect[]), "123")) : (kvSuperTanks.GetString("Idle Ability/Ability Effect", g_sIdleEffect2[iIndex], sizeof(g_sIdleEffect2[]), g_sIdleEffect[iIndex]));
			main ? (g_iIdleMessage[iIndex] = kvSuperTanks.GetNum("Idle Ability/Ability Message", 0)) : (g_iIdleMessage2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Ability Message", g_iIdleMessage[iIndex]));
			main ? (g_iIdleMessage[iIndex] = iClamp(g_iIdleMessage[iIndex], 0, 3)) : (g_iIdleMessage2[iIndex] = iClamp(g_iIdleMessage2[iIndex], 0, 3));
			main ? (g_iIdleChance[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Chance", 4)) : (g_iIdleChance2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Chance", g_iIdleChance[iIndex]));
			main ? (g_iIdleChance[iIndex] = iClamp(g_iIdleChance[iIndex], 1, 9999999999)) : (g_iIdleChance2[iIndex] = iClamp(g_iIdleChance2[iIndex], 1, 9999999999));
			main ? (g_iIdleHit[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Hit", 0)) : (g_iIdleHit2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Hit", g_iIdleHit[iIndex]));
			main ? (g_iIdleHit[iIndex] = iClamp(g_iIdleHit[iIndex], 0, 1)) : (g_iIdleHit2[iIndex] = iClamp(g_iIdleHit2[iIndex], 0, 1));
			main ? (g_iIdleHitMode[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Hit Mode", 0)) : (g_iIdleHitMode2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Hit Mode", g_iIdleHitMode[iIndex]));
			main ? (g_iIdleHitMode[iIndex] = iClamp(g_iIdleHitMode[iIndex], 0, 2)) : (g_iIdleHitMode2[iIndex] = iClamp(g_iIdleHitMode2[iIndex], 0, 2));
			main ? (g_flIdleRange[iIndex] = kvSuperTanks.GetFloat("Idle Ability/Idle Range", 150.0)) : (g_flIdleRange2[iIndex] = kvSuperTanks.GetFloat("Idle Ability/Idle Range", g_flIdleRange[iIndex]));
			main ? (g_flIdleRange[iIndex] = flClamp(g_flIdleRange[iIndex], 1.0, 9999999999.0)) : (g_flIdleRange2[iIndex] = flClamp(g_flIdleRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iIdleRangeChance[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Range Chance", 16)) : (g_iIdleRangeChance2[iIndex] = kvSuperTanks.GetNum("Idle Ability/Idle Range Chance", g_iIdleRangeChance[iIndex]));
			main ? (g_iIdleRangeChance[iIndex] = iClamp(g_iIdleRangeChance[iIndex], 1, 9999999999)) : (g_iIdleRangeChance2[iIndex] = iClamp(g_iIdleRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_afk"))
	{
		int iPlayerId = event.GetInt("player"), iIdler = GetClientOfUserId(iPlayerId);
		g_bIdled[iIdler] = true;
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iSurvivorId = event.GetInt("player"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsIdlePlayer(iBot, iSurvivor)) 
		{
			DataPack dpIdleFix = new DataPack();
			CreateDataTimer(0.2, tTimerIdleFix, dpIdleFix, TIMER_FLAG_NO_MAPCHANGE);
			dpIdleFix.WriteCell(iSurvivorId), dpIdleFix.WriteCell(iBotId);
			if (g_bIdle[iSurvivor])
			{
				g_bIdle[iSurvivor] = false;
			}
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iIdleAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iIdleAbility[ST_TankType(tank)] : g_iIdleAbility2[ST_TankType(tank)],
			iIdleRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_iIdleChance[ST_TankType(tank)] : g_iIdleChance2[ST_TankType(tank)];
		float flIdleRange = !g_bTankConfig[ST_TankType(tank)] ? g_flIdleRange[ST_TankType(tank)] : g_flIdleRange2[ST_TankType(tank)],
			flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flIdleRange)
				{
					vIdleHit(iSurvivor, tank, iIdleRangeChance, iIdleAbility, 2, "3");
				}
			}
		}
	}
}

stock void vIdleHit(int survivor, int tank, int chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsHumanSurvivor(survivor) && !g_bIdle[survivor])
	{
		iGetHumanCount() > 1 ? FakeClientCommand(survivor, "go_away_from_keyboard") : SDKCall(g_hSDKIdlePlayer, survivor);
		if (bIsBotIdle(survivor))
		{
			g_bIdle[survivor] = true;
			g_bIdled[survivor] = true;
			int iIdleMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iIdleMessage[ST_TankType(tank)] : g_iIdleMessage2[ST_TankType(tank)];
			char sIdleEffect[4];
			sIdleEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sIdleEffect[ST_TankType(tank)] : g_sIdleEffect2[ST_TankType(tank)];
			vEffect(survivor, tank, sIdleEffect, mode);
			if (iIdleMessage == message || iIdleMessage == 3)
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(tank, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Idle", sTankName, survivor);
			}
		}
	}
}

stock void vReset()
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

stock int iIdleChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIdleChance[ST_TankType(tank)] : g_iIdleChance2[ST_TankType(tank)];
}

stock int iIdleHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIdleHit[ST_TankType(tank)] : g_iIdleHit2[ST_TankType(tank)];
}

stock int iIdleHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIdleHitMode[ST_TankType(tank)] : g_iIdleHitMode2[ST_TankType(tank)];
}

public Action tTimerIdleFix(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell()), iBot = GetClientOfUserId(pack.ReadCell());
	if (!bIsValidClient(iSurvivor) || !IsPlayerAlive(iSurvivor) || !bIsValidClient(iBot) || !IsPlayerAlive(iSurvivor) || !g_bIdled[iSurvivor])
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