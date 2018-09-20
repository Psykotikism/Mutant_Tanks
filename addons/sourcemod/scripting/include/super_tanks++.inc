// Super Tanks++
#if defined _supertanksplusplus_included
	#endinput
#endif
#define _supertanksplusplus_included

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <adminmenu>
#define ST_PREFIX "[ST++]"
#define ST_PREFIX2 "\x04[ST++]\x01"
#define ST_PREFIX3 "\x04[ST++]\x03"
#define ST_PREFIX4 "\x04[ST++]\x05"
#define ST_NAME "Super Tanks++"
#define ST_AUTHOR "Psyk0tik (Crasher_3637)"
#define ST_DESCRIPTION "Super Tanks++ makes fighting Tanks great again!"
#define ST_VERSION "8.42"
#define ST_URL "https://forums.alliedmods.net/showthread.php?t=302140"
#define ST_MAXTYPES 5000
#define ST_MAXHEALTH 65535
#define ST_MAX_HEALTH_REDUCTION -65535
#define MELEE_AXE_V "models/weapons/melee/v_fireaxe.mdl"
#define MELEE_AXE_W "models/weapons/melee/w_fireaxe.mdl"
#define MELEE_BAT_V "models/weapons/melee/v_bat.mdl"
#define MELEE_BAT_W "models/weapons/melee/w_bat.mdl"
#define MELEE_CHAINSAW_V "models/weapons/melee/v_chainsaw.mdl"
#define MELEE_CHAINSAW_W "models/weapons/melee/w_chainsaw.mdl"
#define MELEE_CRICKET_V "models/weapons/melee/v_cricket_bat.mdl"
#define MELEE_CRICKET_W "models/weapons/melee/w_cricket_bat.mdl"
#define MELEE_CROWBAR_V "models/weapons/melee/v_crowbar.mdl"
#define MELEE_CROWBAR_W "models/weapons/melee/w_crowbar.mdl"
#define MELEE_GOLFCLUB_V "models/weapons/melee/v_golfclub.mdl"
#define MELEE_GOLFCLUB_W "models/weapons/melee/w_golfclub.mdl"
#define MELEE_GUITAR_V "models/weapons/melee/v_electric_guitar.mdl"
#define MELEE_GUITAR_W "models/weapons/melee/w_electric_guitar.mdl"
#define MELEE_KATANA_V "models/weapons/melee/v_katana.mdl"
#define MELEE_KATANA_W "models/weapons/melee/w_katana.mdl"
#define MELEE_KNIFE_V "models/v_models/v_knife_t.mdl"
#define MELEE_KNIFE_W "models/w_models/weapons/w_knife_t.mdl"
#define MELEE_MACHETE_V "models/weapons/melee/v_machete.mdl"
#define MELEE_MACHETE_W "models/weapons/melee/w_machete.mdl"
#define MELEE_PAN_V "models/weapons/melee/v_frying_pan.mdl"
#define MELEE_PAN_W "models/weapons/melee/w_frying_pan.mdl"
#define MELEE_TONFA_V "models/weapons/melee/v_tonfa.mdl"
#define MELEE_TONFA_W "models/weapons/melee/w_tonfa.mdl"
#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"
#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl"
#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define PARTICLE_FIRE "aircraft_destroy_fastFireTrail"
#define PARTICLE_ICE "steam_manhole"
#define PARTICLE_METEOR "smoke_medium_01"
#define PARTICLE_SMOKE "smoker_smokecloud"
#define PARTICLE_SPIT "spitter_projectile"
#define SCRIPT_AXE "scripts/melee/fireaxe.txt"
#define SCRIPT_BAT "scripts/melee/baseball_bat.txt"
#define SCRIPT_CRICKET "scripts/melee/cricket_bat.txt"
#define SCRIPT_CROWBAR "scripts/melee/crowbar.txt"
#define SCRIPT_GOLFCLUB "scripts/melee/golfclub.txt"
#define SCRIPT_GUITAR "scripts/melee/electric_guitar.txt"
#define SCRIPT_KATANA "scripts/melee/katana.txt"
#define SCRIPT_KNIFE "scripts/melee/knife.txt"
#define SCRIPT_MACHETE "scripts/melee/machete.txt"
#define SCRIPT_PAN "scripts/melee/frying_pan.txt"
#define SCRIPT_TONFA "scripts/melee/tonfa.txt"
#define SPRITE_FIRE "sprites/sprite_fire01.vmt"
#define SPRITE_GLOW "sprites/glow.vmt"
#define SOUND_BOSS "items/suitchargeok1.wav"
#define SOUND_BULLET "physics/glass/glass_impact_bullet4.wav"
#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"
#define SOUND_EXPLOSION2 "ambient/explosions/explode_2.wav"
#define SOUND_EXPLOSION "ambient/explosions/exp2.wav"
#define SOUND_FIRE "weapons/rpg/rocketfire1.wav"
#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_INFECTED "npc/infected/action/die/male/death_42.wav"
#define SOUND_INFECTED2 "npc/infected/action/die/male/death_43.wav"
#define SOUND_LAUNCH "npc/env_headcrabcanister/launch.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"
#define WEAPON_AUTO_V "models/v_models/weapons/v_autoshot_m4super.mdl"
#define WEAPON_AUTO_W "models/w_models/weapons/w_autoshot_m4super.mdl"
#define WEAPON_HUNT_V "models/v_models/weapons/v_sniper_mini14.mdl"
#define WEAPON_HUNT_W "models/w_models/weapons/w_sniper_mini14.mdl"
#define WEAPON_M16_V "models/v_models/weapons/v_rifle_m16a2.mdl"
#define WEAPON_M16_W "models/w_models/weapons/w_rifle_m16a2.mdl"
#define WEAPON_PISTOL_V "models/v_models/weapons/v_pistol_1911.mdl"
#define WEAPON_PISTOL_W "models/w_models/weapons/w_pistol_1911.mdl"
#define WEAPON_PUMP_V "models/v_models/weapons/v_pumpshotgun_a.mdl"
#define WEAPON_PUMP_W "models/w_models/weapons/w_pumpshotgun_a.mdl"
#define WEAPON_SMG_V "models/v_models/weapons/v_smg_uzi.mdl"
#define WEAPON_SMG_W "models/w_models/weapons/w_smg_uzi.mdl"
#define WEAPON2_AK47_V "models/v_models/weapons/v_rifle_ak47.mdl"
#define WEAPON2_AK47_W "models/w_models/weapons/w_rifle_ak47.mdl"
#define WEAPON2_AUTO_V "models/v_models/weapons/v_autoshot_m4super.mdl"
#define WEAPON2_AUTO_W "models/w_models/weapons/w_autoshot_m4super.mdl"
#define WEAPON2_AWP_V "models/v_models/weapons/v_sniper_awp.mdl"
#define WEAPON2_AWP_W "models/w_models/weapons/w_sniper_awp.mdl"
#define WEAPON2_CHROME_V "models/v_models/weapons/v_shotgun.mdl"
#define WEAPON2_CHROME_W "models/w_models/weapons/w_shotgun.mdl"
#define WEAPON2_DESERT_V "models/v_models/weapons/v_desert_rifle.mdl"
#define WEAPON2_DESERT_W "models/w_models/weapons/w_desert_rifle.mdl"
#define WEAPON2_GRENADE_V "models/v_models/weapons/v_grenade_launcher.mdl"
#define WEAPON2_GRENADE_W "models/w_models/weapons/w_grenade_launcher.mdl"
#define WEAPON2_HUNT_V "models/v_models/weapons/v_sniper_mini14.mdl"
#define WEAPON2_HUNT_W "models/w_models/weapons/w_sniper_mini14.mdl"
#define WEAPON2_M16_V "models/v_models/weapons/v_rifle_m16a2.mdl"
#define WEAPON2_M16_W "models/w_models/weapons/w_rifle_m16a2.mdl"
#define WEAPON2_M60_V "models/v_models/weapons/v_m60.mdl"
#define WEAPON2_M60_W "models/w_models/weapons/w_m60.mdl"
#define WEAPON2_MAGNUM_V "models/v_models/weapons/v_desert_eagle.mdl"
#define WEAPON2_MAGNUM_W "models/w_models/weapons/w_desert_eagle.mdl"
#define WEAPON2_MILITARY_V "models/v_models/weapons/v_sniper_military.mdl"
#define WEAPON2_MILITARY_W "models/w_models/weapons/w_sniper_military.mdl"
#define WEAPON2_MP5_V "models/v_models/weapons/v_smg_mp5.mdl"
#define WEAPON2_MP5_W "models/w_models/weapons/w_smg_mp5.mdl"
#define WEAPON2_PISTOL_V "models/v_models/weapons/v_pistol_a.mdl"
#define WEAPON2_PISTOL_W "models/w_models/weapons/w_pistol_a.mdl"
#define WEAPON2_PUMP_V "models/v_models/weapons/v_pumpshotgun_a.mdl"
#define WEAPON2_PUMP_W "models/w_models/weapons/w_pumpshotgun_a.mdl"
#define WEAPON2_SCOUT_V "models/v_models/weapons/v_sniper_scout.mdl"
#define WEAPON2_SCOUT_W "models/w_models/weapons/w_sniper_scout.mdl"
#define WEAPON2_SG552_V "models/v_models/weapons/v_rifle_sg552.mdl"
#define WEAPON2_SG552_W "models/w_models/weapons/w_rifle_sg552.mdl"
#define WEAPON2_SILENCED_V "models/v_models/weapons/v_smg_a.mdl"
#define WEAPON2_SILENCED_W "models/w_models/weapons/w_smg_a.mdl"
#define WEAPON2_SMG_V "models/v_models/weapons/v_smg_uzi.mdl"
#define WEAPON2_SMG_W "models/w_models/weapons/w_smg_uzi.mdl"
#define WEAPON2_SPAS_V "models/v_models/weapons/v_shotgun_spas.mdl"
#define WEAPON2_SPAS_W "models/w_models/weapons/w_shotgun_spas.mdl"

// Forwards
/* Called every second to trigger the Super Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param client		Client index of the Tank.
 */
forward void ST_Ability(int client);

/* Called when the Super Tank evolves.
 * Use this forward to trigger any features/abilities/settings
 * when a Super Tank evolves.
 *
 * @param client		Client index of the Tank.
 */
forward void ST_BossStage(int client);

/* Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param savepath		The savepath of the config.
 * @param main			Checks whether the main config
 *							or a custom config
 *							is being used.
 */
forward void ST_Configs(const char[] savepath, bool main);

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

// Natives
/* Returns the maximum value of the "Type Range" setting.
 *
 * @return				The maximum value of the
 *							"Type Range" setting.
 */
native int ST_MaxType();

/* Returns the minimum value of the "Type Range" setting.
 *
 * @return				The minimum value of the
 *							"Type Range" setting.
 */
native int ST_MinType();

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

/* Returns the status of the Tank.
 *
 * @param client		Client index of the Tank.
 *
 * @return				True on success, false if
 *							the Tank is controlled
 *							by a human.
 */
native bool ST_TankAllowed(int client);

/* Returns the custom name given to a Tank.
 *
 * @param client		Client index of the Tank.
 * @param buffer		Buffer to store the custom
 *							name in.
 */
native void ST_TankName(int client, char[] buffer);

/* Returns the Super Tank type of the Tank.
 *
 * @param client		Client index of the Tank.
 *
 * @return				The Tank's Super Tank type.
 */
native int ST_TankType(int client);

/* Returns the current finale wave.
 *
 * @return				The current finale wave.
 */
native int ST_TankWave();

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
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 2;
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
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 6;
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
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 3;
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
	return bIsInfected(client) && bIsL4D2Game() && GetEntProp(client, Prop_Send, "m_zombieClass") == 5;
}

stock bool bIsL4D2Game()
{
	return GetEngineVersion() == Engine_Left4Dead2;
}

stock bool bIsPlayerBurning(int client)
{
	if (GetEntPropFloat(client, Prop_Send, "m_burnPercent") > 0.0 || GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONFIRE)
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
		RemoveEntity(iGameMode);
		if (g_iCurrentMode == 0 || !(mode & g_iCurrentMode))
		{
			return false;
		}
	}
	char sGameMode[32], sGameModes[513];
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
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 1;
}

stock bool bIsSpecialInfected(int client)
{
	return bIsSmoker(client) || bIsBoomer(client) || bIsHunter(client) || bIsSpitter(client) || bIsJockey(client) || bIsCharger(client);
}

stock bool bIsSpitter(int client)
{
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 4;
}

stock bool bIsSurvivor(int client)
{
	return bIsValidClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client);
}

stock bool bIsTank(int client)
{
	return bIsInfected(client) && (bIsL4D2Game() ? GetEntProp(client, Prop_Send, "m_zombieClass") == 8 : GetEntProp(client, Prop_Send, "m_zombieClass") == 5);
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
	if (bIsValidEntity(client))
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
	flAngle[0] += offset1, flAngle[1] += offset2;
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
	int iSurvivorCount, iSurvivors[MAXPLAYERS + 1];
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

stock void vAttachParticle(int client, const char[] particlename, float time = 0.0, float origin = 0.0)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (bIsValidEntity(iParticle))
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

stock void vCheatCommand(int client, const char[] command, const char[] arguments = "", any ...)
{
	int iCmdFlags = GetCommandFlags(command);
	SetCommandFlags(command, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, iCmdFlags|FCVAR_CHEAT);
}

stock void vCopyVector(float source[3], float target[3])
{
	target[0] = source[0], target[1] = source[1], target[2] = source[2];
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

stock void vCreateParticle(int client, const char[] particlename, float time, float origin)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (bIsValidEntity(iParticle))
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

stock void vDamage(int client, const char[] damage)
{
	int iPointHurt = CreateEntityByName("point_hurt");
	if (bIsValidEntity(iPointHurt))
	{
		char sTargetName[32];
		Format(sTargetName, sizeof(sTargetName), "HurtTarget%d", GetClientUserId(client));
		DispatchKeyValue(client, "targetname", sTargetName);
		DispatchKeyValue(iPointHurt, "Damage", damage);
		DispatchKeyValue(iPointHurt, "DamageTarget", sTargetName);
		DispatchKeyValue(iPointHurt, "DamageType", "65536");
		DispatchSpawn(iPointHurt);
		AcceptEntityInput(iPointHurt, "Hurt", client);
		RemoveEntity(iPointHurt);
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

stock void vDropWeapon(int client, const char[] slots, const char[] number, int slot)
{
	if (StrContains(slots, number) != -1)
	{
		if (bIsSurvivor(client) && GetPlayerWeaponSlot(client, slot) > 0)
		{
			SDKHooks_DropWeapon(client, GetPlayerWeaponSlot(client, slot), NULL_VECTOR, NULL_VECTOR);
		}
	}
}

stock void vFade(int client, int duration, int unknown, int red, int green, int blue)
{
	Handle hFadeTarget = StartMessageOne("Fade", client);
	if (hFadeTarget != null)
	{
		BfWrite bfWrite = UserMessageToBfWrite(hFadeTarget);
		bfWrite.WriteShort(duration), bfWrite.WriteShort(unknown), bfWrite.WriteShort((0x0010|0x0001));
		bfWrite.WriteByte(red), bfWrite.WriteByte(green), bfWrite.WriteByte(blue), bfWrite.WriteByte(150);
		EndMessage();
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

stock void vHeal(int client, int health, int extrahealth, int maxhealth)
{
	maxhealth = iClamp(maxhealth, 1, ST_MAXHEALTH);
	int iExtraHealth = (extrahealth > maxhealth) ? maxhealth : extrahealth,
		iExtraHealth2 = (extrahealth < health) ? 1 : extrahealth,
		iRealHealth = (extrahealth >= 0) ? iExtraHealth : iExtraHealth2;
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

stock void vRemoveWeapon(int client, int slot)
{
	int iSlot = GetPlayerWeaponSlot(client, slot);
	if (iSlot > 0)
	{
		RemovePlayerItem(client, iSlot);
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
	target[0] = x, target[1] = y, target[2] = z;
}

stock void vShake(int client, float duration = 1.0)
{
	Handle hShakeTarget = StartMessageOne("Shake", client);
	if (hShakeTarget != null)
	{
		BfWrite bfWrite = UserMessageToBfWrite(hShakeTarget);
		bfWrite.WriteByte(0);
		bfWrite.WriteFloat(16.0), bfWrite.WriteFloat(0.5), bfWrite.WriteFloat(duration);
		EndMessage();
	}
}

stock void vSpawnInfected(int client, const char[] infected)
{
	ChangeClientTeam(client, 3);
	vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", infected);
	KickClient(client);
}

stock void vSpecialAttack(int client, float pos[3], const char[] model)
{
	int iProp = CreateEntityByName("prop_physics");
	if (bIsValidEntity(iProp))
	{
		DispatchKeyValue(iProp, "disableshadows", "1");
		SetEntityModel(iProp, model);
		pos[2] += 10.0;
		TeleportEntity(iProp, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iProp);
		SetEntPropEnt(iProp, Prop_Data, "m_hPhysicsAttacker", client);
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
	MarkNativeAsOptional("ST_TankName");
	MarkNativeAsOptional("ST_TankType");
}
#endif