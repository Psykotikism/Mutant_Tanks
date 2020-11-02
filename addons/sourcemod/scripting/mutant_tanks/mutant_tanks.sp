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
#include <adminmenu>
#include <dhooks>
#include <left4dhooks>
#include <mutant_tanks>

#undef REQUIRE_PLUGIN
#tryinclude <mt_clone>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

//#file "Mutant Tanks v8.80"

public Plugin myinfo =
{
	name = MT_NAME,
	author = MT_AUTHOR,
	description = MT_DESCRIPTION,
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		char sMessage[64];
		FormatEx(sMessage, sizeof(sMessage), "\"%s\" only supports Left 4 Dead 1 & 2.", MT_NAME);
		strcopy(error, err_max, sMessage);

		return APLRes_SilentFailure;
	}

	CreateNative("MT_CanTypeSpawn", aNative_CanTypeSpawn);
	CreateNative("MT_DoesTypeRequireHumans", aNative_DoesTypeRequireHumans);
	CreateNative("MT_GetAccessFlags", aNative_GetAccessFlags);
	CreateNative("MT_GetCurrentFinaleWave", aNative_GetCurrentFinaleWave);
	CreateNative("MT_GetGlowRange", aNative_GetGlowRange);
	CreateNative("MT_GetGlowType", aNative_GetGlowType);
	CreateNative("MT_GetImmunityFlags", aNative_GetImmunityFlags);
	CreateNative("MT_GetMaxType", aNative_GetMaxType);
	CreateNative("MT_GetMinType", aNative_GetMinType);
	CreateNative("MT_GetPropColors", aNative_GetPropColors);
	CreateNative("MT_GetRunSpeed", aNative_GetRunSpeed);
	CreateNative("MT_GetScaledDamage", aNative_GetScaledDamage);
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

	RegPluginLibrary("mutant_tanks");

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_CONCRETE_CHUNK "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_FIREWORKCRATE "models/props_junk/explosive_box001.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_TREE_TRUNK "models/props_foliage/tree_trunk.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl"

#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_ELECTRICITY "electrical_arc_01_parent"
#define PARTICLE_FIRE "aircraft_destroy_fastFireTrail"
#define PARTICLE_ICE "apc_wheel_smoke1"
#define PARTICLE_METEOR "smoke_medium_01"
#define PARTICLE_SMOKE "smoker_smokecloud"
#define PARTICLE_SPIT "spitter_projectile"

#define SOUND_ELECTRICITY "items/suitchargeok1.wav"
#define SOUND_MISSILE "player/tank/attack/thrown_missile_loop_1.wav"
#define SOUND_SPIT "player/spitter/voice/warn/spitter_spit_02.wav"

#define MT_MAX_ABILITIES 100

#define MT_ARRIVAL_SPAWN (1 << 0) // announce spawn
#define MT_ARRIVAL_BOSS (1 << 1) // announce evolution
#define MT_ARRIVAL_RANDOM (1 << 2) // announce randomization
#define MT_ARRIVAL_TRANSFORM (1 << 3) // announce transformation
#define MT_ARRIVAL_REVERT (1 << 4) // announce revert

#define MT_CONFIG_DIFFICULTY (1 << 0) // difficulty_configs
#define MT_CONFIG_MAP (1 << 1) // l4d_map_configs/l4d2_map_configs
#define MT_CONFIG_GAMEMODE (1 << 2) // l4d_gamemode_configs/l4d2_gamemode_configs
#define MT_CONFIG_DAY (1 << 3) // daily_configs
#define MT_CONFIG_COUNT (1 << 4) // playercount_configs
#define MT_CONFIG_FINALE (1 << 5) // l4d_finale_configs/l4d2_finale_configs

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

	bool g_bAbilityPlugin[MT_MAX_ABILITIES + 1];
	bool g_bCloneInstalled;
	bool g_bForceSpawned;
	bool g_bHideNameChange;
	bool g_bMapStarted;
	bool g_bPluginEnabled;
	bool g_bUsedParser;

	char g_sChatFile[PLATFORM_MAX_PATH];
	char g_sChosenPath[PLATFORM_MAX_PATH];
	char g_sCurrentSection[128];
	char g_sCurrentSubSection[128];
	char g_sDisabledGameModes[513];
	char g_sEnabledGameModes[513];
	char g_sHealthCharacters[4];
	char g_sSavePath[PLATFORM_MAX_PATH];
	char g_sSection[PLATFORM_MAX_PATH];
	char g_sSection2[PLATFORM_MAX_PATH];

	ConfigState g_csState;
	ConfigState g_csState2;

	ConVar g_cvMTEnabledGameModes;
	ConVar g_cvMTDifficulty;
	ConVar g_cvMTDisabledGameModes;
	ConVar g_cvMTGameMode;
	ConVar g_cvMTGameModeTypes;
	ConVar g_cvMTGameTypes;
	ConVar g_cvMTPluginEnabled;

	DynamicDetour g_ddEnterStasis;
	DynamicDetour g_ddLauncherDirectionDetour;
	DynamicDetour g_ddLeaveStasis;
	DynamicDetour g_ddTankRockDetour;

	float g_flDifficultyDamage[4];
	float g_flExtrasDelay;
	float g_flIdleCheck;
	float g_flRegularDelay;
	float g_flRegularInterval;

	GlobalForward g_gfAbilityActivatedForward;
	GlobalForward g_gfAbilityCheckForward;
	GlobalForward g_gfButtonPressedForward;
	GlobalForward g_gfButtonReleasedForward;
	GlobalForward g_gfChangeTypeForward;
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
	GlobalForward g_gfRockBreakForward;
	GlobalForward g_gfRockThrowForward;
	GlobalForward g_gfSettingsCachedForward;
	GlobalForward g_gfTypeChosenForward;

	Handle g_hRegularWavesTimer;
	Handle g_hSDKFirstContainedResponder;
	Handle g_hSDKGetName;
	Handle g_hSDKIsInStasis;
	Handle g_hSDKLeaveStasis;

	int g_iAccessFlags;
	int g_iAggressiveTanks;
	int g_iAllowDeveloper;
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iBaseHealth;
	int g_iChosenType;
	int g_iConfigCreate;
	int g_iConfigEnable;
	int g_iConfigExecute;
	int g_iConfigMode;
	int g_iCurrentMode;
	int g_iDeathRevert;
	int g_iDetectPlugins;
	int g_iDisplayHealth;
	int g_iDisplayHealthType;
	int g_iFileTimeOld[6];
	int g_iFileTimeNew[6];
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
	int g_iLauncher;
	int g_iLogMessages;
	int g_iMasterControl;
	int g_iMaxType;
	int g_iMinType;
	int g_iMinimumHumans;
	int g_iMultiHealth;
	int g_iParserViewer;
	int g_iPlayerCount[2];
	int g_iPluginEnabled;
	int g_iRegularAmount;
	int g_iRegularCount;
	int g_iRegularLimit;
	int g_iRegularMaxType;
	int g_iRegularMinType;
	int g_iRegularMode;
	int g_iRegularWave;
	int g_iRequiresHumans;
	int g_iScaleDamage;
	int g_iSection;
	int g_iSpawnMode;
	int g_iStasisMode;
	int g_iTankWave;
	int g_iTeamID[2048];

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
	bool g_bDied;
	bool g_bDying;
	bool g_bElectric;
	bool g_bFire;
	bool g_bFirstSpawn;
	bool g_bIce;
	bool g_bKeepCurrentType;
	bool g_bMeteor;
	bool g_bNeedHealth;
	bool g_bRandomized;
	bool g_bReplaceSelf;
	bool g_bSmoke;
	bool g_bSpit;
	bool g_bStasis;
	bool g_bThirdPerson;
	bool g_bThirdPerson2;
	bool g_bTransformed;
	bool g_bTriggered;

	char g_sHealthCharacters[4];
	char g_sTankName[33];

	float g_flAttackDelay;
	float g_flAttackInterval;
	float g_flClawDamage;
	float g_flPropsChance[9];
	float g_flRandomInterval;
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flThrowInterval;
	float g_flTransformDelay;
	float g_flTransformDuration;

	Handle g_hRandomizeTimer;

	int g_iAccessFlags;
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iBodyEffects;
	int g_iBossHealth[4];
	int g_iBossStageCount;
	int g_iBossStages;
	int g_iBossType[4];
	int g_iBulletImmunity;
	int g_iCooldown;
	int g_iCrownColor[4];
	int g_iDeathRevert;
	int g_iDetectPlugins;
	int g_iDisplayHealth;
	int g_iDisplayHealthType;
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
	int g_iImmunityFlags;
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
	int g_iRequiresHumans;
	int g_iRock[20];
	int g_iRockColor[4];
	int g_iRockEffects;
	int g_iRockModel;
	int g_iSkinColor[4];
	int g_iTankDamage[MAXPLAYERS + 1];
	int g_iTankHealth;
	int g_iTankModel;
	int g_iTankNote;
	int g_iTankType;
	int g_iTire[2];
	int g_iTireColor[4];
	int g_iTransformType[10];
	int g_iUserID;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esTank
{
	bool g_bAbilityFound[MT_MAX_ABILITIES + 1];

	char g_sHealthCharacters[4];
	char g_sTankName[33];

	float g_flAttackInterval;
	float g_flClawDamage;
	float g_flPropsChance[9];
	float g_flRandomInterval;
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flTankChance;
	float g_flThrowInterval;
	float g_flTransformDelay;
	float g_flTransformDuration;

	int g_iAccessFlags;
	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iBodyEffects;
	int g_iBossHealth[4];
	int g_iBossStages;
	int g_iBossType[4];
	int g_iBulletImmunity;
	int g_iCrownColor[4];
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
	int g_iHumanSupport;
	int g_iImmunityFlags;
	int g_iLightColor[4];
	int g_iMeleeImmunity;
	int g_iMenuEnabled;
	int g_iMinimumHumans;
	int g_iMultiHealth;
	int g_iOpenAreasOnly;
	int g_iOzTankColor[4];
	int g_iPropsAttached;
	int g_iPropTankColor[4];
	int g_iRandomTank;
	int g_iRequiresHumans;
	int g_iRockColor[4];
	int g_iRockEffects;
	int g_iRockModel;
	int g_iSkinColor[4];
	int g_iSpawnEnabled;
	int g_iSpawnMode;
	int g_iTankEnabled;
	int g_iTankNote;
	int g_iTireColor[4];
	int g_iTransformType[10];
	int g_iChosenTypeLimit;
}

esTank g_esTank[MT_MAXTYPES + 1];

enum struct esCache
{
	char g_sHealthCharacters[4];
	char g_sTankName[33];

	float g_flAttackInterval;
	float g_flClawDamage;
	float g_flPropsChance[9];
	float g_flRandomInterval;
	float g_flRockDamage;
	float g_flRunSpeed;
	float g_flThrowInterval;
	float g_flTransformDelay;
	float g_flTransformDuration;

	int g_iAnnounceArrival;
	int g_iAnnounceDeath;
	int g_iBodyEffects;
	int g_iBossHealth[4];
	int g_iBossStages;
	int g_iBossType[4];
	int g_iBulletImmunity;
	int g_iCrownColor[4];
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
	int g_iLightColor[4];
	int g_iMeleeImmunity;
	int g_iMinimumHumans;
	int g_iMultiHealth;
	int g_iOzTankColor[4];
	int g_iPropsAttached;
	int g_iPropTankColor[4];
	int g_iRandomTank;
	int g_iRequiresHumans;
	int g_iRockColor[4];
	int g_iRockEffects;
	int g_iRockModel;
	int g_iSkinColor[4];
	int g_iTankNote;
	int g_iTireColor[4];
	int g_iTransformType[10];
}

esCache g_esCache[MAXPLAYERS + 1];

public any aNative_CanTypeSpawn(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	return iType > 0 && g_esTank[iType].g_iSpawnEnabled == 1 && bCanTypeSpawn(iType);
}

public any aNative_DoesTypeRequireHumans(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	return iType > 0 && bAreHumansRequired(iType);
}

public any aNative_GetAccessFlags(Handle plugin, int numParams)
{
	int iMode = GetNativeCell(1), iType = GetNativeCell(2), iAdmin = GetNativeCell(3);
	if (iMode > 0)
	{
		switch (iMode)
		{
			case 1: return g_esGeneral.g_iAccessFlags;
			case 2: return (iType > 0) ? g_esTank[iType].g_iAccessFlags : 0;
			case 3: return bIsValidClient(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esPlayer[iAdmin].g_iAccessFlags : 0;
			case 4: return (bIsValidClient(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && iType > 0) ? g_esAdmin[iType].g_iAccessFlags[iAdmin] : 0;
		}
	}

	return 0;
}

public any aNative_GetCurrentFinaleWave(Handle plugin, int numParams)
{
	return g_esGeneral.g_iTankWave;
}

public any aNative_GetGlowRange(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	bool bMode = GetNativeCell(2);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
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
	return bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) ? g_esCache[iTank].g_iGlowType : 0;
}

public any aNative_GetImmunityFlags(Handle plugin, int numParams)
{
	int iMode = GetNativeCell(1), iType = GetNativeCell(2), iAdmin = GetNativeCell(3);
	if (iMode > 0)
	{
		switch (iMode)
		{
			case 1: return g_esGeneral.g_iImmunityFlags;
			case 2: return (iType > 0) ? g_esTank[iType].g_iImmunityFlags : 0;
			case 3: return bIsValidClient(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esPlayer[iAdmin].g_iImmunityFlags : 0;
			case 4: return (bIsValidClient(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && iType > 0) ? g_esAdmin[iType].g_iImmunityFlags[iAdmin] : 0;
		}
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
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
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
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return (g_esCache[iTank].g_flRunSpeed > 0.0) ? g_esCache[iTank].g_flRunSpeed : 1.0;
	}

	return 0.0;
}

public any aNative_GetScaledDamage(Handle plugin, int numParams)
{
	return flGetScaledDamage(GetNativeCell(1));
}

public any aNative_GetTankColors(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = iClamp(GetNativeCell(2), 1, 2);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
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
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), iTank);
		SetNativeString(2, sTankName, sizeof(sTankName));
	}
}

public any aNative_GetTankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) ? g_esPlayer[iTank].g_iTankType : 0;
}

public any aNative_HasAdminAccess(Handle plugin, int numParams)
{
	int iAdmin = GetNativeCell(1);
	return bIsTank(iAdmin, MT_CHECK_INDEX|MT_CHECK_INGAME) && bHasCoreAdminAccess(iAdmin);
}

public any aNative_HasChanceToSpawn(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	return iType > 0 && bTankChance(iType);
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
	return bIsHumanSurvivor(iSurvivor) && bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && bIsCoreAdminImmune(iSurvivor, iTank);
}

public any aNative_IsCorePluginEnabled(Handle plugin, int numParams)
{
	return g_esGeneral.g_bPluginEnabled;
}

public any aNative_IsCustomTankSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsCustomTankAllowed(iTank);
}

public any aNative_IsFinaleType(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	return iType > 0 && g_esTank[iType].g_iFinaleTank == 1;
}

public any aNative_IsGlowEnabled(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esCache[iTank].g_iGlowEnabled == 1;
}

public any aNative_IsGlowFlashing(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esCache[iTank].g_iGlowFlashing == 1;
}

public any aNative_IsNonFinaleType(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	return iType > 0 && g_esTank[iType].g_iFinaleTank == 2;
}

public any aNative_IsTankIdle(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = iClamp(GetNativeCell(2), 0, 2);
	return bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsTankIdle(iTank, iType);
}

public any aNative_IsTankSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsTankAllowed(iTank, GetNativeCell(2));
}

public any aNative_IsTypeEnabled(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	return iType > 0 && g_esTank[iType].g_iTankEnabled == 1 && bIsTypeAvailable(iType);
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
			vLogMessage(iType, sBuffer);
		}
	}
}

public any aNative_SetTankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = GetNativeCell(2);
	bool bMode = GetNativeCell(3);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && iType > 0)
	{
		switch (bMode)
		{
			case true:
			{
				vSetColor(iTank, iType);
				vTankSpawn(iTank, 5);
			}
			case false:
			{
				vNewTankSettings(iTank);
				g_esPlayer[iTank].g_iOldTankType = g_esPlayer[iTank].g_iTankType;
				g_esPlayer[iTank].g_iTankType = iType;
				vCacheSettings(iTank);
			}
		}
	}
}

public any aNative_SpawnTank(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = GetNativeCell(2);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && iType > 0)
	{
		vQueueTank(iTank, iType);
	}
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
	g_esGeneral.g_gfChangeTypeForward = new GlobalForward("MT_OnChangeType", ET_Ignore, Param_Cell, Param_Cell);
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
	g_esGeneral.g_gfRockBreakForward = new GlobalForward("MT_OnRockBreak", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfRockThrowForward = new GlobalForward("MT_OnRockThrow", ET_Ignore, Param_Cell, Param_Cell);
	g_esGeneral.g_gfSettingsCachedForward = new GlobalForward("MT_OnSettingsCached", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_esGeneral.g_gfTypeChosenForward = new GlobalForward("MT_OnTypeChosen", ET_Event, Param_CellByRef, Param_Cell);

	vMultiTargetFilters(1);

	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_config", cmdMTConfig, "View a section of the config file.");
	RegConsoleCmd("sm_mt_info", cmdMTInfo, "View information about Mutant Tanks.");
	RegConsoleCmd("sm_mt_list", cmdMTList, "View a list of installed abilities.");
	RegConsoleCmd("sm_mt_version", cmdMTVersion, "Find out the current version of Mutant Tanks.");
	RegAdminCmd("sm_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Mutant Tank.");
	RegAdminCmd("sm_mt_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Mutant Tank.");
	RegConsoleCmd("sm_tank2", cmdTank2, "Spawn a Mutant Tank.");
	RegConsoleCmd("sm_mt_tank2", cmdTank2, "Spawn a Mutant Tank.");
	RegConsoleCmd("sm_mutanttank", cmdMutantTank, "Choose a Mutant Tank.");

	g_esGeneral.g_cvMTDisabledGameModes = CreateConVar("mt_disabledgamemodes", "", "Disable Mutant Tanks in these game modes.\nSeparate by commas.\nEmpty: None\nNot empty: Disabled only in these game modes.");
	g_esGeneral.g_cvMTEnabledGameModes = CreateConVar("mt_enabledgamemodes", "", "Enable Mutant Tanks in these game modes.\nSeparate by commas.\nEmpty: All\nNot empty: Enabled only in these game modes.");
	g_esGeneral.g_cvMTGameModeTypes = CreateConVar("mt_gamemodetypes", "0", "Enable Mutant Tanks in these game mode types.\n0 OR 15: All game mode types.\n1: Co-Op modes only.\n2: Versus modes only.\n4: Survival modes only.\n8: Scavenge modes only. (Only available in Left 4 Dead 2.)", _, true, 0.0, true, 15.0);
	g_esGeneral.g_cvMTPluginEnabled = CreateConVar("mt_pluginenabled", "1", "Enable Mutant Tanks.\n0: OFF\n1: ON", _, true, 0.0, true, 1.0);
	CreateConVar("mt_pluginversion", MT_VERSION, "Mutant Tanks Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	AutoExecConfig(true, "mutant_tanks");

	g_esGeneral.g_cvMTDifficulty = FindConVar("z_difficulty");
	g_esGeneral.g_cvMTGameMode = FindConVar("mp_gamemode");
	g_esGeneral.g_cvMTGameTypes = FindConVar("sv_gametypes");

	g_esGeneral.g_cvMTDisabledGameModes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTEnabledGameModes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTGameModeTypes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTPluginEnabled.AddChangeHook(vMTPluginStatusCvar);

	g_esGeneral.g_cvMTDifficulty.AddChangeHook(vMTGameDifficultyCvar);

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

	TopMenu tmAdminMenu;
	if (LibraryExists("adminmenu") && ((tmAdminMenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(tmAdminMenu);
	}

	HookUserMessage(GetUserMessageId("SayText2"), umNameChange, true);

	char sDate[32];
	FormatTime(sDate, sizeof(sDate), "%Y-%m-%d", GetTime());
	BuildPath(Path_SM, g_esGeneral.g_sChatFile, sizeof(esGeneral::g_sChatFile), "logs/mutant_tanks_%s.log", sDate);

	GameData gdMutantTanks = new GameData("mutant_tanks");

	switch (gdMutantTanks == null)
	{
		case true: LogError("Unable to load the \"mutant_tanks\" gamedata file.");
		case false:
		{
			if (bIsValidGame())
			{
				StartPrepSDKCall(SDKCall_Player);
				if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CBaseEntity::IsInStasis"))
				{
					vLogMessage(MT_LOG_SERVER, "%s Failed to load offset: CBaseEntity::IsInStasis", MT_TAG);
				}

				PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
				g_esGeneral.g_hSDKIsInStasis = EndPrepSDKCall();
				if (g_esGeneral.g_hSDKIsInStasis == null)
				{
					vLogMessage(MT_LOG_SERVER, "%s Your \"CBaseEntity::IsInStasis\" offsets are outdated.", MT_TAG);
				}
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "Tank::LeaveStasis"))
			{
				vLogMessage(MT_LOG_SERVER, "%s Failed to find signature: Tank::LeaveStasis", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKLeaveStasis = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKLeaveStasis == null)
			{
				vLogMessage(MT_LOG_SERVER, "%s Your \"Tank::LeaveStasis\" signature is outdated..", MT_TAG);
			}

			g_esGeneral.g_iIntentionOffset = gdMutantTanks.GetOffset("Tank::GetIntentionInterface");
			if (g_esGeneral.g_iIntentionOffset == -1)
			{
				vLogMessage(MT_LOG_SERVER, "%s Failed to load offset: Tank::GetIntentionInterface", MT_TAG);
			}

			int iOffset = gdMutantTanks.GetOffset("TankIntention::FirstContainedResponder");
			StartPrepSDKCall(SDKCall_Raw);
			PrepSDKCall_SetVirtual(iOffset);
			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKFirstContainedResponder = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKFirstContainedResponder == null)
			{
				vLogMessage(MT_LOG_SERVER, "%s Your \"TankIntention::FirstContainedResponder\" offsets are outdated.", MT_TAG);
			}

			iOffset = gdMutantTanks.GetOffset("TankIdle::GetName");
			StartPrepSDKCall(SDKCall_Raw);
			PrepSDKCall_SetVirtual(iOffset);
			PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Plain);
			g_esGeneral.g_hSDKGetName = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetName == null)
			{
				vLogMessage(MT_LOG_SERVER, "%s Your \"TankIdle::GetName\" offsets are outdated.", MT_TAG);
			}

			g_esGeneral.g_ddLauncherDirectionDetour = DynamicDetour.FromConf(gdMutantTanks, "CEnvRockLauncher::LaunchCurrentDir");
			if (g_esGeneral.g_ddLauncherDirectionDetour == null)
			{
				vLogMessage(MT_LOG_SERVER, "%s Failed to find signature: CEnvRockLauncher::LaunchCurrentDir", MT_TAG);
			}

			g_esGeneral.g_ddTankRockDetour = DynamicDetour.FromConf(gdMutantTanks, "CTankRock::Create");
			if (g_esGeneral.g_ddTankRockDetour == null)
			{
				vLogMessage(MT_LOG_SERVER, "%s Failed to find signature: CTankRock::Create", MT_TAG);
			}

			g_esGeneral.g_ddEnterStasis = DynamicDetour.FromConf(gdMutantTanks, "Tank::EnterStasis");
			if (g_esGeneral.g_ddEnterStasis == null)
			{
				vLogMessage(MT_LOG_SERVER, "%s Failed to find signature: Tank::EnterStasis", MT_TAG);
			}

			g_esGeneral.g_ddLeaveStasis = DynamicDetour.FromConf(gdMutantTanks, "Tank::LeaveStasis");
			if (g_esGeneral.g_ddLeaveStasis == null)
			{
				vLogMessage(MT_LOG_SERVER, "%s Failed to find signature: Tank::LeaveStasis", MT_TAG);
			}

			delete gdMutantTanks;
		}
	}

	g_esGeneral.g_alFilePaths = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
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

	PrecacheModel(MODEL_CONCRETE_CHUNK, true);
	PrecacheModel(MODEL_FIREWORKCRATE, true);
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_JETPACK, true);
	PrecacheModel(MODEL_PROPANETANK, true);
	PrecacheModel(MODEL_TIRES, true);
	PrecacheModel(MODEL_TREE_TRUNK, true);
	PrecacheModel(MODEL_WITCH, true);
	PrecacheModel(MODEL_WITCHBRIDE, true);

	iPrecacheParticle(PARTICLE_BLOOD);
	iPrecacheParticle(PARTICLE_ELECTRICITY);
	iPrecacheParticle(PARTICLE_FIRE);
	iPrecacheParticle(PARTICLE_ICE);
	iPrecacheParticle(PARTICLE_METEOR);
	iPrecacheParticle(PARTICLE_SMOKE);
	iPrecacheParticle(PARTICLE_SPIT);

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_SPIT, true);

	vReset();

	vToggleLogging(1);
}

public void OnClientPutInServer(int client)
{
	g_esPlayer[client].g_iUserID = GetClientUserId(client);

	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset3(client);
	vCacheSettings(client);
	vResetCore(client);
}

public void OnClientPostAdminCheck(int client)
{
	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		vLoadConfigs(g_esGeneral.g_sSavePath, 3);
	}

	g_esGeneral.g_iPlayerCount[0] = iGetPlayerCount();
}

public void OnClientDisconnect_Post(int client)
{
	vReset3(client);
	vResetCore(client);

	g_esGeneral.g_iPlayerCount[0] = iGetPlayerCount();
}

public void OnConfigsExecuted()
{
	g_esGeneral.g_iRegularCount = 0;
	g_esGeneral.g_iChosenType = 0;

	vLoadConfigs(g_esGeneral.g_sSavePath, 1);

	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (IsMapValid(sMapName))
	{
		vPluginStatus();
		vResetTimers();

		CreateTimer(1.0, tTimerRefreshConfigs, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	if ((g_esGeneral.g_iConfigCreate & MT_CONFIG_DIFFICULTY) && g_esGeneral.g_iConfigEnable == 1)
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

	if ((g_esGeneral.g_iConfigCreate & MT_CONFIG_MAP) && g_esGeneral.g_iConfigEnable == 1)
	{
		char sSMPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/%s", (bIsValidGame() ? "l4d2_map_configs/" : "l4d_map_configs/"));
		CreateDirectory(sSMPath, 511);

		char sMap[128];
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
					alMaps.GetString(iPos, sMap, sizeof(sMap));
					vCreateConfigFile((bIsValidGame() ? "l4d2_map_configs/" : "l4d_map_configs/"), sMap);
				}
			}

			delete alMaps;
		}
	}

	if ((g_esGeneral.g_iConfigCreate & MT_CONFIG_GAMEMODE) && g_esGeneral.g_iConfigEnable == 1)
	{
		char sSMPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/%s", (bIsValidGame() ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"));
		CreateDirectory(sSMPath, 511);

		char sGameType[2049], sTypes[64][32];
		g_esGeneral.g_cvMTGameTypes.GetString(sGameType, sizeof(sGameType));
		ReplaceString(sGameType, sizeof(sGameType), " ", "");
		ExplodeString(sGameType, ",", sTypes, sizeof(sTypes), sizeof(sTypes[]));

		for (int iMode = 0; iMode < sizeof(sTypes); iMode++)
		{
			if (StrContains(sGameType, sTypes[iMode]) != -1 && sTypes[iMode][0] != '\0')
			{
				vCreateConfigFile((bIsValidGame() ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"), sTypes[iMode]);
			}
		}
	}

	if ((g_esGeneral.g_iConfigCreate & MT_CONFIG_DAY) && g_esGeneral.g_iConfigEnable == 1)
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

	if ((g_esGeneral.g_iConfigCreate & MT_CONFIG_COUNT) && g_esGeneral.g_iConfigEnable == 1)
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

	if ((g_esGeneral.g_iConfigCreate & MT_CONFIG_FINALE) && g_esGeneral.g_iConfigEnable == 1)
	{
		char sSMPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/%s", (bIsValidGame() ? "l4d2_finale_configs/" : "l4d_finale_configs/"));
		CreateDirectory(sSMPath, 511);

		char sEvent[32];
		int iAmount = bIsValidGame() ? 11 : 8;
		for (int iType = 0; iType < iAmount; iType++)
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

			vCreateConfigFile((bIsValidGame() ? "l4d2_finale_configs/" : "l4d_finale_configs/"), sEvent);
		}
	}

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_esGeneral.g_iConfigEnable == 1 && g_esGeneral.g_cvMTDifficulty != null)
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

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_MAP) && g_esGeneral.g_iConfigEnable == 1)
	{
		char sMap[64], sMapConfig[PLATFORM_MAX_PATH];
		GetCurrentMap(sMap, sizeof(sMap));

		BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), "data/mutant_tanks/%s/%s.cfg", (bIsValidGame() ? "l4d2_map_configs" : "l4d_map_configs"), sMap);
		if (FileExists(sMapConfig, true))
		{
			vCustomConfig(sMapConfig);
			g_esGeneral.g_iFileTimeOld[2] = GetFileTime(sMapConfig, FileTime_LastChange);
		}
	}

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_GAMEMODE) && g_esGeneral.g_iConfigEnable == 1)
	{
		char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
		g_esGeneral.g_cvMTGameMode.GetString(sMode, sizeof(sMode));

		BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), "data/mutant_tanks/%s/%s.cfg", (bIsValidGame() ? "l4d2_gamemode_configs" : "l4d_gamemode_configs"), sMode);
		if (FileExists(sModeConfig, true))
		{
			vCustomConfig(sModeConfig);
			g_esGeneral.g_iFileTimeOld[3] = GetFileTime(sModeConfig, FileTime_LastChange);
		}
	}

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DAY) && g_esGeneral.g_iConfigEnable == 1)
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

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_COUNT) && g_esGeneral.g_iConfigEnable == 1)
	{
		char sCountConfig[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/playercount_configs/%i.cfg", iGetPlayerCount());
		if (FileExists(sCountConfig, true))
		{
			vCustomConfig(sCountConfig);
			g_esGeneral.g_iFileTimeOld[5] = GetFileTime(sCountConfig, FileTime_LastChange);
		}
	}
}

public void OnMapEnd()
{
	g_esGeneral.g_bMapStarted = false;

	vReset();

	vToggleLogging(0);
}

public void OnPluginEnd()
{
	vMultiTargetFilters(0);
	vClearSectionList();

	if (g_esGeneral.g_alFilePaths != null)
	{
		g_esGeneral.g_alFilePaths.Clear();

		delete g_esGeneral.g_alFilePaths;
	}

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
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

	static char sMessage[255];

	msg.ReadByte();
	msg.ReadByte();
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

	TopMenuObject tmoCommands = g_esGeneral.g_tmMTMenu.AddCategory("MutantTanks", iMTAdminMenuHandler);
	if (tmoCommands != INVALID_TOPMENUOBJECT)
	{
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_tank", vMutantTanksMenu, tmoCommands, "sm_mt_tank", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_config", vMTConfigMenu, tmoCommands, "sm_mt_config", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_info", vMTInfoMenu, tmoCommands, "sm_mt_info", ADMFLAG_GENERIC);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_list", vMTListMenu, tmoCommands, "sm_mt_list", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_version", vMTVersionMenu, tmoCommands, "sm_mt_version", ADMFLAG_GENERIC);
	}
}

public int iMTAdminMenuHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayTitle, TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%s", MT_NAME);
	}

	return 0;
}

public void vMutantTanksMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTMenu", param);
		case TopMenuAction_SelectOption:
		{
			g_esPlayer[param].g_bAdminMenu = true;

			vTankMenu(param, 0);
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
			g_esPlayer[param].g_bAdminMenu = true;

			vPathMenu(param, 0);
		}
	}
}

public void vMTInfoMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTInfoMenu", param);
		case TopMenuAction_SelectOption:
		{
			g_esPlayer[param].g_bAdminMenu = true;

			vInfoMenu(param, 0);
		}
	}
}

public void vMTListMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTListMenu", param);
		case TopMenuAction_SelectOption: vListAbilities(param);
	}
}

public void vMTVersionMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTVersionMenu", param);
		case TopMenuAction_SelectOption: MT_PrintToChat(param, "%s %s{yellow} v%s{mint}, by{olive} %s", MT_TAG3, MT_NAME, MT_VERSION, MT_AUTHOR);
	}
}

public Action cmdMTConfig(int client, int args)
{
	if (g_esGeneral.g_bUsedParser)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "StillParsing");

		return Plugin_Handled;
	}

	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (!CheckCommandAccess(client, "sm_tank", ADMFLAG_ROOT) && !CheckCommandAccess(client, "sm_mt_tank", ADMFLAG_ROOT) && !bIsDeveloper(client))
		{
			MT_ReplyToCommand(client, "%s %t", MT_TAG2, "NoCommandAccess");

			return Plugin_Handled;
		}
	}
	else
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vPathMenu(client, 0);
		}

		return Plugin_Handled;
	}

	GetCmdArg(1, g_esGeneral.g_sSection, sizeof(esGeneral::g_sSection));
	if (IsCharNumeric(g_esGeneral.g_sSection[0]))
	{
		g_esGeneral.g_iSection = StringToInt(g_esGeneral.g_sSection);
	}

	BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof(esGeneral::g_sChosenPath), "data/mutant_tanks/mutant_tanks.cfg");
	vParseConfig(client);

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

			vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "ErrorParsing", LANG_SERVER, g_esGeneral.g_sChosenPath, sSmcError);
		}

		delete smcParser;
	}
	else
	{
		vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "FailedParsing", LANG_SERVER, g_esGeneral.g_sChosenPath);
	}
}

public void SMCParseStart2(SMCParser smc)
{
	if (bIsValidClient(g_esGeneral.g_iParserViewer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		g_esGeneral.g_csState2 = ConfigState_None;
		g_esGeneral.g_iIgnoreLevel2 = 0;

		MT_PrintToChat(g_esGeneral.g_iParserViewer, "%s %t", MT_TAG2, "StartParsing");
	}
}

public SMCResult SMCNewSection2(SMCParser smc, const char[] name, bool opt_quotes)
{
	if (bIsValidClient(g_esGeneral.g_iParserViewer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (g_esGeneral.g_iIgnoreLevel2)
		{
			g_esGeneral.g_iIgnoreLevel2++;

			return SMCParse_Continue;
		}

		if (g_esGeneral.g_csState2 == ConfigState_None)
		{
			if (StrEqual(name, "MutantTanks", false) || StrEqual(name, MT_NAME, false) || StrEqual(name, "Mutant_Tanks", false) || StrEqual(name, "MT", false))
			{
				g_esGeneral.g_csState2 = ConfigState_Start;

				MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("\"%s\"\n{") : ("%s\n{"), name);
			}
			else
			{
				g_esGeneral.g_iIgnoreLevel2++;
			}
		}
		else if (g_esGeneral.g_csState2 == ConfigState_Start)
		{
			if ((StrEqual(name, "PluginSettings", false) || StrEqual(name, "Plugin Settings", false) || StrEqual(name, "Plugin_Settings", false) || StrEqual(name, "settings", false)) && StrContains(name, g_esGeneral.g_sSection, false) != -1)
			{
				g_esGeneral.g_csState2 = ConfigState_Settings;

				MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%10s \"%s\"\n%10s {") : ("%10s %s\n%10s {"), "", name, "");
			}
			else if (g_esGeneral.g_iSection > 0 && (StrContains(name, "Tank#", false) != -1 || StrContains(name, "Tank #", false) != -1 || StrContains(name, "Tank_#", false) != -1 || StrContains(name, "Tank", false) != -1 || name[0] == '#' || IsCharNumeric(name[0]) || StrContains(name, "all", false) != -1 || StrContains(name, ",") != -1 || StrContains(name, "-") != -1))
			{
				static char sTankName[7][33];
				FormatEx(sTankName[0], sizeof(sTankName[]), "Tank#%i", g_esGeneral.g_iSection);
				FormatEx(sTankName[1], sizeof(sTankName[]), "Tank #%i", g_esGeneral.g_iSection);
				FormatEx(sTankName[2], sizeof(sTankName[]), "Tank_#%i", g_esGeneral.g_iSection);
				FormatEx(sTankName[3], sizeof(sTankName[]), "Tank%i", g_esGeneral.g_iSection);
				FormatEx(sTankName[4], sizeof(sTankName[]), "Tank %i", g_esGeneral.g_iSection);
				FormatEx(sTankName[5], sizeof(sTankName[]), "Tank_%i", g_esGeneral.g_iSection);
				FormatEx(sTankName[6], sizeof(sTankName[]), "#%i", g_esGeneral.g_iSection);

				static int iIndex;
				iIndex = iFindSectionType(name, g_esGeneral.g_iSection);

				static char sIndex[5], sType[5];
				IntToString(iIndex, sIndex, sizeof(sIndex));
				IntToString(g_esGeneral.g_iSection, sType, sizeof(sType));

				if (StrContains(name, sType) != -1)
				{
					for (int iType = 0; iType < sizeof(sTankName); iType++)
					{
						if (StrEqual(name, sTankName[iType], false) || StrEqual(name, sType) || StrEqual(sIndex, sType) || StrContains(name, "all", false) != -1)
						{
							g_esGeneral.g_csState2 = ConfigState_Type;

							MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%10s \"%s\"\n%10s {") : ("%10s %s\n%10s {"), "", name, "");
						}
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

				MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%10s \"%s\"\n%10s {") : ("%10s %s\n%10s {"), "", name, "");
			}
			else if ((StrContains(name, "STEAM_", false) == 0 || strncmp("0:", name, 2) == 0 || strncmp("1:", name, 2) == 0 || (!strncmp(name, "[U:", 3) && name[strlen(name) - 1] == ']')) && StrContains(name, g_esGeneral.g_sSection, false) != -1)
			{
				g_esGeneral.g_csState2 = ConfigState_Admin;

				MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%10s \"%s\"\n%10s {") : ("%10s %s\n%10s {"), "", name, "");
			}
			else
			{
				g_esGeneral.g_iIgnoreLevel2++;
			}
		}
		else if (g_esGeneral.g_csState2 == ConfigState_Settings || g_esGeneral.g_csState2 == ConfigState_Type || g_esGeneral.g_csState2 == ConfigState_Admin)
		{
			g_esGeneral.g_csState2 = ConfigState_Specific;

			MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%20s \"%s\"\n%20s {") : ("%20s %s\n%20s {"), "", name, "");
		}
		else
		{
			g_esGeneral.g_iIgnoreLevel2++;
		}
	}

	return SMCParse_Continue;
}

public SMCResult SMCKeyValues2(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	if (bIsValidClient(g_esGeneral.g_iParserViewer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (g_esGeneral.g_iIgnoreLevel2)
		{
			return SMCParse_Continue;
		}

		if (g_esGeneral.g_csState2 == ConfigState_Specific)
		{
			static char sKey[64], sValue[384];
			FormatEx(sKey, sizeof(sKey), ((key_quotes) ? ("\"%s\"") : ("%s")), key);
			FormatEx(sValue, sizeof(sValue), ((value_quotes) ? ("\"%s\"") : ("%s")), value);
			MT_PrintToChat(g_esGeneral.g_iParserViewer, "%30s %30s %s", "", sKey, (value[0] == '\0') ? "\"\"" : sValue);
		}
	}

	return SMCParse_Continue;
}

public SMCResult SMCEndSection2(SMCParser smc)
{
	if (bIsValidClient(g_esGeneral.g_iParserViewer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (g_esGeneral.g_iIgnoreLevel2)
		{
			g_esGeneral.g_iIgnoreLevel2--;

			return SMCParse_Continue;
		}

		if (g_esGeneral.g_csState2 == ConfigState_Specific)
		{
			if (StrEqual(g_esGeneral.g_sSection, "PluginSettings", false) || StrEqual(g_esGeneral.g_sSection, "Plugin Settings", false) || StrEqual(g_esGeneral.g_sSection, "Plugin_Settings", false) || StrEqual(g_esGeneral.g_sSection, "settings", false))
			{
				g_esGeneral.g_csState2 = ConfigState_Settings;

				MT_PrintToChat(g_esGeneral.g_iParserViewer, "%20s }", "");
			}
			else if (g_esGeneral.g_iSection > 0 && (StrContains(g_esGeneral.g_sSection, "Tank#", false) != -1 || StrContains(g_esGeneral.g_sSection, "Tank #", false) != -1 || StrContains(g_esGeneral.g_sSection, "Tank_#", false) != -1 || StrContains(g_esGeneral.g_sSection, "Tank", false) != -1 || g_esGeneral.g_sSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sSection[0]) || StrContains(g_esGeneral.g_sSection, "all", false) != -1 || StrContains(g_esGeneral.g_sSection, ",") != -1 || StrContains(g_esGeneral.g_sSection, "-") != -1))
			{
				g_esGeneral.g_csState2 = ConfigState_Type;

				MT_PrintToChat(g_esGeneral.g_iParserViewer, "%20s }", "");
			}
			else if (StrContains(g_esGeneral.g_sSection, "all", false) != -1 || StrContains(g_esGeneral.g_sSection, ",") != -1 || StrContains(g_esGeneral.g_sSection, "-") != -1)
			{
				g_esGeneral.g_csState2 = ConfigState_Type;

				MT_PrintToChat(g_esGeneral.g_iParserViewer, "%20s }", "");
			}
			else if (StrContains(g_esGeneral.g_sSection, "STEAM_", false) == 0 || strncmp("0:", g_esGeneral.g_sSection, 2) == 0 || strncmp("1:", g_esGeneral.g_sSection, 2) == 0 || (!strncmp(g_esGeneral.g_sSection, "[U:", 3) && g_esGeneral.g_sSection[strlen(g_esGeneral.g_sSection) - 1] == ']'))
			{
				g_esGeneral.g_csState2 = ConfigState_Admin;

				MT_PrintToChat(g_esGeneral.g_iParserViewer, "%20s }", "");
			}
		}
		else if (g_esGeneral.g_csState2 == ConfigState_Settings || g_esGeneral.g_csState2 == ConfigState_Type || g_esGeneral.g_csState2 == ConfigState_Admin)
		{
			g_esGeneral.g_csState2 = ConfigState_Start;

			MT_PrintToChat(g_esGeneral.g_iParserViewer, "%10s }", "");
		}
		else if (g_esGeneral.g_csState2 == ConfigState_Start)
		{
			g_esGeneral.g_csState2 = ConfigState_None;

			MT_PrintToChat(g_esGeneral.g_iParserViewer, "}");
		}
	}

	return SMCParse_Continue;
}

public void SMCParseEnd2(SMCParser smc, bool halted, bool failed)
{
	if (bIsValidClient(g_esGeneral.g_iParserViewer))
	{
		MT_PrintToChat(g_esGeneral.g_iParserViewer, "\n\n\n\n\n\n%s %t", MT_TAG2, "CompletedParsing");
		MT_PrintToChat(g_esGeneral.g_iParserViewer, "%s %t", MT_TAG2, "CheckConsole");
	}

	g_esGeneral.g_bUsedParser = false;
	g_esGeneral.g_csState2 = ConfigState_None;
	g_esGeneral.g_iIgnoreLevel2 = 0;
	g_esGeneral.g_iParserViewer = 0;
	g_esGeneral.g_iSection = 0;
	g_esGeneral.g_sSection[0] = '\0';
}

static void vPathMenu(int admin, int item)
{
	g_esGeneral.g_bUsedParser = true;
	g_esGeneral.g_iParserViewer = admin;

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

	mPathMenu.ExitBackButton = g_esPlayer[admin].g_bAdminMenu;

	if (iCount > 0)
	{
		mPathMenu.DisplayAt(admin, item, MENU_TIME_FOREVER);
	}
	else
	{
		MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoItems");

		delete mPathMenu;
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

				if (param2 == MenuCancel_ExitBack && g_esGeneral.g_tmMTMenu != null)
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

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vConfigMenu(param1, 0);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTPathMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
	}

	return 0;
}

static void vConfigMenu(int admin, int item)
{
	g_esGeneral.g_bUsedParser = true;
	g_esGeneral.g_iParserViewer = admin;

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

				vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "ErrorParsing", LANG_SERVER, g_esGeneral.g_sChosenPath, sSmcError);

				delete smcConfig;
				delete mConfigMenu;

				return;
			}

			delete smcConfig;
		}
		else
		{
			vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "FailedParsing", LANG_SERVER, g_esGeneral.g_sChosenPath);

			delete mConfigMenu;

			return;
		}

		static int iListSize;
		iListSize = (g_esGeneral.g_alSections.Length > 0) ? g_esGeneral.g_alSections.Length : 0;
		if (iListSize > 0)
		{
			static char sSection[PLATFORM_MAX_PATH];
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_alSections.GetString(iPos, sSection, sizeof(sSection));
				if (sSection[0] != '\0')
				{
					mConfigMenu.AddItem(sSection, sSection);
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
	}
}

public int iConfigMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_ExitBack)
			{
				vPathMenu(param1, 0);
			}
		}
		case MenuAction_Select:
		{
			char sInfo[PLATFORM_MAX_PATH];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			if (StrContains(sInfo, "Plugin", false) != -1 || StrContains(sInfo, "settings", false) != -1 || StrContains(sInfo, "STEAM_", false) == 0 || (!strncmp(sInfo, "[U:", 3) && sInfo[strlen(sInfo) - 1] == ']') || StrContains(sInfo, "all", false) != -1 || StrContains(sInfo, ",") != -1 || StrContains(sInfo, "-") != -1)
			{
				g_esGeneral.g_sSection = sInfo;
			}
			else
			{
				int iStartPos = 0;
				for (int iPos = 0; iPos < sizeof(sInfo); iPos++)
				{
					if (IsCharNumeric(sInfo[iPos]))
					{
						iStartPos = iPos;

						break;
					}
				}

				char sIndex[5];
				for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
				{
					IntToString(iIndex, sIndex, sizeof(sIndex));
					if (StrEqual(sInfo[iStartPos], sIndex))
					{
						g_esGeneral.g_sSection = sIndex;
						g_esGeneral.g_iSection = iIndex;

						break;
					}
				}
			}

			vParseConfig(param1);

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vConfigMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTConfigMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH], sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			if (StrEqual(sInfo, "Plugin Settings", false))
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
	g_esGeneral.g_sSection2[0] = '\0';
}

public SMCResult SMCNewSection3(SMCParser smc, const char[] name, bool opt_quotes)
{
	if (StrContains(name, "Mutant", false) == -1 && (StrEqual(name, "PluginSettings", false) || StrEqual(name, "Plugin Settings", false) || StrEqual(name, "Plugin_Settings", false) || StrEqual(name, "settings", false) || StrContains(name, "STEAM_", false) == 0
		|| strncmp("0:", name, 2) == 0 || strncmp("1:", name, 2) == 0 || (!strncmp(name, "[U:", 3) && name[strlen(name) - 1] == ']') || StrContains(name, "all", false) != -1 || StrContains(name, ",") != -1 || StrContains(name, "-") != -1))
	{
		g_esGeneral.g_alSections.PushString(name);
	}
	else if (StrContains(name, "Tank#", false) != -1 || StrContains(name, "Tank #", false) != -1 || StrContains(name, "Tank_#", false) != -1 || StrContains(name, "Tank", false) != -1 || name[0] == '#' || IsCharNumeric(name[0]))
	{
		strcopy(g_esGeneral.g_sSection2, sizeof(esGeneral::g_sSection2), name);
	}

	return SMCParse_Continue;
}

public SMCResult SMCKeyValues3(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	if (g_esGeneral.g_sSection2[0] != '\0' && (StrEqual(key, "TankName", false) || StrEqual(key, "Tank Name", false) || StrEqual(key, "Tank_Name", false) || StrEqual(key, "name", false)))
	{
		static bool bBracket, bParenthesis, bBrace;
		static char sSection[46], sValue[33], sMark[2];
		strcopy(sValue, sizeof(sValue), value);
		bBracket = StrContains(sValue, "(") != -1 || StrContains(sValue, ")") != -1;
		bParenthesis = StrContains(sValue, "[") != -1 || StrContains(sValue, "]") != -1;
		bBrace = bBracket && bParenthesis;
		sMark = (bBracket && !bParenthesis) ? "[]" : "()";
		sMark = bBrace ? "{}" : sMark;
		FormatEx(sSection, sizeof(sSection), "%s %c%s%c", sValue, sMark[0], g_esGeneral.g_sSection2, sMark[1]);
		g_esGeneral.g_alSections.PushString(sSection);
		g_esGeneral.g_sSection2[0] = '\0';
	}

	return SMCParse_Continue;
}

public SMCResult SMCEndSection3(SMCParser smc)
{
	g_esGeneral.g_sSection2[0] = '\0';

	return SMCParse_Continue;
}

public void SMCParseEnd3(SMCParser smc, bool halted, bool failed)
{
	g_esGeneral.g_sSection2[0] = '\0';
}

public Action cmdMTInfo(int client, int args)
{
	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vInfoMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vInfoMenu(int client, int item)
{
	Menu mInfoMenu = new Menu(iInfoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mInfoMenu.SetTitle("%s Information", MT_NAME);
	mInfoMenu.AddItem("Status", "Status");
	mInfoMenu.AddItem("Details", "Details");
	mInfoMenu.AddItem("Human Support", "Human Support");

	Call_StartForward(g_esGeneral.g_gfDisplayMenuForward);
	Call_PushCell(mInfoMenu);
	Call_Finish();

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

				if (param2 == MenuCancel_ExitBack && g_esGeneral.g_tmMTMenu != null)
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

			if (param2 < 3 && bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vInfoMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTInfoMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH];

			switch (param2)
			{
				case 0:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);

					return RedrawMenuItem(sMenuOption);
				}
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

					if (sMenuOption[0] != '\0')
					{
						return RedrawMenuItem(sMenuOption);
					}
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

	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && !CheckCommandAccess(client, "sm_tank", ADMFLAG_ROOT) && !CheckCommandAccess(client, "sm_mt_tank", ADMFLAG_ROOT) && !bIsDeveloper(client))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "NoCommandAccess");

		return Plugin_Handled;
	}

	vListAbilities(client);

	return Plugin_Handled;
}

static void vListAbilities(int admin)
{
	static bool bHuman;
	bHuman = bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT);
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
					case false: PrintToServer("%s %t", MT_TAG, "AbilityInstalled2", sFilename);
				}
			}
		}
		else
		{
			switch (bHuman)
			{
				case true: MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoAbilities");
				case false: PrintToServer("%s %t", MT_TAG, "NoAbilities");
			}
		}
	}
	else
	{
		switch (bHuman)
		{
			case true: MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoAbilities");
			case false: PrintToServer("%s %t", MT_TAG, "NoAbilities");
		}
	}
}

public Action cmdMTVersion(int client, int args)
{
	MT_ReplyToCommand(client, "%s %s{yellow} v%s{mint}, by{olive} %s", MT_TAG3, MT_NAME, MT_VERSION, MT_AUTHOR);

	return Plugin_Handled;
}

public Action cmdTank(int client, int args)
{
	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vTankMenu(client, 0);
		}

		return Plugin_Handled;
	}

	static char sCmd[12], sType[5];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	GetCmdArg(1, sType, sizeof(sType));
	static int iType, iAmount, iMode;
	iType = iClamp(StringToInt(sType), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);
	iAmount = GetCmdArgInt(2);
	iMode = GetCmdArgInt(3);

	if (iAmount == 0)
	{
		iAmount = 1;
	}

	if ((IsCharNumeric(sType[0]) && (iType < g_esGeneral.g_iMinType || iType > g_esGeneral.g_iMaxType)) || iAmount > 32 || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	if (IsCharNumeric(sType[0]) && (g_esTank[iType].g_iTankEnabled == 0 || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		static char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), _, iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, false, iAmount, iMode);

	return Plugin_Handled;
}

public Action cmdTank2(int client, int args)
{
	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (!CheckCommandAccess(client, "sm_tank", ADMFLAG_ROOT) && !CheckCommandAccess(client, "sm_mt_tank", ADMFLAG_ROOT) && !bIsDeveloper(client))
		{
			MT_ReplyToCommand(client, "%s %t", MT_TAG2, "NoCommandAccess");

			return Plugin_Handled;
		}
	}
	else
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vTankMenu(client, 0);
		}

		return Plugin_Handled;
	}

	static char sCmd[12], sType[5];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	GetCmdArg(1, sType, sizeof(sType));
	static int iType, iAmount, iMode;
	iType = iClamp(StringToInt(sType), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);
	iAmount = GetCmdArgInt(2);
	iMode = GetCmdArgInt(3);

	if (iAmount == 0)
	{
		iAmount = 1;
	}

	if ((IsCharNumeric(sType[0]) && (iType < g_esGeneral.g_iMinType || iType > g_esGeneral.g_iMaxType)) || iAmount > 32 || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	if (IsCharNumeric(sType[0]) && (g_esTank[iType].g_iTankEnabled == 0 || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		static char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), _, iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, false, iAmount, iMode);

	return Plugin_Handled;
}

public Action cmdMutantTank(int client, int args)
{
	if (!g_esGeneral.g_bPluginEnabled)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (g_esGeneral.g_iSpawnMode == 1 && !CheckCommandAccess(client, "sm_tank", ADMFLAG_ROOT) && !CheckCommandAccess(client, "sm_mt_tank", ADMFLAG_ROOT) && !bIsDeveloper(client))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "NoCommandAccess");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vTankMenu(client, 0);
		}

		return Plugin_Handled;
	}

	static char sCmd[12], sType[5];
	GetCmdArg(0, sCmd, sizeof(sCmd));
	GetCmdArg(1, sType, sizeof(sType));
	static int iType, iAmount, iMode;
	iType = iClamp(StringToInt(sType), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);
	iAmount = GetCmdArgInt(2);
	iMode = GetCmdArgInt(3);

	if (iAmount == 0)
	{
		iAmount = 1;
	}

	if ((IsCharNumeric(sType[0]) && (iType < g_esGeneral.g_iMinType || iType > g_esGeneral.g_iMaxType)) || iAmount > 32 || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	if (IsCharNumeric(sType[0]) && (g_esTank[iType].g_iTankEnabled == 0 || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		static char sTankName[33];
		vGetTranslatedName(sTankName, sizeof(sTankName), _, iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, false, iAmount, iMode);

	return Plugin_Handled;
}

static void vTank(int admin, char[] type, bool spawn = true, int amount = 1, int mode = 0)
{
	int iType = StringToInt(type);

	switch (iType)
	{
		case 0:
		{
			char sPhrase[32], sTankName[33];
			int iTypeCount, iTankTypes[MT_MAXTYPES + 1];
			for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
			{
				vGetTranslatedName(sPhrase, sizeof(sPhrase), _, iIndex);
				SetGlobalTransTarget(admin);
				FormatEx(sTankName, sizeof(sTankName), "%T", sPhrase, admin);
				if (g_esTank[iIndex].g_iTankEnabled == 0 || !bHasCoreAdminAccess(admin, iIndex) || g_esTank[iIndex].g_iMenuEnabled == 0 || !bIsTypeAvailable(iIndex, admin) || bAreHumansRequired(iIndex, admin) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(admin, g_esTank[iIndex].g_iOpenAreasOnly) || StrContains(sTankName, type) == -1)
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
				case 1: MT_PrintToChat(admin, "%s %t", MT_TAG3, "RequestSucceeded");
				default:
				{
					MT_PrintToChat(admin, "%s %t", MT_TAG3, "MultipleMatches");

					g_esGeneral.g_iChosenType = iTankTypes[GetRandomInt(1, iTypeCount)];
				}
			}
		}
		default:
		{
			g_esGeneral.g_iChosenType = iClamp(iType, g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType);
		}
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
						case true: vSpawnTank(admin, g_esGeneral.g_iChosenType, amount, mode);
						case false:
						{
							if ((GetClientButtons(admin) & IN_SPEED) && (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT) || CheckCommandAccess(admin, "sm_mt_tank", ADMFLAG_ROOT) || bIsDeveloper(admin)))
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

										if (g_esGeneral.g_iMasterControl == 0 && (!CheckCommandAccess(admin, "mt_admin", ADMFLAG_ROOT) && !bIsDeveloper(admin)))
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
				case false: vSpawnTank(admin, g_esGeneral.g_iChosenType, amount, mode);
			}
		}
		case false:
		{
			switch (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT) || CheckCommandAccess(admin, "sm_mt_tank", ADMFLAG_ROOT) || bIsDeveloper(admin))
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
				vSpawnTank(admin, g_esGeneral.g_iChosenType, amount, mode);
			}
		}
		case false: vSpawnTank(admin, g_esGeneral.g_iChosenType, amount, mode);
	}
}

static void vQueueTank(int admin, int type, bool mode = true)
{
	char sType[5];
	IntToString(type, sType, sizeof(sType));
	vTank(admin, sType, mode);
}

static void vSpawnTank(int admin, int type, int amount, int mode)
{
	g_esGeneral.g_bForceSpawned = true;

	char sParameter[32];

	switch (mode)
	{
		case 0: sParameter = "tank";
		case 1: sParameter = "tank auto";
	}

	switch (amount)
	{
		case 1: vCheatCommand(admin, bIsValidGame() ? "z_spawn_old" : "z_spawn", sParameter);
		default:
		{
			for (int iAmount = 0; iAmount <= amount; iAmount++)
			{
				if (iAmount < amount)
				{
					if (bIsValidClient(admin))
					{
						vCheatCommand(admin, bIsValidGame() ? "z_spawn_old" : "z_spawn", sParameter);
						g_esGeneral.g_iChosenType = type;
					}
				}
				else if (iAmount == amount)
				{
					g_esGeneral.g_iChosenType = 0;
				}
			}
		}
	}
}

static void vTankMenu(int admin, int item)
{
	Menu mTankMenu = new Menu(iTankMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mTankMenu.SetTitle("%s Menu", MT_NAME);

	static int iCount;
	iCount = 0;

	if (bIsTank(admin))
	{
		mTankMenu.AddItem("Default Tank", "Default Tank", ((g_esPlayer[admin].g_iTankType > 0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
		iCount++;
	}

	static char sMenuItem[46], sTankName[33];
	for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
	{
		if (g_esTank[iIndex].g_iTankEnabled == 0 || !bHasCoreAdminAccess(admin, iIndex) || g_esTank[iIndex].g_iMenuEnabled == 0 || !bIsTypeAvailable(iIndex, admin) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(admin, g_esTank[iIndex].g_iOpenAreasOnly))
		{
			continue;
		}

		vGetTranslatedName(sTankName, sizeof(sTankName), _, iIndex);
		SetGlobalTransTarget(admin);
		FormatEx(sMenuItem, sizeof(sMenuItem), "%T", "MTTankItem", admin, sTankName, iIndex);
		mTankMenu.AddItem(g_esTank[iIndex].g_sTankName, sMenuItem, ((g_esPlayer[admin].g_iTankType != iIndex) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
		iCount++;
	}

	mTankMenu.ExitBackButton = g_esPlayer[admin].g_bAdminMenu;

	if (iCount > 0)
	{
		mTankMenu.DisplayAt(admin, item, MENU_TIME_FOREVER);
	}
	else
	{
		MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoItems");

		delete mTankMenu;
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

				if (param2 == MenuCancel_ExitBack && g_esGeneral.g_tmMTMenu != null)
				{
					g_esGeneral.g_tmMTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
			}
		}
		case MenuAction_Select:
		{
			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));

			switch (StrEqual(sInfo, "Default Tank", false))
			{
				case true: vQueueTank(param1, g_esPlayer[param1].g_iTankType, false);
				case false:
				{
					for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
					{
						if (g_esTank[iIndex].g_iTankEnabled == 0 || !bHasCoreAdminAccess(param1, iIndex) || g_esTank[iIndex].g_iMenuEnabled == 0 || !bIsTypeAvailable(iIndex, param1) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(param1, g_esTank[iIndex].g_iOpenAreasOnly))
						{
							continue;
						}

						if (StrEqual(sInfo, g_esTank[iIndex].g_sTankName, false))
						{
							vQueueTank(param1, iIndex, false);

							break;
						}
					}
				}
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vTankMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTMenu", param1);
			panel.SetTitle(sMenuTitle);
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
			SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
		}
		else if (StrEqual(classname, "inferno") || StrEqual(classname, "pipe_bomb_projectile") || (bIsValidGame() && (StrEqual(classname, "fire_cracker_blast") || StrEqual(classname, "grenade_launcher_projectile"))))
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
			if (bIsTankAllowed(iThrower) && bHasCoreAdminAccess(iThrower) && !bIsTankIdle(iThrower) && g_esTank[g_esPlayer[iThrower].g_iTankType].g_iTankEnabled == 1)
			{
				Call_StartForward(g_esGeneral.g_gfRockBreakForward);
				Call_PushCell(iThrower);
				Call_PushCell(entity);
				Call_Finish();
			}

			StopSound(entity, SNDCHAN_BODY, SOUND_MISSILE);
		}
		else if (StrEqual(sClassname, "infected") || StrEqual(sClassname, "witch"))
		{
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
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
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
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
						iHealth = (g_esPlayer[iTarget].g_bDying) ? 0 : GetClientHealth(iTarget);
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(client))
	{
		return Plugin_Continue;
	}

	if ((buttons & IN_ATTACK) && !g_esPlayer[client].g_bAttackedAgain)
	{
		g_esPlayer[client].g_bAttackedAgain = true;
	}

	if (bIsTankAllowed(client, MT_CHECK_FAKECLIENT))
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

	if (g_esCache[client].g_iFireImmunity == 1 && bIsPlayerBurning(client))
	{
		ExtinguishEntity(client);
		SetEntPropFloat(client, Prop_Send, "m_burnPercent", 1.0);
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
	static char sModel[64];
	GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	if (StrEqual(sModel, MODEL_JETPACK) || StrEqual(sModel, MODEL_PROPANETANK) || StrEqual(sModel, MODEL_GASCAN) || (bIsValidGame() && StrEqual(sModel, MODEL_FIREWORKCRATE)))
	{
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
	}
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
				return Plugin_Handled;
			}
		}
		else if (0 < attacker <= MaxClients)
		{
			if (g_esGeneral.g_iTeamID[inflictor] == 3 && (!IsClientInGame(attacker) || GetClientUserId(attacker) != g_esPlayer[attacker].g_iUserID || GetClientTeam(attacker) != 3))
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && damage >= 0.5)
	{
		static char sClassname[32];
		static int iTank, iTank2;
		if (bIsValidEntity(inflictor))
		{
			iTank = HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity") : 0;
			iTank2 = HasEntProp(inflictor, Prop_Data, "m_hThrower") ? GetEntPropEnt(inflictor, Prop_Data, "m_hThrower") : 0;
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		}

		if (bIsTankAllowed(attacker) && bHasCoreAdminAccess(attacker) && bIsSurvivor(victim) && !bIsCoreAdminImmune(victim, attacker))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") && g_esCache[attacker].g_flClawDamage >= 0.0)
			{
				damage = flGetScaledDamage(g_esCache[attacker].g_flClawDamage);

				return (g_esCache[attacker].g_flClawDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
			}
			else if (StrEqual(sClassname, "tank_rock") && g_esCache[attacker].g_flRockDamage >= 0.0)
			{
				damage = flGetScaledDamage(g_esCache[attacker].g_flRockDamage);

				return (g_esCache[attacker].g_flRockDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
			}
		}
		else if (bIsInfected(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) || bIsCommonInfected(victim) || bIsWitch(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw"))
			{
				return Plugin_Continue;
			}

			if (bIsTankAllowed(attacker) || bIsTankAllowed(iTank) || bIsTankAllowed(iTank2))
			{
				if (StrEqual(sClassname, "tank_rock") || ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA) || (damagetype & DMG_BURN)))
				{
					return Plugin_Handled;
				}
			}

			if (bIsTankAllowed(victim) && bHasCoreAdminAccess(victim))
			{
				if (attacker == victim || ((damagetype & DMG_BULLET) && g_esCache[victim].g_iBulletImmunity == 1) || (((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA)) && g_esCache[victim].g_iExplosiveImmunity == 1)
					|| ((damagetype & DMG_BURN) && g_esCache[victim].g_iFireImmunity == 1) || (((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB)) && g_esCache[victim].g_iMeleeImmunity == 1))
				{
					return Plugin_Handled;
				}
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

static void vCacheSettings(int tank)
{
	static bool bAccess, bHuman;
	bAccess = bIsTankAllowed(tank) && bHasCoreAdminAccess(tank);
	bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	static int iType;
	iType = g_esPlayer[tank].g_iTankType;
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sHealthCharacters, sizeof(esCache::g_sHealthCharacters), g_esTank[iType].g_sHealthCharacters, g_esGeneral.g_sHealthCharacters);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sHealthCharacters, sizeof(esCache::g_sHealthCharacters), g_esPlayer[tank].g_sHealthCharacters, g_esCache[tank].g_sHealthCharacters);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sTankName, sizeof(esCache::g_sTankName), g_esPlayer[tank].g_sTankName, g_esTank[iType].g_sTankName);
	g_esCache[tank].g_flAttackInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flAttackInterval, g_esTank[iType].g_flAttackInterval, true);
	g_esCache[tank].g_flClawDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flClawDamage, g_esTank[iType].g_flClawDamage, true);
	g_esCache[tank].g_flRandomInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRandomInterval, g_esTank[iType].g_flRandomInterval);
	g_esCache[tank].g_flRockDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRockDamage, g_esTank[iType].g_flRockDamage, true);
	g_esCache[tank].g_flRunSpeed = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRunSpeed, g_esTank[iType].g_flRunSpeed, true);
	g_esCache[tank].g_flThrowInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flThrowInterval, g_esTank[iType].g_flThrowInterval, true);
	g_esCache[tank].g_flTransformDelay = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flTransformDelay, g_esTank[iType].g_flTransformDelay);
	g_esCache[tank].g_flTransformDuration = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flTransformDuration, g_esTank[iType].g_flTransformDuration);
	g_esCache[tank].g_iAnnounceArrival = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAnnounceArrival, g_esGeneral.g_iAnnounceArrival);
	g_esCache[tank].g_iAnnounceArrival = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAnnounceArrival, g_esCache[tank].g_iAnnounceArrival);
	g_esCache[tank].g_iAnnounceDeath = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAnnounceDeath, g_esGeneral.g_iAnnounceDeath);
	g_esCache[tank].g_iAnnounceDeath = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAnnounceDeath, g_esCache[tank].g_iAnnounceDeath);
	g_esCache[tank].g_iBodyEffects = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBodyEffects, g_esTank[iType].g_iBodyEffects);
	g_esCache[tank].g_iBossStages = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossStages, g_esTank[iType].g_iBossStages);
	g_esCache[tank].g_iBulletImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBulletImmunity, g_esTank[iType].g_iBulletImmunity);
	g_esCache[tank].g_iDeathRevert = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathRevert, g_esGeneral.g_iDeathRevert);
	g_esCache[tank].g_iDeathRevert = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathRevert, g_esCache[tank].g_iDeathRevert);
	g_esCache[tank].g_iDetectPlugins = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDetectPlugins, g_esGeneral.g_iDetectPlugins);
	g_esCache[tank].g_iDetectPlugins = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDetectPlugins, g_esCache[tank].g_iDetectPlugins);
	g_esCache[tank].g_iDisplayHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDisplayHealth, g_esGeneral.g_iDisplayHealth);
	g_esCache[tank].g_iDisplayHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDisplayHealth, g_esCache[tank].g_iDisplayHealth);
	g_esCache[tank].g_iDisplayHealthType = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDisplayHealthType, g_esGeneral.g_iDisplayHealthType);
	g_esCache[tank].g_iDisplayHealthType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDisplayHealthType, g_esCache[tank].g_iDisplayHealthType);
	g_esCache[tank].g_iExplosiveImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iExplosiveImmunity, g_esTank[iType].g_iExplosiveImmunity);
	g_esCache[tank].g_iExtraHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iExtraHealth, g_esTank[iType].g_iExtraHealth);
	g_esCache[tank].g_iFireImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFireImmunity, g_esTank[iType].g_iFireImmunity);
	g_esCache[tank].g_iGlowEnabled = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowEnabled, g_esTank[iType].g_iGlowEnabled);
	g_esCache[tank].g_iGlowFlashing = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowFlashing, g_esTank[iType].g_iGlowFlashing);
	g_esCache[tank].g_iGlowMaxRange = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowMaxRange, g_esTank[iType].g_iGlowMaxRange);
	g_esCache[tank].g_iGlowMinRange = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowMinRange, g_esTank[iType].g_iGlowMinRange);
	g_esCache[tank].g_iGlowType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowType, g_esTank[iType].g_iGlowType);
	g_esCache[tank].g_iMeleeImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMeleeImmunity, g_esTank[iType].g_iMeleeImmunity);
	g_esCache[tank].g_iMinimumHumans = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMinimumHumans, g_esGeneral.g_iMinimumHumans);
	g_esCache[tank].g_iMinimumHumans = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMinimumHumans, g_esCache[tank].g_iMinimumHumans);
	g_esCache[tank].g_iMultiHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMultiHealth, g_esGeneral.g_iMultiHealth);
	g_esCache[tank].g_iMultiHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMultiHealth, g_esCache[tank].g_iMultiHealth);
	g_esCache[tank].g_iPropsAttached = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iPropsAttached, g_esTank[iType].g_iPropsAttached);
	g_esCache[tank].g_iRandomTank = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRandomTank, g_esTank[iType].g_iRandomTank);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRequiresHumans, g_esGeneral.g_iRequiresHumans);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esCache[tank].g_iRequiresHumans);
	g_esCache[tank].g_iRockEffects = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockEffects, g_esTank[iType].g_iRockEffects);
	g_esCache[tank].g_iRockModel = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockModel, g_esTank[iType].g_iRockModel);
	g_esCache[tank].g_iTankNote = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTankNote, g_esTank[iType].g_iTankNote);

	for (int iPos = 0; iPos < sizeof(esCache::g_iTransformType); iPos++)
	{
		g_esCache[tank].g_iTransformType[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTransformType[iPos], g_esTank[iType].g_iTransformType[iPos]);

		if (iPos < sizeof(esCache::g_flPropsChance))
		{
			g_esCache[tank].g_flPropsChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flPropsChance[iPos], g_esTank[iType].g_flPropsChance[iPos]);
		}

		if (iPos < sizeof(esCache::g_iSkinColor))
		{
			g_esCache[tank].g_iSkinColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSkinColor[iPos], g_esTank[iType].g_iSkinColor[iPos], true);
			g_esCache[tank].g_iBossHealth[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossHealth[iPos], g_esTank[iType].g_iBossHealth[iPos]);
			g_esCache[tank].g_iBossType[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossType[iPos], g_esTank[iType].g_iBossType[iPos]);
			g_esCache[tank].g_iLightColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iLightColor[iPos], g_esTank[iType].g_iLightColor[iPos], true);
			g_esCache[tank].g_iOzTankColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iOzTankColor[iPos], g_esTank[iType].g_iOzTankColor[iPos], true);
			g_esCache[tank].g_iFlameColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFlameColor[iPos], g_esTank[iType].g_iFlameColor[iPos], true);
			g_esCache[tank].g_iRockColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockColor[iPos], g_esTank[iType].g_iRockColor[iPos], true);
			g_esCache[tank].g_iTireColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTireColor[iPos], g_esTank[iType].g_iTireColor[iPos], true);
			g_esCache[tank].g_iPropTankColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iPropTankColor[iPos], g_esTank[iType].g_iPropTankColor[iPos], true);
			g_esCache[tank].g_iFlashlightColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFlashlightColor[iPos], g_esTank[iType].g_iFlashlightColor[iPos], true);
			g_esCache[tank].g_iCrownColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iCrownColor[iPos], g_esTank[iType].g_iCrownColor[iPos], true);
		}

		if (iPos < sizeof(esCache::g_iGlowColor))
		{
			g_esCache[tank].g_iGlowColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowColor[iPos], g_esTank[iType].g_iGlowColor[iPos], true);
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

static void vCopyDamage(int oldSurvivor, int newSurvivor)
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		g_esPlayer[newSurvivor].g_iTankDamage[iTank] = g_esPlayer[oldSurvivor].g_iTankDamage[iTank];
	}
}

static void vCopyStats(int tank, int newtank)
{
	g_esPlayer[newtank].g_bBlood = g_esPlayer[tank].g_bBlood;
	g_esPlayer[newtank].g_bBlur = g_esPlayer[tank].g_bBlur;
	g_esPlayer[newtank].g_bBoss = g_esPlayer[tank].g_bBoss;
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
		Call_PushArrayEx(g_esGeneral.g_alPlugins, MT_MAX_ABILITIES + 1, SM_PARAM_COPYBACK);
		Call_Finish();
	}

	Call_StartForward(g_esGeneral.g_gfAbilityCheckForward);

	vClearAbilityList();
	for (int iPos = 0; iPos < sizeof(esGeneral::g_alAbilitySections); iPos++)
	{
		g_esGeneral.g_alAbilitySections[iPos] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
		Call_PushArrayEx(g_esGeneral.g_alAbilitySections[iPos], MT_MAX_ABILITIES + 1, SM_PARAM_COPYBACK);
	}

	Call_Finish();

	for (int iPos = 0; iPos < MT_MAX_ABILITIES; iPos++)
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

			vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "ErrorParsing", LANG_SERVER, savepath, sSmcError);
		}

		delete smcLoader;
	}
	else
	{
		vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "FailedParsing", LANG_SERVER, savepath);
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
		g_esGeneral.g_iAnnounceArrival = 31;
		g_esGeneral.g_iAnnounceDeath = 1;
		g_esGeneral.g_iDeathRevert = 1;
		g_esGeneral.g_iDetectPlugins = 1;
		g_esGeneral.g_iFinalesOnly = 0;
		g_esGeneral.g_flIdleCheck = 10.0;
		g_esGeneral.g_iIdleCheckMode = 2;
		g_esGeneral.g_iLogMessages = 0;
		g_esGeneral.g_iMinType = 1;
		g_esGeneral.g_iMaxType = MT_MAXTYPES;
		g_esGeneral.g_iRequiresHumans = 0;
		g_esGeneral.g_iScaleDamage = 0;
		g_esGeneral.g_iBaseHealth = 0;
		g_esGeneral.g_iDisplayHealth = 11;
		g_esGeneral.g_iDisplayHealthType = 1;
		g_esGeneral.g_sHealthCharacters = "|,-";
		g_esGeneral.g_iMinimumHumans = 2;
		g_esGeneral.g_iMultiHealth = 0;
		g_esGeneral.g_iAllowDeveloper = 1;
		g_esGeneral.g_iAccessFlags = 0;
		g_esGeneral.g_iImmunityFlags = 0;
		g_esGeneral.g_iHumanCooldown = 600;
		g_esGeneral.g_iMasterControl = 0;
		g_esGeneral.g_iSpawnMode = 1;
		g_esGeneral.g_flExtrasDelay = 3.0;
		g_esGeneral.g_iRegularAmount = 0;
		g_esGeneral.g_flRegularDelay = 10.0;
		g_esGeneral.g_flRegularInterval = 300.0;
		g_esGeneral.g_iRegularLimit = 999999;
		g_esGeneral.g_iRegularMinType = 0;
		g_esGeneral.g_iRegularMaxType = 0;
		g_esGeneral.g_iRegularMode = 0;
		g_esGeneral.g_iRegularWave = 0;
		g_esGeneral.g_iFinaleAmount = 0;
		g_esGeneral.g_iAggressiveTanks = 0;
		g_esGeneral.g_iStasisMode = 0;
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

			if (iPos < sizeof(esGeneral::g_flDifficultyDamage))
			{
				g_esGeneral.g_flDifficultyDamage[iPos] = 0.0;
			}
		}

		for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
		{
			FormatEx(g_esTank[iIndex].g_sTankName, sizeof(esTank::g_sTankName), "Tank #%i", iIndex);
			g_esTank[iIndex].g_iTankEnabled = 0;
			g_esTank[iIndex].g_flTankChance = 100.0;
			g_esTank[iIndex].g_iTankNote = 0;
			g_esTank[iIndex].g_iSpawnEnabled = 1;
			g_esTank[iIndex].g_iMenuEnabled = 1;
			g_esTank[iIndex].g_iAnnounceArrival = 0;
			g_esTank[iIndex].g_iAnnounceDeath = 0;
			g_esTank[iIndex].g_iDeathRevert = 0;
			g_esTank[iIndex].g_iDetectPlugins = 0;
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
			g_esTank[iIndex].g_iOpenAreasOnly = 0;
			g_esTank[iIndex].g_iRequiresHumans = 0;
			g_esTank[iIndex].g_iAccessFlags = 0;
			g_esTank[iIndex].g_iImmunityFlags = 0;
			g_esTank[iIndex].g_iChosenTypeLimit = 32;
			g_esTank[iIndex].g_iFinaleTank = 0;
			g_esTank[iIndex].g_iBossStages = 4;
			g_esTank[iIndex].g_iRandomTank = 1;
			g_esTank[iIndex].g_flRandomInterval = 5.0;
			g_esTank[iIndex].g_flTransformDelay = 10.0;
			g_esTank[iIndex].g_flTransformDuration = 10.0;
			g_esTank[iIndex].g_iSpawnMode = 0;
			g_esTank[iIndex].g_iPropsAttached = bIsValidGame() ? 510 : 462;
			g_esTank[iIndex].g_iBodyEffects = 0;
			g_esTank[iIndex].g_iRockEffects = 0;
			g_esTank[iIndex].g_iRockModel = 2;
			g_esTank[iIndex].g_flAttackInterval = -1.0;
			g_esTank[iIndex].g_flClawDamage = -1.0;
			g_esTank[iIndex].g_flRockDamage = -1.0;
			g_esTank[iIndex].g_flRunSpeed = -1.0;
			g_esTank[iIndex].g_flThrowInterval = -1.0;
			g_esTank[iIndex].g_iBulletImmunity = 0;
			g_esTank[iIndex].g_iExplosiveImmunity = 0;
			g_esTank[iIndex].g_iFireImmunity = 0;
			g_esTank[iIndex].g_iMeleeImmunity = 0;

			for (int iPos = 0; iPos < sizeof(esTank::g_iTransformType); iPos++)
			{
				g_esTank[iIndex].g_iTransformType[iPos] = iPos + 1;

				if (iPos < sizeof(esTank::g_flPropsChance))
				{
					g_esTank[iIndex].g_flPropsChance[iPos] = 33.3;
				}

				if (iPos < sizeof(esTank::g_iSkinColor))
				{
					g_esTank[iIndex].g_iSkinColor[iPos] = -1;
					g_esTank[iIndex].g_iBossHealth[iPos] = 5000 / (iPos + 1);
					g_esTank[iIndex].g_iBossType[iPos] = iPos + 2;
					g_esTank[iIndex].g_iLightColor[iPos] = -1;
					g_esTank[iIndex].g_iOzTankColor[iPos] = -1;
					g_esTank[iIndex].g_iFlameColor[iPos] = -1;
					g_esTank[iIndex].g_iRockColor[iPos] = -1;
					g_esTank[iIndex].g_iTireColor[iPos] = -1;
					g_esTank[iIndex].g_iPropTankColor[iPos] = -1;
					g_esTank[iIndex].g_iFlashlightColor[iPos] = -1;
					g_esTank[iIndex].g_iCrownColor[iPos] = -1;
				}

				if (iPos < sizeof(esTank::g_iGlowColor))
				{
					g_esTank[iIndex].g_iGlowColor[iPos] = -1;
				}
			}
		}
	}

	if (g_esGeneral.g_iConfigMode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
			{
				g_esPlayer[iPlayer].g_sTankName[0] = '\0';
				g_esPlayer[iPlayer].g_iTankNote = 0;
				g_esPlayer[iPlayer].g_iAnnounceArrival = 0;
				g_esPlayer[iPlayer].g_iAnnounceDeath = 0;
				g_esPlayer[iPlayer].g_iDeathRevert = 0;
				g_esPlayer[iPlayer].g_iDetectPlugins = 0;
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
				g_esPlayer[iPlayer].g_iRequiresHumans = 0;
				g_esPlayer[iPlayer].g_iFavoriteType = 0;
				g_esPlayer[iPlayer].g_iAccessFlags = 0;
				g_esPlayer[iPlayer].g_iImmunityFlags = 0;
				g_esPlayer[iPlayer].g_iBossStages = 0;
				g_esPlayer[iPlayer].g_iRandomTank = 0;
				g_esPlayer[iPlayer].g_flRandomInterval = 0.0;
				g_esPlayer[iPlayer].g_flTransformDelay = 0.0;
				g_esPlayer[iPlayer].g_flTransformDuration = 0.0;
				g_esPlayer[iPlayer].g_iPropsAttached = 0;
				g_esPlayer[iPlayer].g_iBodyEffects = 0;
				g_esPlayer[iPlayer].g_iRockEffects = 0;
				g_esPlayer[iPlayer].g_iRockModel = 0;
				g_esPlayer[iPlayer].g_flAttackInterval = -1.0;
				g_esPlayer[iPlayer].g_flClawDamage = -1.0;
				g_esPlayer[iPlayer].g_flRockDamage = -1.0;
				g_esPlayer[iPlayer].g_flRunSpeed = -1.0;
				g_esPlayer[iPlayer].g_flThrowInterval = -1.0;
				g_esPlayer[iPlayer].g_iBulletImmunity = 0;
				g_esPlayer[iPlayer].g_iExplosiveImmunity = 0;
				g_esPlayer[iPlayer].g_iFireImmunity = 0;
				g_esPlayer[iPlayer].g_iMeleeImmunity = 0;

				for (int iPos = 0; iPos < sizeof(esPlayer::g_iTransformType); iPos++)
				{
					g_esPlayer[iPlayer].g_iTransformType[iPos] = 0;

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
		if (StrEqual(name, "MutantTanks", false) || StrEqual(name, MT_NAME, false) || StrEqual(name, "Mutant_Tanks", false) || StrEqual(name, "MT", false))
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
		if (StrEqual(name, "PluginSettings", false) || StrEqual(name, "Plugin Settings", false) || StrEqual(name, "Plugin_Settings", false) || StrEqual(name, "settings", false))
		{
			g_esGeneral.g_csState = ConfigState_Settings;

			strcopy(g_esGeneral.g_sCurrentSection, sizeof(esGeneral::g_sCurrentSection), name);
		}
		else if (StrContains(name, "Tank#", false) == 0 || StrContains(name, "Tank #", false) == 0 || StrContains(name, "Tank_#", false) == 0 || StrContains(name, "Tank", false) == 0 || name[0] == '#' || IsCharNumeric(name[0]) || StrContains(name, "all", false) != -1 || StrContains(name, ",") != -1 || StrContains(name, "-") != -1)
		{
			static char sTankName[7][33];
			for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
			{
				FormatEx(sTankName[0], sizeof(sTankName[]), "Tank#%i", iIndex);
				FormatEx(sTankName[1], sizeof(sTankName[]), "Tank #%i", iIndex);
				FormatEx(sTankName[2], sizeof(sTankName[]), "Tank_#%i", iIndex);
				FormatEx(sTankName[3], sizeof(sTankName[]), "Tank%i", iIndex);
				FormatEx(sTankName[4], sizeof(sTankName[]), "Tank %i", iIndex);
				FormatEx(sTankName[5], sizeof(sTankName[]), "Tank_%i", iIndex);
				FormatEx(sTankName[6], sizeof(sTankName[]), "#%i", iIndex);

				static int iRealType;
				iRealType = iFindSectionType(name, iIndex);

				static char sIndex[5], sRealType[5];
				IntToString(iIndex, sIndex, sizeof(sIndex));
				IntToString(iRealType, sRealType, sizeof(sRealType));

				for (int iType = 0; iType < sizeof(sTankName); iType++)
				{
					if (StrEqual(name, sTankName[iType], false) || StrEqual(name, sIndex) || StrEqual(sRealType, sIndex) || StrContains(name, "all", false) != -1)
					{
						g_esGeneral.g_csState = ConfigState_Type;

						strcopy(g_esGeneral.g_sCurrentSection, sizeof(esGeneral::g_sCurrentSection), name);
					}
				}
			}
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
		if (g_esGeneral.g_iConfigMode < 3 && (StrEqual(g_esGeneral.g_sCurrentSection, "PluginSettings", false) || StrEqual(g_esGeneral.g_sCurrentSection, "Plugin Settings", false) || StrEqual(g_esGeneral.g_sCurrentSection, "Plugin_Settings", false) || StrEqual(g_esGeneral.g_sCurrentSection, "settings", false)))
		{
			g_esGeneral.g_iPluginEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "PluginEnabled", "Plugin Enabled", "Plugin_Enabled", "enabled", g_esGeneral.g_iPluginEnabled, value, 0, 1);
			g_esGeneral.g_iAnnounceArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esGeneral.g_iAnnounceArrival, value, 0, 31);
			g_esGeneral.g_iAnnounceDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esGeneral.g_iAnnounceDeath, value, 0, 2);
			g_esGeneral.g_iDeathRevert = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esGeneral.g_iDeathRevert, value, 0, 1);
			g_esGeneral.g_iDetectPlugins = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "DetectPlugins", "Detect Plugins", "Detect_Plugins", "detect", g_esGeneral.g_iDetectPlugins, value, 0, 1);
			g_esGeneral.g_iFinalesOnly = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "FinalesOnly", "Finales Only", "Finales_Only", "finale", g_esGeneral.g_iFinalesOnly, value, 0, 4);
			g_esGeneral.g_flIdleCheck = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "IdleCheck", "Idle Check", "Idle_Check", "idle", g_esGeneral.g_flIdleCheck, value, 0.0, 999999.0);
			g_esGeneral.g_iIdleCheckMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "IdleCheckMode", "Idle Check Mode", "Idle_Check_Mode", "idlemode", g_esGeneral.g_iIdleCheckMode, value, 0, 2);
			g_esGeneral.g_iLogMessages = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "LogMessages", "Log Messages", "Log_Messages", "log", g_esGeneral.g_iLogMessages, value, 0, 31);
			g_esGeneral.g_iRequiresHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGeneral.g_iRequiresHumans, value, 0, 32);
			g_esGeneral.g_iAggressiveTanks = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Competitive", "Competitive", "Competitive", "comp", key, "AggressiveTanks", "Aggressive Tanks", "Aggressive_Tanks", "aggressive", g_esGeneral.g_iAggressiveTanks, value, 0, 1);
			g_esGeneral.g_iStasisMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Competitive", "Competitive", "Competitive", "comp", key, "StasisMode", "Stasis Mode", "Stasis_Mode", "stasis", g_esGeneral.g_iStasisMode, value, 0, 1);
			g_esGeneral.g_iScaleDamage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Difficulty", "Difficulty", "Difficulty", "diff", key, "ScaleDamage", "Scale Damage", "Scale_Damage", "scaledmg", g_esGeneral.g_iScaleDamage, value, 0, 1);
			g_esGeneral.g_iBaseHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "BaseHealth", "Base Health", "Base_Health", "health", g_esGeneral.g_iBaseHealth, value, 0, MT_MAXHEALTH);
			g_esGeneral.g_iDisplayHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esGeneral.g_iDisplayHealth, value, 0, 11);
			g_esGeneral.g_iDisplayHealthType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esGeneral.g_iDisplayHealthType, value, 0, 2);
			g_esGeneral.g_iMinimumHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esGeneral.g_iMinimumHumans, value, 1, 32);
			g_esGeneral.g_iMultiHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esGeneral.g_iMultiHealth, value, 0, 3);
			g_esGeneral.g_iHumanCooldown = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "HumanSupport", "Human Support", "Human_Support", "human", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "cooldown", g_esGeneral.g_iHumanCooldown, value, 0, 999999);
			g_esGeneral.g_iMasterControl = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "HumanSupport", "Human Support", "Human_Support", "human", key, "MasterControl", "Master Control", "Master_Control", "master", g_esGeneral.g_iMasterControl, value, 0, 1);
			g_esGeneral.g_iSpawnMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "HumanSupport", "Human Support", "Human_Support", "human", key, "SpawnMode", "Spawn Mode", "Spawn_Mode", "spawnmode", g_esGeneral.g_iSpawnMode, value, 0, 1);
			g_esGeneral.g_flExtrasDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "ExtrasDelay", "Extras Delay", "Extras_Delay", "exdelay", g_esGeneral.g_flExtrasDelay, value, 0.1, 999999.0);
			g_esGeneral.g_iRegularAmount = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularAmount", "Regular Amount", "Regular_Amount", "regamount", g_esGeneral.g_iRegularAmount, value, 0, 32);
			g_esGeneral.g_flRegularDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularDelay", "Regular Delay", "Regular_Delay", "regdelay", g_esGeneral.g_flRegularDelay, value, 0.1, 999999.0);
			g_esGeneral.g_flRegularInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularInterval", "Regular Interval", "Regular_Interval", "reginterval", g_esGeneral.g_flRegularInterval, value, 0.1, 999999.0);
			g_esGeneral.g_iRegularLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularLimit", "Regular Limit", "Regular_Limit", "reglimit", g_esGeneral.g_iRegularLimit, value, 0, 999999);
			g_esGeneral.g_iRegularMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularMode", "Regular Mode", "Regular_Mode", "regmode", g_esGeneral.g_iRegularMode, value, 0, 1);
			g_esGeneral.g_iRegularWave = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularWave", "Regular Wave", "Regular_Wave", "regwave", g_esGeneral.g_iRegularWave, value, 0, 1);
			g_esGeneral.g_iFinaleAmount = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "FinaleAmount", "Finale Amount", "Finale_Amount", "finamount", g_esGeneral.g_iFinaleAmount, value, 0, 32);

			if (StrEqual(g_esGeneral.g_sCurrentSubSection, "General", false))
			{
				if (StrEqual(key, "TypeRange", false) || StrEqual(key, "Type Range", false) || StrEqual(key, "Type_Range", false) || StrEqual(key, "types", false))
				{
					static char sValue[10];
					strcopy(sValue, sizeof(sValue), value);
					ReplaceString(sValue, sizeof(sValue), " ", "");

					static char sRange[2][5];
					ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

					g_esGeneral.g_iMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 1, MT_MAXTYPES) : g_esGeneral.g_iMinType;
					g_esGeneral.g_iMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 1, MT_MAXTYPES) : g_esGeneral.g_iMaxType;
				}
			}
			else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Difficulty", false) || StrEqual(g_esGeneral.g_sCurrentSubSection, "diff", false))
			{
				if (StrEqual(key, "DifficultyDamage", false) || StrEqual(key, "Difficulty Damage", false) || StrEqual(key, "Difficulty_Damage", false) || StrEqual(key, "diffdmg", false))
				{
					static char sValue[36];
					strcopy(sValue, sizeof(sValue), value);
					ReplaceString(sValue, sizeof(sValue), " ", "");

					static char sSet[4][9];
					ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

					for (int iPos = 0; iPos < sizeof(esGeneral::g_flDifficultyDamage); iPos++)
					{
						g_esGeneral.g_flDifficultyDamage[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esGeneral.g_flDifficultyDamage[iPos];
					}
				}
			}
			else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Health", false))
			{
				if (StrEqual(key, "HealthCharacters", false) || StrEqual(key, "Health Characters", false) || StrEqual(key, "Health_Characters", false) || StrEqual(key, "hpchars", false))
				{
					strcopy(g_esGeneral.g_sHealthCharacters, sizeof(esGeneral::g_sHealthCharacters), value);
				}
			}
			else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Administration", false) || StrEqual(g_esGeneral.g_sCurrentSubSection, "admin", false))
			{
				g_esGeneral.g_iAllowDeveloper = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Administration", "Administration", "Administration", "admin", key, "AllowDeveloper", "Allow Developer", "Allow_Developer", "developer", g_esGeneral.g_iAllowDeveloper, value, 0, 1);

				if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
				{
					g_esGeneral.g_iAccessFlags = ReadFlagString(value);
				}
				else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
				{
					g_esGeneral.g_iImmunityFlags = ReadFlagString(value);
				}
			}
			else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Waves", false))
			{
				if (StrEqual(key, "RegularType", false) || StrEqual(key, "Regular Type", false) || StrEqual(key, "Regular_Type", false) || StrEqual(key, "regtype", false))
				{
					static char sValue[10];
					strcopy(sValue, sizeof(sValue), value);
					ReplaceString(sValue, sizeof(sValue), " ", "");

					static char sRange[2][5];
					ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

					g_esGeneral.g_iRegularMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, g_esGeneral.g_iMaxType) : g_esGeneral.g_iRegularMinType;
					g_esGeneral.g_iRegularMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, g_esGeneral.g_iMaxType) : g_esGeneral.g_iRegularMaxType;
				}
				else if (StrEqual(key, "FinaleTypes", false) || StrEqual(key, "Finale Types", false) || StrEqual(key, "Finale_Types", false) || StrEqual(key, "fintypes", false))
				{
					static char sValue[100];
					strcopy(sValue, sizeof(sValue), value);
					ReplaceString(sValue, sizeof(sValue), " ", "");

					static char sRange[10][10];
					ExplodeString(sValue, ",", sRange, sizeof(sRange), sizeof(sRange[]));

					for (int iPos = 0; iPos < sizeof(sRange); iPos++)
					{
						if (sRange[iPos][0] == '\0')
						{
							continue;
						}

						static char sSet[2][5];
						ExplodeString(sRange[iPos], "-", sSet, sizeof(sSet), sizeof(sSet[]));

						g_esGeneral.g_iFinaleMinTypes[iPos] = (sSet[0][0] != '\0') ? iClamp(StringToInt(sSet[0]), 0, g_esGeneral.g_iMaxType) : g_esGeneral.g_iFinaleMinTypes[iPos];
						g_esGeneral.g_iFinaleMaxTypes[iPos] = (sSet[1][0] != '\0') ? iClamp(StringToInt(sSet[1]), 0, g_esGeneral.g_iMaxType) : g_esGeneral.g_iFinaleMaxTypes[iPos];
					}
				}
				else if (StrEqual(key, "FinaleWaves", false) || StrEqual(key, "Finale Waves", false) || StrEqual(key, "Finale_Waves", false) || StrEqual(key, "finwaves", false))
				{
					static char sValue[30];
					strcopy(sValue, sizeof(sValue), value);
					ReplaceString(sValue, sizeof(sValue), " ", "");

					static char sSet[10][3];
					ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

					for (int iPos = 0; iPos < sizeof(esGeneral::g_iFinaleWave); iPos++)
					{
						g_esGeneral.g_iFinaleWave[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 32) : g_esGeneral.g_iFinaleWave[iPos];
					}
				}
			}

			if (g_esGeneral.g_iConfigMode == 1)
			{
				g_esGeneral.g_iGameModeTypes = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "GameModes", "Game Modes", "Game_Modes", "modes", key, "GameModeTypes", "Game Mode Types", "Game_Mode_Types", "types", g_esGeneral.g_iGameModeTypes, value, 0, 15);
				g_esGeneral.g_iConfigEnable = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Custom", "Custom", "Custom", "Custom", key, "EnableCustomConfigs", "Enable Custom Configs", "Enable_Custom_Configs", "enabled", g_esGeneral.g_iConfigEnable, value, 0, 1);
				g_esGeneral.g_iConfigCreate = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Custom", "Custom", "Custom", "Custom", key, "CreateConfigTypes", "Create Config Types", "Create_Config_Types", "create", g_esGeneral.g_iConfigCreate, value, 0, 63);
				g_esGeneral.g_iConfigExecute = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Custom", "Custom", "Custom", "Custom", key, "ExecuteConfigTypes", "Execute Config Types", "Execute_Config_Types", "execute", g_esGeneral.g_iConfigExecute, value, 0, 63);

				if (StrEqual(g_esGeneral.g_sCurrentSubSection, "GameModes", false) || StrEqual(g_esGeneral.g_sCurrentSubSection, "Game Modes", false) || StrEqual(g_esGeneral.g_sCurrentSubSection, "Game_Modes", false) || StrEqual(g_esGeneral.g_sCurrentSubSection, "modes", false))
				{
					if (StrEqual(key, "EnabledGameModes", false) || StrEqual(key, "Enabled Game Modes", false) || StrEqual(key, "Enabled_Game_Modes", false) || StrEqual(key, "enabled", false))
					{
						strcopy(g_esGeneral.g_sEnabledGameModes, sizeof(esGeneral::g_sEnabledGameModes), value);
					}
					else if (StrEqual(key, "DisabledGameModes", false) || StrEqual(key, "Disabled Game Modes", false) || StrEqual(key, "Disabled_Game_Modes", false) || StrEqual(key, "disabled", false))
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
		else if (g_esGeneral.g_iConfigMode < 3 && (StrContains(g_esGeneral.g_sCurrentSection, "Tank#", false) == 0 || StrContains(g_esGeneral.g_sCurrentSection, "Tank #", false) == 0 || StrContains(g_esGeneral.g_sCurrentSection, "Tank_#", false) == 0 || StrContains(g_esGeneral.g_sCurrentSection, "Tank", false) == 0 || g_esGeneral.g_sCurrentSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSection, "-") != -1))
		{
			static char sTankName[7][33];
			for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
			{
				FormatEx(sTankName[0], sizeof(sTankName[]), "Tank#%i", iIndex);
				FormatEx(sTankName[1], sizeof(sTankName[]), "Tank #%i", iIndex);
				FormatEx(sTankName[2], sizeof(sTankName[]), "Tank_#%i", iIndex);
				FormatEx(sTankName[3], sizeof(sTankName[]), "Tank%i", iIndex);
				FormatEx(sTankName[4], sizeof(sTankName[]), "Tank %i", iIndex);
				FormatEx(sTankName[5], sizeof(sTankName[]), "Tank_%i", iIndex);
				FormatEx(sTankName[6], sizeof(sTankName[]), "#%i", iIndex);

				static int iRealType;
				iRealType = iFindSectionType(g_esGeneral.g_sCurrentSection, iIndex);

				static char sIndex[5], sRealType[5];
				IntToString(iIndex, sIndex, sizeof(sIndex));
				IntToString(iRealType, sRealType, sizeof(sRealType));

				for (int iType = 0; iType < sizeof(sTankName); iType++)
				{
					if (StrEqual(g_esGeneral.g_sCurrentSection, sTankName[iType], false) || StrEqual(g_esGeneral.g_sCurrentSection, sIndex) || StrEqual(sRealType, sIndex) || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1)
					{
						g_esTank[iIndex].g_iTankEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "TankEnabled", "Tank Enabled", "Tank_Enabled", "enabled", g_esTank[iIndex].g_iTankEnabled, value, 0, 1);
						g_esTank[iIndex].g_flTankChance = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "TankChance", "Tank Chance", "Tank_Chance", "chance", g_esTank[iIndex].g_flTankChance, value, 0.0, 100.0);
						g_esTank[iIndex].g_iTankNote = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "TankNote", "Tank Note", "Tank_Note", "note", g_esTank[iIndex].g_iTankNote, value, 0, 1);
						g_esTank[iIndex].g_iSpawnEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "SpawnEnabled", "Spawn Enabled", "Spawn_Enabled", "spawn", g_esTank[iIndex].g_iSpawnEnabled, value, 0, 1);
						g_esTank[iIndex].g_iMenuEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "MenuEnabled", "Menu Enabled", "Menu_Enabled", "menu", g_esTank[iIndex].g_iMenuEnabled, value, 0, 1);
						g_esTank[iIndex].g_iAnnounceArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esTank[iIndex].g_iAnnounceArrival, value, 0, 31);
						g_esTank[iIndex].g_iAnnounceDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esTank[iIndex].g_iAnnounceDeath, value, 0, 2);
						g_esTank[iIndex].g_iDeathRevert = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esTank[iIndex].g_iDeathRevert, value, 0, 1);
						g_esTank[iIndex].g_iDetectPlugins = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "DetectPlugins", "Detect Plugins", "Detect_Plugins", "detect", g_esTank[iIndex].g_iDetectPlugins, value, 0, 1);
						g_esTank[iIndex].g_iRequiresHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esTank[iIndex].g_iRequiresHumans, value, 0, 32);
						g_esTank[iIndex].g_iGlowEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Glow", "Glow", "Glow", "Glow", key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "enabled", g_esTank[iIndex].g_iGlowEnabled, value, 0, 1);
						g_esTank[iIndex].g_iGlowFlashing = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Glow", "Glow", "Glow", "Glow", key, "GlowFlashing", "Glow Flashing", "Glow_Flashing", "flashing", g_esTank[iIndex].g_iGlowFlashing, value, 0, 1);
						g_esTank[iIndex].g_iGlowType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Glow", "Glow", "Glow", "Glow", key, "GlowType", "Glow Type", "Glow_Type", "type", g_esTank[iIndex].g_iGlowType, value, 0, 1);
						g_esTank[iIndex].g_iDisplayHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esTank[iIndex].g_iDisplayHealth, value, 0, 11);
						g_esTank[iIndex].g_iDisplayHealthType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esTank[iIndex].g_iDisplayHealthType, value, 0, 2);
						g_esTank[iIndex].g_iExtraHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "ExtraHealth", "Extra Health", "Extra_Health", "health", g_esTank[iIndex].g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
						g_esTank[iIndex].g_iMinimumHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esTank[iIndex].g_iMinimumHumans, value, 1, 32);
						g_esTank[iIndex].g_iMultiHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esTank[iIndex].g_iMultiHealth, value, 0, 3);
						g_esTank[iIndex].g_iHumanSupport = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "HumanSupport", "Human Support", "Human_Support", "human", key, "HumanSupport", "Human Support", "Human_Support", "human", g_esTank[iIndex].g_iHumanSupport, value, 0, 2);
						g_esTank[iIndex].g_iChosenTypeLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TypeLimit", "Type Limit", "Type_Limit", "limit", g_esTank[iIndex].g_iChosenTypeLimit, value, 0, 32);
						g_esTank[iIndex].g_iFinaleTank = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "FinaleTank", "Finale Tank", "Finale_Tank", "finale", g_esTank[iIndex].g_iFinaleTank, value, 0, 4);
						g_esTank[iIndex].g_iOpenAreasOnly = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esTank[iIndex].g_iOpenAreasOnly, value, 0, 1);
						g_esTank[iIndex].g_iBossStages = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "BossStages", "Boss Stages", "Boss_Stages", "stages", g_esTank[iIndex].g_iBossStages, value, 1, 4);
						g_esTank[iIndex].g_iRandomTank = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "RandomTank", "Random Tank", "Random_Tank", "random", g_esTank[iIndex].g_iRandomTank, value, 0, 1);
						g_esTank[iIndex].g_flRandomInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "RandomInterval", "Random Interval", "Random_Interval", "randinterval", g_esTank[iIndex].g_flRandomInterval, value, 0.1, 999999.0);
						g_esTank[iIndex].g_flTransformDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TransformDelay", "Transform Delay", "Transform_Delay", "transdelay", g_esTank[iIndex].g_flTransformDelay, value, 0.1, 999999.0);
						g_esTank[iIndex].g_flTransformDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TransformDuration", "Transform Duration", "Transform_Duration", "transduration", g_esTank[iIndex].g_flTransformDuration, value, 0.1, 999999.0);
						g_esTank[iIndex].g_iSpawnMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "SpawnMode", "Spawn Mode", "Spawn_Mode", "mode", g_esTank[iIndex].g_iSpawnMode, value, 0, 3);
						g_esTank[iIndex].g_iRockModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Props", "Props", "Props", "Props", key, "RockModel", "Rock Model", "Rock_Model", "rockmodel", g_esTank[iIndex].g_iRockModel, value, 0, 2);
						g_esTank[iIndex].g_iPropsAttached = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Props", "Props", "Props", "Props", key, "PropsAttached", "Props Attached", "Props_Attached", "attached", g_esTank[iIndex].g_iPropsAttached, value, 0, 511);
						g_esTank[iIndex].g_iBodyEffects = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Particles", "Particles", "Particles", "Particles", key, "BodyEffects", "Body Effects", "Body_Effects", "body", g_esTank[iIndex].g_iBodyEffects, value, 0, 127);
						g_esTank[iIndex].g_iRockEffects = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Particles", "Particles", "Particles", "Particles", key, "RockEffects", "Rock Effects", "Rock_Effects", "rock", g_esTank[iIndex].g_iRockEffects, value, 0, 15);
						g_esTank[iIndex].g_flAttackInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "AttackInterval", "Attack Interval", "Attack_Interval", "attack", g_esTank[iIndex].g_flAttackInterval, value, -1.0, 999999.0);
						g_esTank[iIndex].g_flClawDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_esTank[iIndex].g_flClawDamage, value, -1.0, 999999.0);
						g_esTank[iIndex].g_flRockDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esTank[iIndex].g_flRockDamage, value, -1.0, 999999.0);
						g_esTank[iIndex].g_flRunSpeed = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esTank[iIndex].g_flRunSpeed, value, -1.0, 3.0);
						g_esTank[iIndex].g_flThrowInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esTank[iIndex].g_flThrowInterval, value, -1.0, 999999.0);
						g_esTank[iIndex].g_iBulletImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "immune", key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esTank[iIndex].g_iBulletImmunity, value, 0, 1);
						g_esTank[iIndex].g_iExplosiveImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "immune", key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esTank[iIndex].g_iExplosiveImmunity, value, 0, 1);
						g_esTank[iIndex].g_iFireImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "immune", key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esTank[iIndex].g_iFireImmunity, value, 0, 1);
						g_esTank[iIndex].g_iMeleeImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "immune", key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esTank[iIndex].g_iMeleeImmunity, value, 0, 1);

						if (StrEqual(g_esGeneral.g_sCurrentSubSection, "General", false))
						{
							if (StrEqual(key, "TankName", false) || StrEqual(key, "Tank Name", false) || StrEqual(key, "Tank_Name", false) || StrEqual(key, "name", false))
							{
								strcopy(g_esTank[iIndex].g_sTankName, sizeof(esTank::g_sTankName), value);
							}
							else if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
							{
								static char sValue[16];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");

								static char sSet[4][4];
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < sizeof(esTank::g_iSkinColor); iPos++)
								{
									g_esTank[iIndex].g_iSkinColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
								}
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Glow", false))
						{
							if (StrEqual(key, "GlowColor", false) || StrEqual(key, "Glow Color", false) || StrEqual(key, "Glow_Color", false))
							{
								static char sValue[12];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");

								static char sSet[3][4];
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < sizeof(esTank::g_iGlowColor); iPos++)
								{
									g_esTank[iIndex].g_iGlowColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
								}
							}
							else if (StrEqual(key, "GlowRange", false) || StrEqual(key, "Glow Range", false) || StrEqual(key, "Glow_Range", false))
							{
								static char sValue[50];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");

								static char sRange[2][7];
								ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

								g_esTank[iIndex].g_iGlowMinRange = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, 999999) : g_esTank[iIndex].g_iGlowMinRange;
								g_esTank[iIndex].g_iGlowMaxRange = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, 999999) : g_esTank[iIndex].g_iGlowMaxRange;
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Health", false))
						{
							if (StrEqual(key, "HealthCharacters", false) || StrEqual(key, "Health Characters", false) || StrEqual(key, "Health_Characters", false) || StrEqual(key, "hpchars", false))
							{
								strcopy(g_esTank[iIndex].g_sHealthCharacters, sizeof(esTank::g_sHealthCharacters), value);
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Administration", false) || StrEqual(g_esGeneral.g_sCurrentSubSection, "admin", false))
						{
							if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
							{
								g_esTank[iIndex].g_iAccessFlags = ReadFlagString(value);
							}
							else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
							{
								g_esTank[iIndex].g_iImmunityFlags = ReadFlagString(value);
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Spawn", false))
						{
							if (StrEqual(key, "TransformTypes", false) || StrEqual(key, "Transform Types", false) || StrEqual(key, "Transform_Types", false) || StrEqual(key, "transtypes", false))
							{
								static char sValue[50];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");

								static char sSet[10][5];
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < sizeof(esTank::g_iTransformType); iPos++)
								{
									g_esTank[iIndex].g_iTransformType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType) : g_esTank[iIndex].g_iTransformType[iPos];
								}
							}
							else
							{
								static char sValue[24];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");

								static char sSet[4][6];
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < sizeof(esTank::g_iBossHealth); iPos++)
								{
									if (StrEqual(key, "BossHealthStages", false) || StrEqual(key, "Boss Health Stages", false) || StrEqual(key, "Boss_Health_Stages", false) || StrEqual(key, "healthstages", false))
									{
										g_esTank[iIndex].g_iBossHealth[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXHEALTH) : g_esTank[iIndex].g_iBossHealth[iPos];
									}
									else if (StrEqual(key, "BossTypes", false) || StrEqual(key, "Boss Types", false) || StrEqual(key, "Boss_Types", false))
									{
										g_esTank[iIndex].g_iBossType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType) : g_esTank[iIndex].g_iBossType[iPos];
									}
								}
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Props", false))
						{
							if (StrEqual(key, "PropsChance", false) || StrEqual(key, "Props Chance", false) || StrEqual(key, "Props_Chance", false) || StrEqual(key, "chance", false))
							{
								static char sValue[54];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");

								static char sSet[9][6];
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < sizeof(esTank::g_flPropsChance); iPos++)
								{
									g_esTank[iIndex].g_flPropsChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esTank[iIndex].g_flPropsChance[iPos];
								}
							}
							else
							{
								static char sValue[16];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");

								static char sSet[4][4];
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < sizeof(esTank::g_iLightColor); iPos++)
								{
									if (StrEqual(key, "LightColor", false) || StrEqual(key, "Light Color", false) || StrEqual(key, "Light_Color", false) || StrEqual(key, "light", false))
									{
										g_esTank[iIndex].g_iLightColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
									else if (StrEqual(key, "OxygenTankColor", false) || StrEqual(key, "Oxygen Tank Color", false) || StrEqual(key, "Oxygen_Tank_Color", false) || StrEqual(key, "oxygen", false))
									{
										g_esTank[iIndex].g_iOzTankColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
									else if (StrEqual(key, "FlameColor", false) || StrEqual(key, "Flame Color", false) || StrEqual(key, "Flame_Color", false) || StrEqual(key, "flame", false))
									{
										g_esTank[iIndex].g_iFlameColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
									else if (StrEqual(key, "RockColor", false) || StrEqual(key, "Rock Color", false) || StrEqual(key, "Rock_Color", false) || StrEqual(key, "rock", false))
									{
										g_esTank[iIndex].g_iRockColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
									else if (StrEqual(key, "TireColor", false) || StrEqual(key, "Tire Color", false) || StrEqual(key, "Tire_Color", false) || StrEqual(key, "tire", false))
									{
										g_esTank[iIndex].g_iTireColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
									else if (StrEqual(key, "PropaneTankColor", false) || StrEqual(key, "Propane Tank Color", false) || StrEqual(key, "Propane_Tank_Color", false) || StrEqual(key, "propane", false))
									{
										g_esTank[iIndex].g_iPropTankColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
									else if (StrEqual(key, "FlashlightColor", false) || StrEqual(key, "Flashlight Color", false) || StrEqual(key, "Flashlight_Color", false) || StrEqual(key, "flashlight", false))
									{
										g_esTank[iIndex].g_iFlashlightColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
									else if (StrEqual(key, "CrownColor", false) || StrEqual(key, "Crown Color", false) || StrEqual(key, "Crown_Color", false) || StrEqual(key, "crown", false))
									{
										g_esTank[iIndex].g_iCrownColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
								}
							}
						}

						for (int iPos = 0; iPos < MT_MAX_ABILITIES; iPos++)
						{
							g_esTank[iIndex].g_bAbilityFound[iPos] = bHasAbility(g_esGeneral.g_sCurrentSubSection, iPos);
						}

						Call_StartForward(g_esGeneral.g_gfConfigsLoadedForward);
						Call_PushString(g_esGeneral.g_sCurrentSubSection);
						Call_PushString(key);
						Call_PushString(value);
						Call_PushCell(iIndex);
						Call_PushCell(-1);
						Call_PushCell(g_esGeneral.g_iConfigMode);
						Call_Finish();
					}
				}
			}
		}
		else if (g_esGeneral.g_iConfigMode == 3 && (StrContains(g_esGeneral.g_sCurrentSection, "STEAM_", false) == 0 || strncmp("0:", g_esGeneral.g_sCurrentSection, 2) == 0 || strncmp("1:", g_esGeneral.g_sCurrentSection, 2) == 0 || (!strncmp(g_esGeneral.g_sCurrentSection, "[U:", 3) && g_esGeneral.g_sCurrentSection[strlen(g_esGeneral.g_sCurrentSection) - 1] == ']')))
		{
			static char sSteamID32[32], sSteam3ID[32];
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
				{
					if (GetClientAuthId(iPlayer, AuthId_Steam2, sSteamID32, sizeof(sSteamID32)) && GetClientAuthId(iPlayer, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID)))
					{
						if (StrEqual(sSteamID32, g_esGeneral.g_sCurrentSection, false) || StrEqual(sSteam3ID, g_esGeneral.g_sCurrentSection, false))
						{
							g_esPlayer[iPlayer].g_iTankNote = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "TankNote", "Tank Note", "Tank_Note", "note", g_esPlayer[iPlayer].g_iTankNote, value, 0, 1);
							g_esPlayer[iPlayer].g_iAnnounceArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esPlayer[iPlayer].g_iAnnounceArrival, value, 0, 31);
							g_esPlayer[iPlayer].g_iAnnounceDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esPlayer[iPlayer].g_iAnnounceDeath, value, 0, 2);
							g_esPlayer[iPlayer].g_iDeathRevert = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esPlayer[iPlayer].g_iDeathRevert, value, 0, 1);
							g_esPlayer[iPlayer].g_iDetectPlugins = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "DetectPlugins", "Detect Plugins", "Detect_Plugins", "detect", g_esPlayer[iPlayer].g_iDetectPlugins, value, 0, 1);
							g_esPlayer[iPlayer].g_iRequiresHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "General", "General", "General", "General", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[iPlayer].g_iRequiresHumans, value, 0, 32);
							g_esPlayer[iPlayer].g_iGlowEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Glow", "Glow", "Glow", "Glow", key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "enabled", g_esPlayer[iPlayer].g_iGlowEnabled, value, 0, 1);
							g_esPlayer[iPlayer].g_iGlowFlashing = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Glow", "Glow", "Glow", "Glow", key, "GlowFlashing", "Glow Flashing", "Glow_Flashing", "flashing", g_esPlayer[iPlayer].g_iGlowFlashing, value, 0, 1);
							g_esPlayer[iPlayer].g_iGlowType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Glow", "Glow", "Glow", "Glow", key, "GlowType", "Glow Type", "Glow_Type", "type", g_esPlayer[iPlayer].g_iGlowType, value, 0, 1);
							g_esPlayer[iPlayer].g_iDisplayHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esPlayer[iPlayer].g_iDisplayHealth, value, 0, 11);
							g_esPlayer[iPlayer].g_iDisplayHealthType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esPlayer[iPlayer].g_iDisplayHealthType, value, 0, 2);
							g_esPlayer[iPlayer].g_iExtraHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "ExtraHealth", "Extra Health", "Extra_Health", "health", g_esPlayer[iPlayer].g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
							g_esPlayer[iPlayer].g_iMinimumHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esPlayer[iPlayer].g_iMinimumHumans, value, 1, 32);
							g_esPlayer[iPlayer].g_iMultiHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Health", "Health", "Health", "Health", key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esPlayer[iPlayer].g_iMultiHealth, value, 0, 3);
							g_esPlayer[iPlayer].g_iBossStages = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "BossStages", "Boss Stages", "Boss_Stages", "stages", g_esPlayer[iPlayer].g_iBossStages, value, 1, 4);
							g_esPlayer[iPlayer].g_iRandomTank = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "RandomTank", "Random Tank", "Random_Tank", "random", g_esPlayer[iPlayer].g_iRandomTank, value, 0, 1);
							g_esPlayer[iPlayer].g_flRandomInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "RandomInterval", "Random Interval", "Random_Interval", "randinterval", g_esPlayer[iPlayer].g_flRandomInterval, value, 0.1, 999999.0);
							g_esPlayer[iPlayer].g_flTransformDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TransformDelay", "Transform Delay", "Transform_Delay", "transdelay", g_esPlayer[iPlayer].g_flTransformDelay, value, 0.1, 999999.0);
							g_esPlayer[iPlayer].g_flTransformDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TransformDuration", "Transform Duration", "Transform_Duration", "transduration", g_esPlayer[iPlayer].g_flTransformDuration, value, 0.1, 999999.0);
							g_esPlayer[iPlayer].g_iRockModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Props", "Props", "Props", "Props", key, "RockModel", "Rock Model", "Rock_Model", "rockmodel", g_esPlayer[iPlayer].g_iRockModel, value, 0, 2);
							g_esPlayer[iPlayer].g_iPropsAttached = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Props", "Props", "Props", "Props", key, "PropsAttached", "Props Attached", "Props_Attached", "attached", g_esPlayer[iPlayer].g_iPropsAttached, value, 0, 511);
							g_esPlayer[iPlayer].g_iBodyEffects = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Particles", "Particles", "Particles", "Particles", key, "BodyEffects", "Body Effects", "Body_Effects", "body", g_esPlayer[iPlayer].g_iBodyEffects, value, 0, 127);
							g_esPlayer[iPlayer].g_iRockEffects = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Particles", "Particles", "Particles", "Particles", key, "RockEffects", "Rock Effects", "Rock_Effects", "rock", g_esPlayer[iPlayer].g_iRockEffects, value, 0, 15);
							g_esPlayer[iPlayer].g_flAttackInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "AttackInterval", "Attack Interval", "Attack_Interval", "attack", g_esPlayer[iPlayer].g_flAttackInterval, value, -1.0, 999999.0);
							g_esPlayer[iPlayer].g_flClawDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_esPlayer[iPlayer].g_flClawDamage, value, -1.0, 999999.0);
							g_esPlayer[iPlayer].g_flRockDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esPlayer[iPlayer].g_flRockDamage, value, -1.0, 999999.0);
							g_esPlayer[iPlayer].g_flRunSpeed = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esPlayer[iPlayer].g_flRunSpeed, value, -1.0, 3.0);
							g_esPlayer[iPlayer].g_flThrowInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esPlayer[iPlayer].g_flThrowInterval, value, -1.0, 999999.0);
							g_esPlayer[iPlayer].g_iBulletImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "immune", key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esPlayer[iPlayer].g_iBulletImmunity, value, 0, 1);
							g_esPlayer[iPlayer].g_iExplosiveImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "immune", key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esPlayer[iPlayer].g_iExplosiveImmunity, value, 0, 1);
							g_esPlayer[iPlayer].g_iFireImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "immune", key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esPlayer[iPlayer].g_iFireImmunity, value, 0, 1);
							g_esPlayer[iPlayer].g_iMeleeImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "immune", key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esPlayer[iPlayer].g_iMeleeImmunity, value, 0, 1);
							g_esPlayer[iPlayer].g_iFavoriteType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, "Administration", "Administration", "Administration", "admin", key, "FavoriteType", "Favorite Type", "Favorite_Type", "favorite", g_esPlayer[iPlayer].g_iFavoriteType, value, 0, g_esGeneral.g_iMaxType);

							if (StrEqual(g_esGeneral.g_sCurrentSubSection, "General", false))
							{
								if (StrEqual(key, "TankName", false) || StrEqual(key, "Tank Name", false) || StrEqual(key, "Tank_Name", false) || StrEqual(key, "name", false))
								{
									strcopy(g_esPlayer[iPlayer].g_sTankName, sizeof(esPlayer::g_sTankName), value);
								}
								else if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
								{
									static char sValue[16];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");

									static char sSet[4][4];
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < sizeof(esPlayer::g_iSkinColor); iPos++)
									{
										g_esPlayer[iPlayer].g_iSkinColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
								}
							}
							else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Glow", false))
							{
								if (StrEqual(key, "GlowColor", false) || StrEqual(key, "Glow Color", false) || StrEqual(key, "Glow_Color", false))
								{
									static char sValue[12];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");

									static char sSet[3][4];
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < sizeof(esPlayer::g_iGlowColor); iPos++)
									{
										g_esPlayer[iPlayer].g_iGlowColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
									}
								}
								else if (StrEqual(key, "GlowRange", false) || StrEqual(key, "Glow Range", false) || StrEqual(key, "Glow_Range", false))
								{
									static char sValue[14];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");

									static char sRange[2][7];
									ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

									g_esPlayer[iPlayer].g_iGlowMinRange = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, 999999) : g_esPlayer[iPlayer].g_iGlowMinRange;
									g_esPlayer[iPlayer].g_iGlowMaxRange = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, 999999) : g_esPlayer[iPlayer].g_iGlowMaxRange;
								}
							}
							else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Health", false))
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
							else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Spawn", false))
							{
								if (StrEqual(key, "TransformTypes", false) || StrEqual(key, "Transform Types", false) || StrEqual(key, "Transform_Types", false) || StrEqual(key, "transtypes", false))
								{
									static char sValue[50];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");

									static char sSet[10][5];
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < sizeof(esPlayer::g_iTransformType); iPos++)
									{
										g_esPlayer[iPlayer].g_iTransformType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType) : g_esPlayer[iPlayer].g_iTransformType[iPos];
									}
								}
								else
								{
									static char sValue[24];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");

									static char sSet[4][6];
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < sizeof(esPlayer::g_iBossHealth); iPos++)
									{
										if (StrEqual(key, "BossHealthStages", false) || StrEqual(key, "Boss Health Stages", false) || StrEqual(key, "Boss_Health_Stages", false) || StrEqual(key, "healthstages", false))
										{
											g_esPlayer[iPlayer].g_iBossHealth[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXHEALTH) : g_esPlayer[iPlayer].g_iBossHealth[iPos];
										}
										else if (StrEqual(key, "BossTypes", false) || StrEqual(key, "Boss Types", false) || StrEqual(key, "Boss_Types", false))
										{
											g_esPlayer[iPlayer].g_iBossType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_esGeneral.g_iMinType, g_esGeneral.g_iMaxType) : g_esPlayer[iPlayer].g_iBossType[iPos];
										}
									}
								}
							}
							else if (StrEqual(g_esGeneral.g_sCurrentSubSection, "Props", false))
							{
								if (StrEqual(key, "PropsChance", false) || StrEqual(key, "Props Chance", false) || StrEqual(key, "Props_Chance", false) || StrEqual(key, "chance", false))
								{
									static char sValue[54];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");

									static char sSet[9][6];
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < sizeof(esPlayer::g_flPropsChance); iPos++)
									{
										g_esPlayer[iPlayer].g_flPropsChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esPlayer[iPlayer].g_flPropsChance[iPos];
									}
								}
								else
								{
									static char sValue[16];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");

									static char sSet[4][4];
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
							else if (StrContains(g_esGeneral.g_sCurrentSubSection, "Tank#", false) == 0 || StrContains(g_esGeneral.g_sCurrentSubSection, "Tank #", false) == 0 || StrContains(g_esGeneral.g_sCurrentSubSection, "Tank_#", false) == 0 || StrContains(g_esGeneral.g_sCurrentSubSection, "Tank", false) == 0 || g_esGeneral.g_sCurrentSubSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sCurrentSubSection[0]) || StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSubSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSubSection, "-") != -1)
							{
								static char sTankName[7][33];
								for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
								{
									FormatEx(sTankName[0], sizeof(sTankName[]), "Tank#%i", iIndex);
									FormatEx(sTankName[1], sizeof(sTankName[]), "Tank #%i", iIndex);
									FormatEx(sTankName[2], sizeof(sTankName[]), "Tank_#%i", iIndex);
									FormatEx(sTankName[3], sizeof(sTankName[]), "Tank%i", iIndex);
									FormatEx(sTankName[4], sizeof(sTankName[]), "Tank %i", iIndex);
									FormatEx(sTankName[5], sizeof(sTankName[]), "Tank_%i", iIndex);
									FormatEx(sTankName[6], sizeof(sTankName[]), "#%i", iIndex);

									static int iRealType;
									iRealType = iFindSectionType(g_esGeneral.g_sCurrentSubSection, iIndex);

									static char sIndex[5], sRealType[5];
									IntToString(iIndex, sIndex, sizeof(sIndex));
									IntToString(iRealType, sRealType, sizeof(sRealType));

									for (int iType = 0; iType < sizeof(sTankName); iType++)
									{
										if (StrEqual(g_esGeneral.g_sCurrentSubSection, sTankName[iType], false) || StrEqual(g_esGeneral.g_sCurrentSubSection, sIndex) || StrEqual(sRealType, sIndex) || StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1)
										{
											if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
											{
												g_esAdmin[iIndex].g_iAccessFlags[iPlayer] = ReadFlagString(value);
											}
											else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
											{
												g_esAdmin[iIndex].g_iImmunityFlags[iPlayer] = ReadFlagString(value);
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
		if (StrEqual(g_esGeneral.g_sCurrentSection, "PluginSettings", false) || StrEqual(g_esGeneral.g_sCurrentSection, "Plugin Settings", false) || StrEqual(g_esGeneral.g_sCurrentSection, "Plugin_Settings", false) || StrEqual(g_esGeneral.g_sCurrentSection, "settings", false))
		{
			g_esGeneral.g_csState = ConfigState_Settings;
		}
		else if (StrContains(g_esGeneral.g_sCurrentSection, "Tank#", false) == 0 || StrContains(g_esGeneral.g_sCurrentSection, "Tank #", false) == 0 || StrContains(g_esGeneral.g_sCurrentSection, "Tank_#", false) == 0 || StrContains(g_esGeneral.g_sCurrentSection, "Tank", false) == 0 || g_esGeneral.g_sCurrentSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || StrContains(g_esGeneral.g_sCurrentSection, ",") != -1 || StrContains(g_esGeneral.g_sCurrentSection, "-") != -1)
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
			if (bIsTankAllowed(iTank) && bHasCoreAdminAccess(iTank))
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
					vCopyStats(iBot, iPlayer);
					vTankSpawn(iPlayer, -1);
					vReset2(iBot, 0);
					vReset3(iBot);
					vCacheSettings(iBot);
				}
				else if (bIsSurvivor(iPlayer))
				{
					vCopyDamage(iBot, iPlayer);
				}
			}
		}
		else if (StrEqual(name, "finale_escape_start") || StrEqual(name, "finale_vehicle_incoming") || StrEqual(name, "finale_vehicle_ready"))
		{
			g_esGeneral.g_iTankWave = 3;

			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_vehicle_leaving") || StrEqual(name, "finale_win"))
		{
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
		else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start"))
		{
			g_esGeneral.g_iTankWave = 0;

			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
				{
					vReset2(iPlayer);
					vReset3(iPlayer);
					vCacheSettings(iPlayer);
				}
			}
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
					vCopyStats(iPlayer, iBot);
					vTankSpawn(iBot, -1);
					vReset2(iPlayer, 0);
					vReset3(iPlayer);
					vCacheSettings(iPlayer);
				}
				else if (bIsSurvivor(iBot))
				{
					vCopyDamage(iPlayer, iBot);
				}
			}
		}
		else if (StrEqual(name, "player_death"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTankAllowed(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) || g_esPlayer[iTank].g_iTankType > 0)
			{
				g_esPlayer[iTank].g_bDied = true;
				g_esPlayer[iTank].g_bDying = false;
				g_esPlayer[iTank].g_bTriggered = false;

				if (bIsCustomTankAllowed(iTank))
				{
					switch (g_esCache[iTank].g_iAnnounceDeath)
					{
						case 1: vAnnounceDeath(iTank);
						case 2:
						{
							int iSurvivor = GetClientOfUserId(event.GetInt("attacker"));
							if (bIsSurvivor(iSurvivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
							{
								int iAssistant = iSurvivor;
								for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
								{
									if (bIsValidClient(iPlayer, MT_CHECK_INGAME) && g_esPlayer[iPlayer].g_iTankDamage[iTank] > g_esPlayer[iAssistant].g_iTankDamage[iTank])
									{
										iAssistant = iPlayer;
									}
								}

								char sPhrase[32], sTankName[33];
								float flPercentage = (float(g_esPlayer[iAssistant].g_iTankDamage[iTank]) / float(g_esPlayer[iTank].g_iTankHealth)) * 100;
								int iOption = GetRandomInt(1, 10);
								FormatEx(sPhrase, sizeof(sPhrase), "Killer%i", iOption);
								vGetTranslatedName(sTankName, sizeof(sTankName), iTank);
								MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, iSurvivor, sTankName, iAssistant, flPercentage);
								vLogMessage(MT_LOG_LIFE, "%s %T", MT_TAG, sPhrase, LANG_SERVER, iSurvivor, sTankName, iAssistant, flPercentage);

								vResetDamage(iTank);
							}
							else
							{
								vAnnounceDeath(iTank);
							}
						}
					}
				}

				if (g_esCache[iTank].g_iDeathRevert == 1)
				{
					int iType = g_esPlayer[iTank].g_iTankType;
					vSetColor(iTank, _, _, true);

					g_esPlayer[iTank].g_iTankType = iType;
				}

				vReset2(iTank, g_esCache[iTank].g_iDeathRevert);

				CreateTimer(1.0, tTimerResetType, iTankId, TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(5.0, tTimerTankWave, _, TIMER_FLAG_NO_MAPCHANGE);
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
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				g_esPlayer[iTank].g_bDied = false;
				g_esPlayer[iTank].g_bDying = true;

				CreateTimer(7.5, tTimerKillStuckTank, iTankId, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else if (StrEqual(name, "player_now_it"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
 			if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && bIsValidGame())
			{
				vRemoveGlow(iTank);
			}
		}
		else if (StrEqual(name, "player_no_longer_it"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
 			if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && bIsValidGame() && !bIsPlayerIncapacitated(iTank) && g_esCache[iTank].g_iGlowEnabled == 1)
			{
				vSetGlow(iTank);
			}
		}
		else if (StrEqual(name, "player_spawn"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank))
			{
				RequestFrame(vPlayerSpawnFrame, iTankId);
			}
		}
		else if (StrEqual(name, "weapon_fire"))
		{
			static int iTankId, iTank;
			iTankId = event.GetInt("userid");
			iTank = GetClientOfUserId(iTankId);
			if (bIsTankAllowed(iTank) && g_esCache[iTank].g_flAttackInterval > 0.0)
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
						CreateTimer(g_esCache[iTank].g_flAttackInterval, tTimerResetDelay, iTankId, TIMER_FLAG_NO_MAPCHANGE);

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

static void vExecuteFinaleConfigs(const char[] filename)
{
	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_FINALE) && g_esGeneral.g_iConfigEnable == 1)
	{
		static char sFilePath[PLATFORM_MAX_PATH], sFinaleConfig[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sFinaleConfig, sizeof(sFinaleConfig), "data/mutant_tanks/%s", (bIsValidGame() ? "l4d2_finale_configs/" : "l4d_finale_configs/"));
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
	}
	else if (g_esGeneral.g_bPluginEnabled && (!bPluginAllowed || !bPluginEnabled))
	{
		g_esGeneral.g_bPluginEnabled = false;

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
		HookEvent("mission_lost", vEventHandler);
		HookEvent("player_bot_replace", vEventHandler);
		HookEvent("player_death", vEventHandler, EventHookMode_Pre);
		HookEvent("player_hurt", vEventHandler);
		HookEvent("player_incapacitated", vEventHandler);
		HookEvent("player_jump", vEventHandler);
		HookEvent("player_spawn", vEventHandler);
		HookEvent("player_now_it", vEventHandler);
		HookEvent("player_no_longer_it", vEventHandler);
		HookEvent("weapon_fire", vEventHandler);

		if (bIsValidGame())
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
		UnhookEvent("mission_lost", vEventHandler);
		UnhookEvent("player_bot_replace", vEventHandler);
		UnhookEvent("player_death", vEventHandler, EventHookMode_Pre);
		UnhookEvent("player_hurt", vEventHandler);
		UnhookEvent("player_incapacitated", vEventHandler);
		UnhookEvent("player_jump", vEventHandler);
		UnhookEvent("player_spawn", vEventHandler);
		UnhookEvent("player_now_it", vEventHandler);
		UnhookEvent("player_no_longer_it", vEventHandler);
		UnhookEvent("weapon_fire", vEventHandler);

		if (bIsValidGame())
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

static void vLogMessage(int type, const char[] message, any ...)
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
				static char sBuffer[255], sMessage[255], sTime[32];
				SetGlobalTransTarget(LANG_SERVER);
				VFormat(sBuffer, sizeof(sBuffer), message, 3);

				ReplaceString(sBuffer, sizeof(sBuffer), "{default}", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "\x01", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "{mint}", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "\x03", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "{yellow}", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "\x04", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "{olive}", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "\x05", "");
				ReplaceString(sBuffer, sizeof(sBuffer), "{percent}", "%%");

				FormatTime(sTime, sizeof(sTime), "%Y-%m-%d - %H:%M:%S", GetTime());
				FormatEx(sMessage, sizeof(sMessage), "[%s] %s", sTime, sBuffer);

				PrintToServer(sBuffer);
				vSaveMessage(sMessage);
			}
		}
	}
}

static void vToggleLogging(int type = -1)
{
	static char sMessage[255], sMap[128], sTime[32], sDate[32];

	GetCurrentMap(sMap, sizeof(sMap));
	FormatTime(sTime, sizeof(sTime), "%m/%d/%Y %H:%M:%S", GetTime());

	FormatTime(sDate, sizeof(sDate), "%Y-%m-%d", GetTime());
	BuildPath(Path_SM, g_esGeneral.g_sChatFile, sizeof(esGeneral::g_sChatFile), "logs/mutant_tanks_%s.log", sDate);

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

				FormatEx(sMessage, sizeof(sMessage), "[%s] --- %s: %s ---", sTime, ((iType != 0) ? "LOG STARTED ON MAP" : "LOG ENDED ON MAP"), sMap);
			}
		}
		case 0, 1:
		{
			if (g_esGeneral.g_iLogMessages != 0)
			{
				bLog = true;
				iType = g_esGeneral.g_iLogMessages;

				FormatEx(sMessage, sizeof(sMessage), "[%s] --- %s: %s ---", sTime, ((type == 1) ? "LOG STARTED ON MAP" : "LOG ENDED ON MAP"), sMap);
			}
		}
	}

	if (bLog)
	{
		vSaveMessage("--=================================================================--");
		vSaveMessage(sMessage);
		vSaveMessage("--=================================================================--");
	}
}

static void vSaveMessage(const char[] message)
{
	File fLog = OpenFile(g_esGeneral.g_sChatFile, "a");
	fLog.WriteLine(message);

	delete fLog;
}

static void vBoss(int tank, int limit, int stages, int type, int stage)
{
	if (stages >= stage)
	{
		static int iHealth, iNewHealth, iFinalHealth;
		iHealth = GetClientHealth(tank);
		if (iHealth <= limit)
		{
			g_esPlayer[tank].g_iBossStageCount = stage;

			vSetColor(tank, type);
			vTankSpawn(tank, 1);

			iNewHealth = g_esPlayer[tank].g_iTankHealth + limit;
			iFinalHealth = (iNewHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iNewHealth;
			//SetEntityHealth(tank, iFinalHealth);
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth);
		}
	}
}

static void vNewTankSettings(int tank, bool revert = false)
{
	vResetTank(tank);

	Call_StartForward(g_esGeneral.g_gfChangeTypeForward);
	Call_PushCell(tank);
	Call_PushCell(revert);
	Call_Finish();
}

static void vRegularSpawn()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsValidClient(iTank, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "tank auto");

			break;
		}
	}
}

static void vRemoveGlow(int tank)
{
	SetEntProp(tank, Prop_Send, "m_glowColorOverride", 0);
	SetEntProp(tank, Prop_Send, "m_bFlashing", 0);
	SetEntProp(tank, Prop_Send, "m_iGlowType", 0);
}

static void vRemoveProps(int tank, int mode = 1)
{
	if (bIsValidEntRef(g_esPlayer[tank].g_iTankModel))
	{
		g_esPlayer[tank].g_iTankModel = EntRefToEntIndex(g_esPlayer[tank].g_iTankModel);
		if (bIsValidEntity(g_esPlayer[tank].g_iTankModel))
		{
			SDKUnhook(g_esPlayer[tank].g_iTankModel, SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_esPlayer[tank].g_iTankModel);
		}
	}

	g_esPlayer[tank].g_iTankModel = INVALID_ENT_REFERENCE;

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

	if (bIsValidGame())
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
	g_esGeneral.g_bForceSpawned = false;
	g_esGeneral.g_bUsedParser = false;
	g_esGeneral.g_iChosenType = 0;
	g_esGeneral.g_iParserViewer = 0;
	g_esGeneral.g_iRegularCount = 0;

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset2(iPlayer);
			vReset3(iPlayer);
			vResetCore(iPlayer);
			vCacheSettings(iPlayer);
			vKillRandomizeTimer(iPlayer);
		}
	}

	vClearAbilityList();
	vClearPluginList();
	vKillRegularWavesTimer();
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
}

static void vResetCore(int client)
{
	g_esPlayer[client].g_bAdminMenu = false;
	g_esPlayer[client].g_bAttacked = false;
	g_esPlayer[client].g_bDied = false;
	g_esPlayer[client].g_bDying = false;
	g_esPlayer[client].g_iLastButtons = 0;
	g_esPlayer[client].g_bStasis = false;
	g_esPlayer[client].g_bThirdPerson = false;
	g_esPlayer[client].g_bThirdPerson2 = false;

	vResetDamage(client);
}

static void vResetDamage(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		g_esPlayer[iSurvivor].g_iTankDamage[tank] = 0;
	}
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

static void vResetTank(int tank)
{
	ExtinguishEntity(tank);
	vAttachParticle(tank, PARTICLE_ELECTRICITY, 2.0, 30.0);
	EmitSoundToAll(SOUND_ELECTRICITY, tank);
	vResetSpeed(tank, true);
}

static void vKillRandomizeTimer(int tank)
{
	if (g_esPlayer[tank].g_hRandomizeTimer != null)
	{
		KillTimer(g_esPlayer[tank].g_hRandomizeTimer);
		g_esPlayer[tank].g_hRandomizeTimer = null;
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
		if (bIsTankAllowed(iTank))
		{
			vRandomize(iTank);
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

static void vSpawnModes(int tank, bool status)
{
	g_esPlayer[tank].g_bBoss = status;
	g_esPlayer[tank].g_bRandomized = status;
	g_esPlayer[tank].g_bTransformed = status;
}

static void vSetColor(int tank, int type = 0, bool change = true, bool revert = false)
{
	if (change)
	{
		vNewTankSettings(tank, revert);
	}

	if (type == 0)
	{
		vRemoveProps(tank);

		return;
	}
	else if (g_esPlayer[tank].g_iTankType > 0 && g_esPlayer[tank].g_iTankType == type && !g_esPlayer[tank].g_bReplaceSelf && !g_esPlayer[tank].g_bKeepCurrentType)
	{
		vRemoveProps(tank);

		g_esPlayer[tank].g_iTankType = 0;

		return;
	}
	else if (type > 0 && g_esPlayer[tank].g_iTankType > 0)
	{
		g_esPlayer[tank].g_iOldTankType = g_esPlayer[tank].g_iTankType;
	}

	g_esPlayer[tank].g_iTankType = type;
	g_esPlayer[tank].g_bReplaceSelf = false;

	vCacheSettings(tank);

	SetEntityRenderMode(tank, RENDER_NORMAL);
	SetEntityRenderColor(tank, iGetRandomColor(g_esCache[tank].g_iSkinColor[0]), iGetRandomColor(g_esCache[tank].g_iSkinColor[1]), iGetRandomColor(g_esCache[tank].g_iSkinColor[2]), iGetRandomColor(g_esCache[tank].g_iSkinColor[3]));

	if (bIsValidGame() && g_esCache[tank].g_iGlowEnabled == 1)
	{
		vSetGlow(tank);
	}
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
	SetEntProp(tank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGetRandomColor(g_esCache[tank].g_iGlowColor[0]), iGetRandomColor(g_esCache[tank].g_iGlowColor[1]), iGetRandomColor(g_esCache[tank].g_iGlowColor[2])));
	SetEntProp(tank, Prop_Send, "m_bFlashing", g_esCache[tank].g_iGlowFlashing);
	SetEntProp(tank, Prop_Send, "m_nGlowRangeMin", g_esCache[tank].g_iGlowMinRange);
	SetEntProp(tank, Prop_Send, "m_nGlowRange", g_esCache[tank].g_iGlowMaxRange);
	SetEntProp(tank, Prop_Send, "m_iGlowType", (g_esCache[tank].g_iGlowType == 1 ? 3 : 2));
}

static void vSetName(int tank, const char[] oldname, const char[] name, int mode)
{
	if (bIsTank(tank))
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

		switch (bIsTankIdle(tank))
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
	if (bIsTank(tank))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[0] && (g_esCache[tank].g_iPropsAttached & MT_PROP_BLUR) && !g_esPlayer[tank].g_bBlur)
		{
			g_esPlayer[tank].g_bBlur = true;

			CreateTimer(0.25, tTimerBlurEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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

					if (bIsValidGame())
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

					if (bIsValidGame())
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

				if (bIsValidGame())
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
		case 2: SetEntityModel(rock, (GetRandomInt(0, 1) == 0 ? MODEL_CONCRETE_CHUNK : MODEL_TREE_TRUNK));
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
				vLogMessage(MT_LOG_CHANGE, "%s %T", MT_TAG, "Evolved", LANG_SERVER, oldname, name, g_esPlayer[tank].g_iBossStageCount + 1);
			}
		}
		case 2:
		{
			if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_RANDOM)
			{
				MT_PrintToChatAll("%s %t", MT_TAG2, "Randomized", oldname, name);
				vLogMessage(MT_LOG_CHANGE, "%s %T", MT_TAG, "Randomized", LANG_SERVER, oldname, name);
			}
		}
		case 3:
		{
			if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_TRANSFORM)
			{
				MT_PrintToChatAll("%s %t", MT_TAG2, "Transformed", oldname, name);
				vLogMessage(MT_LOG_CHANGE, "%s %T", MT_TAG, "Transformed", LANG_SERVER, oldname, name);
			}
		}
		case 4:
		{
			if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_REVERT)
			{
				MT_PrintToChatAll("%s %t", MT_TAG2, "Untransformed", oldname, name);
				vLogMessage(MT_LOG_CHANGE, "%s %T", MT_TAG, "Untransformed", LANG_SERVER, oldname, name);
			}
		}
		case 5:
		{
			vAnnounceArrival(tank, name);
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChangeType");
		}
	}

	if (mode >= 0 && g_esCache[tank].g_iTankNote == 1 && bIsCustomTankAllowed(tank))
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
		vLogMessage(MT_LOG_LIFE, "%s %T", MT_TAG, (bExists ? sTankNote : "NoNote"), LANG_SERVER);
	}
}

static void vAnnounceArrival(int tank, const char[] name)
{
	if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_SPAWN)
	{
		char sPhrase[32];
		int iOption = GetRandomInt(1, 10);
		FormatEx(sPhrase, sizeof(sPhrase), "Arrival%i", iOption);
		MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, name);
		vLogMessage(MT_LOG_LIFE, "%s %T", MT_TAG, sPhrase, LANG_SERVER, name);
	}
}

static void vAnnounceDeath(int tank)
{
	char sPhrase[32], sTankName[33];
	int iOption = GetRandomInt(1, 10);
	FormatEx(sPhrase, sizeof(sPhrase), "Death%i", iOption);
	vGetTranslatedName(sTankName, sizeof(sTankName), tank);
	MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sTankName);
	vLogMessage(MT_LOG_LIFE, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sTankName);
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
		DispatchKeyValue(g_esPlayer[tank].g_iFlashlight, "spotlight_radius", "240.0");
		DispatchKeyValue(g_esPlayer[tank].g_iFlashlight, "distance", "255.0");
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
		DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "HDRColorScale", "0.7");

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
			flOrigin[2] = 95.0;
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
	if (bIsTankAllowed(tank) && g_esCache[tank].g_iBodyEffects > 0)
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

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_SPIT) && bIsValidGame() && !g_esPlayer[tank].g_bSpit)
		{
			g_esPlayer[tank].g_bSpit = true;

			CreateTimer(2.0, tTimerSpitEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

static void vMutateTank(int tank)
{
	if (bCanTypeSpawn())
	{
		int iType;
		if (g_esGeneral.g_iChosenType <= 0 && g_esPlayer[tank].g_iTankType <= 0)
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
			iType = (g_esGeneral.g_iChosenType > 0) ? g_esGeneral.g_iChosenType : g_esPlayer[tank].g_iTankType;
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

		switch (g_esTank[g_esPlayer[tank].g_iTankType].g_iSpawnMode)
		{
			case 1:
			{
				if (!g_esPlayer[tank].g_bBoss)
				{
					vSpawnModes(tank, true);

					DataPack dpBoss;
					CreateDataTimer(1.0, tTimerBoss, dpBoss, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					dpBoss.WriteCell(GetClientUserId(tank));
					dpBoss.WriteCell(g_esCache[tank].g_iBossStages);

					for (int iPos = 0; iPos < sizeof(esCache::g_iBossHealth); iPos++)
					{
						dpBoss.WriteCell(g_esCache[tank].g_iBossHealth[iPos]);
						dpBoss.WriteCell(g_esCache[tank].g_iBossType[iPos]);
					}
				}
			}
			case 2:
			{
				if (!g_esPlayer[tank].g_bRandomized)
				{
					vSpawnModes(tank, true);
					vRandomize(tank);
				}
			}
			case 3:
			{
				if (!g_esPlayer[tank].g_bTransformed)
				{
					vSpawnModes(tank, true);

					CreateTimer(g_esCache[tank].g_flTransformDelay, tTimerTransform, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

					DataPack dpUntransform;
					CreateDataTimer(g_esCache[tank].g_flTransformDuration + g_esCache[tank].g_flTransformDelay, tTimerUntransform, dpUntransform, TIMER_FLAG_NO_MAPCHANGE);
					dpUntransform.WriteCell(GetClientUserId(tank));
					dpUntransform.WriteCell(g_esPlayer[tank].g_iTankType);
				}
			}
		}

		if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iFavoriteType > 0 && iType != g_esPlayer[tank].g_iFavoriteType)
		{
			vFavoriteMenu(tank);
		}
	}

	g_esGeneral.g_bForceSpawned = false;
}

static void vRandomize(int tank)
{
	if (g_esPlayer[tank].g_bRandomized)
	{
		vKillRandomizeTimer(tank);
		g_esPlayer[tank].g_hRandomizeTimer = CreateTimer(g_esCache[tank].g_flRandomInterval, tTimerRandomize, GetClientUserId(tank), TIMER_REPEAT);
	}
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
				case 0: vQueueTank(param1, g_esPlayer[param1].g_iFavoriteType, false);
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "FavoriteUnused");
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MTFavoriteMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH];

			switch (param2)
			{
				case 0:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "OptionYes", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "OptionNo", param1);

					return RedrawMenuItem(sMenuOption);
				}
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

public void vPlayerSpawnFrame(int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (bIsTank(iTank) && !g_esPlayer[iTank].g_bFirstSpawn)
	{
		if (bIsTankInStasis(iTank) && g_esGeneral.g_iStasisMode == 1)
		{
			SDKCall(g_esGeneral.g_hSDKLeaveStasis, iTank);
		}

		g_esPlayer[iTank].g_bDying = false;
		g_esPlayer[iTank].g_bFirstSpawn = true;

		if (g_esPlayer[iTank].g_bDied)
		{
			g_esPlayer[iTank].g_bDied = false;
			g_esPlayer[iTank].g_iOldTankType = 0;
			g_esPlayer[iTank].g_iTankType = 0;
		}

		switch (g_esGeneral.g_iChosenType)
		{
			case 0:
			{
				switch (bIsTankAllowed(iTank, MT_CHECK_FAKECLIENT))
				{
					case true:
					{
						switch (g_esGeneral.g_iSpawnMode)
						{
							case 0:
							{
								g_esPlayer[iTank].g_bNeedHealth = true;

								vTankMenu(iTank, 0);
							}
							case 1: vMutateTank(iTank);
						}
					}
					case false: vMutateTank(iTank);
				}
			}
			default: vMutateTank(iTank);
		}
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
		if (bIsTankAllowed(iThrower) && bHasCoreAdminAccess(iThrower) && !bIsTankIdle(iThrower) && g_esTank[g_esPlayer[iThrower].g_iTankType].g_iTankEnabled == 1)
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
		}
	}
}

public void vTankSpawnFrame(DataPack pack)
{
	pack.Reset();

	static int iTank, iMode;
	iTank = GetClientOfUserId(pack.ReadCell()), iMode = pack.ReadCell();
	delete pack;
	if (bIsTankAllowed(iTank) && bHasCoreAdminAccess(iTank))
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

		if (iMode == 0)
		{
			if (bIsCustomTankAllowed(iTank))
			{
				static int iHumanCount, iSpawnHealth, iExtraHealthNormal, iExtraHealthBoost, iExtraHealthBoost2, iExtraHealthBoost3, iNoBoost, iBoost,
					iBoost2, iBoost3, iNegaNoBoost, iNegaBoost, iNegaBoost2, iNegaBoost3, iFinalNoHealth, iFinalHealth, iFinalHealth2, iFinalHealth3;
				iHumanCount = iGetHumanCount();
				iSpawnHealth = (g_esGeneral.g_iBaseHealth > 0) ? g_esGeneral.g_iBaseHealth : GetClientHealth(iTank);
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
				//SetEntityHealth(iTank, iFinalNoHealth);
				SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalNoHealth);
				SetEntProp(iTank, Prop_Data, "m_iMaxHealth", iFinalNoHealth);

				switch (g_esCache[iTank].g_iMultiHealth)
				{
					case 1:
					{
						//SetEntityHealth(iTank, iFinalHealth);
						SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalHealth);
						SetEntProp(iTank, Prop_Data, "m_iMaxHealth", iFinalHealth);
					}
					case 2:
					{
						//SetEntityHealth(iTank, iFinalHealth2);
						SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalHealth2);
						SetEntProp(iTank, Prop_Data, "m_iMaxHealth", iFinalHealth2);
					}
					case 3:
					{
						//SetEntityHealth(iTank, iFinalHealth3);
						SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalHealth3);
						SetEntProp(iTank, Prop_Data, "m_iMaxHealth", iFinalHealth3);
					}
				}

				if (bIsTankAllowed(iTank, MT_CHECK_FAKECLIENT) && g_esTank[g_esPlayer[iTank].g_iTankType].g_iHumanSupport == 1 && bHasCoreAdminAccess(iTank))
				{
					MT_PrintToChat(iTank, "%s %t", MT_TAG3, "SpawnMessage");
					MT_PrintToChat(iTank, "%s %t", MT_TAG2, "AbilityButtons");
					MT_PrintToChat(iTank, "%s %t", MT_TAG2, "AbilityButtons2");
					MT_PrintToChat(iTank, "%s %t", MT_TAG2, "AbilityButtons3");
					MT_PrintToChat(iTank, "%s %t", MT_TAG2, "AbilityButtons4");
				}
			}

			g_esPlayer[iTank].g_iTankHealth = GetClientHealth(iTank);
		}

		Call_StartForward(g_esGeneral.g_gfPostTankSpawnForward);
		Call_PushCell(iTank);
		Call_Finish();
	}
}

static void vAttackInterval(int tank)
{
	if (bIsTankAllowed(tank) && g_esCache[tank].g_flAttackInterval > 0.0)
	{
		static int iWeapon;
		iWeapon = GetPlayerWeaponSlot(tank, 0);
		if (iWeapon > 0)
		{
			g_esPlayer[tank].g_flAttackDelay = GetGameTime() + g_esCache[tank].g_flAttackInterval;
			SetEntPropFloat(iWeapon, Prop_Send, "m_attackTimer", g_esCache[tank].g_flAttackInterval, 0);
			SetEntPropFloat(iWeapon, Prop_Send, "m_attackTimer", g_esPlayer[tank].g_flAttackDelay, 1);
		}
	}
}

static void vThrowInterval(int tank)
{
	if (bIsTankAllowed(tank) && g_esCache[tank].g_flThrowInterval > 0.0)
	{
		int iAbility = GetEntPropEnt(tank, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", g_esCache[tank].g_flThrowInterval);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", GetGameTime() + g_esCache[tank].g_flThrowInterval);
		}
	}
}

static bool bAreHumansRequired(int type, int tank = 0)
{
	static int iCount;
	iCount = iGetHumanCount();
	return (tank > 0 && (g_esCache[tank].g_iRequiresHumans > 0 && iCount < g_esCache[tank].g_iRequiresHumans)) || (g_esTank[type].g_iRequiresHumans > 0 && iCount < g_esTank[type].g_iRequiresHumans) || (g_esGeneral.g_iRequiresHumans > 0 && iCount < g_esGeneral.g_iRequiresHumans);
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

static bool bHasAbility(const char[] subsection, int index)
{
	if (g_esGeneral.g_alAbilitySections[0] != null)
	{
		static int iListSize;
		iListSize = (g_esGeneral.g_alAbilitySections[0].Length > 0) ? g_esGeneral.g_alAbilitySections[0].Length : 0;
		if (iListSize > 0)
		{
			if (iListSize - 1 < index)
			{
				return false;
			}

			static char sSubset[4][32];
			for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
			{
				g_esGeneral.g_alAbilitySections[iPos].GetString(index, sSubset[iPos], sizeof(sSubset[]));
				if (StrEqual(subsection, sSubset[iPos], false))
				{
					return true;
				}
			}
		}
	}

	return false;
}

static bool bHasCoreAdminAccess(int admin, int type = 0)
{
	if (!bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || bIsDeveloper(admin))
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

	if (bIsDeveloper(survivor))
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

static bool bIsCustomTankAllowed(int tank)
{
	if (g_esGeneral.g_bCloneInstalled && !MT_IsCloneSupported(tank))
	{
		return false;
	}

	return true;
}

static bool bIsDeveloper(int developer)
{
	if (g_esGeneral.g_iAllowDeveloper == 1)
	{
		static char sSteamID32[32], sSteam3ID[32];
		if (GetClientAuthId(developer, AuthId_Steam2, sSteamID32, sizeof(sSteamID32)) && GetClientAuthId(developer, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID)))
		{
			if (StrEqual(sSteamID32, "STEAM_1:1:48199803", false) || StrEqual(sSteamID32, "STEAM_0:0:104982031", false) || StrEqual(sSteam3ID, "[U:1:96399607]", false) || StrEqual(sSteam3ID, "[U:1:209964062]", false))
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

static bool bIsTankAllowed(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE)
{
	if (!bIsTank(tank, flags) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esTank[g_esPlayer[tank].g_iTankType].g_iHumanSupport == 0))
	{
		return false;
	}

	return true;
}

static bool bIsTankIdle(int tank, int type = 0)
{
	if (!bIsTank(tank) || bIsTank(tank, MT_CHECK_FAKECLIENT))
	{
		return false;
	}

	Address adTank = GetEntityAddress(tank);
	if (adTank == Address_Null)
	{
		return false;
	}

	Address adIntention = view_as<Address>(iDereference(adTank, g_esGeneral.g_iIntentionOffset));
	if (adIntention == Address_Null)
	{
		return false;
	}

	Address adBehavior = adGetFirstContainedResponder(adIntention);
	if (adBehavior == Address_Null)
	{
		return false;
	}

	Address adAction = adGetFirstContainedResponder(adBehavior);
	if (adAction == Address_Null)
	{
		return false;
	}

	Address adChildAction;
	while ((adChildAction = adGetFirstContainedResponder(adAction)) != Address_Null)
	{
		adAction = adChildAction;
	}

	char sAction[64];
	SDKCall(g_esGeneral.g_hSDKGetName, adAction, sAction, sizeof(sAction));
	return (type != 2 && StrEqual(sAction, "TankIdle")) || (type != 1 && (StrEqual(sAction, "TankBehavior") || adAction == adBehavior));
}

static bool bIsTankInStasis(int tank)
{
	return g_esPlayer[tank].g_bStasis || (bIsValidGame() && (SDKCall(g_esGeneral.g_hSDKIsInStasis, tank) || bIsTankStasis(tank)));
}

static bool bIsTankInThirdPerson(int tank)
{
	return g_esPlayer[tank].g_bThirdPerson || g_esPlayer[tank].g_bThirdPerson2 || bIsTankThirdPerson(tank);
}

static bool bIsTypeAvailable(int type, int tank = 0)
{
	if ((tank > 0 && g_esCache[tank].g_iDetectPlugins == 0) || (g_esGeneral.g_iDetectPlugins == 0 && g_esTank[type].g_iDetectPlugins == 0))
	{
		return true;
	}

	static int iAbilityCount, iAbilities[MT_MAX_ABILITIES + 1];
	iAbilityCount = 0;
	for (int iAbility = 0; iAbility < MT_MAX_ABILITIES; iAbility++)
	{
		if (!g_esTank[type].g_bAbilityFound[iAbility])
		{
			continue;
		}

		iAbilities[iAbilityCount] = iAbility;
		iAbilityCount++;
	}

	if (iAbilityCount > 0)
	{
		static int iPluginCount;
		iPluginCount = 0;
		for (int iPos = 0; iPos < iAbilityCount; iPos++)
		{
			if (!g_esGeneral.g_bAbilityPlugin[iAbilities[iPos]])
			{
				continue;
			}

			iPluginCount++;
		}

		if (iPluginCount == 0)
		{
			return false;
		}
	}

	return true;
}

static bool bTankChance(int type)
{
	return GetRandomFloat(0.1, 100.0) <= g_esTank[type].g_flTankChance;
}

static float flGetScaledDamage(float damage)
{
	if (g_esGeneral.g_iCurrentMode == 1 && g_esGeneral.g_iScaleDamage == 1)
	{
		static char sDifficulty[11];
		g_esGeneral.g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));

		switch (sDifficulty[0])
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
			case 1: bCondition = g_esTank[iIndex].g_iTankEnabled == 0 || !bHasCoreAdminAccess(tank, iIndex) || g_esTank[iIndex].g_iSpawnEnabled == 0 || !bIsTypeAvailable(iIndex, tank) || bAreHumansRequired(iIndex, tank) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(tank, g_esTank[iIndex].g_iOpenAreasOnly) || !bTankChance(iIndex) || (g_esTank[iIndex].g_iChosenTypeLimit > 0 && iGetTypeCount(iIndex) >= g_esTank[iIndex].g_iChosenTypeLimit) || g_esPlayer[tank].g_iTankType == iIndex;
			case 2: bCondition = g_esTank[iIndex].g_iTankEnabled == 0 || !bHasCoreAdminAccess(tank) || g_esTank[iIndex].g_iRandomTank == 0 || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iRandomTank == 0) || g_esPlayer[tank].g_iTankType == iIndex || !bIsTypeAvailable(iIndex, tank) || bAreHumansRequired(iIndex, tank) || !bCanTypeSpawn(iIndex) || bIsAreaNarrow(tank, g_esTank[iIndex].g_iOpenAreasOnly);
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

static int iDereference(Address address, int offset = 0)
{
	if (address == Address_Null)
	{
		return -1;
	}

	return LoadFromAddress(address + view_as<Address>(offset), NumberType_Int32);
}

static int iFindSectionType(const char[] section, int type)
{
	static char sSection[PLATFORM_MAX_PATH], sSet[16][10];
	if (StrContains(section, ",") != -1 || StrContains(section, "-") != -1)
	{
		strcopy(sSection, sizeof(sSection), section);

		if (StrContains(section, ",") != -1)
		{
			ExplodeString(sSection, ",", sSet, sizeof(sSet), sizeof(sSet[]));

			for (int iPos = 0; iPos < sizeof(sSet); iPos++)
			{
				if (StrContains(sSet[iPos], "-") != -1)
				{
					static char sSubset[2][5];
					ExplodeString(sSet[iPos], "-", sSubset, sizeof(sSubset), sizeof(sSubset[]));

					for (int iType = StringToInt(sSubset[0]); iType <= StringToInt(sSubset[1]); iType++)
					{
						if (type == iType)
						{
							return iType;
						}
					}
				}
				else
				{
					static int iType;
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

			for (int iType = StringToInt(sSet[0]); iType <= StringToInt(sSet[1]); iType++)
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

static int iGetTankCount(bool include = false)
{
	static int iTankCount;
	iTankCount = 0;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
		{
			if (!include && g_esGeneral.g_bCloneInstalled && MT_IsTankClone(iTank))
			{
				continue;
			}

			iTankCount++;
		}
	}

	return iTankCount;
}

static int iGetTypeCount(int type)
{
	static int iTypeCount;
	iTypeCount = 0;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTankAllowed(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iTank].g_iTankType == type)
		{
			iTypeCount++;
		}
	}

	return iTypeCount;
}

static Address adGetFirstContainedResponder(Address address)
{
	return view_as<Address>(SDKCall(g_esGeneral.g_hSDKFirstContainedResponder, address));
}

public void L4D_OnEnterGhostState(int client)
{
	if (bIsTank(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && g_esPlayer[client].g_iTankType > 0)
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
	vCopyStats(tank, newtank);
	vTankSpawn(newtank, -1);
	vReset2(tank, 0);
	vReset3(tank);
	vCacheSettings(tank);
}

public Action L4D_OnSpawnTank(const float vecPos[3], const float vecAng[3])
{
	if (g_esGeneral.g_bForceSpawned)
	{
		g_esGeneral.g_bForceSpawned = false;

		return Plugin_Continue;
	}

	bool bBlock = false;
	int iCount = iGetTankCount();

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
						case 0: bBlock = g_esGeneral.g_iFinaleWave[g_esGeneral.g_iTankWave - 1] <= iCount;
						default: bBlock = g_esGeneral.g_iFinaleAmount <= iCount;
					}
				}
			}
		}
		case false: bBlock = 0 < g_esGeneral.g_iRegularAmount <= iCount;
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

public MRESReturn mreLaunchDirectionPre(int pThis)
{
	if (bIsValidEntity(pThis))
	{
		g_esGeneral.g_iLauncher = pThis;
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

public MRESReturn mreTankRockPost(Handle hReturn)
{
	static int iRock;
	iRock = DHookGetReturn(hReturn);
	if (bIsValidEntity(iRock) && bIsValidEntity(g_esGeneral.g_iLauncher))
	{
		static int iThrower;
		iThrower = GetEntPropEnt(iRock, Prop_Data, "m_hThrower");
		if (bIsTank(iThrower))
		{
			return MRES_Ignored;
		}

		static int iTank;
		iTank = GetEntPropEnt(g_esGeneral.g_iLauncher, Prop_Send, "m_hOwnerEntity");
		if (bIsTank(iTank))
		{
			SetEntPropEnt(iRock, Prop_Data, "m_hThrower", iTank);
			SetEntPropEnt(iRock, Prop_Send, "m_hOwnerEntity", g_esGeneral.g_iLauncher);
			SetEntityRenderColor(iRock, iGetRandomColor(g_esCache[iTank].g_iRockColor[0]), iGetRandomColor(g_esCache[iTank].g_iRockColor[1]), iGetRandomColor(g_esCache[iTank].g_iRockColor[2]), iGetRandomColor(g_esCache[iTank].g_iRockColor[3]));
			vSetRockModel(iTank, iRock);
		}
	}

	g_esGeneral.g_iLauncher = 0;

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
	if (bIsValidClient(client))
	{
		switch (result)
		{
			case ConVarQuery_Okay: g_esPlayer[client].g_bThirdPerson = (StrEqual(cvarName, "z_view_distance") && StringToInt(cvarValue) <= -1) ? true : false;
			default: g_esPlayer[client].g_bThirdPerson = false;
		}
	}
}

public void vViewQuery2(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (bIsValidClient(client))
	{
		switch (result)
		{
			case ConVarQuery_Okay: g_esPlayer[client].g_bThirdPerson2 = (StrEqual(cvarName, "c_thirdpersonshoulder") && (StringToInt(cvarValue) == 1 || StrEqual(cvarValue, "1", false))) ? true : false;
			default: g_esPlayer[client].g_bThirdPerson2 = false;
		}
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
	else if (bIsTankIdle(iTank, 1) && g_esGeneral.g_iCurrentMode == 1 && g_esGeneral.g_iAggressiveTanks == 1 && !g_esPlayer[iTank].g_bTriggered)
	{
		g_esPlayer[iTank].g_bTriggered = true;

		int iHealth = GetClientHealth(iTank);
		vDamageEntity(iTank, iGetRandomSurvivor(iTank), 1.0, "0");
		SetEntProp(iTank, Prop_Data, "m_iHealth", iHealth);
	}

	return Plugin_Continue;
}

public Action tTimerBloodEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_BLOOD) || !g_esPlayer[iTank].g_bBlood)
	{
		g_esPlayer[iTank].g_bBlood = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_BLOOD, 0.75, 30.0);

	return Plugin_Continue;
}

public Action tTimerBlurEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iPropsAttached & MT_PROP_BLUR) || !g_esPlayer[iTank].g_bBlur)
	{
		g_esPlayer[iTank].g_bBlur = false;

		return Plugin_Stop;
	}

	static float flTankPos[3], flTankAng[3];
	GetClientAbsOrigin(iTank, flTankPos);
	GetClientAbsAngles(iTank, flTankAng);

	g_esPlayer[iTank].g_iTankModel = CreateEntityByName("prop_dynamic");
	if (bIsValidEntity(g_esPlayer[iTank].g_iTankModel))
	{
		SetEntityModel(g_esPlayer[iTank].g_iTankModel, MODEL_TANK);
		SetEntPropEnt(g_esPlayer[iTank].g_iTankModel, Prop_Send, "m_hOwnerEntity", iTank);

		TeleportEntity(g_esPlayer[iTank].g_iTankModel, flTankPos, flTankAng, NULL_VECTOR);
		DispatchSpawn(g_esPlayer[iTank].g_iTankModel);

		AcceptEntityInput(g_esPlayer[iTank].g_iTankModel, "DisableCollision");

		SetEntityRenderColor(g_esPlayer[iTank].g_iTankModel, iGetRandomColor(g_esCache[iTank].g_iSkinColor[0]), iGetRandomColor(g_esCache[iTank].g_iSkinColor[1]), iGetRandomColor(g_esCache[iTank].g_iSkinColor[2]), iGetRandomColor(g_esCache[iTank].g_iSkinColor[3]));

		SetEntProp(g_esPlayer[iTank].g_iTankModel, Prop_Send, "m_nSequence", GetEntProp(iTank, Prop_Send, "m_nSequence"));
		SetEntPropFloat(g_esPlayer[iTank].g_iTankModel, Prop_Send, "m_flPlaybackRate", 5.0);

		SDKHook(g_esPlayer[iTank].g_iTankModel, SDKHook_SetTransmit, SetTransmit);

		g_esPlayer[iTank].g_iTankModel = EntIndexToEntRef(g_esPlayer[iTank].g_iTankModel);
		vDeleteEntity(g_esPlayer[iTank].g_iTankModel, 0.3);
	}

	return Plugin_Continue;
}

public Action tTimerBoss(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank;
	iTank = GetClientOfUserId(pack.ReadCell());
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bIsCustomTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !g_esPlayer[iTank].g_bBoss)
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	static int iBossStages, iBossHealth, iType, iBossHealth2, iType2, iBossHealth3, iType3, iBossHealth4, iType4;
	iBossStages = pack.ReadCell();
	iBossHealth = pack.ReadCell();
	iType = pack.ReadCell();
	iBossHealth2 = pack.ReadCell();
	iType2 = pack.ReadCell();
	iBossHealth3 = pack.ReadCell(),
	iType3 = pack.ReadCell();
	iBossHealth4 = pack.ReadCell();
	iType4 = pack.ReadCell();

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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank))
	{
		return Plugin_Stop;
	}

	QueryClientConVar(iTank, "z_view_distance", vViewQuery);
	QueryClientConVar(iTank, "c_thirdpersonshoulder", vViewQuery2);

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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_ELECTRICITY) || !g_esPlayer[iTank].g_bElectric)
	{
		g_esPlayer[iTank].g_bElectric = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_ELECTRICITY, 0.75, 30.0);

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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_FIRE) || !g_esPlayer[iTank].g_bFire)
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0)
	{
		return Plugin_Stop;
	}

	int iAbility = L4D_MaterializeFromGhost(iTank);
	if (iAbility == -1)
	{
		MT_PrintToChat(iTank, "%s %t", MT_TAG3, "SpawnManually");
	}

	return Plugin_Continue;
}

public Action tTimerIceEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_ICE) || !g_esPlayer[iTank].g_bIce)
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bIsTankAllowed(iTank, MT_CHECK_ALIVE) || bIsTankAllowed(iTank, MT_CHECK_FAKECLIENT))
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bIsPlayerIncapacitated(iTank))
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_METEOR) || !g_esPlayer[iTank].g_bMeteor)
	{
		g_esPlayer[iTank].g_bMeteor = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_METEOR, 6.0, 30.0);

	return Plugin_Continue;
}

public Action tTimerRandomize(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !bIsCustomTankAllowed(iTank) || !g_esPlayer[iTank].g_bRandomized)
	{
		g_esPlayer[iTank].g_hRandomizeTimer = null;

		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	static int iType;
	iType = iChooseTank(iTank, 2, _, _, false);
	switch (iType)
	{
		case 0:
		{
			g_esPlayer[iTank].g_hRandomizeTimer = null;

			return Plugin_Stop;
		}
		default: vSetColor(iTank, iType);
	}

	vTankSpawn(iTank, 2);

	return Plugin_Continue;
}

public Action tTimerRefreshConfigs(Handle timer)
{
	if (FileExists(g_esGeneral.g_sSavePath, true))
	{
		g_esGeneral.g_iFileTimeNew[0] = GetFileTime(g_esGeneral.g_sSavePath, FileTime_LastChange);
		if (g_esGeneral.g_iFileTimeOld[0] != g_esGeneral.g_iFileTimeNew[0])
		{
			vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, g_esGeneral.g_sSavePath);
			vLoadConfigs(g_esGeneral.g_sSavePath, 1);
			vPluginStatus();
			vResetTimers();
			vToggleLogging();
			g_esGeneral.g_iFileTimeOld[0] = g_esGeneral.g_iFileTimeNew[0];
		}
	}

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_esGeneral.g_iConfigEnable == 1 && g_esGeneral.g_cvMTDifficulty != null)
	{
		static char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_esGeneral.g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/mutant_tanks/difficulty_configs/%s.cfg", sDifficulty);
		if (FileExists(sDifficultyConfig, true))
		{
			g_esGeneral.g_iFileTimeNew[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
			if (g_esGeneral.g_iFileTimeOld[1] != g_esGeneral.g_iFileTimeNew[1])
			{
				vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sDifficultyConfig);
				vCustomConfig(sDifficultyConfig);
				g_esGeneral.g_iFileTimeOld[1] = g_esGeneral.g_iFileTimeNew[1];
			}
		}
	}

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_MAP) && g_esGeneral.g_iConfigEnable == 1)
	{
		static char sMap[64], sMapConfig[PLATFORM_MAX_PATH];
		GetCurrentMap(sMap, sizeof(sMap));
		BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), "data/mutant_tanks/%s/%s.cfg", (bIsValidGame() ? "l4d2_map_configs" : "l4d_map_configs"), sMap);
		if (FileExists(sMapConfig, true))
		{
			g_esGeneral.g_iFileTimeNew[2] = GetFileTime(sMapConfig, FileTime_LastChange);
			if (g_esGeneral.g_iFileTimeOld[2] != g_esGeneral.g_iFileTimeNew[2])
			{
				vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sMapConfig);
				vCustomConfig(sMapConfig);
				g_esGeneral.g_iFileTimeOld[2] = g_esGeneral.g_iFileTimeNew[2];
			}
		}
	}

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_GAMEMODE) && g_esGeneral.g_iConfigEnable == 1)
	{
		static char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
		g_esGeneral.g_cvMTGameMode.GetString(sMode, sizeof(sMode));
		BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), "data/mutant_tanks/%s/%s.cfg", (bIsValidGame() ? "l4d2_gamemode_configs" : "l4d_gamemode_configs"), sMode);
		if (FileExists(sModeConfig, true))
		{
			g_esGeneral.g_iFileTimeNew[3] = GetFileTime(sModeConfig, FileTime_LastChange);
			if (g_esGeneral.g_iFileTimeOld[3] != g_esGeneral.g_iFileTimeNew[3])
			{
				vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sModeConfig);
				vCustomConfig(sModeConfig);
				g_esGeneral.g_iFileTimeOld[3] = g_esGeneral.g_iFileTimeNew[3];
			}
		}
	}

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DAY) && g_esGeneral.g_iConfigEnable == 1)
	{
		static char sDay[9], sDayNumber[2], sDayConfig[PLATFORM_MAX_PATH];
		FormatTime(sDayNumber, sizeof(sDayNumber), "%w", GetTime());
		static int iDayNumber;
		iDayNumber = StringToInt(sDayNumber);

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
			if (g_esGeneral.g_iFileTimeOld[4] != g_esGeneral.g_iFileTimeNew[4])
			{
				vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sDayConfig);
				vCustomConfig(sDayConfig);
				g_esGeneral.g_iFileTimeOld[4] = g_esGeneral.g_iFileTimeNew[4];
			}
		}
	}

	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_COUNT) && g_esGeneral.g_iConfigEnable == 1)
	{
		static char sCountConfig[PLATFORM_MAX_PATH];
		static int iCount;
		iCount = iGetPlayerCount();
		BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/playercount_configs/%i.cfg", iCount);
		if (FileExists(sCountConfig, true))
		{
			g_esGeneral.g_iFileTimeNew[5] = GetFileTime(sCountConfig, FileTime_LastChange);
			if (g_esGeneral.g_iFileTimeOld[5] != g_esGeneral.g_iFileTimeNew[5])
			{
				vLogMessage(MT_LOG_SERVER, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sCountConfig);
				vCustomConfig(sCountConfig);
				g_esGeneral.g_iFileTimeOld[5] = g_esGeneral.g_iFileTimeNew[5];
				g_esGeneral.g_iPlayerCount[1] = iCount;
				g_esGeneral.g_iPlayerCount[0] = g_esGeneral.g_iPlayerCount[1];
			}
			else if (g_esGeneral.g_iPlayerCount[0] != g_esGeneral.g_iPlayerCount[1])
			{
				vCustomConfig(sCountConfig);
				g_esGeneral.g_iPlayerCount[1] = iCount;
				g_esGeneral.g_iPlayerCount[0] = g_esGeneral.g_iPlayerCount[1];
			}
		}
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
	iCount = iGetTankCount();
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

public Action tTimerResetDelay(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank))
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
	if (!bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || g_esCache[iTank].g_iRockEffects == 0)
	{
		return Plugin_Stop;
	}

	static char sClassname[32];
	GetEntityClassname(iRock, sClassname, sizeof(sClassname));
	if (StrEqual(sClassname, "tank_rock"))
	{
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

		if (g_esCache[iTank].g_iRockEffects & MT_ROCK_SPIT)
		{
			EmitSoundToAll(SOUND_SPIT, iTank);
			vAttachParticle(iRock, PARTICLE_SPIT, 0.75);
		}

		return Plugin_Continue;
	}

	return Plugin_Stop;
}

public Action tTimerSmokeEffect(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_SMOKE) || !g_esPlayer[iTank].g_bSmoke)
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
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_SPIT) || !g_esPlayer[iTank].g_bSpit)
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

	static int iTank, iAmount, iCount;
	iTank = GetClientOfUserId(pack.ReadCell()), iAmount = pack.ReadCell(), iCount = iGetTankCount();
	if (!bIsTank(iTank) || iAmount == 0 || iCount >= iAmount || (bIsNonFinaleMap() && g_esGeneral.g_iTankWave == 0 && g_esGeneral.g_iRegularMode == 1 && g_esGeneral.g_iRegularWave == 1))
	{
		return Plugin_Stop;
	}
	else if (iCount < iAmount)
	{
		vRegularSpawn();
	}

	return Plugin_Continue;
}

public Action tTimerTankUpdate(Handle timer, int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bIsCustomTankAllowed(iTank) || g_esPlayer[iTank].g_iTankType <= 0)
	{
		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	Call_StartForward(g_esGeneral.g_gfAbilityActivatedForward);
	Call_PushCell(iTank);
	Call_Finish();

	return Plugin_Continue;
}

public Action tTimerTankWave(Handle timer)
{
	if (bIsNonFinaleMap() || iGetTankCount(true) > 0 || !(0 < g_esGeneral.g_iTankWave < 10))
	{
		return Plugin_Stop;
	}

	g_esGeneral.g_iTankWave++;

	return Plugin_Continue;
}

public Action tTimerTransform(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasCoreAdminAccess(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0 || !bIsCustomTankAllowed(iTank) || !g_esPlayer[iTank].g_bTransformed)
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	int iPos = GetRandomInt(0, 9);
	vSetColor(iTank, g_esCache[iTank].g_iTransformType[iPos]);
	vTankSpawn(iTank, 3);

	return Plugin_Continue;
}

public Action tTimerUntransform(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || g_esTank[g_esPlayer[iTank].g_iTankType].g_iTankEnabled == 0)
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	int iTankType = pack.ReadCell();
	vSetColor(iTank, iTankType);
	vTankSpawn(iTank, 4);
	vSpawnModes(iTank, false);

	return Plugin_Continue;
}