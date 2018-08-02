// Super Tanks++: Ice Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Ice Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bIce[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flIceDuration[ST_MAXTYPES + 1];
float g_flIceDuration2[ST_MAXTYPES + 1];
float g_flIceRange[ST_MAXTYPES + 1];
float g_flIceRange2[ST_MAXTYPES + 1];
int g_iIceAbility[ST_MAXTYPES + 1];
int g_iIceAbility2[ST_MAXTYPES + 1];
int g_iIceChance[ST_MAXTYPES + 1];
int g_iIceChance2[ST_MAXTYPES + 1];
int g_iIceHit[ST_MAXTYPES + 1];
int g_iIceHit2[ST_MAXTYPES + 1];
int g_iIceRangeChance[ST_MAXTYPES + 1];
int g_iIceRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Ice Ability only supports Left 4 Dead 1 & 2.");
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
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_ice", "st_ice");
}

public void OnMapStart()
{
	PrecacheSound(SOUND_BULLET, true);
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bIce[iPlayer] = false;
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
	g_bIce[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bIce[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bIce[iPlayer] = false;
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
				int iIceChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iIceChance[ST_TankType(attacker)] : g_iIceChance2[ST_TankType(attacker)];
				int iIceHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iIceHit[ST_TankType(attacker)] : g_iIceHit2[ST_TankType(attacker)];
				vIceHit(victim, attacker, iIceChance, iIceHit);
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
			main ? (g_iIceAbility[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", 0)) : (g_iIceAbility2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", g_iIceAbility[iIndex]));
			main ? (g_iIceAbility[iIndex] = iSetCellLimit(g_iIceAbility[iIndex], 0, 1)) : (g_iIceAbility2[iIndex] = iSetCellLimit(g_iIceAbility2[iIndex], 0, 1));
			main ? (g_iIceChance[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Chance", 4)) : (g_iIceChance2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Chance", g_iIceChance[iIndex]));
			main ? (g_iIceChance[iIndex] = iSetCellLimit(g_iIceChance[iIndex], 1, 9999999999)) : (g_iIceChance2[iIndex] = iSetCellLimit(g_iIceChance2[iIndex], 1, 9999999999));
			main ? (g_flIceDuration[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", 5.0)) : (g_flIceDuration2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", g_flIceDuration[iIndex]));
			main ? (g_flIceDuration[iIndex] = flSetFloatLimit(g_flIceDuration[iIndex], 0.1, 9999999999.0)) : (g_flIceDuration2[iIndex] = flSetFloatLimit(g_flIceDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iIceHit[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", 0)) : (g_iIceHit2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", g_iIceHit[iIndex]));
			main ? (g_iIceHit[iIndex] = iSetCellLimit(g_iIceHit[iIndex], 0, 1)) : (g_iIceHit2[iIndex] = iSetCellLimit(g_iIceHit2[iIndex], 0, 1));
			main ? (g_flIceRange[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", 150.0)) : (g_flIceRange2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", g_flIceRange[iIndex]));
			main ? (g_flIceRange[iIndex] = flSetFloatLimit(g_flIceRange[iIndex], 1.0, 9999999999.0)) : (g_flIceRange2[iIndex] = flSetFloatLimit(g_flIceRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iIceRangeChance[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Range Chance", 16)) : (g_iIceRangeChance2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Range Chance", g_iIceRangeChance[iIndex]));
			main ? (g_iIceRangeChance[iIndex] = iSetCellLimit(g_iIceRangeChance[iIndex], 1, 9999999999)) : (g_iIceRangeChance2[iIndex] = iSetCellLimit(g_iIceRangeChance2[iIndex], 1, 9999999999));
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
		int iIceAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iIceAbility[ST_TankType(iTank)] : g_iIceAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iIceAbility == 1)
		{
			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsSurvivor(iSurvivor) && g_bIce[iSurvivor])
				{
					DataPack dpDataPack;
					CreateDataTimer(0.1, tTimerStopIce, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
					dpDataPack.WriteCell(GetClientUserId(iSurvivor));
					dpDataPack.WriteCell(GetClientUserId(iTank));
				}
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client))
	{
		int iIceAbility = !g_bTankConfig[ST_TankType(client)] ? g_iIceAbility[ST_TankType(client)] : g_iIceAbility2[ST_TankType(client)];
		int iIceRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iIceChance[ST_TankType(client)] : g_iIceChance2[ST_TankType(client)];
		float flIceRange = !g_bTankConfig[ST_TankType(client)] ? g_flIceRange[ST_TankType(client)] : g_flIceRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flIceRange)
				{
					vIceHit(iSurvivor, client, iIceRangeChance, iIceAbility);
				}
			}
		}
	}
}

void vIceHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bIce[client])
	{
		g_bIce[client] = true;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) != MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
		}
		SetEntityRenderColor(client, 0, 130, 255, 190);
		EmitAmbientSound(SOUND_BULLET, flPos, client, SNDLEVEL_RAIDSIREN);
		float flIceDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flIceDuration[ST_TankType(owner)] : g_flIceDuration2[ST_TankType(owner)];
		DataPack dpDataPack;
		CreateDataTimer(flIceDuration, tTimerStopIce, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vStopIce(int client)
{
	if (g_bIce[client])
	{
		g_bIce[client] = false;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) == MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
		SetEntityRenderColor(client, 255, 255, 255, 255);
		EmitAmbientSound(SOUND_BULLET, flPos, client, SNDLEVEL_RAIDSIREN);
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
		fFilename.WriteLine("		// The Super Tank freezes survivors.");
		fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is frozen in place.");
		fFilename.WriteLine("		// - \"Ice Range\"");
		fFilename.WriteLine("		// - \"Ice Range Chance\"");
		fFilename.WriteLine("		// \"Ice Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is frozen in place.");
		fFilename.WriteLine("		// - \"Ice Chance\"");
		fFilename.WriteLine("		// Requires \"st_ice.smx\" to be installed.");
		fFilename.WriteLine("		\"Ice Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// Note: This setting does not affect the \"Ice Hit\" setting.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Ice Chance\"					\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
		fFilename.WriteLine("			// Minimum: 0.1");
		fFilename.WriteLine("			// Maximum: 9999999999.0");
		fFilename.WriteLine("			\"Ice Duration\"					\"5.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
		fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ice Hit\"						\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
		fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
		fFilename.WriteLine("			\"Ice Range\"						\"150.0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Ice Range Chance\"				\"16\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}

public Action tTimerStopIce(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iIceAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iIceAbility[ST_TankType(iTank)] : g_iIceAbility2[ST_TankType(iTank)];
	if (iIceAbility == 0 || !bIsTank(iTank) || !IsPlayerAlive(iTank) || !bIsSurvivor(iSurvivor))
	{
		if (bIsSurvivor(iSurvivor))
		{
			vStopIce(iSurvivor);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		vStopIce(iSurvivor);
	}
	return Plugin_Continue;
}