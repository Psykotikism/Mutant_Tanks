/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <sdkhooks>
#include <dhooks>
#include <left4dhooks>
#include <mutant_tanks>

#undef REQUIRE_PLUGIN
#tryinclude <adminmenu>
#tryinclude <mt_clone>
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

bool g_bLateLoad, g_bSecondGame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			char sMessage[64];
			FormatEx(sMessage, sizeof(sMessage), "\"%s\" only supports Left 4 Dead 1 & 2.", MT_NAME);
			strcopy(error, err_max, sMessage);

			return APLRes_SilentFailure;
		}
	}

	CreateNative("MT_CanTypeSpawn", aNative_CanTypeSpawn);
	CreateNative("MT_DetonateTankRock", aNative_DetonateTankRock);
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
	CreateNative("MT_SetTankType", aNative_SetTankType);
	CreateNative("MT_SpawnTank", aNative_SpawnTank);
	CreateNative("MT_TankMaxHealth", aNative_TankMaxHealth);

	RegPluginLibrary("mutant_tanks");

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_CONCRETE_CHUNK "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_FIREWORKCRATE "models/props_junk/explosive_box001.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_TANK_MAIN "models/infected/hulk.mdl"
#define MODEL_TANK_DLC "models/infected/hulk_dlc3.mdl"
#define MODEL_TANK_L4D1 "models/infected/hulk_l4d1.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_TREE_TRUNK "models/props_foliage/tree_trunk.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl"

#define PARTICLE_ACHIEVED "achieved"
#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_ELECTRICITY "electrical_arc_01_parent"
#define PARTICLE_FIRE "aircraft_destroy_fastFireTrail"
#define PARTICLE_FIREWORK "mini_fireworks"
#define PARTICLE_ICE "apc_wheel_smoke1"
#define PARTICLE_METEOR "smoke_medium_01"
#define PARTICLE_SMOKE "smoker_smokecloud"
#define PARTICLE_SPIT "spitter_projectile"

#define SOUND_ACHIEVEMENT "ui/pickup_misc42.wav"
#define SOUND_ELECTRICITY "items/suitchargeok1.wav"
#define SOUND_EXPLOSION2 "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_2.wav" // Only available in L4D2
#define SOUND_EXPLOSION1 "animation/van_inside_debris.wav"
#define SOUND_METAL "physics/metal/metal_solid_impact_hard5.wav"
#define SOUND_MISSILE "player/tank/attack/thrown_missile_loop_1.wav"
#define SOUND_SPIT "player/spitter/voice/warn/spitter_spit_02.wav"

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

#define MT_CONFIG_SECTION_MAIN "MutantTanks"
#define MT_CONFIG_SECTION_MAIN2 "Mutant_Tanks"
#define MT_CONFIG_SECTION_MAIN3 "MTanks"
#define MT_CONFIG_SECTION_MAIN4 "MT"
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

#define MT_PARTICLE_BLOOD (1 << 0) // blood particle
#define MT_PARTICLE_ELECTRICITY (1 << 1) // electric particle
#define MT_PARTICLE_FIRE (1 << 2) // fire particle
#define MT_PARTICLE_ICE (1 << 3) // ice particle
#define MT_PARTICLE_METEOR (1 << 4) // meteor particle
#define MT_PARTICLE_SMOKE (1 << 5) // smoke particle
#define MT_PARTICLE_SPIT (1 << 6) // spit particle

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

#define MT_USEFUL_REFILL (1 << 0) // useful refill reward
#define MT_USEFUL_HEALTH (1 << 1) // useful health reward
#define MT_USEFUL_AMMO (1 << 2) // useful ammo reward
#define MT_USEFUL_RESPAWN (1 << 3) // useful respawn reward

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
	ArrayList g_alAbilitySections[4];
	ArrayList g_alFilePaths;
	ArrayList g_alPlugins;
	ArrayList g_alSections;

	bool g_bAbilityPlugin[MT_MAXABILITIES + 1];
	bool g_bCloneInstalled;
	bool g_bFinaleEnded;
	bool g_bForceSpawned;
	bool g_bHideNameChange;
	bool g_bMapStarted;
	bool g_bPluginEnabled;
	bool g_bUsedParser;

	char g_sChosenPath[PLATFORM_MAX_PATH];
	char g_sCurrentSection[128];
	char g_sCurrentSubSection[128];
	char g_sDisabledGameModes[513];
	char g_sEnabledGameModes[513];
	char g_sHealthCharacters[4];
	char g_sItemReward[320];
	char g_sItemReward2[320];
	char g_sItemReward3[320];
	char g_sLogFile[PLATFORM_MAX_PATH];
	char g_sSavePath[PLATFORM_MAX_PATH];
	char g_sSection[PLATFORM_MAX_PATH];

	ConfigState g_csState;
	ConfigState g_csState2;

	ConVar g_cvMTBurnMax;
	ConVar g_cvMTDifficulty;
	ConVar g_cvMTDisabledGameModes;
	ConVar g_cvMTEnabledGameModes;
	ConVar g_cvMTGameMode;
	ConVar g_cvMTGameModeTypes;
	ConVar g_cvMTGameTypes;
	ConVar g_cvMTPluginEnabled;

	DynamicDetour g_ddEnterStasis;
	DynamicDetour g_ddEventKilled;
	DynamicDetour g_ddLauncherDirectionDetour;
	DynamicDetour g_ddLeaveStasis;
	DynamicDetour g_ddTankRockDetour;

	float g_flBurntSkin;
	float g_flDamageBoostReward[3];
	float g_flDifficultyDamage[4];
	float g_flExtrasDelay;
	float g_flIdleCheck;
	float g_flRegularDelay;
	float g_flRegularInterval;
	float g_flRewardChance[3];
	float g_flRewardDuration[3];
	float g_flRewardPercentage[3];
	float g_flSpeedBoostReward[3];

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
	GlobalForward g_gfHookEventForward;
	GlobalForward g_gfLogMessageForward;
	GlobalForward g_gfMenuItemDisplayedForward;
	GlobalForward g_gfMenuItemSelectedForward;
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
	Handle g_hSDKDetonateRock;
	Handle g_hSDKFirstContainedResponder;
	Handle g_hSDKGetName;
	Handle g_hSDKIsInStasis;
	Handle g_hSDKLeaveStasis;
	Handle g_hSDKRespawnPlayer;

	int g_iAccessFlags;
	int g_iAggressiveTanks;
	int g_iAllowDeveloper;
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iAnnounceKill;
	int g_iArrivalMessage;
	int g_iBaseHealth;
	int g_iChosenType;
	int g_iConfigCreate;
	int g_iConfigEnable;
	int g_iConfigExecute;
	int g_iConfigMode;
	int g_iCreditIgniters;
	int g_iCurrentMode;
	int g_iDeathMessage;
	int g_iDeathRevert;
	int g_iDetectPlugins;
	int g_iDeveloperAccess;
	int g_iDisplayHealth;
	int g_iDisplayHealthType;
	int g_iExtraHealth;
	int g_iFileTimeOld[8];
	int g_iFileTimeNew[8];
	int g_iFinaleAmount;
	int g_iFinaleMaxTypes[10];
	int g_iFinaleMinTypes[10];
	int g_iFinalesOnly;
	int g_iFinaleWave[10];
	int g_iGameModeTypes;
	int g_iHumanCooldown;
	int g_iIdleCheckMode;
	int g_iIgnoreLevel;
	int g_iIgnoreLevel2;
	int g_iImmunityFlags;
	int g_iIntentionOffset;
	int g_iKillMessage;
	int g_iLauncher;
	int g_iLimitExtras;
	int g_iLogCommands;
	int g_iLogMessages;
	int g_iMasterControl;
	int g_iMaxType;
	int g_iMeleeOffset;
	int g_iMinType;
	int g_iMinimumHumans;
	int g_iMultiHealth;
	int g_iParserViewer;
	int g_iPlayerCount[3];
	int g_iPluginEnabled;
	int g_iRegularAmount;
	int g_iRegularCount;
	int g_iRegularLimit;
	int g_iRegularMaxType;
	int g_iRegularMinType;
	int g_iRegularMode;
	int g_iRegularWave;
	int g_iRequiresHumans;
	int g_iRespawnLoadoutReward[3];
	int g_iRewardEffect[3];
	int g_iRewardEnabled[3];
	int g_iScaleDamage;
	int g_iSection;
	int g_iSpawnMode;
	int g_iStasisMode;
	int g_iTankCount;
	int g_iTankModel;
	int g_iTankWave;
	int g_iTeamID[2048];
	int g_iUsefulRewards[3];

	TopMenu g_tmMTMenu;
}

esGeneral g_esGeneral;

enum struct esAdmin
{
	int g_iAccessFlags[MAXPLAYERS + 1];
	int g_iImmunityFlags[MAXPLAYERS + 1];
}

esAdmin g_esAdmin[MT_MAXTYPES + 1];

enum struct esPlayer
{
	bool g_bAdminMenu;
	bool g_bAttacked;
	bool g_bAttackedAgain;
	bool g_bBlood;
	bool g_bBlur;
	bool g_bBoss;
	bool g_bCombo;
	bool g_bDied;
	bool g_bDualWielding;
	bool g_bDying;
	bool g_bElectric;
	bool g_bFire;
	bool g_bFirstSpawn;
	bool g_bIce;
	bool g_bKeepCurrentType;
	bool g_bLastLife;
	bool g_bMeteor;
	bool g_bNeedHealth;
	bool g_bRandomized;
	bool g_bReplaceSelf;
	bool g_bRewardedAmmo;
	bool g_bRewardedDamage;
	bool g_bRewardedGod;
	bool g_bRewardedHealth;
	bool g_bRewardedItem;
	bool g_bRewardedRefill;
	bool g_bRewardedRespawn;
	bool g_bRewardedSpeed;
	bool g_bSmoke;
	bool g_bSpit;
	bool g_bStasis;
	bool g_bThirdPerson;
	bool g_bTransformed;
	bool g_bTriggered;

	char g_sComboSet[320];
	char g_sHealthCharacters[4];
	char g_sItemReward[320];
	char g_sItemReward2[320];
	char g_sItemReward3[320];
	char g_sTankName[33];
	char g_sWeaponPrimary[32];
	char g_sWeaponSecondary[32];
	char g_sWeaponThrowable[32];
	char g_sWeaponMedkit[32];
	char g_sWeaponPills[32];

	float g_flAttackDelay;
	float g_flAttackInterval;
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
	float g_flDamageBoostReward[3];
	float g_flHittableDamage;
	float g_flLastAngles[3];
	float g_flLastPosition[3];
	float g_flPropsChance[9];
	float g_flRandomDuration;
	float g_flRandomInterval;
	float g_flRewardChance[3];
	float g_flRewardDuration[3];
	float g_flRewardPercentage[3];
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flSpeedBoost;
	float g_flSpeedBoostReward[3];
	float g_flThrowInterval;
	float g_flTransformDelay;
	float g_flTransformDuration;

	Handle g_hRewardTimer;

	int g_iAccessFlags;
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iAnnounceKill;
	int g_iArrivalMessage;
	int g_iBaseHealth;
	int g_iBodyEffects;
	int g_iBossHealth[4];
	int g_iBossStageCount;
	int g_iBossStages;
	int g_iBossType[4];
	int g_iBulletImmunity;
	int g_iCooldown;
	int g_iCrownColor[4];
	int g_iDeathMessage;
	int g_iDeathRevert;
	int g_iDetectPlugins;
	int g_iDisplayHealth;
	int g_iDisplayHealthType;
	int g_iEffect[2];
	int g_iExplosiveImmunity;
	int g_iExtraHealth;
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
	int g_iHittableImmunity;
	int g_iImmunityFlags;
	int g_iKillMessage;
	int g_iLastButtons;
	int g_iLight[10];
	int g_iLightColor[4];
	int g_iMeleeImmunity;
	int g_iMinimumHumans;
	int g_iMultiHealth;
	int g_iOldTankType;
	int g_iOzTank[2];
	int g_iOzTankColor[4];
	int g_iPropsAttached;
	int g_iPropaneTank;
	int g_iPropTankColor[4];
	int g_iRandomTank;
	int g_iRespawnLoadoutReward[3];
	int g_iRewardEffect[3];
	int g_iRewardEnabled[3];
	int g_iRock[20];
	int g_iRockColor[4];
	int g_iRockEffects;
	int g_iRockModel;
	int g_iSkinColor[4];
	int g_iSpawnType;
	int g_iTankDamage[MAXPLAYERS + 1];
	int g_iTankHealth;
	int g_iTankModel;
	int g_iTankNote;
	int g_iTankType;
	int g_iTire[2];
	int g_iTireColor[4];
	int g_iTransformType[10];
	int g_iUsefulRewards[3];
	int g_iUserID;
	int g_iWeaponInfo[4];
	int g_iWeaponInfo2;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esTank
{
	char g_sComboSet[320];
	char g_sHealthCharacters[4];
	char g_sItemReward[320];
	char g_sItemReward2[320];
	char g_sItemReward3[320];
	char g_sTankName[33];

	float g_flAttackInterval;
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
	float g_flDamageBoostReward[3];
	float g_flHittableDamage;
	float g_flOpenAreasOnly;
	float g_flPropsChance[9];
	float g_flRandomDuration;
	float g_flRandomInterval;
	float g_flRewardChance[3];
	float g_flRewardDuration[3];
	float g_flRewardPercentage[3];
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flSpeedBoostReward[3];
	float g_flTankChance;
	float g_flThrowInterval;
	float g_flTransformDelay;
	float g_flTransformDuration;

	int g_iAbilityCount;
	int g_iAccessFlags;
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iAnnounceKill;
	int g_iArrivalMessage;
	int g_iBaseHealth;
	int g_iBodyEffects;
	int g_iBossHealth[4];
	int g_iBossStages;
	int g_iBossType[4];
	int g_iBulletImmunity;
	int g_iCrownColor[4];
	int g_iDeathMessage;
	int g_iDeathRevert;
	int g_iDetectPlugins;
	int g_iDisplayHealth;
	int g_iDisplayHealthType;
	int g_iExplosiveImmunity;
	int g_iExtraHealth;
	int g_iFinaleTank;
	int g_iFireImmunity;
	int g_iFlameColor[4];
	int g_iFlashlightColor[4];
	int g_iGlowColor[3];
	int g_iGlowEnabled;
	int g_iGlowFlashing;
	int g_iGlowMaxRange;
	int g_iGlowMinRange;
	int g_iGlowType;
	int g_iHittableImmunity;
	int g_iHumanSupport;
	int g_iImmunityFlags;
	int g_iKillMessage;
	int g_iLightColor[4];
	int g_iMeleeImmunity;
	int g_iMenuEnabled;
	int g_iMinimumHumans;
	int g_iMultiHealth;
	int g_iOzTankColor[4];
	int g_iPropsAttached;
	int g_iPropTankColor[4];
	int g_iRandomTank;
	int g_iRequiresHumans;
	int g_iRespawnLoadoutReward[3];
	int g_iRewardEffect[3];
	int g_iRewardEnabled[3];
	int g_iRockColor[4];
	int g_iRockEffects;
	int g_iRockModel;
	int g_iSkinColor[4];
	int g_iSpawnEnabled;
	int g_iSpawnType;
	int g_iTankEnabled;
	int g_iTankModel;
	int g_iTankNote;
	int g_iTireColor[4];
	int g_iTransformType[10];
	int g_iTypeLimit;
	int g_iUsefulRewards[3];
}

esTank g_esTank[MT_MAXTYPES + 1];

enum struct esCache
{
	char g_sComboSet[320];
	char g_sHealthCharacters[4];
	char g_sItemReward[320];
	char g_sItemReward2[320];
	char g_sItemReward3[320];
	char g_sTankName[33];

	float g_flAttackInterval;
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
	float g_flDamageBoostReward[3];
	float g_flHittableDamage;
	float g_flPropsChance[9];
	float g_flRandomDuration;
	float g_flRandomInterval;
	float g_flRewardChance[3];
	float g_flRewardDuration[3];
	float g_flRewardPercentage[3];
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flSpeedBoostReward[3];
	float g_flThrowInterval;
	float g_flTransformDelay;
	float g_flTransformDuration;

	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iAnnounceKill;
	int g_iArrivalMessage;
	int g_iBaseHealth;
	int g_iBodyEffects;
	int g_iBossHealth[4];
	int g_iBossStages;
	int g_iBossType[4];
	int g_iBulletImmunity;
	int g_iCrownColor[4];
	int g_iDeathMessage;
	int g_iDeathRevert;
	int g_iDetectPlugins;
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
	int g_iHittableImmunity;
	int g_iKillMessage;
	int g_iLightColor[4];
	int g_iMeleeImmunity;
	int g_iMinimumHumans;
	int g_iMultiHealth;
	int g_iOzTankColor[4];
	int g_iPropsAttached;
	int g_iPropTankColor[4];
	int g_iRandomTank;
	int g_iRespawnLoadoutReward[3];
	int g_iRewardEffect[3];
	int g_iRewardEnabled[3];
	int g_iRockColor[4];
	int g_iRockEffects;
	int g_iRockModel;
	int g_iSkinColor[4];
	int g_iSpawnType;
	int g_iTankModel;
	int g_iTankNote;
	int g_iTireColor[4];
	int g_iTransformType[10];
	int g_iUsefulRewards[3];
}

esCache g_esCache[MAXPLAYERS + 1];

int g_iBossBeamSprite = -1, g_iBossHaloSprite = -1;

public any aNative_CanTypeSpawn(Handle plugin, int numParams)
{
	int iType = iClamp(GetNativeCell(1), 1, MT_MAXTYPES);
	return g_esTank[iType].g_iSpawnEnabled == 1 && bCanTypeSpawn(iType);
}

public any aNative_DetonateTankRock(Handle plugin, int numParams)
{
	int iRock = GetNativeCell(1);
	if (bIsValidEntity(iRock))
	{
		RequestFrame(vDetonateRockFrame, EntIndexToEntRef(iRock));
	}
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
	if (bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
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
	return bTankChance(iType);
}

public any aNative_HideEntity(Handle plugin, int numParams)
{
	int iEntity = GetNativeCell(1);
	bool bMode = GetNativeCell(2);
	if (bIsValidEntity(iEntity))
	{
		switch (bMode)
		{
			case true: SDKHook(iEntity, SDKHook_SetTransmit, SetTransmit);
			case false: SDKUnhook(iEntity, SDKHook_SetTransmit, SetTransmit);
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
	return bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsTankIdle(iTank, iType);
}

public any aNative_IsTankSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && bIsTankSupported(iTank, GetNativeCell(2));
}

public any aNative_IsTypeEnabled(Handle plugin, int numParams)
{
	int iType = iClamp(GetNativeCell(1), 1, MT_MAXTYPES);
	return g_esTank[iType].g_iTankEnabled == 1 && bIsTypeAvailable(iType);
}

public any aNative_LogMessage(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	if (g_esGeneral.g_iLogMessages & iType)
	{
		char sBuffer[255];
		int iSize = 0, iResult = FormatNativeString(0, 2, 3, sizeof(sBuffer), iSize, sBuffer);
		if (iResult == SP_ERROR_NONE)
		{
			vLogMessage(iType, _, sBuffer);
		}
	}
}

public any aNative_SetTankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = iClamp(GetNativeCell(2), 1, MT_MAXTYPES);
	bool bMode = GetNativeCell(3);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE))
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
	if (bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE))
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

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_esGeneral.g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_esGeneral.g_bCloneInstalled = false;
	}
}

public void OnAllPluginsLoaded()
{
	g_esGeneral.g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnPluginStart()
{
	g_esGeneral.g_gfAbilityActivatedForward = new GlobalForward("MT_OnAbilityActivated", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfAbilityCheckForward = new GlobalForward("MT_OnAbilityCheck", ET_Ignore, Param_Array, Param_Array, Param_Array, Param_Array);
	g_esGeneral.g_gfButtonPressedForward = new GlobalForward("MT_OnButtonPressed", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfButtonReleasedForward = new GlobalForward("MT_OnButtonReleased", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfChangeTypeForward = new GlobalForward("MT_OnChangeType", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_esGeneral.g_gfCombineAbilitiesForward = new GlobalForward("MT_OnCombineAbilities", ET_Ignore, Param_Cell, Param_Cell, Param_Float, Param_String, Param_Cell, Param_Cell, Param_String);
	g_esGeneral.g_gfConfigsLoadForward = new GlobalForward("MT_OnConfigsLoad", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfConfigsLoadedForward = new GlobalForward("MT_OnConfigsLoaded", ET_Ignore, Param_String, Param_String, Param_String, Param_Cell, Param_Cell, Param_Cell);
	g_esGeneral.g_gfCopyStatsForward = new GlobalForward("MT_OnCopyStats", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfDisplayMenuForward = new GlobalForward("MT_OnDisplayMenu", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfEventFiredForward = new GlobalForward("MT_OnEventFired", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	g_esGeneral.g_gfHookEventForward = new GlobalForward("MT_OnHookEvent", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfLogMessageForward = new GlobalForward("MT_OnLogMessage", ET_Event, Param_Cell, Param_String);
	g_esGeneral.g_gfMenuItemDisplayedForward = new GlobalForward("MT_OnMenuItemDisplayed", ET_Ignore, Param_Cell, Param_String, Param_String, Param_Cell);
	g_esGeneral.g_gfMenuItemSelectedForward = new GlobalForward("MT_OnMenuItemSelected", ET_Ignore, Param_Cell, Param_String);
	g_esGeneral.g_gfPluginCheckForward = new GlobalForward("MT_OnPluginCheck", ET_Ignore, Param_Array);
	g_esGeneral.g_gfPluginEndForward = new GlobalForward("MT_OnPluginEnd", ET_Ignore);
	g_esGeneral.g_gfPostTankSpawnForward = new GlobalForward("MT_OnPostTankSpawn", ET_Ignore, Param_Cell);
	g_esGeneral.g_gfResetTimersForward = new GlobalForward("MT_OnResetTimers", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfRewardSurvivorForward = new GlobalForward("MT_OnRewardSurvivor", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell);
	g_esGeneral.g_gfRockBreakForward = new GlobalForward("MT_OnRockBreak", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfRockThrowForward = new GlobalForward("MT_OnRockThrow", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfSettingsCachedForward = new GlobalForward("MT_OnSettingsCached", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_esGeneral.g_gfTypeChosenForward = new GlobalForward("MT_OnTypeChosen", ET_Event, Param_CellByRef, Param_Cell);

	vMultiTargetFilters(true);

	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegAdminCmd("sm_mt_config", cmdMTConfig, ADMFLAG_ROOT, "View a section of the config file.");
	RegConsoleCmd("sm_mt_config2", cmdMTConfig2, "View a section of the config file.");
	RegConsoleCmd("sm_mt_info", cmdMTInfo, "View information about Mutant Tanks.");
	RegAdminCmd("sm_mt_list", cmdMTList, ADMFLAG_ROOT, "View a list of installed abilities.");
	RegConsoleCmd("sm_mt_list2", cmdMTList2, "View a list of installed abilities.");
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
	g_esGeneral.g_cvMTPluginEnabled = CreateConVar("mt_pluginenabled", "1", "Enable Mutant Tanks.\n0: OFF\n1: ON", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar("mt_pluginversion", MT_VERSION, "Mutant Tanks Version", FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_SPONLY);

	AutoExecConfig(true, "mutant_tanks");

	g_esGeneral.g_cvMTBurnMax = FindConVar("z_burn_max");
	g_esGeneral.g_cvMTDifficulty = FindConVar("z_difficulty");
	g_esGeneral.g_cvMTGameMode = FindConVar("mp_gamemode");
	g_esGeneral.g_cvMTGameTypes = FindConVar("sv_gametypes");

	g_esGeneral.g_cvMTDisabledGameModes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTEnabledGameModes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTGameModeTypes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTPluginEnabled.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTDifficulty.AddChangeHook(vMTGameDifficultyCvar);

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
		case false:
		{
			SetFailState("Unable to load config file: %s", g_esGeneral.g_sSavePath);

			return;
		}
	}

	HookEvent("round_start", vEventHandler);
	HookEvent("round_end", vEventHandler);

	HookUserMessage(GetUserMessageId("SayText2"), umNameChange, true);

	GameData gdMutantTanks = new GameData("mutant_tanks");

	switch (gdMutantTanks == null)
	{
		case true:
		{
			SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");

			delete gdMutantTanks;
		}
		case false:
		{
			if (g_bSecondGame)
			{
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

				g_esGeneral.g_iMeleeOffset = gdMutantTanks.GetOffset("HiddenMelee");
				if (g_esGeneral.g_iMeleeOffset == -1)
				{
					LogError("%s Failed to load offset: HiddenMelee", MT_TAG);
				}
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

			StartPrepSDKCall(SDKCall_Entity);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTankRock::Detonate"))
			{
				LogError("%s Failed to find signature: CTankRock::Detonate", MT_TAG);
			}

			g_esGeneral.g_hSDKDetonateRock = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKDetonateRock == null)
			{
				LogError("%s Your \"CTankRock::Detonate\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::RoundRespawn"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::RoundRespawn", MT_TAG);
			}

			g_esGeneral.g_hSDKRespawnPlayer = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKRespawnPlayer == null)
			{
				LogError("%s Your \"CTerrorPlayer::RoundRespawn\" signature is outdated.", MT_TAG);
			}

			g_esGeneral.g_iIntentionOffset = gdMutantTanks.GetOffset("Tank::GetIntentionInterface");
			if (g_esGeneral.g_iIntentionOffset == -1)
			{
				LogError("%s Failed to load offset: Tank::GetIntentionInterface", MT_TAG);
			}

			int iOffset = gdMutantTanks.GetOffset("Action<Tank>::FirstContainedResponder");
			StartPrepSDKCall(SDKCall_Raw);
			PrepSDKCall_SetVirtual(iOffset);
			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKFirstContainedResponder = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKFirstContainedResponder == null)
			{
				LogError("%s Your \"Action<Tank>::FirstContainedResponder\" offsets are outdated.", MT_TAG);
			}

			iOffset = gdMutantTanks.GetOffset("TankIdle::GetName");
			StartPrepSDKCall(SDKCall_Raw);
			PrepSDKCall_SetVirtual(iOffset);
			PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Plain);
			g_esGeneral.g_hSDKGetName = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetName == null)
			{
				LogError("%s Your \"TankIdle::GetName\" offsets are outdated.", MT_TAG);
			}

			g_esGeneral.g_ddLauncherDirectionDetour = DynamicDetour.FromConf(gdMutantTanks, "CEnvRockLauncher::LaunchCurrentDir");
			if (g_esGeneral.g_ddLauncherDirectionDetour == null)
			{
				LogError("%s Failed to find signature: CEnvRockLauncher::LaunchCurrentDir", MT_TAG);
			}

			g_esGeneral.g_ddTankRockDetour = DynamicDetour.FromConf(gdMutantTanks, "CTankRock::Create");
			if (g_esGeneral.g_ddTankRockDetour == null)
			{
				LogError("%s Failed to find signature: CTankRock::Create", MT_TAG);
			}

			g_esGeneral.g_ddEnterStasis = DynamicDetour.FromConf(gdMutantTanks, "Tank::EnterStasis");
			if (g_esGeneral.g_ddEnterStasis == null)
			{
				LogError("%s Failed to find signature: Tank::EnterStasis", MT_TAG);
			}

			g_esGeneral.g_ddLeaveStasis = DynamicDetour.FromConf(gdMutantTanks, "Tank::LeaveStasis");
			if (g_esGeneral.g_ddLeaveStasis == null)
			{
				LogError("%s Failed to find signature: Tank::LeaveStasis", MT_TAG);
			}

			g_esGeneral.g_ddEventKilled = DynamicDetour.FromConf(gdMutantTanks, "CTerrorPlayer::Event_Killed");
			if (g_esGeneral.g_ddEventKilled == null)
			{
				LogError("%s Failed to find signature: CTerrorPlayer::Event_Killed", MT_TAG);
			}

			delete gdMutantTanks;
		}
	}

	g_esGeneral.g_alFilePaths = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

	if (g_bLateLoad)
	{
		TopMenu tmAdminMenu = null;
		if (LibraryExists("adminmenu") && ((tmAdminMenu = GetAdminTopMenu()) != null))
		{
			OnAdminMenuReady(tmAdminMenu);
		}

		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
			{
				OnClientPutInServer(iPlayer);
				OnClientPostAdminCheck(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	g_esGeneral.g_bMapStarted = true;

	PrecacheModel(MODEL_TANK_MAIN, true);
	PrecacheModel(MODEL_TANK_DLC, true);

	PrecacheModel(MODEL_CONCRETE_CHUNK, true);
	PrecacheModel(MODEL_FIREWORKCRATE, true);
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_JETPACK, true);
	PrecacheModel(MODEL_PROPANETANK, true);
	PrecacheModel(MODEL_TIRES, true);
	PrecacheModel(MODEL_TREE_TRUNK, true);
	PrecacheModel(MODEL_WITCH, true);
	PrecacheModel(MODEL_WITCHBRIDE, true);

	iPrecacheParticle(PARTICLE_ACHIEVED);
	iPrecacheParticle(PARTICLE_BLOOD);
	iPrecacheParticle(PARTICLE_ELECTRICITY);
	iPrecacheParticle(PARTICLE_FIRE);
	iPrecacheParticle(PARTICLE_FIREWORK);
	iPrecacheParticle(PARTICLE_ICE);
	iPrecacheParticle(PARTICLE_METEOR);
	iPrecacheParticle(PARTICLE_SMOKE);
	iPrecacheParticle(PARTICLE_SPIT);

	switch (g_bSecondGame)
	{
		case true:
		{
			PrecacheSound(SOUND_EXPLOSION2, true);
			PrecacheSound(SOUND_SPIT, true);
		}
		case false:
		{
			PrecacheSound(SOUND_EXPLOSION1, true);
			PrecacheModel(MODEL_TANK_L4D1, true);
		}
	}

	PrecacheSound(SOUND_ACHIEVEMENT, true);
	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_METAL, true);

	g_iBossBeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
	g_iBossHaloSprite = PrecacheModel("sprites/glow01.vmt", true);
	PrecacheModel(SPRITE_EXPLODE, true);

	vReset();
	vToggleLogging(1);
	AddNormalSoundHook(RockSoundHook);
}

public void OnClientPutInServer(int client)
{
	g_esPlayer[client].g_iUserID = GetClientUserId(client);

	SDKHook(client, SDKHook_OnTakeDamage, OnTakeCombineDamage);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakePlayerDamage);

	vReset3(client);
	vCacheSettings(client);
	vResetCore(client);
}

public void OnClientPostAdminCheck(int client)
{
	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		if (bIsDeveloper(client))
		{
			g_esGeneral.g_iDeveloperAccess = 125;
		}

		vLoadConfigs(g_esGeneral.g_sSavePath, 3);
	}

	g_esGeneral.g_iPlayerCount[0] = iGetPlayerCount();
}

public void OnClientDisconnect(int client)
{
	if (bIsTank(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bIsValidClient(client, MT_CHECK_FAKECLIENT))
	{
		if (!bIsCustomTank(client))
		{
			g_esGeneral.g_iTankCount--;
		}

		vCalculateDeath(client);
	}

	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && bIsDeveloper(client))
	{
		g_esGeneral.g_iDeveloperAccess = 0;
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
	g_esGeneral.g_iChosenType = 0;
	g_esGeneral.g_iRegularCount = 0;
	g_esGeneral.g_iTankCount = 0;

	vLoadConfigs(g_esGeneral.g_sSavePath, 1);
	vPluginStatus();
	vResetTimers();
	CreateTimer(1.0, tTimerReloadConfigs, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

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
					case 0: sDifficulty = "easy";
					case 1: sDifficulty = "normal";
					case 2: sDifficulty = "hard";
					case 3: sDifficulty = "impossible";
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
	RemoveNormalSoundHook(RockSoundHook);
}

public void OnPluginEnd()
{
	vMultiTargetFilters(false);
	vClearSectionList();

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

public void OnAdminMenuReady(Handle topmenu)
{
	TopMenu tmMTMenu = TopMenu.FromHandle(topmenu);
	if (topmenu == g_esGeneral.g_tmMTMenu)
	{
		return;
	}

	g_esGeneral.g_tmMTMenu = tmMTMenu;
	TopMenuObject tmoCommands = g_esGeneral.g_tmMTMenu.AddCategory(MT_CONFIG_SECTION_MAIN, vMTAdminMenuHandler, "mt_adminmenu", ADMFLAG_GENERIC);
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
		case TopMenuAction_DisplayTitle, TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", MT_CONFIG_SECTION_MAIN, param);
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
			vLogCommand(param, MT_CMD_SPAWN, "{default}Opened the{mint} %s{default} menu.", MT_NAME);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Opened the %s menu.", MT_TAG, param, MT_NAME);
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
			vLogCommand(param, MT_CMD_CONFIG, "{default}Opened the config file viewer.");
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
			vLogCommand(param, MT_CMD_LIST, "{default}Checked the list of abilities installed.");
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
			vLogCommand(param, MT_CMD_RELOAD, "{default}Reloaded all config files.");
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
			MT_PrintToChat(param, "%s %s{yellow} v%s{mint}, by{olive} %s", MT_TAG3, MT_NAME, MT_VERSION, MT_AUTHOR);
			vLogCommand(param, MT_CMD_VERSION, "{default}Checked the current version of{mint} %s{default}.", MT_NAME);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Checked the current version of %s.", MT_TAG, param, MT_NAME);

			if (bIsValidClient(param, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && g_esGeneral.g_tmMTMenu != null)
			{
				g_esGeneral.g_tmMTMenu.Display(param, TopMenuPosition_LastCategory);
			}
		}
	}
}

public Action cmdMTConfig(int client, int args)
{
	if (args < 1)
	{
		if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
		{
			switch (IsVoteInProgress())
			{
				case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
				case false: vPathMenu(client);
			}

			vLogCommand(client, MT_CMD_CONFIG, "{default}Opened the config file viewer.");
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
			BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/%s.cfg", sFilename);
			if (!FileExists(g_esGeneral.g_sChosenPath, true))
			{
				BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/mutant_tanks.cfg");
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
	vLogCommand(client, MT_CMD_CONFIG, "{default}Viewed the{mint} %s{default} section of the{olive} %s{default} config file.", sSection, sFilePath);
	vLogMessage(MT_LOG_SERVER, _, "%s %N: Viewed the %s section of the %s config file.", MT_TAG, client, sSection, sFilePath);

	return Plugin_Handled;
}

public Action cmdMTConfig2(int client, int args)
{
	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client))
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
			int iAmount = iClamp(GetCmdArgInt(2), 1, 127);
			g_esGeneral.g_iDeveloperAccess = iAmount;

			vSetupDeveloper(client, true);
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
			BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/%s.cfg", sFilename);
			if (!FileExists(g_esGeneral.g_sChosenPath, true))
			{
				BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/mutant_tanks.cfg");
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
		if (StrEqual(name, MT_CONFIG_SECTION_MAIN, false) || StrEqual(name, MT_NAME, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN2, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN3, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN4, false))
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
	Menu mPathMenu = new Menu(iPathMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
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

		if (g_esPlayer[admin].g_bAdminMenu && bIsValidClient(admin, MT_CHECK_INGAME) && g_esGeneral.g_tmMTMenu != null)
		{
			g_esGeneral.g_tmMTMenu.Display(admin, TopMenuPosition_LastCategory);
		}
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

				if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && param2 == MenuCancel_ExitBack && g_esGeneral.g_tmMTMenu != null)
				{
					g_esGeneral.g_tmMTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
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
			iStartPos = 0;
			iIndex = 0;
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

		if (g_esPlayer[admin].g_bAdminMenu && bIsValidClient(admin, MT_CHECK_INGAME) && g_esGeneral.g_tmMTMenu != null)
		{
			g_esGeneral.g_tmMTMenu.Display(admin, TopMenuPosition_LastCategory);
		}
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
			vLogCommand(param1, MT_CMD_CONFIG, "{default}Viewed the{mint} %s{default} section of the{olive} %s{default} config file.", sInfo, sFilePath);
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
	if (StrEqual(name, MT_CONFIG_SECTION_MAIN, false) || StrEqual(name, MT_NAME, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN2, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN3, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN4, false))
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

public Action cmdMTInfo(int client, int args)
{
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
	mInfoMenu.SetTitle("%s Information", MT_NAME);
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

				if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && param2 == MenuCancel_ExitBack && g_esGeneral.g_tmMTMenu != null)
				{
					g_esGeneral.g_tmMTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
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
	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	vListAbilities(client);
	vLogCommand(client, MT_CMD_LIST, "{default}Checked the list of abilities installed.");
	vLogMessage(MT_LOG_SERVER, _, "%s %N: Checked the list of abilities installed.", MT_TAG, client);

	return Plugin_Handled;
}

public Action cmdMTList2(int client, int args)
{
	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client))
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
			int iAmount = iClamp(GetCmdArgInt(2), 1, 127);
			g_esGeneral.g_iDeveloperAccess = iAmount;

			vSetupDeveloper(client, true);
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
					case false: PrintToServer("%s %T", MT_TAG, "AbilityInstalled2", LANG_SERVER, sFilename);
				}
			}
		}
		else
		{
			switch (bHuman)
			{
				case true: MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoAbilities");
				case false: PrintToServer("%s %T", MT_TAG, "NoAbilities", LANG_SERVER);
			}
		}
	}
	else
	{
		switch (bHuman)
		{
			case true: MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoAbilities");
			case false: PrintToServer("%s %T", MT_TAG, "NoAbilities", LANG_SERVER);
		}
	}
}

public Action cmdMTReload(int client, int args)
{
	vReloadConfig(client);
	vLogCommand(client, MT_CMD_RELOAD, "{default}Reloaded all config files.");
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
		case false: PrintToServer("%s %T", MT_TAG, "ReloadedConfig", LANG_SERVER);
	}
}

public Action cmdMTVersion(int client, int args)
{
	MT_ReplyToCommand(client, "%s %s{yellow} v%s{mint}, by{olive} %s", MT_TAG3, MT_NAME, MT_VERSION, MT_AUTHOR);
	vLogCommand(client, MT_CMD_VERSION, "{default}Checked the current version of{mint} %s{default}.", MT_NAME);
	vLogMessage(MT_LOG_SERVER, _, "%s %N: Checked the current version of %s.", MT_TAG, client, MT_NAME);

	return Plugin_Handled;
}

public Action cmdMTVersion2(int client, int args)
{
	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client))
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
			int iAmount = iClamp(GetCmdArgInt(2), 1, 127);
			g_esGeneral.g_iDeveloperAccess = iAmount;

			vSetupDeveloper(client, true);
			MT_ReplyToCommand(client, "%s %s{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, MT_AUTHOR, iAmount);

			return Plugin_Handled;
		}
	}

	MT_ReplyToCommand(client, "%s %s{yellow} v%s{mint}, by{olive} %s", MT_TAG3, MT_NAME, MT_VERSION, MT_AUTHOR);

	return Plugin_Handled;
}

public Action cmdTank(int client, int args)
{
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

		vLogCommand(client, MT_CMD_SPAWN, "{default}Opened the{mint} %s{default} menu.", MT_NAME);
		vLogMessage(MT_LOG_SERVER, _, "%s %N: Opened the %s menu.", MT_TAG, client, MT_NAME);

		return Plugin_Handled;
	}

	char sCmd[12], sType[33];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	GetCmdArg(1, sType, sizeof(sType));
	int iType = iClamp(StringToInt(sType), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType), iLimit = StrEqual(sType, "psy_dev_access", false) ? 127 : 32, iAmount = iClamp(GetCmdArgInt(2), 1, iLimit), iMode = iClamp(GetCmdArgInt(3), 0, 1);

	if ((IsCharNumeric(sType[0]) && (iType < g_esGeneral.g_iMinType || iType > g_esGeneral.g_iMaxType)) || iAmount > iLimit || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	if (IsCharNumeric(sType[0]) && (g_esTank[iType].g_iTankEnabled == 0 || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bHasCoreAdminAccess(client, iType)))
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
	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		if (!bIsDeveloper(client))
		{
			MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

			return Plugin_Handled;
		}
	}
	else
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

		return Plugin_Handled;
	}

	char sCmd[12], sType[33];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	GetCmdArg(1, sType, sizeof(sType));
	int iType = iClamp(StringToInt(sType), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType), iLimit = StrEqual(sType, "psy_dev_access", false) ? 127 : 32, iAmount = iClamp(GetCmdArgInt(2), 1, iLimit), iMode = iClamp(GetCmdArgInt(3), 0, 1);

	if ((IsCharNumeric(sType[0]) && (iType < g_esGeneral.g_iMinType || iType > g_esGeneral.g_iMaxType)) || iAmount > iLimit || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	if (IsCharNumeric(sType[0]) && (g_esTank[iType].g_iTankEnabled == 0 || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), _, iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, _, _, iAmount, iMode);

	return Plugin_Handled;
}

public Action cmdMutantTank(int client, int args)
{
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

	if (g_esGeneral.g_iSpawnMode == 1 && !bIsTank(client) && !CheckCommandAccess(client, "sm_mutanttank", ADMFLAG_ROOT, true) && !bIsDeveloper(client))
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

	char sCmd[12], sType[33];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	GetCmdArg(1, sType, sizeof(sType));
	int iType = iClamp(StringToInt(sType), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType), iLimit = StrEqual(sType, "psy_dev_access", false) ? 127 : 32, iAmount = iClamp(GetCmdArgInt(2), 1, iLimit), iMode = iClamp(GetCmdArgInt(3), 0, 1);

	if ((IsCharNumeric(sType[0]) && (iType < g_esGeneral.g_iMinType || iType > g_esGeneral.g_iMaxType)) || iAmount > iLimit || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	if (IsCharNumeric(sType[0]) && (g_esTank[iType].g_iTankEnabled == 0 || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), _, iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, _, _, iAmount, iMode);

	return Plugin_Handled;
}

static void vTank(int admin, char[] type, bool spawn = false, bool log = true, int amount = 1, int mode = 0)
{
	int iType = StringToInt(type);

	switch (iType)
	{
		case 0:
		{
			if (bIsValidClient(admin) && bIsDeveloper(admin) && StrEqual(type, "psy_dev_access", false))
			{
				g_esGeneral.g_iDeveloperAccess = amount;

				vSetupDeveloper(admin, true);
				MT_PrintToChat(admin, "%s %s{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, MT_AUTHOR, amount);

				return;
			}
			else
			{
				char sPhrase[32], sTankName[33];
				int iTypeCount = 0, iTankTypes[MT_MAXTYPES + 1];
				for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
				{
					vGetTranslatedName(sPhrase, sizeof(sPhrase), _, iIndex);
					SetGlobalTransTarget(admin);
					FormatEx(sTankName, sizeof(sTankName), "%T", sPhrase, admin);
					if (g_esTank[iIndex].g_iTankEnabled == 0 || !bHasCoreAdminAccess(admin, iIndex) || g_esTank[iIndex].g_iMenuEnabled == 0 || !bIsTypeAvailable(iIndex, admin) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(admin, g_esTank[iIndex].g_flOpenAreasOnly) || StrContains(sTankName, type, false) == -1)
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
		default: g_esGeneral.g_iChosenType = iClamp(iType, g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);
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
							if ((GetClientButtons(admin) & IN_SPEED) && (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT, true) || CheckCommandAccess(admin, "sm_mt_tank", ADMFLAG_ROOT, true) || bIsDeveloper(admin)))
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
			switch (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT, true) || CheckCommandAccess(admin, "sm_mt_tank", ADMFLAG_ROOT, true) || bIsDeveloper(admin))
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
			char sClassname[32];
			GetEntityClassname(iTarget, sClassname, sizeof(sClassname));
			if (StrEqual(sClassname, "player"))
			{
				vSetColor(iTarget, g_esGeneral.g_iChosenType);
				vTankSpawn(iTarget, 5);

				if (bIsTank(iTarget, MT_CHECK_FAKECLIENT))
				{
					vExternalView(iTarget, 1.5);
				}

				g_esGeneral.g_iChosenType = 0;
			}
			else
			{
				vSpawnTank(admin, _, amount, mode);
			}
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
	char sParameter[32];
	sParameter = (mode == 0) ? "tank" : "tank auto";
	int iType = g_esGeneral.g_iChosenType;
	g_esGeneral.g_bForceSpawned = true;

	switch (amount)
	{
		case 1: vCheatCommand(admin, (g_bSecondGame ? "z_spawn_old" : "z_spawn"), sParameter);
		default:
		{
			for (int iAmount = 0; iAmount <= amount; iAmount++)
			{
				if (iAmount < amount)
				{
					if (bIsValidClient(admin))
					{
						vCheatCommand(admin, (g_bSecondGame ? "z_spawn_old" : "z_spawn"), sParameter);

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
		vLogCommand(admin, MT_CMD_SPAWN, "{default}Spawned{mint} %i{olive} %s%s{default}.", amount, g_esTank[iType].g_sTankName, ((amount > 1) ? "s" : ""));
		vLogMessage(MT_LOG_SERVER, _, "%s %N: Spawned %i %s%s.", MT_TAG, admin, amount, g_esTank[iType].g_sTankName, ((amount > 1) ? "s" : ""));
	}
}

static void vTankMenu(int admin, bool adminmenu = false, int item = 0)
{
	Menu mTankMenu = new Menu(iTankMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mTankMenu.SetTitle("%s List", MT_NAME);

	static int iCount;
	iCount = 0;

	if (bIsTank(admin))
	{
		mTankMenu.AddItem("Default Tank", "Default Tank", ((g_esPlayer[admin].g_iTankType > 0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
		iCount++;
	}

	static char sIndex[5], sMenuItem[46], sTankName[33];
	for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
	{
		if (g_esTank[iIndex].g_iTankEnabled == 0 || !bHasCoreAdminAccess(admin, iIndex) || g_esTank[iIndex].g_iMenuEnabled == 0 || !bIsTypeAvailable(iIndex, admin) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(admin, g_esTank[iIndex].g_flOpenAreasOnly))
		{
			continue;
		}

		vGetTranslatedName(sTankName, sizeof(sTankName), _, iIndex);
		SetGlobalTransTarget(admin);
		FormatEx(sMenuItem, sizeof(sMenuItem), "%T", "MTTankItem", admin, sTankName, iIndex);
		IntToString(iIndex, sIndex, sizeof(sIndex));
		mTankMenu.AddItem(sIndex, sMenuItem, ((g_esPlayer[admin].g_iTankType != iIndex) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
		iCount++;
	}

	g_esPlayer[admin].g_bAdminMenu = adminmenu;
	mTankMenu.ExitBackButton = g_esPlayer[admin].g_bAdminMenu;

	if (iCount > 0)
	{
		mTankMenu.DisplayAt(admin, item, MENU_TIME_FOREVER);
	}
	else
	{
		MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoItems");

		delete mTankMenu;

		if (g_esPlayer[admin].g_bAdminMenu && bIsValidClient(admin, MT_CHECK_INGAME) && g_esGeneral.g_tmMTMenu != null)
		{
			g_esGeneral.g_tmMTMenu.Display(admin, TopMenuPosition_LastCategory);
		}
	}
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

				if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && param2 == MenuCancel_ExitBack && g_esGeneral.g_tmMTMenu != null)
				{
					g_esGeneral.g_tmMTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
			}
		}
		case MenuAction_Select:
		{
			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			if (StrEqual(sInfo, "Default Tank", false))
			{
				vQueueTank(param1, g_esPlayer[param1].g_iTankType, false);
			}
			else
			{
				int iIndex = StringToInt(sInfo);
				if (g_esTank[iIndex].g_iTankEnabled == 1 && bHasCoreAdminAccess(param1, iIndex) && g_esTank[iIndex].g_iMenuEnabled == 1 && bIsTypeAvailable(iIndex, param1) && !bAreHumansRequired(iIndex) && bCanTypeSpawn(iIndex) && !bIsAreaNarrow(param1, g_esTank[iIndex].g_flOpenAreasOnly))
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
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH], sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			if (StrEqual(sInfo, "Default Tank", false))
			{
				FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "MTDefaultItem", param1);

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (g_esGeneral.g_bPluginEnabled && bIsValidEntity(entity))
	{
		g_esGeneral.g_iTeamID[entity] = 0;

		if (StrEqual(classname, "tank_rock"))
		{
			RequestFrame(vRockThrowFrame, EntIndexToEntRef(entity));
		}
		else if (StrEqual(classname, "infected") || StrEqual(classname, "witch"))
		{
			SDKHook(entity, SDKHook_OnTakeDamage, OnTakePlayerDamage);
			SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
		}
		else if (StrEqual(classname, "inferno") || StrEqual(classname, "pipe_bomb_projectile") || (g_bSecondGame && (StrEqual(classname, "fire_cracker_blast") || StrEqual(classname, "grenade_launcher_projectile"))))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnSpawnPost);
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
			if (bIsTankSupported(iThrower) && bHasCoreAdminAccess(iThrower) && !bIsTankIdle(iThrower) && g_esTank[g_esPlayer[iThrower].g_iTankType].g_iTankEnabled == 1)
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
		}
	}
}

public void OnGameFrame()
{
	if (g_esGeneral.g_bPluginEnabled)
	{
		static char sClassname[32], sHealthBar[51], sSet[2][2];
		static float flPercentage;
		static int iTarget, iHealth;
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

					GetEntityClassname(iTarget, sClassname, sizeof(sClassname));
					if (StrEqual(sClassname, "player"))
					{
						sHealthBar[0] = '\0';
						iHealth = (g_esPlayer[iTarget].g_bDying) ? 0 : GetEntProp(iTarget, Prop_Data, "m_iHealth");
						flPercentage = (float(iHealth) / float(g_esPlayer[iTarget].g_iTankHealth)) * 100;

						ReplaceString(g_esCache[iTarget].g_sHealthCharacters, sizeof(esCache::g_sHealthCharacters), " ", "");
						ExplodeString(g_esCache[iTarget].g_sHealthCharacters, ",", sSet, sizeof(sSet), sizeof(sSet[]));

						for (int iCount = 0; iCount < (float(iHealth) / float(g_esPlayer[iTarget].g_iTankHealth)) * sizeof(sHealthBar) - 1 && iCount < sizeof(sHealthBar) - 1; iCount++)
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
									case 3: PrintHintText(iPlayer, "%i/%i HP (%.0f%s)", iHealth, g_esPlayer[iTarget].g_iTankHealth, flPercentage, "%%");
									case 4: PrintHintText(iPlayer, "HP: |-<%s>-|", sHealthBar);
									case 5: PrintHintText(iPlayer, "%t %s (%i HP)", sTankName, (bHuman ? sHumanTag : ""), iHealth);
									case 6: PrintHintText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]", sTankName, (bHuman ? sHumanTag : ""), iHealth, g_esPlayer[iTarget].g_iTankHealth, flPercentage, "%%");
									case 7: PrintHintText(iPlayer, "%t %s\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), sHealthBar);
									case 8: PrintHintText(iPlayer, "%i HP\nHP: |-<%s>-|", iHealth, sHealthBar);
									case 9: PrintHintText(iPlayer, "%i/%i HP (%.0f%s)\nHP: |-<%s>-|", iHealth, g_esPlayer[iTarget].g_iTankHealth, flPercentage, "%%", sHealthBar);
									case 10: PrintHintText(iPlayer, "%t %s (%i HP)\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, sHealthBar);
									case 11: PrintHintText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, g_esPlayer[iTarget].g_iTankHealth, flPercentage, "%%", sHealthBar);
								}
							}
							case 2:
							{
								switch (g_esCache[iTarget].g_iDisplayHealth)
								{
									case 1: PrintCenterText(iPlayer, "%t %s", sTankName, (bHuman ? sHumanTag : ""));
									case 2: PrintCenterText(iPlayer, "%i HP", iHealth);
									case 3: PrintCenterText(iPlayer, "%i/%i HP (%.0f%s)", iHealth, g_esPlayer[iTarget].g_iTankHealth, flPercentage, "%%");
									case 4: PrintCenterText(iPlayer, "HP: |-<%s>-|", sHealthBar);
									case 5: PrintCenterText(iPlayer, "%t %s (%i HP)", sTankName, (bHuman ? sHumanTag : ""), iHealth);
									case 6: PrintCenterText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]", sTankName, (bHuman ? sHumanTag : ""), iHealth, g_esPlayer[iTarget].g_iTankHealth, flPercentage, "%%");
									case 7: PrintCenterText(iPlayer, "%t %s\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), sHealthBar);
									case 8: PrintCenterText(iPlayer, "%i HP\nHP: |-<%s>-|", iHealth, sHealthBar);
									case 9: PrintCenterText(iPlayer, "%i/%i HP (%.0f%s)\nHP: |-<%s>-|", iHealth, g_esPlayer[iTarget].g_iTankHealth, flPercentage, "%%", sHealthBar);
									case 10: PrintCenterText(iPlayer, "%t %s (%i HP)\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, sHealthBar);
									case 11: PrintCenterText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, g_esPlayer[iTarget].g_iTankHealth, flPercentage, "%%", sHealthBar);
								}
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(client))
	{
		return Plugin_Continue;
	}

	if ((buttons & IN_ATTACK) && !g_esPlayer[client].g_bAttackedAgain)
	{
		g_esPlayer[client].g_bAttackedAgain = true;
	}

	if (bIsTankSupported(client, MT_CHECK_FAKECLIENT))
	{
		static int iButton;
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

	return Plugin_Continue;
}

public void OnSpawnPost(int entity)
{
	int iAttacker = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (bIsTank(iAttacker, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esGeneral.g_iTeamID[entity] = GetClientTeam(iAttacker);
	}
}

public void OnPropSpawnPost(int entity)
{
	static char sModel[45];
	GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	if (StrEqual(sModel, MODEL_JETPACK) || StrEqual(sModel, MODEL_PROPANETANK) || StrEqual(sModel, MODEL_GASCAN) || (g_bSecondGame && StrEqual(sModel, MODEL_FIREWORKCRATE)))
	{
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
	}
}

public void OnSpeedPreThinkPost(int survivor)
{
	switch (bIsSurvivor(survivor) && (bIsDeveloper(survivor, 6) || g_esPlayer[survivor].g_bRewardedSpeed))
	{
		case true: SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", (g_esPlayer[survivor].g_bRewardedSpeed ? g_esPlayer[survivor].g_flSpeedBoost : 1.25));
		case false: vSetupDeveloper(survivor, false);
	}
}

public Action OnTakeCombineDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage >= 0.5)
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
	if (g_esGeneral.g_bPluginEnabled && damage >= 0.5)
	{
		static char sClassname[32];
		sClassname[0] = '\0';
		static int iTank, iTank2;
		if (bIsValidEntity(inflictor))
		{
			iTank = HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity") : 0;
			iTank2 = HasEntProp(inflictor, Prop_Data, "m_hThrower") ? GetEntPropEnt(inflictor, Prop_Data, "m_hThrower") : 0;
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		}

		static bool bDeveloper;
		bDeveloper = bIsValidClient(victim) && bIsDeveloper(victim, 5);
		if (bIsTankSupported(attacker) && bIsSurvivor(victim))
		{
			vSaveSurvivorStats(victim, true);

			if (bHasCoreAdminAccess(attacker) && !bIsCoreAdminImmune(victim, attacker))
			{
				if (StrEqual(sClassname, "weapon_tank_claw") && g_esCache[attacker].g_flClawDamage >= 0.0)
				{
					damage = flGetScaledDamage(g_esCache[attacker].g_flClawDamage);
					damage = (bIsHumanSurvivor(victim) && bDeveloper) ? (damage * 0.5) : damage;

					return (g_esCache[attacker].g_flClawDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
				}
				else if ((damagetype & DMG_CRUSH) && bIsValidEntity(inflictor) && HasEntProp(inflictor, Prop_Send, "m_isCarryable") && g_esCache[attacker].g_flHittableDamage >= 0.0)
				{
					damage = flGetScaledDamage(g_esCache[attacker].g_flHittableDamage);
					damage = (bIsHumanSurvivor(victim) && bDeveloper) ? (damage * 0.5) : damage;

					return (g_esCache[attacker].g_flHittableDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
				}
				else if (StrEqual(sClassname, "tank_rock") && !bIsValidEntity(iTank) && g_esCache[attacker].g_flRockDamage >= 0.0)
				{
					damage = flGetScaledDamage(g_esCache[attacker].g_flRockDamage);
					damage = (bIsHumanSurvivor(victim) && bDeveloper) ? (damage * 0.5) : damage;

					return (g_esCache[attacker].g_flRockDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
				}
			}
			else if (bIsHumanSurvivor(victim) && bDeveloper)
			{
				damage *= 0.5;

				return Plugin_Changed;
			}
		}
		else if (bIsHumanSurvivor(victim) && bDeveloper)
		{
			damage *= 0.5;

			return Plugin_Changed;
		}
		else if (bIsInfected(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) || bIsCommonInfected(victim) || bIsWitch(victim))
		{
			bDeveloper = bIsValidClient(attacker) && bIsDeveloper(attacker, 4);
			if (bIsTankSupported(victim) && bHasCoreAdminAccess(victim))
			{
				if (StrEqual(sClassname, "tank_rock"))
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
					if (bBlockFire)
					{
						ExtinguishEntity(victim);
					}

					if (bBlockBullets || bBlockMelee)
					{
						EmitSoundToAll(SOUND_METAL, victim);

						if (bBlockMelee)
						{
							static float flTankPos[3];
							GetClientAbsOrigin(victim, flTankPos);
							vPushNearbyEntities(victim, flTankPos);
						}
					}

					return Plugin_Handled;
				}

				if (bIsSurvivor(attacker) && (damagetype & DMG_BURN) && g_esGeneral.g_iCreditIgniters == 0)
				{
					if (bIsSurvivor(attacker) && (bDeveloper || g_esPlayer[attacker].g_bRewardedDamage))
					{
						damage *= g_esPlayer[attacker].g_bRewardedDamage ? g_esPlayer[attacker].g_flDamageBoost : 1.75;
					}

					inflictor = 0;
					attacker = 0;

					return Plugin_Changed;
				}
			}

			if (bIsSurvivor(attacker) && (bDeveloper || g_esPlayer[attacker].g_bRewardedDamage))
			{
				damage *= g_esPlayer[attacker].g_bRewardedDamage ? g_esPlayer[attacker].g_flDamageBoost : 1.75;

				return Plugin_Changed;
			}
			else if ((bIsTankSupported(attacker) && victim != attacker) || (bIsTankSupported(iTank) && victim != iTank) || (bIsTankSupported(iTank2) && victim != iTank2))
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

public Action OnTakePropDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && (bIsInfected(victim) || bIsCommonInfected(victim) || bIsWitch(victim)) && damage >= 0.5)
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

public Action SetTransmit(int entity, int client)
{
	int iOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (g_esGeneral.g_bPluginEnabled && bIsValidClient(iOwner) && bIsValidClient(client) && iOwner == client && !bIsTankInThirdPerson(client))
	{
		return Plugin_Handled;
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

static void vCacheSettings(int tank)
{
	static bool bAccess, bHuman;
	bAccess = bIsTankSupported(tank) && bHasCoreAdminAccess(tank);
	bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	static int iType;
	iType = g_esPlayer[tank].g_iTankType;
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sComboSet, sizeof(esCache::g_sComboSet), g_esPlayer[tank].g_sComboSet, g_esTank[iType].g_sComboSet);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sHealthCharacters, sizeof(esCache::g_sHealthCharacters), g_esTank[iType].g_sHealthCharacters, g_esGeneral.g_sHealthCharacters);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sHealthCharacters, sizeof(esCache::g_sHealthCharacters), g_esPlayer[tank].g_sHealthCharacters, g_esCache[tank].g_sHealthCharacters);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward, sizeof(esCache::g_sItemReward), g_esTank[iType].g_sItemReward, g_esGeneral.g_sItemReward);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward, sizeof(esCache::g_sItemReward), g_esPlayer[tank].g_sItemReward, g_esCache[tank].g_sItemReward);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward2, sizeof(esCache::g_sItemReward2), g_esTank[iType].g_sItemReward2, g_esGeneral.g_sItemReward2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward2, sizeof(esCache::g_sItemReward2), g_esPlayer[tank].g_sItemReward2, g_esCache[tank].g_sItemReward2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward3, sizeof(esCache::g_sItemReward3), g_esTank[iType].g_sItemReward3, g_esGeneral.g_sItemReward3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward3, sizeof(esCache::g_sItemReward3), g_esPlayer[tank].g_sItemReward3, g_esCache[tank].g_sItemReward3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sTankName, sizeof(esCache::g_sTankName), g_esPlayer[tank].g_sTankName, g_esTank[iType].g_sTankName);
	g_esCache[tank].g_flAttackInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flAttackInterval, g_esTank[iType].g_flAttackInterval);
	g_esCache[tank].g_flBurntSkin = flGetSettingValue(bAccess, true, g_esTank[iType].g_flBurntSkin, g_esGeneral.g_flBurntSkin, 1);
	g_esCache[tank].g_flBurntSkin = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flBurntSkin, g_esCache[tank].g_flBurntSkin, 1);
	g_esCache[tank].g_flClawDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flClawDamage, g_esTank[iType].g_flClawDamage, 1);
	g_esCache[tank].g_flHittableDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flHittableDamage, g_esTank[iType].g_flHittableDamage, 1);
	g_esCache[tank].g_flRandomDuration = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRandomDuration, g_esTank[iType].g_flRandomDuration);
	g_esCache[tank].g_flRandomInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRandomInterval, g_esTank[iType].g_flRandomInterval);
	g_esCache[tank].g_flRockDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRockDamage, g_esTank[iType].g_flRockDamage, 1);
	g_esCache[tank].g_flRunSpeed = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRunSpeed, g_esTank[iType].g_flRunSpeed);
	g_esCache[tank].g_flThrowInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flThrowInterval, g_esTank[iType].g_flThrowInterval);
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
	g_esCache[tank].g_iBaseHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iBaseHealth, g_esGeneral.g_iBaseHealth);
	g_esCache[tank].g_iBaseHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBaseHealth, g_esCache[tank].g_iBaseHealth);
	g_esCache[tank].g_iBodyEffects = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBodyEffects, g_esTank[iType].g_iBodyEffects);
	g_esCache[tank].g_iBossStages = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossStages, g_esTank[iType].g_iBossStages);
	g_esCache[tank].g_iBulletImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBulletImmunity, g_esTank[iType].g_iBulletImmunity);
	g_esCache[tank].g_iDeathMessage = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathMessage, g_esGeneral.g_iDeathMessage);
	g_esCache[tank].g_iDeathMessage = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathMessage, g_esCache[tank].g_iDeathMessage);
	g_esCache[tank].g_iDeathRevert = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathRevert, g_esGeneral.g_iDeathRevert);
	g_esCache[tank].g_iDeathRevert = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathRevert, g_esCache[tank].g_iDeathRevert);
	g_esCache[tank].g_iDetectPlugins = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDetectPlugins, g_esGeneral.g_iDetectPlugins);
	g_esCache[tank].g_iDetectPlugins = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDetectPlugins, g_esCache[tank].g_iDetectPlugins);
	g_esCache[tank].g_iDisplayHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDisplayHealth, g_esGeneral.g_iDisplayHealth);
	g_esCache[tank].g_iDisplayHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDisplayHealth, g_esCache[tank].g_iDisplayHealth);
	g_esCache[tank].g_iDisplayHealthType = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDisplayHealthType, g_esGeneral.g_iDisplayHealthType);
	g_esCache[tank].g_iDisplayHealthType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDisplayHealthType, g_esCache[tank].g_iDisplayHealthType);
	g_esCache[tank].g_iExplosiveImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iExplosiveImmunity, g_esTank[iType].g_iExplosiveImmunity);
	g_esCache[tank].g_iExtraHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iExtraHealth, g_esGeneral.g_iExtraHealth, 2);
	g_esCache[tank].g_iExtraHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iExtraHealth, g_esCache[tank].g_iExtraHealth, 2);
	g_esCache[tank].g_iFireImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFireImmunity, g_esTank[iType].g_iFireImmunity);
	g_esCache[tank].g_iGlowEnabled = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowEnabled, g_esTank[iType].g_iGlowEnabled);
	g_esCache[tank].g_iGlowFlashing = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowFlashing, g_esTank[iType].g_iGlowFlashing);
	g_esCache[tank].g_iGlowMaxRange = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowMaxRange, g_esTank[iType].g_iGlowMaxRange);
	g_esCache[tank].g_iGlowMinRange = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowMinRange, g_esTank[iType].g_iGlowMinRange);
	g_esCache[tank].g_iGlowType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowType, g_esTank[iType].g_iGlowType);
	g_esCache[tank].g_iHittableImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iHittableImmunity, g_esTank[iType].g_iHittableImmunity);
	g_esCache[tank].g_iKillMessage = iGetSettingValue(bAccess, true, g_esTank[iType].g_iKillMessage, g_esGeneral.g_iKillMessage);
	g_esCache[tank].g_iKillMessage = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iKillMessage, g_esCache[tank].g_iKillMessage);
	g_esCache[tank].g_iMeleeImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMeleeImmunity, g_esTank[iType].g_iMeleeImmunity);
	g_esCache[tank].g_iMinimumHumans = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMinimumHumans, g_esGeneral.g_iMinimumHumans);
	g_esCache[tank].g_iMinimumHumans = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMinimumHumans, g_esCache[tank].g_iMinimumHumans);
	g_esCache[tank].g_iMultiHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMultiHealth, g_esGeneral.g_iMultiHealth);
	g_esCache[tank].g_iMultiHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMultiHealth, g_esCache[tank].g_iMultiHealth);
	g_esCache[tank].g_iPropsAttached = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iPropsAttached, g_esTank[iType].g_iPropsAttached);
	g_esCache[tank].g_iRandomTank = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRandomTank, g_esTank[iType].g_iRandomTank);
	g_esCache[tank].g_iRockEffects = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockEffects, g_esTank[iType].g_iRockEffects);
	g_esCache[tank].g_iRockModel = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockModel, g_esTank[iType].g_iRockModel);
	g_esCache[tank].g_iSpawnType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSpawnType, g_esTank[iType].g_iSpawnType);
	g_esCache[tank].g_iTankModel = iGetSettingValue(bAccess, true, g_esTank[iType].g_iTankModel, g_esGeneral.g_iTankModel);
	g_esCache[tank].g_iTankModel = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTankModel, g_esCache[tank].g_iTankModel);
	g_esCache[tank].g_iTankNote = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTankNote, g_esTank[iType].g_iTankNote);

	for (int iPos = 0; iPos < sizeof(esCache::g_iTransformType); iPos++)
	{
		g_esCache[tank].g_iTransformType[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTransformType[iPos], g_esTank[iType].g_iTransformType[iPos]);

		if (iPos < sizeof(esCache::g_iRewardEnabled))
		{
			g_esCache[tank].g_flDamageBoostReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flDamageBoostReward[iPos], g_esGeneral.g_flDamageBoostReward[iPos]);
			g_esCache[tank].g_flDamageBoostReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flDamageBoostReward[iPos], g_esCache[tank].g_flDamageBoostReward[iPos]);
			g_esCache[tank].g_flRewardChance[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRewardChance[iPos], g_esGeneral.g_flRewardChance[iPos]);
			g_esCache[tank].g_flRewardChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRewardChance[iPos], g_esCache[tank].g_flRewardChance[iPos]);
			g_esCache[tank].g_flRewardDuration[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRewardDuration[iPos], g_esGeneral.g_flRewardDuration[iPos]);
			g_esCache[tank].g_flRewardDuration[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRewardDuration[iPos], g_esCache[tank].g_flRewardDuration[iPos]);
			g_esCache[tank].g_flRewardPercentage[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRewardPercentage[iPos], g_esGeneral.g_flRewardPercentage[iPos]);
			g_esCache[tank].g_flRewardPercentage[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRewardPercentage[iPos], g_esCache[tank].g_flRewardPercentage[iPos]);
			g_esCache[tank].g_iRewardEffect[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardEffect[iPos], g_esGeneral.g_iRewardEffect[iPos]);
			g_esCache[tank].g_iRewardEffect[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardEffect[iPos], g_esCache[tank].g_iRewardEffect[iPos]);
			g_esCache[tank].g_iRewardEnabled[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardEnabled[iPos], g_esGeneral.g_iRewardEnabled[iPos], 1);
			g_esCache[tank].g_iRewardEnabled[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardEnabled[iPos], g_esCache[tank].g_iRewardEnabled[iPos], 1);
			g_esCache[tank].g_iRespawnLoadoutReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRespawnLoadoutReward[iPos], g_esGeneral.g_iRespawnLoadoutReward[iPos]);
			g_esCache[tank].g_iRespawnLoadoutReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRespawnLoadoutReward[iPos], g_esCache[tank].g_iRespawnLoadoutReward[iPos]);
			g_esCache[tank].g_flSpeedBoostReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flSpeedBoostReward[iPos], g_esGeneral.g_flSpeedBoostReward[iPos]);
			g_esCache[tank].g_flSpeedBoostReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flSpeedBoostReward[iPos], g_esCache[tank].g_flSpeedBoostReward[iPos]);
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
	g_esPlayer[newSurvivor].g_bRewardedAmmo = g_esPlayer[oldSurvivor].g_bRewardedAmmo;
	g_esPlayer[newSurvivor].g_bRewardedDamage = g_esPlayer[oldSurvivor].g_bRewardedDamage;
	g_esPlayer[newSurvivor].g_bRewardedGod = g_esPlayer[oldSurvivor].g_bRewardedGod;
	g_esPlayer[newSurvivor].g_bRewardedHealth = g_esPlayer[oldSurvivor].g_bRewardedHealth;
	g_esPlayer[newSurvivor].g_bRewardedItem = g_esPlayer[oldSurvivor].g_bRewardedItem;
	g_esPlayer[newSurvivor].g_bRewardedRefill = g_esPlayer[oldSurvivor].g_bRewardedRefill;
	g_esPlayer[newSurvivor].g_bRewardedRespawn = g_esPlayer[oldSurvivor].g_bRewardedRespawn;
	g_esPlayer[newSurvivor].g_bRewardedSpeed = g_esPlayer[oldSurvivor].g_bRewardedSpeed;
	g_esPlayer[newSurvivor].g_flDamageBoost = g_esPlayer[oldSurvivor].g_flDamageBoost;
	g_esPlayer[newSurvivor].g_flSpeedBoost = g_esPlayer[oldSurvivor].g_flSpeedBoost;

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		g_esPlayer[newSurvivor].g_iTankDamage[iTank] = g_esPlayer[oldSurvivor].g_iTankDamage[iTank];
	}
}

static void vCopyTankStats(int tank, int newtank)
{
	SetEntProp(newtank, Prop_Data, "m_iMaxHealth", GetEntProp(tank, Prop_Data, "m_iMaxHealth"));

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
	CreateDataTimer(3.0, tTimerExecuteCustomConfig, dpConfig, TIMER_FLAG_NO_MAPCHANGE);
	dpConfig.WriteString(savepath);
}

static void vLoadConfigs(const char[] savepath, int mode)
{
	vClearPluginList();
	g_esGeneral.g_alPlugins = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	if (g_esGeneral.g_alPlugins != null)
	{
		Call_StartForward(g_esGeneral.g_gfPluginCheckForward);
		Call_PushArrayEx(g_esGeneral.g_alPlugins, MT_MAXABILITIES + 1, SM_PARAM_COPYBACK);
		Call_Finish();
	}

	Call_StartForward(g_esGeneral.g_gfAbilityCheckForward);

	vClearAbilityList();
	for (int iPos = 0; iPos < sizeof(esGeneral::g_alAbilitySections); iPos++)
	{
		g_esGeneral.g_alAbilitySections[iPos] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
		Call_PushArrayEx(g_esGeneral.g_alAbilitySections[iPos], MT_MAXABILITIES + 1, SM_PARAM_COPYBACK);
	}

	Call_Finish();

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
		g_esGeneral.g_iDeathRevert = 1;
		g_esGeneral.g_iDetectPlugins = 1;
		g_esGeneral.g_iFinalesOnly = 0;
		g_esGeneral.g_flIdleCheck = 10.0;
		g_esGeneral.g_iIdleCheckMode = 2;
		g_esGeneral.g_iLogCommands = 31;
		g_esGeneral.g_iLogMessages = 0;
		g_esGeneral.g_iTankModel = 0;
		g_esGeneral.g_flBurntSkin = -1.0;
		g_esGeneral.g_iMinType = 1;
		g_esGeneral.g_iMaxType = MT_MAXTYPES;
		g_esGeneral.g_iRequiresHumans = 0;
		g_esGeneral.g_iAnnounceArrival = 31;
		g_esGeneral.g_iAnnounceDeath = 1;
		g_esGeneral.g_iAnnounceKill = 1;
		g_esGeneral.g_iArrivalMessage = 0;
		g_esGeneral.g_iDeathMessage = 0;
		g_esGeneral.g_iKillMessage = 0;
		g_esGeneral.g_sItemReward = "first_aid_kit";
		g_esGeneral.g_sItemReward2 = "first_aid_kit";
		g_esGeneral.g_sItemReward3 = "first_aid_kit";
		g_esGeneral.g_iAggressiveTanks = 0;
		g_esGeneral.g_iCreditIgniters = 1;
		g_esGeneral.g_iStasisMode = 0;
		g_esGeneral.g_iScaleDamage = 0;
		g_esGeneral.g_iBaseHealth = 0;
		g_esGeneral.g_iDisplayHealth = 11;
		g_esGeneral.g_iDisplayHealthType = 1;
		g_esGeneral.g_iExtraHealth = 0;
		g_esGeneral.g_sHealthCharacters = "|,-";
		g_esGeneral.g_iMinimumHumans = 2;
		g_esGeneral.g_iMultiHealth = 0;
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
		g_esGeneral.g_iRegularMinType = 0;
		g_esGeneral.g_iRegularMaxType = 0;
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
			g_esGeneral.g_iFinaleMaxTypes[iPos] = 0;
			g_esGeneral.g_iFinaleMinTypes[iPos] = 0;
			g_esGeneral.g_iFinaleWave[iPos] = 0;

			if (iPos < sizeof(esGeneral::g_iRewardEnabled))
			{
				g_esGeneral.g_iRewardEffect[iPos] = 15;
				g_esGeneral.g_iRewardEnabled[iPos] = -1;
				g_esGeneral.g_flRewardChance[iPos] = 33.3;
				g_esGeneral.g_flRewardDuration[iPos] = 10.0;
				g_esGeneral.g_flRewardPercentage[iPos] = 10.0;
				g_esGeneral.g_flDamageBoostReward[iPos] = 1.25;
				g_esGeneral.g_iRespawnLoadoutReward[iPos] = 1;
				g_esGeneral.g_flSpeedBoostReward[iPos] = 1.25;
				g_esGeneral.g_iUsefulRewards[iPos] = 15;
			}

			if (iPos < sizeof(esGeneral::g_flDifficultyDamage))
			{
				g_esGeneral.g_flDifficultyDamage[iPos] = 0.0;
			}
		}

		for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
		{
			g_esTank[iIndex].g_iAbilityCount = -1;

			FormatEx(g_esTank[iIndex].g_sTankName, sizeof(esTank::g_sTankName), "Tank #%i", iIndex);
			g_esTank[iIndex].g_iTankEnabled = 0;
			g_esTank[iIndex].g_flTankChance = 100.0;
			g_esTank[iIndex].g_iTankModel = 0;
			g_esTank[iIndex].g_flBurntSkin = -1.0;
			g_esTank[iIndex].g_iTankNote = 0;
			g_esTank[iIndex].g_iSpawnEnabled = 1;
			g_esTank[iIndex].g_iMenuEnabled = 1;
			g_esTank[iIndex].g_iDeathRevert = 0;
			g_esTank[iIndex].g_iDetectPlugins = 0;
			g_esTank[iIndex].g_iAnnounceArrival = 0;
			g_esTank[iIndex].g_iAnnounceDeath = 0;
			g_esTank[iIndex].g_iAnnounceKill = 0;
			g_esTank[iIndex].g_iArrivalMessage = 0;
			g_esTank[iIndex].g_iDeathMessage = 0;
			g_esTank[iIndex].g_iKillMessage = 0;
			g_esTank[iIndex].g_sItemReward[0] = '\0';
			g_esTank[iIndex].g_sItemReward2[0] = '\0';
			g_esTank[iIndex].g_sItemReward3[0] = '\0';
			g_esTank[iIndex].g_iBaseHealth = 0;
			g_esTank[iIndex].g_iDisplayHealth = 0;
			g_esTank[iIndex].g_iDisplayHealthType = 0;
			g_esTank[iIndex].g_iExtraHealth = 0;
			g_esTank[iIndex].g_sHealthCharacters[0] = '\0';
			g_esTank[iIndex].g_iMinimumHumans = 0;
			g_esTank[iIndex].g_iMultiHealth = 0;
			g_esTank[iIndex].g_iHumanSupport = 0;
			g_esTank[iIndex].g_iGlowEnabled = 0;
			g_esTank[iIndex].g_iGlowFlashing = 0;
			g_esTank[iIndex].g_iGlowMinRange = 0;
			g_esTank[iIndex].g_iGlowMaxRange = 999999;
			g_esTank[iIndex].g_iGlowType = 0;
			g_esTank[iIndex].g_flOpenAreasOnly = 0.0;
			g_esTank[iIndex].g_iRequiresHumans = 0;
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
			g_esTank[iIndex].g_flRockDamage = -1.0;
			g_esTank[iIndex].g_flRunSpeed = 0.0;
			g_esTank[iIndex].g_flThrowInterval = 0.0;
			g_esTank[iIndex].g_iBulletImmunity = 0;
			g_esTank[iIndex].g_iExplosiveImmunity = 0;
			g_esTank[iIndex].g_iFireImmunity = 0;
			g_esTank[iIndex].g_iHittableImmunity = 0;
			g_esTank[iIndex].g_iMeleeImmunity = 0;

			for (int iPos = 0; iPos < sizeof(esTank::g_iTransformType); iPos++)
			{
				g_esTank[iIndex].g_iTransformType[iPos] = iPos + 1;

				if (iPos < sizeof(esTank::g_iRewardEnabled))
				{
					g_esTank[iIndex].g_iRewardEffect[iPos] = 0;
					g_esTank[iIndex].g_iRewardEnabled[iPos] = -1;
					g_esTank[iIndex].g_flRewardChance[iPos] = 0.0;
					g_esTank[iIndex].g_flRewardDuration[iPos] = 0.0;
					g_esTank[iIndex].g_flRewardPercentage[iPos] = 0.0;
					g_esTank[iIndex].g_flDamageBoostReward[iPos] = 0.0;
					g_esTank[iIndex].g_iRespawnLoadoutReward[iPos] = 0;
					g_esTank[iIndex].g_flSpeedBoostReward[iPos] = 0.0;
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
				g_esPlayer[iPlayer].g_flBurntSkin = -1.0;
				g_esPlayer[iPlayer].g_iTankNote = 0;
				g_esPlayer[iPlayer].g_iDeathRevert = 0;
				g_esPlayer[iPlayer].g_iDetectPlugins = 0;
				g_esPlayer[iPlayer].g_iAnnounceArrival = 0;
				g_esPlayer[iPlayer].g_iAnnounceDeath = 0;
				g_esPlayer[iPlayer].g_iAnnounceKill = 0;
				g_esPlayer[iPlayer].g_iArrivalMessage = 0;
				g_esPlayer[iPlayer].g_iDeathMessage = 0;
				g_esPlayer[iPlayer].g_iKillMessage = 0;
				g_esPlayer[iPlayer].g_sItemReward[0] = '\0';
				g_esPlayer[iPlayer].g_sItemReward2[0] = '\0';
				g_esPlayer[iPlayer].g_sItemReward3[0] = '\0';
				g_esPlayer[iPlayer].g_iBaseHealth = 0;
				g_esPlayer[iPlayer].g_iDisplayHealth = 0;
				g_esPlayer[iPlayer].g_iDisplayHealthType = 0;
				g_esPlayer[iPlayer].g_iExtraHealth = 0;
				g_esPlayer[iPlayer].g_sHealthCharacters[0] = '\0';
				g_esPlayer[iPlayer].g_iMinimumHumans = 0;
				g_esPlayer[iPlayer].g_iMultiHealth = 0;
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
				g_esPlayer[iPlayer].g_flRockDamage = -1.0;
				g_esPlayer[iPlayer].g_flRunSpeed = 0.0;
				g_esPlayer[iPlayer].g_flThrowInterval = 0.0;
				g_esPlayer[iPlayer].g_iBulletImmunity = 0;
				g_esPlayer[iPlayer].g_iExplosiveImmunity = 0;
				g_esPlayer[iPlayer].g_iFireImmunity = 0;
				g_esPlayer[iPlayer].g_iHittableImmunity = 0;
				g_esPlayer[iPlayer].g_iMeleeImmunity = 0;

				for (int iPos = 0; iPos < sizeof(esPlayer::g_iTransformType); iPos++)
				{
					g_esPlayer[iPlayer].g_iTransformType[iPos] = 0;

					if (iPos < sizeof(esPlayer::g_iRewardEnabled))
					{
						g_esPlayer[iPlayer].g_iRewardEffect[iPos] = 0;
						g_esPlayer[iPlayer].g_iRewardEnabled[iPos] = -1;
						g_esPlayer[iPlayer].g_flRewardChance[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flRewardDuration[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flRewardPercentage[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flDamageBoostReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iRespawnLoadoutReward[iPos] = 0;
						g_esPlayer[iPlayer].g_flSpeedBoostReward[iPos] = 0.0;
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

				for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
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
		if (StrEqual(name, MT_CONFIG_SECTION_MAIN, false) || StrEqual(name, MT_NAME, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN2, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN3, false) || StrEqual(name, MT_CONFIG_SECTION_MAIN4, false))
		{
			g_esGeneral.g_csState = ConfigState_Start;
		}
		else
		{
			g_esGeneral.g_iIgnoreLevel++;
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
				g_esGeneral.g_iDeathRevert = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esGeneral.g_iDeathRevert, value, 0, 1);
				g_esGeneral.g_iDetectPlugins = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "DetectPlugins", "Detect Plugins", "Detect_Plugins", "detect", g_esGeneral.g_iDetectPlugins, value, 0, 1);
				g_esGeneral.g_iFinalesOnly = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "FinalesOnly", "Finales Only", "Finales_Only", "finale", g_esGeneral.g_iFinalesOnly, value, 0, 4);
				g_esGeneral.g_flIdleCheck = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "IdleCheck", "Idle Check", "Idle_Check", "idle", g_esGeneral.g_flIdleCheck, value, 0.0, 999999.0);
				g_esGeneral.g_iIdleCheckMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "IdleCheckMode", "Idle Check Mode", "Idle_Check_Mode", "idlemode", g_esGeneral.g_iIdleCheckMode, value, 0, 2);
				g_esGeneral.g_iLogCommands = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "LogCommands", "Log Commands", "Log_Commands", "logcmds", g_esGeneral.g_iLogCommands, value, 0, 31);
				g_esGeneral.g_iLogMessages = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "LogMessages", "Log Messages", "Log_Messages", "logmsgs", g_esGeneral.g_iLogMessages, value, 0, 31);
				g_esGeneral.g_iRequiresHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGeneral.g_iRequiresHumans, value, 0, 32);
				g_esGeneral.g_iTankModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "TankModel", "Tank Model", "Tank_Model", "model", g_esGeneral.g_iTankModel, value, 0, 7);
				g_esGeneral.g_flBurntSkin = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "BurntSkin", "Burnt Skin", "Burnt_Skin", "burnt", g_esGeneral.g_flBurntSkin, value, -1.0, 1.0);
				g_esGeneral.g_iAnnounceArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esGeneral.g_iAnnounceArrival, value, 0, 31);
				g_esGeneral.g_iAnnounceDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esGeneral.g_iAnnounceDeath, value, 0, 2);
				g_esGeneral.g_iAnnounceKill = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceKill", "Announce Kill", "Announce_Kill", "kill", g_esGeneral.g_iAnnounceKill, value, 0, 1);
				g_esGeneral.g_iArrivalMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "ArrivalMessage", "Arrival Message", "Arrival_Message", "arrivalmsg", g_esGeneral.g_iArrivalMessage, value, 0, 1023);
				g_esGeneral.g_iDeathMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathMessage", "Death Message", "Death_Message", "deathmsg", g_esGeneral.g_iDeathMessage, value, 0, 1023);
				g_esGeneral.g_iKillMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "KillMessage", "Kill Message", "Kill_Message", "killmsg", g_esGeneral.g_iKillMessage, value, 0, 1023);
				g_esGeneral.g_iAggressiveTanks = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_COMP, key, "AggressiveTanks", "Aggressive Tanks", "Aggressive_Tanks", "aggressive", g_esGeneral.g_iAggressiveTanks, value, 0, 1);
				g_esGeneral.g_iCreditIgniters = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_COMP, key, "CreditIgniters", "Credit Igniters", "Credit_Igniters", "credit", g_esGeneral.g_iCreditIgniters, value, 0, 1);
				g_esGeneral.g_iStasisMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_COMP, key, "StasisMode", "Stasis Mode", "Stasis_Mode", "stasis", g_esGeneral.g_iStasisMode, value, 0, 1);
				g_esGeneral.g_iScaleDamage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_DIFF, key, "ScaleDamage", "Scale Damage", "Scale_Damage", "scaledmg", g_esGeneral.g_iScaleDamage, value, 0, 1);
				g_esGeneral.g_iBaseHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "BaseHealth", "Base Health", "Base_Health", "basehp", g_esGeneral.g_iBaseHealth, value, 0, MT_MAXHEALTH);
				g_esGeneral.g_iDisplayHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esGeneral.g_iDisplayHealth, value, 0, 11);
				g_esGeneral.g_iDisplayHealthType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esGeneral.g_iDisplayHealthType, value, 0, 2);
				g_esGeneral.g_iExtraHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "ExtraHealth", "Extra Health", "Extra_Health", "extrahp", g_esGeneral.g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
				g_esGeneral.g_iMinimumHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esGeneral.g_iMinimumHumans, value, 1, 32);
				g_esGeneral.g_iMultiHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esGeneral.g_iMultiHealth, value, 0, 3);
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

						g_esGeneral.g_iMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 1, MT_MAXTYPES) : g_esGeneral.g_iMinType;
						g_esGeneral.g_iMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 1, MT_MAXTYPES) : g_esGeneral.g_iMaxType;
					}
				}
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_REWARDS, false))
				{
					static char sValue[960], sSet[3][320];
					strcopy(sValue, sizeof(sValue), value);
					ReplaceString(sValue, sizeof(sValue), " ", "");
					ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
					for (int iPos = 0; iPos < sizeof(esGeneral::g_iRewardEnabled); iPos++)
					{
						if (StrEqual(key, "RewardEnabled", false) || StrEqual(key, "Reward Enabled", false) || StrEqual(key, "Reward_Enabled", false) || StrEqual(key, "renabled", false))
						{
							g_esGeneral.g_iRewardEnabled[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), -1, 2147483647) : g_esGeneral.g_iRewardEnabled[iPos];
						}
						else if (StrEqual(key, "RewardEffect", false) || StrEqual(key, "Reward Effect", false) || StrEqual(key, "Reward_Effect", false) || StrEqual(key, "effect", false))
						{
							g_esGeneral.g_iRewardEffect[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 15) : g_esGeneral.g_iRewardEffect[iPos];
						}
						else if (StrEqual(key, "RewardChance", false) || StrEqual(key, "Reward Chance", false) || StrEqual(key, "Reward_Chance", false) || StrEqual(key, "chance", false))
						{
							g_esGeneral.g_flRewardChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.1, 100.0) : g_esGeneral.g_flRewardChance[iPos];
						}
						else if (StrEqual(key, "RewardDuration", false) || StrEqual(key, "Reward Duration", false) || StrEqual(key, "Reward_Duration", false) || StrEqual(key, "duration", false))
						{
							g_esGeneral.g_flRewardDuration[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.1, 999999.0) : g_esGeneral.g_flRewardDuration[iPos];
						}
						else if (StrEqual(key, "RewardPercentage", false) || StrEqual(key, "Reward Percentage", false) || StrEqual(key, "Reward_Percentage", false) || StrEqual(key, "percent", false))
						{
							g_esGeneral.g_flRewardPercentage[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.1, 100.0) : g_esGeneral.g_flRewardPercentage[iPos];
						}
						else if (StrEqual(key, "DamageBoostReward", false) || StrEqual(key, "Damage Boost Reward", false) || StrEqual(key, "Damage_Boost_Reward", false) || StrEqual(key, "dmgboost", false))
						{
							g_esGeneral.g_flDamageBoostReward[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 1.1, 999999.0) : g_esGeneral.g_flDamageBoostReward[iPos];
						}
						else if (StrEqual(key, "ItemReward", false) || StrEqual(key, "Item Reward", false) || StrEqual(key, "Item_Reward", false) || StrEqual(key, "item", false))
						{
							switch (iPos)
							{
								case 0: strcopy(g_esGeneral.g_sItemReward, sizeof(esGeneral::g_sItemReward), sSet[iPos]);
								case 1: strcopy(g_esGeneral.g_sItemReward2, sizeof(esGeneral::g_sItemReward2), sSet[iPos]);
								case 2: strcopy(g_esGeneral.g_sItemReward3, sizeof(esGeneral::g_sItemReward3), sSet[iPos]);
							}
						}
						else if (StrEqual(key, "RespawnLoadoutReward", false) || StrEqual(key, "Respawn Loadout Reward", false) || StrEqual(key, "Respawn_Loadout_Reward", false) || StrEqual(key, "resloadout", false))
						{
							g_esGeneral.g_iRespawnLoadoutReward[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 1) : g_esGeneral.g_iRespawnLoadoutReward[iPos];
						}
						else if (StrEqual(key, "SpeedBoostReward", false) || StrEqual(key, "Speed Boost Reward", false) || StrEqual(key, "Speed_Boost_Reward", false) || StrEqual(key, "speedboost", false))
						{
							g_esGeneral.g_flSpeedBoostReward[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 1.1, 999999.0) : g_esGeneral.g_flSpeedBoostReward[iPos];
						}
						else if (StrEqual(key, "UsefulRewards", false) || StrEqual(key, "Useful Rewards", false) || StrEqual(key, "Useful_Rewards", false) || StrEqual(key, "useful", false))
						{
							g_esGeneral.g_iUsefulRewards[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 15) : g_esGeneral.g_iUsefulRewards[iPos];
						}
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
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, false))
				{
					if (StrEqual(key, "HealthCharacters", false) || StrEqual(key, "Health Characters", false) || StrEqual(key, "Health_Characters", false) || StrEqual(key, "hpchars", false))
					{
						strcopy(g_esGeneral.g_sHealthCharacters, sizeof(esGeneral::g_sHealthCharacters), value);
					}
				}
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ADMIN, false) || StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ADMIN2, false))
				{
					if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
					{
						g_esGeneral.g_iAccessFlags = ReadFlagString(value);
					}
					else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
					{
						g_esGeneral.g_iImmunityFlags = ReadFlagString(value);
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

						g_esGeneral.g_iRegularMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, g_esGeneral.g_iMaxType) : g_esGeneral.g_iRegularMinType;
						g_esGeneral.g_iRegularMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, g_esGeneral.g_iMaxType) : g_esGeneral.g_iRegularMaxType;
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

							g_esGeneral.g_iFinaleMinTypes[iPos] = (sSet[0][0] != '\0') ? iClamp(StringToInt(sSet[0]), 0, g_esGeneral.g_iMaxType) : g_esGeneral.g_iFinaleMinTypes[iPos];
							g_esGeneral.g_iFinaleMaxTypes[iPos] = (sSet[1][0] != '\0') ? iClamp(StringToInt(sSet[1]), 0, g_esGeneral.g_iMaxType) : g_esGeneral.g_iFinaleMaxTypes[iPos];
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

				if (g_esGeneral.g_iConfigMode == 1)
				{
					g_esGeneral.g_iGameModeTypes = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GAMEMODES, key, "GameModeTypes", "Game Mode Types", "Game_Mode_Types", "types", g_esGeneral.g_iGameModeTypes, value, 0, 15);
					g_esGeneral.g_iConfigEnable = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_CUSTOM, key, "EnableCustomConfigs", "Enable Custom Configs", "Enable_Custom_Configs", "cenabled", g_esGeneral.g_iConfigEnable, value, 0, 1);
					g_esGeneral.g_iConfigCreate = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_CUSTOM, key, "CreateConfigTypes", "Create Config Types", "Create_Config_Types", "create", g_esGeneral.g_iConfigCreate, value, 0, 255);
					g_esGeneral.g_iConfigExecute = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_CUSTOM, key, "ExecuteConfigTypes", "Execute Config Types", "Execute_Config_Types", "execute", g_esGeneral.g_iConfigExecute, value, 0, 255);

					if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GAMEMODES, false) || StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GAMEMODES2, false) || StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GAMEMODES3, false) || StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GAMEMODES4, false))
					{
						if (StrEqual(key, "EnabledGameModes", false) || StrEqual(key, "Enabled Game Modes", false) || StrEqual(key, "Enabled_Game_Modes", false) || StrEqual(key, "gmenabled", false))
						{
							strcopy(g_esGeneral.g_sEnabledGameModes, sizeof(esGeneral::g_sEnabledGameModes), value);
						}
						else if (StrEqual(key, "DisabledGameModes", false) || StrEqual(key, "Disabled Game Modes", false) || StrEqual(key, "Disabled_Game_Modes", false) || StrEqual(key, "gmdisabled", false))
						{
							strcopy(g_esGeneral.g_sDisabledGameModes, sizeof(esGeneral::g_sDisabledGameModes), value);
						}
					}
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
			static char sSteamID32[32], sSteam3ID[32];
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
				{
					if (GetClientAuthId(iPlayer, AuthId_Steam2, sSteamID32, sizeof(sSteamID32)) && GetClientAuthId(iPlayer, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID)))
					{
						if (StrEqual(sSteamID32, g_esGeneral.g_sCurrentSection, false) || StrEqual(sSteam3ID, g_esGeneral.g_sCurrentSection, false))
						{
							g_esPlayer[iPlayer].g_iTankModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "TankModel", "Tank Model", "Tank_Model", "model", g_esPlayer[iPlayer].g_iTankModel, value, 0, 7);
							g_esPlayer[iPlayer].g_flBurntSkin = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "BurntSkin", "Burnt Skin", "Burnt_Skin", "burnt", g_esPlayer[iPlayer].g_flBurntSkin, value, -1.0, 1.0);
							g_esPlayer[iPlayer].g_iTankNote = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "TankNote", "Tank Note", "Tank_Note", "note", g_esPlayer[iPlayer].g_iTankNote, value, 0, 1);
							g_esPlayer[iPlayer].g_iDeathRevert = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esPlayer[iPlayer].g_iDeathRevert, value, 0, 1);
							g_esPlayer[iPlayer].g_iDetectPlugins = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GENERAL, key, "DetectPlugins", "Detect Plugins", "Detect_Plugins", "detect", g_esPlayer[iPlayer].g_iDetectPlugins, value, 0, 1);
							g_esPlayer[iPlayer].g_iAnnounceArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esPlayer[iPlayer].g_iAnnounceArrival, value, 0, 31);
							g_esPlayer[iPlayer].g_iAnnounceDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esPlayer[iPlayer].g_iAnnounceDeath, value, 0, 2);
							g_esPlayer[iPlayer].g_iAnnounceKill = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceKill", "Announce Kill", "Announce_Kill", "kill", g_esPlayer[iPlayer].g_iAnnounceKill, value, 0, 1);
							g_esPlayer[iPlayer].g_iArrivalMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "ArrivalMessage", "Arrival Message", "Arrival_Message", "arrivalmsg", g_esPlayer[iPlayer].g_iArrivalMessage, value, 0, 1023);
							g_esPlayer[iPlayer].g_iDeathMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathMessage", "Death Message", "Death_Message", "deathmsg", g_esPlayer[iPlayer].g_iDeathMessage, value, 0, 1023);
							g_esPlayer[iPlayer].g_iKillMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ANNOUNCE, key, "KillMessage", "Kill Message", "Kill_Message", "killmsg", g_esPlayer[iPlayer].g_iKillMessage, value, 0, 1023);
							g_esPlayer[iPlayer].g_iGlowEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GLOW, key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "genabled", g_esPlayer[iPlayer].g_iGlowEnabled, value, 0, 1);
							g_esPlayer[iPlayer].g_iGlowFlashing = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GLOW, key, "GlowFlashing", "Glow Flashing", "Glow_Flashing", "flashing", g_esPlayer[iPlayer].g_iGlowFlashing, value, 0, 1);
							g_esPlayer[iPlayer].g_iGlowType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_GLOW, key, "GlowType", "Glow Type", "Glow_Type", "type", g_esPlayer[iPlayer].g_iGlowType, value, 0, 1);
							g_esPlayer[iPlayer].g_iBaseHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "BaseHealth", "Base Health", "Base_Health", "basehp", g_esPlayer[iPlayer].g_iBaseHealth, value, 0, MT_MAXHEALTH);
							g_esPlayer[iPlayer].g_iDisplayHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esPlayer[iPlayer].g_iDisplayHealth, value, 0, 11);
							g_esPlayer[iPlayer].g_iDisplayHealthType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esPlayer[iPlayer].g_iDisplayHealthType, value, 0, 2);
							g_esPlayer[iPlayer].g_iExtraHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "ExtraHealth", "Extra Health", "Extra_Health", "extrahp", g_esPlayer[iPlayer].g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
							g_esPlayer[iPlayer].g_iMinimumHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esPlayer[iPlayer].g_iMinimumHumans, value, 1, 32);
							g_esPlayer[iPlayer].g_iMultiHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_HEALTH, key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esPlayer[iPlayer].g_iMultiHealth, value, 0, 3);
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
							g_esPlayer[iPlayer].g_flRockDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esPlayer[iPlayer].g_flRockDamage, value, -1.0, 999999.0);
							g_esPlayer[iPlayer].g_flRunSpeed = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esPlayer[iPlayer].g_flRunSpeed, value, 0.0, 3.0);
							g_esPlayer[iPlayer].g_flThrowInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ENHANCE, key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esPlayer[iPlayer].g_flThrowInterval, value, 0.0, 999999.0);
							g_esPlayer[iPlayer].g_iBulletImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esPlayer[iPlayer].g_iBulletImmunity, value, 0, 1);
							g_esPlayer[iPlayer].g_iExplosiveImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esPlayer[iPlayer].g_iExplosiveImmunity, value, 0, 1);
							g_esPlayer[iPlayer].g_iFireImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esPlayer[iPlayer].g_iFireImmunity, value, 0, 1);
							g_esPlayer[iPlayer].g_iHittableImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "HittableImmunity", "Hittable Immunity", "Hittable_Immunity", "hittable", g_esPlayer[iPlayer].g_iHittableImmunity, value, 0, 1);
							g_esPlayer[iPlayer].g_iMeleeImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_IMMUNE, key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esPlayer[iPlayer].g_iMeleeImmunity, value, 0, 1);
							g_esPlayer[iPlayer].g_iFavoriteType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTIONS_ADMIN, key, "FavoriteType", "Favorite Type", "Favorite_Type", "favorite", g_esPlayer[iPlayer].g_iFavoriteType, value, 0, g_esGeneral.g_iMaxType);

							if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, false))
							{
								if (StrEqual(key, "TankName", false) || StrEqual(key, "Tank Name", false) || StrEqual(key, "Tank_Name", false) || StrEqual(key, "name", false))
								{
									strcopy(g_esPlayer[iPlayer].g_sTankName, sizeof(esPlayer::g_sTankName), value);
								}
								else if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
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
							}
							else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_REWARDS, false))
							{
								static char sValue[960], sSet[3][320];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
								for (int iPos = 0; iPos < sizeof(esPlayer::g_iRewardEnabled); iPos++)
								{
									if (StrEqual(key, "RewardEnabled", false) || StrEqual(key, "Reward Enabled", false) || StrEqual(key, "Reward_Enabled", false) || StrEqual(key, "renabled", false))
									{
										g_esPlayer[iPlayer].g_iRewardEnabled[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), -1, 2147483647) : g_esPlayer[iPlayer].g_iRewardEnabled[iPos];
									}
									else if (StrEqual(key, "RewardEffect", false) || StrEqual(key, "Reward Effect", false) || StrEqual(key, "Reward_Effect", false) || StrEqual(key, "effect", false))
									{
										g_esPlayer[iPlayer].g_iRewardEffect[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 15) : g_esPlayer[iPlayer].g_iRewardEffect[iPos];
									}
									else if (StrEqual(key, "RewardChance", false) || StrEqual(key, "Reward Chance", false) || StrEqual(key, "Reward_Chance", false) || StrEqual(key, "chance", false))
									{
										g_esPlayer[iPlayer].g_flRewardChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.1, 100.0) : g_esPlayer[iPlayer].g_flRewardChance[iPos];
									}
									else if (StrEqual(key, "RewardDuration", false) || StrEqual(key, "Reward Duration", false) || StrEqual(key, "Reward_Duration", false) || StrEqual(key, "duration", false))
									{
										g_esPlayer[iPlayer].g_flRewardDuration[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.1, 999999.0) : g_esPlayer[iPlayer].g_flRewardDuration[iPos];
									}
									else if (StrEqual(key, "RewardPercentage", false) || StrEqual(key, "Reward Percentage", false) || StrEqual(key, "Reward_Percentage", false) || StrEqual(key, "percent", false))
									{
										g_esPlayer[iPlayer].g_flRewardPercentage[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.1, 100.0) : g_esPlayer[iPlayer].g_flRewardPercentage[iPos];
									}
									else if (StrEqual(key, "DamageBoostReward", false) || StrEqual(key, "Damage Boost Reward", false) || StrEqual(key, "Damage_Boost_Reward", false) || StrEqual(key, "dmgboost", false))
									{
										g_esPlayer[iPlayer].g_flDamageBoostReward[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 1.1, 999999.0) : g_esPlayer[iPlayer].g_flDamageBoostReward[iPos];
									}
									else if (StrEqual(key, "ItemReward", false) || StrEqual(key, "Item Reward", false) || StrEqual(key, "Item_Reward", false) || StrEqual(key, "item", false))
									{
										switch (iPos)
										{
											case 0: strcopy(g_esPlayer[iPlayer].g_sItemReward, sizeof(esPlayer::g_sItemReward), sSet[iPos]);
											case 1: strcopy(g_esPlayer[iPlayer].g_sItemReward2, sizeof(esPlayer::g_sItemReward2), sSet[iPos]);
											case 2: strcopy(g_esPlayer[iPlayer].g_sItemReward3, sizeof(esPlayer::g_sItemReward3), sSet[iPos]);
										}
									}
									else if (StrEqual(key, "RespawnLoadoutReward", false) || StrEqual(key, "Respawn Loadout Reward", false) || StrEqual(key, "Respawn_Loadout_Reward", false) || StrEqual(key, "resloadout", false))
									{
										g_esPlayer[iPlayer].g_iRespawnLoadoutReward[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 1) : g_esPlayer[iPlayer].g_iRespawnLoadoutReward[iPos];
									}
									else if (StrEqual(key, "SpeedBoostReward", false) || StrEqual(key, "Speed Boost Reward", false) || StrEqual(key, "Speed_Boost_Reward", false) || StrEqual(key, "speedboost", false))
									{
										g_esPlayer[iPlayer].g_flSpeedBoostReward[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 1.1, 999999.0) : g_esPlayer[iPlayer].g_flSpeedBoostReward[iPos];
									}
									else if (StrEqual(key, "UsefulRewards", false) || StrEqual(key, "Useful Rewards", false) || StrEqual(key, "Useful_Rewards", false) || StrEqual(key, "useful", false))
									{
										g_esPlayer[iPlayer].g_iUsefulRewards[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 15) : g_esPlayer[iPlayer].g_iUsefulRewards[iPos];
									}
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
							else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, false))
							{
								if (StrEqual(key, "HealthCharacters", false) || StrEqual(key, "Health Characters", false) || StrEqual(key, "Health_Characters", false) || StrEqual(key, "hpchars", false))
								{
									strcopy(g_esPlayer[iPlayer].g_sHealthCharacters, sizeof(esPlayer::g_sHealthCharacters), value);
								}
							}
							else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Administration", false) || StrEqual(g_esGeneral.g_sCurrentSubSection, "admin", false))
							{
								if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
								{
									g_esPlayer[iPlayer].g_iAccessFlags = ReadFlagString(value);
								}
								else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
								{
									g_esPlayer[iPlayer].g_iImmunityFlags = ReadFlagString(value);
								}
							}
							else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_BOSS, false))
							{
								static char sValue[24], sSet[4][6];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
								for (int iPos = 0; iPos < sizeof(esPlayer::g_iBossHealth); iPos++)
								{
									if (StrEqual(key, "BossHealthStages", false) || StrEqual(key, "Boss Health Stages", false) || StrEqual(key, "Boss_Health_Stages", false) || StrEqual(key, "bosshpstages", false))
									{
										g_esPlayer[iPlayer].g_iBossHealth[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXHEALTH) : g_esPlayer[iPlayer].g_iBossHealth[iPos];
									}
									else if (StrEqual(key, "BossTypes", false) || StrEqual(key, "Boss Types", false) || StrEqual(key, "Boss_Types", false))
									{
										g_esPlayer[iPlayer].g_iBossType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType) : g_esPlayer[iPlayer].g_iBossType[iPos];
									}
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
								else if (StrEqual(key, "ComboSet", false) || StrEqual(key, "Combo Set", false) || StrEqual(key, "Combo_Set", false) || StrEqual(key, "set", false))
								{
									strcopy(g_esPlayer[iPlayer].g_sComboSet, sizeof(esPlayer::g_sComboSet), value);
								}
								else
								{
									static char sValue[140], sSet[10][14];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
									for (int iPos = 0; iPos < sizeof(esPlayer::g_flComboChance); iPos++)
									{
										if (StrEqual(key, "ComboChance", false) || StrEqual(key, "Combo Chance", false) || StrEqual(key, "Combo_Chance", false) || StrEqual(key, "chance", false))
										{
											g_esPlayer[iPlayer].g_flComboChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esPlayer[iPlayer].g_flComboChance[iPos];
										}
										else if (StrEqual(key, "ComboDamage", false) || StrEqual(key, "Combo Damage", false) || StrEqual(key, "Combo_Damage", false) || StrEqual(key, "damage", false))
										{
											g_esPlayer[iPlayer].g_flComboDamage[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esPlayer[iPlayer].g_flComboDamage[iPos];
										}
										else if (StrEqual(key, "ComboDeathChance", false) || StrEqual(key, "Combo Death Chance", false) || StrEqual(key, "Combo_Death_Chance", false) || StrEqual(key, "deathchance", false))
										{
											g_esPlayer[iPlayer].g_flComboDeathChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esPlayer[iPlayer].g_flComboDeathChance[iPos];
										}
										else if (StrEqual(key, "ComboDeathRange", false) || StrEqual(key, "Combo Death Range", false) || StrEqual(key, "Combo_Death_Range", false) || StrEqual(key, "deathrange", false))
										{
											g_esPlayer[iPlayer].g_flComboDeathRange[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esPlayer[iPlayer].g_flComboDeathRange[iPos];
										}
										else if (StrEqual(key, "ComboDelay", false) || StrEqual(key, "Combo Delay", false) || StrEqual(key, "Combo_Delay", false) || StrEqual(key, "delay", false))
										{
											g_esPlayer[iPlayer].g_flComboDelay[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esPlayer[iPlayer].g_flComboDelay[iPos];
										}
										else if (StrEqual(key, "ComboDuration", false) || StrEqual(key, "Combo Duration", false) || StrEqual(key, "Combo_Duration", false) || StrEqual(key, "duration", false))
										{
											g_esPlayer[iPlayer].g_flComboDuration[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esPlayer[iPlayer].g_flComboDuration[iPos];
										}
										else if (StrEqual(key, "ComboInterval", false) || StrEqual(key, "Combo Interval", false) || StrEqual(key, "Combo_Interval", false) || StrEqual(key, "interval", false))
										{
											g_esPlayer[iPlayer].g_flComboInterval[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esPlayer[iPlayer].g_flComboInterval[iPos];
										}
										else if (StrEqual(key, "ComboRadius", false) || StrEqual(key, "Combo Radius", false) || StrEqual(key, "Combo_Radius", false) || StrEqual(key, "radius", false))
										{
											static char sRange[2][7], sSubset[14];
											strcopy(sSubset, sizeof(sSubset), sSet[iPos]);
											ReplaceString(sSubset, sizeof(sSubset), " ", "");
											ExplodeString(sSubset, ";", sRange, sizeof(sRange), sizeof(sRange[]));

											g_esPlayer[iPlayer].g_flComboMinRadius[iPos] = (sRange[0][0] != '\0') ? flClamp(StringToFloat(sRange[0]), -200.0, 0.0) : g_esPlayer[iPlayer].g_flComboMinRadius[iPos];
											g_esPlayer[iPlayer].g_flComboMaxRadius[iPos] = (sRange[1][0] != '\0') ? flClamp(StringToFloat(sRange[1]), 0.0, 200.0) : g_esPlayer[iPlayer].g_flComboMaxRadius[iPos];
										}
										else if (StrEqual(key, "ComboRange", false) || StrEqual(key, "Combo Range", false) || StrEqual(key, "Combo_Range", false) || StrEqual(key, "range", false))
										{
											g_esPlayer[iPlayer].g_flComboRange[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esPlayer[iPlayer].g_flComboRange[iPos];
										}
										else if (StrEqual(key, "ComboRangeChance", false) || StrEqual(key, "Combo Range Chance", false) || StrEqual(key, "Combo_Range_Chance", false) || StrEqual(key, "rangechance", false))
										{
											g_esPlayer[iPlayer].g_flComboRangeChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esPlayer[iPlayer].g_flComboRangeChance[iPos];
										}
										else if (StrEqual(key, "ComboRockChance", false) || StrEqual(key, "Combo Rock Chance", false) || StrEqual(key, "Combo_Rock_Chance", false) || StrEqual(key, "rockchance", false))
										{
											g_esPlayer[iPlayer].g_flComboRockChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esPlayer[iPlayer].g_flComboRockChance[iPos];
										}
										else if (StrEqual(key, "ComboSpeed", false) || StrEqual(key, "Combo Speed", false) || StrEqual(key, "Combo_Speed", false) || StrEqual(key, "speed", false))
										{
											g_esPlayer[iPlayer].g_flComboSpeed[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esPlayer[iPlayer].g_flComboSpeed[iPos];
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
										g_esPlayer[iPlayer].g_iTransformType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType) : g_esPlayer[iPlayer].g_iTransformType[iPos];
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
										if (StrEqual(key, "LightColor", false) || StrEqual(key, "Light Color", false) || StrEqual(key, "Light_Color", false) || StrEqual(key, "light", false))
										{
											g_esPlayer[iPlayer].g_iLightColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
										}
										else if (StrEqual(key, "OxygenTankColor", false) || StrEqual(key, "Oxygen Tank Color", false) || StrEqual(key, "Oxygen_Tank_Color", false) || StrEqual(key, "oxygen", false))
										{
											g_esPlayer[iPlayer].g_iOzTankColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
										}
										else if (StrEqual(key, "FlameColor", false) || StrEqual(key, "Flame Color", false) || StrEqual(key, "Flame_Color", false) || StrEqual(key, "flame", false))
										{
											g_esPlayer[iPlayer].g_iFlameColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
										}
										else if (StrEqual(key, "RockColor", false) || StrEqual(key, "Rock Color", false) || StrEqual(key, "Rock_Color", false) || StrEqual(key, "rock", false))
										{
											g_esPlayer[iPlayer].g_iRockColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
										}
										else if (StrEqual(key, "TireColor", false) || StrEqual(key, "Tire Color", false) || StrEqual(key, "Tire_Color", false) || StrEqual(key, "tire", false))
										{
											g_esPlayer[iPlayer].g_iTireColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
										}
										else if (StrEqual(key, "PropaneTankColor", false) || StrEqual(key, "Propane Tank Color", false) || StrEqual(key, "Propane_Tank_Color", false) || StrEqual(key, "propane", false))
										{
											g_esPlayer[iPlayer].g_iPropTankColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
										}
										else if (StrEqual(key, "FlashlightColor", false) || StrEqual(key, "Flashlight Color", false) || StrEqual(key, "Flashlight_Color", false) || StrEqual(key, "flashlight", false))
										{
											g_esPlayer[iPlayer].g_iFlashlightColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
										}
										else if (StrEqual(key, "CrownColor", false) || StrEqual(key, "Crown Color", false) || StrEqual(key, "Crown_Color", false) || StrEqual(key, "crown", false))
										{
											g_esPlayer[iPlayer].g_iCrownColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
										}
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
											iRealType = iFindSectionType(g_esGeneral.g_sCurrentSubSection, iIndex);
											if (iIndex == iRealType || StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1)
											{
												vReadAdminSettings(iPlayer, iIndex, key, value);
											}
										}
									}
								}
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
			if (bIsTankSupported(iTank) && bHasCoreAdminAccess(iTank))
			{
				vThrowInterval(iTank);
			}
		}
		else if (StrEqual(name, "bot_player_replace"))
		{
			int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
				iPlayerId = event.GetInt("player"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsValidClient(iBot, MT_CHECK_INDEX|MT_CHECK_INGAME))
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

			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_start") || StrEqual(name, "gauntlet_finale_start"))
		{
			g_esGeneral.g_iTankWave = 1;

			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_rush") || StrEqual(name, "finale_radio_start") || StrEqual(name, "finale_radio_damaged") || StrEqual(name, "finale_bridge_lowering") || StrEqual(name, "finale_win"))
		{
			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "heal_success"))
		{
			int iSurvivorId = event.GetInt("subject"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsSurvivor(iSurvivor))
			{
				g_esPlayer[iSurvivor].g_bLastLife = false;
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
			if (bIsValidClient(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
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
				}
			}
		}
		else if (StrEqual(name, "player_death"))
		{
			int iVictimId = event.GetInt("userid"), iVictim = GetClientOfUserId(iVictimId), iAttacker = GetClientOfUserId(event.GetInt("attacker"));
			if (bIsTankSupported(iVictim, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				g_esPlayer[iVictim].g_bDied = true;
				g_esPlayer[iVictim].g_bDying = false;
				g_esPlayer[iVictim].g_bTriggered = false;

				vCalculateDeath(iVictim, iAttacker);

				if (g_esCache[iVictim].g_iDeathRevert == 1)
				{
					int iType = g_esPlayer[iVictim].g_iTankType;
					vSetColor(iVictim, _, _, true);

					g_esPlayer[iVictim].g_iTankType = iType;
				}

				vReset2(iVictim, g_esCache[iVictim].g_iDeathRevert);

				CreateTimer(1.0, tTimerResetType, iVictimId, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(5.0, tTimerTankWave, _, TIMER_FLAG_NO_MAPCHANGE);
			}
			else if (bIsSurvivor(iVictim, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				if (bIsTankSupported(iAttacker, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esCache[iAttacker].g_iAnnounceKill == 1)
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

				vRemoveEffects(iVictim);
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
				g_esPlayer[iPlayer].g_bDying = true;

				CreateTimer(10.0, tTimerKillStuckTank, iPlayerId, TIMER_FLAG_NO_MAPCHANGE);
				vCombineAbilitiesForward(iPlayer, MT_COMBO_UPONINCAP);
			}
		}
		else if (StrEqual(name, "player_jump"))
		{
			int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsHumanSurvivor(iSurvivor) && bIsDeveloper(iSurvivor, 6))
			{
				SetEntityGravity(iSurvivor, 0.75);
			}
		}
		else if (StrEqual(name, "player_now_it"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
 			if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_bSecondGame)
			{
				vRemoveGlow(iTank);
			}
		}
		else if (StrEqual(name, "player_no_longer_it"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
 			if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_bSecondGame && !bIsPlayerIncapacitated(iTank) && g_esCache[iTank].g_iGlowEnabled == 1)
			{
				vSetGlow(iTank);
			}
		}
		else if (StrEqual(name, "player_spawn"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsValidClient(iPlayer))
			{
				DataPack dpPlayerSpawn = new DataPack();
				RequestFrame(vPlayerSpawnFrame, dpPlayerSpawn);
				dpPlayerSpawn.WriteCell(iPlayerId);
				dpPlayerSpawn.WriteCell(g_esGeneral.g_iChosenType);
			}
		}
		else if (StrEqual(name, "player_team"))
		{
			int iPlayer = GetClientOfUserId(event.GetInt("userid"));
			if (bIsValidClient(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
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
			}
		}
		else if (StrEqual(name, "weapon_fire"))
		{
			static int iTankId, iTank;
			iTankId = event.GetInt("userid");
			iTank = GetClientOfUserId(iTankId);
			if (bIsTankSupported(iTank) && g_esCache[iTank].g_flAttackInterval > 0.0)
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
		g_esTank[type].g_iTankEnabled = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "TankEnabled", "Tank Enabled", "Tank_Enabled", "tenabled", g_esTank[type].g_iTankEnabled, value, 0, 1);
		g_esTank[type].g_flTankChance = flGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "TankChance", "Tank Chance", "Tank_Chance", "chance", g_esTank[type].g_flTankChance, value, 0.0, 100.0);
		g_esTank[type].g_iTankModel = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "TankModel", "Tank Model", "Tank_Model", "model", g_esTank[type].g_iTankModel, value, 0, 7);
		g_esTank[type].g_flBurntSkin = flGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "BurntSkin", "Burnt Skin", "Burnt_Skin", "burnt", g_esTank[type].g_flBurntSkin, value, -1.0, 1.0);
		g_esTank[type].g_iTankNote = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "TankNote", "Tank Note", "Tank_Note", "note", g_esTank[type].g_iTankNote, value, 0, 1);
		g_esTank[type].g_iSpawnEnabled = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "SpawnEnabled", "Spawn Enabled", "Spawn_Enabled", "spawn", g_esTank[type].g_iSpawnEnabled, value, 0, 1);
		g_esTank[type].g_iMenuEnabled = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "MenuEnabled", "Menu Enabled", "Menu_Enabled", "menu", g_esTank[type].g_iMenuEnabled, value, 0, 1);
		g_esTank[type].g_iDeathRevert = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esTank[type].g_iDeathRevert, value, 0, 1);
		g_esTank[type].g_iDetectPlugins = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "DetectPlugins", "Detect Plugins", "Detect_Plugins", "detect", g_esTank[type].g_iDetectPlugins, value, 0, 1);
		g_esTank[type].g_iRequiresHumans = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GENERAL, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esTank[type].g_iRequiresHumans, value, 0, 32);
		g_esTank[type].g_iAnnounceArrival = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esTank[type].g_iAnnounceArrival, value, 0, 31);
		g_esTank[type].g_iAnnounceDeath = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esTank[type].g_iAnnounceDeath, value, 0, 2);
		g_esTank[type].g_iAnnounceKill = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "AnnounceKill", "Announce Kill", "Announce_Kill", "kill", g_esTank[type].g_iAnnounceKill, value, 0, 1);
		g_esTank[type].g_iArrivalMessage = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "ArrivalMessage", "Arrival Message", "Arrival_Message", "arrivalmsg", g_esTank[type].g_iArrivalMessage, value, 0, 1023);
		g_esTank[type].g_iDeathMessage = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "DeathMessage", "Death Message", "Death_Message", "deathmsg", g_esTank[type].g_iDeathMessage, value, 0, 1023);
		g_esTank[type].g_iKillMessage = iGetKeyValue(sub, MT_CONFIG_SECTIONS_ANNOUNCE, key, "KillMessage", "Kill Message", "Kill_Message", "killmsg", g_esTank[type].g_iKillMessage, value, 0, 1023);
		g_esTank[type].g_iGlowEnabled = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GLOW, key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "genabled", g_esTank[type].g_iGlowEnabled, value, 0, 1);
		g_esTank[type].g_iGlowFlashing = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GLOW, key, "GlowFlashing", "Glow Flashing", "Glow_Flashing", "flashing", g_esTank[type].g_iGlowFlashing, value, 0, 1);
		g_esTank[type].g_iGlowType = iGetKeyValue(sub, MT_CONFIG_SECTIONS_GLOW, key, "GlowType", "Glow Type", "Glow_Type", "type", g_esTank[type].g_iGlowType, value, 0, 1);
		g_esTank[type].g_iBaseHealth = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "BaseHealth", "Base Health", "Base_Health", "basehp", g_esTank[type].g_iBaseHealth, value, 0, MT_MAXHEALTH);
		g_esTank[type].g_iDisplayHealth = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esTank[type].g_iDisplayHealth, value, 0, 11);
		g_esTank[type].g_iDisplayHealthType = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esTank[type].g_iDisplayHealthType, value, 0, 2);
		g_esTank[type].g_iExtraHealth = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "ExtraHealth", "Extra Health", "Extra_Health", "extrahp", g_esTank[type].g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		g_esTank[type].g_iMinimumHumans = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esTank[type].g_iMinimumHumans, value, 1, 32);
		g_esTank[type].g_iMultiHealth = iGetKeyValue(sub, MT_CONFIG_SECTIONS_HEALTH, key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esTank[type].g_iMultiHealth, value, 0, 3);
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
		g_esTank[type].g_flRockDamage = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esTank[type].g_flRockDamage, value, -1.0, 999999.0);
		g_esTank[type].g_flRunSpeed = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esTank[type].g_flRunSpeed, value, 0.0, 3.0);
		g_esTank[type].g_flThrowInterval = flGetKeyValue(sub, MT_CONFIG_SECTIONS_ENHANCE, key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esTank[type].g_flThrowInterval, value, 0.0, 999999.0);
		g_esTank[type].g_iBulletImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esTank[type].g_iBulletImmunity, value, 0, 1);
		g_esTank[type].g_iExplosiveImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esTank[type].g_iExplosiveImmunity, value, 0, 1);
		g_esTank[type].g_iFireImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esTank[type].g_iFireImmunity, value, 0, 1);
		g_esTank[type].g_iHittableImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "HittableImmunity", "Hittable Immunity", "Hittable_Immunity", "hittable", g_esTank[type].g_iHittableImmunity, value, 0, 1);
		g_esTank[type].g_iMeleeImmunity = iGetKeyValue(sub, MT_CONFIG_SECTIONS_IMMUNE, key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esTank[type].g_iMeleeImmunity, value, 0, 1);

		if (StrEqual(sub, MT_CONFIG_SECTION_GENERAL, false))
		{
			if (StrEqual(key, "TankName", false) || StrEqual(key, "Tank Name", false) || StrEqual(key, "Tank_Name", false) || StrEqual(key, "name", false))
			{
				strcopy(g_esTank[type].g_sTankName, sizeof(esTank::g_sTankName), value);
			}
			else if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
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
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_REWARDS, false))
		{
			static char sValue[960], sSet[3][320];
			strcopy(sValue, sizeof(sValue), value);
			ReplaceString(sValue, sizeof(sValue), " ", "");
			ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
			for (int iPos = 0; iPos < sizeof(esTank::g_iRewardEnabled); iPos++)
			{
				if (StrEqual(key, "RewardEnabled", false) || StrEqual(key, "Reward Enabled", false) || StrEqual(key, "Reward_Enabled", false) || StrEqual(key, "renabled", false))
				{
					g_esTank[type].g_iRewardEnabled[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), -1, 2147483647) : g_esTank[type].g_iRewardEnabled[iPos];
				}
				else if (StrEqual(key, "RewardEffect", false) || StrEqual(key, "Reward Effect", false) || StrEqual(key, "Reward_Effect", false) || StrEqual(key, "effect", false))
				{
					g_esTank[type].g_iRewardEffect[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 15) : g_esTank[type].g_iRewardEffect[iPos];
				}
				else if (StrEqual(key, "RewardChance", false) || StrEqual(key, "Reward Chance", false) || StrEqual(key, "Reward_Chance", false) || StrEqual(key, "chance", false))
				{
					g_esTank[type].g_flRewardChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.1, 100.0) : g_esTank[type].g_flRewardChance[iPos];
				}
				else if (StrEqual(key, "RewardDuration", false) || StrEqual(key, "Reward Duration", false) || StrEqual(key, "Reward_Duration", false) || StrEqual(key, "duration", false))
				{
					g_esTank[type].g_flRewardDuration[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.1, 999999.0) : g_esTank[type].g_flRewardDuration[iPos];
				}
				else if (StrEqual(key, "RewardPercentage", false) || StrEqual(key, "Reward Percentage", false) || StrEqual(key, "Reward_Percentage", false) || StrEqual(key, "percent", false))
				{
					g_esTank[type].g_flRewardPercentage[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.1, 100.0) : g_esTank[type].g_flRewardPercentage[iPos];
				}
				else if (StrEqual(key, "DamageBoostReward", false) || StrEqual(key, "Damage Boost Reward", false) || StrEqual(key, "Damage_Boost_Reward", false) || StrEqual(key, "dmgboost", false))
				{
					g_esTank[type].g_flDamageBoostReward[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 1.1, 999999.0) : g_esTank[type].g_flDamageBoostReward[iPos];
				}
				else if (StrEqual(key, "ItemReward", false) || StrEqual(key, "Item Reward", false) || StrEqual(key, "Item_Reward", false) || StrEqual(key, "item", false))
				{
					switch (iPos)
					{
						case 0: strcopy(g_esTank[type].g_sItemReward, sizeof(esTank::g_sItemReward), sSet[iPos]);
						case 1: strcopy(g_esTank[type].g_sItemReward2, sizeof(esTank::g_sItemReward2), sSet[iPos]);
						case 2: strcopy(g_esTank[type].g_sItemReward3, sizeof(esTank::g_sItemReward3), sSet[iPos]);
					}
				}
				else if (StrEqual(key, "RespawnLoadoutReward", false) || StrEqual(key, "Respawn Loadout Reward", false) || StrEqual(key, "Respawn_Loadout_Reward", false) || StrEqual(key, "resloadout", false))
				{
					g_esTank[type].g_iRespawnLoadoutReward[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 1) : g_esTank[type].g_iRespawnLoadoutReward[iPos];
				}
				else if (StrEqual(key, "SpeedBoostReward", false) || StrEqual(key, "Speed Boost Reward", false) || StrEqual(key, "Speed_Boost_Reward", false) || StrEqual(key, "speedboost", false))
				{
					g_esTank[type].g_flSpeedBoostReward[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 1.1, 999999.0) : g_esTank[type].g_flSpeedBoostReward[iPos];
				}
				else if (StrEqual(key, "UsefulRewards", false) || StrEqual(key, "Useful Rewards", false) || StrEqual(key, "Useful_Rewards", false) || StrEqual(key, "useful", false))
				{
					g_esTank[type].g_iUsefulRewards[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 15) : g_esTank[type].g_iUsefulRewards[iPos];
				}
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
		else if (StrEqual(sub, MT_CONFIG_SECTION_HEALTH, false))
		{
			if (StrEqual(key, "HealthCharacters", false) || StrEqual(key, "Health Characters", false) || StrEqual(key, "Health_Characters", false) || StrEqual(key, "hpchars", false))
			{
				strcopy(g_esTank[type].g_sHealthCharacters, sizeof(esTank::g_sHealthCharacters), value);
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_ADMIN, false) || StrEqual(sub, MT_CONFIG_SECTION_ADMIN2, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esTank[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esTank[type].g_iImmunityFlags = ReadFlagString(value);
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_BOSS, false))
		{
			static char sValue[24], sSet[4][6];
			strcopy(sValue, sizeof(sValue), value);
			ReplaceString(sValue, sizeof(sValue), " ", "");
			ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
			for (int iPos = 0; iPos < sizeof(esTank::g_iBossHealth); iPos++)
			{
				if (StrEqual(key, "BossHealthStages", false) || StrEqual(key, "Boss Health Stages", false) || StrEqual(key, "Boss_Health_Stages", false) || StrEqual(key, "bosshpstages", false))
				{
					g_esTank[type].g_iBossHealth[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXHEALTH) : g_esTank[type].g_iBossHealth[iPos];
				}
				else if (StrEqual(key, "BossTypes", false) || StrEqual(key, "Boss Types", false) || StrEqual(key, "Boss_Types", false))
				{
					g_esTank[type].g_iBossType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType) : g_esTank[type].g_iBossType[iPos];
				}
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
			else if (StrEqual(key, "ComboSet", false) || StrEqual(key, "Combo Set", false) || StrEqual(key, "Combo_Set", false) || StrEqual(key, "set", false))
			{
				strcopy(g_esTank[type].g_sComboSet, sizeof(esTank::g_sComboSet), value);
			}
			else
			{
				static char sValue[140], sSet[10][14];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(esTank::g_flComboChance); iPos++)
				{
					if (StrEqual(key, "ComboChance", false) || StrEqual(key, "Combo Chance", false) || StrEqual(key, "Combo_Chance", false) || StrEqual(key, "chance", false))
					{
						g_esTank[type].g_flComboChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esTank[type].g_flComboChance[iPos];
					}
					else if (StrEqual(key, "ComboDamage", false) || StrEqual(key, "Combo Damage", false) || StrEqual(key, "Combo_Damage", false) || StrEqual(key, "damage", false))
					{
						g_esTank[type].g_flComboDamage[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esTank[type].g_flComboDamage[iPos];
					}
					else if (StrEqual(key, "ComboDeathChance", false) || StrEqual(key, "Combo Death Chance", false) || StrEqual(key, "Combo_Death_Chance", false) || StrEqual(key, "deathchance", false))
					{
						g_esTank[type].g_flComboDeathChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esTank[type].g_flComboDeathChance[iPos];
					}
					else if (StrEqual(key, "ComboDeathRange", false) || StrEqual(key, "Combo Death Range", false) || StrEqual(key, "Combo_Death_Range", false) || StrEqual(key, "deathrange", false))
					{
						g_esTank[type].g_flComboDeathRange[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esTank[type].g_flComboDeathRange[iPos];
					}
					else if (StrEqual(key, "ComboDelay", false) || StrEqual(key, "Combo Delay", false) || StrEqual(key, "Combo_Delay", false) || StrEqual(key, "delay", false))
					{
						g_esTank[type].g_flComboDelay[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esTank[type].g_flComboDelay[iPos];
					}
					else if (StrEqual(key, "ComboDuration", false) || StrEqual(key, "Combo Duration", false) || StrEqual(key, "Combo_Duration", false) || StrEqual(key, "duration", false))
					{
						g_esTank[type].g_flComboDuration[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esTank[type].g_flComboDuration[iPos];
					}
					else if (StrEqual(key, "ComboInterval", false) || StrEqual(key, "Combo Interval", false) || StrEqual(key, "Combo_Interval", false) || StrEqual(key, "interval", false))
					{
						g_esTank[type].g_flComboInterval[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esTank[type].g_flComboInterval[iPos];
					}
					else if (StrEqual(key, "ComboRadius", false) || StrEqual(key, "Combo Radius", false) || StrEqual(key, "Combo_Radius", false) || StrEqual(key, "radius", false))
					{
						static char sRange[2][7], sSubset[14];
						strcopy(sSubset, sizeof(sSubset), sSet[iPos]);
						ReplaceString(sSubset, sizeof(sSubset), " ", "");
						ExplodeString(sSubset, ";", sRange, sizeof(sRange), sizeof(sRange[]));

						g_esTank[type].g_flComboMinRadius[iPos] = (sRange[0][0] != '\0') ? flClamp(StringToFloat(sRange[0]), -200.0, 0.0) : g_esTank[type].g_flComboMinRadius[iPos];
						g_esTank[type].g_flComboMaxRadius[iPos] = (sRange[1][0] != '\0') ? flClamp(StringToFloat(sRange[1]), 0.0, 200.0) : g_esTank[type].g_flComboMaxRadius[iPos];
					}
					else if (StrEqual(key, "ComboRange", false) || StrEqual(key, "Combo Range", false) || StrEqual(key, "Combo_Range", false) || StrEqual(key, "range", false))
					{
						g_esTank[type].g_flComboRange[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esTank[type].g_flComboRange[iPos];
					}
					else if (StrEqual(key, "ComboRangeChance", false) || StrEqual(key, "Combo Range Chance", false) || StrEqual(key, "Combo_Range_Chance", false) || StrEqual(key, "rangechance", false))
					{
						g_esTank[type].g_flComboRangeChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esTank[type].g_flComboRangeChance[iPos];
					}
					else if (StrEqual(key, "ComboRockChance", false) || StrEqual(key, "Combo Rock Chance", false) || StrEqual(key, "Combo_Rock_Chance", false) || StrEqual(key, "rockchance", false))
					{
						g_esTank[type].g_flComboRockChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esTank[type].g_flComboRockChance[iPos];
					}
					else if (StrEqual(key, "ComboSpeed", false) || StrEqual(key, "Combo Speed", false) || StrEqual(key, "Combo_Speed", false) || StrEqual(key, "speed", false))
					{
						g_esTank[type].g_flComboSpeed[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esTank[type].g_flComboSpeed[iPos];
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
					g_esTank[type].g_iTransformType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType) : g_esTank[type].g_iTransformType[iPos];
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
					if (StrEqual(key, "LightColor", false) || StrEqual(key, "Light Color", false) || StrEqual(key, "Light_Color", false) || StrEqual(key, "light", false))
					{
						g_esTank[type].g_iLightColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
					else if (StrEqual(key, "OxygenTankColor", false) || StrEqual(key, "Oxygen Tank Color", false) || StrEqual(key, "Oxygen_Tank_Color", false) || StrEqual(key, "oxygen", false))
					{
						g_esTank[type].g_iOzTankColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
					else if (StrEqual(key, "FlameColor", false) || StrEqual(key, "Flame Color", false) || StrEqual(key, "Flame_Color", false) || StrEqual(key, "flame", false))
					{
						g_esTank[type].g_iFlameColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
					else if (StrEqual(key, "RockColor", false) || StrEqual(key, "Rock Color", false) || StrEqual(key, "Rock_Color", false) || StrEqual(key, "rock", false))
					{
						g_esTank[type].g_iRockColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
					else if (StrEqual(key, "TireColor", false) || StrEqual(key, "Tire Color", false) || StrEqual(key, "Tire_Color", false) || StrEqual(key, "tire", false))
					{
						g_esTank[type].g_iTireColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
					else if (StrEqual(key, "PropaneTankColor", false) || StrEqual(key, "Propane Tank Color", false) || StrEqual(key, "Propane_Tank_Color", false) || StrEqual(key, "propane", false))
					{
						g_esTank[type].g_iPropTankColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
					else if (StrEqual(key, "FlashlightColor", false) || StrEqual(key, "Flashlight Color", false) || StrEqual(key, "Flashlight_Color", false) || StrEqual(key, "flashlight", false))
					{
						g_esTank[type].g_iFlashlightColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
					else if (StrEqual(key, "CrownColor", false) || StrEqual(key, "Crown Color", false) || StrEqual(key, "Crown_Color", false) || StrEqual(key, "crown", false))
					{
						g_esTank[type].g_iCrownColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
				}
			}
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

static void vVocalizeDeath(int killer, int assistant, int tank)
{
	int iTimestamp = RoundToNearest(GetGameTime() * 10.0);
	if (bIsSurvivor(killer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE))
	{
		FakeClientCommand(killer, "vocalize PlayerHurrah #%i", iTimestamp);
	}

	if (bIsSurvivor(assistant, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && assistant != killer)
	{
		FakeClientCommand(assistant, "vocalize PlayerTaunt #%i", iTimestamp);
	}

	for (int iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
	{
		if (bIsSurvivor(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iTeammate].g_iTankDamage[tank] > 0.0 && iTeammate != killer && iTeammate != assistant)
		{
			FakeClientCommand(iTeammate, "vocalize PlayerNiceJob #%i", iTimestamp);
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
	bool bPluginAllowed = g_esGeneral.g_cvMTPluginEnabled.BoolValue && g_esGeneral.g_iPluginEnabled == 1, bPluginEnabled = bIsPluginEnabled();
	if (!g_esGeneral.g_bPluginEnabled && bPluginAllowed && bPluginEnabled)
	{
		g_esGeneral.g_bPluginEnabled = true;

		if (g_esGeneral.g_cvMTBurnMax != null)
		{
			g_esGeneral.g_cvMTBurnMax.FloatValue = 1.0;
		}

		vHookEvents(true);

		if (!g_esGeneral.g_ddLauncherDirectionDetour.Enable(Hook_Pre, mreLaunchDirectionPre))
		{
			LogError("Failed to enable detour pre: CEnvRockLauncher::LaunchCurrentDir");
		}

		if (!g_esGeneral.g_ddTankRockDetour.Enable(Hook_Post, mreTankRockPost))
		{
			LogError("Failed to enable detour post: CTankRock::Create");
		}

		if (!g_esGeneral.g_ddEnterStasis.Enable(Hook_Post, mreEnterStasisPost))
		{
			LogError("Failed to enable detour post: Tank::EnterStasis");
		}

		if (!g_esGeneral.g_ddLeaveStasis.Enable(Hook_Post, mreLeaveStasisPost))
		{
			LogError("Failed to enable detour post: Tank::LeaveStasis");
		}

		if (!g_esGeneral.g_ddEventKilled.Enable(Hook_Pre, mreEventKilledPre))
		{
			LogError("Failed to enable detour pre: CTerrorPlayer::Event_Killed");
		}
	}
	else if (g_esGeneral.g_bPluginEnabled && (!bPluginAllowed || !bPluginEnabled))
	{
		g_esGeneral.g_bPluginEnabled = false;

		if (g_esGeneral.g_cvMTBurnMax != null)
		{
			g_esGeneral.g_cvMTBurnMax.FloatValue = 0.85;
		}

		vHookEvents(false);

		if (!g_esGeneral.g_ddLauncherDirectionDetour.Disable(Hook_Pre, mreLaunchDirectionPre))
		{
			LogError("Failed to disable detour pre: CEnvRockLauncher::LaunchCurrentDir");
		}

		if (!g_esGeneral.g_ddTankRockDetour.Disable(Hook_Post, mreTankRockPost))
		{
			LogError("Failed to disable detour post: CTankRock::Create");
		}

		if (!g_esGeneral.g_ddEnterStasis.Disable(Hook_Post, mreEnterStasisPost))
		{
			LogError("Failed to disable detour post: Tank::EnterStasis");
		}

		if (!g_esGeneral.g_ddLeaveStasis.Disable(Hook_Post, mreLeaveStasisPost))
		{
			LogError("Failed to disable detour post: Tank::LeaveStasis");
		}

		if (!g_esGeneral.g_ddEventKilled.Disable(Hook_Pre, mreEventKilledPre))
		{
			LogError("Failed to disable detour pre: CTerrorPlayer::Event_Killed");
		}
	}
}

static void vHookEvents(bool hook)
{
	static bool bHooked;
	if (hook && !bHooked)
	{
		bHooked = true;

		HookEvent("ability_use", vEventHandler);
		HookEvent("bot_player_replace", vEventHandler);
		HookEvent("finale_escape_start", vEventHandler);
		HookEvent("finale_start", vEventHandler, EventHookMode_Pre);
		HookEvent("finale_vehicle_leaving", vEventHandler);
		HookEvent("finale_vehicle_ready", vEventHandler);
		HookEvent("finale_rush", vEventHandler);
		HookEvent("finale_radio_start", vEventHandler);
		HookEvent("finale_radio_damaged", vEventHandler);
		HookEvent("finale_win", vEventHandler);
		HookEvent("heal_success", vEventHandler);
		HookEvent("mission_lost", vEventHandler);
		HookEvent("player_bot_replace", vEventHandler);
		HookEvent("player_death", vEventHandler, EventHookMode_Pre);
		HookEvent("player_hurt", vEventHandler);
		HookEvent("player_incapacitated", vEventHandler);
		HookEvent("player_jump", vEventHandler);
		HookEvent("player_spawn", vEventHandler);
		HookEvent("player_now_it", vEventHandler);
		HookEvent("player_no_longer_it", vEventHandler);
		HookEvent("player_team", vEventHandler);
		HookEvent("revive_success", vEventHandler);
		HookEvent("weapon_fire", vEventHandler);

		if (g_bSecondGame)
		{
			HookEvent("finale_vehicle_incoming", vEventHandler);
			HookEvent("finale_bridge_lowering", vEventHandler);
			HookEvent("gauntlet_finale_start", vEventHandler);
		}

		vHookEventForward(true);
	}
	else if (!hook && bHooked)
	{
		bHooked = false;

		UnhookEvent("ability_use", vEventHandler);
		UnhookEvent("bot_player_replace", vEventHandler);
		UnhookEvent("finale_escape_start", vEventHandler);
		UnhookEvent("finale_start", vEventHandler, EventHookMode_Pre);
		UnhookEvent("finale_vehicle_leaving", vEventHandler);
		UnhookEvent("finale_vehicle_ready", vEventHandler);
		UnhookEvent("finale_rush", vEventHandler);
		UnhookEvent("finale_radio_start", vEventHandler);
		UnhookEvent("finale_radio_damaged", vEventHandler);
		UnhookEvent("finale_win", vEventHandler);
		UnhookEvent("heal_success", vEventHandler);
		UnhookEvent("mission_lost", vEventHandler);
		UnhookEvent("player_bot_replace", vEventHandler);
		UnhookEvent("player_death", vEventHandler, EventHookMode_Pre);
		UnhookEvent("player_hurt", vEventHandler);
		UnhookEvent("player_incapacitated", vEventHandler);
		UnhookEvent("player_jump", vEventHandler);
		UnhookEvent("player_spawn", vEventHandler);
		UnhookEvent("player_now_it", vEventHandler);
		UnhookEvent("player_no_longer_it", vEventHandler);
		UnhookEvent("player_team", vEventHandler);
		UnhookEvent("revive_success", vEventHandler);
		UnhookEvent("weapon_fire", vEventHandler);

		if (g_bSecondGame)
		{
			UnhookEvent("finale_vehicle_incoming", vEventHandler);
			UnhookEvent("finale_bridge_lowering", vEventHandler);
			UnhookEvent("gauntlet_finale_start", vEventHandler);
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
		char sMessage[255], sTag[32];
		FormatEx(sTag, sizeof(sTag), "%s ", MT_TAG4);
		VFormat(sMessage, sizeof(sMessage), activity, 3);

		ReplaceString(sMessage, sizeof(sMessage), "{default}", "\x01");
		ReplaceString(sMessage, sizeof(sMessage), "{mint}", "\x03");
		ReplaceString(sMessage, sizeof(sMessage), "{yellow}", "\x04");
		ReplaceString(sMessage, sizeof(sMessage), "{olive}", "\x05");
		ReplaceString(sMessage, sizeof(sMessage), "{percent}", "%%");

		ShowActivity2(admin, sTag, sMessage);
	}
}

static void vLogMessage(int type, bool timestamp = true, const char[] message, any ...)
{
	if (g_esGeneral.g_iLogMessages & type)
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
				static char sBuffer[255], sMessage[255];
				SetGlobalTransTarget(LANG_SERVER);
				VFormat(sBuffer, sizeof(sBuffer), message, 4);

				ReplaceString(sBuffer, sizeof(sBuffer), "{default}", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "\x01", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "{mint}", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "\x03", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "{yellow}", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "\x04", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "{olive}", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "\x05", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "{percent}", "%%");

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

static void vToggleLogging(int type = -1)
{
	static char sMessage[255], sMap[128], sTime[32], sDate[32];
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
	fLog.WriteLine(message);

	delete fLog;
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

			vResetSpeed(tank, true);
			vSurvivorReactions(tank);
			vSetColor(tank, type, false);
			vTankSpawn(tank, 1);

			static int iNewHealth, iFinalHealth;
			iNewHealth = GetEntProp(tank, Prop_Data, "m_iMaxHealth") + limit;
			iFinalHealth = (iNewHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iNewHealth;
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth);

			g_esPlayer[tank].g_iTankHealth += iFinalHealth;
		}
	}
}

static void vSurvivorReactions(int tank)
{
	static char sModel[40];
	static float flTankPos[3], flSurvivorPos[3];
	static int iTimestamp;
	iTimestamp = RoundToNearest(GetGameTime() * 10.0);
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
						case 'c', 'b', 'h', 'd': FakeClientCommand(iSurvivor, "vocalize C2M1Falling #%i", iTimestamp);
						case 'v', 'e', 'a', 'n': FakeClientCommand(iSurvivor, "vocalize PlaneCrashResponse #%i", iTimestamp);
					}
				}
				case 2: FakeClientCommand(iSurvivor, "vocalize PlayerYellRun #%i", iTimestamp);
				case 3: FakeClientCommand(iSurvivor, "vocalize %s #%i", (g_bSecondGame ? "PlayerWarnTank" : "PlayerAlsoWarnTank"), iTimestamp);
				case 4: FakeClientCommand(iSurvivor, "vocalize PlayerBackUp #%i", iTimestamp);
				case 5: FakeClientCommand(iSurvivor, "vocalize PlayerEmphaticGo #%i", iTimestamp);
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

	vPushNearbyEntities(tank, flTankPos);

	flTankPos[2] += 40.0;
	TE_SetupBeamRingPoint(flTankPos, 10.0, 500.0, g_iBossBeamSprite, g_iBossHaloSprite, 0, 35, 0.75, 88.0, 3.0, {255, 255, 255, 50}, 1000, 0);
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

static void vRemoveEffects(int survivor)
{
	int iEffect = g_esPlayer[survivor].g_iEffect[0];
	if (bIsValidEntRef(iEffect))
	{
		RemoveEntity(iEffect);
	}

	g_esPlayer[survivor].g_iEffect[0] = INVALID_ENT_REFERENCE;

	iEffect = g_esPlayer[survivor].g_iEffect[1];
	if (bIsValidEntRef(iEffect))
	{
		RemoveEntity(iEffect);
	}

	g_esPlayer[survivor].g_iEffect[1] = INVALID_ENT_REFERENCE;
}

static void vRemoveGlow(int tank)
{
	if (!g_bSecondGame)
	{
		return;
	}

	SetEntProp(tank, Prop_Send, "m_glowColorOverride", 0);
	SetEntProp(tank, Prop_Send, "m_bFlashing", 0);
	SetEntProp(tank, Prop_Send, "m_iGlowType", 0);
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
				SDKUnhook(g_esPlayer[tank].g_iLight[iLight], SDKHook_SetTransmit, SetTransmit);
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
				SDKUnhook(g_esPlayer[tank].g_iFlame[iOzTank], SDKHook_SetTransmit, SetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iFlame[iOzTank]);
			}
		}

		g_esPlayer[tank].g_iFlame[iOzTank] = INVALID_ENT_REFERENCE;

		if (bIsValidEntRef(g_esPlayer[tank].g_iOzTank[iOzTank]))
		{
			g_esPlayer[tank].g_iOzTank[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iOzTank[iOzTank]);
			if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]))
			{
				SDKUnhook(g_esPlayer[tank].g_iOzTank[iOzTank], SDKHook_SetTransmit, SetTransmit);
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
				SDKUnhook(g_esPlayer[tank].g_iRock[iRock], SDKHook_SetTransmit, SetTransmit);
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
				SDKUnhook(g_esPlayer[tank].g_iTire[iTire], SDKHook_SetTransmit, SetTransmit);
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
			SDKUnhook(g_esPlayer[tank].g_iPropaneTank, SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_esPlayer[tank].g_iPropaneTank);
		}
	}

	g_esPlayer[tank].g_iPropaneTank = INVALID_ENT_REFERENCE;

	if (bIsValidEntRef(g_esPlayer[tank].g_iFlashlight))
	{
		g_esPlayer[tank].g_iFlashlight = EntRefToEntIndex(g_esPlayer[tank].g_iFlashlight);
		if (bIsValidEntity(g_esPlayer[tank].g_iFlashlight))
		{
			SDKUnhook(g_esPlayer[tank].g_iFlashlight, SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_esPlayer[tank].g_iFlashlight);
		}
	}

	g_esPlayer[tank].g_iFlashlight = INVALID_ENT_REFERENCE;

	if (g_bSecondGame)
	{
		vRemoveGlow(tank);
	}

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
	vResetSpeed(tank, true);
	vSpawnModes(tank, false);
}

static void vReset3(int tank)
{
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
	g_esPlayer[client].g_bDying = false;
	g_esPlayer[client].g_bLastLife = false;
	g_esPlayer[client].g_iLastButtons = 0;
	g_esPlayer[client].g_bStasis = false;
	g_esPlayer[client].g_bThirdPerson = false;

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
			vKillRewardTimer(iPlayer);
		}
	}

	vKillRegularWavesTimer();
}

static void vResetSpeed(int tank, bool mode = false)
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
	g_esPlayer[survivor].g_bRewardedDamage = false;
	g_esPlayer[survivor].g_bRewardedGod = false;
	g_esPlayer[survivor].g_bRewardedSpeed = false;
	g_esPlayer[survivor].g_flDamageBoost = 0.0;
	g_esPlayer[survivor].g_flSpeedBoost = 0.0;

	vResetSurvivorStats2(survivor);
}

static void vResetSurvivorStats2(int survivor)
{
	g_esPlayer[survivor].g_bRewardedAmmo = false;
	g_esPlayer[survivor].g_bRewardedHealth = false;
	g_esPlayer[survivor].g_bRewardedItem = false;
	g_esPlayer[survivor].g_bRewardedRefill = false;
	g_esPlayer[survivor].g_bRewardedRespawn = false;
}

static void vSaveSurvivorStats(int survivor, bool override = false)
{
	if (bIsEntityGrounded(survivor) || override)
	{
		GetClientAbsOrigin(survivor, g_esPlayer[survivor].g_flLastPosition);
		GetClientEyeAngles(survivor, g_esPlayer[survivor].g_flLastAngles);
	}

	if (!override)
	{
		vResetSurvivorStats(survivor);
	}

	vSaveWeapons(survivor);
}

static void vResetTank(int tank)
{
	ExtinguishEntity(tank);
	vAttachParticle(tank, PARTICLE_ELECTRICITY, 2.0, 30.0);
	EmitSoundToAll(SOUND_ELECTRICITY, tank);
	vResetSpeed(tank, true);

	if (g_bSecondGame)
	{
		vRemoveGlow(tank);
	}
}

static void vKillRegularWavesTimer()
{
	if (g_esGeneral.g_hRegularWavesTimer != null)
	{
		KillTimer(g_esGeneral.g_hRegularWavesTimer);
		g_esGeneral.g_hRegularWavesTimer = null;
	}
}

static void vResetTimers(bool delay = false)
{
	switch (delay)
	{
		case true: CreateTimer(g_esGeneral.g_flRegularDelay, tTimerDelayRegularWaves, _, TIMER_FLAG_NO_MAPCHANGE);
		case false:
		{
			if (L4D_HasAnySurvivorLeftSafeArea())
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

static void vCalculateDeath(int tank, int survivor = 0)
{
	if (bIsCustomTankSupported(tank))
	{
		int iAssistant = bIsSurvivor(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME) ? survivor : 0;
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME) && GetClientTeam(iPlayer) != 3 && g_esPlayer[iPlayer].g_iTankDamage[tank] > g_esPlayer[iAssistant].g_iTankDamage[tank])
			{
				iAssistant = iPlayer;
			}
		}

		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), tank);

		float flPercentage = (float(g_esPlayer[iAssistant].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;

		switch (g_esCache[tank].g_iAnnounceDeath)
		{
			case 1: vAnnounceDeath(tank);
			case 2:
			{
				int iOption = iGetMessageType(g_esCache[tank].g_iDeathMessage);
				if (iOption > 0)
				{
					char sPhrase[32];
					if (bIsSurvivor(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME))
					{
						FormatEx(sPhrase, sizeof(sPhrase), "Killer%i", iOption);
						MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, survivor, sTankName, iAssistant, flPercentage);
						vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, survivor, sTankName, iAssistant, flPercentage);
						vVocalizeDeath(survivor, iAssistant, tank);
					}
					else if (flPercentage >= 1.0)
					{
						FormatEx(sPhrase, sizeof(sPhrase), "Assist%i", iOption);
						MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sTankName, iAssistant, flPercentage);
						vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sTankName, iAssistant, flPercentage);
						vVocalizeDeath(0, iAssistant, tank);
					}
					else
					{
						vAnnounceDeath(tank);
					}
				}
			}
		}

		float flRandom = GetRandomFloat(0.1, 100.0);
		if (bIsSurvivor(iAssistant, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esCache[tank].g_iRewardEnabled[1] != -1 && flRandom <= g_esCache[tank].g_flRewardChance[1])
		{
			switch (flPercentage >= g_esCache[tank].g_flRewardPercentage[1])
			{
				case true: vChooseReward(iAssistant, tank, 1);
				case false: MT_PrintToChat(iAssistant, "%s %t", MT_TAG3, "RewardNone", sTankName);
			}
		}

		flPercentage = (float(g_esPlayer[survivor].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;
		if (bIsSurvivor(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esCache[tank].g_iRewardEnabled[0] != -1 && flRandom <= g_esCache[tank].g_flRewardChance[0])
		{
			switch (flPercentage >= g_esCache[tank].g_flRewardPercentage[0])
			{
				case true: vChooseReward(survivor, tank, 0);
				case false: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardNone", sTankName);
			}
		}

		if (g_esCache[tank].g_iRewardEnabled[2] != -1 && flRandom <= g_esCache[tank].g_flRewardChance[2])
		{
			for (int iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
			{
				if (bIsSurvivor(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME) && iTeammate != survivor && iTeammate != iAssistant)
				{
					flPercentage = (float(g_esPlayer[iTeammate].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;
					if (flPercentage >= g_esCache[tank].g_flRewardPercentage[2])
					{
						vChooseReward(iTeammate, tank, 2);
						vResetSurvivorStats2(iTeammate);
					}
					else
					{
						MT_PrintToChat(iTeammate, "%s %t", MT_TAG3, "RewardNone", sTankName);
					}
				}
			}
		}

		vResetDamage(tank);
		vResetSurvivorStats2(survivor);
		vResetSurvivorStats2(iAssistant);
	}
	else if (g_esCache[tank].g_iAnnounceDeath > 0)
	{
		vAnnounceDeath(tank);
	}
}

static void vChooseReward(int survivor, int tank, int priority)
{
	int iType = (g_esCache[tank].g_iRewardEnabled[priority] > 0) ? g_esCache[tank].g_iRewardEnabled[priority] : (1 << GetRandomInt(0, 7));
	iType = bIsDeveloper(survivor, 3) ? MT_REWARD_REFILL|MT_REWARD_DAMAGEBOOST|MT_REWARD_SPEEDBOOST|MT_REWARD_GODMODE|MT_REWARD_ITEM|MT_REWARD_RESPAWN : iType;
	if (g_esCache[tank].g_iUsefulRewards[priority] > 0)
	{
		if (bIsSurvivor(survivor, MT_CHECK_ALIVE))
		{
			int iAmmo = -1, iWeapon = GetPlayerWeaponSlot(survivor, 0);
			if (iWeapon > MaxClients)
			{
				char sWeapon[32];
				GetEntityClassname(iWeapon, sWeapon, sizeof(sWeapon));
				iAmmo = GetEntProp(survivor, Prop_Send, "m_iAmmo", _, iGetWeaponOffset(sWeapon));
			}

			if ((g_esCache[tank].g_iUsefulRewards[priority] & MT_USEFUL_REFILL) && !(iType & MT_REWARD_REFILL) && (g_esPlayer[survivor].g_bLastLife || bIsPlayerDisabled(survivor)) && -1 < iAmmo <= 10)
			{
				iType |= MT_REWARD_REFILL;
			}
			else if ((g_esCache[tank].g_iUsefulRewards[priority] & MT_USEFUL_HEALTH) && !(iType & MT_REWARD_HEALTH) && (g_esPlayer[survivor].g_bLastLife || bIsPlayerDisabled(survivor)))
			{
				iType |= MT_REWARD_HEALTH;
			}
			else if ((g_esCache[tank].g_iUsefulRewards[priority] & MT_USEFUL_AMMO) && !(iType & MT_REWARD_AMMO) && -1 < iAmmo <= 10)
			{
				iType |= MT_REWARD_AMMO;
			}
		}
		else if ((g_esCache[tank].g_iUsefulRewards[priority] & MT_USEFUL_RESPAWN) && !(iType & MT_REWARD_RESPAWN))
		{
			iType |= MT_REWARD_RESPAWN;
		}
	}

	vRewardSurvivor(survivor, tank, iType, priority, true);
	vStartRewardTimer(survivor, tank, iType, priority);
}

static void vRewardSurvivor(int survivor, int tank, int type, int priority, bool apply)
{
	switch (apply)
	{
		case true:
		{
			char sTankName[33];
			vGetTranslatedName(sTankName, sizeof(sTankName), tank);

			if ((type & MT_REWARD_RESPAWN) && !bIsSurvivor(survivor, MT_CHECK_ALIVE) && !g_esPlayer[survivor].g_bRewardedRespawn && g_esGeneral.g_hSDKRespawnPlayer != null)
			{
				g_esPlayer[survivor].g_bRewardedRespawn = true;

				SDKCall(g_esGeneral.g_hSDKRespawnPlayer, survivor);

				bool bTeleport = true;
				float flOrigin[3], flAngles[3];
				for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
				{
					if (bIsSurvivor(iSurvivor) && !bIsPlayerHanging(iSurvivor) && iSurvivor != survivor)
					{
						bTeleport = false;

						GetClientAbsOrigin(iSurvivor, flOrigin);
						GetClientEyeAngles(iSurvivor, flAngles);
						TeleportEntity(survivor, flOrigin, flAngles, NULL_VECTOR);

						break;
					}
				}

				if (bTeleport)
				{
					TeleportEntity(survivor, g_esPlayer[survivor].g_flLastPosition, g_esPlayer[survivor].g_flLastAngles, NULL_VECTOR);
				}

				if (g_esCache[tank].g_iRespawnLoadoutReward[priority] == 1)
				{
					vRemoveWeapons(survivor);
					vGiveWeapons(survivor);
				}

				switch (priority)
				{
					case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardRespawn", sTankName);
					case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardRespawn2", sTankName);
					case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardRespawn3", sTankName);
				}
			}

			if (bIsSurvivor(survivor, MT_CHECK_ALIVE))
			{
				if ((type & MT_REWARD_HEALTH) && GetEntProp(survivor, Prop_Data, "m_takedamage", 1) == 2 && (bIsPlayerDisabled(survivor) || GetEntProp(survivor, Prop_Data, "m_iHealth") < GetEntProp(survivor, Prop_Data, "m_iMaxHealth")) && !g_esPlayer[survivor].g_bRewardedHealth)
				{
					g_esPlayer[survivor].g_bLastLife = false;
					g_esPlayer[survivor].g_bRewardedHealth = true;

					vSaveCaughtSurvivor(survivor);
					vCheatCommand(survivor, "give", "health");

					switch (priority)
					{
						case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardHealth", sTankName);
						case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardHealth2", sTankName);
						case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardHealth3", sTankName);
					}
				}

				if ((type & MT_REWARD_AMMO) && GetPlayerWeaponSlot(survivor, 0) > MaxClients && !g_esPlayer[survivor].g_bRewardedAmmo)
				{
					g_esPlayer[survivor].g_bRewardedAmmo = true;

					vCheatCommand(survivor, "give", "ammo");

					switch (priority)
					{
						case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardAmmo", sTankName);
						case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardAmmo2", sTankName);
						case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardAmmo3", sTankName);
					}
				}

				if ((type & MT_REWARD_REFILL) && !g_esPlayer[survivor].g_bRewardedRefill)
				{
					g_esPlayer[survivor].g_bLastLife = false;
					g_esPlayer[survivor].g_bRewardedRefill = true;

					if (GetEntProp(survivor, Prop_Data, "m_takedamage", 1) == 2 && (bIsPlayerDisabled(survivor) || GetEntProp(survivor, Prop_Data, "m_iHealth") < GetEntProp(survivor, Prop_Data, "m_iMaxHealth")))
					{
						vSaveCaughtSurvivor(survivor);
						vCheatCommand(survivor, "give", "health");
					}

					vCheatCommand(survivor, "give", "ammo");

					switch (priority)
					{
						case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardRefill", sTankName);
						case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardRefill2", sTankName);
						case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardRefill3", sTankName);
					}
				}

				if ((type & MT_REWARD_ITEM) && !g_esPlayer[survivor].g_bRewardedItem)
				{
					g_esPlayer[survivor].g_bRewardedItem = true;

					char sItems[320], sItem[5][64];

					switch (priority)
					{
						case 0: strcopy(sItems, sizeof(sItems), g_esCache[tank].g_sItemReward);
						case 1: strcopy(sItems, sizeof(sItems), g_esCache[tank].g_sItemReward2);
						case 2: strcopy(sItems, sizeof(sItems), g_esCache[tank].g_sItemReward3);
					}

					ExplodeString(sItems, ",", sItem, sizeof(sItem), sizeof(sItem[]));
					for (int iPos = 0; iPos < sizeof(sItem); iPos++)
					{
						if (sItem[iPos][0] != '\0')
						{
							vCheatCommand(survivor, "give", sItem[iPos]);
							ReplaceString(sItem[iPos], sizeof(sItem[]), "_", " ");

							switch (priority)
							{
								case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardItem", sItem[iPos], sTankName);
								case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardItem2", sItem[iPos], sTankName);
								case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardItem3", sItem[iPos], sTankName);
							}
						}
					}
				}

				if ((type & MT_REWARD_SPEEDBOOST) && !g_esPlayer[survivor].g_bRewardedSpeed)
				{
					g_esPlayer[survivor].g_bRewardedSpeed = true;
					g_esPlayer[survivor].g_flSpeedBoost = g_esCache[tank].g_flSpeedBoostReward[priority];

					SDKHook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);

					switch (priority)
					{
						case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardSpeedBoost", sTankName);
						case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardSpeedBoost2", sTankName);
						case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardSpeedBoost3", sTankName);
					}
				}

				if ((type & MT_REWARD_DAMAGEBOOST) && !g_esPlayer[survivor].g_bRewardedDamage)
				{
					g_esPlayer[survivor].g_bRewardedDamage = true;
					g_esPlayer[survivor].g_flDamageBoost = g_esCache[tank].g_flDamageBoostReward[priority];

					switch (priority)
					{
						case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardDamageBoost", sTankName);
						case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardDamageBoost2", sTankName);
						case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardDamageBoost3", sTankName);
					}
				}

				if ((type & MT_REWARD_GODMODE) && !g_esPlayer[survivor].g_bRewardedGod)
				{
					g_esPlayer[survivor].g_bRewardedGod = true;

					SetEntProp(survivor, Prop_Data, "m_takedamage", 0, 1);

					switch (priority)
					{
						case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardGod", sTankName);
						case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardGod2", sTankName);
						case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardGod3", sTankName);
					}
				}

				bool bDeveloper = bIsDeveloper(survivor, 3);
				int iEffect = g_esCache[tank].g_iRewardEffect[priority];
				if ((iEffect & MT_EFFECT_TROPHY) || bDeveloper)
				{
					g_esPlayer[survivor].g_iEffect[0] = EntIndexToEntRef(iCreateParticle(survivor, PARTICLE_ACHIEVED, 3.5, 3.5, true));
				}

				if ((iEffect & MT_EFFECT_FIREWORKS) || bDeveloper)
				{
					g_esPlayer[survivor].g_iEffect[1] = EntIndexToEntRef(iCreateParticle(survivor, PARTICLE_FIREWORK, 4.0, 3.5, false));
				}

				if ((iEffect & MT_EFFECT_SOUND) || bDeveloper)
				{
					EmitSoundToAll(SOUND_ACHIEVEMENT, survivor, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				}

				if (((iEffect & MT_EFFECT_THIRDPERSON) || bDeveloper) && bIsSurvivor(survivor, MT_CHECK_FAKECLIENT))
				{
					vExternalView(survivor, 3.5);
				}
			}
		}
		case false:
		{
			if ((type & MT_REWARD_SPEEDBOOST) && g_esPlayer[survivor].g_bRewardedSpeed)
			{
				if (bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
				{
					MT_PrintToChat(survivor, "%s %t", MT_TAG2, "RewardSpeedBoostEnd");
				}

				g_esPlayer[survivor].g_bRewardedSpeed = false;
			}

			if ((type & MT_REWARD_DAMAGEBOOST) && g_esPlayer[survivor].g_bRewardedDamage)
			{
				if (bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
				{
					MT_PrintToChat(survivor, "%s %t", MT_TAG2, "RewardDamageBoostEnd");
				}

				g_esPlayer[survivor].g_bRewardedDamage = false;
			}

			if ((type & MT_REWARD_GODMODE) && g_esPlayer[survivor].g_bRewardedGod)
			{
				if (bIsSurvivor(survivor, MT_CHECK_ALIVE))
				{
					SetEntProp(survivor, Prop_Data, "m_takedamage", 2, 1);
				}

				if (bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
				{
					MT_PrintToChat(survivor, "%s %t", MT_TAG2, "RewardGodEnd");
				}

				g_esPlayer[survivor].g_bRewardedGod = false;
			}
		}
	}

	Call_StartForward(g_esGeneral.g_gfRewardSurvivorForward);
	Call_PushCell(survivor);
	Call_PushCell(tank);
	Call_PushCell(type);
	Call_PushCell(priority);
	Call_PushFloat(g_esCache[tank].g_flRewardDuration[priority]);
	Call_PushCell(apply);
	Call_Finish();
}

static void vKillRewardTimer(int survivor)
{
	if (g_esPlayer[survivor].g_hRewardTimer != null)
	{
		KillTimer(g_esPlayer[survivor].g_hRewardTimer);
		g_esPlayer[survivor].g_hRewardTimer = null;
	}
}

static void vStartRewardTimer(int survivor, int tank, int type, int priority)
{
	vKillRewardTimer(survivor);

	DataPack dpReward;
	g_esPlayer[survivor].g_hRewardTimer = CreateDataTimer((bIsDeveloper(survivor, 3) ? 60.0 : g_esCache[tank].g_flRewardDuration[priority]), tTimerEndReward, dpReward);
	dpReward.WriteCell(GetClientUserId(survivor));
	dpReward.WriteCell(type);
	dpReward.WriteCell(priority);
}

static void vGiveWeapons(int survivor)
{
	if (g_esPlayer[survivor].g_sWeaponPrimary[0] != '\0')
	{
		vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponPrimary);

		int iSlot = GetPlayerWeaponSlot(survivor, 0);
		if (iSlot > MaxClients)
		{
			SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[survivor].g_iWeaponInfo[0]);
			SetEntProp(survivor, Prop_Send, "m_iAmmo", g_esPlayer[survivor].g_iWeaponInfo[1], _, iGetWeaponOffset(g_esPlayer[survivor].g_sWeaponPrimary));

			if (g_esPlayer[survivor].g_iWeaponInfo[2] > 0)
			{
				SetEntProp(iSlot, Prop_Send, "m_upgradeBitVec", g_esPlayer[survivor].g_iWeaponInfo[2]);
			}

			if (g_bSecondGame)
			{
				SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", g_esPlayer[survivor].g_iWeaponInfo[3]);
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

		int iSlot2 = GetPlayerWeaponSlot(survivor, 1);
		if (iSlot2 > MaxClients && g_esPlayer[survivor].g_iWeaponInfo2 != -1)
		{
			SetEntProp(iSlot2, Prop_Send, "m_iClip1", g_esPlayer[survivor].g_iWeaponInfo2);
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

	g_esPlayer[survivor].g_bDualWielding = false;
	g_esPlayer[survivor].g_iWeaponInfo2 = -1;
	g_esPlayer[survivor].g_sWeaponPrimary[0] = '\0';
	g_esPlayer[survivor].g_sWeaponSecondary[0] = '\0';
	g_esPlayer[survivor].g_sWeaponThrowable[0] = '\0';
	g_esPlayer[survivor].g_sWeaponMedkit[0] = '\0';
	g_esPlayer[survivor].g_sWeaponPills[0] = '\0';
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
		g_esPlayer[survivor].g_iWeaponInfo[1] = GetEntProp(survivor, Prop_Send, "m_iAmmo", _, iGetWeaponOffset(sWeapon));

		if (HasEntProp(iSlot, Prop_Send, "m_upgradeBitVec"))
		{
			g_esPlayer[survivor].g_iWeaponInfo[2] = GetEntProp(iSlot, Prop_Send, "m_upgradeBitVec");
		}

		if (g_bSecondGame)
		{
			g_esPlayer[survivor].g_iWeaponInfo[3] = GetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
		}
	}

	int iSlot2 = 0;
	if (g_bSecondGame)
	{
		if (bIsPlayerIncapacitated(survivor))
		{
			int iMelee = GetEntDataEnt2(survivor, g_esGeneral.g_iMeleeOffset);
			switch (bIsValidEntity(iMelee))
			{
				case true: iSlot2 = iMelee;
				case false: iSlot2 = GetPlayerWeaponSlot(survivor, 1);
			}
		}
		else
		{
			iSlot2 = GetPlayerWeaponSlot(survivor, 1);
		}

		if (iSlot2 > MaxClients)
		{
			GetEntityClassname(iSlot2, sWeapon, sizeof(sWeapon));
			if (StrEqual(sWeapon, "weapon_melee"))
			{
				GetEntPropString(iSlot2, Prop_Data, "m_strMapSetScriptName", sWeapon, sizeof(sWeapon));
			}
		}
	}
	else
	{
		iSlot2 = GetPlayerWeaponSlot(survivor, 1);
		if (iSlot2 > MaxClients)
		{
			GetEntityClassname(iSlot2, sWeapon, sizeof(sWeapon));
		}
	}

	if (iSlot2 > 0)
	{
		strcopy(g_esPlayer[survivor].g_sWeaponSecondary, sizeof(esPlayer::g_sWeaponSecondary), sWeapon);
		if (StrContains(sWeapon, "pistol") != -1 || StrContains(sWeapon, "weapon_chainsaw") != -1)
		{
			g_esPlayer[survivor].g_iWeaponInfo2 = GetEntProp(iSlot2, Prop_Send, "m_iClip1");
		}

		g_esPlayer[survivor].g_bDualWielding = StrContains(sWeapon, "pistol") != -1 && GetEntProp(iSlot2, Prop_Send, "m_isDualWielding") > 0;
	}

	int iSlot3 = GetPlayerWeaponSlot(survivor, 2);
	if (iSlot3 > MaxClients)
	{
		GetEntityClassname(iSlot3, sWeapon, sizeof(sWeapon));
		strcopy(g_esPlayer[survivor].g_sWeaponThrowable, sizeof(esPlayer::g_sWeaponThrowable), sWeapon);
	}

	int iSlot4 = GetPlayerWeaponSlot(survivor, 3);
	if (iSlot4 > MaxClients)
	{
		GetEntityClassname(iSlot4, sWeapon, sizeof(sWeapon));
		strcopy(g_esPlayer[survivor].g_sWeaponMedkit, sizeof(esPlayer::g_sWeaponMedkit), sWeapon);
	}

	int iSlot5 = GetPlayerWeaponSlot(survivor, 4);
	if (iSlot5 > MaxClients)
	{
		GetEntityClassname(iSlot5, sWeapon, sizeof(sWeapon));
		strcopy(g_esPlayer[survivor].g_sWeaponPills, sizeof(esPlayer::g_sWeaponPills), sWeapon);
	}
}

static void vSaveCaughtSurvivor(int survivor)
{
	int iSpecial = GetEntPropEnt(survivor, Prop_Send, "m_pounceAttacker");
	iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_tongueOwner") : iSpecial;
	if (g_bSecondGame)
	{
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_pummelAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_carryAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_jockeyAttacker") : iSpecial;
	}

	if (iSpecial > 0)
	{
		ForcePlayerSuicide(iSpecial);
	}
}

static void vSetupDeveloper(int developer, bool setup)
{
	if (setup && bIsHumanSurvivor(developer))
	{
		if (bIsDeveloper(developer, 2))
		{
			vRemoveWeapons(developer);
			vCheatCommand(developer, "give", "molotov");
			vCheatCommand(developer, "give", "first_aid_kit");
			vCheatCommand(developer, "give", "health");

			switch (g_bSecondGame)
			{
				case true:
				{
					switch (GetRandomInt(1, 5))
					{
						case 1: vCheatCommand(developer, "give", "shotgun_spas");
						case 2: vCheatCommand(developer, "give", "autoshotgun");
						case 3: vCheatCommand(developer, "give", "rifle_ak47");
						case 4: vCheatCommand(developer, "give", "rifle");
						case 5: vCheatCommand(developer, "give", "sniper_military");
					}

					switch (GetRandomInt(1, 2))
					{
						case 1: vCheatCommand(developer, "give", "machete");
						case 2: vCheatCommand(developer, "give", "katana");
					}

					switch (GetRandomInt(1, 2))
					{
						case 1: vCheatCommand(developer, "give", "pain_pills");
						case 2: vCheatCommand(developer, "give", "adrenaline");
					}
				}
				case false:
				{
					switch (GetRandomInt(1, 3))
					{
						case 1: vCheatCommand(developer, "give", "autoshotgun");
						case 2: vCheatCommand(developer, "give", "rifle");
						case 3: vCheatCommand(developer, "give", "hunting_rifle");
					}

					vCheatCommand(developer, "give", "pistol");
					vCheatCommand(developer, "give", "pistol");
					vCheatCommand(developer, "give", "pain_pills");
				}
			}
		}

		if (bIsDeveloper(developer, 6))
		{
			SDKHook(developer, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
		}
	}
	else
	{
		SDKUnhook(developer, SDKHook_PreThinkPost, OnSpeedPreThinkPost);

		if (bIsValidClient(developer, MT_CHECK_ALIVE))
		{
			SetEntPropFloat(developer, Prop_Data, "m_flGravity", 1.0);
			SetEntPropFloat(developer, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
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
	else if (g_esPlayer[tank].g_iTankType > 0 && g_esPlayer[tank].g_iTankType == type && !g_esPlayer[tank].g_bReplaceSelf && !g_esPlayer[tank].g_bKeepCurrentType)
	{
		g_esPlayer[tank].g_iTankType = 0;

		vRemoveProps(tank);
		vChangeTypeForward(tank, type, g_esPlayer[tank].g_iTankType, revert);

		return;
	}
	else if (type > 0 && g_esPlayer[tank].g_iTankType > 0)
	{
		g_esPlayer[tank].g_iOldTankType = g_esPlayer[tank].g_iTankType;
	}

	g_esPlayer[tank].g_iTankType = type;
	g_esPlayer[tank].g_bReplaceSelf = false;

	vChangeTypeForward(tank, g_esPlayer[tank].g_iOldTankType, g_esPlayer[tank].g_iTankType, revert);
	vCacheSettings(tank);
	vSetTankModel(tank);

	if (g_bSecondGame)
	{
		vRemoveGlow(tank);
	}

	SetEntityRenderMode(tank, RENDER_NORMAL);
	SetEntityRenderColor(tank, iGetRandomColor(g_esCache[tank].g_iSkinColor[0]), iGetRandomColor(g_esCache[tank].g_iSkinColor[1]), iGetRandomColor(g_esCache[tank].g_iSkinColor[2]), iGetRandomColor(g_esCache[tank].g_iSkinColor[3]));
}

static void vGetTranslatedName(char[] buffer, int size, int tank = 0, int type = 0)
{
	static int iType;
	iType = (type > 0) ? type : g_esPlayer[tank].g_iTankType;
	if (tank > 0 && g_esPlayer[tank].g_sTankName[0] != '\0')
	{
		static char sSteamID32[32], sSteam3ID[32];
		if (GetClientAuthId(tank, AuthId_Steam2, sSteamID32, sizeof(sSteamID32)) && GetClientAuthId(tank, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID)))
		{
			static char sPhrase[32], sPhrase2[32], sSteamIDFinal[32];
			FormatEx(sPhrase, sizeof(sPhrase), "%s Name", sSteamID32);
			FormatEx(sPhrase2, sizeof(sPhrase2), "%s Name", sSteam3ID);
			FormatEx(sSteamIDFinal, sizeof(sSteamIDFinal), "%s", (TranslationPhraseExists(sPhrase) ? sPhrase : sPhrase2));

			switch (sSteamIDFinal[0] != '\0' && TranslationPhraseExists(sSteamIDFinal))
			{
				case true: strcopy(buffer, size, sSteamIDFinal);
				case false: strcopy(buffer, size, "NoName");
			}
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

static void vSetGlow(int tank)
{
	if (!g_bSecondGame)
	{
		return;
	}

	SetEntProp(tank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGetRandomColor(g_esCache[tank].g_iGlowColor[0]), iGetRandomColor(g_esCache[tank].g_iGlowColor[1]), iGetRandomColor(g_esCache[tank].g_iGlowColor[2])));
	SetEntProp(tank, Prop_Send, "m_bFlashing", g_esCache[tank].g_iGlowFlashing);
	SetEntProp(tank, Prop_Send, "m_nGlowRangeMin", g_esCache[tank].g_iGlowMinRange);
	SetEntProp(tank, Prop_Send, "m_nGlowRange", g_esCache[tank].g_iGlowMaxRange);
	SetEntProp(tank, Prop_Send, "m_iGlowType", ((bIsTankIdle(tank) || g_esCache[tank].g_iGlowType == 0) ? 2 : 3));
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

				SDKHook(iTankModel, SDKHook_SetTransmit, SetTransmit);

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
			iFlag = (iLight < 3) ? MT_PROP_LIGHT : MT_PROP_CROWN;
			iType = (iLight < 3) ? 1 : 8;
			if ((g_esPlayer[tank].g_iLight[iLight] == 0 || g_esPlayer[tank].g_iLight[iLight] == INVALID_ENT_REFERENCE) && flValue <= g_esCache[tank].g_flPropsChance[iType] && (g_esCache[tank].g_iPropsAttached & iFlag))
			{
				vLightProp(tank, iLight, flOrigin, flAngles);
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iLight[iLight]))
			{
				g_esPlayer[tank].g_iLight[iLight] = EntRefToEntIndex(g_esPlayer[tank].g_iLight[iLight]);
				if (bIsValidEntity(g_esPlayer[tank].g_iLight[iLight]))
				{
					SDKUnhook(g_esPlayer[tank].g_iLight[iLight], SDKHook_SetTransmit, SetTransmit);
					RemoveEntity(g_esPlayer[tank].g_iLight[iLight]);
				}

				g_esPlayer[tank].g_iLight[iLight] = INVALID_ENT_REFERENCE;
				if (g_esCache[tank].g_iPropsAttached & iFlag)
				{
					vLightProp(tank, iLight, flOrigin, flAngles);
				}
			}
		}

		GetClientEyePosition(tank, flOrigin);
		GetClientAbsAngles(tank, flAngles);

		for (int iOzTank = 0; iOzTank < sizeof(esPlayer::g_iOzTank); iOzTank++)
		{
			if ((g_esPlayer[tank].g_iOzTank[iOzTank] == 0 || g_esPlayer[tank].g_iOzTank[iOzTank] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[2] && (g_esCache[tank].g_iPropsAttached & MT_PROP_OXYGENTANK))
			{
				g_esPlayer[tank].g_iOzTank[iOzTank] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]))
				{
					SetEntityModel(g_esPlayer[tank].g_iOzTank[iOzTank], MODEL_JETPACK);
					SetEntityRenderColor(g_esPlayer[tank].g_iOzTank[iOzTank], iGetRandomColor(g_esCache[tank].g_iOzTankColor[0]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[1]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[2]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[3]));
					vSetEntityParent(g_esPlayer[tank].g_iOzTank[iOzTank], tank, true);

					switch (iOzTank)
					{
						case 0:
						{
							SetVariantString("rfoot");
							vSetVector(flOrigin, 0.0, 30.0, 8.0);
						}
						case 1:
						{
							SetVariantString("lfoot");
							vSetVector(flOrigin, 0.0, 30.0, -8.0);
						}
					}

					AcceptEntityInput(g_esPlayer[tank].g_iOzTank[iOzTank], "SetParentAttachment");

					static float flAngles2[3];
					vSetVector(flAngles2, 0.0, 0.0, 1.0);
					GetVectorAngles(flAngles2, flAngles2);
					vCopyVector(flAngles, flAngles2);
					flAngles2[2] += 90.0;
					DispatchKeyValueVector(g_esPlayer[tank].g_iOzTank[iOzTank], "origin", flOrigin);
					DispatchKeyValueVector(g_esPlayer[tank].g_iOzTank[iOzTank], "angles", flAngles2);

					AcceptEntityInput(g_esPlayer[tank].g_iOzTank[iOzTank], "Enable");
					AcceptEntityInput(g_esPlayer[tank].g_iOzTank[iOzTank], "DisableCollision");

					TeleportEntity(g_esPlayer[tank].g_iOzTank[iOzTank], flOrigin, NULL_VECTOR, flAngles2);
					DispatchSpawn(g_esPlayer[tank].g_iOzTank[iOzTank]);

					SDKHook(g_esPlayer[tank].g_iOzTank[iOzTank], SDKHook_SetTransmit, SetTransmit);
					g_esPlayer[tank].g_iOzTank[iOzTank] = EntIndexToEntRef(g_esPlayer[tank].g_iOzTank[iOzTank]);

					if ((g_esPlayer[tank].g_iFlame[iOzTank] == 0 || g_esPlayer[tank].g_iFlame[iOzTank] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[3] && (g_esCache[tank].g_iPropsAttached & MT_PROP_FLAME))
					{
						g_esPlayer[tank].g_iFlame[iOzTank] = CreateEntityByName("env_steam");
						if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]))
						{
							SetEntityRenderColor(g_esPlayer[tank].g_iFlame[iOzTank], iGetRandomColor(g_esCache[tank].g_iFlameColor[0]), iGetRandomColor(g_esCache[tank].g_iFlameColor[1]), iGetRandomColor(g_esCache[tank].g_iFlameColor[2]), iGetRandomColor(g_esCache[tank].g_iFlameColor[3]));

							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "spawnflags", "1");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Type", "0");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "InitialState", "1");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Spreadspeed", "1");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Speed", "250");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Startsize", "6");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "EndSize", "8");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Rate", "555");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "JetLength", "40");

							vSetEntityParent(g_esPlayer[tank].g_iFlame[iOzTank], g_esPlayer[tank].g_iOzTank[iOzTank], true);

							static float flOrigin2[3], flAngles3[3];
							vSetVector(flOrigin2, -2.0, 0.0, 26.0);
							vSetVector(flAngles3, 0.0, 0.0, 1.0);
							GetVectorAngles(flAngles3, flAngles3);

							TeleportEntity(g_esPlayer[tank].g_iFlame[iOzTank], flOrigin2, flAngles3, NULL_VECTOR);
							DispatchSpawn(g_esPlayer[tank].g_iFlame[iOzTank]);
							AcceptEntityInput(g_esPlayer[tank].g_iFlame[iOzTank], "TurnOn");

							SDKHook(g_esPlayer[tank].g_iFlame[iOzTank], SDKHook_SetTransmit, SetTransmit);
							g_esPlayer[tank].g_iFlame[iOzTank] = EntIndexToEntRef(g_esPlayer[tank].g_iFlame[iOzTank]);
						}
					}
				}
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iOzTank[iOzTank]))
			{
				g_esPlayer[tank].g_iOzTank[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iOzTank[iOzTank]);
				if (g_esCache[tank].g_iPropsAttached & MT_PROP_OXYGENTANK)
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iOzTank[iOzTank], iGetRandomColor(g_esCache[tank].g_iOzTankColor[0]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[1]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[2]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[3]));
				}
				else
				{
					if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]))
					{
						SDKUnhook(g_esPlayer[tank].g_iOzTank[iOzTank], SDKHook_SetTransmit, SetTransmit);
						RemoveEntity(g_esPlayer[tank].g_iOzTank[iOzTank]);
					}

					g_esPlayer[tank].g_iOzTank[iOzTank] = INVALID_ENT_REFERENCE;
				}

				if (bIsValidEntRef(g_esPlayer[tank].g_iFlame[iOzTank]))
				{
					g_esPlayer[tank].g_iFlame[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iFlame[iOzTank]);
					if (g_esCache[tank].g_iPropsAttached & MT_PROP_FLAME)
					{
						SetEntityRenderColor(g_esPlayer[tank].g_iFlame[iOzTank], iGetRandomColor(g_esCache[tank].g_iFlameColor[0]), iGetRandomColor(g_esCache[tank].g_iFlameColor[1]), iGetRandomColor(g_esCache[tank].g_iFlameColor[2]), iGetRandomColor(g_esCache[tank].g_iFlameColor[3]));
					}
					else
					{
						if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]))
						{
							SDKUnhook(g_esPlayer[tank].g_iFlame[iOzTank], SDKHook_SetTransmit, SetTransmit);
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

					SDKHook(g_esPlayer[tank].g_iRock[iRock], SDKHook_SetTransmit, SetTransmit);
					g_esPlayer[tank].g_iRock[iRock] = EntIndexToEntRef(g_esPlayer[tank].g_iRock[iRock]);
				}
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iRock[iRock]))
			{
				g_esPlayer[tank].g_iRock[iRock] = EntRefToEntIndex(g_esPlayer[tank].g_iRock[iRock]);
				if (g_esCache[tank].g_iPropsAttached & MT_PROP_ROCK)
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iRock[iRock], iGetRandomColor(g_esCache[tank].g_iRockColor[0]), iGetRandomColor(g_esCache[tank].g_iRockColor[1]), iGetRandomColor(g_esCache[tank].g_iRockColor[2]), iGetRandomColor(g_esCache[tank].g_iRockColor[3]));
					vSetRockModel(tank, g_esPlayer[tank].g_iRock[iRock]);
				}
				else
				{
					if (bIsValidEntity(g_esPlayer[tank].g_iRock[iRock]))
					{
						SDKUnhook(g_esPlayer[tank].g_iRock[iRock], SDKHook_SetTransmit, SetTransmit);
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

					SDKHook(g_esPlayer[tank].g_iTire[iTire], SDKHook_SetTransmit, SetTransmit);
					g_esPlayer[tank].g_iTire[iTire] = EntIndexToEntRef(g_esPlayer[tank].g_iTire[iTire]);
				}
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iTire[iTire]))
			{
				g_esPlayer[tank].g_iTire[iTire] = EntRefToEntIndex(g_esPlayer[tank].g_iTire[iTire]);
				if (g_esCache[tank].g_iPropsAttached & MT_PROP_TIRE)
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iTire[iTire], iGetRandomColor(g_esCache[tank].g_iTireColor[0]), iGetRandomColor(g_esCache[tank].g_iTireColor[1]), iGetRandomColor(g_esCache[tank].g_iTireColor[2]), iGetRandomColor(g_esCache[tank].g_iTireColor[3]));
				}
				else
				{
					if (bIsValidEntity(g_esPlayer[tank].g_iTire[iTire]))
					{
						SDKUnhook(g_esPlayer[tank].g_iTire[iTire], SDKHook_SetTransmit, SetTransmit);
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

				SDKHook(g_esPlayer[tank].g_iPropaneTank, SDKHook_SetTransmit, SetTransmit);
				g_esPlayer[tank].g_iPropaneTank = EntIndexToEntRef(g_esPlayer[tank].g_iPropaneTank);
			}
		}
		else if (bIsValidEntRef(g_esPlayer[tank].g_iPropaneTank))
		{
			g_esPlayer[tank].g_iPropaneTank = EntRefToEntIndex(g_esPlayer[tank].g_iPropaneTank);
			if (g_esCache[tank].g_iPropsAttached & MT_PROP_PROPANETANK)
			{
				SetEntityRenderColor(g_esPlayer[tank].g_iPropaneTank, iGetRandomColor(g_esCache[tank].g_iPropTankColor[0]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[1]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[2]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[3]));
			}
			else
			{
				if (bIsValidEntity(g_esPlayer[tank].g_iPropaneTank))
				{
					SDKUnhook(g_esPlayer[tank].g_iPropaneTank, SDKHook_SetTransmit, SetTransmit);
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
				SDKUnhook(g_esPlayer[tank].g_iFlashlight, SDKHook_SetTransmit, SetTransmit);
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
		char sPhrase[32], sSteamID32[32], sSteam3ID[32], sSteamIDFinal[32], sTankNote[32];
		if (GetClientAuthId(tank, AuthId_Steam2, sSteamID32, sizeof(sSteamID32)) && GetClientAuthId(tank, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID)))
		{
			FormatEx(sSteamIDFinal, sizeof(sSteamIDFinal), "%s", (TranslationPhraseExists(sSteamID32) ? sSteamID32 : sSteam3ID));
		}

		FormatEx(sPhrase, sizeof(sPhrase), "Tank #%i", g_esPlayer[tank].g_iTankType);
		FormatEx(sTankNote, sizeof(sTankNote), "%s", ((bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iTankNote == 1 && sSteamIDFinal[0] != '\0') ? sSteamIDFinal : sPhrase));

		bool bExists = TranslationPhraseExists(sTankNote);
		MT_PrintToChatAll("%s %t", MT_TAG3, (bExists ? sTankNote : "NoNote"));
		vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, (bExists ? sTankNote : "NoNote"), LANG_SERVER);
	}

	if (g_bSecondGame && g_esCache[tank].g_iGlowEnabled == 1)
	{
		vSetGlow(tank);
	}
}

static void vAnnounceArrival(int tank, const char[] name)
{
	if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_SPAWN)
	{
		int iOption = iGetMessageType(g_esCache[tank].g_iArrivalMessage), iTimestamp = RoundToNearest(GetGameTime() * 10.0);
		if (iOption > 0)
		{
			char sPhrase[32];
			FormatEx(sPhrase, sizeof(sPhrase), "Arrival%i", iOption);
			MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, name);
			vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, name);
		}

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE))
			{
				switch (GetRandomInt(1, 3))
				{
					case 1: FakeClientCommand(iSurvivor, "vocalize PlayerYellRun #%i", iTimestamp);
					case 2: FakeClientCommand(iSurvivor, "vocalize %s #%i", (g_bSecondGame ? "PlayerWarnTank" : "PlayerAlsoWarnTank"), iTimestamp);
					case 3: FakeClientCommand(iSurvivor, "vocalize PlayerBackUp #%i", iTimestamp);
				}
			}
		}
	}
}

static void vAnnounceDeath(int tank)
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
		TeleportEntity(g_esPlayer[tank].g_iFlashlight, flOrigin2, angles, NULL_VECTOR);
		DispatchSpawn(g_esPlayer[tank].g_iFlashlight);
		vSetEntityParent(g_esPlayer[tank].g_iFlashlight, tank, true);
		AcceptEntityInput(g_esPlayer[tank].g_iFlashlight, "TurnOn");

		SDKHook(g_esPlayer[tank].g_iFlashlight, SDKHook_SetTransmit, SetTransmit);
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

		static float flOrigin[3], flAngles[3];
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
			flAngles[0] = -45.0;

			switch (light)
			{
				case 1: flAngles[1] = 60.0;
				case 2: flAngles[1] = 120.0;
				case 3: flAngles[1] = 180.0;
				case 4: flAngles[1] = 240.0;
				case 5: flAngles[1] = 300.0;
				case 6: flAngles[1] = 360.0;
			}

			flAngles[2] = 0.0;
			flOrigin[2] = 70.0;
		}

		AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "Enable");
		AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "DisableCollision");
		AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "TurnOn");

		switch (light)
		{
			case 0, 1, 2: TeleportEntity(g_esPlayer[tank].g_iLight[light], NULL_VECTOR, angles, NULL_VECTOR);
			case 3, 4, 5, 6, 7, 8, 9: TeleportEntity(g_esPlayer[tank].g_iLight[light], flOrigin, flAngles, NULL_VECTOR);
		}

		DispatchSpawn(g_esPlayer[tank].g_iLight[light]);
		SDKHook(g_esPlayer[tank].g_iLight[light], SDKHook_SetTransmit, SetTransmit);
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
		if (type <= 0 && g_esPlayer[tank].g_iTankType <= 0)
		{
			switch (bIsFinaleMap() && g_esGeneral.g_iTankWave > 0)
			{
				case true: iType = iChooseTank(tank, 1, g_esGeneral.g_iFinaleMinTypes[g_esGeneral.g_iTankWave - 1], g_esGeneral.g_iFinaleMaxTypes[g_esGeneral.g_iTankWave - 1]);
				case false: iType = (bIsNonFinaleMap() && g_esGeneral.g_iRegularMode == 1 && g_esGeneral.g_iRegularWave == 1) ? iChooseTank(tank, 1, g_esGeneral.g_iRegularMinType, g_esGeneral.g_iRegularMaxType) : iChooseTank(tank, 1);
			}

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
		else
		{
			iType = (type > 0) ? type : g_esPlayer[tank].g_iTankType;
			vSetColor(tank, iType, false);
		}

		g_esGeneral.g_iChosenType = 0;

		vTankSpawn(tank);

		CreateTimer(0.1, tTimerCheckView, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerTankUpdate, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

		if (g_esGeneral.g_flIdleCheck > 0.0)
		{
			CreateTimer(g_esGeneral.g_flIdleCheck, tTimerKillIdleTank, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iFavoriteType > 0 && iType != g_esPlayer[tank].g_iFavoriteType)
		{
			vFavoriteMenu(tank);
		}
	}

	g_esGeneral.g_bForceSpawned = false;
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
	if (bIsValidEntity(iRock) && g_esGeneral.g_hSDKDetonateRock != null)
	{
		SDKCall(g_esGeneral.g_hSDKDetonateRock, iRock);
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
		vSetupDeveloper(iPlayer, true);
	}
	else if (bIsTank(iPlayer) && !g_esPlayer[iPlayer].g_bFirstSpawn)
	{
		if (bIsTankInStasis(iPlayer) && g_esGeneral.g_iStasisMode == 1 && g_esGeneral.g_hSDKLeaveStasis != null)
		{
			SDKCall(g_esGeneral.g_hSDKLeaveStasis, iPlayer);
		}

		g_esPlayer[iPlayer].g_bDying = false;
		g_esPlayer[iPlayer].g_bFirstSpawn = true;

		if (g_esPlayer[iPlayer].g_bDied)
		{
			g_esPlayer[iPlayer].g_bDied = false;
			g_esPlayer[iPlayer].g_iOldTankType = 0;
			g_esPlayer[iPlayer].g_iTankType = 0;
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

public void vRockThrowFrame(int ref)
{
	int iRock = EntRefToEntIndex(ref);
	if (g_esGeneral.g_bPluginEnabled && bIsValidEntity(iRock))
	{
		static int iThrower;
		iThrower = GetEntPropEnt(iRock, Prop_Data, "m_hThrower");
		if (bIsTankSupported(iThrower) && bHasCoreAdminAccess(iThrower) && !bIsTankIdle(iThrower) && g_esTank[g_esPlayer[iThrower].g_iTankType].g_iTankEnabled == 1)
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

		static char sOldName[33], sNewName[33];
		vGetTranslatedName(sOldName, sizeof(sOldName), _, g_esPlayer[iTank].g_iOldTankType);
		vGetTranslatedName(sNewName, sizeof(sNewName), _, g_esPlayer[iTank].g_iTankType);
		vSetName(iTank, sOldName, sNewName, iMode);

		if (!bIsInfectedGhost(iTank) && !bIsTankInStasis(iTank))
		{
			g_esPlayer[iTank].g_bKeepCurrentType = false;

			vParticleEffects(iTank);
			vResetSpeed(iTank);
			vSetProps(iTank);
			vThrowInterval(iTank);
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
					static int iHumanCount, iSpawnHealth, iExtraHealthNormal, iExtraHealthBoost, iExtraHealthBoost2, iExtraHealthBoost3, iNoBoost, iBoost,
						iBoost2, iBoost3, iNegaNoBoost, iNegaBoost, iNegaBoost2, iNegaBoost3, iFinalNoHealth, iFinalHealth, iFinalHealth2, iFinalHealth3;
					iHumanCount = iGetHumanCount();
					iSpawnHealth = (g_esCache[iTank].g_iBaseHealth > 0) ? g_esCache[iTank].g_iBaseHealth : GetEntProp(iTank, Prop_Data, "m_iHealth");
					iExtraHealthNormal = iSpawnHealth + g_esCache[iTank].g_iExtraHealth;
					iExtraHealthBoost = (iHumanCount >= g_esCache[iTank].g_iMinimumHumans) ? ((iSpawnHealth * iHumanCount) + g_esCache[iTank].g_iExtraHealth) : iExtraHealthNormal;
					iExtraHealthBoost2 = (iHumanCount >= g_esCache[iTank].g_iMinimumHumans) ? (iSpawnHealth + (iHumanCount * g_esCache[iTank].g_iExtraHealth)) : iExtraHealthNormal;
					iExtraHealthBoost3 = (iHumanCount >= g_esCache[iTank].g_iMinimumHumans) ? (iHumanCount * (iSpawnHealth + g_esCache[iTank].g_iExtraHealth)) : iExtraHealthNormal;
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
					SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalNoHealth);
					SetEntProp(iTank, Prop_Data, "m_iMaxHealth", iFinalNoHealth);

					switch (g_esCache[iTank].g_iMultiHealth)
					{
						case 1:
						{
							SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalHealth);
							SetEntProp(iTank, Prop_Data, "m_iMaxHealth", iFinalHealth);
						}
						case 2:
						{
							SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalHealth2);
							SetEntProp(iTank, Prop_Data, "m_iMaxHealth", iFinalHealth2);
						}
						case 3:
						{
							SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalHealth3);
							SetEntProp(iTank, Prop_Data, "m_iMaxHealth", iFinalHealth3);
						}
					}

					vSpawnMessages(iTank);

					g_esGeneral.g_iTankCount++;
				}

				g_esPlayer[iTank].g_iTankHealth = GetEntProp(iTank, Prop_Data, "m_iMaxHealth");
			}
		}

		Call_StartForward(g_esGeneral.g_gfPostTankSpawnForward);
		Call_PushCell(iTank);
		Call_Finish();

		vCombineAbilitiesForward(iTank, MT_COMBO_POSTSPAWN);
	}
}

static void vAttackInterval(int tank)
{
	if (bIsTankSupported(tank) && g_esCache[tank].g_flAttackInterval > 0.0)
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
	if (bIsTankSupported(tank) && g_esCache[tank].g_flThrowInterval > 0.0)
	{
		int iAbility = GetEntPropEnt(tank, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", g_esCache[tank].g_flThrowInterval);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", GetGameTime() + g_esCache[tank].g_flThrowInterval);
		}
	}
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
	return g_esGeneral.g_bCloneInstalled && MT_IsTankClone(tank);
}

static bool bIsCustomTankSupported(int tank)
{
	if (g_esGeneral.g_bCloneInstalled && !MT_IsCloneSupported(tank))
	{
		return false;
	}

	return true;
}

static bool bIsDeveloper(int developer, int bit = -1)
{
	if (g_esGeneral.g_iAllowDeveloper == 1 || bit == -1 || (bit >= 0 && (g_esGeneral.g_iDeveloperAccess & (1 << bit))))
	{
		static char sSteamID32[32], sSteam3ID[32];
		if (GetClientAuthId(developer, AuthId_Steam2, sSteamID32, sizeof(sSteamID32)))
		{
			if (StrEqual(sSteamID32, "STEAM_1:1:48199803", false) || StrEqual(sSteamID32, "STEAM_0:0:104982031", false))
			{
				return true;
			}
		}
		else if (GetClientAuthId(developer, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID)))
		{
			if (StrEqual(sSteam3ID, "[U:1:96399607]", false) || StrEqual(sSteam3ID, "[U:1:209964062]", false))
			{
				return true;
			}
		}
	}

	return false;
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
	if (g_esGeneral.g_cvMTGameMode == null)
	{
		return false;
	}

	int iMode = g_esGeneral.g_iGameModeTypes;
	iMode = (iMode == 0) ? g_esGeneral.g_cvMTGameModeTypes.IntValue : iMode;
	if (iMode != 0)
	{
		if (!g_esGeneral.g_bMapStarted)
		{
			return false;
		}

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

		if (g_esGeneral.g_iCurrentMode == 0 || !(iMode & g_esGeneral.g_iCurrentMode))
		{
			return false;
		}
	}

	char sFixed[32], sGameMode[32], sGameModes[513], sList[513];
	g_esGeneral.g_cvMTGameMode.GetString(sGameMode, sizeof(sGameMode));
	FormatEx(sFixed, sizeof(sFixed), ",%s,", sGameMode);

	strcopy(sGameModes, sizeof(sGameModes), g_esGeneral.g_sEnabledGameModes);
	if (sGameModes[0] == '\0')
	{
		g_esGeneral.g_cvMTEnabledGameModes.GetString(sGameModes, sizeof(sGameModes));
	}

	if (sGameModes[0] != '\0')
	{
		FormatEx(sList, sizeof(sList), ",%s,", sGameModes);
		if (StrContains(sList, sFixed, false) == -1)
		{
			return false;
		}
	}

	strcopy(sGameModes, sizeof(sGameModes), g_esGeneral.g_sDisabledGameModes);
	if (sGameModes[0] == '\0')
	{
		g_esGeneral.g_cvMTDisabledGameModes.GetString(sGameModes, sizeof(sGameModes));
	}

	if (sGameModes[0] != '\0')
	{
		FormatEx(sList, sizeof(sList), ",%s,", sGameModes);
		if (StrContains(sList, sFixed, false) != -1)
		{
			return false;
		}
	}

	return true;
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
	if (bIsTank(tank) && !bIsTank(tank, MT_CHECK_FAKECLIENT))
	{
		Address adTank = GetEntityAddress(tank);
		if (adTank != Address_Null)
		{
			Address adIntention = view_as<Address>(LoadFromAddress(adTank + view_as<Address>(g_esGeneral.g_iIntentionOffset), NumberType_Int32));
			if (adIntention != Address_Null && g_esGeneral.g_hSDKFirstContainedResponder != null)
			{
				Address adBehavior = view_as<Address>(SDKCall(g_esGeneral.g_hSDKFirstContainedResponder, adIntention));
				if (adBehavior != Address_Null)
				{
					Address adAction = view_as<Address>(SDKCall(g_esGeneral.g_hSDKFirstContainedResponder, adBehavior));
					if (adAction != Address_Null)
					{
						Address adChildAction = Address_Null;
						while ((adChildAction = view_as<Address>(SDKCall(g_esGeneral.g_hSDKFirstContainedResponder, adAction))) != Address_Null)
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

static bool bIsTankInStasis(int tank)
{
	return g_esPlayer[tank].g_bStasis || (g_bSecondGame && ((g_esGeneral.g_hSDKIsInStasis != null && SDKCall(g_esGeneral.g_hSDKIsInStasis, tank)) || bIsTankStasis(tank)));
}

static bool bIsTankInThirdPerson(int tank)
{
	return g_esPlayer[tank].g_bThirdPerson || bIsTankThirdPerson(tank);
}

static bool bIsTypeAvailable(int type, int tank = 0)
{
	if ((tank > 0 && g_esCache[tank].g_iDetectPlugins == 0) && g_esGeneral.g_iDetectPlugins == 0 && g_esTank[type].g_iDetectPlugins == 0)
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

static bool bTankChance(int type)
{
	return GetRandomFloat(0.1, 100.0) <= g_esTank[type].g_flTankChance;
}

static float flGetScaledDamage(float damage)
{
	if (g_esGeneral.g_cvMTDifficulty != null && g_esGeneral.g_iScaleDamage == 1)
	{
		static char sDifficulty[11];
		g_esGeneral.g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));

		switch (CharToLower(sDifficulty[0]))
		{
			case 'e': return (g_esGeneral.g_flDifficultyDamage[0] > 0.0) ? (damage * g_esGeneral.g_flDifficultyDamage[0]) : damage;
			case 'n': return (g_esGeneral.g_flDifficultyDamage[1] > 0.0) ? (damage * g_esGeneral.g_flDifficultyDamage[1]) : damage;
			case 'h': return (g_esGeneral.g_flDifficultyDamage[2] > 0.0) ? (damage * g_esGeneral.g_flDifficultyDamage[2]) : damage;
			case 'i': return (g_esGeneral.g_flDifficultyDamage[3] > 0.0) ? (damage * g_esGeneral.g_flDifficultyDamage[3]) : damage;
		}
	}

	return damage;
}

static int iChooseTank(int tank, int exclude, int min = 0, int max = 0, bool mutate = true)
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

static int iChooseType(int exclude, int tank = 0, int min = 0, int max = 0)
{
	static bool bCondition;
	bCondition = false;
	static int iMin, iMax, iTypeCount, iTankTypes[MT_MAXTYPES + 1];
	iMin = (min > 0) ? min : g_esGeneral.g_iMinType;
	iMax = (max > 0) ? max : g_esGeneral.g_iMaxType;
	iTypeCount = 0;
	for (int iIndex = iMin; iIndex <= iMax; iIndex++)
	{
		switch (exclude)
		{
			case 1: bCondition = g_esTank[iIndex].g_iTankEnabled == 0 || !bHasCoreAdminAccess(tank, iIndex) || g_esTank[iIndex].g_iSpawnEnabled == 0 || !bIsTypeAvailable(iIndex, tank) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(tank, g_esTank[iIndex].g_flOpenAreasOnly) || !bTankChance(iIndex) || (g_esTank[iIndex].g_iTypeLimit > 0 && iGetTypeCount(iIndex) >= g_esTank[iIndex].g_iTypeLimit) || g_esPlayer[tank].g_iTankType == iIndex;
			case 2: bCondition = g_esTank[iIndex].g_iTankEnabled == 0 || !bHasCoreAdminAccess(tank) || g_esTank[iIndex].g_iRandomTank == 0 || g_esTank[iIndex].g_iSpawnEnabled == 0 || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iRandomTank == 0) || g_esPlayer[tank].g_iTankType == iIndex || !bIsTypeAvailable(iIndex, tank) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(tank, g_esTank[iIndex].g_flOpenAreasOnly);
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

static int iGetRealType(int type, int exclude = 0, int tank = 0, int min = 0, int max = 0)
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

static int iGetTypeCount(int type)
{
	static int iTypeCount;
	iTypeCount = 0;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTankSupported(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iTank].g_iTankType == type)
		{
			iTypeCount++;
		}
	}

	return iTypeCount;
}

public void L4D_OnEnterGhostState(int client)
{
	if (bIsTank(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		g_esPlayer[client].g_bKeepCurrentType = true;

		CreateTimer(1.0, tTimerForceSpawnTank, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
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

public Action L4D_OnSpawnTank(const float vecPos[3], const float vecAng[3])
{
	if (g_esGeneral.g_iLimitExtras == 0 || g_esGeneral.g_bForceSpawned)
	{
		g_esGeneral.g_bForceSpawned = false;

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
	if (bIsSurvivor(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esPlayer[pThis].g_bLastLife = false;

		vSaveSurvivorStats(pThis);
	}
	else if (bIsTankSupported(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		if (!bIsCustomTank(pThis))
		{
			g_esGeneral.g_iTankCount--;
		}

		if (bIsCustomTankSupported(pThis))
		{
			vCombineAbilitiesForward(pThis, MT_COMBO_UPONDEATH);
		}
	}
	else if (bIsSpecialInfected(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		SetEntityRenderMode(pThis, RENDER_NORMAL);
		SetEntityRenderColor(pThis, 255, 255, 255, 255);
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

public MRESReturn mreTankRockPost(DHookReturn hReturn)
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

public void vViewQuery(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	switch (bIsValidClient(client) && result == ConVarQuery_Okay)
	{
		case true: g_esPlayer[client].g_bThirdPerson = (StrEqual(cvarName, "z_view_distance") && StringToInt(cvarValue) <= -1) ? true : false;
		case false: g_esPlayer[client].g_bThirdPerson = false;
	}
}

public Action tTimerAnnounce(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank;
	iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankSupported(iTank))
	{
		return Plugin_Stop;
	}

	if (!bIsTankIdle(iTank))
	{
		static char sOldName[33], sNewName[33];
		pack.ReadString(sOldName, sizeof(sOldName));
		pack.ReadString(sNewName, sizeof(sNewName));
		static int iMode;
		iMode = pack.ReadCell();
		vAnnounce(iTank, sOldName, sNewName, iMode);

		return Plugin_Stop;
	}
	else if (bIsTankIdle(iTank, 1) && g_esGeneral.g_cvMTDifficulty != null && g_esGeneral.g_iAggressiveTanks == 1 && !g_esPlayer[iTank].g_bTriggered)
	{
		g_esPlayer[iTank].g_bTriggered = true;

		static int iHealth;
		iHealth = GetEntProp(iTank, Prop_Data, "m_iHealth");
		vDamagePlayer(iTank, iGetRandomSurvivor(iTank), 1.0);
		SetEntProp(iTank, Prop_Data, "m_iHealth", iHealth);
	}

	return Plugin_Continue;
}

public Action tTimerBloodEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_BLOOD) || !g_esPlayer[iTank].g_bBlood)
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
	iTankModel = EntRefToEntIndex(pack.ReadCell());
	iTank = GetClientOfUserId(pack.ReadCell());
	if (iTankModel == INVALID_ENT_REFERENCE || !bIsValidEntity(iTankModel))
	{
		g_esPlayer[iTank].g_bBlur = false;

		return Plugin_Stop;
	}

	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iPropsAttached & MT_PROP_BLUR) || !g_esPlayer[iTank].g_bBlur)
	{
		g_esPlayer[iTank].g_bBlur = false;

		SDKUnhook(iTankModel, SDKHook_SetTransmit, SetTransmit);
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bIsCustomTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !g_esPlayer[iTank].g_bBoss)
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

public Action tTimerCheckView(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank))
	{
		return Plugin_Stop;
	}

	QueryClientConVar(iTank, "z_view_distance", vViewQuery);

	return Plugin_Continue;
}

public Action tTimerDelayRegularWaves(Handle timer)
{
	vKillRegularWavesTimer();
	g_esGeneral.g_hRegularWavesTimer = CreateTimer(g_esGeneral.g_flRegularInterval, tTimerRegularWaves, _, TIMER_REPEAT);
}

public Action tTimerElectricEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_ELECTRICITY) || !g_esPlayer[iTank].g_bElectric)
	{
		g_esPlayer[iTank].g_bElectric = false;

		return Plugin_Stop;
	}

	for (int iAmount = 0; iAmount < 5; iAmount++)
	{
		vAttachParticle(iTank, PARTICLE_ELECTRICITY, 0.75, (1.0 * float(iAmount * 15)));
	}

	return Plugin_Continue;
}

public Action tTimerEndReward(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_hRewardTimer = null;

		vResetSurvivorStats(iSurvivor);

		return Plugin_Stop;
	}

	int iType = pack.ReadCell(), iPriority = pack.ReadCell();
	vRewardSurvivor(iSurvivor, 0, iType, iPriority, false);

	g_esPlayer[iSurvivor].g_hRewardTimer = null;

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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_FIRE) || !g_esPlayer[iTank].g_bFire)
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTank(iTank))
	{
		return Plugin_Stop;
	}

	int iAbility = L4D_MaterializeFromGhost(iTank);
	switch (iAbility == -1)
	{
		case true: MT_PrintToChat(iTank, "%s %t", MT_TAG3, "SpawnManually");
		case false: vTankSpawn(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerIceEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_ICE) || !g_esPlayer[iTank].g_bIce)
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bIsTankSupported(iTank, MT_CHECK_ALIVE) || bIsTankSupported(iTank, MT_CHECK_FAKECLIENT))
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bIsPlayerIncapacitated(iTank))
	{
		return Plugin_Stop;
	}

	ForcePlayerSuicide(iTank);

	return Plugin_Continue;
}

public Action tTimerMeteorEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_METEOR) || !g_esPlayer[iTank].g_bMeteor)
	{
		g_esPlayer[iTank].g_bMeteor = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_METEOR, 6.0, 30.0);

	return Plugin_Continue;
}

public Action tTimerRandomize(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank;
	iTank = GetClientOfUserId(pack.ReadCell());
	static float flTime;
	flTime = pack.ReadFloat();
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !bIsCustomTankSupported(iTank) || !g_esPlayer[iTank].g_bRandomized || (flTime + g_esCache[iTank].g_flRandomDuration < GetEngineTime()))
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

	static int iRock;
	iRock = EntRefToEntIndex(pack.ReadCell());
	if (!g_esGeneral.g_bPluginEnabled || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	static int iTank;
	iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || g_esCache[iTank].g_iRockEffects == 0)
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

public Action tTimerSmokeEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_SMOKE) || !g_esPlayer[iTank].g_bSmoke)
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_SPIT) || !g_esPlayer[iTank].g_bSpit)
	{
		g_esPlayer[iTank].g_bSpit = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_SPIT, 2.0, 30.0);

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
		return Plugin_Stop;
	}

	g_esGeneral.g_iTankWave++;

	return Plugin_Continue;
}

public Action tTimerTransform(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !bIsCustomTankSupported(iTank) || !g_esPlayer[iTank].g_bTransformed)
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
	if (!bIsTankSupported(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0)
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