// Super Tanks++: Spam Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Spam Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bSpam[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flSpamDuration[ST_MAXTYPES + 1];
float g_flSpamDuration2[ST_MAXTYPES + 1];
int g_iSpamAbility[ST_MAXTYPES + 1];
int g_iSpamAbility2[ST_MAXTYPES + 1];
int g_iSpamChance[ST_MAXTYPES + 1];
int g_iSpamChance2[ST_MAXTYPES + 1];
int g_iSpamDamage[ST_MAXTYPES + 1];
int g_iSpamDamage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Spam Ability only supports Left 4 Dead 1 & 2.");
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
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_spam", "st_spam");
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bSpam[iPlayer] = false;
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
	g_bSpam[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bSpam[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bSpam[iPlayer] = false;
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
		if (bIsInfected(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (inflictor != -1)
			{
				int iOwner;
				if (HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity"))
				{
					iOwner = GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity");
				}
				int iThrower;
				if (HasEntProp(inflictor, Prop_Data, "m_hThrower"))
				{
					iThrower = GetEntPropEnt(inflictor, Prop_Data, "m_hThrower");
				}
				if ((iOwner > 0 && iOwner == victim) || (iThrower > 0 && iThrower == victim) || ST_TankAllowed(iOwner) || strcmp(sClassname, "tank_rock") == 0)
				{
					damage = 0.0;
					return Plugin_Changed;
				}
			}
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
			main ? (g_iSpamAbility[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", 0)) : (g_iSpamAbility2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", g_iSpamAbility[iIndex]));
			main ? (g_iSpamAbility[iIndex] = iSetCellLimit(g_iSpamAbility[iIndex], 0, 1)) : (g_iSpamAbility2[iIndex] = iSetCellLimit(g_iSpamAbility2[iIndex], 0, 1));
			main ? (g_iSpamChance[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Chance", 4)) : (g_iSpamChance2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Chance", g_iSpamChance[iIndex]));
			main ? (g_iSpamChance[iIndex] = iSetCellLimit(g_iSpamChance[iIndex], 1, 9999999999)) : (g_iSpamChance2[iIndex] = iSetCellLimit(g_iSpamChance2[iIndex], 1, 9999999999));
			main ? (g_iSpamDamage[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", 5)) : (g_iSpamDamage2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", g_iSpamDamage[iIndex]));
			main ? (g_iSpamDamage[iIndex] = iSetCellLimit(g_iSpamDamage[iIndex], 1, 9999999999)) : (g_iSpamDamage2[iIndex] = iSetCellLimit(g_iSpamDamage2[iIndex], 1, 9999999999));
			main ? (g_flSpamDuration[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", 5.0)) : (g_flSpamDuration2[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", g_flSpamDuration[iIndex]));
			main ? (g_flSpamDuration[iIndex] = flSetFloatLimit(g_flSpamDuration[iIndex], 0.1, 9999999999.0)) : (g_flSpamDuration2[iIndex] = flSetFloatLimit(g_flSpamDuration2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iSpamAbility = !g_bTankConfig[ST_TankType(client)] ? g_iSpamAbility[ST_TankType(client)] : g_iSpamAbility2[ST_TankType(client)];
	int iSpamChance = !g_bTankConfig[ST_TankType(client)] ? g_iSpamChance[ST_TankType(client)] : g_iSpamChance2[ST_TankType(client)];
	if (iSpamAbility == 1 && GetRandomInt(1, iSpamChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bSpam[client])
	{
		g_bSpam[client] = true;
		DataPack dpDataPack = new DataPack();
		CreateDataTimer(0.5, tTimerSpam, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
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
		fFilename.WriteLine("		// The Super Tank spams rocks at survivors.");
		fFilename.WriteLine("		// Requires \"st_spam.smx\" to be installed.");
		fFilename.WriteLine("		\"Spam Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Spam Chance\"					\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's rocks do this much damage.");
		fFilename.WriteLine("			// Minimum: 1");
		fFilename.WriteLine("			// Maximum: 9999999999");
		fFilename.WriteLine("			\"Spam Damage\"					\"5\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
		fFilename.WriteLine("			// Minimum: 0.1");
		fFilename.WriteLine("			// Maximum: 9999999999.0");
		fFilename.WriteLine("			\"Spam Duration\"					\"5.0\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}

public Action tTimerSpam(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bSpam[iTank] = false;
		return Plugin_Stop;
	}
	float flTime = pack.ReadFloat();
	int iSpamAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iSpamAbility[ST_TankType(iTank)] : g_iSpamAbility2[ST_TankType(iTank)];
	float flSpamDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flSpamDuration[ST_TankType(iTank)] : g_flSpamDuration2[ST_TankType(iTank)];
	if (iSpamAbility == 0 || (flTime + flSpamDuration) < GetEngineTime())
	{
		g_bSpam[iTank] = false;
		return Plugin_Stop;
	}
	char sDamage[6];
	int iSpamDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iSpamDamage[ST_TankType(iTank)] : g_iSpamDamage2[ST_TankType(iTank)];
	IntToString(iSpamDamage, sDamage, sizeof(sDamage));
	float flPos[3];
	float flAng[3];
	GetClientEyePosition(iTank, flPos);
	GetClientEyeAngles(iTank, flAng);
	flPos[2] += 80.0;
	int iSpammer = CreateEntityByName("env_rock_launcher");
	if (bIsValidEntity(iSpammer))
	{
		DispatchKeyValue(iSpammer, "rockdamageoverride", sDamage);
		TeleportEntity(iSpammer, flPos, flAng, NULL_VECTOR);
		DispatchSpawn(iSpammer);
		AcceptEntityInput(iSpammer, "LaunchRock");
		AcceptEntityInput(iSpammer, "Kill");
	}
	return Plugin_Continue;
}