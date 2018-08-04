// Super Tanks++: Electric Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Electric Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bElectric[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flElectricDuration[ST_MAXTYPES + 1];
float g_flElectricDuration2[ST_MAXTYPES + 1];
float g_flElectricInterval[ST_MAXTYPES + 1];
float g_flElectricInterval2[ST_MAXTYPES + 1];
float g_flElectricRange[ST_MAXTYPES + 1];
float g_flElectricRange2[ST_MAXTYPES + 1];
float g_flElectricSpeed[ST_MAXTYPES + 1];
float g_flElectricSpeed2[ST_MAXTYPES + 1];
int g_iElectricAbility[ST_MAXTYPES + 1];
int g_iElectricAbility2[ST_MAXTYPES + 1];
int g_iElectricChance[ST_MAXTYPES + 1];
int g_iElectricChance2[ST_MAXTYPES + 1];
int g_iElectricDamage[ST_MAXTYPES + 1];
int g_iElectricDamage2[ST_MAXTYPES + 1];
int g_iElectricHit[ST_MAXTYPES + 1];
int g_iElectricHit2[ST_MAXTYPES + 1];
int g_iElectricRangeChance[ST_MAXTYPES + 1];
int g_iElectricRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Electric Ability only supports Left 4 Dead 1 & 2.");
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
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_electric", "st_electric");
}

public void OnMapStart()
{
	vPrecacheParticle(PARTICLE_ELECTRICITY);
	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bElectric[iPlayer] = false;
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
	g_bElectric[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bElectric[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bElectric[iPlayer] = false;
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
				int iElectricChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iElectricChance[ST_TankType(attacker)] : g_iElectricChance2[ST_TankType(attacker)];
				int iElectricHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iElectricHit[ST_TankType(attacker)] : g_iElectricHit2[ST_TankType(attacker)];
				vElectricHit(victim, attacker, iElectricChance, iElectricHit);
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
			main ? (g_iElectricAbility[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Enabled", 0)) : (g_iElectricAbility2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Enabled", g_iElectricAbility[iIndex]));
			main ? (g_iElectricAbility[iIndex] = iSetCellLimit(g_iElectricAbility[iIndex], 0, 1)) : (g_iElectricAbility2[iIndex] = iSetCellLimit(g_iElectricAbility2[iIndex], 0, 1));
			main ? (g_iElectricChance[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Chance", 4)) : (g_iElectricChance2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Chance", g_iElectricChance[iIndex]));
			main ? (g_iElectricChance[iIndex] = iSetCellLimit(g_iElectricChance[iIndex], 1, 9999999999)) : (g_iElectricChance2[iIndex] = iSetCellLimit(g_iElectricChance2[iIndex], 1, 9999999999));
			main ? (g_iElectricDamage[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Damage", 5)) : (g_iElectricDamage2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Damage", g_iElectricDamage[iIndex]));
			main ? (g_iElectricDamage[iIndex] = iSetCellLimit(g_iElectricDamage[iIndex], 1, 9999999999)) : (g_iElectricDamage2[iIndex] = iSetCellLimit(g_iElectricDamage2[iIndex], 1, 9999999999));
			main ? (g_flElectricDuration[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Duration", 5.0)) : (g_flElectricDuration2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Duration", g_flElectricDuration[iIndex]));
			main ? (g_flElectricDuration[iIndex] = flSetFloatLimit(g_flElectricDuration[iIndex], 0.1, 9999999999.0)) : (g_flElectricDuration2[iIndex] = flSetFloatLimit(g_flElectricDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iElectricHit[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit", 0)) : (g_iElectricHit2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit", g_iElectricHit[iIndex]));
			main ? (g_iElectricHit[iIndex] = iSetCellLimit(g_iElectricHit[iIndex], 0, 1)) : (g_iElectricHit2[iIndex] = iSetCellLimit(g_iElectricHit2[iIndex], 0, 1));
			main ? (g_flElectricInterval[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Interval", 1.0)) : (g_flElectricInterval2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Interval", g_flElectricInterval[iIndex]));
			main ? (g_flElectricInterval[iIndex] = flSetFloatLimit(g_flElectricInterval[iIndex], 0.1, 9999999999.0)) : (g_flElectricInterval2[iIndex] = flSetFloatLimit(g_flElectricInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flElectricRange[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range", 150.0)) : (g_flElectricRange2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range", g_flElectricRange[iIndex]));
			main ? (g_flElectricRange[iIndex] = flSetFloatLimit(g_flElectricRange[iIndex], 1.0, 9999999999.0)) : (g_flElectricRange2[iIndex] = flSetFloatLimit(g_flElectricRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iElectricRangeChance[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Range Chance", 16)) : (g_iElectricRangeChance2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Range Chance", g_iElectricRangeChance[iIndex]));
			main ? (g_iElectricRangeChance[iIndex] = iSetCellLimit(g_iElectricRangeChance[iIndex], 1, 9999999999)) : (g_iElectricRangeChance2[iIndex] = iSetCellLimit(g_iElectricRangeChance2[iIndex], 1, 9999999999));
			main ? (g_flElectricSpeed[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Speed", 0.75)) : (g_flElectricSpeed2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Speed", g_flElectricSpeed[iIndex]));
			main ? (g_flElectricSpeed[iIndex] = flSetFloatLimit(g_flElectricSpeed[iIndex], 0.1, 0.9)) : (g_flElectricSpeed2[iIndex] = flSetFloatLimit(g_flElectricSpeed2[iIndex], 0.1, 0.9));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iElectricAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iElectricAbility[ST_TankType(iTank)] : g_iElectricAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iElectricAbility == 1)
		{
			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsSurvivor(iSurvivor) && g_bElectric[iSurvivor])
				{
					SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
				}
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iElectricAbility = !g_bTankConfig[ST_TankType(client)] ? g_iElectricAbility[ST_TankType(client)] : g_iElectricAbility2[ST_TankType(client)];
		int iElectricRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iElectricChance[ST_TankType(client)] : g_iElectricChance2[ST_TankType(client)];
		float flElectricRange = !g_bTankConfig[ST_TankType(client)] ? g_flElectricRange[ST_TankType(client)] : g_flElectricRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flElectricRange)
				{
					vElectricHit(iSurvivor, client, iElectricRangeChance, iElectricAbility);
				}
			}
		}
	}
}

void vElectricHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bElectric[client])
	{
		g_bElectric[client] = true;
		float flElectricSpeed = !g_bTankConfig[ST_TankType(owner)] ? g_flElectricSpeed[ST_TankType(owner)] : g_flElectricSpeed2[ST_TankType(owner)];
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", flElectricSpeed);
		float flElectricInterval = !g_bTankConfig[ST_TankType(owner)] ? g_flElectricInterval[ST_TankType(owner)] : g_flElectricInterval2[ST_TankType(owner)];
		DataPack dpDataPack = new DataPack();
		CreateDataTimer(flElectricInterval, tTimerElectric, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
		dpDataPack.WriteFloat(GetEngineTime());
		vAttachParticle(client, PARTICLE_ELECTRICITY, 2.0, 30.0);
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
		fFilename.WriteLine("		// The Super Tank electrocutes survivors.");
		fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is electrocuted.");
		fFilename.WriteLine("		// - \"Electric Range\"");
		fFilename.WriteLine("		// - \"Electric Range Chance\"");
		fFilename.WriteLine("		// \"Electric Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is electrocuted.");
		fFilename.WriteLine("		// - \"Electric Chance\"");
		fFilename.WriteLine("		// Requires \"st_electric.smx\" to be installed.");
		fFilename.WriteLine("		\"Electric Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// Note: This setting does not affect the \"Electric Hit\" setting.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Electric Chance\"				\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's electrocutions do this much damage.");
		fFilename.WriteLine("			// Minimum: 1");
		fFilename.WriteLine("			// Maximum: 9999999999");
		fFilename.WriteLine("			\"Electric Damage\"				\"5\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
		fFilename.WriteLine("			// Minimum: 0.1");
		fFilename.WriteLine("			// Maximum: 9999999999.0");
		fFilename.WriteLine("			\"Electric Duration\"				\"5.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
		fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Electric Hit\"					\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank electrocutes survivors every time this many seconds passes.");
		fFilename.WriteLine("			// Minimum: 0.1");
		fFilename.WriteLine("			// Maximum: 9999999999.0");
		fFilename.WriteLine("			\"Electric Interval\"				\"1.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
		fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
		fFilename.WriteLine("			\"Electric Range\"				\"150.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Electric Range Chance\"			\"16\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank sets the survivors' run speed to this value when they are electrocuted.");
		fFilename.WriteLine("			// Minimum: 0.1");
		fFilename.WriteLine("			// Maximum: 0.99");
		fFilename.WriteLine("			\"Electric Speed\"				\"0.75\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}

public Action tTimerElectric(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bElectric[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bElectric[iSurvivor] = false;
		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		return Plugin_Stop;
	}
	float flTime = pack.ReadFloat();
	int iElectricAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iElectricAbility[ST_TankType(iTank)] : g_iElectricAbility2[ST_TankType(iTank)];
	float flElectricDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flElectricDuration[ST_TankType(iTank)] : g_flElectricDuration2[ST_TankType(iTank)];
	if (iElectricAbility == 0 || (flTime + flElectricDuration) < GetEngineTime())
	{
		g_bElectric[iSurvivor] = false;
		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		return Plugin_Stop;
	}
	char sDamage[6];
	int iElectricDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iElectricDamage[ST_TankType(iTank)] : g_iElectricDamage2[ST_TankType(iTank)];
	IntToString(iElectricDamage, sDamage, sizeof(sDamage));
	vDamage(iSurvivor, sDamage);
	vShake(iSurvivor);
	vAttachParticle(iSurvivor, PARTICLE_ELECTRICITY, 2.0, 30.0);
	switch (GetRandomInt(1, 2)) 
	{
		case 1: EmitSoundToAll(SOUND_ELECTRICITY, iSurvivor);
		case 2: EmitSoundToAll(SOUND_ELECTRICITY2, iSurvivor);
	}
	return Plugin_Continue;
}