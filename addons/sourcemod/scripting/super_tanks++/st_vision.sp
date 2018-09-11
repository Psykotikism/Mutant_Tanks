// Super Tanks++: Vision Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Vision Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bVision[MAXPLAYERS + 1];
float g_flVisionDuration[ST_MAXTYPES + 1], g_flVisionDuration2[ST_MAXTYPES + 1], g_flVisionRange[ST_MAXTYPES + 1], g_flVisionRange2[ST_MAXTYPES + 1];
int g_iVisionAbility[ST_MAXTYPES + 1], g_iVisionAbility2[ST_MAXTYPES + 1], g_iVisionChance[ST_MAXTYPES + 1], g_iVisionChance2[ST_MAXTYPES + 1], g_iVisionFOV[ST_MAXTYPES + 1], g_iVisionFOV2[ST_MAXTYPES + 1], g_iVisionHit[ST_MAXTYPES + 1], g_iVisionHit2[ST_MAXTYPES + 1], g_iVisionHitMode[ST_MAXTYPES + 1], g_iVisionHitMode2[ST_MAXTYPES + 1], g_iVisionRangeChance[ST_MAXTYPES + 1], g_iVisionRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Vision Ability only supports Left 4 Dead 1 & 2.");
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
	g_bVision[client] = false;
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
		if ((iVisionHitMode(attacker) == 0 || iVisionHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vVisionHit(victim, attacker, iVisionChance(attacker), iVisionHit(attacker));
			}
		}
		else if ((iVisionHitMode(victim) == 0 || iVisionHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vVisionHit(attacker, victim, iVisionChance(victim), iVisionHit(victim));
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
			main ? (g_iVisionHitMode[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit Mode", 0)) : (g_iVisionHitMode2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit Mode", g_iVisionHitMode[iIndex]));
			main ? (g_iVisionHitMode[iIndex] = iSetCellLimit(g_iVisionHitMode[iIndex], 0, 2)) : (g_iVisionHitMode2[iIndex] = iSetCellLimit(g_iVisionHitMode2[iIndex], 0, 2));
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
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iVisionAbility = !g_bTankConfig[ST_TankType(client)] ? g_iVisionAbility[ST_TankType(client)] : g_iVisionAbility2[ST_TankType(client)],
			iVisionRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iVisionChance[ST_TankType(client)] : g_iVisionChance2[ST_TankType(client)];
		float flVisionRange = !g_bTankConfig[ST_TankType(client)] ? g_flVisionRange[ST_TankType(client)] : g_flVisionRange2[ST_TankType(client)],
			flTankPos[3];
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

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bVision[iPlayer] = false;
		}
	}
}

stock void vVisionHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bVision[client])
	{
		g_bVision[client] = true;
		DataPack dpVision = new DataPack();
		CreateDataTimer(0.1, tTimerVision, dpVision, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpVision.WriteCell(GetClientUserId(client)), dpVision.WriteCell(GetClientUserId(owner)), dpVision.WriteCell(enabled), dpVision.WriteFloat(GetEngineTime());
	}
}

stock int iVisionChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iVisionChance[ST_TankType(client)] : g_iVisionChance2[ST_TankType(client)];
}

stock int iVisionHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iVisionHit[ST_TankType(client)] : g_iVisionHit2[ST_TankType(client)];
}

stock int iVisionHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iVisionHitMode[ST_TankType(client)] : g_iVisionHitMode2[ST_TankType(client)];
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
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bVision[iSurvivor] = false;
		SetEntProp(iSurvivor, Prop_Send, "m_iFOV", 90);
		SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", 90);
		return Plugin_Stop;
	}
	int iVisionAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flVisionDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flVisionDuration[ST_TankType(iTank)] : g_flVisionDuration2[ST_TankType(iTank)];
	if (iVisionAbility == 0 || (flTime + flVisionDuration) < GetEngineTime())
	{
		g_bVision[iSurvivor] = false;
		SetEntProp(iSurvivor, Prop_Send, "m_iFOV", 90);
		SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", 90);
		return Plugin_Stop;
	}
	int iVisionFov = !g_bTankConfig[ST_TankType(iTank)] ? g_iVisionFOV[ST_TankType(iTank)] : g_iVisionFOV2[ST_TankType(iTank)];
	SetEntProp(iSurvivor, Prop_Send, "m_iFOV", iVisionFov);
	SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", iVisionFov);
	return Plugin_Continue;
}