// Super Tanks++: Flash Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Flash Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bFlash[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flFlashDuration[ST_MAXTYPES + 1], g_flFlashDuration2[ST_MAXTYPES + 1], g_flFlashSpeed[ST_MAXTYPES + 1], g_flFlashSpeed2[ST_MAXTYPES + 1], g_flRunSpeed[ST_MAXTYPES + 1], g_flRunSpeed2[ST_MAXTYPES + 1];
int g_iFlashAbility[ST_MAXTYPES + 1], g_iFlashAbility2[ST_MAXTYPES + 1], g_iFlashChance[ST_MAXTYPES + 1], g_iFlashChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Flash Ability only supports Left 4 Dead 1 & 2.");
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
	g_bFlash[client] = false;
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
			main ? (g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", 1.0)) : (g_flRunSpeed2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", g_flRunSpeed[iIndex]));
			main ? (g_flRunSpeed[iIndex] = flSetFloatLimit(g_flRunSpeed[iIndex], 0.1, 3.0)) : (g_flRunSpeed2[iIndex] = flSetFloatLimit(g_flRunSpeed2[iIndex], 0.1, 3.0));
			main ? (g_iFlashAbility[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Enabled", 0)) : (g_iFlashAbility2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Enabled", g_iFlashAbility[iIndex]));
			main ? (g_iFlashAbility[iIndex] = iSetCellLimit(g_iFlashAbility[iIndex], 0, 1)) : (g_iFlashAbility2[iIndex] = iSetCellLimit(g_iFlashAbility2[iIndex], 0, 1));
			main ? (g_iFlashChance[iIndex] = kvSuperTanks.GetNum("Flash Ability/Flash Chance", 4)) : (g_iFlashChance2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Flash Chance", g_iFlashChance[iIndex]));
			main ? (g_iFlashChance[iIndex] = iSetCellLimit(g_iFlashChance[iIndex], 1, 9999999999)) : (g_iFlashChance2[iIndex] = iSetCellLimit(g_iFlashChance2[iIndex], 1, 9999999999));
			main ? (g_flFlashDuration[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Duration", 5.0)) : (g_flFlashDuration2[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Duration", g_flFlashDuration[iIndex]));
			main ? (g_flFlashDuration[iIndex] = flSetFloatLimit(g_flFlashDuration[iIndex], 0.1, 9999999999.0)) : (g_flFlashDuration2[iIndex] = flSetFloatLimit(g_flFlashDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flFlashSpeed[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Speed", 5.0)) : (g_flFlashSpeed2[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Speed", g_flFlashSpeed[iIndex]));
			main ? (g_flFlashSpeed[iIndex] = flSetFloatLimit(g_flFlashSpeed[iIndex], 3.0, 10.0)) : (g_flFlashSpeed2[iIndex] = flSetFloatLimit(g_flFlashSpeed2[iIndex], 3.0, 10.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (iFlashAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		if (!g_bFlash[client])
		{
			float flRunSpeed = !g_bTankConfig[ST_TankType(client)] ? g_flRunSpeed[ST_TankType(client)] : g_flRunSpeed2[ST_TankType(client)];
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", flRunSpeed);
			int iFlashChance = !g_bTankConfig[ST_TankType(client)] ? g_iFlashChance[ST_TankType(client)] : g_iFlashChance2[ST_TankType(client)];
			if (GetRandomInt(1, iFlashChance) == 1)
			{
				g_bFlash[client] = true;
			}
		}
		else
		{
			float flFlashSpeed = !g_bTankConfig[ST_TankType(client)] ? g_flFlashSpeed[ST_TankType(client)] : g_flFlashSpeed2[ST_TankType(client)],
				flFlashDuration = !g_bTankConfig[ST_TankType(client)] ? g_flFlashDuration[ST_TankType(client)] : g_flFlashDuration2[ST_TankType(client)];
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", flFlashSpeed);
			CreateTimer(flFlashDuration, tTimerStopFlash, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bFlash[iPlayer] = false;
		}
	}
}

stock int iFlashAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFlashAbility[ST_TankType(client)] : g_iFlashAbility2[ST_TankType(client)];
}

public Action tTimerStopFlash(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bFlash[iTank] = false;
		return Plugin_Stop;
	}
	if (iFlashAbility(iTank) == 0)
	{
		g_bFlash[iTank] = false;
		return Plugin_Stop;
	}
	g_bFlash[iTank] = false;
	return Plugin_Continue;
}