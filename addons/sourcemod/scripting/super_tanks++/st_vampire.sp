// Super Tanks++: Vampire Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Vampire Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flVampireRange[ST_MAXTYPES + 1];
float g_flVampireRange2[ST_MAXTYPES + 1];
int g_iVampireAbility[ST_MAXTYPES + 1];
int g_iVampireAbility2[ST_MAXTYPES + 1];
int g_iVampireChance[ST_MAXTYPES + 1];
int g_iVampireChance2[ST_MAXTYPES + 1];
int g_iVampireHealth[ST_MAXTYPES + 1];
int g_iVampireHealth2[ST_MAXTYPES + 1];
int g_iVampireHit[ST_MAXTYPES + 1];
int g_iVampireHit2[ST_MAXTYPES + 1];
int g_iVampireRangeChance[ST_MAXTYPES + 1];
int g_iVampireRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Vampire Ability only supports Left 4 Dead 1 & 2.");
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
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_vampire", "st_vampire");
}

public void OnMapStart()
{
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
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
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iVampireChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iVampireChance[ST_TankType(attacker)] : g_iVampireChance2[ST_TankType(attacker)];
				int iVampireHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iVampireHit[ST_TankType(attacker)] : g_iVampireHit2[ST_TankType(attacker)];
				vVampireHit(attacker, iVampireChance, iVampireHit);
			}
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
			main ? (g_iVampireAbility[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Enabled", 0)) : (g_iVampireAbility2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Enabled", g_iVampireAbility[iIndex]));
			main ? (g_iVampireAbility[iIndex] = iSetCellLimit(g_iVampireAbility[iIndex], 0, 1)) : (g_iVampireAbility2[iIndex] = iSetCellLimit(g_iVampireAbility2[iIndex], 0, 1));
			main ? (g_iVampireChance[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Chance", 4)) : (g_iVampireChance2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Chance", g_iVampireChance[iIndex]));
			main ? (g_iVampireChance[iIndex] = iSetCellLimit(g_iVampireChance[iIndex], 1, 9999999999)) : (g_iVampireChance2[iIndex] = iSetCellLimit(g_iVampireChance2[iIndex], 1, 9999999999));
			main ? (g_iVampireHealth[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Health", 100)) : (g_iVampireHealth2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Health", g_iVampireHealth[iIndex]));
			main ? (g_iVampireHealth[iIndex] = iSetCellLimit(g_iVampireHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iVampireHealth2[iIndex] = iSetCellLimit(g_iVampireHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_iVampireHit[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit", 0)) : (g_iVampireHit2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Hit", g_iVampireHit[iIndex]));
			main ? (g_iVampireHit[iIndex] = iSetCellLimit(g_iVampireHit[iIndex], 0, 1)) : (g_iVampireHit2[iIndex] = iSetCellLimit(g_iVampireHit2[iIndex], 0, 1));
			main ? (g_flVampireRange[iIndex] = kvSuperTanks.GetFloat("Vampire Ability/Vampire Range", 500.0)) : (g_flVampireRange2[iIndex] = kvSuperTanks.GetFloat("Vampire Ability/Vampire Range", g_flVampireRange[iIndex]));
			main ? (g_flVampireRange[iIndex] = flSetFloatLimit(g_flVampireRange[iIndex], 1.0, 9999999999.0)) : (g_flVampireRange2[iIndex] = flSetFloatLimit(g_flVampireRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iVampireRangeChance[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Range Chance", 16)) : (g_iVampireRangeChance2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Vampire Range Chance", g_iVampireRangeChance[iIndex]));
			main ? (g_iVampireRangeChance[iIndex] = iSetCellLimit(g_iVampireRangeChance[iIndex], 1, 9999999999)) : (g_iVampireRangeChance2[iIndex] = iSetCellLimit(g_iVampireRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iVampireAbility = !g_bTankConfig[ST_TankType(client)] ? g_iVampireAbility[ST_TankType(client)] : g_iVampireAbility2[ST_TankType(client)];
	int iVampireRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iVampireChance[ST_TankType(client)] : g_iVampireChance2[ST_TankType(client)];
	if (iVampireAbility == 1 && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iVampireCount;
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		float flVampireRange = !g_bTankConfig[ST_TankType(client)] ? g_flVampireRange[ST_TankType(client)] : g_flVampireRange2[ST_TankType(client)];
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flVampireRange)
				{
					iVampireCount++;
				}
			}
		}
		if (iVampireCount > 0)
		{
			vVampireHit(client, iVampireRangeChance, iVampireAbility);
		}
	}
}

void vVampireHit(int client, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iHealth = GetClientHealth(client);
		int iVampireHealth = !g_bTankConfig[ST_TankType(client)] ? (iHealth + g_iVampireHealth[ST_TankType(client)]) : (iHealth + g_iVampireHealth2[ST_TankType(client)]);
		int iExtraHealth = (iVampireHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iVampireHealth;
		int iExtraHealth2 = (iVampireHealth < iHealth) ? 1 : iVampireHealth;
		int iRealHealth = (iVampireHealth >= 0) ? iExtraHealth : iExtraHealth2;
		SetEntityHealth(client, iRealHealth);
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
		fFilename.WriteLine("		// The Super Tank gains health from hurting survivors.");
		fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the Tank gains health.");
		fFilename.WriteLine("		// - \"Vampire Range\"");
		fFilename.WriteLine("		// - \"Vampire Range Chance\"");
		fFilename.WriteLine("		// \"Vampire Hit\" - When a survivor is hit by a Tank's claw or rock, the Tank gains health.");
		fFilename.WriteLine("		// - \"Vampire Chance\"");
		fFilename.WriteLine("		// Requires \"st_vampire.smx\" to be installed.");
		fFilename.WriteLine("		\"Vampire Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// Note: This setting does not affect the \"Vampire Hit\" setting.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Vampire Chance\"				\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank receives this much health from survivors.");
		fFilename.WriteLine("			// Note: Tank's health limit on any difficulty is 65,535.");
		fFilename.WriteLine("			// Positive numbers: Current health + Vampire health");
		fFilename.WriteLine("			// Negative numbers: Current health - Vampire health");
		fFilename.WriteLine("			// Minimum: -65535");
		fFilename.WriteLine("			// Maximum: 65535");
		fFilename.WriteLine("			\"Vampire Health\"				\"100\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
		fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Vampire Hit\"					\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
		fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
		fFilename.WriteLine("			\"Vampire Range\"					\"500.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Vampire Range Chance\"			\"16\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}