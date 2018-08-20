// Super Tanks++: God Ability
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] God Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bGod[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flGodDuration[ST_MAXTYPES + 1], g_flGodDuration2[ST_MAXTYPES + 1];
int g_iGodAbility[ST_MAXTYPES + 1], g_iGodAbility2[ST_MAXTYPES + 1], g_iGodChance[ST_MAXTYPES + 1],
	g_iGodChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if ((evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2) || !IsDedicatedServer())
	{
		strcopy(error, err_max, "[ST++] God Ability only supports Left 4 Dead 1 & 2 Dedicated Servers.");
		return APLRes_SilentFailure;
	}
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
	vReset();
}

public void OnClientPostAdminCheck(int client)
{
	g_bGod[client] = false;
}

public void OnMapEnd()
{
	vReset();
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
			main ? (g_iGodAbility[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Enabled", 0)) : (g_iGodAbility2[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Enabled", g_iGodAbility[iIndex]));
			main ? (g_iGodAbility[iIndex] = iSetCellLimit(g_iGodAbility[iIndex], 0, 1)) : (g_iGodAbility2[iIndex] = iSetCellLimit(g_iGodAbility2[iIndex], 0, 1));
			main ? (g_iGodChance[iIndex] = kvSuperTanks.GetNum("God Ability/God Chance", 4)) : (g_iGodChance2[iIndex] = kvSuperTanks.GetNum("God Ability/God Chance", g_iGodChance[iIndex]));
			main ? (g_iGodChance[iIndex] = iSetCellLimit(g_iGodChance[iIndex], 1, 9999999999)) : (g_iGodChance2[iIndex] = iSetCellLimit(g_iGodChance2[iIndex], 1, 9999999999));
			main ? (g_flGodDuration[iIndex] = kvSuperTanks.GetFloat("God Ability/God Duration", 5.0)) : (g_flGodDuration2[iIndex] = kvSuperTanks.GetFloat("God Ability/God Duration", g_flGodDuration[iIndex]));
			main ? (g_flGodDuration[iIndex] = flSetFloatLimit(g_flGodDuration[iIndex], 0.1, 9999999999.0)) : (g_flGodDuration2[iIndex] = flSetFloatLimit(g_flGodDuration2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_incapacitated") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iGodAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iGodAbility[ST_TankType(iTank)] : g_iGodAbility2[ST_TankType(iTank)];
		if (iGodAbility == 1 && ST_TankAllowed(iTank))
		{
			if (g_bGod[iTank])
			{
				tTimerStopGod(null, GetClientUserId(iTank));
			}
		}
	}
}

public void ST_Ability(int client)
{
	int iGodAbility = !g_bTankConfig[ST_TankType(client)] ? g_iGodAbility[ST_TankType(client)] : g_iGodAbility2[ST_TankType(client)];
	int iGodChance = !g_bTankConfig[ST_TankType(client)] ? g_iGodChance[ST_TankType(client)] : g_iGodChance2[ST_TankType(client)];
	if (iGodAbility == 1 && GetRandomInt(1, iGodChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bGod[client])
	{
		g_bGod[client] = true;
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		float flGodDuration = !g_bTankConfig[ST_TankType(client)] ? g_flGodDuration[ST_TankType(client)] : g_flGodDuration2[ST_TankType(client)];
		CreateTimer(flGodDuration, tTimerStopGod, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bGod[iPlayer] = false;
		}
	}
}

public Action tTimerStopGod(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bGod[iTank] = false;
		return Plugin_Stop;
	}
	int iGodAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iGodAbility[ST_TankType(iTank)] : g_iGodAbility2[ST_TankType(iTank)];
	if (iGodAbility == 0)
	{
		g_bGod[iTank] = false;
		return Plugin_Stop;
	}
	g_bGod[iTank] = false;
	SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);
	return Plugin_Continue;
}