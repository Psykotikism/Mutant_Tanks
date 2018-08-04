// Super Tanks++: Absorb Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Absorb Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bAbsorb[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flAbsorbDuration[ST_MAXTYPES + 1];
float g_flAbsorbDuration2[ST_MAXTYPES + 1];
int g_iAbsorbAbility[ST_MAXTYPES + 1];
int g_iAbsorbAbility2[ST_MAXTYPES + 1];
int g_iAbsorbChance[ST_MAXTYPES + 1];
int g_iAbsorbChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Absorb Ability only supports Left 4 Dead 1 & 2.");
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

public void OnPluginStart()
{
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_absorb", "st_absorb");
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bAbsorb[iPlayer] = false;
		}
	}
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bAbsorb[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bAbsorb[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bAbsorb[iPlayer] = false;
		}
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
		if (ST_TankAllowed(victim) && IsPlayerAlive(victim) && g_bAbsorb[victim])
		{
			if (damagetype & DMG_BULLET || damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
			{
				damage = damage / 10;
			}
			else if (damagetype & DMG_SLASH || damagetype & DMG_CLUB)
			{
				damage = damage / 1000;
			}
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
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
			main ? (g_iAbsorbAbility[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Enabled", 0)) : (g_iAbsorbAbility2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Enabled", g_iAbsorbAbility[iIndex]));
			main ? (g_iAbsorbAbility[iIndex] = iSetCellLimit(g_iAbsorbAbility[iIndex], 0, 1)) : (g_iAbsorbAbility2[iIndex] = iSetCellLimit(g_iAbsorbAbility2[iIndex], 0, 1));
			main ? (g_iAbsorbChance[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Absorb Chance", 4)) : (g_iAbsorbChance2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Absorb Chance", g_iAbsorbChance[iIndex]));
			main ? (g_iAbsorbChance[iIndex] = iSetCellLimit(g_iAbsorbChance[iIndex], 1, 9999999999)) : (g_iAbsorbChance2[iIndex] = iSetCellLimit(g_iAbsorbChance2[iIndex], 1, 9999999999));
			main ? (g_flAbsorbDuration[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Duration", 5.0)) : (g_flAbsorbDuration2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Duration", g_flAbsorbDuration[iIndex]));
			main ? (g_flAbsorbDuration[iIndex] = flSetFloatLimit(g_flAbsorbDuration[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbDuration2[iIndex] = flSetFloatLimit(g_flAbsorbDuration2[iIndex], 0.1, 9999999999.0));
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
		int iAbsorbAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iAbsorbAbility[ST_TankType(iTank)] : g_iAbsorbAbility2[ST_TankType(iTank)];
		if (iAbsorbAbility == 1 && ST_TankAllowed(iTank))
		{
			if (g_bAbsorb[iTank])
			{
				tTimerStopAbsorb(null, GetClientUserId(iTank));
			}
		}
	}
}

public void ST_Ability(int client)
{
	int iAbsorbAbility = !g_bTankConfig[ST_TankType(client)] ? g_iAbsorbAbility[ST_TankType(client)] : g_iAbsorbAbility2[ST_TankType(client)];
	int iAbsorbChance = !g_bTankConfig[ST_TankType(client)] ? g_iAbsorbChance[ST_TankType(client)] : g_iAbsorbChance2[ST_TankType(client)];
	if (iAbsorbAbility == 1 && GetRandomInt(1, iAbsorbChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bAbsorb[client])
	{
		g_bAbsorb[client] = true;
		float flAbsorbDuration = !g_bTankConfig[ST_TankType(client)] ? g_flAbsorbDuration[ST_TankType(client)] : g_flAbsorbDuration2[ST_TankType(client)];
		CreateTimer(flAbsorbDuration, tTimerStopAbsorb, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
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
		fFilename.WriteLine("		// The Super Tank absorbs most of the damage it receives.");
		fFilename.WriteLine("		// Requires \"st_absorb.smx\" to be installed.");
		fFilename.WriteLine("		\"Absorb Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Absorb Chance\"					\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
		fFilename.WriteLine("			// Minimum: 0.1");
		fFilename.WriteLine("			// Maximum: 9999999999.0");
		fFilename.WriteLine("			\"Absorb Duration\"				\"5.0\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}

public Action tTimerStopAbsorb(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bAbsorb[iTank] = false;
		return Plugin_Stop;
	}
	int iAbsorbAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iAbsorbAbility[ST_TankType(iTank)] : g_iAbsorbAbility2[ST_TankType(iTank)];
	if (iAbsorbAbility == 0)
	{
		g_bAbsorb[iTank] = false;
		return Plugin_Stop;
	}
	g_bAbsorb[iTank] = false;
	return Plugin_Continue;
}