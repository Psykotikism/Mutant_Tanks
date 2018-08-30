// Super Tanks++: Bury Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Bury Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bBury[MAXPLAYERS + 1], g_bLateLoad, g_bPluginEnabled, g_bTankConfig[ST_MAXTYPES + 1];
float g_flBuryDuration[ST_MAXTYPES + 1], g_flBuryDuration2[ST_MAXTYPES + 1],
	g_flBuryHeight[ST_MAXTYPES + 1], g_flBuryHeight2[ST_MAXTYPES + 1],
	g_flBuryRange[ST_MAXTYPES + 1], g_flBuryRange2[ST_MAXTYPES + 1];
Handle g_hSDKRevivePlayer;
int g_iBuryAbility[ST_MAXTYPES + 1], g_iBuryAbility2[ST_MAXTYPES + 1],
	g_iBuryChance[ST_MAXTYPES + 1], g_iBuryChance2[ST_MAXTYPES + 1], g_iBuryHit[ST_MAXTYPES + 1],
	g_iBuryHit2[ST_MAXTYPES + 1], g_iBuryRangeChance[ST_MAXTYPES + 1],
	g_iBuryRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Bury Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	LibraryExists("super_tanks++") ? (g_bPluginEnabled = true) : (g_bPluginEnabled = false);
}

public void OnLibraryAdded(const char[] name)
{
	if (strcmp(name, "super_tanks++") == 0)
	{
		g_bPluginEnabled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "super_tanks++") == 0)
	{
		g_bPluginEnabled = false;
	}
}

public void OnPluginStart()
{
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnRevived");
	g_hSDKRevivePlayer = EndPrepSDKCall();
	if (g_hSDKRevivePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnRevived\" signature is outdated.", ST_PREFIX);
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
	g_bBury[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_bPluginEnabled && ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iBuryChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iBuryChance[ST_TankType(attacker)] : g_iBuryChance2[ST_TankType(attacker)];
				int iBuryHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iBuryHit[ST_TankType(attacker)] : g_iBuryHit2[ST_TankType(attacker)];
				vBuryHit(victim, attacker, iBuryChance, iBuryHit);
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
			main ? (g_iBuryAbility[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Enabled", 0)) : (g_iBuryAbility2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Enabled", g_iBuryAbility[iIndex]));
			main ? (g_iBuryAbility[iIndex] = iSetCellLimit(g_iBuryAbility[iIndex], 0, 1)) : (g_iBuryAbility2[iIndex] = iSetCellLimit(g_iBuryAbility2[iIndex], 0, 1));
			main ? (g_iBuryChance[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Chance", 4)) : (g_iBuryChance2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Chance", g_iBuryChance[iIndex]));
			main ? (g_iBuryChance[iIndex] = iSetCellLimit(g_iBuryChance[iIndex], 1, 9999999999)) : (g_iBuryChance2[iIndex] = iSetCellLimit(g_iBuryChance2[iIndex], 1, 9999999999));
			main ? (g_flBuryDuration[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Duration", 5.0)) : (g_flBuryDuration2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Duration", g_flBuryDuration[iIndex]));
			main ? (g_flBuryDuration[iIndex] = flSetFloatLimit(g_flBuryDuration[iIndex], 0.1, 9999999999.0)) : (g_flBuryDuration2[iIndex] = flSetFloatLimit(g_flBuryDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flBuryHeight[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Height", 50.0)) : (g_flBuryHeight2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Height", g_flBuryHeight[iIndex]));
			main ? (g_flBuryHeight[iIndex] = flSetFloatLimit(g_flBuryHeight[iIndex], 0.1, 9999999999.0)) : (g_flBuryHeight2[iIndex] = flSetFloatLimit(g_flBuryHeight2[iIndex], 0.1, 9999999999.0));
			main ? (g_iBuryHit[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit", 0)) : (g_iBuryHit2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit", g_iBuryHit[iIndex]));
			main ? (g_iBuryHit[iIndex] = iSetCellLimit(g_iBuryHit[iIndex], 0, 1)) : (g_iBuryHit2[iIndex] = iSetCellLimit(g_iBuryHit2[iIndex], 0, 1));
			main ? (g_flBuryRange[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range", 150.0)) : (g_flBuryRange2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range", g_flBuryRange[iIndex]));
			main ? (g_flBuryRange[iIndex] = flSetFloatLimit(g_flBuryRange[iIndex], 1.0, 9999999999.0)) : (g_flBuryRange2[iIndex] = flSetFloatLimit(g_flBuryRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iBuryRangeChance[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Range Chance", 16)) : (g_iBuryRangeChance2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Range Chance", g_iBuryRangeChance[iIndex]));
			main ? (g_iBuryRangeChance[iIndex] = iSetCellLimit(g_iBuryRangeChance[iIndex], 1, 9999999999)) : (g_iBuryRangeChance2[iIndex] = iSetCellLimit(g_iBuryRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iBuryAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iBuryAbility[ST_TankType(iTank)] : g_iBuryAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iBuryAbility == 1)
		{
			vRemoveBury(iTank);
		}
	}
}

public void ST_Ability(int client)
{
	if (g_bPluginEnabled && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iBuryAbility = !g_bTankConfig[ST_TankType(client)] ? g_iBuryAbility[ST_TankType(client)] : g_iBuryAbility2[ST_TankType(client)];
		int iBuryRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iBuryChance[ST_TankType(client)] : g_iBuryChance2[ST_TankType(client)];
		float flBuryRange = !g_bTankConfig[ST_TankType(client)] ? g_flBuryRange[ST_TankType(client)] : g_flBuryRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flBuryRange)
				{
					vBuryHit(iSurvivor, client, iBuryRangeChance, iBuryAbility);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	int iBuryAbility = !g_bTankConfig[ST_TankType(client)] ? g_iBuryAbility[ST_TankType(client)] : g_iBuryAbility2[ST_TankType(client)];
	if (g_bPluginEnabled && ST_TankAllowed(client) && iBuryAbility == 1)
	{
		vRemoveBury(client);
	}
}

void vBuryHit(int client, int owner, int chance, int enabled)
{
	if (g_bPluginEnabled && enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bBury[client] && bIsPlayerGrounded(client))
	{
		g_bBury[client] = true;
		float flOrigin[3], flPos[3];
		float flBuryHeight = !g_bTankConfig[ST_TankType(owner)] ? g_flBuryHeight[ST_TankType(owner)] : g_flBuryHeight2[ST_TankType(owner)];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] = flOrigin[2] - flBuryHeight;
		SetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		if (!bIsPlayerIncapacitated(client))
		{
			SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
			SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		}
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) != MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
		}
		float flBuryDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flBuryDuration[ST_TankType(owner)] : g_flBuryDuration2[ST_TankType(owner)];
		DataPack dpDataPack = new DataPack();
		CreateDataTimer(flBuryDuration, tTimerStopBury, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vRemoveBury(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bBury[iSurvivor])
		{
			DataPack dpDataPack = new DataPack();
			CreateDataTimer(0.1, tTimerStopBury, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
			dpDataPack.WriteCell(GetClientUserId(iSurvivor));
			dpDataPack.WriteCell(GetClientUserId(client));
		}
	}
}

void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bBury[iPlayer] = false;
		}
	}
}

void vStopBury(int client, int owner)
{
	if (g_bBury[client])
	{
		g_bBury[client] = false;
		float flOrigin[3], flCurrentOrigin[3];
		float flBuryHeight = !g_bTankConfig[ST_TankType(owner)] ? g_flBuryHeight[ST_TankType(owner)] : g_flBuryHeight2[ST_TankType(owner)];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] = flOrigin[2] + flBuryHeight;
		SetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsSurvivor(iPlayer) && !g_bBury[iPlayer] && iPlayer != client)
			{
				GetClientAbsOrigin(iPlayer, flCurrentOrigin);
				TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
				break;
			}
		}
		if (bIsPlayerIncapacitated(client))
		{
			SDKCall(g_hSDKRevivePlayer, client);
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		}
		if (GetEntityMoveType(client) == MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
	}
}

public Action tTimerStopBury(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!g_bPluginEnabled || !bIsSurvivor(iSurvivor))
	{
		g_bBury[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		vStopBury(iSurvivor, iTank);
		return Plugin_Stop;
	}
	int iBuryAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iBuryAbility[ST_TankType(iTank)] : g_iBuryAbility2[ST_TankType(iTank)];
	if (iBuryAbility == 0)
	{
		vStopBury(iSurvivor, iTank);
		return Plugin_Stop;
	}
	vStopBury(iSurvivor, iTank);
	return Plugin_Continue;
}