// Super Tanks++: God Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] God Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bGod[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flGodDuration[ST_MAXTYPES + 1];
float g_flGodDuration2[ST_MAXTYPES + 1];
int g_iGodAbility[ST_MAXTYPES + 1];
int g_iGodAbility2[ST_MAXTYPES + 1];
int g_iGodChance[ST_MAXTYPES + 1];
int g_iGodChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] God Ability only supports Left 4 Dead 1 & 2.");
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

public void OnPluginStart()
{
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_god", "st_god");
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bGod[iPlayer] = false;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	g_bGod[client] = false;
}

public void OnClientDisconnect(int client)
{
	g_bGod[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bGod[iPlayer] = false;
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

void vCreateInfoFile(const char[] filepath, const char[] folder, const char[] filename, const char[] label = "")
{
	char sConfigFilename[128];
	char sConfigLabel[128];
	File fFilename;
	Format(sConfigFilename, sizeof(sConfigFilename), "%s%s%s.txt", filepath, folder, filename);
	if (FileExists(sConfigFilename))
	{
		return;
	}
	fFilename = OpenFile(sConfigFilename, "w+");
	strlen(label) > 0 ? strcopy(sConfigLabel, sizeof(sConfigLabel), label) : strcopy(sConfigLabel, sizeof(sConfigLabel), sConfigFilename);
	if (fFilename != null)
	{
		fFilename.WriteLine("// Note: The config will automatically update any changes mid-game. No need to restart the server or reload the plugin.");
		fFilename.WriteLine("\"Super Tanks++\"");
		fFilename.WriteLine("{");
		fFilename.WriteLine("	\"Example\"");
		fFilename.WriteLine("	{");
		fFilename.WriteLine("		// The Super Tank gains temporary immunity to all damage.");
		fFilename.WriteLine("		// Requires \"st_god.smx\" to be installed.");
		fFilename.WriteLine("		\"God Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"God Chance\"					\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
		fFilename.WriteLine("			// Minimum: 0.1");
		fFilename.WriteLine("			// Maximum: 9999999999.0");
		fFilename.WriteLine("			\"God Duration\"					\"5.0\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}

public Action tTimerStopGod(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iGodAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iGodAbility[ST_TankType(iTank)] : g_iGodAbility2[ST_TankType(iTank)];
	if (iGodAbility == 0 || !bIsTank(iTank) || !IsPlayerAlive(iTank))
	{
		g_bGod[iTank] = false;
		return Plugin_Stop;
	}
	if (ST_TankAllowed(iTank))
	{
		g_bGod[iTank] = false;
		SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);
	}
	return Plugin_Continue;
}