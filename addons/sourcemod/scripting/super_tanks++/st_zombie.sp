// Super Tanks++: Zombie Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Zombie Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bTankConfig[ST_MAXTYPES + 1];
int g_iZombieAbility[ST_MAXTYPES + 1];
int g_iZombieAbility2[ST_MAXTYPES + 1];
int g_iZombieAmount[ST_MAXTYPES + 1];
int g_iZombieAmount2[ST_MAXTYPES + 1];
int g_iZombieInterval[MAXPLAYERS + 1];

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
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnPluginStart()
{
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_zombie", "st_zombie");
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iZombieInterval[iPlayer] = 0;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	g_iZombieInterval[client] = 0;
}

public void OnClientDisconnect(int client)
{
	g_iZombieInterval[client] = 0;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iZombieInterval[iPlayer] = 0;
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
			main ? (g_iZombieAbility[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Enabled", 0)) : (g_iZombieAbility2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Enabled", g_iZombieAbility[iIndex]));
			main ? (g_iZombieAbility[iIndex] = iSetCellLimit(g_iZombieAbility[iIndex], 0, 1)) : (g_iZombieAbility2[iIndex] = iSetCellLimit(g_iZombieAbility2[iIndex], 0, 1));
			main ? (g_iZombieAmount[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Amount", 10)) : (g_iZombieAmount2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Amount", g_iZombieAmount[iIndex]));
			main ? (g_iZombieAmount[iIndex] = iSetCellLimit(g_iZombieAmount[iIndex], 1, 100)) : (g_iZombieAmount2[iIndex] = iSetCellLimit(g_iZombieAmount2[iIndex], 1, 100));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iZombieAbility = !g_bTankConfig[ST_TankType(client)] ? g_iZombieAbility[ST_TankType(client)] : g_iZombieAbility2[ST_TankType(client)];
	if (iZombieAbility == 1 && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		g_iZombieInterval[client]++;
		int iZombieAmount = !g_bTankConfig[ST_TankType(client)] ? g_iZombieAmount[ST_TankType(client)] : g_iZombieAmount2[ST_TankType(client)];
		if (g_iZombieInterval[client] >= iZombieAmount)
		{
			for (int iZombie = 1; iZombie <= iZombieAmount; iZombie++)
			{
				vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", "zombie area");
			}
			g_iZombieInterval[client] = 0;
		}
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
		fFilename.WriteLine("		// The Super Tank spawns common infected.");
		fFilename.WriteLine("		// Requires \"st_zombie.smx\" to be installed.");
		fFilename.WriteLine("		\"Zombie Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank spawns this many common infected at once.");
		fFilename.WriteLine("			// Minimum: 1");
		fFilename.WriteLine("			// Maximum: 100");
		fFilename.WriteLine("			\"Zombie Amount\"					\"10\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}