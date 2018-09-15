// Super Tanks++: Zombie Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Zombie Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1], g_bZombie[MAXPLAYERS + 1];
float g_flZombieInterval[ST_MAXTYPES + 1], g_flZombieInterval2[ST_MAXTYPES + 1];
int g_iZombieAbility[ST_MAXTYPES + 1], g_iZombieAbility2[ST_MAXTYPES + 1], g_iZombieAmount[ST_MAXTYPES + 1], g_iZombieAmount2[ST_MAXTYPES + 1], g_iZombieMessage[ST_MAXTYPES + 1], g_iZombieMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Zombie Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
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
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	g_bZombie[client] = false;
}

public void OnMapEnd()
{
	vReset();
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
			main ? (g_iZombieAbility[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Enabled", 0)) : (g_iZombieAbility2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Enabled", g_iZombieAbility[iIndex]));
			main ? (g_iZombieAbility[iIndex] = iSetCellLimit(g_iZombieAbility[iIndex], 0, 1)) : (g_iZombieAbility2[iIndex] = iSetCellLimit(g_iZombieAbility2[iIndex], 0, 1));
			main ? (g_iZombieMessage[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Message", 0)) : (g_iZombieMessage2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Message", g_iZombieMessage[iIndex]));
			main ? (g_iZombieMessage[iIndex] = iSetCellLimit(g_iZombieMessage[iIndex], 0, 1)) : (g_iZombieMessage2[iIndex] = iSetCellLimit(g_iZombieMessage2[iIndex], 0, 1));
			main ? (g_iZombieAmount[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Amount", 10)) : (g_iZombieAmount2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Amount", g_iZombieAmount[iIndex]));
			main ? (g_iZombieAmount[iIndex] = iSetCellLimit(g_iZombieAmount[iIndex], 1, 100)) : (g_iZombieAmount2[iIndex] = iSetCellLimit(g_iZombieAmount2[iIndex], 1, 100));
			main ? (g_flZombieInterval[iIndex] = kvSuperTanks.GetFloat("Zombie Ability/Zombie Interval", 5.0)) : (g_flZombieInterval2[iIndex] = kvSuperTanks.GetFloat("Zombie Ability/Zombie Interval", g_flZombieInterval[iIndex]));
			main ? (g_flZombieInterval[iIndex] = flSetFloatLimit(g_flZombieInterval[iIndex], 0.1, 9999999999.0)) : (g_flZombieInterval2[iIndex] = flSetFloatLimit(g_flZombieInterval2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (iZombieAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bZombie[client])
	{
		g_bZombie[client] = true;
		float flZombieInterval = !g_bTankConfig[ST_TankType(client)] ? g_flZombieInterval[ST_TankType(client)] : g_flZombieInterval2[ST_TankType(client)];
		int iZombieMessage = !g_bTankConfig[ST_TankType(client)] ? g_iZombieMessage[ST_TankType(client)] : g_iZombieMessage2[ST_TankType(client)];
		CreateTimer(flZombieInterval, tTimerZombie, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		if (iZombieMessage == 1)
		{
			PrintToChatAll("%s %t", ST_PREFIX2, "Zombie", client);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bZombie[iPlayer] = false;
		}
	}
}

stock int iZombieAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iZombieAbility[ST_TankType(client)] : g_iZombieAbility2[ST_TankType(client)];
}

public Action tTimerZombie(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bZombie[iTank] = false;
		return Plugin_Stop;
	}
	if (iZombieAbility(iTank) == 0)
	{
		g_bZombie[iTank] = false;
		return Plugin_Stop;
	}
	int iZombieAmount = !g_bTankConfig[ST_TankType(iTank)] ? g_iZombieAmount[ST_TankType(iTank)] : g_iZombieAmount2[ST_TankType(iTank)];
	for (int iZombie = 1; iZombie <= iZombieAmount; iZombie++)
	{
		vCheatCommand(iTank, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", "zombie area");
	}
	return Plugin_Continue;
}