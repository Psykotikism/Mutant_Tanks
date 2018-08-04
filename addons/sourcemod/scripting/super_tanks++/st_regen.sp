// Super Tanks++: Regen Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Regen Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bRegen[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flRegenInterval[ST_MAXTYPES + 1];
float g_flRegenInterval2[ST_MAXTYPES + 1];
int g_iRegenAbility[ST_MAXTYPES + 1];
int g_iRegenAbility2[ST_MAXTYPES + 1];
int g_iRegenHealth[ST_MAXTYPES + 1];
int g_iRegenHealth2[ST_MAXTYPES + 1];
int g_iRegenLimit[ST_MAXTYPES + 1];
int g_iRegenLimit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Regen Ability only supports Left 4 Dead 1 & 2.");
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
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_regen", "st_regen");
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRegen[iPlayer] = false;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	g_bRegen[client] = false;
}

public void OnClientDisconnect(int client)
{
	g_bRegen[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRegen[iPlayer] = false;
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
			main ? (g_iRegenAbility[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Enabled", 0)) : (g_iRegenAbility2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Enabled", g_iRegenAbility[iIndex]));
			main ? (g_iRegenAbility[iIndex] = iSetCellLimit(g_iRegenAbility[iIndex], 0, 1)) : (g_iRegenAbility2[iIndex] = iSetCellLimit(g_iRegenAbility2[iIndex], 0, 1));
			main ? (g_iRegenHealth[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Health", 1)) : (g_iRegenHealth2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Health", g_iRegenHealth[iIndex]));
			main ? (g_iRegenHealth[iIndex] = iSetCellLimit(g_iRegenHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iRegenHealth2[iIndex] = iSetCellLimit(g_iRegenHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_flRegenInterval[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Interval", 1.0)) : (g_flRegenInterval2[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Duration", g_flRegenInterval[iIndex]));
			main ? (g_flRegenInterval[iIndex] = flSetFloatLimit(g_flRegenInterval[iIndex], 0.1, 9999999999.0)) : (g_flRegenInterval2[iIndex] = flSetFloatLimit(g_flRegenInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_iRegenLimit[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Limit", ST_MAXHEALTH)) : (g_iRegenLimit2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Limit", g_iRegenLimit[iIndex]));
			main ? (g_iRegenLimit[iIndex] = iSetCellLimit(g_iRegenLimit[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iRegenLimit2[iIndex] = iSetCellLimit(g_iRegenLimit2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iRegenAbility = !g_bTankConfig[ST_TankType(client)] ? g_iRegenAbility[ST_TankType(client)] : g_iRegenAbility2[ST_TankType(client)];
	if (iRegenAbility == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bRegen[client])
	{
		g_bRegen[client] = true;
		float flRegenInterval = !g_bTankConfig[ST_TankType(client)] ? g_flRegenInterval[ST_TankType(client)] : g_flRegenInterval2[ST_TankType(client)];
		CreateTimer(flRegenInterval, tTimerRegen, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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
		fFilename.WriteLine("		// The Super Tank regenerates health.");
		fFilename.WriteLine("		// Requires \"st_regen.smx\" to be installed.");
		fFilename.WriteLine("		\"Regen Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank regenerates this much health each time.");
		fFilename.WriteLine("			// Positive numbers: Current health + Regen health");
		fFilename.WriteLine("			// Negative numbers: Current health - Regen health");
		fFilename.WriteLine("			// Minimum: -65535");
		fFilename.WriteLine("			// Maximum: 65535");
		fFilename.WriteLine("			\"Regen Health\"					\"1\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank regenerates health every time this many seconds passes.");
		fFilename.WriteLine("			// Minimum: 0.1");
		fFilename.WriteLine("			// Maximum: 9999999999.0");
		fFilename.WriteLine("			\"Regen Interval\"				\"1.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank stops regenerating health at this value.");
		fFilename.WriteLine("			// Positive numbers: The Super Tank will stop regenerating health when it reaches this number.");
		fFilename.WriteLine("			// Negative numbers: The Super Tank will stop losing health when it reaches this number.");
		fFilename.WriteLine("			// Minimum: -65535");
		fFilename.WriteLine("			// Maximum: 65535");
		fFilename.WriteLine("			\"Regen Limit\"					\"65535\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}

public Action tTimerRegen(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bRegen[iTank] = false;
		return Plugin_Stop;
	}
	int iRegenAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iRegenAbility[ST_TankType(iTank)] : g_iRegenAbility2[ST_TankType(iTank)];
	if (iRegenAbility == 0)
	{
		g_bRegen[iTank] = false;
		return Plugin_Stop;
	}
	int iHealth = GetClientHealth(iTank);
	int iRegenHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iRegenHealth[ST_TankType(iTank)]) : (iHealth + g_iRegenHealth2[ST_TankType(iTank)]);
	int iRegenLimit = !g_bTankConfig[ST_TankType(iTank)] ? g_iRegenLimit[ST_TankType(iTank)] : g_iRegenLimit2[ST_TankType(iTank)];
	int iExtraHealth = (iRegenHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iRegenHealth;
	int iExtraHealth2 = (iRegenHealth < iHealth) ? 1 : iRegenHealth;
	int iRealHealth = (iRegenHealth >= 0) ? iExtraHealth : iExtraHealth2;
	int iLimitHealth = (iRealHealth > iRegenLimit) ? iRegenLimit : iRealHealth;
	int iLimitHealth2 = (iRealHealth < iRegenLimit) ? iRegenLimit : iRealHealth;
	int iFinalHealth = (iRegenLimit >= 0) ? iLimitHealth : iLimitHealth2;
	SetEntityHealth(iTank, iFinalHealth);
	return Plugin_Continue;
}