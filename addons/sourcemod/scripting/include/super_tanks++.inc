// Super Tanks++
#if defined _supertanksplusplus_included
	#endinput
#endif
#define _supertanksplusplus_included

public SharedPlugin __pl_supertanksplusplus = 
{
	name = "super_tanks++",
	file = "super_tanks++.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_supertanksplusplus_SetNTVOptional()
{
	MarkNativeAsOptional("ST_MaxTypes");
	MarkNativeAsOptional("ST_PluginEnabled");
	MarkNativeAsOptional("ST_SpawnTank");
	MarkNativeAsOptional("ST_TankAllowed");
	MarkNativeAsOptional("ST_TankType");
}
#endif

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <adminmenu>
#define ST_PREFIX "[ST++]"
#define ST_NAME "Super Tanks++"
#define ST_AUTHOR "Psyk0tik (Crasher_3637)"
#define ST_DESCRIPTION "Super Tanks++ makes fighting Tanks great again!"
#define ST_VERSION "8.29"
#define ST_URL "https://forums.alliedmods.net/showthread.php?t=302140"
#define ST_MAXTYPES 2500
#define ST_MAXHEALTH 65535
#define ST_MAX_HEALTH_REDUCTION -65535

// Forwards
/* Called every second to trigger the Super Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param client		Client index of the Tank.
 */
forward void ST_Ability(int client);

/* Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param savepath		The savepath of the config.
 * @param limit			The limit for how many
 *							Super Tank types' settings
 *							to check for.
 * @param main			Checks whether the main config
 *							or a custom config
 *							is being used.
 */
forward void ST_Configs(char[] savepath, int limit, bool main);

/* Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 */
forward void ST_Event(Event event, const char[] name);

/* Called when the Tank's rock breaks.
 * Use this forward for any after-effects.
 *
 * @param client		Client index of the Tank.
 * @param entity		Entity index of the rock.
 */
forward void ST_RockBreak(int client, int entity);

/* Called when the Tank throws a rock.
 * Use this forward for any throwing abilities.
 *
 * @param client		Client index of the Tank.
 * @param entity		Entity index of the rock.
 */
forward void ST_RockThrow(int client, int entity);

/* Called when the Tank spawns.
 * Use this forward for any one-time abilities
 * or on-spawn presets.
 *
 * @param client		Client index of the Tank.
 */
forward void ST_Spawn(int client);

// Natives
/* Returns the value of the "Maximum Types" setting.
 *
 * @return				The value of the
 *							"Maximum Types" setting.
 */
native int ST_MaxTypes();

/* Returns the status of the core plugin.
 *
 * @return				True on success, false if
 *							core plugin is disabled.
 */
native bool ST_PluginEnabled();

/* Spawns a Tank with the specified Super Tank type.
 *
 * @param client		Client index of the Tank.
 * @param type			Type of Super Tank.
 */
native void ST_SpawnTank(int client, int type);

/* Returns the status of the "Human Super Tanks" setting.
 *
 * @param client		Client index of the Tank.
 *
 * @return				True on success, false if
 *							the setting is disabled.
 */
native bool ST_TankAllowed(int client);

/* Returns the Super Tank type of the Tank.
 *
 * @param client		Client index of the Tank.
 *
 * @return				The Tank's Super Tank type.
 */
native int ST_TankType(int client);

// Checks
stock bool bHasIdlePlayer(int client)
{
	char sClassname[12];
	GetEntityNetClass(client, sClassname, sizeof(sClassname));
	if (strcmp(sClassname, "SurvivorBot") == 0)
	{
		int iSpectatorUserId = GetEntProp(client, Prop_Send, "m_humanSpectatorUserID");
		if (iSpectatorUserId > 0)
		{
			int iIdler = GetClientOfUserId(iSpectatorUserId);
			if (iIdler > 0 && IsClientInGame(iIdler) && !IsFakeClient(iIdler) && (GetClientTeam(iIdler) != 2))
			{
				return true;
			}
		}
	}
	return false;
}

stock bool bIsBoomer(int client)
{
	if (bIsInfected(client))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 2)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsBotIdle(int client)
{
	return bIsSurvivor(client) && IsFakeClient(client) && bHasIdlePlayer(client);
}

stock bool bIsBotIdleSurvivor(int client)
{
	return bIsSurvivor(client) && IsFakeClient(client) && !bHasIdlePlayer(client);
}

stock bool bIsBotSurvivor(int client)
{
	return bIsSurvivor(client) && IsFakeClient(client);
}

stock bool bIsCharger(int client)
{
	if (bIsInfected(client))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 6)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsFinaleMap()
{
	return FindEntityByClassname(-1, "trigger_finale") != -1;
}

stock bool bIsHumanSurvivor(int client)
{
	return bIsSurvivor(client) && !IsFakeClient(client) && !bHasIdlePlayer(client) && !bIsPlayerIdle(client);
}

stock bool bIsHunter(int client)
{
	if (bIsInfected(client))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 3)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsIdlePlayer(int bot, int client)
{
	return bIsValidClient(client) && !IsFakeClient(client) && GetClientTeam(bot) == 2;
}

stock bool bIsInfected(int client)
{
	return bIsValidClient(client) && GetClientTeam(client) == 3;
}

stock bool bIsJockey(int client)
{
	if (bIsInfected(client))
	{
		if (bIsL4D2Game() && GetEntProp(client, Prop_Send, "m_zombieClass") == 5)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsL4D2Game()
{
	return GetEngineVersion() == Engine_Left4Dead2;
}

stock bool bIsPlayerBurning(int client)
{
	if (GetEntPropFloat(client, Prop_Send, "m_burnPercent") > 0)
	{
		return true;
	}
	return false;
}

stock bool bIsPlayerFired(int client)
{
	if (GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONFIRE)
	{
		return true;
	}
	return false;
}

stock bool bIsPlayerGrounded(int client)
{
	if (GetEntProp(client, Prop_Send, "m_fFlags") & FL_ONGROUND)
	{
		return true;
	}
	return false;
}

stock bool bIsPlayerIdle(int client)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!IsClientInGame(iPlayer) || GetClientTeam(iPlayer) != 2 || !IsFakeClient(iPlayer) || !bHasIdlePlayer(iPlayer))
		{
			continue;
		}
		char sClassname[12];
		GetEntityNetClass(iPlayer, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "SurvivorBot") == 0)
		{
			int iSpectatorUserId = GetEntProp(iPlayer, Prop_Send, "m_humanSpectatorUserID");
			if (iSpectatorUserId > 0)
			{
				int iIdler = GetClientOfUserId(iSpectatorUserId);
				if (iIdler == client)
				{
					return true;
				}
			}
		}
	}
	return false;
}

stock bool bIsPlayerIncapacitated(int client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1))
	{
		return true;
	}
	return false;
}

int g_iCurrentMode;
stock bool bIsPluginEnabled(ConVar convar, int mode, char[] enabled, char[] disabled)
{
	if (convar == null)
	{
		return false;
	}
	if (mode != 0)
	{
		g_iCurrentMode = 0;
		int iGameMode = CreateEntityByName("info_gamemode");
		DispatchSpawn(iGameMode);
		HookSingleEntityOutput(iGameMode, "OnCoop", vGameMode, true);
		HookSingleEntityOutput(iGameMode, "OnSurvival", vGameMode, true);
		HookSingleEntityOutput(iGameMode, "OnVersus", vGameMode, true);
		HookSingleEntityOutput(iGameMode, "OnScavenge", vGameMode, true);
		ActivateEntity(iGameMode);
		AcceptEntityInput(iGameMode, "PostSpawnActivate");
		AcceptEntityInput(iGameMode, "Kill");
		if (g_iCurrentMode == 0 || !(mode & g_iCurrentMode))
		{
			return false;
		}
	}
	char sGameMode[64];
	char sGameModes[64];
	convar.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);
	if (strcmp(enabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", enabled);
		if (StrContains(sGameModes, sGameMode, false) == -1)
		{
			return false;
		}
	}
	if (strcmp(disabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", disabled);
		if (StrContains(sGameModes, sGameMode, false) != -1)
		{
			return false;
		}
	}
	return true;
}

stock bool bIsSmoker(int client)
{
	if (bIsInfected(client))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 1)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsSpecialInfected(int client)
{
	if (bIsSmoker(client) || bIsBoomer(client) || bIsHunter(client) || bIsSpitter(client) || bIsJockey(client) || bIsCharger(client))
	{
		return true;
	}
	return false;
}

stock bool bIsSpitter(int client)
{
	if (bIsInfected(client))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 4)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsSurvivor(int client)
{
	return bIsValidClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client);
}

stock bool bIsTank(int client)
{
	if (bIsInfected(client))
	{
		int iClass = GetEntProp(client, Prop_Send, "m_zombieClass");
		if ((bIsL4D2Game() && iClass == 8) || (!bIsL4D2Game() && iClass == 5))
		{
			return true;
		}
	}
	return false;
}

stock bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

stock bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

stock bool bIsValidEntRef(int entity)
{
	return entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE;
}

stock bool bIsValidHumanClient(int client)
{
	return bIsValidClient(client) && !IsFakeClient(client);
}

stock bool bIsWitch(int client)
{
	if (IsValidEntity(client))
	{
		char sClassname[32];
		GetEntityClassname(client, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "witch") == 0)
		{
			return true;
		}
	}
	return false;
}

public bool bBoomerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsBoomer(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bChargerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsCharger(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bHunterFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsHunter(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bJockeyFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsJockey(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bSmokerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSmoker(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bSpitterFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSpitter(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bTankFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsTank(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bTraceRayDontHitSelf(int entity, int mask, any data)
{
	if (entity == data)
	{
		return false;
	}
	return true;
}

public bool bTraceRayDontHitSelfAndPlayer(int entity, int mask, any data)
{
	if (entity == data || bIsValidClient(entity))
	{
		return false;
	}
	return true;
}

public bool bTraceRayDontHitSelfAndSurvivor(int entity, int mask, any data)
{
	if (entity == data || bIsSurvivor(entity))
	{
		return false;
	}
	return true;
}

stock bool bVisiblePosition(float pos1[3], float pos2[3], int entity, int flag)
{
	Handle hTrace;
	switch (flag)
	{
		case 1: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndSurvivor, entity);
		case 2: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndPlayer, entity);
	}
	if (TR_DidHit(hTrace))
	{
		return false;
	}
	delete hTrace;
	return true;
}

// Functions
stock float flGetAngle(float angle1[3], float angle2[3])
{
	return ArcCosine(GetVectorDotProduct(angle1, angle2) / (GetVectorLength(angle1) * GetVectorLength(angle2)));
}

stock float flGetDistance(float pos[3], float angle[3], float offset1, float offset2, float force[3], int entity, int trace) 
{
	float flAngle[3];
	vCopyVector(angle, flAngle);
	flAngle[0] += offset1;
	flAngle[1] += offset2;
	GetAngleVectors(flAngle, force, NULL_VECTOR, NULL_VECTOR);
	float flDistance = flGetRayDistance(pos, flAngle, entity, trace);
	return flDistance;
}

stock float flGetGroundUnits(int entity)
{
	if (!(GetEntityFlags(entity) & FL_ONGROUND))
	{ 
		Handle hTrace;
		float flOrigin[3];
		float flPosition[3];
		float flDown[3] = {90.0, 0.0, 0.0};
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);
		hTrace = TR_TraceRayFilterEx(flOrigin, flDown, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, bTraceRayDontHitSelf, entity);
		if (TR_DidHit(hTrace))
		{
			float flUnits;
			TR_GetEndPosition(flPosition, hTrace);
			flUnits = flOrigin[2] - flPosition[2];
			delete hTrace;
			return flUnits;
		}
		delete hTrace;
	}
	return 0.0;
}

stock float flGetRayDistance(float pos[3], float angle[3], int entity, int trace)
{
	float flHitPos[3];
	iGetRayHitPos(pos, angle, flHitPos, entity, false, trace);
	return GetVectorDistance(pos, flHitPos);
}

stock float flSetFloatLimit(float value, float min, float max)
{
	if (value < min)
	{
		value = min;
	}
	else if (value > max)
	{
		value = max;
	}
	return value;
}

stock int iGetBotSurvivor()
{
	for (int iBot = MaxClients; iBot >= 1; iBot--)
	{
		if (bIsBotSurvivor(iBot))
		{
			return iBot;
		}
	}
	return -1;
}

stock int iGetHumanCount()
{
	int iHumanCount;
	for (int iHuman = 1; iHuman <= MaxClients; iHuman++)
	{
		if (bIsHumanSurvivor(iHuman))
		{
			iHumanCount++;
		}
	}
	return iHumanCount;
}

stock int iGetIdleBot(int client)
{
	for (int iBot = 1; iBot <= MaxClients; iBot++)
	{
		if (iGetIdlePlayer(iBot) == client)
		{
			return iBot;
		}
	}
	return 0;
}

stock int iGetIdlePlayer(int client)
{
	if (bIsBotSurvivor(client))
	{
		char sClassname[12];
		GetEntityNetClass(client, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "SurvivorBot") == 0)
		{
			int iIdler = GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));
			if (iIdler > 0 && IsClientInGame(iIdler) && GetClientTeam(iIdler) == 1)
			{
				return iIdler;
			}
		}
	}
	return 0;
}

stock int iGetNearestSurvivor(int client)
{
	float flDistance = 0.0;
	float flNearest = 0.0;
	float flPlayerPos[3];
	float flTargetPos[3];
	if (bIsValidClient(client))
	{
		GetClientAbsOrigin(client, flPlayerPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				GetClientAbsOrigin(iSurvivor, flTargetPos);
				flDistance = GetVectorDistance(flPlayerPos, flTargetPos);
				if (flNearest == 0.0 || flNearest > flDistance)
				{
					flNearest = flDistance;
				}
			}
		}
	}
	return RoundFloat(flDistance);
}

stock int iGetPlayerCount()
{
	int iPlayerCount;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidHumanClient(iPlayer))
		{
			iPlayerCount++;
		}
	}
	return iPlayerCount;
}

stock int iGetRandomSurvivor(int client)
{
	int iSurvivorCount;
	int iSurvivors[MAXPLAYERS + 1];
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && iSurvivor != client)
		{
			iSurvivors[iSurvivorCount++] = iSurvivor;
		}
	}
	return iSurvivors[GetRandomInt(0, iSurvivorCount - 1)];
}

stock int iGetRandomTarget(float pos[3], float angle[3])
{
	float flMin = 4.0;
	float flPos[3];
	float flAngle;
	int iTarget;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			GetClientEyePosition(iSurvivor, flPos);
			MakeVectorFromPoints(pos, flPos, flPos);
			flAngle = flGetAngle(angle, flPos);
			if (flAngle <= flMin)
			{
				flMin = flAngle;
				iTarget = iSurvivor;
			}
		}
	}
	return iTarget;
}

stock int iGetRayHitPos(float pos[3], float angle[3], float hitpos[3], int entity = 0, bool offset = false, int trace)
{
	int iHit = 0;
	Handle hTrace;
	switch (trace)
	{
		case 1: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, entity);
		case 2: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndPlayer, entity);
		case 3: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndSurvivor, entity);
	}
	if (TR_DidHit(hTrace))
	{
		TR_GetEndPosition(hitpos, hTrace);
		iHit = TR_GetEntityIndex(hTrace);
	}
	delete hTrace;
	if (offset)
	{
		float flVector[3];
		MakeVectorFromPoints(hitpos, pos, flVector);
		NormalizeVector(flVector, flVector);
		ScaleVector(flVector, 15.0);
		AddVectors(hitpos, flVector, hitpos);
	}
	return iHit;
}

stock int iGetRGBColor(int red, int green, int blue) 
{
	return (blue * 65536) + (green * 256) + red;
}

stock int iGetWitchCount()
{
	int iWitchCount;
	int iWitch = -1;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		iWitchCount++;
	}
	return iWitchCount;
}

stock int iSetCellLimit(int value, int min, int max)
{
	if (value < min)
	{
		value = min;
	}
	else if (value > max)
	{
		value = max;
	}
	return value;
}

stock void vAttachParticle(int client, char[] particlename, float time = 0.0, float origin = 0.0)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;
			DispatchKeyValue(iParticle, "scale", "");
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Enable");
			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vCheatCommand(int client, char[] command, char[] arguments = "", any ...)
{
	int iCmdFlags = GetCommandFlags(command);
	SetCommandFlags(command, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, iCmdFlags|FCVAR_CHEAT);
}

stock void vCopyVector(float source[3], float target[3])
{
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2];
}

stock void vCreateConfigFile(const char[] filepath, const char[] folder, const char[] filename, const char[] label = "", bool main = false)
{
	char sConfigFilename[128];
	char sConfigLabel[128];
	File fFilename;
	Format(sConfigFilename, sizeof(sConfigFilename), "%s%s%s.cfg", filepath, folder, filename);
	if (FileExists(sConfigFilename))
	{
		return;
	}
	fFilename = OpenFile(sConfigFilename, "w+");
	strlen(label) > 0 ? strcopy(sConfigLabel, sizeof(sConfigLabel), label) : strcopy(sConfigLabel, sizeof(sConfigLabel), sConfigFilename);
	if (fFilename != null)
	{
		if (main)
		{
			fFilename.WriteLine("// Super Tanks++ KeyValues Settings");
			fFilename.WriteLine("// Note: The config will automatically update any changes mid-game. No need to restart the server or reload the plugin.");
			fFilename.WriteLine("// If any of these Tanks don't work, make sure you have all the abilities installed.");
			fFilename.WriteLine("\"Super Tanks++\"");
			fFilename.WriteLine("{");
			fFilename.WriteLine("	// These are the general settings.");
			fFilename.WriteLine("	// Note: The following settings will not work in custom config files:");
			fFilename.WriteLine("	// \"Create Backup\"");
			fFilename.WriteLine("	// \"Game Mode Types\"");
			fFilename.WriteLine("	// \"Enabled Game Modes\"");
			fFilename.WriteLine("	// \"Disabled Game Modes\"");
			fFilename.WriteLine("	// \"Enable Custom Configs\"");
			fFilename.WriteLine("	// \"Create Config Types\"");
			fFilename.WriteLine("	// \"Execute Config Types\"");
			fFilename.WriteLine("	\"Plugin Settings\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable Super Tanks++.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Plugin Enabled\"				\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Super Tanks++ will create a backup config file.");
			fFilename.WriteLine("			// The file will be located in cfg/sourcemod/super_tanks++/backup_config.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Create Backup\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable Super Tanks++ in these game mode types.");
			fFilename.WriteLine("			// Add up numbers together for different results.");
			fFilename.WriteLine("			// 0: All game mode types.");
			fFilename.WriteLine("			// 1: Co-Op modes only.");
			fFilename.WriteLine("			// 2: Versus modes only.");
			fFilename.WriteLine("			// 4: Survival modes only.");
			fFilename.WriteLine("			// 8: Scavenge modes only. (Only available in Left 4 Dead 2.)");
			fFilename.WriteLine("			\"Game Mode Types\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable Super Tanks++ in these game modes.");
			fFilename.WriteLine("			// Separate game modes with commas.");
			fFilename.WriteLine("			// Game mode limit: 64");
			fFilename.WriteLine("			// Character limit for each game mode: 64");
			fFilename.WriteLine("			// Empty: All");
			fFilename.WriteLine("			// Not empty: Enabled only in these game modes.");
			fFilename.WriteLine("			\"Enabled Game Modes\"			\"\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Disable Super Tanks++ in these game modes.");
			fFilename.WriteLine("			// Separate game modes with commas.");
			fFilename.WriteLine("			// Game mode limit: 64");
			fFilename.WriteLine("			// Character limit for each game mode: 64");
			fFilename.WriteLine("			// Empty: None");
			fFilename.WriteLine("			// Not empty: Disabled only in these game modes.");
			fFilename.WriteLine("			\"Disabled Game Modes\"			\"\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Announce each Super Tank's arrival.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Announce Arrival\"				\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Announce each Super Tank's death.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Announce Death\"				\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Display Tanks' names and health.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON, show names only.");
			fFilename.WriteLine("			// 2: ON, show health only.");
			fFilename.WriteLine("			// 3: ON, show both names and health.");
			fFilename.WriteLine("			\"Display Health\"				\"3\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable Super Tanks++ in finales only.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Finales Only\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable Super Tanks++ for human-controlled Tanks.");
			fFilename.WriteLine("			// Note: Some Super Tank abilities may be too overpowered to use in a competitive game mode.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Human Super Tanks\"				\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Maximum types of Super Tanks allowed.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 2500");
			fFilename.WriteLine("			\"Maximum Types\"					\"86\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Multiply the Super Tank's health.");
			fFilename.WriteLine("			// Note: Health changes only occur when there are at least 2 alive non-idle human survivors.");
			fFilename.WriteLine("			// 0: No changes to health.");
			fFilename.WriteLine("			// 1: Multiply original health only.");
			fFilename.WriteLine("			// 2: Multiply extra health only.");
			fFilename.WriteLine("			// 3: Multiply both.");
			fFilename.WriteLine("			\"Multiply Health\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Amount of Tanks to spawn for each finale wave.");
			fFilename.WriteLine("			// Separate waves with commas.");
			fFilename.WriteLine("			// Wave limit: 3");
			fFilename.WriteLine("			// Character limit for each wave: 3");
			fFilename.WriteLine("			// 1st number = 1st wave");
			fFilename.WriteLine("			// 2nd number = 2nd wave");
			fFilename.WriteLine("			// 3rd number = 3rd wave");
			fFilename.WriteLine("			\"Tank Waves\"					\"2,3,4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Custom\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable Super Tanks++ custom configuration.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Enable Custom Configs\"			\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The type of custom config that Super Tanks++ creates.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Character limit: 5");
			fFilename.WriteLine("			// 1: Difficulties");
			fFilename.WriteLine("			// 2: Maps");
			fFilename.WriteLine("			// 3: Game modes");
			fFilename.WriteLine("			// 4: Days");
			fFilename.WriteLine("			// 5: Player count");
			fFilename.WriteLine("			\"Create Config Types\"			\"12345\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The type of custom config that Super Tanks++ executes.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Character limit: 5");
			fFilename.WriteLine("			// 1: Difficulties");
			fFilename.WriteLine("			// 2: Maps");
			fFilename.WriteLine("			// 3: Game modes");
			fFilename.WriteLine("			// 4: Days");
			fFilename.WriteLine("			// 5: Player count");
			fFilename.WriteLine("			\"Execute Config Types\"			\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Example\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Name of the Super Tank.");
			fFilename.WriteLine("			// Character limit: 32");
			fFilename.WriteLine("			// Empty: \"Tank\"");
			fFilename.WriteLine("			// Not Empty: Tank's custom name");
			fFilename.WriteLine("			\"Tank Name\"						\"Tank 1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// These are the Super Tank's skin and glow outline colors.");
			fFilename.WriteLine("			// Separate colors with \"|\".");
			fFilename.WriteLine("			// Separate RGBAs with commas.");
			fFilename.WriteLine("			// 1st set = skin color (RGBA)");
			fFilename.WriteLine("			// 2nd set = glow color (RGB)");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,255,255,255|255,255,255\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank will have a glow outline.");
			fFilename.WriteLine("			// Only available in Left 4 Dead 2.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Glow Effect\"					\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Props that the Super Tank can spawn with.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Character limit: 6");
			fFilename.WriteLine("			// 1: Attach a blur effect only.");
			fFilename.WriteLine("			// 2: Attach lights only.");
			fFilename.WriteLine("			// 3: Attach oxygen tanks only.");
			fFilename.WriteLine("			// 4: Attach flames to oxygen tanks.");
			fFilename.WriteLine("			// 5: Attach rocks only.");
			fFilename.WriteLine("			// 6: Attach tires only.");
			fFilename.WriteLine("			\"Props Attached\"				\"23456\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Each prop has 1 of this many chances to appear when the Super Tank appears.");
			fFilename.WriteLine("			// Separate chances with commas.");
			fFilename.WriteLine("			// Chances limit: 6");
			fFilename.WriteLine("			// Character limit for each chance: 3");
			fFilename.WriteLine("			// 1st number = Chance for a blur effect to appear.");
			fFilename.WriteLine("			// 2nd number = Chance for lights to appear.");
			fFilename.WriteLine("			// 3rd number = Chance for oxygen tanks to appear.");
			fFilename.WriteLine("			// 4th number = Chance for oxygen tank flames to appear.");
			fFilename.WriteLine("			// 5th number = Chance for rocks to appear.");
			fFilename.WriteLine("			// 6th number = Chance for tires to appear.");
			fFilename.WriteLine("			\"Props Chance\"					\"3,3,3,3,3,3\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's prop colors.");
			fFilename.WriteLine("			// Separate colors with \"|\".");
			fFilename.WriteLine("			// Separate RGBAs with commas.");
			fFilename.WriteLine("			// 1st set = lights color (RGBA)");
			fFilename.WriteLine("			// 2nd set = oxygen tanks color (RGBA)");
			fFilename.WriteLine("			// 3rd set = oxygen tank flames color (RGBA)");
			fFilename.WriteLine("			// 4th set = rocks color (RGBA)");
			fFilename.WriteLine("			// 5th set = tires color (RGBA)");
			fFilename.WriteLine("			\"Props Colors\"					\"255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank will spawn with a particle effect.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Particle Effect\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The particle effects for the Super Tank.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Character limit: 7");
			fFilename.WriteLine("			// 1: Blood Explosion");
			fFilename.WriteLine("			// 2: Electric Jolt");
			fFilename.WriteLine("			// 3: Fire Trail");
			fFilename.WriteLine("			// 4: Ice Steam");
			fFilename.WriteLine("			// 5: Meteor Smoke");
			fFilename.WriteLine("			// 6: Smoker Cloud");
			fFilename.WriteLine("			// 7: Acid Trail (Only available in Left 4 Dead 2.)");
			fFilename.WriteLine("			\"Particle Effects\"				\"1234567\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's rock will have a particle effect.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Rock Effect\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The particle effects for the Super Tank's rock.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Character limit: 4");
			fFilename.WriteLine("			// 1: Blood Explosion");
			fFilename.WriteLine("			// 2: Electric Jolt");
			fFilename.WriteLine("			// 3: Fire Trail");
			fFilename.WriteLine("			// 4: Acid Trail (Only available in Left 4 Dead 2.)");
			fFilename.WriteLine("			\"Rock Effects\"					\"1234\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// The Super Tank's claw attacks do this much damage.");
			fFilename.WriteLine("			// Minimum: 0.0");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Claw Damage\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Extra health given to the Super Tank.");
			fFilename.WriteLine("			// Note: Tank's health limit on any difficulty is 65,535.");
			fFilename.WriteLine("			// Note: Depending on the setting for \"Multiply Health,\" the Super Tank's health will be multiplied based on player count.");
			fFilename.WriteLine("			// Positive numbers: Current health + Extra health");
			fFilename.WriteLine("			// Negative numbers: Current health - Extra health");
			fFilename.WriteLine("			// Minimum: -65535");
			fFilename.WriteLine("			// Maximum: 65535");
			fFilename.WriteLine("			\"Extra Health\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's rock throws do this much damage.");
			fFilename.WriteLine("			// Minimum: 0.0");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Rock Damage\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Set the Super Tank's run speed.");
			fFilename.WriteLine("			// Note: Default run speed is 1.0.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 3.0");
			fFilename.WriteLine("			\"Run Speed\"						\"1.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank throws a rock every time this many seconds passes.");
			fFilename.WriteLine("			// Note: Default throw interval is 5.0 seconds.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Throw Interval\"				\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Give the Super Tank bullet immunity.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Bullet Immunity\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Give the Super Tank explosive immunity.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Explosive Immunity\"			\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Give the Super Tank fire immunity.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Fire Immunity\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Give the Super Tank melee immunity.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Melee Immunity\"				\"0\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("		// The Super Tank creates acid puddles.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, an acid puddle is created underneath the survivor.");
			fFilename.WriteLine("		// - \"Acid Range\"");
			fFilename.WriteLine("		// - \"Acid Range Chance\"");
			fFilename.WriteLine("		// \"Acid Hit\" - When a survivor is hit by a Tank's claw or rock, an acid puddle is created underneath the survivor.");
			fFilename.WriteLine("		// - \"Acid Chance\"");
			fFilename.WriteLine("		// Requires \"st_acid.smx\" to be installed.");
			fFilename.WriteLine("		\"Acid Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Acid Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Acid Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Acid Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Acid Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Acid Range Chance\"				\"16\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's rock creates an acid puddle when it breaks.");
			fFilename.WriteLine("			// Only available in Left 4 Dead 2.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Acid Rock Break\"				\"0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank receives more damage from bullets and explosions than usual.");
			fFilename.WriteLine("		// The Super Tank takes away survivors' ammunition.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, their ammunition is taken away.");
			fFilename.WriteLine("		// - \"Ammo Range\"");
			fFilename.WriteLine("		// - \"Ammo Range Chance\"");
			fFilename.WriteLine("		// \"Ammo Hit\" - When a survivor is hit by a Tank's claw or rock, their ammunition is taken away.");
			fFilename.WriteLine("		// - \"Ammo Chance\"");
			fFilename.WriteLine("		// Requires \"st_ammo.smx\" to be installed.");
			fFilename.WriteLine("		\"Ammo Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Ammo Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Ammo Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank sets survivors' ammunition to this amount.");
			fFilename.WriteLine("			// Minimum: 0");
			fFilename.WriteLine("			// Maximum: 25");
			fFilename.WriteLine("			\"Ammo Count\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ammo Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Ammo Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Ammo Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank blinds survivors.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is blinded.");
			fFilename.WriteLine("		// - \"Blind Range\"");
			fFilename.WriteLine("		// - \"Blind Range Chance\"");
			fFilename.WriteLine("		// \"Blind Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is blinded.");
			fFilename.WriteLine("		// - \"Blind Chance\"");
			fFilename.WriteLine("		// Requires \"st_blind.smx\" to be installed.");
			fFilename.WriteLine("		\"Blind Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Blind Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Blind Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Blind Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Blind Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The intensity of the Super Tank's blind effect.");
			fFilename.WriteLine("			// Minimum: 0 (No effect)");
			fFilename.WriteLine("			// Maximum: 255 (Fully blind)");
			fFilename.WriteLine("			\"Blind Intensity\"				\"255\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Blind Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Blind Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank creates explosions.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, an explosion is created around the survivor.");
			fFilename.WriteLine("		// - \"Bomb Range\"");
			fFilename.WriteLine("		// - \"Bomb Range Chance\"");
			fFilename.WriteLine("		// \"Bomb Hit\" - When a survivor is hit by a Tank's claw or rock, an explosion is created around the survivor.");
			fFilename.WriteLine("		// - \"Bomb Chance\"");
			fFilename.WriteLine("		// Requires \"st_bomb.smx\" to be installed.");
			fFilename.WriteLine("		\"Bomb Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Bomb Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Bomb Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Bomb Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Bomb Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Bomb Range Chance\"				\"16\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's rock creates an explosion when it breaks.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Bomb Rock Break\"				\"0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank buries survivors.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is buried.");
			fFilename.WriteLine("		// - \"Bury Range\"");
			fFilename.WriteLine("		// - \"Bury Range Chance\"");
			fFilename.WriteLine("		// \"Bury Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is buried.");
			fFilename.WriteLine("		// - \"Bury Chance\"");
			fFilename.WriteLine("		// Requires \"st_bury.smx\" to be installed.");
			fFilename.WriteLine("		\"Bury Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Bury Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Bury Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Bury Duration\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank buries survivors this deep into the ground.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Bury Height\"					\"50.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Bury Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Bury Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Bury Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank creates clones of itself.");
			fFilename.WriteLine("		// Requires \"st_clone.smx\" to be installed.");
			fFilename.WriteLine("		\"Clone Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The amount of clones the Super Tank can spawn.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 25");
			fFilename.WriteLine("			\"Clone Amount\"					\"2\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Clone Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's clones' health.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 65535");
			fFilename.WriteLine("			\"Clone Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank drops weapons upon death.");
			fFilename.WriteLine("		// Requires \"st_drop.smx\" to be installed.");
			fFilename.WriteLine("		\"Drop Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Drop Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to drop guns with a full clip.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Drop Clip Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's weapon size is multiplied by this value.");
			fFilename.WriteLine("			// Note: Default weapon size x Drop weapon scale");
			fFilename.WriteLine("			// Minimum: 1.0");
			fFilename.WriteLine("			// Maximum: 2.0");
			fFilename.WriteLine("			\"Drop Weapon Scale\"				\"1.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank drugs survivors.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is drugged.");
			fFilename.WriteLine("		// - \"Drug Range\"");
			fFilename.WriteLine("		// - \"Drug Range Chance\"");
			fFilename.WriteLine("		// \"Drug Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is drugged.");
			fFilename.WriteLine("		// - \"Drug Chance\"");
			fFilename.WriteLine("		// Requires \"st_drug.smx\" to be installed.");
			fFilename.WriteLine("		\"Drug Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Drug Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Drug Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Drug Duration\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Drug Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Drug Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Drug Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("		// The Super Tank forces survivors to only use a certain weapon slot.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is forced to only use a certain weapon slot.");
			fFilename.WriteLine("		// - \"Enforce Range\"");
			fFilename.WriteLine("		// - \"Enforce Range Chance\"");
			fFilename.WriteLine("		// \"Enforce Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is forced to only use a certain weapon slot.");
			fFilename.WriteLine("		// - \"Enforce Chance\"");
			fFilename.WriteLine("		// Requires \"st_enforce.smx\" to be installed.");
			fFilename.WriteLine("		\"Enforce Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Enforce Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Enforce Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Enforce Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Enforce Hit\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Enforce Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Enforce Range Chance\"			\"16\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank forces survivors to only use one of the following weapon slots.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Character limit: 5");
			fFilename.WriteLine("			// 1: 1st slot only.");
			fFilename.WriteLine("			// 2: 2nd slot only.");
			fFilename.WriteLine("			// 3: 3rd slot only.");
			fFilename.WriteLine("			// 4: 4th slot only.");
			fFilename.WriteLine("			// 5: 5th slot only.");
			fFilename.WriteLine("			\"Enforce Weapon Slots\"			\"12345\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank creates fires.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, a fire is created around the survivor.");
			fFilename.WriteLine("		// - \"Fire Range\"");
			fFilename.WriteLine("		// - \"Fire Range Chance\"");
			fFilename.WriteLine("		// \"Fire Hit\" - When a survivor is hit by a Tank's claw or rock, a fire is created around the survivor.");
			fFilename.WriteLine("		// - \"Fire Chance\"");
			fFilename.WriteLine("		// Requires \"st_fire.smx\" to be installed.");
			fFilename.WriteLine("		\"Fire Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Fire Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Fire Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Fire Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Fire Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Fire Range Chance\"				\"16\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's rock creates a fire when it breaks.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Fire Rock Break\"				\"0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank runs really fast like the Flash.");
			fFilename.WriteLine("		// Requires \"st_flash.smx\" to be installed.");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Flash Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Flash Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's special speed.");
			fFilename.WriteLine("			// Minimum: 3.0");
			fFilename.WriteLine("			// Maximum: 10.0");
			fFilename.WriteLine("			\"Flash Speed\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank flings survivors high into the air.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is flung into the air.");
			fFilename.WriteLine("		// - \"Fling Range\"");
			fFilename.WriteLine("		// - \"Fling Range Chance\"");
			fFilename.WriteLine("		// \"Fling Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is flung into the air.");
			fFilename.WriteLine("		// - \"Fling Chance\"");
			fFilename.WriteLine("		// Requires \"st_fling.smx\" to be installed.");
			fFilename.WriteLine("		\"Fling Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Fling Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Fling Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Fling Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Fling Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Fling Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank takes more damage.");
			fFilename.WriteLine("		// Requires \"st_fragile.smx\" to be installed.");
			fFilename.WriteLine("		\"Fragile Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Fragile Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Fragile Duration\"				\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank makes itself and any other nearby special infected invisible, and disarms survivors.");
			fFilename.WriteLine("		// \"Ability Enabled\" - Any nearby special infected turns invisible.");
			fFilename.WriteLine("		// - \"Ghost Cloak Range\"");
			fFilename.WriteLine("		// - \"Ghost Fade Limit\"");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is disarmed.");
			fFilename.WriteLine("		// - \"Ghost Range\"");
			fFilename.WriteLine("		// - \"Ghost Range Chance\"");
			fFilename.WriteLine("		// \"Ghost Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is disarmed.");
			fFilename.WriteLine("		// - \"Ghost Chance\"");
			fFilename.WriteLine("		// Requires \"st_ghost.smx\" to be installed.");
			fFilename.WriteLine("		\"Ghost Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Ghost Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Ghost Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a special infected and the Super Tank needed to trigger the cloak ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Ghost Cloak Range\"				\"500.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The limit of the Super Tank's ghost fade effect.");
			fFilename.WriteLine("			// Minimum: 0 (Fully faded)");
			fFilename.WriteLine("			// Maximum: 255 (No effect)");
			fFilename.WriteLine("			\"Ghost Fade Limit\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ghost Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Ghost Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Ghost Range Chance\"			\"16\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank disarms the following weapon slots.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Character limit: 5");
			fFilename.WriteLine("			// 1: 1st slot only.");
			fFilename.WriteLine("			// 2: 2nd slot only.");
			fFilename.WriteLine("			// 3: 3rd slot only.");
			fFilename.WriteLine("			// 4: 4th slot only.");
			fFilename.WriteLine("			// 5: 5th slot only.");
			fFilename.WriteLine("			\"Ghost Weapon Slots\"			\"12345\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("		// The Super Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.");
			fFilename.WriteLine("		// \"Ability Enabled\" - Any nearby infected and survivors are pulled in or pushed away.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor's gravity changes.");
			fFilename.WriteLine("		// - \"Gravity Range\"");
			fFilename.WriteLine("		// - \"Gravity Range Chance\"");
			fFilename.WriteLine("		// \"Gravity Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor's gravity changes.");
			fFilename.WriteLine("		// - \"Gravity Chance\"");
			fFilename.WriteLine("		// Requires \"st_gravity.smx\" to be installed.");
			fFilename.WriteLine("		\"Gravity Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Gravity Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Gravity Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Gravity Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's gravity force.");
			fFilename.WriteLine("			// Positive numbers = Push back");
			fFilename.WriteLine("			// Negative numbers = Pull back");
			fFilename.WriteLine("			// Minimum: -100.0");
			fFilename.WriteLine("			// Maximum: 100.0");
			fFilename.WriteLine("			\"Gravity Force\"					\"-50.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Gravity Hit\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Gravity Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Gravity Range Chance\"			\"16\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank sets the survivors' gravity to this value.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 0.99");
			fFilename.WriteLine("			\"Gravity Value\"					\"0.3\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank gains health from other nearby infected and sets survivors to black and white with temporary health.");
			fFilename.WriteLine("		// \"Ability Enabled\" - Any nearby infected can give the Tank some health.");
			fFilename.WriteLine("		// - \"Heal Interval\"");
			fFilename.WriteLine("		// - \"Heal Range\"");
			fFilename.WriteLine("		// \"Heal Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor can go black and white and have temporary health.");
			fFilename.WriteLine("		// - \"Heal Chance\"");
			fFilename.WriteLine("		// Requires \"st_heal.smx\" to be installed.");
			fFilename.WriteLine("		\"Heal Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Heal Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Heal Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Heal Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank receives health from nearby infected every time this many seconds passes.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Heal Interval\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between an infected and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Heal Range\"					\"500.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank receives this much health from nearby common infected.");
			fFilename.WriteLine("			// Positive numbers: Current health + Health from commons");
			fFilename.WriteLine("			// Negative numbers: Current health - Health from commons");
			fFilename.WriteLine("			// Minimum: -65535");
			fFilename.WriteLine("			// Maximum: 65535");
			fFilename.WriteLine("			\"Health From Commons\"			\"50\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank receives this much health from other nearby special infected.");
			fFilename.WriteLine("			// Positive numbers: Current health + Health from specials");
			fFilename.WriteLine("			// Negative numbers: Current health - Health from specials");
			fFilename.WriteLine("			// Minimum: -65535");
			fFilename.WriteLine("			// Maximum: 65535");
			fFilename.WriteLine("			\"Health From Specials\"			\"100\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank receives this much health from other nearby Tanks.");
			fFilename.WriteLine("			// Positive numbers: Current health + Health from Tanks");
			fFilename.WriteLine("			// Negative numbers: Current health - Health from Tanks");
			fFilename.WriteLine("			// Minimum: -65535");
			fFilename.WriteLine("			// Maximum: 65535");
			fFilename.WriteLine("			\"Health From Tanks\"				\"500\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("		// The Super Tank hypnotizes survivors to damage themselves or teammates.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is hypnotized.");
			fFilename.WriteLine("		// - \"Hypno Range\"");
			fFilename.WriteLine("		// - \"Hypno Range Chance\"");
			fFilename.WriteLine("		// \"Hypno Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is hypnotized.");
			fFilename.WriteLine("		// - \"Hypno Chance\"");
			fFilename.WriteLine("		// Requires \"st_hypno.smx\" to be installed.");
			fFilename.WriteLine("		\"Hypno Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Hypno Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Hypno Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Hypno Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Hypno Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The mode of the Super Tank's hypno ability.");
			fFilename.WriteLine("			// 0: Hypnotized survivors hurt themselves.");
			fFilename.WriteLine("			// 1: Hypnotized survivors can hurt their teammates.");
			fFilename.WriteLine("			\"Hypno Mode\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Hypno Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Hypno Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("		// The Super Tank forces survivors to go idle.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor goes idle.");
			fFilename.WriteLine("		// - \"Idle Range\"");
			fFilename.WriteLine("		// - \"Idle Range Chance\"");
			fFilename.WriteLine("		// \"Idle Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor goes idle.");
			fFilename.WriteLine("		// - \"Idle Chance\"");
			fFilename.WriteLine("		// Requires \"st_idle.smx\" to be installed.");
			fFilename.WriteLine("		\"Idle Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Idle Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Idle Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Idle Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Idle Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Idle Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank inverts the survivors' movement keys.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor's movement keys are inverted.");
			fFilename.WriteLine("		// - \"Invert Range\"");
			fFilename.WriteLine("		// - \"Invert Range Chance\"");
			fFilename.WriteLine("		// \"Invert Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor's movement keys are inverted.");
			fFilename.WriteLine("		// - \"Invert Chance\"");
			fFilename.WriteLine("		// Requires \"st_invert.smx\" to be installed.");
			fFilename.WriteLine("		\"Invert Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Invert Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"50.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Invert Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Invert Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Invert Hit\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Invert Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Invert Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank gives survivors items upon death.");
			fFilename.WriteLine("		// Requires \"st_item.smx\" to be installed.");
			fFilename.WriteLine("		\"Item Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Item Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank gives survivors this loadout.");
			fFilename.WriteLine("			// Item limit: 5");
			fFilename.WriteLine("			// Character limit for each item: 64");
			fFilename.WriteLine("			\"Item Loadout\"					\"rifle,pistol,first_aid_kit,pain_pills\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The mode of the Super Tank's item ability.");
			fFilename.WriteLine("			// 0: Survivors get a random item.");
			fFilename.WriteLine("			// 1: Survivors get all items.");
			fFilename.WriteLine("			\"Item Mode\"						\"0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank jumps really high.");
			fFilename.WriteLine("		// Requires \"st_jump.smx\" to be installed.");
			fFilename.WriteLine("		\"Jump Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Jump Chance\"					\"4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank heals special infected upon death.");
			fFilename.WriteLine("		// Requires \"st_medic.smx\" to be installed.");
			fFilename.WriteLine("		\"Medic Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Medic Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank gives special infected this much health each time.");
			fFilename.WriteLine("			// 1st number = Health given to Smokers.");
			fFilename.WriteLine("			// 2nd number = Health given to Boomers.");
			fFilename.WriteLine("			// 3rd number = Health given to Hunters.");
			fFilename.WriteLine("			// 4th number = Health given to Spitters.");
			fFilename.WriteLine("			// 5th number = Health given to Jockeys.");
			fFilename.WriteLine("			// 6th number = Health given to Chargers.");
			fFilename.WriteLine("			// Positive numbers: Current health + Medic health");
			fFilename.WriteLine("			// Negative numbers: Current health - Medic health");
			fFilename.WriteLine("			// Minimum: -65535");
			fFilename.WriteLine("			// Maximum: 65535");
			fFilename.WriteLine("			\"Medic Health\"					\"25,25,25,25,25,25\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The special infected's max health.");
			fFilename.WriteLine("			// The Super Tank will not heal special infected if they already have this much health.");
			fFilename.WriteLine("			// 1st number = Smoker's maximum health.");
			fFilename.WriteLine("			// 2nd number = Boomer's maximum health.");
			fFilename.WriteLine("			// 3rd number = Hunter's maximum health.");
			fFilename.WriteLine("			// 4th number = Spitter's maximum health.");
			fFilename.WriteLine("			// 5th number = Jockey's maximum health.");
			fFilename.WriteLine("			// 6th number = Charger's maximum health.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 65535");
			fFilename.WriteLine("			\"Medic Max Health\"				\"250,50,250,100,325,600\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Medic Range\"					\"500.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank creates meteor showers.");
			fFilename.WriteLine("		// Requires \"st_meteor.smx\" to be installed.");
			fFilename.WriteLine("		\"Meteor Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Meteor Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's meteorites do this much damage.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 9999999999");
			fFilename.WriteLine("			\"Meteor Damage\"					\"5\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The radius of the Super Tank's meteor shower.");
			fFilename.WriteLine("			// 1st number = Minimum radius");
			fFilename.WriteLine("			// Minimum: -200.0");
			fFilename.WriteLine("			// Maximum: 0.0");
			fFilename.WriteLine("			// 2nd number = Maximum radius");
			fFilename.WriteLine("			// Minimum: 0.0");
			fFilename.WriteLine("			// Maximum: 200.0");
			fFilename.WriteLine("			\"Meteor Radius\"					\"-180.0,180.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank spawns minions.");
			fFilename.WriteLine("		// Requires \"st_minion.smx\" to be installed.");
			fFilename.WriteLine("		\"Minion Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The amount of minions the Super Tank can spawn.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 25");
			fFilename.WriteLine("			\"Minion Amount\"					\"5\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Minion Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank can spawn these minions.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Repeat the same number to increase its chance of being chosen.");
			fFilename.WriteLine("			// Character limit: 12");
			fFilename.WriteLine("			// 1: Smoker");
			fFilename.WriteLine("			// 2: Boomer");
			fFilename.WriteLine("			// 3: Hunter");
			fFilename.WriteLine("			// 4: Spitter (Switches to Boomer in L4D1.)");
			fFilename.WriteLine("			// 5: Jockey (Switches to Hunter in L4D1.)");
			fFilename.WriteLine("			// 6: Charger (Switches to Smoker in L4D1.)");
			fFilename.WriteLine("			\"Minion Types\"					\"123456\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank nullifies all of the survivors' damage.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor does not do any damage.");
			fFilename.WriteLine("		// - \"Nullify Range\"");
			fFilename.WriteLine("		// - \"Nullify Range Chance\"");
			fFilename.WriteLine("		// \"Nullify Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor does not do any damage.");
			fFilename.WriteLine("		// - \"Nullify Chance\"");
			fFilename.WriteLine("		// Requires \"st_nullify.smx\" to be installed.");
			fFilename.WriteLine("		\"Nullify Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Nullify Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Nullify Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Nullify Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Nullify Hit\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Nullify Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Nullify Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank starts panic events.");
			fFilename.WriteLine("		// \"Ability Enabled\" - The Tank starts a panic event periodically.");
			fFilename.WriteLine("		// - \"Panic Interval\"");
			fFilename.WriteLine("		// \"Panic Hit\" - When a survivor is hit by a Tank's claw or rock, a panic event starts.");
			fFilename.WriteLine("		// - \"Panic Chance\"");
			fFilename.WriteLine("		// Requires \"st_panic.smx\" to be installed.");
			fFilename.WriteLine("		\"Panic Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Panic Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Panic Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Panic Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank starts a panic event every time this many seconds passes.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Panic Interval\"				\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank pimp slaps survivors.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is repeatedly pimp slapped.");
			fFilename.WriteLine("		// - \"Pimp Range\"");
			fFilename.WriteLine("		// - \"Pimp Range Chance\"");
			fFilename.WriteLine("		// \"Pimp Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is repeatedly pimp slapped.");
			fFilename.WriteLine("		// - \"Pimp Chance\"");
			fFilename.WriteLine("		// Requires \"st_pimp.smx\" to be installed.");
			fFilename.WriteLine("		\"Pimp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Pimp Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The amount of pimp slaps the Super Tank can give to survivors.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 9999999999");
			fFilename.WriteLine("			\"Pimp Amount\"					\"5\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Pimp Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's pimp slaps do this much damage.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 9999999999");
			fFilename.WriteLine("			\"Pimp Damage\"					\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Pimp Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Pimp Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Pimp Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank pukes on survivors.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the Tank pukes on the survivor.");
			fFilename.WriteLine("		// - \"Puke Range\"");
			fFilename.WriteLine("		// - \"Puke Range Chance\"");
			fFilename.WriteLine("		// \"Puke Hit\" - When a survivor is hit by a Tank's claw or rock, the Tank pukes on the survivor.");
			fFilename.WriteLine("		// - \"Puke Chance\"");
			fFilename.WriteLine("		// Requires \"st_puke.smx\" to be installed.");
			fFilename.WriteLine("		\"Puke Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Puke Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Puke Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Puke Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Puke Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Puke Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank gains speed when on fire.");
			fFilename.WriteLine("		// Requires \"st_pyro.smx\" to be installed.");
			fFilename.WriteLine("		\"Pyro Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's speed boost value when on fire.");
			fFilename.WriteLine("			// Note: This is a speed boost, not the overall speed. (Current speed + Pyro boost)");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 3.0");
			fFilename.WriteLine("			\"Pyro Boost\"					\"1.0\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank respawns.");
			fFilename.WriteLine("		// Requires \"st_respawn.smx\" to be installed.");
			fFilename.WriteLine("		\"Respawn Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank respawns up to this many times.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 9999999999");
			fFilename.WriteLine("			\"Respawn Amount\"				\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Respawn Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank respawns as a random Super Tank.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Respawn Random\"				\"0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank forces survivors to restart at the beginning of the map with a new loadout.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor respawns at the start of the map or near a teammate.");
			fFilename.WriteLine("		// - \"Restart Range\"");
			fFilename.WriteLine("		// - \"Restart Range Chance\"");
			fFilename.WriteLine("		// \"Restart Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor respawns at the start of the map or near a teammate.");
			fFilename.WriteLine("		// - \"Restart Chance\"");
			fFilename.WriteLine("		// Requires \"st_restart.smx\" to be installed.");
			fFilename.WriteLine("		\"Restart Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Restart Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Restart Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Restart Hit\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank makes survivors restart with this loadout.");
			fFilename.WriteLine("			// Item limit: 5");
			fFilename.WriteLine("			// Character limit for each item: 64");
			fFilename.WriteLine("			\"Restart Loadout\"				\"smg,pistol,pain_pills\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Restart Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Restart Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank creates rock showers.");
			fFilename.WriteLine("		// Requires \"st_rock.smx\" to be installed.");
			fFilename.WriteLine("		\"Rock Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Rock Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's rocks do this much damage.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 9999999999");
			fFilename.WriteLine("			\"Rock Damage\"					\"5\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Rock Duration\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The radius of the Super Tank's rock shower.");
			fFilename.WriteLine("			// 1st number = Minimum radius");
			fFilename.WriteLine("			// Minimum: -5.0");
			fFilename.WriteLine("			// Maximum: 0.0");
			fFilename.WriteLine("			// 2nd number = Maximum radius");
			fFilename.WriteLine("			// Minimum: 0.0");
			fFilename.WriteLine("			// Maximum: 5.0");
			fFilename.WriteLine("			\"Rock Radius\"					\"-1.25,1.25\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank sends survivors into space.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is sent into space.");
			fFilename.WriteLine("		// - \"Rocket Range\"");
			fFilename.WriteLine("		// - \"Rocket Range Chance\"");
			fFilename.WriteLine("		// \"Rocket Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is sent into space.");
			fFilename.WriteLine("		// - \"Rocket Chance\"");
			fFilename.WriteLine("		// Requires \"st_rocket.smx\" to be installed.");
			fFilename.WriteLine("		\"Rocket Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Rocket Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Rocket Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Rocket Hit\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Rocket Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Rocket Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank shakes the survivors' screens.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor's screen is shaken.");
			fFilename.WriteLine("		// - \"Shake Range\"");
			fFilename.WriteLine("		// - \"Shake Range Chance\"");
			fFilename.WriteLine("		// \"Shake Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor's screen is shaken.");
			fFilename.WriteLine("		// - \"Shake Chance\"");
			fFilename.WriteLine("		// Requires \"st_shake.smx\" to be installed.");
			fFilename.WriteLine("		\"Shake Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Shake Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Shake Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Shake Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Shake Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Shake Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Shake Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank protects itself with a shield and traps survivors inside their own shields.");
			fFilename.WriteLine("		// Requires \"st_shield.smx\" to be installed.");
			fFilename.WriteLine("		\"Shield Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// This is the Super Tank's shield's color.");
			fFilename.WriteLine("			// 1st number = Red");
			fFilename.WriteLine("			// 2nd number = Green");
			fFilename.WriteLine("			// 3rd number = Blue");
			fFilename.WriteLine("			\"Shield Color\"					\"255,255,255\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's shield reactivates after this many seconds passes.");
			fFilename.WriteLine("			// Minimum: 1.0");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Shield Delay\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank shoves survivors.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is shoved repeatedly.");
			fFilename.WriteLine("		// - \"Shove Range\"");
			fFilename.WriteLine("		// - \"Shove Range Chance\"");
			fFilename.WriteLine("		// \"Shove Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is shoved repeatedly.");
			fFilename.WriteLine("		// - \"Shove Chance\"");
			fFilename.WriteLine("		// Requires \"st_shove.smx\" to be installed.");
			fFilename.WriteLine("		\"Shove Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Shove Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Shove Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Shove Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Shove Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Shove Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Shove Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("		// The Super Tank smites survivors.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is smitten.");
			fFilename.WriteLine("		// - \"Smite Range\"");
			fFilename.WriteLine("		// - \"Smite Range Chance\"");
			fFilename.WriteLine("		// \"Smite Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is smitten.");
			fFilename.WriteLine("		// - \"Smite Chance\"");
			fFilename.WriteLine("		// Requires \"st_smite.smx\" to be installed.");
			fFilename.WriteLine("		\"Smite Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Smite Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Smite Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Smite Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Smite Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Smite Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("		// The Super Tank releases a splash damage upon death.");
			fFilename.WriteLine("		// Requires \"st_splash.smx\" to be installed.");
			fFilename.WriteLine("		\"Splash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Splash Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's splashes do this much damage.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 9999999999");
			fFilename.WriteLine("			\"Splash Damage\"					\"5\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Splash Range\"					\"150.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank slows survivors down.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor is slowed down.");
			fFilename.WriteLine("		// - \"Stun Range\"");
			fFilename.WriteLine("		// - \"Stun Range Chance\"");
			fFilename.WriteLine("		// \"Stun Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is slowed down.");
			fFilename.WriteLine("		// - \"Stun Chance\"");
			fFilename.WriteLine("		// Requires \"st_stun.smx\" to be installed.");
			fFilename.WriteLine("		\"Stun Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Stun Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Stun Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Stun Duration\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Stun Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Stun Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Stun Range Chance\"				\"16\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank sets the survivors' run speed to this value.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 0.99");
			fFilename.WriteLine("			\"Stun Speed\"					\"0.25\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank throws things.");
			fFilename.WriteLine("		// Requires \"st_throw.smx\" to be installed.");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON, the Super Tank throws cars.");
			fFilename.WriteLine("			// 2: ON, the Super Tank throws special infected.");
			fFilename.WriteLine("			// 3: ON, the Super Tank throws itself.");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank can throw these cars.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Repeat the same number to increase its chance of being chosen.");
			fFilename.WriteLine("			// Character limit: 6");
			fFilename.WriteLine("			// 1: Small car with a big hatchback.");
			fFilename.WriteLine("			// 2: Car that looks like a Chevrolet Impala SS.");
			fFilename.WriteLine("			// 3: Car that looks like a Sixth Generation Chevrolet Impala.");
			fFilename.WriteLine("			\"Throw Car Options\"				\"123\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank can throw these special infected.");
			fFilename.WriteLine("			// Combine numbers in any order for different results.");
			fFilename.WriteLine("			// Repeat the same number to increase its chance of being chosen.");
			fFilename.WriteLine("			// Character limit: 14");
			fFilename.WriteLine("			// 1: Smoker");
			fFilename.WriteLine("			// 2: Boomer");
			fFilename.WriteLine("			// 3: Hunter");
			fFilename.WriteLine("			// 4: Spitter (Switches to Boomer in L4D1.)");
			fFilename.WriteLine("			// 5: Jockey (Switches to Hunter in L4D1.)");
			fFilename.WriteLine("			// 6: Charger (Switches to Smoker in L4D1.)");
			fFilename.WriteLine("			// 7: Tank");
			fFilename.WriteLine("			\"Throw Infected Options\"		\"1234567\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank throws a heat-seeking rock that will track down the nearest survivor.");
			fFilename.WriteLine("		// Requires \"st_track.smx\" to be installed.");
			fFilename.WriteLine("		\"Track Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Track Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The mode of the Super Tank's track ability.");
			fFilename.WriteLine("			// 0: The Super Tank's rock will only start tracking when it's near a survivor.");
			fFilename.WriteLine("			// 1: The Super Tank's rock will track the nearest survivor.");
			fFilename.WriteLine("			\"Track Mode\"					\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's track ability is this fast.");
			fFilename.WriteLine("			// Note: This setting only applies if the \"Track Mode\" setting is set to 1.");
			fFilename.WriteLine("			// Minimum: 100.0");
			fFilename.WriteLine("			// Maximum: 500.0");
			fFilename.WriteLine("			\"Track Speed\"					\"300.0\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("		// The Super Tank changes the survivors' field of views.");
			fFilename.WriteLine("		// \"Ability Enabled\" - When a survivor is within range of the Tank, the survivor's vision changes.");
			fFilename.WriteLine("		// - \"Vision Range\"");
			fFilename.WriteLine("		// - \"Vision Range Chance\"");
			fFilename.WriteLine("		// \"Vision Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor's vision changes.");
			fFilename.WriteLine("		// - \"Vision Chance\"");
			fFilename.WriteLine("		// Requires \"st_vision.smx\" to be installed.");
			fFilename.WriteLine("		\"Vision Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// Note: This setting does not affect the \"Vision Hit\" setting.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Vision Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's ability effects last this long.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Vision Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank sets survivors' fields of view to this value.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 160");
			fFilename.WriteLine("			\"Vision FOV\"					\"160\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Vision Hit\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
			fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
			fFilename.WriteLine("			\"Vision Range\"					\"150.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the range ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Vision Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank warps to survivors and warps survivors back to teammates.");
			fFilename.WriteLine("		// \"Ability Enabled\" - The Tank warps to a random survivor.");
			fFilename.WriteLine("		// - \"Warp Interval\"");
			fFilename.WriteLine("		// \"Warp Hit\" - When a survivor is hit by a Tank's claw or rock, the survivor is warped to a random teammate.");
			fFilename.WriteLine("		// - \"Warp Chance\"");
			fFilename.WriteLine("		// Requires \"st_warp.smx\" to be installed.");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
			fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
			fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
			fFilename.WriteLine("			\"Warp Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// Enable the Super Tank's claw/rock attack.");
			fFilename.WriteLine("			// Note: This setting does not need \"Ability Enabled\" set to 1.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Warp Hit\"						\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank warps to a random survivor every time this many seconds passes.");
			fFilename.WriteLine("			// Minimum: 0.1");
			fFilename.WriteLine("			// Maximum: 9999999999.0");
			fFilename.WriteLine("			\"Warp Interval\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The mode of the Super Tank's warp ability.");
			fFilename.WriteLine("			// 0: The Super Tank warps to a random survivor.");
			fFilename.WriteLine("			// 1: The Super Tank switches places with a random survivor.");
			fFilename.WriteLine("			\"Warp Mode\"						\"0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		// The Super Tank spawns Witch minions.");
			fFilename.WriteLine("		// Requires \"st_witch.smx\" to be installed.");
			fFilename.WriteLine("		\"Witch Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			// Enable this ability.");
			fFilename.WriteLine("			// 0: OFF");
			fFilename.WriteLine("			// 1: ON");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank spawns this many Witches at once.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 25");
			fFilename.WriteLine("			\"Witch Amount\"					\"3\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("			// The Super Tank's Witch minion causes this much damage per hit.");
			fFilename.WriteLine("			// Minimum: 1");
			fFilename.WriteLine("			// Maximum: 9999999999");
			fFilename.WriteLine("			\"Witch Minion Damage\"			\"5\"");
			fFilename.WriteLine("		}");
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
			fFilename.WriteLine("	// Super Tanks++ Samples");
			fFilename.WriteLine("	// These Tanks should not be used as-is because they are just meant to showcase each ability.");
			fFilename.WriteLine("	// Some of them may be too overpowered for players and bots.");
			fFilename.WriteLine("	// It is recommended to configure these settings based on your own liking.");
			fFilename.WriteLine("	\"Tank 1\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Absorber Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"50,90,150,255|50,90,150\"");
			fFilename.WriteLine("			\"Props Colors\"					\"10,10,10,255|10,10,10,255|10,10,10,180|10,10,10,255|10,10,10,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Absorb Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Absorb Chance\"					\"4\"");
			fFilename.WriteLine("			\"Absorb Duration\"				\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 2\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Acidic Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,255,125,255|0,255,125\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,0,0,255|255,0,0,255|255,0,0,180|255,0,0,255|255,0,0,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"7\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Acid Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Acid Chance\"					\"4\"");
			fFilename.WriteLine("			\"Acid Hit\"						\"1\"");
			fFilename.WriteLine("			\"Acid Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Acid Range Chance\"				\"16\"");
			fFilename.WriteLine("			\"Acid Rock Break\"				\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 3\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Ammo Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"170,200,210,255|170,200,210\"");
			fFilename.WriteLine("			\"Props Colors\"					\"5,20,35,255|5,20,35,255|5,20,35,180|5,20,35,255|5,20,35,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Ammo Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Ammo Chance\"					\"4\"");
			fFilename.WriteLine("			\"Ammo Count\"					\"0\"");
			fFilename.WriteLine("			\"Ammo Hit\"						\"1\"");
			fFilename.WriteLine("			\"Ammo Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Ammo Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 4\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Blind Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"5,0,105,255|5,0,105\"");
			fFilename.WriteLine("			\"Props Colors\"					\"30,20,0,255|30,20,0,255|30,20,0,180|30,20,0,255|30,20,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Blind Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Blind Chance\"					\"4\"");
			fFilename.WriteLine("			\"Blind Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Blind Hit\"						\"1\"");
			fFilename.WriteLine("			\"Blind Intensity\"				\"255\"");
			fFilename.WriteLine("			\"Blind Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Blind Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 5\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Bomber Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"100,0,0,255|100,0,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"15,15,15,255|15,15,15,255|15,15,15,180|15,15,15,255|15,15,15,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Explosive Immunity\"			\"1\"");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Bomb Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Bomb Chance\"					\"4\"");
			fFilename.WriteLine("			\"Bomb Hit\"						\"1\"");
			fFilename.WriteLine("			\"Bomb Rock Break\"				\"1\"");
			fFilename.WriteLine("			\"Bomb Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Bomb Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 6\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Bombshell Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,100,0,255|255,100,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,100,125,255|255,100,125,255|255,100,125,180|255,100,125,255|255,100,125,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Explosive Immunity\"			\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 7\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Boomer Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"65,105,0,255|65,105,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,0,65,255|0,0,65,255|0,0,65,180|0,0,65,255|0,0,65,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"1\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Minion Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Minion Amount\"					\"5\"");
			fFilename.WriteLine("			\"Minion Chance\"					\"5\"");
			fFilename.WriteLine("			\"Minion Types\"					\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"2\"");
			fFilename.WriteLine("			\"Throw Infected Options\"		\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 8\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Bulletproof Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"135,0,85,255|135,0,85\"");
			fFilename.WriteLine("			\"Props Colors\"					\"135,255,85,255|135,255,85,255|135,255,85,180|135,255,85,255|135,255,85,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Bullet Immunity\"				\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 9\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Burier Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,170,0,255|255,170,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,170,255,255|0,170,255,255|0,170,255,180|0,170,255,255|0,170,255,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Bury Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Bury Chance\"					\"4\"");
			fFilename.WriteLine("			\"Bury Duration\"					\"5.0\"");
			fFilename.WriteLine("			\"Bury Height\"					\"50.0\"");
			fFilename.WriteLine("			\"Bury Hit\"						\"1\"");
			fFilename.WriteLine("			\"Bury Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Bury Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 10\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Car Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,120,75,255|255,120,75\"");
			fFilename.WriteLine("			\"Props Colors\"					\"100,35,0,255|100,35,0,255|100,35,0,180|100,35,0,255|100,35,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"10.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Throw Car Options\"				\"123\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 11\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Charger Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"95,140,80,255|95,140,80\"");
			fFilename.WriteLine("			\"Props Colors\"					\"25,255,115,255|25,255,115,255|25,255,115,180|25,255,115,255|25,255,115,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Minion Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Minion Amount\"					\"5\"");
			fFilename.WriteLine("			\"Minion Chance\"					\"5\"");
			fFilename.WriteLine("			\"Minion Types\"					\"6\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"2\"");
			fFilename.WriteLine("			\"Throw Infected Options\"		\"6\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 12\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Clone Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"10,25,205,255|10,25,205\"");
			fFilename.WriteLine("			\"Props Colors\"					\"140,40,255,255|140,40,255,255|140,40,255,180|140,40,255,255|140,40,255,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Clone Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Clone Amount\"					\"2\"");
			fFilename.WriteLine("			\"Clone Chance\"					\"4\"");
			fFilename.WriteLine("			\"Clone Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"2\"");
			fFilename.WriteLine("			\"Throw Infected Options\"		\"7\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 13\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Dropper Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"200,100,0,255|200,100,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,100,200,255|0,100,200,255|0,100,200,180|0,100,200,255|0,100,200,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Drop Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Drop Chance\"					\"4\"");
			fFilename.WriteLine("			\"Drop Clip Chance\"				\"4\"");
			fFilename.WriteLine("			\"Drop Weapon Scale\"				\"1.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 14\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Drugger Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,245,0,255|255,245,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"55,205,65,255|55,205,65,255|55,205,65,180|55,205,65,255|55,205,65,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Drug Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Drug Chance\"					\"4\"");
			fFilename.WriteLine("			\"Drug Duration\"					\"5.0\"");
			fFilename.WriteLine("			\"Drug Hit\"						\"1\"");
			fFilename.WriteLine("			\"Drug Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Drug Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 15\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Electric Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"100,165,255,255|100,165,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,0,50,255|0,0,50,255|0,0,50,180|0,0,50,255|0,0,50,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Electric Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Electric Chance\"				\"4\"");
			fFilename.WriteLine("			\"Electric Damage\"				\"5\"");
			fFilename.WriteLine("			\"Electric Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Electric Hit\"					\"1\"");
			fFilename.WriteLine("			\"Electric Interval\"				\"1.0\"");
			fFilename.WriteLine("			\"Electric Range\"				\"150.0\"");
			fFilename.WriteLine("			\"Electric Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Electric Speed\"				\"0.75\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 16\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Enforcer Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"200,150,50,255|200,150,50\"");
			fFilename.WriteLine("			\"Props Colors\"					\"50,150,200,255|50,150,200,255|50,150,200,180|50,150,200,255|50,150,200,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enforce Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Enforce Chance\"				\"4\"");
			fFilename.WriteLine("			\"Enforce Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Enforce Hit\"					\"1\"");
			fFilename.WriteLine("			\"Enforce Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Enforce Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Enforce Weapon Slots\"			\"12345\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 17\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Fireproof Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"150,0,0,255|150,0,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,135,0,255|255,135,0,255|255,135,0,180|255,135,0,255|255,135,0,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"3\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Fire Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Fire Chance\"					\"4\"");
			fFilename.WriteLine("			\"Fire Hit\"						\"1\"");
			fFilename.WriteLine("			\"Fire Rock Break\"				\"1\"");
			fFilename.WriteLine("			\"Fire Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Fire Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 18\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Flash Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,0,0,150|255,255,0\"");
			fFilename.WriteLine("			\"Props Attached\"				\"123456\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,3,3,3,3,3\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,255,0,150|255,255,0,150|255,255,0,180|255,255,0,150|255,255,0,150\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"2\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"3.0\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Flash Chance\"					\"4\"");
			fFilename.WriteLine("			\"Flash Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Flash Speed\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 19\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Flinger Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"160,225,65,255|160,225,65\"");
			fFilename.WriteLine("			\"Props Colors\"					\"25,40,130,255|25,40,130,255|25,40,130,180|25,40,130,255|25,40,130,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Fling Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Fling Chance\"					\"4\"");
			fFilename.WriteLine("			\"Fling Hit\"						\"1\"");
			fFilename.WriteLine("			\"Fling Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Fling Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 20\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Fragile Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,150,50,255|50,150,50\"");
			fFilename.WriteLine("			\"Props Colors\"					\"50,150,50,255|50,150,50,255|50,150,50,180|50,150,50,255|50,150,50,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Fragile Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Fragile Chance\"				\"4\"");
			fFilename.WriteLine("			\"Fragile Duration\"				\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 21\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Ghost Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"50,50,50,150|50,50,50\"");
			fFilename.WriteLine("			\"Props Colors\"					\"150,150,150,150|150,150,150,150|150,150,150,180|150,150,150,150|150,150,150,150\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Ghost Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Ghost Chance\"					\"4\"");
			fFilename.WriteLine("			\"Ghost Fade Limit\"				\"0\"");
			fFilename.WriteLine("			\"Ghost Hit\"						\"0\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"1.0\"");
			fFilename.WriteLine("			\"Ghost Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Ghost Weapon Slots\"			\"12345\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 22\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Godly Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"50,25,150,255|50,25,150\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,0,0,255|0,0,0,255|0,0,0,180|0,0,0,255|0,0,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"God Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"God Chance\"					\"4\"");
			fFilename.WriteLine("			\"God Duration\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 23\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Gravity Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"25,25,25,255|25,25,25\"");
			fFilename.WriteLine("			\"Props Colors\"					\"200,200,200,255|200,200,200,255|200,200,200,180|200,200,200,255|200,200,200,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Gravity Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Gravity Chance\"				\"4\"");
			fFilename.WriteLine("			\"Gravity Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Gravity Force\"					\"-50.0\"");
			fFilename.WriteLine("			\"Gravity Hit\"					\"0\"");
			fFilename.WriteLine("			\"Gravity Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Gravity Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Gravity Value\"					\"0.3\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 24\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Health Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"75,200,75,255|75,200,75\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Heal Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Heal Chance\"					\"4\"");
			fFilename.WriteLine("			\"Heal Hit\"						\"1\"");
			fFilename.WriteLine("			\"Heal Interval\"					\"5.0\"");
			fFilename.WriteLine("			\"Heal Range\"					\"500.0\"");
			fFilename.WriteLine("			\"Health From Commons\"			\"50\"");
			fFilename.WriteLine("			\"Health From Specials\"			\"100\"");
			fFilename.WriteLine("			\"Health From Tanks\"				\"500\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 25\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Hunter Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,80,140,255|0,80,140\"");
			fFilename.WriteLine("			\"Props Colors\"					\"200,200,200,255|200,200,200,255|200,200,200,180|200,200,200,255|200,200,200,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Minion Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Minion Amount\"					\"5\"");
			fFilename.WriteLine("			\"Minion Chance\"					\"5\"");
			fFilename.WriteLine("			\"Minion Types\"					\"3\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"2\"");
			fFilename.WriteLine("			\"Throw Infected Options\"		\"3\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 26\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Hurtful Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"80,255,255,255|80,255,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"150,150,150,255|150,150,150,255|150,150,150,180|150,150,150,255|150,150,150,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Hurt Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Hurt Chance\"					\"4\"");
			fFilename.WriteLine("			\"Hurt Damage\"					\"1\"");
			fFilename.WriteLine("			\"Hurt Duration\"					\"5.0\"");
			fFilename.WriteLine("			\"Hurt Hit\"						\"1\"");
			fFilename.WriteLine("			\"Hurt Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Hurt Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 27\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Hypnotizer Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"110,0,130,255|110,0,130\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,250,45,255|255,250,45,255|255,250,45,180|255,250,45,255|255,250,45,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Hypno Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Hypno Chance\"					\"4\"");
			fFilename.WriteLine("			\"Hypno Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Hypno Hit\"						\"1\"");
			fFilename.WriteLine("			\"Hypno Mode\"					\"1\"");
			fFilename.WriteLine("			\"Hypno Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Hypno Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 28\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Ice Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,155,255,200|0,155,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"170,240,255,200|170,240,255,200|170,240,255,180|170,240,255,200|170,240,255,200\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Ice Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Ice Chance\"					\"4\"");
			fFilename.WriteLine("			\"Ice Duration\"					\"5.0\"");
			fFilename.WriteLine("			\"Ice Hit\"						\"1\"");
			fFilename.WriteLine("			\"Ice Range\"						\"150.0\"");
			fFilename.WriteLine("			\"Ice Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 29\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Idler Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"225,235,255,255|225,235,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"10,40,15,255|10,40,15,255|10,40,15,180|10,40,15,255|10,40,15,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Idle Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Idle Chance\"					\"4\"");
			fFilename.WriteLine("			\"Idle Hit\"						\"1\"");
			fFilename.WriteLine("			\"Idle Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Idle Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 30\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Inverter Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,235,220,255|0,235,220\"");
			fFilename.WriteLine("			\"Props Colors\"					\"250,65,255,255|250,65,255,255|250,65,255,180|250,65,255,255|250,65,255,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Invert Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Invert Chance\"					\"4\"");
			fFilename.WriteLine("			\"Invert Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Invert Hit\"					\"1\"");
			fFilename.WriteLine("			\"Invert Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Invert Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 31\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Item Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,105,255,255|0,105,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,105,0,255|255,105,0,255|255,105,0,180|255,105,0,255|255,105,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Item Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Item Chance\"					\"4\"");
			fFilename.WriteLine("			\"Item Loadout\"					\"rifle,pistol,first_aid_kit,pain_pills\"");
			fFilename.WriteLine("			\"Item Mode\"						\"0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 32\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Jockey Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,235,235,255|255,235,235\"");
			fFilename.WriteLine("			\"Props Colors\"					\"130,0,0,255|130,0,0,255|130,0,0,180|130,0,0,255|130,0,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Minion Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Minion Amount\"					\"5\"");
			fFilename.WriteLine("			\"Minion Chance\"					\"5\"");
			fFilename.WriteLine("			\"Minion Types\"					\"5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"2\"");
			fFilename.WriteLine("			\"Throw Infected Options\"		\"5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 33\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Jumper Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"225,215,0,255|225,215,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"225,0,205,255|225,0,205,255|225,0,205,180|225,0,205,255|225,0,205,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Jump Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Jump Chance\"					\"4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 34\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Medic Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,0,50,255|255,0,50\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,100,50,255|255,100,50,255|255,100,50,180|255,100,50,255|255,100,50,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Medic Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Medic Chance\"					\"4\"");
			fFilename.WriteLine("			\"Medic Health\"					\"25,25,25,25,25,25\"");
			fFilename.WriteLine("			\"Medic Max Health\"				\"250,50,250,100,325,600\"");
			fFilename.WriteLine("			\"Medic Range\"					\"500.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 35\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Meteor Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"120,20,10,255|120,20,10\"");
			fFilename.WriteLine("			\"Props Colors\"					\"200,200,200,255|200,200,200,255|200,200,200,180|200,200,200,255|200,200,200,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Explosive Immunity\"			\"1\"");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Meteor Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Meteor Chance\"					\"4\"");
			fFilename.WriteLine("			\"Meteor Damage\"					\"5\"");
			fFilename.WriteLine("			\"Meteor Radius\"					\"-180.0,180.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 36\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Nullifier Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,255,140,255|255,255,140\"");
			fFilename.WriteLine("			\"Props Colors\"					\"140,140,255,255|140,140,255,255|140,140,255,180|140,140,255,255|140,140,255,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Nullify Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Nullify Chance\"				\"4\"");
			fFilename.WriteLine("			\"Nullify Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Nullify Hit\"					\"1\"");
			fFilename.WriteLine("			\"Nullify Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Nullify Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 37\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Overpowered Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,0,255,255|255,255,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,0,0,255|255,0,0,255|255,0,0,180|255,0,0,255|255,0,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Claw Damage\"					\"25.0\"");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Rock Damage\"					\"25.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 38\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Panic Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,0,255,255|255,100,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,100,0,255|255,100,0,255|255,100,0,180|255,100,0,255|255,100,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Panic Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Panic Chance\"					\"4\"");
			fFilename.WriteLine("			\"Panic Hit\"						\"1\"");
			fFilename.WriteLine("			\"Panic Interval\"				\"50.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 39\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Pimp Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,0,255,255|0,255,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,255,0,255|0,255,0,255|0,255,0,180|0,255,0,255|0,255,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Pimp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Pimp Amount\"					\"5\"");
			fFilename.WriteLine("			\"Pimp Chance\"					\"4\"");
			fFilename.WriteLine("			\"Pimp Damage\"					\"1\"");
			fFilename.WriteLine("			\"Pimp Hit\"						\"1\"");
			fFilename.WriteLine("			\"Pimp Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Pimp Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 40\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Platinum Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"110,175,255,255|110,50,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"110,50,255,255|110,50,255,255|110,50,255,180|110,50,255,255|110,50,255,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Melee Immunity\"				\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 41\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Puke Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"170,180,45,255|170,180,45\"");
			fFilename.WriteLine("			\"Props Colors\"					\"140,0,0,255|140,0,0,255|140,0,0,180|140,0,0,255|140,0,0,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"1\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Puke Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Puke Chance\"					\"4\"");
			fFilename.WriteLine("			\"Puke Hit\"						\"1\"");
			fFilename.WriteLine("			\"Puke Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Puke Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 42\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Pyro Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,35,0,255|255,35,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,180,0,255|255,180,0,255|255,180,0,180|255,180,0,255|255,180,0,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"3\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"3\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Pyro Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Pyro Boost\"					\"1.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 43\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Regenerative Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"50,25,0,255|50,25,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"30,30,30,255|30,30,30,255|30,30,30,180|30,30,30,255|30,30,30,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Regen Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Regen Health\"					\"1\"");
			fFilename.WriteLine("			\"Regen Interval\"				\"1.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 44\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Respawner Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"55,125,70,255|55,125,70\"");
			fFilename.WriteLine("			\"Props Colors\"					\"150,100,50,255|150,100,50,255|150,100,50,180|150,100,50,255|150,100,50,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Respawn Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Respawn Amount\"				\"1\"");
			fFilename.WriteLine("			\"Respawn Chance\"				\"4\"");
			fFilename.WriteLine("			\"Respawn Random\"				\"0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 45\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Restarter Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"10,40,15,255|10,40,15\"");
			fFilename.WriteLine("			\"Props Colors\"					\"225,235,0,255|225,235,0,255|225,235,0,180|225,235,0,255|225,235,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Restart Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Restart Chance\"				\"4\"");
			fFilename.WriteLine("			\"Restart Hit\"					\"1\"");
			fFilename.WriteLine("			\"Restart Loadout\"				\"smg,pistol,pain_pills\"");
			fFilename.WriteLine("			\"Restart Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Restart Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 46\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Rock Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"75,25,25,255|75,25,25\"");
			fFilename.WriteLine("			\"Props Colors\"					\"25,25,75,255|25,25,75,255|25,25,75,180|25,25,75,255|25,25,75,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Rock Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Rock Chance\"					\"4\"");
			fFilename.WriteLine("			\"Rock Damage\"					\"5\"");
			fFilename.WriteLine("			\"Rock Duration\"					\"5.0\"");
			fFilename.WriteLine("			\"Rock Radius\"					\"-1.25,1.25\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 47\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Rocketeer Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"250,110,0,255|250,110,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,180,50,255|255,180,50,255|255,180,50,180|255,180,50,255|255,180,50,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Rocket Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("			\"Rocket Chance\"					\"16\"");
			fFilename.WriteLine("			\"Rocket Hit\"					\"1\"");
			fFilename.WriteLine("			\"Rocket Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Rocket Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 48\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Self-sacrificial Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"90,55,25,255|90,55,25\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,220,125,255|0,220,125,255|0,220,125,180|0,220,125,255|0,220,125,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"3\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 49\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Shaker Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"100,25,25,255|100,25,25\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,170,255,255|0,170,255,255|0,170,255,180|0,170,255,255|0,170,255,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Shake Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Shake Chance\"					\"4\"");
			fFilename.WriteLine("			\"Shake Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Shake Hit\"						\"1\"");
			fFilename.WriteLine("			\"Shake Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Shake Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 50\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Shield Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"135,205,255,255|135,205,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"25,125,125,255|25,125,125,255|25,125,125,180|25,125,125,255|25,125,125,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Shield Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Shield Color\"					\"25,125,125\"");
			fFilename.WriteLine("			\"Shield Delay\"					\"7.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 51\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Shove Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"10,100,0,255|10,100,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"25,10,0,255|25,10,0,255|25,10,0,180|25,10,0,255|25,10,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Shove Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Shove Chance\"					\"4\"");
			fFilename.WriteLine("			\"Shove Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Shove Hit\"						\"1\"");
			fFilename.WriteLine("			\"Shove Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Shove Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 52\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Smasher Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"70,80,100,255|70,80,100\"");
			fFilename.WriteLine("			\"Props Colors\"					\"130,65,0,255|130,65,0,255|130,65,0,180|130,65,0,255|130,65,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"0.65\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Smash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("			\"Smash Chance\"					\"16\"");
			fFilename.WriteLine("			\"Smash Hit\"						\"1\"");
			fFilename.WriteLine("			\"Smash Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Smash Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 53\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Smiter Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,230,230,255|0,230,230\"");
			fFilename.WriteLine("			\"Props Colors\"					\"230,230,0,255|230,230,0,255|230,230,0,180|230,230,0,255|230,230,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"0.25\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Smite Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
			fFilename.WriteLine("			\"Smite Chance\"					\"16\"");
			fFilename.WriteLine("			\"Smite Hit\"						\"1\"");
			fFilename.WriteLine("			\"Smite Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Smite Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 54\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Smoker Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"150,0,150,255|150,0,150\"");
			fFilename.WriteLine("			\"Props Colors\"					\"200,100,145,255|200,100,145,255|200,100,145,180|200,100,145,255|200,100,145,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"6\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Minion Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Minion Amount\"					\"5\"");
			fFilename.WriteLine("			\"Minion Chance\"					\"5\"");
			fFilename.WriteLine("			\"Minion Types\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"2\"");
			fFilename.WriteLine("			\"Throw Infected Options\"		\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 55\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Spammer Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"175,75,75,255|175,75,75\"");
			fFilename.WriteLine("			\"Props Colors\"					\"75,175,175,255|75,175,175,255|75,175,175,180|75,175,175,255|75,175,175,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Spam Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Spam Chance\"					\"4\"");
			fFilename.WriteLine("			\"Spam Damage\"					\"5\"");
			fFilename.WriteLine("			\"Spam Duration\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 56\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Special Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,175,125,255|0,175,125\"");
			fFilename.WriteLine("			\"Props Colors\"					\"165,175,125,255|165,175,125,255|165,175,125,180|165,175,125,255|165,175,125,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Minion Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Minion Amount\"					\"5\"");
			fFilename.WriteLine("			\"Minion Chance\"					\"5\"");
			fFilename.WriteLine("			\"Minion Types\"					\"123456\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"2\"");
			fFilename.WriteLine("			\"Throw Infected Options\"		\"123456\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 57\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Spitter Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,200,0,255|0,200,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,80,150,255|255,80,150,255|255,80,150,180|255,80,150,255|255,80,150,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"7\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Minion Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Minion Amount\"					\"5\"");
			fFilename.WriteLine("			\"Minion Chance\"					\"5\"");
			fFilename.WriteLine("			\"Minion Types\"					\"4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Throw Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"2\"");
			fFilename.WriteLine("			\"Throw Infected Options\"		\"4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 58\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Splasher Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"75,50,75,255|75,50,75\"");
			fFilename.WriteLine("			\"Props Colors\"					\"50,75,50,255|50,75,50,255|50,75,50,180|50,75,50,255|50,75,50,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Splash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Splash Chance\"					\"4\"");
			fFilename.WriteLine("			\"Splash Damage\"					\"5\"");
			fFilename.WriteLine("			\"Splash Range\"					\"150.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 59\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Stun Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"80,130,255,255|80,130,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,185,45,255|255,185,45,255|255,185,45,180|255,185,45,255|255,185,45,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Stun Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Stun Chance\"					\"4\"");
			fFilename.WriteLine("			\"Stun Duration\"					\"5.0\"");
			fFilename.WriteLine("			\"Stun Hit\"						\"1\"");
			fFilename.WriteLine("			\"Stun Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Stun Range Chance\"				\"16\"");
			fFilename.WriteLine("			\"Stun Speed\"					\"0.25\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 60\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Tracker Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"150,50,0,255|150,50,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,100,0,255|0,100,0,255|0,100,0,180|0,100,0,255|0,100,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"1.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Track Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Track Chance\"					\"4\"");
			fFilename.WriteLine("			\"Track Mode\"					\"1\"");
			fFilename.WriteLine("			\"Track Speed\"					\"300.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 61\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Vampire Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"180,0,70,255|180,0,70\"");
			fFilename.WriteLine("			\"Props Colors\"					\"70,210,70,255|70,210,70,255|70,210,70,180|70,210,70,255|70,210,70,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"1\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Vampire Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Vampire Chance\"				\"4\"");
			fFilename.WriteLine("			\"Vampire Health\"				\"100\"");
			fFilename.WriteLine("			\"Vampire Hit\"					\"1\"");
			fFilename.WriteLine("			\"Vampire Range\"					\"500.0\"");
			fFilename.WriteLine("			\"Vampire Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 62\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Visual Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"175,25,205,255|175,25,205\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,40,10,255|255,40,10,255|255,40,10,180|255,40,10,255|255,40,10,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Vision Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Vision Chance\"					\"4\"");
			fFilename.WriteLine("			\"Vision Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Vision FOV\"					\"160\"");
			fFilename.WriteLine("			\"Vision Hit\"					\"1\"");
			fFilename.WriteLine("			\"Vision Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Vision Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 63\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Warp Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"130,130,255,255|130,130,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"225,100,0,255|225,100,0,255|225,100,0,180|225,100,0,255|225,100,0,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"2\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Chance\"					\"4\"");
			fFilename.WriteLine("			\"Warp Hit\"						\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"5.0\"");
			fFilename.WriteLine("			\"Warp Mode\"						\"0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 64\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Witch Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,145,255,255|255,145,255\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,210,80,255|255,210,80,255|255,210,80,180|255,210,80,255|255,210,80,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"1\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Witch Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Witch Amount\"					\"3\"");
			fFilename.WriteLine("			\"Witch Minion Damage\"			\"5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 65\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Zombie Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"165,205,175,255|165,205,175\"");
			fFilename.WriteLine("			\"Props Colors\"					\"190,255,250,255|190,255,250,255|190,255,250,180|190,255,250,255|190,255,250,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Zombie Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Zombie Amount\"					\"10\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// Super Tanks and Super Tanks+ Tanks");
			fFilename.WriteLine("	// Most of the Tank combos from ST+ are already recreated above.");
			fFilename.WriteLine("	\"Tank 66\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Armageddon Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"75,0,0,255|75,0,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"35,35,35,255|35,35,35,255|35,35,35,180|35,35,35,255|35,35,35,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Explosive Immunity\"			\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Gravity Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Gravity Force\"					\"-50.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Meteor Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Meteor Chance\"					\"2\"");
			fFilename.WriteLine("			\"Meteor Damage\"					\"5\"");
			fFilename.WriteLine("			\"Meteor Radius\"					\"-180.0,180.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 67\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Boss Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,0,50,255|0,175,255\"");
			fFilename.WriteLine("			\"Props Attached\"				\"123456\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,3,3,3,3,3\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,175,255,255|0,175,255,255|0,175,255,180|0,175,255,255|0,175,255,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"1234567\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"1234\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Flash Chance\"					\"3\"");
			fFilename.WriteLine("			\"Flash Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Flash Speed\"					\"4.5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Ghost Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Ghost Chance\"					\"3\"");
			fFilename.WriteLine("			\"Ghost Fade Limit\"				\"0\"");
			fFilename.WriteLine("			\"Ghost Hit\"						\"0\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"1.0\"");
			fFilename.WriteLine("			\"Ghost Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Ghost Weapon Slots\"			\"123\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Gravity Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Gravity Chance\"				\"3\"");
			fFilename.WriteLine("			\"Gravity Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Gravity Force\"					\"-75.0\"");
			fFilename.WriteLine("			\"Gravity Hit\"					\"1\"");
			fFilename.WriteLine("			\"Gravity Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Gravity Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Gravity Value\"					\"0.4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Jump Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Jump Chance\"					\"6\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Meteor Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Meteor Chance\"					\"1\"");
			fFilename.WriteLine("			\"Meteor Damage\"					\"5\"");
			fFilename.WriteLine("			\"Meteor Radius\"					\"-180.0,180.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Shield Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Shield Color\"					\"0,175,255\"");
			fFilename.WriteLine("			\"Shield Delay\"					\"4.5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Smite Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Smite Chance\"					\"5\"");
			fFilename.WriteLine("			\"Smite Hit\"						\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Witch Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Witch Amount\"					\"10\"");
			fFilename.WriteLine("			\"Witch Minion Damage\"			\"10\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Zombie Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Zombie Amount\"					\"50\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 68\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Distraction Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"225,225,0,255|225,225,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"25,0,0,255|25,0,0,255|25,0,0,180|25,0,0,255|25,0,0,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Jump Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Jump Chance\"					\"3\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"3.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 69\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Feedback Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"90,60,90,255|90,60,90\"");
			fFilename.WriteLine("			\"Props Colors\"					\"90,90,60,255|90,90,60,255|90,90,60,180|90,90,60,255|90,90,60,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"2\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Gravity Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Gravity Force\"					\"50.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 70\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Goliath Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,0,100,255|0,0,100\"");
			fFilename.WriteLine("			\"Props Colors\"					\"25,25,25,255|25,25,25,255|25,25,25,180|25,25,25,255|25,25,25,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"0.5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Heal Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Heal Chance\"					\"3\"");
			fFilename.WriteLine("			\"Heal Hit\"						\"1\"");
			fFilename.WriteLine("			\"Heal Interval\"					\"3.0\"");
			fFilename.WriteLine("			\"Heal Range\"					\"500.0\"");
			fFilename.WriteLine("			\"Health From Commons\"			\"250\"");
			fFilename.WriteLine("			\"Health From Specials\"			\"750\"");
			fFilename.WriteLine("			\"Health From Tanks\"				\"1250\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Shield Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Shield Color\"					\"0,0,100\"");
			fFilename.WriteLine("			\"Shield Delay\"					\"7.5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Smite Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Smite Chance\"					\"4\"");
			fFilename.WriteLine("			\"Smite Hit\"						\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 71\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Hallucination Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"50,50,50,0|50,50,50\"");
			fFilename.WriteLine("			\"Props Colors\"					\"50,50,50,0|50,50,50,0|50,50,50,0|50,50,50,0|50,50,50,0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Ghost Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Ghost Chance\"					\"3\"");
			fFilename.WriteLine("			\"Ghost Fade Limit\"				\"0\"");
			fFilename.WriteLine("			\"Ghost Hit\"						\"0\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"1.0\"");
			fFilename.WriteLine("			\"Ghost Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Ghost Weapon Slots\"			\"123\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"3.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 72\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Meme Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,255,0,255|0,255,0\"");
			fFilename.WriteLine("			\"Props Attached\"				\"123456\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,3,3,3,3,3\"");
			fFilename.WriteLine("			\"Props Colors\"					\"225,0,255,255|225,0,255,255|225,0,255,180|225,0,255,255|225,0,255,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"1234567\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"1234\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Absorb Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Absorb Chance\"					\"4\"");
			fFilename.WriteLine("			\"Absorb Duration\"				\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Flash Chance\"					\"3\"");
			fFilename.WriteLine("			\"Flash Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Flash Speed\"					\"4.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Ghost Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Ghost Chance\"					\"3\"");
			fFilename.WriteLine("			\"Ghost Fade Limit\"				\"0\"");
			fFilename.WriteLine("			\"Ghost Hit\"						\"0\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"1.0\"");
			fFilename.WriteLine("			\"Ghost Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Ghost Weapon Slots\"			\"123\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Gravity Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Gravity Chance\"				\"3\"");
			fFilename.WriteLine("			\"Gravity Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Gravity Force\"					\"-25.0\"");
			fFilename.WriteLine("			\"Gravity Hit\"					\"1\"");
			fFilename.WriteLine("			\"Gravity Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Gravity Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Gravity Value\"					\"0.4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Jump Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Jump Chance\"					\"3\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Meteor Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Meteor Chance\"					\"1\"");
			fFilename.WriteLine("			\"Meteor Damage\"					\"5\"");
			fFilename.WriteLine("			\"Meteor Radius\"					\"-180.0,180.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Smite Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Smite Chance\"					\"5\"");
			fFilename.WriteLine("			\"Smite Hit\"						\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Spam Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Spam Chance\"					\"1\"");
			fFilename.WriteLine("			\"Spam Damage\"					\"5\"");
			fFilename.WriteLine("			\"Spam Duration\"					\"1.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"3.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Witch Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Witch Amount\"					\"5\"");
			fFilename.WriteLine("			\"Witch Minion Damage\"			\"5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Zombie Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Zombie Amount\"					\"50\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 73\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Mirage Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"25,40,25,255|25,40,25\"");
			fFilename.WriteLine("			\"Props Attached\"				\"123456\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,3,3,3,3,3\"");
			fFilename.WriteLine("			\"Props Colors\"					\"25,40,25,255|25,40,25,255|25,40,25,180|25,40,25,255|25,40,25,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"3.0\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Flash Chance\"					\"3\"");
			fFilename.WriteLine("			\"Flash Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Flash Speed\"					\"5.5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"3.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 74\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Poltergeist Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"100,50,50,255|100,50,50\"");
			fFilename.WriteLine("			\"Props Attached\"				\"123456\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,3,3,3,3,3\"");
			fFilename.WriteLine("			\"Props Colors\"					\"50,100,50,255|50,100,50,255|50,100,50,180|50,100,50,255|50,100,50,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"3.0\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Flash Chance\"					\"2\"");
			fFilename.WriteLine("			\"Flash Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Flash Speed\"					\"7.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Ghost Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Ghost Chance\"					\"3\"");
			fFilename.WriteLine("			\"Ghost Fade Limit\"				\"0\"");
			fFilename.WriteLine("			\"Ghost Hit\"						\"0\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"1.0\"");
			fFilename.WriteLine("			\"Ghost Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Ghost Weapon Slots\"			\"123\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"3.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 75\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Psychotic Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,0,0,255|255,0,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,0,0,255|255,0,0,255|255,0,0,180|255,0,0,255|255,0,0,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"12\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"12\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Heal Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Heal Chance\"					\"3\"");
			fFilename.WriteLine("			\"Heal Hit\"						\"1\"");
			fFilename.WriteLine("			\"Heal Interval\"					\"5.0\"");
			fFilename.WriteLine("			\"Heal Range\"					\"500.0\"");
			fFilename.WriteLine("			\"Health From Commons\"			\"100\"");
			fFilename.WriteLine("			\"Health From Specials\"			\"500\"");
			fFilename.WriteLine("			\"Health From Tanks\"				\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Jump Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Jump Chance\"					\"3\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Meteor Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Meteor Chance\"					\"3\"");
			fFilename.WriteLine("			\"Meteor Damage\"					\"5\"");
			fFilename.WriteLine("			\"Meteor Radius\"					\"-180.0,180.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Shield Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Shield Color\"					\"255,0,0\"");
			fFilename.WriteLine("			\"Shield Delay\"					\"8.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"8.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 76\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Reverse Flash Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"255,255,0,150|255,0,0\"");
			fFilename.WriteLine("			\"Props Attached\"				\"123456\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,3,3,3,3,3\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,0,0,150|255,0,0,150|255,0,0,180|255,0,0,150|255,0,0,150\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"2\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"3.0\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Flash Chance\"					\"2\"");
			fFilename.WriteLine("			\"Flash Duration\"				\"10.0\"");
			fFilename.WriteLine("			\"Flash Speed\"					\"6.5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 77\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Spawner Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"75,95,105,255|75,95,105\"");
			fFilename.WriteLine("			\"Props Colors\"					\"100,100,100,255|100,100,100,255|100,100,100,180|100,100,100,255|100,100,100,255\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"6\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Zombie Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Zombie Amount\"					\"25\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 78\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Zoom Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"45,45,45,150|65,135,245\"");
			fFilename.WriteLine("			\"Props Attached\"				\"123456\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,3,3,3,3,3\"");
			fFilename.WriteLine("			\"Props Colors\"					\"65,135,245,150|65,135,245,150|65,135,245,180|65,135,245,150|65,135,245,150\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"2\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"3.0\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Flash Chance\"					\"2\"");
			fFilename.WriteLine("			\"Flash Duration\"				\"15.0\"");
			fFilename.WriteLine("			\"Flash Speed\"					\"7.5\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"3.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// Last Boss Extended Tanks");
			fFilename.WriteLine("	// Most of the Tanks from LBE are already recreated above.");
			fFilename.WriteLine("	\"Tank 79\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Dread Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"90,90,90,255|90,90,90\"");
			fFilename.WriteLine("			\"Props Colors\"					\"165,165,165,255|165,165,165,255|165,165,165,180|165,165,165,255|165,165,165,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Blind Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Blind Chance\"					\"4\"");
			fFilename.WriteLine("			\"Blind Duration\"				\"7.5\"");
			fFilename.WriteLine("			\"Blind Hit\"						\"1\"");
			fFilename.WriteLine("			\"Blind Intensity\"				\"235\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Drug Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Drug Chance\"					\"1\"");
			fFilename.WriteLine("			\"Drug Duration\"					\"2.0\"");
			fFilename.WriteLine("			\"Drug Hit\"						\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 80\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Rabid Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"175,50,95,255|175,50,95\"");
			fFilename.WriteLine("			\"Props Colors\"					\"0,165,165,255|0,165,165,255|0,165,165,180|0,165,165,255|0,165,165,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Drug Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Drug Chance\"					\"1\"");
			fFilename.WriteLine("			\"Drug Duration\"					\"5.0\"");
			fFilename.WriteLine("			\"Drug Hit\"						\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Hurt Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Hurt Chance\"					\"1\"");
			fFilename.WriteLine("			\"Hurt Damage\"					\"5\"");
			fFilename.WriteLine("			\"Hurt Duration\"					\"5.0\"");
			fFilename.WriteLine("			\"Hurt Hit\"						\"1\"");
			fFilename.WriteLine("			\"Hurt Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Hurt Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 81\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Tremor Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"130,65,0,255|130,65,0\"");
			fFilename.WriteLine("			\"Props Colors\"					\"20,20,20,255|20,20,20,255|20,20,20,180|20,20,20,255|20,20,20,255\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Rock Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Rock Chance\"					\"4\"");
			fFilename.WriteLine("			\"Rock Damage\"					\"5\"");
			fFilename.WriteLine("			\"Rock Duration\"					\"5.0\"");
			fFilename.WriteLine("			\"Rock Radius\"					\"-1.25,1.25\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Spam Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Spam Chance\"					\"4\"");
			fFilename.WriteLine("			\"Spam Damage\"					\"5\"");
			fFilename.WriteLine("			\"Spam Duration\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// This is the plugin developer's personal Tank.");
			fFilename.WriteLine("	// It has all the abilities that the plugin developer likes the most.");
			fFilename.WriteLine("	\"Tank 82\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Psyk0tik Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"0,170,255,150|255,0,0\"");
			fFilename.WriteLine("			\"Props Attached\"				\"1256\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,1,1,1,1,1\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,0,0,150|255,0,0,150|255,0,0,180|255,0,0,150|255,0,0,150\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"23457\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"234\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Acid Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Acid Rock Break\"				\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Bomb Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Bomb Rock Break\"				\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Clone Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Clone Amount\"					\"10\"");
			fFilename.WriteLine("			\"Clone Chance\"					\"1\"");
			fFilename.WriteLine("			\"Clone Health\"					\"250\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Fire Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Rock Break\"				\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Flash Chance\"					\"1\"");
			fFilename.WriteLine("			\"Flash Duration\"				\"5.0\"");
			fFilename.WriteLine("			\"Flash Speed\"					\"4.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Ghost Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Ghost Fade Limit\"				\"150\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"1.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Rock Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Rock Chance\"					\"3\"");
			fFilename.WriteLine("			\"Rock Damage\"					\"5\"");
			fFilename.WriteLine("			\"Rock Duration\"					\"10.0\"");
			fFilename.WriteLine("			\"Rock Radius\"					\"-1.25,1.25\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Spam Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Spam Chance\"					\"4\"");
			fFilename.WriteLine("			\"Spam Damage\"					\"10\"");
			fFilename.WriteLine("			\"Spam Duration\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// Here are some miscellaneous Tanks.");
			fFilename.WriteLine("	// These Tanks are just random combinations that the plugin developer put together.");
			fFilename.WriteLine("	\"Tank 83\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Apocalyptic Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"15,15,15,255|100,15,15\"");
			fFilename.WriteLine("			\"Props Colors\"					\"100,15,15,255|100,15,15,255|100,15,15,180|100,15,15,255|100,15,15,255|\"");
			fFilename.WriteLine("			\"Glow Effect\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"2.5\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Meteor Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Meteor Chance\"					\"1\"");
			fFilename.WriteLine("			\"Meteor Damage\"					\"5\"");
			fFilename.WriteLine("			\"Meteor Radius\"					\"-200.0,200.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Panic Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Panic Chance\"					\"4\"");
			fFilename.WriteLine("			\"Panic Hit\"						\"1\"");
			fFilename.WriteLine("			\"Panic Interval\"				\"15.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Rock Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Rock Chance\"					\"4\"");
			fFilename.WriteLine("			\"Rock Damage\"					\"10\"");
			fFilename.WriteLine("			\"Rock Duration\"					\"2.5\"");
			fFilename.WriteLine("			\"Rock Radius\"					\"-5.0,5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 84\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Horde Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"100,100,15,255|200,50,15\"");
			fFilename.WriteLine("			\"Props Colors\"					\"200,50,15,255|200,50,15,255|200,50,15,180|200,50,15,255|200,50,15,255\"");
			fFilename.WriteLine("			\"Glow Effect\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Minion Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Minion Amount\"					\"2\"");
			fFilename.WriteLine("			\"Minion Chance\"					\"1\"");
			fFilename.WriteLine("			\"Minion Types\"					\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Panic Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Panic Chance\"					\"6\"");
			fFilename.WriteLine("			\"Panic Hit\"						\"1\"");
			fFilename.WriteLine("			\"Panic Interval\"				\"15.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Puke Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Puke Chance\"					\"10\"");
			fFilename.WriteLine("			\"Puke Hit\"						\"1\"");
			fFilename.WriteLine("			\"Puke Range\"					\"250.0\"");
			fFilename.WriteLine("			\"Puke Range Chance\"				\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Zombie Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Zombie Amount\"					\"10\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 85\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Grim Reaper Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"50,50,50,150|100,100,100\"");
			fFilename.WriteLine("			\"Props Attached\"				\"123456\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,3,3,3,3,3\"");
			fFilename.WriteLine("			\"Props Colors\"					\"100,100,100,150|100,100,100,150|100,100,100,180|100,100,100,150|100,100,100,150\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Run Speed\"						\"3.0\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Bury Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Bury Chance\"					\"3\"");
			fFilename.WriteLine("			\"Bury Duration\"					\"30.0\"");
			fFilename.WriteLine("			\"Bury Height\"					\"100.0\"");
			fFilename.WriteLine("			\"Bury Hit\"						\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Ghost Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Ghost Fade Limit\"				\"150\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"1.0\"");
			fFilename.WriteLine("			\"Ghost Range Chance\"			\"16\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Warp Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Warp Interval\"					\"5.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 86\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Speedster Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
			fFilename.WriteLine("			\"Skin-Glow Colors\"				\"150,0,0,150|255,100,0\"");
			fFilename.WriteLine("			\"Props Attached\"				\"123456\"");
			fFilename.WriteLine("			\"Props Chance\"					\"1,3,3,3,3,3\"");
			fFilename.WriteLine("			\"Props Colors\"					\"255,100,0,150|255,100,0,150|255,100,0,180|255,100,0,150|255,100,0,150\"");
			fFilename.WriteLine("			\"Particle Effect\"				\"1\"");
			fFilename.WriteLine("			\"Particle Effects\"				\"2\"");
			fFilename.WriteLine("			\"Rock Effect\"					\"1\"");
			fFilename.WriteLine("			\"Rock Effects\"					\"2\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Enhancements\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Run Speed\"						\"3.0\"");
			fFilename.WriteLine("			\"Throw Interval\"				\"9999999999.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Immunities\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Fire Immunity\"					\"1\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Clone Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Clone Amount\"					\"5\"");
			fFilename.WriteLine("			\"Clone Chance\"					\"1\"");
			fFilename.WriteLine("			\"Clone Health\"					\"250\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Flash Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Flash Chance\"					\"1\"");
			fFilename.WriteLine("			\"Flash Duration\"				\"9999999999.0\"");
			fFilename.WriteLine("			\"Flash Speed\"					\"8.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// Create your own Super Tanks below.");
			fFilename.WriteLine("}");
		}
		else
		{
			fFilename.WriteLine("// This config file was auto-generated by Super Tanks++ v%s (%s)", ST_VERSION, ST_URL);
			fFilename.WriteLine("");
			fFilename.WriteLine("");
		}
		delete fFilename;
	}
}

stock void vCreateParticle(int client, char[] particlename, float time, float origin)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vDamage(int client, char[] damage)
{
	int iPointHurt = CreateEntityByName("point_hurt");
	if (bIsValidEntity(iPointHurt))
	{
		DispatchKeyValue(client, "targetname", "hurtme");
		DispatchKeyValue(iPointHurt, "Damage", damage);
		DispatchKeyValue(iPointHurt, "DamageTarget", "hurtme");
		DispatchKeyValue(iPointHurt, "DamageType", "2");
		DispatchSpawn(iPointHurt);
		AcceptEntityInput(iPointHurt, "Hurt", client);
		AcceptEntityInput(iPointHurt, "Kill");
		DispatchKeyValue(client, "targetname", "donthurtme");
	}
}

stock void vDeleteEntity(int entity, float time = 0.1)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];
		Format(sVariant, sizeof(sVariant), "OnUser1 !self:kill::%f:1", time);
		AcceptEntityInput(entity, "ClearParent");
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}

public void vGameMode(const char[] output, int caller, int activator, float delay)
{
	if (strcmp(output, "OnCoop") == 0)
	{
		g_iCurrentMode = 1;
	}
	else if (strcmp(output, "OnVersus") == 0)
	{
		g_iCurrentMode = 2;
	}
	else if (strcmp(output, "OnSurvival") == 0)
	{
		g_iCurrentMode = 4;
	}
	else if (strcmp(output, "OnScavenge") == 0)
	{
		g_iCurrentMode = 8;
	}
}

stock void vGetCurrentCount(char[] config)
{
	int iPlayerCount = iGetPlayerCount();
	Format(config, strlen(config), "cfg/sourcemod/super_tanks++/playercount_configs/%d.cfg", iPlayerCount);
}

stock void vGetCurrentDay(char[] config)
{
	char sDay[9];
	char sDayNumber[2];
	FormatTime(sDayNumber, sizeof(sDayNumber), "%w", GetTime());
	int iDayNumber = StringToInt(sDayNumber);
	switch (iDayNumber)
	{
		case 6: sDay = "saturday";
		case 5: sDay = "friday";
		case 4: sDay = "thursday";
		case 3: sDay = "wednesday";
		case 2: sDay = "tuesday";
		case 1: sDay = "monday";
		default: sDay = "sunday";
	}
	Format(config, strlen(config), "cfg/sourcemod/super_tanks++/daily_configs/%s.cfg", sDay);
}

stock void vGetCurrentDifficulty(ConVar convar, char[] config)
{
	char sDifficulty[11];
	convar.GetString(sDifficulty, sizeof(sDifficulty));
	Format(config, strlen(config), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
}

stock void vGetCurrentMap(char[] config)
{
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	Format(config, strlen(config), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_map_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
}

stock void vGetCurrentMode(ConVar convar, char[] config)
{
	char sMode[64];
	convar.GetString(sMode, sizeof(sMode));
	Format(config, strlen(config), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
}

stock void vGhost(int client, int slot)
{
	if (bIsSurvivor(client) && GetPlayerWeaponSlot(client, slot) > 0)
	{
		SDKHooks_DropWeapon(client, GetPlayerWeaponSlot(client, slot), NULL_VECTOR, NULL_VECTOR);
	}
}

stock void vGhostDrop(int client, char[] slots, char[] number, int slot)
{
	if (StrContains(slots, number) != -1)
	{
		vGhost(client, slot);
	}
}

stock void vHeal(int client, int health, int extrahealth, int maxhealth)
{
	maxhealth = iSetCellLimit(maxhealth, 1, ST_MAXHEALTH);
	int iExtraHealth = (extrahealth > maxhealth) ? maxhealth : extrahealth;
	int iExtraHealth2 = (extrahealth < health) ? 1 : extrahealth;
	int iRealHealth = (extrahealth >= 0) ? iExtraHealth : iExtraHealth2;
	SetEntityHealth(client, iRealHealth);
}

stock void vMultiTargetFilters(int toggle)
{
	switch (toggle)
	{
		case 0:
		{
			RemoveMultiTargetFilter("@smokers", bSmokerFilter);
			RemoveMultiTargetFilter("@boomers", bBoomerFilter);
			RemoveMultiTargetFilter("@hunters", bHunterFilter);
			RemoveMultiTargetFilter("@spitters", bSpitterFilter);
			RemoveMultiTargetFilter("@jockeys", bJockeyFilter);
			RemoveMultiTargetFilter("@chargers", bChargerFilter);
			RemoveMultiTargetFilter("@tanks", bTankFilter);
		}
		case 1:
		{
			AddMultiTargetFilter("@smokers", bSmokerFilter, "all Smokers", false);
			AddMultiTargetFilter("@boomers", bBoomerFilter, "all Boomers", false);
			AddMultiTargetFilter("@hunters", bHunterFilter, "all Hunters", false);
			AddMultiTargetFilter("@spitters", bSpitterFilter, "all Spitters", false);
			AddMultiTargetFilter("@jockeys", bJockeyFilter, "all Jockeys", false);
			AddMultiTargetFilter("@chargers", bChargerFilter, "all Chargers", false);
			AddMultiTargetFilter("@tanks", bTankFilter, "all Tanks", false);
		}
	}
}

stock void vPrecacheParticle(char[] particlename)
{
	int iParticle = CreateEntityByName("info_particle_system");
	if (IsValidEntity(iParticle))
	{
		DispatchKeyValue(iParticle, "effect_name", particlename);
		DispatchSpawn(iParticle);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "Start");
		vSetEntityParent(iParticle, iParticle);
		iParticle = EntIndexToEntRef(iParticle);
		vDeleteEntity(iParticle);
	}
}

stock void vSetEntityParent(int entity, int parent)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);
}

stock void vSetVector(float target[3], float x, float y, float z)
{
	target[0] = x;
	target[1] = y;
	target[2] = z;
}

stock void vShake(int client, float duration = 1.0)
{
	Handle hShakeTarget = StartMessageOne("Shake", client);
	if (hShakeTarget != null)
	{
		BfWrite bfWrite = UserMessageToBfWrite(hShakeTarget);
		bfWrite.WriteByte(0);
		bfWrite.WriteFloat(16.0);
		bfWrite.WriteFloat(0.5);
		bfWrite.WriteFloat(duration);
		EndMessage();
	}
}

stock void vSpawnInfected(int client, char[] infected)
{
	ChangeClientTeam(client, 3);
	vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", infected);
	KickClient(client);
}