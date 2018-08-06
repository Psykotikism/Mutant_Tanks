// Super Tanks++: Shove Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Shove Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bShove[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flShoveDuration[ST_MAXTYPES + 1];
float g_flShoveDuration2[ST_MAXTYPES + 1];
float g_flShoveRange[ST_MAXTYPES + 1];
float g_flShoveRange2[ST_MAXTYPES + 1];
Handle g_hSDKShovePlayer;
int g_iShoveAbility[ST_MAXTYPES + 1];
int g_iShoveAbility2[ST_MAXTYPES + 1];
int g_iShoveChance[ST_MAXTYPES + 1];
int g_iShoveChance2[ST_MAXTYPES + 1];
int g_iShoveHit[ST_MAXTYPES + 1];
int g_iShoveHit2[ST_MAXTYPES + 1];
int g_iShoveRangeChance[ST_MAXTYPES + 1];
int g_iShoveRangeChance2[ST_MAXTYPES + 1];

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
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnPluginStart()
{
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
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bShove[iPlayer] = false;
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
	g_bShove[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bShove[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bShove[iPlayer] = false;
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
				int iShoveChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iShoveChance[ST_TankType(attacker)] : g_iShoveChance2[ST_TankType(attacker)];
				int iShoveHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iShoveHit[ST_TankType(attacker)] : g_iShoveHit2[ST_TankType(attacker)];
				vShoveHit(victim, attacker, iShoveChance, iShoveHit);
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
			main ? (g_iShoveAbility[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", 0)) : (g_iShoveAbility2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", g_iShoveAbility[iIndex]));
			main ? (g_iShoveAbility[iIndex] = iSetCellLimit(g_iShoveAbility[iIndex], 0, 1)) : (g_iShoveAbility2[iIndex] = iSetCellLimit(g_iShoveAbility2[iIndex], 0, 1));
			main ? (g_iShoveChance[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Chance", 4)) : (g_iShoveChance2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Chance", g_iShoveChance[iIndex]));
			main ? (g_iShoveChance[iIndex] = iSetCellLimit(g_iShoveChance[iIndex], 1, 9999999999)) : (g_iShoveChance2[iIndex] = iSetCellLimit(g_iShoveChance2[iIndex], 1, 9999999999));
			main ? (g_flShoveDuration[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", 5.0)) : (g_flShoveDuration2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", g_flShoveDuration[iIndex]));
			main ? (g_flShoveDuration[iIndex] = flSetFloatLimit(g_flShoveDuration[iIndex], 0.1, 9999999999.0)) : (g_flShoveDuration2[iIndex] = flSetFloatLimit(g_flShoveDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iShoveHit[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", 0)) : (g_iShoveHit2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", g_iShoveHit[iIndex]));
			main ? (g_iShoveHit[iIndex] = iSetCellLimit(g_iShoveHit[iIndex], 0, 1)) : (g_iShoveHit2[iIndex] = iSetCellLimit(g_iShoveHit2[iIndex], 0, 1));
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
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iShoveAbility = !g_bTankConfig[ST_TankType(client)] ? g_iShoveAbility[ST_TankType(client)] : g_iShoveAbility2[ST_TankType(client)];
		int iShoveRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iShoveChance[ST_TankType(client)] : g_iShoveChance2[ST_TankType(client)];
		float flShoveRange = !g_bTankConfig[ST_TankType(client)] ? g_flShoveRange[ST_TankType(client)] : g_flShoveRange2[ST_TankType(client)];
		float flTankPos[3];
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
					vShoveHit(iSurvivor, client, iShoveRangeChance, iShoveAbility);
				}
			}
		}
	}
}

void vShoveHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bShove[client])
	{
		g_bShove[client] = true;
		DataPack dpDataPack = new DataPack();
		CreateDataTimer(1.0, tTimerShove, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
		dpDataPack.WriteFloat(GetEngineTime());
	}
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
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bShove[iSurvivor] = false;
		return Plugin_Stop;
	}
	float flTime = pack.ReadFloat();
	int iShoveAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iShoveAbility[ST_TankType(iTank)] : g_iShoveAbility2[ST_TankType(iTank)];
	float flShoveDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flShoveDuration[ST_TankType(iTank)] : g_flShoveDuration2[ST_TankType(iTank)];
	if (iShoveAbility == 0 || (flTime + flShoveDuration) < GetEngineTime())
	{
		g_bShove[iSurvivor] = false;
		return Plugin_Stop;
	}
	float flOrigin[3];
	GetClientAbsOrigin(iSurvivor, flOrigin);
	SDKCall(g_hSDKShovePlayer, iSurvivor, iSurvivor, flOrigin);
	return Plugin_Continue;
}