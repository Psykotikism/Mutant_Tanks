// Super Tanks++: God Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] God Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains temporary immunity to all damage.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bGod[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flGodDuration[ST_MAXTYPES + 1], g_flGodDuration2[ST_MAXTYPES + 1];
int g_iGodAbility[ST_MAXTYPES + 1], g_iGodAbility2[ST_MAXTYPES + 1], g_iGodChance[ST_MAXTYPES + 1], g_iGodChance2[ST_MAXTYPES + 1], g_iGodMessage[ST_MAXTYPES + 1], g_iGodMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] God Ability only supports Left 4 Dead 1 & 2.");
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
	g_bGod[client] = false;
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
			main ? (g_iGodAbility[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Enabled", 0)) : (g_iGodAbility2[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Enabled", g_iGodAbility[iIndex]));
			main ? (g_iGodAbility[iIndex] = iClamp(g_iGodAbility[iIndex], 0, 1)) : (g_iGodAbility2[iIndex] = iClamp(g_iGodAbility2[iIndex], 0, 1));
			main ? (g_iGodMessage[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Message", 0)) : (g_iGodMessage2[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Message", g_iGodMessage[iIndex]));
			main ? (g_iGodMessage[iIndex] = iClamp(g_iGodMessage[iIndex], 0, 1)) : (g_iGodMessage2[iIndex] = iClamp(g_iGodMessage2[iIndex], 0, 1));
			main ? (g_iGodChance[iIndex] = kvSuperTanks.GetNum("God Ability/God Chance", 4)) : (g_iGodChance2[iIndex] = kvSuperTanks.GetNum("God Ability/God Chance", g_iGodChance[iIndex]));
			main ? (g_iGodChance[iIndex] = iClamp(g_iGodChance[iIndex], 1, 9999999999)) : (g_iGodChance2[iIndex] = iClamp(g_iGodChance2[iIndex], 1, 9999999999));
			main ? (g_flGodDuration[iIndex] = kvSuperTanks.GetFloat("God Ability/God Duration", 5.0)) : (g_flGodDuration2[iIndex] = kvSuperTanks.GetFloat("God Ability/God Duration", g_flGodDuration[iIndex]));
			main ? (g_flGodDuration[iIndex] = flClamp(g_flGodDuration[iIndex], 0.1, 9999999999.0)) : (g_flGodDuration2[iIndex] = flClamp(g_flGodDuration2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iGodAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && g_bGod[iTank])
		{
			tTimerStopGod(null, GetClientUserId(iTank));
		}
	}
}

public void ST_Ability(int tank)
{
	int iGodChance = !g_bTankConfig[ST_TankType(tank)] ? g_iGodChance[ST_TankType(tank)] : g_iGodChance2[ST_TankType(tank)];
	if (iGodAbility(tank) == 1 && GetRandomInt(1, iGodChance) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank) && !g_bGod[tank])
	{
		g_bGod[tank] = true;
		SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);
		float flGodDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flGodDuration[ST_TankType(tank)] : g_flGodDuration2[ST_TankType(tank)];
		CreateTimer(flGodDuration, tTimerStopGod, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
		if (iGodMessage(tank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "God", sTankName);
		}
		
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bGod[iPlayer] = false;
		}
	}
}

stock void vReset2(int tank)
{
	g_bGod[tank] = false;
	SetEntProp(tank, Prop_Data, "m_takedamage", 2, 1);
	if (iGodMessage(tank) == 1)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(tank, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "God2", sTankName);
	}
}

stock int iGodAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGodAbility[ST_TankType(tank)] : g_iGodAbility2[ST_TankType(tank)];
}

stock int iGodMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGodMessage[ST_TankType(tank)] : g_iGodMessage2[ST_TankType(tank)];
}

public Action tTimerStopGod(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bGod[iTank] = false;
		return Plugin_Stop;
	}
	if (iGodAbility(iTank) == 0 || !g_bGod[iTank])
	{
		vReset2(iTank);
		return Plugin_Stop;
	}
	vReset2(iTank);
	return Plugin_Continue;
}