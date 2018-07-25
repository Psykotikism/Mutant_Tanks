// Super Tanks++: Warp Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Warp Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
bool g_bWarp[MAXPLAYERS + 1];
float g_flWarpInterval[ST_MAXTYPES + 1];
float g_flWarpInterval2[ST_MAXTYPES + 1];
int g_iWarpAbility[ST_MAXTYPES + 1];
int g_iWarpAbility2[ST_MAXTYPES + 1];
int g_iWarpChance[ST_MAXTYPES + 1];
int g_iWarpChance2[ST_MAXTYPES + 1];
int g_iWarpHit[ST_MAXTYPES + 1];
int g_iWarpHit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Warp Ability only supports Left 4 Dead 1 & 2.");
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
			g_bWarp[iPlayer] = false;
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
	g_bWarp[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bWarp[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bWarp[iPlayer] = false;
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
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (bIsTank(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vWarpHit(victim, attacker);
			}
		}
		else if (bIsSurvivor(attacker) && bIsTank(victim))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vWarpHit(attacker, victim);
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
			main ? (g_iWarpAbility[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Enabled", 0)) : (g_iWarpAbility2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Enabled", g_iWarpAbility[iIndex]));
			main ? (g_iWarpAbility[iIndex] = iSetCellLimit(g_iWarpAbility[iIndex], 0, 1)) : (g_iWarpAbility2[iIndex] = iSetCellLimit(g_iWarpAbility2[iIndex], 0, 1));
			main ? (g_iWarpChance[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Chance", 4)) : (g_iWarpChance2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Chance", g_iWarpChance[iIndex]));
			main ? (g_iWarpChance[iIndex] = iSetCellLimit(g_iWarpChance[iIndex], 1, 9999999999)) : (g_iWarpChance2[iIndex] = iSetCellLimit(g_iWarpChance2[iIndex], 1, 9999999999));
			main ? (g_iWarpHit[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit", 0)) : (g_iWarpHit2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit", g_iWarpHit[iIndex]));
			main ? (g_iWarpHit[iIndex] = iSetCellLimit(g_iWarpHit[iIndex], 0, 1)) : (g_iWarpHit2[iIndex] = iSetCellLimit(g_iWarpHit2[iIndex], 0, 1));
			main ? (g_flWarpInterval[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Interval", 5.0)) : (g_flWarpInterval2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Interval", g_flWarpInterval[iIndex]));
			main ? (g_flWarpInterval[iIndex] = flSetFloatLimit(g_flWarpInterval[iIndex], 0.1, 9999999999.0)) : (g_flWarpInterval2[iIndex] = flSetFloatLimit(g_flWarpInterval2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iWarpAbility = !g_bTankConfig[ST_TankType(client)] ? g_iWarpAbility[ST_TankType(client)] : g_iWarpAbility2[ST_TankType(client)];
	if (iWarpAbility == 1 && bIsTank(client) && !g_bWarp[client])
	{
		g_bWarp[client] = true;
		float flWarpInterval = !g_bTankConfig[ST_TankType(client)] ? g_flWarpInterval[ST_TankType(client)] : g_flWarpInterval2[ST_TankType(client)];
		CreateTimer(flWarpInterval, tTimerWarp, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void vWarpHit(int client, int owner)
{
	int iWarpChance = !g_bTankConfig[ST_TankType(owner)] ? g_iWarpChance[ST_TankType(owner)] : g_iWarpChance2[ST_TankType(owner)];
	int iWarpHit = !g_bTankConfig[ST_TankType(owner)] ? g_iWarpHit[ST_TankType(owner)] : g_iWarpHit2[ST_TankType(owner)];
	if (iWarpHit == 1 && GetRandomInt(1, iWarpChance) == 1 && bIsSurvivor(client))
	{
		float flCurrentOrigin[3];
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsSurvivor(iPlayer) && iPlayer != client)
			{
				GetClientAbsOrigin(iPlayer, flCurrentOrigin);
				TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
				break;
			}
		}
	}
}

int iGetRandomSurvivor()
{
	int iSurvivorCount;
	int iSurvivors[MAXPLAYERS + 1];
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			iSurvivors[iSurvivorCount++] = iSurvivor;
		}
	}
	return iSurvivors[GetRandomInt(0, iSurvivorCount - 1)];
}

public Action tTimerWarp(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iWarpAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iWarpAbility[ST_TankType(iTank)] : g_iWarpAbility2[ST_TankType(iTank)];
	if (iWarpAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	if (bIsTank(iTank))
	{
		int iTarget = iGetRandomSurvivor();
		if (iTarget > 0)
		{
			float flOrigin[3];
			float flAngles[3];
			GetClientAbsOrigin(iTarget, flOrigin);
			GetClientAbsAngles(iTarget, flAngles);
			vCreateParticle(iTank, PARTICLE_ELECTRICITY, 1.0, 0.0);
			TeleportEntity(iTank, flOrigin, flAngles, NULL_VECTOR);
		}
	}
	return Plugin_Continue;
}