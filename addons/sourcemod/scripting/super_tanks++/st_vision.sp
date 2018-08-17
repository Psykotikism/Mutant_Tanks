// Super Tanks++: Vision Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Vision Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
bool g_bVision[MAXPLAYERS + 1];
float g_flVisionDuration[ST_MAXTYPES + 1];
float g_flVisionDuration2[ST_MAXTYPES + 1];
float g_flVisionRange[ST_MAXTYPES + 1];
float g_flVisionRange2[ST_MAXTYPES + 1];
int g_iVisionAbility[ST_MAXTYPES + 1];
int g_iVisionAbility2[ST_MAXTYPES + 1];
int g_iVisionChance[ST_MAXTYPES + 1];
int g_iVisionChance2[ST_MAXTYPES + 1];
int g_iVisionFOV[ST_MAXTYPES + 1];
int g_iVisionFOV2[ST_MAXTYPES + 1];
int g_iVisionHit[ST_MAXTYPES + 1];
int g_iVisionHit2[ST_MAXTYPES + 1];
int g_iVisionRangeChance[ST_MAXTYPES + 1];
int g_iVisionRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if ((evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2) || !IsDedicatedServer())
	{
		strcopy(error, err_max, "[ST++] Vision Ability only supports Left 4 Dead 1 & 2 Dedicated Servers.");
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
			g_bVision[iPlayer] = false;
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
	g_bVision[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bVision[iPlayer] = false;
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
				int iVisionChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iVisionChance[ST_TankType(attacker)] : g_iVisionChance2[ST_TankType(attacker)];
				int iVisionHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iVisionHit[ST_TankType(attacker)] : g_iVisionHit2[ST_TankType(attacker)];
				vVisionHit(victim, attacker, iVisionChance, iVisionHit);
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
			main ? (g_iVisionAbility[iIndex] = kvSuperTanks.GetNum("Vision Ability/Ability Enabled", 0)) : (g_iVisionAbility2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Ability Enabled", g_iVisionAbility[iIndex]));
			main ? (g_iVisionAbility[iIndex] = iSetCellLimit(g_iVisionAbility[iIndex], 0, 1)) : (g_iVisionAbility2[iIndex] = iSetCellLimit(g_iVisionAbility2[iIndex], 0, 1));
			main ? (g_iVisionChance[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Chance", 4)) : (g_iVisionChance2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Chance", g_iVisionChance[iIndex]));
			main ? (g_iVisionChance[iIndex] = iSetCellLimit(g_iVisionChance[iIndex], 1, 9999999999)) : (g_iVisionChance2[iIndex] = iSetCellLimit(g_iVisionChance2[iIndex], 1, 9999999999));
			main ? (g_flVisionDuration[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Duration", 5.0)) : (g_flVisionDuration2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Duration", g_flVisionDuration[iIndex]));
			main ? (g_flVisionDuration[iIndex] = flSetFloatLimit(g_flVisionDuration[iIndex], 0.1, 9999999999.0)) : (g_flVisionDuration2[iIndex] = flSetFloatLimit(g_flVisionDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iVisionFOV[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision FOV", 160)) : (g_iVisionFOV2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision FOV", g_iVisionFOV[iIndex]));
			main ? (g_iVisionFOV[iIndex] = iSetCellLimit(g_iVisionFOV[iIndex], 1, 160)) : (g_iVisionFOV2[iIndex] = iSetCellLimit(g_iVisionFOV2[iIndex], 1, 160));
			main ? (g_iVisionHit[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit", 0)) : (g_iVisionHit2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit", g_iVisionHit[iIndex]));
			main ? (g_iVisionHit[iIndex] = iSetCellLimit(g_iVisionHit[iIndex], 0, 1)) : (g_iVisionHit2[iIndex] = iSetCellLimit(g_iVisionHit2[iIndex], 0, 1));
			main ? (g_flVisionRange[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range", 150.0)) : (g_flVisionRange2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range", g_flVisionRange[iIndex]));
			main ? (g_flVisionRange[iIndex] = flSetFloatLimit(g_flVisionRange[iIndex], 1.0, 9999999999.0)) : (g_flVisionRange2[iIndex] = flSetFloatLimit(g_flVisionRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iVisionRangeChance[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Range Chance", 16)) : (g_iVisionRangeChance2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Range Chance", g_iVisionRangeChance[iIndex]));
			main ? (g_iVisionRangeChance[iIndex] = iSetCellLimit(g_iVisionRangeChance[iIndex], 1, 9999999999)) : (g_iVisionRangeChance2[iIndex] = iSetCellLimit(g_iVisionRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iVisionAbility = !g_bTankConfig[ST_TankType(client)] ? g_iVisionAbility[ST_TankType(client)] : g_iVisionAbility2[ST_TankType(client)];
		int iVisionRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iVisionChance[ST_TankType(client)] : g_iVisionChance2[ST_TankType(client)];
		float flVisionRange = !g_bTankConfig[ST_TankType(client)] ? g_flVisionRange[ST_TankType(client)] : g_flVisionRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flVisionRange)
				{
					vVisionHit(iSurvivor, client, iVisionRangeChance, iVisionAbility);
				}
			}
		}
	}
}

void vVisionHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bVision[client])
	{
		g_bVision[client] = true;
		DataPack dpDataPack = new DataPack();
		CreateDataTimer(0.1, tTimerVision, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

public Action tTimerVision(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bVision[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bVision[iSurvivor] = false;
		SetEntProp(iSurvivor, Prop_Send, "m_iFOV", 90);
		SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", 90);
		return Plugin_Stop;
	}
	float flTime = pack.ReadFloat();
	int iVisionAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iVisionAbility[ST_TankType(iTank)] : g_iVisionAbility2[ST_TankType(iTank)];
	float flVisionDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flVisionDuration[ST_TankType(iTank)] : g_flVisionDuration2[ST_TankType(iTank)];
	if (iVisionAbility == 0 || (flTime + flVisionDuration) < GetEngineTime())
	{
		g_bVision[iSurvivor] = false;
		SetEntProp(iSurvivor, Prop_Send, "m_iFOV", 90);
		SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", 90);
		return Plugin_Stop;
	}
	int iFov = !g_bTankConfig[ST_TankType(iTank)] ? g_iVisionFOV[ST_TankType(iTank)] : g_iVisionFOV2[ST_TankType(iTank)];
	SetEntProp(iSurvivor, Prop_Send, "m_iFOV", iFov);
	SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", iFov);
	return Plugin_Continue;
}