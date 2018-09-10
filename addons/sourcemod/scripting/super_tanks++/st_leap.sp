// Super Tanks++: Leap Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Leap Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLeap[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flLeapHeight[ST_MAXTYPES + 1], g_flLeapHeight2[ST_MAXTYPES + 1], g_flLeapInterval[ST_MAXTYPES + 1], g_flLeapInterval2[ST_MAXTYPES + 1];
int g_iLeapAbility[ST_MAXTYPES + 1], g_iLeapAbility2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Leap Ability only supports Left 4 Dead 1 & 2.");
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

public void OnMapStart()
{
	vReset();
}

public void OnClientPostAdminCheck(int client)
{
	g_bLeap[client] = false;
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
			main ? (g_iLeapAbility[iIndex] = kvSuperTanks.GetNum("Leap Ability/Ability Enabled", 0)) : (g_iLeapAbility2[iIndex] = kvSuperTanks.GetNum("Leap Ability/Ability Enabled", g_iLeapAbility[iIndex]));
			main ? (g_iLeapAbility[iIndex] = iSetCellLimit(g_iLeapAbility[iIndex], 0, 1)) : (g_iLeapAbility2[iIndex] = iSetCellLimit(g_iLeapAbility2[iIndex], 0, 1));
			main ? (g_flLeapHeight[iIndex] = kvSuperTanks.GetFloat("Leap Ability/Leap Height", 500.0)) : (g_flLeapHeight2[iIndex] = kvSuperTanks.GetFloat("Leap Ability/Leap Height", g_flLeapHeight[iIndex]));
			main ? (g_flLeapHeight[iIndex] = flSetFloatLimit(g_flLeapHeight[iIndex], 0.1, 9999999999.0)) : (g_flLeapHeight2[iIndex] = flSetFloatLimit(g_flLeapHeight2[iIndex], 0.1, 9999999999.0));
			main ? (g_flLeapInterval[iIndex] = kvSuperTanks.GetFloat("Leap Ability/Leap Interval", 1.0)) : (g_flLeapInterval2[iIndex] = kvSuperTanks.GetFloat("Leap Ability/Leap Interval", g_flLeapInterval[iIndex]));
			main ? (g_flLeapInterval[iIndex] = flSetFloatLimit(g_flLeapInterval[iIndex], 0.1, 9999999999.0)) : (g_flLeapInterval2[iIndex] = flSetFloatLimit(g_flLeapInterval2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (iLeapAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bLeap[client])
	{
		g_bLeap[client] = true;
		float flLeapInterval = !g_bTankConfig[ST_TankType(client)] ? g_flLeapInterval[ST_TankType(client)] : g_flLeapInterval2[ST_TankType(client)];
		CreateTimer(flLeapInterval, tTimerLeap, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bLeap[iPlayer] = false;
		}
	}
}

stock int iLeapAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iLeapAbility[ST_TankType(client)] : g_iLeapAbility2[ST_TankType(client)];
}

public Action tTimerLeap(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bLeap[iTank] = false;
		return Plugin_Stop;
	}
	if (iLeapAbility(iTank) == 0)
	{
		g_bLeap[iTank] = false;
		return Plugin_Stop;
	}
	float flLeapHeight = !g_bTankConfig[ST_TankType(iTank)] ? g_flLeapHeight[ST_TankType(iTank)] : g_flLeapHeight2[ST_TankType(iTank)],
		flVelocity[3];
	GetEntPropVector(iTank, Prop_Data, "m_vecVelocity", flVelocity);
	flVelocity[2] += flLeapHeight;
	TeleportEntity(iTank, NULL_VECTOR, NULL_VECTOR, flVelocity);
	return Plugin_Continue;
}