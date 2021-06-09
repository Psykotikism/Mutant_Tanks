/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2021  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <dhooks>
#include <mutant_tanks>

#undef REQUIRE_PLUGIN
#tryinclude <adminmenu>
#tryinclude <clientprefs>
#tryinclude <left4dhooks>
#tryinclude <mt_clone>
#tryinclude <WeaponHandling>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = MT_NAME,
	author = MT_AUTHOR,
	description = MT_DESCRIPTION,
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad, g_bSecondGame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"Mutant Tanks\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	CreateNative("MT_CanTypeSpawn", aNative_CanTypeSpawn);
	CreateNative("MT_DetonateTankRock", aNative_DetonateTankRock);
	CreateNative("MT_DoesSurvivorHaveRewardType", aNative_DoesSurvivorHaveRewardType);
	CreateNative("MT_DoesTypeRequireHumans", aNative_DoesTypeRequireHumans);
	CreateNative("MT_GetAccessFlags", aNative_GetAccessFlags);
	CreateNative("MT_GetCombinationSetting", aNative_GetCombinationSetting);
	CreateNative("MT_GetCurrentFinaleWave", aNative_GetCurrentFinaleWave);
	CreateNative("MT_GetGlowRange", aNative_GetGlowRange);
	CreateNative("MT_GetGlowType", aNative_GetGlowType);
	CreateNative("MT_GetImmunityFlags", aNative_GetImmunityFlags);
	CreateNative("MT_GetMaxType", aNative_GetMaxType);
	CreateNative("MT_GetMinType", aNative_GetMinType);
	CreateNative("MT_GetPropColors", aNative_GetPropColors);
	CreateNative("MT_GetRunSpeed", aNative_GetRunSpeed);
	CreateNative("MT_GetScaledDamage", aNative_GetScaledDamage);
	CreateNative("MT_GetSpawnType", aNative_GetSpawnType);
	CreateNative("MT_GetTankColors", aNative_GetTankColors);
	CreateNative("MT_GetTankName", aNative_GetTankName);
	CreateNative("MT_GetTankType", aNative_GetTankType);
	CreateNative("MT_HasAdminAccess", aNative_HasAdminAccess);
	CreateNative("MT_HasChanceToSpawn", aNative_HasChanceToSpawn);
	CreateNative("MT_HideEntity", aNative_HideEntity);
	CreateNative("MT_IsAdminImmune", aNative_IsAdminImmune);
	CreateNative("MT_IsCorePluginEnabled", aNative_IsCorePluginEnabled);
	CreateNative("MT_IsCustomTankSupported", aNative_IsCustomTankSupported);
	CreateNative("MT_IsFinaleType", aNative_IsFinaleType);
	CreateNative("MT_IsGlowEnabled", aNative_IsGlowEnabled);
	CreateNative("MT_IsGlowFlashing", aNative_IsGlowFlashing);
	CreateNative("MT_IsNonFinaleType", aNative_IsNonFinaleType);
	CreateNative("MT_IsTankIdle", aNative_IsTankIdle);
	CreateNative("MT_IsTankSupported", aNative_IsTankSupported);
	CreateNative("MT_IsTypeEnabled", aNative_IsTypeEnabled);
	CreateNative("MT_LogMessage", aNative_LogMessage);
	CreateNative("MT_RespawnSurvivor", aNative_RespawnSurvivor);
	CreateNative("MT_SetTankType", aNative_SetTankType);
	CreateNative("MT_ShoveBySurvivor", aNative_ShoveBySurvivor);
	CreateNative("MT_SpawnTank", aNative_SpawnTank);
	CreateNative("MT_TankMaxHealth", aNative_TankMaxHealth);
	CreateNative("MT_UnvomitPlayer", aNative_UnvomitPlayer);
	CreateNative("MT_VomitPlayer", aNative_VomitPlayer);

	RegPluginLibrary("mutant_tanks");

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_CONCRETE_CHUNK "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_FIREWORKCRATE "models/props_junk/explosive_box001.mdl" // Only available in L4D2
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_OXYGENTANK "models/props_equipment/oxygentank01.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_TANK_MAIN "models/infected/hulk.mdl"
#define MODEL_TANK_DLC "models/infected/hulk_dlc3.mdl"
#define MODEL_TANK_L4D1 "models/infected/hulk_l4d1.mdl" // Only available in L4D2
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_TREE_TRUNK "models/props_foliage/tree_trunk.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl" // Only available in L4D2

#define PARTICLE_ACHIEVED "achieved"
#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define PARTICLE_FIRE "aircraft_destroy_fastFireTrail"
#define PARTICLE_FIREWORK "mini_fireworks"
#define PARTICLE_GORE "gore_wound_fullbody_1"
#define PARTICLE_ICE "apc_wheel_smoke1"
#define PARTICLE_METEOR "smoke_medium_01"
#define PARTICLE_SMOKE "smoker_smokecloud"
#define PARTICLE_SPIT "spitter_projectile" // Only available in L4D2
#define PARTICLE_SPIT2 "spitter_slime_trail" // Only available in L4D2

#define SOUND_ACHIEVEMENT "ui/pickup_misc42.wav"
#define SOUND_DAMAGE "player/damage1.wav"
#define SOUND_DAMAGE2 "player/damage2.wav"
#define SOUND_DEATH "ui/pickup_scifi37.wav"
#define SOUND_ELECTRICITY "items/suitchargeok1.wav"
#define SOUND_EXPLOSION2 "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_2.wav" // Only available in L4D2
#define SOUND_EXPLOSION1 "animation/van_inside_debris.wav" // Only used in L4D1
#define SOUND_LADYKILLER "ui/alert_clink.wav"
#define SOUND_METAL "physics/metal/metal_solid_impact_hard5.wav"
#define SOUND_MISSILE "player/tank/attack/thrown_missile_loop_1.wav"
#define SOUND_NULL "common/null.wav"
#define SOUND_SPAWN "ui/pickup_secret01.wav"
#define SOUND_SPIT "player/spitter/voice/warn/spitter_spit_02.wav" // Only available in L4D2

#define SPRITE_EXPLODE "sprites/zerogxplode.spr"

#define MT_ARRIVAL_SPAWN (1 << 0) // announce spawn
#define MT_ARRIVAL_BOSS (1 << 1) // announce evolution
#define MT_ARRIVAL_RANDOM (1 << 2) // announce randomization
#define MT_ARRIVAL_TRANSFORM (1 << 3) // announce transformation
#define MT_ARRIVAL_REVERT (1 << 4) // announce revert

#define MT_CMD_SPAWN (1 << 0) // "sm_tank"/"sm_mt_tank"
#define MT_CMD_CONFIG (1 << 1) // "sm_mt_config"
#define MT_CMD_LIST (1 << 2) // "sm_mt_list"
#define MT_CMD_RELOAD (1 << 3) // "sm_mt_reload"
#define MT_CMD_VERSION (1 << 4) // "sm_mt_version"

#define MT_CONFIG_DIFFICULTY (1 << 0) // difficulty_configs
#define MT_CONFIG_MAP (1 << 1) // l4d_map_configs/l4d2_map_configs
#define MT_CONFIG_GAMEMODE (1 << 2) // l4d_gamemode_configs/l4d2_gamemode_configs
#define MT_CONFIG_DAY (1 << 3) // daily_configs
#define MT_CONFIG_PLAYERCOUNT (1 << 4) // playercount_configs
#define MT_CONFIG_SURVIVORCOUNT (1 << 5) // survivorcount_configs
#define MT_CONFIG_INFECTEDCOUNT (1 << 6) // infectedcount_configs
#define MT_CONFIG_FINALE (1 << 7) // l4d_finale_configs/l4d2_finale_configs

#define MT_CONFIG_SECTION_MAIN "Mutant Tanks"
#define MT_CONFIG_SECTION_MAIN2 "MutantTanks"
#define MT_CONFIG_SECTION_MAIN3 "Mutant_Tanks"
#define MT_CONFIG_SECTION_MAIN4 "MTanks"
#define MT_CONFIG_SECTION_MAIN5 "MT"
#define MT_CONFIG_SECTION_SETTINGS "PluginSettings"
#define MT_CONFIG_SECTION_SETTINGS2 "Plugin Settings"
#define MT_CONFIG_SECTION_SETTINGS3 "Plugin_Settings"
#define MT_CONFIG_SECTION_SETTINGS4 "settings"
#define MT_CONFIG_SECTION_GENERAL "General"
#define MT_CONFIG_SECTIONS_GENERAL MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL
#define MT_CONFIG_SECTION_ANNOUNCE "Announcements"
#define MT_CONFIG_SECTION_ANNOUNCE2 "announce"
#define MT_CONFIG_SECTIONS_ANNOUNCE MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2
#define MT_CONFIG_SECTION_REWARDS "Rewards"
#define MT_CONFIG_SECTIONS_REWARDS MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS
#define MT_CONFIG_SECTION_COMP "Competitive"
#define MT_CONFIG_SECTION_COMP2 "comp"
#define MT_CONFIG_SECTIONS_COMP MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP2
#define MT_CONFIG_SECTION_DIFF "Difficulty"
#define MT_CONFIG_SECTION_DIFF2 "diff"
#define MT_CONFIG_SECTIONS_DIFF MT_CONFIG_SECTION_DIFF, MT_CONFIG_SECTION_DIFF, MT_CONFIG_SECTION_DIFF, MT_CONFIG_SECTION_DIFF2
#define MT_CONFIG_SECTION_HEALTH "Health"
#define MT_CONFIG_SECTIONS_HEALTH MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH
#define MT_CONFIG_SECTION_HUMAN "HumanSupport"
#define MT_CONFIG_SECTION_HUMAN2 "Human Support"
#define MT_CONFIG_SECTION_HUMAN3 "Human_Support"
#define MT_CONFIG_SECTION_HUMAN4 "human"
#define MT_CONFIG_SECTIONS_HUMAN MT_CONFIG_SECTION_HUMAN, MT_CONFIG_SECTION_HUMAN2, MT_CONFIG_SECTION_HUMAN3, MT_CONFIG_SECTION_HUMAN4
#define MT_CONFIG_SECTION_WAVES "Waves"
#define MT_CONFIG_SECTIONS_WAVES MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES
#define MT_CONFIG_SECTION_CONVARS "ConVars"
#define MT_CONFIG_SECTION_CONVARS2 "cvars"
#define MT_CONFIG_SECTIONS_CONVARS MT_CONFIG_SECTION_CONVARS, MT_CONFIG_SECTION_CONVARS, MT_CONFIG_SECTION_CONVARS, MT_CONFIG_SECTION_CONVARS2
#define MT_CONFIG_SECTION_GAMEMODES "GameModes"
#define MT_CONFIG_SECTION_GAMEMODES2 "Game Modes"
#define MT_CONFIG_SECTION_GAMEMODES3 "Game_Modes"
#define MT_CONFIG_SECTION_GAMEMODES4 "modes"
#define MT_CONFIG_SECTIONS_GAMEMODES MT_CONFIG_SECTION_GAMEMODES, MT_CONFIG_SECTION_GAMEMODES2, MT_CONFIG_SECTION_GAMEMODES3, MT_CONFIG_SECTION_GAMEMODES4
#define MT_CONFIG_SECTION_CUSTOM "Custom"
#define MT_CONFIG_SECTIONS_CUSTOM MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM
#define MT_CONFIG_SECTION_GLOW "Glow"
#define MT_CONFIG_SECTIONS_GLOW MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW
#define MT_CONFIG_SECTION_SPAWN "Spawn"
#define MT_CONFIG_SECTIONS_SPAWN MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN
#define MT_CONFIG_SECTION_BOSS "Boss"
#define MT_CONFIG_SECTIONS_BOSS MT_CONFIG_SECTION_BOSS, MT_CONFIG_SECTION_BOSS, MT_CONFIG_SECTION_BOSS, MT_CONFIG_SECTION_BOSS
#define MT_CONFIG_SECTION_COMBO "Combo"
#define MT_CONFIG_SECTIONS_COMBO MT_CONFIG_SECTION_COMBO, MT_CONFIG_SECTION_COMBO, MT_CONFIG_SECTION_COMBO, MT_CONFIG_SECTION_COMBO
#define MT_CONFIG_SECTION_RANDOM "Random"
#define MT_CONFIG_SECTIONS_RANDOM MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM
#define MT_CONFIG_SECTION_TRANSFORM "Transform"
#define MT_CONFIG_SECTIONS_TRANSFORM MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM
#define MT_CONFIG_SECTION_ADMIN "Administration"
#define MT_CONFIG_SECTION_ADMIN2 "admin"
#define MT_CONFIG_SECTIONS_ADMIN MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN2
#define MT_CONFIG_SECTION_PROPS "Props"
#define MT_CONFIG_SECTIONS_PROPS MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS
#define MT_CONFIG_SECTION_PARTICLES "Particles"
#define MT_CONFIG_SECTIONS_PARTICLES MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES
#define MT_CONFIG_SECTION_ENHANCE "Enhancements"
#define MT_CONFIG_SECTION_ENHANCE2 "enhance"
#define MT_CONFIG_SECTIONS_ENHANCE MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2
#define MT_CONFIG_SECTION_IMMUNE "Immunities"
#define MT_CONFIG_SECTION_IMMUNE2 "immune"
#define MT_CONFIG_SECTIONS_IMMUNE MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2

#define MT_EFFECT_TROPHY (1 << 0) // trophy
#define MT_EFFECT_FIREWORKS (1 << 1) // fireworks particles
#define MT_EFFECT_SOUND (1 << 2) // sound effect
#define MT_EFFECT_THIRDPERSON (1 << 3) // thirdperson view

#define MT_JUMP_DEFAULTHEIGHT 57.0 // default jump height
#define MT_JUMP_FALLPASSES 3 // safe fall passes
#define MT_JUMP_FORWARDBOOST 50.0 // forward boost for each jump

#define MT_INFAMMO_PRIMARY (1 << 0) // primary weapon
#define MT_INFAMMO_SECONDARY (1 << 1) // secondary weapon
#define MT_INFAMMO_THROWABLE (1 << 2) // throwable
#define MT_INFAMMO_MEDKIT (1 << 3) // medkit
#define MT_INFAMMO_PILLS (1 << 4) // pills

#define MT_PARTICLE_BLOOD (1 << 0) // blood particle
#define MT_PARTICLE_ELECTRICITY (1 << 1) // electric particle
#define MT_PARTICLE_FIRE (1 << 2) // fire particle
#define MT_PARTICLE_ICE (1 << 3) // ice particle
#define MT_PARTICLE_METEOR (1 << 4) // meteor particle
#define MT_PARTICLE_SMOKE (1 << 5) // smoke particle
#define MT_PARTICLE_SPIT (1 << 6) // spit particle

#define MT_PATCH_LIMIT 50 // number of patches allowed
#define MT_PATCH_MAXLEN 48 // number of bytes allowed

#define MT_PROP_BLUR (1 << 0) // blur prop
#define MT_PROP_LIGHT (1 << 1) // light prop
#define MT_PROP_OXYGENTANK (1 << 2) // oxgyen tank prop
#define MT_PROP_FLAME (1 << 3) // flame prop
#define MT_PROP_ROCK (1 << 4) // rock prop
#define MT_PROP_TIRE (1 << 5) // tire prop
#define MT_PROP_PROPANETANK (1 << 6) // propane tank prop
#define MT_PROP_FLASHLIGHT (1 << 7) // flashlight prop
#define MT_PROP_CROWN (1 << 8) // crown prop

#define MT_ROCK_BLOOD (1 << 0) // blood particle
#define MT_ROCK_ELECTRICITY (1 << 1) // electric particle
#define MT_ROCK_FIRE (1 << 2) // fire particle
#define MT_ROCK_SPIT (1 << 3) // spit particle

#define MT_STACK_HEALTH 2 // how many times to stack health reward
#define MT_STACK_SPEEDBOOST 2 // how many times to stack speed boost reward
#define MT_STACK_DAMAGEBOOST 2 // how many times to stack damage boost reward
#define MT_STACK_ATTACKBOOST 2 // how many times to stack attack boost reward
#define MT_STACK_AMMO 2 // how many times to stack ammo reward
#define MT_STACK_GODMODE 2 // how many times to stack god mode reward
#define MT_STACK_INFAMMO 2 // how many times to stack infinite ammo reward

#define MT_USEFUL_REFILL (1 << 0) // useful refill reward
#define MT_USEFUL_HEALTH (1 << 1) // useful health reward
#define MT_USEFUL_AMMO (1 << 2) // useful ammo reward
#define MT_USEFUL_RESPAWN (1 << 3) // useful respawn reward

#define MT_VISUAL_SCREEN (1 << 0) // screen color
#define MT_VISUAL_GLOW (1 << 1) // glow outline
#define MT_VISUAL_BODY (1 << 2) // body color
#define MT_VISUAL_PARTICLE (1 << 3) // particle effect
#define MT_VISUAL_VOICELINE (1 << 4) // looping voiceline

enum ConfigState
{
	ConfigState_None, // no section yet
	ConfigState_Start, // reached "Mutant Tanks" section
	ConfigState_Settings, // reached "Plugin Settings" section
	ConfigState_Type, // reached "Tank #" section
	ConfigState_Admin, // reached "STEAM_" or "[U:" section
	ConfigState_Specific // reached specific sections
};

enum struct esGeneral
{
	Address g_adDirector;
	Address g_adDoJumpValue;
	Address g_adFallingSound;

	ArrayList g_alAbilitySections[4];
	ArrayList g_alFilePaths;
	ArrayList g_alPlugins;
	ArrayList g_alSections;

	bool g_bAbilityPlugin[MT_MAXABILITIES + 1];
	bool g_bClientPrefsInstalled;
	bool g_bCloneInstalled;
	bool g_bFinaleEnded;
	bool g_bForceSpawned;
	bool g_bHideNameChange;
	bool g_bLeft4DHooksInstalled;
	bool g_bLinux;
	bool g_bMapStarted;
	bool g_bPatchDoJumpValue;
	bool g_bPatchFallingSound;
	bool g_bPluginEnabled;
	bool g_bUsedParser;
	bool g_bWitchKilled[2048];

	char g_sBodyColorVisual[48];
	char g_sBodyColorVisual2[48];
	char g_sBodyColorVisual3[48];
	char g_sBodyColorVisual4[48];
	char g_sChosenPath[PLATFORM_MAX_PATH];
	char g_sCurrentSection[128];
	char g_sCurrentSubSection[128];
	char g_sDisabledGameModes[513];
	char g_sEnabledGameModes[513];
	char g_sFallVoicelineReward[64];
	char g_sFallVoicelineReward2[64];
	char g_sFallVoicelineReward3[64];
	char g_sFallVoicelineReward4[64];
	char g_sGlowColorVisual[36];
	char g_sGlowColorVisual2[36];
	char g_sGlowColorVisual3[36];
	char g_sGlowColorVisual4[36];
	char g_sHealthCharacters[4];
	char g_sItemReward[320];
	char g_sItemReward2[320];
	char g_sItemReward3[320];
	char g_sItemReward4[320];
	char g_sLogFile[PLATFORM_MAX_PATH];
	char g_sLoopingVoicelineVisual[64];
	char g_sLoopingVoicelineVisual2[64];
	char g_sLoopingVoicelineVisual3[64];
	char g_sLoopingVoicelineVisual4[64];
	char g_sSavePath[PLATFORM_MAX_PATH];
	char g_sScreenColorVisual[48];
	char g_sScreenColorVisual2[48];
	char g_sScreenColorVisual3[48];
	char g_sScreenColorVisual4[48];
	char g_sSection[PLATFORM_MAX_PATH];

	ConfigState g_csState;
	ConfigState g_csState2;

	ConVar g_cvMTAmmoPackUseDuration;
	ConVar g_cvMTAssaultRifleAmmo;
	ConVar g_cvMTAutoShotgunAmmo;
	ConVar g_cvMTColaBottlesUseDuration;
	ConVar g_cvMTDefibrillatorUseDuration;
	ConVar g_cvMTDifficulty;
	ConVar g_cvMTDisabledGameModes;
	ConVar g_cvMTEnabledGameModes;
	ConVar g_cvMTFirstAidHealPercent;
	ConVar g_cvMTFirstAidKitUseDuration;
	ConVar g_cvMTGameMode;
	ConVar g_cvMTGameModeTypes;
	ConVar g_cvMTGameTypes;
	ConVar g_cvMTGasCanUseDuration;
	ConVar g_cvMTGrenadeLauncherAmmo;
	ConVar g_cvMTGunSwingInterval;
	ConVar g_cvMTHuntingRifleAmmo;
	ConVar g_cvMTListenSupport;
	ConVar g_cvMTMeleeRange;
	ConVar g_cvMTPainPillsDecayRate;
	ConVar g_cvMTPhysicsPushScale;
	ConVar g_cvMTPluginEnabled;
	ConVar g_cvMTShotgunAmmo;
	ConVar g_cvMTSMGAmmo;
	ConVar g_cvMTSniperRifleAmmo;
	ConVar g_cvMTSurvivorReviveDuration;
	ConVar g_cvMTSurvivorReviveHealth;
	ConVar g_cvMTTempSetting;
	ConVar g_cvMTUpgradePackUseDuration;
#if defined _clientprefs_included
	Cookie g_ckMTPrefs;
#endif
	DynamicDetour g_ddActionCompleteDetour;
	DynamicDetour g_ddDeathFallCameraEnableDetour;
	DynamicDetour g_ddDoAnimationEventDetour;
	DynamicDetour g_ddDoJumpDetour;
	DynamicDetour g_ddEnterGhostStateDetour;
	DynamicDetour g_ddEnterStasisDetour;
	DynamicDetour g_ddEventKilledDetour;
	DynamicDetour g_ddFallingDetour;
	DynamicDetour g_ddFinishHealingDetour;
	DynamicDetour g_ddFirstSurvivorLeftSafeAreaDetour;
	DynamicDetour g_ddFireBulletDetour;
	DynamicDetour g_ddFlingDetour;
	DynamicDetour g_ddGetMaxClip1Detour;
	DynamicDetour g_ddHitByVomitJarDetour;
	DynamicDetour g_ddLauncherDirectionDetour;
	DynamicDetour g_ddLeaveStasisDetour;
	DynamicDetour g_ddMaxCarryDetour;
	DynamicDetour g_ddReplaceTankDetour;
	DynamicDetour g_ddRevivedDetour;
	DynamicDetour g_ddSecondaryAttackDetour;
	DynamicDetour g_ddSecondaryAttackDetour2;
	DynamicDetour g_ddSelectWeightedSequenceDetour;
	DynamicDetour g_ddSetMainActivityDetour;
	DynamicDetour g_ddShovedByPounceLandingDetour;
	DynamicDetour g_ddShovedBySurvivorDetour;
	DynamicDetour g_ddSpawnTankDetour;
	DynamicDetour g_ddStaggerDetour;
	DynamicDetour g_ddStartHealingDetour;
	DynamicDetour g_ddStartRevivingDetour;
	DynamicDetour g_ddStartActionDetour;
	DynamicDetour g_ddTankClawDoSwingDetour;
	DynamicDetour g_ddTankClawPlayerHitDetour;
	DynamicDetour g_ddTankRockCreateDetour;
	DynamicDetour g_ddTestMeleeSwingCollisionDetour;
	DynamicDetour g_ddVomitedUponDetour;

	float g_flActionDurationReward[4];
	float g_flAttackBoostReward[4];
	float g_flAttackInterval;
	float g_flBurnDuration;
	float g_flBurntSkin;
	float g_flClawDamage;
	float g_flDamageBoostReward[4];
	float g_flDamageResistanceReward[4];
	float g_flDefaultAmmoPackUseDuration;
	float g_flDefaultColaBottlesUseDuration;
	float g_flDefaultDefibrillatorUseDuration;
	float g_flDefaultFirstAidHealPercent;
	float g_flDefaultFirstAidKitUseDuration;
	float g_flDefaultGasCanUseDuration;
	float g_flDefaultGunSwingInterval;
	float g_flDefaultPhysicsPushScale;
	float g_flDefaultSurvivorReviveDuration;
	float g_flDefaultUpgradePackUseDuration;
	float g_flDifficultyDamage[4];
	float g_flExtrasDelay;
	float g_flForceSpawn;
	float g_flHealPercentReward[4];
	float g_flHittableDamage;
	float g_flIdleCheck;
	float g_flJumpHeightReward[4];
	float g_flPunchForce;
	float g_flPunchResistanceReward[4];
	float g_flPunchThrow;
	float g_flRegularDelay;
	float g_flRegularInterval;
	float g_flRewardChance[4];
	float g_flRewardDuration[4];
	float g_flRewardPercentage[4];
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flShoveDamageReward[4];
	float g_flShoveRateReward[4];
	float g_flSpeedBoostReward[4];
	float g_flSurvivalDelay;
	float g_flThrowInterval;
	float g_flTickInterval;

	GlobalForward g_gfAbilityActivatedForward;
	GlobalForward g_gfAbilityCheckForward;
	GlobalForward g_gfButtonPressedForward;
	GlobalForward g_gfButtonReleasedForward;
	GlobalForward g_gfChangeTypeForward;
	GlobalForward g_gfCombineAbilitiesForward;
	GlobalForward g_gfConfigsLoadForward;
	GlobalForward g_gfConfigsLoadedForward;
	GlobalForward g_gfCopyStatsForward;
	GlobalForward g_gfDisplayMenuForward;
	GlobalForward g_gfEventFiredForward;
	GlobalForward g_gfFatalFallingForward;
	GlobalForward g_gfHookEventForward;
	GlobalForward g_gfLogMessageForward;
	GlobalForward g_gfMenuItemDisplayedForward;
	GlobalForward g_gfMenuItemSelectedForward;
	GlobalForward g_gfPlayerEventKilledForward;
	GlobalForward g_gfPlayerHitByVomitJarForward;
	GlobalForward g_gfPlayerShovedBySurvivorForward;
	GlobalForward g_gfPluginCheckForward;
	GlobalForward g_gfPluginEndForward;
	GlobalForward g_gfPostTankSpawnForward;
	GlobalForward g_gfResetTimersForward;
	GlobalForward g_gfRewardSurvivorForward;
	GlobalForward g_gfRockBreakForward;
	GlobalForward g_gfRockThrowForward;
	GlobalForward g_gfSettingsCachedForward;
	GlobalForward g_gfTypeChosenForward;

	Handle g_hRegularWavesTimer;
	Handle g_hSDKGetMaxClip1;
	Handle g_hSDKGetName;
	Handle g_hSDKGetRefEHandle;
	Handle g_hSDKGetUseAction;
	Handle g_hSDKHasAnySurvivorLeftSafeArea;
	Handle g_hSDKIsInStasis;
	Handle g_hSDKITExpired;
	Handle g_hSDKLeaveStasis;
	Handle g_hSDKMaterializeGhost;
	Handle g_hSDKRevive;
	Handle g_hSDKRockDetonate;
	Handle g_hSDKRoundRespawn;
	Handle g_hSDKShovedBySurvivor;
	Handle g_hSDKVomitedUpon;
	Handle g_hSurvivalTimer;
	Handle g_hTankWaveTimer;

	int g_iAccessFlags;
	int g_iActionOffset;
	int g_iAggressiveTanks;
	int g_iAllowDeveloper;
	int g_iAmmoBoostReward[4];
	int g_iAmmoRegenReward[4];
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iAnnounceKill;
	int g_iArrivalMessage;
	int g_iArrivalSound;
	int g_iBaseHealth;
	int g_iBehaviorOffset;
	int g_iBulletImmunity;
	int g_iCheckAbilities;
	int g_iChildActionOffset;
	int g_iChosenType;
	int g_iCleanKillsReward[4];
	int g_iConfigCreate;
	int g_iConfigEnable;
	int g_iConfigExecute;
	int g_iConfigMode;
	int g_iCreditIgniters;
	int g_iCurrentMode;
	int g_iDeathDetails;
	int g_iDeathMessage;
	int g_iDeathRevert;
	int g_iDeathSound;
	int g_iDefaultMeleeRange;
	int g_iDefaultSurvivorReviveHealth;
	int g_iDisplayHealth;
	int g_iDisplayHealthType;
	int g_iEventKilledAttackerOffset;
	int g_iExplosiveImmunity;
	int g_iExtraHealth;
	int g_iFileTimeOld[8];
	int g_iFileTimeNew[8];
	int g_iFinaleAmount;
	int g_iFinaleMaxTypes[10];
	int g_iFinaleMinTypes[10];
	int g_iFinalesOnly;
	int g_iFinaleWave[10];
	int g_iFireImmunity;
	int g_iGameModeTypes;
	int g_iHealthRegenReward[4];
	int g_iHittableImmunity;
	int g_iHollowpointAmmoReward[4];
	int g_iHumanCooldown;
	int g_iIdleCheckMode;
	int g_iIgnoreLevel;
	int g_iIgnoreLevel2;
	int g_iImmunityFlags;
	int g_iInfectedHealth[2048];
	int g_iInfiniteAmmoReward[4];
	int g_iIntentionOffset;
	int g_iKillMessage;
	int g_iLadyKillerReward[4];
	int g_iLauncher;
	int g_iLifeLeechReward[4];
	int g_iLimitExtras;
	int g_iListenSupport;
	int g_iLogCommands;
	int g_iLogMessages;
	int g_iMasterControl;
	int g_iMaxType;
	int g_iMeleeImmunity;
	int g_iMeleeOffset;
	int g_iMeleeRangeReward[4];
	int g_iMinType;
	int g_iMinimumHumans;
	int g_iMultiplyHealth;
	int g_iParserViewer;
	int g_iParticleEffectVisual[4];
	int g_iPlayerCount[3];
	int g_iPluginEnabled;
	int g_iPrefsNotify[4];
	int g_iRegularAmount;
	int g_iRegularCount;
	int g_iRegularLimit;
	int g_iRegularMaxType;
	int g_iRegularMinType;
	int g_iRegularMode;
	int g_iRegularWave;
	int g_iRequiresHumans;
	int g_iRespawnLoadoutReward[4];
	int g_iReviveHealthReward[4];
	int g_iRewardBots[4];
	int g_iRewardEffect[4];
	int g_iRewardEnabled[4];
	int g_iRewardNotify[4];
	int g_iRewardPriority[4];
	int g_iRewardVisual[4];
	int g_iScaleDamage;
	int g_iSection;
	int g_iShovePenaltyReward[4];
	int g_iSkipTaunt;
	int g_iSledgehammerRoundsReward[4];
	int g_iSpawnLimit;
	int g_iSpawnEnabled;
	int g_iSpawnMode;
	int g_iSpecialAmmoReward[4];
	int g_iStackRewards[4];
	int g_iStasisMode;
	int g_iSurvivalBlock;
	int g_iSweepFist;
	int g_iTankCount;
	int g_iTankEnabled;
	int g_iTankModel;
	int g_iTankTarget;
	int g_iTankWave;
	int g_iTeamID[2048];
	int g_iTeammateLimit;
	int g_iThornsReward[4];
	int g_iUsefulRewards[4];
	int g_iVocalizeArrival;
	int g_iVocalizeDeath;
	int g_iVomitImmunity;
#if defined _adminmenu_included
	TopMenu g_tmMTMenu;
#endif
}

esGeneral g_esGeneral;

enum struct esAdmin
{
	int g_iAccessFlags[MAXPLAYERS + 1];
	int g_iImmunityFlags[MAXPLAYERS + 1];
}

esAdmin g_esAdmin[MT_MAXTYPES + 1];

enum struct esDeveloper
{
	bool g_bDevVisual;

	char g_sDevFallVoiceline[64];
	char g_sDevGlowOutline[12];
	char g_sDevLoadout[384];
	char g_sDevSkinColor[16];

	float g_flDevActionDuration;
	float g_flDevAttackBoost;
	float g_flDevDamageBoost;
	float g_flDevDamageResistance;
	float g_flDevHealPercent;
	float g_flDevJumpHeight;
	float g_flDevPunchResistance;
	float g_flDevRewardDuration;
	float g_flDevShoveDamage;
	float g_flDevShoveRate;
	float g_flDevSpeedBoost;

	int g_iDevAccess;
	int g_iDevAmmoRegen;
	int g_iDevHealthRegen;
	int g_iDevInfiniteAmmo;
	int g_iDevLifeLeech;
	int g_iDevMeleeRange;
	int g_iDevPanelLevel;
	int g_iDevParticle;
	int g_iDevReviveHealth;
	int g_iDevRewardTypes;
	int g_iDevSpecialAmmo;
	int g_iDevWeaponSkin;
}

esDeveloper g_esDeveloper[MAXPLAYERS + 1];

enum struct esPlayer
{
	bool g_bAdminMenu;
	bool g_bApplyVisuals[5];
	bool g_bArtificial;
	bool g_bAttacked;
	bool g_bAttackedAgain;
	bool g_bBlood;
	bool g_bBlur;
	bool g_bBoss;
	bool g_bCombo;
	bool g_bDied;
	bool g_bDualWielding;
	bool g_bElectric;
	bool g_bFallDamage;
	bool g_bFalling;
	bool g_bFallTracked;
	bool g_bFatalFalling;
	bool g_bFire;
	bool g_bFirstSpawn;
	bool g_bIce;
	bool g_bIgnoreCmd;
	bool g_bKeepCurrentType;
	bool g_bLastLife;
	bool g_bMeteor;
	bool g_bNeedHealth;
	bool g_bRandomized;
	bool g_bReplaceSelf;
	bool g_bSetup;
	bool g_bSmoke;
	bool g_bSpit;
	bool g_bStasis;
	bool g_bThirdPerson;
	bool g_bThirdPerson2;
	bool g_bTransformed;
	bool g_bTriggered;
	bool g_bVomited;

	char g_sBodyColor[48];
	char g_sBodyColorVisual[48];
	char g_sBodyColorVisual2[48];
	char g_sBodyColorVisual3[48];
	char g_sBodyColorVisual4[48];
	char g_sComboSet[320];
	char g_sHealthCharacters[4];
	char g_sFallVoiceline[64];
	char g_sFallVoicelineReward[64];
	char g_sFallVoicelineReward2[64];
	char g_sFallVoicelineReward3[64];
	char g_sFallVoicelineReward4[64];
	char g_sGlowColor[36];
	char g_sGlowColorVisual[36];
	char g_sGlowColorVisual2[36];
	char g_sGlowColorVisual3[36];
	char g_sGlowColorVisual4[36];
	char g_sItemReward[320];
	char g_sItemReward2[320];
	char g_sItemReward3[320];
	char g_sItemReward4[320];
	char g_sLoopingVoiceline[64];
	char g_sLoopingVoicelineVisual[64];
	char g_sLoopingVoicelineVisual2[64];
	char g_sLoopingVoicelineVisual3[64];
	char g_sLoopingVoicelineVisual4[64];
	char g_sScreenColorVisual[48];
	char g_sScreenColorVisual2[48];
	char g_sScreenColorVisual3[48];
	char g_sScreenColorVisual4[48];
	char g_sSteamID32[32];
	char g_sSteam3ID[32];
	char g_sStoredThrowable[32];
	char g_sStoredMedkit[32];
	char g_sStoredPills[32];
	char g_sTankName[33];
	char g_sWeaponPrimary[32];
	char g_sWeaponSecondary[32];
	char g_sWeaponThrowable[32];
	char g_sWeaponMedkit[32];
	char g_sWeaponPills[32];

	float g_flActionDuration;
	float g_flActionDurationReward[4];
	float g_flAttackBoost;
	float g_flAttackBoostReward[4];
	float g_flAttackDelay;
	float g_flAttackInterval;
	float g_flBurnDuration;
	float g_flBurntSkin;
	float g_flClawDamage;
	float g_flComboChance[10];
	float g_flComboDamage[10];
	float g_flComboDeathChance[10];
	float g_flComboDeathRange[10];
	float g_flComboDelay[10];
	float g_flComboDuration[10];
	float g_flComboInterval[10];
	float g_flComboMaxRadius[10];
	float g_flComboMinRadius[10];
	float g_flComboRange[10];
	float g_flComboRangeChance[10];
	float g_flComboRockChance[10];
	float g_flComboSpeed[10];
	float g_flComboTypeChance[7];
	float g_flDamageBoost;
	float g_flDamageBoostReward[4];
	float g_flDamageResistance;
	float g_flDamageResistanceReward[4];
	float g_flHealPercent;
	float g_flHealPercentReward[4];
	float g_flHittableDamage;
	float g_flJumpHeight;
	float g_flJumpHeightReward[4];
	float g_flPreFallZ;
	float g_flPropsChance[9];
	float g_flPunchForce;
	float g_flPunchResistance;
	float g_flPunchResistanceReward[4];
	float g_flPunchThrow;
	float g_flRandomDuration;
	float g_flRandomInterval;
	float g_flRewardChance[4];
	float g_flRewardDuration[4];
	float g_flRewardPercentage[4];
	float g_flRewardTime[7];
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flShoveDamage;
	float g_flShoveDamageReward[4];
	float g_flShoveRate;
	float g_flShoveRateReward[4];
	float g_flSpeedBoost;
	float g_flSpeedBoostReward[4];
	float g_flStaggerTime;
	float g_flThrowInterval;
	float g_flTransformDelay;
	float g_flTransformDuration;
	float g_flVisualTime[5];

	int g_iAccessFlags;
	int g_iAmmoBoost;
	int g_iAmmoBoostReward[4];
	int g_iAmmoRegen;
	int g_iAmmoRegenReward[4];
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iAnnounceKill;
	int g_iArrivalMessage;
	int g_iArrivalSound;
	int g_iBaseHealth;
	int g_iBodyEffects;
	int g_iBossHealth[4];
	int g_iBossStageCount;
	int g_iBossStages;
	int g_iBossType[4];
	int g_iBulletImmunity;
	int g_iCheckAbilities;
	int g_iCleanKills;
	int g_iCleanKillsReward[4];
	int g_iCooldown;
	int g_iCrownColor[4];
	int g_iDeathDetails;
	int g_iDeathMessage;
	int g_iDeathRevert;
	int g_iDeathSound;
	int g_iDisplayHealth;
	int g_iDisplayHealthType;
	int g_iEffect[2];
	int g_iExplosiveImmunity;
	int g_iExtraHealth;
	int g_iFallPasses;
	int g_iFavoriteType;
	int g_iFireImmunity;
	int g_iFlame[2];
	int g_iFlameColor[4];
	int g_iFlashlight;
	int g_iFlashlightColor[4];
	int g_iGlowColor[3];
	int g_iGlowEnabled;
	int g_iGlowFlashing;
	int g_iGlowMaxRange;
	int g_iGlowMinRange;
	int g_iGlowType;
	int g_iHealthRegen;
	int g_iHealthRegenReward[4];
	int g_iHittableImmunity;
	int g_iHollowpointAmmo;
	int g_iHollowpointAmmoReward[4];
	int g_iImmunityFlags;
	int g_iInfiniteAmmo;
	int g_iInfiniteAmmoReward[4];
	int g_iKillMessage;
	int g_iLadyKiller;
	int g_iLadyKillerCount;
	int g_iLadyKillerReward[4];
	int g_iLastButtons;
	int g_iLifeLeech;
	int g_iLifeLeechReward[4];
	int g_iLight[9];
	int g_iLightColor[4];
	int g_iMaxClip[2];
	int g_iMeleeImmunity;
	int g_iMeleeRange;
	int g_iMeleeRangeReward[4];
	int g_iMinimumHumans;
	int g_iMultiplyHealth;
	int g_iNotify;
	int g_iOldTankType;
	int g_iOzTank[2];
	int g_iOzTankColor[4];
	int g_iParticleEffect;
	int g_iParticleEffectVisual[4];
	int g_iPrefsAccess;
	int g_iPrefsNotify[4];
	int g_iPropsAttached;
	int g_iPropaneTank;
	int g_iPropTankColor[4];
	int g_iRandomTank;
	int g_iRespawnLoadoutReward[4];
	int g_iReviveCount;
	int g_iReviveHealth;
	int g_iReviveHealthReward[4];
	int g_iRewardBots[4];
	int g_iRewardEffect[4];
	int g_iRewardEnabled[4];
	int g_iRewardNotify[4];
	int g_iRewardPriority[4];
	int g_iRewardStack[7];
	int g_iRewardTypes;
	int g_iRewardVisual[4];
	int g_iRewardVisuals;
	int g_iRock[20];
	int g_iRockColor[4];
	int g_iRockEffects;
	int g_iRockModel;
	int g_iScreenColorVisual[4];
	int g_iShovePenalty;
	int g_iShovePenaltyReward[4];
	int g_iSkinColor[4];
	int g_iSkipTaunt;
	int g_iSledgehammerRounds;
	int g_iSledgehammerRoundsReward[4];
	int g_iSpawnType;
	int g_iSpecialAmmo;
	int g_iSpecialAmmoReward[4];
	int g_iStackRewards[4];
	int g_iSweepFist;
	int g_iTankDamage[MAXPLAYERS + 1];
	int g_iTankHealth;
	int g_iTankModel;
	int g_iTankNote;
	int g_iTankType;
	int g_iTeammateLimit;
	int g_iThorns;
	int g_iThornsReward[4];
	int g_iTire[2];
	int g_iTireColor[4];
	int g_iTransformType[10];
	int g_iUsefulRewards[4];
	int g_iUserID;
	int g_iVocalizeArrival;
	int g_iVocalizeDeath;
	int g_iVomitImmunity;
	int g_iWeaponInfo[4];
	int g_iWeaponInfo2;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esTank
{
	char g_sBodyColorVisual[48];
	char g_sBodyColorVisual2[48];
	char g_sBodyColorVisual3[48];
	char g_sBodyColorVisual4[48];
	char g_sComboSet[320];
	char g_sFallVoicelineReward[64];
	char g_sFallVoicelineReward2[64];
	char g_sFallVoicelineReward3[64];
	char g_sFallVoicelineReward4[64];
	char g_sGlowColorVisual[36];
	char g_sGlowColorVisual2[36];
	char g_sGlowColorVisual3[36];
	char g_sGlowColorVisual4[36];
	char g_sHealthCharacters[4];
	char g_sItemReward[320];
	char g_sItemReward2[320];
	char g_sItemReward3[320];
	char g_sItemReward4[320];
	char g_sLoopingVoicelineVisual[64];
	char g_sLoopingVoicelineVisual2[64];
	char g_sLoopingVoicelineVisual3[64];
	char g_sLoopingVoicelineVisual4[64];
	char g_sScreenColorVisual[48];
	char g_sScreenColorVisual2[48];
	char g_sScreenColorVisual3[48];
	char g_sScreenColorVisual4[48];
	char g_sTankName[33];

	float g_flActionDurationReward[4];
	float g_flAttackBoostReward[4];
	float g_flAttackInterval;
	float g_flBurnDuration;
	float g_flBurntSkin;
	float g_flClawDamage;
	float g_flComboChance[10];
	float g_flComboDamage[10];
	float g_flComboDeathChance[10];
	float g_flComboDeathRange[10];
	float g_flComboDelay[10];
	float g_flComboDuration[10];
	float g_flComboInterval[10];
	float g_flComboMaxRadius[10];
	float g_flComboMinRadius[10];
	float g_flComboRange[10];
	float g_flComboRangeChance[10];
	float g_flComboRockChance[10];
	float g_flComboSpeed[10];
	float g_flComboTypeChance[7];
	float g_flDamageBoostReward[4];
	float g_flDamageResistanceReward[4];
	float g_flHealPercentReward[4];
	float g_flHittableDamage;
	float g_flJumpHeightReward[4];
	float g_flOpenAreasOnly;
	float g_flPropsChance[9];
	float g_flPunchForce;
	float g_flPunchResistanceReward[4];
	float g_flPunchThrow;
	float g_flRandomDuration;
	float g_flRandomInterval;
	float g_flRewardChance[4];
	float g_flRewardDuration[4];
	float g_flRewardPercentage[4];
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flShoveDamageReward[4];
	float g_flShoveRateReward[4];
	float g_flSpeedBoostReward[4];
	float g_flTankChance;
	float g_flThrowInterval;
	float g_flTransformDelay;
	float g_flTransformDuration;

	int g_iAbilityCount;
	int g_iAccessFlags;
	int g_iAmmoBoostReward[4];
	int g_iAmmoRegenReward[4];
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iAnnounceKill;
	int g_iArrivalMessage;
	int g_iArrivalSound;
	int g_iBaseHealth;
	int g_iBodyEffects;
	int g_iBossHealth[4];
	int g_iBossStages;
	int g_iBossType[4];
	int g_iBulletImmunity;
	int g_iCheckAbilities;
	int g_iCleanKillsReward[4];
	int g_iCrownColor[4];
	int g_iDeathDetails;
	int g_iDeathMessage;
	int g_iDeathRevert;
	int g_iDeathSound;
	int g_iDisplayHealth;
	int g_iDisplayHealthType;
	int g_iExplosiveImmunity;
	int g_iExtraHealth;
	int g_iFinaleTank;
	int g_iFireImmunity;
	int g_iFlameColor[4];
	int g_iFlashlightColor[4];
	int g_iGameType;
	int g_iGlowColor[3];
	int g_iGlowEnabled;
	int g_iGlowFlashing;
	int g_iGlowMaxRange;
	int g_iGlowMinRange;
	int g_iGlowType;
	int g_iHealthRegenReward[4];
	int g_iHittableImmunity;
	int g_iHollowpointAmmoReward[4];
	int g_iHumanSupport;
	int g_iImmunityFlags;
	int g_iInfiniteAmmoReward[4];
	int g_iKillMessage;
	int g_iLadyKillerReward[4];
	int g_iLifeLeechReward[4];
	int g_iLightColor[4];
	int g_iMeleeImmunity;
	int g_iMeleeRangeReward[4];
	int g_iMenuEnabled;
	int g_iMinimumHumans;
	int g_iMultiplyHealth;
	int g_iOzTankColor[4];
	int g_iParticleEffectVisual[4];
	int g_iPrefsNotify[4];
	int g_iPropsAttached;
	int g_iPropTankColor[4];
	int g_iRandomTank;
	int g_iRequiresHumans;
	int g_iRespawnLoadoutReward[4];
	int g_iReviveHealthReward[4];
	int g_iRewardBots[4];
	int g_iRewardEffect[4];
	int g_iRewardEnabled[4];
	int g_iRewardNotify[4];
	int g_iRewardPriority[4];
	int g_iRewardVisual[4];
	int g_iRockColor[4];
	int g_iRockEffects;
	int g_iRockModel;
	int g_iShovePenaltyReward[4];
	int g_iSkinColor[4];
	int g_iSkipTaunt;
	int g_iSledgehammerRoundsReward[4];
	int g_iSpawnEnabled;
	int g_iSpawnType;
	int g_iSpecialAmmoReward[4];
	int g_iStackRewards[4];
	int g_iSweepFist;
	int g_iTankEnabled;
	int g_iTankModel;
	int g_iTankNote;
	int g_iTeammateLimit;
	int g_iThornsReward[4];
	int g_iTireColor[4];
	int g_iTransformType[10];
	int g_iTypeLimit;
	int g_iUsefulRewards[4];
	int g_iVocalizeArrival;
	int g_iVocalizeDeath;
	int g_iVomitImmunity;
}

esTank g_esTank[MT_MAXTYPES + 1];

enum struct esCache
{
	char g_sBodyColorVisual[48];
	char g_sBodyColorVisual2[48];
	char g_sBodyColorVisual3[48];
	char g_sBodyColorVisual4[48];
	char g_sComboSet[320];
	char g_sFallVoicelineReward[64];
	char g_sFallVoicelineReward2[64];
	char g_sFallVoicelineReward3[64];
	char g_sFallVoicelineReward4[64];
	char g_sGlowColorVisual[36];
	char g_sGlowColorVisual2[36];
	char g_sGlowColorVisual3[36];
	char g_sGlowColorVisual4[36];
	char g_sHealthCharacters[4];
	char g_sItemReward[320];
	char g_sItemReward2[320];
	char g_sItemReward3[320];
	char g_sItemReward4[320];
	char g_sLoopingVoicelineVisual[64];
	char g_sLoopingVoicelineVisual2[64];
	char g_sLoopingVoicelineVisual3[64];
	char g_sLoopingVoicelineVisual4[64];
	char g_sScreenColorVisual[48];
	char g_sScreenColorVisual2[48];
	char g_sScreenColorVisual3[48];
	char g_sScreenColorVisual4[48];
	char g_sTankName[33];

	float g_flActionDurationReward[4];
	float g_flAttackBoostReward[4];
	float g_flAttackInterval;
	float g_flBurnDuration;
	float g_flBurntSkin;
	float g_flClawDamage;
	float g_flComboChance[10];
	float g_flComboDamage[10];
	float g_flComboDeathChance[10];
	float g_flComboDeathRange[10];
	float g_flComboDelay[10];
	float g_flComboDuration[10];
	float g_flComboInterval[10];
	float g_flComboMaxRadius[10];
	float g_flComboMinRadius[10];
	float g_flComboRange[10];
	float g_flComboRangeChance[10];
	float g_flComboRockChance[10];
	float g_flComboSpeed[10];
	float g_flComboTypeChance[7];
	float g_flDamageBoostReward[4];
	float g_flDamageResistanceReward[4];
	float g_flHealPercentReward[4];
	float g_flHittableDamage;
	float g_flJumpHeightReward[4];
	float g_flPropsChance[9];
	float g_flPunchForce;
	float g_flPunchResistanceReward[4];
	float g_flPunchThrow;
	float g_flRandomDuration;
	float g_flRandomInterval;
	float g_flRewardChance[4];
	float g_flRewardDuration[4];
	float g_flRewardPercentage[4];
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flShoveDamageReward[4];
	float g_flShoveRateReward[4];
	float g_flSpeedBoostReward[4];
	float g_flThrowInterval;
	float g_flTransformDelay;
	float g_flTransformDuration;

	int g_iAmmoBoostReward[4];
	int g_iAmmoRegenReward[4];
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iAnnounceKill;
	int g_iArrivalMessage;
	int g_iArrivalSound;
	int g_iBaseHealth;
	int g_iBodyEffects;
	int g_iBossHealth[4];
	int g_iBossStages;
	int g_iBossType[4];
	int g_iBulletImmunity;
	int g_iCheckAbilities;
	int g_iCleanKillsReward[4];
	int g_iCrownColor[4];
	int g_iDeathDetails;
	int g_iDeathMessage;
	int g_iDeathRevert;
	int g_iDeathSound;
	int g_iDisplayHealth;
	int g_iDisplayHealthType;
	int g_iExplosiveImmunity;
	int g_iExtraHealth;
	int g_iFireImmunity;
	int g_iFlameColor[4];
	int g_iFlashlightColor[4];
	int g_iGlowColor[3];
	int g_iGlowEnabled;
	int g_iGlowFlashing;
	int g_iGlowMaxRange;
	int g_iGlowMinRange;
	int g_iGlowType;
	int g_iHealthRegenReward[4];
	int g_iHittableImmunity;
	int g_iHollowpointAmmoReward[4];
	int g_iInfiniteAmmoReward[4];
	int g_iKillMessage;
	int g_iLadyKillerReward[4];
	int g_iLifeLeechReward[4];
	int g_iLightColor[4];
	int g_iMeleeImmunity;
	int g_iMeleeRangeReward[4];
	int g_iMinimumHumans;
	int g_iMultiplyHealth;
	int g_iOzTankColor[4];
	int g_iParticleEffectVisual[4];
	int g_iPrefsNotify[4];
	int g_iPropsAttached;
	int g_iPropTankColor[4];
	int g_iRandomTank;
	int g_iRespawnLoadoutReward[4];
	int g_iReviveHealthReward[4];
	int g_iRewardBots[4];
	int g_iRewardEffect[4];
	int g_iRewardEnabled[4];
	int g_iRewardNotify[4];
	int g_iRewardPriority[4];
	int g_iRewardVisual[4];
	int g_iRockColor[4];
	int g_iRockEffects;
	int g_iRockModel;
	int g_iShovePenaltyReward[4];
	int g_iSkinColor[4];
	int g_iSkipTaunt;
	int g_iSledgehammerRoundsReward[4];
	int g_iSpawnEnabled;
	int g_iSpawnType;
	int g_iSpecialAmmoReward[4];
	int g_iStackRewards[4];
	int g_iSweepFist;
	int g_iTankEnabled;
	int g_iTankModel;
	int g_iTankNote;
	int g_iTeammateLimit;
	int g_iThornsReward[4];
	int g_iTireColor[4];
	int g_iTransformType[10];
	int g_iUsefulRewards[4];
	int g_iVocalizeArrival;
	int g_iVocalizeDeath;
	int g_iVomitImmunity;
}

esCache g_esCache[MAXPLAYERS + 1];

Address g_adPatchAddress[MT_PATCH_LIMIT];

bool g_bPatchInstalled[MT_PATCH_LIMIT], g_bPermanentPatch[MT_PATCH_LIMIT];

char g_sPatchName[MT_PATCH_LIMIT][64];

int g_iBossBeamSprite = -1, g_iBossHaloSprite = -1, g_iOriginalBytes[MT_PATCH_LIMIT][MT_PATCH_MAXLEN], g_iPatchBytes[MT_PATCH_LIMIT][MT_PATCH_MAXLEN], g_iPatchCount = 0, g_iPatchLength[MT_PATCH_LIMIT], g_iPatchOffset[MT_PATCH_LIMIT];

public any aNative_CanTypeSpawn(Handle plugin, int numParams)
{
	int iType = iClamp(GetNativeCell(1), 1, MT_MAXTYPES);
	return (g_esGeneral.g_iSpawnEnabled == 1 || g_esTank[iType].g_iSpawnEnabled == 1) && bCanTypeSpawn(iType) && bIsRightGame(iType);
}

public any aNative_DetonateTankRock(Handle plugin, int numParams)
{
	int iRock = GetNativeCell(1);
	if (bIsValidEntity(iRock))
	{
		RequestFrame(vDetonateRockFrame, EntIndexToEntRef(iRock));
	}
}

public any aNative_DoesSurvivorHaveRewardType(Handle plugin, int numParams)
{
	int iSurvivor = GetNativeCell(1), iType = GetNativeCell(2);
	if (bIsSurvivor(iSurvivor) && iType > 0)
	{
		if (iType & MT_REWARD_HEALTH)
		{
			return bIsDeveloper(iSurvivor, 6) || bIsDeveloper(iSurvivor, 7) || (g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
		else if (iType & MT_REWARD_SPEEDBOOST)
		{
			return bIsDeveloper(iSurvivor, 5) || (g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
		else if (iType & MT_REWARD_DAMAGEBOOST)
		{
			return bIsDeveloper(iSurvivor, 4) || (g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
		else if (iType & MT_REWARD_ATTACKBOOST)
		{
			return bIsDeveloper(iSurvivor, 6) || (g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
		else if (iType & MT_REWARD_AMMO)
		{
			return bIsDeveloper(iSurvivor, 4) || bIsDeveloper(iSurvivor, 6) || (g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
		else if (iType & MT_REWARD_ITEM)
		{
			return !!(g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
		else if (iType & MT_REWARD_GODMODE)
		{
			return bIsDeveloper(iSurvivor, 11) || (g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
		else if (iType & MT_REWARD_REFILL)
		{
			return !!(g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
		else if (iType & MT_REWARD_RESPAWN)
		{
			return bIsDeveloper(iSurvivor, 10) || (g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
		else if (iType & MT_REWARD_INFAMMO)
		{
			return bIsDeveloper(iSurvivor, 7) || (g_esPlayer[iSurvivor].g_iRewardTypes & iType);
		}
	}

	return false;
}

public any aNative_DoesTypeRequireHumans(Handle plugin, int numParams)
{
	int iType = iClamp(GetNativeCell(1), 1, MT_MAXTYPES);
	return bAreHumansRequired(iType);
}

public any aNative_GetAccessFlags(Handle plugin, int numParams)
{
	int iMode = iClamp(GetNativeCell(1), 1, 4), iType = iClamp(GetNativeCell(2), 1, MT_MAXTYPES), iAdmin = GetNativeCell(3);

	switch (iMode)
	{
		case 1: return g_esGeneral.g_iAccessFlags;
		case 2: return g_esTank[iType].g_iAccessFlags;
		case 3: return bIsValidClient(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esPlayer[iAdmin].g_iAccessFlags : 0;
		case 4: return bIsValidClient(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esAdmin[iType].g_iAccessFlags[iAdmin] : 0;
	}

	return 0;
}

public any aNative_GetCombinationSetting(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = iClamp(GetNativeCell(2), 1, 13), iPos = iClamp(GetNativeCell(3), 0, 9);
	if (bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		switch (iType)
		{
			case 1: return g_esCache[iTank].g_flComboChance[iPos];
			case 2: return g_esCache[iTank].g_flComboDamage[iPos];
			case 3: return g_esCache[iTank].g_flComboDelay[iPos];
			case 4: return g_esCache[iTank].g_flComboDuration[iPos];
			case 5: return g_esCache[iTank].g_flComboInterval[iPos];
			case 6: return g_esCache[iTank].g_flComboMinRadius[iPos];
			case 7: return g_esCache[iTank].g_flComboMaxRadius[iPos];
			case 8: return g_esCache[iTank].g_flComboRange[iPos];
			case 9: return g_esCache[iTank].g_flComboRangeChance[iPos];
			case 10: return g_esCache[iTank].g_flComboDeathChance[iPos];
			case 11: return g_esCache[iTank].g_flComboDeathRange[iPos];
			case 12: return g_esCache[iTank].g_flComboRockChance[iPos];
			case 13: return g_esCache[iTank].g_flComboSpeed[iPos];
		}
	}

	return 0.0;
}

public any aNative_GetCurrentFinaleWave(Handle plugin, int numParams)
{
	return g_esGeneral.g_iTankWave;
}

public any aNative_GetGlowRange(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	bool bMode = GetNativeCell(2);
	if (bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		switch (bMode)
		{
			case true: return g_esCache[iTank].g_iGlowMaxRange;
			case false: return g_esCache[iTank].g_iGlowMinRange;
		}
	}

	return 0;
}

public any aNative_GetGlowType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) ? g_esCache[iTank].g_iGlowType : 0;
}

public any aNative_GetImmunityFlags(Handle plugin, int numParams)
{
	int iMode = iClamp(GetNativeCell(1), 1, 4), iType = iClamp(GetNativeCell(2), 1, MT_MAXTYPES), iAdmin = GetNativeCell(3);

	switch (iMode)
	{
		case 1: return g_esGeneral.g_iImmunityFlags;
		case 2: return g_esTank[iType].g_iImmunityFlags;
		case 3: return bIsValidClient(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esPlayer[iAdmin].g_iImmunityFlags : 0;
		case 4: return bIsValidClient(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esAdmin[iType].g_iImmunityFlags[iAdmin] : 0;
	}

	return 0;
}

public any aNative_GetMaxType(Handle plugin, int numParams)
{
	return g_esGeneral.g_iMaxType;
}

public any aNative_GetMinType(Handle plugin, int numParams)
{
	return g_esGeneral.g_iMinType;
}

public any aNative_GetPropColors(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = iClamp(GetNativeCell(2), 1, 8);
	if (bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		int iColor[4];
		for (int iPos = 0; iPos < sizeof(iColor); iPos++)
		{
			switch (iType)
			{
				case 1: iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iLightColor[iPos]);
				case 2: iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iOzTankColor[iPos]);
				case 3: iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iFlameColor[iPos]);
				case 4: iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iRockColor[iPos]);
				case 5: iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iTireColor[iPos]);
				case 6: iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iPropTankColor[iPos]);
				case 7: iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iFlashlightColor[iPos]);
				case 8: iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iCrownColor[iPos]);
			}

			SetNativeCellRef(iPos + 3, iColor[iPos]);
		}
	}
}

public any aNative_GetRunSpeed(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank))
	{
		return (g_esCache[iTank].g_flRunSpeed > 0.0) ? g_esCache[iTank].g_flRunSpeed : 1.0;
	}

	return 0.0;
}

public any aNative_GetScaledDamage(Handle plugin, int numParams)
{
	return flGetScaledDamage(GetNativeCell(1));
}

public any aNative_GetSpawnType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return (bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && !bIsTank(iTank, MT_CHECK_FAKECLIENT)) ? g_esCache[iTank].g_iSpawnType : 0;
}

public any aNative_GetTankColors(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = iClamp(GetNativeCell(2), 1, 2);
	if (bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		int iColor[4];
		for (int iPos = 0; iPos < sizeof(iColor); iPos++)
		{
			switch (iType)
			{
				case 1: iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iSkinColor[iPos]);
				case 2:
				{
					if (iPos < sizeof(esCache::g_iGlowColor))
					{
						iColor[iPos] = iGetRandomColor(g_esCache[iTank].g_iGlowColor[iPos]);
					}
				}
			}

			SetNativeCellRef(iPos + 3, iColor[iPos]);
		}
	}
}

public any aNative_GetTankName(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), iTank);
		SetNativeString(2, sTankName, sizeof(sTankName));
	}
}

public any aNative_GetTankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) ? g_esPlayer[iTank].g_iTankType : 0;
}

public any aNative_HasAdminAccess(Handle plugin, int numParams)
{
	int iAdmin = GetNativeCell(1);
	return bIsTankSupported(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME) && bHasCoreAdminAccess(iAdmin);
}

public any aNative_HasChanceToSpawn(Handle plugin, int numParams)
{
	int iType = iClamp(GetNativeCell(1), 1, MT_MAXTYPES);
	return GetRandomFloat(0.1, 100.0) <= g_esTank[iType].g_flTankChance;
}

public any aNative_HideEntity(Handle plugin, int numParams)
{
	int iEntity = GetNativeCell(1);
	bool bMode = GetNativeCell(2);
	if (bIsValidEntity(iEntity))
	{
		switch (bMode)
		{
			case true: SDKHook(iEntity, SDKHook_SetTransmit, OnPropSetTransmit);
			case false: SDKUnhook(iEntity, SDKHook_SetTransmit, OnPropSetTransmit);
		}
	}
}

public any aNative_IsAdminImmune(Handle plugin, int numParams)
{
	int iSurvivor = GetNativeCell(1), iTank = GetNativeCell(2);
	return bIsHumanSurvivor(iSurvivor) && bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && bIsCoreAdminImmune(iSurvivor, iTank);
}

public any aNative_IsCorePluginEnabled(Handle plugin, int numParams)
{
	return g_esGeneral.g_bPluginEnabled;
}

public any aNative_IsCustomTankSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && bIsCustomTankSupported(iTank);
}

public any aNative_IsFinaleType(Handle plugin, int numParams)
{
	int iType = iClamp(GetNativeCell(1), 1, MT_MAXTYPES);
	return g_esTank[iType].g_iFinaleTank == 1;
}

public any aNative_IsGlowEnabled(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esCache[iTank].g_iGlowEnabled == 1;
}

public any aNative_IsGlowFlashing(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esCache[iTank].g_iGlowFlashing == 1;
}

public any aNative_IsNonFinaleType(Handle plugin, int numParams)
{
	int iType = iClamp(GetNativeCell(1), 1, MT_MAXTYPES);
	return g_esTank[iType].g_iFinaleTank == 2;
}

public any aNative_IsTankIdle(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = iClamp(GetNativeCell(2), 0, 2);
	return bIsTank(iTank) && bIsTankIdle(iTank, iType);
}

public any aNative_IsTankSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && bIsTankSupported(iTank, GetNativeCell(2));
}

public any aNative_IsTypeEnabled(Handle plugin, int numParams)
{
	int iType = iClamp(GetNativeCell(1), 1, MT_MAXTYPES);
	return bIsTankEnabled(iType) && bIsTypeAvailable(iType);
}

public any aNative_LogMessage(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	if (g_esGeneral.g_iLogMessages > 0 && iType > 0 && (g_esGeneral.g_iLogMessages & iType))
	{
		char sBuffer[1024];
		int iSize = 0, iResult = FormatNativeString(0, 2, 3, sizeof(sBuffer), iSize, sBuffer);
		if (iResult == SP_ERROR_NONE)
		{
			vLogMessage(iType, _, sBuffer);
		}
	}
}

public any aNative_RespawnSurvivor(Handle plugin, int numParams)
{
	int iSurvivor = GetNativeCell(1);
	if (bIsSurvivor(iSurvivor, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esGeneral.g_hSDKRoundRespawn != null)
	{
		vRespawnSurvivor(iSurvivor);
	}
}

public any aNative_SetTankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = iClamp(GetNativeCell(2), 1, MT_MAXTYPES);
	bool bMode = GetNativeCell(3);
	if (bIsTank(iTank))
	{
		switch (bMode)
		{
			case true:
			{
				vSetColor(iTank, iType, _, (g_esPlayer[iTank].g_iTankType == iType ? true : false));
				vTankSpawn(iTank, 5);
			}
			case false:
			{
				vResetTank(iTank);
				vChangeTypeForward(iTank, g_esPlayer[iTank].g_iTankType, iType, (g_esPlayer[iTank].g_iTankType == iType ? true : false));

				g_esPlayer[iTank].g_iOldTankType = g_esPlayer[iTank].g_iTankType;
				g_esPlayer[iTank].g_iTankType = iType;

				vCacheSettings(iTank);
			}
		}
	}
}

public any aNative_ShoveBySurvivor(Handle plugin, int numParams)
{
	int iSpecial = GetNativeCell(1), iSurvivor = GetNativeCell(2);
	float flDirection[3];
	GetNativeArray(3, flDirection, sizeof(flDirection));
	if (bIsInfected(iSpecial) && bIsSurvivor(iSurvivor) && g_esGeneral.g_hSDKShovedBySurvivor != null)
	{
		SDKCall(g_esGeneral.g_hSDKShovedBySurvivor, iSpecial, iSurvivor, flDirection);
	}
}

public any aNative_SpawnTank(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = iClamp(GetNativeCell(2), 1, MT_MAXTYPES);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		vQueueTank(iTank, iType, _, false);
	}
}

public any aNative_TankMaxHealth(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iMode = iClamp(GetNativeCell(2), 1, 3), iNewHealth = GetNativeCell(3);
	if (bIsTank(iTank))
	{
		switch (iMode)
		{
			case 1: return g_esPlayer[iTank].g_iTankHealth;
			case 2: return GetEntProp(iTank, Prop_Data, "m_iMaxHealth");
			case 3: g_esPlayer[iTank].g_iTankHealth = iNewHealth;
			case 4:
			{
				SetEntProp(iTank, Prop_Data, "m_iMaxHealth", iNewHealth);

				g_esPlayer[iTank].g_iTankHealth = GetEntProp(iTank, Prop_Data, "m_iMaxHealth");
			}
		}
	}

	return 0;
}

public any aNative_UnvomitPlayer(Handle plugin, int numParams)
{
	int iPlayer = GetNativeCell(1);
	if (bIsValidClient(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && GetClientTeam(iPlayer) > 1 && g_esPlayer[iPlayer].g_bVomited)
	{
		vUnvomitPlayer(iPlayer);
	}
}

public any aNative_VomitPlayer(Handle plugin, int numParams)
{
	int iPlayer = GetNativeCell(1), iBoomer = GetNativeCell(2);
	if (bIsValidClient(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && GetClientTeam(iPlayer) > 1 && bIsValidClient(iBoomer, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
#if defined _l4dh_included
		switch (g_esGeneral.g_bLeft4DHooksInstalled || g_esGeneral.g_hSDKVomitedUpon == null)
		{
			case true: L4D_CTerrorPlayer_OnVomitedUpon(iPlayer, iBoomer);
			case false: SDKCall(g_esGeneral.g_hSDKVomitedUpon, iPlayer, iBoomer, true);
		}
#else
		if (g_esGeneral.g_hSDKVomitedUpon != null)
		{
			SDKCall(g_esGeneral.g_hSDKVomitedUpon, iPlayer, iBoomer, true);
		}
#endif
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "clientprefs"))
	{
		g_esGeneral.g_bClientPrefsInstalled = true;
	}
	else if (StrEqual(name, "left4dhooks"))
	{
		g_esGeneral.g_bLeft4DHooksInstalled = true;
	}
	else if (StrEqual(name, "mt_clone"))
	{
		g_esGeneral.g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "clientprefs"))
	{
		g_esGeneral.g_bClientPrefsInstalled = false;
	}
	else if (StrEqual(name, "left4dhooks"))
	{
		g_esGeneral.g_bLeft4DHooksInstalled = false;
	}
	else if (StrEqual(name, "mt_clone"))
	{
		g_esGeneral.g_bCloneInstalled = false;
	}
}

public void OnAllPluginsLoaded()
{
	g_esGeneral.g_bClientPrefsInstalled = LibraryExists("clientprefs");
	g_esGeneral.g_bCloneInstalled = LibraryExists("mt_clone");
	g_esGeneral.g_bLeft4DHooksInstalled = LibraryExists("left4dhooks");
}

public void OnPluginStart()
{
	g_esGeneral.g_gfAbilityActivatedForward = new GlobalForward("MT_OnAbilityActivated", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfAbilityCheckForward = new GlobalForward("MT_OnAbilityCheck", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_esGeneral.g_gfButtonPressedForward = new GlobalForward("MT_OnButtonPressed", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfButtonReleasedForward = new GlobalForward("MT_OnButtonReleased", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfChangeTypeForward = new GlobalForward("MT_OnChangeType", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_esGeneral.g_gfCombineAbilitiesForward = new GlobalForward("MT_OnCombineAbilities", ET_Ignore, Param_Cell, Param_Cell, Param_Float, Param_String, Param_Cell, Param_Cell, Param_String);
	g_esGeneral.g_gfConfigsLoadForward = new GlobalForward("MT_OnConfigsLoad", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfConfigsLoadedForward = new GlobalForward("MT_OnConfigsLoaded", ET_Ignore, Param_String, Param_String, Param_String, Param_Cell, Param_Cell, Param_Cell);
	g_esGeneral.g_gfCopyStatsForward = new GlobalForward("MT_OnCopyStats", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfDisplayMenuForward = new GlobalForward("MT_OnDisplayMenu", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfEventFiredForward = new GlobalForward("MT_OnEventFired", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	g_esGeneral.g_gfFatalFallingForward = new GlobalForward("MT_OnFatalFalling", ET_Event, Param_Cell);
	g_esGeneral.g_gfHookEventForward = new GlobalForward("MT_OnHookEvent", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfLogMessageForward = new GlobalForward("MT_OnLogMessage", ET_Event, Param_Cell, Param_String);
	g_esGeneral.g_gfMenuItemDisplayedForward = new GlobalForward("MT_OnMenuItemDisplayed", ET_Ignore, Param_Cell, Param_String, Param_String, Param_Cell);
	g_esGeneral.g_gfMenuItemSelectedForward = new GlobalForward("MT_OnMenuItemSelected", ET_Ignore, Param_Cell, Param_String);
	g_esGeneral.g_gfPlayerEventKilledForward = new GlobalForward("MT_OnPlayerEventKilled", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfPlayerHitByVomitJarForward = new GlobalForward("MT_OnPlayerHitByVomitJar", ET_Event, Param_Cell, Param_Cell);
	g_esGeneral.g_gfPlayerShovedBySurvivorForward = new GlobalForward("MT_OnPlayerShovedBySurvivor", ET_Event, Param_Cell, Param_Cell, Param_Array);
	g_esGeneral.g_gfPluginCheckForward = new GlobalForward("MT_OnPluginCheck", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfPluginEndForward = new GlobalForward("MT_OnPluginEnd", ET_Ignore);
	g_esGeneral.g_gfPostTankSpawnForward = new GlobalForward("MT_OnPostTankSpawn", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfResetTimersForward = new GlobalForward("MT_OnResetTimers", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfRewardSurvivorForward = new GlobalForward("MT_OnRewardSurvivor", ET_Event, Param_Cell, Param_Cell, Param_CellByRef, Param_Cell, Param_FloatByRef, Param_Cell);
	g_esGeneral.g_gfRockBreakForward = new GlobalForward("MT_OnRockBreak", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfRockThrowForward = new GlobalForward("MT_OnRockThrow", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfSettingsCachedForward = new GlobalForward("MT_OnSettingsCached", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_esGeneral.g_gfTypeChosenForward = new GlobalForward("MT_OnTypeChosen", ET_Event, Param_CellByRef, Param_Cell);

	for (int iDeveloper = 1; iDeveloper <= MaxClients; iDeveloper++)
	{
		vDeveloperSettings(iDeveloper);
	}

	vMultiTargetFilters(true);

	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	AddCommandListener(cmdMTCommandListener, "give");
	AddCommandListener(cmdMTCommandListener2, "go_away_from_keyboard");
	AddCommandListener(cmdMTCommandListener2, "vocalize");
	AddCommandListener(cmdMTCommandListener3);

	RegAdminCmd("sm_mt_config", cmdMTConfig, ADMFLAG_ROOT, "View a section of the config file.");
	RegConsoleCmd("sm_mt_config2", cmdMTConfig2, "View a section of the config file.");
	RegConsoleCmd("sm_mt_dev", cmdMTDev, "Used only by and for the developer.");
	RegConsoleCmd("sm_mt_info", cmdMTInfo, "View information about Mutant Tanks.");
	RegAdminCmd("sm_mt_list", cmdMTList, ADMFLAG_ROOT, "View a list of installed abilities.");
	RegConsoleCmd("sm_mt_list2", cmdMTList2, "View a list of installed abilities.");
	RegConsoleCmd("sm_mt_prefs", cmdMTPrefs, "Set your Mutant Tanks preferences.");
	RegAdminCmd("sm_mt_reload", cmdMTReload, ADMFLAG_ROOT, "Reload the config file.");
	RegAdminCmd("sm_mt_version", cmdMTVersion, ADMFLAG_ROOT, "Find out the current version of Mutant Tanks.");
	RegConsoleCmd("sm_mt_version2", cmdMTVersion2, "Find out the current version of Mutant Tanks.");
	RegAdminCmd("sm_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Mutant Tank.");
	RegAdminCmd("sm_mt_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Mutant Tank.");
	RegConsoleCmd("sm_tank2", cmdTank2, "Spawn a Mutant Tank.");
	RegConsoleCmd("sm_mt_tank2", cmdTank2, "Spawn a Mutant Tank.");
	RegConsoleCmd("sm_mutanttank", cmdMutantTank, "Choose a Mutant Tank.");

	g_esGeneral.g_cvMTDisabledGameModes = CreateConVar("mt_disabledgamemodes", "", "Disable Mutant Tanks in these game modes.\nSeparate by commas.\nEmpty: None\nNot empty: Disabled only in these game modes.", FCVAR_NOTIFY);
	g_esGeneral.g_cvMTEnabledGameModes = CreateConVar("mt_enabledgamemodes", "", "Enable Mutant Tanks in these game modes.\nSeparate by commas.\nEmpty: All\nNot empty: Enabled only in these game modes.", FCVAR_NOTIFY);
	g_esGeneral.g_cvMTGameModeTypes = CreateConVar("mt_gamemodetypes", "0", "Enable Mutant Tanks in these game mode types.\n0 OR 15: All game mode types.\n1: Co-Op modes only.\n2: Versus modes only.\n4: Survival modes only.\n8: Scavenge modes only. (Only available in Left 4 Dead 2.)", FCVAR_NOTIFY, true, 0.0, true, 15.0);
	g_esGeneral.g_cvMTListenSupport = CreateConVar("mt_listensupport", (g_bDedicated ? "0" : "1"), "Enable Mutant Tanks on listen servers.\n0: OFF\n1: ON", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_esGeneral.g_cvMTPluginEnabled = CreateConVar("mt_pluginenabled", "1", "Enable Mutant Tanks.\n0: OFF\n1: ON", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar("mt_pluginversion", MT_VERSION, "Mutant Tanks Version", FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_SPONLY);
	AutoExecConfig(true, "mutant_tanks");

	g_esGeneral.g_cvMTAssaultRifleAmmo = FindConVar("ammo_assaultrifle_max");
	g_esGeneral.g_cvMTAutoShotgunAmmo = g_bSecondGame ? FindConVar("ammo_autoshotgun_max") : FindConVar("ammo_buckshot_max");
	g_esGeneral.g_cvMTDifficulty = FindConVar("z_difficulty");
	g_esGeneral.g_cvMTFirstAidHealPercent = FindConVar("first_aid_heal_percent");
	g_esGeneral.g_cvMTFirstAidKitUseDuration = FindConVar("first_aid_kit_use_duration");
	g_esGeneral.g_cvMTGrenadeLauncherAmmo = FindConVar("ammo_grenadelauncher_max");
	g_esGeneral.g_cvMTHuntingRifleAmmo = FindConVar("ammo_huntingrifle_max");
	g_esGeneral.g_cvMTGameMode = FindConVar("mp_gamemode");
	g_esGeneral.g_cvMTGameTypes = FindConVar("sv_gametypes");
	g_esGeneral.g_cvMTPainPillsDecayRate = FindConVar("pain_pills_decay_rate");
	g_esGeneral.g_cvMTShotgunAmmo = g_bSecondGame ? FindConVar("ammo_shotgun_max") : FindConVar("ammo_buckshot_max");
	g_esGeneral.g_cvMTSMGAmmo = FindConVar("ammo_smg_max");
	g_esGeneral.g_cvMTSniperRifleAmmo = FindConVar("ammo_sniperrifle_max");
	g_esGeneral.g_cvMTSurvivorReviveDuration = FindConVar("survivor_revive_duration");
	g_esGeneral.g_cvMTSurvivorReviveHealth = FindConVar("survivor_revive_health");
	g_esGeneral.g_cvMTGunSwingInterval = FindConVar("z_gun_swing_interval");

	if (g_bSecondGame)
	{
		g_esGeneral.g_cvMTAmmoPackUseDuration = FindConVar("ammo_pack_use_duration");
		g_esGeneral.g_cvMTColaBottlesUseDuration = FindConVar("cola_bottles_use_duration");
		g_esGeneral.g_cvMTDefibrillatorUseDuration = FindConVar("defibrillator_use_duration");
		g_esGeneral.g_cvMTGasCanUseDuration = FindConVar("gas_can_use_duration");
		g_esGeneral.g_cvMTMeleeRange = FindConVar("melee_range");
		g_esGeneral.g_cvMTPhysicsPushScale = FindConVar("phys_pushscale");
		g_esGeneral.g_cvMTUpgradePackUseDuration = FindConVar("upgrade_pack_use_duration");
	}

	g_esGeneral.g_cvMTDisabledGameModes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTEnabledGameModes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTGameModeTypes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTPluginEnabled.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTDifficulty.AddChangeHook(vMTGameDifficultyCvar);
#if defined _clientprefs_included
	g_esGeneral.g_ckMTPrefs = new Cookie("MTPrefs", "Mutant Tanks Preferences", CookieAccess_Private);
#endif
	char sDate[32];
	FormatTime(sDate, sizeof(sDate), "%Y-%m-%d", GetTime());
	BuildPath(Path_SM, g_esGeneral.g_sLogFile, sizeof(esGeneral::g_sLogFile), "logs/mutant_tanks_%s.log", sDate);

	char sSMPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/");
	CreateDirectory(sSMPath, 511);
	FormatEx(g_esGeneral.g_sSavePath, sizeof(esGeneral::g_sSavePath), "%smutant_tanks.cfg", sSMPath);

	switch (FileExists(g_esGeneral.g_sSavePath, true))
	{
		case true:
		{
			vLoadConfigs(g_esGeneral.g_sSavePath, 1);
			g_esGeneral.g_iFileTimeOld[0] = GetFileTime(g_esGeneral.g_sSavePath, FileTime_LastChange);
		}
		case false: SetFailState("Unable to load the \"%s\" config file.", g_esGeneral.g_sSavePath);
	}

	HookEvent("round_start", vEventHandler);
	HookEvent("round_end", vEventHandler);

	HookUserMessage(GetUserMessageId("SayText2"), umNameChange, true);

	GameData gdMutantTanks = new GameData("mutant_tanks");

	switch (gdMutantTanks == null)
	{
		case true: SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");
		case false:
		{
			g_esGeneral.g_bLinux = gdMutantTanks.GetOffset("OS") == 1;

			if (g_bSecondGame)
			{
				StartPrepSDKCall(SDKCall_Entity);
				if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CBaseBackpackItem::GetUseAction"))
				{
					LogError("%s Failed to load offset: CBaseBackpackItem::GetUseAction", MT_TAG);
				}

				PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
				g_esGeneral.g_hSDKGetUseAction = EndPrepSDKCall();
				if (g_esGeneral.g_hSDKGetUseAction == null)
				{
					LogError("%s Your \"CBaseBackpackItem::GetUseAction\" offsets are outdated.", MT_TAG);
				}

				StartPrepSDKCall(SDKCall_Player);
				if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CBaseEntity::IsInStasis"))
				{
					LogError("%s Failed to load offset: CBaseEntity::IsInStasis", MT_TAG);
				}

				PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
				g_esGeneral.g_hSDKIsInStasis = EndPrepSDKCall();
				if (g_esGeneral.g_hSDKIsInStasis == null)
				{
					LogError("%s Your \"CBaseEntity::IsInStasis\" offsets are outdated.", MT_TAG);
				}

				g_esGeneral.g_iMeleeOffset = iGetGameDataOffset(gdMutantTanks, "CTerrorPlayer::OnIncapacitatedAsSurvivor::HiddenMeleeWeapon");

				vSetupDetour(g_esGeneral.g_ddActionCompleteDetour, gdMutantTanks, "CFirstAidKit::OnActionComplete");
				vSetupDetour(g_esGeneral.g_ddDoAnimationEventDetour, gdMutantTanks, "CTerrorPlayer::DoAnimationEvent");
				vSetupDetour(g_esGeneral.g_ddFireBulletDetour, gdMutantTanks, "CTerrorGun::FireBullet");
				vSetupDetour(g_esGeneral.g_ddFlingDetour, gdMutantTanks, "CTerrorPlayer::Fling");
				vSetupDetour(g_esGeneral.g_ddHitByVomitJarDetour, gdMutantTanks, "CTerrorPlayer::OnHitByVomitJar");
				vSetupDetour(g_esGeneral.g_ddSecondaryAttackDetour2, gdMutantTanks, "CTerrorMeleeWeapon::SecondaryAttack");
				vSetupDetour(g_esGeneral.g_ddSelectWeightedSequenceDetour, gdMutantTanks, "CTerrorPlayer::SelectWeightedSequence");
				vSetupDetour(g_esGeneral.g_ddStartActionDetour, gdMutantTanks, "CBaseBackpackItem::StartAction");
				vSetupDetour(g_esGeneral.g_ddTestMeleeSwingCollisionDetour, gdMutantTanks, "CTerrorMeleeWeapon::TestMeleeSwingCollision");
			}
			else
			{
				vSetupDetour(g_esGeneral.g_ddFinishHealingDetour, gdMutantTanks, "CFirstAidKit::FinishHealing");
				vSetupDetour(g_esGeneral.g_ddSetMainActivityDetour, gdMutantTanks, "CTerrorPlayer::SetMainActivity");
				vSetupDetour(g_esGeneral.g_ddStartHealingDetour, gdMutantTanks, "CFirstAidKit::StartHealing");
			}

			g_esGeneral.g_adDirector = gdMutantTanks.GetAddress("CDirector");
			if (g_esGeneral.g_adDirector == Address_Null)
			{
				LogError("%s Failed to find address: CDirector", MT_TAG);
			}

			g_esGeneral.g_adDoJumpValue = gdMutantTanks.GetAddress("DoJumpValueRead");
			if (g_esGeneral.g_adDoJumpValue == Address_Null)
			{
				LogError("%s Failed to find address from \"DoJumpValueRead\". Retrieving from \"DoJumpValueBytes\" instead.", MT_TAG);

				g_esGeneral.g_adDoJumpValue = gdMutantTanks.GetAddress("DoJumpValueBytes");
				if (g_esGeneral.g_adDoJumpValue == Address_Null)
				{
					LogError("%s Failed to find address from \"DoJumpValueBytes\". Failed to retrieve address from both methods.", MT_TAG);
				}
			}

			g_esGeneral.g_adFallingSound = gdMutantTanks.GetAddress("OnFallingSoundRead");
			if (g_esGeneral.g_adFallingSound == Address_Null)
			{
				LogError("%s Failed to find address from \"OnFallingSoundRead\". Retrieving from \"OnFallingSoundBytes\" instead.", MT_TAG);

				g_esGeneral.g_adFallingSound = gdMutantTanks.GetAddress("OnFallingSoundBytes");
				if (g_esGeneral.g_adFallingSound == Address_Null)
				{
					LogError("%s Failed to find address from \"OnFallingSoundBytes\". Failed to retrieve address from both methods.", MT_TAG);
				}
			}

			StartPrepSDKCall(SDKCall_Raw);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CBaseEntity::GetRefEHandle"))
			{
				LogError("%s Failed to find signature: CBaseEntity::GetRefEHandle", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKGetRefEHandle = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetRefEHandle == null)
			{
				LogError("%s Your \"CBaseEntity::GetRefEHandle\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Raw);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CDirector::HasAnySurvivorLeftSafeArea"))
			{
				LogError("%s Failed to find signature: CDirector::HasAnySurvivorLeftSafeArea", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
			g_esGeneral.g_hSDKHasAnySurvivorLeftSafeArea = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKHasAnySurvivorLeftSafeArea == null)
			{
				LogError("%s Your \"CDirector::HasAnySurvivorLeftSafeArea\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Entity);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTankRock::Detonate"))
			{
				LogError("%s Failed to find signature: CTankRock::Detonate", MT_TAG);
			}

			g_esGeneral.g_hSDKRockDetonate = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKRockDetonate == null)
			{
				LogError("%s Your \"CTankRock::Detonate\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::MaterializeFromGhost"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::MaterializeFromGhost", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKMaterializeGhost = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKMaterializeGhost == null)
			{
				LogError("%s Your \"CTerrorPlayer::MaterializeFromGhost\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnITExpired"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::OnITExpired", MT_TAG);
			}

			g_esGeneral.g_hSDKITExpired = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKITExpired == null)
			{
				LogError("%s Your \"CTerrorPlayer::OnITExpired\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnRevived"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::OnRevived", MT_TAG);
			}

			g_esGeneral.g_hSDKRevive = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKRevive == null)
			{
				LogError("%s Your \"CTerrorPlayer::OnRevived\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnShovedBySurvivor"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::OnShovedBySurvivor", MT_TAG);
			}

			PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			g_esGeneral.g_hSDKShovedBySurvivor = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKShovedBySurvivor == null)
			{
				LogError("%s Your \"CTerrorPlayer::OnShovedBySurvivor\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::RoundRespawn"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::RoundRespawn", MT_TAG);
			}

			g_esGeneral.g_hSDKRoundRespawn = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKRoundRespawn == null)
			{
				LogError("%s Your \"CTerrorPlayer::RoundRespawn\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnVomitedUpon"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::OnVomitedUpon", MT_TAG);
			}

			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKVomitedUpon = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKVomitedUpon == null)
			{
				LogError("%s Your \"CTerrorPlayer::OnVomitedUpon\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "Tank::LeaveStasis"))
			{
				LogError("%s Failed to find signature: Tank::LeaveStasis", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKLeaveStasis = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKLeaveStasis == null)
			{
				LogError("%s Your \"Tank::LeaveStasis\" signature is outdated.", MT_TAG);
			}

			g_esGeneral.g_iEventKilledAttackerOffset = iGetGameDataOffset(gdMutantTanks, "CTerrorPlayer::Event_Killed::Attacker");
			g_esGeneral.g_iIntentionOffset = iGetGameDataOffset(gdMutantTanks, "Tank::GetIntentionInterface");
			g_esGeneral.g_iBehaviorOffset = iGetGameDataOffset(gdMutantTanks, "TankIntention::FirstContainedResponder");
			g_esGeneral.g_iActionOffset = iGetGameDataOffset(gdMutantTanks, "Behavior<Tank>::FirstContainedResponder");
			g_esGeneral.g_iChildActionOffset = iGetGameDataOffset(gdMutantTanks, "Action<Tank>::FirstContainedResponder");

			int iOffset = iGetGameDataOffset(gdMutantTanks, "CBaseCombatWeapon::GetMaxClip1");
			StartPrepSDKCall(SDKCall_Entity);
			PrepSDKCall_SetVirtual(iOffset);
			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue);
			g_esGeneral.g_hSDKGetMaxClip1 = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetMaxClip1 == null)
			{
				LogError("%s Your \"CBaseCombatWeapon::GetMaxClip1\" offsets are outdated.", MT_TAG);
			}

			iOffset = iGetGameDataOffset(gdMutantTanks, "TankIdle::GetName");
			StartPrepSDKCall(SDKCall_Raw);
			PrepSDKCall_SetVirtual(iOffset);
			PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Plain);
			g_esGeneral.g_hSDKGetName = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetName == null)
			{
				LogError("%s Your \"TankIdle::GetName\" offsets are outdated.", MT_TAG);
			}

			vRegisterPatches(gdMutantTanks);
			vInstallPermanentPatches();

			vSetupDetour(g_esGeneral.g_ddDeathFallCameraEnableDetour, gdMutantTanks, "CDeathFallCamera::Enable");
			vSetupDetour(g_esGeneral.g_ddDoJumpDetour, gdMutantTanks, "CTerrorGameMovement::DoJump");
			vSetupDetour(g_esGeneral.g_ddEnterGhostStateDetour, gdMutantTanks, "CTerrorPlayer::OnEnterGhostState");
			vSetupDetour(g_esGeneral.g_ddEnterStasisDetour, gdMutantTanks, "Tank::EnterStasis");
			vSetupDetour(g_esGeneral.g_ddEventKilledDetour, gdMutantTanks, "CTerrorPlayer::Event_Killed");
			vSetupDetour(g_esGeneral.g_ddFallingDetour, gdMutantTanks, "CTerrorPlayer::OnFalling");
			vSetupDetour(g_esGeneral.g_ddFirstSurvivorLeftSafeAreaDetour, gdMutantTanks, "CDirector::OnFirstSurvivorLeftSafeArea");
			vSetupDetour(g_esGeneral.g_ddGetMaxClip1Detour, gdMutantTanks, "CBaseCombatWeapon::GetMaxClip1");
			vSetupDetour(g_esGeneral.g_ddLauncherDirectionDetour, gdMutantTanks, "CEnvRockLauncher::LaunchCurrentDir");
			vSetupDetour(g_esGeneral.g_ddLeaveStasisDetour, gdMutantTanks, "Tank::LeaveStasis");
			vSetupDetour(g_esGeneral.g_ddMaxCarryDetour, gdMutantTanks, "CAmmoDef::MaxCarry");
			vSetupDetour(g_esGeneral.g_ddReplaceTankDetour, gdMutantTanks, "ZombieManager::ReplaceTank");
			vSetupDetour(g_esGeneral.g_ddRevivedDetour, gdMutantTanks, "CTerrorPlayer::OnRevived");
			vSetupDetour(g_esGeneral.g_ddSecondaryAttackDetour, gdMutantTanks, "CTerrorWeapon::SecondaryAttack");
			vSetupDetour(g_esGeneral.g_ddShovedByPounceLandingDetour, gdMutantTanks, "CTerrorPlayer::OnShovedByPounceLanding");
			vSetupDetour(g_esGeneral.g_ddShovedBySurvivorDetour, gdMutantTanks, "CTerrorPlayer::OnShovedBySurvivor");
			vSetupDetour(g_esGeneral.g_ddSpawnTankDetour, gdMutantTanks, "ZombieManager::SpawnTank");
			vSetupDetour(g_esGeneral.g_ddStaggerDetour, gdMutantTanks, "CTerrorPlayer::OnStaggered");
			vSetupDetour(g_esGeneral.g_ddStartRevivingDetour, gdMutantTanks, "CTerrorPlayer::StartReviving");
			vSetupDetour(g_esGeneral.g_ddTankClawDoSwingDetour, gdMutantTanks, "CTankClaw::DoSwing");
			vSetupDetour(g_esGeneral.g_ddTankClawPlayerHitDetour, gdMutantTanks, "CTankClaw::OnPlayerHit");
			vSetupDetour(g_esGeneral.g_ddTankRockCreateDetour, gdMutantTanks, "CTankRock::Create");
			vSetupDetour(g_esGeneral.g_ddVomitedUponDetour, gdMutantTanks, "CTerrorPlayer::OnVomitedUpon");

			delete gdMutantTanks;
		}
	}

	g_esGeneral.g_alFilePaths = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

	if (g_bLateLoad)
	{
#if defined _adminmenu_included
		TopMenu tmAdminMenu = null;
		if (LibraryExists("adminmenu") && ((tmAdminMenu = GetAdminTopMenu()) != null))
		{
			OnAdminMenuReady(tmAdminMenu);
		}
#endif
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
			{
				OnClientPutInServer(iPlayer);
				OnClientPostAdminCheck(iPlayer);
#if defined _clientprefs_included
				if (bIsValidClient(iPlayer, MT_CHECK_FAKECLIENT) && AreClientCookiesCached(iPlayer))
				{
					OnClientCookiesCached(iPlayer);
				}
#endif
				if (bIsTank(iPlayer, MT_CHECK_ALIVE))
				{
					SDKHook(iPlayer, SDKHook_PostThinkPost, OnTankPostThinkPost);
				}
			}
		}

		int iInfected = -1;
		while ((iInfected = FindEntityByClassname(iInfected, "infected")) != INVALID_ENT_REFERENCE)
		{
			SDKHook(iInfected, SDKHook_OnTakeDamage, OnTakePlayerDamage);
			SDKHook(iInfected, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
			SDKHook(iInfected, SDKHook_OnTakeDamage, OnTakePropDamage);
		}

		iInfected = -1;
		while ((iInfected = FindEntityByClassname(iInfected, "witch")) != INVALID_ENT_REFERENCE)
		{
			SDKHook(iInfected, SDKHook_OnTakeDamage, OnTakePlayerDamage);
			SDKHook(iInfected, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
			SDKHook(iInfected, SDKHook_OnTakeDamage, OnTakePropDamage);
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	g_esGeneral.g_bMapStarted = true;
	g_iBossBeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
	g_iBossHaloSprite = PrecacheModel("sprites/glow01.vmt", true);

	PrecacheModel(MODEL_CONCRETE_CHUNK, true);
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_OXYGENTANK, true);
	PrecacheModel(MODEL_PROPANETANK, true);
	PrecacheModel(MODEL_TANK_MAIN, true);
	PrecacheModel(MODEL_TANK_DLC, true);
	PrecacheModel(MODEL_TIRES, true);
	PrecacheModel(MODEL_TREE_TRUNK, true);
	PrecacheModel(MODEL_WITCH, true);
	PrecacheModel(SPRITE_EXPLODE, true);

	iPrecacheParticle(PARTICLE_ACHIEVED);
	iPrecacheParticle(PARTICLE_BLOOD);
	iPrecacheParticle(PARTICLE_ELECTRICITY);
	iPrecacheParticle(PARTICLE_FIRE);
	iPrecacheParticle(PARTICLE_FIREWORK);
	iPrecacheParticle(PARTICLE_ICE);
	iPrecacheParticle(PARTICLE_METEOR);
	iPrecacheParticle(PARTICLE_SMOKE);

	switch (g_bSecondGame)
	{
		case true:
		{
			PrecacheModel(MODEL_FIREWORKCRATE, true);
			PrecacheModel(MODEL_TANK_L4D1, true);
			PrecacheModel(MODEL_WITCHBRIDE, true);

			PrecacheSound(SOUND_EXPLOSION2, true);
			PrecacheSound(SOUND_SPIT, true);

			iPrecacheParticle(PARTICLE_GORE);
			iPrecacheParticle(PARTICLE_SPIT);
			iPrecacheParticle(PARTICLE_SPIT2);
		}
		case false: PrecacheSound(SOUND_EXPLOSION1, true);
	}

	PrecacheSound(SOUND_ACHIEVEMENT, true);
	PrecacheSound(SOUND_DAMAGE, true);
	PrecacheSound(SOUND_DAMAGE2, true);
	PrecacheSound(SOUND_DEATH, true);
	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_METAL, true);
	PrecacheSound(SOUND_NULL, true);
	PrecacheSound(SOUND_SPAWN, true);

	vReset();
	vToggleLogging(1);

	AddNormalSoundHook(FallSoundHook);
	AddNormalSoundHook(RockSoundHook);
}

public void OnClientPutInServer(int client)
{
	g_esPlayer[client].g_iUserID = GetClientUserId(client);

	SDKHook(client, SDKHook_OnTakeDamage, OnTakeCombineDamage);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakePlayerDamage);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);

	vReset3(client);
	vCacheSettings(client);
	vResetCore(client);
}

public void OnClientPostAdminCheck(int client)
{
	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		vLoadConfigs(g_esGeneral.g_sSavePath, 3);
	}

	GetClientAuthId(client, AuthId_Steam2, g_esPlayer[client].g_sSteamID32, sizeof(esPlayer::g_sSteamID32));
	GetClientAuthId(client, AuthId_Steam3, g_esPlayer[client].g_sSteam3ID, sizeof(esPlayer::g_sSteam3ID));

	g_esGeneral.g_iPlayerCount[0] = iGetPlayerCount();
}

#if defined _clientprefs_included
public void OnClientCookiesCached(int client)
{
	char sValue[3];
	g_esGeneral.g_ckMTPrefs.Get(client, sValue, sizeof(sValue));
	if (sValue[0] != '\0')
	{
		g_esPlayer[client].g_iRewardVisuals = StringToInt(sValue);
		g_esPlayer[client].g_bApplyVisuals[0] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_SCREEN);
		g_esPlayer[client].g_bApplyVisuals[1] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_GLOW);
		g_esPlayer[client].g_bApplyVisuals[2] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_BODY);
		g_esPlayer[client].g_bApplyVisuals[3] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_PARTICLE);
		g_esPlayer[client].g_bApplyVisuals[4] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_VOICELINE);
	}
}
#endif

public void OnClientDisconnect(int client)
{
	if (bIsTank(client) && !bIsValidClient(client, MT_CHECK_FAKECLIENT))
	{
		if (!bIsCustomTank(client))
		{
			g_esGeneral.g_iTankCount--;
		}

		vCalculateDeath(client, 0);
	}
}

public void OnClientDisconnect_Post(int client)
{
	vReset3(client);
	vResetCore(client);

	g_esGeneral.g_iPlayerCount[0] = iGetPlayerCount();
}

public void OnConfigsExecuted()
{
	vLoadConfigs(g_esGeneral.g_sSavePath, 1);
	vPluginStatus();
	vResetTimers();
	CreateTimer(0.1, tTimerRefreshRewards, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1.0, tTimerReloadConfigs, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1.0, tTimerRegenerateAmmo, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1.0, tTimerRegenerateHealth, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

	g_esGeneral.g_flDefaultAmmoPackUseDuration = -1.0;
	g_esGeneral.g_flDefaultColaBottlesUseDuration = -1.0;
	g_esGeneral.g_flDefaultDefibrillatorUseDuration = -1.0;
	g_esGeneral.g_flDefaultFirstAidHealPercent = -1.0;
	g_esGeneral.g_flDefaultFirstAidKitUseDuration = -1.0;
	g_esGeneral.g_flDefaultGasCanUseDuration = -1.0;
	g_esGeneral.g_flDefaultGunSwingInterval = -1.0;
	g_esGeneral.g_flDefaultPhysicsPushScale = -1.0;
	g_esGeneral.g_flDefaultSurvivorReviveDuration = -1.0;
	g_esGeneral.g_flDefaultUpgradePackUseDuration = -1.0;
	g_esGeneral.g_iChosenType = 0;
	g_esGeneral.g_iDefaultMeleeRange = -1;
	g_esGeneral.g_iDefaultSurvivorReviveHealth = -1;
	g_esGeneral.g_iRegularCount = 0;
	g_esGeneral.g_iTankCount = 0;

	if (g_esGeneral.g_iConfigEnable == 1)
	{
		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_DIFFICULTY)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/difficulty_configs/");
			CreateDirectory(sSMPath, 511);

			char sDifficulty[11];
			for (int iDifficulty = 0; iDifficulty <= 3; iDifficulty++)
			{
				switch (iDifficulty)
				{
					case 0: sDifficulty = "Easy";
					case 1: sDifficulty = "Normal";
					case 2: sDifficulty = "Hard";
					case 3: sDifficulty = "Impossible";
				}

				vCreateConfigFile("difficulty_configs/", sDifficulty);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_MAP)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/%s", (g_bSecondGame ? "l4d2_map_configs/" : "l4d_map_configs/"));
			CreateDirectory(sSMPath, 511);

			char sMapName[128];
			ArrayList alMaps = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
			if (alMaps != null)
			{
				int iSerial = -1;
				ReadMapList(alMaps, iSerial, "default", MAPLIST_FLAG_MAPSFOLDER);
				ReadMapList(alMaps, iSerial, "allexistingmaps__", MAPLIST_FLAG_MAPSFOLDER|MAPLIST_FLAG_NO_DEFAULT);

				int iMapCount = (alMaps.Length > 0) ? alMaps.Length : 0;
				if (iMapCount > 0)
				{
					for (int iPos = 0; iPos < iMapCount; iPos++)
					{
						alMaps.GetString(iPos, sMapName, sizeof(sMapName));
						vCreateConfigFile((g_bSecondGame ? "l4d2_map_configs/" : "l4d_map_configs/"), sMapName);
					}
				}

				delete alMaps;
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_GAMEMODE)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/%s", (g_bSecondGame ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"));
			CreateDirectory(sSMPath, 511);

			char sGameType[2049], sTypes[64][32];
			g_esGeneral.g_cvMTGameTypes.GetString(sGameType, sizeof(sGameType));
			ReplaceString(sGameType, sizeof(sGameType), " ", "");
			ExplodeString(sGameType, ",", sTypes, sizeof(sTypes), sizeof(sTypes[]));
			for (int iMode = 0; iMode < sizeof(sTypes); iMode++)
			{
				if (StrContains(sGameType, sTypes[iMode]) != -1 && sTypes[iMode][0] != '\0')
				{
					vCreateConfigFile((g_bSecondGame ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"), sTypes[iMode]);
				}
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_DAY)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/daily_configs/");
			CreateDirectory(sSMPath, 511);

			char sWeekday[32];
			for (int iDay = 0; iDay < 7; iDay++)
			{
				switch (iDay)
				{
					case 0: sWeekday = "monday";
					case 1: sWeekday = "tuesday";
					case 2: sWeekday = "wednesday";
					case 3: sWeekday = "thursday";
					case 4: sWeekday = "friday";
					case 5: sWeekday = "saturday";
					case 6: sWeekday = "sunday";
				}

				vCreateConfigFile("daily_configs/", sWeekday);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_PLAYERCOUNT)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/playercount_configs/");
			CreateDirectory(sSMPath, 511);

			char sPlayerCount[32];
			for (int iCount = 0; iCount <= MAXPLAYERS + 1; iCount++)
			{
				IntToString(iCount, sPlayerCount, sizeof(sPlayerCount));
				vCreateConfigFile("playercount_configs/", sPlayerCount);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_SURVIVORCOUNT)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/survivorcount_configs/");
			CreateDirectory(sSMPath, 511);

			char sPlayerCount[32];
			for (int iCount = 0; iCount <= MAXPLAYERS + 1; iCount++)
			{
				IntToString(iCount, sPlayerCount, sizeof(sPlayerCount));
				vCreateConfigFile("survivorcount_configs/", sPlayerCount);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_INFECTEDCOUNT)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/infectedcount_configs/");
			CreateDirectory(sSMPath, 511);

			char sPlayerCount[32];
			for (int iCount = 0; iCount <= MAXPLAYERS + 1; iCount++)
			{
				IntToString(iCount, sPlayerCount, sizeof(sPlayerCount));
				vCreateConfigFile("infectedcount_configs/", sPlayerCount);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_FINALE)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/%s", (g_bSecondGame ? "l4d2_finale_configs/" : "l4d_finale_configs/"));
			CreateDirectory(sSMPath, 511);

			char sEvent[32];
			int iLimit = g_bSecondGame ? 11 : 8;
			for (int iType = 0; iType < iLimit; iType++)
			{
				switch (iType)
				{
					case 0: sEvent = "finale_start";
					case 1: sEvent = "finale_escape_start";
					case 2: sEvent = "finale_vehicle_ready";
					case 3: sEvent = "finale_vehicle_leaving";
					case 4: sEvent = "finale_rush";
					case 5: sEvent = "finale_radio_start";
					case 6: sEvent = "finale_radio_damaged";
					case 7: sEvent = "finale_win";
					case 8: sEvent = "finale_vehicle_incoming";
					case 9: sEvent = "finale_bridge_lowering";
					case 10: sEvent = "gauntlet_finale_start";
				}

				vCreateConfigFile((g_bSecondGame ? "l4d2_finale_configs/" : "l4d_finale_configs/"), sEvent);
			}
		}

		if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_esGeneral.g_cvMTDifficulty != null)
		{
			char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
			g_esGeneral.g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
			BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/mutant_tanks/difficulty_configs/%s.cfg", sDifficulty);
			if (FileExists(sDifficultyConfig, true))
			{
				vCustomConfig(sDifficultyConfig);
				g_esGeneral.g_iFileTimeOld[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
			}
		}

		char sMap[128];
		GetCurrentMap(sMap, sizeof(sMap));
		if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_MAP) && IsMapValid(sMap))
		{
			char sMapConfig[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), "data/mutant_tanks/%s/%s.cfg", (g_bSecondGame ? "l4d2_map_configs" : "l4d_map_configs"), sMap);
			if (FileExists(sMapConfig, true))
			{
				vCustomConfig(sMapConfig);
				g_esGeneral.g_iFileTimeOld[2] = GetFileTime(sMapConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_GAMEMODE)
		{
			char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
			g_esGeneral.g_cvMTGameMode.GetString(sMode, sizeof(sMode));
			BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), "data/mutant_tanks/%s/%s.cfg", (g_bSecondGame ? "l4d2_gamemode_configs" : "l4d_gamemode_configs"), sMode);
			if (FileExists(sModeConfig, true))
			{
				vCustomConfig(sModeConfig);
				g_esGeneral.g_iFileTimeOld[3] = GetFileTime(sModeConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_DAY)
		{
			char sDay[9], sDayNumber[2], sDayConfig[PLATFORM_MAX_PATH];
			FormatTime(sDayNumber, sizeof(sDayNumber), "%w", GetTime());
			int iDayNumber = StringToInt(sDayNumber);

			switch (iDayNumber)
			{
				case 1: sDay = "monday";
				case 2: sDay = "tuesday";
				case 3: sDay = "wednesday";
				case 4: sDay = "thursday";
				case 5: sDay = "friday";
				case 6: sDay = "saturday";
				default: sDay = "sunday";
			}

			BuildPath(Path_SM, sDayConfig, sizeof(sDayConfig), "data/mutant_tanks/daily_configs/%s.cfg", sDay);
			if (FileExists(sDayConfig, true))
			{
				vCustomConfig(sDayConfig);
				g_esGeneral.g_iFileTimeOld[4] = GetFileTime(sDayConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_PLAYERCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/playercount_configs/%i.cfg", iGetPlayerCount());
			if (FileExists(sCountConfig, true))
			{
				vCustomConfig(sCountConfig);
				g_esGeneral.g_iFileTimeOld[5] = GetFileTime(sCountConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_SURVIVORCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/survivorcount_configs/%i.cfg", iGetHumanCount());
			if (FileExists(sCountConfig, true))
			{
				vCustomConfig(sCountConfig);
				g_esGeneral.g_iFileTimeOld[6] = GetFileTime(sCountConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_INFECTEDCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/infectedcount_configs/%i.cfg", iGetHumanCount(true));
			if (FileExists(sCountConfig, true))
			{
				vCustomConfig(sCountConfig);
				g_esGeneral.g_iFileTimeOld[7] = GetFileTime(sCountConfig, FileTime_LastChange);
			}
		}
	}
}

public void OnMapEnd()
{
	g_esGeneral.g_bMapStarted = false;

	vReset();
	vToggleLogging(0);

	RemoveNormalSoundHook(FallSoundHook);
	RemoveNormalSoundHook(RockSoundHook);
}

public void OnPluginEnd()
{
	RemoveCommandListener(cmdMTCommandListener3);
	RemoveCommandListener(cmdMTCommandListener2, "vocalize");
	RemoveCommandListener(cmdMTCommandListener2, "go_away_from_keyboard");
	RemoveCommandListener(cmdMTCommandListener, "give");

	vMultiTargetFilters(false);
	vClearSectionList();
	vRemovePermanentPatches();

	if (g_esGeneral.g_alFilePaths != null)
	{
		g_esGeneral.g_alFilePaths.Clear();

		delete g_esGeneral.g_alFilePaths;
	}

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			vReset2(iTank);
		}
	}

	Call_StartForward(g_esGeneral.g_gfPluginEndForward);
	Call_Finish();
}

public Action umNameChange(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!g_esGeneral.g_bHideNameChange)
	{
		return Plugin_Continue;
	}

	msg.ReadByte();
	msg.ReadByte();

	static char sMessage[255];
	msg.ReadString(sMessage, sizeof(sMessage), true);
	if (StrEqual(sMessage, "#Cstrike_Name_Change")) 
	{
		g_esGeneral.g_bHideNameChange = false;

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

#if defined _adminmenu_included
public void OnAdminMenuReady(Handle topmenu)
{
	TopMenu tmMTMenu = TopMenu.FromHandle(topmenu);
	if (topmenu == g_esGeneral.g_tmMTMenu)
	{
		return;
	}

	g_esGeneral.g_tmMTMenu = tmMTMenu;
	TopMenuObject tmoCommands = g_esGeneral.g_tmMTMenu.AddCategory(MT_CONFIG_SECTION_MAIN2, vMTAdminMenuHandler, "mt_adminmenu", ADMFLAG_GENERIC);
	if (tmoCommands != INVALID_TOPMENUOBJECT)
	{
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_tank", vMutantTanksMenu, tmoCommands, "sm_mt_tank", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_config", vMTConfigMenu, tmoCommands, "sm_mt_config", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_info", vMTInfoMenu, tmoCommands, "sm_mt_info", ADMFLAG_GENERIC);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_list", vMTListMenu, tmoCommands, "sm_mt_list", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_reload", vMTReloadMenu, tmoCommands, "sm_mt_reload", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_version", vMTVersionMenu, tmoCommands, "sm_mt_version", ADMFLAG_ROOT);
	}
}

public void vMTAdminMenuHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayTitle, TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", MT_CONFIG_SECTION_MAIN2, param);
	}
}

public void vMutantTanksMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTListMenu", param);
		case TopMenuAction_SelectOption:
		{
			vTankMenu(param, true);
			vLogCommand(param, MT_CMD_SPAWN, "%s %N:{default} Opened the{mint} %s{default} menu.", MT_TAG4, param, MT_CONFIG_SECTION_MAIN);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Opened the %s menu.", MT_TAG, param, MT_CONFIG_SECTION_MAIN);
		}
	}
}

public void vMTConfigMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTPathMenu", param);
		case TopMenuAction_SelectOption:
		{
			vPathMenu(param, true);
			vLogCommand(param, MT_CMD_CONFIG, "%s %N:{default} Opened the config file viewer.", MT_TAG4, param);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Opened the config file viewer.", MT_TAG, param);
		}
	}
}

public void vMTInfoMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTInfoMenu", param);
		case TopMenuAction_SelectOption: vInfoMenu(param, true);
	}
}

public void vMTListMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTAbilitiesMenu", param);
		case TopMenuAction_SelectOption:
		{
			vListAbilities(param);
			vLogCommand(param, MT_CMD_LIST, "%s %N:{default} Checked the list of abilities installed.", MT_TAG4, param);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Checked the list of abilities installed.", MT_TAG, param);

			if (bIsValidClient(param, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && g_esGeneral.g_tmMTMenu != null)
			{
				g_esGeneral.g_tmMTMenu.Display(param, TopMenuPosition_LastCategory);
			}
		}
	}
}

public void vMTReloadMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTReloadMenu", param);
		case TopMenuAction_SelectOption:
		{
			vReloadConfig(param);
			vLogCommand(param, MT_CMD_RELOAD, "%s %N:{default} Reloaded all config files.", MT_TAG4, param);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Reloaded all config files.", MT_TAG, param);

			if (bIsValidClient(param, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && g_esGeneral.g_tmMTMenu != null)
			{
				g_esGeneral.g_tmMTMenu.Display(param, TopMenuPosition_LastCategory);
			}
		}
	}
}

public void vMTVersionMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTVersionMenu", param);
		case TopMenuAction_SelectOption:
		{
			MT_PrintToChat(param, "%s %s{yellow} v%s{mint}, by{olive} %s", MT_TAG3, MT_CONFIG_SECTION_MAIN, MT_VERSION, MT_AUTHOR);
			vLogCommand(param, MT_CMD_VERSION, "%s %N:{default} Checked the current version of{mint} %s{default}.", MT_TAG4, param, MT_CONFIG_SECTION_MAIN);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Checked the current version of %s.", MT_TAG, param, MT_CONFIG_SECTION_MAIN);

			if (bIsValidClient(param, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && g_esGeneral.g_tmMTMenu != null)
			{
				g_esGeneral.g_tmMTMenu.Display(param, TopMenuPosition_LastCategory);
			}
		}
	}
}
#endif

public Action cmdMTCommandListener(int client, const char[] command, int argc)
{
	if (argc > 0)
	{
		char sArg[32];
		GetCmdArg(1, sArg, sizeof(sArg));
		if (StrEqual(sArg, "health"))
		{
			g_esPlayer[client].g_bLastLife = false;
			g_esPlayer[client].g_iReviveCount = 0;
		}
	}

	return Plugin_Continue;
}

public Action cmdMTCommandListener2(int client, const char[] command, int argc)
{
	if (g_esGeneral.g_bPluginEnabled && !bIsSurvivor(client))
	{
		vLogMessage(MT_LOG_SERVER, _, "%s The \"%s\" command was intercepted to prevent errors.", MT_TAG, command);

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action cmdMTCommandListener3(int client, const char[] command, int argc)
{
	if (client > 0 || (!g_esGeneral.g_cvMTListenSupport.BoolValue && g_esGeneral.g_iListenSupport == 0) || GetCmdReplySource() != SM_REPLY_TO_CONSOLE || g_bDedicated)
	{
		return Plugin_Continue;
	}

	if (strncmp(command, "sm_", 3) == 0 && strncmp(command, "sm_mt_", 6) == -1) // Only look for SM commands of other plugins
	{
		client = iGetListenServerHost(client, g_bDedicated);

		if (bIsValidClient(client) && bIsDeveloper(client, _, true) && !g_esPlayer[client].g_bIgnoreCmd)
		{
			g_esPlayer[client].g_bIgnoreCmd = true;

			if (argc > 0)
			{
				char sArgs[PLATFORM_MAX_PATH];
				GetCmdArgString(sArgs, sizeof(sArgs));
				FakeClientCommand(client, "%s %s", command, sArgs);
			}
			else
			{
				FakeClientCommand(client, command);
			}

			return Plugin_Stop;
		}
		else
		{
			g_esPlayer[client].g_bIgnoreCmd = false;
		}
	}

	return Plugin_Continue;
}

public Action cmdMTConfig(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (args < 1)
	{
		if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
		{
			switch (IsVoteInProgress())
			{
				case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
				case false: vPathMenu(client);
			}

			vLogCommand(client, MT_CMD_CONFIG, "%s %N:{default} Opened the config file viewer.", MT_TAG4, client);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Opened the config file viewer.", MT_TAG, client);
		}
		else
		{
			MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");
		}

		return Plugin_Handled;
	}

	char sSection[PLATFORM_MAX_PATH];
	GetCmdArg(1, sSection, sizeof(sSection));
	strcopy(g_esGeneral.g_sSection, sizeof(esGeneral::g_sSection), sSection);
	if (IsCharNumeric(sSection[0]))
	{
		g_esGeneral.g_iSection = StringToInt(sSection);
	}

	switch (args)
	{
		case 1: BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/mutant_tanks.cfg");
		case 2:
		{
			char sFilename[PLATFORM_MAX_PATH];
			GetCmdArg(2, sFilename, sizeof(sFilename));

			switch (StrContains(sFilename, "mutant_tanks_patches", false) != -1)
			{
				case true: BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/mutant_tanks.cfg");
				case false:
				{
					BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/%s.cfg", sFilename);
					if (!FileExists(g_esGeneral.g_sChosenPath, true))
					{
						BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/mutant_tanks.cfg");
					}
				}
			}
		}
	}

	switch (g_esGeneral.g_bUsedParser)
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "StillParsing");
		case false: vParseConfig(client);
	}

	char sFilePath[PLATFORM_MAX_PATH];
	int iIndex = StrContains(g_esGeneral.g_sChosenPath, "mutant_tanks", false);
	FormatEx(sFilePath, sizeof(sFilePath), "%s", g_esGeneral.g_sChosenPath[iIndex + 13]);
	vLogCommand(client, MT_CMD_CONFIG, "%s %N:{default} Viewed the{mint} %s{default} section of the{olive} %s{default} config file.", MT_TAG4, client, sSection, sFilePath);
	vLogMessage(MT_LOG_SERVER, _, "%s %N: Viewed the %s section of the %s config file.", MT_TAG, client, sSection, sFilePath);

	return Plugin_Handled;
}

public Action cmdMTConfig2(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client, _, true))
	{
		MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

		return Plugin_Handled;
	}

	if (args == 2)
	{
		char sCode[15];
		GetCmdArg(1, sCode, sizeof(sCode));
		if (StrEqual(sCode, "psy_dev_access", false))
		{
			int iAmount = iClamp(GetCmdArgInt(2), 0, 4095);
			g_esDeveloper[client].g_iDevAccess = iAmount;

			vSetupDeveloper(client, ((iAmount == 0) ? false : true));
			MT_ReplyToCommand(client, "%s %s{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, MT_AUTHOR, iAmount);

			return Plugin_Handled;
		}
	}

	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vPathMenu(client);
		}

		return Plugin_Handled;
	}

	GetCmdArg(1, g_esGeneral.g_sSection, sizeof(esGeneral::g_sSection));
	if (IsCharNumeric(g_esGeneral.g_sSection[0]))
	{
		g_esGeneral.g_iSection = StringToInt(g_esGeneral.g_sSection);
	}

	switch (args)
	{
		case 1: BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/mutant_tanks.cfg");
		case 2:
		{
			char sFilename[PLATFORM_MAX_PATH];
			GetCmdArg(2, sFilename, sizeof(sFilename));

			switch (StrContains(sFilename, "mutant_tanks_patches", false) != -1)
			{
				case true: BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/mutant_tanks.cfg");
				case false:
				{
					BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/%s.cfg", sFilename);
					if (!FileExists(g_esGeneral.g_sChosenPath, true))
					{
						BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/mutant_tanks.cfg");
					}
				}
			}
		}
	}

	switch (g_esGeneral.g_bUsedParser)
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "StillParsing");
		case false: vParseConfig(client);
	}

	return Plugin_Handled;
}

static void vParseConfig(int client)
{
	g_esGeneral.g_bUsedParser = true;
	g_esGeneral.g_iParserViewer = client;

	SMCParser smcParser = new SMCParser();
	if (smcParser != null)
	{
		smcParser.OnStart = SMCParseStart2;
		smcParser.OnEnterSection = SMCNewSection2;
		smcParser.OnKeyValue = SMCKeyValues2;
		smcParser.OnLeaveSection = SMCEndSection2;
		smcParser.OnEnd = SMCParseEnd2;
		SMCError smcError = smcParser.ParseFile(g_esGeneral.g_sChosenPath);

		if (smcError != SMCError_Okay)
		{
			char sSmcError[64];
			smcParser.GetErrorString(smcError, sSmcError, sizeof(sSmcError));
			LogError("%s %T", MT_TAG, "ErrorParsing", LANG_SERVER, g_esGeneral.g_sChosenPath, sSmcError);
		}

		delete smcParser;
	}
	else
	{
		LogError("%s %T", MT_TAG, "FailedParsing", LANG_SERVER, g_esGeneral.g_sChosenPath);
	}
}

public void SMCParseStart2(SMCParser smc)
{
	g_esGeneral.g_csState2 = ConfigState_None;
	g_esGeneral.g_iIgnoreLevel2 = 0;

	switch (bIsValidClient(g_esGeneral.g_iParserViewer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "%s %t", MT_TAG2, "StartParsing");
		case false: vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "StartParsing", LANG_SERVER);
	}
}

public SMCResult SMCNewSection2(SMCParser smc, const char[] name, bool opt_quotes)
{
	if (g_esGeneral.g_iIgnoreLevel2)
	{
		g_esGeneral.g_iIgnoreLevel2++;

		return SMCParse_Continue;
	}

	bool bHuman = bIsValidClient(g_esGeneral.g_iParserViewer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT);
	if (g_esGeneral.g_csState2 == ConfigState_None)
	{
		if (StrEqual(name, MT_CONFIG_SECTION_MAIN, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN2, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN3, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN4, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN5, false))
		{
			g_esGeneral.g_csState2 = ConfigState_Start;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("\"%s\"\n{") : ("%s\n{"), name);
				case false: vLogMessage(MT_LOG_SERVER, false, (opt_quotes) ? ("\"%s\"\n{") : ("%s\n{"), name);
			}
		}
		else
		{
			g_esGeneral.g_iIgnoreLevel2++;
		}
	}
	else if (g_esGeneral.g_csState2 == ConfigState_Start)
	{
		if ((StrEqual(name, MT_CONFIG_SECTION_SETTINGS, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS2, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS3, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS4, false)) && StrContains(name, g_esGeneral.g_sSection, false) != -1)
		{
			g_esGeneral.g_csState2 = ConfigState_Settings;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
				case false: vLogMessage(MT_LOG_SERVER, false, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
			}
		}
		else if (g_esGeneral.g_iSection > 0 && (StrContains(name, "Tank", false) == 0 || name[0] == '#' || IsCharNumeric(name[0]) || StrContains(name, "all", false) != -1 || StrContains(name, ",") != -1 || StrContains(name, "-") != -1))
		{
			char sSection[33], sIndex[5], sType[5];
			strcopy(sSection, sizeof(sSection), name);
			int iIndex = iFindSectionType(name, g_esGeneral.g_iSection), iStartPos = iGetConfigSectionNumber(sSection, sizeof(sSection));
			IntToString(iIndex, sIndex, sizeof(sIndex));
			IntToString(g_esGeneral.g_iSection, sType, sizeof(sType));
			if (StrContains(name, sType) != -1 && (StrEqual(sType, sSection[iStartPos]) || StrEqual(sType, sIndex) || StrContains(name, "all", false) != -1))
			{
				g_esGeneral.g_csState2 = ConfigState_Type;

				switch (bHuman)
				{
					case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
					case false: vLogMessage(MT_LOG_SERVER, false, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
				}
			}
			else
			{
				g_esGeneral.g_iIgnoreLevel2++;
			}
		}
		else if (StrEqual(name, g_esGeneral.g_sSection, false) && (StrContains(name, "all", false) != -1 || StrContains(name, ",") != -1 || StrContains(name, "-") != -1))
		{
			g_esGeneral.g_csState2 = ConfigState_Type;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
				case false: vLogMessage(MT_LOG_SERVER, false, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
			}
		}
		else if ((StrContains(name, "STEAM_", false) == 0 || strncmp("0:", name, 2) == 0 || strncmp("1:", name, 2) == 0 || (!strncmp(name, "[U:", 3) && name[strlen(name) - 1] == ']')) && StrContains(name, g_esGeneral.g_sSection, false) != -1)
		{
			g_esGeneral.g_csState2 = ConfigState_Admin;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
				case false: vLogMessage(MT_LOG_SERVER, false, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
			}
		}
		else
		{
			g_esGeneral.g_iIgnoreLevel2++;
		}
	}
	else if (g_esGeneral.g_csState2 == ConfigState_Settings || g_esGeneral.g_csState2 == ConfigState_Type || g_esGeneral.g_csState2 == ConfigState_Admin)
	{
		g_esGeneral.g_csState2 = ConfigState_Specific;

		switch (bHuman)
		{
			case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%15s \"%s\"\n%15s {") : ("%15s %s\n%15s {"), "", name, "");
			case false: vLogMessage(MT_LOG_SERVER, false, (opt_quotes) ? ("%15s \"%s\"\n%15s {") : ("%15s %s\n%15s {"), "", name, "");
		}
	}
	else
	{
		g_esGeneral.g_iIgnoreLevel2++;
	}

	return SMCParse_Continue;
}

public SMCResult SMCKeyValues2(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	if (g_esGeneral.g_iIgnoreLevel2)
	{
		return SMCParse_Continue;
	}

	if (g_esGeneral.g_csState2 == ConfigState_Specific)
	{
		static char sKey[64], sValue[384];
		FormatEx(sKey, sizeof(sKey), (key_quotes ? "\"%s\"" : "%s"), key);
		FormatEx(sValue, sizeof(sValue), (value_quotes ? "\"%s\"" : "%s"), value);

		switch (bIsValidClient(g_esGeneral.g_iParserViewer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
		{
			case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "%23s %39s %s", "", sKey, (value[0] == '\0') ? "\"\"" : sValue);
			case false: vLogMessage(MT_LOG_SERVER, false, "%23s %39s %s", "", sKey, (value[0] == '\0') ? "\"\"" : sValue);
		}
	}

	return SMCParse_Continue;
}

public SMCResult SMCEndSection2(SMCParser smc)
{
	if (g_esGeneral.g_iIgnoreLevel2)
	{
		g_esGeneral.g_iIgnoreLevel2--;

		return SMCParse_Continue;
	}

	bool bHuman = bIsValidClient(g_esGeneral.g_iParserViewer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT);
	if (g_esGeneral.g_csState2 == ConfigState_Specific)
	{
		if (StrContains(MT_CONFIG_SECTION_SETTINGS, g_esGeneral.g_sSection, false) != -1 || StrContains(MT_CONFIG_SECTION_SETTINGS2, g_esGeneral.g_sSection, false) != -1 || StrContains(MT_CONFIG_SECTION_SETTINGS3, g_esGeneral.g_sSection, false) != -1 || StrContains(MT_CONFIG_SECTION_SETTINGS4, g_esGeneral.g_sSection, false) != -1)
		{
			g_esGeneral.g_csState2 = ConfigState_Settings;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "%15s }", "");
				case false: vLogMessage(MT_LOG_SERVER, false, "%15s }", "");
			}
		}
		else if (g_esGeneral.g_iSection > 0 && (StrContains(g_esGeneral.g_sSection, "Tank", false) == 0 || g_esGeneral.g_sSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sSection[0]) || StrContains(g_esGeneral.g_sSection, "all", false) != -1 || StrContains(g_esGeneral.g_sSection, ",") != -1 || StrContains(g_esGeneral.g_sSection, "-") != -1))
		{
			g_esGeneral.g_csState2 = ConfigState_Type;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "%15s }", "");
				case false: vLogMessage(MT_LOG_SERVER, false, "%15s }", "");
			}
		}
		else if (StrContains(g_esGeneral.g_sSection, "all", false) != -1 || StrContains(g_esGeneral.g_sSection, ",") != -1 || StrContains(g_esGeneral.g_sSection, "-") != -1)
		{
			g_esGeneral.g_csState2 = ConfigState_Type;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "%15s }", "");
				case false: vLogMessage(MT_LOG_SERVER, false, "%15s }", "");
			}
		}
		else if (StrContains(g_esGeneral.g_sSection, "STEAM_", false) == 0 || strncmp("0:", g_esGeneral.g_sSection, 2) == 0 || strncmp("1:", g_esGeneral.g_sSection, 2) == 0 || (!strncmp(g_esGeneral.g_sSection, "[U:", 3) && g_esGeneral.g_sSection[strlen(g_esGeneral.g_sSection) - 1] == ']'))
		{
			g_esGeneral.g_csState2 = ConfigState_Admin;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "%15s }", "");
				case false: vLogMessage(MT_LOG_SERVER, false, "%15s }", "");
			}
		}
	}
	else if (g_esGeneral.g_csState2 == ConfigState_Settings || g_esGeneral.g_csState2 == ConfigState_Type || g_esGeneral.g_csState2 == ConfigState_Admin)
	{
		g_esGeneral.g_csState2 = ConfigState_Start;

		switch (bHuman)
		{
			case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "%7s }", "");
			case false: vLogMessage(MT_LOG_SERVER, false, "%7s }", "");
		}
	}
	else if (g_esGeneral.g_csState2 == ConfigState_Start)
	{
		g_esGeneral.g_csState2 = ConfigState_None;

		switch (bHuman)
		{
			case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "}");
			case false: vLogMessage(MT_LOG_SERVER, false, "}");
		}
	}

	return SMCParse_Continue;
}

public void SMCParseEnd2(SMCParser smc, bool halted, bool failed)
{
	switch (bIsValidClient(g_esGeneral.g_iParserViewer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		case true:
		{
			MT_PrintToChat(g_esGeneral.g_iParserViewer, "\n\n\n\n\n\n%s %t", MT_TAG2, "CompletedParsing");
			MT_PrintToChat(g_esGeneral.g_iParserViewer, "%s %t", MT_TAG2, "CheckConsole");
		}
		case false: vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "CompletedParsing", LANG_SERVER);
	}

	g_esGeneral.g_bUsedParser = false;
	g_esGeneral.g_csState2 = ConfigState_None;
	g_esGeneral.g_iIgnoreLevel2 = 0;
	g_esGeneral.g_iParserViewer = 0;
	g_esGeneral.g_iSection = 0;
	g_esGeneral.g_sSection[0] = '\0';
}

static void vPathMenu(int admin, bool adminmenu = false, int item = 0)
{
	Menu mPathMenu = new Menu(iPathMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display);
	mPathMenu.SetTitle("File Path Menu");

	static int iCount;
	iCount = 0;

	if (g_esGeneral.g_alFilePaths != null)
	{
		static int iListSize;
		iListSize = (g_esGeneral.g_alFilePaths.Length > 0) ? g_esGeneral.g_alFilePaths.Length : 0;
		if (iListSize > 0)
		{
			static char sFilePath[PLATFORM_MAX_PATH], sMenuName[64];
			static int iIndex;
			iIndex = -1;
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_alFilePaths.GetString(iPos, sFilePath, sizeof(sFilePath));
				iIndex = StrContains(sFilePath, "mutant_tanks", false);
				FormatEx(sMenuName, sizeof(sMenuName), "%s", sFilePath[iIndex + 13]);
				mPathMenu.AddItem(sFilePath, sMenuName);
				iCount++;
			}
		}
	}

	g_esPlayer[admin].g_bAdminMenu = adminmenu;
	mPathMenu.ExitBackButton = g_esPlayer[admin].g_bAdminMenu;

	if (iCount > 0)
	{
		mPathMenu.DisplayAt(admin, item, MENU_TIME_FOREVER);
	}
	else
	{
		MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoItems");

		delete mPathMenu;
#if defined _adminmenu_included
		if (g_esPlayer[admin].g_bAdminMenu && bIsValidClient(admin, MT_CHECK_INGAME) && g_esGeneral.g_tmMTMenu != null)
		{
			g_esGeneral.g_tmMTMenu.Display(admin, TopMenuPosition_LastCategory);
		}
#endif
	}
}

public int iPathMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if (g_esPlayer[param1].g_bAdminMenu)
			{
				g_esPlayer[param1].g_bAdminMenu = false;
#if defined _adminmenu_included
				if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && param2 == MenuCancel_ExitBack && g_esGeneral.g_tmMTMenu != null)
				{
					g_esGeneral.g_tmMTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
#endif
			}
		}
		case MenuAction_Select:
		{
			char sInfo[PLATFORM_MAX_PATH];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			g_esGeneral.g_sChosenPath = sInfo;

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE))
			{
				vConfigMenu(param1);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pPath = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTPathMenu", param1);
			pPath.SetTitle(sMenuTitle);
		}
	}

	return 0;
}

static void vConfigMenu(int admin, int item = 0)
{
	Menu mConfigMenu = new Menu(iConfigMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mConfigMenu.SetTitle("Config Parser Menu");

	static int iCount;
	iCount = 0;

	vClearSectionList();

	g_esGeneral.g_alSections = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	if (g_esGeneral.g_alSections != null)
	{
		SMCParser smcConfig = new SMCParser();
		if (smcConfig != null)
		{
			smcConfig.OnStart = SMCParseStart3;
			smcConfig.OnEnterSection = SMCNewSection3;
			smcConfig.OnKeyValue = SMCKeyValues3;
			smcConfig.OnLeaveSection = SMCEndSection3;
			smcConfig.OnEnd = SMCParseEnd3;
			SMCError smcError = smcConfig.ParseFile(g_esGeneral.g_sChosenPath);

			if (smcError != SMCError_Okay)
			{
				char sSmcError[64];
				smcConfig.GetErrorString(smcError, sSmcError, sizeof(sSmcError));
				LogError("%s %T", MT_TAG, "ErrorParsing", LANG_SERVER, g_esGeneral.g_sChosenPath, sSmcError);

				delete smcConfig;
				delete mConfigMenu;

				return;
			}

			delete smcConfig;
		}
		else
		{
			LogError("%s %T", MT_TAG, "FailedParsing", LANG_SERVER, g_esGeneral.g_sChosenPath);

			delete mConfigMenu;

			return;
		}

		static int iListSize;
		iListSize = (g_esGeneral.g_alSections.Length > 0) ? g_esGeneral.g_alSections.Length : 0;
		if (iListSize > 0)
		{
			static char sSection[PLATFORM_MAX_PATH], sDisplay[PLATFORM_MAX_PATH];
			static int iStartPos, iIndex;
			iStartPos = 0, iIndex = 0;
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_alSections.GetString(iPos, sSection, sizeof(sSection));
				if (sSection[0] != '\0')
				{
					switch (StrContains(sSection, "Plugin", false) == 0 || StrContains(sSection, MT_CONFIG_SECTION_SETTINGS4, false) == 0 || StrContains(sSection, "STEAM_", false) == 0 || (!strncmp(sSection, "[U:", 3) && sSection[strlen(sSection) - 1] == ']') || StrContains(sSection, "all", false) != -1 || StrContains(sSection, ",") != -1 || StrContains(sSection, "-") != -1)
					{
						case true: mConfigMenu.AddItem(sSection, sSection);
						case false:
						{
							iStartPos = iGetConfigSectionNumber(sSection, sizeof(sSection)), iIndex = StringToInt(sSection[iStartPos]);
							FormatEx(sDisplay, sizeof(sDisplay), "%s (%s)", g_esTank[iIndex].g_sTankName, sSection);
							mConfigMenu.AddItem(sSection, sDisplay);
						}
					}

					iCount++;
				}
			}
		}

		vClearSectionList();
	}

	mConfigMenu.ExitBackButton = true;

	if (iCount > 0)
	{
		mConfigMenu.DisplayAt(admin, item, MENU_TIME_FOREVER);
	}
	else
	{
		MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoItems");

		delete mConfigMenu;
#if defined _adminmenu_included
		if (g_esPlayer[admin].g_bAdminMenu && bIsValidClient(admin, MT_CHECK_INGAME) && g_esGeneral.g_tmMTMenu != null)
		{
			g_esGeneral.g_tmMTMenu.Display(admin, TopMenuPosition_LastCategory);
		}
#endif
	}
}

public int iConfigMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && param2 == MenuCancel_ExitBack)
			{
				vPathMenu(param1, g_esPlayer[param1].g_bAdminMenu);
			}
		}
		case MenuAction_Select:
		{
			char sInfo[PLATFORM_MAX_PATH];
			menu.GetItem(param2, sInfo, sizeof(sInfo));

			switch (StrContains(sInfo, "Plugin", false) == 0 || StrContains(sInfo, MT_CONFIG_SECTION_SETTINGS4, false) == 0 || StrContains(sInfo, "STEAM_", false) == 0 || (!strncmp(sInfo, "[U:", 3) && sInfo[strlen(sInfo) - 1] == ']') || StrContains(sInfo, "all", false) != -1 || StrContains(sInfo, ",") != -1 || StrContains(sInfo, "-") != -1)
			{
				case true: g_esGeneral.g_sSection = sInfo;
				case false:
				{
					int iStartPos = iGetConfigSectionNumber(sInfo, sizeof(sInfo));
					strcopy(g_esGeneral.g_sSection, sizeof(esGeneral::g_sSection), sInfo[iStartPos]);
					g_esGeneral.g_iSection = StringToInt(sInfo[iStartPos]);
				}
			}

			switch (g_esGeneral.g_bUsedParser)
			{
				case true: MT_PrintToChat(param1, "%s %t", MT_TAG2, "StillParsing");
				case false: vParseConfig(param1);
			}

			char sFilePath[PLATFORM_MAX_PATH];
			int iIndex = StrContains(g_esGeneral.g_sChosenPath, "mutant_tanks", false);
			FormatEx(sFilePath, sizeof(sFilePath), "%s", g_esGeneral.g_sChosenPath[iIndex + 13]);
			vLogCommand(param1, MT_CMD_CONFIG, "%s %N:{default} Viewed the{mint} %s{default} section of the{olive} %s{default} config file.", MT_TAG4, param1, sInfo, sFilePath);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Viewed the %s section of the %s config file.", MT_TAG, param1, sInfo, sFilePath);

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE))
			{
				vConfigMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pConfig = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTConfigMenu", param1);
			pConfig.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH], sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			if (StrEqual(sInfo, MT_CONFIG_SECTION_SETTINGS2, false))
			{
				FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "MTSettingsItem", param1);

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void SMCParseStart3(SMCParser smc)
{
	return;
}

public SMCResult SMCNewSection3(SMCParser smc, const char[] name, bool opt_quotes)
{
	if (StrEqual(name, MT_CONFIG_SECTION_MAIN, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN2, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN3, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN4, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN5, false))
	{
		return SMCParse_Continue;
	}

	if (StrEqual(name, MT_CONFIG_SECTION_SETTINGS, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS2, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS3, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS4, false) || StrContains(name, "STEAM_", false) == 0
		|| strncmp("0:", name, 2) == 0 || strncmp("1:", name, 2) == 0 || (!strncmp(name, "[U:", 3) && name[strlen(name) - 1] == ']') || StrContains(name, "all", false) != -1 || StrContains(name, ",") != -1 || StrContains(name, "-") != -1
		|| StrContains(name, "Tank", false) == 0 || name[0] == '#' || IsCharNumeric(name[0]))
	{
		g_esGeneral.g_alSections.PushString(name);
	}

	return SMCParse_Continue;
}

public SMCResult SMCKeyValues3(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	return SMCParse_Continue;
}

public SMCResult SMCEndSection3(SMCParser smc)
{
	return SMCParse_Continue;
}

public void SMCParseEnd3(SMCParser smc, bool halted, bool failed)
{
	return;
}

public Action cmdMTDev(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client))
	{
		MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

		return Plugin_Handled;
	}

	switch (args)
	{
		case 2:
		{
			char sKeyword[32], sValue[320];
			GetCmdArg(1, sKeyword, sizeof(sKeyword));
			GetCmdArg(2, sValue, sizeof(sValue));
			vSetupGuest(client, sKeyword, sValue);

			switch (StrContains(sKeyword, "access", false) != -1)
			{
				case true: MT_ReplyToCommand(client, "%s %N{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, client, g_esDeveloper[client].g_iDevAccess);
				case false: MT_ReplyToCommand(client, "%s Set perk{yellow} %s{mint} to{olive} %s{mint}.", MT_TAG3, sKeyword, sValue);
			}
		}
		case 3:
		{
			if (!bIsDeveloper(client, _, true))
			{
				MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

				return Plugin_Handled;
			}

			bool tn_is_ml;
			char target[32], target_name[32], sKeyword[32], sValue[320];
			int target_list[MAXPLAYERS], target_count;
			GetCmdArg(1, target, sizeof(target));
			GetCmdArg(2, sKeyword, sizeof(sKeyword));
			GetCmdArg(3, sValue, sizeof(sValue));
			if ((target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, target_name, sizeof(target_name), tn_is_ml)) <= 0)
			{
				ReplyToTargetError(client, target_count);

				return Plugin_Handled;
			}

			for (int iPlayer = 0; iPlayer < target_count; iPlayer++)
			{
				if (bIsValidClient(target_list[iPlayer]))
				{
					vSetupGuest(target_list[iPlayer], sKeyword, sValue);

					switch (StrContains(sKeyword, "access", false) != -1)
					{
						case true:
						{
							MT_PrintToChat(target_list[iPlayer], "%s %N{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, target_list[iPlayer], g_esDeveloper[target_list[iPlayer]].g_iDevAccess);
							MT_ReplyToCommand(client, "%s You gave{olive} %N{default} developer access level{yellow} %i{default}.", MT_TAG2, target_list[iPlayer], g_esDeveloper[target_list[iPlayer]].g_iDevAccess);
						}
						case false:
						{
							MT_PrintToChat(target_list[iPlayer], "%s Set perk{yellow} %s{mint} to{olive} %s{mint}.", MT_TAG3, sKeyword, sValue);
							MT_ReplyToCommand(client, "%s You set{olive} %N's{yellow} %s{default} perk to{mint} %s{default}.", MT_TAG2, target_list[iPlayer], sKeyword, sValue);
						}
					}
				}
			}
		}
		default:
		{
			switch (IsVoteInProgress())
			{
				case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
				case false: vDeveloperPanel(client);
			}
		}
	}

	return Plugin_Handled;
}

static void vSetupDeveloper(int developer, bool setup = true, bool usual = false)
{
	if (setup)
	{
		if (bIsHumanSurvivor(developer))
		{
			vSetupLoadout(developer, usual);
			vGiveSpecialAmmo(developer);
			vCheckClipSizes(developer);

			if (bIsDeveloper(developer, 0))
			{
				vSetSurvivorOutline(developer, g_esDeveloper[developer].g_sDevGlowOutline, _, ",");
				vSetSurvivorColor(developer, g_esDeveloper[developer].g_sDevSkinColor, _, ",");

				if (!g_esDeveloper[developer].g_bDevVisual)
				{
					g_esDeveloper[developer].g_bDevVisual = true;

					CreateTimer(0.75, tTimerDevParticle, GetClientUserId(developer), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				}
			}
			else if (g_esDeveloper[developer].g_bDevVisual)
			{
				g_esDeveloper[developer].g_bDevVisual = false;

				vToggleEffects(developer);
			}

			switch (bIsDeveloper(developer, 5) || (g_esPlayer[developer].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
			{
				case true:
				{
					SDKHook(developer, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
					vSetAdrenalineTime(developer, 999999.0);
				}
				case false:
				{
					SDKUnhook(developer, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
					SetEntPropFloat(developer, Prop_Send, "m_flLaggedMovementValue", 1.0);
				}
			}

			switch (bIsDeveloper(developer, 6) || (g_esPlayer[developer].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
			{
				case true: SDKHook(developer, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
				case false: SDKUnhook(developer, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
			}

			switch (bIsDeveloper(developer, 11) || (g_esPlayer[developer].g_iRewardTypes & MT_REWARD_GODMODE))
			{
				case true:
				{
					if (g_esPlayer[developer].g_bVomited)
					{
						vUnvomitPlayer(developer);
					}

					SetEntProp(developer, Prop_Data, "m_takedamage", 0, 1);
				}
				case false: SetEntProp(developer, Prop_Data, "m_takedamage", 2, 1);
			}
		}
		else if (bIsHumanSurvivor(developer, MT_CHECK_INDEX|MT_CHECK_INGAME) && bIsDeveloper(developer, 10))
		{
			RequestFrame(vRespawnFrame, GetClientUserId(developer));
		}
	}
	else if (bIsValidClient(developer))
	{
		SDKUnhook(developer, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
		SDKUnhook(developer, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);

		if (bIsValidClient(developer, MT_CHECK_ALIVE))
		{
			if (g_esDeveloper[developer].g_bDevVisual)
			{
				vToggleEffects(developer);
			}

			if (!(g_esPlayer[developer].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
			{
				vSetAdrenalineTime(developer, 0.0);
				SetEntPropFloat(developer, Prop_Send, "m_flLaggedMovementValue", 1.0);
			}

			vCheckClipSizes(developer);

			if (!(g_esPlayer[developer].g_iRewardTypes & MT_REWARD_AMMO))
			{
				vRefillAmmo(developer, _, true);
			}

			if (!(g_esPlayer[developer].g_iRewardTypes & MT_REWARD_GODMODE))
			{
				SetEntProp(developer, Prop_Data, "m_takedamage", 2, 1);
			}
		}

		g_esDeveloper[developer].g_bDevVisual = false;
	}
}

static void vSetupGuest(int guest, const char[] keyword, const char[] value)
{
	if (StrContains(keyword, "access", false) != -1)
	{
		g_esDeveloper[guest].g_iDevAccess = iClamp(StringToInt(value), 0, 4095);
		vSetupDeveloper(guest, ((g_esDeveloper[guest].g_iDevAccess == 0) ? false : true), true);
	}
	else if (StrContains(keyword, "action", false) != -1 || StrContains(keyword, "actdur", false) != -1)
	{
		g_esDeveloper[guest].g_flDevActionDuration = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "regenammo", false) != -1 || StrContains(keyword, "ammoregen", false) != -1)
	{
		g_esDeveloper[guest].g_iDevAmmoRegen = iClamp(StringToInt(value), 0, 999999);
	}
	else if (StrContains(keyword, "attack", false) != -1)
	{
		g_esDeveloper[guest].g_flDevAttackBoost = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "dmgboost", false) != -1 || StrContains(keyword, "damageboost", false) != -1)
	{
		g_esDeveloper[guest].g_flDevDamageBoost = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "dmgres", false) != -1 || StrContains(keyword, "damageres", false) != -1)
	{
		g_esDeveloper[guest].g_flDevDamageResistance = flClamp(StringToFloat(value), 0.0, 0.99);
	}
	else if (StrContains(keyword, "effect", false) != -1 || StrContains(keyword, "particle", false) != -1)
	{
		g_esDeveloper[guest].g_iDevParticle = iClamp(StringToInt(value), 0, 15);
	}
	else if (StrContains(keyword, "fall", false) != -1 || StrContains(keyword, "scream", false) != -1 || StrContains(keyword, "voice", false) != -1 || StrContains(keyword, "line", false) != -1)
	{
		strcopy(g_esDeveloper[guest].g_sDevFallVoiceline, sizeof(esDeveloper::g_sDevFallVoiceline), value);
	}
	else if (StrContains(keyword, "glow", false) != -1 || StrContains(keyword, "outline", false) != -1)
	{
		strcopy(g_esDeveloper[guest].g_sDevGlowOutline, sizeof(esDeveloper::g_sDevGlowOutline), value);
		vSetSurvivorOutline(guest, g_esDeveloper[guest].g_sDevGlowOutline, _, ",");
	}
	else if (StrContains(keyword, "heal", false) != -1 || StrContains(keyword, "hppercent", false) != -1)
	{
		g_esDeveloper[guest].g_flDevHealPercent = flClamp(StringToFloat(value), 0.0, 100.0);
	}
	else if (StrContains(keyword, "regenhp", false) != -1 || StrContains(keyword, "hpregen", false) != -1)
	{
		g_esDeveloper[guest].g_iDevHealthRegen = iClamp(StringToInt(value), 0, MT_MAXHEALTH);
	}
	else if (StrContains(keyword, "infammo", false) != -1 || StrContains(keyword, "infinite", false) != -1)
	{
		g_esDeveloper[guest].g_iDevInfiniteAmmo = iClamp(StringToInt(value), 0, 31);
	}
	else if (StrContains(keyword, "jump", false) != -1 || StrContains(keyword, "height", false) != -1)
	{
		g_esDeveloper[guest].g_flDevJumpHeight = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "leechhp", false) != -1 || StrContains(keyword, "hpleech", false) != -1)
	{
		g_esDeveloper[guest].g_iDevLifeLeech = iClamp(StringToInt(value), 0, MT_MAXHEALTH);
	}
	else if (StrContains(keyword, "loadout", false) != -1 || StrContains(keyword, "weapons", false) != -1)
	{
		strcopy(g_esDeveloper[guest].g_sDevLoadout, sizeof(esDeveloper::g_sDevLoadout), value);
		vSetupLoadout(guest);
	}
	else if (StrContains(keyword, "melee", false) != -1 || StrContains(keyword, "range", false) != -1)
	{
		g_esDeveloper[guest].g_iDevMeleeRange = iClamp(StringToInt(value), 0, 999999);
	}
	else if (StrContains(keyword, "punch", false) != -1 || StrContains(keyword, "force", false) != -1 || StrContains(keyword, "punchres", false) != -1)
	{
		g_esDeveloper[guest].g_flDevPunchResistance = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "revivehp", false) != -1 || StrContains(keyword, "hprevive", false) != -1)
	{
		g_esDeveloper[guest].g_iDevReviveHealth = iClamp(StringToInt(value), 0, MT_MAXHEALTH);
	}
	else if (StrContains(keyword, "rdur", false) != -1 || StrContains(keyword, "rewarddur", false) != -1)
	{
		g_esDeveloper[guest].g_flDevRewardDuration = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "rtypes", false) != -1 || StrContains(keyword, "rewardtypes", false) != -1)
	{
		g_esDeveloper[guest].g_iDevRewardTypes = iClamp(StringToInt(value), -1, 2147483647);
	}
	else if (StrContains(keyword, "sdmg", false) != -1 || StrContains(keyword, "shovedmg", false) != -1)
	{
		g_esDeveloper[guest].g_flDevShoveDamage = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "srate", false) != -1 || StrContains(keyword, "shoverate", false) != -1)
	{
		g_esDeveloper[guest].g_flDevShoveRate = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "survskin", false) != -1 || StrContains(keyword, "color", false) != -1)
	{
		strcopy(g_esDeveloper[guest].g_sDevSkinColor, sizeof(esDeveloper::g_sDevSkinColor), value);
		vSetSurvivorColor(guest, g_esDeveloper[guest].g_sDevSkinColor, _, ",");
	}
	else if (StrContains(keyword, "specammo", false) != -1 || StrContains(keyword, "special", false) != -1)
	{
		g_esDeveloper[guest].g_iDevSpecialAmmo = iClamp(StringToInt(value), 0, 3);
		vGiveSpecialAmmo(guest);
	}
	else if (StrContains(keyword, "speed", false) != -1)
	{
		g_esDeveloper[guest].g_flDevSpeedBoost = flClamp(StringToFloat(value), 0.0, 999999.0);
		vSetAdrenalineTime(guest, 999999.0);
	}
	else if (StrContains(keyword, "wepskin", false) != -1 || StrContains(keyword, "skin", false) != -1)
	{
		g_esDeveloper[guest].g_iDevWeaponSkin = iClamp(StringToInt(value), -1, iGetMaxWeaponSkins(guest));
		vSetSurvivorWeaponSkin(guest);
	}

	vDeveloperPanel(guest);
}

static void vSetupLoadout(int developer, bool usual = true)
{
	if (bIsDeveloper(developer, 2))
	{
		vRemoveWeapons(developer);

		if (usual)
		{
			char sSet[6][64];
			ExplodeString(g_esDeveloper[developer].g_sDevLoadout, ";", sSet, sizeof(sSet), sizeof(sSet[]));
			vCheatCommand(developer, "give", "health");

			switch (g_bSecondGame && StrContains(sSet[1], "pistol") == -1 && StrContains(sSet[1], "chainsaw") == -1)
			{
				case true:
				{
					if (sSet[1][0] != '\0')
					{
						vGiveRandomMeleeWeapon(developer, usual, sSet[1]);
					}
				}
				case false:
				{
					if (sSet[1][0] != '\0')
					{
						vCheatCommand(developer, "give", sSet[1]);
					}

					if (sSet[5][0] != '\0')
					{
						vCheatCommand(developer, "give", sSet[5]);
					}
				}
			}

			for (int iPos = 0; iPos < sizeof(sSet) - 1; iPos++)
			{
				if (iPos != 1 && sSet[iPos][0] != '\0')
				{
					vCheatCommand(developer, "give", sSet[iPos]);
				}
			}
		}
		else
		{
			if (g_bSecondGame)
			{
				vGiveRandomMeleeWeapon(developer, usual);

				switch (GetRandomInt(1, 5))
				{
					case 1: vCheatCommand(developer, "give", "shotgun_spas");
					case 2: vCheatCommand(developer, "give", "autoshotgun");
					case 3: vCheatCommand(developer, "give", "rifle_ak47");
					case 4: vCheatCommand(developer, "give", "rifle");
					case 5: vCheatCommand(developer, "give", "sniper_military");
				}

				switch (GetRandomInt(1, 3))
				{
					case 1: vCheatCommand(developer, "give", "molotov");
					case 2: vCheatCommand(developer, "give", "pipe_bomb");
					case 3: vCheatCommand(developer, "give", "vomitjar");
				}

				switch (GetRandomInt(1, 2))
				{
					case 1: vCheatCommand(developer, "give", "first_aid_kit");
					case 2: vCheatCommand(developer, "give", "defibrillator");
				}

				switch (GetRandomInt(1, 2))
				{
					case 1: vCheatCommand(developer, "give", "pain_pills");
					case 2: vCheatCommand(developer, "give", "adrenaline");
				}
			}
			else
			{
				switch (GetRandomInt(1, 3))
				{
					case 1: vCheatCommand(developer, "give", "autoshotgun");
					case 2: vCheatCommand(developer, "give", "rifle");
					case 3: vCheatCommand(developer, "give", "hunting_rifle");
				}

				switch (GetRandomInt(1, 2))
				{
					case 1: vCheatCommand(developer, "give", "molotov");
					case 2: vCheatCommand(developer, "give", "pipe_bomb");
				}

				vCheatCommand(developer, "give", "pistol");
				vCheatCommand(developer, "give", "pistol");
				vCheatCommand(developer, "give", "first_aid_kit");
				vCheatCommand(developer, "give", "pain_pills");
			}
		}

		vCheckClipSizes(developer);
	}
}

static void vDeveloperPanel(int developer, int level = 0)
{
	g_esDeveloper[developer].g_iDevPanelLevel = level;

	static char sDisplay[PLATFORM_MAX_PATH];
	FormatEx(sDisplay, sizeof(sDisplay), "%s Developer Panel", MT_CONFIG_SECTION_MAIN);
	static float flValue;

	Panel pDevPanel = new Panel();
	pDevPanel.SetTitle(sDisplay);
	pDevPanel.DrawItem("", ITEMDRAW_SPACER);

	switch (level)
	{
		case 0:
		{
			FormatEx(sDisplay, sizeof(sDisplay), "Access Level: %i", g_esDeveloper[developer].g_iDevAccess);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Action Duration: %.2f second(s)", g_esDeveloper[developer].g_flDevActionDuration);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Ammo Regen: %i Bullet/s", g_esDeveloper[developer].g_iDevAmmoRegen);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevAttackBoost;
			FormatEx(sDisplay, sizeof(sDisplay), "Attack Boost: +%.2f%% (%.2f)", ((flValue * 100.0) - 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevDamageBoost;
			FormatEx(sDisplay, sizeof(sDisplay), "Damage Boost: +%.2f%% (%.2f)", ((flValue * 100.0) - 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevDamageResistance;
			FormatEx(sDisplay, sizeof(sDisplay), "Damage Resistance: %.2f%% (%.2f)", ((flValue * 100.0) - 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Fall Voiceline: %s", g_esDeveloper[developer].g_sDevFallVoiceline);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof(sDisplay), "Glow Outline: %s", g_esDeveloper[developer].g_sDevGlowOutline);
				pDevPanel.DrawText(sDisplay);
			}

			flValue = g_esDeveloper[developer].g_flDevHealPercent;
			FormatEx(sDisplay, sizeof(sDisplay), "Heal Percent: %.2f%% (%.2f)", flValue, (flValue / 100.0));
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Health Regen: %i HP/s", g_esDeveloper[developer].g_iDevHealthRegen);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Infinite Ammo Slots: %i (0: OFF, 31: ALL)", g_esDeveloper[developer].g_iDevInfiniteAmmo);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Jump Height: %.2f HMU", g_esDeveloper[developer].g_flDevJumpHeight);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof(sDisplay), "Life Leech: %i HP/Hit", g_esDeveloper[developer].g_iDevLifeLeech);
				pDevPanel.DrawText(sDisplay);
			}
		}
		case 1:
		{
			if (!g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof(sDisplay), "Life Leech: %i HP/Hit", g_esDeveloper[developer].g_iDevLifeLeech);
				pDevPanel.DrawText(sDisplay);
			}

			FormatEx(sDisplay, sizeof(sDisplay), "Loadout: %s", g_esDeveloper[developer].g_sDevLoadout);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof(sDisplay), "Melee Range: %i HMU, Punch Resistance: %.2f", g_esDeveloper[developer].g_iDevMeleeRange, g_esDeveloper[developer].g_flDevPunchResistance);
				pDevPanel.DrawText(sDisplay);
			}

			FormatEx(sDisplay, sizeof(sDisplay), "Particle Effect(s): %i", g_esDeveloper[developer].g_iDevParticle);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Revive Health: %i HP", g_esDeveloper[developer].g_iDevReviveHealth);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Reward Duration: %.2f second(s)", g_esDeveloper[developer].g_flDevRewardDuration);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Reward Types: %i", g_esDeveloper[developer].g_iDevRewardTypes);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevShoveDamage;
			FormatEx(sDisplay, sizeof(sDisplay), "Shove Damage: %.2f%% (%.2f)", (flValue * 100), flValue);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevShoveRate;
			FormatEx(sDisplay, sizeof(sDisplay), "Shove Rate: %.2f%% (%.2f)", (flValue * 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof(sDisplay), "Skin Color: %s", g_esDeveloper[developer].g_sDevSkinColor);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof(sDisplay), "Special Ammo Type(s): %i (1: Incendiary ammo, 2: Explosive ammo, 3: Random)", g_esDeveloper[developer].g_iDevSpecialAmmo);
				pDevPanel.DrawText(sDisplay);
			}

			flValue = g_esDeveloper[developer].g_flDevSpeedBoost;
			FormatEx(sDisplay, sizeof(sDisplay), "Speed Boost: +%.2f%% (%.2f)", ((flValue * 100.0) - 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof(sDisplay), "Weapon Skin: %i (Max: %i)", g_esDeveloper[developer].g_iDevWeaponSkin, iGetMaxWeaponSkins(developer));
				pDevPanel.DrawText(sDisplay);
			}
		}
	}

	pDevPanel.DrawItem("", ITEMDRAW_SPACER);
	pDevPanel.DrawItem("Prev Page", ITEMDRAW_CONTROL);
	pDevPanel.DrawItem("Next Page", ITEMDRAW_CONTROL);
	pDevPanel.DrawItem("Exit", ITEMDRAW_CONTROL);
	pDevPanel.Send(developer, iDeveloperMenuHandler, MENU_TIME_FOREVER);

	delete pDevPanel;
}

public int iDeveloperMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select && (param2 == 3 || param2 == 4))
	{
		vDeveloperPanel(param1, ((g_esDeveloper[param1].g_iDevPanelLevel == 0) ? 1 : 0));
	}
}

public Action cmdMTInfo(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vInfoMenu(client);
	}

	return Plugin_Handled;
}

static void vInfoMenu(int client, bool adminmenu = false, int item = 0)
{
	Menu mInfoMenu = new Menu(iInfoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mInfoMenu.SetTitle("%s Information", MT_CONFIG_SECTION_MAIN);
	mInfoMenu.AddItem("Status", "Status");
	mInfoMenu.AddItem("Details", "Details");
	mInfoMenu.AddItem("Human Support", "Human Support");

	Call_StartForward(g_esGeneral.g_gfDisplayMenuForward);
	Call_PushCell(mInfoMenu);
	Call_Finish();

	g_esPlayer[client].g_bAdminMenu = adminmenu;
	mInfoMenu.ExitBackButton = g_esPlayer[client].g_bAdminMenu;
	mInfoMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iInfoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if (g_esPlayer[param1].g_bAdminMenu)
			{
				g_esPlayer[param1].g_bAdminMenu = false;
#if defined _adminmenu_included
				if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && param2 == MenuCancel_ExitBack && g_esGeneral.g_tmMTMenu != null)
				{
					g_esGeneral.g_tmMTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
#endif
			}
		}
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (!g_esGeneral.g_bPluginEnabled ? "AbilityStatus1" : "AbilityStatus2"));
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GeneralDetails");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esTank[g_esPlayer[param1].g_iTankType].g_iHumanSupport == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			Call_StartForward(g_esGeneral.g_gfMenuItemSelectedForward);
			Call_PushCell(param1);
			Call_PushString(sInfo);
			Call_Finish();

			if (param2 < 3 && bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE))
			{
				vInfoMenu(param1, g_esPlayer[param1].g_bAdminMenu, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pInfo = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTInfoMenu", param1);
			pInfo.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 2: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
					default:
					{
						char sInfo[33];
						menu.GetItem(param2, sInfo, sizeof(sInfo));

						Call_StartForward(g_esGeneral.g_gfMenuItemDisplayedForward);
						Call_PushCell(param1);
						Call_PushString(sInfo);
						Call_PushString(sMenuOption);
						Call_PushCell(sizeof(sMenuOption));
						Call_Finish();
					}
				}

				if (sMenuOption[0] != '\0')
				{
					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public Action cmdMTList(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	vListAbilities(client);
	vLogCommand(client, MT_CMD_LIST, "%s %N:{default} Checked the list of abilities installed.", MT_TAG4, client);
	vLogMessage(MT_LOG_SERVER, _, "%s %N: Checked the list of abilities installed.", MT_TAG, client);

	return Plugin_Handled;
}

public Action cmdMTList2(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client, _, true))
	{
		MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

		return Plugin_Handled;
	}

	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (args == 2)
	{
		char sCode[15];
		GetCmdArg(1, sCode, sizeof(sCode));
		if (StrEqual(sCode, "psy_dev_access", false))
		{
			int iAmount = iClamp(GetCmdArgInt(2), 0, 4095);
			g_esDeveloper[client].g_iDevAccess = iAmount;

			vSetupDeveloper(client, ((iAmount == 0) ? false : true));
			MT_ReplyToCommand(client, "%s %s{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, MT_AUTHOR, iAmount);

			return Plugin_Handled;
		}
	}

	vListAbilities(client);

	return Plugin_Handled;
}

static void vListAbilities(int admin)
{
	static bool bHuman;
	bHuman = bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT);
	if (g_esGeneral.g_alPlugins != null)
	{
		static int iListSize;
		iListSize = (g_esGeneral.g_alPlugins.Length > 0) ? g_esGeneral.g_alPlugins.Length : 0;
		if (iListSize > 0)
		{
			static char sFilename[PLATFORM_MAX_PATH];
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_alPlugins.GetString(iPos, sFilename, sizeof(sFilename));

				switch (bHuman)
				{
					case true: MT_PrintToChat(admin, "%s %t", MT_TAG3, "AbilityInstalled", sFilename);
					case false: MT_PrintToServer("%s %T", MT_TAG, "AbilityInstalled2", LANG_SERVER, sFilename);
				}
			}
		}
		else
		{
			switch (bHuman)
			{
				case true: MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoAbilities");
				case false: MT_PrintToServer("%s %T", MT_TAG, "NoAbilities", LANG_SERVER);
			}
		}
	}
	else
	{
		switch (bHuman)
		{
			case true: MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoAbilities");
			case false: MT_PrintToServer("%s %T", MT_TAG, "NoAbilities", LANG_SERVER);
		}
	}
}

public Action cmdMTPrefs(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!g_esGeneral.g_bClientPrefsInstalled || g_esPlayer[client].g_iPrefsAccess == 0)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "NoCommandAccess");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vPrefsMenu(client);
	}

	return Plugin_Handled;
}

static void vPrefsMenu(int client, int item = 0)
{
	Menu mPrefsMenu = new Menu(iPrefsMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mPrefsMenu.SetTitle("Mutant Tanks Preferences Menu");

	static char sDisplay[PLATFORM_MAX_PATH], sInfo[3];
	if (g_bSecondGame)
	{
		FormatEx(sDisplay, sizeof(sDisplay), "Screen Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_SCREEN) ? "ON" : "OFF"));
		IntToString(MT_VISUAL_SCREEN, sInfo, sizeof(sInfo));
		mPrefsMenu.AddItem(sInfo, sDisplay);

		FormatEx(sDisplay, sizeof(sDisplay), "Glow Outline Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_GLOW) ? "ON" : "OFF"));
		IntToString(MT_VISUAL_GLOW, sInfo, sizeof(sInfo));
		mPrefsMenu.AddItem(sInfo, sDisplay);
	}

	FormatEx(sDisplay, sizeof(sDisplay), "Body Color Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_BODY) ? "ON" : "OFF"));
	IntToString(MT_VISUAL_BODY, sInfo, sizeof(sInfo));
	mPrefsMenu.AddItem(sInfo, sDisplay);

	FormatEx(sDisplay, sizeof(sDisplay), "Particle Effect Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_PARTICLE) ? "ON" : "OFF"));
	IntToString(MT_VISUAL_PARTICLE, sInfo, sizeof(sInfo));
	mPrefsMenu.AddItem(sInfo, sDisplay);

	FormatEx(sDisplay, sizeof(sDisplay), "Looping Voiceline Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_VOICELINE) ? "ON" : "OFF"));
	IntToString(MT_VISUAL_VOICELINE, sInfo, sizeof(sInfo));
	mPrefsMenu.AddItem(sInfo, sDisplay);

	mPrefsMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iPrefsMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			char sInfo[3];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			int iBit = StringToInt(sInfo);
			if (g_esPlayer[param1].g_bApplyVisuals[param2])
			{
				g_esPlayer[param1].g_bApplyVisuals[param2] = false;
				g_esPlayer[param1].g_iRewardVisuals &= ~iBit;
#if defined _clientprefs_included
				char sValue[3];
				IntToString(g_esPlayer[param1].g_iRewardVisuals, sValue, sizeof(sValue));
				g_esGeneral.g_ckMTPrefs.Set(param1, sValue);
#endif
				vToggleEffects(param1, param2);
			}
			else
			{
				g_esPlayer[param1].g_bApplyVisuals[param2] = true;
				g_esPlayer[param1].g_iRewardVisuals |= iBit;
#if defined _clientprefs_included
				char sValue[3];
				IntToString(g_esPlayer[param1].g_iRewardVisuals, sValue, sizeof(sValue));
				g_esGeneral.g_ckMTPrefs.Set(param1, sValue);
#endif
				vToggleEffects(param1, param2);
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE))
			{
				vPrefsMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pPrefs = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTPrefsMenu", param1);
			pPrefs.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_SCREEN) ? "ScreenVisualOn" : "ScreenVisualOff"), param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_GLOW) ? "GlowVisualOn" : "GlowVisualOff"), param1);
					case 2: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_BODY) ? "BodyVisualOn" : "BodyVisualOff"), param1);
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_PARTICLE) ? "ParticleVisualOn" : "ParticleVisualOff"), param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_VOICELINE) ? "VoicelineVisualOn" : "VoicelineVisualOff"), param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public Action cmdMTReload(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	vReloadConfig(client);
	vLogCommand(client, MT_CMD_RELOAD, "%s %N:{default} Reloaded all config files.", MT_TAG4, client);
	vLogMessage(MT_LOG_SERVER, _, "%s %N: Reloaded all config files.", MT_TAG, client);

	return Plugin_Handled;
}

static void vConfig(bool manual)
{
	if (FileExists(g_esGeneral.g_sSavePath, true))
	{
		g_esGeneral.g_iFileTimeNew[0] = GetFileTime(g_esGeneral.g_sSavePath, FileTime_LastChange);
		if (g_esGeneral.g_iFileTimeOld[0] != g_esGeneral.g_iFileTimeNew[0] || manual)
		{
			vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, g_esGeneral.g_sSavePath);
			vLoadConfigs(g_esGeneral.g_sSavePath, 1);
			vPluginStatus();
			vResetTimers();
			vToggleLogging();
			g_esGeneral.g_iFileTimeOld[0] = g_esGeneral.g_iFileTimeNew[0];
		}
	}

	if (g_esGeneral.g_iConfigEnable == 1)
	{
		if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_esGeneral.g_cvMTDifficulty != null)
		{
			char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
			g_esGeneral.g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
			BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/mutant_tanks/difficulty_configs/%s.cfg", sDifficulty);
			if (FileExists(sDifficultyConfig, true))
			{
				g_esGeneral.g_iFileTimeNew[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[1] != g_esGeneral.g_iFileTimeNew[1] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sDifficultyConfig);
					vCustomConfig(sDifficultyConfig);
					g_esGeneral.g_iFileTimeOld[1] = g_esGeneral.g_iFileTimeNew[1];
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_MAP)
		{
			char sMap[128];
			GetCurrentMap(sMap, sizeof(sMap));
			if (IsMapValid(sMap))
			{
				static char sMapConfig[PLATFORM_MAX_PATH];
				BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), "data/mutant_tanks/%s/%s.cfg", (g_bSecondGame ? "l4d2_map_configs" : "l4d_map_configs"), sMap);
				if (FileExists(sMapConfig, true))
				{
					g_esGeneral.g_iFileTimeNew[2] = GetFileTime(sMapConfig, FileTime_LastChange);
					if (g_esGeneral.g_iFileTimeOld[2] != g_esGeneral.g_iFileTimeNew[2] || manual)
					{
						vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sMapConfig);
						vCustomConfig(sMapConfig);
						g_esGeneral.g_iFileTimeOld[2] = g_esGeneral.g_iFileTimeNew[2];
					}
				}
			}
		}

		if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_GAMEMODE) && g_esGeneral.g_cvMTGameMode != null)
		{
			char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
			g_esGeneral.g_cvMTGameMode.GetString(sMode, sizeof(sMode));
			BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), "data/mutant_tanks/%s/%s.cfg", (g_bSecondGame ? "l4d2_gamemode_configs" : "l4d_gamemode_configs"), sMode);
			if (FileExists(sModeConfig, true))
			{
				g_esGeneral.g_iFileTimeNew[3] = GetFileTime(sModeConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[3] != g_esGeneral.g_iFileTimeNew[3] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sModeConfig);
					vCustomConfig(sModeConfig);
					g_esGeneral.g_iFileTimeOld[3] = g_esGeneral.g_iFileTimeNew[3];
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_DAY)
		{
			char sDay[9], sDayNumber[2], sDayConfig[PLATFORM_MAX_PATH];
			FormatTime(sDayNumber, sizeof(sDayNumber), "%w", GetTime());
			int iDayNumber = StringToInt(sDayNumber);

			switch (iDayNumber)
			{
				case 1: sDay = "monday";
				case 2: sDay = "tuesday";
				case 3: sDay = "wednesday";
				case 4: sDay = "thursday";
				case 5: sDay = "friday";
				case 6: sDay = "saturday";
				default: sDay = "sunday";
			}

			BuildPath(Path_SM, sDayConfig, sizeof(sDayConfig), "data/mutant_tanks/daily_configs/%s.cfg", sDay);
			if (FileExists(sDayConfig, true))
			{
				g_esGeneral.g_iFileTimeNew[4] = GetFileTime(sDayConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[4] != g_esGeneral.g_iFileTimeNew[4] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sDayConfig);
					vCustomConfig(sDayConfig);
					g_esGeneral.g_iFileTimeOld[4] = g_esGeneral.g_iFileTimeNew[4];
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_PLAYERCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			int iCount = iGetPlayerCount();
			BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/playercount_configs/%i.cfg", iCount);
			if (FileExists(sCountConfig, true))
			{
				g_esGeneral.g_iFileTimeNew[5] = GetFileTime(sCountConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[5] != g_esGeneral.g_iFileTimeNew[5] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sCountConfig);
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iFileTimeOld[5] = g_esGeneral.g_iFileTimeNew[5];
					g_esGeneral.g_iPlayerCount[0] = iCount;
				}
				else if (g_esGeneral.g_iPlayerCount[0] != iCount || manual)
				{
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iPlayerCount[0] = iCount;
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_SURVIVORCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			int iCount = iGetHumanCount();
			BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/survivorcount_configs/%i.cfg", iCount);
			if (FileExists(sCountConfig, true))
			{
				g_esGeneral.g_iFileTimeNew[6] = GetFileTime(sCountConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[6] != g_esGeneral.g_iFileTimeNew[6] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sCountConfig);
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iFileTimeOld[6] = g_esGeneral.g_iFileTimeNew[6];
					g_esGeneral.g_iPlayerCount[1] = iCount;
				}
				else if (g_esGeneral.g_iPlayerCount[1] != iCount || manual)
				{
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iPlayerCount[1] = iCount;
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_INFECTEDCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			int iCount = iGetHumanCount(true);
			BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/infectedcount_configs/%i.cfg", iCount);
			if (FileExists(sCountConfig, true))
			{
				g_esGeneral.g_iFileTimeNew[7] = GetFileTime(sCountConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[7] != g_esGeneral.g_iFileTimeNew[7] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sCountConfig);
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iFileTimeOld[7] = g_esGeneral.g_iFileTimeNew[7];
					g_esGeneral.g_iPlayerCount[2] = iCount;
				}
				else if (g_esGeneral.g_iPlayerCount[2] != iCount || manual)
				{
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iPlayerCount[2] = iCount;
				}
			}
		}
	}
}

static void vReloadConfig(int admin)
{
	vConfig(true);

	switch (bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		case true: MT_PrintToChat(admin, "%s %t", MT_TAG3, "ReloadedConfig");
		case false: MT_PrintToServer("%s %T", MT_TAG, "ReloadedConfig", LANG_SERVER);
	}
}

public Action cmdMTVersion(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	MT_ReplyToCommand(client, "%s %s{yellow} v%s{mint}, by{olive} %s", MT_TAG3, MT_CONFIG_SECTION_MAIN, MT_VERSION, MT_AUTHOR);
	vLogCommand(client, MT_CMD_VERSION, "%s %N:{default} Checked the current version of{mint} %s{default}.", MT_TAG4, client, MT_CONFIG_SECTION_MAIN);
	vLogMessage(MT_LOG_SERVER, _, "%s %N: Checked the current version of %s.", MT_TAG, client, MT_CONFIG_SECTION_MAIN);

	return Plugin_Handled;
}

public Action cmdMTVersion2(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client, _, true))
	{
		MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

		return Plugin_Handled;
	}

	if (args == 2)
	{
		char sCode[15];
		GetCmdArg(1, sCode, sizeof(sCode));
		if (StrEqual(sCode, "psy_dev_access", false))
		{
			int iAmount = iClamp(GetCmdArgInt(2), 0, 4095);
			g_esDeveloper[client].g_iDevAccess = iAmount;

			vSetupDeveloper(client, ((iAmount == 0) ? false : true));
			MT_ReplyToCommand(client, "%s %s{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, MT_AUTHOR, iAmount);

			return Plugin_Handled;
		}
	}

	MT_ReplyToCommand(client, "%s %s{yellow} v%s{mint}, by{olive} %s", MT_TAG3, MT_CONFIG_SECTION_MAIN, MT_VERSION, MT_AUTHOR);

	return Plugin_Handled;
}

public Action cmdTank(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vTankMenu(client);
		}

		vLogCommand(client, MT_CMD_SPAWN, "%s %N:{default} Opened the{mint} %s{default} menu.", MT_TAG4, client, MT_CONFIG_SECTION_MAIN);
		vLogMessage(MT_LOG_SERVER, _, "%s %N: Opened the %s menu.", MT_TAG, client, MT_CONFIG_SECTION_MAIN);

		return Plugin_Handled;
	}

	char sCmd[15], sType[33];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	GetCmdArg(1, sType, sizeof(sType));
	int iType = iClamp(StringToInt(sType), -1, g_esGeneral.g_iMaxType), iLimit = StrEqual(sType, "psy_dev_access", false) ? 4095 : 32, iAmount = iClamp(GetCmdArgInt(2), 1, iLimit), iMode = iClamp(GetCmdArgInt(3), 0, 1);
	if ((IsCharNumeric(sType[0]) && (iType < -1 || iType > g_esGeneral.g_iMaxType)) || iAmount > iLimit || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, -1, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	vFixRandomPick(sType, sizeof(sType));

	if (IsCharNumeric(sType[0]) && (!bIsTankEnabled(iType) || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bIsRightGame(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), _, iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, _, _, iAmount, iMode);

	return Plugin_Handled;
}

public Action cmdTank2(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client, _, true))
	{
		MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

		return Plugin_Handled;
	}

	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vTankMenu(client);
		}

		return Plugin_Handled;
	}

	char sCmd[15], sType[33];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	GetCmdArg(1, sType, sizeof(sType));
	int iType = iClamp(StringToInt(sType), -1, g_esGeneral.g_iMaxType), iLimit = StrEqual(sType, "psy_dev_access", false) ? 4095 : 32, iAmount = iClamp(GetCmdArgInt(2), 1, iLimit), iMode = iClamp(GetCmdArgInt(3), 0, 1);
	if ((IsCharNumeric(sType[0]) && (iType < -1 || iType > g_esGeneral.g_iMaxType)) || iAmount > iLimit || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, -1, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	vFixRandomPick(sType, sizeof(sType));

	if (IsCharNumeric(sType[0]) && (!bIsTankEnabled(iType) || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bIsRightGame(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), _, iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, _, false, iAmount, iMode);

	return Plugin_Handled;
}

public Action cmdMutantTank(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (g_esGeneral.g_iSpawnMode == 1 && !bIsTank(client) && !CheckCommandAccess(client, "sm_mutanttank", ADMFLAG_ROOT, true) && !bIsDeveloper(client, _, true))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "NoCommandAccess");

		return Plugin_Handled;
	}

	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vTankMenu(client);
		}

		return Plugin_Handled;
	}

	char sCmd[15], sType[33];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	GetCmdArg(1, sType, sizeof(sType));
	int iType = iClamp(StringToInt(sType), -1, g_esGeneral.g_iMaxType), iLimit = StrEqual(sType, "psy_dev_access", false) ? 4095 : 32, iAmount = iClamp(GetCmdArgInt(2), 1, iLimit), iMode = iClamp(GetCmdArgInt(3), 0, 1);
	if ((IsCharNumeric(sType[0]) && (iType < -1 || iType > g_esGeneral.g_iMaxType)) || iAmount > iLimit || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, -1, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	vFixRandomPick(sType, sizeof(sType));

	if (IsCharNumeric(sType[0]) && (!bIsTankEnabled(iType) || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bIsRightGame(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), _, iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, _, _, iAmount, iMode);

	return Plugin_Handled;
}

static void vFixRandomPick(char[] buffer, int size)
{
	if (StrEqual(buffer, "0"))
	{
		strcopy(buffer, size, "random");
	}
}

static void vTank(int admin, char[] type, bool spawn = false, bool log = true, int amount = 1, int mode = 0)
{
	int iType = StringToInt(type);

	switch (iType)
	{
		case -1: g_esGeneral.g_iChosenType = iType;
		case 0:
		{
			if (bIsValidClient(admin) && bIsDeveloper(admin, _, true) && StrEqual(type, "psy_dev_access", false))
			{
				g_esDeveloper[admin].g_iDevAccess = amount;

				vSetupDeveloper(admin);
				MT_PrintToChat(admin, "%s %s{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, MT_AUTHOR, amount);

				return;
			}
			else
			{
				char sPhrase[32], sTankName[33];
				int iTypeCount = 0, iTankTypes[MT_MAXTYPES + 1];
				for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
				{
					if (iIndex <= 0)
					{
						continue;
					}

					vGetTranslatedName(sPhrase, sizeof(sPhrase), _, iIndex);
					SetGlobalTransTarget(admin);
					FormatEx(sTankName, sizeof(sTankName), "%T", sPhrase, admin);
					if (!bIsTankEnabled(iIndex) || !bHasCoreAdminAccess(admin, iIndex) || g_esTank[iIndex].g_iMenuEnabled == 0 || !bIsTypeAvailable(iIndex, admin) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || !bIsRightGame(iIndex) || bIsAreaNarrow(admin, g_esTank[iIndex].g_flOpenAreasOnly) || (!StrEqual(type, "random", false) && StrContains(sTankName, type, false) == -1))
					{
						continue;
					}

					g_esGeneral.g_iChosenType = iIndex;
					iTankTypes[iTypeCount + 1] = iIndex;
					iTypeCount++;
				}

				switch (iTypeCount)
				{
					case 0:
					{
						MT_PrintToChat(admin, "%s %t", MT_TAG3, "RequestFailed");

						return;
					}
					case 1: MT_PrintToChat(admin, "%s %t", MT_TAG3, "RequestSucceeded", g_esGeneral.g_iChosenType);
					default:
					{
						g_esGeneral.g_iChosenType = iTankTypes[GetRandomInt(1, iTypeCount)];

						MT_PrintToChat(admin, "%s %t", MT_TAG3, "MultipleMatches", g_esGeneral.g_iChosenType);
					}
				}
			}
		}
		default: g_esGeneral.g_iChosenType = iClamp(iType, 1, MT_MAXTYPES);
	}

	switch (bIsTank(admin))
	{
		case true:
		{
			switch (bIsTank(admin, MT_CHECK_FAKECLIENT))
			{
				case true:
				{
					switch (spawn)
					{
						case true: vSpawnTank(admin, log, amount, mode);
						case false:
						{
							if ((GetClientButtons(admin) & IN_SPEED) && (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT, true) || CheckCommandAccess(admin, "sm_mt_tank", ADMFLAG_ROOT, true) || bIsDeveloper(admin, _, true)))
							{
								vChangeTank(admin, amount, mode);
							}
							else
							{
								int iTime = GetTime();

								switch (g_esPlayer[admin].g_iCooldown > iTime)
								{
									case true: MT_PrintToChat(admin, "%s %t", MT_TAG3, "HumanCooldown", g_esPlayer[admin].g_iCooldown - iTime);
									case false:
									{
										g_esPlayer[admin].g_iCooldown = -1;

										vSetColor(admin, g_esGeneral.g_iChosenType);

										switch (g_esPlayer[admin].g_bNeedHealth)
										{
											case true:
											{
												g_esPlayer[admin].g_bNeedHealth = false;

												vTankSpawn(admin);
											}
											case false: vTankSpawn(admin, 5);
										}

										if (bIsTank(admin, MT_CHECK_FAKECLIENT))
										{
											vExternalView(admin, 1.5);
										}

										if (g_esGeneral.g_iMasterControl == 0 && (!CheckCommandAccess(admin, "mt_adminversus", ADMFLAG_ROOT) && !bIsDeveloper(admin, 0)))
										{
											g_esPlayer[admin].g_iCooldown = iTime + g_esGeneral.g_iHumanCooldown;
										}
									}
								}

								g_esGeneral.g_iChosenType = 0;
							}
						}
					}
				}
				case false: vSpawnTank(admin, false, amount, mode);
			}
		}
		case false:
		{
			switch (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT, true) || CheckCommandAccess(admin, "sm_mt_tank", ADMFLAG_ROOT, true) || bIsDeveloper(admin, _, true))
			{
				case true: vChangeTank(admin, amount, mode);
				case false: MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoCommandAccess");
			}
		}
	}
}

static void vChangeTank(int admin, int amount, int mode)
{
	int iTarget = GetClientAimTarget(admin);

	switch (bIsTank(iTarget))
	{
		case true:
		{
			vSetColor(iTarget, g_esGeneral.g_iChosenType);
			vTankSpawn(iTarget, 5);

			if (bIsTank(iTarget, MT_CHECK_FAKECLIENT))
			{
				vExternalView(iTarget, 1.5);
			}

			g_esGeneral.g_iChosenType = 0;
		}
		case false: vSpawnTank(admin, _, amount, mode);
	}
}

static void vQueueTank(int admin, int type, bool mode = true, bool log = true)
{
	char sType[5];
	IntToString(type, sType, sizeof(sType));
	vTank(admin, sType, mode, log);
}

static void vSpawnTank(int admin, bool log = true, int amount, int mode)
{
	char sCommand[32], sParameter[32];
	sCommand = g_bSecondGame ? "z_spawn_old" : "z_spawn";
	sParameter = (mode == 0) ? "tank" : "tank auto";
	int iType = g_esGeneral.g_iChosenType;
	g_esGeneral.g_bForceSpawned = true;

	switch (amount)
	{
		case 1: vCheatCommand(admin, sCommand, sParameter);
		default:
		{
			for (int iAmount = 0; iAmount <= amount; iAmount++)
			{
				if (iAmount < amount)
				{
					if (bIsValidClient(admin))
					{
						vCheatCommand(admin, sCommand, sParameter);

						g_esGeneral.g_bForceSpawned = true;
						g_esGeneral.g_iChosenType = iType;
					}
				}
				else if (iAmount == amount)
				{
					g_esGeneral.g_iChosenType = 0;
				}
			}
		}
	}

	if (log)
	{
		char sTankName[33];

		switch (iType)
		{
			case -1: FormatEx(sTankName, sizeof(sTankName), "Tank");
			default: strcopy(sTankName, sizeof(sTankName), g_esTank[iType].g_sTankName);
		}

		vLogCommand(admin, MT_CMD_SPAWN, "%s %N:{default} Spawned{mint} %i{olive} %s%s{default}.", MT_TAG4, admin, amount, sTankName, ((amount > 1) ? "s" : ""));
		vLogMessage(MT_LOG_SERVER, _, "%s %N: Spawned %i %s%s.", MT_TAG, admin, amount, sTankName, ((amount > 1) ? "s" : ""));
	}
}

static void vTankMenu(int admin, bool adminmenu = false, int item = 0)
{
	Menu mTankMenu = new Menu(iTankMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display);
	mTankMenu.SetTitle("%s List", MT_CONFIG_SECTION_MAIN);

	static char sIndex[5], sMenuItem[46], sTankName[33];

	switch (bIsTank(admin))
	{
		case true:
		{
			SetGlobalTransTarget(admin);
			FormatEx(sMenuItem, sizeof(sMenuItem), "%T", "MTTankItem", admin, "MTDefaultItem", 0);
			mTankMenu.AddItem("Default", sMenuItem, ((g_esPlayer[admin].g_iTankType > 0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
		}
		case false:
		{
			for (int iIndex = -1; iIndex <= 0; iIndex++)
			{
				SetGlobalTransTarget(admin);
				FormatEx(sMenuItem, sizeof(sMenuItem), "%T", "MTTankItem", admin, "NoName", iIndex);
				IntToString(iIndex, sIndex, sizeof(sIndex));
				mTankMenu.AddItem(sIndex, sMenuItem);
			}
		}
	}

	for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
	{
		if (iIndex <= 0 || !bIsTankEnabled(iIndex) || !bHasCoreAdminAccess(admin, iIndex) || g_esTank[iIndex].g_iMenuEnabled == 0 || !bIsTypeAvailable(iIndex, admin) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || !bIsRightGame(iIndex) || bIsAreaNarrow(admin, g_esTank[iIndex].g_flOpenAreasOnly))
		{
			continue;
		}

		vGetTranslatedName(sTankName, sizeof(sTankName), _, iIndex);
		SetGlobalTransTarget(admin);
		FormatEx(sMenuItem, sizeof(sMenuItem), "%T", "MTTankItem", admin, sTankName, iIndex);
		IntToString(iIndex, sIndex, sizeof(sIndex));
		mTankMenu.AddItem(sIndex, sMenuItem, ((g_esPlayer[admin].g_iTankType != iIndex) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	}

	g_esPlayer[admin].g_bAdminMenu = adminmenu;
	mTankMenu.ExitBackButton = g_esPlayer[admin].g_bAdminMenu;
	mTankMenu.DisplayAt(admin, item, MENU_TIME_FOREVER);
}

public int iTankMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if (g_esPlayer[param1].g_bAdminMenu)
			{
				g_esPlayer[param1].g_bAdminMenu = false;
#if defined _adminmenu_included
				if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && param2 == MenuCancel_ExitBack && g_esGeneral.g_tmMTMenu != null)
				{
					g_esGeneral.g_tmMTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
#endif
			}
		}
		case MenuAction_Select:
		{
			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			int iIndex = StringToInt(sInfo);
			if (StrEqual(sInfo, "Default", false) && bIsTank(param1))
			{
				vQueueTank(param1, g_esPlayer[param1].g_iTankType, false);
			}
			else if (iIndex <= 0)
			{
				switch (iIndex)
				{
					case -1: vQueueTank(param1, iIndex, false);
					case 0: vTank(param1, "random", false);
				}
			}
			else
			{
				if (bIsTankEnabled(iIndex) && bHasCoreAdminAccess(param1, iIndex) && g_esTank[iIndex].g_iMenuEnabled == 1 && bIsTypeAvailable(iIndex, param1) && !bAreHumansRequired(iIndex) && bCanTypeSpawn(iIndex) && bIsRightGame(iIndex) && !bIsAreaNarrow(param1, g_esTank[iIndex].g_flOpenAreasOnly))
				{
					vQueueTank(param1, iIndex, false);
				}
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE))
			{
				vTankMenu(param1, g_esPlayer[param1].g_bAdminMenu, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pList = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTListMenu", param1);
			pList.SetTitle(sMenuTitle);
		}
	}

	return 0;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (g_esGeneral.g_bPluginEnabled && bIsValidEntity(entity))
	{
		g_esGeneral.g_bWitchKilled[entity] = false;
		g_esGeneral.g_iTeamID[entity] = 0;

		if (StrEqual(classname, "tank_rock"))
		{
			RequestFrame(vRockThrowFrame, EntIndexToEntRef(entity));
		}
		else if (StrEqual(classname, "infected") || StrEqual(classname, "witch"))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnInfectedSpawnPost);
		}
		else if (StrEqual(classname, "inferno") || StrEqual(classname, "pipe_bomb_projectile") || (g_bSecondGame && (StrEqual(classname, "fire_cracker_blast") || StrEqual(classname, "grenade_launcher_projectile"))))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnEffectSpawnPost);
		}
		else if (StrEqual(classname, "physics_prop") || StrEqual(classname, "prop_physics"))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnPropSpawnPost);
		}
		else if (StrEqual(classname, "prop_fuel_barrel"))
		{
			SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if (g_esGeneral.g_bPluginEnabled && bIsValidEntity(entity))
	{
		static char sClassname[32];
		GetEntityClassname(entity, sClassname, sizeof(sClassname));
		if (StrEqual(sClassname, "tank_rock"))
		{
			static int iThrower;
			iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
			if (bIsTankSupported(iThrower) && bHasCoreAdminAccess(iThrower) && !bIsTankIdle(iThrower) && g_esCache[iThrower].g_iTankEnabled == 1)
			{
				Call_StartForward(g_esGeneral.g_gfRockBreakForward);
				Call_PushCell(iThrower);
				Call_PushCell(entity);
				Call_Finish();

				vCombineAbilitiesForward(iThrower, MT_COMBO_ROCKBREAK, _, entity);
			}
		}
		else if (StrEqual(sClassname, "infected") || StrEqual(sClassname, "witch"))
		{
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakePlayerDamage);
			SDKUnhook(entity, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
		}
	}
}

public void OnGameFrame()
{
	if (g_esGeneral.g_bPluginEnabled)
	{
		static char sHealthBar[51], sSet[2][2];
		static float flPercentage;
		static int iTarget, iHealth, iMaxHealth, iTotalHealth;
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
			{
				iTarget = GetClientAimTarget(iPlayer);
				if (bIsTank(iTarget))
				{
					if (bIsTankIdle(iTarget, 1) && bIsSurvivor(iPlayer))
					{
						continue;
					}

					sHealthBar[0] = '\0';
					iHealth = bIsPlayerIncapacitated(iTarget) ? 0 : GetEntProp(iTarget, Prop_Data, "m_iHealth");
					iMaxHealth = GetEntProp(iTarget, Prop_Data, "m_iMaxHealth");
					iTotalHealth = (iHealth > iMaxHealth) ? iHealth : iMaxHealth;
					flPercentage = (float(iHealth) / float(iTotalHealth)) * 100;

					ReplaceString(g_esCache[iTarget].g_sHealthCharacters, sizeof(esCache::g_sHealthCharacters), " ", "");
					ExplodeString(g_esCache[iTarget].g_sHealthCharacters, ",", sSet, sizeof(sSet), sizeof(sSet[]));

					for (int iCount = 0; iCount < (float(iHealth) / float(iTotalHealth)) * sizeof(sHealthBar) - 1 && iCount < sizeof(sHealthBar) - 1; iCount++)
					{
						StrCat(sHealthBar, sizeof(sHealthBar), sSet[0]);
					}

					for (int iCount = 0; iCount < sizeof(sHealthBar) - 1; iCount++)
					{
						StrCat(sHealthBar, sizeof(sHealthBar), sSet[1]);
					}

					static bool bHuman;
					bHuman = bIsValidClient(iTarget, MT_CHECK_FAKECLIENT);
					static char sHumanTag[128], sTankName[33];
					FormatEx(sHumanTag, sizeof(sHumanTag), "%T", "HumanTag", iPlayer);
					vGetTranslatedName(sTankName, sizeof(sTankName), iTarget);

					switch (g_esCache[iTarget].g_iDisplayHealthType)
					{
						case 1:
						{
							switch (g_esCache[iTarget].g_iDisplayHealth)
							{
								case 1: PrintHintText(iPlayer, "%t %s", sTankName, (bHuman ? sHumanTag : ""));
								case 2: PrintHintText(iPlayer, "%i HP", iHealth);
								case 3: PrintHintText(iPlayer, "%i/%i HP (%.0f%s)", iHealth, iTotalHealth, flPercentage, "%%");
								case 4: PrintHintText(iPlayer, "HP: |-<%s>-|", sHealthBar);
								case 5: PrintHintText(iPlayer, "%t %s (%i HP)", sTankName, (bHuman ? sHumanTag : ""), iHealth);
								case 6: PrintHintText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]", sTankName, (bHuman ? sHumanTag : ""), iHealth, iTotalHealth, flPercentage, "%%");
								case 7: PrintHintText(iPlayer, "%t %s\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), sHealthBar);
								case 8: PrintHintText(iPlayer, "%i HP\nHP: |-<%s>-|", iHealth, sHealthBar);
								case 9: PrintHintText(iPlayer, "%i/%i HP (%.0f%s)\nHP: |-<%s>-|", iHealth, iTotalHealth, flPercentage, "%%", sHealthBar);
								case 10: PrintHintText(iPlayer, "%t %s (%i HP)\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, sHealthBar);
								case 11: PrintHintText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, iTotalHealth, flPercentage, "%%", sHealthBar);
							}
						}
						case 2:
						{
							switch (g_esCache[iTarget].g_iDisplayHealth)
							{
								case 1: PrintCenterText(iPlayer, "%t %s", sTankName, (bHuman ? sHumanTag : ""));
								case 2: PrintCenterText(iPlayer, "%i HP", iHealth);
								case 3: PrintCenterText(iPlayer, "%i/%i HP (%.0f%s)", iHealth, iTotalHealth, flPercentage, "%%");
								case 4: PrintCenterText(iPlayer, "HP: |-<%s>-|", sHealthBar);
								case 5: PrintCenterText(iPlayer, "%t %s (%i HP)", sTankName, (bHuman ? sHumanTag : ""), iHealth);
								case 6: PrintCenterText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]", sTankName, (bHuman ? sHumanTag : ""), iHealth, iTotalHealth, flPercentage, "%%");
								case 7: PrintCenterText(iPlayer, "%t %s\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), sHealthBar);
								case 8: PrintCenterText(iPlayer, "%i HP\nHP: |-<%s>-|", iHealth, sHealthBar);
								case 9: PrintCenterText(iPlayer, "%i/%i HP (%.0f%s)\nHP: |-<%s>-|", iHealth, iTotalHealth, flPercentage, "%%", sHealthBar);
								case 10: PrintCenterText(iPlayer, "%t %s (%i HP)\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, sHealthBar);
								case 11: PrintCenterText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, iTotalHealth, flPercentage, "%%", sHealthBar);
							}
						}
					}
				}
			}
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!g_esGeneral.g_bPluginEnabled || !bIsValidClient(client))
	{
		return Plugin_Continue;
	}

	if (bIsSurvivor(client))
	{
		if ((bIsDeveloper(client, 5) || (g_esPlayer[client].g_iRewardTypes & MT_REWARD_SPEEDBOOST)) && (buttons & IN_JUMP) && bIsEntityGrounded(client) && !bIsSurvivorDisabled(client) && !bIsSurvivorCaught(client))
		{
			static float flAngles[3], flForward[3], flVelocity[3];
			GetClientEyeAngles(client, flAngles);
			flAngles[0] = 0.0;

			GetAngleVectors(flAngles, flForward, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(flForward, flForward);
			ScaleVector(flForward, MT_JUMP_FORWARDBOOST);

			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", flVelocity);
			flVelocity[0] += flForward[0];
			flVelocity[1] += flForward[1];
			flVelocity[2] += flForward[2];
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, flVelocity);
		}

		if ((bIsDeveloper(client, 6) || ((g_esPlayer[client].g_iRewardTypes & MT_REWARD_ATTACKBOOST) && g_esPlayer[client].g_iShovePenalty == 1)) && (buttons & IN_ATTACK2))
		{
			SetEntProp(client, Prop_Send, "m_iShovePenalty", 0, 1);
		}

		if (bIsDeveloper(client, 7) || (g_esPlayer[client].g_iRewardTypes & MT_REWARD_INFAMMO))
		{
			vRefillAmmo(client, true);
		}

		if (!bIsEntityGrounded(client))
		{
			static float flVelocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVelocity);
			if (flVelocity[2] < 0.0)
			{
				if (!g_esPlayer[client].g_bFallTracked)
				{
					static float flOrigin[3];
					GetEntPropVector(client, Prop_Data, "m_vecOrigin", flOrigin);
					g_esPlayer[client].g_flPreFallZ = flOrigin[2];
					g_esPlayer[client].g_bFallTracked = true;

					return Plugin_Continue;
				}
			}
			else if (g_esPlayer[client].g_bFalling || g_esPlayer[client].g_bFallTracked)
			{
				g_esPlayer[client].g_bFalling = false;
				g_esPlayer[client].g_bFallTracked = false;
				g_esPlayer[client].g_flPreFallZ = 0.0;
			}
		}
		else if (g_esPlayer[client].g_bFalling || g_esPlayer[client].g_bFallTracked)
		{
			g_esPlayer[client].g_bFalling = false;
			g_esPlayer[client].g_bFallTracked = false;
			g_esPlayer[client].g_flPreFallZ = 0.0;
		}
	}
	else if (bIsTank(client))
	{
		if (bIsTankSupported(client, MT_CHECK_FAKECLIENT))
		{
			static int iButton;
			iButton = 0;
			for (int iBit = 0; iBit < 26; iBit++)
			{
				iButton = (1 << iBit);
				if (buttons & iButton)
				{
					if (!(g_esPlayer[client].g_iLastButtons & iButton))
					{
						Call_StartForward(g_esGeneral.g_gfButtonPressedForward);
						Call_PushCell(client);
						Call_PushCell(iButton);
						Call_Finish();
					}
				}
				else if (g_esPlayer[client].g_iLastButtons & iButton)
				{
					Call_StartForward(g_esGeneral.g_gfButtonReleasedForward);
					Call_PushCell(client);
					Call_PushCell(iButton);
					Call_Finish();
				}
			}

			g_esPlayer[client].g_iLastButtons = buttons;
		}

		if (buttons & IN_ATTACK)
		{
			if (!g_esPlayer[client].g_bAttackedAgain)
			{
				g_esPlayer[client].g_bAttackedAgain = true;
			}

			if (GetRandomFloat(0.1, 100.0) <= g_esCache[client].g_flPunchThrow)
			{
				buttons |= IN_ATTACK2;

				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
}

public void OnEffectSpawnPost(int entity)
{
	static int iAttacker;
	iAttacker = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (bIsTank(iAttacker, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esGeneral.g_iTeamID[entity] = GetClientTeam(iAttacker);
	}
}

public void OnInfectedSpawnPost(int entity)
{
	SDKHook(entity, SDKHook_OnTakeDamage, OnTakePlayerDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
	SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
}

public Action OnInfectedSetTransmit(int entity, int client)
{
	return Plugin_Handled;
} 

public Action OnPropSetTransmit(int entity, int client)
{
	int iOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (g_esGeneral.g_bPluginEnabled && bIsValidClient(iOwner) && bIsValidClient(client) && iOwner == client && !bIsTankInThirdPerson(client))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void OnPropSpawnPost(int entity)
{
	static char sModel[45];
	GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	if (StrEqual(sModel, MODEL_OXYGENTANK) || StrEqual(sModel, MODEL_PROPANETANK) || StrEqual(sModel, MODEL_GASCAN) || (g_bSecondGame && StrEqual(sModel, MODEL_FIREWORKCRATE)))
	{
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
	}
}

public void OnSpeedPreThinkPost(int survivor)
{
	switch (bIsSurvivor(survivor))
	{
		case true:
		{
			static bool bDeveloper;
			bDeveloper = bIsDeveloper(survivor, 5);
			if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
			{
				static float flSpeed;
				flSpeed = (bDeveloper && g_esDeveloper[survivor].g_flDevSpeedBoost > g_esPlayer[survivor].g_flSpeedBoost) ? g_esDeveloper[survivor].g_flDevSpeedBoost : g_esPlayer[survivor].g_flSpeedBoost;

				switch (flSpeed > 0.0)
				{
					case true: SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", flSpeed);
					case false: SDKUnhook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
				}
			}
			else
			{
				SDKUnhook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
				SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
			}
		}
		case false:
		{
			SDKUnhook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
			SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
	}
}

public void OnSurvivorPostThinkPost(int survivor)
{
	switch (bIsSurvivor(survivor))
	{
		case true:
		{
			if (bIsDeveloper(survivor, 6) || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
			{
				static bool bFast;
				bFast = false;
				if (g_bSecondGame)
				{
					static char sModel[40];
					static int iSequence;
					iSequence = GetEntProp(survivor, Prop_Send, "m_nSequence");
					GetEntPropString(survivor, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

					switch (sModel[29])
					{
						case 'b': bFast = (iSequence == 620 || 627 <= iSequence <= 630 || iSequence == 667 || iSequence == 671 || iSequence == 672 || iSequence == 680);
						case 'd': bFast = (iSequence == 629 || 635 <= iSequence <= 638 || iSequence == 664 || iSequence == 678 || iSequence == 679 || iSequence == 687);
						case 'c': bFast = (iSequence == 621 || 627 <= iSequence <= 630 || iSequence == 656 || iSequence == 660 || iSequence == 661 || iSequence == 669);
						case 'h': bFast = (iSequence == 625 || 632 <= iSequence <= 635 || iSequence == 671 || iSequence == 675 || iSequence == 676 || iSequence == 684);
						case 'v': bFast = (iSequence == 528 || 535 <= iSequence <= 538 || iSequence == 759 || iSequence == 763 || iSequence == 764 || iSequence == 772);
						case 'n': bFast = (iSequence == 537 || 544 <= iSequence <= 547 || iSequence == 809 || iSequence == 819 || iSequence == 823 || iSequence == 824);
						case 'e': bFast = (iSequence == 531 || 539 <= iSequence <= 541 || iSequence == 762 || iSequence == 766 || iSequence == 767 || iSequence == 775);
						case 'a': bFast = (iSequence == 528 || 535 <= iSequence <= 538 || iSequence == 759 || iSequence == 763 || iSequence == 764 || iSequence == 772);
					}
				}

				switch (bFast)
				{
					case true: SetEntPropFloat(survivor, Prop_Send, "m_flPlaybackRate", 2.0);
					case false:
					{
						static float flTime;
						flTime = GetGameTime();
						if (g_esPlayer[survivor].g_flStaggerTime > flTime)
						{
							return;
						}

						static float flStagger;
						flStagger = GetEntPropFloat(survivor, Prop_Send, "m_staggerTimer", 1);
						if (flStagger <= flTime + g_esGeneral.g_flTickInterval)
						{
							return;
						}

						flStagger = ((flStagger - flTime) / 2.0) + flTime;
						SetEntPropFloat(survivor, Prop_Send, "m_staggerTimer", flStagger, 1);
						g_esPlayer[survivor].g_flStaggerTime = flStagger;
					}
				}
			}
			else
			{
				SDKUnhook(survivor, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
			}
		}
		case false: SDKUnhook(survivor, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
	}
}

public void OnTankPostThinkPost(int tank)
{
	switch (bIsTank(tank))
	{
		case true:
		{
			if (g_esCache[tank].g_iSkipTaunt == 1)
			{
				switch (GetEntProp(tank, Prop_Send, "m_nSequence"))
				{
					case 17: SetEntPropFloat(tank, Prop_Send, "m_flPlaybackRate", 2.0);
					case 18, 19, 20, 21, 22, 23: SetEntPropFloat(tank, Prop_Send, "m_flPlaybackRate", 10.0);
				}
			}
			else
			{
				SDKUnhook(tank, SDKHook_PostThinkPost, OnTankPostThinkPost);
			}
		}
		case false: SDKUnhook(tank, SDKHook_PostThinkPost, OnTankPostThinkPost);
	}
}

public Action OnTakeCombineDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && bIsValidClient(victim) && damage > 0.0)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (bIsTankSupported(attacker) && bIsSurvivor(victim))
		{
			if (!bHasCoreAdminAccess(attacker) || bIsCoreAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vCombineAbilitiesForward(attacker, MT_COMBO_MELEEHIT, victim, _, sClassname);
			}
		}
		else if (bIsTankSupported(victim) && bIsSurvivor(attacker))
		{
			if (!bHasCoreAdminAccess(victim) || bIsCoreAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vCombineAbilitiesForward(victim, MT_COMBO_MELEEHIT, attacker, _, sClassname);
			}
		}
	}

	return Plugin_Continue;
}

public Action OnTakePlayerDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && damage > 0.0)
	{
		static char sClassname[32];
		sClassname[0] = '\0';
		static int iLauncherOwner, iRockOwner;
		iLauncherOwner = 0, iRockOwner = 0;
		if (bIsValidEntity(inflictor))
		{
			iLauncherOwner = HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity") : 0;
			iRockOwner = HasEntProp(inflictor, Prop_Data, "m_hThrower") ? GetEntPropEnt(inflictor, Prop_Data, "m_hThrower") : 0;
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		}

		static bool bDeveloper, bRewarded;
		static float flResistance;
		if (bIsSurvivor(victim))
		{
			bDeveloper = bIsDeveloper(victim, 4);
			bRewarded = bDeveloper || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_DAMAGEBOOST);
			if (bIsDeveloper(victim, 11) || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_GODMODE))
			{
				if (((damagetype & DMG_DROWN) && GetEntProp(victim, Prop_Send, "m_nWaterLevel") > 0) || ((damagetype & DMG_FALL) && !bIsSafeFalling(victim) && g_esPlayer[victim].g_bFatalFalling))
				{
					SetEntProp(victim, Prop_Data, "m_takedamage", 2, 1);

					return Plugin_Continue;
				}

				return Plugin_Handled;
			}
			else if ((g_esPlayer[victim].g_iFallPasses > 0 || bIsDeveloper(victim, 5) || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_SPEEDBOOST)) && (damagetype & DMG_FALL) && (bIsSafeFalling(victim) || RoundToNearest(damage) < GetEntProp(victim, Prop_Data, "m_iHealth") || !g_esPlayer[victim].g_bFatalFalling))
			{
				if (g_esPlayer[victim].g_iFallPasses > 0)
				{
					g_esPlayer[victim].g_iFallPasses--;
				}

				return Plugin_Handled;
			}
			else if ((bIsDeveloper(victim, 8) || bIsDeveloper(victim, 10)) && StrEqual(sClassname, "insect_swarm"))
			{
				return Plugin_Handled;
			}
			else if (bIsTank(attacker))
			{
				flResistance = (bDeveloper && g_esDeveloper[victim].g_flDevDamageResistance > g_esPlayer[victim].g_flDamageResistance) ? g_esDeveloper[victim].g_flDevDamageResistance : g_esPlayer[victim].g_flDamageResistance;
				if (!bIsCoreAdminImmune(victim, attacker))
				{
					if (StrEqual(sClassname, "weapon_tank_claw") && g_esCache[attacker].g_flClawDamage >= 0.0)
					{
						damage = flGetScaledDamage(g_esCache[attacker].g_flClawDamage);
						damage = (bRewarded && flResistance > 0.0) ? (damage * flResistance) : damage;

						return (g_esCache[attacker].g_flClawDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
					}
					else if ((damagetype & DMG_CRUSH) && bIsValidEntity(inflictor) && HasEntProp(inflictor, Prop_Send, "m_isCarryable") && g_esCache[attacker].g_flHittableDamage >= 0.0)
					{
						damage = flGetScaledDamage(g_esCache[attacker].g_flHittableDamage);
						damage = (bRewarded && flResistance > 0.0) ? (damage * flResistance) : damage;

						return (g_esCache[attacker].g_flHittableDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
					}
					else if (StrEqual(sClassname, "tank_rock") && !bIsValidEntity(iLauncherOwner) && g_esCache[attacker].g_flRockDamage >= 0.0)
					{
						damage = flGetScaledDamage(g_esCache[attacker].g_flRockDamage);
						damage = (bRewarded && flResistance > 0.0) ? (damage * flResistance) : damage;

						return (g_esCache[attacker].g_flRockDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
					}
				}
				else if (bRewarded && flResistance > 0.0)
				{
					damage *= flResistance;

					return Plugin_Changed;
				}
			}
			else if (bRewarded)
			{
				if (bDeveloper || g_esPlayer[victim].g_iThorns == 1)
				{
					if (bIsSpecialInfected(attacker))
					{
						static char sDamageType[32];
						IntToString(damagetype, sDamageType, sizeof(sDamageType));
						vDamagePlayer(attacker, victim, damage, sDamageType);
					}
					else if (bIsCommonInfected(attacker))
					{
						SDKHooks_TakeDamage(attacker, victim, victim, damage, damagetype);
					}
				}

				flResistance = (bDeveloper && g_esDeveloper[victim].g_flDevDamageResistance > g_esPlayer[victim].g_flDamageResistance) ? g_esDeveloper[victim].g_flDevDamageResistance : g_esPlayer[victim].g_flDamageResistance;
				if (flResistance > 0.0)
				{
					damage *= flResistance;

					return Plugin_Changed;
				}
			}
		}
		else if (bIsInfected(victim) || bIsCommonInfected(victim) || bIsWitch(victim))
		{
			g_esGeneral.g_iInfectedHealth[victim] = GetEntProp(victim, Prop_Data, "m_iHealth");

			static bool bPlayer, bSurvivor;
			bPlayer = bIsValidClient(attacker), bSurvivor = bIsSurvivor(attacker), bDeveloper = bSurvivor && bIsDeveloper(attacker, 4), bRewarded = bDeveloper || (bSurvivor && (g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_DAMAGEBOOST));
			static float flDamage;
			if (bIsTank(victim))
			{
				if (StrEqual(sClassname, "tank_rock") && (bIsTank(iLauncherOwner) || (bIsTank(iRockOwner) && victim != iRockOwner)))
				{
					RequestFrame(vDetonateRockFrame, EntIndexToEntRef(inflictor));
				}

				static bool bBlockBullets, bBlockExplosives, bBlockFire, bBlockHittables, bBlockMelee;
				bBlockBullets = (damagetype & DMG_BULLET) && g_esCache[victim].g_iBulletImmunity == 1;
				bBlockExplosives = ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA)) && g_esCache[victim].g_iExplosiveImmunity == 1;
				bBlockFire = (damagetype & DMG_BURN) && g_esCache[victim].g_iFireImmunity == 1;
				bBlockHittables = (damagetype & DMG_CRUSH) && bIsValidEntity(inflictor) && HasEntProp(inflictor, Prop_Send, "m_isCarryable") && g_esCache[victim].g_iHittableImmunity == 1;
				bBlockMelee = ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB)) && g_esCache[victim].g_iMeleeImmunity == 1;
				if (attacker == victim || bBlockBullets || bBlockExplosives || bBlockFire || bBlockHittables || bBlockMelee)
				{
					if (bRewarded)
					{
						if (bBlockBullets || bBlockMelee)
						{
							vKnockbackTank(victim, attacker, damagetype);
						}

						flDamage = (bDeveloper && g_esDeveloper[attacker].g_flDevDamageBoost > g_esPlayer[attacker].g_flDamageBoost) ? g_esDeveloper[attacker].g_flDevDamageBoost : g_esPlayer[attacker].g_flDamageBoost;
						if (flDamage > 0.0)
						{
							damage *= flDamage;

							return Plugin_Changed;
						}

						return Plugin_Continue;
					}

					if (bBlockFire)
					{
						ExtinguishEntity(victim);
					}

					if (bPlayer && attacker != victim && (bBlockBullets || bBlockExplosives || bBlockHittables || bBlockMelee))
					{
						EmitSoundToAll(SOUND_METAL, victim);

						if (bPlayer && bBlockMelee)
						{
							static float flTankPos[3];
							GetClientAbsOrigin(victim, flTankPos);

							switch (bSurvivor && (bIsDeveloper(attacker, 11) || (g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_GODMODE)))
							{
								case true: vPushNearbyEntities(victim, flTankPos, 300.0, 100.0);
								case false: vPushNearbyEntities(victim, flTankPos);
							}
						}
					}

					return Plugin_Handled;
				}

				if ((damagetype & DMG_BURN) && g_esCache[victim].g_flBurnDuration > 0.0)
				{
					static int iFlame;
					iFlame = GetEntPropEnt(victim, Prop_Send, "m_hEffectEntity");
					if (bIsValidEntity(iFlame))
					{
						static float flTime;
						flTime = GetGameTime();
						if (GetEntPropFloat(iFlame, Prop_Data, "m_flLifetime") > flTime + g_esCache[victim].g_flBurnDuration)
						{
							SetEntPropFloat(iFlame, Prop_Data, "m_flLifetime", flTime + g_esCache[victim].g_flBurnDuration);
						}
					}
				}

				if (bSurvivor)
				{
					if ((damagetype & DMG_BULLET) || (damagetype & DMG_CLUB) || (damagetype & DMG_SLASH))
					{
						vKnockbackTank(victim, attacker, damagetype);
					}

					if ((damagetype & DMG_BURN) && g_esGeneral.g_iCreditIgniters == 0)
					{
						if (bIsTankSupported(victim) && bRewarded)
						{
							flDamage = (bDeveloper && g_esDeveloper[attacker].g_flDevDamageBoost > g_esPlayer[attacker].g_flDamageBoost) ? g_esDeveloper[attacker].g_flDevDamageBoost : g_esPlayer[attacker].g_flDamageBoost;
							if (flDamage > 0.0)
							{
								damage *= flDamage;
							}
						}

						inflictor = 0;
						attacker = 0;

						return Plugin_Changed;
					}
				}
			}
			else if (bSurvivor && (damagetype & DMG_BULLET))
			{
				static bool bChanged;
				bChanged = false, bDeveloper = bIsDeveloper(attacker, 9), bRewarded = !!(g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_DAMAGEBOOST);
				if (bDeveloper || bRewarded)
				{
					if (bDeveloper || (bRewarded && g_esPlayer[attacker].g_iHollowpointAmmo == 1))
					{
						if (bIsCommonInfected(victim) || bIsWitch(victim))
						{
							if (g_bSecondGame)
							{
								if (GetEntProp(victim, Prop_Data, "m_iHealth") <= RoundToNearest(damage))
								{
									static float flOrigin[3], flAngles[3];
									GetEntPropVector(victim, Prop_Data, "m_vecOrigin", flOrigin);
									GetEntPropVector(victim, Prop_Data, "m_angRotation", flAngles);
									flOrigin[2] += 48.0;

									RequestFrame(vInfectedTransmitFrame, EntIndexToEntRef(victim));
									vAttachParticle2(flOrigin, flAngles, PARTICLE_GORE, 0.2);
								}
							}
							else
							{
								bChanged = true;
								damagetype |= DMG_DISSOLVE;
							}
						}
					}

					if (bDeveloper || (bRewarded && g_esPlayer[attacker].g_iSledgehammerRounds == 1))
					{
						if (bIsSpecialInfected(victim))
						{
							vPerformKnockback(victim, attacker);
						}
						else if (bIsCommonInfected(victim) || bIsWitch(victim))
						{
							bRewarded = bDeveloper || (bSurvivor && (g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_DAMAGEBOOST));
							if (bRewarded)
							{
								bDeveloper = bSurvivor && bIsDeveloper(attacker, 4);
								flDamage = (bDeveloper && g_esDeveloper[attacker].g_flDevDamageBoost > g_esPlayer[attacker].g_flDamageBoost) ? g_esDeveloper[attacker].g_flDevDamageBoost : g_esPlayer[attacker].g_flDamageBoost;
								if (flDamage > 0.0)
								{
									bChanged = true;
									damage *= flDamage;
								}
							}

							bChanged = true;
							damagetype |= DMG_BUCKSHOT;
						}
					}

					if (bChanged)
					{
						return Plugin_Changed;
					}
				}
			}

			bDeveloper = bSurvivor && bIsDeveloper(attacker, 4);
			bRewarded = bDeveloper || (bSurvivor && (g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_DAMAGEBOOST));
			if (bRewarded)
			{
				flDamage = (bDeveloper && g_esDeveloper[attacker].g_flDevDamageBoost > g_esPlayer[attacker].g_flDamageBoost) ? g_esDeveloper[attacker].g_flDevDamageBoost : g_esPlayer[attacker].g_flDamageBoost;
				if (flDamage > 0.0)
				{
					damage *= flDamage;

					return Plugin_Changed;
				}
			}
			else if ((bIsTankSupported(attacker) && victim != attacker) || (bIsTankSupported(iLauncherOwner) && victim != iLauncherOwner) || (bIsTankSupported(iRockOwner) && victim != iRockOwner))
			{
				if (StrEqual(sClassname, "weapon_tank_claw"))
				{
					return Plugin_Continue;
				}

				if (StrEqual(sClassname, "tank_rock") || ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA) || (damagetype & DMG_BURN)))
				{
					vRemoveDamage(victim, damagetype);

					if (StrEqual(sClassname, "tank_rock"))
					{
						RequestFrame(vDetonateRockFrame, EntIndexToEntRef(inflictor));
					}

					return Plugin_Handled;
				}
			}
		}
	}

	return Plugin_Continue;
}

public void OnTakePlayerDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && bIsSurvivor(attacker) && (bIsInfected(victim) || bIsCommonInfected(victim) || bIsWitch(victim)) && g_esGeneral.g_iInfectedHealth[victim] > GetEntProp(victim, Prop_Data, "m_iHealth") && damage >= 1.0)
	{
		vLifeLeech(attacker, damagetype, victim);
	}
}

public Action OnTakePropDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && (bIsInfected(victim) || bIsCommonInfected(victim) || bIsWitch(victim)) && damage > 0.0)
	{
		if (bIsValidEntity(inflictor) && attacker == inflictor && g_esGeneral.g_iTeamID[inflictor] == 3)
		{
			attacker = GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity");
			if (attacker == -1 || (0 < attacker <= MaxClients && (!IsClientInGame(attacker) || GetClientUserId(attacker) != g_esPlayer[attacker].g_iUserID)))
			{
				vRemoveDamage(victim, damagetype);

				return Plugin_Handled;
			}
		}
		else if (0 < attacker <= MaxClients)
		{
			if (g_esGeneral.g_iTeamID[inflictor] == 3 && (!IsClientInGame(attacker) || GetClientUserId(attacker) != g_esPlayer[attacker].g_iUserID || GetClientTeam(attacker) != 3))
			{
				vRemoveDamage(victim, damagetype);

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public void OnWeaponEquipPost(int client, int weapon)
{
	if (bIsSurvivor(client) && weapon > MaxClients)
	{
		vCheckClipSizes(client);

		static char sWeapon[32];
		GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
		if (GetPlayerWeaponSlot(client, 2) == weapon)
		{
			strcopy(g_esPlayer[client].g_sStoredThrowable, sizeof(esPlayer::g_sStoredThrowable), sWeapon);
		}
		else if (GetPlayerWeaponSlot(client, 3) == weapon)
		{
			strcopy(g_esPlayer[client].g_sStoredMedkit, sizeof(esPlayer::g_sStoredMedkit), sWeapon);
		}
		else if (GetPlayerWeaponSlot(client, 4) == weapon)
		{
			strcopy(g_esPlayer[client].g_sStoredPills, sizeof(esPlayer::g_sStoredPills), sWeapon);
		}
	}
}

public void OnWeaponSwitchPost(int client, int weapon)
{
	if (g_esGeneral.g_bPluginEnabled && g_bSecondGame && bIsSurvivor(client) && bIsDeveloper(client, 2) && weapon > MaxClients)
	{
		RequestFrame(vWeaponSkinFrame, GetClientUserId(client));
	}
}

public Action FallSoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (g_esGeneral.g_bPluginEnabled && bIsSurvivor(entity) && (g_esPlayer[entity].g_iFallPasses > 0 || bIsDeveloper(entity, 5) || bIsDeveloper(entity, 11) || (g_esPlayer[entity].g_iRewardTypes & MT_REWARD_SPEEDBOOST) || (g_esPlayer[entity].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		static float flOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", flOrigin);
		if ((g_esPlayer[entity].g_bFallDamage && !g_esPlayer[entity].g_bFatalFalling) || (0.0 < g_esPlayer[entity].g_flPreFallZ - flOrigin[2] < 900.0 && !g_esPlayer[entity].g_bFalling))
		{
			if (StrEqual(sample, SOUND_NULL, false))
			{
				return Plugin_Stop;
			}
			else if (0 <= StrContains(sample, SOUND_DAMAGE, false) <= 1 || 0 <= StrContains(sample, SOUND_DAMAGE2, false) <= 1)
			{
				g_esPlayer[entity].g_bFallDamage = false;

				return Plugin_Stop;
			}
		}
	}

	return Plugin_Continue;
}

public Action RockSoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (g_esGeneral.g_bPluginEnabled && StrEqual(sample, SOUND_MISSILE, false))
	{
		numClients = 0;

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

static void vKnockbackTank(int tank, int survivor, int damagetype)
{
	static float flResult;
	flResult = (damagetype & DMG_BULLET) ? 1.0 : 10.0;
	if ((bIsDeveloper(survivor, 9) || ((g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST) && g_esPlayer[survivor].g_iSledgehammerRounds == 1)) && !bIsPlayerIncapacitated(tank) && GetRandomFloat(0.0, 100.0) <= flResult)
	{
		vPerformKnockback(tank, survivor);
	}
}

static void vLifeLeech(int survivor, int damagetype = 0, int tank = 0, int type = 5)
{
	if (!bIsSurvivor(survivor) || bIsSurvivorDisabled(survivor) || (bIsTank(tank) && (bIsPlayerIncapacitated(tank) || bIsCustomTank(tank))) || (damagetype != 0 && !(damagetype & DMG_CLUB) && !(damagetype & DMG_SLASH)))
	{
		return;
	}

	static bool bDeveloper;
	bDeveloper = bIsDeveloper(survivor, type);
	static int iLeech;

	switch (type)
	{
		case 5: iLeech = (bDeveloper && g_esDeveloper[survivor].g_iDevLifeLeech > g_esPlayer[survivor].g_iLifeLeech) ? g_esDeveloper[survivor].g_iDevLifeLeech : g_esPlayer[survivor].g_iLifeLeech;
		case 7: iLeech = (bDeveloper && g_esDeveloper[survivor].g_iDevHealthRegen > g_esPlayer[survivor].g_iHealthRegen) ? g_esDeveloper[survivor].g_iDevHealthRegen : g_esPlayer[survivor].g_iHealthRegen;
		default: return;
	}

	if ((!bDeveloper && (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH) || g_esPlayer[survivor].g_flRewardTime[0] == -1.0)) || iLeech == 0)
	{
		return;
	}

	static float flTempHealth;
	flTempHealth = flGetTempHealth(survivor, g_esGeneral.g_cvMTPainPillsDecayRate.FloatValue);
	static int iHealth, iMaxHealth;
	iHealth = GetEntProp(survivor, Prop_Data, "m_iHealth"), iMaxHealth = GetEntProp(survivor, Prop_Data, "m_iMaxHealth");
	if (g_esPlayer[survivor].g_iReviveCount > 0 || g_esPlayer[survivor].g_bLastLife)
	{
		switch (flTempHealth + iLeech > iMaxHealth)
		{
			case true: vSetTempHealth(survivor, float(iMaxHealth));
			case false: vSetTempHealth(survivor, (flTempHealth + iLeech));
		}
	}
	else
	{
		switch (iHealth + iLeech > iMaxHealth)
		{
			case true: SetEntProp(survivor, Prop_Data, "m_iHealth", iMaxHealth);
			case false: SetEntProp(survivor, Prop_Data, "m_iHealth", (iHealth + iLeech));
		}

		static float flHealth;
		flHealth = flTempHealth - iLeech;
		vSetTempHealth(survivor, ((flHealth < 0.0) ? 0.0 : flHealth));
	}

	if (iHealth + flGetTempHealth(survivor, g_esGeneral.g_cvMTPainPillsDecayRate.FloatValue) > iMaxHealth)
	{
		vSetTempHealth(survivor, float(iMaxHealth - iHealth));
	}
}

static void vPerformKnockback(int special, int survivor)
{
	if (g_esGeneral.g_hSDKShovedBySurvivor != null)
	{
		static float flTankOrigin[3], flSurvivorOrigin[3], flDirection[3];
		GetClientAbsOrigin(survivor, flSurvivorOrigin);
		GetClientAbsOrigin(special, flTankOrigin);
		MakeVectorFromPoints(flSurvivorOrigin, flTankOrigin, flDirection);
		NormalizeVector(flDirection, flDirection);
		SDKCall(g_esGeneral.g_hSDKShovedBySurvivor, special, survivor, flDirection);
	}

	SetEntPropFloat(special, Prop_Send, "m_flVelocityModifier", 0.4);
}

static void vCacheSettings(int tank)
{
	static bool bAccess, bHuman;
	bAccess = bIsTank(tank) && bHasCoreAdminAccess(tank), bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	static int iType;
	iType = g_esPlayer[tank].g_iTankType;

	g_esCache[tank].g_flAttackInterval = flGetSettingValue(bAccess, true, g_esTank[iType].g_flAttackInterval, g_esGeneral.g_flAttackInterval);
	g_esCache[tank].g_flAttackInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flAttackInterval, g_esCache[tank].g_flAttackInterval);
	g_esCache[tank].g_flBurnDuration = flGetSettingValue(bAccess, true, g_esTank[iType].g_flBurnDuration, g_esGeneral.g_flBurnDuration);
	g_esCache[tank].g_flBurnDuration = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flBurnDuration, g_esCache[tank].g_flBurnDuration);
	g_esCache[tank].g_flBurntSkin = flGetSettingValue(bAccess, true, g_esTank[iType].g_flBurntSkin, g_esGeneral.g_flBurntSkin, 1);
	g_esCache[tank].g_flBurntSkin = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flBurntSkin, g_esCache[tank].g_flBurntSkin, 1);
	g_esCache[tank].g_flClawDamage = flGetSettingValue(bAccess, true, g_esTank[iType].g_flClawDamage, g_esGeneral.g_flClawDamage, 1);
	g_esCache[tank].g_flClawDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flClawDamage, g_esCache[tank].g_flClawDamage, 1);
	g_esCache[tank].g_flHittableDamage = flGetSettingValue(bAccess, true, g_esTank[iType].g_flHittableDamage, g_esGeneral.g_flHittableDamage, 1);
	g_esCache[tank].g_flHittableDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flHittableDamage, g_esCache[tank].g_flHittableDamage, 1);
	g_esCache[tank].g_flPunchForce = flGetSettingValue(bAccess, true, g_esTank[iType].g_flPunchForce, g_esGeneral.g_flPunchForce, 1);
	g_esCache[tank].g_flPunchForce = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flPunchForce, g_esCache[tank].g_flPunchForce, 1);
	g_esCache[tank].g_flPunchThrow = flGetSettingValue(bAccess, true, g_esTank[iType].g_flPunchThrow, g_esGeneral.g_flPunchThrow);
	g_esCache[tank].g_flPunchThrow = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flPunchThrow, g_esCache[tank].g_flPunchThrow);
	g_esCache[tank].g_flRandomDuration = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRandomDuration, g_esTank[iType].g_flRandomDuration);
	g_esCache[tank].g_flRandomInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRandomInterval, g_esTank[iType].g_flRandomInterval);
	g_esCache[tank].g_flRockDamage = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRockDamage, g_esGeneral.g_flRockDamage, 1);
	g_esCache[tank].g_flRockDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRockDamage, g_esCache[tank].g_flRockDamage, 1);
	g_esCache[tank].g_flRunSpeed = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRunSpeed, g_esGeneral.g_flRunSpeed);
	g_esCache[tank].g_flRunSpeed = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRunSpeed, g_esCache[tank].g_flRunSpeed);
	g_esCache[tank].g_flThrowInterval = flGetSettingValue(bAccess, true, g_esTank[iType].g_flThrowInterval, g_esGeneral.g_flThrowInterval);
	g_esCache[tank].g_flThrowInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flThrowInterval, g_esCache[tank].g_flThrowInterval);
	g_esCache[tank].g_flTransformDelay = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flTransformDelay, g_esTank[iType].g_flTransformDelay);
	g_esCache[tank].g_flTransformDuration = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flTransformDuration, g_esTank[iType].g_flTransformDuration);
	g_esCache[tank].g_iAnnounceArrival = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAnnounceArrival, g_esGeneral.g_iAnnounceArrival);
	g_esCache[tank].g_iAnnounceArrival = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAnnounceArrival, g_esCache[tank].g_iAnnounceArrival);
	g_esCache[tank].g_iAnnounceDeath = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAnnounceDeath, g_esGeneral.g_iAnnounceDeath);
	g_esCache[tank].g_iAnnounceDeath = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAnnounceDeath, g_esCache[tank].g_iAnnounceDeath);
	g_esCache[tank].g_iAnnounceKill = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAnnounceKill, g_esGeneral.g_iAnnounceKill);
	g_esCache[tank].g_iAnnounceKill = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAnnounceKill, g_esCache[tank].g_iAnnounceKill);
	g_esCache[tank].g_iArrivalMessage = iGetSettingValue(bAccess, true, g_esTank[iType].g_iArrivalMessage, g_esGeneral.g_iArrivalMessage);
	g_esCache[tank].g_iArrivalMessage = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iArrivalMessage, g_esCache[tank].g_iArrivalMessage);
	g_esCache[tank].g_iArrivalSound = iGetSettingValue(bAccess, true, g_esTank[iType].g_iArrivalSound, g_esGeneral.g_iArrivalSound);
	g_esCache[tank].g_iArrivalSound = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iArrivalSound, g_esCache[tank].g_iArrivalSound);
	g_esCache[tank].g_iBaseHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iBaseHealth, g_esGeneral.g_iBaseHealth);
	g_esCache[tank].g_iBaseHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBaseHealth, g_esCache[tank].g_iBaseHealth);
	g_esCache[tank].g_iBodyEffects = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBodyEffects, g_esTank[iType].g_iBodyEffects);
	g_esCache[tank].g_iBossStages = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossStages, g_esTank[iType].g_iBossStages);
	g_esCache[tank].g_iBulletImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iBulletImmunity, g_esGeneral.g_iBulletImmunity);
	g_esCache[tank].g_iBulletImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBulletImmunity, g_esCache[tank].g_iBulletImmunity);
	g_esCache[tank].g_iCheckAbilities = iGetSettingValue(bAccess, true, g_esTank[iType].g_iCheckAbilities, g_esGeneral.g_iCheckAbilities);
	g_esCache[tank].g_iCheckAbilities = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iCheckAbilities, g_esCache[tank].g_iCheckAbilities);
	g_esCache[tank].g_iDeathDetails = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathDetails, g_esGeneral.g_iDeathDetails);
	g_esCache[tank].g_iDeathDetails = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathDetails, g_esCache[tank].g_iDeathDetails);
	g_esCache[tank].g_iDeathMessage = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathMessage, g_esGeneral.g_iDeathMessage);
	g_esCache[tank].g_iDeathMessage = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathMessage, g_esCache[tank].g_iDeathMessage);
	g_esCache[tank].g_iDeathRevert = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathRevert, g_esGeneral.g_iDeathRevert);
	g_esCache[tank].g_iDeathRevert = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathRevert, g_esCache[tank].g_iDeathRevert);
	g_esCache[tank].g_iDeathSound = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathSound, g_esGeneral.g_iDeathSound);
	g_esCache[tank].g_iDeathSound = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathSound, g_esCache[tank].g_iDeathSound);
	g_esCache[tank].g_iDisplayHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDisplayHealth, g_esGeneral.g_iDisplayHealth);
	g_esCache[tank].g_iDisplayHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDisplayHealth, g_esCache[tank].g_iDisplayHealth);
	g_esCache[tank].g_iDisplayHealthType = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDisplayHealthType, g_esGeneral.g_iDisplayHealthType);
	g_esCache[tank].g_iDisplayHealthType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDisplayHealthType, g_esCache[tank].g_iDisplayHealthType);
	g_esCache[tank].g_iExplosiveImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iExplosiveImmunity, g_esGeneral.g_iExplosiveImmunity);
	g_esCache[tank].g_iExplosiveImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iExplosiveImmunity, g_esCache[tank].g_iExplosiveImmunity);
	g_esCache[tank].g_iExtraHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iExtraHealth, g_esGeneral.g_iExtraHealth, 2);
	g_esCache[tank].g_iExtraHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iExtraHealth, g_esCache[tank].g_iExtraHealth, 2);
	g_esCache[tank].g_iFireImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iFireImmunity, g_esGeneral.g_iFireImmunity);
	g_esCache[tank].g_iFireImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFireImmunity, g_esCache[tank].g_iFireImmunity);
	g_esCache[tank].g_iGlowEnabled = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowEnabled, g_esTank[iType].g_iGlowEnabled);
	g_esCache[tank].g_iGlowFlashing = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowFlashing, g_esTank[iType].g_iGlowFlashing);
	g_esCache[tank].g_iGlowMaxRange = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowMaxRange, g_esTank[iType].g_iGlowMaxRange);
	g_esCache[tank].g_iGlowMinRange = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowMinRange, g_esTank[iType].g_iGlowMinRange);
	g_esCache[tank].g_iGlowType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowType, g_esTank[iType].g_iGlowType);
	g_esCache[tank].g_iHittableImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iHittableImmunity, g_esGeneral.g_iHittableImmunity);
	g_esCache[tank].g_iHittableImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iHittableImmunity, g_esCache[tank].g_iHittableImmunity);
	g_esCache[tank].g_iKillMessage = iGetSettingValue(bAccess, true, g_esTank[iType].g_iKillMessage, g_esGeneral.g_iKillMessage);
	g_esCache[tank].g_iKillMessage = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iKillMessage, g_esCache[tank].g_iKillMessage);
	g_esCache[tank].g_iMeleeImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMeleeImmunity, g_esGeneral.g_iMeleeImmunity);
	g_esCache[tank].g_iMeleeImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMeleeImmunity, g_esCache[tank].g_iMeleeImmunity);
	g_esCache[tank].g_iMinimumHumans = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMinimumHumans, g_esGeneral.g_iMinimumHumans);
	g_esCache[tank].g_iMinimumHumans = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMinimumHumans, g_esCache[tank].g_iMinimumHumans);
	g_esCache[tank].g_iMultiplyHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMultiplyHealth, g_esGeneral.g_iMultiplyHealth);
	g_esCache[tank].g_iMultiplyHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMultiplyHealth, g_esCache[tank].g_iMultiplyHealth);
	g_esCache[tank].g_iPropsAttached = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iPropsAttached, g_esTank[iType].g_iPropsAttached);
	g_esCache[tank].g_iRandomTank = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRandomTank, g_esTank[iType].g_iRandomTank);
	g_esCache[tank].g_iRockEffects = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockEffects, g_esTank[iType].g_iRockEffects);
	g_esCache[tank].g_iRockModel = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockModel, g_esTank[iType].g_iRockModel);
	g_esCache[tank].g_iSkipTaunt = iGetSettingValue(bAccess, true, g_esTank[iType].g_iSkipTaunt, g_esGeneral.g_iSkipTaunt);
	g_esCache[tank].g_iSkipTaunt = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSkipTaunt, g_esCache[tank].g_iSkipTaunt);
	g_esCache[tank].g_iSpawnType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSpawnType, g_esTank[iType].g_iSpawnType);
	g_esCache[tank].g_iSweepFist = iGetSettingValue(bAccess, true, g_esTank[iType].g_iSweepFist, g_esGeneral.g_iSweepFist);
	g_esCache[tank].g_iSweepFist = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSweepFist, g_esCache[tank].g_iSweepFist);
	g_esCache[tank].g_iTankEnabled = iGetSettingValue(bAccess, true, g_esTank[iType].g_iTankEnabled, g_esGeneral.g_iTankEnabled, 1);
	g_esCache[tank].g_iTankModel = iGetSettingValue(bAccess, true, g_esTank[iType].g_iTankModel, g_esGeneral.g_iTankModel);
	g_esCache[tank].g_iTankModel = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTankModel, g_esCache[tank].g_iTankModel);
	g_esCache[tank].g_iTankNote = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTankNote, g_esTank[iType].g_iTankNote);
	g_esCache[tank].g_iTeammateLimit = iGetSettingValue(bAccess, true, g_esTank[iType].g_iTeammateLimit, g_esGeneral.g_iTeammateLimit);
	g_esCache[tank].g_iTeammateLimit = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTeammateLimit, g_esCache[tank].g_iTeammateLimit);
	g_esCache[tank].g_iVocalizeArrival = iGetSettingValue(bAccess, true, g_esTank[iType].g_iVocalizeArrival, g_esGeneral.g_iVocalizeArrival);
	g_esCache[tank].g_iVocalizeArrival = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iVocalizeArrival, g_esCache[tank].g_iVocalizeArrival);
	g_esCache[tank].g_iVocalizeDeath = iGetSettingValue(bAccess, true, g_esTank[iType].g_iVocalizeDeath, g_esGeneral.g_iVocalizeDeath);
	g_esCache[tank].g_iVocalizeDeath = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iVocalizeDeath, g_esCache[tank].g_iVocalizeDeath);
	g_esCache[tank].g_iVomitImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iVomitImmunity, g_esGeneral.g_iVomitImmunity);
	g_esCache[tank].g_iVomitImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iVomitImmunity, g_esCache[tank].g_iVomitImmunity);

	vGetSettingValue(bAccess, true, g_esCache[tank].g_sBodyColorVisual, sizeof(esCache::g_sBodyColorVisual), g_esTank[iType].g_sBodyColorVisual, g_esGeneral.g_sBodyColorVisual);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sBodyColorVisual, sizeof(esCache::g_sBodyColorVisual), g_esPlayer[tank].g_sBodyColorVisual, g_esCache[tank].g_sBodyColorVisual);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sBodyColorVisual2, sizeof(esCache::g_sBodyColorVisual2), g_esTank[iType].g_sBodyColorVisual2, g_esGeneral.g_sBodyColorVisual2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sBodyColorVisual2, sizeof(esCache::g_sBodyColorVisual2), g_esPlayer[tank].g_sBodyColorVisual2, g_esCache[tank].g_sBodyColorVisual2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sBodyColorVisual3, sizeof(esCache::g_sBodyColorVisual3), g_esTank[iType].g_sBodyColorVisual3, g_esGeneral.g_sBodyColorVisual3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sBodyColorVisual3, sizeof(esCache::g_sBodyColorVisual3), g_esPlayer[tank].g_sBodyColorVisual3, g_esCache[tank].g_sBodyColorVisual3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sBodyColorVisual4, sizeof(esCache::g_sBodyColorVisual4), g_esTank[iType].g_sBodyColorVisual4, g_esGeneral.g_sBodyColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sBodyColorVisual4, sizeof(esCache::g_sBodyColorVisual4), g_esPlayer[tank].g_sBodyColorVisual4, g_esCache[tank].g_sBodyColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sComboSet, sizeof(esCache::g_sComboSet), g_esPlayer[tank].g_sComboSet, g_esTank[iType].g_sComboSet);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sFallVoicelineReward, sizeof(esCache::g_sFallVoicelineReward), g_esTank[iType].g_sFallVoicelineReward, g_esGeneral.g_sFallVoicelineReward);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFallVoicelineReward, sizeof(esCache::g_sFallVoicelineReward), g_esPlayer[tank].g_sFallVoicelineReward, g_esCache[tank].g_sFallVoicelineReward);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sFallVoicelineReward2, sizeof(esCache::g_sFallVoicelineReward2), g_esTank[iType].g_sFallVoicelineReward2, g_esGeneral.g_sFallVoicelineReward2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFallVoicelineReward2, sizeof(esCache::g_sFallVoicelineReward2), g_esPlayer[tank].g_sFallVoicelineReward2, g_esCache[tank].g_sFallVoicelineReward2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sFallVoicelineReward3, sizeof(esCache::g_sFallVoicelineReward3), g_esTank[iType].g_sFallVoicelineReward3, g_esGeneral.g_sFallVoicelineReward3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFallVoicelineReward3, sizeof(esCache::g_sFallVoicelineReward3), g_esPlayer[tank].g_sFallVoicelineReward3, g_esCache[tank].g_sFallVoicelineReward3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sFallVoicelineReward4, sizeof(esCache::g_sFallVoicelineReward4), g_esTank[iType].g_sFallVoicelineReward4, g_esGeneral.g_sFallVoicelineReward4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFallVoicelineReward4, sizeof(esCache::g_sFallVoicelineReward4), g_esPlayer[tank].g_sFallVoicelineReward4, g_esCache[tank].g_sFallVoicelineReward4);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sGlowColorVisual, sizeof(esCache::g_sGlowColorVisual), g_esTank[iType].g_sGlowColorVisual, g_esGeneral.g_sGlowColorVisual);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sGlowColorVisual, sizeof(esCache::g_sGlowColorVisual), g_esPlayer[tank].g_sGlowColorVisual, g_esCache[tank].g_sGlowColorVisual);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sGlowColorVisual2, sizeof(esCache::g_sGlowColorVisual2), g_esTank[iType].g_sGlowColorVisual2, g_esGeneral.g_sGlowColorVisual2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sGlowColorVisual2, sizeof(esCache::g_sGlowColorVisual2), g_esPlayer[tank].g_sGlowColorVisual2, g_esCache[tank].g_sGlowColorVisual2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sGlowColorVisual3, sizeof(esCache::g_sGlowColorVisual3), g_esTank[iType].g_sGlowColorVisual3, g_esGeneral.g_sGlowColorVisual3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sGlowColorVisual3, sizeof(esCache::g_sGlowColorVisual3), g_esPlayer[tank].g_sGlowColorVisual3, g_esCache[tank].g_sGlowColorVisual3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sGlowColorVisual4, sizeof(esCache::g_sGlowColorVisual4), g_esTank[iType].g_sGlowColorVisual4, g_esGeneral.g_sGlowColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sGlowColorVisual4, sizeof(esCache::g_sGlowColorVisual4), g_esPlayer[tank].g_sGlowColorVisual4, g_esCache[tank].g_sGlowColorVisual4);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sHealthCharacters, sizeof(esCache::g_sHealthCharacters), g_esTank[iType].g_sHealthCharacters, g_esGeneral.g_sHealthCharacters);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sHealthCharacters, sizeof(esCache::g_sHealthCharacters), g_esPlayer[tank].g_sHealthCharacters, g_esCache[tank].g_sHealthCharacters);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward, sizeof(esCache::g_sItemReward), g_esTank[iType].g_sItemReward, g_esGeneral.g_sItemReward);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward, sizeof(esCache::g_sItemReward), g_esPlayer[tank].g_sItemReward, g_esCache[tank].g_sItemReward);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward2, sizeof(esCache::g_sItemReward2), g_esTank[iType].g_sItemReward2, g_esGeneral.g_sItemReward2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward2, sizeof(esCache::g_sItemReward2), g_esPlayer[tank].g_sItemReward2, g_esCache[tank].g_sItemReward2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward3, sizeof(esCache::g_sItemReward3), g_esTank[iType].g_sItemReward3, g_esGeneral.g_sItemReward3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward3, sizeof(esCache::g_sItemReward3), g_esPlayer[tank].g_sItemReward3, g_esCache[tank].g_sItemReward3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward4, sizeof(esCache::g_sItemReward4), g_esTank[iType].g_sItemReward4, g_esGeneral.g_sItemReward4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward4, sizeof(esCache::g_sItemReward4), g_esPlayer[tank].g_sItemReward4, g_esCache[tank].g_sItemReward4);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLoopingVoicelineVisual, sizeof(esCache::g_sLoopingVoicelineVisual), g_esTank[iType].g_sLoopingVoicelineVisual, g_esGeneral.g_sLoopingVoicelineVisual);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLoopingVoicelineVisual, sizeof(esCache::g_sLoopingVoicelineVisual), g_esPlayer[tank].g_sLoopingVoicelineVisual, g_esCache[tank].g_sLoopingVoicelineVisual);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLoopingVoicelineVisual2, sizeof(esCache::g_sLoopingVoicelineVisual2), g_esTank[iType].g_sLoopingVoicelineVisual2, g_esGeneral.g_sLoopingVoicelineVisual2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLoopingVoicelineVisual2, sizeof(esCache::g_sLoopingVoicelineVisual2), g_esPlayer[tank].g_sLoopingVoicelineVisual2, g_esCache[tank].g_sLoopingVoicelineVisual2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLoopingVoicelineVisual3, sizeof(esCache::g_sLoopingVoicelineVisual3), g_esTank[iType].g_sLoopingVoicelineVisual3, g_esGeneral.g_sLoopingVoicelineVisual3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLoopingVoicelineVisual3, sizeof(esCache::g_sLoopingVoicelineVisual3), g_esPlayer[tank].g_sLoopingVoicelineVisual3, g_esCache[tank].g_sLoopingVoicelineVisual3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLoopingVoicelineVisual4, sizeof(esCache::g_sLoopingVoicelineVisual4), g_esTank[iType].g_sLoopingVoicelineVisual4, g_esGeneral.g_sLoopingVoicelineVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLoopingVoicelineVisual4, sizeof(esCache::g_sLoopingVoicelineVisual4), g_esPlayer[tank].g_sLoopingVoicelineVisual4, g_esCache[tank].g_sLoopingVoicelineVisual4);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sScreenColorVisual, sizeof(esCache::g_sScreenColorVisual), g_esTank[iType].g_sScreenColorVisual, g_esGeneral.g_sScreenColorVisual);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sScreenColorVisual, sizeof(esCache::g_sScreenColorVisual), g_esPlayer[tank].g_sScreenColorVisual, g_esCache[tank].g_sScreenColorVisual);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sScreenColorVisual2, sizeof(esCache::g_sScreenColorVisual2), g_esTank[iType].g_sScreenColorVisual2, g_esGeneral.g_sScreenColorVisual2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sScreenColorVisual2, sizeof(esCache::g_sScreenColorVisual2), g_esPlayer[tank].g_sScreenColorVisual2, g_esCache[tank].g_sScreenColorVisual2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sScreenColorVisual3, sizeof(esCache::g_sScreenColorVisual3), g_esTank[iType].g_sScreenColorVisual3, g_esGeneral.g_sScreenColorVisual3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sScreenColorVisual3, sizeof(esCache::g_sScreenColorVisual3), g_esPlayer[tank].g_sScreenColorVisual3, g_esCache[tank].g_sScreenColorVisual3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sScreenColorVisual4, sizeof(esCache::g_sScreenColorVisual4), g_esTank[iType].g_sScreenColorVisual4, g_esGeneral.g_sScreenColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sScreenColorVisual4, sizeof(esCache::g_sScreenColorVisual4), g_esPlayer[tank].g_sScreenColorVisual4, g_esCache[tank].g_sScreenColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sTankName, sizeof(esCache::g_sTankName), g_esPlayer[tank].g_sTankName, g_esTank[iType].g_sTankName);

	for (int iPos = 0; iPos < sizeof(esCache::g_iTransformType); iPos++)
	{
		g_esCache[tank].g_iTransformType[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTransformType[iPos], g_esTank[iType].g_iTransformType[iPos]);

		if (iPos < sizeof(esCache::g_iRewardEnabled))
		{
			g_esCache[tank].g_flActionDurationReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flActionDurationReward[iPos], g_esGeneral.g_flActionDurationReward[iPos]);
			g_esCache[tank].g_flActionDurationReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flActionDurationReward[iPos], g_esCache[tank].g_flActionDurationReward[iPos]);
			g_esCache[tank].g_iAmmoBoostReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAmmoBoostReward[iPos], g_esGeneral.g_iAmmoBoostReward[iPos]);
			g_esCache[tank].g_iAmmoBoostReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAmmoBoostReward[iPos], g_esCache[tank].g_iAmmoBoostReward[iPos]);
			g_esCache[tank].g_iAmmoRegenReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAmmoRegenReward[iPos], g_esGeneral.g_iAmmoRegenReward[iPos]);
			g_esCache[tank].g_iAmmoRegenReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAmmoRegenReward[iPos], g_esCache[tank].g_iAmmoRegenReward[iPos]);
			g_esCache[tank].g_flAttackBoostReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flAttackBoostReward[iPos], g_esGeneral.g_flAttackBoostReward[iPos]);
			g_esCache[tank].g_flAttackBoostReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flAttackBoostReward[iPos], g_esCache[tank].g_flAttackBoostReward[iPos]);
			g_esCache[tank].g_iCleanKillsReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iCleanKillsReward[iPos], g_esGeneral.g_iCleanKillsReward[iPos]);
			g_esCache[tank].g_iCleanKillsReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iCleanKillsReward[iPos], g_esCache[tank].g_iCleanKillsReward[iPos]);
			g_esCache[tank].g_flDamageBoostReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flDamageBoostReward[iPos], g_esGeneral.g_flDamageBoostReward[iPos]);
			g_esCache[tank].g_flDamageBoostReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flDamageBoostReward[iPos], g_esCache[tank].g_flDamageBoostReward[iPos]);
			g_esCache[tank].g_flDamageResistanceReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flDamageResistanceReward[iPos], g_esGeneral.g_flDamageResistanceReward[iPos]);
			g_esCache[tank].g_flDamageResistanceReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flDamageResistanceReward[iPos], g_esCache[tank].g_flDamageResistanceReward[iPos]);
			g_esCache[tank].g_flHealPercentReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flHealPercentReward[iPos], g_esGeneral.g_flHealPercentReward[iPos]);
			g_esCache[tank].g_flHealPercentReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flHealPercentReward[iPos], g_esCache[tank].g_flHealPercentReward[iPos]);
			g_esCache[tank].g_iHealthRegenReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iHealthRegenReward[iPos], g_esGeneral.g_iHealthRegenReward[iPos]);
			g_esCache[tank].g_iHealthRegenReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iHealthRegenReward[iPos], g_esCache[tank].g_iHealthRegenReward[iPos]);
			g_esCache[tank].g_iHollowpointAmmoReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iHollowpointAmmoReward[iPos], g_esGeneral.g_iHollowpointAmmoReward[iPos]);
			g_esCache[tank].g_iHollowpointAmmoReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iHollowpointAmmoReward[iPos], g_esCache[tank].g_iHollowpointAmmoReward[iPos]);
			g_esCache[tank].g_flJumpHeightReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flJumpHeightReward[iPos], g_esGeneral.g_flJumpHeightReward[iPos]);
			g_esCache[tank].g_flJumpHeightReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flJumpHeightReward[iPos], g_esCache[tank].g_flJumpHeightReward[iPos]);
			g_esCache[tank].g_iInfiniteAmmoReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iInfiniteAmmoReward[iPos], g_esGeneral.g_iInfiniteAmmoReward[iPos]);
			g_esCache[tank].g_iInfiniteAmmoReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iInfiniteAmmoReward[iPos], g_esCache[tank].g_iInfiniteAmmoReward[iPos]);
			g_esCache[tank].g_iLadyKillerReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iLadyKillerReward[iPos], g_esGeneral.g_iLadyKillerReward[iPos]);
			g_esCache[tank].g_iLadyKillerReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iLadyKillerReward[iPos], g_esCache[tank].g_iLadyKillerReward[iPos]);
			g_esCache[tank].g_iLifeLeechReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iLifeLeechReward[iPos], g_esGeneral.g_iLifeLeechReward[iPos]);
			g_esCache[tank].g_iLifeLeechReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iLifeLeechReward[iPos], g_esCache[tank].g_iLifeLeechReward[iPos]);
			g_esCache[tank].g_iMeleeRangeReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMeleeRangeReward[iPos], g_esGeneral.g_iMeleeRangeReward[iPos]);
			g_esCache[tank].g_iMeleeRangeReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMeleeRangeReward[iPos], g_esCache[tank].g_iMeleeRangeReward[iPos]);
			g_esCache[tank].g_iParticleEffectVisual[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iParticleEffectVisual[iPos], g_esGeneral.g_iParticleEffectVisual[iPos]);
			g_esCache[tank].g_iParticleEffectVisual[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iParticleEffectVisual[iPos], g_esCache[tank].g_iParticleEffectVisual[iPos]);
			g_esCache[tank].g_iPrefsNotify[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iPrefsNotify[iPos], g_esGeneral.g_iPrefsNotify[iPos]);
			g_esCache[tank].g_iPrefsNotify[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iPrefsNotify[iPos], g_esCache[tank].g_iPrefsNotify[iPos]);
			g_esCache[tank].g_flPunchResistanceReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flPunchResistanceReward[iPos], g_esGeneral.g_flPunchResistanceReward[iPos]);
			g_esCache[tank].g_flPunchResistanceReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flPunchResistanceReward[iPos], g_esCache[tank].g_flPunchResistanceReward[iPos]);
			g_esCache[tank].g_iRespawnLoadoutReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRespawnLoadoutReward[iPos], g_esGeneral.g_iRespawnLoadoutReward[iPos]);
			g_esCache[tank].g_iRespawnLoadoutReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRespawnLoadoutReward[iPos], g_esCache[tank].g_iRespawnLoadoutReward[iPos]);
			g_esCache[tank].g_iReviveHealthReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iReviveHealthReward[iPos], g_esGeneral.g_iReviveHealthReward[iPos]);
			g_esCache[tank].g_iReviveHealthReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iReviveHealthReward[iPos], g_esCache[tank].g_iReviveHealthReward[iPos]);
			g_esCache[tank].g_iRewardBots[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardBots[iPos], g_esGeneral.g_iRewardBots[iPos], 1);
			g_esCache[tank].g_iRewardBots[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardBots[iPos], g_esCache[tank].g_iRewardBots[iPos], 1);
			g_esCache[tank].g_flRewardChance[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRewardChance[iPos], g_esGeneral.g_flRewardChance[iPos]);
			g_esCache[tank].g_flRewardChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRewardChance[iPos], g_esCache[tank].g_flRewardChance[iPos]);
			g_esCache[tank].g_flRewardDuration[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRewardDuration[iPos], g_esGeneral.g_flRewardDuration[iPos]);
			g_esCache[tank].g_flRewardDuration[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRewardDuration[iPos], g_esCache[tank].g_flRewardDuration[iPos]);
			g_esCache[tank].g_iRewardEffect[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardEffect[iPos], g_esGeneral.g_iRewardEffect[iPos]);
			g_esCache[tank].g_iRewardEffect[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardEffect[iPos], g_esCache[tank].g_iRewardEffect[iPos]);
			g_esCache[tank].g_iRewardEnabled[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardEnabled[iPos], g_esGeneral.g_iRewardEnabled[iPos], 1);
			g_esCache[tank].g_iRewardEnabled[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardEnabled[iPos], g_esCache[tank].g_iRewardEnabled[iPos], 1);
			g_esCache[tank].g_iRewardNotify[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardNotify[iPos], g_esGeneral.g_iRewardNotify[iPos]);
			g_esCache[tank].g_iRewardNotify[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardNotify[iPos], g_esCache[tank].g_iRewardNotify[iPos]);
			g_esCache[tank].g_flRewardPercentage[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRewardPercentage[iPos], g_esGeneral.g_flRewardPercentage[iPos]);
			g_esCache[tank].g_flRewardPercentage[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRewardPercentage[iPos], g_esCache[tank].g_flRewardPercentage[iPos]);
			g_esCache[tank].g_iRewardPriority[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardPriority[iPos], g_esGeneral.g_iRewardPriority[iPos]);
			g_esCache[tank].g_iRewardPriority[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardPriority[iPos], g_esCache[tank].g_iRewardPriority[iPos]);
			g_esCache[tank].g_iRewardVisual[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardVisual[iPos], g_esGeneral.g_iRewardVisual[iPos]);
			g_esCache[tank].g_iRewardVisual[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardVisual[iPos], g_esCache[tank].g_iRewardVisual[iPos]);
			g_esCache[tank].g_flShoveDamageReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flShoveDamageReward[iPos], g_esGeneral.g_flShoveDamageReward[iPos]);
			g_esCache[tank].g_flShoveDamageReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flShoveDamageReward[iPos], g_esCache[tank].g_flShoveDamageReward[iPos]);
			g_esCache[tank].g_iShovePenaltyReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iShovePenaltyReward[iPos], g_esGeneral.g_iShovePenaltyReward[iPos]);
			g_esCache[tank].g_iShovePenaltyReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iShovePenaltyReward[iPos], g_esCache[tank].g_iShovePenaltyReward[iPos]);
			g_esCache[tank].g_flShoveRateReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flShoveRateReward[iPos], g_esGeneral.g_flShoveRateReward[iPos]);
			g_esCache[tank].g_flShoveRateReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flShoveRateReward[iPos], g_esCache[tank].g_flShoveRateReward[iPos]);
			g_esCache[tank].g_iSledgehammerRoundsReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iSledgehammerRoundsReward[iPos], g_esGeneral.g_iSledgehammerRoundsReward[iPos]);
			g_esCache[tank].g_iSledgehammerRoundsReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSledgehammerRoundsReward[iPos], g_esCache[tank].g_iSledgehammerRoundsReward[iPos]);
			g_esCache[tank].g_iSpecialAmmoReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iSpecialAmmoReward[iPos], g_esGeneral.g_iSpecialAmmoReward[iPos]);
			g_esCache[tank].g_iSpecialAmmoReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSpecialAmmoReward[iPos], g_esCache[tank].g_iSpecialAmmoReward[iPos]);
			g_esCache[tank].g_flSpeedBoostReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flSpeedBoostReward[iPos], g_esGeneral.g_flSpeedBoostReward[iPos]);
			g_esCache[tank].g_flSpeedBoostReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flSpeedBoostReward[iPos], g_esCache[tank].g_flSpeedBoostReward[iPos]);
			g_esCache[tank].g_iStackRewards[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iStackRewards[iPos], g_esGeneral.g_iStackRewards[iPos]);
			g_esCache[tank].g_iStackRewards[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iStackRewards[iPos], g_esCache[tank].g_iStackRewards[iPos]);
			g_esCache[tank].g_iThornsReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iThornsReward[iPos], g_esGeneral.g_iThornsReward[iPos]);
			g_esCache[tank].g_iThornsReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iThornsReward[iPos], g_esCache[tank].g_iThornsReward[iPos]);
			g_esCache[tank].g_iUsefulRewards[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iUsefulRewards[iPos], g_esGeneral.g_iUsefulRewards[iPos]);
			g_esCache[tank].g_iUsefulRewards[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iUsefulRewards[iPos], g_esCache[tank].g_iUsefulRewards[iPos]);
		}

		if (iPos < sizeof(esCache::g_flComboChance))
		{
			g_esCache[tank].g_flComboChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboChance[iPos], g_esTank[iType].g_flComboChance[iPos]);
			g_esCache[tank].g_flComboDamage[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDamage[iPos], g_esTank[iType].g_flComboDamage[iPos]);
			g_esCache[tank].g_flComboDeathChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDeathChance[iPos], g_esTank[iType].g_flComboDeathChance[iPos]);
			g_esCache[tank].g_flComboDeathRange[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDeathRange[iPos], g_esTank[iType].g_flComboDeathRange[iPos]);
			g_esCache[tank].g_flComboDelay[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDelay[iPos], g_esTank[iType].g_flComboDelay[iPos]);
			g_esCache[tank].g_flComboDuration[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDuration[iPos], g_esTank[iType].g_flComboDuration[iPos]);
			g_esCache[tank].g_flComboInterval[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboInterval[iPos], g_esTank[iType].g_flComboInterval[iPos]);
			g_esCache[tank].g_flComboMinRadius[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboMinRadius[iPos], g_esTank[iType].g_flComboMinRadius[iPos]);
			g_esCache[tank].g_flComboMaxRadius[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboMaxRadius[iPos], g_esTank[iType].g_flComboMaxRadius[iPos]);
			g_esCache[tank].g_flComboRange[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboRange[iPos], g_esTank[iType].g_flComboRange[iPos]);
			g_esCache[tank].g_flComboRangeChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboRangeChance[iPos], g_esTank[iType].g_flComboRangeChance[iPos]);
			g_esCache[tank].g_flComboRockChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboRockChance[iPos], g_esTank[iType].g_flComboRockChance[iPos]);
			g_esCache[tank].g_flComboSpeed[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboSpeed[iPos], g_esTank[iType].g_flComboSpeed[iPos]);
		}

		if (iPos < sizeof(esCache::g_flComboTypeChance))
		{
			g_esCache[tank].g_flComboTypeChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboTypeChance[iPos], g_esTank[iType].g_flComboTypeChance[iPos]);
		}

		if (iPos < sizeof(esCache::g_flPropsChance))
		{
			g_esCache[tank].g_flPropsChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flPropsChance[iPos], g_esTank[iType].g_flPropsChance[iPos]);
		}

		if (iPos < sizeof(esCache::g_iSkinColor))
		{
			g_esCache[tank].g_iSkinColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSkinColor[iPos], g_esTank[iType].g_iSkinColor[iPos], 1);
			g_esCache[tank].g_iBossHealth[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossHealth[iPos], g_esTank[iType].g_iBossHealth[iPos]);
			g_esCache[tank].g_iBossType[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossType[iPos], g_esTank[iType].g_iBossType[iPos]);
			g_esCache[tank].g_iLightColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iLightColor[iPos], g_esTank[iType].g_iLightColor[iPos], 1);
			g_esCache[tank].g_iOzTankColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iOzTankColor[iPos], g_esTank[iType].g_iOzTankColor[iPos], 1);
			g_esCache[tank].g_iFlameColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFlameColor[iPos], g_esTank[iType].g_iFlameColor[iPos], 1);
			g_esCache[tank].g_iRockColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockColor[iPos], g_esTank[iType].g_iRockColor[iPos], 1);
			g_esCache[tank].g_iTireColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTireColor[iPos], g_esTank[iType].g_iTireColor[iPos], 1);
			g_esCache[tank].g_iPropTankColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iPropTankColor[iPos], g_esTank[iType].g_iPropTankColor[iPos], 1);
			g_esCache[tank].g_iFlashlightColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFlashlightColor[iPos], g_esTank[iType].g_iFlashlightColor[iPos], 1);
			g_esCache[tank].g_iCrownColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iCrownColor[iPos], g_esTank[iType].g_iCrownColor[iPos], 1);
		}

		if (iPos < sizeof(esCache::g_iGlowColor))
		{
			g_esCache[tank].g_iGlowColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowColor[iPos], g_esTank[iType].g_iGlowColor[iPos], 1);
		}
	}

	Call_StartForward(g_esGeneral.g_gfSettingsCachedForward);
	Call_PushCell(tank);
	Call_PushCell(bAccess);
	Call_PushCell(iType);
	Call_Finish();
}

static void vClearAbilityList()
{
	for (int iPos = 0; iPos < sizeof(esGeneral::g_alAbilitySections); iPos++)
	{
		if (g_esGeneral.g_alAbilitySections[iPos] != null)
		{
			g_esGeneral.g_alAbilitySections[iPos].Clear();

			delete g_esGeneral.g_alAbilitySections[iPos];
		}
	}
}

static void vClearPluginList()
{
	if (g_esGeneral.g_alPlugins != null)
	{
		g_esGeneral.g_alPlugins.Clear();

		delete g_esGeneral.g_alPlugins;
	}
}

static void vClearSectionList()
{
	if (g_esGeneral.g_alSections != null)
	{
		g_esGeneral.g_alSections.Clear();

		delete g_esGeneral.g_alSections;
	}
}

static void vCombineAbilitiesForward(int tank, int type, int survivor = 0, int weapon = 0, const char[] classname = "")
{
	if (bIsTankSupported(tank) && bIsCustomTankSupported(tank) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flComboTypeChance[type] && g_esPlayer[tank].g_bCombo)
	{
		Call_StartForward(g_esGeneral.g_gfCombineAbilitiesForward);
		Call_PushCell(tank);
		Call_PushCell(type);
		Call_PushFloat(GetRandomFloat(0.1, 100.0));
		Call_PushString(g_esCache[tank].g_sComboSet);
		Call_PushCell(survivor);
		Call_PushCell(weapon);
		Call_PushString(classname);
		Call_Finish();
	}
}

static void vCopySurvivorStats(int oldSurvivor, int newSurvivor)
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		g_esPlayer[newSurvivor].g_iTankDamage[iTank] = g_esPlayer[oldSurvivor].g_iTankDamage[iTank];
	}
}

static void vCopyTankStats(int tank, int newtank)
{
	SetEntProp(newtank, Prop_Data, "m_iMaxHealth", GetEntProp(tank, Prop_Data, "m_iMaxHealth"));

	g_esPlayer[newtank].g_bArtificial = g_esPlayer[tank].g_bArtificial;
	g_esPlayer[newtank].g_bBlood = g_esPlayer[tank].g_bBlood;
	g_esPlayer[newtank].g_bBlur = g_esPlayer[tank].g_bBlur;
	g_esPlayer[newtank].g_bBoss = g_esPlayer[tank].g_bBoss;
	g_esPlayer[newtank].g_bCombo = g_esPlayer[tank].g_bCombo;
	g_esPlayer[newtank].g_bElectric = g_esPlayer[tank].g_bElectric;
	g_esPlayer[newtank].g_bFire = g_esPlayer[tank].g_bFire;
	g_esPlayer[newtank].g_bFirstSpawn = g_esPlayer[tank].g_bFirstSpawn;
	g_esPlayer[newtank].g_bIce = g_esPlayer[tank].g_bIce;
	g_esPlayer[newtank].g_bKeepCurrentType = g_esPlayer[tank].g_bKeepCurrentType;
	g_esPlayer[newtank].g_bMeteor = g_esPlayer[tank].g_bMeteor;
	g_esPlayer[newtank].g_bNeedHealth = g_esPlayer[tank].g_bNeedHealth;
	g_esPlayer[newtank].g_bRandomized = g_esPlayer[tank].g_bRandomized;
	g_esPlayer[newtank].g_bSmoke = g_esPlayer[tank].g_bSmoke;
	g_esPlayer[newtank].g_bSpit = g_esPlayer[tank].g_bSpit;
	g_esPlayer[newtank].g_bTransformed = g_esPlayer[tank].g_bTransformed;
	g_esPlayer[newtank].g_bTriggered = g_esPlayer[tank].g_bTriggered;
	g_esPlayer[newtank].g_iBossStageCount = g_esPlayer[tank].g_iBossStageCount;
	g_esPlayer[newtank].g_iCooldown = g_esPlayer[tank].g_iCooldown;
	g_esPlayer[newtank].g_iOldTankType = g_esPlayer[tank].g_iOldTankType;
	g_esPlayer[newtank].g_iTankHealth = g_esPlayer[tank].g_iTankHealth;
	g_esPlayer[newtank].g_iTankType = g_esPlayer[tank].g_iTankType;

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		g_esPlayer[iSurvivor].g_iTankDamage[newtank] = g_esPlayer[iSurvivor].g_iTankDamage[tank];
	}

	if (bIsValidClient(newtank, MT_CHECK_FAKECLIENT) && g_esGeneral.g_iSpawnMode == 0)
	{
		vTankMenu(newtank);
	}

	Call_StartForward(g_esGeneral.g_gfCopyStatsForward);
	Call_PushCell(tank);
	Call_PushCell(newtank);
	Call_Finish();
}

static void vCustomConfig(const char[] savepath)
{
	DataPack dpConfig;
	CreateDataTimer(1.5, tTimerExecuteCustomConfig, dpConfig, TIMER_FLAG_NO_MAPCHANGE);
	dpConfig.WriteString(savepath);
}

static void vLoadConfigs(const char[] savepath, int mode)
{
	vClearAbilityList();
	vClearPluginList();

	g_esGeneral.g_alPlugins = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	if (g_esGeneral.g_alPlugins != null)
	{
		Call_StartForward(g_esGeneral.g_gfPluginCheckForward);
		Call_PushCell(g_esGeneral.g_alPlugins);
		Call_Finish();
	}

	static bool bFinish;
	bFinish = true;
	Call_StartForward(g_esGeneral.g_gfAbilityCheckForward);

	for (int iPos = 0; iPos < sizeof(esGeneral::g_alAbilitySections); iPos++)
	{
		g_esGeneral.g_alAbilitySections[iPos] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

		switch (g_esGeneral.g_alAbilitySections[iPos] != null)
		{
			case true: Call_PushCell(g_esGeneral.g_alAbilitySections[iPos]);
			case false:
			{
				bFinish = false;

				Call_Cancel();

				break;
			}
		}
	}

	if (bFinish)
	{
		Call_Finish();
	}

	for (int iPos = 0; iPos < MT_MAXABILITIES; iPos++)
	{
		g_esGeneral.g_bAbilityPlugin[iPos] = false;
	}

	if (g_esGeneral.g_alPlugins != null)
	{
		int iListSize = (g_esGeneral.g_alPlugins.Length > 0) ? g_esGeneral.g_alPlugins.Length : 0;
		if (iListSize > 0)
		{
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_bAbilityPlugin[iPos] = true;
			}
		}
	}

	g_esGeneral.g_iConfigMode = mode;

	if (g_esGeneral.g_alFilePaths != null)
	{
		static int iListSize;
		iListSize = (g_esGeneral.g_alFilePaths.Length > 0) ? g_esGeneral.g_alFilePaths.Length : 0;
		if (iListSize > 0)
		{
			static bool bAdd;
			bAdd = true;
			static char sFilePath[PLATFORM_MAX_PATH];
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_alFilePaths.GetString(iPos, sFilePath, sizeof(sFilePath));
				if (StrEqual(savepath, sFilePath, false))
				{
					bAdd = false;

					break;
				}
			}

			if (bAdd)
			{
				g_esGeneral.g_alFilePaths.PushString(savepath);
			}
		}
		else
		{
			g_esGeneral.g_alFilePaths.PushString(savepath);
		}
	}

	SMCParser smcLoader = new SMCParser();
	if (smcLoader != null)
	{
		smcLoader.OnStart = SMCParseStart;
		smcLoader.OnEnterSection = SMCNewSection;
		smcLoader.OnKeyValue = SMCKeyValues;
		smcLoader.OnLeaveSection = SMCEndSection;
		smcLoader.OnEnd = SMCParseEnd;
		SMCError smcError = smcLoader.ParseFile(savepath);

		if (smcError != SMCError_Okay)
		{
			char sSmcError[64];
			smcLoader.GetErrorString(smcError, sSmcError, sizeof(sSmcError));
			LogError("%s %T", MT_TAG, "ErrorParsing", LANG_SERVER, savepath, sSmcError);
		}

		delete smcLoader;
	}
	else
	{
		LogError("%s %T", MT_TAG, "FailedParsing", LANG_SERVER, savepath);
	}
}

public void SMCParseStart(SMCParser smc)
{
	g_esGeneral.g_csState = ConfigState_None;
	g_esGeneral.g_iIgnoreLevel = 0;
	g_esGeneral.g_sCurrentSection[0] = '\0';
	g_esGeneral.g_sCurrentSubSection[0] = '\0';

	if (g_esGeneral.g_iConfigMode == 1)
	{
		g_esGeneral.g_iPluginEnabled = 0;
		g_esGeneral.g_iListenSupport = g_bDedicated ? 0 : 1;
		g_esGeneral.g_iCheckAbilities = 1;
		g_esGeneral.g_iDeathRevert = 1;
		g_esGeneral.g_iFinalesOnly = 0;
		g_esGeneral.g_flIdleCheck = 10.0;
		g_esGeneral.g_iIdleCheckMode = 2;
		g_esGeneral.g_iLogCommands = 31;
		g_esGeneral.g_iLogMessages = 0;
		g_esGeneral.g_iTankEnabled = -1;
		g_esGeneral.g_iTankModel = 0;
		g_esGeneral.g_flBurnDuration = 0.0;
		g_esGeneral.g_flBurntSkin = -1.0;
		g_esGeneral.g_iSpawnEnabled = -1;
		g_esGeneral.g_iSpawnLimit = 0;
		g_esGeneral.g_iMinType = 1;
		g_esGeneral.g_iMaxType = MT_MAXTYPES;
		g_esGeneral.g_iRequiresHumans = 0;
		g_esGeneral.g_iAnnounceArrival = 31;
		g_esGeneral.g_iAnnounceDeath = 1;
		g_esGeneral.g_iAnnounceKill = 1;
		g_esGeneral.g_iArrivalMessage = 0;
		g_esGeneral.g_iArrivalSound = 1;
		g_esGeneral.g_iDeathDetails = 5;
		g_esGeneral.g_iDeathMessage = 0;
		g_esGeneral.g_iDeathSound = 1;
		g_esGeneral.g_iKillMessage = 0;
		g_esGeneral.g_iVocalizeArrival = 1;
		g_esGeneral.g_iVocalizeDeath = 1;
		g_esGeneral.g_sBodyColorVisual = "-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1";
		g_esGeneral.g_sBodyColorVisual2 = "-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1";
		g_esGeneral.g_sBodyColorVisual3 = "-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1";
		g_esGeneral.g_sBodyColorVisual4 = "-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1";
		g_esGeneral.g_sFallVoicelineReward = "PlayerLaugh";
		g_esGeneral.g_sFallVoicelineReward2 = "PlayerLaugh";
		g_esGeneral.g_sFallVoicelineReward3 = "PlayerLaugh";
		g_esGeneral.g_sFallVoicelineReward4 = "PlayerLaugh";
		g_esGeneral.g_sGlowColorVisual = "-1;-1;-1,-1;-1;-1,-1;-1;-1";
		g_esGeneral.g_sGlowColorVisual2 = "-1;-1;-1,-1;-1;-1,-1;-1;-1";
		g_esGeneral.g_sGlowColorVisual3 = "-1;-1;-1,-1;-1;-1,-1;-1;-1";
		g_esGeneral.g_sGlowColorVisual4 = "-1;-1;-1,-1;-1;-1,-1;-1;-1";
		g_esGeneral.g_sItemReward = "first_aid_kit";
		g_esGeneral.g_sItemReward2 = "first_aid_kit";
		g_esGeneral.g_sItemReward3 = "first_aid_kit";
		g_esGeneral.g_sItemReward4 = "first_aid_kit";
		g_esGeneral.g_sLoopingVoicelineVisual = "PlayerDeath";
		g_esGeneral.g_sLoopingVoicelineVisual2 = "PlayerDeath";
		g_esGeneral.g_sLoopingVoicelineVisual3 = "PlayerDeath";
		g_esGeneral.g_sLoopingVoicelineVisual4 = "PlayerDeath";
		g_esGeneral.g_sScreenColorVisual = "-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1";
		g_esGeneral.g_sScreenColorVisual2 = "-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1";
		g_esGeneral.g_sScreenColorVisual3 = "-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1";
		g_esGeneral.g_sScreenColorVisual4 = "-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1";
		g_esGeneral.g_iTeammateLimit = 0;
		g_esGeneral.g_iAggressiveTanks = 0;
		g_esGeneral.g_iCreditIgniters = 1;
		g_esGeneral.g_flForceSpawn = 0.0;
		g_esGeneral.g_iStasisMode = 0;
		g_esGeneral.g_flSurvivalDelay = 0.1;
		g_esGeneral.g_iScaleDamage = 0;
		g_esGeneral.g_iBaseHealth = 0;
		g_esGeneral.g_iDisplayHealth = 11;
		g_esGeneral.g_iDisplayHealthType = 1;
		g_esGeneral.g_iExtraHealth = 0;
		g_esGeneral.g_sHealthCharacters = "|,-";
		g_esGeneral.g_iMinimumHumans = 2;
		g_esGeneral.g_iMultiplyHealth = 0;
		g_esGeneral.g_flAttackInterval = 0.0;
		g_esGeneral.g_flClawDamage = -1.0;
		g_esGeneral.g_flHittableDamage = -1.0;
		g_esGeneral.g_flPunchForce = -1.0;
		g_esGeneral.g_flPunchThrow = 0.0;
		g_esGeneral.g_flRockDamage = -1.0;
		g_esGeneral.g_flRunSpeed = 0.0;
		g_esGeneral.g_iSkipTaunt = 0;
		g_esGeneral.g_iSweepFist = 0;
		g_esGeneral.g_flThrowInterval = 0.0;
		g_esGeneral.g_iBulletImmunity = 0;
		g_esGeneral.g_iExplosiveImmunity = 0;
		g_esGeneral.g_iFireImmunity = 0;
		g_esGeneral.g_iHittableImmunity = 0;
		g_esGeneral.g_iMeleeImmunity = 0;
		g_esGeneral.g_iVomitImmunity = 0;
		g_esGeneral.g_iAllowDeveloper = 0;
		g_esGeneral.g_iAccessFlags = 0;
		g_esGeneral.g_iImmunityFlags = 0;
		g_esGeneral.g_iHumanCooldown = 600;
		g_esGeneral.g_iMasterControl = 0;
		g_esGeneral.g_iSpawnMode = 1;
		g_esGeneral.g_iLimitExtras = 1;
		g_esGeneral.g_flExtrasDelay = 0.1;
		g_esGeneral.g_iRegularAmount = 0;
		g_esGeneral.g_flRegularDelay = 10.0;
		g_esGeneral.g_flRegularInterval = 300.0;
		g_esGeneral.g_iRegularLimit = 999999;
		g_esGeneral.g_iRegularMinType = 1;
		g_esGeneral.g_iRegularMaxType = MT_MAXTYPES;
		g_esGeneral.g_iRegularMode = 0;
		g_esGeneral.g_iRegularWave = 0;
		g_esGeneral.g_iFinaleAmount = 0;
		g_esGeneral.g_iGameModeTypes = 0;
		g_esGeneral.g_sEnabledGameModes[0] = '\0';
		g_esGeneral.g_sDisabledGameModes[0] = '\0';
		g_esGeneral.g_iConfigEnable = 0;
		g_esGeneral.g_iConfigCreate = 0;
		g_esGeneral.g_iConfigExecute = 0;

		for (int iPos = 0; iPos < sizeof(esGeneral::g_iFinaleWave); iPos++)
		{
			g_esGeneral.g_iFinaleMaxTypes[iPos] = MT_MAXTYPES;
			g_esGeneral.g_iFinaleMinTypes[iPos] = 1;
			g_esGeneral.g_iFinaleWave[iPos] = 0;

			if (iPos < sizeof(esGeneral::g_iRewardEnabled))
			{
				g_esGeneral.g_iRewardEnabled[iPos] = -1;
				g_esGeneral.g_iRewardBots[iPos] = -1;
				g_esGeneral.g_flRewardChance[iPos] = 33.3;
				g_esGeneral.g_flRewardDuration[iPos] = 10.0;
				g_esGeneral.g_iRewardEffect[iPos] = 15;
				g_esGeneral.g_iRewardNotify[iPos] = 3;
				g_esGeneral.g_flRewardPercentage[iPos] = 10.0;
				g_esGeneral.g_iRewardPriority[iPos] = iPos + 1;
				g_esGeneral.g_iRewardVisual[iPos] = 31;
				g_esGeneral.g_flActionDurationReward[iPos] = 2.0;
				g_esGeneral.g_iAmmoBoostReward[iPos] = 1;
				g_esGeneral.g_iAmmoRegenReward[iPos] = 1;
				g_esGeneral.g_flAttackBoostReward[iPos] = 1.25;
				g_esGeneral.g_iCleanKillsReward[iPos] = 1;
				g_esGeneral.g_flDamageBoostReward[iPos] = 1.25;
				g_esGeneral.g_flDamageResistanceReward[iPos] = 0.5;
				g_esGeneral.g_flHealPercentReward[iPos] = 100.0;
				g_esGeneral.g_iHealthRegenReward[iPos] = 1;
				g_esGeneral.g_iHollowpointAmmoReward[iPos] = 1;
				g_esGeneral.g_flJumpHeightReward[iPos] = 75.0;
				g_esGeneral.g_iInfiniteAmmoReward[iPos] = 31;
				g_esGeneral.g_iLadyKillerReward[iPos] = 1;
				g_esGeneral.g_iLifeLeechReward[iPos] = 1;
				g_esGeneral.g_iMeleeRangeReward[iPos] = 150;
				g_esGeneral.g_iParticleEffectVisual[iPos] = 15;
				g_esGeneral.g_iPrefsNotify[iPos] = 1;
				g_esGeneral.g_flPunchResistanceReward[iPos] = 0.25;
				g_esGeneral.g_iRespawnLoadoutReward[iPos] = 1;
				g_esGeneral.g_iReviveHealthReward[iPos] = 100;
				g_esGeneral.g_flShoveDamageReward[iPos] = 0.025;
				g_esGeneral.g_iShovePenaltyReward[iPos] = 1;
				g_esGeneral.g_flShoveRateReward[iPos] = 0.7;
				g_esGeneral.g_iSledgehammerRoundsReward[iPos] = 1;
				g_esGeneral.g_iSpecialAmmoReward[iPos] = 3;
				g_esGeneral.g_flSpeedBoostReward[iPos] = 1.25;
				g_esGeneral.g_iStackRewards[iPos] = 1;
				g_esGeneral.g_iThornsReward[iPos] = 1;
				g_esGeneral.g_iUsefulRewards[iPos] = 15;
			}

			if (iPos < sizeof(esGeneral::g_flDifficultyDamage))
			{
				g_esGeneral.g_flDifficultyDamage[iPos] = 0.0;
			}
		}

		for (int iIndex = 0; iIndex <= MT_MAXTYPES; iIndex++)
		{
			FormatEx(g_esTank[iIndex].g_sTankName, sizeof(esTank::g_sTankName), "Tank", iIndex);

			g_esTank[iIndex].g_iAbilityCount = -1;
			g_esTank[iIndex].g_iGameType = 0;
			g_esTank[iIndex].g_iTankEnabled = -1;
			g_esTank[iIndex].g_flTankChance = 100.0;
			g_esTank[iIndex].g_iTankNote = 0;
			g_esTank[iIndex].g_iTankModel = 0;
			g_esTank[iIndex].g_flBurnDuration = 0.0;
			g_esTank[iIndex].g_flBurntSkin = -1.0;
			g_esTank[iIndex].g_iSpawnEnabled = 1;
			g_esTank[iIndex].g_iMenuEnabled = 1;
			g_esTank[iIndex].g_iCheckAbilities = 0;
			g_esTank[iIndex].g_iDeathRevert = 0;
			g_esTank[iIndex].g_iAnnounceArrival = 0;
			g_esTank[iIndex].g_iAnnounceDeath = 0;
			g_esTank[iIndex].g_iAnnounceKill = 0;
			g_esTank[iIndex].g_iArrivalMessage = 0;
			g_esTank[iIndex].g_iArrivalSound = 0;
			g_esTank[iIndex].g_iDeathDetails = 0;
			g_esTank[iIndex].g_iDeathMessage = 0;
			g_esTank[iIndex].g_iDeathSound = 0;
			g_esTank[iIndex].g_iKillMessage = 0;
			g_esTank[iIndex].g_iVocalizeArrival = 0;
			g_esTank[iIndex].g_iVocalizeDeath = 0;
			g_esTank[iIndex].g_sBodyColorVisual[0] = '\0';
			g_esTank[iIndex].g_sBodyColorVisual2[0] = '\0';
			g_esTank[iIndex].g_sBodyColorVisual3[0] = '\0';
			g_esTank[iIndex].g_sBodyColorVisual4[0] = '\0';
			g_esTank[iIndex].g_sFallVoicelineReward[0] = '\0';
			g_esTank[iIndex].g_sFallVoicelineReward2[0] = '\0';
			g_esTank[iIndex].g_sFallVoicelineReward3[0] = '\0';
			g_esTank[iIndex].g_sFallVoicelineReward4[0] = '\0';
			g_esTank[iIndex].g_sGlowColorVisual[0] = '\0';
			g_esTank[iIndex].g_sGlowColorVisual2[0] = '\0';
			g_esTank[iIndex].g_sGlowColorVisual3[0] = '\0';
			g_esTank[iIndex].g_sGlowColorVisual4[0] = '\0';
			g_esTank[iIndex].g_sItemReward[0] = '\0';
			g_esTank[iIndex].g_sItemReward2[0] = '\0';
			g_esTank[iIndex].g_sItemReward3[0] = '\0';
			g_esTank[iIndex].g_sItemReward4[0] = '\0';
			g_esTank[iIndex].g_sLoopingVoicelineVisual[0] = '\0';
			g_esTank[iIndex].g_sLoopingVoicelineVisual2[0] = '\0';
			g_esTank[iIndex].g_sLoopingVoicelineVisual3[0] = '\0';
			g_esTank[iIndex].g_sLoopingVoicelineVisual4[0] = '\0';
			g_esTank[iIndex].g_sScreenColorVisual[0] = '\0';
			g_esTank[iIndex].g_sScreenColorVisual2[0] = '\0';
			g_esTank[iIndex].g_sScreenColorVisual3[0] = '\0';
			g_esTank[iIndex].g_sScreenColorVisual4[0] = '\0';
			g_esTank[iIndex].g_iTeammateLimit = 0;
			g_esTank[iIndex].g_iBaseHealth = 0;
			g_esTank[iIndex].g_iDisplayHealth = 0;
			g_esTank[iIndex].g_iDisplayHealthType = 0;
			g_esTank[iIndex].g_iExtraHealth = 0;
			g_esTank[iIndex].g_sHealthCharacters[0] = '\0';
			g_esTank[iIndex].g_iMinimumHumans = 0;
			g_esTank[iIndex].g_iMultiplyHealth = 0;
			g_esTank[iIndex].g_iHumanSupport = 0;
			g_esTank[iIndex].g_iRequiresHumans = 0;
			g_esTank[iIndex].g_iGlowEnabled = 0;
			g_esTank[iIndex].g_iGlowFlashing = 0;
			g_esTank[iIndex].g_iGlowMinRange = 0;
			g_esTank[iIndex].g_iGlowMaxRange = 999999;
			g_esTank[iIndex].g_iGlowType = 0;
			g_esTank[iIndex].g_flOpenAreasOnly = 0.0;
			g_esTank[iIndex].g_iAccessFlags = 0;
			g_esTank[iIndex].g_iImmunityFlags = 0;
			g_esTank[iIndex].g_iTypeLimit = 32;
			g_esTank[iIndex].g_iFinaleTank = 0;
			g_esTank[iIndex].g_iBossStages = 4;
			g_esTank[iIndex].g_sComboSet[0] = '\0';
			g_esTank[iIndex].g_iRandomTank = 1;
			g_esTank[iIndex].g_flRandomDuration = 999999.0;
			g_esTank[iIndex].g_flRandomInterval = 5.0;
			g_esTank[iIndex].g_flTransformDelay = 10.0;
			g_esTank[iIndex].g_flTransformDuration = 10.0;
			g_esTank[iIndex].g_iSpawnType = 0;
			g_esTank[iIndex].g_iPropsAttached = g_bSecondGame ? 510 : 462;
			g_esTank[iIndex].g_iBodyEffects = 0;
			g_esTank[iIndex].g_iRockEffects = 0;
			g_esTank[iIndex].g_iRockModel = 2;
			g_esTank[iIndex].g_flAttackInterval = 0.0;
			g_esTank[iIndex].g_flClawDamage = -1.0;
			g_esTank[iIndex].g_flHittableDamage = -1.0;
			g_esTank[iIndex].g_flPunchForce = -1.0;
			g_esTank[iIndex].g_flPunchThrow = 0.0;
			g_esTank[iIndex].g_flRockDamage = -1.0;
			g_esTank[iIndex].g_flRunSpeed = 0.0;
			g_esTank[iIndex].g_iSkipTaunt = 0;
			g_esTank[iIndex].g_iSweepFist = 0;
			g_esTank[iIndex].g_flThrowInterval = 0.0;
			g_esTank[iIndex].g_iBulletImmunity = 0;
			g_esTank[iIndex].g_iExplosiveImmunity = 0;
			g_esTank[iIndex].g_iFireImmunity = 0;
			g_esTank[iIndex].g_iHittableImmunity = 0;
			g_esTank[iIndex].g_iMeleeImmunity = 0;
			g_esTank[iIndex].g_iVomitImmunity = 0;

			for (int iPos = 0; iPos < sizeof(esTank::g_iTransformType); iPos++)
			{
				g_esTank[iIndex].g_iTransformType[iPos] = iPos + 1;

				if (iPos < sizeof(esTank::g_iRewardEnabled))
				{
					g_esTank[iIndex].g_iRewardEnabled[iPos] = -1;
					g_esTank[iIndex].g_iRewardBots[iPos] = -1;
					g_esTank[iIndex].g_flRewardChance[iPos] = 0.0;
					g_esTank[iIndex].g_flRewardDuration[iPos] = 0.0;
					g_esTank[iIndex].g_iRewardEffect[iPos] = 0;
					g_esTank[iIndex].g_iRewardNotify[iPos] = 0;
					g_esTank[iIndex].g_flRewardPercentage[iPos] = 0.0;
					g_esTank[iIndex].g_iRewardPriority[iPos] = 0;
					g_esTank[iIndex].g_iRewardVisual[iPos] = 0;
					g_esTank[iIndex].g_flActionDurationReward[iPos] = 0.0;
					g_esTank[iIndex].g_iAmmoBoostReward[iPos] = 0;
					g_esTank[iIndex].g_iAmmoRegenReward[iPos] = 0;
					g_esTank[iIndex].g_flAttackBoostReward[iPos] = 0.0;
					g_esTank[iIndex].g_iCleanKillsReward[iPos] = 0;
					g_esTank[iIndex].g_flDamageBoostReward[iPos] = 0.0;
					g_esTank[iIndex].g_flDamageResistanceReward[iPos] = 0.0;
					g_esTank[iIndex].g_flHealPercentReward[iPos] = 0.0;
					g_esTank[iIndex].g_iHealthRegenReward[iPos] = 0;
					g_esTank[iIndex].g_iHollowpointAmmoReward[iPos] = 0;
					g_esTank[iIndex].g_flJumpHeightReward[iPos] = 0.0;
					g_esTank[iIndex].g_iInfiniteAmmoReward[iPos] = 0;
					g_esTank[iIndex].g_iLadyKillerReward[iPos] = 0;
					g_esTank[iIndex].g_iLifeLeechReward[iPos] = 0;
					g_esTank[iIndex].g_iMeleeRangeReward[iPos] = 0;
					g_esTank[iIndex].g_iParticleEffectVisual[iPos] = 0;
					g_esTank[iIndex].g_iPrefsNotify[iPos] = 0;
					g_esTank[iIndex].g_flPunchResistanceReward[iPos] = 0.0;
					g_esTank[iIndex].g_iRespawnLoadoutReward[iPos] = 0;
					g_esTank[iIndex].g_iReviveHealthReward[iPos] = 0;
					g_esTank[iIndex].g_flShoveDamageReward[iPos] = 0.0;
					g_esTank[iIndex].g_iShovePenaltyReward[iPos] = 0;
					g_esTank[iIndex].g_flShoveRateReward[iPos] = 0.0;
					g_esTank[iIndex].g_iSledgehammerRoundsReward[iPos] = 0;
					g_esTank[iIndex].g_iSpecialAmmoReward[iPos] = 0;
					g_esTank[iIndex].g_flSpeedBoostReward[iPos] = 0.0;
					g_esTank[iIndex].g_iStackRewards[iPos] = 0;
					g_esTank[iIndex].g_iThornsReward[iPos] = 0;
					g_esTank[iIndex].g_iUsefulRewards[iPos] = 0;
				}

				if (iPos < sizeof(esTank::g_flComboChance))
				{
					g_esTank[iIndex].g_flComboChance[iPos] = 0.0;
					g_esTank[iIndex].g_flComboDamage[iPos] = 0.0;
					g_esTank[iIndex].g_flComboDeathChance[iPos] = 0.0;
					g_esTank[iIndex].g_flComboDeathRange[iPos] = 0.0;
					g_esTank[iIndex].g_flComboDelay[iPos] = 0.0;
					g_esTank[iIndex].g_flComboDuration[iPos] = 0.0;
					g_esTank[iIndex].g_flComboInterval[iPos] = 0.0;
					g_esTank[iIndex].g_flComboMaxRadius[iPos] = 0.0;
					g_esTank[iIndex].g_flComboMinRadius[iPos] = 0.0;
					g_esTank[iIndex].g_flComboRange[iPos] = 0.0;
					g_esTank[iIndex].g_flComboRangeChance[iPos] = 0.0;
					g_esTank[iIndex].g_flComboRockChance[iPos] = 0.0;
					g_esTank[iIndex].g_flComboSpeed[iPos] = 0.0;
				}

				if (iPos < sizeof(esTank::g_flComboTypeChance))
				{
					g_esTank[iIndex].g_flComboTypeChance[iPos] = 0.0;
				}

				if (iPos < sizeof(esTank::g_flPropsChance))
				{
					g_esTank[iIndex].g_flPropsChance[iPos] = 33.3;
				}

				if (iPos < sizeof(esTank::g_iSkinColor))
				{
					g_esTank[iIndex].g_iSkinColor[iPos] = 255;
					g_esTank[iIndex].g_iBossHealth[iPos] = 5000 / (iPos + 1);
					g_esTank[iIndex].g_iBossType[iPos] = iPos + 2;
					g_esTank[iIndex].g_iLightColor[iPos] = 255;
					g_esTank[iIndex].g_iOzTankColor[iPos] = 255;
					g_esTank[iIndex].g_iFlameColor[iPos] = 255;
					g_esTank[iIndex].g_iRockColor[iPos] = 255;
					g_esTank[iIndex].g_iTireColor[iPos] = 255;
					g_esTank[iIndex].g_iPropTankColor[iPos] = 255;
					g_esTank[iIndex].g_iFlashlightColor[iPos] = 255;
					g_esTank[iIndex].g_iCrownColor[iPos] = 255;
				}

				if (iPos < sizeof(esTank::g_iGlowColor))
				{
					g_esTank[iIndex].g_iGlowColor[iPos] = 255;
				}
			}
		}
	}

	if (g_esGeneral.g_iConfigMode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
			{
				g_esPlayer[iPlayer].g_sTankName[0] = '\0';
				g_esPlayer[iPlayer].g_iTankModel = 0;
				g_esPlayer[iPlayer].g_flBurnDuration = 0.0;
				g_esPlayer[iPlayer].g_flBurntSkin = -1.0;
				g_esPlayer[iPlayer].g_iTankNote = 0;
				g_esPlayer[iPlayer].g_iCheckAbilities = 0;
				g_esPlayer[iPlayer].g_iDeathRevert = 0;
				g_esPlayer[iPlayer].g_iAnnounceArrival = 0;
				g_esPlayer[iPlayer].g_iAnnounceDeath = 0;
				g_esPlayer[iPlayer].g_iAnnounceKill = 0;
				g_esPlayer[iPlayer].g_iArrivalMessage = 0;
				g_esPlayer[iPlayer].g_iArrivalSound = 0;
				g_esPlayer[iPlayer].g_iDeathDetails = 0;
				g_esPlayer[iPlayer].g_iDeathMessage = 0;
				g_esPlayer[iPlayer].g_iDeathSound = 0;
				g_esPlayer[iPlayer].g_iKillMessage = 0;
				g_esPlayer[iPlayer].g_iVocalizeArrival = 0;
				g_esPlayer[iPlayer].g_iVocalizeDeath = 0;
				g_esPlayer[iPlayer].g_sBodyColorVisual[0] = '\0';
				g_esPlayer[iPlayer].g_sBodyColorVisual2[0] = '\0';
				g_esPlayer[iPlayer].g_sBodyColorVisual3[0] = '\0';
				g_esPlayer[iPlayer].g_sBodyColorVisual4[0] = '\0';
				g_esPlayer[iPlayer].g_sFallVoicelineReward[0] = '\0';
				g_esPlayer[iPlayer].g_sFallVoicelineReward2[0] = '\0';
				g_esPlayer[iPlayer].g_sFallVoicelineReward3[0] = '\0';
				g_esPlayer[iPlayer].g_sFallVoicelineReward4[0] = '\0';
				g_esPlayer[iPlayer].g_sGlowColorVisual[0] = '\0';
				g_esPlayer[iPlayer].g_sGlowColorVisual2[0] = '\0';
				g_esPlayer[iPlayer].g_sGlowColorVisual3[0] = '\0';
				g_esPlayer[iPlayer].g_sGlowColorVisual4[0] = '\0';
				g_esPlayer[iPlayer].g_sItemReward[0] = '\0';
				g_esPlayer[iPlayer].g_sItemReward2[0] = '\0';
				g_esPlayer[iPlayer].g_sItemReward3[0] = '\0';
				g_esPlayer[iPlayer].g_sItemReward4[0] = '\0';
				g_esPlayer[iPlayer].g_sLoopingVoicelineVisual[0] = '\0';
				g_esPlayer[iPlayer].g_sLoopingVoicelineVisual2[0] = '\0';
				g_esPlayer[iPlayer].g_sLoopingVoicelineVisual3[0] = '\0';
				g_esPlayer[iPlayer].g_sLoopingVoicelineVisual4[0] = '\0';
				g_esPlayer[iPlayer].g_sScreenColorVisual[0] = '\0';
				g_esPlayer[iPlayer].g_sScreenColorVisual2[0] = '\0';
				g_esPlayer[iPlayer].g_sScreenColorVisual3[0] = '\0';
				g_esPlayer[iPlayer].g_sScreenColorVisual4[0] = '\0';
				g_esPlayer[iPlayer].g_iTeammateLimit = 0;
				g_esPlayer[iPlayer].g_iBaseHealth = 0;
				g_esPlayer[iPlayer].g_iDisplayHealth = 0;
				g_esPlayer[iPlayer].g_iDisplayHealthType = 0;
				g_esPlayer[iPlayer].g_iExtraHealth = 0;
				g_esPlayer[iPlayer].g_sHealthCharacters[0] = '\0';
				g_esPlayer[iPlayer].g_iMinimumHumans = 0;
				g_esPlayer[iPlayer].g_iMultiplyHealth = 0;
				g_esPlayer[iPlayer].g_iGlowEnabled = 0;
				g_esPlayer[iPlayer].g_iGlowFlashing = 0;
				g_esPlayer[iPlayer].g_iGlowMinRange = 0;
				g_esPlayer[iPlayer].g_iGlowMaxRange = 0;
				g_esPlayer[iPlayer].g_iGlowType = 0;
				g_esPlayer[iPlayer].g_iFavoriteType = 0;
				g_esPlayer[iPlayer].g_iAccessFlags = 0;
				g_esPlayer[iPlayer].g_iImmunityFlags = 0;
				g_esPlayer[iPlayer].g_iBossStages = 0;
				g_esPlayer[iPlayer].g_sComboSet[0] = '\0';
				g_esPlayer[iPlayer].g_iRandomTank = 0;
				g_esPlayer[iPlayer].g_flRandomDuration = 0.0;
				g_esPlayer[iPlayer].g_flRandomInterval = 0.0;
				g_esPlayer[iPlayer].g_flTransformDelay = 0.0;
				g_esPlayer[iPlayer].g_flTransformDuration = 0.0;
				g_esPlayer[iPlayer].g_iSpawnType = 0;
				g_esPlayer[iPlayer].g_iPropsAttached = 0;
				g_esPlayer[iPlayer].g_iBodyEffects = 0;
				g_esPlayer[iPlayer].g_iRockEffects = 0;
				g_esPlayer[iPlayer].g_iRockModel = 0;
				g_esPlayer[iPlayer].g_flAttackInterval = 0.0;
				g_esPlayer[iPlayer].g_flClawDamage = -1.0;
				g_esPlayer[iPlayer].g_flHittableDamage = -1.0;
				g_esPlayer[iPlayer].g_flPunchForce = -1.0;
				g_esPlayer[iPlayer].g_flPunchThrow = 0.0;
				g_esPlayer[iPlayer].g_flRockDamage = -1.0;
				g_esPlayer[iPlayer].g_flRunSpeed = 0.0;
				g_esPlayer[iPlayer].g_iSkipTaunt = 0;
				g_esPlayer[iPlayer].g_iSweepFist = 0;
				g_esPlayer[iPlayer].g_flThrowInterval = 0.0;
				g_esPlayer[iPlayer].g_iBulletImmunity = 0;
				g_esPlayer[iPlayer].g_iExplosiveImmunity = 0;
				g_esPlayer[iPlayer].g_iFireImmunity = 0;
				g_esPlayer[iPlayer].g_iHittableImmunity = 0;
				g_esPlayer[iPlayer].g_iMeleeImmunity = 0;
				g_esPlayer[iPlayer].g_iVomitImmunity = 0;

				for (int iPos = 0; iPos < sizeof(esPlayer::g_iTransformType); iPos++)
				{
					g_esPlayer[iPlayer].g_iTransformType[iPos] = 0;

					if (iPos < sizeof(esPlayer::g_iRewardEnabled))
					{
						g_esPlayer[iPlayer].g_iRewardEnabled[iPos] = -1;
						g_esPlayer[iPlayer].g_iRewardBots[iPos] = -1;
						g_esPlayer[iPlayer].g_flRewardChance[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flRewardDuration[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iRewardEffect[iPos] = 0;
						g_esPlayer[iPlayer].g_iRewardNotify[iPos] = 0;
						g_esPlayer[iPlayer].g_flRewardPercentage[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iRewardPriority[iPos] = 0;
						g_esPlayer[iPlayer].g_iRewardVisual[iPos] = 0;
						g_esPlayer[iPlayer].g_flActionDurationReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iAmmoBoostReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iAmmoRegenReward[iPos] = 0;
						g_esPlayer[iPlayer].g_flAttackBoostReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iCleanKillsReward[iPos] = 0;
						g_esPlayer[iPlayer].g_flDamageBoostReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flDamageResistanceReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flHealPercentReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iHealthRegenReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iHollowpointAmmoReward[iPos] = 0;
						g_esPlayer[iPlayer].g_flJumpHeightReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iInfiniteAmmoReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iLadyKillerReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iLifeLeechReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iMeleeRangeReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iParticleEffectVisual[iPos] = 0;
						g_esPlayer[iPlayer].g_iPrefsNotify[iPos] = 0;
						g_esPlayer[iPlayer].g_flPunchResistanceReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iRespawnLoadoutReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iReviveHealthReward[iPos] = 0;
						g_esPlayer[iPlayer].g_flShoveDamageReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iShovePenaltyReward[iPos] = 0;
						g_esPlayer[iPlayer].g_flShoveRateReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iSledgehammerRoundsReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iSpecialAmmoReward[iPos] = 0;
						g_esPlayer[iPlayer].g_flSpeedBoostReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iStackRewards[iPos] = 0;
						g_esPlayer[iPlayer].g_iThornsReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iUsefulRewards[iPos] = 0;
					}

					if (iPos < sizeof(esPlayer::g_flComboChance))
					{
						g_esPlayer[iPlayer].g_flComboChance[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboDamage[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboDeathChance[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboDeathRange[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboDelay[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboDuration[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboInterval[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboMaxRadius[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboMinRadius[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboRange[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboRangeChance[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboRockChance[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flComboSpeed[iPos] = 0.0;
					}

					if (iPos < sizeof(esPlayer::g_flComboTypeChance))
					{
						g_esPlayer[iPlayer].g_flComboTypeChance[iPos] = 0.0;
					}

					if (iPos < sizeof(esPlayer::g_flPropsChance))
					{
						g_esPlayer[iPlayer].g_flPropsChance[iPos] = 0.0;
					}

					if (iPos < sizeof(esPlayer::g_iSkinColor))
					{
						g_esPlayer[iPlayer].g_iSkinColor[iPos] = -1;
						g_esPlayer[iPlayer].g_iBossHealth[iPos] = 0;
						g_esPlayer[iPlayer].g_iBossType[iPos] = 0;
						g_esPlayer[iPlayer].g_iLightColor[iPos] = -1;
						g_esPlayer[iPlayer].g_iOzTankColor[iPos] = -1;
						g_esPlayer[iPlayer].g_iFlameColor[iPos] = -1;
						g_esPlayer[iPlayer].g_iRockColor[iPos] = -1;
						g_esPlayer[iPlayer].g_iTireColor[iPos] = -1;
						g_esPlayer[iPlayer].g_iPropTankColor[iPos] = -1;
						g_esPlayer[iPlayer].g_iFlashlightColor[iPos] = -1;
						g_esPlayer[iPlayer].g_iCrownColor[iPos] = -1;
					}

					if (iPos < sizeof(esPlayer::g_iGlowColor))
					{
						g_esPlayer[iPlayer].g_iGlowColor[iPos] = -1;
					}
				}

				for (int iIndex = 1; iIndex <= MT_MAXTYPES; iIndex++)
				{
					g_esAdmin[iIndex].g_iAccessFlags[iPlayer] = 0;
					g_esAdmin[iIndex].g_iImmunityFlags[iPlayer] = 0;
				}
			}
		}
	}

	Call_StartForward(g_esGeneral.g_gfConfigsLoadForward);
	Call_PushCell(g_esGeneral.g_iConfigMode);
	Call_Finish();
}

public SMCResult SMCNewSection(SMCParser smc, const char[] name, bool opt_quotes)
{
	if (g_esGeneral.g_iIgnoreLevel)
	{
		g_esGeneral.g_iIgnoreLevel++;

		return SMCParse_Continue;
	}

	if (g_esGeneral.g_csState == ConfigState_None)
	{
		switch (StrEqual(name, MT_CONFIG_SECTION_MAIN, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN2, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN3, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN4, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN5, false))
		{
			case true: g_esGeneral.g_csState = ConfigState_Start;
			case false: g_esGeneral.g_iIgnoreLevel++;
		}
	}
	else if (g_esGeneral.g_csState == ConfigState_Start)
	{
		if (StrEqual(name, MT_CONFIG_SECTION_SETTINGS, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS2, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS3, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS4, false))
		{
			g_esGeneral.g_csState = ConfigState_Settings;

			strcopy(g_esGeneral.g_sCurrentSection, sizeof(esGeneral::g_sCurrentSection), name);
		}
		else if (StrContains(name, "Tank", false) == 0 || name[0] == '#' || IsCharNumeric(name[0]) || StrContains(name, "all", false) != -1 || StrContains(name, ",") != -1 || StrContains(name, "-") != -1)
		{
			g_esGeneral.g_csState = ConfigState_Type;

			strcopy(g_esGeneral.g_sCurrentSection, sizeof(esGeneral::g_sCurrentSection), name);
		}
		else if (StrContains(name, "STEAM_", false) == 0 || strncmp("0:", name, 2) == 0 || strncmp("1:", name, 2) == 0 || (!strncmp(name, "[U:", 3) && name[strlen(name) - 1] == ']'))
		{
			g_esGeneral.g_csState = ConfigState_Admin;

			strcopy(g_esGeneral.g_sCurrentSection, sizeof(esGeneral::g_sCurrentSection), name);
		}
		else
		{
			g_esGeneral.g_iIgnoreLevel++;
		}
	}
	else if (g_esGeneral.g_csState == ConfigState_Settings || g_esGeneral.g_csState == ConfigState_Type || g_esGeneral.g_csState == ConfigState_Admin)
	{
		g_esGeneral.g_csState = ConfigState_Specific;

		strcopy(g_esGeneral.g_sCurrentSubSection, sizeof(esGeneral::g_sCurrentSubSection), name);
	}
	else
	{
		g_esGeneral.g_iIgnoreLevel++;
	}

	return SMCParse_Continue;
}

public SMCResult SMCKeyValues(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	if (g_esGeneral.g_iIgnoreLevel)
	{
		return SMCParse_Continue;
	}

	if (g_esGeneral.g_csState == ConfigState_Specific && value[0] != '\0')
	{
		if (g_esGeneral.g_iConfigMode < 3)
		{
			if (StrEqual(g_esGeneral.g_sCurrentSection, MT_CONFIG_SECTION_SETTINGS, false) || StrEqual(g_esGeneral.g_sCurrentSection, MT_CONFIG_SECTION_SETTINGS2, false) || StrEqual(g_esGeneral.g_sCurrentSection, MT_CONFIG_SECTION_SETTINGS3, false) || StrEqual(g_esGeneral.g_sCurrentSection, MT_CONFIG_SECTION_SETTINGS4, false))
			{
				g_esGeneral.g_iPluginEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "PluginEnabled", "Plugin Enabled", "Plugin_Enabled", "penabled", g_esGeneral.g_iPluginEnabled, value, 0, 1);
				g_esGeneral.g_iListenSupport = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "ListenSupport", "Listen Support", "Listen_Support", "listen", g_esGeneral.g_iListenSupport, value, 0, 1);
				g_esGeneral.g_iCheckAbilities = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "CheckAbilities", "Check Abilities", "Check_Abilities", "check", g_esGeneral.g_iCheckAbilities, value, 0, 1);
				g_esGeneral.g_iDeathRevert = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esGeneral.g_iDeathRevert, value, 0, 1);
				g_esGeneral.g_iFinalesOnly = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "FinalesOnly", "Finales Only", "Finales_Only", "finale", g_esGeneral.g_iFinalesOnly, value, 0, 4);
				g_esGeneral.g_flIdleCheck = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "IdleCheck", "Idle Check", "Idle_Check", "idle", g_esGeneral.g_flIdleCheck, value, 0.0, 999999.0);
				g_esGeneral.g_iIdleCheckMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "IdleCheckMode", "Idle Check Mode", "Idle_Check_Mode", "idlemode", g_esGeneral.g_iIdleCheckMode, value, 0, 2);
				g_esGeneral.g_iLogCommands = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "LogCommands", "Log Commands", "Log_Commands", "logcmds", g_esGeneral.g_iLogCommands, value, 0, 31);
				g_esGeneral.g_iLogMessages = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "LogMessages", "Log Messages", "Log_Messages", "logmsgs", g_esGeneral.g_iLogMessages, value, 0, 31);
				g_esGeneral.g_iRequiresHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGeneral.g_iRequiresHumans, value, 0, 32);
				g_esGeneral.g_iTankEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "TankEnabled", "Tank Enabled", "Tank_Enabled", "tenabled", g_esGeneral.g_iTankEnabled, value, -1, 1);
				g_esGeneral.g_iTankModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "TankModel", "Tank Model", "Tank_Model", "model", g_esGeneral.g_iTankModel, value, 0, 7);
				g_esGeneral.g_flBurnDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "BurnDuration", "Burn Duration", "Burn_Duration", "burndur", g_esGeneral.g_flBurnDuration, value, 0.0, 999999.0);
				g_esGeneral.g_flBurntSkin = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "BurntSkin", "Burnt Skin", "Burnt_Skin", "burnt", g_esGeneral.g_flBurntSkin, value, -1.0, 1.0);
				g_esGeneral.g_iSpawnEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "SpawnEnabled", "Spawn Enabled", "Spawn_Enabled", "spawn", g_esGeneral.g_iSpawnEnabled, value, -1, 1);
				g_esGeneral.g_iSpawnLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "SpawnLimit", "Spawn Limit", "Spawn_Limit", "limit", g_esGeneral.g_iSpawnLimit, value, 0, 32);
				g_esGeneral.g_iAnnounceArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esGeneral.g_iAnnounceArrival, value, 0, 31);
				g_esGeneral.g_iAnnounceDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esGeneral.g_iAnnounceDeath, value, 0, 2);
				g_esGeneral.g_iAnnounceKill = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceKill", "Announce Kill", "Announce_Kill", "kill", g_esGeneral.g_iAnnounceKill, value, 0, 1);
				g_esGeneral.g_iArrivalMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "ArrivalMessage", "Arrival Message", "Arrival_Message", "arrivalmsg", g_esGeneral.g_iArrivalMessage, value, 0, 1023);
				g_esGeneral.g_iArrivalSound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "ArrivalSound", "Arrival Sound", "Arrival_Sound", "arrivalsnd", g_esGeneral.g_iArrivalSound, value, 0, 1);
				g_esGeneral.g_iDeathDetails = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathDetails", "Death Details", "Death_Details", "deathdets", g_esGeneral.g_iDeathDetails, value, 0, 5);
				g_esGeneral.g_iDeathMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathMessage", "Death Message", "Death_Message", "deathmsg", g_esGeneral.g_iDeathMessage, value, 0, 1023);
				g_esGeneral.g_iDeathSound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathSound", "Death Sound", "Death_Sound", "deathsnd", g_esGeneral.g_iDeathSound, value, 0, 1);
				g_esGeneral.g_iKillMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "KillMessage", "Kill Message", "Kill_Message", "killmsg", g_esGeneral.g_iKillMessage, value, 0, 1023);
				g_esGeneral.g_iVocalizeArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "VocalizeArrival", "Vocalize Arrival", "Vocalize_Arrival", "arrivalvoc", g_esGeneral.g_iVocalizeArrival, value, 0, 1);
				g_esGeneral.g_iVocalizeDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "VocalizeDeath", "Vocalize Death", "Vocalize_Death", "deathvoc", g_esGeneral.g_iVocalizeDeath, value, 0, 1);
				g_esGeneral.g_iTeammateLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_REWARDS, key, "TeammateLimit", "Teammate Limit", "Teammate_Limit", "teamlimit", g_esGeneral.g_iTeammateLimit, value, 0, 32);
				g_esGeneral.g_iAggressiveTanks = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_COMP, key, "AggressiveTanks", "Aggressive Tanks", "Aggressive_Tanks", "aggressive", g_esGeneral.g_iAggressiveTanks, value, 0, 1);
				g_esGeneral.g_iCreditIgniters = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_COMP, key, "CreditIgniters", "Credit Igniters", "Credit_Igniters", "credit", g_esGeneral.g_iCreditIgniters, value, 0, 1);
				g_esGeneral.g_flForceSpawn = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_COMP, key, "ForceSpawn", "Force Spawn", "Force_Spawn", "force", g_esGeneral.g_flForceSpawn, value, 0.0, 999999.0);
				g_esGeneral.g_iStasisMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_COMP, key, "StasisMode", "Stasis Mode", "Stasis_Mode", "stasis", g_esGeneral.g_iStasisMode, value, 0, 1);
				g_esGeneral.g_flSurvivalDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_COMP, key, "SurvivalDelay", "Survival Delay", "Survival_Delay", "survdelay", g_esGeneral.g_flSurvivalDelay, value, 0.1, 999999.0);
				g_esGeneral.g_iScaleDamage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_DIFF, key, "ScaleDamage", "Scale Damage", "Scale_Damage", "scaledmg", g_esGeneral.g_iScaleDamage, value, 0, 1);
				g_esGeneral.g_iBaseHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "BaseHealth", "Base Health", "Base_Health", "basehp", g_esGeneral.g_iBaseHealth, value, 0, MT_MAXHEALTH);
				g_esGeneral.g_iDisplayHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esGeneral.g_iDisplayHealth, value, 0, 11);
				g_esGeneral.g_iDisplayHealthType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esGeneral.g_iDisplayHealthType, value, 0, 2);
				g_esGeneral.g_iExtraHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "ExtraHealth", "Extra Health", "Extra_Health", "extrahp", g_esGeneral.g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
				g_esGeneral.g_iMinimumHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esGeneral.g_iMinimumHumans, value, 1, 32);
				g_esGeneral.g_iMultiplyHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esGeneral.g_iMultiplyHealth, value, 0, 3);
				g_esGeneral.g_flAttackInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "AttackInterval", "Attack Interval", "Attack_Interval", "attack", g_esGeneral.g_flAttackInterval, value, 0.0, 999999.0);
				g_esGeneral.g_flClawDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_esGeneral.g_flClawDamage, value, -1.0, 999999.0);
				g_esGeneral.g_flHittableDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "HittableDamage", "Hittable Damage", "Hittable_Damage", "hittable", g_esGeneral.g_flHittableDamage, value, -1.0, 999999.0);
				g_esGeneral.g_flPunchForce = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "PunchForce", "Punch Force", "Punch_Force", "punchf", g_esGeneral.g_flPunchForce, value, -1.0, 999999.0);
				g_esGeneral.g_flPunchThrow = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "PunchThrow", "Punch Throw", "Punch_Throw", "puncht", g_esGeneral.g_flPunchThrow, value, 0.0, 100.0);
				g_esGeneral.g_flRockDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esGeneral.g_flRockDamage, value, -1.0, 999999.0);
				g_esGeneral.g_flRunSpeed = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esGeneral.g_flRunSpeed, value, 0.0, 3.0);
				g_esGeneral.g_iSkipTaunt = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "SkipTaunt", "SkipTaunt", "Skip_Taunt", "taunt", g_esGeneral.g_iSkipTaunt, value, 0, 1);
				g_esGeneral.g_iSweepFist = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "SweepFist", "Sweep Fist", "Sweep_Fist", "sweep", g_esGeneral.g_iSweepFist, value, 0, 1);
				g_esGeneral.g_flThrowInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esGeneral.g_flThrowInterval, value, 0.0, 999999.0);
				g_esGeneral.g_iBulletImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esGeneral.g_iBulletImmunity, value, 0, 1);
				g_esGeneral.g_iExplosiveImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esGeneral.g_iExplosiveImmunity, value, 0, 1);
				g_esGeneral.g_iFireImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esGeneral.g_iFireImmunity, value, 0, 1);
				g_esGeneral.g_iHittableImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "HittableImmunity", "Hittable Immunity", "Hittable_Immunity", "hittable", g_esGeneral.g_iHittableImmunity, value, 0, 1);
				g_esGeneral.g_iMeleeImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esGeneral.g_iMeleeImmunity, value, 0, 1);
				g_esGeneral.g_iVomitImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "VomitImmunity", "Vomit Immunity", "Vomit_Immunity", "vomit", g_esGeneral.g_iVomitImmunity, value, 0, 1);
				g_esGeneral.g_iAllowDeveloper = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ADMIN, key, "AllowDeveloper", "Allow Developer", "Allow_Developer", "developer", g_esGeneral.g_iAllowDeveloper, value, 0, 1);
				g_esGeneral.g_iHumanCooldown = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HUMAN, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "cooldown", g_esGeneral.g_iHumanCooldown, value, 0, 999999);
				g_esGeneral.g_iMasterControl = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HUMAN, key, "MasterControl", "Master Control", "Master_Control", "master", g_esGeneral.g_iMasterControl, value, 0, 1);
				g_esGeneral.g_iSpawnMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HUMAN, key, "SpawnMode", "Spawn Mode", "Spawn_Mode", "spawnmode", g_esGeneral.g_iSpawnMode, value, 0, 1);
				g_esGeneral.g_iLimitExtras = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_WAVES, key, "LimitExtras", "Limit Extras", "Limit_Extras", "limitex", g_esGeneral.g_iLimitExtras, value, 0, 1);
				g_esGeneral.g_flExtrasDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_WAVES, key, "ExtrasDelay", "Extras Delay", "Extras_Delay", "exdelay", g_esGeneral.g_flExtrasDelay, value, 0.1, 999999.0);
				g_esGeneral.g_iRegularAmount = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_WAVES, key, "RegularAmount", "Regular Amount", "Regular_Amount", "regamount", g_esGeneral.g_iRegularAmount, value, 0, 32);
				g_esGeneral.g_flRegularDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_WAVES, key, "RegularDelay", "Regular Delay", "Regular_Delay", "regdelay", g_esGeneral.g_flRegularDelay, value, 0.1, 999999.0);
				g_esGeneral.g_flRegularInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_WAVES, key, "RegularInterval", "Regular Interval", "Regular_Interval", "reginterval", g_esGeneral.g_flRegularInterval, value, 0.1, 999999.0);
				g_esGeneral.g_iRegularLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_WAVES, key, "RegularLimit", "Regular Limit", "Regular_Limit", "reglimit", g_esGeneral.g_iRegularLimit, value, 0, 999999);
				g_esGeneral.g_iRegularMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_WAVES, key, "RegularMode", "Regular Mode", "Regular_Mode", "regmode", g_esGeneral.g_iRegularMode, value, 0, 1);
				g_esGeneral.g_iRegularWave = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_WAVES, key, "RegularWave", "Regular Wave", "Regular_Wave", "regwave", g_esGeneral.g_iRegularWave, value, 0, 1);
				g_esGeneral.g_iFinaleAmount = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_WAVES, key, "FinaleAmount", "Finale Amount", "Finale_Amount", "finamount", g_esGeneral.g_iFinaleAmount, value, 0, 32);

				if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, false))
				{
					if (StrEqual(key, "TypeRange", false) || StrEqual(key, "Type Range", false) || StrEqual(key, "Type_Range", false) || StrEqual(key, "types", false))
					{
						static char sValue[10], sRange[2][5];
						strcopy(sValue, sizeof(sValue), value);
						ReplaceString(sValue, sizeof(sValue), " ", "");
						ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

						g_esGeneral.g_iMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esGeneral.g_iMinType;
						g_esGeneral.g_iMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esGeneral.g_iMaxType;
					}
				}
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_REWARDS, false))
				{
					static char sValue[1280], sSet[4][320];
					strcopy(sValue, sizeof(sValue), value);
					ReplaceString(sValue, sizeof(sValue), " ", "");
					ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
					for (int iPos = 0; iPos < sizeof(esGeneral::g_iRewardEnabled); iPos++)
					{
						g_esGeneral.g_flRewardChance[iPos] = flGetClampedValue(key, "RewardChance", "Reward Chance", "Reward_Chance", "chance", g_esGeneral.g_flRewardChance[iPos], sSet[iPos], 0.1, 100.0);
						g_esGeneral.g_flRewardDuration[iPos] = flGetClampedValue(key, "RewardDuration", "Reward Duration", "Reward_Duration", "duration", g_esGeneral.g_flRewardDuration[iPos], sSet[iPos], 0.1, 999999.0);
						g_esGeneral.g_flRewardPercentage[iPos] = flGetClampedValue(key, "RewardPercentage", "Reward Percentage", "Reward_Percentage", "percent", g_esGeneral.g_flRewardPercentage[iPos], sSet[iPos], 0.1, 100.0);
						g_esGeneral.g_flActionDurationReward[iPos] = flGetClampedValue(key, "ActionDurationReward", "Action Duration Reward", "Action_Duration_Reward", "actionduration", g_esGeneral.g_flActionDurationReward[iPos], sSet[iPos], 0.0, 999999.0);
						g_esGeneral.g_flAttackBoostReward[iPos] = flGetClampedValue(key, "AttackBoostReward", "Attack Boost Reward", "Attack_Boost_Reward", "attackboost", g_esGeneral.g_flAttackBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
						g_esGeneral.g_flDamageBoostReward[iPos] = flGetClampedValue(key, "DamageBoostReward", "Damage Boost Reward", "Damage_Boost_Reward", "dmgboost", g_esGeneral.g_flDamageBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
						g_esGeneral.g_flDamageResistanceReward[iPos] = flGetClampedValue(key, "DamageResistanceReward", "Damage Resistance Reward", "Damage_Resistance_Reward", "dmgres", g_esGeneral.g_flDamageResistanceReward[iPos], sSet[iPos], 0.0, 1.0);
						g_esGeneral.g_flHealPercentReward[iPos] = flGetClampedValue(key, "HealPercentReward", "Heal Percent Reward", "Heal_Percent_Reward", "healpercent", g_esGeneral.g_flHealPercentReward[iPos], sSet[iPos], 0.0, 100.0);
						g_esGeneral.g_flJumpHeightReward[iPos] = flGetClampedValue(key, "JumpHeightReward", "Jump Height Reward", "Jump_Height_Reward", "jumpheight", g_esGeneral.g_flJumpHeightReward[iPos], sSet[iPos], 0.0, 999999.0);
						g_esGeneral.g_flPunchResistanceReward[iPos] = flGetClampedValue(key, "PunchResistanceReward", "Punch Resistance Reward", "Punch_Resistance_Reward", "punchres", g_esGeneral.g_flPunchResistanceReward[iPos], sSet[iPos], 0.0, 1.0);
						g_esGeneral.g_flShoveDamageReward[iPos] = flGetClampedValue(key, "ShoveDamageReward", "Shove Damage Reward", "Shove_Damage_Reward", "shovedmg", g_esGeneral.g_flShoveDamageReward[iPos], sSet[iPos], 0.0, 999999.0);
						g_esGeneral.g_flShoveRateReward[iPos] = flGetClampedValue(key, "ShoveRateReward", "Shove Rate Reward", "Shove_Rate_Reward", "shoverate", g_esGeneral.g_flShoveRateReward[iPos], sSet[iPos], 0.0, 999999.0);
						g_esGeneral.g_flSpeedBoostReward[iPos] = flGetClampedValue(key, "SpeedBoostReward", "Speed Boost Reward", "Speed_Boost_Reward", "speedboost", g_esGeneral.g_flSpeedBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
						g_esGeneral.g_iRewardEnabled[iPos] = iGetClampedValue(key, "RewardEnabled", "Reward Enabled", "Reward_Enabled", "renabled", g_esGeneral.g_iRewardEnabled[iPos], sSet[iPos], -1, 2147483647);
						g_esGeneral.g_iRewardBots[iPos] = iGetClampedValue(key, "RewardBots", "Reward Bots", "Reward_Bots", "bots", g_esGeneral.g_iRewardBots[iPos], sSet[iPos], -1, 2147483647);
						g_esGeneral.g_iRewardEffect[iPos] = iGetClampedValue(key, "RewardEffect", "Reward Effect", "Reward_Effect", "effect", g_esGeneral.g_iRewardEffect[iPos], sSet[iPos], 0, 15);
						g_esGeneral.g_iRewardNotify[iPos] = iGetClampedValue(key, "RewardNotify", "Reward Notify", "Reward_Notify", "rnotify", g_esGeneral.g_iRewardNotify[iPos], sSet[iPos], 0, 3);
						g_esGeneral.g_iRewardPriority[iPos] = iGetClampedValue(key, "RewardPriority", "Reward Priority", "Reward_Priority", "priority", g_esGeneral.g_iRewardPriority[iPos], sSet[iPos], 0, 4);
						g_esGeneral.g_iRewardVisual[iPos] = iGetClampedValue(key, "RewardVisual", "Reward Visual", "Reward_Visual", "visual", g_esGeneral.g_iRewardVisual[iPos], sSet[iPos], 0, 31);
						g_esGeneral.g_iAmmoBoostReward[iPos] = iGetClampedValue(key, "AmmoBoostReward", "Ammo Boost Reward", "Ammo_Boost_Reward", "ammoboost", g_esGeneral.g_iAmmoBoostReward[iPos], sSet[iPos], 0, 1);
						g_esGeneral.g_iAmmoRegenReward[iPos] = iGetClampedValue(key, "AmmoRegenReward", "Ammo Regen Reward", "Ammo_Regen_Reward", "ammoregen", g_esGeneral.g_iAmmoRegenReward[iPos], sSet[iPos], 0, 999999);
						g_esGeneral.g_iCleanKillsReward[iPos] = iGetClampedValue(key, "CleanKillsReward", "Clean Kills Reward", "Clean_Kills_Reward", "cleankills", g_esGeneral.g_iCleanKillsReward[iPos], sSet[iPos], 0, 1);
						g_esGeneral.g_iHealthRegenReward[iPos] = iGetClampedValue(key, "HealthRegenReward", "Health Regen Reward", "Health_Regen_Reward", "hpregen", g_esGeneral.g_iHealthRegenReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
						g_esGeneral.g_iHollowpointAmmoReward[iPos] = iGetClampedValue(key, "HollowpointAmmoReward", "Hollowpoint Ammo Reward", "Hollowpoint_Ammo_Reward", "hollowpoint", g_esGeneral.g_iHollowpointAmmoReward[iPos], sSet[iPos], 0, 1);
						g_esGeneral.g_iInfiniteAmmoReward[iPos] = iGetClampedValue(key, "InfiniteAmmoReward", "Infinite Ammo Reward", "Infinite_Ammo_Reward", "infammo", g_esGeneral.g_iInfiniteAmmoReward[iPos], sSet[iPos], 0, 31);
						g_esGeneral.g_iLadyKillerReward[iPos] = iGetClampedValue(key, "LadyKillerReward", "Lady Killer Reward", "Lady_Killer_Reward", "ladykiller", g_esGeneral.g_iLadyKillerReward[iPos], sSet[iPos], 0, 999999);
						g_esGeneral.g_iLifeLeechReward[iPos] = iGetClampedValue(key, "LifeLeechReward", "Life Leech Reward", "Life_Leech_Reward", "lifeleech", g_esGeneral.g_iLifeLeechReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
						g_esGeneral.g_iMeleeRangeReward[iPos] = iGetClampedValue(key, "MeleeRangeReward", "Melee Range Reward", "Melee_Range_Reward", "meleerange", g_esGeneral.g_iMeleeRangeReward[iPos], sSet[iPos], 0, 999999);
						g_esGeneral.g_iParticleEffectVisual[iPos] = iGetClampedValue(key, "ParticleEffectVisual", "Particle Effect Visual", "Particle_Effect_Visual", "particle", g_esGeneral.g_iParticleEffectVisual[iPos], sSet[iPos], 0, 15);
						g_esGeneral.g_iPrefsNotify[iPos] = iGetClampedValue(key, "PrefsNotify", "Prefs Notify", "Prefs_Notify", "pnotify", g_esGeneral.g_iPrefsNotify[iPos], sSet[iPos], 0, 1);
						g_esGeneral.g_iRespawnLoadoutReward[iPos] = iGetClampedValue(key, "RespawnLoadoutReward", "Respawn Loadout Reward", "Respawn_Loadout_Reward", "resloadout", g_esGeneral.g_iRespawnLoadoutReward[iPos], sSet[iPos], 0, 1);
						g_esGeneral.g_iReviveHealthReward[iPos] = iGetClampedValue(key, "ReviveHealthReward", "Revive Health Reward", "Revive_Health_Reward", "revivehp", g_esGeneral.g_iReviveHealthReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
						g_esGeneral.g_iShovePenaltyReward[iPos] = iGetClampedValue(key, "ShovePenaltyReward", "Shove Penalty Reward", "Shove_Penalty_Reward", "shovepenalty", g_esGeneral.g_iShovePenaltyReward[iPos], sSet[iPos], 0, 1);
						g_esGeneral.g_iSledgehammerRoundsReward[iPos] = iGetClampedValue(key, "SledgehammerRoundsReward", "Sledgehammer Rounds Reward", "Sledgehammer_Rounds_Reward", "sledgehammer", g_esGeneral.g_iSledgehammerRoundsReward[iPos], sSet[iPos], 0, 1);
						g_esGeneral.g_iSpecialAmmoReward[iPos] = iGetClampedValue(key, "SpecialAmmoReward", "Special Ammo Reward", "Special_Ammo_Reward", "specialammo", g_esGeneral.g_iSpecialAmmoReward[iPos], sSet[iPos], 0, 3);
						g_esGeneral.g_iStackRewards[iPos] = iGetClampedValue(key, "StackRewards", "Stack Rewards", "Stack_Rewards", "stack", g_esGeneral.g_iStackRewards[iPos], sSet[iPos], 0, 1);
						g_esGeneral.g_iThornsReward[iPos] = iGetClampedValue(key, "ThornsReward", "Thorns Reward", "Thorns_Reward", "thorns", g_esGeneral.g_iThornsReward[iPos], sSet[iPos], 0, 1);
						g_esGeneral.g_iUsefulRewards[iPos] = iGetClampedValue(key, "UsefulRewards", "Useful Rewards", "Useful_Rewards", "useful", g_esGeneral.g_iUsefulRewards[iPos], sSet[iPos], 0, 15);

						vGetStringValue(key, "BodyColorVisual", "Body Color Visual", "Body_Color_Visual", "bodycolor", iPos, g_esGeneral.g_sBodyColorVisual, sizeof(esGeneral::g_sBodyColorVisual), g_esGeneral.g_sBodyColorVisual2, sizeof(esGeneral::g_sBodyColorVisual2), g_esGeneral.g_sBodyColorVisual3, sizeof(esGeneral::g_sBodyColorVisual3), g_esGeneral.g_sBodyColorVisual4, sizeof(esGeneral::g_sBodyColorVisual4), sSet[iPos]);
						vGetStringValue(key, "FallVoicelineReward", "Fall Voiceline Reward", "Fall_Voiceline_Reward", "fallvoice", iPos, g_esGeneral.g_sFallVoicelineReward, sizeof(esGeneral::g_sFallVoicelineReward), g_esGeneral.g_sFallVoicelineReward2, sizeof(esGeneral::g_sFallVoicelineReward2), g_esGeneral.g_sFallVoicelineReward3, sizeof(esGeneral::g_sFallVoicelineReward3), g_esGeneral.g_sFallVoicelineReward4, sizeof(esGeneral::g_sFallVoicelineReward4), sSet[iPos]);
						vGetStringValue(key, "GlowColorVisual", "Glow Color Visual", "Glow_Color_Visual", "glowcolor", iPos, g_esGeneral.g_sGlowColorVisual, sizeof(esGeneral::g_sGlowColorVisual), g_esGeneral.g_sGlowColorVisual2, sizeof(esGeneral::g_sGlowColorVisual2), g_esGeneral.g_sGlowColorVisual3, sizeof(esGeneral::g_sGlowColorVisual3), g_esGeneral.g_sGlowColorVisual4, sizeof(esGeneral::g_sGlowColorVisual4), sSet[iPos]);
						vGetStringValue(key, "ItemReward", "Item Reward", "Item_Reward", "item", iPos, g_esGeneral.g_sItemReward, sizeof(esGeneral::g_sItemReward), g_esGeneral.g_sItemReward2, sizeof(esGeneral::g_sItemReward2), g_esGeneral.g_sItemReward3, sizeof(esGeneral::g_sItemReward3), g_esGeneral.g_sItemReward4, sizeof(esGeneral::g_sItemReward4), sSet[iPos]);
						vGetStringValue(key, "LoopingVoicelineVisual", "Looping Voiceline Visual", "Looping_Voiceline_Visual", "loopvoice", iPos, g_esGeneral.g_sLoopingVoicelineVisual, sizeof(esGeneral::g_sLoopingVoicelineVisual), g_esGeneral.g_sLoopingVoicelineVisual2, sizeof(esGeneral::g_sLoopingVoicelineVisual2), g_esGeneral.g_sLoopingVoicelineVisual3, sizeof(esGeneral::g_sLoopingVoicelineVisual3), g_esGeneral.g_sLoopingVoicelineVisual4, sizeof(esGeneral::g_sLoopingVoicelineVisual4), sSet[iPos]);
						vGetStringValue(key, "ScreenColorVisual", "Screen Color Visual", "Screen_Color_Visual", "screencolor", iPos, g_esGeneral.g_sScreenColorVisual, sizeof(esGeneral::g_sScreenColorVisual), g_esGeneral.g_sScreenColorVisual2, sizeof(esGeneral::g_sScreenColorVisual2), g_esGeneral.g_sScreenColorVisual3, sizeof(esGeneral::g_sScreenColorVisual3), g_esGeneral.g_sScreenColorVisual4, sizeof(esGeneral::g_sScreenColorVisual4), sSet[iPos]);
					}
				}
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_DIFF, false) || StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_DIFF2, false))
				{
					if (StrEqual(key, "DifficultyDamage", false) || StrEqual(key, "Difficulty Damage", false) || StrEqual(key, "Difficulty_Damage", false) || StrEqual(key, "diffdmg", false))
					{
						static char sValue[36], sSet[4][9];
						strcopy(sValue, sizeof(sValue), value);
						ReplaceString(sValue, sizeof(sValue), " ", "");
						ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
						for (int iPos = 0; iPos < sizeof(esGeneral::g_flDifficultyDamage); iPos++)
						{
							g_esGeneral.g_flDifficultyDamage[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esGeneral.g_flDifficultyDamage[iPos];
						}
					}
				}
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, false))
				{
					if (StrEqual(key, "RegularType", false) || StrEqual(key, "Regular Type", false) || StrEqual(key, "Regular_Type", false) || StrEqual(key, "regtype", false))
					{
						static char sValue[10], sRange[2][5];
						strcopy(sValue, sizeof(sValue), value);
						ReplaceString(sValue, sizeof(sValue), " ", "");
						ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

						g_esGeneral.g_iRegularMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esGeneral.g_iRegularMinType;
						g_esGeneral.g_iRegularMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esGeneral.g_iRegularMaxType;
					}
					else if (StrEqual(key, "FinaleTypes", false) || StrEqual(key, "Finale Types", false) || StrEqual(key, "Finale_Types", false) || StrEqual(key, "fintypes", false))
					{
						static char sValue[100], sRange[10][10], sSet[2][5];
						strcopy(sValue, sizeof(sValue), value);
						ReplaceString(sValue, sizeof(sValue), " ", "");
						ExplodeString(sValue, ",", sRange, sizeof(sRange), sizeof(sRange[]));
						for (int iPos = 0; iPos < sizeof(sRange); iPos++)
						{
							if (sRange[iPos][0] == '\0')
							{
								continue;
							}

							ExplodeString(sRange[iPos], "-", sSet, sizeof(sSet), sizeof(sSet[]));
							g_esGeneral.g_iFinaleMinTypes[iPos] = (sSet[0][0] != '\0') ? iClamp(StringToInt(sSet[0]), 0, MT_MAXTYPES) : g_esGeneral.g_iFinaleMinTypes[iPos];
							g_esGeneral.g_iFinaleMaxTypes[iPos] = (sSet[1][0] != '\0') ? iClamp(StringToInt(sSet[1]), 0, MT_MAXTYPES) : g_esGeneral.g_iFinaleMaxTypes[iPos];
						}
					}
					else if (StrEqual(key, "FinaleWaves", false) || StrEqual(key, "Finale Waves", false) || StrEqual(key, "Finale_Waves", false) || StrEqual(key, "finwaves", false))
					{
						static char sValue[30], sSet[10][3];
						strcopy(sValue, sizeof(sValue), value);
						ReplaceString(sValue, sizeof(sValue), " ", "");
						ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
						for (int iPos = 0; iPos < sizeof(esGeneral::g_iFinaleWave); iPos++)
						{
							g_esGeneral.g_iFinaleWave[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 32) : g_esGeneral.g_iFinaleWave[iPos];
						}
					}
				}
				else if ((StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_CONVARS, false) || StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_CONVARS2, false)) && key[0] != '\0')
				{
					static char sKey[128];
					strcopy(sKey, sizeof(sKey), key);
					ReplaceString(sKey, sizeof(sKey), " ", "");
					if (StrContains(sKey, "mt_disabledgamemodes", false) == -1 && StrContains(sKey, "mt_enabledgamemodes", false) == -1 && StrContains(sKey, "mt_gamemodetypes", false) == -1 && StrContains(sKey, "mt_pluginenabled", false) == -1 && StrContains(sKey, "mt_pluginversion", false) == -1)
					{
						static char sValue[PLATFORM_MAX_PATH];
						strcopy(sValue, sizeof(sValue), value);
						ReplaceString(sValue, sizeof(sValue), " ", "");
						g_esGeneral.g_cvMTTempSetting = FindConVar(sKey);
						if (g_esGeneral.g_cvMTTempSetting != null)
						{
							static int iFlags;
							iFlags = g_esGeneral.g_cvMTTempSetting.Flags;
							g_esGeneral.g_cvMTTempSetting.Flags &= ~FCVAR_NOTIFY;
							g_esGeneral.g_cvMTTempSetting.SetString(sValue);
							g_esGeneral.g_cvMTTempSetting.Flags = iFlags;
							g_esGeneral.g_cvMTTempSetting = null;

							vLogMessage(MT_LOG_SERVER, _, "%s Changed cvar \"%s\" to \"%s\".", MT_TAG, sKey, sValue);
						}
						else
						{
							vLogMessage(MT_LOG_SERVER, _, "%s Unable to find cvar: %s", MT_TAG, sKey);
						}
					}
					else
					{
						vLogMessage(MT_LOG_SERVER, _, "%s Unable to change cvar: %s", MT_TAG, sKey);
					}
				}
				else
				{
					g_esGeneral.g_iAccessFlags = iGetAdminFlagsValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ADMIN, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
					g_esGeneral.g_iImmunityFlags = iGetAdminFlagsValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ADMIN, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);

					vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "HealthCharacters", "Health Characters", "Health_Characters", "hpchars", g_esGeneral.g_sHealthCharacters, sizeof(esGeneral::g_sHealthCharacters), value);
				}

				if (g_esGeneral.g_iConfigMode == 1)
				{
					g_esGeneral.g_iGameModeTypes = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GAMEMODES, key, "GameModeTypes", "Game Mode Types", "Game_Mode_Types", "types", g_esGeneral.g_iGameModeTypes, value, 0, 15);
					g_esGeneral.g_iConfigEnable = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_CUSTOM, key, "EnableCustomConfigs", "Enable Custom Configs", "Enable_Custom_Configs", "cenabled", g_esGeneral.g_iConfigEnable, value, 0, 1);
					g_esGeneral.g_iConfigCreate = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_CUSTOM, key, "CreateConfigTypes", "Create Config Types", "Create_Config_Types", "create", g_esGeneral.g_iConfigCreate, value, 0, 255);
					g_esGeneral.g_iConfigExecute = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_CUSTOM, key, "ExecuteConfigTypes", "Execute Config Types", "Execute_Config_Types", "execute", g_esGeneral.g_iConfigExecute, value, 0, 255);

					vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GAMEMODES, key, "EnabledGameModes", "Enabled Game Modes", "Enabled_Game_Modes", "gmenabled", g_esGeneral.g_sEnabledGameModes, sizeof(esGeneral::g_sEnabledGameModes), value);
					vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GAMEMODES, key, "DisabledGameModes", "Disabled Game Modes", "Disabled_Game_Modes", "gmdisabled", g_esGeneral.g_sDisabledGameModes, sizeof(esGeneral::g_sDisabledGameModes), value);
				}

				Call_StartForward(g_esGeneral.g_gfConfigsLoadedForward);
				Call_PushString(g_esGeneral.g_sCurrentSubSection);
				Call_PushString(key);
				Call_PushString(value);
				Call_PushCell(0);
				Call_PushCell(-1);
				Call_PushCell(g_esGeneral.g_iConfigMode);
				Call_Finish();
			}
			else if (StrContains(g_esGeneral.g_sCurrentSection, "Tank", false) == 0 || g_esGeneral.g_sCurrentSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSection, "-") != -1)
			{
				int iStartPos = 0, iIndex = 0, iRealType = 0;
				if (StrContains(g_esGeneral.g_sCurrentSection, "Tank", false) == 0 || g_esGeneral.g_sCurrentSection[0] == '#')
				{
					iStartPos = iGetConfigSectionNumber(g_esGeneral.g_sCurrentSection, sizeof(esGeneral::g_sCurrentSection)), iIndex = StringToInt(g_esGeneral.g_sCurrentSection[iStartPos]);
					vReadTankSettings(iIndex, g_esGeneral.g_sCurrentSubSection, key, value);
				}
				else if (IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSection, "-") != -1)
				{
					if (IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) && (StrContains(g_esGeneral.g_sCurrentSection, ",") == -1 || StrContains(g_esGeneral.g_sCurrentSection, "-") == -1))
					{
						iIndex = StringToInt(g_esGeneral.g_sCurrentSection);
						vReadTankSettings(iIndex, g_esGeneral.g_sCurrentSubSection, key, value);
					}
					else if (StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSection, "-") != -1)
					{
						for (iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
						{
							if (iIndex <= 0)
							{
								continue;
							}

							iRealType = iFindSectionType(g_esGeneral.g_sCurrentSection, iIndex);
							if (iIndex == iRealType || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1)
							{
								vReadTankSettings(iIndex, g_esGeneral.g_sCurrentSubSection, key, value);
							}
						}
					}
				}
			}
		}
		else if (g_esGeneral.g_iConfigMode == 3 && (StrContains(g_esGeneral.g_sCurrentSection, "STEAM_", false) == 0 || strncmp("0:", g_esGeneral.g_sCurrentSection, 2) == 0 || strncmp("1:", g_esGeneral.g_sCurrentSection, 2) == 0 || (!strncmp(g_esGeneral.g_sCurrentSection, "[U:", 3) && g_esGeneral.g_sCurrentSection[strlen(g_esGeneral.g_sCurrentSection) - 1] == ']')))
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
				{
					if (StrEqual(g_esPlayer[iPlayer].g_sSteamID32, g_esGeneral.g_sCurrentSection, false) || StrEqual(g_esPlayer[iPlayer].g_sSteam3ID, g_esGeneral.g_sCurrentSection, false))
					{
						g_esPlayer[iPlayer].g_iTankModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "TankModel", "Tank Model", "Tank_Model", "model", g_esPlayer[iPlayer].g_iTankModel, value, 0, 7);
						g_esPlayer[iPlayer].g_flBurnDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "BurnDuration", "Burn Duration", "Burn_Duration", "burndur", g_esPlayer[iPlayer].g_flBurnDuration, value, 0.0, 999999.0);
						g_esPlayer[iPlayer].g_flBurntSkin = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "BurntSkin", "Burnt Skin", "Burnt_Skin", "burnt", g_esPlayer[iPlayer].g_flBurntSkin, value, -1.0, 1.0);
						g_esPlayer[iPlayer].g_iTankNote = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "TankNote", "Tank Note", "Tank_Note", "note", g_esPlayer[iPlayer].g_iTankNote, value, 0, 1);
						g_esPlayer[iPlayer].g_iCheckAbilities = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "CheckAbilities", "Check Abilities", "Check_Abilities", "check", g_esPlayer[iPlayer].g_iCheckAbilities, value, 0, 1);
						g_esPlayer[iPlayer].g_iDeathRevert = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esPlayer[iPlayer].g_iDeathRevert, value, 0, 1);
						g_esPlayer[iPlayer].g_iAnnounceArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esPlayer[iPlayer].g_iAnnounceArrival, value, 0, 31);
						g_esPlayer[iPlayer].g_iAnnounceDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esPlayer[iPlayer].g_iAnnounceDeath, value, 0, 2);
						g_esPlayer[iPlayer].g_iAnnounceKill = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceKill", "Announce Kill", "Announce_Kill", "kill", g_esPlayer[iPlayer].g_iAnnounceKill, value, 0, 1);
						g_esPlayer[iPlayer].g_iArrivalMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "ArrivalMessage", "Arrival Message", "Arrival_Message", "arrivalmsg", g_esPlayer[iPlayer].g_iArrivalMessage, value, 0, 1023);
						g_esPlayer[iPlayer].g_iArrivalSound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "ArrivalSound", "Arrival Sound", "Arrival_Sound", "arrivalsnd", g_esPlayer[iPlayer].g_iArrivalSound, value, 0, 1);
						g_esPlayer[iPlayer].g_iDeathDetails = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathDetails", "Death Details", "Death_Details", "deathdets", g_esPlayer[iPlayer].g_iDeathDetails, value, 0, 5);
						g_esPlayer[iPlayer].g_iDeathMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathMessage", "Death Message", "Death_Message", "deathmsg", g_esPlayer[iPlayer].g_iDeathMessage, value, 0, 1023);
						g_esPlayer[iPlayer].g_iDeathSound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathSound", "Death Sound", "Death_Sound", "deathsnd", g_esPlayer[iPlayer].g_iDeathSound, value, 0, 1);
						g_esPlayer[iPlayer].g_iKillMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "KillMessage", "Kill Message", "Kill_Message", "killmsg", g_esPlayer[iPlayer].g_iKillMessage, value, 0, 1023);
						g_esPlayer[iPlayer].g_iVocalizeArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "VocalizeArrival", "Vocalize Arrival", "Vocalize_Arrival", "arrivalvoc", g_esPlayer[iPlayer].g_iVocalizeArrival, value, 0, 1);
						g_esPlayer[iPlayer].g_iVocalizeDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "VocalizeDeath", "Vocalize Death", "Vocalize_Death", "deathvoc", g_esPlayer[iPlayer].g_iVocalizeDeath, value, 0, 1);
						g_esPlayer[iPlayer].g_iTeammateLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_REWARDS, key, "TeammateLimit", "Teammate Limit", "Teammate_Limit", "teamlimit", g_esPlayer[iPlayer].g_iTeammateLimit, value, 0, 32);
						g_esPlayer[iPlayer].g_iGlowEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GLOW, key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "genabled", g_esPlayer[iPlayer].g_iGlowEnabled, value, 0, 1);
						g_esPlayer[iPlayer].g_iGlowFlashing = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GLOW, key, "GlowFlashing", "Glow Flashing", "Glow_Flashing", "flashing", g_esPlayer[iPlayer].g_iGlowFlashing, value, 0, 1);
						g_esPlayer[iPlayer].g_iGlowType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GLOW, key, "GlowType", "Glow Type", "Glow_Type", "type", g_esPlayer[iPlayer].g_iGlowType, value, 0, 1);
						g_esPlayer[iPlayer].g_iBaseHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "BaseHealth", "Base Health", "Base_Health", "basehp", g_esPlayer[iPlayer].g_iBaseHealth, value, 0, MT_MAXHEALTH);
						g_esPlayer[iPlayer].g_iDisplayHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esPlayer[iPlayer].g_iDisplayHealth, value, 0, 11);
						g_esPlayer[iPlayer].g_iDisplayHealthType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esPlayer[iPlayer].g_iDisplayHealthType, value, 0, 2);
						g_esPlayer[iPlayer].g_iExtraHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "ExtraHealth", "Extra Health", "Extra_Health", "extrahp", g_esPlayer[iPlayer].g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
						g_esPlayer[iPlayer].g_iMinimumHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esPlayer[iPlayer].g_iMinimumHumans, value, 1, 32);
						g_esPlayer[iPlayer].g_iMultiplyHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esPlayer[iPlayer].g_iMultiplyHealth, value, 0, 3);
						g_esPlayer[iPlayer].g_iBossStages = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_BOSS, key, "BossStages", "Boss Stages", "Boss_Stages", "bossstages", g_esPlayer[iPlayer].g_iBossStages, value, 1, 4);
						g_esPlayer[iPlayer].g_iRandomTank = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_RANDOM, key, "RandomTank", "Random Tank", "Random_Tank", "random", g_esPlayer[iPlayer].g_iRandomTank, value, 0, 1);
						g_esPlayer[iPlayer].g_flRandomDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_RANDOM, key, "RandomDuration", "Random Duration", "Random_Duration", "randduration", g_esPlayer[iPlayer].g_flRandomDuration, value, 0.1, 999999.0);
						g_esPlayer[iPlayer].g_flRandomInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_RANDOM, key, "RandomInterval", "Random Interval", "Random_Interval", "randinterval", g_esPlayer[iPlayer].g_flRandomInterval, value, 0.1, 999999.0);
						g_esPlayer[iPlayer].g_flTransformDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_TRANSFORM, key, "TransformDelay", "Transform Delay", "Transform_Delay", "transdelay", g_esPlayer[iPlayer].g_flTransformDelay, value, 0.1, 999999.0);
						g_esPlayer[iPlayer].g_flTransformDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_TRANSFORM, key, "TransformDuration", "Transform Duration", "Transform_Duration", "transduration", g_esPlayer[iPlayer].g_flTransformDuration, value, 0.1, 999999.0);
						g_esPlayer[iPlayer].g_iSpawnType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_SPAWN, key, "SpawnType", "Spawn Type", "Spawn_Type", "spawntype", g_esPlayer[iPlayer].g_iSpawnType, value, 0, 4);
						g_esPlayer[iPlayer].g_iRockModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_PROPS, key, "RockModel", "Rock Model", "Rock_Model", "rockmodel", g_esPlayer[iPlayer].g_iRockModel, value, 0, 2);
						g_esPlayer[iPlayer].g_iPropsAttached = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_PROPS, key, "PropsAttached", "Props Attached", "Props_Attached", "attached", g_esPlayer[iPlayer].g_iPropsAttached, value, 0, 511);
						g_esPlayer[iPlayer].g_iBodyEffects = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_PARTICLES, key, "BodyEffects", "Body Effects", "Body_Effects", "body", g_esPlayer[iPlayer].g_iBodyEffects, value, 0, 127);
						g_esPlayer[iPlayer].g_iRockEffects = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_PARTICLES, key, "RockEffects", "Rock Effects", "Rock_Effects", "rock", g_esPlayer[iPlayer].g_iRockEffects, value, 0, 15);
						g_esPlayer[iPlayer].g_flAttackInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "AttackInterval", "Attack Interval", "Attack_Interval", "attack", g_esPlayer[iPlayer].g_flAttackInterval, value, 0.0, 999999.0);
						g_esPlayer[iPlayer].g_flClawDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_esPlayer[iPlayer].g_flClawDamage, value, -1.0, 999999.0);
						g_esPlayer[iPlayer].g_flHittableDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "HittableDamage", "Hittable Damage", "Hittable_Damage", "hittable", g_esPlayer[iPlayer].g_flHittableDamage, value, -1.0, 999999.0);
						g_esPlayer[iPlayer].g_flPunchForce = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "PunchForce", "Punch Force", "Punch_Force", "punchf", g_esPlayer[iPlayer].g_flPunchForce, value, -1.0, 999999.0);
						g_esPlayer[iPlayer].g_flPunchThrow = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "PunchThrow", "Punch Throw", "Punch_Throw", "puncht", g_esPlayer[iPlayer].g_flPunchThrow, value, 0.0, 100.0);
						g_esPlayer[iPlayer].g_flRockDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esPlayer[iPlayer].g_flRockDamage, value, -1.0, 999999.0);
						g_esPlayer[iPlayer].g_flRunSpeed = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esPlayer[iPlayer].g_flRunSpeed, value, 0.0, 3.0);
						g_esPlayer[iPlayer].g_iSkipTaunt = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "SkipTaunt", "SkipTaunt", "Skip_Taunt", "taunt", g_esPlayer[iPlayer].g_iSkipTaunt, value, 0, 1);
						g_esPlayer[iPlayer].g_iSweepFist = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "SweepFist", "Sweep Fist", "Sweep_Fist", "sweep", g_esPlayer[iPlayer].g_iSweepFist, value, 0, 1);
						g_esPlayer[iPlayer].g_flThrowInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esPlayer[iPlayer].g_flThrowInterval, value, 0.0, 999999.0);
						g_esPlayer[iPlayer].g_iBulletImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esPlayer[iPlayer].g_iBulletImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iExplosiveImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esPlayer[iPlayer].g_iExplosiveImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iFireImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esPlayer[iPlayer].g_iFireImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iHittableImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "HittableImmunity", "Hittable Immunity", "Hittable_Immunity", "hittable", g_esPlayer[iPlayer].g_iHittableImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iMeleeImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esPlayer[iPlayer].g_iMeleeImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iVomitImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "VomitImmunity", "Vomit Immunity", "Vomit_Immunity", "vomit", g_esPlayer[iPlayer].g_iVomitImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iFavoriteType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ADMIN, key, "FavoriteType", "Favorite Type", "Favorite_Type", "favorite", g_esPlayer[iPlayer].g_iFavoriteType, value, 0, g_esGeneral.g_iMaxType);

						if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, false))
						{
							if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
							{
								static char sValue[16], sSet[4][4];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
								for (int iPos = 0; iPos < sizeof(esPlayer::g_iSkinColor); iPos++)
								{
									g_esPlayer[iPlayer].g_iSkinColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
								}
							}
							else
							{
								vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "TankName", "Tank Name", "Tank_Name", "name", g_esPlayer[iPlayer].g_sTankName, sizeof(esPlayer::g_sTankName), value);
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_REWARDS, false))
						{
							static char sValue[1280], sSet[4][320];
							strcopy(sValue, sizeof(sValue), value);
							ReplaceString(sValue, sizeof(sValue), " ", "");
							ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
							for (int iPos = 0; iPos < sizeof(esPlayer::g_iRewardEnabled); iPos++)
							{
								g_esPlayer[iPlayer].g_flRewardChance[iPos] = flGetClampedValue(key, "RewardChance", "Reward Chance", "Reward_Chance", "chance", g_esPlayer[iPlayer].g_flRewardChance[iPos], sSet[iPos], 0.1, 100.0);
								g_esPlayer[iPlayer].g_flRewardDuration[iPos] = flGetClampedValue(key, "RewardDuration", "Reward Duration", "Reward_Duration", "duration", g_esPlayer[iPlayer].g_flRewardDuration[iPos], sSet[iPos], 0.1, 999999.0);
								g_esPlayer[iPlayer].g_flRewardPercentage[iPos] = flGetClampedValue(key, "RewardPercentage", "Reward Percentage", "Reward_Percentage", "percent", g_esPlayer[iPlayer].g_flRewardPercentage[iPos], sSet[iPos], 0.1, 100.0);
								g_esPlayer[iPlayer].g_flActionDurationReward[iPos] = flGetClampedValue(key, "ActionDurationReward", "Action Duration Reward", "Action_Duration_Reward", "actionduration", g_esPlayer[iPlayer].g_flActionDurationReward[iPos], sSet[iPos], 0.0, 999999.0);
								g_esPlayer[iPlayer].g_flAttackBoostReward[iPos] = flGetClampedValue(key, "AttackBoostReward", "Attack Boost Reward", "Attack_Boost_Reward", "attackboost", g_esPlayer[iPlayer].g_flAttackBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
								g_esPlayer[iPlayer].g_flDamageBoostReward[iPos] = flGetClampedValue(key, "DamageBoostReward", "Damage Boost Reward", "Damage_Boost_Reward", "dmgboost", g_esPlayer[iPlayer].g_flDamageBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
								g_esPlayer[iPlayer].g_flDamageResistanceReward[iPos] = flGetClampedValue(key, "DamageResistanceReward", "Damage Resistance Reward", "Damage_Resistance_Reward", "dmgres", g_esPlayer[iPlayer].g_flDamageResistanceReward[iPos], sSet[iPos], 0.0, 1.0);
								g_esPlayer[iPlayer].g_flHealPercentReward[iPos] = flGetClampedValue(key, "HealPercentReward", "Heal Percent Reward", "Heal_Percent_Reward", "healpercent", g_esPlayer[iPlayer].g_flHealPercentReward[iPos], sSet[iPos], 0.0, 100.0);
								g_esPlayer[iPlayer].g_flJumpHeightReward[iPos] = flGetClampedValue(key, "JumpHeightReward", "Jump Height Reward", "Jump_Height_Reward", "jumpheight", g_esPlayer[iPlayer].g_flJumpHeightReward[iPos], sSet[iPos], 0.0, 999999.0);
								g_esPlayer[iPlayer].g_flPunchResistanceReward[iPos] = flGetClampedValue(key, "PunchResistanceReward", "Punch Resistance Reward", "Punch_Resistance_Reward", "punchres", g_esPlayer[iPlayer].g_flPunchResistanceReward[iPos], sSet[iPos], 0.0, 1.0);
								g_esPlayer[iPlayer].g_flShoveDamageReward[iPos] = flGetClampedValue(key, "ShoveDamageReward", "Shove Damage Reward", "Shove_Damage_Reward", "shovedmg", g_esPlayer[iPlayer].g_flShoveDamageReward[iPos], sSet[iPos], 0.0, 999999.0);
								g_esPlayer[iPlayer].g_flShoveRateReward[iPos] = flGetClampedValue(key, "ShoveRateReward", "Shove Rate Reward", "Shove_Rate_Reward", "shoverate", g_esPlayer[iPlayer].g_flShoveRateReward[iPos], sSet[iPos], 0.0, 999999.0);
								g_esPlayer[iPlayer].g_flSpeedBoostReward[iPos] = flGetClampedValue(key, "SpeedBoostReward", "Speed Boost Reward", "Speed_Boost_Reward", "speedboost", g_esPlayer[iPlayer].g_flSpeedBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
								g_esPlayer[iPlayer].g_iRewardEnabled[iPos] = iGetClampedValue(key, "RewardEnabled", "Reward Enabled", "Reward_Enabled", "renabled", g_esPlayer[iPlayer].g_iRewardEnabled[iPos], sSet[iPos], -1, 2147483647);
								g_esPlayer[iPlayer].g_iRewardBots[iPos] = iGetClampedValue(key, "RewardBots", "Reward Bots", "Reward_Bots", "bots", g_esPlayer[iPlayer].g_iRewardBots[iPos], sSet[iPos], -1, 2147483647);
								g_esPlayer[iPlayer].g_iRewardEffect[iPos] = iGetClampedValue(key, "RewardEffect", "Reward Effect", "Reward_Effect", "effect", g_esPlayer[iPlayer].g_iRewardEffect[iPos], sSet[iPos], 0, 15);
								g_esPlayer[iPlayer].g_iRewardNotify[iPos] = iGetClampedValue(key, "RewardNotify", "Reward Notify", "Reward_Notify", "rnotify", g_esPlayer[iPlayer].g_iRewardNotify[iPos], sSet[iPos], 0, 3);
								g_esPlayer[iPlayer].g_iRewardPriority[iPos] = iGetClampedValue(key, "RewardPriority", "Reward Priority", "Reward_Priority", "priority", g_esPlayer[iPlayer].g_iRewardPriority[iPos], sSet[iPos], 0, 4);
								g_esPlayer[iPlayer].g_iRewardVisual[iPos] = iGetClampedValue(key, "RewardVisual", "Reward Visual", "Reward_Visual", "visual", g_esPlayer[iPlayer].g_iRewardVisual[iPos], sSet[iPos], 0, 31);
								g_esPlayer[iPlayer].g_iAmmoBoostReward[iPos] = iGetClampedValue(key, "AmmoBoostReward", "Ammo Boost Reward", "Ammo_Boost_Reward", "ammoboost", g_esPlayer[iPlayer].g_iAmmoBoostReward[iPos], sSet[iPos], 0, 1);
								g_esPlayer[iPlayer].g_iAmmoRegenReward[iPos] = iGetClampedValue(key, "AmmoRegenReward", "Ammo Regen Reward", "Ammo_Regen_Reward", "ammoregen", g_esPlayer[iPlayer].g_iAmmoRegenReward[iPos], sSet[iPos], 0, 999999);
								g_esPlayer[iPlayer].g_iCleanKillsReward[iPos] = iGetClampedValue(key, "CleanKillsReward", "Clean Kills Reward", "Clean_Kills_Reward", "cleankills", g_esPlayer[iPlayer].g_iCleanKillsReward[iPos], sSet[iPos], 0, 1);
								g_esPlayer[iPlayer].g_iHealthRegenReward[iPos] = iGetClampedValue(key, "HealthRegenReward", "Health Regen Reward", "Health_Regen_Reward", "hpregen", g_esPlayer[iPlayer].g_iHealthRegenReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
								g_esPlayer[iPlayer].g_iHollowpointAmmoReward[iPos] = iGetClampedValue(key, "HollowpointAmmoReward", "Hollowpoint Ammo Reward", "Hollowpoint_Ammo_Reward", "hollowpoint", g_esPlayer[iPlayer].g_iHollowpointAmmoReward[iPos], sSet[iPos], 0, 1);
								g_esPlayer[iPlayer].g_iInfiniteAmmoReward[iPos] = iGetClampedValue(key, "InfiniteAmmoReward", "Infinite Ammo Reward", "Infinite_Ammo_Reward", "infammo", g_esPlayer[iPlayer].g_iInfiniteAmmoReward[iPos], sSet[iPos], 0, 31);
								g_esPlayer[iPlayer].g_iLadyKillerReward[iPos] = iGetClampedValue(key, "LadyKillerReward", "Lady Killer Reward", "Lady_Killer_Reward", "ladykiller", g_esPlayer[iPlayer].g_iLadyKillerReward[iPos], sSet[iPos], 0, 999999);
								g_esPlayer[iPlayer].g_iLifeLeechReward[iPos] = iGetClampedValue(key, "LifeLeechReward", "Life Leech Reward", "Life_Leech_Reward", "lifeleech", g_esPlayer[iPlayer].g_iLifeLeechReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
								g_esPlayer[iPlayer].g_iMeleeRangeReward[iPos] = iGetClampedValue(key, "MeleeRangeReward", "Melee Range Reward", "Melee_Range_Reward", "meleerange", g_esPlayer[iPlayer].g_iMeleeRangeReward[iPos], sSet[iPos], 0, 999999);
								g_esPlayer[iPlayer].g_iParticleEffectVisual[iPos] = iGetClampedValue(key, "ParticleEffectVisual", "Particle Effect Visual", "Particle_Effect_Visual", "particle", g_esPlayer[iPlayer].g_iParticleEffectVisual[iPos], sSet[iPos], 0, 15);
								g_esPlayer[iPlayer].g_iPrefsNotify[iPos] = iGetClampedValue(key, "PrefsNotify", "Prefs Notify", "Prefs_Notify", "pnotify", g_esPlayer[iPlayer].g_iPrefsNotify[iPos], sSet[iPos], 0, 1);
								g_esPlayer[iPlayer].g_iRespawnLoadoutReward[iPos] = iGetClampedValue(key, "RespawnLoadoutReward", "Respawn Loadout Reward", "Respawn_Loadout_Reward", "resloadout", g_esPlayer[iPlayer].g_iRespawnLoadoutReward[iPos], sSet[iPos], 0, 1);
								g_esPlayer[iPlayer].g_iReviveHealthReward[iPos] = iGetClampedValue(key, "ReviveHealthReward", "Revive Health Reward", "Revive_Health_Reward", "revivehp", g_esPlayer[iPlayer].g_iReviveHealthReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
								g_esPlayer[iPlayer].g_iShovePenaltyReward[iPos] = iGetClampedValue(key, "ShovePenaltyReward", "Shove Penalty Reward", "Shove_Penalty_Reward", "shovepenalty", g_esPlayer[iPlayer].g_iShovePenaltyReward[iPos], sSet[iPos], 0, 1);
								g_esPlayer[iPlayer].g_iSledgehammerRoundsReward[iPos] = iGetClampedValue(key, "SledgehammerRoundsReward", "Sledgehammer Rounds Reward", "Sledgehammer_Rounds_Reward", "sledgehammer", g_esPlayer[iPlayer].g_iSledgehammerRoundsReward[iPos], sSet[iPos], 0, 1);
								g_esPlayer[iPlayer].g_iSpecialAmmoReward[iPos] = iGetClampedValue(key, "SpecialAmmoReward", "Special Ammo Reward", "Special_Ammo_Reward", "specialammo", g_esPlayer[iPlayer].g_iSpecialAmmoReward[iPos], sSet[iPos], 0, 3);
								g_esPlayer[iPlayer].g_iStackRewards[iPos] = iGetClampedValue(key, "StackRewards", "Stack Rewards", "Stack_Rewards", "stack", g_esPlayer[iPlayer].g_iStackRewards[iPos], sSet[iPos], 0, 1);
								g_esPlayer[iPlayer].g_iThornsReward[iPos] = iGetClampedValue(key, "ThornsReward", "Thorns Reward", "Thorns_Reward", "thorns", g_esPlayer[iPlayer].g_iThornsReward[iPos], sSet[iPos], 0, 1);
								g_esPlayer[iPlayer].g_iUsefulRewards[iPos] = iGetClampedValue(key, "UsefulRewards", "Useful Rewards", "Useful_Rewards", "useful", g_esPlayer[iPlayer].g_iUsefulRewards[iPos], sSet[iPos], 0, 15);

								vGetStringValue(key, "BodyColorVisual", "Body Color Visual", "Body_Color_Visual", "bodycolor", iPos, g_esPlayer[iPlayer].g_sBodyColorVisual, sizeof(esPlayer::g_sBodyColorVisual), g_esPlayer[iPlayer].g_sBodyColorVisual2, sizeof(esPlayer::g_sBodyColorVisual2), g_esPlayer[iPlayer].g_sBodyColorVisual3, sizeof(esPlayer::g_sBodyColorVisual3), g_esPlayer[iPlayer].g_sBodyColorVisual4, sizeof(esPlayer::g_sBodyColorVisual4), sSet[iPos]);
								vGetStringValue(key, "FallVoicelineReward", "Fall Voiceline Reward", "Fall_Voiceline_Reward", "fallvoice", iPos, g_esPlayer[iPlayer].g_sFallVoicelineReward, sizeof(esPlayer::g_sFallVoicelineReward), g_esPlayer[iPlayer].g_sFallVoicelineReward2, sizeof(esPlayer::g_sFallVoicelineReward2), g_esPlayer[iPlayer].g_sFallVoicelineReward3, sizeof(esPlayer::g_sFallVoicelineReward3), g_esPlayer[iPlayer].g_sFallVoicelineReward4, sizeof(esPlayer::g_sFallVoicelineReward4), sSet[iPos]);
								vGetStringValue(key, "GlowColorVisual", "Glow Color Visual", "Glow_Color_Visual", "glowcolor", iPos, g_esPlayer[iPlayer].g_sGlowColorVisual, sizeof(esPlayer::g_sGlowColorVisual), g_esPlayer[iPlayer].g_sGlowColorVisual2, sizeof(esPlayer::g_sGlowColorVisual2), g_esPlayer[iPlayer].g_sGlowColorVisual3, sizeof(esPlayer::g_sGlowColorVisual3), g_esPlayer[iPlayer].g_sGlowColorVisual4, sizeof(esPlayer::g_sGlowColorVisual4), sSet[iPos]);
								vGetStringValue(key, "ItemReward", "Item Reward", "Item_Reward", "item", iPos, g_esPlayer[iPlayer].g_sItemReward, sizeof(esPlayer::g_sItemReward), g_esPlayer[iPlayer].g_sItemReward2, sizeof(esPlayer::g_sItemReward2), g_esPlayer[iPlayer].g_sItemReward3, sizeof(esPlayer::g_sItemReward3), g_esPlayer[iPlayer].g_sItemReward4, sizeof(esPlayer::g_sItemReward4), sSet[iPos]);
								vGetStringValue(key, "LoopingVoicelineVisual", "Looping Voiceline Visual", "Looping_Voiceline_Visual", "loopvoice", iPos, g_esPlayer[iPlayer].g_sLoopingVoicelineVisual, sizeof(esPlayer::g_sLoopingVoicelineVisual), g_esPlayer[iPlayer].g_sLoopingVoicelineVisual2, sizeof(esPlayer::g_sLoopingVoicelineVisual2), g_esPlayer[iPlayer].g_sLoopingVoicelineVisual3, sizeof(esPlayer::g_sLoopingVoicelineVisual3), g_esPlayer[iPlayer].g_sLoopingVoicelineVisual4, sizeof(esPlayer::g_sLoopingVoicelineVisual4), sSet[iPos]);
								vGetStringValue(key, "ScreenColorVisual", "Screen Color Visual", "Screen_Color_Visual", "screencolor", iPos, g_esPlayer[iPlayer].g_sScreenColorVisual, sizeof(esPlayer::g_sScreenColorVisual), g_esPlayer[iPlayer].g_sScreenColorVisual2, sizeof(esPlayer::g_sScreenColorVisual2), g_esPlayer[iPlayer].g_sScreenColorVisual3, sizeof(esPlayer::g_sScreenColorVisual3), g_esPlayer[iPlayer].g_sScreenColorVisual4, sizeof(esPlayer::g_sScreenColorVisual4), sSet[iPos]);
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GLOW, false))
						{
							if (StrEqual(key, "GlowColor", false) || StrEqual(key, "Glow Color", false) || StrEqual(key, "Glow_Color", false))
							{
								static char sValue[12], sSet[3][4];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
								for (int iPos = 0; iPos < sizeof(esPlayer::g_iGlowColor); iPos++)
								{
									g_esPlayer[iPlayer].g_iGlowColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
								}
							}
							else if (StrEqual(key, "GlowRange", false) || StrEqual(key, "Glow Range", false) || StrEqual(key, "Glow_Range", false))
							{
								static char sValue[14], sRange[2][7];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

								g_esPlayer[iPlayer].g_iGlowMinRange = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, 999999) : g_esPlayer[iPlayer].g_iGlowMinRange;
								g_esPlayer[iPlayer].g_iGlowMaxRange = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, 999999) : g_esPlayer[iPlayer].g_iGlowMaxRange;
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_BOSS, false))
						{
							static char sValue[44], sSet[4][11];
							strcopy(sValue, sizeof(sValue), value);
							ReplaceString(sValue, sizeof(sValue), " ", "");
							ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
							for (int iPos = 0; iPos < sizeof(esPlayer::g_iBossHealth); iPos++)
							{
								g_esPlayer[iPlayer].g_iBossHealth[iPos] = iGetClampedValue(key, "BossHealthStages", "Boss Health Stages", "Boss_Health_Stages", "bosshpstages", g_esPlayer[iPlayer].g_iBossHealth[iPos], sSet[iPos], 1, MT_MAXHEALTH);
								g_esPlayer[iPlayer].g_iBossType[iPos] = iGetClampedValue(key, "BossTypes", "Boss Types", "Boss_Types", "bosstypes", g_esPlayer[iPlayer].g_iBossType[iPos], sSet[iPos], 1, MT_MAXTYPES);
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_COMBO, false))
						{
							if (StrEqual(key, "ComboTypeChance", false) || StrEqual(key, "Combo Type Chance", false) || StrEqual(key, "Combo_Type_Chance", false) || StrEqual(key, "typechance", false))
							{
								static char sValue[42], sSet[7][6];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
								for (int iPos = 0; iPos < sizeof(esPlayer::g_flComboTypeChance); iPos++)
								{
									g_esPlayer[iPlayer].g_flComboTypeChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esPlayer[iPlayer].g_flComboTypeChance[iPos];
								}
							}
							else
							{
								static char sValue[140], sSet[10][14];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
								for (int iPos = 0; iPos < sizeof(esPlayer::g_flComboChance); iPos++)
								{
									if (StrEqual(key, "ComboRadius", false) || StrEqual(key, "Combo Radius", false) || StrEqual(key, "Combo_Radius", false) || StrEqual(key, "radius", false))
									{
										static char sRange[2][7], sSubset[14];
										strcopy(sSubset, sizeof(sSubset), sSet[iPos]);
										ReplaceString(sSubset, sizeof(sSubset), " ", "");
										ExplodeString(sSubset, ";", sRange, sizeof(sRange), sizeof(sRange[]));

										g_esPlayer[iPlayer].g_flComboMinRadius[iPos] = (sRange[0][0] != '\0') ? flClamp(StringToFloat(sRange[0]), -200.0, 0.0) : g_esPlayer[iPlayer].g_flComboMinRadius[iPos];
										g_esPlayer[iPlayer].g_flComboMaxRadius[iPos] = (sRange[1][0] != '\0') ? flClamp(StringToFloat(sRange[1]), 0.0, 200.0) : g_esPlayer[iPlayer].g_flComboMaxRadius[iPos];
									}
									else
									{
										g_esPlayer[iPlayer].g_flComboChance[iPos] = flGetClampedValue(key, "ComboChance", "Combo Chance", "Combo_Chance", "chance", g_esPlayer[iPlayer].g_flComboChance[iPos], sSet[iPos], 0.0, 100.0);
										g_esPlayer[iPlayer].g_flComboDamage[iPos] = flGetClampedValue(key, "ComboDamage", "Combo Damage", "Combo_Damage", "damage", g_esPlayer[iPlayer].g_flComboDamage[iPos], sSet[iPos], 0.0, 999999.0);
										g_esPlayer[iPlayer].g_flComboDeathChance[iPos] = flGetClampedValue(key, "ComboDeathChance", "Combo Death Chance", "Combo_Death_Chance", "deathchance", g_esPlayer[iPlayer].g_flComboDeathChance[iPos], sSet[iPos], 0.0, 100.0);
										g_esPlayer[iPlayer].g_flComboDeathRange[iPos] = flGetClampedValue(key, "ComboDeathRange", "Combo Death Range", "Combo_Death_Range", "deathrange", g_esPlayer[iPlayer].g_flComboDeathRange[iPos], sSet[iPos], 0.0, 999999.0);
										g_esPlayer[iPlayer].g_flComboDelay[iPos] = flGetClampedValue(key, "ComboDelay", "Combo Delay", "Combo_Delay", "delay", g_esPlayer[iPlayer].g_flComboDelay[iPos], sSet[iPos], 0.0, 999999.0);
										g_esPlayer[iPlayer].g_flComboDuration[iPos] = flGetClampedValue(key, "ComboDuration", "Combo Duration", "Combo_Duration", "duration", g_esPlayer[iPlayer].g_flComboDuration[iPos], sSet[iPos], 0.0, 999999.0);
										g_esPlayer[iPlayer].g_flComboInterval[iPos] = flGetClampedValue(key, "ComboInterval", "Combo Interval", "Combo_Interval", "interval", g_esPlayer[iPlayer].g_flComboInterval[iPos], sSet[iPos], 0.0, 999999.0);
										g_esPlayer[iPlayer].g_flComboRange[iPos] = flGetClampedValue(key, "ComboRange", "Combo Range", "Combo_Range", "range", g_esPlayer[iPlayer].g_flComboRange[iPos], sSet[iPos], 0.0, 999999.0);
										g_esPlayer[iPlayer].g_flComboRangeChance[iPos] = flGetClampedValue(key, "ComboRangeChance", "Combo Range Chance", "Combo_Range_Chance", "rangechance", g_esPlayer[iPlayer].g_flComboRangeChance[iPos], sSet[iPos], 0.0, 100.0);
										g_esPlayer[iPlayer].g_flComboRockChance[iPos] = flGetClampedValue(key, "ComboRockChance", "Combo Rock Chance", "Combo_Rock_Chance", "rockchance", g_esPlayer[iPlayer].g_flComboRockChance[iPos], sSet[iPos], 0.0, 100.0);
										g_esPlayer[iPlayer].g_flComboSpeed[iPos] = flGetClampedValue(key, "ComboSpeed", "Combo Speed", "Combo_Speed", "speed", g_esPlayer[iPlayer].g_flComboSpeed[iPos], sSet[iPos], 0.0, 999999.0);
									}
								}
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_TRANSFORM, false))
						{
							if (StrEqual(key, "TransformTypes", false) || StrEqual(key, "Transform Types", false) || StrEqual(key, "Transform_Types", false) || StrEqual(key, "transtypes", false))
							{
								static char sValue[50], sSet[10][5];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
								for (int iPos = 0; iPos < sizeof(esPlayer::g_iTransformType); iPos++)
								{
									g_esPlayer[iPlayer].g_iTransformType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXTYPES) : g_esPlayer[iPlayer].g_iTransformType[iPos];
								}
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_PROPS, false))
						{
							if (StrEqual(key, "PropsChance", false) || StrEqual(key, "Props Chance", false) || StrEqual(key, "Props_Chance", false) || StrEqual(key, "chance", false))
							{
								static char sValue[54], sSet[9][6];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
								for (int iPos = 0; iPos < sizeof(esPlayer::g_flPropsChance); iPos++)
								{
									g_esPlayer[iPlayer].g_flPropsChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esPlayer[iPlayer].g_flPropsChance[iPos];
								}
							}
							else
							{
								static char sValue[16], sSet[4][4];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
								for (int iPos = 0; iPos < sizeof(esPlayer::g_iLightColor); iPos++)
								{
									g_esPlayer[iPlayer].g_iLightColor[iPos] = iGetClampedValue(key, "LightColor", "Light Color", "Light_Color", "light", g_esPlayer[iPlayer].g_iLightColor[iPos], sSet[iPos], 0, 255, 0);
									g_esPlayer[iPlayer].g_iOzTankColor[iPos] = iGetClampedValue(key, "OxygenTankColor", "Oxygen Tank Color", "Oxygen_Tank_Color", "oxygen", g_esPlayer[iPlayer].g_iOzTankColor[iPos], sSet[iPos], 0, 255, 0);
									g_esPlayer[iPlayer].g_iFlameColor[iPos] = iGetClampedValue(key, "FlameColor", "Flame Color", "Flame_Color", "flame", g_esPlayer[iPlayer].g_iFlameColor[iPos], sSet[iPos], 0, 255, 0);
									g_esPlayer[iPlayer].g_iRockColor[iPos] = iGetClampedValue(key, "RockColor", "Rock Color", "Rock_Color", "rock", g_esPlayer[iPlayer].g_iRockColor[iPos], sSet[iPos], 0, 255, 0);
									g_esPlayer[iPlayer].g_iTireColor[iPos] = iGetClampedValue(key, "TireColor", "Tire Color", "Tire_Color", "tire", g_esPlayer[iPlayer].g_iTireColor[iPos], sSet[iPos], 0, 255, 0);
									g_esPlayer[iPlayer].g_iPropTankColor[iPos] = iGetClampedValue(key, "PropaneTankColor", "Propane Tank Color", "Propane_Tank_Color", "propane", g_esPlayer[iPlayer].g_iPropTankColor[iPos], sSet[iPos], 0, 255, 0);
									g_esPlayer[iPlayer].g_iFlashlightColor[iPos] = iGetClampedValue(key, "FlashlightColor", "Flashlight Color", "Flashlight_Color", "flashlight", g_esPlayer[iPlayer].g_iFlashlightColor[iPos], sSet[iPos], 0, 255, 0);
									g_esPlayer[iPlayer].g_iCrownColor[iPos] = iGetClampedValue(key, "CrownColor", "Crown Color", "Crown_Color", "crown", g_esPlayer[iPlayer].g_iCrownColor[iPos], sSet[iPos], 0, 255, 0);
								}
							}
						}
						else if (StrContains(g_esGeneral.g_sCurrentSubSection, "Tank", false) == 0 || g_esGeneral.g_sCurrentSubSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sCurrentSubSection[0]) || StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSubSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSubSection, "-") != -1)
						{
							int iStartPos = 0, iIndex = 0, iRealType = 0;
							if (StrContains(g_esGeneral.g_sCurrentSubSection, "Tank", false) == 0 || g_esGeneral.g_sCurrentSubSection[0] == '#')
							{
								iStartPos = iGetConfigSectionNumber(g_esGeneral.g_sCurrentSubSection, sizeof(esGeneral::g_sCurrentSubSection)), iIndex = StringToInt(g_esGeneral.g_sCurrentSubSection[iStartPos]);
								vReadAdminSettings(iPlayer, iIndex, key, value);
							}
							else if (IsCharNumeric(g_esGeneral.g_sCurrentSubSection[0]) || StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSubSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSubSection, "-") != -1)
							{
								if (IsCharNumeric(g_esGeneral.g_sCurrentSubSection[0]) && (StrContains(g_esGeneral.g_sCurrentSubSection, ",") == -1 || StrContains(g_esGeneral.g_sCurrentSubSection, "-") == -1))
								{
									iIndex = StringToInt(g_esGeneral.g_sCurrentSubSection);
									vReadAdminSettings(iPlayer, iIndex, key, value);
								}
								else if (StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSubSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSubSection, "-") != -1)
								{
									for (iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
									{
										if (iIndex <= 0)
										{
											continue;
										}

										iRealType = iFindSectionType(g_esGeneral.g_sCurrentSubSection, iIndex);
										if (iIndex == iRealType || StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1)
										{
											vReadAdminSettings(iPlayer, iIndex, key, value);
										}
									}
								}
							}
						}
						else
						{
							g_esPlayer[iPlayer].g_iAccessFlags = iGetAdminFlagsValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ADMIN, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
							g_esPlayer[iPlayer].g_iImmunityFlags = iGetAdminFlagsValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ADMIN, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);

							vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "HealthCharacters", "Health Characters", "Health_Characters", "hpchars", g_esPlayer[iPlayer].g_sHealthCharacters, sizeof(esPlayer::g_sHealthCharacters), value);
							vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_COMBO, key, "ComboSet", "Combo Set", "Combo_Set", "set", g_esPlayer[iPlayer].g_sComboSet, sizeof(esPlayer::g_sComboSet), value);
						}

						Call_StartForward(g_esGeneral.g_gfConfigsLoadedForward);
						Call_PushString(g_esGeneral.g_sCurrentSubSection);
						Call_PushString(key);
						Call_PushString(value);
						Call_PushCell(0);
						Call_PushCell(iPlayer);
						Call_PushCell(g_esGeneral.g_iConfigMode);
						Call_Finish();

						break;
					}
				}
			}
		}
	}

	return SMCParse_Continue;
}

public SMCResult SMCEndSection(SMCParser smc)
{
	if (g_esGeneral.g_iIgnoreLevel)
	{
		g_esGeneral.g_iIgnoreLevel--;

		return SMCParse_Continue;
	}

	if (g_esGeneral.g_csState == ConfigState_Specific)
	{
		if (StrEqual(g_esGeneral.g_sCurrentSection, MT_CONFIG_SECTION_SETTINGS, false) || StrEqual(g_esGeneral.g_sCurrentSection, MT_CONFIG_SECTION_SETTINGS2, false) || StrEqual(g_esGeneral.g_sCurrentSection, MT_CONFIG_SECTION_SETTINGS3, false) || StrEqual(g_esGeneral.g_sCurrentSection, MT_CONFIG_SECTION_SETTINGS4, false))
		{
			g_esGeneral.g_csState = ConfigState_Settings;
		}
		else if (StrContains(g_esGeneral.g_sCurrentSection, "Tank", false) == 0 || g_esGeneral.g_sCurrentSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSection, "-") != -1)
		{
			g_esGeneral.g_csState = ConfigState_Type;
		}
		else if (StrContains(g_esGeneral.g_sCurrentSection, "STEAM_", false) == 0 || strncmp("0:", g_esGeneral.g_sCurrentSection, 2) == 0 || strncmp("1:", g_esGeneral.g_sCurrentSection, 2) == 0 || (!strncmp(g_esGeneral.g_sCurrentSection, "[U:", 3) && g_esGeneral.g_sCurrentSection[strlen(g_esGeneral.g_sCurrentSection) - 1] == ']'))
		{
			g_esGeneral.g_csState = ConfigState_Admin;
		}
	}
	else if (g_esGeneral.g_csState == ConfigState_Settings || g_esGeneral.g_csState == ConfigState_Type || g_esGeneral.g_csState == ConfigState_Admin)
	{
		g_esGeneral.g_csState = ConfigState_Start;
	}
	else if (g_esGeneral.g_csState == ConfigState_Start)
	{
		g_esGeneral.g_csState = ConfigState_None;
	}

	return SMCParse_Continue;
}

public void SMCParseEnd(SMCParser smc, bool halted, bool failed)
{
	g_esGeneral.g_csState = ConfigState_None;
	g_esGeneral.g_iIgnoreLevel = 0;
	g_esGeneral.g_sCurrentSection[0] = '\0';
	g_esGeneral.g_sCurrentSubSection[0] = '\0';

	vClearAbilityList();

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vCacheSettings(iPlayer);
		}
	}
}

public void vEventHandler(Event event, const char[] name, bool dontBroadcast)
{
	if (g_esGeneral.g_bPluginEnabled)
	{
		if (StrEqual(name, "ability_use"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank))
			{
				vThrowInterval(iTank);
			}
		}
		else if (StrEqual(name, "bot_player_replace"))
		{
			int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
				iPlayerId = event.GetInt("player"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsValidClient(iBot))
			{
				if (bIsTank(iPlayer))
				{
					vSetColor(iPlayer, g_esPlayer[iBot].g_iTankType);
					vCopyTankStats(iBot, iPlayer);
					vTankSpawn(iPlayer, -1);
					vReset2(iBot, 0);
					vReset3(iBot);
					vCacheSettings(iBot);
				}
				else if (bIsSurvivor(iPlayer))
				{
					vCopySurvivorStats(iBot, iPlayer);
					vSetupDeveloper(iPlayer, _, true);
					vRemoveEffects(iBot);
				}
			}
		}
		else if (StrEqual(name, "choke_start") || StrEqual(name, "lunge_pounce") || StrEqual(name, "tongue_grab") || StrEqual(name, "charger_carry_start") || StrEqual(name, "charger_pummel_start") || StrEqual(name, "jockey_ride"))
		{
			int iSpecialId = event.GetInt("userid"), iSpecial = GetClientOfUserId(iSpecialId),
				iSurvivorId = event.GetInt("victim"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsSpecialInfected(iSpecial) && bIsSurvivor(iSurvivor) && (bIsDeveloper(iSurvivor, 11) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_GODMODE)))
			{
				vSaveCaughtSurvivor(iSurvivor, iSpecial);
			}
		}
		else if (StrEqual(name, "create_panic_event"))
		{
			if (g_esGeneral.g_iCurrentMode == 4 && g_esGeneral.g_iSurvivalBlock == 0)
			{
				vKillSurvivalTimer();
				g_esGeneral.g_iSurvivalBlock = 1;
				g_esGeneral.g_hSurvivalTimer = CreateTimer(g_esGeneral.g_flSurvivalDelay, tTimerDelaySurvival);
			}
		}
		else if (StrEqual(name, "entity_shoved"))
		{
			int iSurvivorId = event.GetInt("attacker"), iSurvivor = GetClientOfUserId(iSurvivorId),
				iWitch = event.GetInt("entityid");
			if (bIsWitch(iWitch) && bIsSurvivor(iSurvivor))
			{
				bool bDeveloper = bIsDeveloper(iSurvivor, 9);
				if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
				{
					float flMultiplier = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevShoveDamage > g_esPlayer[iSurvivor].g_flShoveDamage) ? g_esDeveloper[iSurvivor].g_flDevShoveDamage : g_esPlayer[iSurvivor].g_flShoveDamage;
					if (flMultiplier > 0.0)
					{
						SDKHooks_TakeDamage(iWitch, iSurvivor, iSurvivor, (float(GetEntProp(iWitch, Prop_Data, "m_iMaxHealth")) * flMultiplier), DMG_CLUB);
					}
				}
			}
		}
		else if (StrEqual(name, "finale_escape_start") || StrEqual(name, "finale_vehicle_incoming") || StrEqual(name, "finale_vehicle_ready"))
		{
			g_esGeneral.g_iTankWave = 3;

			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_vehicle_leaving"))
		{
			g_esGeneral.g_bFinaleEnded = true;
			g_esGeneral.g_iTankWave = 4;

			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_start") || StrEqual(name, "gauntlet_finale_start"))
		{
			g_esGeneral.g_iTankWave = 1;

			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_rush") || StrEqual(name, "finale_radio_start") || StrEqual(name, "finale_radio_damaged") || StrEqual(name, "finale_bridge_lowering"))
		{
			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_win"))
		{
			vExecuteFinaleConfigs(name);

			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				g_esPlayer[iSurvivor].g_iLadyKiller = 0;
				g_esPlayer[iSurvivor].g_iLadyKillerCount = 0;
			}
		}
		else if (StrEqual(name, "heal_success"))
		{
			int iSurvivorId = event.GetInt("subject"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsSurvivor(iSurvivor))
			{
				g_esPlayer[iSurvivor].g_bLastLife = false;
				g_esPlayer[iSurvivor].g_iReviveCount = 0;
			}
		}
		else if (StrEqual(name, "infected_hurt"))
		{
			int iSurvivorId = event.GetInt("attacker"), iSurvivor = GetClientOfUserId(iSurvivorId),
				iWitch = event.GetInt("entityid"), iDamageType = event.GetInt("type");
			if (bIsSurvivor(iSurvivor) && bIsWitch(iWitch) && !g_esGeneral.g_bWitchKilled[iWitch])
			{
				bool bDeveloper = bIsDeveloper(iSurvivor, 11);
				if (bDeveloper || (g_esPlayer[iSurvivor].g_iLadyKillerCount < g_esPlayer[iSurvivor].g_iLadyKiller))
				{
					g_esGeneral.g_bWitchKilled[iWitch] = true;

					SDKHooks_TakeDamage(iWitch, iSurvivor, iSurvivor, float(GetEntProp(iWitch, Prop_Data, "m_iHealth")), iDamageType);
					EmitSoundToClient(iSurvivor, SOUND_LADYKILLER, iSurvivor, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

					if (!bDeveloper)
					{
						g_esPlayer[iSurvivor].g_iLadyKillerCount++;

						MT_PrintToChat(iSurvivor, "%s %t", MT_TAG2, "RewardLadyKiller2", g_esPlayer[iSurvivor].g_iLadyKiller - g_esPlayer[iSurvivor].g_iLadyKillerCount);
					}
				}
			}
		}
		else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
		{
			vResetRound();
		}
		else if (StrEqual(name, "player_bot_replace"))
		{
			int iPlayerId = event.GetInt("player"), iPlayer = GetClientOfUserId(iPlayerId),
				iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
			if (bIsValidClient(iPlayer))
			{
				if (bIsTank(iBot))
				{
					vSetColor(iBot, g_esPlayer[iPlayer].g_iTankType);
					vCopyTankStats(iPlayer, iBot);
					vTankSpawn(iBot, -1);
					vReset2(iPlayer, 0);
					vReset3(iPlayer);
					vCacheSettings(iPlayer);
				}
				else if (bIsSurvivor(iBot))
				{
					vCopySurvivorStats(iPlayer, iBot);
					vSetupDeveloper(iPlayer, false);
					vRemoveEffects(iPlayer);
				}
			}
		}
		else if (StrEqual(name, "player_connect") || StrEqual(name, "player_disconnect"))
		{
			int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
			g_esPlayer[iSurvivor].g_iLadyKiller = 0;
			g_esPlayer[iSurvivor].g_iLadyKillerCount = 0;

			vDeveloperSettings(iSurvivor);
		}
		else if (StrEqual(name, "player_death"))
		{
			int iVictimId = event.GetInt("userid"), iVictim = GetClientOfUserId(iVictimId),
				iAttackerId = event.GetInt("attacker"), iAttacker = GetClientOfUserId(iAttackerId);
			if (bIsTank(iVictim, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				g_esPlayer[iVictim].g_bDied = true;
				g_esPlayer[iVictim].g_bTriggered = false;

				SDKUnhook(iVictim, SDKHook_PostThinkPost, OnTankPostThinkPost);
				vCalculateDeath(iVictim, iAttacker);

				if (g_esPlayer[iVictim].g_iTankType > 0)
				{
					if (g_esCache[iVictim].g_iDeathRevert == 1)
					{
						int iType = g_esPlayer[iVictim].g_iTankType;
						vSetColor(iVictim, _, _, true);
						g_esPlayer[iVictim].g_iTankType = iType;
					}

					vReset2(iVictim, g_esCache[iVictim].g_iDeathRevert);
					CreateTimer(1.0, tTimerResetType, iVictimId, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else if (bIsSurvivor(iVictim, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				if (bIsTank(iAttacker, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esCache[iAttacker].g_iAnnounceKill == 1)
				{
					int iOption = iGetMessageType(g_esCache[iAttacker].g_iKillMessage);
					if (iOption > 0)
					{
						char sPhrase[32], sTankName[33];
						FormatEx(sPhrase, sizeof(sPhrase), "Kill%i", iOption);
						vGetTranslatedName(sTankName, sizeof(sTankName), iAttacker);
						MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sTankName, iVictim);
						vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sTankName, iVictim);
					}
				}

				vRemoveEffects(iVictim, true);
				RequestFrame(vRespawnFrame, iVictimId);
			}
		}
		else if (StrEqual(name, "player_hurt"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId),
				iSurvivorId = event.GetInt("attacker"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsTank(iTank) && !bIsPlayerIncapacitated(iTank) && bIsSurvivor(iSurvivor))
			{
				g_esPlayer[iSurvivor].g_iTankDamage[iTank] += event.GetInt("dmg_health");
			}
		}
		else if (StrEqual(name, "player_incapacitated"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsTank(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				g_esPlayer[iPlayer].g_bDied = false;

				CreateTimer(10.0, tTimerKillStuckTank, iPlayerId, TIMER_FLAG_NO_MAPCHANGE);
				vCombineAbilitiesForward(iPlayer, MT_COMBO_UPONINCAP);
			}
			else if (bIsSurvivor(iPlayer) && (bIsDeveloper(iPlayer, 5) || (g_esPlayer[iPlayer].g_iRewardTypes & MT_REWARD_GODMODE)))
			{
				vReviveSurvivor(iPlayer);
			}
		}
		else if (StrEqual(name, "player_ledge_grab"))
		{
			int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsSurvivor(iSurvivor) && bIsDeveloper(iSurvivor, 5))
			{
				vReviveSurvivor(iSurvivor);
			}
		}
		else if (StrEqual(name, "player_now_it"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
 			if (bIsTank(iPlayer) || bIsSurvivor(iPlayer))
 			{
 				vRemoveGlow(iPlayer);
 			}

			if (bIsValidClient(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && !g_esPlayer[iPlayer].g_bVomited)
			{
				g_esPlayer[iPlayer].g_bVomited = true;
			}
		}
		else if (StrEqual(name, "player_no_longer_it"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
 			if (bIsTank(iPlayer) && !bIsPlayerIncapacitated(iPlayer))
 			{
 				vSetTankGlow(iPlayer);
 			}
			else if (bIsSurvivor(iPlayer))
			{
				switch (bIsDeveloper(iPlayer, 0))
				{
					case true: vSetSurvivorOutline(iPlayer, g_esDeveloper[iPlayer].g_sDevGlowOutline, _, ",");
					case false: vToggleEffects(iPlayer, 1);
				}
			}

			if (bIsValidClient(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iPlayer].g_bVomited)
			{
				g_esPlayer[iPlayer].g_bVomited = false;
			}
		}
		else if (StrEqual(name, "player_shoved"))
		{
			int iSpecialId = event.GetInt("userid"), iSpecial = GetClientOfUserId(iSpecialId),
				iSurvivorId = event.GetInt("attacker"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if ((bIsTank(iSpecial) || bIsCharger(iSpecial)) && bIsSurvivor(iSurvivor))
			{
				bool bDeveloper = bIsDeveloper(iSurvivor, 9);
				if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
				{
					float flMultiplier = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevShoveDamage > g_esPlayer[iSurvivor].g_flShoveDamage) ? g_esDeveloper[iSurvivor].g_flDevShoveDamage : g_esPlayer[iSurvivor].g_flShoveDamage;
					if (flMultiplier > 0.0)
					{
						vDamagePlayer(iSpecial, iSurvivor, (float(GetEntProp(iSpecial, Prop_Data, "m_iMaxHealth")) * flMultiplier), "128");
					}
				}
			}
		}
		else if (StrEqual(name, "player_spawn"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsValidClient(iPlayer))
			{
				SDKUnhook(iPlayer, SDKHook_PostThinkPost, OnTankPostThinkPost);

				DataPack dpPlayerSpawn = new DataPack();
				RequestFrame(vPlayerSpawnFrame, dpPlayerSpawn);
				dpPlayerSpawn.WriteCell(iPlayerId);
				dpPlayerSpawn.WriteCell(g_esGeneral.g_iChosenType);
			}
		}
		else if (StrEqual(name, "player_team"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsValidClient(iPlayer))
			{
				vRemoveEffects(iPlayer);
			}
		}
		else if (StrEqual(name, "revive_success"))
		{
			int iSurvivorId = event.GetInt("subject"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsSurvivor(iSurvivor))
			{
				g_esPlayer[iSurvivor].g_bLastLife = event.GetBool("lastlife");
				g_esPlayer[iSurvivor].g_iReviveCount++;
			}
		}
		else if (StrEqual(name, "weapon_fire"))
		{
			static int iTankId, iTank;
			iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank) && g_esCache[iTank].g_flAttackInterval > 0.0)
			{
				static char sWeapon[32];
				event.GetString("weapon", sWeapon, sizeof(sWeapon));
				if (StrEqual(sWeapon, "tank_claw"))
				{
					if (!g_esPlayer[iTank].g_bAttacked)
					{
						g_esPlayer[iTank].g_bAttacked = true;

						vAttackInterval(iTank);
					}
					else if (g_esPlayer[iTank].g_flAttackDelay == -1.0 && g_esPlayer[iTank].g_bAttackedAgain)
					{
						CreateTimer(g_esCache[iTank].g_flAttackInterval, tTimerResetAttackDelay, iTankId, TIMER_FLAG_NO_MAPCHANGE);
						vAttackInterval(iTank);
					}
					else if (g_esPlayer[iTank].g_flAttackDelay < GetGameTime())
					{
						g_esPlayer[iTank].g_flAttackDelay = -1.0;
					}
				}
			}
		}
		else if (StrEqual(name, "witch_harasser_set"))
		{
			int iHarasserId = event.GetInt("userid"), iHarasser = GetClientOfUserId(iHarasserId);
			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsSurvivor(iSurvivor) && g_esPlayer[iSurvivor].g_iLadyKiller > 0 && iSurvivor != iHarasser)
				{
					MT_PrintToChat(iSurvivor, "%s %t", MT_TAG2, "RewardLadyKiller2", g_esPlayer[iSurvivor].g_iLadyKiller - g_esPlayer[iSurvivor].g_iLadyKillerCount);
				}
			}
		}
		else if (StrEqual(name, "witch_killed"))
		{
			int iWitch = event.GetInt("witchid");
			g_esGeneral.g_bWitchKilled[iWitch] = false;
		}

		Call_StartForward(g_esGeneral.g_gfEventFiredForward);
		Call_PushCell(event);
		Call_PushString(name);
		Call_PushCell(dontBroadcast);
		Call_Finish();
	}
}

static void vReadAdminSettings(int admin, int type, const char[] key, const char[] value)
{
	if (1 <= type <= MT_MAXTYPES)
	{
		if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
		{
			g_esAdmin[type].g_iAccessFlags[admin] = ReadFlagString(value);
		}
		else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
		{
			g_esAdmin[type].g_iImmunityFlags[admin] = ReadFlagString(value);
		}
	}
}

static void vReadTankSettings(int type, const char[] sub, const char[] key, const char[] value)
{
	if (1 <= type <= MT_MAXTYPES)
	{
		g_esTank[type].g_iGameType = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "GameType", "Game Type", "Game_Type", "game", g_esTank[type].g_iGameType, value, 0, 2);
		g_esTank[type].g_iTankEnabled = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "TankEnabled", "Tank Enabled", "Tank_Enabled", "tenabled", g_esTank[type].g_iTankEnabled, value, -1, 1);
		g_esTank[type].g_flTankChance = flGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "TankChance", "Tank Chance", "Tank_Chance", "chance", g_esTank[type].g_flTankChance, value, 0.0, 100.0);
		g_esTank[type].g_iTankModel = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "TankModel", "Tank Model", "Tank_Model", "model", g_esTank[type].g_iTankModel, value, 0, 7);
		g_esTank[type].g_flBurnDuration = flGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "BurnDuration", "Burn Duration", "Burn_Duration", "burndur", g_esTank[type].g_flBurnDuration, value, 0.0, 999999.0);
		g_esTank[type].g_flBurntSkin = flGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "BurntSkin", "Burnt Skin", "Burnt_Skin", "burnt", g_esTank[type].g_flBurntSkin, value, -1.0, 1.0);
		g_esTank[type].g_iTankNote = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "TankNote", "Tank Note", "Tank_Note", "note", g_esTank[type].g_iTankNote, value, 0, 1);
		g_esTank[type].g_iSpawnEnabled = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "SpawnEnabled", "Spawn Enabled", "Spawn_Enabled", "spawn", g_esTank[type].g_iSpawnEnabled, value, -1, 1);
		g_esTank[type].g_iMenuEnabled = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "MenuEnabled", "Menu Enabled", "Menu_Enabled", "menu", g_esTank[type].g_iMenuEnabled, value, 0, 1);
		g_esTank[type].g_iCheckAbilities = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "CheckAbilities", "Check Abilities", "Check_Abilities", "check", g_esTank[type].g_iCheckAbilities, value, 0, 1);
		g_esTank[type].g_iDeathRevert = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esTank[type].g_iDeathRevert, value, 0, 1);
		g_esTank[type].g_iRequiresHumans = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esTank[type].g_iRequiresHumans, value, 0, 32);
		g_esTank[type].g_iAnnounceArrival = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esTank[type].g_iAnnounceArrival, value, 0, 31);
		g_esTank[type].g_iAnnounceDeath = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esTank[type].g_iAnnounceDeath, value, 0, 2);
		g_esTank[type].g_iAnnounceKill = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceKill", "Announce Kill", "Announce_Kill", "kill", g_esTank[type].g_iAnnounceKill, value, 0, 1);
		g_esTank[type].g_iArrivalMessage = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "ArrivalMessage", "Arrival Message", "Arrival_Message", "arrivalmsg", g_esTank[type].g_iArrivalMessage, value, 0, 1023);
		g_esTank[type].g_iArrivalSound = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "ArrivalSound", "Arrival Sound", "Arrival_Sound", "arrivalsnd", g_esTank[type].g_iArrivalSound, value, 0, 1);
		g_esTank[type].g_iDeathDetails = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathDetails", "Death Details", "Death_Details", "deathdets", g_esTank[type].g_iDeathDetails, value, 0, 5);
		g_esTank[type].g_iDeathMessage = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathMessage", "Death Message", "Death_Message", "deathmsg", g_esTank[type].g_iDeathMessage, value, 0, 1023);
		g_esTank[type].g_iDeathSound = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathSound", "Death Sound", "Death_Sound", "deathsnd", g_esTank[type].g_iDeathSound, value, 0, 1);
		g_esTank[type].g_iKillMessage = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "KillMessage", "Kill Message", "Kill_Message", "killmsg", g_esTank[type].g_iKillMessage, value, 0, 1023);
		g_esTank[type].g_iVocalizeArrival = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "VocalizeArrival", "Vocalize Arrival", "Vocalize_Arrival", "arrivalvoc", g_esTank[type].g_iVocalizeArrival, value, 0, 1);
		g_esTank[type].g_iVocalizeDeath = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "VocalizeDeath", "Vocalize Death", "Vocalize_Death", "deathvoc", g_esTank[type].g_iVocalizeDeath, value, 0, 1);
		g_esTank[type].g_iTeammateLimit = iGetKeyValue(sub, MT_CONFIG_SECTIONS_REWARDS, key, "TeammateLimit", "Teammate Limit", "Teammate_Limit", "teamlimit", g_esTank[type].g_iTeammateLimit, value, 0, 32);
		g_esTank[type].g_iGlowEnabled = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GLOW, key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "genabled", g_esTank[type].g_iGlowEnabled, value, 0, 1);
		g_esTank[type].g_iGlowFlashing = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GLOW, key, "GlowFlashing", "Glow Flashing", "Glow_Flashing", "flashing", g_esTank[type].g_iGlowFlashing, value, 0, 1);
		g_esTank[type].g_iGlowType = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GLOW, key, "GlowType", "Glow Type", "Glow_Type", "type", g_esTank[type].g_iGlowType, value, 0, 1);
		g_esTank[type].g_iBaseHealth = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "BaseHealth", "Base Health", "Base_Health", "basehp", g_esTank[type].g_iBaseHealth, value, 0, MT_MAXHEALTH);
		g_esTank[type].g_iDisplayHealth = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esTank[type].g_iDisplayHealth, value, 0, 11);
		g_esTank[type].g_iDisplayHealthType = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esTank[type].g_iDisplayHealthType, value, 0, 2);
		g_esTank[type].g_iExtraHealth = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "ExtraHealth", "Extra Health", "Extra_Health", "extrahp", g_esTank[type].g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		g_esTank[type].g_iMinimumHumans = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esTank[type].g_iMinimumHumans, value, 1, 32);
		g_esTank[type].g_iMultiplyHealth = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esTank[type].g_iMultiplyHealth, value, 0, 3);
		g_esTank[type].g_iHumanSupport = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HUMAN, key, MT_CONFIG_SECTIONS_HUMAN, g_esTank[type].g_iHumanSupport, value, 0, 2);
		g_esTank[type].g_iTypeLimit = iGetKeyValue(sub, MT_CONFIG_SECTIONS_SPAWN, key, "TypeLimit", "Type Limit", "Type_Limit", "limit", g_esTank[type].g_iTypeLimit, value, 0, 32);
		g_esTank[type].g_iFinaleTank = iGetKeyValue(sub, MT_CONFIG_SECTIONS_SPAWN, key, "FinaleTank", "Finale Tank", "Finale_Tank", "finale", g_esTank[type].g_iFinaleTank, value, 0, 4);
		g_esTank[type].g_flOpenAreasOnly = flGetKeyValue(sub, MT_CONFIG_SECTIONS_SPAWN, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esTank[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esTank[type].g_iBossStages = iGetKeyValue(sub, MT_CONFIG_SECTIONS_BOSS, key, "BossStages", "Boss Stages", "Boss_Stages", "bossstages", g_esTank[type].g_iBossStages, value, 1, 4);
		g_esTank[type].g_iRandomTank = iGetKeyValue(sub, MT_CONFIG_SECTIONS_RANDOM, key, "RandomTank", "Random Tank", "Random_Tank", "random", g_esTank[type].g_iRandomTank, value, 0, 1);
		g_esTank[type].g_flRandomDuration = flGetKeyValue(sub, MT_CONFIG_SECTIONS_RANDOM, key, "RandomDuration", "Random Duration", "Random_Duration", "randduration", g_esTank[type].g_flRandomDuration, value, 0.1, 999999.0);
		g_esTank[type].g_flRandomInterval = flGetKeyValue(sub, MT_CONFIG_SECTIONS_RANDOM, key, "RandomInterval", "Random Interval", "Random_Interval", "randinterval", g_esTank[type].g_flRandomInterval, value, 0.1, 999999.0);
		g_esTank[type].g_flTransformDelay = flGetKeyValue(sub, MT_CONFIG_SECTIONS_TRANSFORM, key, "TransformDelay", "Transform Delay", "Transform_Delay", "transdelay", g_esTank[type].g_flTransformDelay, value, 0.1, 999999.0);
		g_esTank[type].g_flTransformDuration = flGetKeyValue(sub, MT_CONFIG_SECTIONS_TRANSFORM, key, "TransformDuration", "Transform Duration", "Transform_Duration", "transduration", g_esTank[type].g_flTransformDuration, value, 0.1, 999999.0);
		g_esTank[type].g_iSpawnType = iGetKeyValue(sub, MT_CONFIG_SECTIONS_SPAWN, key, "SpawnType", "Spawn Type", "Spawn_Type", "spawntype", g_esTank[type].g_iSpawnType, value, 0, 4);
		g_esTank[type].g_iRockModel = iGetKeyValue(sub, MT_CONFIG_SECTIONS_PROPS, key, "RockModel", "Rock Model", "Rock_Model", "rockmodel", g_esTank[type].g_iRockModel, value, 0, 2);
		g_esTank[type].g_iPropsAttached = iGetKeyValue(sub, MT_CONFIG_SECTIONS_PROPS, key, "PropsAttached", "Props Attached", "Props_Attached", "attached", g_esTank[type].g_iPropsAttached, value, 0, 511);
		g_esTank[type].g_iBodyEffects = iGetKeyValue(sub, MT_CONFIG_SECTIONS_PARTICLES, key, "BodyEffects", "Body Effects", "Body_Effects", "body", g_esTank[type].g_iBodyEffects, value, 0, 127);
		g_esTank[type].g_iRockEffects = iGetKeyValue(sub, MT_CONFIG_SECTIONS_PARTICLES, key, "RockEffects", "Rock Effects", "Rock_Effects", "rock", g_esTank[type].g_iRockEffects, value, 0, 15);
		g_esTank[type].g_flAttackInterval = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "AttackInterval", "Attack Interval", "Attack_Interval", "attack", g_esTank[type].g_flAttackInterval, value, 0.0, 999999.0);
		g_esTank[type].g_flClawDamage = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_esTank[type].g_flClawDamage, value, -1.0, 999999.0);
		g_esTank[type].g_flHittableDamage = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "HittableDamage", "Hittable Damage", "Hittable_Damage", "hittable", g_esTank[type].g_flHittableDamage, value, -1.0, 999999.0);
		g_esTank[type].g_flPunchForce = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "PunchForce", "Punch Force", "Punch_Force", "punchf", g_esTank[type].g_flPunchForce, value, -1.0, 999999.0);
		g_esTank[type].g_flPunchThrow = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "PunchThrow", "Punch Throw", "Punch_Throw", "puncht", g_esTank[type].g_flPunchThrow, value, 0.0, 100.0);
		g_esTank[type].g_flRockDamage = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esTank[type].g_flRockDamage, value, -1.0, 999999.0);
		g_esTank[type].g_flRunSpeed = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esTank[type].g_flRunSpeed, value, 0.0, 3.0);
		g_esTank[type].g_iSkipTaunt = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "SkipTaunt", "SkipTaunt", "Skip_Taunt", "taunt", g_esTank[type].g_iSkipTaunt, value, 0, 1);
		g_esTank[type].g_iSweepFist = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "SweepFist", "Sweep Fist", "Sweep_Fist", "sweep", g_esTank[type].g_iSweepFist, value, 0, 1);
		g_esTank[type].g_flThrowInterval = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esTank[type].g_flThrowInterval, value, 0.0, 999999.0);
		g_esTank[type].g_iBulletImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esTank[type].g_iBulletImmunity, value, 0, 1);
		g_esTank[type].g_iExplosiveImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esTank[type].g_iExplosiveImmunity, value, 0, 1);
		g_esTank[type].g_iFireImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esTank[type].g_iFireImmunity, value, 0, 1);
		g_esTank[type].g_iHittableImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "HittableImmunity", "Hittable Immunity", "Hittable_Immunity", "hittable", g_esTank[type].g_iHittableImmunity, value, 0, 1);
		g_esTank[type].g_iMeleeImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esTank[type].g_iMeleeImmunity, value, 0, 1);
		g_esTank[type].g_iVomitImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "VomitImmunity", "Vomit Immunity", "Vomit_Immunity", "vomit", g_esTank[type].g_iVomitImmunity, value, 0, 1);

		if (StrEqual(sub, MT_CONFIG_SECTION_GENERAL, false))
		{
			if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
			{
				static char sValue[16], sSet[4][4];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(esTank::g_iSkinColor); iPos++)
				{
					g_esTank[type].g_iSkinColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
				}
			}
			else
			{
				vGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "TankName", "Tank Name", "Tank_Name", "name", g_esTank[type].g_sTankName, sizeof(esTank::g_sTankName), value);
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_REWARDS, false))
		{
			static char sValue[1280], sSet[4][320];
			strcopy(sValue, sizeof(sValue), value);
			ReplaceString(sValue, sizeof(sValue), " ", "");
			ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
			for (int iPos = 0; iPos < sizeof(esTank::g_iRewardEnabled); iPos++)
			{
				g_esTank[type].g_flRewardChance[iPos] = flGetClampedValue(key, "RewardChance", "Reward Chance", "Reward_Chance", "chance", g_esTank[type].g_flRewardChance[iPos], sSet[iPos], 0.1, 100.0);
				g_esTank[type].g_flRewardDuration[iPos] = flGetClampedValue(key, "RewardDuration", "Reward Duration", "Reward_Duration", "duration", g_esTank[type].g_flRewardDuration[iPos], sSet[iPos], 0.1, 999999.0);
				g_esTank[type].g_flRewardPercentage[iPos] = flGetClampedValue(key, "RewardPercentage", "Reward Percentage", "Reward_Percentage", "percent", g_esTank[type].g_flRewardPercentage[iPos], sSet[iPos], 0.1, 100.0);
				g_esTank[type].g_flActionDurationReward[iPos] = flGetClampedValue(key, "ActionDurationReward", "Action Duration Reward", "Action_Duration_Reward", "actionduration", g_esTank[type].g_flActionDurationReward[iPos], sSet[iPos], 0.0, 999999.0);
				g_esTank[type].g_flAttackBoostReward[iPos] = flGetClampedValue(key, "AttackBoostReward", "Attack Boost Reward", "Attack_Boost_Reward", "attackboost", g_esTank[type].g_flAttackBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
				g_esTank[type].g_flDamageBoostReward[iPos] = flGetClampedValue(key, "DamageBoostReward", "Damage Boost Reward", "Damage_Boost_Reward", "dmgboost", g_esTank[type].g_flDamageBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
				g_esTank[type].g_flDamageResistanceReward[iPos] = flGetClampedValue(key, "DamageResistanceReward", "Damage Resistance Reward", "Damage_Resistance_Reward", "dmgres", g_esTank[type].g_flDamageResistanceReward[iPos], sSet[iPos], 0.0, 1.0);
				g_esTank[type].g_flHealPercentReward[iPos] = flGetClampedValue(key, "HealPercentReward", "Heal Percent Reward", "Heal_Percent_Reward", "healpercent", g_esTank[type].g_flHealPercentReward[iPos], sSet[iPos], 0.0, 100.0);
				g_esTank[type].g_flJumpHeightReward[iPos] = flGetClampedValue(key, "JumpHeightReward", "Jump Height Reward", "Jump_Height_Reward", "jumpheight", g_esTank[type].g_flJumpHeightReward[iPos], sSet[iPos], 0.0, 999999.0);
				g_esTank[type].g_flPunchResistanceReward[iPos] = flGetClampedValue(key, "PunchResistanceReward", "Punch Resistance Reward", "Punch_Resistance_Reward", "punchres", g_esTank[type].g_flPunchResistanceReward[iPos], sSet[iPos], 0.0, 1.0);
				g_esTank[type].g_flShoveDamageReward[iPos] = flGetClampedValue(key, "ShoveDamageReward", "Shove Damage Reward", "Shove_Damage_Reward", "shovedmg", g_esTank[type].g_flShoveDamageReward[iPos], sSet[iPos], 0.0, 999999.0);
				g_esTank[type].g_flShoveRateReward[iPos] = flGetClampedValue(key, "ShoveRateReward", "Shove Rate Reward", "Shove_Rate_Reward", "shoverate", g_esTank[type].g_flShoveRateReward[iPos], sSet[iPos], 0.0, 999999.0);
				g_esTank[type].g_flSpeedBoostReward[iPos] = flGetClampedValue(key, "SpeedBoostReward", "Speed Boost Reward", "Speed_Boost_Reward", "speedboost", g_esTank[type].g_flSpeedBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
				g_esTank[type].g_iRewardEnabled[iPos] = iGetClampedValue(key, "RewardEnabled", "Reward Enabled", "Reward_Enabled", "renabled", g_esTank[type].g_iRewardEnabled[iPos], sSet[iPos], -1, 2147483647);
				g_esTank[type].g_iRewardBots[iPos] = iGetClampedValue(key, "RewardBots", "Reward Bots", "Reward_Bots", "bots", g_esTank[type].g_iRewardBots[iPos], sSet[iPos], -1, 2147483647);
				g_esTank[type].g_iRewardEffect[iPos] = iGetClampedValue(key, "RewardEffect", "Reward Effect", "Reward_Effect", "effect", g_esTank[type].g_iRewardEffect[iPos], sSet[iPos], 0, 15);
				g_esTank[type].g_iRewardNotify[iPos] = iGetClampedValue(key, "RewardNotify", "Reward Notify", "Reward_Notify", "rnotify", g_esTank[type].g_iRewardNotify[iPos], sSet[iPos], 0, 3);
				g_esTank[type].g_iRewardPriority[iPos] = iGetClampedValue(key, "RewardPriority", "Reward Priority", "Reward_Priority", "priority", g_esTank[type].g_iRewardPriority[iPos], sSet[iPos], 0, 4);
				g_esTank[type].g_iRewardVisual[iPos] = iGetClampedValue(key, "RewardVisual", "Reward Visual", "Reward_Visual", "visual", g_esTank[type].g_iRewardVisual[iPos], sSet[iPos], 0, 31);
				g_esTank[type].g_iAmmoBoostReward[iPos] = iGetClampedValue(key, "AmmoBoostReward", "Ammo Boost Reward", "Ammo_Boost_Reward", "ammoboost", g_esTank[type].g_iAmmoBoostReward[iPos], sSet[iPos], 0, 1);
				g_esTank[type].g_iAmmoRegenReward[iPos] = iGetClampedValue(key, "AmmoRegenReward", "Ammo Regen Reward", "Ammo_Regen_Reward", "ammoregen", g_esTank[type].g_iAmmoRegenReward[iPos], sSet[iPos], 0, 999999);
				g_esTank[type].g_iCleanKillsReward[iPos] = iGetClampedValue(key, "CleanKillsReward", "Clean Kills Reward", "Clean_Kills_Reward", "cleankills", g_esTank[type].g_iCleanKillsReward[iPos], sSet[iPos], 0, 1);
				g_esTank[type].g_iHealthRegenReward[iPos] = iGetClampedValue(key, "HealthRegenReward", "Health Regen Reward", "Health_Regen_Reward", "hpregen", g_esTank[type].g_iHealthRegenReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
				g_esTank[type].g_iHollowpointAmmoReward[iPos] = iGetClampedValue(key, "HollowpointAmmoReward", "Hollowpoint Ammo Reward", "Hollowpoint_Ammo_Reward", "hollowpoint", g_esTank[type].g_iHollowpointAmmoReward[iPos], sSet[iPos], 0, 1);
				g_esTank[type].g_iInfiniteAmmoReward[iPos] = iGetClampedValue(key, "InfiniteAmmoReward", "Infinite Ammo Reward", "Infinite_Ammo_Reward", "infammo", g_esTank[type].g_iInfiniteAmmoReward[iPos], sSet[iPos], 0, 31);
				g_esTank[type].g_iLadyKillerReward[iPos] = iGetClampedValue(key, "LadyKillerReward", "Lady Killer Reward", "Lady_Killer_Reward", "ladykiller", g_esTank[type].g_iLadyKillerReward[iPos], sSet[iPos], 0, 999999);
				g_esTank[type].g_iLifeLeechReward[iPos] = iGetClampedValue(key, "LifeLeechReward", "Life Leech Reward", "Life_Leech_Reward", "lifeleech", g_esTank[type].g_iLifeLeechReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
				g_esTank[type].g_iMeleeRangeReward[iPos] = iGetClampedValue(key, "MeleeRangeReward", "Melee Range Reward", "Melee_Range_Reward", "meleerange", g_esTank[type].g_iMeleeRangeReward[iPos], sSet[iPos], 0, 999999);
				g_esTank[type].g_iParticleEffectVisual[iPos] = iGetClampedValue(key, "ParticleEffectVisual", "Particle Effect Visual", "Particle_Effect_Visual", "particle", g_esTank[type].g_iParticleEffectVisual[iPos], sSet[iPos], 0, 15);
				g_esTank[type].g_iPrefsNotify[iPos] = iGetClampedValue(key, "PrefsNotify", "Prefs Notify", "Prefs_Notify", "pnotify", g_esTank[type].g_iPrefsNotify[iPos], sSet[iPos], 0, 1);
				g_esTank[type].g_iRespawnLoadoutReward[iPos] = iGetClampedValue(key, "RespawnLoadoutReward", "Respawn Loadout Reward", "Respawn_Loadout_Reward", "resloadout", g_esTank[type].g_iRespawnLoadoutReward[iPos], sSet[iPos], 0, 1);
				g_esTank[type].g_iReviveHealthReward[iPos] = iGetClampedValue(key, "ReviveHealthReward", "Revive Health Reward", "Revive_Health_Reward", "revivehp", g_esTank[type].g_iReviveHealthReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
				g_esTank[type].g_iShovePenaltyReward[iPos] = iGetClampedValue(key, "ShovePenaltyReward", "Shove Penalty Reward", "Shove_Penalty_Reward", "shovepenalty", g_esTank[type].g_iShovePenaltyReward[iPos], sSet[iPos], 0, 1);
				g_esTank[type].g_iSledgehammerRoundsReward[iPos] = iGetClampedValue(key, "SledgehammerRoundsReward", "Sledgehammer Rounds Reward", "Sledgehammer_Rounds_Reward", "sledgehammer", g_esTank[type].g_iSledgehammerRoundsReward[iPos], sSet[iPos], 0, 1);
				g_esTank[type].g_iSpecialAmmoReward[iPos] = iGetClampedValue(key, "SpecialAmmoReward", "Special Ammo Reward", "Special_Ammo_Reward", "specialammo", g_esTank[type].g_iSpecialAmmoReward[iPos], sSet[iPos], 0, 3);
				g_esTank[type].g_iStackRewards[iPos] = iGetClampedValue(key, "StackRewards", "Stack Rewards", "Stack_Rewards", "stack", g_esTank[type].g_iStackRewards[iPos], sSet[iPos], 0, 1);
				g_esTank[type].g_iThornsReward[iPos] = iGetClampedValue(key, "ThornsReward", "Thorns Reward", "Thorns_Reward", "thorns", g_esTank[type].g_iThornsReward[iPos], sSet[iPos], 0, 1);
				g_esTank[type].g_iUsefulRewards[iPos] = iGetClampedValue(key, "UsefulRewards", "Useful Rewards", "Useful_Rewards", "useful", g_esTank[type].g_iUsefulRewards[iPos], sSet[iPos], 0, 15);

				vGetStringValue(key, "BodyColorVisual", "Body Color Visual", "Body_Color_Visual", "bodycolor", iPos, g_esTank[type].g_sBodyColorVisual, sizeof(esTank::g_sBodyColorVisual), g_esTank[type].g_sBodyColorVisual2, sizeof(esTank::g_sBodyColorVisual2), g_esTank[type].g_sBodyColorVisual3, sizeof(esTank::g_sBodyColorVisual3), g_esTank[type].g_sBodyColorVisual4, sizeof(esTank::g_sBodyColorVisual4), sSet[iPos]);
				vGetStringValue(key, "FallVoicelineReward", "Fall Voiceline Reward", "Fall_Voiceline_Reward", "fallvoice", iPos, g_esTank[type].g_sFallVoicelineReward, sizeof(esTank::g_sFallVoicelineReward), g_esTank[type].g_sFallVoicelineReward2, sizeof(esTank::g_sFallVoicelineReward2), g_esTank[type].g_sFallVoicelineReward3, sizeof(esTank::g_sFallVoicelineReward3), g_esTank[type].g_sFallVoicelineReward4, sizeof(esTank::g_sFallVoicelineReward4), sSet[iPos]);
				vGetStringValue(key, "GlowColorVisual", "Glow Color Visual", "Glow_Color_Visual", "glowcolor", iPos, g_esTank[type].g_sGlowColorVisual, sizeof(esTank::g_sGlowColorVisual), g_esTank[type].g_sGlowColorVisual2, sizeof(esTank::g_sGlowColorVisual2), g_esTank[type].g_sGlowColorVisual3, sizeof(esTank::g_sGlowColorVisual3), g_esTank[type].g_sGlowColorVisual4, sizeof(esTank::g_sGlowColorVisual4), sSet[iPos]);
				vGetStringValue(key, "ItemReward", "Item Reward", "Item_Reward", "item", iPos, g_esTank[type].g_sItemReward, sizeof(esTank::g_sItemReward), g_esTank[type].g_sItemReward2, sizeof(esTank::g_sItemReward2), g_esTank[type].g_sItemReward3, sizeof(esTank::g_sItemReward3), g_esTank[type].g_sItemReward4, sizeof(esTank::g_sItemReward4), sSet[iPos]);
				vGetStringValue(key, "LoopingVoicelineVisual", "Looping Voiceline Visual", "Looping_Voiceline_Visual", "loopvoice", iPos, g_esTank[type].g_sLoopingVoicelineVisual, sizeof(esTank::g_sLoopingVoicelineVisual), g_esTank[type].g_sLoopingVoicelineVisual2, sizeof(esTank::g_sLoopingVoicelineVisual2), g_esTank[type].g_sLoopingVoicelineVisual3, sizeof(esTank::g_sLoopingVoicelineVisual3), g_esTank[type].g_sLoopingVoicelineVisual4, sizeof(esTank::g_sLoopingVoicelineVisual4), sSet[iPos]);
				vGetStringValue(key, "ScreenColorVisual", "Screen Color Visual", "Screen_Color_Visual", "screencolor", iPos, g_esTank[type].g_sScreenColorVisual, sizeof(esTank::g_sScreenColorVisual), g_esTank[type].g_sScreenColorVisual2, sizeof(esTank::g_sScreenColorVisual2), g_esTank[type].g_sScreenColorVisual3, sizeof(esTank::g_sScreenColorVisual3), g_esTank[type].g_sScreenColorVisual4, sizeof(esTank::g_sScreenColorVisual4), sSet[iPos]);
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_GLOW, false))
		{
			if (StrEqual(key, "GlowColor", false) || StrEqual(key, "Glow Color", false) || StrEqual(key, "Glow_Color", false))
			{
				static char sValue[12], sSet[3][4];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(esTank::g_iGlowColor); iPos++)
				{
					g_esTank[type].g_iGlowColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
				}
			}
			else if (StrEqual(key, "GlowRange", false) || StrEqual(key, "Glow Range", false) || StrEqual(key, "Glow_Range", false))
			{
				static char sValue[50], sRange[2][7];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

				g_esTank[type].g_iGlowMinRange = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, 999999) : g_esTank[type].g_iGlowMinRange;
				g_esTank[type].g_iGlowMaxRange = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, 999999) : g_esTank[type].g_iGlowMaxRange;
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_BOSS, false))
		{
			static char sValue[44], sSet[4][11];
			strcopy(sValue, sizeof(sValue), value);
			ReplaceString(sValue, sizeof(sValue), " ", "");
			ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
			for (int iPos = 0; iPos < sizeof(esTank::g_iBossHealth); iPos++)
			{
				g_esTank[type].g_iBossHealth[iPos] = iGetClampedValue(key, "BossHealthStages", "Boss Health Stages", "Boss_Health_Stages", "bosshpstages", g_esTank[type].g_iBossHealth[iPos], sSet[iPos], 1, MT_MAXHEALTH);
				g_esTank[type].g_iBossType[iPos] = iGetClampedValue(key, "BossTypes", "Boss Types", "Boss_Types", "bosstypes", g_esTank[type].g_iBossType[iPos], sSet[iPos], 1, MT_MAXTYPES);
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_COMBO, false))
		{
			if (StrEqual(key, "ComboTypeChance", false) || StrEqual(key, "Combo Type Chance", false) || StrEqual(key, "Combo_Type_Chance", false) || StrEqual(key, "typechance", false))
			{
				static char sValue[42], sSet[7][6];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(esTank::g_flComboTypeChance); iPos++)
				{
					g_esTank[type].g_flComboTypeChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esTank[type].g_flComboTypeChance[iPos];
				}
			}
			else
			{
				static char sValue[140], sSet[10][14];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(esTank::g_flComboChance); iPos++)
				{
					if (StrEqual(key, "ComboRadius", false) || StrEqual(key, "Combo Radius", false) || StrEqual(key, "Combo_Radius", false) || StrEqual(key, "radius", false))
					{
						static char sRange[2][7], sSubset[14];
						strcopy(sSubset, sizeof(sSubset), sSet[iPos]);
						ReplaceString(sSubset, sizeof(sSubset), " ", "");
						ExplodeString(sSubset, ";", sRange, sizeof(sRange), sizeof(sRange[]));

						g_esTank[type].g_flComboMinRadius[iPos] = (sRange[0][0] != '\0') ? flClamp(StringToFloat(sRange[0]), -200.0, 0.0) : g_esTank[type].g_flComboMinRadius[iPos];
						g_esTank[type].g_flComboMaxRadius[iPos] = (sRange[1][0] != '\0') ? flClamp(StringToFloat(sRange[1]), 0.0, 200.0) : g_esTank[type].g_flComboMaxRadius[iPos];
					}
					else
					{
						g_esTank[type].g_flComboChance[iPos] = flGetClampedValue(key, "ComboChance", "Combo Chance", "Combo_Chance", "chance", g_esTank[type].g_flComboChance[iPos], sSet[iPos], 0.0, 100.0);
						g_esTank[type].g_flComboDamage[iPos] = flGetClampedValue(key, "ComboDamage", "Combo Damage", "Combo_Damage", "damage", g_esTank[type].g_flComboDamage[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboDeathChance[iPos] = flGetClampedValue(key, "ComboDeathChance", "Combo Death Chance", "Combo_Death_Chance", "deathchance", g_esTank[type].g_flComboDeathChance[iPos], sSet[iPos], 0.0, 100.0);
						g_esTank[type].g_flComboDeathRange[iPos] = flGetClampedValue(key, "ComboDeathRange", "Combo Death Range", "Combo_Death_Range", "deathrange", g_esTank[type].g_flComboDeathRange[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboDelay[iPos] = flGetClampedValue(key, "ComboDelay", "Combo Delay", "Combo_Delay", "delay", g_esTank[type].g_flComboDelay[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboDuration[iPos] = flGetClampedValue(key, "ComboDuration", "Combo Duration", "Combo_Duration", "duration", g_esTank[type].g_flComboDuration[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboInterval[iPos] = flGetClampedValue(key, "ComboInterval", "Combo Interval", "Combo_Interval", "interval", g_esTank[type].g_flComboInterval[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboRange[iPos] = flGetClampedValue(key, "ComboRange", "Combo Range", "Combo_Range", "range", g_esTank[type].g_flComboRange[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboRangeChance[iPos] = flGetClampedValue(key, "ComboRangeChance", "Combo Range Chance", "Combo_Range_Chance", "rangechance", g_esTank[type].g_flComboRangeChance[iPos], sSet[iPos], 0.0, 100.0);
						g_esTank[type].g_flComboRockChance[iPos] = flGetClampedValue(key, "ComboRockChance", "Combo Rock Chance", "Combo_Rock_Chance", "rockchance", g_esTank[type].g_flComboRockChance[iPos], sSet[iPos], 0.0, 100.0);
						g_esTank[type].g_flComboSpeed[iPos] = flGetClampedValue(key, "ComboSpeed", "Combo Speed", "Combo_Speed", "speed", g_esTank[type].g_flComboSpeed[iPos], sSet[iPos], 0.0, 999999.0);
					}
				}
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_TRANSFORM, false))
		{
			if (StrEqual(key, "TransformTypes", false) || StrEqual(key, "Transform Types", false) || StrEqual(key, "Transform_Types", false) || StrEqual(key, "transtypes", false))
			{
				static char sValue[50], sSet[10][5];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(esTank::g_iTransformType); iPos++)
				{
					g_esTank[type].g_iTransformType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXTYPES) : g_esTank[type].g_iTransformType[iPos];
				}
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_PROPS, false))
		{
			if (StrEqual(key, "PropsChance", false) || StrEqual(key, "Props Chance", false) || StrEqual(key, "Props_Chance", false) || StrEqual(key, "chance", false))
			{
				static char sValue[54], sSet[9][6];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(esTank::g_flPropsChance); iPos++)
				{
					g_esTank[type].g_flPropsChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esTank[type].g_flPropsChance[iPos];
				}
			}
			else
			{
				static char sValue[16], sSet[4][4];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(esTank::g_iLightColor); iPos++)
				{
					g_esTank[type].g_iLightColor[iPos] = iGetClampedValue(key, "LightColor", "Light Color", "Light_Color", "light", g_esTank[type].g_iLightColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iOzTankColor[iPos] = iGetClampedValue(key, "OxygenTankColor", "Oxygen Tank Color", "Oxygen_Tank_Color", "oxygen", g_esTank[type].g_iOzTankColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iFlameColor[iPos] = iGetClampedValue(key, "FlameColor", "Flame Color", "Flame_Color", "flame", g_esTank[type].g_iFlameColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iRockColor[iPos] = iGetClampedValue(key, "RockColor", "Rock Color", "Rock_Color", "rock", g_esTank[type].g_iRockColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iTireColor[iPos] = iGetClampedValue(key, "TireColor", "Tire Color", "Tire_Color", "tire", g_esTank[type].g_iTireColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iPropTankColor[iPos] = iGetClampedValue(key, "PropaneTankColor", "Propane Tank Color", "Propane_Tank_Color", "propane", g_esTank[type].g_iPropTankColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iFlashlightColor[iPos] = iGetClampedValue(key, "FlashlightColor", "Flashlight Color", "Flashlight_Color", "flashlight", g_esTank[type].g_iFlashlightColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iCrownColor[iPos] = iGetClampedValue(key, "CrownColor", "Crown Color", "Crown_Color", "crown", g_esTank[type].g_iCrownColor[iPos], sSet[iPos], 0, 255, 0);
				}
			}
		}
		else
		{
			g_esTank[type].g_iAccessFlags = iGetAdminFlagsValue(sub, MT_CONFIG_SECTIONS_ADMIN, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esTank[type].g_iImmunityFlags = iGetAdminFlagsValue(sub, MT_CONFIG_SECTIONS_ADMIN, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);

			vGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "HealthCharacters", "Health Characters", "Health_Characters", "hpchars", g_esTank[type].g_sHealthCharacters, sizeof(esTank::g_sHealthCharacters), value);
			vGetKeyValue(sub, MT_CONFIG_SECTIONS_COMBO, key, "ComboSet", "Combo Set", "Combo_Set", "set", g_esTank[type].g_sComboSet, sizeof(esTank::g_sComboSet), value);
		}

		if (g_esTank[type].g_iAbilityCount == -1 && (StrContains(sub, "ability", false) != -1 || (((StrContains(key, "ability", false) == 0 && StrContains(key, "enabled", false) != -1) || StrEqual(key, "aenabled", false) || (StrContains(key, " hit", false) != -1 && StrContains(key, "mode", false) == -1) || StrEqual(key, "hit", false)) && StringToInt(value) > 0)))
		{
			g_esTank[type].g_iAbilityCount = 0;
		}
		else if (g_esTank[type].g_iAbilityCount != -1 && (bFoundSection(sub, 0) || bFoundSection(sub, 1) || bFoundSection(sub, 2) || bFoundSection(sub, 3))
			&& ((StrContains(key, "enabled", false) != -1 || (StrContains(key, " hit", false) != -1 && StrContains(key, "mode", false) == -1) || StrEqual(key, "hit", false)) && StringToInt(value) > 0))
		{
			g_esTank[type].g_iAbilityCount++;
		}

		Call_StartForward(g_esGeneral.g_gfConfigsLoadedForward);
		Call_PushString(sub);
		Call_PushString(key);
		Call_PushString(value);
		Call_PushCell(type);
		Call_PushCell(-1);
		Call_PushCell(g_esGeneral.g_iConfigMode);
		Call_Finish();
	}
}

static void vVocalize(int survivor, const char[] voiceline)
{
	switch (g_bSecondGame)
	{
		case true: FakeClientCommand(survivor, "vocalize %s #%i", voiceline, RoundToNearest(GetGameTime() * 10.0));
		case false: FakeClientCommand(survivor, "vocalize %s", voiceline);
	}
}

static void vVocalizeDeath(int killer, int assistant, int tank)
{
	if (g_esCache[tank].g_iVocalizeDeath == 1)
	{
		if (bIsSurvivor(killer))
		{
			vVocalize(killer, "PlayerHurrah");
		}

		if (bIsSurvivor(assistant) && assistant != killer)
		{
			vVocalize(assistant, "PlayerTaunt");
		}

		for (int iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
		{
			if (bIsSurvivor(iTeammate, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iTeammate].g_iTankDamage[tank] > 0.0 && iTeammate != killer && iTeammate != assistant)
			{
				vVocalize(iTeammate, "PlayerNiceJob");
			}
		}
	}
}

static void vExecuteFinaleConfigs(const char[] filename)
{
	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_FINALE) && g_esGeneral.g_iConfigEnable == 1)
	{
		static char sFilePath[PLATFORM_MAX_PATH], sFinaleConfig[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sFinaleConfig, sizeof(sFinaleConfig), "data/mutant_tanks/%s", (g_bSecondGame ? "l4d2_finale_configs/" : "l4d_finale_configs/"));
		FormatEx(sFilePath, sizeof(sFilePath), "%s%s.cfg", sFinaleConfig, filename);
		if (FileExists(sFilePath, true))
		{
			vCustomConfig(sFilePath);
		}
	}
}

static void vPluginStatus()
{
	bool bPluginAllowed = bIsPluginEnabled();
	if (!g_esGeneral.g_bPluginEnabled && bPluginAllowed)
	{
		g_esGeneral.g_bPluginEnabled = true;

		vHookEvents(true);

		vToggleDetour(g_esGeneral.g_ddDeathFallCameraEnableDetour, "CDeathFallCamera::Enable", Hook_Pre, mreDeathFallCameraEnablePre, true);
		vToggleDetour(g_esGeneral.g_ddDoJumpDetour, "CTerrorGameMovement::DoJump", Hook_Pre, mreDoJumpPre, true);
		vToggleDetour(g_esGeneral.g_ddDoJumpDetour, "CTerrorGameMovement::DoJump", Hook_Post, mreDoJumpPost, true);
		vToggleDetour(g_esGeneral.g_ddEnterStasisDetour, "Tank::EnterStasis", Hook_Post, mreEnterStasisPost, true);
		vToggleDetour(g_esGeneral.g_ddEventKilledDetour, "CTerrorPlayer::Event_Killed", Hook_Pre, mreEventKilledPre, true);
		vToggleDetour(g_esGeneral.g_ddEventKilledDetour, "CTerrorPlayer::Event_Killed", Hook_Post, mreEventKilledPost, true);
		vToggleDetour(g_esGeneral.g_ddFallingDetour, "CTerrorPlayer::OnFalling", Hook_Pre, mreFallingPre, true);
		vToggleDetour(g_esGeneral.g_ddFallingDetour, "CTerrorPlayer::OnFalling", Hook_Post, mreFallingPost, true);
		vToggleDetour(g_esGeneral.g_ddGetMaxClip1Detour, "CBaseCombatWeapon::GetMaxClip1", Hook_Pre, mreGetMaxClip1Pre, true);
		vToggleDetour(g_esGeneral.g_ddLauncherDirectionDetour, "CEnvRockLauncher::LaunchCurrentDir", Hook_Pre, mreLaunchDirectionPre, true);
		vToggleDetour(g_esGeneral.g_ddLeaveStasisDetour, "Tank::LeaveStasis", Hook_Post, mreLeaveStasisPost, true);
		vToggleDetour(g_esGeneral.g_ddMaxCarryDetour, "CAmmoDef::MaxCarry", Hook_Pre, mreMaxCarryPre, true);
		vToggleDetour(g_esGeneral.g_ddRevivedDetour, "CTerrorPlayer::OnRevived", Hook_Pre, mreRevivedPre, true);
		vToggleDetour(g_esGeneral.g_ddRevivedDetour, "CTerrorPlayer::OnRevived", Hook_Post, mreRevivedPost, true);
		vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour, "CTerrorWeapon::SecondaryAttack", Hook_Pre, mreSecondaryAttackPre, true);
		vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour, "CTerrorWeapon::SecondaryAttack", Hook_Post, mreSecondaryAttackPost, true);
		vToggleDetour(g_esGeneral.g_ddStartRevivingDetour, "CTerrorPlayer::StartReviving", Hook_Pre, mreStartRevivingPre, true);
		vToggleDetour(g_esGeneral.g_ddStartRevivingDetour, "CTerrorPlayer::StartReviving", Hook_Post, mreStartRevivingPost, true);
		vToggleDetour(g_esGeneral.g_ddTankClawDoSwingDetour, "CTankClaw::DoSwing", Hook_Pre, mreTankClawDoSwingPre, true);
		vToggleDetour(g_esGeneral.g_ddTankClawDoSwingDetour, "CTankClaw::DoSwing", Hook_Post, mreTankClawDoSwingPost, true);
		vToggleDetour(g_esGeneral.g_ddTankClawPlayerHitDetour, "CTankClaw::OnPlayerHit", Hook_Pre, mreTankClawPlayerHitPre, true);
		vToggleDetour(g_esGeneral.g_ddTankClawPlayerHitDetour, "CTankClaw::OnPlayerHit", Hook_Post, mreTankClawPlayerHitPost, true);
		vToggleDetour(g_esGeneral.g_ddTankRockCreateDetour, "CTankRock::Create", Hook_Post, mreTankRockCreatePost, true);
		vToggleDetour(g_esGeneral.g_ddVomitedUponDetour, "CTerrorPlayer::OnVomitedUpon", Hook_Pre, mreVomitedUponPre, true);
		vToggleDetour(g_esGeneral.g_ddActionCompleteDetour, "CFirstAidKit::OnActionComplete", Hook_Pre, mreActionCompletePre, true, 2);
		vToggleDetour(g_esGeneral.g_ddActionCompleteDetour, "CFirstAidKit::OnActionComplete", Hook_Post, mreActionCompletePost, true, 2);
		vToggleDetour(g_esGeneral.g_ddDoAnimationEventDetour, "CTerrorPlayer::DoAnimationEvent", Hook_Pre, mreDoAnimationEventPre, true, 2);
		vToggleDetour(g_esGeneral.g_ddFireBulletDetour, "CTerrorGun::FireBullet", Hook_Pre, mreFireBulletPre, true, 2);
		vToggleDetour(g_esGeneral.g_ddFireBulletDetour, "CTerrorGun::FireBullet", Hook_Post, mreFireBulletPost, true, 2);
		vToggleDetour(g_esGeneral.g_ddFlingDetour, "CTerrorPlayer::Fling", Hook_Pre, mreFlingPre, true, 2);
		vToggleDetour(g_esGeneral.g_ddHitByVomitJarDetour, "CTerrorPlayer::OnHitByVomitJar", Hook_Pre, mreHitByVomitJarPre, true, 2);
		vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour2, "CTerrorMeleeWeapon::SecondaryAttack", Hook_Pre, mreSecondaryAttackPre, true, 2);
		vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour2, "CTerrorMeleeWeapon::SecondaryAttack", Hook_Post, mreSecondaryAttackPost, true, 2);
		vToggleDetour(g_esGeneral.g_ddSelectWeightedSequenceDetour, "CTerrorPlayer::SelectWeightedSequence", Hook_Post, mreSelectWeightedSequencePost, true, 2);
		vToggleDetour(g_esGeneral.g_ddStartActionDetour, "CBaseBackpackItem::StartAction", Hook_Pre, mreStartActionPre, true, 2);
		vToggleDetour(g_esGeneral.g_ddStartActionDetour, "CBaseBackpackItem::StartAction", Hook_Post, mreStartActionPost, true, 2);
		vToggleDetour(g_esGeneral.g_ddTestMeleeSwingCollisionDetour, "CTerrorMeleeWeapon::TestMeleeSwingCollision", Hook_Pre, mreTestMeleeSwingCollisionPre, true, 2);
		vToggleDetour(g_esGeneral.g_ddTestMeleeSwingCollisionDetour, "CTerrorMeleeWeapon::TestMeleeSwingCollision", Hook_Post, mreTestMeleeSwingCollisionPost, true, 2);
		vToggleDetour(g_esGeneral.g_ddFinishHealingDetour, "CFirstAidKit::FinishHealing", Hook_Pre, mreFinishHealingPre, true, 1);
		vToggleDetour(g_esGeneral.g_ddFinishHealingDetour, "CFirstAidKit::FinishHealing", Hook_Post, mreFinishHealingPost, true, 1);
		vToggleDetour(g_esGeneral.g_ddSetMainActivityDetour, "CTerrorPlayer::SetMainActivity", Hook_Pre, mreSetMainActivityPre, true, 1);
		vToggleDetour(g_esGeneral.g_ddStartHealingDetour, "CFirstAidKit::StartHealing", Hook_Pre, mreStartHealingPre, true, 1);
		vToggleDetour(g_esGeneral.g_ddStartHealingDetour, "CFirstAidKit::StartHealing", Hook_Post, mreStartHealingPost, true, 1);

		if (!g_esGeneral.g_bLeft4DHooksInstalled)
		{
			vToggleDetour(g_esGeneral.g_ddEnterGhostStateDetour, "CTerrorPlayer::OnEnterGhostState", Hook_Post, mreEnterGhostStatePost, true);
			vToggleDetour(g_esGeneral.g_ddFirstSurvivorLeftSafeAreaDetour, "CDirector::OnFirstSurvivorLeftSafeArea", Hook_Post, mreFirstSurvivorLeftSafeAreaPost, true);
			vToggleDetour(g_esGeneral.g_ddReplaceTankDetour, "ZombieManager::ReplaceTank", Hook_Post, mreReplaceTankPost, true);
			vToggleDetour(g_esGeneral.g_ddShovedByPounceLandingDetour, "CTerrorPlayer::OnShovedByPounceLanding", Hook_Pre, mreShovedByPounceLandingPre, true);
			vToggleDetour(g_esGeneral.g_ddShovedBySurvivorDetour, "CTerrorPlayer::OnShovedBySurvivor", Hook_Pre, mreShovedBySurvivorPre, true);
			vToggleDetour(g_esGeneral.g_ddSpawnTankDetour, "ZombieManager::SpawnTank", Hook_Pre, mreSpawnTankPre, true);
			vToggleDetour(g_esGeneral.g_ddStaggerDetour, "CTerrorPlayer::OnStaggered", Hook_Pre, mreStaggerPre, true);
		}
	}
	else if (g_esGeneral.g_bPluginEnabled && !bPluginAllowed)
	{
		g_esGeneral.g_bPluginEnabled = false;

		vHookEvents(false);

		vToggleDetour(g_esGeneral.g_ddDeathFallCameraEnableDetour, "CDeathFallCamera::Enable", Hook_Pre, mreDeathFallCameraEnablePre, false);
		vToggleDetour(g_esGeneral.g_ddDoJumpDetour, "CTerrorGameMovement::DoJump", Hook_Pre, mreDoJumpPre, false);
		vToggleDetour(g_esGeneral.g_ddDoJumpDetour, "CTerrorGameMovement::DoJump", Hook_Post, mreDoJumpPost, false);
		vToggleDetour(g_esGeneral.g_ddEnterStasisDetour, "Tank::EnterStasis", Hook_Post, mreEnterStasisPost, false);
		vToggleDetour(g_esGeneral.g_ddEventKilledDetour, "CTerrorPlayer::Event_Killed", Hook_Pre, mreEventKilledPre, false);
		vToggleDetour(g_esGeneral.g_ddEventKilledDetour, "CTerrorPlayer::Event_Killed", Hook_Post, mreEventKilledPost, false);
		vToggleDetour(g_esGeneral.g_ddFallingDetour, "CTerrorPlayer::OnFalling", Hook_Pre, mreFallingPre, false);
		vToggleDetour(g_esGeneral.g_ddFallingDetour, "CTerrorPlayer::OnFalling", Hook_Post, mreFallingPost, false);
		vToggleDetour(g_esGeneral.g_ddGetMaxClip1Detour, "CBaseCombatWeapon::GetMaxClip1", Hook_Pre, mreGetMaxClip1Pre, false);
		vToggleDetour(g_esGeneral.g_ddLauncherDirectionDetour, "CEnvRockLauncher::LaunchCurrentDir", Hook_Pre, mreLaunchDirectionPre, false);
		vToggleDetour(g_esGeneral.g_ddLeaveStasisDetour, "Tank::LeaveStasis", Hook_Post, mreLeaveStasisPost, false);
		vToggleDetour(g_esGeneral.g_ddMaxCarryDetour, "CAmmoDef::MaxCarry", Hook_Pre, mreMaxCarryPre, false);
		vToggleDetour(g_esGeneral.g_ddRevivedDetour, "CTerrorPlayer::OnRevived", Hook_Pre, mreRevivedPre, false);
		vToggleDetour(g_esGeneral.g_ddRevivedDetour, "CTerrorPlayer::OnRevived", Hook_Post, mreRevivedPost, false);
		vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour, "CTerrorWeapon::SecondaryAttack", Hook_Pre, mreSecondaryAttackPre, false);
		vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour, "CTerrorWeapon::SecondaryAttack", Hook_Post, mreSecondaryAttackPost, false);
		vToggleDetour(g_esGeneral.g_ddStartRevivingDetour, "CTerrorPlayer::StartReviving", Hook_Pre, mreStartRevivingPre, false);
		vToggleDetour(g_esGeneral.g_ddStartRevivingDetour, "CTerrorPlayer::StartReviving", Hook_Post, mreStartRevivingPost, false);
		vToggleDetour(g_esGeneral.g_ddTankClawDoSwingDetour, "CTankClaw::DoSwing", Hook_Pre, mreTankClawDoSwingPre, false);
		vToggleDetour(g_esGeneral.g_ddTankClawDoSwingDetour, "CTankClaw::DoSwing", Hook_Post, mreTankClawDoSwingPost, false);
		vToggleDetour(g_esGeneral.g_ddTankClawPlayerHitDetour, "CTankClaw::OnPlayerHit", Hook_Pre, mreTankClawPlayerHitPre, false);
		vToggleDetour(g_esGeneral.g_ddTankClawPlayerHitDetour, "CTankClaw::OnPlayerHit", Hook_Post, mreTankClawPlayerHitPost, false);
		vToggleDetour(g_esGeneral.g_ddTankRockCreateDetour, "CTankRock::Create", Hook_Post, mreTankRockCreatePost, false);
		vToggleDetour(g_esGeneral.g_ddVomitedUponDetour, "CTerrorPlayer::OnVomitedUpon", Hook_Pre, mreVomitedUponPre, false);
		vToggleDetour(g_esGeneral.g_ddActionCompleteDetour, "CFirstAidKit::OnActionComplete", Hook_Pre, mreActionCompletePre, false, 2);
		vToggleDetour(g_esGeneral.g_ddActionCompleteDetour, "CFirstAidKit::OnActionComplete", Hook_Post, mreActionCompletePost, false, 2);
		vToggleDetour(g_esGeneral.g_ddDoAnimationEventDetour, "CTerrorPlayer::DoAnimationEvent", Hook_Pre, mreDoAnimationEventPre, false, 2);
		vToggleDetour(g_esGeneral.g_ddFireBulletDetour, "CTerrorGun::FireBullet", Hook_Pre, mreFireBulletPre, false, 2);
		vToggleDetour(g_esGeneral.g_ddFireBulletDetour, "CTerrorGun::FireBullet", Hook_Post, mreFireBulletPost, false, 2);
		vToggleDetour(g_esGeneral.g_ddFlingDetour, "CTerrorPlayer::Fling", Hook_Pre, mreFlingPre, false, 2);
		vToggleDetour(g_esGeneral.g_ddHitByVomitJarDetour, "CTerrorPlayer::OnHitByVomitJar", Hook_Pre, mreHitByVomitJarPre, false, 2);
		vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour2, "CTerrorMeleeWeapon::SecondaryAttack", Hook_Pre, mreSecondaryAttackPre, false, 2);
		vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour2, "CTerrorMeleeWeapon::SecondaryAttack", Hook_Post, mreSecondaryAttackPost, false, 2);
		vToggleDetour(g_esGeneral.g_ddSelectWeightedSequenceDetour, "CTerrorPlayer::SelectWeightedSequence", Hook_Post, mreSelectWeightedSequencePost, false, 2);
		vToggleDetour(g_esGeneral.g_ddStartActionDetour, "CBaseBackpackItem::StartAction", Hook_Pre, mreStartActionPre, false, 2);
		vToggleDetour(g_esGeneral.g_ddStartActionDetour, "CBaseBackpackItem::StartAction", Hook_Post, mreStartActionPost, false, 2);
		vToggleDetour(g_esGeneral.g_ddTestMeleeSwingCollisionDetour, "CTerrorMeleeWeapon::TestMeleeSwingCollision", Hook_Pre, mreTestMeleeSwingCollisionPre, false, 2);
		vToggleDetour(g_esGeneral.g_ddTestMeleeSwingCollisionDetour, "CTerrorMeleeWeapon::TestMeleeSwingCollision", Hook_Post, mreTestMeleeSwingCollisionPost, false, 2);
		vToggleDetour(g_esGeneral.g_ddFinishHealingDetour, "CFirstAidKit::FinishHealing", Hook_Pre, mreFinishHealingPre, false, 1);
		vToggleDetour(g_esGeneral.g_ddFinishHealingDetour, "CFirstAidKit::FinishHealing", Hook_Post, mreFinishHealingPost, false, 1);
		vToggleDetour(g_esGeneral.g_ddSetMainActivityDetour, "CTerrorPlayer::SetMainActivity", Hook_Pre, mreSetMainActivityPre, false, 1);
		vToggleDetour(g_esGeneral.g_ddStartHealingDetour, "CFirstAidKit::StartHealing", Hook_Pre, mreStartHealingPre, false, 1);
		vToggleDetour(g_esGeneral.g_ddStartHealingDetour, "CFirstAidKit::StartHealing", Hook_Post, mreStartHealingPost, false, 1);

		if (!g_esGeneral.g_bLeft4DHooksInstalled)
		{
			vToggleDetour(g_esGeneral.g_ddEnterGhostStateDetour, "CTerrorPlayer::OnEnterGhostState", Hook_Post, mreEnterGhostStatePost, false);
			vToggleDetour(g_esGeneral.g_ddFirstSurvivorLeftSafeAreaDetour, "CDirector::OnFirstSurvivorLeftSafeArea", Hook_Post, mreFirstSurvivorLeftSafeAreaPost, false);
			vToggleDetour(g_esGeneral.g_ddReplaceTankDetour, "ZombieManager::ReplaceTank", Hook_Post, mreReplaceTankPost, false);
			vToggleDetour(g_esGeneral.g_ddShovedByPounceLandingDetour, "CTerrorPlayer::OnShovedByPounceLanding", Hook_Pre, mreShovedByPounceLandingPre, false);
			vToggleDetour(g_esGeneral.g_ddShovedBySurvivorDetour, "CTerrorPlayer::OnShovedBySurvivor", Hook_Pre, mreShovedBySurvivorPre, false);
			vToggleDetour(g_esGeneral.g_ddSpawnTankDetour, "ZombieManager::SpawnTank", Hook_Pre, mreSpawnTankPre, false);
			vToggleDetour(g_esGeneral.g_ddStaggerDetour, "CTerrorPlayer::OnStaggered", Hook_Pre, mreStaggerPre, false);
		}
	}
}

static void vHookEvents(bool hook)
{
	static bool bHooked, bCheck[41];
	if (hook && !bHooked)
	{
		bHooked = true;

		bCheck[0] = HookEventEx("ability_use", vEventHandler);
		bCheck[1] = HookEventEx("bot_player_replace", vEventHandler);
		bCheck[2] = HookEventEx("choke_start", vEventHandler);
		bCheck[3] = HookEventEx("create_panic_event", vEventHandler);
		bCheck[4] = HookEventEx("entity_shoved", vEventHandler);
		bCheck[5] = HookEventEx("finale_escape_start", vEventHandler);
		bCheck[6] = HookEventEx("finale_start", vEventHandler, EventHookMode_Pre);
		bCheck[7] = HookEventEx("finale_vehicle_leaving", vEventHandler);
		bCheck[8] = HookEventEx("finale_vehicle_ready", vEventHandler);
		bCheck[9] = HookEventEx("finale_rush", vEventHandler);
		bCheck[10] = HookEventEx("finale_radio_start", vEventHandler);
		bCheck[11] = HookEventEx("finale_radio_damaged", vEventHandler);
		bCheck[12] = HookEventEx("finale_win", vEventHandler);
		bCheck[13] = HookEventEx("heal_success", vEventHandler);
		bCheck[14] = HookEventEx("infected_hurt", vEventHandler);
		bCheck[15] = HookEventEx("lunge_pounce", vEventHandler);
		bCheck[16] = HookEventEx("mission_lost", vEventHandler);
		bCheck[17] = HookEventEx("player_bot_replace", vEventHandler);
		bCheck[18] = HookEventEx("player_connect", vEventHandler, EventHookMode_Pre);
		bCheck[19] = HookEventEx("player_death", vEventHandler, EventHookMode_Pre);
		bCheck[20] = HookEventEx("player_disconnect", vEventHandler, EventHookMode_Pre);
		bCheck[21] = HookEventEx("player_hurt", vEventHandler);
		bCheck[22] = HookEventEx("player_incapacitated", vEventHandler);
		bCheck[23] = HookEventEx("player_jump", vEventHandler);
		bCheck[24] = HookEventEx("player_ledge_grab", vEventHandler);
		bCheck[25] = HookEventEx("player_now_it", vEventHandler);
		bCheck[26] = HookEventEx("player_no_longer_it", vEventHandler);
		bCheck[27] = HookEventEx("player_shoved", vEventHandler);
		bCheck[28] = HookEventEx("player_spawn", vEventHandler);
		bCheck[29] = HookEventEx("player_team", vEventHandler);
		bCheck[30] = HookEventEx("revive_success", vEventHandler);
		bCheck[31] = HookEventEx("tongue_grab", vEventHandler);
		bCheck[32] = HookEventEx("weapon_fire", vEventHandler);
		bCheck[33] = HookEventEx("witch_harasser_set", vEventHandler);
		bCheck[34] = HookEventEx("witch_killed", vEventHandler);

		if (g_bSecondGame)
		{
			bCheck[35] = HookEventEx("charger_carry_start", vEventHandler);
			bCheck[36] = HookEventEx("charger_pummel_start", vEventHandler);
			bCheck[37] = HookEventEx("finale_vehicle_incoming", vEventHandler);
			bCheck[38] = HookEventEx("finale_bridge_lowering", vEventHandler);
			bCheck[39] = HookEventEx("gauntlet_finale_start", vEventHandler);
			bCheck[40] = HookEventEx("jockey_ride", vEventHandler);
		}

		vHookEventForward(true);
	}
	else if (!hook && bHooked)
	{
		static bool bPreHook[41];
		bHooked = false;
		static char sEvent[32];

		for (int iPos = 0; iPos < sizeof(bCheck); iPos++)
		{
			switch (iPos)
			{
				case 0: sEvent = "ability_use";
				case 1: sEvent = "bot_player_replace";
				case 2: sEvent = "choke_start";
				case 3: sEvent = "create_panic_event";
				case 4: sEvent = "entity_shoved";
				case 5: sEvent = "finale_escape_start";
				case 6: sEvent = "finale_start";
				case 7: sEvent = "finale_vehicle_leaving";
				case 8: sEvent = "finale_vehicle_ready";
				case 9: sEvent = "finale_rush";
				case 10: sEvent = "finale_radio_start";
				case 11: sEvent = "finale_radio_damaged";
				case 12: sEvent = "finale_win";
				case 13: sEvent = "heal_success";
				case 14: sEvent = "infected_hurt";
				case 15: sEvent = "lunge_pounce";
				case 16: sEvent = "mission_lost";
				case 17: sEvent = "player_bot_replace";
				case 18: sEvent = "player_connect";
				case 19: sEvent = "player_death";
				case 20: sEvent = "player_disconnect";
				case 21: sEvent = "player_hurt";
				case 22: sEvent = "player_incapacitated";
				case 23: sEvent = "player_jump";
				case 24: sEvent = "player_ledge_grab";
				case 25: sEvent = "player_now_it";
				case 26: sEvent = "player_no_longer_it";
				case 27: sEvent = "player_shoved";
				case 28: sEvent = "player_spawn";
				case 29: sEvent = "player_team";
				case 30: sEvent = "revive_success";
				case 31: sEvent = "tongue_grab";
				case 32: sEvent = "weapon_fire";
				case 33: sEvent = "witch_harasser_set";
				case 34: sEvent = "witch_killed";
				case 35: sEvent = "charger_carry_start";
				case 36: sEvent = "charger_pummel_start";
				case 37: sEvent = "finale_vehicle_incoming";
				case 38: sEvent = "finale_bridge_lowering";
				case 39: sEvent = "gauntlet_finale_start";
				case 40: sEvent = "jockey_ride";
			}

			if (bCheck[iPos])
			{
				bPreHook[iPos] = (iPos == 6) || (iPos >= 18 && iPos <= 20);

				if (!g_bSecondGame && iPos >= 35 && iPos <= 40)
				{
					continue;
				}

				UnhookEvent(sEvent, vEventHandler, (bPreHook[iPos] ? EventHookMode_Pre : EventHookMode_Post));
			}
		}

		vHookEventForward(false);
	}
}

static void vHookEventForward(bool mode)
{
	Call_StartForward(g_esGeneral.g_gfHookEventForward);
	Call_PushCell(mode);
	Call_Finish();
}

static void vLogCommand(int admin, int type, const char[] activity, any ...)
{
	if (g_esGeneral.g_iLogCommands & type)
	{
		static char sMessage[1024];
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && CheckCommandAccess(iPlayer, "sm_admin", ADMFLAG_ROOT, true) && iPlayer != admin)
			{
				SetGlobalTransTarget(iPlayer);
				VFormat(sMessage, sizeof(sMessage), activity, 4);
				MT_PrintToChat(iPlayer, sMessage);
			}
		}
	}
}

static void vLogMessage(int type, bool timestamp = true, const char[] message, any ...)
{
	if (type == -1 || (g_esGeneral.g_iLogMessages & type))
	{
		static Action aResult;
		aResult = Plugin_Continue;

		Call_StartForward(g_esGeneral.g_gfLogMessageForward);
		Call_PushCell(type);
		Call_PushString(message);
		Call_Finish(aResult);

		switch (aResult)
		{
			case Plugin_Handled: return;
			case Plugin_Continue:
			{
				static char sBuffer[1024], sMessage[1024];
				SetGlobalTransTarget(LANG_SERVER);
				VFormat(sBuffer, sizeof(sBuffer), message, 4);
				MT_ReplaceChatPlaceholders(sBuffer, sizeof(sBuffer), true);

				switch (timestamp)
				{
					case true:
					{
						static char sTime[32];
						FormatTime(sTime, sizeof(sTime), "%Y-%m-%d - %H:%M:%S", GetTime());
						FormatEx(sMessage, sizeof(sMessage), "[%s] %s", sTime, sBuffer);
						vSaveMessage(sMessage);
					}
					case false: vSaveMessage(sBuffer);
				}

				PrintToServer(sBuffer);
			}
		}
	}
}

static void vSetupDetour(DynamicDetour &detourHandle, GameData dataHandle, const char[] name)
{
	detourHandle = DynamicDetour.FromConf(dataHandle, name);
	if (detourHandle == null)
	{
		LogError("%s Failed to find signature: %s", MT_TAG, name);
	}
}

static void vToggleDetour(DynamicDetour &detourHandle, const char[] name, HookMode mode, DHookCallback callback, bool toggle, int game = 0)
{
	if ((game == 1 && g_bSecondGame) || (game == 2 && !g_bSecondGame))
	{
		return;
	}

	if ((toggle && !detourHandle.Enable(mode, callback)) || (!toggle && !detourHandle.Disable(mode, callback)))
	{
		LogError("%s Failed to %s the %s-hook detour for the \"%s\" function.", MT_TAG, (toggle ? "enable" : "disable"), ((mode == Hook_Pre) ? "pre" : "post"), name);
	}
}

static void vToggleEffects(int survivor, int type = 0)
{
	if (type == 0 || type == 1)
	{
		switch (g_esPlayer[survivor].g_flVisualTime[1] != -1.0 && g_esPlayer[survivor].g_flVisualTime[1] > GetGameTime())
		{
			case true: vSetSurvivorOutline(survivor, g_esPlayer[survivor].g_sGlowColor, g_esPlayer[survivor].g_bApplyVisuals[1], _, true);
			case false: vRemoveGlow(survivor);
		}
	}

	if (type == 0 || type == 2)
	{
		switch (g_esPlayer[survivor].g_flVisualTime[2] != -1.0 && g_esPlayer[survivor].g_flVisualTime[2] > GetGameTime())
		{
			case true: vSetSurvivorColor(survivor, g_esPlayer[survivor].g_sBodyColor, g_esPlayer[survivor].g_bApplyVisuals[2], _, true);
			case false: SetEntityRenderColor(survivor, 255, 255, 255, 255);
		}
	}
}

static void vToggleLogging(int type = -1)
{
	static char sMessage[1024], sMap[128], sTime[32], sDate[32];
	GetCurrentMap(sMap, sizeof(sMap));
	if (IsMapValid(sMap))
	{
		FormatTime(sTime, sizeof(sTime), "%m/%d/%Y %H:%M:%S", GetTime());
		FormatTime(sDate, sizeof(sDate), "%Y-%m-%d", GetTime());
		BuildPath(Path_SM, g_esGeneral.g_sLogFile, sizeof(esGeneral::g_sLogFile), "logs/mutant_tanks_%s.log", sDate);

		static bool bLog;
		bLog = false;
		static int iType;

		switch (type)
		{
			case -1:
			{
				if (g_esGeneral.g_iLogMessages != iType)
				{
					bLog = true;
					iType = g_esGeneral.g_iLogMessages;

					FormatEx(sMessage, sizeof(sMessage), "%T", ((iType != 0) ? "LogStarted" : "LogEnded"), LANG_SERVER, sTime, sMap);
				}
			}
			case 0, 1:
			{
				if (g_esGeneral.g_iLogMessages != 0)
				{
					bLog = true;
					iType = g_esGeneral.g_iLogMessages;

					FormatEx(sMessage, sizeof(sMessage), "%T", ((type == 1) ? "LogStarted" : "LogEnded"), LANG_SERVER, sTime, sMap);
				}
			}
		}

		if (bLog)
		{
			int iLength = strlen(sMessage);
			char[] sBorder = new char[iLength + 1];
			StrCat(sBorder, iLength, "--");
			for (int iPos = 0; iPos < iLength - 4; iPos++)
			{
				StrCat(sBorder, iLength + 1, "=");
			}

			StrCat(sBorder, iLength + 1, "--");
			vSaveMessage(sBorder);
			vSaveMessage(sMessage);
			vSaveMessage(sBorder);
		}
	}
}

static void vSaveMessage(const char[] message)
{
	File fLog = OpenFile(g_esGeneral.g_sLogFile, "a");
	if (fLog != null)
	{
		fLog.WriteLine(message);

		delete fLog;
	}
}

static void vBoss(int tank, int limit, int stages, int type, int stage)
{
	if (stages >= stage)
	{
		static int iHealth;
		iHealth = GetEntProp(tank, Prop_Data, "m_iHealth");
		if (iHealth <= limit)
		{
			g_esPlayer[tank].g_iBossStageCount = stage;

			vResetSpeed(tank);
			vSurvivorReactions(tank);
			vSetColor(tank, type, false);
			vTankSpawn(tank, 1);

			static int iNewHealth, iLeftover, iLeftover2, iFinalHealth;
			iNewHealth = GetEntProp(tank, Prop_Data, "m_iMaxHealth") + limit;
			iLeftover = iNewHealth - iHealth;
			iLeftover2 = (iLeftover > MT_MAXHEALTH) ? (iLeftover - MT_MAXHEALTH) : iLeftover;
			iFinalHealth = (iNewHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iNewHealth;
			g_esPlayer[tank].g_iTankHealth += (iLeftover > MT_MAXHEALTH) ? iLeftover2 : iLeftover;
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth);
		}
	}
}

static void vSurvivorReactions(int tank)
{
	static char sModel[40];
	static float flTankPos[3], flSurvivorPos[3];
	GetClientAbsOrigin(tank, flTankPos);
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);
			if (GetVectorDistance(flTankPos, flSurvivorPos) <= 500.0)
			{
				if (bIsValidClient(iSurvivor, MT_CHECK_FAKECLIENT))
				{
					vShakePlayerScreen(iSurvivor, 2.0);
				}
			}

			switch (GetRandomInt(1, 5))
			{
				case 1:
				{
					GetEntPropString(iSurvivor, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

					switch (sModel[29])
					{
						case 'b', 'd', 'c', 'h': vVocalize(iSurvivor, "C2M1Falling");
						case 'v', 'n', 'e', 'a': vVocalize(iSurvivor, "PlaneCrashResponse");
					}
				}
				case 2: vVocalize(iSurvivor, "PlayerYellRun");
				case 3: vVocalize(iSurvivor, (g_bSecondGame ? "PlayerWarnTank" : "PlayerAlsoWarnTank"));
				case 4: vVocalize(iSurvivor, "PlayerBackUp");
				case 5: vVocalize(iSurvivor, "PlayerEmphaticGo");
			}
		}
	}

	static int iExplosion;
	iExplosion = CreateEntityByName("env_explosion");
	if (bIsValidEntity(iExplosion))
	{
		DispatchKeyValue(iExplosion, "fireballsprite", SPRITE_EXPLODE);
		DispatchKeyValue(iExplosion, "iMagnitude", "50");
		DispatchKeyValue(iExplosion, "rendermode", "5");
		DispatchKeyValue(iExplosion, "spawnflags", "1");

		TeleportEntity(iExplosion, flTankPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iExplosion);

		SetEntPropEnt(iExplosion, Prop_Send, "m_hOwnerEntity", tank);
		SetEntProp(iExplosion, Prop_Send, "m_iTeamNum", 3);
		AcceptEntityInput(iExplosion, "Explode");

		iExplosion = EntIndexToEntRef(iExplosion);
		vDeleteEntity(iExplosion, 2.0);

		EmitSoundToAll((g_bSecondGame ? SOUND_EXPLOSION2 : SOUND_EXPLOSION1), iExplosion, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}

	if (g_bSecondGame)
	{
		static int iTimescale;
		iTimescale = CreateEntityByName("func_timescale");
		if (bIsValidEntity(iTimescale))
		{
			DispatchKeyValueFloat(iTimescale, "desiredTimescale", 0.2);
			DispatchKeyValueFloat(iTimescale, "acceleration", 2.0);
			DispatchKeyValueFloat(iTimescale, "minBlendRate", 1.0);
			DispatchKeyValueFloat(iTimescale, "blendDeltaMultiplier", 2.0);
			DispatchSpawn(iTimescale);
			AcceptEntityInput(iTimescale, "Start");
			CreateTimer(0.75, tTimerRemoveTimescale, EntIndexToEntRef(iTimescale), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	vPushNearbyEntities(tank, flTankPos);

	flTankPos[2] += 40.0;
	TE_SetupBeamRingPoint(flTankPos, 10.0, 2000.0, g_iBossBeamSprite, g_iBossHaloSprite, 0, 50, 1.0, 88.0, 3.0, {255, 255, 255, 50}, 1000, 0);
	TE_SendToAll();
}

static void vChangeTypeForward(int tank, int oldType, int newType, bool revert)
{
	Call_StartForward(g_esGeneral.g_gfChangeTypeForward);
	Call_PushCell(tank);
	Call_PushCell(oldType);
	Call_PushCell(newType);
	Call_PushCell(revert);
	Call_Finish();
}

static void vRegularSpawn()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vCheatCommand(iPlayer, (g_bSecondGame ? "z_spawn_old" : "z_spawn"), "tank auto");

			break;
		}
	}
}

static void vRemoveDamage(int victim, int damagetype)
{
	if (damagetype & DMG_BURN)
	{
		ExtinguishEntity(victim);
	}

	vSetWounds(victim);
}

static void vRemoveEffects(int survivor, bool body = false)
{
	int iEffect = -1;
	for (int iPos = 0; iPos < sizeof(esPlayer::g_iEffect); iPos++)
	{
		iEffect = g_esPlayer[survivor].g_iEffect[iPos];
		if (bIsValidEntRef(iEffect))
		{
			RemoveEntity(iEffect);
		}

		g_esPlayer[survivor].g_iEffect[iPos] = INVALID_ENT_REFERENCE;
	}

	if (body || bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE))
	{
		vRemoveGlow(survivor);
		SetEntityRenderColor(survivor, 255, 255, 255, 255);
	}

	SDKUnhook(survivor, SDKHook_PostThinkPost, OnTankPostThinkPost);
}

static void vRemoveGlow(int player)
{
	if (!g_bSecondGame)
	{
		return;
	}

	SetEntProp(player, Prop_Send, "m_glowColorOverride", 0);
	SetEntProp(player, Prop_Send, "m_bFlashing", 0);
	SetEntProp(player, Prop_Send, "m_iGlowType", 0);
}

static void vRemoveProps(int tank, int mode = 1)
{
	for (int iLight = 0; iLight < sizeof(esPlayer::g_iLight); iLight++)
	{
		if (bIsValidEntRef(g_esPlayer[tank].g_iLight[iLight]))
		{
			g_esPlayer[tank].g_iLight[iLight] = EntRefToEntIndex(g_esPlayer[tank].g_iLight[iLight]);
			if (bIsValidEntity(g_esPlayer[tank].g_iLight[iLight]))
			{
				SDKUnhook(g_esPlayer[tank].g_iLight[iLight], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iLight[iLight]);
			}
		}

		g_esPlayer[tank].g_iLight[iLight] = INVALID_ENT_REFERENCE;
	}

	for (int iOzTank = 0; iOzTank < sizeof(esPlayer::g_iFlame); iOzTank++)
	{
		if (bIsValidEntRef(g_esPlayer[tank].g_iFlame[iOzTank]))
		{
			g_esPlayer[tank].g_iFlame[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iFlame[iOzTank]);
			if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]))
			{
				SDKUnhook(g_esPlayer[tank].g_iFlame[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iFlame[iOzTank]);
			}
		}

		g_esPlayer[tank].g_iFlame[iOzTank] = INVALID_ENT_REFERENCE;

		if (bIsValidEntRef(g_esPlayer[tank].g_iOzTank[iOzTank]))
		{
			g_esPlayer[tank].g_iOzTank[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iOzTank[iOzTank]);
			if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]))
			{
				SDKUnhook(g_esPlayer[tank].g_iOzTank[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iOzTank[iOzTank]);
			}
		}

		g_esPlayer[tank].g_iOzTank[iOzTank] = INVALID_ENT_REFERENCE;
	}

	for (int iRock = 0; iRock < sizeof(esPlayer::g_iRock); iRock++)
	{
		if (bIsValidEntRef(g_esPlayer[tank].g_iRock[iRock]))
		{
			g_esPlayer[tank].g_iRock[iRock] = EntRefToEntIndex(g_esPlayer[tank].g_iRock[iRock]);
			if (bIsValidEntity(g_esPlayer[tank].g_iRock[iRock]))
			{
				SDKUnhook(g_esPlayer[tank].g_iRock[iRock], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iRock[iRock]);
			}
		}

		g_esPlayer[tank].g_iRock[iRock] = INVALID_ENT_REFERENCE;
	}

	for (int iTire = 0; iTire < sizeof(esPlayer::g_iTire); iTire++)
	{
		if (bIsValidEntRef(g_esPlayer[tank].g_iTire[iTire]))
		{
			g_esPlayer[tank].g_iTire[iTire] = EntRefToEntIndex(g_esPlayer[tank].g_iTire[iTire]);
			if (bIsValidEntity(g_esPlayer[tank].g_iTire[iTire]))
			{
				SDKUnhook(g_esPlayer[tank].g_iTire[iTire], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iTire[iTire]);
			}
		}

		g_esPlayer[tank].g_iTire[iTire] = INVALID_ENT_REFERENCE;
	}

	if (bIsValidEntRef(g_esPlayer[tank].g_iPropaneTank))
	{
		g_esPlayer[tank].g_iPropaneTank = EntRefToEntIndex(g_esPlayer[tank].g_iPropaneTank);
		if (bIsValidEntity(g_esPlayer[tank].g_iPropaneTank))
		{
			SDKUnhook(g_esPlayer[tank].g_iPropaneTank, SDKHook_SetTransmit, OnPropSetTransmit);
			RemoveEntity(g_esPlayer[tank].g_iPropaneTank);
		}
	}

	g_esPlayer[tank].g_iPropaneTank = INVALID_ENT_REFERENCE;

	if (bIsValidEntRef(g_esPlayer[tank].g_iFlashlight))
	{
		g_esPlayer[tank].g_iFlashlight = EntRefToEntIndex(g_esPlayer[tank].g_iFlashlight);
		if (bIsValidEntity(g_esPlayer[tank].g_iFlashlight))
		{
			SDKUnhook(g_esPlayer[tank].g_iFlashlight, SDKHook_SetTransmit, OnPropSetTransmit);
			RemoveEntity(g_esPlayer[tank].g_iFlashlight);
		}
	}

	g_esPlayer[tank].g_iFlashlight = INVALID_ENT_REFERENCE;

	vRemoveGlow(tank);

	if (mode == 1)
	{
		SetEntityRenderMode(tank, RENDER_NORMAL);
		SetEntityRenderColor(tank, 255, 255, 255, 255);
	}
}

static void vReset()
{
	g_esGeneral.g_iPlayerCount[1] = iGetHumanCount();
	g_esGeneral.g_iPlayerCount[2] = iGetHumanCount(true);

	vResetRound();
	vClearAbilityList();
	vClearPluginList();
}

static void vReset2(int tank, int mode = 1)
{
	vRemoveProps(tank, mode);
	vResetSpeed(tank);
	vSpawnModes(tank, false);
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bArtificial = false;
	g_esPlayer[tank].g_bAttackedAgain = false;
	g_esPlayer[tank].g_bBlood = false;
	g_esPlayer[tank].g_bBlur = false;
	g_esPlayer[tank].g_bElectric = false;
	g_esPlayer[tank].g_bFire = false;
	g_esPlayer[tank].g_bFirstSpawn = false;
	g_esPlayer[tank].g_bIce = false;
	g_esPlayer[tank].g_bKeepCurrentType = false;
	g_esPlayer[tank].g_bMeteor = false;
	g_esPlayer[tank].g_bNeedHealth = false;
	g_esPlayer[tank].g_bReplaceSelf = false;
	g_esPlayer[tank].g_bSmoke = false;
	g_esPlayer[tank].g_bSpit = false;
	g_esPlayer[tank].g_bTriggered = false;
	g_esPlayer[tank].g_bVomited = false;
	g_esPlayer[tank].g_flAttackDelay = -1.0;
	g_esPlayer[tank].g_iBossStageCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iOldTankType = 0;
	g_esPlayer[tank].g_iTankType = 0;

	vResetSurvivorStats(tank);
}

static void vResetCore(int client)
{
	g_esPlayer[client].g_bAdminMenu = false;
	g_esPlayer[client].g_bAttacked = false;
	g_esPlayer[client].g_bDied = false;
	g_esPlayer[client].g_bIgnoreCmd = false;
	g_esPlayer[client].g_bLastLife = false;
	g_esPlayer[client].g_bStasis = false;
	g_esPlayer[client].g_bThirdPerson = false;
	g_esPlayer[client].g_bThirdPerson2 = false;
	g_esPlayer[client].g_iLastButtons = 0;
	g_esPlayer[client].g_iMaxClip[0] = 0;
	g_esPlayer[client].g_iMaxClip[1] = 0;
	g_esPlayer[client].g_iReviveCount = 0;

	vResetDamage(client);
}

static void vResetDamage(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		g_esPlayer[iSurvivor].g_iTankDamage[tank] = 0;
	}
}

static void vResetRound()
{
	g_esGeneral.g_bFinaleEnded = false;
	g_esGeneral.g_bForceSpawned = false;
	g_esGeneral.g_bUsedParser = false;
	g_esGeneral.g_iChosenType = 0;
	g_esGeneral.g_iParserViewer = 0;
	g_esGeneral.g_iRegularCount = 0;
	g_esGeneral.g_iSurvivalBlock = 0;
	g_esGeneral.g_iTankCount = 0;
	g_esGeneral.g_iTankWave = 0;

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vReset2(iPlayer);
			vReset3(iPlayer);
			vResetCore(iPlayer);
			vRemoveEffects(iPlayer);
			vCacheSettings(iPlayer);
		}
	}

	vKillRegularWavesTimer();
	vKillSurvivalTimer();
	vKillTankWaveTimer();
}

static void vResetSpeed(int tank, bool mode = true)
{
	if (bIsValidClient(tank))
	{
		switch (mode)
		{
			case true: SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", 1.0);
			case false:
			{
				if (g_esCache[tank].g_flRunSpeed > 0.0)
				{
					SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", g_esCache[tank].g_flRunSpeed);
				}
			}
		}
	}
}

static void vResetSurvivorStats(int survivor)
{
	g_esDeveloper[survivor].g_bDevVisual = false;
	g_esPlayer[survivor].g_bFallDamage = false;
	g_esPlayer[survivor].g_bFalling = false;
	g_esPlayer[survivor].g_bFallTracked = false;
	g_esPlayer[survivor].g_bFatalFalling = false;
	g_esPlayer[survivor].g_bSetup = false;
	g_esPlayer[survivor].g_bVomited = false;
	g_esPlayer[survivor].g_sLoopingVoiceline[0] = '\0';
	g_esPlayer[survivor].g_flActionDuration = 0.0;
	g_esPlayer[survivor].g_flAttackBoost = 0.0;
	g_esPlayer[survivor].g_flDamageBoost = 0.0;
	g_esPlayer[survivor].g_flDamageResistance = 0.0;
	g_esPlayer[survivor].g_flHealPercent = 0.0;
	g_esPlayer[survivor].g_flJumpHeight = 0.0;
	g_esPlayer[survivor].g_flPreFallZ = 0.0;
	g_esPlayer[survivor].g_flShoveDamage = 0.0;
	g_esPlayer[survivor].g_flShoveRate = 0.0;
	g_esPlayer[survivor].g_flSpeedBoost = 0.0;
	g_esPlayer[survivor].g_iAmmoBoost = 0;
	g_esPlayer[survivor].g_iAmmoRegen = 0;
	g_esPlayer[survivor].g_iCleanKills = 0;
	g_esPlayer[survivor].g_iFallPasses = 0;
	g_esPlayer[survivor].g_iHealthRegen = 0;
	g_esPlayer[survivor].g_iHollowpointAmmo = 0;
	g_esPlayer[survivor].g_iInfiniteAmmo = 0;
	g_esPlayer[survivor].g_iLifeLeech = 0;
	g_esPlayer[survivor].g_iMeleeRange = 0;
	g_esPlayer[survivor].g_iNotify = 0;
	g_esPlayer[survivor].g_iPrefsAccess = 0;
	g_esPlayer[survivor].g_iParticleEffect = 0;
	g_esPlayer[survivor].g_iReviveHealth = 0;
	g_esPlayer[survivor].g_iRewardTypes = 0;
	g_esPlayer[survivor].g_iShovePenalty = 0;
	g_esPlayer[survivor].g_iSledgehammerRounds = 0;
	g_esPlayer[survivor].g_iSpecialAmmo = 0;
	g_esPlayer[survivor].g_iThorns = 0;

	for (int iPos = 0; iPos < sizeof(esPlayer::g_flRewardTime); iPos++)
	{
		g_esPlayer[survivor].g_flRewardTime[iPos] = -1.0;
		g_esPlayer[survivor].g_iRewardStack[iPos] = 0;

		if (iPos < sizeof(esPlayer::g_flVisualTime))
		{
			g_esPlayer[survivor].g_flVisualTime[iPos] = -1.0;
		}

		if (iPos < sizeof(esPlayer::g_iScreenColorVisual))
		{
			g_esPlayer[survivor].g_iScreenColorVisual[iPos] = -1;
		}
	}
}

static void vResetSurvivorStats2(int survivor)
{
	if (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_REFILL)
	{
		g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_REFILL;
	}

	if (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ITEM)
	{
		g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_ITEM;
	}

	if (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_RESPAWN)
	{
		g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_RESPAWN;
	}
}

static void vResetTank(int tank)
{
	ExtinguishEntity(tank);
	EmitSoundToAll(SOUND_ELECTRICITY, tank);
	vAttachParticle(tank, PARTICLE_ELECTRICITY, 2.0, 30.0);
	vResetSpeed(tank);
	vRemoveGlow(tank);
}

static void vKillRegularWavesTimer()
{
	if (g_esGeneral.g_hRegularWavesTimer != null)
	{
		KillTimer(g_esGeneral.g_hRegularWavesTimer);
		g_esGeneral.g_hRegularWavesTimer = null;
	}
}

static void vKillSurvivalTimer()
{
	if (g_esGeneral.g_hSurvivalTimer != null)
	{
		KillTimer(g_esGeneral.g_hSurvivalTimer);
		g_esGeneral.g_hSurvivalTimer = null;
	}
}

static void vKillTankWaveTimer()
{
	if (g_esGeneral.g_hTankWaveTimer != null)
	{
		KillTimer(g_esGeneral.g_hTankWaveTimer);
		g_esGeneral.g_hTankWaveTimer = null;
	}
}

static void vResetTimers(bool delay = false)
{
	switch (delay)
	{
		case true: CreateTimer(g_esGeneral.g_flRegularDelay, tTimerDelayRegularWaves, _, TIMER_FLAG_NO_MAPCHANGE);
		case false:
		{
			bool bStart = SDKCall(g_esGeneral.g_hSDKHasAnySurvivorLeftSafeArea, g_esGeneral.g_adDirector);
			if (g_esGeneral.g_hSDKHasAnySurvivorLeftSafeArea != null && g_esGeneral.g_adDirector != Address_Null && bStart)
			{
				vKillRegularWavesTimer();
				g_esGeneral.g_hRegularWavesTimer = CreateTimer(g_esGeneral.g_flRegularInterval, tTimerRegularWaves, _, TIMER_REPEAT);
			}
		}
	}

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTankSupported(iTank))
		{
			vResetTimersForward(1, iTank);
		}
	}

	vResetTimersForward();
}

static void vResetTimersForward(int mode = 0, int tank = 0)
{
	Call_StartForward(g_esGeneral.g_gfResetTimersForward);
	Call_PushCell(mode);
	Call_PushCell(tank);
	Call_Finish();
}

static void vReviveSurvivor(int survivor)
{
#if defined _l4dh_included
	switch (g_esGeneral.g_bLeft4DHooksInstalled || g_esGeneral.g_hSDKRevive == null)
	{
		case true: L4D_ReviveSurvivor(survivor);
		case false: SDKCall(g_esGeneral.g_hSDKRevive, survivor);
	}
#else
	if (g_esGeneral.g_hSDKRevive != null)
	{
		SDKCall(g_esGeneral.g_hSDKRevive, survivor);
	}
#endif
}

static void vUnvomitPlayer(int player)
{
#if defined _l4dh_included
	switch (g_esGeneral.g_bLeft4DHooksInstalled || g_esGeneral.g_hSDKITExpired == null)
	{
		case true: L4D_OnITExpired(player);
		case false: SDKCall(g_esGeneral.g_hSDKITExpired, player);
	}
#else
	if (g_esGeneral.g_hSDKITExpired != null)
	{
		SDKCall(g_esGeneral.g_hSDKITExpired, player);
	}
#endif
}

static void vCalculateDeath(int tank, int survivor)
{
	if (g_esPlayer[tank].g_iTankType <= 0 || !bIsCustomTank(tank))
	{
		int iAssistant = bIsSurvivor(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME) ? survivor : 0;
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME) && GetClientTeam(iPlayer) != 3 && g_esPlayer[iPlayer].g_iTankDamage[tank] > g_esPlayer[iAssistant].g_iTankDamage[tank])
			{
				iAssistant = iPlayer;
			}
		}

		float flPercentage = (float(g_esPlayer[survivor].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100,
			flAssistPercentage = (float(g_esPlayer[iAssistant].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;

		switch (flAssistPercentage < 90.0)
		{
			case true: vAnnounceDeath(tank, survivor, flPercentage, iAssistant, flAssistPercentage);
			case false: vAnnounceDeath(tank, 0, 0.0, 0, 0.0, false);
		}

		vRewardPriority(survivor, iAssistant, tank, g_esCache[tank].g_iRewardPriority[0]);
		vRewardPriority(survivor, iAssistant, tank, g_esCache[tank].g_iRewardPriority[1]);
		vRewardPriority(survivor, iAssistant, tank, g_esCache[tank].g_iRewardPriority[2]);
		vRewardPriority(survivor, iAssistant, tank, g_esCache[tank].g_iRewardPriority[3]);
		vResetDamage(tank);
		vResetSurvivorStats2(survivor);
		vResetSurvivorStats2(iAssistant);
	}
	else if (g_esCache[tank].g_iAnnounceDeath > 0)
	{
		vAnnounceDeath(tank, 0, 0.0, 0, 0.0);
	}
}

static void vChooseReward(int survivor, int tank, int priority, int setting)
{
	int iType = (setting > 0) ? setting : (1 << GetRandomInt(0, 7));
	if (bIsDeveloper(survivor, 3))
	{
		iType = g_esDeveloper[survivor].g_iDevRewardTypes;
	}

	iType |= iGetUsefulRewards(survivor, tank, iType, priority);
	vRewardSurvivor(survivor, iType, tank, true, priority);
}

static void vListRewards(int survivor, int count, const char[][] buffers, int maxStrings, char[] buffer, int size)
{
	bool bListed = false;
	for (int iPos = 0; iPos < maxStrings; iPos++)
	{
		if (buffers[iPos][0] != '\0')
		{
			switch (bListed)
			{
				case true:
				{
					switch (iPos < maxStrings - 1 && buffers[iPos + 1][0] != '\0')
					{
						case true: Format(buffer, size, "%s{default}, {yellow}%s", buffer, buffers[iPos]);
						case false:
						{
							switch (count)
							{
								case 2: Format(buffer, size, "%s{default} %T{yellow} %s", buffer, "AndConjunction", survivor, buffers[iPos]);
								default: Format(buffer, size, "%s{default}, %T{yellow} %s", buffer, "AndConjunction", survivor, buffers[iPos]);
							}
						}
					}
				}
				case false:
				{
					bListed = true;

					FormatEx(buffer, size, "%s", buffers[iPos]);
				}
			}
		}
	}
}

static void vRewardPriority(int survivor, int assistant, int tank, int priority)
{
	char sTankName[33];
	vGetTranslatedName(sTankName, sizeof(sTankName), tank);
	float flPercentage = 0.0, flRandom = GetRandomFloat(0.1, 100.0);
	int iSetting = 0;

	switch (priority)
	{
		case 0: return;
		case 1:
		{
			if (survivor == assistant)
			{
				return;
			}

			iSetting = bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esCache[tank].g_iRewardEnabled[0] : g_esCache[tank].g_iRewardBots[0];
			if (bIsSurvivor(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME) && iSetting != -1 && flRandom <= g_esCache[tank].g_flRewardChance[0])
			{
				flPercentage = (float(g_esPlayer[survivor].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;
				if (flPercentage >= g_esCache[tank].g_flRewardPercentage[0])
				{
					if (flPercentage >= 90.0)
					{
						vRewardNotify(survivor, tank, 0, "RewardSolo", sTankName);
					}

					vChooseReward(survivor, tank, 0, iSetting);
				}
				else
				{
					vRewardNotify(survivor, tank, 0, "RewardNone", sTankName);
				}
			}
		}
		case 2:
		{
			if (survivor == assistant)
			{
				return;
			}

			iSetting = bIsValidClient(assistant, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esCache[tank].g_iRewardEnabled[1] : g_esCache[tank].g_iRewardBots[1];
			if (bIsSurvivor(assistant, MT_CHECK_INDEX|MT_CHECK_INGAME) && iSetting != -1 && flRandom <= g_esCache[tank].g_flRewardChance[1])
			{
				flPercentage = (float(g_esPlayer[assistant].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;
				if (flPercentage >= g_esCache[tank].g_flRewardPercentage[1])
				{
					if (flPercentage >= 90.0)
					{
						vRewardNotify(assistant, tank, 1, "RewardSolo", sTankName);
					}

					vChooseReward(assistant, tank, 1, iSetting);
				}
				else
				{
					vRewardNotify(assistant, tank, 1, "RewardNone", sTankName);
				}
			}
		}
		case 3:
		{
			if (flRandom <= g_esCache[tank].g_flRewardChance[2])
			{
				float[] flPercentages = new float[MaxClients + 1];
				int[] iSurvivors = new int[MaxClients + 1];
				int iSurvivorCount = 0;
				for (int iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
				{
					iSetting = bIsValidClient(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esCache[tank].g_iRewardEnabled[2] : g_esCache[tank].g_iRewardBots[2];
					if (bIsSurvivor(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esPlayer[iTeammate].g_iTankDamage[tank] > 0 && iSetting != -1 && iTeammate != survivor && iTeammate != assistant)
					{
						flPercentages[iSurvivorCount] = (float(g_esPlayer[iTeammate].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;
						iSurvivors[iSurvivorCount] = iTeammate;
						iSurvivorCount++;
					}
				}

				if (iSurvivorCount > 0)
				{
					SortFloats(flPercentages, MaxClients + 1, Sort_Descending);
				}

				int iTeammate = 0, iTeammateCount = 0;
				for (int iPos = 0; iPos < iSurvivorCount; iPos++)
				{
					iTeammate = iSurvivors[iPos];
					flPercentage = flPercentages[iPos];
					if (bIsSurvivor(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME))
					{
						if (0 < g_esCache[tank].g_iTeammateLimit <= iTeammateCount)
						{
							vRewardNotify(iTeammate, tank, 2, "RewardNone", sTankName);

							continue;
						}

						if (flPercentage >= g_esCache[tank].g_flRewardPercentage[2])
						{
							if (flPercentage >= 90.0)
							{
								vRewardNotify(iTeammate, tank, 2, "RewardSolo", sTankName);
							}

							iSetting = bIsValidClient(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esCache[tank].g_iRewardEnabled[2] : g_esCache[tank].g_iRewardBots[2];
							vChooseReward(iTeammate, tank, 2, iSetting);
							vResetSurvivorStats2(iTeammate);
						}
						else
						{
							vRewardNotify(iTeammate, tank, 2, "RewardNone", sTankName);
						}

						iTeammateCount++;
					}
				}
			}
		}
		case 4:
		{
			if (survivor != assistant)
			{
				return;
			}

			iSetting = bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esCache[tank].g_iRewardEnabled[3] : g_esCache[tank].g_iRewardBots[3];
			if (bIsSurvivor(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME) && iSetting != -1 && flRandom <= g_esCache[tank].g_flRewardChance[3])
			{
				flPercentage = (float(g_esPlayer[survivor].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;
				if (flPercentage >= g_esCache[tank].g_flRewardPercentage[3])
				{
					if (flPercentage >= 90.0)
					{
						vRewardNotify(survivor, tank, 3, "RewardSolo", sTankName);
					}

					vChooseReward(survivor, tank, 3, iSetting);
				}
				else
				{
					vRewardNotify(survivor, tank, 3, "RewardNone", sTankName);
				}
			}
		}
	}
}

static void vRewardSurvivor(int survivor, int type, int tank = 0, bool apply = false, int priority = 0)
{
	Action aResult = Plugin_Continue;
	bool bDeveloper = bIsDeveloper(survivor, 3);
	float flTime = (bDeveloper && g_esDeveloper[survivor].g_flDevRewardDuration > g_esCache[tank].g_flRewardDuration[priority]) ? g_esDeveloper[survivor].g_flDevRewardDuration : g_esCache[tank].g_flRewardDuration[priority];
	int iType = type;

	Call_StartForward(g_esGeneral.g_gfRewardSurvivorForward);
	Call_PushCell(survivor);
	Call_PushCell(tank);
	Call_PushCellRef(iType);
	Call_PushCell(priority);
	Call_PushFloatRef(flTime);
	Call_PushCell(apply);
	Call_Finish(aResult);

	if (aResult == Plugin_Handled)
	{
		return;
	}

	switch (apply)
	{
		case true:
		{
			char sSet[9][64], sTankName[33];
			int iRewardCount = 0;
			vGetTranslatedName(sTankName, sizeof(sTankName), tank);
			g_esPlayer[survivor].g_iNotify = g_esCache[tank].g_iRewardNotify[priority];
			g_esPlayer[survivor].g_iPrefsAccess = g_esCache[tank].g_iPrefsNotify[priority];
			if ((iType & MT_REWARD_RESPAWN) && bRespawnSurvivor(survivor, (bDeveloper || g_esCache[tank].g_iRespawnLoadoutReward[priority] == 1)) && !(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_RESPAWN))
			{
				FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardRespawn", survivor);
				g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_RESPAWN;
				iRewardCount++;
			}

			if (bIsSurvivor(survivor))
			{
				char sReceived[1024];
				float flCurrentTime = GetGameTime(), flDuration = flCurrentTime + flTime;
				if (iType & MT_REWARD_HEALTH)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH))
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardHealth", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_HEALTH);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_HEALTH;
						iRewardCount++;

						vSaveCaughtSurvivor(survivor);
						vRefillHealth(survivor);
					}
					else
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardHealth", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_HEALTH);

						iRewardCount++;

						vSaveCaughtSurvivor(survivor);
						vRefillHealth(survivor);
					}

					if (g_esPlayer[survivor].g_flRewardTime[0] == -1.0 || (flTime > (g_esPlayer[survivor].g_flRewardTime[0] - flCurrentTime)))
					{
						g_esPlayer[survivor].g_flRewardTime[0] = flDuration;
					}
				}

				if (iType & MT_REWARD_SPEEDBOOST)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
					{
						SDKHook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardSpeedBoost", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_SPEEDBOOST);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_SPEEDBOOST;
						iRewardCount++;

						if (!bIsDeveloper(survivor, 5) || flGetAdrenalineTime(survivor) > 0.0)
						{
							vSetAdrenalineTime(survivor, flDuration);
						}

						switch (priority)
						{
							case 0: strcopy(g_esPlayer[survivor].g_sFallVoiceline, sizeof(esPlayer::g_sFallVoiceline), g_esCache[tank].g_sFallVoicelineReward);
							case 1: strcopy(g_esPlayer[survivor].g_sFallVoiceline, sizeof(esPlayer::g_sFallVoiceline), g_esCache[tank].g_sFallVoicelineReward2);
							case 2: strcopy(g_esPlayer[survivor].g_sFallVoiceline, sizeof(esPlayer::g_sFallVoiceline), g_esCache[tank].g_sFallVoicelineReward3);
							case 3: strcopy(g_esPlayer[survivor].g_sFallVoiceline, sizeof(esPlayer::g_sFallVoiceline), g_esCache[tank].g_sFallVoicelineReward4);
						}
					}
					else
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardSpeedBoost", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_SPEEDBOOST);

						iRewardCount++;
					}

					if (g_esPlayer[survivor].g_flRewardTime[1] == -1.0 || (flTime > (g_esPlayer[survivor].g_flRewardTime[1] - flCurrentTime)))
					{
						g_esPlayer[survivor].g_flRewardTime[1] = flDuration;
					}
				}

				if (iType & MT_REWARD_DAMAGEBOOST)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardDamageBoost", survivor);
						vRewardLadyKillerMessage(survivor, tank, priority, sReceived, sizeof(sReceived));
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_DAMAGEBOOST);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_DAMAGEBOOST;
						iRewardCount++;
					}
					else
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardDamageBoost", survivor);
						vRewardLadyKillerMessage(survivor, tank, priority, sReceived, sizeof(sReceived));
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_DAMAGEBOOST);

						iRewardCount++;
					}

					if (g_esPlayer[survivor].g_flRewardTime[2] == -1.0 || (flTime > (g_esPlayer[survivor].g_flRewardTime[2] - flCurrentTime)))
					{
						g_esPlayer[survivor].g_flRewardTime[2] = flDuration;
					}
				}

				if (iType & MT_REWARD_ATTACKBOOST)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
					{
						SDKHook(survivor, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardAttackBoost", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_ATTACKBOOST);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_ATTACKBOOST;
						iRewardCount++;
					}
					else
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardAttackBoost", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_ATTACKBOOST);

						iRewardCount++;
					}

					if (g_esPlayer[survivor].g_flRewardTime[3] == -1.0 || (flTime > (g_esPlayer[survivor].g_flRewardTime[3] - flCurrentTime)))
					{
						g_esPlayer[survivor].g_flRewardTime[3] = flDuration;
					}
				}

				if (iType & MT_REWARD_AMMO)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_AMMO))
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardAmmo", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_AMMO);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_AMMO;
						iRewardCount++;

						vCheckClipSizes(survivor);
						vRefillAmmo(survivor);
						vGiveSpecialAmmo(survivor);
					}
					else
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardAmmo", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_AMMO);

						iRewardCount++;

						vCheckClipSizes(survivor);
						vRefillAmmo(survivor);
						vGiveSpecialAmmo(survivor);
					}

					if (g_esPlayer[survivor].g_flRewardTime[4] == -1.0 || (flTime > (g_esPlayer[survivor].g_flRewardTime[4] - flCurrentTime)))
					{
						g_esPlayer[survivor].g_flRewardTime[4] = flDuration;
					}
				}

				if ((iType & MT_REWARD_ITEM) && !(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ITEM))
				{
					bool bListed = false;
					char sLoadout[320], sItems[5][64], sList[320];
					switch (priority)
					{
						case 0: strcopy(sLoadout, sizeof(sLoadout), g_esCache[tank].g_sItemReward);
						case 1: strcopy(sLoadout, sizeof(sLoadout), g_esCache[tank].g_sItemReward2);
						case 2: strcopy(sLoadout, sizeof(sLoadout), g_esCache[tank].g_sItemReward3);
						case 3: strcopy(sLoadout, sizeof(sLoadout), g_esCache[tank].g_sItemReward4);
					}

					if (StrContains(sLoadout, ";") != -1)
					{
						ExplodeString(sLoadout, ";", sItems, sizeof(sItems), sizeof(sItems[]));
						for (int iPos = 0; iPos < sizeof(sItems); iPos++)
						{
							if (sItems[iPos][0] != '\0')
							{
								vCheatCommand(survivor, "give", sItems[iPos]);
								ReplaceString(sItems[iPos], sizeof(sItems[]), "_", " ");

								switch (bListed)
								{
									case true:
									{
										switch (iPos < sizeof(sItems) - 1 && sItems[iPos + 1][0] != '\0')
										{
											case true: Format(sList, sizeof(sList), "%s{default}, {yellow}%s", sList, sItems[iPos]);
											case false: Format(sList, sizeof(sList), "%s{default}, %T{yellow} %s", sList, "AndConjunction", survivor, sItems[iPos]);
										}
									}
									case false:
									{
										bListed = true;

										FormatEx(sList, sizeof(sList), "%s", sItems[iPos]);
									}
								}
							}
						}

						vRewardItemMessage(survivor, sList, sReceived, sizeof(sReceived), true);
					}
					else
					{
						vCheatCommand(survivor, "give", sLoadout);
						ReplaceString(sLoadout, sizeof(sLoadout), "_", " ");
						vRewardItemMessage(survivor, sLoadout, sReceived, sizeof(sReceived), false);
					}

					g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_ITEM;
				}

				if (sReceived[0] != '\0')
				{
					MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardReceived", sReceived);
				}

				if (iType & MT_REWARD_GODMODE)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_GODMODE))
					{
						SetEntProp(survivor, Prop_Data, "m_takedamage", 0, 1);
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardGod", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_GODMODE);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_GODMODE;
						iRewardCount++;

						if (g_esPlayer[survivor].g_bVomited)
						{
							vUnvomitPlayer(survivor);
						}
					}
					else
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardGod", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_GODMODE);

						iRewardCount++;
					}

					if (g_esPlayer[survivor].g_flRewardTime[5] == -1.0 || (flTime > (g_esPlayer[survivor].g_flRewardTime[5] - flCurrentTime)))
					{
						g_esPlayer[survivor].g_flRewardTime[5] = flDuration;
					}
				}

				if ((iType & MT_REWARD_REFILL) && !(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_REFILL))
				{
					FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardRefill", survivor);

					g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_REFILL;
					iRewardCount++;

					vSaveCaughtSurvivor(survivor);
					vCheckClipSizes(survivor);
					vRefillAmmo(survivor, _, !(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_AMMO));
					vRefillHealth(survivor);
				}

				if (iType & MT_REWARD_INFAMMO)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_INFAMMO))
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardInfAmmo", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_INFAMMO);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_INFAMMO;
						iRewardCount++;
					}
					else
					{
						FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardInfAmmo", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_INFAMMO);

						iRewardCount++;
					}

					if (g_esPlayer[survivor].g_flRewardTime[6] == -1.0 || (flTime > (g_esPlayer[survivor].g_flRewardTime[6] - flCurrentTime)))
					{
						g_esPlayer[survivor].g_flRewardTime[6] = flDuration;
					}
				}

				char sRewards[1024];
				vListRewards(survivor, iRewardCount, sSet, sizeof(sSet), sRewards, sizeof(sRewards));
				vRewardMessage(survivor, iRewardCount, priority, sRewards, sTankName);

				int iVisual = g_esCache[tank].g_iRewardVisual[priority];
				if (iVisual > 0)
				{
#if defined _clientprefs_included
					switch (g_esPlayer[survivor].g_iPrefsAccess)
					{
						case 0: vDefaultCookieSettings(survivor);
						case 1:
						{
							if (AreClientCookiesCached(survivor))
							{
								OnClientCookiesCached(survivor);
							}
						}
					}
#else
					vDefaultCookieSettings(survivor);
#endif
					bool bIgnore = bIsDeveloper(survivor, 0);
					if (bDeveloper || (iVisual & MT_VISUAL_SCREEN))
					{
						if (g_esPlayer[survivor].g_flVisualTime[0] == -1.0 || (flTime > (g_esPlayer[survivor].g_flVisualTime[0] - flCurrentTime)))
						{
							char sColor[48], sValue[4][4];

							switch (priority)
							{
								case 0: strcopy(sColor, sizeof(sColor), g_esCache[tank].g_sScreenColorVisual);
								case 1: strcopy(sColor, sizeof(sColor), g_esCache[tank].g_sScreenColorVisual2);
								case 2: strcopy(sColor, sizeof(sColor), g_esCache[tank].g_sScreenColorVisual3);
								case 3: strcopy(sColor, sizeof(sColor), g_esCache[tank].g_sScreenColorVisual4);
							}

							ExplodeString(sColor, ";", sValue, sizeof(sValue), sizeof(sValue[]));
							for (int iPos = 0; iPos < sizeof(sValue); iPos++)
							{
								if (sValue[iPos][0] != '\0')
								{
									g_esPlayer[survivor].g_iScreenColorVisual[iPos] = iGetRandomColor(StringToInt(sValue[iPos]));
								}
							}

							if (g_esPlayer[survivor].g_flVisualTime[0] == -1.0)
							{
								CreateTimer(2.0, tTimerScreenEffect, GetClientUserId(survivor), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
							}

							if (flTime > (g_esPlayer[survivor].g_flVisualTime[0] - flCurrentTime))
							{
								g_esPlayer[survivor].g_flVisualTime[0] = flDuration;
							}
						}
					}

					if (g_bSecondGame && (bDeveloper || (iVisual & MT_VISUAL_GLOW)))
					{
						if (g_esPlayer[survivor].g_flVisualTime[1] == -1.0 || (flTime > (g_esPlayer[survivor].g_flVisualTime[1] - flCurrentTime)))
						{
							switch (priority)
							{
								case 0: strcopy(g_esPlayer[survivor].g_sGlowColor, sizeof(esPlayer::g_sGlowColor), g_esCache[tank].g_sGlowColorVisual);
								case 1: strcopy(g_esPlayer[survivor].g_sGlowColor, sizeof(esPlayer::g_sGlowColor), g_esCache[tank].g_sGlowColorVisual2);
								case 2: strcopy(g_esPlayer[survivor].g_sGlowColor, sizeof(esPlayer::g_sGlowColor), g_esCache[tank].g_sGlowColorVisual3);
								case 3: strcopy(g_esPlayer[survivor].g_sGlowColor, sizeof(esPlayer::g_sGlowColor), g_esCache[tank].g_sGlowColorVisual4);
							}

							if (!bIgnore)
							{
								vSetSurvivorOutline(survivor, g_esPlayer[survivor].g_sGlowColor, g_esPlayer[survivor].g_bApplyVisuals[1], _, true);
							}

							if (flTime > (g_esPlayer[survivor].g_flVisualTime[1] - flCurrentTime))
							{
								g_esPlayer[survivor].g_flVisualTime[1] = flDuration;
							}
						}
					}

					if (bDeveloper || (iVisual & MT_VISUAL_BODY))
					{
						if (g_esPlayer[survivor].g_flVisualTime[2] == -1.0 || (flTime > (g_esPlayer[survivor].g_flVisualTime[2] - flCurrentTime)))
						{
							switch (priority)
							{
								case 0: strcopy(g_esPlayer[survivor].g_sBodyColor, sizeof(esPlayer::g_sBodyColor), g_esCache[tank].g_sBodyColorVisual);
								case 1: strcopy(g_esPlayer[survivor].g_sBodyColor, sizeof(esPlayer::g_sBodyColor), g_esCache[tank].g_sBodyColorVisual2);
								case 2: strcopy(g_esPlayer[survivor].g_sBodyColor, sizeof(esPlayer::g_sBodyColor), g_esCache[tank].g_sBodyColorVisual3);
								case 3: strcopy(g_esPlayer[survivor].g_sBodyColor, sizeof(esPlayer::g_sBodyColor), g_esCache[tank].g_sBodyColorVisual4);
							}

							if (!bIgnore)
							{
								vSetSurvivorColor(survivor, g_esPlayer[survivor].g_sBodyColor, g_esPlayer[survivor].g_bApplyVisuals[2], _, true);
							}

							if (flTime > (g_esPlayer[survivor].g_flVisualTime[2] - flCurrentTime))
							{
								g_esPlayer[survivor].g_flVisualTime[2] = flDuration;
							}
						}
					}

					if (bDeveloper || (iVisual & MT_VISUAL_PARTICLE))
					{
						if (g_esPlayer[survivor].g_flVisualTime[3] == -1.0 || (flTime > (g_esPlayer[survivor].g_flVisualTime[3] - flCurrentTime)))
						{
							int iEffect = g_esCache[tank].g_iParticleEffectVisual[priority];
							if (iEffect > 0 && g_esPlayer[survivor].g_iParticleEffect != iEffect)
							{
								g_esPlayer[survivor].g_iParticleEffect = iEffect;
							}

							if (g_esPlayer[survivor].g_flVisualTime[3] == -1.0)
							{
								CreateTimer(0.75, tTimerParticleVisual, GetClientUserId(survivor), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
							}

							if (flTime > (g_esPlayer[survivor].g_flVisualTime[3] - flCurrentTime))
							{
								g_esPlayer[survivor].g_flVisualTime[3] = flDuration;
							}
						}
					}

					if (bDeveloper || (iVisual & MT_VISUAL_VOICELINE))
					{
						if (g_esPlayer[survivor].g_flVisualTime[4] == -1.0 || (flTime > (g_esPlayer[survivor].g_flVisualTime[4] - flCurrentTime)))
						{
							switch (priority)
							{
								case 0: strcopy(g_esPlayer[survivor].g_sLoopingVoiceline, sizeof(esPlayer::g_sLoopingVoiceline), g_esCache[tank].g_sLoopingVoicelineVisual);
								case 1: strcopy(g_esPlayer[survivor].g_sLoopingVoiceline, sizeof(esPlayer::g_sLoopingVoiceline), g_esCache[tank].g_sLoopingVoicelineVisual2);
								case 2: strcopy(g_esPlayer[survivor].g_sLoopingVoiceline, sizeof(esPlayer::g_sLoopingVoiceline), g_esCache[tank].g_sLoopingVoicelineVisual3);
								case 3: strcopy(g_esPlayer[survivor].g_sLoopingVoiceline, sizeof(esPlayer::g_sLoopingVoiceline), g_esCache[tank].g_sLoopingVoicelineVisual4);
							}

							if (g_esPlayer[survivor].g_flVisualTime[4] == -1.0)
							{
								CreateTimer(3.0, tTimerLoopVoiceline, GetClientUserId(survivor), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
							}

							if (flTime > (g_esPlayer[survivor].g_flVisualTime[4] - flCurrentTime))
							{
								g_esPlayer[survivor].g_flVisualTime[4] = flDuration;
							}
						}
					}

					if (g_esPlayer[survivor].g_iPrefsAccess == 1)
					{
						MT_PrintToChat(survivor, "%s %t", MT_TAG2, "MTPrefsInfo");
					}
				}

				int iEffect = g_esCache[tank].g_iRewardEffect[priority];
				if (iEffect > 0)
				{
					if ((bDeveloper || (iEffect & MT_EFFECT_TROPHY)) && g_esPlayer[survivor].g_iEffect[0] == INVALID_ENT_REFERENCE)
					{
						g_esPlayer[survivor].g_iEffect[0] = EntIndexToEntRef(iCreateParticle(survivor, PARTICLE_ACHIEVED, view_as<float>({0.0, 0.0, 50.0}), NULL_VECTOR, 1.5, 1.5));
					}

					if ((bDeveloper || (iEffect & MT_EFFECT_FIREWORKS)) && g_esPlayer[survivor].g_iEffect[1] == INVALID_ENT_REFERENCE)
					{
						g_esPlayer[survivor].g_iEffect[1] = EntIndexToEntRef(iCreateParticle(survivor, PARTICLE_FIREWORK, view_as<float>({0.0, 0.0, 50.0}), NULL_VECTOR, 2.0, 1.5));
					}

					if (bDeveloper || (iEffect & MT_EFFECT_SOUND))
					{
						EmitSoundToAll(SOUND_ACHIEVEMENT, survivor, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
					}

					if ((bDeveloper || (iEffect & MT_EFFECT_THIRDPERSON)) && bIsSurvivor(survivor, MT_CHECK_FAKECLIENT))
					{
						vExternalView(survivor, 1.5);
					}
				}
			}
		}
		case false:
		{
			char sSet[8][64];
			int iRewardCount = 0;
			if ((iType & MT_REWARD_HEALTH) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH))
			{
				FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardHealth", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_HEALTH;
				g_esPlayer[survivor].g_flRewardTime[0] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[0] = 0;
				g_esPlayer[survivor].g_flHealPercent = 0.0;
				g_esPlayer[survivor].g_iHealthRegen = 0;
				g_esPlayer[survivor].g_iLifeLeech = 0;
				g_esPlayer[survivor].g_iReviveHealth = 0;
				iRewardCount++;
			}

			if ((iType & MT_REWARD_SPEEDBOOST) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
			{
				FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardSpeedBoost", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_SPEEDBOOST;
				g_esPlayer[survivor].g_flRewardTime[1] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[1] = 0;
				g_esPlayer[survivor].g_flJumpHeight = 0.0;
				g_esPlayer[survivor].g_flSpeedBoost = 0.0;
				g_esPlayer[survivor].g_iFallPasses = MT_JUMP_FALLPASSES;
				iRewardCount++;

				if (bIsSurvivor(survivor, MT_CHECK_ALIVE) && !bIsDeveloper(survivor, 5))
				{
					if (flGetAdrenalineTime(survivor) > 0.0)
					{
						vSetAdrenalineTime(survivor, 0.0);
					}

					SDKUnhook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
					SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
				}
			}

			if ((iType & MT_REWARD_DAMAGEBOOST) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
			{
				FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardDamageBoost", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_DAMAGEBOOST;
				g_esPlayer[survivor].g_flRewardTime[2] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[2] = 0;
				g_esPlayer[survivor].g_flDamageBoost = 0.0;
				g_esPlayer[survivor].g_flDamageResistance = 0.0;
				g_esPlayer[survivor].g_iHollowpointAmmo = 0;
				g_esPlayer[survivor].g_iMeleeRange = 0;
				g_esPlayer[survivor].g_iSledgehammerRounds = 0;
				g_esPlayer[survivor].g_iThorns = 0;
				iRewardCount++;
			}

			if ((iType & MT_REWARD_ATTACKBOOST) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
			{
				FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardAttackBoost", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_ATTACKBOOST;
				g_esPlayer[survivor].g_flRewardTime[3] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[3] = 0;
				g_esPlayer[survivor].g_flActionDuration = 0.0;
				g_esPlayer[survivor].g_flAttackBoost = 0.0;
				g_esPlayer[survivor].g_flShoveDamage = 0.0;
				g_esPlayer[survivor].g_flShoveRate = 0.0;
				g_esPlayer[survivor].g_iShovePenalty = 0;
				iRewardCount++;
			}

			if ((iType & MT_REWARD_AMMO) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_AMMO))
			{
				FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardAmmo", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_AMMO;
				g_esPlayer[survivor].g_flRewardTime[4] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[4] = 0;
				g_esPlayer[survivor].g_iAmmoBoost = 0;
				g_esPlayer[survivor].g_iAmmoRegen = 0;
				g_esPlayer[survivor].g_iSpecialAmmo = 0;
				iRewardCount++;

				if (bIsSurvivor(survivor, MT_CHECK_ALIVE))
				{
					vRefillAmmo(survivor, _, true);
				}
			}

			if ((iType & MT_REWARD_GODMODE) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_GODMODE))
			{
				FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardGod", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_GODMODE;
				g_esPlayer[survivor].g_flRewardTime[5] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[5] = 0;
				g_esPlayer[survivor].g_flPunchResistance = 0.0;
				g_esPlayer[survivor].g_iCleanKills = 0;
				iRewardCount++;

				if (bIsSurvivor(survivor, MT_CHECK_ALIVE))
				{
					SetEntProp(survivor, Prop_Data, "m_takedamage", 2, 1);
				}
			}

			if ((iType & MT_REWARD_INFAMMO) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_INFAMMO))
			{
				FormatEx(sSet[iRewardCount], sizeof(sSet[]), "%T", "RewardInfAmmo", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_INFAMMO;
				g_esPlayer[survivor].g_flRewardTime[6] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[6] = 0;
				g_esPlayer[survivor].g_iInfiniteAmmo = 0;
				iRewardCount++;
			}

			char sRewards[1024];
			vListRewards(survivor, iRewardCount, sSet, sizeof(sSet), sRewards, sizeof(sRewards));
			vRewardEndMessage(survivor, iRewardCount, "RewardEnd", sRewards);

			if (g_esPlayer[survivor].g_iRewardTypes <= 0)
			{
				g_esPlayer[survivor].g_iNotify = 0;
				g_esPlayer[survivor].g_iPrefsAccess = 0;
			}
		}
	}
}

static void vRewardEndMessage(int survivor, int count, const char[] phrase, const char[] list)
{
	if (!bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || count == 0 || g_esPlayer[survivor].g_iNotify == 0 || g_esPlayer[survivor].g_iNotify == 1)
	{
		return;
	}

	MT_PrintToChat(survivor, "%s %t", MT_TAG2, phrase, list);
}

static void vRewardItemMessage(int survivor, const char[] list, char[] buffer, int size, bool set)
{
	char sTemp[PLATFORM_MAX_PATH];

	switch (buffer[0] != '\0')
	{
		case true:
		{
			switch (set)
			{
				case true: FormatEx(sTemp, sizeof(sTemp), "{default}, {yellow}%s", list);
				case false: FormatEx(sTemp, sizeof(sTemp), "{default} %T{yellow} %s", "AndConjunction", survivor, list);
			}

			StrCat(buffer, size, sTemp);
		}
		case false: StrCat(buffer, size, list);
	}
}

static void vRewardLadyKillerMessage(int survivor, int tank, int priority, char[] buffer, int size)
{
	if (!bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		return;
	}

	int iLimit = 999999, iReward = g_esCache[tank].g_iLadyKillerReward[priority],
	iUses = g_esPlayer[survivor].g_iLadyKiller - g_esPlayer[survivor].g_iLadyKillerCount,
	iNewUses = iReward + iUses,
	iFinalUses = iClamp(iNewUses, 0, iLimit),
	iReceivedUses = (iNewUses > iLimit) ? (iLimit - iUses) : iReward;
	if ((g_esPlayer[survivor].g_iNotify == 2 || g_esPlayer[survivor].g_iNotify == 3) && iReceivedUses > 0)
	{
		char sTemp[64];
		FormatEx(sTemp, sizeof(sTemp), "%T", "RewardLadyKiller", survivor, iReceivedUses);
		StrCat(buffer, size, sTemp);
	}

	g_esPlayer[survivor].g_iLadyKiller = iFinalUses;
	g_esPlayer[survivor].g_iLadyKillerCount = 0;
}

static void vRewardMessage(int survivor, int count, int priority, const char[] list, const char[] namePhrase)
{
	if (!bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || count == 0 || g_esPlayer[survivor].g_iNotify == 0 || g_esPlayer[survivor].g_iNotify == 1)
	{
		return;
	}

	switch (priority)
	{
		case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardList", list, namePhrase);
		case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardList2", list, namePhrase);
		case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardList3", list, namePhrase);
		case 3: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardList4", list, namePhrase);
	}
}

static void vRewardNotify(int survivor, int tank, int priority, const char[] phrase, const char[] namePhrase)
{
	if (!bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iRewardNotify[priority] == 0 || g_esCache[tank].g_iRewardNotify[priority] == 2)
	{
		return;
	}

	switch (StrEqual(phrase, "RewardNone"))
	{
		case true: MT_PrintToChat(survivor, "%s %t", MT_TAG3, phrase, namePhrase);
		case false:
		{
			MT_PrintToChatAll("%s %t", MT_TAG3, phrase, survivor, namePhrase);
			vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, phrase, LANG_SERVER, survivor, namePhrase);
		}
	}
}

static void vSetupRewardCounts(int survivor, int tank, int priority, int type)
{
	switch (type)
	{
		case MT_REWARD_HEALTH:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flHealPercent = g_esCache[tank].g_flHealPercentReward[priority];
				g_esPlayer[survivor].g_iHealthRegen = g_esCache[tank].g_iHealthRegenReward[priority];
				g_esPlayer[survivor].g_iLifeLeech = g_esCache[tank].g_iLifeLeechReward[priority];
				g_esPlayer[survivor].g_iReviveHealth = g_esCache[tank].g_iReviveHealthReward[priority];
			}
			else if (g_esCache[tank].g_iStackRewards[priority] == 1 && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esPlayer[survivor].g_iRewardStack[0] < MT_STACK_HEALTH)
			{
				g_esPlayer[survivor].g_flHealPercent -= g_esCache[tank].g_flHealPercentReward[priority] / 2.0;
				g_esPlayer[survivor].g_flHealPercent = flClamp(g_esPlayer[survivor].g_flHealPercent, 1.0, 100.0);
				g_esPlayer[survivor].g_iHealthRegen += g_esCache[tank].g_iHealthRegenReward[priority];
				g_esPlayer[survivor].g_iHealthRegen = iClamp(g_esPlayer[survivor].g_iHealthRegen, 0, MT_MAXHEALTH);
				g_esPlayer[survivor].g_iLifeLeech += g_esCache[tank].g_iLifeLeechReward[priority];
				g_esPlayer[survivor].g_iLifeLeech = iClamp(g_esPlayer[survivor].g_iLifeLeech, 0, MT_MAXHEALTH);
				g_esPlayer[survivor].g_iReviveHealth += g_esCache[tank].g_iReviveHealthReward[priority];
				g_esPlayer[survivor].g_iReviveHealth = iClamp(g_esPlayer[survivor].g_iReviveHealth, 0, MT_MAXHEALTH);
				g_esPlayer[survivor].g_iRewardStack[0]++;
			}
		}
		case MT_REWARD_SPEEDBOOST:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flJumpHeight = g_esCache[tank].g_flJumpHeightReward[priority];
				g_esPlayer[survivor].g_flSpeedBoost = g_esCache[tank].g_flSpeedBoostReward[priority];
				g_esPlayer[survivor].g_iFallPasses = 0;
			}
			else if (g_esCache[tank].g_iStackRewards[priority] == 1 && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esPlayer[survivor].g_iRewardStack[1] < MT_STACK_SPEEDBOOST)
			{
				g_esPlayer[survivor].g_flJumpHeight += g_esCache[tank].g_flJumpHeightReward[priority];
				g_esPlayer[survivor].g_flJumpHeight = flClamp(g_esPlayer[survivor].g_flJumpHeight, 0.1, 999999.0);
				g_esPlayer[survivor].g_flSpeedBoost += g_esCache[tank].g_flSpeedBoostReward[priority];
				g_esPlayer[survivor].g_flSpeedBoost = flClamp(g_esPlayer[survivor].g_flSpeedBoost, 0.1, 999999.0);
				g_esPlayer[survivor].g_iFallPasses = 0;
				g_esPlayer[survivor].g_iRewardStack[1]++;
			}
		}
		case MT_REWARD_DAMAGEBOOST:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flDamageBoost = g_esCache[tank].g_flDamageBoostReward[priority];
				g_esPlayer[survivor].g_flDamageResistance = g_esCache[tank].g_flDamageResistanceReward[priority];
				g_esPlayer[survivor].g_iHollowpointAmmo = g_esCache[tank].g_iHollowpointAmmoReward[priority];
				g_esPlayer[survivor].g_iMeleeRange = g_esCache[tank].g_iMeleeRangeReward[priority];
				g_esPlayer[survivor].g_iSledgehammerRounds = g_esCache[tank].g_iSledgehammerRoundsReward[priority];
				g_esPlayer[survivor].g_iThorns = g_esCache[tank].g_iThornsReward[priority];
			}
			else if (g_esCache[tank].g_iStackRewards[priority] == 1 && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esPlayer[survivor].g_iRewardStack[2] < MT_STACK_DAMAGEBOOST)
			{
				g_esPlayer[survivor].g_flDamageBoost += g_esCache[tank].g_flDamageBoostReward[priority];
				g_esPlayer[survivor].g_flDamageBoost = flClamp(g_esPlayer[survivor].g_flDamageBoost, 0.1, 999999.0);
				g_esPlayer[survivor].g_flDamageResistance -= g_esCache[tank].g_flDamageResistanceReward[priority] / 2.0;
				g_esPlayer[survivor].g_flDamageResistance = flClamp(g_esPlayer[survivor].g_flDamageResistance, 0.1, 1.0);
				g_esPlayer[survivor].g_iHollowpointAmmo = g_esCache[tank].g_iHollowpointAmmoReward[priority];
				g_esPlayer[survivor].g_iMeleeRange += g_esCache[tank].g_iMeleeRangeReward[priority];
				g_esPlayer[survivor].g_iMeleeRange = iClamp(g_esPlayer[survivor].g_iMeleeRange, 0, 999999);
				g_esPlayer[survivor].g_iSledgehammerRounds = g_esCache[tank].g_iSledgehammerRoundsReward[priority];
				g_esPlayer[survivor].g_iThorns = g_esCache[tank].g_iThornsReward[priority];
				g_esPlayer[survivor].g_iRewardStack[2]++;
			}
		}
		case MT_REWARD_ATTACKBOOST:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flActionDuration = g_esCache[tank].g_flActionDurationReward[priority];
				g_esPlayer[survivor].g_flAttackBoost = g_esCache[tank].g_flAttackBoostReward[priority];
				g_esPlayer[survivor].g_flShoveDamage = g_esCache[tank].g_flShoveDamageReward[priority];
				g_esPlayer[survivor].g_flShoveRate = g_esCache[tank].g_flShoveRateReward[priority];
				g_esPlayer[survivor].g_iShovePenalty = g_esCache[tank].g_iShovePenaltyReward[priority];
			}
			else if (g_esCache[tank].g_iStackRewards[priority] == 1 && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esPlayer[survivor].g_iRewardStack[3] < MT_STACK_ATTACKBOOST)
			{
				g_esPlayer[survivor].g_flActionDuration -= g_esCache[tank].g_flActionDurationReward[priority] / 2.0;
				g_esPlayer[survivor].g_flActionDuration = flClamp(g_esPlayer[survivor].g_flActionDuration, 0.1, 999999.0);
				g_esPlayer[survivor].g_flAttackBoost += g_esCache[tank].g_flAttackBoostReward[priority];
				g_esPlayer[survivor].g_flAttackBoost = flClamp(g_esPlayer[survivor].g_flAttackBoost, 0.1, 999999.0);
				g_esPlayer[survivor].g_flShoveDamage += g_esCache[tank].g_flShoveDamageReward[priority];
				g_esPlayer[survivor].g_flShoveDamage = flClamp(g_esPlayer[survivor].g_flShoveDamage, 0.1, 999999.0);
				g_esPlayer[survivor].g_flShoveRate -= g_esCache[tank].g_flShoveRateReward[priority] / 2.0;
				g_esPlayer[survivor].g_flShoveRate = flClamp(g_esPlayer[survivor].g_flShoveRate, 0.1, 999999.0);
				g_esPlayer[survivor].g_iShovePenalty = g_esCache[tank].g_iShovePenaltyReward[priority];
				g_esPlayer[survivor].g_iRewardStack[3]++;
			}
		}
		case MT_REWARD_AMMO:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_iAmmoBoost = g_esCache[tank].g_iAmmoBoostReward[priority];
				g_esPlayer[survivor].g_iAmmoRegen = g_esCache[tank].g_iAmmoRegenReward[priority];
				g_esPlayer[survivor].g_iSpecialAmmo = g_esCache[tank].g_iSpecialAmmoReward[priority];
			}
			else if (g_esCache[tank].g_iStackRewards[priority] == 1 && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esPlayer[survivor].g_iRewardStack[4] < MT_STACK_AMMO)
			{
				g_esPlayer[survivor].g_iAmmoBoost = g_esCache[tank].g_iAmmoBoostReward[priority];
				g_esPlayer[survivor].g_iAmmoRegen += g_esCache[tank].g_iAmmoRegenReward[priority];
				g_esPlayer[survivor].g_iAmmoRegen = iClamp(g_esPlayer[survivor].g_iAmmoRegen, 0, 999999);
				g_esPlayer[survivor].g_iSpecialAmmo |= g_esCache[tank].g_iSpecialAmmoReward[priority];
				g_esPlayer[survivor].g_iSpecialAmmo = iClamp(g_esPlayer[survivor].g_iSpecialAmmo, 0, 3);
				g_esPlayer[survivor].g_iRewardStack[4]++;
			}
		}
		case MT_REWARD_GODMODE:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flPunchResistance = g_esCache[tank].g_flPunchResistanceReward[priority];
				g_esPlayer[survivor].g_iCleanKills = g_esCache[tank].g_iCleanKillsReward[priority];
			}
			else if (g_esCache[tank].g_iStackRewards[priority] == 1 && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esPlayer[survivor].g_iRewardStack[5] < MT_STACK_GODMODE)
			{
				g_esPlayer[survivor].g_flPunchResistance -= g_esCache[tank].g_flPunchResistanceReward[priority] / 2.0;
				g_esPlayer[survivor].g_flPunchResistance = flClamp(g_esPlayer[survivor].g_flPunchResistance, 0.1, 1.0);
				g_esPlayer[survivor].g_iCleanKills = g_esCache[tank].g_iCleanKillsReward[priority];
				g_esPlayer[survivor].g_iRewardStack[5]++;
			}
		}
		case MT_REWARD_INFAMMO:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_iInfiniteAmmo = g_esCache[tank].g_iInfiniteAmmoReward[priority];
			}
			else if (g_esCache[tank].g_iStackRewards[priority] == 1 && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esPlayer[survivor].g_iRewardStack[6] < MT_STACK_INFAMMO)
			{
				g_esPlayer[survivor].g_iInfiniteAmmo |= g_esCache[tank].g_iInfiniteAmmoReward[priority];
				g_esPlayer[survivor].g_iInfiniteAmmo = iClamp(g_esPlayer[survivor].g_iInfiniteAmmo, 0, 31);
				g_esPlayer[survivor].g_iRewardStack[6]++;
			}
		}
	}
}

static void vDefaultCookieSettings(int client)
{
	g_esPlayer[client].g_iRewardVisuals = MT_VISUAL_SCREEN|MT_VISUAL_GLOW|MT_VISUAL_BODY|MT_VISUAL_PARTICLE|MT_VISUAL_VOICELINE;

	for (int iPos = 0; iPos < sizeof(esPlayer::g_bApplyVisuals); iPos++)
	{
		g_esPlayer[client].g_bApplyVisuals[iPos] = true;
	}
}

static void vDeveloperSettings(int developer)
{
	g_esDeveloper[developer].g_bDevVisual = false;
	g_esDeveloper[developer].g_sDevFallVoiceline = "PlayerLaugh";
	g_esDeveloper[developer].g_sDevGlowOutline = "255,135,0";
	g_esDeveloper[developer].g_sDevLoadout = g_bSecondGame ? "shotgun_spas;machete;molotov;first_aid_kit;pain_pills" : "autoshotgun;pistol;molotov;first_aid_kit;pain_pills;pistol";
	g_esDeveloper[developer].g_sDevSkinColor = "150,0,0,150";
	g_esDeveloper[developer].g_flDevActionDuration = 2.0;
	g_esDeveloper[developer].g_flDevAttackBoost = 1.25;
	g_esDeveloper[developer].g_flDevDamageBoost = 1.75;
	g_esDeveloper[developer].g_flDevDamageResistance = 0.5;
	g_esDeveloper[developer].g_flDevHealPercent = 100.0;
	g_esDeveloper[developer].g_flDevJumpHeight = 100.0;
	g_esDeveloper[developer].g_flDevPunchResistance = 0.0;
	g_esDeveloper[developer].g_flDevRewardDuration = 60.0;
	g_esDeveloper[developer].g_flDevShoveDamage = 0.025;
	g_esDeveloper[developer].g_flDevShoveRate = 0.4;
	g_esDeveloper[developer].g_flDevSpeedBoost = 1.25;
	g_esDeveloper[developer].g_iDevAccess = 0;
	g_esDeveloper[developer].g_iDevAmmoRegen = 1;
	g_esDeveloper[developer].g_iDevHealthRegen = 1;
	g_esDeveloper[developer].g_iDevInfiniteAmmo = 31;
	g_esDeveloper[developer].g_iDevLifeLeech = 5;
	g_esDeveloper[developer].g_iDevMeleeRange = 150;
	g_esDeveloper[developer].g_iDevPanelLevel = 0;
	g_esDeveloper[developer].g_iDevParticle = MT_ROCK_FIRE;
	g_esDeveloper[developer].g_iDevReviveHealth = 100;
	g_esDeveloper[developer].g_iDevRewardTypes = MT_REWARD_HEALTH|MT_REWARD_AMMO|MT_REWARD_REFILL|MT_REWARD_ATTACKBOOST|MT_REWARD_DAMAGEBOOST|MT_REWARD_SPEEDBOOST|MT_REWARD_GODMODE|MT_REWARD_ITEM|MT_REWARD_RESPAWN|MT_REWARD_INFAMMO;
	g_esDeveloper[developer].g_iDevSpecialAmmo = 0;
	g_esDeveloper[developer].g_iDevWeaponSkin = 1;

	vDefaultCookieSettings(developer);
}

static void vCheckClipSizes(int survivor)
{
	if (g_esGeneral.g_hSDKGetMaxClip1 != null)
	{
		int iSlot = GetPlayerWeaponSlot(survivor, 0);
		if (iSlot > MaxClients)
		{
			g_esPlayer[survivor].g_iMaxClip[0] = SDKCall(g_esGeneral.g_hSDKGetMaxClip1, iSlot);
		}

		iSlot = GetPlayerWeaponSlot(survivor, 1);
		if (iSlot > MaxClients)
		{
			char sWeapon[32];
			GetEntityClassname(iSlot, sWeapon, sizeof(sWeapon));
			if (StrContains(sWeapon, "pistol") != -1 || StrEqual(sWeapon, "weapon_chainsaw"))
			{
				g_esPlayer[survivor].g_iMaxClip[1] = SDKCall(g_esGeneral.g_hSDKGetMaxClip1, iSlot);
			}
		}
	}
}

static void vGiveRandomMeleeWeapon(int survivor, bool specific, const char[] name = "")
{
	if (specific)
	{
		vCheatCommand(survivor, "give", ((name[0] != '\0') ? name : "machete"));

		if (GetPlayerWeaponSlot(survivor, 1) > MaxClients)
		{
			return;
		}

		vGiveRandomMeleeWeapon(survivor, false);
	}
	else
	{
		char sName[32];
		for (int iType = 1; iType < 13; iType++)
		{
			if (GetPlayerWeaponSlot(survivor, 1) > MaxClients)
			{
				break;
			}

			switch (iType)
			{
				case 1: sName = "machete";
				case 2: sName = "katana";
				case 3: sName = "fireaxe";
				case 4: sName = "shovel";
				case 5: sName = "baseball_bat";
				case 6: sName = "cricket_bat";
				case 7: sName = "golfclub";
				case 8: sName = "electric_guitar";
				case 9: sName = "frying_pan";
				case 10: sName = "tonfa";
				case 11: sName = "crowbar";
				case 12: sName = "knife";
				case 13: sName = "pitchfork";
			}

			vCheatCommand(survivor, "give", sName);
		}
	}
}

static void vGiveSpecialAmmo(int survivor)
{
	int iType = ((bIsDeveloper(survivor, 7) || bIsDeveloper(survivor, 11)) && g_esDeveloper[survivor].g_iDevSpecialAmmo > g_esPlayer[survivor].g_iSpecialAmmo) ? g_esDeveloper[survivor].g_iDevSpecialAmmo : g_esPlayer[survivor].g_iSpecialAmmo;
	if (g_bSecondGame && iType > 0)
	{
		int iSlot = GetPlayerWeaponSlot(survivor, 0);
		if (iSlot > MaxClients)
		{
			int iAmmoType = GetEntProp(iSlot, Prop_Send, "m_iPrimaryAmmoType");
			if (iAmmoType != 6 && iAmmoType != 17) // rifle_m60 and grenade_launcher
			{
				int iUpgrades = GetEntProp(iSlot, Prop_Send, "m_upgradeBitVec");

				switch (iType)
				{
					case 1: iUpgrades = (iUpgrades & MT_UPGRADE_LASERSIGHT) ? MT_UPGRADE_LASERSIGHT|MT_UPGRADE_INCENDIARY : MT_UPGRADE_INCENDIARY;
					case 2: iUpgrades = (iUpgrades & MT_UPGRADE_LASERSIGHT) ? MT_UPGRADE_LASERSIGHT|MT_UPGRADE_EXPLOSIVE : MT_UPGRADE_EXPLOSIVE;
					case 3:
					{
						int iSpecialAmmo = (GetRandomInt(1, 2) == 2) ? MT_UPGRADE_INCENDIARY : MT_UPGRADE_EXPLOSIVE;
						iUpgrades = (iUpgrades & MT_UPGRADE_LASERSIGHT) ? MT_UPGRADE_LASERSIGHT|iSpecialAmmo : iSpecialAmmo;
					}
				}

				SetEntProp(iSlot, Prop_Send, "m_upgradeBitVec", iUpgrades);
				SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", GetEntProp(iSlot, Prop_Send, "m_iClip1"));
			}
		}
	}
}

static void vGiveWeapons(int survivor)
{
	int iSlot = 0;
	if (g_esPlayer[survivor].g_sWeaponPrimary[0] != '\0')
	{
		vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponPrimary);

		iSlot = GetPlayerWeaponSlot(survivor, 0);
		if (iSlot > MaxClients)
		{
			SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[survivor].g_iWeaponInfo[0]);
			SetEntProp(survivor, Prop_Send, "m_iAmmo", g_esPlayer[survivor].g_iWeaponInfo[1], _, iGetWeaponOffset(iSlot));

			if (g_bSecondGame)
			{
				if (g_esPlayer[survivor].g_iWeaponInfo[2] > 0)
				{
					SetEntProp(iSlot, Prop_Send, "m_upgradeBitVec", g_esPlayer[survivor].g_iWeaponInfo[2]);
				}

				if (g_esPlayer[survivor].g_iWeaponInfo[3] > 0)
				{
					SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", g_esPlayer[survivor].g_iWeaponInfo[3]);
				}
			}
		}
	}

	if (g_esPlayer[survivor].g_sWeaponSecondary[0] != '\0')
	{
		switch (g_esPlayer[survivor].g_bDualWielding)
		{
			case true:
			{
				vCheatCommand(survivor, "give", "weapon_pistol");
				vCheatCommand(survivor, "give", "weapon_pistol");
			}
			case false: vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponSecondary);
		}

		iSlot = GetPlayerWeaponSlot(survivor, 1);
		if (iSlot > MaxClients && g_esPlayer[survivor].g_iWeaponInfo2 != -1)
		{
			SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[survivor].g_iWeaponInfo2);
		}
	}

	if (g_esPlayer[survivor].g_sWeaponThrowable[0] != '\0')
	{
		vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponThrowable);
	}

	if (g_esPlayer[survivor].g_sWeaponMedkit[0] != '\0')
	{
		vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponMedkit);
	}

	if (g_esPlayer[survivor].g_sWeaponPills[0] != '\0')
	{
		vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponPills);
	}

	for (int iPos = 0; iPos < sizeof(esPlayer::g_iWeaponInfo); iPos++)
	{
		g_esPlayer[survivor].g_iWeaponInfo[iPos] = 0;
	}

	g_esPlayer[survivor].g_iWeaponInfo2 = -1;
	g_esPlayer[survivor].g_sWeaponPrimary[0] = '\0';
	g_esPlayer[survivor].g_sWeaponSecondary[0] = '\0';
	g_esPlayer[survivor].g_sWeaponThrowable[0] = '\0';
	g_esPlayer[survivor].g_sWeaponMedkit[0] = '\0';
	g_esPlayer[survivor].g_sWeaponPills[0] = '\0';
}

static void vRefillAmmo(int survivor, bool all = false, bool reset = false)
{
	static int iSetting;
	iSetting = (bIsDeveloper(survivor, 7) && g_esDeveloper[survivor].g_iDevInfiniteAmmo > g_esPlayer[survivor].g_iInfiniteAmmo) ? g_esDeveloper[survivor].g_iDevInfiniteAmmo : g_esPlayer[survivor].g_iInfiniteAmmo;
	iSetting = all ? iSetting : 0;

	static int iSlot;
	if (!all || (iSetting > 0 && (iSetting & MT_INFAMMO_PRIMARY)))
	{
		iSlot = GetPlayerWeaponSlot(survivor, 0);
		if (iSlot > MaxClients)
		{
			static int iMaxClip;
			iMaxClip = reset ? iGetMaxAmmo(survivor, 0, iSlot, false, true) : g_esPlayer[survivor].g_iMaxClip[0];
			if (!reset || (reset && GetEntProp(iSlot, Prop_Send, "m_iClip1") >= iMaxClip))
			{
				SetEntProp(iSlot, Prop_Send, "m_iClip1", iMaxClip);
			}

			if (g_bSecondGame)
			{
				static int iUpgrades;
				iUpgrades = GetEntProp(iSlot, Prop_Send, "m_upgradeBitVec");
				if ((iUpgrades & MT_UPGRADE_INCENDIARY) || (iUpgrades & MT_UPGRADE_EXPLOSIVE))
				{
					SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", iMaxClip);
				}
			}

			vRefillMagazine(survivor, iSlot, reset);
		}
	}

	if (!all || (iSetting > 0 && (iSetting & MT_INFAMMO_SECONDARY)))
	{
		iSlot = GetPlayerWeaponSlot(survivor, 1);
		if (iSlot > MaxClients)
		{
			static char sWeapon[32];
			GetEntityClassname(iSlot, sWeapon, sizeof(sWeapon));
			if ((StrContains(sWeapon, "pistol") != -1 || StrEqual(sWeapon, "weapon_chainsaw")) && (!reset || (reset && GetEntProp(iSlot, Prop_Send, "m_iClip1") >= g_esPlayer[survivor].g_iMaxClip[1])))
			{
				SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[survivor].g_iMaxClip[1]);
			}
		}
	}

	if (all && iSetting > 0)
	{
		iSlot = GetPlayerWeaponSlot(survivor, 2);
		if (!bIsValidEntity(iSlot) && (iSetting & MT_INFAMMO_THROWABLE))
		{
			vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sStoredThrowable);
		}

		iSlot = GetPlayerWeaponSlot(survivor, 3);
		if (!bIsValidEntity(iSlot) && (iSetting & MT_INFAMMO_MEDKIT))
		{
			vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sStoredMedkit);
		}

		iSlot = GetPlayerWeaponSlot(survivor, 4);
		if (!bIsValidEntity(iSlot) && (iSetting & MT_INFAMMO_PILLS))
		{
			vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sStoredPills);
		}
	}
}

static void vRefillHealth(int survivor)
{
	if (bIsSurvivorDisabled(survivor) || GetEntProp(survivor, Prop_Data, "m_iHealth") < GetEntProp(survivor, Prop_Data, "m_iMaxHealth"))
	{
		int iMode = GetEntProp(survivor, Prop_Data, "m_takedamage", 1);
		if (iMode != 2)
		{
			SetEntProp(survivor, Prop_Data, "m_takedamage", 2, 1);
			vCheatCommand(survivor, "give", "health");
			SetEntProp(survivor, Prop_Data, "m_takedamage", iMode, 1);
		}
		else
		{
			vCheatCommand(survivor, "give", "health");
		}

		g_esPlayer[survivor].g_bLastLife = false;
		g_esPlayer[survivor].g_iReviveCount = 0;
	}
}

static void vRefillMagazine(int survivor, int weapon, bool reset)
{
	static int iAmmoOffset, iNewAmmo;
	iAmmoOffset = iGetWeaponOffset(weapon), iNewAmmo = 0;

	switch (reset)
	{
		case true:
		{
			static int iMaxAmmo;
			iMaxAmmo = iGetMaxAmmo(survivor, 0, weapon, true, reset);
			if (GetEntProp(survivor, Prop_Send, "m_iAmmo", _, iAmmoOffset) > iMaxAmmo)
			{
				iNewAmmo = iMaxAmmo;
			}
		}
		case false: iNewAmmo = iGetMaxAmmo(survivor, 0, weapon, true, reset);
	}

	if (iNewAmmo > 0)
	{
		SetEntProp(survivor, Prop_Send, "m_iAmmo", iNewAmmo, _, iAmmoOffset);
	}
}

static void vRespawnSurvivor(int survivor)
{
	if (g_esGeneral.g_hSDKRoundRespawn != null)
	{
		static int iIndex = -1;
		if (iIndex == -1)
		{
			iIndex = iGetPatchIndex("RespawnStats");
		}

		if (iIndex != -1)
		{
			bInstallPatch(iIndex);
		}

		SDKCall(g_esGeneral.g_hSDKRoundRespawn, survivor);

		if (iIndex != -1)
		{
			bRemovePatch(iIndex);
		}
	}
}

static void vSaveWeapons(int survivor)
{
	char sWeapon[32];
	g_esPlayer[survivor].g_iWeaponInfo2 = -1;
	int iSlot = GetPlayerWeaponSlot(survivor, 0);
	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof(sWeapon));
		strcopy(g_esPlayer[survivor].g_sWeaponPrimary, sizeof(esPlayer::g_sWeaponPrimary), sWeapon);

		g_esPlayer[survivor].g_iWeaponInfo[0] = GetEntProp(iSlot, Prop_Send, "m_iClip1");
		g_esPlayer[survivor].g_iWeaponInfo[1] = GetEntProp(survivor, Prop_Send, "m_iAmmo", _, iGetWeaponOffset(iSlot));

		if (g_bSecondGame)
		{
			g_esPlayer[survivor].g_iWeaponInfo[2] = GetEntProp(iSlot, Prop_Send, "m_upgradeBitVec");
			g_esPlayer[survivor].g_iWeaponInfo[3] = GetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
		}
	}

	iSlot = 0;
	if (g_bSecondGame)
	{
		if (bIsSurvivorDisabled(survivor) && g_esGeneral.g_iMeleeOffset != -1)
		{
			int iMelee = GetEntDataEnt2(survivor, g_esGeneral.g_iMeleeOffset);

			switch (bIsValidEntity(iMelee))
			{
				case true: iSlot = iMelee;
				case false: iSlot = GetPlayerWeaponSlot(survivor, 1);
			}
		}
		else
		{
			iSlot = GetPlayerWeaponSlot(survivor, 1);
		}
	}
	else
	{
		iSlot = GetPlayerWeaponSlot(survivor, 1);
	}

	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof(sWeapon));
		if (StrEqual(sWeapon, "weapon_melee"))
		{
			GetEntPropString(iSlot, Prop_Data, "m_strMapSetScriptName", sWeapon, sizeof(sWeapon));
		}

		strcopy(g_esPlayer[survivor].g_sWeaponSecondary, sizeof(esPlayer::g_sWeaponSecondary), sWeapon);
		if (StrContains(sWeapon, "pistol") != -1 || StrEqual(sWeapon, "weapon_chainsaw"))
		{
			g_esPlayer[survivor].g_iWeaponInfo2 = GetEntProp(iSlot, Prop_Send, "m_iClip1");
		}

		g_esPlayer[survivor].g_bDualWielding = StrContains(sWeapon, "pistol") != -1 && GetEntProp(iSlot, Prop_Send, "m_isDualWielding") > 0;
	}

	iSlot = GetPlayerWeaponSlot(survivor, 2);
	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof(sWeapon));
		strcopy(g_esPlayer[survivor].g_sWeaponThrowable, sizeof(esPlayer::g_sWeaponThrowable), sWeapon);
	}

	iSlot = GetPlayerWeaponSlot(survivor, 3);
	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof(sWeapon));
		strcopy(g_esPlayer[survivor].g_sWeaponMedkit, sizeof(esPlayer::g_sWeaponMedkit), sWeapon);
	}

	iSlot = GetPlayerWeaponSlot(survivor, 4);
	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof(sWeapon));
		strcopy(g_esPlayer[survivor].g_sWeaponPills, sizeof(esPlayer::g_sWeaponPills), sWeapon);
	}
}

static void vSaveCaughtSurvivor(int survivor, int special = 0)
{
	int iSpecial = special;
	iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_pounceAttacker") : iSpecial;
	iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_tongueOwner") : iSpecial;
	if (g_bSecondGame)
	{
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_pummelAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_carryAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_jockeyAttacker") : iSpecial;
	}

	if (iSpecial > 0)
	{
		SDKHooks_TakeDamage(iSpecial, survivor, survivor, float(GetEntProp(iSpecial, Prop_Data, "m_iHealth")));
	}
}

static void vSpawnMessages(int tank)
{
	if (bIsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esTank[g_esPlayer[tank].g_iTankType].g_iHumanSupport == 1 && bHasCoreAdminAccess(tank))
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpawnMessage");
		MT_PrintToChat(tank, "%s %t", MT_TAG2, "AbilityButtons");
		MT_PrintToChat(tank, "%s %t", MT_TAG2, "AbilityButtons2");
		MT_PrintToChat(tank, "%s %t", MT_TAG2, "AbilityButtons3");
		MT_PrintToChat(tank, "%s %t", MT_TAG2, "AbilityButtons4");
	}
}

static void vSpawnModes(int tank, bool status)
{
	g_esPlayer[tank].g_bBoss = status;
	g_esPlayer[tank].g_bCombo = status;
	g_esPlayer[tank].g_bRandomized = status;
	g_esPlayer[tank].g_bTransformed = status;
}

static void vSetColor(int tank, int type = 0, bool change = true, bool revert = false)
{
	if (type == -1)
	{
		return;
	}

	if (g_esPlayer[tank].g_iTankType > 0)
	{
		if (change)
		{
			vResetTank(tank);
		}

		if (type == 0)
		{
			vRemoveProps(tank);
			vChangeTypeForward(tank, g_esPlayer[tank].g_iTankType, type, revert);

			g_esPlayer[tank].g_iTankType = type;

			return;
		}
		else if (g_esPlayer[tank].g_iTankType == type && !g_esPlayer[tank].g_bReplaceSelf && !g_esPlayer[tank].g_bKeepCurrentType)
		{
			g_esPlayer[tank].g_iTankType = 0;

			vRemoveProps(tank);
			vChangeTypeForward(tank, type, g_esPlayer[tank].g_iTankType, revert);

			return;
		}
		else if (type > 0)
		{
			g_esPlayer[tank].g_iOldTankType = g_esPlayer[tank].g_iTankType;
		}
	}

	g_esPlayer[tank].g_iTankType = type;
	g_esPlayer[tank].g_bReplaceSelf = false;

	vChangeTypeForward(tank, g_esPlayer[tank].g_iOldTankType, g_esPlayer[tank].g_iTankType, revert);
	vCacheSettings(tank);
	vSetTankModel(tank);
	vRemoveGlow(tank);
	SetEntityRenderMode(tank, RENDER_NORMAL);
	SetEntityRenderColor(tank, iGetRandomColor(g_esCache[tank].g_iSkinColor[0]), iGetRandomColor(g_esCache[tank].g_iSkinColor[1]), iGetRandomColor(g_esCache[tank].g_iSkinColor[2]), iGetRandomColor(g_esCache[tank].g_iSkinColor[3]));
}

static void vSetDurationCvars(int item, bool reset, float duration = 1.0)
{
	if (g_esGeneral.g_hSDKGetUseAction != null)
	{
		int iType = SDKCall(g_esGeneral.g_hSDKGetUseAction, item);
		if (reset)
		{
			switch (iType)
			{
				case 1:
				{
					if (g_esGeneral.g_flDefaultFirstAidKitUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = g_esGeneral.g_flDefaultFirstAidKitUseDuration; // first_aid_kit
						g_esGeneral.g_flDefaultFirstAidKitUseDuration = -1.0;
					}
				}
				case 2:
				{
					if (g_esGeneral.g_flDefaultAmmoPackUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTAmmoPackUseDuration.FloatValue = g_esGeneral.g_flDefaultAmmoPackUseDuration; // ammo_pack
						g_esGeneral.g_flDefaultAmmoPackUseDuration = -1.0;
					}
				}
				case 4:
				{
					if (g_esGeneral.g_flDefaultDefibrillatorUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTDefibrillatorUseDuration.FloatValue = g_esGeneral.g_flDefaultDefibrillatorUseDuration; // defibrillator
						g_esGeneral.g_flDefaultDefibrillatorUseDuration = -1.0;
					}
				}
				case 6, 7:
				{
					if (g_esGeneral.g_flDefaultUpgradePackUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTUpgradePackUseDuration.FloatValue = g_esGeneral.g_flDefaultUpgradePackUseDuration; // upgrade_pack
						g_esGeneral.g_flDefaultUpgradePackUseDuration = -1.0;
					}
				}
				case 8:
				{
					if (g_esGeneral.g_flDefaultGasCanUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTGasCanUseDuration.FloatValue = g_esGeneral.g_flDefaultGasCanUseDuration; // gas_can
						g_esGeneral.g_flDefaultGasCanUseDuration = -1.0;
					}
				}
				case 9:
				{
					if (g_esGeneral.g_flDefaultColaBottlesUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTColaBottlesUseDuration.FloatValue = g_esGeneral.g_flDefaultColaBottlesUseDuration; // cola_bottles
						g_esGeneral.g_flDefaultColaBottlesUseDuration = -1.0;
					}
				}
			}
		}
		else
		{
			switch (iType)
			{
				case 1:
				{
					if (g_esGeneral.g_cvMTFirstAidKitUseDuration != null)
					{
						g_esGeneral.g_flDefaultFirstAidKitUseDuration = g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue;
						g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = duration; // first_aid_kit
					}
				}
				case 2:
				{
					if (g_esGeneral.g_cvMTAmmoPackUseDuration != null)
					{
						g_esGeneral.g_flDefaultAmmoPackUseDuration = g_esGeneral.g_cvMTAmmoPackUseDuration.FloatValue;
						g_esGeneral.g_cvMTAmmoPackUseDuration.FloatValue = duration; // ammo_pack
					}
				}
				case 4:
				{
					if (g_esGeneral.g_cvMTDefibrillatorUseDuration != null)
					{
						g_esGeneral.g_flDefaultDefibrillatorUseDuration = g_esGeneral.g_cvMTDefibrillatorUseDuration.FloatValue;
						g_esGeneral.g_cvMTDefibrillatorUseDuration.FloatValue = duration; // defibrillator
					}
				}
				case 6, 7:
				{
					if (g_esGeneral.g_cvMTUpgradePackUseDuration != null)
					{
						g_esGeneral.g_flDefaultUpgradePackUseDuration = g_esGeneral.g_cvMTUpgradePackUseDuration.FloatValue;
						g_esGeneral.g_cvMTUpgradePackUseDuration.FloatValue = duration; // upgrade_pack
					}
				}
				case 8:
				{
					if (g_esGeneral.g_cvMTGasCanUseDuration != null)
					{
						g_esGeneral.g_flDefaultGasCanUseDuration = g_esGeneral.g_cvMTGasCanUseDuration.FloatValue;
						g_esGeneral.g_cvMTGasCanUseDuration.FloatValue = duration; // gas_can
					}
				}
				case 9:
				{
					if (g_esGeneral.g_cvMTColaBottlesUseDuration != null)
					{
						g_esGeneral.g_flDefaultColaBottlesUseDuration = g_esGeneral.g_cvMTColaBottlesUseDuration.FloatValue;
						g_esGeneral.g_cvMTColaBottlesUseDuration.FloatValue = duration; // cola_bottles
					}
				}
			}
		}
	}
}

static void vSetHealPercentCvar(bool reset, int survivor = 0)
{
	if (reset)
	{
		if (g_esGeneral.g_flDefaultFirstAidHealPercent != -1.0)
		{
			g_esGeneral.g_cvMTFirstAidHealPercent.FloatValue = g_esGeneral.g_flDefaultFirstAidHealPercent;
			g_esGeneral.g_flDefaultFirstAidHealPercent = -1.0;
		}
	}
	else
	{
		bool bDeveloper = bIsDeveloper(survivor, 6);
		if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH))
		{
			float flPercent = (bDeveloper && g_esDeveloper[survivor].g_flDevHealPercent > g_esPlayer[survivor].g_flHealPercent) ? g_esDeveloper[survivor].g_flDevHealPercent : g_esPlayer[survivor].g_flHealPercent;
			if (flPercent > 0.0)
			{
				g_esGeneral.g_flDefaultFirstAidHealPercent = g_esGeneral.g_cvMTFirstAidHealPercent.FloatValue;
				g_esGeneral.g_cvMTFirstAidHealPercent.FloatValue = flPercent / 100.0;
			}
		}
	}
}

static void vSetReviveDurationCvar(int survivor)
{
	bool bDeveloper = bIsDeveloper(survivor, 6);
	if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
	{
		float flDuration = (bDeveloper && g_esDeveloper[survivor].g_flDevActionDuration > g_esPlayer[survivor].g_flActionDuration) ? g_esDeveloper[survivor].g_flDevActionDuration : g_esPlayer[survivor].g_flActionDuration;
		if (flDuration > 0.0)
		{
			g_esGeneral.g_flDefaultSurvivorReviveDuration = g_esGeneral.g_cvMTSurvivorReviveDuration.FloatValue;
			g_esGeneral.g_cvMTSurvivorReviveDuration.FloatValue = flDuration;
		}
	}
}

static void vSetReviveHealthCvar(bool reset, int survivor = 0)
{
	if (reset)
	{
		if (g_esGeneral.g_iDefaultSurvivorReviveHealth != -1)
		{
			g_esGeneral.g_cvMTSurvivorReviveHealth.IntValue = g_esGeneral.g_iDefaultSurvivorReviveHealth;
			g_esGeneral.g_iDefaultSurvivorReviveHealth = -1;
		}
	}
	else
	{
		bool bDeveloper = bIsDeveloper(survivor, 6);
		if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH))
		{
			int iHealth = (bDeveloper && g_esDeveloper[survivor].g_iDevReviveHealth > g_esPlayer[survivor].g_iReviveHealth) ? g_esDeveloper[survivor].g_iDevReviveHealth : g_esPlayer[survivor].g_iReviveHealth;
			if (iHealth > 0)
			{
				g_esGeneral.g_iDefaultSurvivorReviveHealth = g_esGeneral.g_cvMTSurvivorReviveHealth.IntValue;
				g_esGeneral.g_cvMTSurvivorReviveHealth.IntValue = iHealth;
			}
		}
	}
}

static void vGetTranslatedName(char[] buffer, int size, int tank = 0, int type = 0)
{
	static int iType;
	iType = (type > 0) ? type : g_esPlayer[tank].g_iTankType;
	if (tank > 0 && g_esPlayer[tank].g_sTankName[0] != '\0')
	{
		static char sPhrase[32], sPhrase2[32], sSteamIDFinal[32];
		FormatEx(sPhrase, sizeof(sPhrase), "%s Name", g_esPlayer[tank].g_sSteamID32);
		FormatEx(sPhrase2, sizeof(sPhrase2), "%s Name", g_esPlayer[tank].g_sSteam3ID);
		FormatEx(sSteamIDFinal, sizeof(sSteamIDFinal), "%s", (TranslationPhraseExists(sPhrase) ? sPhrase : sPhrase2));

		switch (sSteamIDFinal[0] != '\0' && TranslationPhraseExists(sSteamIDFinal))
		{
			case true: strcopy(buffer, size, sSteamIDFinal);
			case false: strcopy(buffer, size, "NoName");
		}
	}
	else if (g_esTank[iType].g_sTankName[0] != '\0')
	{
		static char sTankName[32];
		FormatEx(sTankName, sizeof(sTankName), "Tank #%i Name", iType);

		switch (sTankName[0] != '\0' && TranslationPhraseExists(sTankName))
		{
			case true: strcopy(buffer, size, sTankName);
			case false: strcopy(buffer, size, "NoName");
		}
	}
	else
	{
		strcopy(buffer, size, "NoName");
	}
}

static void vSetHealth(int tank)
{
	static int iHumanCount, iSpawnHealth, iExtraHealthNormal, iExtraHealthBoost, iExtraHealthBoost2, iExtraHealthBoost3, iNoBoost, iBoost,
		iBoost2, iBoost3, iNegaNoBoost, iNegaBoost, iNegaBoost2, iNegaBoost3, iFinalNoHealth, iFinalHealth, iFinalHealth2, iFinalHealth3;
	iHumanCount = iGetHumanCount();
	iSpawnHealth = (g_esCache[tank].g_iBaseHealth > 0) ? g_esCache[tank].g_iBaseHealth : GetEntProp(tank, Prop_Data, "m_iHealth");
	iExtraHealthNormal = iSpawnHealth + g_esCache[tank].g_iExtraHealth;
	iExtraHealthBoost = (iHumanCount >= g_esCache[tank].g_iMinimumHumans) ? ((iSpawnHealth * iHumanCount) + g_esCache[tank].g_iExtraHealth) : iExtraHealthNormal;
	iExtraHealthBoost2 = (iHumanCount >= g_esCache[tank].g_iMinimumHumans) ? (iSpawnHealth + (iHumanCount * g_esCache[tank].g_iExtraHealth)) : iExtraHealthNormal;
	iExtraHealthBoost3 = (iHumanCount >= g_esCache[tank].g_iMinimumHumans) ? (iHumanCount * (iSpawnHealth + g_esCache[tank].g_iExtraHealth)) : iExtraHealthNormal;
	iNoBoost = (iExtraHealthNormal > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthNormal;
	iBoost = (iExtraHealthBoost > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthBoost;
	iBoost2 = (iExtraHealthBoost2 > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthBoost2;
	iBoost3 = (iExtraHealthBoost3 > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthBoost3;
	iNegaNoBoost = (iExtraHealthNormal < iSpawnHealth) ? 1 : iExtraHealthNormal;
	iNegaBoost = (iExtraHealthBoost < iSpawnHealth) ? 1 : iExtraHealthBoost;
	iNegaBoost2 = (iExtraHealthBoost2 < iSpawnHealth) ? 1 : iExtraHealthBoost2;
	iNegaBoost3 = (iExtraHealthBoost3 < iSpawnHealth) ? 1 : iExtraHealthBoost3;
	iFinalNoHealth = (iExtraHealthNormal >= 0) ? iNoBoost : iNegaNoBoost;
	iFinalHealth = (iExtraHealthNormal >= 0) ? iBoost : iNegaBoost;
	iFinalHealth2 = (iExtraHealthNormal >= 0) ? iBoost2 : iNegaBoost2;
	iFinalHealth3 = (iExtraHealthNormal >= 0) ? iBoost3 : iNegaBoost3;
	SetEntProp(tank, Prop_Data, "m_iHealth", iFinalNoHealth);
	SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalNoHealth);

	switch (g_esCache[tank].g_iMultiplyHealth)
	{
		case 1:
		{
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth);
		}
		case 2:
		{
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth2);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth2);
		}
		case 3:
		{
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth3);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth3);
		}
	}
}

static void vSetName(int tank, const char[] oldname, const char[] name, int mode)
{
	if (bIsTankSupported(tank))
	{
		if (!bIsTank(tank, MT_CHECK_FAKECLIENT))
		{
			if (g_esCache[tank].g_sTankName[0] == '\0')
			{
				g_esCache[tank].g_sTankName = "Tank";
			}

			g_esGeneral.g_bHideNameChange = true;
			SetClientName(tank, g_esCache[tank].g_sTankName);
			g_esGeneral.g_bHideNameChange = false;
		}

		switch (bIsTankIdle(tank) && (mode == 0 || mode == 5))
		{
			case true:
			{
				DataPack dpAnnounce;
				CreateDataTimer(0.1, tTimerAnnounce, dpAnnounce, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpAnnounce.WriteCell(GetClientUserId(tank));
				dpAnnounce.WriteString(oldname);
				dpAnnounce.WriteString(name);
				dpAnnounce.WriteCell(mode);
			}
			case false: vAnnounce(tank, oldname, name, mode);
		}
	}
}

static void vTriggerTank(int tank)
{
	if (bIsTankIdle(tank, 1) && g_esGeneral.g_iCurrentMode == 1 && g_esGeneral.g_iAggressiveTanks == 1 && !g_esPlayer[tank].g_bTriggered)
	{
		g_esPlayer[tank].g_bTriggered = true;

		int iHealth = GetEntProp(tank, Prop_Data, "m_iHealth");
		vDamagePlayer(tank, iGetRandomSurvivor(tank), 1.0);
		SetEntProp(tank, Prop_Data, "m_iHealth", iHealth);
	}
}

static void vSetProps(int tank)
{
	if (bIsTankSupported(tank))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[0] && (g_esCache[tank].g_iPropsAttached & MT_PROP_BLUR) && !g_esPlayer[tank].g_bBlur)
		{
			float flTankPos[3], flTankAng[3];
			GetClientAbsOrigin(tank, flTankPos);
			GetClientAbsAngles(tank, flTankAng);

			int iTankModel = CreateEntityByName("prop_dynamic");
			if (bIsValidEntity(iTankModel))
			{
				g_esPlayer[tank].g_bBlur = true;

				char sModel[32];
				GetEntPropString(tank, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

				switch (sModel[21])
				{
					case 'm': SetEntityModel(iTankModel, MODEL_TANK_MAIN);
					case 'd': SetEntityModel(iTankModel, MODEL_TANK_DLC);
					case 'l': SetEntityModel(iTankModel, MODEL_TANK_L4D1);
				}

				SetEntityRenderColor(iTankModel, iGetRandomColor(g_esCache[tank].g_iSkinColor[0]), iGetRandomColor(g_esCache[tank].g_iSkinColor[1]), iGetRandomColor(g_esCache[tank].g_iSkinColor[2]), iGetRandomColor(g_esCache[tank].g_iSkinColor[3]));
				SetEntPropEnt(iTankModel, Prop_Send, "m_hOwnerEntity", tank);

				TeleportEntity(iTankModel, flTankPos, flTankAng, NULL_VECTOR);
				DispatchSpawn(iTankModel);

				AcceptEntityInput(iTankModel, "DisableCollision");
				SetEntProp(iTankModel, Prop_Send, "m_nSequence", GetEntProp(tank, Prop_Send, "m_nSequence"));
				SetEntPropFloat(iTankModel, Prop_Send, "m_flPlaybackRate", 5.0);

				SDKHook(iTankModel, SDKHook_SetTransmit, OnPropSetTransmit);

				DataPack dpBlur;
				CreateDataTimer(0.25, tTimerBlurEffect, dpBlur, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpBlur.WriteCell(EntIndexToEntRef(iTankModel));
				dpBlur.WriteCell(GetClientUserId(tank));
			}
		}

		float flOrigin[3], flAngles[3];
		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		float flChance = GetRandomFloat(0.1, 100.0);
		for (int iLight = 0; iLight < sizeof(esPlayer::g_iLight); iLight++)
		{
			static float flValue;
			flValue = (iLight < 3) ? GetRandomFloat(0.1, 100.0) : flChance;
			static int iFlag, iType;
			iFlag = (iLight < 3) ? MT_PROP_LIGHT : MT_PROP_CROWN, iType = (iLight < 3) ? 1 : 8;
			if ((g_esPlayer[tank].g_iLight[iLight] == 0 || g_esPlayer[tank].g_iLight[iLight] == INVALID_ENT_REFERENCE) && flValue <= g_esCache[tank].g_flPropsChance[iType] && (g_esCache[tank].g_iPropsAttached & iFlag))
			{
				vLightProp(tank, iLight, flOrigin, flAngles);
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iLight[iLight]))
			{
				g_esPlayer[tank].g_iLight[iLight] = EntRefToEntIndex(g_esPlayer[tank].g_iLight[iLight]);
				if (bIsValidEntity(g_esPlayer[tank].g_iLight[iLight]))
				{
					SDKUnhook(g_esPlayer[tank].g_iLight[iLight], SDKHook_SetTransmit, OnPropSetTransmit);
					RemoveEntity(g_esPlayer[tank].g_iLight[iLight]);
				}

				g_esPlayer[tank].g_iLight[iLight] = INVALID_ENT_REFERENCE;
				if (g_esCache[tank].g_iPropsAttached & iFlag)
				{
					vLightProp(tank, iLight, flOrigin, flAngles);
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		for (int iOzTank = 0; iOzTank < sizeof(esPlayer::g_iOzTank); iOzTank++)
		{
			if ((g_esPlayer[tank].g_iOzTank[iOzTank] == 0 || g_esPlayer[tank].g_iOzTank[iOzTank] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[2] && (g_esCache[tank].g_iPropsAttached & MT_PROP_OXYGENTANK))
			{
				g_esPlayer[tank].g_iOzTank[iOzTank] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]))
				{
					SetEntityModel(g_esPlayer[tank].g_iOzTank[iOzTank], MODEL_OXYGENTANK);
					SetEntityRenderColor(g_esPlayer[tank].g_iOzTank[iOzTank], iGetRandomColor(g_esCache[tank].g_iOzTankColor[0]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[1]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[2]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[3]));

					DispatchKeyValueVector(g_esPlayer[tank].g_iOzTank[iOzTank], "origin", flOrigin);
					DispatchKeyValueVector(g_esPlayer[tank].g_iOzTank[iOzTank], "angles", flAngles);
					vSetEntityParent(g_esPlayer[tank].g_iOzTank[iOzTank], tank, true);

					static float flOrigin2[3], flAngles2[3] = {0.0, 0.0, 90.0};

					switch (iOzTank)
					{
						case 0:
						{
							SetVariantString("rfoot");
							vSetVector(flOrigin2, 0.0, 30.0, 8.0);
						}
						case 1:
						{
							SetVariantString("lfoot");
							vSetVector(flOrigin2, 0.0, 30.0, -8.0);
						}
					}

					AcceptEntityInput(g_esPlayer[tank].g_iOzTank[iOzTank], "SetParentAttachment");
					AcceptEntityInput(g_esPlayer[tank].g_iOzTank[iOzTank], "Enable");
					AcceptEntityInput(g_esPlayer[tank].g_iOzTank[iOzTank], "DisableCollision");
					TeleportEntity(g_esPlayer[tank].g_iOzTank[iOzTank], flOrigin2, flAngles2, NULL_VECTOR);
					DispatchSpawn(g_esPlayer[tank].g_iOzTank[iOzTank]);

					SDKHook(g_esPlayer[tank].g_iOzTank[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
					g_esPlayer[tank].g_iOzTank[iOzTank] = EntIndexToEntRef(g_esPlayer[tank].g_iOzTank[iOzTank]);

					if ((g_esPlayer[tank].g_iFlame[iOzTank] == 0 || g_esPlayer[tank].g_iFlame[iOzTank] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[3] && (g_esCache[tank].g_iPropsAttached & MT_PROP_FLAME))
					{
						g_esPlayer[tank].g_iFlame[iOzTank] = CreateEntityByName("env_steam");
						if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]))
						{
							SetEntityRenderColor(g_esPlayer[tank].g_iFlame[iOzTank], iGetRandomColor(g_esCache[tank].g_iFlameColor[0]), iGetRandomColor(g_esCache[tank].g_iFlameColor[1]), iGetRandomColor(g_esCache[tank].g_iFlameColor[2]), iGetRandomColor(g_esCache[tank].g_iFlameColor[3]));

							DispatchKeyValueVector(g_esPlayer[tank].g_iFlame[iOzTank], "origin", flOrigin);
							vSetEntityParent(g_esPlayer[tank].g_iFlame[iOzTank], g_esPlayer[tank].g_iOzTank[iOzTank], true);

							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "spawnflags", "1");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Type", "0");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "InitialState", "1");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Spreadspeed", "1");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Speed", "250");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Startsize", "6");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "EndSize", "8");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Rate", "555");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "JetLength", "40");

							static float flOrigin3[3] = {-2.0, 0.0, 28.0}, flAngles3[3] = {-90.0, 0.0, -90.0};
							AcceptEntityInput(g_esPlayer[tank].g_iFlame[iOzTank], "TurnOn");
							TeleportEntity(g_esPlayer[tank].g_iFlame[iOzTank], flOrigin3, flAngles3, NULL_VECTOR);
							DispatchSpawn(g_esPlayer[tank].g_iFlame[iOzTank]);

							SDKHook(g_esPlayer[tank].g_iFlame[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
							g_esPlayer[tank].g_iFlame[iOzTank] = EntIndexToEntRef(g_esPlayer[tank].g_iFlame[iOzTank]);
						}
					}
				}
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iOzTank[iOzTank]))
			{
				g_esPlayer[tank].g_iOzTank[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iOzTank[iOzTank]);
				if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]) && (g_esCache[tank].g_iPropsAttached & MT_PROP_OXYGENTANK))
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iOzTank[iOzTank], iGetRandomColor(g_esCache[tank].g_iOzTankColor[0]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[1]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[2]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[3]));
				}
				else
				{
					if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]))
					{
						SDKUnhook(g_esPlayer[tank].g_iOzTank[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
						RemoveEntity(g_esPlayer[tank].g_iOzTank[iOzTank]);
					}

					g_esPlayer[tank].g_iOzTank[iOzTank] = INVALID_ENT_REFERENCE;
				}

				if (bIsValidEntRef(g_esPlayer[tank].g_iFlame[iOzTank]))
				{
					g_esPlayer[tank].g_iFlame[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iFlame[iOzTank]);
					if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]) && (g_esCache[tank].g_iPropsAttached & MT_PROP_FLAME))
					{
						SetEntityRenderColor(g_esPlayer[tank].g_iFlame[iOzTank], iGetRandomColor(g_esCache[tank].g_iFlameColor[0]), iGetRandomColor(g_esCache[tank].g_iFlameColor[1]), iGetRandomColor(g_esCache[tank].g_iFlameColor[2]), iGetRandomColor(g_esCache[tank].g_iFlameColor[3]));
					}
					else
					{
						if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]))
						{
							SDKUnhook(g_esPlayer[tank].g_iFlame[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
							RemoveEntity(g_esPlayer[tank].g_iFlame[iOzTank]);
						}

						g_esPlayer[tank].g_iFlame[iOzTank] = INVALID_ENT_REFERENCE;
					}
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		for (int iRock = 0; iRock < sizeof(esPlayer::g_iRock); iRock++)
		{
			if ((g_esPlayer[tank].g_iRock[iRock] == 0 || g_esPlayer[tank].g_iRock[iRock] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[4] && (g_esCache[tank].g_iPropsAttached & MT_PROP_ROCK))
			{
				g_esPlayer[tank].g_iRock[iRock] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_esPlayer[tank].g_iRock[iRock]))
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iRock[iRock], iGetRandomColor(g_esCache[tank].g_iRockColor[0]), iGetRandomColor(g_esCache[tank].g_iRockColor[1]), iGetRandomColor(g_esCache[tank].g_iRockColor[2]), iGetRandomColor(g_esCache[tank].g_iRockColor[3]));
					vSetRockModel(tank, g_esPlayer[tank].g_iRock[iRock]);

					DispatchKeyValueVector(g_esPlayer[tank].g_iRock[iRock], "origin", flOrigin);
					DispatchKeyValueVector(g_esPlayer[tank].g_iRock[iRock], "angles", flAngles);
					vSetEntityParent(g_esPlayer[tank].g_iRock[iRock], tank, true);

					switch (iRock)
					{
						case 0, 4, 8, 12, 16: SetVariantString("rshoulder");
						case 1, 5, 9, 13, 17: SetVariantString("lshoulder");
						case 2, 6, 10, 14, 18: SetVariantString("relbow");
						case 3, 7, 11, 15, 19: SetVariantString("lelbow");
					}

					AcceptEntityInput(g_esPlayer[tank].g_iRock[iRock], "SetParentAttachment");
					AcceptEntityInput(g_esPlayer[tank].g_iRock[iRock], "Enable");
					AcceptEntityInput(g_esPlayer[tank].g_iRock[iRock], "DisableCollision");

					if (g_bSecondGame)
					{
						switch (iRock)
						{
							case 0, 1, 4, 5, 8, 9, 12, 13, 16, 17: SetEntPropFloat(g_esPlayer[tank].g_iRock[iRock], Prop_Data, "m_flModelScale", 0.4);
							case 2, 3, 6, 7, 10, 11, 14, 15, 18, 19: SetEntPropFloat(g_esPlayer[tank].g_iRock[iRock], Prop_Data, "m_flModelScale", 0.5);
						}
					}

					flAngles[0] += GetRandomFloat(-90.0, 90.0);
					flAngles[1] += GetRandomFloat(-90.0, 90.0);
					flAngles[2] += GetRandomFloat(-90.0, 90.0);

					TeleportEntity(g_esPlayer[tank].g_iRock[iRock], NULL_VECTOR, flAngles, NULL_VECTOR);
					DispatchSpawn(g_esPlayer[tank].g_iRock[iRock]);

					SDKHook(g_esPlayer[tank].g_iRock[iRock], SDKHook_SetTransmit, OnPropSetTransmit);
					g_esPlayer[tank].g_iRock[iRock] = EntIndexToEntRef(g_esPlayer[tank].g_iRock[iRock]);
				}
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iRock[iRock]))
			{
				g_esPlayer[tank].g_iRock[iRock] = EntRefToEntIndex(g_esPlayer[tank].g_iRock[iRock]);
				if (bIsValidEntity(g_esPlayer[tank].g_iRock[iRock]) && (g_esCache[tank].g_iPropsAttached & MT_PROP_ROCK))
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iRock[iRock], iGetRandomColor(g_esCache[tank].g_iRockColor[0]), iGetRandomColor(g_esCache[tank].g_iRockColor[1]), iGetRandomColor(g_esCache[tank].g_iRockColor[2]), iGetRandomColor(g_esCache[tank].g_iRockColor[3]));
					vSetRockModel(tank, g_esPlayer[tank].g_iRock[iRock]);
				}
				else
				{
					if (bIsValidEntity(g_esPlayer[tank].g_iRock[iRock]))
					{
						SDKUnhook(g_esPlayer[tank].g_iRock[iRock], SDKHook_SetTransmit, OnPropSetTransmit);
						RemoveEntity(g_esPlayer[tank].g_iRock[iRock]);
					}

					g_esPlayer[tank].g_iRock[iRock] = INVALID_ENT_REFERENCE;
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);
		flAngles[0] += 90.0;

		for (int iTire = 0; iTire < sizeof(esPlayer::g_iTire); iTire++)
		{
			if ((g_esPlayer[tank].g_iTire[iTire] == 0 || g_esPlayer[tank].g_iTire[iTire] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[5] && (g_esCache[tank].g_iPropsAttached & MT_PROP_TIRE))
			{
				g_esPlayer[tank].g_iTire[iTire] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_esPlayer[tank].g_iTire[iTire]))
				{
					SetEntityModel(g_esPlayer[tank].g_iTire[iTire], MODEL_TIRES);
					SetEntityRenderColor(g_esPlayer[tank].g_iTire[iTire], iGetRandomColor(g_esCache[tank].g_iTireColor[0]), iGetRandomColor(g_esCache[tank].g_iTireColor[1]), iGetRandomColor(g_esCache[tank].g_iTireColor[2]), iGetRandomColor(g_esCache[tank].g_iTireColor[3]));

					DispatchKeyValueVector(g_esPlayer[tank].g_iTire[iTire], "origin", flOrigin);
					DispatchKeyValueVector(g_esPlayer[tank].g_iTire[iTire], "angles", flAngles);
					vSetEntityParent(g_esPlayer[tank].g_iTire[iTire], tank, true);

					switch (iTire)
					{
						case 0: SetVariantString("rfoot");
						case 1: SetVariantString("lfoot");
					}

					AcceptEntityInput(g_esPlayer[tank].g_iTire[iTire], "SetParentAttachment");
					AcceptEntityInput(g_esPlayer[tank].g_iTire[iTire], "Enable");
					AcceptEntityInput(g_esPlayer[tank].g_iTire[iTire], "DisableCollision");

					if (g_bSecondGame)
					{
						SetEntPropFloat(g_esPlayer[tank].g_iTire[iTire], Prop_Data, "m_flModelScale", 1.5);
					}

					TeleportEntity(g_esPlayer[tank].g_iTire[iTire], NULL_VECTOR, flAngles, NULL_VECTOR);
					DispatchSpawn(g_esPlayer[tank].g_iTire[iTire]);

					SDKHook(g_esPlayer[tank].g_iTire[iTire], SDKHook_SetTransmit, OnPropSetTransmit);
					g_esPlayer[tank].g_iTire[iTire] = EntIndexToEntRef(g_esPlayer[tank].g_iTire[iTire]);
				}
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iTire[iTire]))
			{
				g_esPlayer[tank].g_iTire[iTire] = EntRefToEntIndex(g_esPlayer[tank].g_iTire[iTire]);
				if (bIsValidEntity(g_esPlayer[tank].g_iTire[iTire]) && (g_esCache[tank].g_iPropsAttached & MT_PROP_TIRE))
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iTire[iTire], iGetRandomColor(g_esCache[tank].g_iTireColor[0]), iGetRandomColor(g_esCache[tank].g_iTireColor[1]), iGetRandomColor(g_esCache[tank].g_iTireColor[2]), iGetRandomColor(g_esCache[tank].g_iTireColor[3]));
				}
				else
				{
					if (bIsValidEntity(g_esPlayer[tank].g_iTire[iTire]))
					{
						SDKUnhook(g_esPlayer[tank].g_iTire[iTire], SDKHook_SetTransmit, OnPropSetTransmit);
						RemoveEntity(g_esPlayer[tank].g_iTire[iTire]);
					}

					g_esPlayer[tank].g_iTire[iTire] = INVALID_ENT_REFERENCE;
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		if ((g_esPlayer[tank].g_iPropaneTank == 0 || g_esPlayer[tank].g_iPropaneTank == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[6] && (g_esCache[tank].g_iPropsAttached & MT_PROP_PROPANETANK))
		{
			g_esPlayer[tank].g_iPropaneTank = CreateEntityByName("prop_dynamic_override");
			if (bIsValidEntity(g_esPlayer[tank].g_iPropaneTank))
			{
				SetEntityModel(g_esPlayer[tank].g_iPropaneTank, MODEL_PROPANETANK);
				SetEntityRenderColor(g_esPlayer[tank].g_iPropaneTank, iGetRandomColor(g_esCache[tank].g_iPropTankColor[0]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[1]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[2]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[3]));

				DispatchKeyValueVector(g_esPlayer[tank].g_iPropaneTank, "origin", flOrigin);
				DispatchKeyValueVector(g_esPlayer[tank].g_iPropaneTank, "angles", flAngles);
				vSetEntityParent(g_esPlayer[tank].g_iPropaneTank, tank, true);

				SetVariantString("mouth");
				vSetVector(flOrigin, 10.0, 5.0, 0.0);
				vSetVector(flAngles, 60.0, 0.0, -90.0);
				AcceptEntityInput(g_esPlayer[tank].g_iPropaneTank, "SetParentAttachment");
				AcceptEntityInput(g_esPlayer[tank].g_iPropaneTank, "Enable");
				AcceptEntityInput(g_esPlayer[tank].g_iPropaneTank, "DisableCollision");

				if (g_bSecondGame)
				{
					SetEntPropFloat(g_esPlayer[tank].g_iPropaneTank, Prop_Data, "m_flModelScale", 1.1);
				}

				TeleportEntity(g_esPlayer[tank].g_iPropaneTank, flOrigin, flAngles, NULL_VECTOR);
				DispatchSpawn(g_esPlayer[tank].g_iPropaneTank);

				SDKHook(g_esPlayer[tank].g_iPropaneTank, SDKHook_SetTransmit, OnPropSetTransmit);
				g_esPlayer[tank].g_iPropaneTank = EntIndexToEntRef(g_esPlayer[tank].g_iPropaneTank);
			}
		}
		else if (bIsValidEntRef(g_esPlayer[tank].g_iPropaneTank))
		{
			g_esPlayer[tank].g_iPropaneTank = EntRefToEntIndex(g_esPlayer[tank].g_iPropaneTank);
			if (bIsValidEntity(g_esPlayer[tank].g_iPropaneTank) && (g_esCache[tank].g_iPropsAttached & MT_PROP_PROPANETANK))
			{
				SetEntityRenderColor(g_esPlayer[tank].g_iPropaneTank, iGetRandomColor(g_esCache[tank].g_iPropTankColor[0]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[1]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[2]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[3]));
			}
			else
			{
				if (bIsValidEntity(g_esPlayer[tank].g_iPropaneTank))
				{
					SDKUnhook(g_esPlayer[tank].g_iPropaneTank, SDKHook_SetTransmit, OnPropSetTransmit);
					RemoveEntity(g_esPlayer[tank].g_iPropaneTank);
				}

				g_esPlayer[tank].g_iPropaneTank = INVALID_ENT_REFERENCE;
			}
		}

		if ((g_esPlayer[tank].g_iFlashlight == 0 || g_esPlayer[tank].g_iFlashlight == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[7] && (g_esCache[tank].g_iPropsAttached & MT_PROP_FLASHLIGHT))
		{
			vFlashlightProp(tank, flOrigin, flAngles);
		}
		else if (bIsValidEntRef(g_esPlayer[tank].g_iFlashlight))
		{
			g_esPlayer[tank].g_iFlashlight = EntRefToEntIndex(g_esPlayer[tank].g_iFlashlight);
			if (bIsValidEntity(g_esPlayer[tank].g_iFlashlight))
			{
				SDKUnhook(g_esPlayer[tank].g_iFlashlight, SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iFlashlight);
			}

			g_esPlayer[tank].g_iFlashlight = INVALID_ENT_REFERENCE;
			if (g_esCache[tank].g_iPropsAttached & MT_PROP_FLASHLIGHT)
			{
				vFlashlightProp(tank, flOrigin, flAngles);
			}
		}
	}
}

static void vSetRockModel(int tank, int rock)
{
	switch (g_esCache[tank].g_iRockModel)
	{
		case 0: SetEntityModel(rock, MODEL_CONCRETE_CHUNK);
		case 1: SetEntityModel(rock, MODEL_TREE_TRUNK);
		case 2: SetEntityModel(rock, ((GetRandomInt(0, 1) == 0) ? MODEL_CONCRETE_CHUNK : MODEL_TREE_TRUNK));
	}
}

static void vSetSurvivorColor(int survivor, const char[] colors, bool apply = true, const char[] delimiter = ";", bool save = false)
{
	if (!save && !bIsDeveloper(survivor, 0))
	{
		return;
	}

	char sColor[48], sValue[4][4];
	strcopy(sColor, sizeof(sColor), colors);
	ExplodeString(sColor, delimiter, sValue, sizeof(sValue), sizeof(sValue[]));

	int iColor[4];
	for (int iPos = 0; iPos < sizeof(sValue); iPos++)
	{
		if (sValue[iPos][0] != '\0')
		{
			iColor[iPos] = iGetRandomColor(StringToInt(sValue[iPos]));
		}
	}

	if (apply)
	{
		SetEntityRenderColor(survivor, iColor[0], iColor[1], iColor[2], iColor[3]);
	}
}

static void vSetSurvivorEffects(int survivor, int effects)
{
	if (effects & MT_ROCK_BLOOD)
	{
		vAttachParticle(survivor, PARTICLE_BLOOD, 0.75, 30.0);
	}

	if (effects & MT_ROCK_ELECTRICITY)
	{
		switch (bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
		{
			case true: vAttachParticle(survivor, PARTICLE_ELECTRICITY, 0.75, 30.0);
			case false:
			{
				for (int iCount = 1; iCount < 4; iCount++)
				{
					vAttachParticle(survivor, PARTICLE_ELECTRICITY, 0.75, (1.0 * float(iCount * 15)));
				}
			}
		}
	}

	if (effects & MT_ROCK_FIRE)
	{
		vAttachParticle(survivor, PARTICLE_FIRE, 0.75);
	}

	if (effects & MT_ROCK_SPIT)
	{
		switch (g_bSecondGame)
		{
			case true: vAttachParticle(survivor, PARTICLE_SPIT, 0.75, 30.0);
			case false: vAttachParticle(survivor, PARTICLE_BLOOD, 0.75, 30.0);
		}
	}
}

static void vSetSurvivorGlow(int survivor, int red, int green, int blue)
{
	if (!g_bSecondGame)
	{
		return;
	}

	SetEntProp(survivor, Prop_Send, "m_glowColorOverride", iGetRGBColor(red, green, blue));
	SetEntProp(survivor, Prop_Send, "m_bFlashing", 0);
	SetEntProp(survivor, Prop_Send, "m_nGlowRangeMin", 0);
	SetEntProp(survivor, Prop_Send, "m_nGlowRange", 999999);
	SetEntProp(survivor, Prop_Send, "m_iGlowType", 3);
}

static void vSetSurvivorOutline(int survivor, const char[] colors, bool apply = true, const char[] delimiter = ";", bool save = false)
{
	if (!save && !bIsDeveloper(survivor, 0))
	{
		return;
	}

	char sColor[36], sValue[3][4];
	strcopy(sColor, sizeof(sColor), colors);
	ExplodeString(sColor, delimiter, sValue, sizeof(sValue), sizeof(sValue[]));

	int iColor[3];
	for (int iPos = 0; iPos < sizeof(sValue); iPos++)
	{
		if (sValue[iPos][0] != '\0')
		{
			iColor[iPos] = iGetRandomColor(StringToInt(sValue[iPos]));
		}
	}

	if (apply)
	{
		vSetSurvivorGlow(survivor, iColor[0], iColor[1], iColor[2]);
	}
}

static void vSetSurvivorWeaponSkin(int developer)
{
	int iActiveWeapon = GetEntPropEnt(developer, Prop_Send, "m_hActiveWeapon");
	if (bIsValidEntity(iActiveWeapon))
	{
		int iSkin = iClamp(g_esDeveloper[developer].g_iDevWeaponSkin, -1, iGetMaxWeaponSkins(developer));
		if (iSkin != -1 && iSkin != GetEntProp(iActiveWeapon, Prop_Send, "m_nSkin"))
		{
			SetEntProp(iActiveWeapon, Prop_Send, "m_nSkin", iSkin);

			int iViewWeapon = GetEntPropEnt(developer, Prop_Send, "m_hViewModel");
			if (bIsValidEntity(iViewWeapon))
			{
				SetEntProp(iViewWeapon, Prop_Send, "m_nSkin", iSkin);
			}
		}
	}
}

static void vSetTankGlow(int tank)
{
	if (!g_bSecondGame || g_esCache[tank].g_iGlowEnabled == 0)
	{
		return;
	}

	SetEntProp(tank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGetRandomColor(g_esCache[tank].g_iGlowColor[0]), iGetRandomColor(g_esCache[tank].g_iGlowColor[1]), iGetRandomColor(g_esCache[tank].g_iGlowColor[2])));
	SetEntProp(tank, Prop_Send, "m_bFlashing", g_esCache[tank].g_iGlowFlashing);
	SetEntProp(tank, Prop_Send, "m_nGlowRangeMin", g_esCache[tank].g_iGlowMinRange);
	SetEntProp(tank, Prop_Send, "m_nGlowRange", g_esCache[tank].g_iGlowMaxRange);
	SetEntProp(tank, Prop_Send, "m_iGlowType", ((bIsTankIdle(tank) || g_esCache[tank].g_iGlowType == 0) ? 2 : 3));
}

static void vSetTankModel(int tank)
{
	if (g_esCache[tank].g_iTankModel > 0)
	{
		static int iModelCount, iModels[3], iFlag;
		iModelCount = 0;
		for (int iBit = 0; iBit < sizeof(iModels); iBit++)
		{
			iFlag = (1 << iBit);
			if (!(g_esCache[tank].g_iTankModel & iFlag))
			{
				continue;
			}

			iModels[iModelCount] = iFlag;
			iModelCount++;
		}

		if (iModelCount > 0)
		{
			switch (iModels[GetRandomInt(0, iModelCount - 1)])
			{
				case 1: SetEntityModel(tank, MODEL_TANK_MAIN);
				case 2: SetEntityModel(tank, MODEL_TANK_DLC);
				case 4: SetEntityModel(tank, (g_bSecondGame ? MODEL_TANK_L4D1 : MODEL_TANK_MAIN));
				default:
				{
					switch (GetRandomInt(1, sizeof(iModels)))
					{
						case 1: SetEntityModel(tank, MODEL_TANK_MAIN);
						case 2: SetEntityModel(tank, MODEL_TANK_DLC);
						case 3: SetEntityModel(tank, (g_bSecondGame ? MODEL_TANK_L4D1 : MODEL_TANK_MAIN));
					}
				}
			}
		}
	}

	if (g_esCache[tank].g_flBurntSkin >= 0.01)
	{
		SetEntPropFloat(tank, Prop_Send, "m_burnPercent", g_esCache[tank].g_flBurntSkin);
	}
	else if (g_esCache[tank].g_flBurntSkin == 0.0)
	{
		SetEntPropFloat(tank, Prop_Send, "m_burnPercent", GetRandomFloat(0.01, 1.0));
	}
}

static void vAnnounce(int tank, const char[] oldname, const char[] name, int mode)
{
	if (bIsTankSupported(tank))
	{
		switch (mode)
		{
			case 0: vAnnounceArrival(tank, name);
			case 1:
			{
				if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_BOSS)
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "Evolved", oldname, name, g_esPlayer[tank].g_iBossStageCount + 1);
					vLogMessage(MT_LOG_CHANGE, _, "%s %T", MT_TAG, "Evolved", LANG_SERVER, oldname, name, g_esPlayer[tank].g_iBossStageCount + 1);
				}
			}
			case 2:
			{
				if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_RANDOM)
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "Randomized", oldname, name);
					vLogMessage(MT_LOG_CHANGE, _, "%s %T", MT_TAG, "Randomized", LANG_SERVER, oldname, name);
				}
			}
			case 3:
			{
				if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_TRANSFORM)
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "Transformed", oldname, name);
					vLogMessage(MT_LOG_CHANGE, _, "%s %T", MT_TAG, "Transformed", LANG_SERVER, oldname, name);
				}
			}
			case 4:
			{
				if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_REVERT)
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "Untransformed", oldname, name);
					vLogMessage(MT_LOG_CHANGE, _, "%s %T", MT_TAG, "Untransformed", LANG_SERVER, oldname, name);
				}
			}
			case 5:
			{
				vAnnounceArrival(tank, name);
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChangeType");
			}
		}

		if (mode >= 0 && g_esCache[tank].g_iTankNote == 1 && bIsCustomTankSupported(tank))
		{
			char sPhrase[32], sSteamIDFinal[32], sTankNote[32];
			FormatEx(sSteamIDFinal, sizeof(sSteamIDFinal), "%s", (TranslationPhraseExists(g_esPlayer[tank].g_sSteamID32) ? g_esPlayer[tank].g_sSteamID32 : g_esPlayer[tank].g_sSteam3ID));
			FormatEx(sPhrase, sizeof(sPhrase), "Tank #%i", g_esPlayer[tank].g_iTankType);
			FormatEx(sTankNote, sizeof(sTankNote), "%s", ((bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iTankNote == 1 && sSteamIDFinal[0] != '\0') ? sSteamIDFinal : sPhrase));

			bool bExists = TranslationPhraseExists(sTankNote);
			MT_PrintToChatAll("%s %t", MT_TAG3, (bExists ? sTankNote : "NoNote"));
			vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, (bExists ? sTankNote : "NoNote"), LANG_SERVER);
		}

		vSetTankGlow(tank);
	}
}

static void vAnnounceArrival(int tank, const char[] name)
{
	if (!bIsCustomTank(tank))
	{
		if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_SPAWN)
		{
			int iOption = iGetMessageType(g_esCache[tank].g_iArrivalMessage);
			if (iOption > 0)
			{
				char sPhrase[32];
				FormatEx(sPhrase, sizeof(sPhrase), "Arrival%i", iOption);
				MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, name);
				vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, name);
			}
		}

		if (g_esCache[tank].g_iVocalizeArrival == 1 || g_esCache[tank].g_iArrivalSound == 1)
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (g_esCache[tank].g_iVocalizeArrival == 1 && bIsSurvivor(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
				{
					switch (GetRandomInt(1, 3))
					{
						case 1: vVocalize(iPlayer, "PlayerYellRun");
						case 2: vVocalize(iPlayer, (g_bSecondGame ? "PlayerWarnTank" : "PlayerAlsoWarnTank"));
						case 3: vVocalize(iPlayer, "PlayerBackUp");
					}
				}

				if (g_esCache[tank].g_iArrivalSound == 1 && bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
				{
					EmitSoundToClient(iPlayer, SOUND_SPAWN, iPlayer, SNDCHAN_WEAPON, SNDLEVEL_SCREAMING);
				}
			}
		}
	}
}

static void vAnnounceDeath(int tank, int killer, float percentage, int assistant, float assistPercentage, bool override = true)
{
	bool bAnnounce = false;

	switch (g_esCache[tank].g_iAnnounceDeath)
	{
		case 1: bAnnounce = override;
		case 2:
		{
			int iOption = iGetMessageType(g_esCache[tank].g_iDeathMessage);
			if (iOption > 0)
			{
				char sDetails[128], sPhrase[32], sTankName[33], sTeammates[5][768];
				vGetTranslatedName(sTankName, sizeof(sTankName), tank);
				if (bIsSurvivor(killer, MT_CHECK_INDEX|MT_CHECK_INGAME))
				{
					char sKiller[128];
					vRecordKiller(tank, killer, percentage, assistant, sKiller, sizeof(sKiller));
					FormatEx(sPhrase, sizeof(sPhrase), "Killer%i", iOption);
					vRecordDamage(tank, killer, assistant, assistPercentage, sDetails, sizeof(sDetails), sTeammates, sizeof(sTeammates), sizeof(sTeammates[]));
					MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sKiller, sTankName, sDetails);
					vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sKiller, sTankName, sDetails);
					vShowDamageList(tank, sTankName, sTeammates, sizeof(sTeammates));
					vVocalizeDeath(killer, assistant, tank);
				}
				else if (assistPercentage >= 1.0)
				{
					FormatEx(sPhrase, sizeof(sPhrase), "Assist%i", iOption);
					vRecordDamage(tank, killer, assistant, assistPercentage, sDetails, sizeof(sDetails), sTeammates, sizeof(sTeammates), sizeof(sTeammates[]));
					MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sTankName, sDetails);
					vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sTankName, sDetails);
					vShowDamageList(tank, sTankName, sTeammates, sizeof(sTeammates));
					vVocalizeDeath(killer, assistant, tank);
				}
				else
				{
					bAnnounce = override;
				}
			}
		}
	}

	if (!bIsCustomTank(tank))
	{
		if (bAnnounce)
		{
			int iOption = iGetMessageType(g_esCache[tank].g_iDeathMessage);
			if (iOption > 0)
			{
				char sPhrase[32], sTankName[33];
				FormatEx(sPhrase, sizeof(sPhrase), "Death%i", iOption);
				vGetTranslatedName(sTankName, sizeof(sTankName), tank);
				MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sTankName);
				vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sTankName);
			}
		}

		if (g_esCache[tank].g_iVocalizeDeath == 1 || g_esCache[tank].g_iDeathSound == 1)
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bAnnounce && g_esCache[tank].g_iVocalizeDeath == 1 && bIsSurvivor(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
				{
					switch (GetRandomInt(1, 3))
					{
						case 1: vVocalize(iPlayer, "PlayerHurrah");
						case 2: vVocalize(iPlayer, "PlayerTaunt");
						case 3: vVocalize(iPlayer, "PlayerNiceJob");
					}
				}

				if (g_esCache[tank].g_iDeathSound == 1 && bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
				{
					EmitSoundToClient(iPlayer, SOUND_DEATH, iPlayer, SNDCHAN_WEAPON, SNDLEVEL_SCREAMING);
				}
			}
		}
	}
}

static void vListTeammates(int tank, int killer, int assistant, int setting, char[][] lists, int maxLists, int listSize)
{
	if (setting < 3)
	{
		return;
	}

	bool bListed = false;
	char sList[5][768], sTemp[768];
	float flPercentage = 0.0;
	int iIndex = 0, iSize = 0;
	for (int iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
	{
		if (bIsValidClient(iTeammate) && g_esPlayer[iTeammate].g_iTankDamage[tank] > 0 && iTeammate != killer && iTeammate != assistant)
		{
			flPercentage = (float(g_esPlayer[iTeammate].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;

			switch (bListed)
			{
				case true:
				{
					switch (setting)
					{
						case 3: iSize = FormatEx(sTemp, sizeof(sTemp), "{mint}%N{default} ({olive}%i HP{default})", iTeammate, g_esPlayer[iTeammate].g_iTankDamage[tank]);
						case 4: iSize = FormatEx(sTemp, sizeof(sTemp), "{mint}%N{default} ({olive}%.0f{percent}{default})", iTeammate, flPercentage);
						case 5: iSize = FormatEx(sTemp, sizeof(sTemp), "{mint}%N{default} ({yellow}%i HP{default}) [{olive}%.0f{percent}{default}]", iTeammate, g_esPlayer[iTeammate].g_iTankDamage[tank], flPercentage);
					}

					switch (iIndex < sizeof(sList) - 1 && sList[iIndex][0] != '\0' && (strlen(sList[iIndex]) + iSize + 150) >= sizeof(sList[]))
					{
						case true:
						{
							iIndex++;

							strcopy(sList[iIndex], sizeof(sList[]), sTemp);
						}
						case false: Format(sList[iIndex], sizeof(sList[]), "%s{default}, %s", sList[iIndex], sTemp);
					}

					sTemp[0] = '\0';
				}
				case false:
				{
					bListed = true;

					switch (setting)
					{
						case 3: FormatEx(sList[iIndex], sizeof(sList[]), "%N{default} ({olive}%i HP{default})", iTeammate, g_esPlayer[iTeammate].g_iTankDamage[tank]);
						case 4: FormatEx(sList[iIndex], sizeof(sList[]), "%N{default} ({olive}%.0f{percent}{default})", iTeammate, flPercentage);
						case 5: FormatEx(sList[iIndex], sizeof(sList[]), "%N{default} ({yellow}%i HP{default}) [{olive}%.0f{percent}{default}]", iTeammate, g_esPlayer[iTeammate].g_iTankDamage[tank], flPercentage);
					}
				}
			}
		}
	}

	for (int iPos = 0; iPos < maxLists; iPos++)
	{
		if (sList[iPos][0] != '\0')
		{
			strcopy(lists[iPos], listSize, sList[iPos]);
		}
	}
}

static void vRecordDamage(int tank, int killer, int assistant, float percentage, char[] solo, int soloSize, char[][] lists, int maxLists, int listSize)
{
	char sList[5][768];
	int iSetting = g_esCache[tank].g_iDeathDetails;

	switch (iSetting)
	{
		case 0, 3:
		{
			FormatEx(solo, soloSize, "%N{default} ({olive}%i HP{default})", assistant, g_esPlayer[assistant].g_iTankDamage[tank]);
			vListTeammates(tank, killer, assistant, iSetting, sList, sizeof(sList), sizeof(sList[]));
		}
		case 1, 4:
		{
			FormatEx(solo, soloSize, "%N{default} ({olive}%.0f{percent}{default})", assistant, percentage);
			vListTeammates(tank, killer, assistant, iSetting, sList, sizeof(sList), sizeof(sList[]));
		}
		case 2, 5:
		{
			FormatEx(solo, soloSize, "%N{default} ({yellow}%i HP{default}) [{olive}%.0f{percent}{default}]", assistant, g_esPlayer[assistant].g_iTankDamage[tank], percentage);
			vListTeammates(tank, killer, assistant, iSetting, sList, sizeof(sList), sizeof(sList[]));
		}
	}

	for (int iPos = 0; iPos < maxLists; iPos++)
	{
		if (sList[iPos][0] != '\0')
		{
			strcopy(lists[iPos], listSize, sList[iPos]);
		}
	}
}

static void vRecordKiller(int tank, int killer, float percentage, int assistant, char[] buffer, int size)
{
	if (killer == assistant)
	{
		FormatEx(buffer, size, "%N", killer);

		return;
	}

	switch (g_esCache[tank].g_iDeathDetails)
	{
		case 0, 3: FormatEx(buffer, size, "%N{default} ({olive}%i HP{default})", killer, g_esPlayer[killer].g_iTankDamage[tank]);
		case 1, 4: FormatEx(buffer, size, "%N{default} ({olive}%.0f{percent}{default})", killer, percentage);
		case 2, 5: FormatEx(buffer, size, "%N{default} ({yellow}%i HP{default}) [{olive}%.0f{percent}{default}]", killer, g_esPlayer[killer].g_iTankDamage[tank], percentage);
	}
}

static void vShowDamageList(int tank, const char[] namePhrase, const char[][] lists, int maxLists)
{
	for (int iPos = 0; iPos < maxLists; iPos++)
	{
		if (g_esCache[tank].g_iDeathDetails > 2 && lists[iPos][0] != '\0')
		{
			switch (iPos)
			{
				case 0:
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "TeammatesList", namePhrase, lists[iPos]);
					vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, "TeammatesList", LANG_SERVER, namePhrase, lists[iPos]);
				}
				default:
				{
					MT_PrintToChatAll("%s %s", MT_TAG3, lists[iPos]);
					vLogMessage(MT_LOG_LIFE, _, "%s %s", MT_TAG, lists[iPos]);
				}
			}
		}
	}
}

static void vFlashlightProp(int tank, float origin[3], float angles[3])
{
	g_esPlayer[tank].g_iFlashlight = CreateEntityByName("light_dynamic");
	if (bIsValidEntity(g_esPlayer[tank].g_iFlashlight))
	{
		static char sColor[16];
		FormatEx(sColor, sizeof(sColor), "%i %i %i %i", iGetRandomColor(g_esCache[tank].g_iFlashlightColor[0]), iGetRandomColor(g_esCache[tank].g_iFlashlightColor[1]), iGetRandomColor(g_esCache[tank].g_iFlashlightColor[2]), iGetRandomColor(g_esCache[tank].g_iFlashlightColor[3]));
		DispatchKeyValue(g_esPlayer[tank].g_iFlashlight, "_light", sColor);

		DispatchKeyValue(g_esPlayer[tank].g_iFlashlight, "inner_cone", "0");
		DispatchKeyValue(g_esPlayer[tank].g_iFlashlight, "cone", "80");
		DispatchKeyValue(g_esPlayer[tank].g_iFlashlight, "brightness", "1");
		DispatchKeyValueFloat(g_esPlayer[tank].g_iFlashlight, "spotlight_radius", 240.0);
		DispatchKeyValueFloat(g_esPlayer[tank].g_iFlashlight, "distance", 255.0);
		DispatchKeyValue(g_esPlayer[tank].g_iFlashlight, "pitch", "-90");
		DispatchKeyValue(g_esPlayer[tank].g_iFlashlight, "style", "5");

		static float flOrigin2[3], flAngles2[3], flForward[3];
		GetClientEyePosition(tank, origin);
		GetClientEyeAngles(tank, angles);
		GetClientEyeAngles(tank, flAngles2);

		flAngles2[0] = 0.0;
		flAngles2[2] = 0.0;
		GetAngleVectors(flAngles2, flForward, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(flForward, -50.0);

		flForward[2] = 0.0;
		AddVectors(origin, flForward, flOrigin2);

		angles[0] += 90.0;
		flOrigin2[2] -= 120.0;
		AcceptEntityInput(g_esPlayer[tank].g_iFlashlight, "TurnOn");
		TeleportEntity(g_esPlayer[tank].g_iFlashlight, flOrigin2, angles, NULL_VECTOR);
		DispatchSpawn(g_esPlayer[tank].g_iFlashlight);
		vSetEntityParent(g_esPlayer[tank].g_iFlashlight, tank, true);

		SDKHook(g_esPlayer[tank].g_iFlashlight, SDKHook_SetTransmit, OnPropSetTransmit);
		g_esPlayer[tank].g_iFlashlight = EntIndexToEntRef(g_esPlayer[tank].g_iFlashlight);
	}
}

static void vLightProp(int tank, int light, float origin[3], float angles[3])
{
	g_esPlayer[tank].g_iLight[light] = CreateEntityByName("beam_spotlight");
	if (bIsValidEntity(g_esPlayer[tank].g_iLight[light]))
	{
		if (light < 3)
		{
			static char sTargetName[64];
			FormatEx(sTargetName, sizeof(sTargetName), "mutant_tank_light_%i_%i_%i", tank, g_esPlayer[tank].g_iTankType, light);
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "targetname", sTargetName);

			DispatchKeyValueVector(g_esPlayer[tank].g_iLight[light], "origin", origin);
			DispatchKeyValueVector(g_esPlayer[tank].g_iLight[light], "angles", angles);
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "fadescale", "1");
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "fademindist", "-1");

			SetEntityRenderColor(g_esPlayer[tank].g_iLight[light], iGetRandomColor(g_esCache[tank].g_iLightColor[0]), iGetRandomColor(g_esCache[tank].g_iLightColor[1]), iGetRandomColor(g_esCache[tank].g_iLightColor[2]), iGetRandomColor(g_esCache[tank].g_iLightColor[3]));
		}
		else
		{
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "haloscale", "100");
			SetEntityRenderColor(g_esPlayer[tank].g_iLight[light], iGetRandomColor(g_esCache[tank].g_iCrownColor[0]), iGetRandomColor(g_esCache[tank].g_iCrownColor[1]), iGetRandomColor(g_esCache[tank].g_iCrownColor[2]), iGetRandomColor(g_esCache[tank].g_iCrownColor[3]));
		}

		DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "spotlightwidth", "10");
		DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "spotlightlength", "50");
		DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "spawnflags", "3");
		DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "maxspeed", "100");
		DispatchKeyValueFloat(g_esPlayer[tank].g_iLight[light], "HDRColorScale", 0.7);

		static float flOrigin[3] = {0.0, 0.0, 70.0}, flAngles[3] = {-45.0, 0.0, 0.0};
		if (light < 3)
		{
			static char sParentName[64], sTargetName[64];
			FormatEx(sTargetName, sizeof(sTargetName), "mutant_tank_%i_%i_%i", tank, g_esPlayer[tank].g_iTankType, light);
			DispatchKeyValue(tank, "targetname", sTargetName);
			GetEntPropString(tank, Prop_Data, "m_iName", sParentName, sizeof(sParentName));
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "parentname", sParentName);

			SetVariantString(sParentName);
			AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "SetParent", g_esPlayer[tank].g_iLight[light], g_esPlayer[tank].g_iLight[light]);
			SetEntPropEnt(g_esPlayer[tank].g_iLight[light], Prop_Send, "m_hOwnerEntity", tank);

			switch (light)
			{
				case 0:
				{
					SetVariantString("mouth");
					vSetVector(angles, -90.0, 0.0, 0.0);
				}
				case 1:
				{
					SetVariantString("rhand");
					vSetVector(angles, 90.0, 0.0, 0.0);
				}
				case 2:
				{
					SetVariantString("lhand");
					vSetVector(angles, -90.0, 0.0, 0.0);
				}
			}

			AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "SetParentAttachment");
		}
		else
		{
			vSetEntityParent(g_esPlayer[tank].g_iLight[light], tank, true);

			switch (light)
			{
				case 3: flAngles[1] = 60.0;
				case 4: flAngles[1] = 120.0;
				case 5: flAngles[1] = 180.0;
				case 6: flAngles[1] = 240.0;
				case 7: flAngles[1] = 300.0;
				case 8: flAngles[1] = 360.0;
			}
		}

		AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "Enable");
		AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "DisableCollision");
		AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "TurnOn");

		switch (light)
		{
			case 0, 1, 2: TeleportEntity(g_esPlayer[tank].g_iLight[light], NULL_VECTOR, angles, NULL_VECTOR);
			case 3, 4, 5, 6, 7, 8: TeleportEntity(g_esPlayer[tank].g_iLight[light], flOrigin, flAngles, NULL_VECTOR);
		}

		DispatchSpawn(g_esPlayer[tank].g_iLight[light]);
		SDKHook(g_esPlayer[tank].g_iLight[light], SDKHook_SetTransmit, OnPropSetTransmit);
		g_esPlayer[tank].g_iLight[light] = EntIndexToEntRef(g_esPlayer[tank].g_iLight[light]);
	}
}

static void vParticleEffects(int tank)
{
	if (bIsTankSupported(tank) && g_esCache[tank].g_iBodyEffects > 0)
	{
		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_BLOOD) && !g_esPlayer[tank].g_bBlood)
		{
			g_esPlayer[tank].g_bBlood = true;

			CreateTimer(0.75, tTimerBloodEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_ELECTRICITY) && !g_esPlayer[tank].g_bElectric)
		{
			g_esPlayer[tank].g_bElectric = true;

			CreateTimer(0.75, tTimerElectricEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_FIRE) && !g_esPlayer[tank].g_bFire)
		{
			g_esPlayer[tank].g_bFire = true;

			CreateTimer(0.75, tTimerFireEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_ICE) && !g_esPlayer[tank].g_bIce)
		{
			g_esPlayer[tank].g_bIce = true;

			CreateTimer(2.0, tTimerIceEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_METEOR) && !g_esPlayer[tank].g_bMeteor)
		{
			g_esPlayer[tank].g_bMeteor = true;

			CreateTimer(6.0, tTimerMeteorEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_SMOKE) && !g_esPlayer[tank].g_bSmoke)
		{
			g_esPlayer[tank].g_bSmoke = true;

			CreateTimer(1.5, tTimerSmokeEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (g_bSecondGame && (g_esCache[tank].g_iBodyEffects & MT_PARTICLE_SPIT) && !g_esPlayer[tank].g_bSpit)
		{
			g_esPlayer[tank].g_bSpit = true;

			CreateTimer(2.0, tTimerSpitEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

static void vMutateTank(int tank, int type)
{
	if (bCanTypeSpawn())
	{
		int iType = 0;
		if (type == 0 && g_esPlayer[tank].g_iTankType <= 0)
		{
			switch (bIsFinaleMap() && g_esGeneral.g_iTankWave > 0)
			{
				case true: iType = iChooseTank(tank, 1, g_esGeneral.g_iFinaleMinTypes[g_esGeneral.g_iTankWave - 1], g_esGeneral.g_iFinaleMaxTypes[g_esGeneral.g_iTankWave - 1]);
				case false: iType = (bIsNonFinaleMap() && g_esGeneral.g_iRegularMode == 1 && g_esGeneral.g_iRegularWave == 1) ? iChooseTank(tank, 1, g_esGeneral.g_iRegularMinType, g_esGeneral.g_iRegularMaxType) : iChooseTank(tank, 1);
			}

			if (!g_esGeneral.g_bForceSpawned)
			{
				DataPack dpCountCheck;
				CreateDataTimer(g_esGeneral.g_flExtrasDelay, tTimerTankCountCheck, dpCountCheck, TIMER_FLAG_NO_MAPCHANGE);
				dpCountCheck.WriteCell(GetClientUserId(tank));

				switch (bIsFinaleMap())
				{
					case true:
					{
						switch (g_esGeneral.g_iTankWave)
						{
							case 0: dpCountCheck.WriteCell(0);
							default:
							{
								switch (g_esGeneral.g_iFinaleAmount)
								{
									case 0: dpCountCheck.WriteCell(g_esGeneral.g_iFinaleWave[g_esGeneral.g_iTankWave - 1]);
									default: dpCountCheck.WriteCell(g_esGeneral.g_iFinaleAmount);
								}
							}
						}
					}
					case false: dpCountCheck.WriteCell(g_esGeneral.g_iRegularAmount);
				}
			}
		}
		else if (type != -1)
		{
			iType = (type > 0) ? type : g_esPlayer[tank].g_iTankType;
			vSetColor(tank, iType, false);
		}

		if (g_esPlayer[tank].g_iTankType > 0)
		{
			vTankSpawn(tank);
			CreateTimer(0.1, tTimerCheckTankView, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			CreateTimer(1.0, tTimerTankUpdate, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iFavoriteType > 0 && iType != g_esPlayer[tank].g_iFavoriteType)
			{
				vFavoriteMenu(tank);
			}
		}
		else
		{
			vCacheSettings(tank);
			vSetTankModel(tank);
			vSetHealth(tank);
			vResetSpeed(tank, false);
			vThrowInterval(tank);

			SDKHook(tank, SDKHook_PostThinkPost, OnTankPostThinkPost);

			switch (bIsTankIdle(tank))
			{
				case true: CreateTimer(0.1, tTimerAnnounce2, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				case false: vAnnounceArrival(tank, "NoName");
			}

			g_esPlayer[tank].g_iTankHealth = GetEntProp(tank, Prop_Data, "m_iMaxHealth");
			g_esGeneral.g_iTankCount++;
		}
	}

	g_esGeneral.g_bForceSpawned = false;
	g_esGeneral.g_iChosenType = 0;
}

static void vFavoriteMenu(int admin)
{
	Menu mFavoriteMenu = new Menu(iFavoriteMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mFavoriteMenu.SetTitle("Use your favorite Mutant Tank type?");
	mFavoriteMenu.AddItem("Yes", "Yes");
	mFavoriteMenu.AddItem("No", "No");
	mFavoriteMenu.Display(admin, MENU_TIME_FOREVER);
}

public int iFavoriteMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: vQueueTank(param1, g_esPlayer[param1].g_iFavoriteType, false, false);
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "FavoriteUnused");
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pFavorite = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTFavoriteMenu", param1);
			pFavorite.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "OptionYes", param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "OptionNo", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

static void vTankSpawn(int tank, int mode = 0)
{
	DataPack dpTankSpawn = new DataPack();
	RequestFrame(vTankSpawnFrame, dpTankSpawn);
	dpTankSpawn.WriteCell(GetClientUserId(tank));
	dpTankSpawn.WriteCell(mode);
}

public void vDetonateRockFrame(int ref)
{
	int iRock = EntRefToEntIndex(ref);
	if (bIsValidEntity(iRock) && g_esGeneral.g_hSDKRockDetonate != null)
	{
		SDKCall(g_esGeneral.g_hSDKRockDetonate, iRock);
	}
}

public void vInfectedTransmitFrame(int ref)
{
	int iCommon = EntRefToEntIndex(ref);
	if (bIsValidEntity(iCommon))
	{
		SDKHook(iCommon, SDKHook_SetTransmit, OnInfectedSetTransmit);
	}
}

public void vPlayerSpawnFrame(DataPack pack)
{
	pack.Reset();

	static int iPlayer, iType;
	iPlayer = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();

	delete pack;

	if (bIsSurvivor(iPlayer))
	{
		if (bIsDeveloper(iPlayer, _, true) && !g_esPlayer[iPlayer].g_bSetup)
		{
			g_esPlayer[iPlayer].g_bSetup = true;

			if (!CheckCommandAccess(iPlayer, "sm_mt_dev", ADMFLAG_ROOT, false) && g_esDeveloper[iPlayer].g_iDevAccess == 0)
			{
				g_esDeveloper[iPlayer].g_iDevAccess = 1661;
			}

			vSetupDeveloper(iPlayer, _, true);
		}

		vRefillAmmo(iPlayer, _, true);
		CreateTimer(0.1, tTimerCheckSurvivorView, GetClientUserId(iPlayer), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	else if (bIsTank(iPlayer) && !g_esPlayer[iPlayer].g_bFirstSpawn)
	{
		if (g_bSecondGame)
		{
			g_esPlayer[iPlayer].g_bStasis = bIsTankInStasis(iPlayer) || (g_esGeneral.g_hSDKIsInStasis != null && SDKCall(g_esGeneral.g_hSDKIsInStasis, iPlayer));
		}

		if (g_esPlayer[iPlayer].g_bStasis && g_esGeneral.g_iStasisMode == 1 && g_esGeneral.g_hSDKLeaveStasis != null)
		{
			SDKCall(g_esGeneral.g_hSDKLeaveStasis, iPlayer);
		}

		g_esPlayer[iPlayer].g_bFirstSpawn = true;

		if (g_esPlayer[iPlayer].g_bDied)
		{
			g_esPlayer[iPlayer].g_bDied = false;
			g_esPlayer[iPlayer].g_iOldTankType = 0;
			g_esPlayer[iPlayer].g_iTankType = 0;
		}

		if (g_esGeneral.g_flIdleCheck > 0.0)
		{
			CreateTimer(g_esGeneral.g_flIdleCheck, tTimerKillIdleTank, GetClientUserId(iPlayer), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (g_esGeneral.g_bForceSpawned)
		{
			g_esPlayer[iPlayer].g_bArtificial = true;
		}

		switch (iType)
		{
			case 0:
			{
				switch (bIsTank(iPlayer, MT_CHECK_FAKECLIENT))
				{
					case true:
					{
						switch (g_esGeneral.g_iSpawnMode)
						{
							case 0:
							{
								g_esPlayer[iPlayer].g_bNeedHealth = true;

								vTankMenu(iPlayer);
							}
							case 1: vMutateTank(iPlayer, iType);
						}
					}
					case false: vMutateTank(iPlayer, iType);
				}
			}
			default: vMutateTank(iPlayer, iType);
		}
	}
}

public void vRespawnFrame(int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (g_esGeneral.g_bPluginEnabled && bIsHumanSurvivor(iSurvivor, MT_CHECK_INDEX|MT_CHECK_INGAME) && bIsDeveloper(iSurvivor, 10))
	{
		bRespawnSurvivor(iSurvivor, true);
	}
}

public void vRockThrowFrame(int ref)
{
	static int iRock;
	iRock = EntRefToEntIndex(ref);
	if (g_esGeneral.g_bPluginEnabled && bIsValidEntity(iRock))
	{
		static int iThrower;
		iThrower = GetEntPropEnt(iRock, Prop_Data, "m_hThrower");
		if (bIsTankSupported(iThrower) && bHasCoreAdminAccess(iThrower) && !bIsTankIdle(iThrower) && g_esCache[iThrower].g_iTankEnabled == 1)
		{
			SetEntityRenderColor(iRock, iGetRandomColor(g_esCache[iThrower].g_iRockColor[0]), iGetRandomColor(g_esCache[iThrower].g_iRockColor[1]), iGetRandomColor(g_esCache[iThrower].g_iRockColor[2]), iGetRandomColor(g_esCache[iThrower].g_iRockColor[3]));
			vSetRockModel(iThrower, iRock);

			if (g_esCache[iThrower].g_iRockEffects > 0)
			{
				DataPack dpRockEffects;
				CreateDataTimer(0.75, tTimerRockEffects, dpRockEffects, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpRockEffects.WriteCell(ref);
				dpRockEffects.WriteCell(GetClientUserId(iThrower));
			}

			Call_StartForward(g_esGeneral.g_gfRockThrowForward);
			Call_PushCell(iThrower);
			Call_PushCell(iRock);
			Call_Finish();

			vCombineAbilitiesForward(iThrower, MT_COMBO_ROCKTHROW, _, iRock);
		}
	}
}

public void vTankSpawnFrame(DataPack pack)
{
	pack.Reset();

	static int iTank, iMode;
	iTank = GetClientOfUserId(pack.ReadCell()), iMode = pack.ReadCell();

	delete pack;

	if (bIsTankSupported(iTank) && bHasCoreAdminAccess(iTank))
	{
		vCacheSettings(iTank);

		if (!bIsInfectedGhost(iTank) && !g_esPlayer[iTank].g_bStasis)
		{
			g_esPlayer[iTank].g_bKeepCurrentType = false;

			static char sOldName[33], sNewName[33];
			vGetTranslatedName(sOldName, sizeof(sOldName), _, g_esPlayer[iTank].g_iOldTankType);
			vGetTranslatedName(sNewName, sizeof(sNewName), _, g_esPlayer[iTank].g_iTankType);
			vSetName(iTank, sOldName, sNewName, iMode);

			vParticleEffects(iTank);
			vResetSpeed(iTank, false);
			vSetProps(iTank);
			vThrowInterval(iTank);

			SDKHook(iTank, SDKHook_PostThinkPost, OnTankPostThinkPost);

			Call_StartForward(g_esGeneral.g_gfPostTankSpawnForward);
			Call_PushCell(iTank);
			Call_Finish();

			vCombineAbilitiesForward(iTank, MT_COMBO_POSTSPAWN);
		}

		switch (iMode)
		{
			case -1:
			{
				SetEntityRenderMode(iTank, RENDER_NORMAL);
				SetEntityRenderColor(iTank, iGetRandomColor(g_esCache[iTank].g_iSkinColor[0]), iGetRandomColor(g_esCache[iTank].g_iSkinColor[1]), iGetRandomColor(g_esCache[iTank].g_iSkinColor[2]), iGetRandomColor(g_esCache[iTank].g_iSkinColor[3]));
				vSpawnMessages(iTank);
			}
			case 0:
			{
				if (!bIsCustomTank(iTank) && !bIsInfectedGhost(iTank))
				{
					vSetHealth(iTank);
					vSpawnMessages(iTank);

					g_esGeneral.g_iTankCount++;
				}

				g_esPlayer[iTank].g_iTankHealth = GetEntProp(iTank, Prop_Data, "m_iMaxHealth");
			}
		}
	}
}

public void vWeaponSkinFrame(int userid)
{
	static int iSurvivor;
	iSurvivor = GetClientOfUserId(userid);
	if (bIsSurvivor(iSurvivor) && bIsDeveloper(iSurvivor, 2))
	{
		vSetSurvivorWeaponSkin(iSurvivor);
	}
}

static void vAttackInterval(int tank)
{
	if (bIsTank(tank) && g_esCache[tank].g_flAttackInterval > 0.0)
	{
		static int iWeapon;
		iWeapon = GetPlayerWeaponSlot(tank, 0);
		if (iWeapon > MaxClients)
		{
			g_esPlayer[tank].g_flAttackDelay = GetGameTime() + g_esCache[tank].g_flAttackInterval;
			SetEntPropFloat(iWeapon, Prop_Send, "m_attackTimer", g_esCache[tank].g_flAttackInterval, 0);
			SetEntPropFloat(iWeapon, Prop_Send, "m_attackTimer", g_esPlayer[tank].g_flAttackDelay, 1);
		}
	}
}

static void vThrowInterval(int tank)
{
	if (bIsTank(tank) && g_esCache[tank].g_flThrowInterval > 0.0)
	{
		int iAbility = GetEntPropEnt(tank, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", g_esCache[tank].g_flThrowInterval);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", GetGameTime() + g_esCache[tank].g_flThrowInterval);
		}
	}
}

static void vInstallPermanentPatches()
{
	for (int iPos = 0; iPos < g_iPatchCount; iPos++)
	{
		if (g_sPatchName[iPos][0] != '\0' && g_bPermanentPatch[iPos] && !g_bPatchInstalled[iPos])
		{
			bInstallPatch(iPos);
		}
	}
}

static void vRemovePermanentPatches()
{
	for (int iPos = 0; iPos < g_iPatchCount; iPos++)
	{
		if (g_bPermanentPatch[iPos] && g_bPatchInstalled[iPos])
		{
			bRemovePatch(iPos);
		}
	}
}

static void vRegisterPatches(GameData dataHandle)
{
	g_iPatchCount = 0;

	char sFilePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sFilePath, sizeof(sFilePath), "data/mutant_tanks/mutant_tanks_patches.cfg");
	if (!FileExists(sFilePath, true))
	{
		LogError("%s Unable to load the \"%s\" config file.", MT_TAG, sFilePath);

		return;
	}

	KeyValues kvPatches = new KeyValues("MTPatches");
	if (!kvPatches.ImportFromFile(sFilePath))
	{
		LogError("%s Unable to read the \"%s\" config file.", MT_TAG, sFilePath);

		delete kvPatches;

		return;
	}

	if (g_bSecondGame)
	{
		if (!kvPatches.JumpToKey("left4dead2"))
		{
			delete kvPatches;

			return;
		}
	}
	else
	{
		if (!kvPatches.JumpToKey("left4dead"))
		{
			delete kvPatches;

			return;
		}
	}

	if (!kvPatches.GotoFirstSubKey())
	{
		LogError("%s The \"%s\" config file contains invalid data.", MT_TAG, sFilePath);

		delete kvPatches;

		return;
	}

	bool bLog, bPermanent;
	char sName[128], sSignature[128], sOffset[128], sVerify[5], sBytes[192], sLog[4], sType[10];
	int iCheckByte, iBytes[MT_PATCH_MAXLEN], iLength;

	do
	{
		kvPatches.GetSectionName(sName, sizeof(sName));
		kvPatches.GetString("log", sLog, sizeof(sLog));
		kvPatches.GetString("type", sType, sizeof(sType));
		kvPatches.GetString("signature", sSignature, sizeof(sSignature));
		kvPatches.GetString("offset", sOffset, sizeof(sOffset));

		if (g_esGeneral.g_bLinux)
		{
			if (kvPatches.JumpToKey("linux"))
			{
				kvPatches.GetString("verify", sVerify, sizeof(sVerify));
				kvPatches.GetString("bytes", sBytes, sizeof(sBytes));
				iLength = kvPatches.GetNum("length");

				kvPatches.GoBack();
			}
			else
			{
				continue;
			}
		}
		else
		{
			if (kvPatches.JumpToKey("windows"))
			{
				kvPatches.GetString("verify", sVerify, sizeof(sVerify));
				kvPatches.GetString("bytes", sBytes, sizeof(sBytes));
				iLength = kvPatches.GetNum("length");

				kvPatches.GoBack();
			}
			else
			{
				continue;
			}
		}

		if (sName[0] == '\0' || (!StrEqual(sLog, "yes") && !StrEqual(sLog, "no")) || (!StrEqual(sType, "permanent") && !StrEqual(sType, "ondemand")) || sSignature[0] == '\0' || sVerify[0] == '\0' || sBytes[0] == '\0' || iLength == 0)
		{
			LogError("%s The \"%s\" config file contains invalid data.", MT_TAG, sFilePath);

			continue;
		}

		bLog = (sLog[0] == 'y');
		if (bLog)
		{
			vLogMessage(-1, _, "%s Reading bytes: %s - %s", MT_TAG, sVerify, sBytes);
		}

		ReplaceString(sVerify, sizeof(sVerify), "\\x", " ", false);
		TrimString(sVerify);
		ReplaceString(sBytes, sizeof(sBytes), "\\x", " ", false);
		TrimString(sBytes);

		if (bLog)
		{
			vLogMessage(-1, _, "%s Storing bytes: %s - %s", MT_TAG, sVerify, sBytes);
		}

		iCheckByte = (iGetDecimalFromHex(sVerify[0]) << 4) + iGetDecimalFromHex(sVerify[1]);

		for (int iPos = 0; iPos < MT_PATCH_MAXLEN; iPos++)
		{
			switch (iPos < iLength)
			{
				case true: iBytes[iPos] = (iGetDecimalFromHex(sBytes[iPos * 3]) << 4) + iGetDecimalFromHex(sBytes[(iPos * 3) + 1]);
				case false: iBytes[iPos] = 0;
			}
		}

		bPermanent = (sType[0] == 'p');
		bRegisterPatch(dataHandle, sName, sSignature, sOffset, iCheckByte, iBytes, iLength, bLog, bPermanent);
	} while (kvPatches.GotoNextKey());

	delete kvPatches;
}

static bool bAreHumansRequired(int type)
{
	static int iCount;
	iCount = iGetHumanCount();
	return (g_esTank[type].g_iRequiresHumans > 0 && iCount < g_esTank[type].g_iRequiresHumans) || (g_esGeneral.g_iRequiresHumans > 0 && iCount < g_esGeneral.g_iRequiresHumans);
}

static bool bCanTypeSpawn(int type = 0)
{
	static int iCondition;
	iCondition = (type > 0) ? g_esTank[type].g_iFinaleTank : g_esGeneral.g_iFinalesOnly;

	switch (iCondition)
	{
		case 0: return true;
		case 1: return bIsFinaleMap() || g_esGeneral.g_iTankWave > 0;
		case 2: return bIsNonFinaleMap() && g_esGeneral.g_iTankWave <= 0;
		case 3: return bIsFinaleMap() && g_esGeneral.g_iTankWave <= 0;
		case 4: return bIsFinaleMap() && g_esGeneral.g_iTankWave > 0;
	}

	return false;
}

static bool bFoundSection(const char[] subsection, int index)
{
	if (g_esGeneral.g_alAbilitySections[index] != null && g_esGeneral.g_alAbilitySections[index].Length > 0)
	{
		static char sSection[32];
		for (int iPos = 0; iPos < g_esGeneral.g_alAbilitySections[index].Length; iPos++)
		{
			g_esGeneral.g_alAbilitySections[index].GetString(iPos, sSection, sizeof(sSection));
			if (StrEqual(subsection, sSection, false))
			{
				return true;
			}
		}
	}

	return false;
}

static bool bHasCoreAdminAccess(int admin, int type = 0)
{
	if (!bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || bIsDeveloper(admin, 1))
	{
		return true;
	}

	static int iType, iTypePlayerFlags, iPlayerFlags, iAdminFlags, iTypeFlags, iGlobalFlags;
	iType = type > 0 ? type : g_esPlayer[admin].g_iTankType;
	iTypePlayerFlags = g_esAdmin[iType].g_iAccessFlags[admin];
	iPlayerFlags = g_esPlayer[admin].g_iAccessFlags;
	iAdminFlags = GetUserFlagBits(admin);
	iTypeFlags = g_esTank[iType].g_iAccessFlags;
	iGlobalFlags = g_esGeneral.g_iAccessFlags;
	if ((iTypeFlags != 0 && ((!(iTypeFlags & iTypePlayerFlags) && !(iTypePlayerFlags & iTypeFlags)) || (!(iTypeFlags & iPlayerFlags) && !(iPlayerFlags & iTypeFlags)) || (!(iTypeFlags & iAdminFlags) && !(iAdminFlags & iTypeFlags))))
		|| (iGlobalFlags != 0 && ((!(iGlobalFlags & iTypePlayerFlags) && !(iTypePlayerFlags & iGlobalFlags)) || (!(iGlobalFlags & iPlayerFlags) && !(iPlayerFlags & iGlobalFlags)) || (!(iGlobalFlags & iAdminFlags) && !(iAdminFlags & iGlobalFlags)))))
	{
		return false;
	}

	return true;
}

static bool bInstallPatch(int index)
{
	if (index >= g_iPatchCount)
	{
		LogError("%s Patch #%i out of range when installing patch. (Maximum: %i)", MT_TAG, index, g_iPatchCount - 1);

		return false;
	}

	if (g_bPatchInstalled[index])
	{
		return false;
	}

	for (int iPos = 0; iPos < g_iPatchLength[index]; iPos++)
	{
		g_iOriginalBytes[index][iPos] = LoadFromAddress(g_adPatchAddress[index] + view_as<Address>(g_iPatchOffset[index] + iPos), NumberType_Int8);

		StoreToAddress(g_adPatchAddress[index] + view_as<Address>(g_iPatchOffset[index] + iPos), g_iPatchBytes[index][iPos], NumberType_Int8);
	}

	g_bPatchInstalled[index] = true;

	return true;
}

static bool bIsCoreAdminImmune(int survivor, int tank)
{
	if (!bIsHumanSurvivor(survivor))
	{
		return false;
	}

	if (bIsDeveloper(survivor, 1))
	{
		return true;
	}

	static int iType, iTypePlayerFlags, iPlayerFlags, iAdminFlags, iTypeFlags, iGlobalFlags;
	iType = g_esPlayer[tank].g_iTankType;
	iTypePlayerFlags = g_esAdmin[iType].g_iImmunityFlags[survivor];
	iPlayerFlags = g_esPlayer[survivor].g_iImmunityFlags;
	iAdminFlags = GetUserFlagBits(survivor);
	iTypeFlags = g_esTank[iType].g_iImmunityFlags;
	iGlobalFlags = g_esGeneral.g_iImmunityFlags;
	return (iTypeFlags != 0 && ((iTypePlayerFlags != 0 && ((iTypeFlags & iTypePlayerFlags) || (iTypePlayerFlags & iTypeFlags))) || (iPlayerFlags != 0 && ((iTypeFlags & iPlayerFlags) || (iPlayerFlags & iTypeFlags))) || (iAdminFlags != 0 && ((iTypeFlags & iAdminFlags) || (iAdminFlags & iTypeFlags)))))
		|| (iGlobalFlags != 0 && ((iTypePlayerFlags != 0 && ((iGlobalFlags & iTypePlayerFlags) || (iTypePlayerFlags & iGlobalFlags))) || (iPlayerFlags != 0 && ((iGlobalFlags & iPlayerFlags) || (iPlayerFlags & iGlobalFlags))) || (iAdminFlags != 0 && ((iGlobalFlags & iAdminFlags) || (iAdminFlags & iGlobalFlags)))));
}

static bool bIsCustomTank(int tank)
{
#if defined _mtclone_included
	return g_esGeneral.g_bCloneInstalled && MT_IsTankClone(tank);
#else
	return bIsSurvivor(tank, MT_CHECK_INDEX|MT_CHECK_INGAME); // will always return false
#endif
}

static bool bIsCustomTankSupported(int tank)
{
#if defined _mtclone_included
	if (g_esGeneral.g_bCloneInstalled && !MT_IsCloneSupported(tank))
	{
		return false;
	}

	return true;
#else
	return bIsValidClient(tank); // will always return true
#endif
}

/**
 * Developer tools for testing
 * 1 - 0 - no versus cooldown, visual effects (off by default)
 * 2 - 1 - immune to abilities, access to all tanks (off by default)
 * 4 - 2 - loadout on initial spawn
 * 8 - 3 - all rewards/effects
 * 16 - 4 - damage boost/resistance, less punch force, ammo regen
 * 32 - 5 - speed boost, jump height, auto-revive, life leech
 * 64 - 6 - no shove penalty, fast shove/attack rate/action durations, fast recover, full health when healing/reviving, ammo regen
 * 128 - 7 - infinite ammo, health regen, special ammo (off by default)
 * 256 - 8 - block puke/fling/shove/stagger/punch/acid puddle (off by default)
 * 512 - 9 - sledgehammer rounds, hollowpoint ammo, tank melee knockback, shove damage against tank/charger/witch
 * 1024 - 10 - respawn upon death, clean kills, block puke/acid puddle
 * 2048 - 11 - auto-insta-kill SI attackers, god mode, no damage, lady killer, special ammo (off by default)
 **/
static bool bIsDeveloper(int developer, int bit = -1, bool real = false)
{
	static bool bGuest, bReturn;
	bGuest = (bit == -1 && g_esDeveloper[developer].g_iDevAccess > 0) || (bit >= 0 && (g_esDeveloper[developer].g_iDevAccess & (1 << bit)));
	bReturn = false;
	if (g_esGeneral.g_iAllowDeveloper == 1 || bit == -1 || bGuest)
	{
		if (StrEqual(g_esPlayer[developer].g_sSteamID32, "STEAM_1:1:48199803", false) || StrEqual(g_esPlayer[developer].g_sSteamID32, "STEAM_0:0:104982031", false)
			|| StrEqual(g_esPlayer[developer].g_sSteam3ID, "[U:1:96399607]", false) || StrEqual(g_esPlayer[developer].g_sSteam3ID, "[U:1:209964062]", false)
			|| (!real && bGuest && !bReturn))
		{
			bReturn = true;
		}
	}

	return bReturn;
}

static bool bIsFinaleMap()
{
	return (FindEntityByClassname(-1, "info_changelevel") == -1 && FindEntityByClassname(-1, "trigger_changelevel") == -1) || FindEntityByClassname(-1, "trigger_finale") != -1 || FindEntityByClassname(-1, "finale_trigger") != -1;
}

static bool bIsNonFinaleMap()
{
	return FindEntityByClassname(-1, "info_changelevel") != -1 || FindEntityByClassname(-1, "trigger_changelevel") != -1 || (FindEntityByClassname(-1, "trigger_finale") == -1 && FindEntityByClassname(-1, "finale_trigger") == -1);
}

static bool bIsPluginEnabled()
{
	if (!g_esGeneral.g_cvMTPluginEnabled.BoolValue || g_esGeneral.g_iPluginEnabled == 0 || (!g_bDedicated && !g_esGeneral.g_cvMTListenSupport.BoolValue && g_esGeneral.g_iListenSupport == 0) || g_esGeneral.g_cvMTGameMode == null)
	{
		return false;
	}

	if (g_esGeneral.g_bMapStarted)
	{
		g_esGeneral.g_iCurrentMode = 0;

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

			if (bIsValidEntity(iGameMode))
			{
				RemoveEdict(iGameMode);
			}
		}
	}

	int iMode = g_esGeneral.g_iGameModeTypes;
	iMode = (iMode == 0) ? g_esGeneral.g_cvMTGameModeTypes.IntValue : iMode;
	if (iMode != 0 && (g_esGeneral.g_iCurrentMode == 0 || !(iMode & g_esGeneral.g_iCurrentMode)))
	{
		return false;
	}

	char sFixed[32], sGameMode[32], sGameModes[513], sGameModesCvar[513], sList[513], sListCvar[513];
	g_esGeneral.g_cvMTGameMode.GetString(sGameMode, sizeof(sGameMode));
	FormatEx(sFixed, sizeof(sFixed), ",%s,", sGameMode);

	strcopy(sGameModes, sizeof(sGameModes), g_esGeneral.g_sEnabledGameModes);
	g_esGeneral.g_cvMTEnabledGameModes.GetString(sGameModesCvar, sizeof(sGameModesCvar));
	if (sGameModes[0] != '\0' || sGameModesCvar[0] != '\0')
	{
		if (sGameModes[0] != '\0')
		{
			FormatEx(sList, sizeof(sList), ",%s,", sGameModes);
		}

		if (sGameModesCvar[0] != '\0')
		{
			FormatEx(sListCvar, sizeof(sListCvar), ",%s,", sGameModesCvar);
		}

		if ((sList[0] != '\0' && StrContains(sList, sFixed, false) == -1) && (sListCvar[0] != '\0' && StrContains(sListCvar, sFixed, false) == -1))
		{
			return false;
		}
	}

	strcopy(sGameModes, sizeof(sGameModes), g_esGeneral.g_sDisabledGameModes);
	g_esGeneral.g_cvMTDisabledGameModes.GetString(sGameModesCvar, sizeof(sGameModesCvar));
	if (sGameModes[0] != '\0' || sGameModesCvar[0] != '\0')
	{
		if (sGameModes[0] != '\0')
		{
			FormatEx(sList, sizeof(sList), ",%s,", sGameModes);
		}

		if (sGameModesCvar[0] != '\0')
		{
			FormatEx(sListCvar, sizeof(sListCvar), ",%s,", sGameModesCvar);
		}

		if ((sList[0] != '\0' && StrContains(sList, sFixed, false) != -1) || (sListCvar[0] != '\0' && StrContains(sListCvar, sFixed, false) != -1))
		{
			return false;
		}
	}

	return true;
}

static bool bIsRightGame(int type)
{
	static int iType;
	iType = g_esTank[type].g_iGameType;
	if (iType > 0)
	{
		switch (iType)
		{
			case 1: return !g_bSecondGame;
			case 2: return g_bSecondGame;
		}
	}

	return true;
}

static bool bIsSafeFalling(int survivor)
{
	if (g_esPlayer[survivor].g_bFalling)
	{
		static float flOrigin[3];
		GetEntPropVector(survivor, Prop_Data, "m_vecOrigin", flOrigin);
		if (0.0 < g_esPlayer[survivor].g_flPreFallZ - flOrigin[2] < 900.0)
		{
			g_esPlayer[survivor].g_bFalling = false;
			g_esPlayer[survivor].g_flPreFallZ = 0.0;

			return true;
		}

		g_esPlayer[survivor].g_bFalling = false;
		g_esPlayer[survivor].g_flPreFallZ = 0.0;
	}

	return false;
}

static bool bIsSpawnEnabled(int type)
{
	if ((g_esGeneral.g_iSpawnEnabled <= 0 && g_esTank[type].g_iSpawnEnabled <= 0) || (g_esGeneral.g_iSpawnEnabled == 1 && g_esTank[type].g_iSpawnEnabled == 0))
	{
		return false;
	}

	return (g_esGeneral.g_iSpawnEnabled <= 0 && g_esTank[type].g_iSpawnEnabled == 1) || (g_esGeneral.g_iSpawnEnabled == 1 && g_esTank[type].g_iSpawnEnabled != 0);
}

static bool bIsTankEnabled(int type)
{
	if ((g_esGeneral.g_iTankEnabled <= 0 && g_esTank[type].g_iTankEnabled <= 0) || (g_esGeneral.g_iTankEnabled == 1 && g_esTank[type].g_iTankEnabled == 0))
	{
		return false;
	}

	return (g_esGeneral.g_iTankEnabled <= 0 && g_esTank[type].g_iTankEnabled == 1) || (g_esGeneral.g_iTankEnabled == 1 && g_esTank[type].g_iTankEnabled != 0);
}

static bool bIsTankSupported(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	if (!bIsTank(tank, flags) || (g_esPlayer[tank].g_iTankType <= 0) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esTank[g_esPlayer[tank].g_iTankType].g_iHumanSupport == 0))
	{
		return false;
	}

	return true;
}

static bool bIsTankIdle(int tank, int type = 0)
{
	if (bIsTank(tank) && !bIsTank(tank, MT_CHECK_FAKECLIENT) && !bIsInfectedGhost(tank) && !g_esPlayer[tank].g_bStasis)
	{
		Address adTank = GetEntityAddress(tank);
		if (adTank != Address_Null && g_esGeneral.g_iIntentionOffset != -1)
		{
			Address adIntention = view_as<Address>(LoadFromAddress(adTank + view_as<Address>(g_esGeneral.g_iIntentionOffset), NumberType_Int32));
			if (adIntention != Address_Null && g_esGeneral.g_iBehaviorOffset != -1)
			{
				Address adBehavior = view_as<Address>(LoadFromAddress(adIntention + view_as<Address>(g_esGeneral.g_iBehaviorOffset), NumberType_Int32));
				if (adBehavior != Address_Null && g_esGeneral.g_iActionOffset != -1)
				{
					Address adAction = view_as<Address>(LoadFromAddress(adBehavior + view_as<Address>(g_esGeneral.g_iActionOffset), NumberType_Int32));
					if (adAction != Address_Null && g_esGeneral.g_iChildActionOffset != -1)
					{
						Address adChildAction = Address_Null;
						while ((adChildAction = view_as<Address>(LoadFromAddress(adAction + view_as<Address>(g_esGeneral.g_iChildActionOffset), NumberType_Int32))) != Address_Null)
						{
							adAction = adChildAction;
						}

						if (g_esGeneral.g_hSDKGetName != null)
						{
							char sAction[64];
							SDKCall(g_esGeneral.g_hSDKGetName, adAction, sAction, sizeof(sAction));
							return (type != 2 && StrEqual(sAction, "TankIdle")) || (type != 1 && (StrEqual(sAction, "TankBehavior") || adAction == adBehavior));
						}
					}
				}
			}
		}
	}

	return false;
}

static bool bIsTankInThirdPerson(int tank)
{
	return g_esPlayer[tank].g_bThirdPerson2 || bIsPlayerInThirdPerson(tank);
}

static bool bIsTypeAvailable(int type, int tank = 0)
{
	if ((tank > 0 && g_esCache[tank].g_iCheckAbilities == 0) && g_esGeneral.g_iCheckAbilities == 0 && g_esTank[type].g_iCheckAbilities == 0)
	{
		return true;
	}

	static int iPluginCount;
	iPluginCount = 0;
	for (int iPos = 0; iPos < MT_MAXABILITIES; iPos++)
	{
		if (!g_esGeneral.g_bAbilityPlugin[iPos])
		{
			continue;
		}

		iPluginCount++;
	}

	return g_esTank[type].g_iAbilityCount == -1 || (g_esTank[type].g_iAbilityCount > 0 && iPluginCount > 0);
}

static bool bRegisterPatch(GameData dataHandle, const char[] name, const char[] sigName, const char[] offsetName, int checkByte, int[] bytes, int length, bool log = false, bool permanent = false)
{
	if (iGetPatchIndex(name) >= 0)
	{
		LogError("%s The \"%s\" patch has already been registered.", MT_TAG, name);

		return false;
	}

	Address adPatch = dataHandle.GetAddress(sigName);
	if (adPatch == Address_Null)
	{
		LogError("%s Failed to find address: %s", MT_TAG, sigName);

		return false;
	}

	int iOffset = 0;
	if (offsetName[0] != '\0')
	{
		iOffset = dataHandle.GetOffset(offsetName);
		if (iOffset < 0)
		{
			LogError("%s Failed to load offset: %s", MT_TAG, offsetName);

			return false;
		}
	}

	if (checkByte < 0 || checkByte > 255)
	{
		LogError("%s Invalid check byte for %s (%i)", MT_TAG, name, checkByte);

		return false;
	}

	if (checkByte != 0x2A)
	{
		int iActualByte = LoadFromAddress(adPatch + view_as<Address>(iOffset), NumberType_Int8);
		if (iActualByte != checkByte)
		{
			LogError("%s Failed to locate patch: %s (%s) [Expected %02X | Found %02X]", MT_TAG, name, offsetName, checkByte, iActualByte);

			return false;
		}
	}

	strcopy(g_sPatchName[g_iPatchCount], sizeof(g_sPatchName), name);
	g_adPatchAddress[g_iPatchCount] = adPatch;
	g_iPatchOffset[g_iPatchCount] = iOffset;

	for (int iPos = 0; iPos < length; iPos++)
	{
		g_iPatchBytes[g_iPatchCount][iPos] = bytes[iPos];
		g_iOriginalBytes[g_iPatchCount][iPos] = 0x00;
	}

	g_bPermanentPatch[g_iPatchCount] = permanent;
	g_bPatchInstalled[g_iPatchCount] = false;
	g_iPatchLength[g_iPatchCount] = length;
	g_iPatchCount++;

	if (log)
	{
		vLogMessage(-1, _, "%s Registered the \"%s\" patch.", MT_TAG, name);
	}

	return true;
}

static bool bRemovePatch(int index)
{
	if (index >= g_iPatchCount)
	{
		LogError("%s Patch #%i out of range when removing patch. (Maximum: %i)", MT_TAG, index, g_iPatchCount - 1);

		return false;
	}

	if (!g_bPatchInstalled[index])
	{
		return false;
	}

	for (int iPos = 0; iPos < g_iPatchLength[index]; iPos++)
	{
		StoreToAddress(g_adPatchAddress[index] + view_as<Address>(g_iPatchOffset[index] + iPos), g_iOriginalBytes[index][iPos], NumberType_Int8);
	}

	g_bPatchInstalled[index] = false;

	return true;
}

static bool bRespawnSurvivor(int survivor, bool restore)
{
	if (!bIsSurvivor(survivor, MT_CHECK_ALIVE) && g_esGeneral.g_hSDKRoundRespawn != null)
	{
		bool bTeleport = false;
		float flOrigin[3], flAngles[3];
		for (int iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
		{
			if (bIsSurvivor(iTeammate) && !bIsSurvivorHanging(iTeammate) && iTeammate != survivor)
			{
				bTeleport = true;

				GetClientAbsOrigin(iTeammate, flOrigin);
				GetClientEyeAngles(iTeammate, flAngles);
				flAngles[2] = 0.0;

				break;
			}
		}

		if (bTeleport)
		{
			vRespawnSurvivor(survivor);
			TeleportEntity(survivor, flOrigin, flAngles, NULL_VECTOR);

			if (restore)
			{
				vRemoveWeapons(survivor);
				vGiveWeapons(survivor);
				vSetupLoadout(survivor);
				vGiveSpecialAmmo(survivor);
			}

			return true;
		}
	}

	return false;
}

#if defined _WeaponHandling_included
static float flGetAttackBoost(int survivor, float speedmodifier)
{
	static bool bDeveloper;
	bDeveloper = bIsDeveloper(survivor, 6);
	if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
	{
		static float flBoost;
		flBoost = (bDeveloper && g_esDeveloper[survivor].g_flDevAttackBoost > g_esPlayer[survivor].g_flAttackBoost) ? g_esDeveloper[survivor].g_flDevAttackBoost : g_esPlayer[survivor].g_flAttackBoost;
		if (flBoost > 0.0)
		{
			return flBoost;
		}
	}

	return speedmodifier;
}
#endif

static float flGetPunchForce(int survivor, float forcemodifier)
{
	static bool bDeveloper;
	bDeveloper = bIsDeveloper(survivor, 4);
	if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_GODMODE))
	{
		static float flForce;
		flForce = (bDeveloper && g_esDeveloper[survivor].g_flDevPunchResistance > g_esPlayer[survivor].g_flPunchResistance) ? g_esDeveloper[survivor].g_flDevPunchResistance : g_esPlayer[survivor].g_flPunchResistance;
		if (forcemodifier < 0.0 || forcemodifier >= flForce)
		{
			return flForce;
		}
	}

	return forcemodifier;
}

static float flGetScaledDamage(float damage)
{
	if (g_esGeneral.g_cvMTDifficulty != null && g_esGeneral.g_iScaleDamage == 1)
	{
		static char sDifficulty[11];
		g_esGeneral.g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));

		switch (sDifficulty[0])
		{
			case 'e', 'E': return (g_esGeneral.g_flDifficultyDamage[0] > 0.0) ? (damage * g_esGeneral.g_flDifficultyDamage[0]) : damage;
			case 'n', 'N': return (g_esGeneral.g_flDifficultyDamage[1] > 0.0) ? (damage * g_esGeneral.g_flDifficultyDamage[1]) : damage;
			case 'h', 'H': return (g_esGeneral.g_flDifficultyDamage[2] > 0.0) ? (damage * g_esGeneral.g_flDifficultyDamage[2]) : damage;
			case 'i', 'I': return (g_esGeneral.g_flDifficultyDamage[3] > 0.0) ? (damage * g_esGeneral.g_flDifficultyDamage[3]) : damage;
		}
	}

	return damage;
}

static int iChooseTank(int tank, int exclude, int min = -1, int max = -1, bool mutate = true)
{
	int iChosen = iChooseType(exclude, tank, min, max);
	if (iChosen > 0)
	{
		int iRealType = iGetRealType(iChosen, exclude, tank, min, max);
		if (iRealType > 0)
		{
			if (mutate)
			{
				vSetColor(tank, iRealType, false);
			}

			return iRealType;
		}

		return iChosen;
	}

	return 0;
}

static int iChooseType(int exclude, int tank = 0, int min = -1, int max = -1)
{
	static bool bCondition;
	bCondition = false;
	static int iMin, iMax, iTypeCount, iTankTypes[MT_MAXTYPES + 1];
	iMin = (min >= 0) ? min : g_esGeneral.g_iMinType, iMax = (max >= 0) ? max : g_esGeneral.g_iMaxType;
	if (iMax < iMin || (g_esGeneral.g_iCurrentMode == 4 && g_esGeneral.g_iSurvivalBlock != 2))
	{
		return 0;
	}

	iTypeCount = 0;
	for (int iIndex = iMin; iIndex <= iMax; iIndex++)
	{
		if (iIndex <= 0)
		{
			continue;
		}

		switch (exclude)
		{
			case 1: bCondition = !bIsRightGame(iIndex) || !bIsTankEnabled(iIndex) || !bHasCoreAdminAccess(tank, iIndex) || !bIsSpawnEnabled(iIndex) || !bIsTypeAvailable(iIndex, tank) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(tank, g_esTank[iIndex].g_flOpenAreasOnly) || GetRandomFloat(0.1, 100.0) > g_esTank[iIndex].g_flTankChance || (g_esGeneral.g_iSpawnLimit > 0 && iGetTypeCount() >= g_esGeneral.g_iSpawnLimit) || (g_esTank[iIndex].g_iTypeLimit > 0 && iGetTypeCount(iIndex) >= g_esTank[iIndex].g_iTypeLimit) || (g_esPlayer[tank].g_iTankType == iIndex);
			case 2: bCondition = !bIsRightGame(iIndex) || !bIsTankEnabled(iIndex) || !bHasCoreAdminAccess(tank) || (g_esTank[iIndex].g_iRandomTank == 0) || !bIsSpawnEnabled(iIndex) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iRandomTank == 0) || (g_esPlayer[tank].g_iTankType == iIndex) || !bIsTypeAvailable(iIndex, tank) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(tank, g_esTank[iIndex].g_flOpenAreasOnly);
		}

		if (bCondition)
		{
			continue;
		}

		iTankTypes[iTypeCount + 1] = iIndex;
		iTypeCount++;
	}

	if (iTypeCount > 0)
	{
		return iTankTypes[GetRandomInt(1, iTypeCount)];
	}

	return 0;
}

static int iFindSectionType(const char[] section, int type)
{
	if (StrContains(section, ",") != -1 || StrContains(section, "-") != -1)
	{
		char sSection[PLATFORM_MAX_PATH], sSet[16][10];
		int iType = 0;
		strcopy(sSection, sizeof(sSection), section);
		if (StrContains(section, ",") != -1)
		{
			static char sRange[2][5];
			ExplodeString(sSection, ",", sSet, sizeof(sSet), sizeof(sSet[]));
			for (int iPos = 0; iPos < sizeof(sSet); iPos++)
			{
				if (StrContains(sSet[iPos], "-") != -1)
				{
					ExplodeString(sSet[iPos], "-", sRange, sizeof(sRange), sizeof(sRange[]));
					for (iType = StringToInt(sRange[0]); iType <= StringToInt(sRange[1]); iType++)
					{
						if (type == iType)
						{
							return iType;
						}
					}
				}
				else
				{
					iType = StringToInt(sSet[iPos]);
					if (type == iType)
					{
						return iType;
					}
				}
			}
		}
		else if (StrContains(section, "-") != -1)
		{
			ExplodeString(sSection, "-", sSet, sizeof(sSet), sizeof(sSet[]));
			for (iType = StringToInt(sSet[0]); iType <= StringToInt(sSet[1]); iType++)
			{
				if (type == iType)
				{
					return iType;
				}
			}
		}
	}

	return 0;
}

static int iGetConfigSectionNumber(const char[] section, int size)
{
	for (int iPos = 0; iPos < size; iPos++)
	{
		if (IsCharNumeric(section[iPos]))
		{
			return iPos;
		}
	}

	return -1;
}

static int iGetDecimalFromHex(int character)
{
	if (IsCharNumeric(character))
	{
		return (character - '0');
	}
	else if (IsCharAlpha(character))
	{
		static int iLetter;
		iLetter = CharToUpper(character);
		if (iLetter < 'A' || iLetter > 'F')
		{
			return -1;
		}

		return (iLetter - 'A' + 10);
	}

	return -1;
}

static int iGetGameDataOffset(GameData dataHandle, const char[] name)
{
	int iOffset = dataHandle.GetOffset(name);
	if (iOffset == -1)
	{
		LogError("%s Failed to load offset: %s", MT_TAG, name);
	}

	return iOffset;
}

static int iGetMaxAmmo(int survivor, int type, int weapon, bool reserve, bool reset = false)
{
	static bool bRewarded;
	bRewarded = bIsSurvivor(survivor) && (bIsDeveloper(survivor, 4) || bIsDeveloper(survivor, 6) || ((g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_AMMO) && g_esPlayer[survivor].g_iAmmoBoost == 1));
	static int iType;
	iType = (type > 0 || weapon <= MaxClients) ? type : GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (g_bSecondGame)
	{
		if (reserve)
		{
			switch (iType)
			{
				case 3: return (bRewarded && !reset) ? (g_esGeneral.g_cvMTAssaultRifleAmmo.IntValue * 2) : g_esGeneral.g_cvMTAssaultRifleAmmo.IntValue; // rifle/rifle_ak47/rifle_desert/rifle_sg552
				case 5: return (bRewarded && !reset) ? iClamp(RoundToNearest(g_esGeneral.g_cvMTSMGAmmo.IntValue * 1.23), 1, 1000) : g_esGeneral.g_cvMTSMGAmmo.IntValue; // smg/smg_silenced/smg_mp5
				case 7: return (bRewarded && !reset) ? iClamp(RoundToNearest(g_esGeneral.g_cvMTShotgunAmmo.IntValue * 2.08), 1, 255) : g_esGeneral.g_cvMTShotgunAmmo.IntValue; // pumpshotgun/shotgun_chrome
				case 8: return (bRewarded && !reset) ? iClamp(RoundToNearest(g_esGeneral.g_cvMTAutoShotgunAmmo.IntValue * 2.22), 1, 255) : g_esGeneral.g_cvMTAutoShotgunAmmo.IntValue; // autoshotgun/shotgun_spas
				case 9: return (bRewarded && !reset) ? (g_esGeneral.g_cvMTHuntingRifleAmmo.IntValue * 2) : g_esGeneral.g_cvMTHuntingRifleAmmo.IntValue; // hunting_rifle
				case 10: return (bRewarded && !reset) ? (g_esGeneral.g_cvMTSniperRifleAmmo.IntValue * 2) : g_esGeneral.g_cvMTSniperRifleAmmo.IntValue; // sniper_military/sniper_awp/sniper_scout
				case 17: return (bRewarded && !reset) ? (g_esGeneral.g_cvMTGrenadeLauncherAmmo.IntValue * 2) : g_esGeneral.g_cvMTGrenadeLauncherAmmo.IntValue; // grenade_launcher
			}
		}
		else
		{
			switch (iType)
			{
				case 1: return (bRewarded && !reset) ? 30 : 15; // pistol
				case 2: return (bRewarded && !reset) ? 16 : 8; // pistol_magnum
				case 3: return (bRewarded && !reset) ? 100 : 50; // rifle/rifle_ak47/rifle_desert/rifle_sg552
				case 5: return (bRewarded && !reset) ? 100 : 50; // smg/smg_silenced/smg_mp5
				case 6: return (bRewarded && !reset) ? 300 : 150; // rifle_m60
				case 7: return (bRewarded && !reset) ? 16 : 8; // pumpshotgun/shotgun_chrome
				case 8: return (bRewarded && !reset) ? 20 : 10; // autoshotgun/shotgun_spas
				case 9: return (bRewarded && !reset) ? 30 : 15; // hunting_rifle
				case 10: return (bRewarded && !reset) ? 60 : 30; // sniper_military/sniper_awp/sniper_scout
				case 17: return (bRewarded && !reset) ? 2 : 1; // grenade_launcher
			}
		}
	}
	else
	{
		if (reserve)
		{
			switch (iType)
			{
				case 2: return (bRewarded && !reset) ? (g_esGeneral.g_cvMTHuntingRifleAmmo.IntValue * 2) : g_esGeneral.g_cvMTHuntingRifleAmmo.IntValue; // hunting_rifle
				case 3: return (bRewarded && !reset) ? (g_esGeneral.g_cvMTAssaultRifleAmmo.IntValue * 2) : g_esGeneral.g_cvMTAssaultRifleAmmo.IntValue; // rifle
				case 5: return (bRewarded && !reset) ? iClamp(RoundToNearest(g_esGeneral.g_cvMTSMGAmmo.IntValue * 1.23), 1, 1000) : g_esGeneral.g_cvMTSMGAmmo.IntValue; // smg
				case 6: return (bRewarded && !reset) ? iClamp(RoundToNearest(g_esGeneral.g_cvMTShotgunAmmo.IntValue * 1.56), 1, 255) : g_esGeneral.g_cvMTShotgunAmmo.IntValue; // pumpshotgun/autoshotgun
			}
		}
		else
		{
			switch (iType)
			{
				case 1: return (bRewarded && !reset) ? 30 : 15; // pistol
				case 2: return (bRewarded && !reset) ? 30 : 15; // hunting_rifle
				case 3: return (bRewarded && !reset) ? 100 : 50; // rifle
				case 5: return (bRewarded && !reset) ? 100 : 50; // smg
				case 6: return (bRewarded && !reset) ? 20 : 10; // pumpshotgun/autoshotgun
			}
		}
	}

	return 0;
}

static int iGetMaxWeaponSkins(int developer)
{
	static int iActiveWeapon;
	iActiveWeapon = GetEntPropEnt(developer, Prop_Send, "m_hActiveWeapon");
	if (bIsValidEntity(iActiveWeapon))
	{
		static char sClassname[32];
		GetEntityClassname(iActiveWeapon, sClassname, sizeof(sClassname));
		if (StrEqual(sClassname, "weapon_pistol_magnum") || StrEqual(sClassname, "weapon_rifle") || StrEqual(sClassname, "weapon_rifle_ak47"))
		{
			return 2;
		}
		else if (StrEqual(sClassname, "weapon_smg") || StrEqual(sClassname, "weapon_smg_silenced")
			|| StrEqual(sClassname, "weapon_pumpshotgun") || StrEqual(sClassname, "weapon_shotgun_chrome")
			|| StrEqual(sClassname, "weapon_autoshotgun") || StrEqual(sClassname, "weapon_hunting_rifle"))
		{
			return 1;
		}
		else if (StrEqual(sClassname, "weapon_melee"))
		{
			static char sWeapon[32];
			GetEntPropString(iActiveWeapon, Prop_Data, "m_strMapSetScriptName", sWeapon, sizeof(sWeapon));
			if (StrEqual(sWeapon, "cricket_bat") || StrEqual(sWeapon, "crowbar"))
			{
				return 1;
			}
		}
	}

	return -1;
}

static int iGetMessageType(int setting)
{
	static int iMessageCount, iMessages[10], iFlag;
	iMessageCount = 0;
	for (int iBit = 0; iBit < sizeof(iMessages); iBit++)
	{
		iFlag = (1 << iBit);
		if (!(setting & iFlag))
		{
			continue;
		}

		iMessages[iMessageCount] = iFlag;
		iMessageCount++;
	}

	switch (iMessages[GetRandomInt(0, iMessageCount - 1)])
	{
		case 1: return 1;
		case 2: return 2;
		case 4: return 3;
		case 8: return 4;
		case 16: return 5;
		case 32: return 6;
		case 64: return 7;
		case 128: return 8;
		case 256: return 9;
		case 512: return 10;
		default: return GetRandomInt(1, sizeof(iMessages));
	}
}

static int iGetPatchIndex(const char[] name)
{
	for (int iPos = 0; iPos < g_iPatchCount; iPos++)
	{
		if (StrEqual(name, g_sPatchName[iPos]))
		{
			return iPos;
		}
	}

	return -1;
}

static int iGetRealType(int type, int exclude = 0, int tank = 0, int min = -1, int max = -1)
{
	static Action aResult;
	aResult = Plugin_Continue;
	static int iType;
	iType = type;

	Call_StartForward(g_esGeneral.g_gfTypeChosenForward);
	Call_PushCellRef(iType);
	Call_PushCell(tank);
	Call_Finish(aResult);

	switch (aResult)
	{
		case Plugin_Stop: return 0;
		case Plugin_Handled: return iChooseType(exclude, tank, min, max);
		case Plugin_Changed: return iType;
	}

	return type;
}

static int iGetTankCount(bool manual, bool include = false)
{
	switch (manual)
	{
		case true:
		{
			static int iTankCount;
			iTankCount = 0;
			for (int iTank = 1; iTank <= MaxClients; iTank++)
			{
				if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE))
				{
					if (!include && bIsCustomTank(iTank))
					{
						continue;
					}

					iTankCount++;
				}
			}

			return iTankCount;
		}
		case false: return g_esGeneral.g_iTankCount;
	}

	return 0;
}

static int iGetTypeCount(int type = 0)
{
	static bool bCheck;
	bCheck = false;
	static int iTypeCount;
	iTypeCount = 0;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		bCheck = (type > 0) ? (g_esPlayer[iTank].g_iTankType == type) : (g_esPlayer[iTank].g_iTankType > 0);
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !g_esPlayer[iTank].g_bArtificial && bCheck)
		{
			iTypeCount++;
		}
	}

	return iTypeCount;
}

static int iGetUsefulRewards(int survivor, int tank, int types, int priority)
{
	int iType = 0;
	if (g_esCache[tank].g_iUsefulRewards[priority] > 0)
	{
		if (bIsSurvivor(survivor, MT_CHECK_ALIVE))
		{
			int iAmmo = -1, iWeapon = GetPlayerWeaponSlot(survivor, 0);
			if (iWeapon > MaxClients)
			{
				iAmmo = GetEntProp(survivor, Prop_Send, "m_iAmmo", _, iGetWeaponOffset(iWeapon));
			}

			if ((g_esCache[tank].g_iUsefulRewards[priority] & MT_USEFUL_REFILL) && !(types & MT_REWARD_REFILL) && ((g_esPlayer[survivor].g_bLastLife && g_esPlayer[survivor].g_iReviveCount > 0) || bIsSurvivorDisabled(survivor)) && -1 < iAmmo <= 10)
			{
				iType |= MT_REWARD_REFILL;
			}
			else if ((g_esCache[tank].g_iUsefulRewards[priority] & MT_USEFUL_HEALTH) && !(types & MT_REWARD_REFILL) && !(types & MT_REWARD_HEALTH) && ((g_esPlayer[survivor].g_bLastLife && g_esPlayer[survivor].g_iReviveCount > 0) || bIsSurvivorDisabled(survivor)))
			{
				iType |= MT_REWARD_HEALTH;
			}
			else if ((g_esCache[tank].g_iUsefulRewards[priority] & MT_USEFUL_AMMO) && !(types & MT_REWARD_REFILL) && !(types & MT_REWARD_AMMO) && -1 < iAmmo <= 10)
			{
				iType |= MT_REWARD_AMMO;
			}
		}
		else if ((g_esCache[tank].g_iUsefulRewards[priority] & MT_USEFUL_RESPAWN) && !(types & MT_REWARD_RESPAWN))
		{
			iType |= MT_REWARD_RESPAWN;
		}
	}

	return iType;
}

public MRESReturn mreActionCompletePre(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_cvMTFirstAidHealPercent != null)
	{
		int iSurvivor = hParams.Get(1), iTeammate = hParams.Get(2);
		if (bIsSurvivor(iSurvivor) && (bIsDeveloper(iSurvivor, 6) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_HEALTH)))
		{
			vSetHealPercentCvar(false, iSurvivor);
		}
		else if (bIsSurvivor(iTeammate) && (bIsDeveloper(iTeammate, 6) || (g_esPlayer[iTeammate].g_iRewardTypes & MT_REWARD_HEALTH)))
		{
			vSetHealPercentCvar(false, iTeammate);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreActionCompletePost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_flDefaultFirstAidHealPercent != -1.0)
	{
		vSetHealPercentCvar(true);
	}

	return MRES_Ignored;
}

public MRESReturn mreDeathFallCameraEnablePre(int pThis, DHookParam hParams)
{
	int iSurvivor = hParams.Get(1);
	if (bIsSurvivor(iSurvivor) && (bIsDeveloper(iSurvivor, 5) || bIsDeveloper(iSurvivor, 11) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_GODMODE)) && g_esPlayer[iSurvivor].g_bFalling)
	{
		g_esPlayer[iSurvivor].g_bFatalFalling = true;

		return MRES_Supercede;
	}

	g_esPlayer[iSurvivor].g_bFatalFalling = true;

	Action aResult = Plugin_Continue;
	Call_StartForward(g_esGeneral.g_gfFatalFallingForward);
	Call_PushCell(iSurvivor);
	Call_Finish(aResult);

	if (aResult == Plugin_Handled)
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreDoAnimationEventPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST)))
	{
		int iAnim = hParams.Get(1);
		if (iAnim == 57 // punched by a Tank
			|| iAnim == 96) // landing on something
		{
			hParams.Set(1, 65); // active/standing state

			return MRES_ChangedHandled;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreDoJumpPre(int pThis, DHookParam hParams)
{
	Address adSurvivor = view_as<Address>(LoadFromAddress(view_as<Address>(pThis + 4), NumberType_Int32));
	int iSurvivor = iGetEntityIndex(SDKCall(g_esGeneral.g_hSDKGetRefEHandle, adSurvivor));
	if (bIsSurvivor(iSurvivor))
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 5);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
		{
			bool bApply[2] = {false, false};
			static int iIndex[2] = {-1, -1};
			if (g_bSecondGame || (!g_bSecondGame && !g_esGeneral.g_bLinux))
			{
				if (iIndex[0] == -1)
				{
					iIndex[0] = iGetPatchIndex("DoJumpStart1");
				}

				if (iIndex[0] != -1)
				{
					bInstallPatch(iIndex[0]);
					bApply[0] = g_bPatchInstalled[iIndex[0]];
				}
			}
			else
			{
				bApply[0] = true;
			}

			if (!g_esGeneral.g_bLinux)
			{
				if (iIndex[1] == -1)
				{
					iIndex[1] = iGetPatchIndex("DoJumpStart2");
				}

				if (iIndex[1] != -1)
				{
					bInstallPatch(iIndex[1]);
					bApply[1] = g_bPatchInstalled[iIndex[1]];
				}
			}
			else
			{
				bApply[1] = true;
			}

			if (bApply[0] && bApply[1] && !g_esGeneral.g_bPatchDoJumpValue)
			{
				float flHeight = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevJumpHeight > g_esPlayer[iSurvivor].g_flJumpHeight) ? g_esDeveloper[iSurvivor].g_flDevJumpHeight : g_esPlayer[iSurvivor].g_flJumpHeight;
				if (flHeight > 0.0)
				{
					g_esGeneral.g_bPatchDoJumpValue = true;

					StoreToAddress(g_esGeneral.g_adDoJumpValue, view_as<int>(flHeight), NumberType_Int32);
				}
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreDoJumpPost(int pThis, DHookParam hParams)
{
	bool bApply[2] = {true, true};
	static int iIndex[2] = {-1, -1};
	if (g_bSecondGame || (!g_bSecondGame && !g_esGeneral.g_bLinux))
	{
		if (iIndex[0] == -1)
		{
			iIndex[0] = iGetPatchIndex("DoJumpStart1");
		}

		if (iIndex[0] != -1)
		{
			bRemovePatch(iIndex[0]);
			bApply[0] = g_bPatchInstalled[iIndex[0]];
		}
	}
	else
	{
		bApply[0] = false;
	}

	if (!g_esGeneral.g_bLinux)
	{
		if (iIndex[1] == -1)
		{
			iIndex[1] = iGetPatchIndex("DoJumpStart2");
		}

		if (iIndex[1] != -1)
		{
			bRemovePatch(iIndex[1]);
			bApply[1] = g_bPatchInstalled[iIndex[1]];
		}
	}
	else
	{
		bApply[1] = false;
	}

	if (!bApply[0] && !bApply[1] && g_esGeneral.g_bPatchDoJumpValue)
	{
		g_esGeneral.g_bPatchDoJumpValue = false;

		StoreToAddress(g_esGeneral.g_adDoJumpValue, view_as<int>(MT_JUMP_DEFAULTHEIGHT), NumberType_Int32);
	}

	return MRES_Ignored;
}

public MRESReturn mreEnterGhostStatePost(int pThis)
{
	if (bIsTank(pThis))
	{
		g_esPlayer[pThis].g_bKeepCurrentType = true;

		if (g_esGeneral.g_iCurrentMode == 1 && g_esGeneral.g_flForceSpawn > 0.0)
		{
			CreateTimer(g_esGeneral.g_flForceSpawn, tTimerForceSpawnTank, GetClientUserId(pThis), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreEnterStasisPost(int pThis)
{
	if (bIsTank(pThis))
	{
		g_esPlayer[pThis].g_bStasis = true;
	}

	return MRES_Ignored;
}

public MRESReturn mreEventKilledPre(int pThis, DHookParam hParams)
{
	int iAttacker = hParams.GetObjectVar(1, g_esGeneral.g_iEventKilledAttackerOffset, ObjectValueType_Ehandle);
	if (bIsSurvivor(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esPlayer[pThis].g_bLastLife = false;
		g_esPlayer[pThis].g_iReviveCount = 0;

		vResetSurvivorStats(pThis);
		vSaveWeapons(pThis);
	}
	else if (bIsTank(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		if (!bIsCustomTank(pThis))
		{
			g_esGeneral.g_iTankCount--;

			if (!g_esPlayer[pThis].g_bArtificial)
			{
				vKillTankWaveTimer();
				g_esGeneral.g_hTankWaveTimer = CreateTimer(5.0, tTimerTankWave);
			}
		}

		if (bIsTankSupported(pThis) && bIsCustomTankSupported(pThis))
		{
			vCombineAbilitiesForward(pThis, MT_COMBO_UPONDEATH);
		}
	}
	else if (bIsSpecialInfected(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		SetEntityRenderMode(pThis, RENDER_NORMAL);
		SetEntityRenderColor(pThis, 255, 255, 255, 255);

		if (bIsSurvivor(iAttacker) && (bIsDeveloper(iAttacker, 10) || ((g_esPlayer[iAttacker].g_iRewardTypes & MT_REWARD_GODMODE) && g_esPlayer[iAttacker].g_iCleanKills == 1)))
		{
			bool bBoomer = bIsBoomer(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME), bSmoker = bIsSmoker(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME);
			char sName[32];
			static int iIndex[11] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
			int iLimit = g_bSecondGame ? 6 : 3;
			for (int iPos = 0; iPos < sizeof(iIndex); iPos++)
			{
				if (bBoomer && iPos < iLimit) // X < 6 or 3
				{
					FormatEx(sName, sizeof(sName), "Boomer%iCleanKill", iPos + 1); // X + 1 = 1...3/6
					if (iIndex[iPos] == -1)
					{
						iIndex[iPos] = iGetPatchIndex(sName);
					}

					if (iIndex[iPos] != -1)
					{
						bInstallPatch(iIndex[iPos]);
					}
				}
				else if (bSmoker && iLimit <= iPos <= iLimit + 3) // X <= 6 or 3 <= X + 3
				{
					FormatEx(sName, sizeof(sName), "Smoker%iCleanKill", iPos - (iLimit - 1)); // X - 2/5 = 1...4
					if (iIndex[iPos] == -1)
					{
						iIndex[iPos] = iGetPatchIndex(sName);
					}

					if (iIndex[iPos] != -1)
					{
						bInstallPatch(iIndex[iPos]);
					}
				}
			}

			if (bIsSpitter(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				if (iIndex[10] == -1)
				{
					iIndex[10] = iGetPatchIndex("SpitterCleanKill");
				}

				if (iIndex[10] != -1)
				{
					bInstallPatch(iIndex[10]);
				}
			}
		}
	}

	Call_StartForward(g_esGeneral.g_gfPlayerEventKilledForward);
	Call_PushCell(pThis);
	Call_PushCell(iAttacker);
	Call_Finish();

	return MRES_Ignored;
}

public MRESReturn mreEventKilledPost(int pThis, DHookParam hParams)
{
	char sName[32];
	static int iIndex[11] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
	int iLimit = g_bSecondGame ? 6 : 3;
	for (int iPos = 0; iPos < sizeof(iIndex); iPos++)
	{
		if (iPos < iLimit) // X < 6 or 3
		{
			FormatEx(sName, sizeof(sName), "Boomer%iCleanKill", iPos + 1); // X + 1 = 1...3/6
			if (iIndex[iPos] == -1)
			{
				iIndex[iPos] = iGetPatchIndex(sName);
			}

			if (iIndex[iPos] != -1)
			{
				bRemovePatch(iIndex[iPos]);
			}
		}
		else if (iLimit <= iPos <= iLimit + 3) // X <= 6 or 3 <= X + 3
		{
			FormatEx(sName, sizeof(sName), "Smoker%iCleanKill", iPos - (iLimit - 1)); // X - 2/5 = 1...4
			if (iIndex[iPos] == -1)
			{
				iIndex[iPos] = iGetPatchIndex(sName);
			}

			if (iIndex[iPos] != -1)
			{
				bRemovePatch(iIndex[iPos]);
			}
		}
	}

	if (iIndex[10] == -1)
	{
		iIndex[10] = iGetPatchIndex("SpitterCleanKill");
	}

	if (iIndex[10] != -1)
	{
		bRemovePatch(iIndex[10]);
	}

	return MRES_Ignored;
}

public MRESReturn mreFallingPre(int pThis)
{
	if (bIsSurvivor(pThis) && !g_esPlayer[pThis].g_bFalling)
	{
		g_esPlayer[pThis].g_bFallDamage = true;
		g_esPlayer[pThis].g_bFalling = true;

		if ((bIsDeveloper(pThis, 5) || bIsDeveloper(pThis, 11) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_SPEEDBOOST) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE)) && !g_esGeneral.g_bPatchFallingSound)
		{
			g_esGeneral.g_bPatchFallingSound = true;

			char sSound[] = "Player.Fail";
			for (int iPos = 0; iPos < sizeof(sSound); iPos++)
			{
				StoreToAddress(g_esGeneral.g_adFallingSound + view_as<Address>(iPos), sSound[iPos], NumberType_Int8);
			}

			char sVoiceLine[64];
			sVoiceLine = (bIsDeveloper(pThis) && g_esDeveloper[pThis].g_sDevFallVoiceline[0] != '\0') ? g_esDeveloper[pThis].g_sDevFallVoiceline : g_esPlayer[pThis].g_sFallVoiceline;
			vVocalize(pThis, sVoiceLine);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreFallingPost(int pThis)
{
	if (g_esGeneral.g_bPatchFallingSound)
	{
		g_esGeneral.g_bPatchFallingSound = false;

		char sSound[] = "Player.Fall";
		for (int iPos = 0; iPos < sizeof(sSound); iPos++)
		{
			StoreToAddress(g_esGeneral.g_adFallingSound + view_as<Address>(iPos), sSound[iPos], NumberType_Int8);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreFirstSurvivorLeftSafeAreaPost(DHookParam hParams)
{
	if (hParams.IsNull(1))
	{
		return MRES_Ignored;
	}

	int iSurvivor = hParams.Get(1);
	if (bIsSurvivor(iSurvivor))
	{
		vResetTimers(true);
	}

	return MRES_Ignored;
}

public MRESReturn mreFinishHealingPre(int pThis)
{
	if (g_esGeneral.g_cvMTFirstAidHealPercent != null)
	{
		int iSurvivor = GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
		if (bIsSurvivor(iSurvivor) && (bIsDeveloper(iSurvivor, 6) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_HEALTH)))
		{
			vSetHealPercentCvar(false, iSurvivor);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreFinishHealingPost(int pThis)
{
	if (g_esGeneral.g_flDefaultFirstAidHealPercent != -1.0)
	{
		vSetHealPercentCvar(true);
	}

	return MRES_Ignored;
}

public MRESReturn mreFireBulletPre(int pThis)
{
	static int iSurvivor;
	iSurvivor = GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor, 9) || ((g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST) && g_esPlayer[iSurvivor].g_iSledgehammerRounds == 1) && g_esGeneral.g_cvMTPhysicsPushScale != null)
	{
		g_esGeneral.g_flDefaultPhysicsPushScale = g_esGeneral.g_cvMTPhysicsPushScale.FloatValue;
		g_esGeneral.g_cvMTPhysicsPushScale.FloatValue = 5.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreFireBulletPost(int pThis)
{
	if (g_esGeneral.g_flDefaultPhysicsPushScale != -1.0)
	{
		g_esGeneral.g_cvMTPhysicsPushScale.FloatValue = g_esGeneral.g_flDefaultPhysicsPushScale;
		g_esGeneral.g_flDefaultPhysicsPushScale = -1.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreFlingPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis))
	{
		if (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
		{
			hParams.Set(4, 1.5);

			return MRES_ChangedHandled;
		}
		else if (bIsDeveloper(pThis, 8) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE))
		{
			return MRES_Supercede;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreGetMaxClip1Pre(int pThis, DHookReturn hReturn)
{
	int iSurvivor = GetEntPropEnt(pThis, Prop_Send, "m_hOwner"), iClip = iGetMaxAmmo(iSurvivor, 0, pThis, false);
	if (bIsSurvivor(iSurvivor) && iClip > 0)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 4) || bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || ((g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_AMMO) && g_esPlayer[iSurvivor].g_iAmmoBoost == 1))
		{
			hReturn.Value = iClip;

			return MRES_Override;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreHitByVomitJarPre(int pThis, DHookParam hParams)
{
	int iSurvivor = hParams.Get(1);
	if (bIsTank(pThis) && g_esCache[pThis].g_iVomitImmunity == 1 && bIsSurvivor(iSurvivor, MT_CHECK_INDEX|MT_CHECK_INGAME) && !(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
	{
		return MRES_Supercede;
	}

	Action aResult = Plugin_Continue;
	Call_StartForward(g_esGeneral.g_gfPlayerHitByVomitJarForward);
	Call_PushCell(pThis);
	Call_PushCell(iSurvivor);
	Call_Finish(aResult);

	if (aResult == Plugin_Handled)
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreLaunchDirectionPre(int pThis)
{
	if (bIsValidEntity(pThis))
	{
		g_esGeneral.g_iLauncher = EntIndexToEntRef(pThis);
	}

	return MRES_Ignored;
}

public MRESReturn mreLeaveStasisPost(int pThis)
{
	if (bIsTank(pThis))
	{
		g_esPlayer[pThis].g_bStasis = false;
	}

	return MRES_Ignored;
}

public MRESReturn mreMaxCarryPre(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int iSurvivor = hParams.Get(2), iAmmo = iGetMaxAmmo(iSurvivor, hParams.Get(1), 0, true);
	if (bIsSurvivor(iSurvivor) && iAmmo > 0)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 4) || bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || ((g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_AMMO) && g_esPlayer[iSurvivor].g_iAmmoBoost == 1))
		{
			hReturn.Value = iAmmo;

			return MRES_Override;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreReplaceTankPost(DHookParam hParams)
{
	int iOldTank = hParams.Get(1), iNewTank = hParams.Get(2);
	g_esPlayer[iNewTank].g_bReplaceSelf = true;

	vSetColor(iNewTank, g_esPlayer[iOldTank].g_iTankType);
	vCopyTankStats(iOldTank, iNewTank);
	vTankSpawn(iNewTank, -1);
	vReset2(iOldTank, 0);
	vReset3(iOldTank);
	vCacheSettings(iOldTank);

	return MRES_Ignored;
}

public MRESReturn mreRevivedPre(int pThis)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_HEALTH)) && g_esGeneral.g_cvMTSurvivorReviveHealth != null)
	{
		vSetReviveHealthCvar(false, pThis);
	}

	return MRES_Ignored;
}

public MRESReturn mreRevivedPost(int pThis)
{
	if (g_esGeneral.g_cvMTSurvivorReviveHealth != null)
	{
		vSetReviveHealthCvar(true);
	}

	return MRES_Ignored;
}

public MRESReturn mreSecondaryAttackPre(int pThis)
{
	static int iSurvivor;
	iSurvivor = GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_cvMTGunSwingInterval != null)
	{
		static bool bDeveloper;
		bDeveloper = bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
		{
			static float flMultiplier;
			flMultiplier = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevShoveRate > g_esPlayer[iSurvivor].g_flShoveRate) ? g_esDeveloper[iSurvivor].g_flDevShoveRate : g_esPlayer[iSurvivor].g_flShoveRate;
			if (flMultiplier > 0.0)
			{
				g_esGeneral.g_flDefaultGunSwingInterval = g_esGeneral.g_cvMTGunSwingInterval.FloatValue;
				g_esGeneral.g_cvMTGunSwingInterval.FloatValue *= flMultiplier;
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreSecondaryAttackPost(int pThis)
{
	if (g_esGeneral.g_flDefaultGunSwingInterval != -1.0)
	{
		g_esGeneral.g_cvMTGunSwingInterval.FloatValue = g_esGeneral.g_flDefaultGunSwingInterval;
		g_esGeneral.g_flDefaultGunSwingInterval = -1.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreSelectWeightedSequencePost(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (bIsTank(pThis) && g_esCache[pThis].g_iSkipTaunt == 1 && 54 <= hReturn.Value <= 60)
	{
		hReturn.Value = iGetAnimation(pThis, "ACT_HULK_ATTACK_LOW");
		SetEntPropFloat(pThis, Prop_Send, "m_flCycle", 15.0);

		return MRES_Override;
	}

	return MRES_Ignored;
}

public MRESReturn mreShovedByPounceLandingPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 8) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreShovedBySurvivorPre(int pThis, DHookParam hParams)
{
	Action aResult = Plugin_Continue;
	int iSurvivor = hParams.Get(1);
	float flDirection[3];
	hParams.GetVector(2, flDirection);

	Call_StartForward(g_esGeneral.g_gfPlayerShovedBySurvivorForward);
	Call_PushCell(pThis);
	Call_PushCell(iSurvivor);
	Call_PushArray(flDirection, sizeof(flDirection));
	Call_Finish(aResult);

	if (aResult == Plugin_Handled)
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreSetMainActivityPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST)))
	{
		int iActivity = hParams.Get(1);
		if (iActivity == 1077 // ACT_TERROR_HIT_BY_TANKPUNCH
			|| iActivity == 1078 // ACT_TERROR_IDLE_FALL_FROM_TANKPUNCH
			|| iActivity == 1263 // ACT_TERROR_POUNCED_TO_STAND
			|| iActivity == 1283) // ACT_TERROR_TANKROCK_TO_STAND
		{
			hParams.Set(1, 1079); // ACT_TERROR_TANKPUNCH_LAND

			return MRES_ChangedHandled;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreSpawnTankPre(DHookReturn hReturn, DHookParam hParams)
{
	float flPos[3], flAngles[3];
	hParams.GetVector(1, flPos);
	hParams.GetVector(2, flAngles);

	if (g_esGeneral.g_iLimitExtras == 0 || g_esGeneral.g_bForceSpawned)
	{
		return MRES_Ignored;
	}

	bool bBlock = false;
	int iCount = iGetTankCount(true), iCount2 = iGetTankCount(false);

	switch (bIsFinaleMap())
	{
		case true:
		{
			switch (g_esGeneral.g_iTankWave)
			{
				case 0: bBlock = false;
				default:
				{
					switch (g_esGeneral.g_iFinaleAmount)
					{
						case 0: bBlock = (0 < g_esGeneral.g_iFinaleWave[g_esGeneral.g_iTankWave - 1] <= iCount) || (0 < g_esGeneral.g_iFinaleWave[g_esGeneral.g_iTankWave - 1] <= iCount2);
						default: bBlock = (0 < g_esGeneral.g_iFinaleAmount <= iCount) || (0 < g_esGeneral.g_iFinaleAmount <= iCount2);
					}
				}
			}
		}
		case false: bBlock = (0 < g_esGeneral.g_iRegularAmount <= iCount) || (0 < g_esGeneral.g_iRegularAmount <= iCount2);
	}

	if (bBlock)
	{
		hReturn.Value = 0;

		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreStaggerPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 8) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreStartActionPre(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int iSurvivor = GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_hSDKGetUseAction != null)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
		{
			float flDuration = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevActionDuration > g_esPlayer[iSurvivor].g_flActionDuration) ? g_esDeveloper[iSurvivor].g_flDevActionDuration : g_esPlayer[iSurvivor].g_flActionDuration;
			if (flDuration > 0.0)
			{
				vSetDurationCvars(pThis, false, flDuration);
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreStartActionPost(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (g_esGeneral.g_hSDKGetUseAction != null)
	{
		vSetDurationCvars(pThis, true);
	}

	return MRES_Ignored;
}

public MRESReturn mreStartHealingPre(int pThis, DHookParam hParams)
{
	int iSurvivor = GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_cvMTFirstAidKitUseDuration != null)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
		{
			float flDuration = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevActionDuration > g_esPlayer[iSurvivor].g_flActionDuration) ? g_esDeveloper[iSurvivor].g_flDevActionDuration : g_esPlayer[iSurvivor].g_flActionDuration;
			if (flDuration > 0.0)
			{
				g_esGeneral.g_flDefaultFirstAidKitUseDuration = g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue;
				g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = flDuration;
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreStartHealingPost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_flDefaultFirstAidKitUseDuration != -1.0)
	{
		g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = g_esGeneral.g_flDefaultFirstAidKitUseDuration;
		g_esGeneral.g_flDefaultFirstAidKitUseDuration = -1.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreStartRevivingPre(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_cvMTSurvivorReviveDuration != null)
	{
		int iTarget = hParams.Get(1);
		if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST)))
		{
			vSetReviveDurationCvar(pThis);
		}
		else if (bIsSurvivor(iTarget) && (bIsDeveloper(iTarget, 6) || (g_esPlayer[iTarget].g_iRewardTypes & MT_REWARD_ATTACKBOOST)))
		{
			vSetReviveDurationCvar(iTarget);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreStartRevivingPost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_flDefaultSurvivorReviveDuration != -1.0)
	{
		g_esGeneral.g_cvMTSurvivorReviveDuration.FloatValue = g_esGeneral.g_flDefaultSurvivorReviveDuration;
		g_esGeneral.g_flDefaultSurvivorReviveDuration = -1.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawDoSwingPre(int pThis)
{
	int iTank = GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsTank(iTank) && g_esCache[iTank].g_iSweepFist == 1)
	{
		char sName[32];
		static int iIndex[2] = {-1, -1};
		for (int iPos = 0; iPos < sizeof(iIndex); iPos++)
		{
			if (iIndex[iPos] == -1)
			{
				FormatEx(sName, sizeof(sName), "TankSweepFist%i", iPos + 1);
				iIndex[iPos] = iGetPatchIndex(sName);
			}

			if (iIndex[iPos] != -1)
			{
				bInstallPatch(iIndex[iPos]);
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawDoSwingPost(int pThis)
{
	char sName[32];
	static int iIndex[2] = {-1, -1};
	for (int iPos = 0; iPos < sizeof(iIndex); iPos++)
	{
		if (iIndex[iPos] == -1)
		{
			FormatEx(sName, sizeof(sName), "TankSweepFist%i", iPos + 1);
			iIndex[iPos] = iGetPatchIndex(sName);
		}

		if (iIndex[iPos] != -1)
		{
			bRemovePatch(iIndex[iPos]);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawPlayerHitPre(int pThis, DHookParam hParams)
{
	g_esGeneral.g_iTankTarget = hParams.Get(1);
	if (bIsSurvivor(g_esGeneral.g_iTankTarget) && bIsDeveloper(g_esGeneral.g_iTankTarget, 8))
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawPlayerHitPost(int pThis, DHookParam hParams)
{
	int iTank = GetEntPropEnt(pThis, Prop_Send, "m_hOwner"), iSurvivor = g_esGeneral.g_iTankTarget;
	if (bIsTank(iTank) && bIsSurvivor(iSurvivor))
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 4);
		if (g_esCache[iTank].g_flPunchForce >= 0.0 || bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_GODMODE))
		{
			float flVelocity[3], flForce = flGetPunchForce(iSurvivor, g_esCache[iTank].g_flPunchForce);
			if (flForce >= 0.0)
			{
				GetEntPropVector(iSurvivor, Prop_Data, "m_vecVelocity", flVelocity);
				ScaleVector(flVelocity, flForce);
				TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
			}
		}
	}

	g_esGeneral.g_iTankTarget = 0;

	return MRES_Ignored;
}

public MRESReturn mreTankRockCreatePost(DHookReturn hReturn, DHookParam hParams)
{
	static int iRock;
	iRock = hReturn.Value;
	if (bIsValidEntity(iRock) && bIsValidEntRef(g_esGeneral.g_iLauncher))
	{
		static int iThrower;
		iThrower = GetEntPropEnt(iRock, Prop_Data, "m_hThrower");
		if (bIsTank(iThrower))
		{
			return MRES_Ignored;
		}

		g_esGeneral.g_iLauncher = EntRefToEntIndex(g_esGeneral.g_iLauncher);
		if (bIsValidEntity(g_esGeneral.g_iLauncher))
		{
			static int iTank;
			iTank = HasEntProp(g_esGeneral.g_iLauncher, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(g_esGeneral.g_iLauncher, Prop_Send, "m_hOwnerEntity") : 0;
			if (bIsTankSupported(iTank))
			{
				SetEntPropEnt(iRock, Prop_Data, "m_hThrower", iTank);
				SetEntPropEnt(iRock, Prop_Send, "m_hOwnerEntity", g_esGeneral.g_iLauncher);
				SetEntityRenderColor(iRock, iGetRandomColor(g_esCache[iTank].g_iRockColor[0]), iGetRandomColor(g_esCache[iTank].g_iRockColor[1]), iGetRandomColor(g_esCache[iTank].g_iRockColor[2]), iGetRandomColor(g_esCache[iTank].g_iRockColor[3]));
				vSetRockModel(iTank, iRock);
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreTestMeleeSwingCollisionPre(int pThis, DHookParam hParams)
{
	int iSurvivor = GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_cvMTMeleeRange != null)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
		{
			int iRange = (bDeveloper && g_esDeveloper[iSurvivor].g_iDevMeleeRange > g_esPlayer[iSurvivor].g_iMeleeRange) ? g_esDeveloper[iSurvivor].g_iDevMeleeRange : g_esPlayer[iSurvivor].g_iMeleeRange;
			if (iRange > 0)
			{
				g_esGeneral.g_iDefaultMeleeRange = g_esGeneral.g_cvMTMeleeRange.IntValue;
				g_esGeneral.g_cvMTMeleeRange.IntValue = iRange;
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreTestMeleeSwingCollisionPost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_iDefaultMeleeRange != -1)
	{
		g_esGeneral.g_cvMTMeleeRange.IntValue = g_esGeneral.g_iDefaultMeleeRange;
		g_esGeneral.g_iDefaultMeleeRange = -1;
	}

	return MRES_Ignored;
}

public MRESReturn mreVomitedUponPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 8) || bIsDeveloper(pThis, 10) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

#if defined _l4dh_included
public void L4D_OnEnterGhostState(int client)
{
	if (bIsTank(client))
	{
		g_esPlayer[client].g_bKeepCurrentType = true;

		if (g_esGeneral.g_iCurrentMode == 1 && g_esGeneral.g_flForceSpawn > 0.0)
		{
			CreateTimer(g_esGeneral.g_flForceSpawn, tTimerForceSpawnTank, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action L4D_OnFirstSurvivorLeftSafeArea(int client)
{
	vResetTimers(true);
}

public void L4D_OnReplaceTank(int tank, int newtank)
{
	g_esPlayer[newtank].g_bReplaceSelf = true;

	vSetColor(newtank, g_esPlayer[tank].g_iTankType);
	vCopyTankStats(tank, newtank);
	vTankSpawn(newtank, -1);
	vReset2(tank, 0);
	vReset3(tank);
	vCacheSettings(tank);
}

public Action L4D_OnShovedBySurvivor(int client, int victim, const float vecDir[3])
{
	Action aResult = Plugin_Continue;
	Call_StartForward(g_esGeneral.g_gfPlayerShovedBySurvivorForward);
	Call_PushCell(victim);
	Call_PushCell(client);
	Call_PushArray(vecDir, 3);
	Call_Finish(aResult);

	return aResult;
}

public Action L4D_OnSpawnTank(const float vecPos[3], const float vecAng[3])
{
	if (g_esGeneral.g_iLimitExtras == 0 || g_esGeneral.g_bForceSpawned)
	{
		return Plugin_Continue;
	}

	bool bBlock = false;
	int iCount = iGetTankCount(true), iCount2 = iGetTankCount(false);

	switch (bIsFinaleMap())
	{
		case true:
		{
			switch (g_esGeneral.g_iTankWave)
			{
				case 0: bBlock = false;
				default:
				{
					switch (g_esGeneral.g_iFinaleAmount)
					{
						case 0: bBlock = (0 < g_esGeneral.g_iFinaleWave[g_esGeneral.g_iTankWave - 1] <= iCount) || (0 < g_esGeneral.g_iFinaleWave[g_esGeneral.g_iTankWave - 1] <= iCount2);
						default: bBlock = (0 < g_esGeneral.g_iFinaleAmount <= iCount) || (0 < g_esGeneral.g_iFinaleAmount <= iCount2);
					}
				}
			}
		}
		case false: bBlock = (0 < g_esGeneral.g_iRegularAmount <= iCount) || (0 < g_esGeneral.g_iRegularAmount <= iCount2);
	}

	return bBlock ? Plugin_Handled : Plugin_Continue;
}

public Action L4D2_OnPounceOrLeapStumble(int victim, int attacker)
{
	if (bIsSurvivor(victim) && (bIsDeveloper(victim, 8) || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D2_OnStagger(int target, int source)
{
	if (bIsSurvivor(target) && (bIsDeveloper(target, 8) || (g_esPlayer[target].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
#endif

#if defined _WeaponHandling_included
public void WH_OnMeleeSwing(int client, int weapon, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnStartThrow(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnReadyingThrow(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnReloadModifier(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnGetRateOfFire(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnDeployModifier(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}
#endif

public void vGameMode(const char[] output, int caller, int activator, float delay)
{
	if (StrEqual(output, "OnCoop"))
	{
		g_esGeneral.g_iCurrentMode = 1;
	}
	else if (StrEqual(output, "OnVersus"))
	{
		g_esGeneral.g_iCurrentMode = 2;
	}
	else if (StrEqual(output, "OnSurvival"))
	{
		g_esGeneral.g_iCurrentMode = 4;
	}
	else if (StrEqual(output, "OnScavenge"))
	{
		g_esGeneral.g_iCurrentMode = 8;
	}
}

public void vMTPluginStatusCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	vPluginStatus();
}

public void vMTGameDifficultyCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_esGeneral.g_iConfigEnable == 1)
	{
		static char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_esGeneral.g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/mutant_tanks/difficulty_configs/%s.cfg", sDifficulty);
		if (FileExists(sDifficultyConfig, true))
		{
			vCustomConfig(sDifficultyConfig);
			g_esGeneral.g_iFileTimeOld[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
			g_esGeneral.g_iFileTimeNew[1] = g_esGeneral.g_iFileTimeOld[1];
		}
	}
}

public void vThirdpersonQuery(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	switch (bIsValidClient(client) && result == ConVarQuery_Okay)
	{
		case true: g_esPlayer[client].g_bThirdPerson = !!StringToInt(cvarValue);
		case false: g_esPlayer[client].g_bThirdPerson = false;
	}
}

public void vViewDistanceQuery(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	switch (bIsValidClient(client) && result == ConVarQuery_Okay)
	{
		case true: g_esPlayer[client].g_bThirdPerson2 = (StringToInt(cvarValue) <= -1) ? true : false;
		case false: g_esPlayer[client].g_bThirdPerson2 = false;
	}
}

public Action tTimerAnnounce(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank;
	iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTank(iTank))
	{
		return Plugin_Stop;
	}

	if (bIsTankSupported(iTank) && !bIsTankIdle(iTank))
	{
		static char sOldName[33], sNewName[33];
		pack.ReadString(sOldName, sizeof(sOldName));
		pack.ReadString(sNewName, sizeof(sNewName));
		static int iMode;
		iMode = pack.ReadCell();
		vAnnounce(iTank, sOldName, sNewName, iMode);

		return Plugin_Stop;
	}
	else
	{
		vTriggerTank(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerAnnounce2(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!bIsTank(iTank))
	{
		return Plugin_Stop;
	}

	if (!bIsTankIdle(iTank))
	{
		vAnnounceArrival(iTank, "NoName");

		return Plugin_Stop;
	}
	else
	{
		vTriggerTank(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerBloodEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_BLOOD) || !g_esPlayer[iTank].g_bBlood)
	{
		g_esPlayer[iTank].g_bBlood = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_BLOOD, 0.75, 30.0);

	return Plugin_Continue;
}

public Action tTimerBlurEffect(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTankModel, iTank;
	iTankModel = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if (iTankModel == INVALID_ENT_REFERENCE || !bIsValidEntity(iTankModel))
	{
		g_esPlayer[iTank].g_bBlur = false;

		return Plugin_Stop;
	}

	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iPropsAttached & MT_PROP_BLUR) || !g_esPlayer[iTank].g_bBlur)
	{
		g_esPlayer[iTank].g_bBlur = false;

		SDKUnhook(iTankModel, SDKHook_SetTransmit, OnPropSetTransmit);
		RemoveEntity(iTankModel);

		return Plugin_Stop;
	}

	static float flTankPos[3], flTankAng[3];
	GetClientAbsOrigin(iTank, flTankPos);
	GetClientAbsAngles(iTank, flTankAng);
	if (bIsValidEntity(iTankModel))
	{
		TeleportEntity(iTankModel, flTankPos, flTankAng, NULL_VECTOR);
		SetEntProp(iTankModel, Prop_Send, "m_nSequence", GetEntProp(iTank, Prop_Send, "m_nSequence"));
	}

	return Plugin_Continue;
}

public Action tTimerBoss(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank;
	iTank = GetClientOfUserId(pack.ReadCell());
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bIsCustomTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !g_esPlayer[iTank].g_bBoss)
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	static int iBossStages, iBossHealth, iType, iBossHealth2, iType2, iBossHealth3, iType3, iBossHealth4, iType4;
	iBossStages = pack.ReadCell();
	iBossHealth = pack.ReadCell(), iType = pack.ReadCell();
	iBossHealth2 = pack.ReadCell(), iType2 = pack.ReadCell();
	iBossHealth3 = pack.ReadCell(), iType3 = pack.ReadCell();
	iBossHealth4 = pack.ReadCell(), iType4 = pack.ReadCell();

	switch (g_esPlayer[iTank].g_iBossStageCount)
	{
		case 0: vBoss(iTank, iBossHealth, iBossStages, iType, 1);
		case 1: vBoss(iTank, iBossHealth2, iBossStages, iType2, 2);
		case 2: vBoss(iTank, iBossHealth3, iBossStages, iType3, 3);
		case 3: vBoss(iTank, iBossHealth4, iBossStages, iType4, 4);
	}

	return Plugin_Continue;
}

public Action tTimerCheckSurvivorView(Handle timer, int userid)
{
	static int iSurvivor;
	iSurvivor = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsHumanSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	QueryClientConVar(iSurvivor, "c_thirdpersonshoulder", vThirdpersonQuery);

	return Plugin_Continue;
}

public Action tTimerCheckTankView(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT))
	{
		return Plugin_Stop;
	}

	QueryClientConVar(iTank, "z_view_distance", vViewDistanceQuery);

	return Plugin_Continue;
}

public Action tTimerDelayRegularWaves(Handle timer)
{
	vKillRegularWavesTimer();
	g_esGeneral.g_hRegularWavesTimer = CreateTimer(g_esGeneral.g_flRegularInterval, tTimerRegularWaves, _, TIMER_REPEAT);
}

public Action tTimerDelaySurvival(Handle timer)
{
	g_esGeneral.g_hSurvivalTimer = null;
	g_esGeneral.g_iSurvivalBlock = 2;
}

public Action tTimerDevParticle(Handle timer, int userid)
{
	static int iSurvivor;
	iSurvivor = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsSurvivor(iSurvivor) || !bIsDeveloper(iSurvivor, 0) || !g_esDeveloper[iSurvivor].g_bDevVisual || g_esDeveloper[iSurvivor].g_iDevParticle == 0 || g_esGeneral.g_bFinaleEnded)
	{
		g_esDeveloper[iSurvivor].g_bDevVisual = false;

		return Plugin_Stop;
	}

	vSetSurvivorEffects(iSurvivor, g_esDeveloper[iSurvivor].g_iDevParticle);

	return Plugin_Continue;
}

public Action tTimerElectricEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_ELECTRICITY) || !g_esPlayer[iTank].g_bElectric)
	{
		g_esPlayer[iTank].g_bElectric = false;

		return Plugin_Stop;
	}

	switch (bIsValidClient(iTank, MT_CHECK_FAKECLIENT))
	{
		case true: vAttachParticle(iTank, PARTICLE_ELECTRICITY, 0.75, 30.0);
		case false:
		{
			for (int iCount = 1; iCount < 4; iCount++)
			{
				vAttachParticle(iTank, PARTICLE_ELECTRICITY, 0.75, (1.0 * float(iCount * 15)));
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerExecuteCustomConfig(Handle timer, DataPack pack)
{
	pack.Reset();

	char sSavePath[PLATFORM_MAX_PATH];
	pack.ReadString(sSavePath, sizeof(sSavePath));
	if (sSavePath[0] != '\0')
	{
		vLoadConfigs(sSavePath, 2);
		vPluginStatus();
		vResetTimers();
		vToggleLogging();
	}

	return Plugin_Continue;
}

public Action tTimerFireEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_FIRE) || !g_esPlayer[iTank].g_bFire)
	{
		g_esPlayer[iTank].g_bFire = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_FIRE, 0.75);

	return Plugin_Continue;
}

public Action tTimerForceSpawnTank(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTank(iTank) || !bIsInfectedGhost(iTank))
	{
		return Plugin_Stop;
	}

	int iAbility = -1;
#if defined _l4dh_included
	switch (g_esGeneral.g_bLeft4DHooksInstalled || g_esGeneral.g_hSDKMaterializeGhost == null)
	{
		case true: iAbility = L4D_MaterializeFromGhost(iTank);
		case false:
		{
			SDKCall(g_esGeneral.g_hSDKMaterializeGhost, iTank);
			iAbility = GetEntPropEnt(iTank, Prop_Send, "m_customAbility");
		}
	}
#else
	if (g_esGeneral.g_hSDKMaterializeGhost != null)
	{
		SDKCall(g_esGeneral.g_hSDKMaterializeGhost, iTank);
		iAbility = GetEntPropEnt(iTank, Prop_Send, "m_customAbility");
	}
#endif
	switch (iAbility)
	{
		case -1: MT_PrintToChat(iTank, "%s %t", MT_TAG3, "SpawnManually");
		default: vTankSpawn(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerIceEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_ICE) || !g_esPlayer[iTank].g_bIce)
	{
		g_esPlayer[iTank].g_bIce = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_ICE, 2.0, 30.0);

	return Plugin_Continue;
}

public Action tTimerKillIdleTank(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTank(iTank) || bIsTank(iTank, MT_CHECK_FAKECLIENT))
	{
		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank, g_esGeneral.g_iIdleCheckMode))
	{
		ForcePlayerSuicide(iTank);

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerKillStuckTank(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTank(iTank) || !bIsPlayerIncapacitated(iTank))
	{
		return Plugin_Stop;
	}

	ForcePlayerSuicide(iTank);

	return Plugin_Continue;
}

public Action tTimerLoopVoiceline(Handle timer, int userid)
{
	static int iSurvivor;
	iSurvivor = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_flVisualTime[4] == -1.0 || g_esPlayer[iSurvivor].g_flVisualTime[4] < GetGameTime() || g_esPlayer[iSurvivor].g_sLoopingVoiceline[0] == '\0' || g_esGeneral.g_bFinaleEnded)
	{
		g_esPlayer[iSurvivor].g_flVisualTime[4] = -1.0;
		g_esPlayer[iSurvivor].g_sLoopingVoiceline[0] = '\0';

		return Plugin_Stop;
	}

	if (!(g_esPlayer[iSurvivor].g_iRewardVisuals & MT_VISUAL_VOICELINE))
	{
		return Plugin_Continue;
	}

	vVocalize(iSurvivor, g_esPlayer[iSurvivor].g_sLoopingVoiceline);

	return Plugin_Continue;
}

public Action tTimerMeteorEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_METEOR) || !g_esPlayer[iTank].g_bMeteor)
	{
		g_esPlayer[iTank].g_bMeteor = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_METEOR, 6.0, 30.0);

	return Plugin_Continue;
}

public Action tTimerParticleVisual(Handle timer, int userid)
{
	static int iSurvivor;
	iSurvivor = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_flVisualTime[3] == -1.0 || g_esPlayer[iSurvivor].g_flVisualTime[3] < GetGameTime() || g_esPlayer[iSurvivor].g_iParticleEffect == 0 || g_esGeneral.g_bFinaleEnded)
	{
		g_esPlayer[iSurvivor].g_flVisualTime[3] = -1.0;
		g_esPlayer[iSurvivor].g_iParticleEffect = 0;

		return Plugin_Stop;
	}

	if (bIsDeveloper(iSurvivor, 0) || !(g_esPlayer[iSurvivor].g_iRewardVisuals & MT_VISUAL_PARTICLE))
	{
		return Plugin_Continue;
	}

	vSetSurvivorEffects(iSurvivor, g_esPlayer[iSurvivor].g_iParticleEffect);

	return Plugin_Continue;
}

public Action tTimerRandomize(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank;
	iTank = GetClientOfUserId(pack.ReadCell());
	static float flTime;
	flTime = pack.ReadFloat();
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !bIsCustomTankSupported(iTank) || !g_esPlayer[iTank].g_bRandomized || (flTime + g_esCache[iTank].g_flRandomDuration < GetEngineTime()))
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	static int iType;
	iType = iChooseTank(iTank, 2, _, _, false);

	switch (iType)
	{
		case 0: return Plugin_Continue;
		default: vSetColor(iTank, iType);
	}

	vTankSpawn(iTank, 2);

	return Plugin_Continue;
}

public Action tTimerRefreshRewards(Handle timer)
{
	if (!g_esGeneral.g_bPluginEnabled)
	{
		return Plugin_Continue;
	}

	static bool bCheck;
	bCheck = false;
	static float flDuration, flTime;
	flDuration = 0.0, flTime = GetGameTime();
	static int iType;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			iType = 0;

			for (int iPos = 0; iPos < sizeof(esPlayer::g_flRewardTime); iPos++)
			{
				if (iPos < sizeof(esPlayer::g_flVisualTime))
				{
					if ((g_esPlayer[iSurvivor].g_flVisualTime[0] != -1.0 && g_esPlayer[iSurvivor].g_flVisualTime[0] < flTime) || g_esGeneral.g_bFinaleEnded)
					{
						g_esPlayer[iSurvivor].g_flVisualTime[0] = -1.0;
						g_esPlayer[iSurvivor].g_iScreenColorVisual[0] = -1;
						g_esPlayer[iSurvivor].g_iScreenColorVisual[1] = -1;
						g_esPlayer[iSurvivor].g_iScreenColorVisual[2] = -1;
						g_esPlayer[iSurvivor].g_iScreenColorVisual[3] = -1;
					}

					if ((g_esPlayer[iSurvivor].g_flVisualTime[1] != -1.0 && g_esPlayer[iSurvivor].g_flVisualTime[1] < flTime) || g_esGeneral.g_bFinaleEnded)
					{
						g_esPlayer[iSurvivor].g_flVisualTime[1] = -1.0;
						g_esPlayer[iSurvivor].g_sGlowColor[0] = '\0';

						if (!bIsDeveloper(iSurvivor, 0))
						{
							vRemoveGlow(iSurvivor);
						}
					}

					if ((g_esPlayer[iSurvivor].g_flVisualTime[2] != -1.0 && g_esPlayer[iSurvivor].g_flVisualTime[2] < flTime) || g_esGeneral.g_bFinaleEnded)
					{
						g_esPlayer[iSurvivor].g_flVisualTime[2] = -1.0;
						g_esPlayer[iSurvivor].g_sBodyColor[0] = '\0';

						if (!bIsDeveloper(iSurvivor, 0))
						{
							SetEntityRenderColor(iSurvivor, 255, 255, 255, 255);
						}
					}

					if ((g_esPlayer[iSurvivor].g_flVisualTime[3] != -1.0 && g_esPlayer[iSurvivor].g_flVisualTime[3] < flTime) || g_esGeneral.g_bFinaleEnded)
					{
						g_esPlayer[iSurvivor].g_flVisualTime[3] = -1.0;
						g_esPlayer[iSurvivor].g_iParticleEffect = 0;
					}

					if ((g_esPlayer[iSurvivor].g_flVisualTime[4] != -1.0 && g_esPlayer[iSurvivor].g_flVisualTime[4] < flTime) || g_esGeneral.g_bFinaleEnded)
					{
						g_esPlayer[iSurvivor].g_flVisualTime[4] = -1.0;
						g_esPlayer[iSurvivor].g_sLoopingVoiceline[0] = '\0';
					}
				}

				switch (iPos)
				{
					case 0: bCheck = !!(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_HEALTH);
					case 1: bCheck = !!(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST);
					case 2: bCheck = !!(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST);
					case 3: bCheck = !!(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST);
					case 4: bCheck = !!(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_AMMO);
					case 5: bCheck = !!(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_GODMODE);
					case 6: bCheck = !!(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_INFAMMO);
				}

				flDuration = g_esPlayer[iSurvivor].g_flRewardTime[iPos];
				if (bCheck && ((flDuration != -1.0 && flDuration < flTime) || g_esGeneral.g_bFinaleEnded))
				{
					switch (iPos)
					{
						case 0: iType |= MT_REWARD_HEALTH;
						case 1: iType |= MT_REWARD_SPEEDBOOST;
						case 2: iType |= MT_REWARD_DAMAGEBOOST;
						case 3: iType |= MT_REWARD_ATTACKBOOST;
						case 4: iType |= MT_REWARD_AMMO;
						case 5: iType |= MT_REWARD_GODMODE;
						case 6: iType |= MT_REWARD_INFAMMO;
					}
				}
			}

			if (iType > 0)
			{
				vRewardSurvivor(iSurvivor, iType);
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerRegenerateAmmo(Handle timer)
{
	if (!g_esGeneral.g_bPluginEnabled)
	{
		return Plugin_Continue;
	}

	static bool bDeveloper;
	static char sWeapon[32];
	static int iAmmo, iAmmoOffset, iMaxAmmo, iClip, iRegen, iSlot, iSpecialAmmo, iUpgrades;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (!bIsSurvivor(iSurvivor))
		{
			continue;
		}

		bDeveloper = bIsDeveloper(iSurvivor, 4) || bIsDeveloper(iSurvivor, 6);
		iRegen = (bDeveloper && g_esDeveloper[iSurvivor].g_iDevAmmoRegen > g_esPlayer[iSurvivor].g_iAmmoRegen) ? g_esDeveloper[iSurvivor].g_iDevAmmoRegen : g_esPlayer[iSurvivor].g_iAmmoRegen;
		if ((!bDeveloper && (!(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_AMMO) || g_esPlayer[iSurvivor].g_flRewardTime[4] == -1.0)) || iRegen == 0)
		{
			continue;
		}

		iSlot = GetPlayerWeaponSlot(iSurvivor, 0);
		if (!bIsValidEntity(iSlot))
		{
			g_esPlayer[iSurvivor].g_iMaxClip[0] = 0;

			continue;
		}

		iClip = GetEntProp(iSlot, Prop_Send, "m_iClip1");
		if (iClip < g_esPlayer[iSurvivor].g_iMaxClip[0] && GetEntProp(iSlot, Prop_Send, "m_bInReload") == 0)
		{
			SetEntProp(iSlot, Prop_Send, "m_iClip1", (iClip + iRegen));
		}

		if (iClip + iRegen > g_esPlayer[iSurvivor].g_iMaxClip[0])
		{
			SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[iSurvivor].g_iMaxClip[0]);
		}

		if (g_bSecondGame)
		{
			iUpgrades = GetEntProp(iSlot, Prop_Send, "m_upgradeBitVec");
			if ((iUpgrades & MT_UPGRADE_INCENDIARY) || (iUpgrades & MT_UPGRADE_EXPLOSIVE))
			{
				iSpecialAmmo = GetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
				if (iSpecialAmmo < g_esPlayer[iSurvivor].g_iMaxClip[0])
				{
					SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", (iSpecialAmmo + iRegen));
				}

				if (iSpecialAmmo + iRegen > g_esPlayer[iSurvivor].g_iMaxClip[0])
				{
					SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", g_esPlayer[iSurvivor].g_iMaxClip[0]);
				}
			}
		}

		iAmmoOffset = iGetWeaponOffset(iSlot), iAmmo = GetEntProp(iSurvivor, Prop_Send, "m_iAmmo", _, iAmmoOffset), iMaxAmmo = iGetMaxAmmo(iSurvivor, 0, iSlot, true);
		if (iAmmo < iMaxAmmo)
		{
			SetEntProp(iSurvivor, Prop_Send, "m_iAmmo", (iAmmo + iRegen), _, iAmmoOffset);
		}

		if (iAmmo + iRegen > iMaxAmmo)
		{
			SetEntProp(iSurvivor, Prop_Send, "m_iAmmo", iMaxAmmo, _, iAmmoOffset);
		}

		iSlot = GetPlayerWeaponSlot(iSurvivor, 1);
		if (!bIsValidEntity(iSlot))
		{
			g_esPlayer[iSurvivor].g_iMaxClip[1] = 0;

			continue;
		}

		GetEntityClassname(iSlot, sWeapon, sizeof(sWeapon));
		if (StrContains(sWeapon, "pistol") != -1 || StrEqual(sWeapon, "weapon_chainsaw"))
		{
			iClip = GetEntProp(iSlot, Prop_Send, "m_iClip1");
			if (iClip < g_esPlayer[iSurvivor].g_iMaxClip[1])
			{
				SetEntProp(iSlot, Prop_Send, "m_iClip1", (iClip + iRegen));
			}

			if (iClip + iRegen > g_esPlayer[iSurvivor].g_iMaxClip[1])
			{
				SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[iSurvivor].g_iMaxClip[1]);
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerRegenerateHealth(Handle timer)
{
	if (!g_esGeneral.g_bPluginEnabled)
	{
		return Plugin_Continue;
	}

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		vLifeLeech(iSurvivor, _, _, 7);
	}

	return Plugin_Continue;
}

public Action tTimerRegularWaves(Handle timer)
{
	if (!bCanTypeSpawn() || bIsFinaleMap() || g_esGeneral.g_iTankWave > 0 || (g_esGeneral.g_iRegularLimit > 0 && g_esGeneral.g_iRegularCount >= g_esGeneral.g_iRegularLimit))
	{
		g_esGeneral.g_hRegularWavesTimer = null;

		return Plugin_Stop;
	}

	static int iCount;
	iCount = iGetTankCount(true);
	iCount = (iCount > 0) ? iCount : iGetTankCount(false);
	if (!g_esGeneral.g_bPluginEnabled || g_esGeneral.g_iRegularLimit == 0 || g_esGeneral.g_iRegularMode == 0 || g_esGeneral.g_iRegularWave == 0 || (g_esGeneral.g_iRegularAmount > 0 && iCount >= g_esGeneral.g_iRegularAmount))
	{
		return Plugin_Continue;
	}

	switch (g_esGeneral.g_iRegularAmount)
	{
		case 0: vRegularSpawn();
		default:
		{
			for (int iAmount = iCount; iAmount < g_esGeneral.g_iRegularAmount; iAmount++)
			{
				vRegularSpawn();
			}

			g_esGeneral.g_iRegularCount++;
		}
	}

	return Plugin_Continue;
}

public Action tTimerReloadConfigs(Handle timer)
{
	vConfig(false);

	return Plugin_Continue;
}

public Action tTimerRemoveTimescale(Handle timer, int ref)
{
	int iTimescale = EntRefToEntIndex(ref);
	if (iTimescale == INVALID_ENT_REFERENCE || !bIsValidEntity(iTimescale))
	{
		return Plugin_Stop;
	}

	AcceptEntityInput(iTimescale, "Stop");
	RemoveEntity(iTimescale);

	return Plugin_Continue;
}

public Action tTimerResetAttackDelay(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankSupported(iTank))
	{
		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bAttackedAgain = false;

	return Plugin_Continue;
}

public Action tTimerResetType(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsValidClient(iTank))
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	vReset3(iTank);
	vCacheSettings(iTank);

	return Plugin_Continue;
}

public Action tTimerRockEffects(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iRock, iTank;
	iRock = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if (!g_esGeneral.g_bPluginEnabled || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock) || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || g_esCache[iTank].g_iRockEffects == 0)
	{
		return Plugin_Stop;
	}

	static char sClassname[32];
	GetEntityClassname(iRock, sClassname, sizeof(sClassname));
	if (!StrEqual(sClassname, "tank_rock"))
	{
		return Plugin_Stop;
	}

	if (g_esCache[iTank].g_iRockEffects & MT_ROCK_BLOOD)
	{
		vAttachParticle(iRock, PARTICLE_BLOOD, 0.75);
	}

	if (g_esCache[iTank].g_iRockEffects & MT_ROCK_ELECTRICITY)
	{
		vAttachParticle(iRock, PARTICLE_ELECTRICITY, 0.75);
	}

	if (g_esCache[iTank].g_iRockEffects & MT_ROCK_FIRE)
	{
		IgniteEntity(iRock, 120.0);
	}

	if (g_bSecondGame && (g_esCache[iTank].g_iRockEffects & MT_ROCK_SPIT))
	{
		EmitSoundToAll(SOUND_SPIT, iTank);
		vAttachParticle(iRock, PARTICLE_SPIT, 0.75);
	}

	return Plugin_Continue;
}

public Action tTimerScreenEffect(Handle timer, int userid)
{
	static int iSurvivor;
	iSurvivor = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_flVisualTime[0] == -1.0 || g_esPlayer[iSurvivor].g_flVisualTime[0] < GetGameTime() || g_esGeneral.g_bFinaleEnded)
	{
		g_esPlayer[iSurvivor].g_flVisualTime[0] = -1.0;
		g_esPlayer[iSurvivor].g_iScreenColorVisual[0] = -1;
		g_esPlayer[iSurvivor].g_iScreenColorVisual[1] = -1;
		g_esPlayer[iSurvivor].g_iScreenColorVisual[2] = -1;
		g_esPlayer[iSurvivor].g_iScreenColorVisual[3] = -1;

		return Plugin_Stop;
	}

	if (!(g_esPlayer[iSurvivor].g_iRewardVisuals & MT_VISUAL_SCREEN) || bIsSurvivorHanging(iSurvivor) || g_esPlayer[iSurvivor].g_bThirdPerson || bIsPlayerInThirdPerson(iSurvivor))
	{
		return Plugin_Continue;
	}

	vEffect(iSurvivor, 0, MT_ATTACK_RANGE, MT_ATTACK_RANGE, g_esPlayer[iSurvivor].g_iScreenColorVisual[0], g_esPlayer[iSurvivor].g_iScreenColorVisual[1], g_esPlayer[iSurvivor].g_iScreenColorVisual[2], g_esPlayer[iSurvivor].g_iScreenColorVisual[3]);

	return Plugin_Continue;
}

public Action tTimerSmokeEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_SMOKE) || !g_esPlayer[iTank].g_bSmoke)
	{
		g_esPlayer[iTank].g_bSmoke = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_SMOKE, 1.5);

	return Plugin_Continue;
}

public Action tTimerSpitEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_SPIT) || !g_esPlayer[iTank].g_bSpit)
	{
		g_esPlayer[iTank].g_bSpit = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_SPIT, 2.0, 30.0);
	iCreateParticle(iTank, PARTICLE_SPIT2, NULL_VECTOR, NULL_VECTOR, 0.95, 2.0, "mouth");

	return Plugin_Continue;
}

public Action tTimerTankCountCheck(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iAmount, iCount, iCount2;
	iTank = GetClientOfUserId(pack.ReadCell()), iAmount = pack.ReadCell(), iCount = iGetTankCount(true), iCount2 = iGetTankCount(false);
	if (!bIsTank(iTank) || iAmount == 0 || iCount >= iAmount || iCount2 >= iAmount || (bIsNonFinaleMap() && g_esGeneral.g_iTankWave == 0 && g_esGeneral.g_iRegularMode == 1 && g_esGeneral.g_iRegularWave == 1))
	{
		return Plugin_Stop;
	}
	else if (iCount < iAmount && iCount2 < iAmount)
	{
		vRegularSpawn();
	}

	return Plugin_Continue;
}

public Action tTimerTankUpdate(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bIsCustomTankSupported(iTank) || bIsPlayerIncapacitated(iTank) || g_esGeneral.g_bFinaleEnded)
	{
		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	switch (g_esCache[iTank].g_iSpawnType)
	{
		case 1:
		{
			if (!g_esPlayer[iTank].g_bBoss)
			{
				vSpawnModes(iTank, true);

				DataPack dpBoss;
				CreateDataTimer(0.1, tTimerBoss, dpBoss, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpBoss.WriteCell(GetClientUserId(iTank));
				dpBoss.WriteCell(g_esCache[iTank].g_iBossStages);

				for (int iPos = 0; iPos < sizeof(esCache::g_iBossHealth); iPos++)
				{
					dpBoss.WriteCell(g_esCache[iTank].g_iBossHealth[iPos]);
					dpBoss.WriteCell(g_esCache[iTank].g_iBossType[iPos]);
				}
			}
		}
		case 2:
		{
			if (!g_esPlayer[iTank].g_bRandomized)
			{
				vSpawnModes(iTank, true);

				DataPack dpRandom;
				CreateDataTimer(g_esCache[iTank].g_flRandomInterval, tTimerRandomize, dpRandom, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpRandom.WriteCell(GetClientUserId(iTank));
				dpRandom.WriteFloat(GetEngineTime());
			}
		}
		case 3:
		{
			if (!g_esPlayer[iTank].g_bTransformed)
			{
				vSpawnModes(iTank, true);
				CreateTimer(g_esCache[iTank].g_flTransformDelay, tTimerTransform, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);

				DataPack dpUntransform;
				CreateDataTimer(g_esCache[iTank].g_flTransformDuration + g_esCache[iTank].g_flTransformDelay, tTimerUntransform, dpUntransform, TIMER_FLAG_NO_MAPCHANGE);
				dpUntransform.WriteCell(GetClientUserId(iTank));
				dpUntransform.WriteCell(g_esPlayer[iTank].g_iTankType);
			}
		}
		case 4: vSpawnModes(iTank, true);
	}

	Call_StartForward(g_esGeneral.g_gfAbilityActivatedForward);
	Call_PushCell(iTank);
	Call_Finish();

	vCombineAbilitiesForward(iTank, MT_COMBO_MAINRANGE);

	return Plugin_Continue;
}

public Action tTimerTankWave(Handle timer)
{
	if (bIsNonFinaleMap() || iGetTankCount(true, true) > 0 || iGetTankCount(false, true) > 0 || !(0 < g_esGeneral.g_iTankWave < 10))
	{
		g_esGeneral.g_hTankWaveTimer = null;

		return Plugin_Stop;
	}

	g_esGeneral.g_hTankWaveTimer = null;
	g_esGeneral.g_iTankWave++;

	return Plugin_Continue;
}

public Action tTimerTransform(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !bIsCustomTankSupported(iTank) || !g_esPlayer[iTank].g_bTransformed)
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	int iPos = GetRandomInt(0, sizeof(esCache::g_iTransformType) - 1);
	vSetColor(iTank, g_esCache[iTank].g_iTransformType[iPos]);
	vTankSpawn(iTank, 3);

	return Plugin_Continue;
}

public Action tTimerUntransform(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankSupported(iTank) || g_esCache[iTank].g_iTankEnabled <= 0)
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	int iTankType = pack.ReadCell();
	vSetColor(iTank, iTankType);
	vTankSpawn(iTank, 4);
	vSpawnModes(iTank, false);

	return Plugin_Continue;
}