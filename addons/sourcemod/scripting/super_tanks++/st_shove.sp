// Super Tanks++: Shove Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Shove Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bShove[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flShoveDuration[ST_MAXTYPES + 1], g_flShoveDuration2[ST_MAXTYPES + 1], g_flShoveRange[ST_MAXTYPES + 1], g_flShoveRange2[ST_MAXTYPES + 1];
Handle g_hSDKShovePlayer;
int g_iShoveAbility[ST_MAXTYPES + 1], g_iShoveAbility2[ST_MAXTYPES + 1], g_iShoveChance[ST_MAXTYPES + 1], g_iShoveChance2[ST_MAXTYPES + 1], g_iShoveHit[ST_MAXTYPES + 1], g_iShoveHit2[ST_MAXTYPES + 1], g_iShoveHitMode[ST_MAXTYPES + 1], g_iShoveHitMode2[ST_MAXTYPES + 1], g_iShoveMessage[ST_MAXTYPES + 1], g_iShoveMessage2[ST_MAXTYPES + 1], g_iShoveRangeChance[ST_MAXTYPES + 1], g_iShoveRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Shove Ability only supports Left 4 Dead 1 & 2.");
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
	if (strcmp(name, "st_clone", false) == 0)
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "st_clone", false) == 0)
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnStaggered");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	g_hSDKShovePlayer = EndPrepSDKCall();
	if (g_hSDKShovePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnStaggered\" signature is outdated.", ST_PREFIX);
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
	g_bShove[client] = false;
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
		if ((iShoveHitMode(attacker) == 0 || iShoveHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vShoveHit(victim, attacker, iShoveChance(attacker), iShoveHit(attacker), 1);
			}
		}
		else if ((iShoveHitMode(victim) == 0 || iShoveHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vShoveHit(attacker, victim, iShoveChance(victim), iShoveHit(victim), 1);
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
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iShoveAbility[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", 0)) : (g_iShoveAbility2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", g_iShoveAbility[iIndex]));
			main ? (g_iShoveAbility[iIndex] = iSetCellLimit(g_iShoveAbility[iIndex], 0, 1)) : (g_iShoveAbility2[iIndex] = iSetCellLimit(g_iShoveAbility2[iIndex], 0, 1));
			main ? (g_iShoveMessage[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Message", 0)) : (g_iShoveMessage2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Message", g_iShoveMessage[iIndex]));
			main ? (g_iShoveMessage[iIndex] = iSetCellLimit(g_iShoveMessage[iIndex], 0, 3)) : (g_iShoveMessage2[iIndex] = iSetCellLimit(g_iShoveMessage2[iIndex], 0, 3));
			main ? (g_iShoveChance[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Chance", 4)) : (g_iShoveChance2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Chance", g_iShoveChance[iIndex]));
			main ? (g_iShoveChance[iIndex] = iSetCellLimit(g_iShoveChance[iIndex], 1, 9999999999)) : (g_iShoveChance2[iIndex] = iSetCellLimit(g_iShoveChance2[iIndex], 1, 9999999999));
			main ? (g_flShoveDuration[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", 5.0)) : (g_flShoveDuration2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", g_flShoveDuration[iIndex]));
			main ? (g_flShoveDuration[iIndex] = flSetFloatLimit(g_flShoveDuration[iIndex], 0.1, 9999999999.0)) : (g_flShoveDuration2[iIndex] = flSetFloatLimit(g_flShoveDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iShoveHit[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", 0)) : (g_iShoveHit2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", g_iShoveHit[iIndex]));
			main ? (g_iShoveHit[iIndex] = iSetCellLimit(g_iShoveHit[iIndex], 0, 1)) : (g_iShoveHit2[iIndex] = iSetCellLimit(g_iShoveHit2[iIndex], 0, 1));
			main ? (g_iShoveHitMode[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit Mode", 0)) : (g_iShoveHitMode2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit Mode", g_iShoveHitMode[iIndex]));
			main ? (g_iShoveHitMode[iIndex] = iSetCellLimit(g_iShoveHitMode[iIndex], 0, 2)) : (g_iShoveHitMode2[iIndex] = iSetCellLimit(g_iShoveHitMode2[iIndex], 0, 2));
			main ? (g_flShoveRange[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range", 150.0)) : (g_flShoveRange2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range", g_flShoveRange[iIndex]));
			main ? (g_flShoveRange[iIndex] = flSetFloatLimit(g_flShoveRange[iIndex], 1.0, 9999999999.0)) : (g_flShoveRange2[iIndex] = flSetFloatLimit(g_flShoveRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iShoveRangeChance[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Range Chance", 16)) : (g_iShoveRangeChance2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Range Chance", g_iShoveRangeChance[iIndex]));
			main ? (g_iShoveRangeChance[iIndex] = iSetCellLimit(g_iShoveRangeChance[iIndex], 1, 9999999999)) : (g_iShoveRangeChance2[iIndex] = iSetCellLimit(g_iShoveRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iShoveAbility = !g_bTankConfig[ST_TankType(client)] ? g_iShoveAbility[ST_TankType(client)] : g_iShoveAbility2[ST_TankType(client)],
			iShoveRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iShoveChance[ST_TankType(client)] : g_iShoveChance2[ST_TankType(client)];
		float flShoveRange = !g_bTankConfig[ST_TankType(client)] ? g_flShoveRange[ST_TankType(client)] : g_flShoveRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flShoveRange)
				{
					vShoveHit(iSurvivor, client, iShoveRangeChance, iShoveAbility, 2);
				}
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
			g_bShove[iPlayer] = false;
		}
	}
}

stock void vReset2(int client, int owner, int message)
{
	g_bShove[client] = false;
	if (iShoveMessage(owner) == message || iShoveMessage(owner) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Shove2", client);
	}
}

stock void vShoveHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bShove[client])
	{
		g_bShove[client] = true;
		DataPack dpShove = new DataPack();
		CreateDataTimer(1.0, tTimerShove, dpShove, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShove.WriteCell(GetClientUserId(client)), dpShove.WriteCell(GetClientUserId(owner)), dpShove.WriteCell(message), dpShove.WriteCell(enabled), dpShove.WriteFloat(GetEngineTime());
		if (iShoveMessage(owner) == message || iShoveMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Shove", sTankName, client);
		}
	}
}

stock int iShoveChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iShoveChance[ST_TankType(client)] : g_iShoveChance2[ST_TankType(client)];
}

stock int iShoveHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iShoveHit[ST_TankType(client)] : g_iShoveHit2[ST_TankType(client)];
}

stock int iShoveHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iShoveHitMode[ST_TankType(client)] : g_iShoveHitMode2[ST_TankType(client)];
}

stock int iShoveMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iShoveMessage[ST_TankType(client)] : g_iShoveMessage2[ST_TankType(client)];
}

public Action tTimerShove(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bShove[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iShoveChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iShoveChat);
		return Plugin_Stop;
	}
	int iShoveAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flShoveDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flShoveDuration[ST_TankType(iTank)] : g_flShoveDuration2[ST_TankType(iTank)];
	if (iShoveAbility == 0 || (flTime + flShoveDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, iShoveChat);
		return Plugin_Stop;
	}
	float flOrigin[3];
	GetClientAbsOrigin(iSurvivor, flOrigin);
	SDKCall(g_hSDKShovePlayer, iSurvivor, iSurvivor, flOrigin);
	return Plugin_Continue;
}