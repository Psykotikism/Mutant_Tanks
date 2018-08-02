// Super Tanks++: Hurt Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Hurt Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bHurt[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flHurtDuration[ST_MAXTYPES + 1];
float g_flHurtDuration2[ST_MAXTYPES + 1];
float g_flHurtRange[ST_MAXTYPES + 1];
float g_flHurtRange2[ST_MAXTYPES + 1];
int g_iHurtAbility[ST_MAXTYPES + 1];
int g_iHurtAbility2[ST_MAXTYPES + 1];
int g_iHurtChance[ST_MAXTYPES + 1];
int g_iHurtChance2[ST_MAXTYPES + 1];
int g_iHurtDamage[ST_MAXTYPES + 1];
int g_iHurtDamage2[ST_MAXTYPES + 1];
int g_iHurtHit[ST_MAXTYPES + 1];
int g_iHurtHit2[ST_MAXTYPES + 1];
int g_iHurtRangeChance[ST_MAXTYPES + 1];
int g_iHurtRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Hurt Ability only supports Left 4 Dead 1 & 2.");
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
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_hurt", "st_hurt");
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bHurt[iPlayer] = false;
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
	g_bHurt[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bHurt[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bHurt[iPlayer] = false;
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
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iHurtChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iHurtChance[ST_TankType(attacker)] : g_iHurtChance2[ST_TankType(attacker)];
				int iHurtHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iHurtHit[ST_TankType(attacker)] : g_iHurtHit2[ST_TankType(attacker)];
				vHurtHit(victim, attacker, iHurtChance, iHurtHit);
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
			main ? (g_iHurtAbility[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Enabled", 0)) : (g_iHurtAbility2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Enabled", g_iHurtAbility[iIndex]));
			main ? (g_iHurtAbility[iIndex] = iSetCellLimit(g_iHurtAbility[iIndex], 0, 1)) : (g_iHurtAbility2[iIndex] = iSetCellLimit(g_iHurtAbility2[iIndex], 0, 1));
			main ? (g_iHurtChance[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Chance", 4)) : (g_iHurtChance2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Chance", g_iHurtChance[iIndex]));
			main ? (g_iHurtChance[iIndex] = iSetCellLimit(g_iHurtChance[iIndex], 1, 9999999999)) : (g_iHurtChance2[iIndex] = iSetCellLimit(g_iHurtChance2[iIndex], 1, 9999999999));
			main ? (g_iHurtDamage[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Damage", 1)) : (g_iHurtDamage2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Damage", g_iHurtDamage[iIndex]));
			main ? (g_iHurtDamage[iIndex] = iSetCellLimit(g_iHurtDamage[iIndex], 1, 9999999999)) : (g_iHurtDamage2[iIndex] = iSetCellLimit(g_iHurtDamage2[iIndex], 1, 9999999999));
			main ? (g_flHurtDuration[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Duration", 5.0)) : (g_flHurtDuration2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Duration", g_flHurtDuration[iIndex]));
			main ? (g_flHurtDuration[iIndex] = flSetFloatLimit(g_flHurtDuration[iIndex], 0.1, 9999999999.0)) : (g_flHurtDuration2[iIndex] = flSetFloatLimit(g_flHurtDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iHurtHit[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit", 0)) : (g_iHurtHit2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit", g_iHurtHit[iIndex]));
			main ? (g_iHurtHit[iIndex] = iSetCellLimit(g_iHurtHit[iIndex], 0, 1)) : (g_iHurtHit2[iIndex] = iSetCellLimit(g_iHurtHit2[iIndex], 0, 1));
			main ? (g_flHurtRange[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range", 150.0)) : (g_flHurtRange2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range", g_flHurtRange[iIndex]));
			main ? (g_flHurtRange[iIndex] = flSetFloatLimit(g_flHurtRange[iIndex], 1.0, 9999999999.0)) : (g_flHurtRange2[iIndex] = flSetFloatLimit(g_flHurtRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iHurtRangeChance[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Range Chance", 16)) : (g_iHurtRangeChance2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Range Chance", g_iHurtRangeChance[iIndex]));
			main ? (g_iHurtRangeChance[iIndex] = iSetCellLimit(g_iHurtRangeChance[iIndex], 1, 9999999999)) : (g_iHurtRangeChance2[iIndex] = iSetCellLimit(g_iHurtRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iHurtAbility = !g_bTankConfig[ST_TankType(client)] ? g_iHurtAbility[ST_TankType(client)] : g_iHurtAbility2[ST_TankType(client)];
		int iHurtRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iHurtChance[ST_TankType(client)] : g_iHurtChance2[ST_TankType(client)];
		float flHurtRange = !g_bTankConfig[ST_TankType(client)] ? g_flHurtRange[ST_TankType(client)] : g_flHurtRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flHurtRange)
				{
					vHurtHit(iSurvivor, client, iHurtRangeChance, iHurtAbility);
				}
			}
		}
	}
}

void vHurtHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bHurt[client])
	{
		g_bHurt[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(1.0, tTimerHurt, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
		dpDataPack.WriteFloat(GetEngineTime());
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
		fFilename.WriteLine("		// The Super Tank hurts survivors.");
		fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor gets hurt repeatedly.");
		fFilename.WriteLine("		// - \"Hurt Range\"");
		fFilename.WriteLine("		// - \"Hurt Range Chance\"");
		fFilename.WriteLine("		// \"Hurt Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor gets hurt repeatedly.");
		fFilename.WriteLine("		// - \"Hurt Chance\"");
		fFilename.WriteLine("		// Requires \"st_hurt.smx\" to be installed.");
		fFilename.WriteLine("		\"Hurt Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// Note: This setting does not affect the \"Hurt Hit\" setting.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Hurt Chance\"					\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's pain inflictions do this much damage.");
		fFilename.WriteLine("			// Minimum: 1");
		fFilename.WriteLine("			// Maximum: 9999999999");
		fFilename.WriteLine("			\"Hurt Damage\"					\"1\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
		fFilename.WriteLine("			// Minimum: 0.1");
		fFilename.WriteLine("			// Maximum: 9999999999.0");
		fFilename.WriteLine("			\"Hurt Duration\"					\"5.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
		fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Hurt Hit\"						\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
		fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
		fFilename.WriteLine("			\"Hurt Range\"					\"150.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Hurt Range Chance\"				\"16\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}

public Action tTimerHurt(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	int iHurtAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iHurtAbility[ST_TankType(iTank)] : g_iHurtAbility2[ST_TankType(iTank)];
	float flHurtDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flHurtDuration[ST_TankType(iTank)] : g_flHurtDuration2[ST_TankType(iTank)];
	if (iHurtAbility == 0 || !bIsTank(iTank) || !IsPlayerAlive(iTank) || !bIsSurvivor(iSurvivor) || (flTime + flHurtDuration) < GetEngineTime())
	{
		g_bHurt[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		char sDamage[6];
		int iHurtDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iHurtDamage[ST_TankType(iTank)] : g_iHurtDamage2[ST_TankType(iTank)];
		IntToString(iHurtDamage, sDamage, sizeof(sDamage));
		vDamage(iSurvivor, sDamage);
	}
	return Plugin_Continue;
}