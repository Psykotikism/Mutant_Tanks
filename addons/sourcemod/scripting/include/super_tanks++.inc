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
#define ST_VERSION "8.33"
#define ST_URL "https://forums.alliedmods.net/showthread.php?t=302140"
#define ST_MAXTYPES 2500
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
		AcceptEntityInput(iGameMode, "Kill");
		if (g_iCurrentMode == 0 || !(mode & g_iCurrentMode))
		{
			return false;
		}
	}
	char sGameMode[32];
	char sGameModes[513];
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
	if (bIsSmoker(client) || bIsBoomer(client) || bIsHunter(client) || bIsSpitter(client) || bIsJockey(client) || bIsCharger(client))
	{
		return true;
	}
	return false;
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
			fFilename.WriteLine("// Note: View the INFORMATION.md file to read about each ability/setting.");
			fFilename.WriteLine("// If any of these Tanks don't work, make sure you have all the abilities installed.");
			fFilename.WriteLine("\"Super Tanks++\"");
			fFilename.WriteLine("{");
			fFilename.WriteLine("	\"Plugin Settings\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Plugin Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Create Backup\"					\"0\"");
			fFilename.WriteLine("			\"Game Mode Types\"				\"0\"");
			fFilename.WriteLine("			\"Enabled Game Modes\"			\"\"");
			fFilename.WriteLine("			\"Disabled Game Modes\"			\"\"");
			fFilename.WriteLine("			\"Announce Arrival\"				\"1\"");
			fFilename.WriteLine("			\"Announce Death\"				\"1\"");
			fFilename.WriteLine("			\"Boss Health Stages\"			\"5000,2500,1500,1000,500\"");
			fFilename.WriteLine("			\"Boss Stages\"					\"3\"");
			fFilename.WriteLine("			\"Display Health\"				\"3\"");
			fFilename.WriteLine("			\"Finales Only\"					\"0\"");
			fFilename.WriteLine("			\"Human Super Tanks\"				\"1\"");
			fFilename.WriteLine("			\"Maximum Types\"					\"86\"");
			fFilename.WriteLine("			\"Multiply Health\"				\"0\"");
			fFilename.WriteLine("			\"Random Interval\"				\"5.0\"");
			fFilename.WriteLine("			\"Spawn Mode\"					\"0\"");
			fFilename.WriteLine("			\"Tank Waves\"					\"2,3,4\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("		\"Custom\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Enable Custom Configs\"			\"0\"");
			fFilename.WriteLine("			\"Create Config Types\"			\"12345\"");
			fFilename.WriteLine("			\"Execute Config Types\"			\"1\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Drop Mode\"						\"0\"");
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
			fFilename.WriteLine("			\"Ghost Hit\"						\"1\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"150.0\"");
			fFilename.WriteLine("			\"Ghost Range Chance\"			\"16\"");
			fFilename.WriteLine("			\"Ghost Weapon Slots\"			\"12345\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 22\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Godly Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Regen Limit\"					\"65535\"");
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
			fFilename.WriteLine("			\"Restart Mode\"					\"1\"");
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
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Rocket Chance\"					\"4\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Smash Chance\"					\"4\"");
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
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Smite Chance\"					\"4\"");
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
			fFilename.WriteLine("			\"Splash Interval\"				\"5.0\"");
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
			fFilename.WriteLine("		\"Track Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Track Chance\"					\"4\"");
			fFilename.WriteLine("			\"Track Mode\"					\"1\"");
			fFilename.WriteLine("			\"Track Speed\"					\"500.0\"");
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
			fFilename.WriteLine("			\"Witch Range\"					\"500.0\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Ghost Hit\"						\"1\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"150.0\"");
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
			fFilename.WriteLine("			\"Witch Amount\"					\"5\"");
			fFilename.WriteLine("			\"Witch Minion Damage\"			\"10\"");
			fFilename.WriteLine("			\"Witch Range\"					\"500.0\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Ghost Hit\"						\"1\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"150.0\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Ghost Hit\"						\"1\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"150.0\"");
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
			fFilename.WriteLine("			\"Witch Range\"					\"500.0\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Ghost Hit\"						\"1\"");
			fFilename.WriteLine("			\"Ghost Range\"					\"150.0\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Claw Damage\"					\"10.0\"");
			fFilename.WriteLine("			\"Extra Health\"					\"1000\"");
			fFilename.WriteLine("			\"Rock Damage\"					\"10.0\"");
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
			fFilename.WriteLine("			\"Clone Amount\"					\"2\"");
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
			fFilename.WriteLine("		\"Track Ability\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Ability Enabled\"				\"1\"");
			fFilename.WriteLine("			\"Track Chance\"					\"1\"");
			fFilename.WriteLine("			\"Track Mode\"					\"1\"");
			fFilename.WriteLine("			\"Track Speed\"					\"600.0\"");
			fFilename.WriteLine("		}");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// Here are some miscellaneous Tanks.");
			fFilename.WriteLine("	// These Tanks are just random combinations that the plugin developer put together.");
			fFilename.WriteLine("	\"Tank 83\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"General\"");
			fFilename.WriteLine("		{");
			fFilename.WriteLine("			\"Tank Name\"						\"Apocalyptic Tank\"");
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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
			fFilename.WriteLine("			\"Tank Enabled\"					\"1\"");
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

stock void vSpecialAttack(int client, float pos[3], char[] model)
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