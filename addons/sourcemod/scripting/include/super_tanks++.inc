// Super Tanks++
#if defined _supertanksplusplus_included
	#endinput
#endif
#define _supertanksplusplus_included

#define ST_PREFIX "[ST++]"
#define ST_PREFIX2 "\x04[ST++]\x01"
#define ST_PREFIX3 "\x04[ST++]\x03"
#define ST_PREFIX4 "\x04[ST++]\x05"

#define ST_AUTHOR "Psyk0tik (Crasher_3637)"
#define ST_VERSION "8.44"
#define ST_URL "https://forums.alliedmods.net/showthread.php?t=302140"

#define ST_MAXTYPES 500
#define ST_MAXHEALTH 65535
#define ST_MAX_HEALTH_REDUCTION -65535

// Forwards
/**
 * Called every second to trigger the Super Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param tank			Client index of the Tank.
 */
forward void ST_Ability(int tank);

/**
 * Called when the Super Tank evolves.
 * Use this forward to trigger any features/abilities/settings when a Super Tank evolves.
 *
 * @param tank			Client index of the Tank.
 */
forward void ST_BossStage(int tank);

/**
 * Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param savepath		The savepath of the config.
 * @param main			Checks whether the main config or a custom config is being used.
 */
forward void ST_Configs(const char[] savepath, bool main);

/**
 * Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 */
forward void ST_Event(Event event, const char[] name);

/**
 * Called when the core plugin is unloaded/reloaded.
 * Use this forward to get rid of any modifications to Tanks or survivors.
 */
forward void ST_PluginEnd();

/**
 * Called when the Tank spawns.
 * Use this forward for any on-spawn presets.
 * If you plan on using this to activate an ability, use ST_Ability() instead.
 *
 * @param tank			Client index of the Tank.
 */
forward void ST_Preset(int tank);

/**
 * Called when the Tank's rock breaks.
 * Use this forward for any after-effects.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 */
forward void ST_RockBreak(int tank, int rock);

/**
 * Called when the Tank throws a rock.
 * Use this forward for any throwing abilities.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 */
forward void ST_RockThrow(int tank, int rock);

// Natives
/**
 * Returns the maximum value of the "Type Range" setting.
 *
 * @return				The maximum value of the "Type Range" setting.
 */
native int ST_MaxType();

/**
 * Returns the minimum value of the "Type Range" setting.
 *
 * @return				The minimum value of the "Type Range" setting.
 */
native int ST_MinType();

/**
 * Returns if the core plugin is enabled.
 *
 * @return				True if core plugin is enabled, false otherwise.
 */
native bool ST_PluginEnabled();

/**
 * Spawns a Tank with the specified Super Tank type.
 *
 * @param tank			Client index of the Tank.
 * @param type			Type of Super Tank.
 * @error				Invalid client index or type is 0.
 */
native void ST_SpawnTank(int tank, int type);

/**
 * Returns if the Tank is allowed to be a Super Tank.
 *
 * @param tank			Client index of the Tank.
 * @return				True if Tank is allowed to be a Super Tank, false otherwise.
 * @error				Invalid client index.
 */
native bool ST_TankAllowed(int tank);

/**
 * Returns if a certain Super Tank type has a chance of spawning.
 *
 * @param type			Super Tank type.
 * @return				True if the type has a chance of spawning, false otherwise.
 * @error				Type is 0.
 */
native bool ST_TankChance(int type);

/**
 * Returns the RGB colors given to a Tank.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Skin color, 2 = Glow outline color
 * @param red			Buffer to store the red color in.
 * @param green			Buffer to store the green color in.
 * @param blue			Buffer to store the blue color in.
 * @error				Invalid client index.
 */
native void ST_TankColors(int tank, int mode, char[] red, char[] green, char[] blue);

/**
 * Returns the custom name given to a Tank.
 *
 * @param tank			Client index of the Tank.
 * @param buffer		Buffer to store the custom name in.
 * @error				Invalid client index.
 */
native void ST_TankName(int tank, char[] buffer);

/**
 * Returns the Super Tank type of the Tank.
 *
 * @param tank			Client index of the Tank.
 * @return				The Tank's Super Tank type.
 * @error				Invalid client index.
 */
native int ST_TankType(int tank);

/**
 * Returns the current finale wave.
 *
 * @return				The current finale wave.
 */
native int ST_TankWave();

/**
 * Returns if a certain Super Tank type is enabled.
 *
 * @param type			Super Tank type.
 * @return				True if the type is enabled, false otherwise.
 * @error				Type is 0.
 */
native bool ST_TypeEnabled(int type);

// Checks
stock bool bHasIdlePlayer(int survivor)
{
	char sClassname[12];
	GetEntityNetClass(survivor, sClassname, sizeof(sClassname));

	if (StrEqual(sClassname, "SurvivorBot"))
	{
		int iSpectatorUserId = GetEntProp(survivor, Prop_Send, "m_humanSpectatorUserID");
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

stock bool bIsBoomer(int boomer)
{
	return bIsInfected(boomer) && GetEntProp(boomer, Prop_Send, "m_zombieClass") == 2;
}

stock bool bIsBotIdle(int bot)
{
	return bIsSurvivor(bot) && IsFakeClient(bot) && bHasIdlePlayer(bot);
}

stock bool bIsBotIdleSurvivor(int bot)
{
	return bIsSurvivor(bot) && IsFakeClient(bot) && !bHasIdlePlayer(bot);
}

stock bool bIsBotSurvivor(int bot)
{
	return bIsSurvivor(bot) && IsFakeClient(bot);
}

stock bool bIsCharger(int charger)
{
	return bIsInfected(charger) && GetEntProp(charger, Prop_Send, "m_zombieClass") == 6;
}

stock bool bIsFinaleMap()
{
	return FindEntityByClassname(-1, "trigger_finale") != -1;
}

stock bool bIsGunWeapon(int survivor)
{
	char sWeapon[32];
	GetClientWeapon(survivor, sWeapon, sizeof(sWeapon));

	if (GetPlayerWeaponSlot(survivor, 0) > 0 || (GetPlayerWeaponSlot(survivor, 1) > 0 && StrContains(sWeapon, "pistol", false) != -1))
	{
		return true;
	}

	return false;
}

stock bool bIsHumanSurvivor(int survivor)
{
	return bIsSurvivor(survivor) && !IsFakeClient(survivor) && !bHasIdlePlayer(survivor) && !bIsPlayerIdle(survivor);
}

stock bool bIsHunter(int hunter)
{
	return bIsInfected(hunter) && GetEntProp(hunter, Prop_Send, "m_zombieClass") == 3;
}

stock bool bIsIdlePlayer(int bot, int survivor)
{
	return bIsValidClient(survivor) && !IsFakeClient(survivor) && GetClientTeam(bot) == 2;
}

stock bool bIsInfected(int infected)
{
	return bIsValidClient(infected) && GetClientTeam(infected) == 3;
}

stock bool bIsJockey(int jockey)
{
	return bIsInfected(jockey) && bIsValidGame() && GetEntProp(jockey, Prop_Send, "m_zombieClass") == 5;
}

stock bool bIsPlayerBurning(int player)
{
	if (GetEntPropFloat(player, Prop_Send, "m_burnPercent") > 0.0 || GetEntProp(player, Prop_Data, "m_fFlags") & FL_ONFIRE)
	{
		return true;
	}

	return false;
}

stock bool bIsPlayerGrounded(int player)
{
	if (GetEntProp(player, Prop_Send, "m_fFlags") & FL_ONGROUND)
	{
		return true;
	}

	return false;
}

stock bool bIsPlayerIdle(int survivor)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!IsClientInGame(iPlayer) || GetClientTeam(iPlayer) != 2 || !IsFakeClient(iPlayer) || !bHasIdlePlayer(iPlayer))
		{
			continue;
		}

		char sClassname[12];
		GetEntityNetClass(iPlayer, sClassname, sizeof(sClassname));

		if (StrEqual(sClassname, "SurvivorBot"))
		{
			int iSpectatorUserId = GetEntProp(iPlayer, Prop_Send, "m_humanSpectatorUserID");
			if (iSpectatorUserId > 0)
			{
				int iIdler = GetClientOfUserId(iSpectatorUserId);
				if (iIdler == survivor)
				{
					return true;
				}
			}
		}
	}

	return false;
}

stock bool bIsPlayerIncapacitated(int survivor)
{
	if (GetEntProp(survivor, Prop_Send, "m_isIncapacitated", 1))
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

		if (bIsValidEntity(iGameMode))
		{
			DispatchSpawn(iGameMode);

			HookSingleEntityOutput(iGameMode, "OnCoop", vGameMode, true);
			HookSingleEntityOutput(iGameMode, "OnSurvival", vGameMode, true);
			HookSingleEntityOutput(iGameMode, "OnVersus", vGameMode, true);
			HookSingleEntityOutput(iGameMode, "OnScavenge", vGameMode, true);

			ActivateEntity(iGameMode);
			AcceptEntityInput(iGameMode, "PostSpawnActivate");
			RemoveEntity(iGameMode);
		}

		if (g_iCurrentMode == 0 || !(mode & g_iCurrentMode))
		{
			return false;
		}
	}

	char sGameMode[32], sGameModes[513];
	convar.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	if (!StrEqual(enabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", enabled);
		if (StrContains(sGameModes, sGameMode, false) == -1)
		{
			return false;
		}
	}

	if (!StrEqual(disabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", disabled);
		if (StrContains(sGameModes, sGameMode, false) != -1)
		{
			return false;
		}
	}

	return true;
}

stock bool bIsSmoker(int smoker)
{
	return bIsInfected(smoker) && GetEntProp(smoker, Prop_Send, "m_zombieClass") == 1;
}

stock bool bIsSpecialInfected(int infected)
{
	return bIsSmoker(infected) || bIsBoomer(infected) || bIsHunter(infected) || bIsSpitter(infected) || bIsJockey(infected) || bIsCharger(infected);
}

stock bool bIsSpitter(int spitter)
{
	return bIsInfected(spitter) && GetEntProp(spitter, Prop_Send, "m_zombieClass") == 4;
}

stock bool bIsSurvivor(int survivor)
{
	return bIsValidClient(survivor) && GetClientTeam(survivor) == 2 && IsPlayerAlive(survivor);
}

stock bool bIsTank(int tank)
{
	return bIsInfected(tank) && (bIsValidGame() ? GetEntProp(tank, Prop_Send, "m_zombieClass") == 8 : GetEntProp(tank, Prop_Send, "m_zombieClass") == 5);
}

stock bool bIsValidClient(int player)
{
	return player > 0 && player <= MaxClients && IsClientInGame(player) && !IsClientInKickQueue(player);
}

stock bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

stock bool bIsValidEntRef(int entity)
{
	return entity > 0 && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE;
}

stock bool bIsValidGame(bool l4d2 = true)
{
	EngineVersion evEngine = GetEngineVersion();

	return l4d2 ? evEngine == Engine_Left4Dead2 : evEngine == Engine_Left4Dead;
}

stock bool bIsValidHumanClient(int player)
{
	return bIsValidClient(player) && !IsFakeClient(player);
}

stock bool bIsWitch(int witch)
{
	if (bIsValidEntity(witch))
	{
		char sClassname[32];
		GetEntityClassname(witch, sClassname, sizeof(sClassname));

		if (StrEqual(sClassname, "witch"))
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
stock float flClamp(float value, float min, float max)
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
		float flOrigin[3], flPosition[3], flDown[3] = {90.0, 0.0, 0.0};

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

stock int iClamp(int value, int min, int max)
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

stock int iGetIdleBot(int bot)
{
	for (int iBot = 1; iBot <= MaxClients; iBot++)
	{
		if (iGetIdlePlayer(iBot) == bot)
		{
			return iBot;
		}
	}

	return 0;
}

stock int iGetIdlePlayer(int bot)
{
	if (bIsBotSurvivor(bot))
	{
		char sClassname[12];
		GetEntityNetClass(bot, sClassname, sizeof(sClassname));

		if (StrEqual(sClassname, "SurvivorBot"))
		{
			int iIdler = GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));
			if (iIdler > 0 && IsClientInGame(iIdler) && GetClientTeam(iIdler) == 1)
			{
				return iIdler;
			}
		}
	}

	return 0;
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

stock int iGetRandomSurvivor(int survivor)
{
	int iSurvivorCount, iSurvivors[MAXPLAYERS + 1];
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && iSurvivor != survivor)
		{
			iSurvivors[iSurvivorCount++] = iSurvivor;
		}
	}

	return iSurvivors[GetRandomInt(0, iSurvivorCount - 1)];
}

stock int iGetRandomTarget(float pos[3], float angle[3])
{
	float flMin = 4.0, flPos[3], flAngle;
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
	int iWitchCount, iWitch = -1;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		iWitchCount++;
	}

	return iWitchCount;
}

stock void vAttachParticle(int player, const char[] particlename, float time = 0.0, float origin = 0.0)
{
	if (bIsValidClient(player))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (bIsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(player, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;

			DispatchKeyValue(iParticle, "scale", "");
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);

			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Enable");
			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, player);

			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vCheatCommand(int player, const char[] command, const char[] arguments = "", any ...)
{
	int iCmdFlags = GetCommandFlags(command);
	SetCommandFlags(command, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(player, "%s %s", command, arguments);
	SetCommandFlags(command, iCmdFlags|FCVAR_CHEAT);
}

stock void vCopyVector(float source[3], float target[3])
{
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2];
}

stock void vCreateConfigFile(const char[] filepath, const char[] folder, const char[] filename, const char[] label = "")
{
	char sConfigFilename[PLATFORM_MAX_PATH], sConfigLabel[PLATFORM_MAX_PATH];
	Format(sConfigFilename, sizeof(sConfigFilename), "%s%s%s.cfg", filepath, folder, filename);
	if (FileExists(sConfigFilename))
	{
		return;
	}

	File fFilename = OpenFile(sConfigFilename, "w+");
	strlen(label) > 0 ? strcopy(sConfigLabel, sizeof(sConfigLabel), label) : strcopy(sConfigLabel, sizeof(sConfigLabel), sConfigFilename);
	if (fFilename != null)
	{
		fFilename.WriteLine("// This config file was auto-generated by Super Tanks++ v%s (%s)", ST_VERSION, ST_URL);
		fFilename.WriteLine("");
		fFilename.WriteLine("");

		delete fFilename;
	}
}

stock void vCreateParticle(int player, const char[] particlename, float time = 0.0, float origin = 0.0)
{
	if (bIsValidClient(player))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (bIsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(player, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;

			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);

			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, player);

			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vDeleteEntity(int entity, float time = 0.1)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];

		Format(sVariant, sizeof(sVariant), "OnUser1 !self:ClearParent::%f:1", time);
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");

		Format(sVariant, sizeof(sVariant), "OnUser1 !self:Kill::%f:1", time + 0.1);
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");

		AcceptEntityInput(entity, "FireUser1");
	}
}

stock void vDropWeapon(int survivor, const char[] slots, const char[] number, int slot)
{
	if (StrContains(slots, number) != -1)
	{
		if (bIsSurvivor(survivor) && GetPlayerWeaponSlot(survivor, slot) > 0)
		{
			SDKHooks_DropWeapon(survivor, GetPlayerWeaponSlot(survivor, slot), NULL_VECTOR, NULL_VECTOR);
		}
	}
}

stock void vEffect(int survivor, int tank, const char[] enabled, const char[] mode)
{
	if (StrContains(enabled, mode) != -1)
	{
		char sRGB[4][4];
		ST_TankColors(tank, GetRandomInt(1, 2), sRGB[0], sRGB[1], sRGB[2]);

		int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
		iRed = iClamp(iRed, 0, 255);

		int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);

		int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);

		Handle hFadeTarget = StartMessageOne("Fade", survivor);
		if (hFadeTarget != null)
		{
			BfWrite bfWrite = UserMessageToBfWrite(hFadeTarget);
			bfWrite.WriteShort(800);
			bfWrite.WriteShort(300);
			bfWrite.WriteShort((0x0010|0x0001));
			bfWrite.WriteByte(iRed);
			bfWrite.WriteByte(iGreen);
			bfWrite.WriteByte(iBlue);
			bfWrite.WriteByte(150);

			EndMessage();
		}
	}
}

public void vGameMode(const char[] output, int caller, int activator, float delay)
{
	if (StrEqual(output, "OnCoop"))
	{
		g_iCurrentMode = 1;
	}
	else if (StrEqual(output, "OnVersus"))
	{
		g_iCurrentMode = 2;
	}
	else if (StrEqual(output, "OnSurvival"))
	{
		g_iCurrentMode = 4;
	}
	else if (StrEqual(output, "OnScavenge"))
	{
		g_iCurrentMode = 8;
	}
}

stock void vHeal(int infected, int health, int extrahealth, int maxhealth)
{
	maxhealth = iClamp(maxhealth, 1, ST_MAXHEALTH);

	int iExtraHealth = (extrahealth > maxhealth) ? maxhealth : extrahealth,
		iExtraHealth2 = (extrahealth < health) ? 1 : extrahealth,
		iRealHealth = (extrahealth >= 0) ? iExtraHealth : iExtraHealth2;

	SetEntityHealth(infected, iRealHealth);
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

stock void vPrecacheParticle(const char[] particlename)
{
	int iParticle = CreateEntityByName("info_particle_system");
	if (bIsValidEntity(iParticle))
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

stock void vRemoveWeapon(int survivor, int slot)
{
	int iSlot = GetPlayerWeaponSlot(survivor, slot);
	if (iSlot > 0)
	{
		RemovePlayerItem(survivor, iSlot);
		RemoveEntity(iSlot);
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

stock void vShake(int survivor, float duration = 1.0)
{
	Handle hShakeTarget = StartMessageOne("Shake", survivor);
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

stock void vSpawnInfected(int tank, const char[] infected)
{
	ChangeClientTeam(tank, 3);
	vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", infected);
	KickClient(tank);
}

stock void vSpecialAttack(int tank, float pos[3], const char[] model)
{
	int iProp = CreateEntityByName("prop_physics");
	if (bIsValidEntity(iProp))
	{
		DispatchKeyValue(iProp, "disableshadows", "1");
		SetEntityModel(iProp, model);

		pos[2] += 10.0;
		TeleportEntity(iProp, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iProp);

		SetEntPropEnt(iProp, Prop_Data, "m_hPhysicsAttacker", tank);
		SetEntPropFloat(iProp, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());

		SetEntProp(iProp, Prop_Send, "m_CollisionGroup", 1);
		SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iProp, 0, 0, 0, 0);

		AcceptEntityInput(iProp, "Break");
	}
}

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
	MarkNativeAsOptional("ST_MaxType");
	MarkNativeAsOptional("ST_MinType");
	MarkNativeAsOptional("ST_PluginEnabled");
	MarkNativeAsOptional("ST_SpawnTank");
	MarkNativeAsOptional("ST_TankAllowed");
	MarkNativeAsOptional("ST_TankChance");
	MarkNativeAsOptional("ST_TankColors");
	MarkNativeAsOptional("ST_TankName");
	MarkNativeAsOptional("ST_TankType");
	MarkNativeAsOptional("ST_TankWave");
	MarkNativeAsOptional("ST_TypeEnabled");
}
#endif