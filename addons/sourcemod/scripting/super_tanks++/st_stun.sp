// Super Tanks++: Stun Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Stun Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bStun[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flStunDuration[ST_MAXTYPES + 1];
float g_flStunDuration2[ST_MAXTYPES + 1];
float g_flStunRange[ST_MAXTYPES + 1];
float g_flStunRange2[ST_MAXTYPES + 1];
float g_flStunSpeed[ST_MAXTYPES + 1];
float g_flStunSpeed2[ST_MAXTYPES + 1];
int g_iStunAbility[ST_MAXTYPES + 1];
int g_iStunAbility2[ST_MAXTYPES + 1];
int g_iStunChance[ST_MAXTYPES + 1];
int g_iStunChance2[ST_MAXTYPES + 1];
int g_iStunHit[ST_MAXTYPES + 1];
int g_iStunHit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Stun Ability only supports Left 4 Dead 1 & 2.");
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
			g_bStun[iPlayer] = false;
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
	g_bStun[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bStun[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bStun[iPlayer] = false;
		}
	}
}

void vIsPluginAllowed()
{
	ST_PluginEnabled() ? vHookEvent(true) : vHookEvent(false);
}

void vHookEvent(bool hook)
{
	static bool hooked;
	if (hook && !hooked)
	{
		HookEvent("player_death", eEventPlayerDeath);
		hooked = true;
	}
	else if (!hook && hooked)
	{
		UnhookEvent("player_death", eEventPlayerDeath);
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
				int iStunHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iStunHit[ST_TankType(attacker)] : g_iStunHit2[ST_TankType(attacker)];
				vStunHit(victim, attacker, iStunHit);
			}
		}
	}
}

public Action eEventPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iPlayer = GetClientOfUserId(iUserId);
	if (bIsTank(iPlayer))
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor) && g_bStun[iSurvivor])
			{
				DataPack dpDataPack;
				CreateDataTimer(0.1, tTimerStopStun, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
				dpDataPack.WriteCell(GetClientUserId(iSurvivor));
				dpDataPack.WriteCell(GetClientUserId(iPlayer));
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
			main ? (g_iStunAbility[iIndex] = kvSuperTanks.GetNum("Stun Ability/Ability Enabled", 0)) : (g_iStunAbility2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Ability Enabled", g_iStunAbility[iIndex]));
			main ? (g_iStunAbility[iIndex] = iSetCellLimit(g_iStunAbility[iIndex], 0, 1)) : (g_iStunAbility2[iIndex] = iSetCellLimit(g_iStunAbility2[iIndex], 0, 1));
			main ? (g_iStunChance[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Chance", 4)) : (g_iStunChance2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Chance", g_iStunChance[iIndex]));
			main ? (g_iStunChance[iIndex] = iSetCellLimit(g_iStunChance[iIndex], 1, 9999999999)) : (g_iStunChance2[iIndex] = iSetCellLimit(g_iStunChance2[iIndex], 1, 9999999999));
			main ? (g_flStunDuration[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Duration", 5.0)) : (g_flStunDuration2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Duration", g_flStunDuration[iIndex]));
			main ? (g_flStunDuration[iIndex] = flSetFloatLimit(g_flStunDuration[iIndex], 0.1, 9999999999.0)) : (g_flStunDuration2[iIndex] = flSetFloatLimit(g_flStunDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iStunHit[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit", 0)) : (g_iStunHit2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit", g_iStunHit[iIndex]));
			main ? (g_iStunHit[iIndex] = iSetCellLimit(g_iStunHit[iIndex], 0, 1)) : (g_iStunHit2[iIndex] = iSetCellLimit(g_iStunHit2[iIndex], 0, 1));
			main ? (g_flStunRange[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range", 150.0)) : (g_flStunRange2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range", g_flStunRange[iIndex]));
			main ? (g_flStunRange[iIndex] = flSetFloatLimit(g_flStunRange[iIndex], 1.0, 9999999999.0)) : (g_flStunRange2[iIndex] = flSetFloatLimit(g_flStunRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_flStunSpeed[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Speed", 0.25)) : (g_flStunSpeed2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Speed", g_flStunSpeed[iIndex]));
			main ? (g_flStunSpeed[iIndex] = flSetFloatLimit(g_flStunSpeed[iIndex], 0.1, 0.9)) : (g_flStunSpeed2[iIndex] = flSetFloatLimit(g_flStunSpeed2[iIndex], 0.1, 0.9));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		int iStunAbility = !g_bTankConfig[ST_TankType(client)] ? g_iStunAbility[ST_TankType(client)] : g_iStunAbility2[ST_TankType(client)];
		float flStunRange = !g_bTankConfig[ST_TankType(client)] ? g_flStunRange[ST_TankType(client)] : g_flStunRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flStunRange)
				{
					vStunHit(iSurvivor, client, iStunAbility);
				}
			}
		}
	}
}

void vStunHit(int client, int owner, int enabled)
{
	int iStunChance = !g_bTankConfig[ST_TankType(owner)] ? g_iStunChance[ST_TankType(owner)] : g_iStunChance2[ST_TankType(owner)];
	if (enabled == 1 && GetRandomInt(1, iStunChance) == 1 && bIsSurvivor(client) && !g_bStun[client])
	{
		g_bStun[client] = true;
		float flStunSpeed = !g_bTankConfig[ST_TankType(owner)] ? g_flStunSpeed[ST_TankType(owner)] : g_flStunSpeed2[ST_TankType(owner)];
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", flStunSpeed);
		float flStunDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flStunDuration[ST_TankType(owner)] : g_flStunDuration2[ST_TankType(owner)];
		DataPack dpDataPack;
		CreateDataTimer(flStunDuration, tTimerStopStun, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerStopStun(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor))
	{
		g_bStun[iSurvivor] = false;
		if (bIsSurvivor(iSurvivor))
		{
			SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bStun[iSurvivor] = false;
		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
	}
	return Plugin_Continue;
}