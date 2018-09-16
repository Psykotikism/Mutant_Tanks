// Super Tanks++: Jump Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Jump Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bJump[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flJumpHeight[ST_MAXTYPES + 1], g_flJumpHeight2[ST_MAXTYPES + 1], g_flJumpInterval[ST_MAXTYPES + 1], g_flJumpInterval2[ST_MAXTYPES + 1];
int g_iJumpAbility[ST_MAXTYPES + 1], g_iJumpAbility2[ST_MAXTYPES + 1], g_iJumpMessage[ST_MAXTYPES + 1], g_iJumpMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Jump Ability only supports Left 4 Dead 1 & 2.");
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
	g_bJump[client] = false;
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
			main ? (g_iJumpAbility[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", 0)) : (g_iJumpAbility2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", g_iJumpAbility[iIndex]));
			main ? (g_iJumpAbility[iIndex] = iSetCellLimit(g_iJumpAbility[iIndex], 0, 1)) : (g_iJumpAbility2[iIndex] = iSetCellLimit(g_iJumpAbility2[iIndex], 0, 1));
			main ? (g_iJumpMessage[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Message", 0)) : (g_iJumpMessage2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Message", g_iJumpMessage[iIndex]));
			main ? (g_iJumpMessage[iIndex] = iSetCellLimit(g_iJumpMessage[iIndex], 0, 1)) : (g_iJumpMessage2[iIndex] = iSetCellLimit(g_iJumpMessage2[iIndex], 0, 1));
			main ? (g_flJumpHeight[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Height", 500.0)) : (g_flJumpHeight2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Height", g_flJumpHeight[iIndex]));
			main ? (g_flJumpHeight[iIndex] = flSetFloatLimit(g_flJumpHeight[iIndex], 0.1, 9999999999.0)) : (g_flJumpHeight2[iIndex] = flSetFloatLimit(g_flJumpHeight2[iIndex], 0.1, 9999999999.0));
			main ? (g_flJumpInterval[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Interval", 1.0)) : (g_flJumpInterval2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Interval", g_flJumpInterval[iIndex]));
			main ? (g_flJumpInterval[iIndex] = flSetFloatLimit(g_flJumpInterval[iIndex], 0.1, 9999999999.0)) : (g_flJumpInterval2[iIndex] = flSetFloatLimit(g_flJumpInterval2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (iJumpAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bJump[client])
	{
		g_bJump[client] = true;
		float flJumpInterval = !g_bTankConfig[ST_TankType(client)] ? g_flJumpInterval[ST_TankType(client)] : g_flJumpInterval2[ST_TankType(client)];
		CreateTimer(flJumpInterval, tTimerJump, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		if (iJumpMessage(client) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(client, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Jump", sTankName);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bJump[iPlayer] = false;
		}
	}
}

stock int iJumpAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iJumpAbility[ST_TankType(client)] : g_iJumpAbility2[ST_TankType(client)];
}

stock int iJumpMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iJumpMessage[ST_TankType(client)] : g_iJumpMessage2[ST_TankType(client)];
}

public Action tTimerJump(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bJump[iTank] = false;
		return Plugin_Stop;
	}
	if (iJumpAbility(iTank) == 0)
	{
		g_bJump[iTank] = false;
		return Plugin_Stop;
	}
	float flJumpHeight = !g_bTankConfig[ST_TankType(iTank)] ? g_flJumpHeight[ST_TankType(iTank)] : g_flJumpHeight2[ST_TankType(iTank)],
		flVelocity[3];
	GetEntPropVector(iTank, Prop_Data, "m_vecVelocity", flVelocity);
	flVelocity[2] += flJumpHeight;
	TeleportEntity(iTank, NULL_VECTOR, NULL_VECTOR, flVelocity);
	if (iJumpMessage(iTank) == 1)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(iTank, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "Jump2", sTankName);
	}
	return Plugin_Continue;
}