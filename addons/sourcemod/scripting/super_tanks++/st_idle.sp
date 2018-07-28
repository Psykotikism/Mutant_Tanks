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
int g_iIdleAbility[ST_MAXTYPES + 1];
int g_iIdleAbility2[ST_MAXTYPES + 1];
int g_iIdleChance[ST_MAXTYPES + 1];
int g_iIdleChance2[ST_MAXTYPES + 1];
int g_iIdleHit[ST_MAXTYPES + 1];
int g_iIdleHit2[ST_MAXTYPES + 1];
int g_iIdleRangeChance[ST_MAXTYPES + 1];
int g_iIdleRangeChance2[ST_MAXTYPES + 1];

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
		if (iGetHumanCount() > 1)
		{
			FakeClientCommand(client, "go_away_from_keyboard");
		}
		else
		{
			SDKCall(g_hSDKIdlePlayer, client);
		}
		if (bIsBotIdle(client))
		{
			g_bIdled[client] = true;
			g_bIdle[client] = true;
		}
	}
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

bool bIsHumanSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && !IsFakeClient(client) && !bHasIdlePlayer(client) && !bIsPlayerIdle(client);
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