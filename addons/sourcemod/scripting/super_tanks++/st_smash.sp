// Super Tanks++: Smash Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Smash Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flSmashRange[ST_MAXTYPES + 1];
float g_flSmashRange2[ST_MAXTYPES + 1];
int g_iSmashAbility[ST_MAXTYPES + 1];
int g_iSmashAbility2[ST_MAXTYPES + 1];
int g_iSmashChance[ST_MAXTYPES + 1];
int g_iSmashChance2[ST_MAXTYPES + 1];
int g_iSmashHit[ST_MAXTYPES + 1];
int g_iSmashHit2[ST_MAXTYPES + 1];
int g_iSmashRangeChance[ST_MAXTYPES + 1];
int g_iSmashRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Smash Ability only supports Left 4 Dead 1 & 2.");
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
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_smash", "st_smash");
}

public void OnMapStart()
{
	vPrecacheParticle(PARTICLE_BLOOD);
	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);
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
				int iSmashChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iSmashChance[ST_TankType(attacker)] : g_iSmashChance2[ST_TankType(attacker)];
				int iSmashHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iSmashHit[ST_TankType(attacker)] : g_iSmashHit2[ST_TankType(attacker)];
				vSmashHit(victim, iSmashChance, iSmashHit);
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
			main ? (g_iSmashAbility[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", 0)) : (g_iSmashAbility2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", g_iSmashAbility[iIndex]));
			main ? (g_iSmashAbility[iIndex] = iSetCellLimit(g_iSmashAbility[iIndex], 0, 1)) : (g_iSmashAbility2[iIndex] = iSetCellLimit(g_iSmashAbility2[iIndex], 0, 1));
			main ? (g_iSmashChance[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Chance", 4)) : (g_iSmashChance2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Chance", g_iSmashChance[iIndex]));
			main ? (g_iSmashChance[iIndex] = iSetCellLimit(g_iSmashChance[iIndex], 1, 9999999999)) : (g_iSmashChance2[iIndex] = iSetCellLimit(g_iSmashChance2[iIndex], 1, 9999999999));
			main ? (g_iSmashHit[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", 0)) : (g_iSmashHit2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", g_iSmashHit[iIndex]));
			main ? (g_iSmashHit[iIndex] = iSetCellLimit(g_iSmashHit[iIndex], 0, 1)) : (g_iSmashHit2[iIndex] = iSetCellLimit(g_iSmashHit2[iIndex], 0, 1));
			main ? (g_flSmashRange[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", 150.0)) : (g_flSmashRange2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", g_flSmashRange[iIndex]));
			main ? (g_flSmashRange[iIndex] = flSetFloatLimit(g_flSmashRange[iIndex], 1.0, 9999999999.0)) : (g_flSmashRange2[iIndex] = flSetFloatLimit(g_flSmashRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iSmashRangeChance[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Range Chance", 16)) : (g_iSmashRangeChance2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Range Chance", g_iSmashRangeChance[iIndex]));
			main ? (g_iSmashRangeChance[iIndex] = iSetCellLimit(g_iSmashRangeChance[iIndex], 1, 9999999999)) : (g_iSmashRangeChance2[iIndex] = iSetCellLimit(g_iSmashRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iSurvivorId = event.GetInt("userid");
		int iSurvivor = GetClientOfUserId(iSurvivorId);
		int iTankId = event.GetInt("attacker");
		int iTank = GetClientOfUserId(iTankId);
		int iSmashAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iSmashAbility[ST_TankType(iTank)] : g_iSmashAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iSmashAbility == 1 && bIsSurvivor(iSurvivor))
		{
			int iCorpse = -1;
			while ((iCorpse = FindEntityByClassname(iCorpse, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iCorpse, Prop_Send, "m_hOwnerEntity");
				if (iSurvivor == iOwner)
				{
					AcceptEntityInput(iCorpse, "Kill");
				}
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iSmashAbility = !g_bTankConfig[ST_TankType(client)] ? g_iSmashAbility[ST_TankType(client)] : g_iSmashAbility2[ST_TankType(client)];
		int iSmashRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iSmashChance[ST_TankType(client)] : g_iSmashChance2[ST_TankType(client)];
		float flSmashRange = !g_bTankConfig[ST_TankType(client)] ? g_flSmashRange[ST_TankType(client)] : g_flSmashRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flSmashRange)
				{
					vSmashHit(iSurvivor, iSmashRangeChance, iSmashAbility);
				}
			}
		}
	}
}

void vSmashHit(int client, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		EmitSoundToAll(SOUND_SMASH, client);
		vAttachParticle(client, PARTICLE_BLOOD, 0.1, 0.0);
		ForcePlayerSuicide(client);
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
		fFilename.WriteLine("		// The Super Tank smashes survivors or crushes them to death.");
		fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is smashed.");
		fFilename.WriteLine("		// - \"Smash Range\"");
		fFilename.WriteLine("		// - \"Smash Range Chance\"");
		fFilename.WriteLine("		// \"Smash Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is crushed to death.");
		fFilename.WriteLine("		// - \"Smash Chance\"");
		fFilename.WriteLine("		// Requires \"st_smash.smx\" to be installed.");
		fFilename.WriteLine("		\"Smash Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// Note: This setting does not affect the \"Smash Hit\" setting.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Smash Chance\"					\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
		fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Smash Hit\"						\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
		fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
		fFilename.WriteLine("			\"Smash Range\"					\"150.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Smash Range Chance\"			\"16\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}