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
	description = "The Super Tank runs really fast like the Flash.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bFlash[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flFlashDuration[ST_MAXTYPES + 1], g_flFlashDuration2[ST_MAXTYPES + 1], g_flFlashInterval[ST_MAXTYPES + 1], g_flFlashInterval2[ST_MAXTYPES + 1], g_flFlashSpeed[ST_MAXTYPES + 1], g_flFlashSpeed2[ST_MAXTYPES + 1], g_flRunSpeed[ST_MAXTYPES + 1], g_flRunSpeed2[ST_MAXTYPES + 1];
int g_iFlashAbility[ST_MAXTYPES + 1], g_iFlashAbility2[ST_MAXTYPES + 1], g_iFlashChance[ST_MAXTYPES + 1], g_iFlashChance2[ST_MAXTYPES + 1], g_iFlashMessage[ST_MAXTYPES + 1], g_iFlashMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
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
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
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
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", 1.0)) : (g_flRunSpeed2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", g_flRunSpeed[iIndex]));
			main ? (g_flRunSpeed[iIndex] = flClamp(g_flRunSpeed[iIndex], 0.1, 3.0)) : (g_flRunSpeed2[iIndex] = flClamp(g_flRunSpeed2[iIndex], 0.1, 3.0));
			main ? (g_iFlashAbility[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Enabled", 0)) : (g_iFlashAbility2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Enabled", g_iFlashAbility[iIndex]));
			main ? (g_iFlashAbility[iIndex] = iClamp(g_iFlashAbility[iIndex], 0, 1)) : (g_iFlashAbility2[iIndex] = iClamp(g_iFlashAbility2[iIndex], 0, 1));
			main ? (g_iFlashMessage[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Message", 0)) : (g_iFlashMessage2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Message", g_iFlashMessage[iIndex]));
			main ? (g_iFlashMessage[iIndex] = iClamp(g_iFlashMessage[iIndex], 0, 1)) : (g_iFlashMessage2[iIndex] = iClamp(g_iFlashMessage2[iIndex], 0, 1));
			main ? (g_iFlashChance[iIndex] = kvSuperTanks.GetNum("Flash Ability/Flash Chance", 4)) : (g_iFlashChance2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Flash Chance", g_iFlashChance[iIndex]));
			main ? (g_iFlashChance[iIndex] = iClamp(g_iFlashChance[iIndex], 1, 9999999999)) : (g_iFlashChance2[iIndex] = iClamp(g_iFlashChance2[iIndex], 1, 9999999999));
			main ? (g_flFlashDuration[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Duration", 5.0)) : (g_flFlashDuration2[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Duration", g_flFlashDuration[iIndex]));
			main ? (g_flFlashDuration[iIndex] = flClamp(g_flFlashDuration[iIndex], 0.1, 9999999999.0)) : (g_flFlashDuration2[iIndex] = flClamp(g_flFlashDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flFlashInterval[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Interval", 1.0)) : (g_flFlashInterval2[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Interval", g_flFlashInterval[iIndex]));
			main ? (g_flFlashInterval[iIndex] = flClamp(g_flFlashInterval[iIndex], 0.1, 9999999999.0)) : (g_flFlashInterval2[iIndex] = flClamp(g_flFlashInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flFlashSpeed[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Speed", 5.0)) : (g_flFlashSpeed2[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Speed", g_flFlashSpeed[iIndex]));
			main ? (g_flFlashSpeed[iIndex] = flClamp(g_flFlashSpeed[iIndex], 3.0, 10.0)) : (g_flFlashSpeed2[iIndex] = flClamp(g_flFlashSpeed2[iIndex], 3.0, 10.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Ability(int client)
{
	int iFlashChance = !g_bTankConfig[ST_TankType(client)] ? g_iFlashChance[ST_TankType(client)] : g_iFlashChance2[ST_TankType(client)];
	if (iFlashAbility(client) == 1 && GetRandomInt(1, iFlashChance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bFlash[client])
	{
		g_bFlash[client] = true;
		float flFlashInterval = !g_bTankConfig[ST_TankType(client)] ? g_flFlashInterval[ST_TankType(client)] : g_flFlashInterval2[ST_TankType(client)];
		DataPack dpFlash = new DataPack();
		CreateDataTimer(flFlashInterval, tTimerFlash, dpFlash, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpFlash.WriteCell(GetClientUserId(client));
		dpFlash.WriteFloat(GetEngineTime());
		if (iFlashMessage(client) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(client, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Flash", sTankName);
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

stock int iFlashMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFlashMessage[ST_TankType(client)] : g_iFlashMessage2[ST_TankType(client)];
}

public Action tTimerFlash(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bFlash[iTank])
	{
		g_bFlash[iTank] = false;
		return Plugin_Stop;
	}
	float flTime = pack.ReadFloat(),
		flFlashDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flFlashDuration[ST_TankType(iTank)] : g_flFlashDuration2[ST_TankType(iTank)];
	if (iFlashAbility(iTank) == 0 || (flTime + flFlashDuration) < GetEngineTime())
	{
		g_bFlash[iTank] = false;
		float flRunSpeed = !g_bTankConfig[ST_TankType(iTank)] ? g_flRunSpeed[ST_TankType(iTank)] : g_flRunSpeed2[ST_TankType(iTank)];
		SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", flRunSpeed);
		if (iFlashMessage(iTank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(iTank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Flash2", sTankName);
		}
		return Plugin_Stop;
	}
	float flFlashSpeed = !g_bTankConfig[ST_TankType(iTank)] ? g_flFlashSpeed[ST_TankType(iTank)] : g_flFlashSpeed2[ST_TankType(iTank)];
	SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", flFlashSpeed);
	return Plugin_Continue;
}