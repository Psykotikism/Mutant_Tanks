/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2019  Alfred "Crasher_3637/Psyk0tik" Llagas
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
#include <mutant_tanks>

#undef REQUIRE_PLUGIN
#include <mt_clone>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Mutant Tanks",
	author = MT_AUTHOR,
	description = "Mutant Tanks makes fighting Tanks great again!",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"Mutant Tanks\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	CreateNative("MT_CanTankSpawn", aNative_CanTankSpawn);
	CreateNative("MT_GetAccessFlags", aNative_GetAccessFlags);
	CreateNative("MT_GetCurrentFinaleWave", aNative_GetCurrentFinaleWave);
	CreateNative("MT_GetImmunityFlags", aNative_GetImmunityFlags);
	CreateNative("MT_GetMaxType", aNative_GetMaxType);
	CreateNative("MT_GetMinType", aNative_GetMinType);
	CreateNative("MT_GetPropColors", aNative_GetPropColors);
	CreateNative("MT_GetRunSpeed", aNative_GetRunSpeed);
	CreateNative("MT_GetTankColors", aNative_GetTankColors);
	CreateNative("MT_GetTankName", aNative_GetTankName);
	CreateNative("MT_GetTankType", aNative_GetTankType);
	CreateNative("MT_HasAdminAccess", aNative_HasAdminAccess);
	CreateNative("MT_HasChanceToSpawn", aNative_HasChanceToSpawn);
	CreateNative("MT_HideEntity", aNative_HideEntity);
	CreateNative("MT_IsAdminImmune", aNative_IsAdminImmune);
	CreateNative("MT_IsCorePluginEnabled", aNative_IsCorePluginEnabled);
	CreateNative("MT_IsFinaleTank", aNative_IsFinaleTank);
	CreateNative("MT_IsGlowEnabled", aNative_IsGlowEnabled);
	CreateNative("MT_IsTankSupported", aNative_IsTankSupported);
	CreateNative("MT_IsTypeEnabled", aNative_IsTypeEnabled);
	CreateNative("MT_SetTankType", aNative_SetTankType);
	CreateNative("MT_SpawnTank", aNative_SpawnTank);

	RegPluginLibrary("mutant_tanks");

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl"

#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define PARTICLE_FIRE "aircraft_destroy_fastFireTrail"
#define PARTICLE_ICE "apc_wheel_smoke1"
#define PARTICLE_METEOR "smoke_medium_01"
#define PARTICLE_SMOKE "smoker_smokecloud"
#define PARTICLE_SPIT "spitter_projectile"

#define SOUND_BOSS "items/suitchargeok1.wav"

#define MT_MAX_ABILITIES 72

#define MT_ARRIVAL_SPAWN (1 << 0) // announce spawn
#define MT_ARRIVAL_BOSS (1 << 1) // announce evolution
#define MT_ARRIVAL_RANDOM (1 << 2) // announce randomization
#define MT_ARRIVAL_TRANSFORM (1 << 3) // announce transformation
#define MT_ARRIVAL_REVERT (1 << 4) // announce revert

#define MT_CONFIG_DIFFICULTY (1 << 0) // difficulty_configs
#define MT_CONFIG_MAP (1 << 1) // l4d_map_configs/l4d2_map_configs
#define MT_CONFIG_GAMEMODE (1 << 2) // l4d_map_configs/l4d2_map_configs
#define MT_CONFIG_DAY (1 << 3) // daily_configs
#define MT_CONFIG_COUNT (1 << 4) // playercount_configs

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

ArrayList g_alAdmins;

bool g_bAbilityFound[MT_MAXTYPES + 1][MT_MAX_ABILITIES + 1], g_bAbilityPlugin[MT_MAX_ABILITIES + 1], g_bAdminMenu[MAXPLAYERS + 1], g_bBlood[MAXPLAYERS + 1], g_bBlur[MAXPLAYERS + 1], g_bBoss[MAXPLAYERS + 1], g_bChanged[MAXPLAYERS + 1], g_bCloneInstalled, g_bDying[MAXPLAYERS + 1], g_bElectric[MAXPLAYERS + 1], g_bFire[MAXPLAYERS + 1],
	g_bFound[MT_MAX_ABILITIES + 1], g_bIce[MAXPLAYERS + 1], g_bMeteor[MAXPLAYERS + 1], g_bNeedHealth[MAXPLAYERS + 1], g_bPluginEnabled, g_bRandomized[MAXPLAYERS + 1], g_bSmoke[MAXPLAYERS + 1], g_bSpit[MAXPLAYERS + 1], g_bThirdPerson[MAXPLAYERS + 1], g_bTransformed[MAXPLAYERS + 1];

char g_sPluginFilenames[][] =
{
	"mt_absorb.smx", "mt_acid.smx", "mt_aimless.smx", "mt_ammo.smx", "mt_blind.smx", "mt_bomb.smx", "mt_bury.smx", "mt_car.smx", "mt_choke.smx", "mt_clone.smx", "mt_cloud.smx", "mt_drop.smx", "mt_drug.smx", "mt_drunk.smx", "mt_electric.smx", "mt_enforce.smx", "mt_fast.smx", "mt_fire.smx", "mt_fling.smx", "mt_fragile.smx", "mt_ghost.smx",
	"mt_god.smx", "mt_gravity.smx", "mt_heal.smx", "mt_hit.smx", "mt_hurt.smx", "mt_hypno.smx", "mt_ice.smx", "mt_idle.smx", "mt_invert.smx", "mt_item.smx", "mt_jump.smx", "mt_kamikaze.smx", "mt_lag.smx", "mt_leech.smx", "mt_medic.smx", "mt_meteor.smx", "mt_minion.smx", "mt_necro.smx", "mt_nullify.smx", "mt_omni.smx", "mt_panic.smx",
	"mt_pimp.smx", "mt_puke.smx", "mt_pyro.smx", "mt_quiet.smx", "mt_recoil.smx", "mt_regen.smx", "mt_respawn.smx", "mt_restart.smx", "mt_rock.smx", "mt_rocket.smx", "mt_shake.smx", "mt_shield.smx", "mt_shove.smx", "mt_slow.smx", "mt_smash.smx", "mt_smite.smx", "mt_spam.smx", "mt_splash.smx", "mt_throw.smx", "mt_track.smx", "mt_ultimate.smx",
	"mt_undead.smx", "mt_vampire.smx", "mt_vision.smx", "mt_warp.smx", "mt_whirl.smx", "mt_witch.smx", "mt_xiphos.smx", "mt_yell.smx", "mt_zombie.smx"
}, g_sCurrentSection[128], g_sCurrentSubSection[128], g_sDisabledGameModes[513], g_sEnabledGameModes[513], g_sHealthCharacters[4], g_sHealthCharacters2[MT_MAXTYPES + 1][4], g_sHealthCharacters3[MAXPLAYERS + 1][4], g_sSavePath[PLATFORM_MAX_PATH], g_sTankName[MT_MAXTYPES + 1][33], g_sTankName2[MAXPLAYERS + 1][33], g_sUsedPath[PLATFORM_MAX_PATH];

ConfigState g_csState;

ConVar g_cvMTDifficulty, g_cvMTGameMode, g_cvMTGameTypes, g_cvMTMaxPlayerZombies;

float g_flClawDamage[MT_MAXTYPES + 1], g_flClawDamage2[MAXPLAYERS + 1], g_flPropsChance[MT_MAXTYPES + 1][6], g_flPropsChance2[MAXPLAYERS + 1][6], g_flRandomInterval[MT_MAXTYPES + 1], g_flRandomInterval2[MAXPLAYERS + 1], g_flRegularInterval, g_flRockDamage[MT_MAXTYPES + 1], g_flRockDamage2[MAXPLAYERS + 1], g_flRunSpeed[MT_MAXTYPES + 1],
	g_flRunSpeed2[MAXPLAYERS + 1], g_flTankChance[MT_MAXTYPES + 1], g_flThrowInterval[MT_MAXTYPES + 1], g_flThrowInterval2[MAXPLAYERS + 1], g_flTransformDelay[MT_MAXTYPES + 1], g_flTransformDelay2[MAXPLAYERS + 1], g_flTransformDuration[MT_MAXTYPES + 1], g_flTransformDuration2[MAXPLAYERS + 1];

GlobalForward g_gfAbilityActivatedForward, g_gfButtonPressedForward, g_gfButtonReleasedForward, g_gfChangeTypeForward, g_gfConfigsLoadForward, g_gfConfigsLoadedForward, g_gfDisplayMenuForward, g_gfEventFiredForward, g_gfHookEventForward, g_gfMenuItemSelectedForward, g_gfPluginEndForward, g_gfPostTankSpawnForward, g_gfRockBreakForward, g_gfRockThrowForward;

int g_iAccessFlags, g_iAccessFlags2[MT_MAXTYPES + 1], g_iAccessFlags3[MAXPLAYERS + 1], g_iAccessFlags4[MT_MAXTYPES + 1][MAXPLAYERS + 1], g_iAllowDeveloper, g_iAnnounceArrival, g_iAnnounceArrival2[MT_MAXTYPES + 1], g_iAnnounceArrival3[MAXPLAYERS + 1], g_iAnnounceDeath, g_iAnnounceDeath2[MT_MAXTYPES + 1], g_iAnnounceDeath3[MAXPLAYERS + 1],
	g_iBaseHealth, g_iBodyEffects[MT_MAXTYPES + 1], g_iBodyEffects2[MAXPLAYERS + 1], g_iBossHealth[MT_MAXTYPES + 1][4], g_iBossHealth2[MAXPLAYERS + 1][4], g_iBossStageCount[MAXPLAYERS + 1], g_iBossStages[MT_MAXTYPES + 1], g_iBossStages2[MAXPLAYERS + 1], g_iBossType[MT_MAXTYPES + 1][4], g_iBossType2[MAXPLAYERS + 1][4],
	g_iBulletImmunity[MT_MAXTYPES + 1], g_iBulletImmunity2[MAXPLAYERS + 1], g_iConfigCreate, g_iConfigEnable, g_iConfigExecute, g_iConfigMode, g_iCooldown[MAXPLAYERS + 1], g_iDeathRevert, g_iDeathRevert2[MT_MAXTYPES + 1], g_iDeathRevert3[MAXPLAYERS + 1], g_iDetectPlugins, g_iDetectPlugins2[MT_MAXTYPES + 1], g_iDetectPlugins3[MAXPLAYERS + 1],
	g_iDisplayHealth, g_iDisplayHealth2[MT_MAXTYPES + 1], g_iDisplayHealth3[MAXPLAYERS + 1], g_iDisplayHealthType, g_iDisplayHealthType2[MT_MAXTYPES + 1], g_iDisplayHealthType3[MAXPLAYERS + 1], g_iExplosiveImmunity[MT_MAXTYPES + 1], g_iExplosiveImmunity2[MAXPLAYERS + 1], g_iExtraHealth[MT_MAXTYPES + 1], g_iExtraHealth2[MAXPLAYERS + 1],
	g_iFavoriteType[MAXPLAYERS + 1], g_iFileTimeOld[7], g_iFileTimeNew[7], g_iFinalesOnly, g_iFinaleTank[MT_MAXTYPES + 1], g_iFinaleType[4], g_iFinaleWave[4], g_iFireImmunity[MT_MAXTYPES + 1], g_iFireImmunity2[MAXPLAYERS + 1], g_iFlame[MAXPLAYERS + 1][3], g_iFlameColor[MT_MAXTYPES + 1][4], g_iFlameColor2[MAXPLAYERS + 1][4], g_iGameModeTypes,
	g_iGlowEnabled[MT_MAXTYPES + 1], g_iGlowEnabled2[MAXPLAYERS + 1], g_iGlowColor[MT_MAXTYPES + 1][3], g_iGlowColor2[MAXPLAYERS + 1][3], g_iHumanCooldown, g_iHumanSupport[MT_MAXTYPES + 1], g_iIgnoreLevel, g_iImmunityFlags, g_iImmunityFlags2[MT_MAXTYPES + 1], g_iImmunityFlags3[MAXPLAYERS + 1], g_iImmunityFlags4[MT_MAXTYPES + 1][MAXPLAYERS + 1],
	g_iIncapTime[MAXPLAYERS + 1], g_iLastButtons[MAXPLAYERS + 1], g_iLight[MAXPLAYERS + 1][4], g_iLightColor[MT_MAXTYPES + 1][4], g_iLightColor2[MAXPLAYERS + 1][4], g_iMasterControl, g_iMaxType, g_iMeleeImmunity[MT_MAXTYPES + 1], g_iMeleeImmunity2[MAXPLAYERS + 1], g_iMenuEnabled[MT_MAXTYPES + 1], g_iMinType, g_iMultiHealth,
	g_iMultiHealth2[MT_MAXTYPES + 1], g_iMultiHealth3[MAXPLAYERS + 1], g_iOzTank[MAXPLAYERS + 1][3], g_iOzTankColor[MT_MAXTYPES + 1][4], g_iOzTankColor2[MAXPLAYERS + 1][4], g_iPlayerCount[2], g_iPluginEnabled, g_iPropsAttached[MT_MAXTYPES + 1], g_iPropsAttached2[MAXPLAYERS + 1], g_iRandomTank[MT_MAXTYPES + 1], g_iRandomTank2[MAXPLAYERS + 1],
	g_iRegularAmount, g_iRegularMode, g_iRegularType, g_iRegularWave, g_iRockEffects[MT_MAXTYPES + 1], g_iRockEffects2[MAXPLAYERS + 1], g_iRock[MAXPLAYERS + 1][17], g_iRockColor[MT_MAXTYPES + 1][4], g_iRockColor2[MAXPLAYERS + 1][4], g_iSkinColor[MT_MAXTYPES + 1][4], g_iSkinColor2[MAXPLAYERS + 1][4], g_iSpawnEnabled[MT_MAXTYPES + 1],
	g_iSpawnMode[MT_MAXTYPES + 1], g_iMTMode, g_iTankEnabled[MT_MAXTYPES + 1], g_iTankHealth[MAXPLAYERS + 1], g_iTankModel[MAXPLAYERS + 1], g_iTankNote[MT_MAXTYPES + 1], g_iTankType[MAXPLAYERS + 1], g_iTankWave, g_iTire[MAXPLAYERS + 1][3], g_iTireColor[MT_MAXTYPES + 1][4], g_iTireColor2[MAXPLAYERS + 1][4], g_iTransformType[MT_MAXTYPES + 1][10],
	g_iTransformType2[MAXPLAYERS + 1][10], g_iType, g_iTypeLimit[MT_MAXTYPES + 1];

TopMenu g_tmMTMenu;

public any aNative_CanTankSpawn(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	if (g_iSpawnEnabled[iType] == 1)
	{
		return true;
	}

	return false;
}

public any aNative_GetAccessFlags(Handle plugin, int numParams)
{
	int iMode = GetNativeCell(1), iType = GetNativeCell(2), iAdmin = GetNativeCell(3);
	if (iMode > 0)
	{
		switch (iMode)
		{
			case 1: return g_iAccessFlags;
			case 2: return g_iAccessFlags2[iType];
			case 3: return g_iAccessFlags3[iAdmin];
			case 4: return g_iAccessFlags4[iType][iAdmin];
		}
	}

	return 0;
}

public any aNative_GetCurrentFinaleWave(Handle plugin, int numParams)
{
	return g_iTankWave;
}

public any aNative_GetImmunityFlags(Handle plugin, int numParams)
{
	int iMode = GetNativeCell(1), iType = GetNativeCell(2), iAdmin = GetNativeCell(3);
	if (iMode > 0)
	{
		switch (iMode)
		{
			case 1: return g_iImmunityFlags;
			case 2: return g_iImmunityFlags2[iType];
			case 3: return g_iImmunityFlags3[iAdmin];
			case 4: return g_iImmunityFlags4[iType][iAdmin];
		}
	}

	return 0;
}

public any aNative_GetMaxType(Handle plugin, int numParams)
{
	return g_iMaxType;
}

public any aNative_GetMinType(Handle plugin, int numParams)
{
	return g_iMinType;
}

public any aNative_GetPropColors(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
	{
		int iMode = GetNativeCell(2), iColor[4];
		for (int iPos = 0; iPos < 4; iPos++)
		{
			switch (iMode)
			{
				case 1: iColor[iPos] = g_iLightColor[g_iTankType[iTank]][iPos];
				case 2: iColor[iPos] = g_iOzTankColor[g_iTankType[iTank]][iPos];
				case 3: iColor[iPos] = g_iFlameColor[g_iTankType[iTank]][iPos];
				case 4: iColor[iPos] = g_iRockColor[g_iTankType[iTank]][iPos];
				case 5: iColor[iPos] = g_iTireColor[g_iTankType[iTank]][iPos];
			}

			SetNativeCellRef(iPos + 3, iColor[iPos]);
		}
	}
}

public any aNative_GetRunSpeed(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && (g_flRunSpeed[g_iTankType[iTank]] > 0.0 || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_flRunSpeed2[iTank] > 0.0)))
	{
		return (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_flRunSpeed2[iTank] >= -1.0) ? g_flRunSpeed2[iTank] : g_flRunSpeed[g_iTankType[iTank]];
	}

	return 1.0;
}

public any aNative_GetTankColors(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
	{
		int iMode = GetNativeCell(2), iColor[4];
		for (int iPos = 0; iPos < 4; iPos++)
		{
			switch (iMode)
			{
				case 1: iColor[iPos] = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iSkinColor2[iTank][iPos] >= -1) ? g_iSkinColor2[iTank][iPos] : g_iSkinColor[g_iTankType[iTank]][iPos];
				case 2: iColor[iPos] = (iPos < 3) ? ((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iGlowColor2[iTank][iPos] >= -1) ? g_iGlowColor2[iTank][iPos] : g_iGlowColor[g_iTankType[iTank]][iPos]) : 255;
			}

			SetNativeCellRef(iPos + 3, iColor[iPos]);
		}
	}
}

public any aNative_GetTankName(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = GetNativeCell(2);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
	{
		char sTankName[33];
		sTankName = (g_sTankName2[iTank][0] == '\0') ? g_sTankName[iType] : g_sTankName2[iTank];
		SetNativeString(3, sTankName, sizeof(sTankName));
	}
}

public any aNative_GetTankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
	{
		return g_iTankType[iTank];
	}

	return 0;
}

public any aNative_HasAdminAccess(Handle plugin, int numParams)
{
	int iAdmin = GetNativeCell(1);
	if (bIsTank(iAdmin) && bHasAdminAccess(iAdmin))
	{
		return true;
	}

	return false;
}

public any aNative_HasChanceToSpawn(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	if (bTankChance(iType))
	{
		return true;
	}

	return false;
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
	if (bIsHumanSurvivor(iSurvivor) && bIsTank(iTank) && bIsAdminImmune(iSurvivor, iTank))
	{
		return true;
	}

	return false;
}

public any aNative_IsCorePluginEnabled(Handle plugin, int numParams)
{
	if (g_bPluginEnabled)
	{
		return true;
	}

	return false;
}

public any aNative_IsFinaleTank(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	if (g_iFinaleTank[iType] == 1)
	{
		return true;
	}

	return false;
}

public any aNative_IsGlowEnabled(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && (g_iGlowEnabled[g_iTankType[iTank]] == 1 || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iGlowEnabled2[iTank] == 1)))
	{
		return true;
	}

	return false;
}

public any aNative_IsTankSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iFlags = GetNativeCell(2);
	if (bIsTankAllowed(iTank, iFlags))
	{
		return true;
	}

	return false;
}

public any aNative_IsTypeEnabled(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	if (g_iTankEnabled[iType] == 1 && bIsTypeAvailable(iType))
	{
		return true;
	}

	return false;
}

public any aNative_SetTankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = GetNativeCell(2);
	bool bMode = GetNativeCell(3);
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
	{
		switch (bMode)
		{
			case true:
			{
				vResetTank(iTank);
				vSetColor(iTank, iType);
				vTankSpawn(iTank, 5);
			}
			case false: g_iTankType[iTank] = iType;
		}
	}
}

public any aNative_SpawnTank(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = GetNativeCell(2);
	if (bIsValidClient(iTank))
	{
		vQueueTank(iTank, iType);
	}
}

public void OnAllPluginsLoaded()
{
	for (int iPos = 0; iPos < MT_MAX_ABILITIES; iPos++)
	{
		g_bAbilityPlugin[iPos] = false;
	}

	char sSMPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "plugins");
	ArrayList alPlugins = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	vFindInstalledAbilities(alPlugins, sSMPath);
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "adminmenu", false))
	{
		g_tmMTMenu = null;
	}
	else if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	g_gfAbilityActivatedForward = new GlobalForward("MT_OnAbilityActivated", ET_Ignore, Param_Cell);
	g_gfButtonPressedForward = new GlobalForward("MT_OnButtonPressed", ET_Ignore, Param_Cell, Param_Cell);
	g_gfButtonReleasedForward = new GlobalForward("MT_OnButtonReleased", ET_Ignore, Param_Cell, Param_Cell);
	g_gfChangeTypeForward = new GlobalForward("MT_OnChangeType", ET_Ignore, Param_Cell, Param_Cell);
	g_gfConfigsLoadForward = new GlobalForward("MT_OnConfigsLoad", ET_Ignore);
	g_gfConfigsLoadedForward = new GlobalForward("MT_OnConfigsLoaded", ET_Ignore, Param_String, Param_String, Param_String, Param_Cell, Param_Cell);
	g_gfDisplayMenuForward = new GlobalForward("MT_OnDisplayMenu", ET_Ignore, Param_Cell);
	g_gfEventFiredForward = new GlobalForward("MT_OnEventFired", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	g_gfHookEventForward = new GlobalForward("MT_OnHookEvent", ET_Ignore, Param_Cell);
	g_gfMenuItemSelectedForward = new GlobalForward("MT_OnMenuItemSelected", ET_Ignore, Param_Cell, Param_String);
	g_gfPluginEndForward = new GlobalForward("MT_OnPluginEnd", ET_Ignore);
	g_gfPostTankSpawnForward = new GlobalForward("MT_OnPostTankSpawn", ET_Ignore, Param_Cell);
	g_gfRockBreakForward = new GlobalForward("MT_OnRockBreak", ET_Ignore, Param_Cell, Param_Cell);
	g_gfRockThrowForward = new GlobalForward("MT_OnRockThrow", ET_Ignore, Param_Cell, Param_Cell);

	vMultiTargetFilters(1);

	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_info", cmdMTInfo, "View information about Mutant Tanks.");
	RegConsoleCmd("sm_mt_list", cmdMTList, "View a list of installed abilities.");
	RegAdminCmd("sm_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Mutant Tank.");
	RegConsoleCmd("sm_tank2", cmdTank2, "Spawn a Mutant Tank.");
	RegConsoleCmd("sm_mutanttank", cmdMutantTank, "Choose a Mutant Tank.");

	CreateConVar("mt_pluginversion", MT_VERSION, "Mutant Tanks Version", FCVAR_NOTIFY);
	AutoExecConfig(true, "mutant_tanks");

	g_cvMTDifficulty = FindConVar("z_difficulty");
	g_cvMTGameMode = FindConVar("mp_gamemode");
	g_cvMTGameTypes = FindConVar("sv_gametypes");
	g_cvMTMaxPlayerZombies = FindConVar("z_max_player_zombies");

	g_cvMTDifficulty.AddChangeHook(vMTGameDifficultyCvar);

	char sSMPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/");
	CreateDirectory(sSMPath, 511);
	Format(g_sSavePath, sizeof(g_sSavePath), "%smutant_tanks.cfg", sSMPath);
	vLoadConfigs(g_sSavePath, 1);
	g_iFileTimeOld[0] = GetFileTime(g_sSavePath, FileTime_LastChange);

	HookEvent("round_start", vEventHandler);

	TopMenu tmAdminMenu;
	if (LibraryExists("adminmenu") && ((tmAdminMenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(tmAdminMenu);
	}

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	PrecacheModel(MODEL_CONCRETE, true);
	PrecacheModel(MODEL_JETPACK, true);
	PrecacheModel(MODEL_TIRES, true);
	PrecacheModel(MODEL_WITCH, true);
	PrecacheModel(MODEL_WITCHBRIDE, true);

	vPrecacheParticle(PARTICLE_BLOOD);
	vPrecacheParticle(PARTICLE_ELECTRICITY);
	vPrecacheParticle(PARTICLE_FIRE);
	vPrecacheParticle(PARTICLE_ICE);
	vPrecacheParticle(PARTICLE_METEOR);
	vPrecacheParticle(PARTICLE_SMOKE);
	vPrecacheParticle(PARTICLE_SPIT);

	PrecacheSound(SOUND_BOSS, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset2(client);

	g_bAdminMenu[client] = false;
	g_bThirdPerson[client] = false;
	g_iIncapTime[client] = 0;
	g_iPlayerCount[0] = iGetPlayerCount();
	g_iTankType[client] = 0;

	CreateTimer(1.0, tTimerCheckView, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public void OnClientPostAdminCheck(int client)
{
	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		vLoadConfigs(g_sSavePath, 3);
	}
}

public void OnClientDisconnect_Post(int client)
{
	g_bAdminMenu[client] = false;
	g_bThirdPerson[client] = false;
	g_iIncapTime[client] = 0;
	g_iLastButtons[client] = 0;
	g_iTankType[client] = 0;
}

public void OnConfigsExecuted()
{
	g_iType = 0;

	vLoadConfigs(g_sSavePath, 1);

	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (IsMapValid(sMapName))
	{
		vPluginStatus();

		CreateTimer(g_flRegularInterval, tTimerRegularWaves, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerReloadConfigs, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(0.1, tTimerTankHealthUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerTankTypeUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerUpdatePlayerCount, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	if ((g_iConfigCreate & MT_CONFIG_DIFFICULTY) && g_iConfigEnable == 1)
	{
		char sSMPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/difficulty_configs/");
		CreateDirectory(sSMPath, 511);

		char sDifficulty[32];
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

	if ((g_iConfigCreate & MT_CONFIG_MAP) && g_iConfigEnable == 1)
	{
		char sSMPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/%s", (bIsValidGame() ? "l4d2_map_configs/" : "l4d_map_configs/"));
		CreateDirectory(sSMPath, 511);

		char sMap[128];
		ArrayList alMaps = new ArrayList(16);

		int iSerial = -1;
		ReadMapList(alMaps, iSerial, "default", MAPLIST_FLAG_MAPSFOLDER);
		ReadMapList(alMaps, iSerial, "allexistingmaps__", MAPLIST_FLAG_MAPSFOLDER|MAPLIST_FLAG_NO_DEFAULT);

		int iMapCount = GetArraySize(alMaps);
		if (iMapCount > 0)
		{
			for (int iMap = 0; iMap < iMapCount; iMap++)
			{
				alMaps.GetString(iMap, sMap, sizeof(sMap));
				vCreateConfigFile((bIsValidGame() ? "l4d2_map_configs/" : "l4d_map_configs/"), sMap);
			}
		}

		delete alMaps;
	}

	if ((g_iConfigCreate & MT_CONFIG_GAMEMODE) && g_iConfigEnable == 1)
	{
		char sSMPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/%s", (bIsValidGame() ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"));
		CreateDirectory(sSMPath, 511);

		char sGameType[2049], sTypes[64][32];
		g_cvMTGameTypes.GetString(sGameType, sizeof(sGameType));
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

	if ((g_iConfigCreate & MT_CONFIG_DAY) && g_iConfigEnable == 1)
	{
		char sSMPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "data/mutant_tanks/daily_configs/");
		CreateDirectory(sSMPath, 511);

		char sWeekday[32];
		for (int iDay = 0; iDay <= 6; iDay++)
		{
			switch (iDay)
			{
				case 1: sWeekday = "monday";
				case 2: sWeekday = "tuesday";
				case 3: sWeekday = "wednesday";
				case 4: sWeekday = "thursday";
				case 5: sWeekday = "friday";
				case 6: sWeekday = "saturday";
				default: sWeekday = "sunday";
			}

			vCreateConfigFile("daily_configs/", sWeekday);
		}
	}

	if ((g_iConfigCreate & MT_CONFIG_COUNT) && g_iConfigEnable == 1)
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

	if ((g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_iConfigEnable == 1 && g_cvMTDifficulty != null)
	{
		char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));

		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/mutant_tanks/difficulty_configs/%s.cfg", sDifficulty);
		vLoadConfigs(sDifficultyConfig, 2);
		vPluginStatus();
		g_iFileTimeOld[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
	}

	if ((g_iConfigExecute & MT_CONFIG_MAP) && g_iConfigEnable == 1)
	{
		char sMap[64], sMapConfig[PLATFORM_MAX_PATH];
		GetCurrentMap(sMap, sizeof(sMap));

		BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), (bIsValidGame() ? "data/mutant_tanks/l4d2_map_configs/%s.cfg" : "data/mutant_tanks/l4d_map_configs/%s.cfg"), sMap);
		vLoadConfigs(sMapConfig, 2);
		vPluginStatus();
		g_iFileTimeOld[2] = GetFileTime(sMapConfig, FileTime_LastChange);
	}

	if ((g_iConfigExecute & MT_CONFIG_GAMEMODE) && g_iConfigEnable == 1)
	{
		char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
		g_cvMTGameMode.GetString(sMode, sizeof(sMode));

		BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), (bIsValidGame() ? "data/mutant_tanks/l4d2_gamemode_configs/%s.cfg" : "data/mutant_tanks/l4d_gamemode_configs/%s.cfg"), sMode);
		vLoadConfigs(sModeConfig, 2);
		vPluginStatus();
		g_iFileTimeOld[3] = GetFileTime(sModeConfig, FileTime_LastChange);
	}

	if ((g_iConfigExecute & MT_CONFIG_DAY) && g_iConfigEnable == 1)
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
		vLoadConfigs(sDayConfig, 2);
		vPluginStatus();
		g_iFileTimeOld[4] = GetFileTime(sDayConfig, FileTime_LastChange);
	}

	if ((g_iConfigExecute & MT_CONFIG_COUNT) && g_iConfigEnable == 1)
	{
		char sCountConfig[PLATFORM_MAX_PATH];

		BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/playercount_configs/%i.cfg", iGetPlayerCount());
		vLoadConfigs(sCountConfig, 2);
		vPluginStatus();
		g_iFileTimeOld[5] = GetFileTime(sCountConfig, FileTime_LastChange);
	}
}

public void OnMapEnd()
{
	vReset();

	if (g_alAdmins != null)
	{
		g_alAdmins.Clear();
		delete g_alAdmins;
	}
}

public void OnPluginEnd()
{
	vMultiTargetFilters(0);

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE))
		{
			vRemoveProps(iTank);
		}
	}

	Call_StartForward(g_gfPluginEndForward);
	Call_Finish();
}

public void OnAdminMenuReady(Handle topmenu)
{
	TopMenu tmMTMenu = TopMenu.FromHandle(topmenu);
	if (topmenu == g_tmMTMenu)
	{
		return;
	}

	g_tmMTMenu = tmMTMenu;

	TopMenuObject mt_commands = g_tmMTMenu.AddCategory("MutantTanks", iMTAdminMenuHandler);
	if (mt_commands != INVALID_TOPMENUOBJECT)
	{
		g_tmMTMenu.AddItem("sm_tank", vMutantTanksMenu, mt_commands, "sm_tank", ADMFLAG_ROOT);
		g_tmMTMenu.AddItem("sm_mt_info", vMTInfoMenu, mt_commands, "sm_mt_info", ADMFLAG_GENERIC);
	}
}

public int iMTAdminMenuHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayTitle, TopMenuAction_DisplayOption: Format(buffer, maxlength, "Mutant Tanks");
	}

	return 0;
}

public void vMutantTanksMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: Format(buffer, maxlength, "%T", "MTMenu", param);
		case TopMenuAction_SelectOption:
		{
			g_bAdminMenu[param] = true;

			vTankMenu(param, 0);
		}
	}
}

public void vMTInfoMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: Format(buffer, maxlength, "%T", "MTInfoMenu", param);
		case TopMenuAction_SelectOption:
		{
			g_bAdminMenu[param] = true;

			vInfoMenu(param, 0);
		}
	}
}

public Action cmdMTInfo(int client, int args)
{
	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vInfoMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vInfoMenu(int client, int item)
{
	Menu mInfoMenu = new Menu(iInfoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mInfoMenu.SetTitle("Mutant Tanks Information");
	mInfoMenu.AddItem("Status", "Status");
	mInfoMenu.AddItem("Details", "Details");
	mInfoMenu.AddItem("Human Support", "Human Support");
	Call_StartForward(g_gfDisplayMenuForward);
	Call_PushCell(mInfoMenu);
	Call_Finish();
	mInfoMenu.ExitBackButton = g_bAdminMenu[client];
	mInfoMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iInfoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if (g_bAdminMenu[param1])
			{
				g_bAdminMenu[param1] = false;

				if (param2 == MenuCancel_ExitBack && g_tmMTMenu != null)
				{
					g_tmMTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
			}
		}
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, !g_bPluginEnabled ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GeneralDetails");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanSupport[g_iTankType[param1]] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			Call_StartForward(g_gfMenuItemSelectedForward);
			Call_PushCell(param1);
			Call_PushString(sInfo);
			Call_Finish();

			if (param2 < 3 && bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				vInfoMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "MTInfoMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];
			switch (param2)
			{
				case 0:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public Action cmdMTList(int client, int args)
{
	if (!g_bPluginEnabled)
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		char sSteamID32[32], sSteam3ID[32];
		GetClientAuthId(client, AuthId_Steam2, sSteamID32, sizeof(sSteamID32));
		GetClientAuthId(client, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID));

		if (!CheckCommandAccess(client, "sm_tank", ADMFLAG_ROOT) && (g_iAllowDeveloper == 1 && !StrEqual(sSteamID32, "STEAM_1:1:48199803", false) && !StrEqual(sSteam3ID, "[U:1:96399607]", false)))
		{
			ReplyToCommand(client, "%s %t", MT_TAG2, "NoCommandAccess");

			return Plugin_Handled;
		}
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	for (int iPos = 0; iPos < MT_MAX_ABILITIES; iPos++)
	{
		g_bFound[iPos] = false;
	}

	char sSMPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sSMPath, sizeof(sSMPath), "plugins");
	ArrayList alPlugins = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	vListInstalledAbilities(client, alPlugins, sSMPath);

	return Plugin_Handled;
}

static void vListInstalledAbilities(int admin, ArrayList list, const char[] directory, bool mode = false)
{
	DirectoryListing dlList = OpenDirectory(directory);
	char sFilename[PLATFORM_MAX_PATH];
	bool bNewFile;
	while (dlList != null && dlList.GetNext(sFilename, sizeof(sFilename)))
	{
		if (!mode && StrContains(sFilename, ".smx", false) != -1)
		{
			list.PushString(sFilename);
		}

		if (StrContains(sFilename, ".smx", false) == -1 && !StrEqual(sFilename, "disabled", false) && !StrEqual(sFilename, ".") && !StrEqual(sFilename, ".."))
		{
			Format(sFilename, sizeof(sFilename), "%s/%s", directory, sFilename);
			vListInstalledAbilities(admin, list, sFilename, true);
		}
		else
		{
			int iFileCount;
			for (int iPos = 0; iPos < GetArraySize(list); iPos++)
			{
				char sFilename2[PLATFORM_MAX_PATH];
				list.GetString(iPos, sFilename2, sizeof(sFilename2));
				if (sFilename2[0] != '\0' && StrEqual(sFilename2, sFilename, false))
				{
					iFileCount++;
				}
			}

			if (iFileCount == 0 && StrContains(sFilename, ".smx", false) != -1)
			{
				list.PushString(sFilename);
			}
		}

		for (int iPos = 0; iPos < GetArraySize(list); iPos++)
		{
			char sFilename2[PLATFORM_MAX_PATH];
			list.GetString(iPos, sFilename2, sizeof(sFilename2));
			if (sFilename2[0] != '\0' && StrEqual(sFilename2, sFilename, false))
			{
				continue;
			}

			bNewFile = true;
		}
	}

	delete dlList;

	for (int iPos = 0; iPos < MT_MAX_ABILITIES; iPos++)
	{
		if (g_bFound[iPos])
		{
			continue;
		}

		for (int iPos2 = 0; iPos2 < GetArraySize(list); iPos2++)
		{
			char sFilename2[PLATFORM_MAX_PATH];
			list.GetString(iPos2, sFilename2, sizeof(sFilename2));
			if (StrEqual(sFilename2, g_sPluginFilenames[iPos], false))
			{
				g_bFound[iPos] = true;

				MT_PrintToChat(admin, "{yellow}%s{mint} is installed.", g_sPluginFilenames[iPos]);
			}
		}
	}

	if (!bNewFile)
	{
		list.Clear();
		delete list;
	}
}

public Action cmdTank(int client, int args)
{
	if (!g_bPluginEnabled)
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	char sType[32], sAmount[32], sMode[32];
	GetCmdArg(1, sType, sizeof(sType));
	int iType = StringToInt(sType);
	GetCmdArg(2, sAmount, sizeof(sAmount));
	int iAmount = StringToInt(sAmount);
	GetCmdArg(3, sMode, sizeof(sMode));
	int iMode = StringToInt(sMode);

	iType = iClamp(iType, g_iMinType, g_iMaxType);
	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vTankMenu(client, 0);
		}

		return Plugin_Handled;
	}

	if (iAmount == 0)
	{
		iAmount = 1;
	}

	if ((IsCharNumeric(sType[0]) && (iType < g_iMinType || iType > g_iMaxType)) || iAmount > 32 || iMode < 0 || iMode > 1 || args > 3)
	{
		ReplyToCommand(client, "%s Usage: sm_tank <type %i-%i> <amount: 1-32> <0: spawn at crosshair|1: spawn automatically>", MT_TAG2, g_iMinType, g_iMaxType);

		return Plugin_Handled;
	}

	if (IsCharNumeric(sType[0]) && (g_iTankEnabled[iType] == 0 || g_iMenuEnabled[iType] == 0 || !bIsTypeAvailable(iType, client)))
	{
		ReplyToCommand(client, "%s %s\x04 (Tank #%i)\x01 is disabled.", MT_TAG4, g_sTankName[iType], iType);

		return Plugin_Handled;
	}

	vTank(client, sType, false, iAmount, iMode);

	return Plugin_Handled;
}

public Action cmdTank2(int client, int args)
{
	if (!g_bPluginEnabled)
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	char sSteamID32[32], sSteam3ID[32];
	GetClientAuthId(client, AuthId_Steam2, sSteamID32, sizeof(sSteamID32));
	GetClientAuthId(client, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID));

	if (!CheckCommandAccess(client, "sm_tank", ADMFLAG_ROOT) && (g_iAllowDeveloper == 1 && !StrEqual(sSteamID32, "STEAM_1:1:48199803", false) && !StrEqual(sSteam3ID, "[U:1:96399607]", false)))
	{
		ReplyToCommand(client, "%s %t", MT_TAG2, "NoCommandAccess");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	char sType[32], sAmount[32], sMode[32];
	GetCmdArg(1, sType, sizeof(sType));
	int iType = StringToInt(sType);
	GetCmdArg(2, sAmount, sizeof(sAmount));
	int iAmount = StringToInt(sAmount);
	GetCmdArg(3, sMode, sizeof(sMode));
	int iMode = StringToInt(sMode);

	iType = iClamp(iType, g_iMinType, g_iMaxType);
	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vTankMenu(client, 0);
		}

		return Plugin_Handled;
	}

	if (iAmount == 0)
	{
		iAmount = 1;
	}

	if ((IsCharNumeric(sType[0]) && (iType < g_iMinType || iType > g_iMaxType)) || iAmount > 32 || iMode < 0 || iMode > 1 || args > 3)
	{
		ReplyToCommand(client, "%s Usage: sm_tank <type %i-%i> <amount: 1-32> <0: spawn at crosshair|1: spawn automatically>", MT_TAG2, g_iMinType, g_iMaxType);

		return Plugin_Handled;
	}

	if (IsCharNumeric(sType[0]) && (g_iTankEnabled[iType] == 0 || g_iMenuEnabled[iType] == 0 || !bIsTypeAvailable(iType, client)))
	{
		ReplyToCommand(client, "%s %s\x04 (Tank #%i)\x01 is disabled.", MT_TAG4, g_sTankName[iType], iType);

		return Plugin_Handled;
	}

	vTank(client, sType, false, iAmount, iMode);

	return Plugin_Handled;
}

public Action cmdMutantTank(int client, int args)
{
	if (!g_bPluginEnabled)
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (g_iMTMode == 1 && !CheckCommandAccess(client, "sm_tank", ADMFLAG_ROOT))
	{
		ReplyToCommand(client, "%s %t", MT_TAG2, "NoCommandAccess");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	char sType[32], sAmount[32], sMode[32];
	GetCmdArg(1, sType, sizeof(sType));
	int iType = StringToInt(sType);
	GetCmdArg(2, sAmount, sizeof(sAmount));
	int iAmount = StringToInt(sAmount);
	GetCmdArg(3, sMode, sizeof(sMode));
	int iMode = StringToInt(sMode);

	iType = iClamp(iType, g_iMinType, g_iMaxType);
	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
			case false: vTankMenu(client, 0);
		}

		return Plugin_Handled;
	}

	if (iAmount == 0)
	{
		iAmount = 1;
	}

	if ((IsCharNumeric(sType[0]) && (iType < g_iMinType || iType > g_iMaxType)) || iAmount > 32 || iMode < 0 || iMode > 1 || args > 3)
	{
		ReplyToCommand(client, "%s Usage: sm_tank <type %i-%i> <amount: 1-32> <0: spawn at crosshair|1: spawn automatically>", MT_TAG2, g_iMinType, g_iMaxType);

		return Plugin_Handled;
	}

	if (IsCharNumeric(sType[0]) && (g_iTankEnabled[iType] == 0 || g_iMenuEnabled[iType] == 0 || !bIsTypeAvailable(iType, client)))
	{
		ReplyToCommand(client, "%s %s\x04 (Tank #%i)\x01 is disabled.", MT_TAG4, g_sTankName[iType], iType);

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
			int iTypeCount, iTankTypes[MT_MAXTYPES + 1];
			for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
			{
				if (g_iTankEnabled[iIndex] == 0 || !bHasAdminAccess(admin, iIndex) || g_iMenuEnabled[iIndex] == 0 || !bIsTypeAvailable(iIndex, admin) || StrContains(g_sTankName[iIndex], type, false) == -1)
				{
					continue;
				}

				g_iType = iIndex;
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

					g_iType = iTankTypes[GetRandomInt(1, iTypeCount)];
				}
			}
		}
		default: g_iType = iClamp(iType, g_iMinType, g_iMaxType);
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
						case true: vSpawnTank(admin, g_iType, amount, mode);
						case false:
						{
							char sSteamID32[32], sSteam3ID[32];
							GetClientAuthId(admin, AuthId_Steam2, sSteamID32, sizeof(sSteamID32));
							GetClientAuthId(admin, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID));

							if ((GetClientButtons(admin) & IN_SPEED == IN_SPEED) && (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT) || (g_iAllowDeveloper == 1 && (StrEqual(sSteamID32, "STEAM_1:1:48199803", false) || StrEqual(sSteam3ID, "[U:1:96399607]", false)))))
							{
								vChangeTank(admin, amount, mode);
							}
							else
							{
								switch (g_bChanged[admin])
								{
									case true: MT_PrintToChat(admin, "%s %t", MT_TAG3, "HumanCooldown", g_iCooldown[admin]);
									case false:
									{
										vNewTankSettings(admin);
										vSetColor(admin, g_iType);

										switch (g_bNeedHealth[admin])
										{
											case true:
											{
												g_bNeedHealth[admin] = false;

												vTankSpawn(admin);
											}
											case false: vTankSpawn(admin, 5);
										}

										if (bIsTank(admin, MT_CHECK_FAKECLIENT))
										{
											vExternalView(admin, 1.5);
										}

										if (g_iMasterControl == 0 && (!CheckCommandAccess(admin, "mt_admin", ADMFLAG_ROOT) && (g_iAllowDeveloper == 1 && !StrEqual(sSteamID32, "STEAM_1:1:48199803", false) && !StrEqual(sSteam3ID, "[U:1:96399607]", false))))
										{
											g_iCooldown[admin] = g_iHumanCooldown;
											if (g_iCooldown[admin] > 0)
											{
												g_bChanged[admin] = true;

												CreateTimer(1.0, tTimerResetCooldown, GetClientOfUserId(admin), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
											}
										}
									}
								}
							}

							g_iType = 0;
						}
					}
				}
				case false: vSpawnTank(admin, g_iType, amount, mode);
			}
		}
		case false:
		{
			char sSteamID32[32], sSteam3ID[32];
			GetClientAuthId(admin, AuthId_Steam2, sSteamID32, sizeof(sSteamID32));
			GetClientAuthId(admin, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID));

			if (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT) || (g_iAllowDeveloper == 1 && (StrEqual(sSteamID32, "STEAM_1:1:48199803", false) || StrEqual(sSteam3ID, "[U:1:96399607]", false))))
			{
				vChangeTank(admin, amount, mode);
			}
			else
			{
				MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoCommandAccess");
			}
		}
	}
}

static void vChangeTank(int admin, int amount, int mode)
{
	int iTarget = GetClientAimTarget(admin, false);
	switch (bIsValidEntity(iTarget))
	{
		case true:
		{
			char sClassname[32];
			GetEntityClassname(iTarget, sClassname, sizeof(sClassname));
			if (bIsTank(iTarget) && StrEqual(sClassname, "player"))
			{
				vNewTankSettings(iTarget);
				vSetColor(iTarget, g_iType);
				vTankSpawn(iTarget, 5);

				if (bIsTank(iTarget, MT_CHECK_FAKECLIENT))
				{
					vExternalView(iTarget, 1.5);
				}

				g_iType = 0;
			}
			else
			{
				vSpawnTank(admin, g_iType, amount, mode);
			}
		}
		case false: vSpawnTank(admin, g_iType, amount, mode);
	}
}

static void vQueueTank(int admin, int type, bool mode = true)
{
	char sType[32];
	IntToString(type, sType, sizeof(sType));
	vTank(admin, sType, mode);
}

static void vSpawnTank(int admin, int type, int amount, int mode)
{
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
					vCheatCommand(admin, bIsValidGame() ? "z_spawn_old" : "z_spawn", sParameter);
					g_iType = type;
				}
				else if (iAmount == amount)
				{
					g_iType = 0;
				}
			}
		}
	}
}

static void vTankMenu(int admin, int item)
{
	Menu mTankMenu = new Menu(iTankMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display);
	mTankMenu.SetTitle("Mutant Tanks Menu");

	if (g_iTankType[admin] > 0)
	{
		mTankMenu.AddItem("Default Tank", "Default Tank");
	}

	for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
	{
		if (g_iTankEnabled[iIndex] == 0 || !bHasAdminAccess(admin, iIndex) || g_iMenuEnabled[iIndex] == 0 || !bIsTypeAvailable(iIndex, admin))
		{
			continue;
		}

		char sMenuItem[46];
		Format(sMenuItem, sizeof(sMenuItem), "%s (Tank #%i)", g_sTankName[iIndex], iIndex);
		mTankMenu.AddItem(g_sTankName[iIndex], sMenuItem);
	}

	mTankMenu.ExitBackButton = g_bAdminMenu[admin];
	mTankMenu.DisplayAt(admin, item, MENU_TIME_FOREVER);
}

public int iTankMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Cancel:
		{
			if (g_bAdminMenu[param1])
			{
				g_bAdminMenu[param1] = false;

				if (param2 == MenuCancel_ExitBack && g_tmMTMenu != null)
				{
					g_tmMTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
			}
		}
		case MenuAction_Select:
		{
			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			switch (StrEqual(sInfo, "Default Tank", false))
			{
				case true: vQueueTank(param1, g_iTankType[param1], false);
				case false:
				{
					for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
					{
						if (g_iTankEnabled[iIndex] == 0 || !bHasAdminAccess(param1, iIndex) || g_iMenuEnabled[iIndex] == 0 || !bIsTypeAvailable(iIndex, param1))
						{
							continue;
						}

						if (StrEqual(sInfo, g_sTankName[iIndex], false))
						{
							vQueueTank(param1, iIndex, false);

							break;
						}
					}
				}
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				vTankMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "MTMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
	}

	return 0;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (g_bPluginEnabled && StrEqual(classname, "tank_rock"))
	{
		CreateTimer(0.1, tTimerRockThrow, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnEntityDestroyed(int entity)
{
	if (g_bPluginEnabled && bIsValidEntity(entity))
	{
		char sClassname[32];
		GetEntityClassname(entity, sClassname, sizeof(sClassname));
		if (StrEqual(sClassname, "tank_rock"))
		{
			int iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
			if (iThrower == 0 || !bIsTankAllowed(iThrower) || !bHasAdminAccess(iThrower) || g_iTankEnabled[g_iTankType[iThrower]] == 0)
			{
				return;
			}

			Call_StartForward(g_gfRockBreakForward);
			Call_PushCell(iThrower);
			Call_PushCell(entity);
			Call_Finish();
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!g_bPluginEnabled && !bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		return Plugin_Continue;
	}

	for (int iBit = 0; iBit < 26; iBit++)
	{
		int iButton = (1 << iBit);
		if ((buttons & iButton))
		{
			if (!(g_iLastButtons[client] & iButton))
			{
				Call_StartForward(g_gfButtonPressedForward);
				Call_PushCell(client);
				Call_PushCell(iButton);
				Call_Finish();
			}
		}
		else if ((g_iLastButtons[client] & iButton))
		{
			Call_StartForward(g_gfButtonReleasedForward);
			Call_PushCell(client);
			Call_PushCell(iButton);
			Call_Finish();
		}
	}

	g_iLastButtons[client] = buttons;

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_bPluginEnabled && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (bIsTankAllowed(attacker) && bHasAdminAccess(attacker) && bIsSurvivor(victim) && !bIsAdminImmune(victim, attacker))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") && (g_flClawDamage[g_iTankType[attacker]] >= 0.0 || (bIsTank(victim, MT_CHECK_FAKECLIENT) && g_flClawDamage2[attacker] > 0.0)))
			{
				damage = (bIsTank(victim, MT_CHECK_FAKECLIENT) && g_flClawDamage2[attacker] >= -1.0) ? g_flClawDamage2[attacker] : g_flClawDamage[g_iTankType[attacker]];

				return Plugin_Changed;
			}
			else if (StrEqual(sClassname, "tank_rock") && (g_flRockDamage[g_iTankType[attacker]] >= 0.0 || (bIsTank(victim, MT_CHECK_FAKECLIENT) && g_flRockDamage2[attacker] > 0.0)))
			{
				damage = (bIsTank(victim, MT_CHECK_FAKECLIENT) && g_flRockDamage2[attacker] >= -1.0) ? g_flRockDamage2[attacker] : g_flRockDamage[g_iTankType[attacker]];

				return Plugin_Changed;
			}
		}
		else if (bIsInfected(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE))
		{
			if (bIsTankAllowed(victim) && bHasAdminAccess(victim))
			{
				if ((damagetype & DMG_BULLET && (g_iBulletImmunity[g_iTankType[victim]] == 1 || (bIsTank(victim, MT_CHECK_FAKECLIENT) && g_iBulletImmunity2[victim] == 1))) ||
					((damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA) && (g_iExplosiveImmunity[g_iTankType[victim]] == 1 || (bIsTank(victim, MT_CHECK_FAKECLIENT) && g_iExplosiveImmunity2[victim] == 1))) ||
					(damagetype & DMG_BURN && (g_iFireImmunity[g_iTankType[victim]] == 1 || (bIsTank(victim, MT_CHECK_FAKECLIENT) && g_iFireImmunity2[victim] == 1))) ||
					((damagetype & DMG_SLASH || damagetype & DMG_CLUB) && (g_iMeleeImmunity[g_iTankType[victim]] == 1 || (bIsTank(victim, MT_CHECK_FAKECLIENT) && g_iMeleeImmunity2[victim] == 1))))
				{
					return Plugin_Handled;
				}
			}

			if (attacker == victim || StrEqual(sClassname, "tank_rock") ||
				((damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA || damagetype & DMG_BURN) && bIsTank(attacker)))
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public Action SetTransmit(int entity, int client)
{
	int iOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (MT_IsCorePluginEnabled() && iOwner == client && !bIsTankThirdPerson(client) && !g_bThirdPerson[client])
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

static void vLoadConfigs(const char[] savepath, int mode)
{
	g_iConfigMode = mode;
	strcopy(g_sUsedPath, sizeof(g_sUsedPath), savepath);

	SMCParser smcLoader = new SMCParser();
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

 		PrintToServer("%s Error while parsing \"%s\" file. Error Message: %s.", MT_TAG, savepath, sSmcError);
		LogError("Error while parsing \"%s\" file. Error Message: %s.", savepath, sSmcError);
	}
	
	delete smcLoader;
}

public void SMCParseStart(SMCParser smc)
{
	g_csState = ConfigState_None;
	g_iIgnoreLevel = 0;
	g_sCurrentSection[0] = '\0';
	g_sCurrentSubSection[0] = '\0';

	if (g_iConfigMode < 2)
	{
		g_iPluginEnabled = 0;
		g_iAnnounceArrival = 31;
		g_iAnnounceDeath = 1;
		g_iBaseHealth = 0;
		g_iDeathRevert = 0;
		g_iDetectPlugins = 0;
		g_iDisplayHealth = 7;
		g_iDisplayHealthType = 1;
		g_sHealthCharacters = "|,-";
		g_iFinalesOnly = 0;
		g_iMultiHealth = 0;
		g_iMinType = 1;
		g_iMaxType = MT_MAXTYPES;
		g_iAllowDeveloper = 1;
		g_iAccessFlags = 0;
		g_iImmunityFlags = 0;
		g_iHumanCooldown = 600;
		g_iMasterControl = 0;
		g_iMTMode = 1;
		g_iRegularAmount = 2;
		g_flRegularInterval = 300.0;
		g_iRegularMode = 0;
		g_iRegularWave = 0;
		g_iGameModeTypes = 0;
		g_sEnabledGameModes[0] = '\0';
		g_sDisabledGameModes[0] = '\0';
		g_iConfigEnable = 0;
		g_iConfigCreate = 0;
		g_iConfigExecute = 0;

		for (int iPos = 0; iPos < 3; iPos++)
		{
			g_iFinaleWave[iPos] = iPos + 2;
		}

		for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
		{
			Format(g_sTankName[iIndex], sizeof(g_sTankName[]), "Tank #%i", iIndex);
			g_iTankEnabled[iIndex] = 0;
			g_flTankChance[iIndex] = 100.0;
			g_iTankNote[iIndex] = 0;
			g_iSpawnEnabled[iIndex] = 1;
			g_iMenuEnabled[iIndex] = 1;
			g_iAnnounceArrival2[iIndex] = 0;
			g_iAnnounceDeath2[iIndex] = 0;
			g_iDeathRevert2[iIndex] = 0;
			g_iDetectPlugins2[iIndex] = 0;
			g_iDisplayHealth2[iIndex] = 0;
			g_iDisplayHealthType2[iIndex] = 0;
			g_sHealthCharacters2[iIndex][0] = '\0';
			g_iMultiHealth2[iIndex] = 0;
			g_iHumanSupport[iIndex] = 0;
			g_iGlowEnabled[iIndex] = 0;
			g_iAccessFlags2[iIndex] = 0;
			g_iImmunityFlags2[iIndex] = 0;
			g_iTypeLimit[iIndex] = 32;
			g_iFinaleTank[iIndex] = 0;
			g_iBossHealth[iIndex][0] = 5000;
			g_iBossHealth[iIndex][1] = 2500;
			g_iBossHealth[iIndex][2] = 1500;
			g_iBossHealth[iIndex][3] = 1000;
			g_iBossStages[iIndex] = 4;
			g_iRandomTank[iIndex] = 1;
			g_flRandomInterval[iIndex] = 5.0;
			g_flTransformDelay[iIndex] = 10.0;
			g_flTransformDuration[iIndex] = 10.0;
			g_iSpawnMode[iIndex] = 0;
			g_iPropsAttached[iIndex] = 62;
			g_iBodyEffects[iIndex] = 0;
			g_iRockEffects[iIndex] = 0;
			g_flClawDamage[iIndex] = -1.0;
			g_iExtraHealth[iIndex] = 0;
			g_flRockDamage[iIndex] = -1.0;
			g_flRunSpeed[iIndex] = -1.0;
			g_flThrowInterval[iIndex] = -1.0;
			g_iBulletImmunity[iIndex] = 0;
			g_iExplosiveImmunity[iIndex] = 0;
			g_iFireImmunity[iIndex] = 0;
			g_iMeleeImmunity[iIndex] = 0;

			for (int iPos = 0; iPos < MT_MAX_ABILITIES; iPos++)
			{
				g_bAbilityFound[iIndex][iPos] = false;
			}

			for (int iPos = 0; iPos < 10; iPos++)
			{
				g_iTransformType[iIndex][iPos] = iPos + 1;

				if (iPos < 6)
				{
					g_flPropsChance[iIndex][iPos] = 33.3;
				}

				if (iPos < 4)
				{
					g_iSkinColor[iIndex][iPos] = 255;
					g_iBossType[iIndex][iPos] = iPos + 2;
					g_iLightColor[iIndex][iPos] = 255;
					g_iOzTankColor[iIndex][iPos] = 255;
					g_iFlameColor[iIndex][iPos] = 255;
					g_iRockColor[iIndex][iPos] = 255;
					g_iTireColor[iIndex][iPos] = 255;
				}

				if (iPos < 3)
				{
					g_iGlowColor[iIndex][iPos] = 255;
				}
			}
		}

		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
			{
				g_sTankName2[iPlayer][0] = '\0';
				g_iAnnounceArrival3[iPlayer] = 0;
				g_iAnnounceDeath3[iPlayer] = 0;
				g_iDeathRevert3[iPlayer] = 0;
				g_iDetectPlugins3[iPlayer] = 0;
				g_iDisplayHealth3[iPlayer] = 0;
				g_iDisplayHealthType3[iPlayer] = 0;
				g_sHealthCharacters3[iPlayer][0] = '\0';
				g_iMultiHealth3[iPlayer] = 0;
				g_iGlowEnabled2[iPlayer] = 0;
				g_iFavoriteType[iPlayer] = 0;
				g_iAccessFlags3[iPlayer] = 0;
				g_iImmunityFlags3[iPlayer] = 0;
				g_iBossHealth2[iPlayer][0] = 0;
				g_iBossHealth2[iPlayer][1] = 0;
				g_iBossHealth2[iPlayer][2] = 0;
				g_iBossHealth2[iPlayer][3] = 0;
				g_iBossStages2[iPlayer] = 0;
				g_iRandomTank2[iPlayer] = 0;
				g_flRandomInterval2[iPlayer] = 0.0;
				g_flTransformDelay2[iPlayer] = 0.0;
				g_flTransformDuration2[iPlayer] = 0.0;
				g_iPropsAttached2[iPlayer] = 0;
				g_iBodyEffects2[iPlayer] = 0;
				g_iRockEffects2[iPlayer] = 0;
				g_flClawDamage2[iPlayer] = -2.0;
				g_iExtraHealth2[iPlayer] = 0;
				g_flRockDamage2[iPlayer] = -2.0;
				g_flRunSpeed2[iPlayer] = -2.0;
				g_flThrowInterval2[iPlayer] = -2.0;
				g_iBulletImmunity2[iPlayer] = 0;
				g_iExplosiveImmunity2[iPlayer] = 0;
				g_iFireImmunity2[iPlayer] = 0;
				g_iMeleeImmunity2[iPlayer] = 0;

				for (int iPos = 0; iPos < 10; iPos++)
				{
					g_iTransformType2[iPlayer][iPos] = 0;

					if (iPos < 6)
					{
						g_flPropsChance2[iPlayer][iPos] = 0.0;
					}

					if (iPos < 4)
					{
						g_iSkinColor2[iPlayer][iPos] = -2;
						g_iBossType2[iPlayer][iPos] = iPos + 2;
						g_iLightColor2[iPlayer][iPos] = -2;
						g_iOzTankColor2[iPlayer][iPos] = -2;
						g_iFlameColor2[iPlayer][iPos] = -2;
						g_iRockColor2[iPlayer][iPos] = -2;
						g_iTireColor2[iPlayer][iPos] = -2;
					}

					if (iPos < 3)
					{
						g_iGlowColor2[iPlayer][iPos] = -2;
					}
				}

				for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
				{
					g_iAccessFlags4[iIndex][iPlayer] = 0;
					g_iImmunityFlags4[iIndex][iPlayer] = 0;
				}
			}
		}

		if (g_alAdmins == null)
		{
			g_alAdmins = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
		}

		Call_StartForward(g_gfConfigsLoadForward);
		Call_Finish();
	}
}

public SMCResult SMCNewSection(SMCParser smc, const char[] name, bool opt_quotes)
{
	if (g_iIgnoreLevel)
	{
		g_iIgnoreLevel++;

		return SMCParse_Continue;
	}

	if (g_csState == ConfigState_None)
	{
		if (StrEqual(name, "MutantTanks", false) || StrEqual(name, "Mutant Tanks", false) || StrEqual(name, "Mutant_Tanks", false) || StrEqual(name, "MT", false))
		{
			g_csState = ConfigState_Start;
		}
		else
		{
			g_iIgnoreLevel++;
		}
	}
	else if (g_csState == ConfigState_Start)
	{
		if (StrEqual(name, "PluginSettings", false) || StrEqual(name, "Plugin Settings", false) || StrEqual(name, "Plugin_Settings", false) || StrEqual(name, "settings", false))
		{
			g_csState = ConfigState_Settings;

			strcopy(g_sCurrentSection, sizeof(g_sCurrentSection), name);
		}
		else if (StrContains(name, "Tank#", false) == 0 || StrContains(name, "Tank #", false) == 0 || StrContains(name, "Tank_#", false) == 0 || StrContains(name, "Tank", false) == 0 || name[0] == '#' || IsCharNumeric(name[0]))
		{
			for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
			{
				char sTankName[8][33];
				Format(sTankName[0], sizeof(sTankName[]), "Tank#%i", iIndex);
				Format(sTankName[1], sizeof(sTankName[]), "Tank #%i", iIndex);
				Format(sTankName[2], sizeof(sTankName[]), "Tank_#%i", iIndex);
				Format(sTankName[3], sizeof(sTankName[]), "Tank%i", iIndex);
				Format(sTankName[4], sizeof(sTankName[]), "Tank %i", iIndex);
				Format(sTankName[5], sizeof(sTankName[]), "Tank_%i", iIndex);
				Format(sTankName[6], sizeof(sTankName[]), "#%i", iIndex);
				Format(sTankName[7], sizeof(sTankName[]), "%i", iIndex);

				for (int iType = 0; iType < 8; iType++)
				{
					if (StrEqual(name, sTankName[iType], false))
					{
						g_csState = ConfigState_Type;

						strcopy(g_sCurrentSection, sizeof(g_sCurrentSection), name);
					}
				}
			}
		}
		else if (StrContains(name, "STEAM_", false) == 0 || strncmp("0:", name, 2) == 0 || strncmp("1:", name, 2) == 0 || (!strncmp(name, "[U:", 3) && name[strlen(name) - 1] == ']'))
		{
			g_csState = ConfigState_Admin;

			strcopy(g_sCurrentSection, sizeof(g_sCurrentSection), name);

			if (GetArraySize(g_alAdmins) > 0)
			{
				for (int iPos = 0; iPos < GetArraySize(g_alAdmins); iPos++)
				{
					char sAdmin[32];
					g_alAdmins.GetString(iPos, sAdmin, sizeof(sAdmin));
					if (StrEqual(sAdmin, name, false))
					{
						continue;
					}

					g_alAdmins.PushString(name);
				}
			}
			else
			{
				g_alAdmins.PushString(name);
			}
		}
		else
		{
			g_iIgnoreLevel++;
		}
	}
	else if (g_csState == ConfigState_Settings || g_csState == ConfigState_Type || g_csState == ConfigState_Admin)
	{
		g_csState = ConfigState_Specific;

		strcopy(g_sCurrentSubSection, sizeof(g_sCurrentSubSection), name);
	}
	else
	{
		g_iIgnoreLevel++;
	}

	return SMCParse_Continue;
}

public SMCResult SMCKeyValues(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	if (g_iIgnoreLevel)
	{
		return SMCParse_Continue;
	}

	if (g_csState == ConfigState_Specific)
	{
		if (g_iConfigMode < 3 && (StrEqual(g_sCurrentSection, "PluginSettings", false) || StrEqual(g_sCurrentSection, "Plugin Settings", false) || StrEqual(g_sCurrentSection, "Plugin_Settings", false) || StrEqual(g_sCurrentSection, "settings", false)))
		{
			g_iPluginEnabled = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "PluginEnabled", "Plugin Enabled", "Plugin_Enabled", "enabled", g_iPluginEnabled, value, 0, 1);
			g_iAnnounceArrival = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_iAnnounceArrival, value, 0, 31);
			g_iAnnounceDeath = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_iAnnounceDeath, value, 0, 1);
			g_iBaseHealth = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "BaseHealth", "Base Health", "Base_Health", "health", g_iBaseHealth, value, 0, MT_MAXHEALTH);
			g_iDeathRevert = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_iDeathRevert, value, 0, 1);
			g_iDetectPlugins = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DetectPlugins", "Detect Plugins", "Detect_Plugins", "detect", g_iDetectPlugins, value, 0, 1);
			g_iDisplayHealth = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_iDisplayHealth, value, 0, 7);
			g_iDisplayHealthType = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_iDisplayHealthType, value, 0, 2);
			g_iFinalesOnly = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "FinalesOnly", "Finales Only", "Finales_Only", "finale", g_iFinalesOnly, value, 0, 1);
			g_iMultiHealth = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_iMultiHealth, value, 0, 3);
			g_iHumanCooldown = iGetValue(g_sCurrentSubSection, "HumanSupport", "Human Support", "Human_Support", "human", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "cooldown", g_iHumanCooldown, value, 0, 9999999999);
			g_iMasterControl = iGetValue(g_sCurrentSubSection, "HumanSupport", "Human Support", "Human_Support", "human", key, "MasterControl", "Master Control", "Master_Control", "master", g_iMasterControl, value, 0, 1);
			g_iMTMode = iGetValue(g_sCurrentSubSection, "HumanSupport", "Human Support", "Human_Support", "human", key, "SpawnMode", "Spawn Mode", "Spawn_Mode", "spawnmode", g_iMTMode, value, 0, 1);
			g_iRegularAmount = iGetValue(g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularAmount", "Regular Amount", "Regular_Amount", "regamount", g_iRegularAmount, value, 1, 64);
			g_flRegularInterval = flGetValue(g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularInterval", "Regular Interval", "Regular_Interval", "reginterval", g_flRegularInterval, value, 0.1, 9999999999.0);
			g_iRegularMode = iGetValue(g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularMode", "Regular Mode", "Regular_Mode", "regmode", g_iRegularMode, value, 0, 1);
			g_iRegularType = iGetValue(g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularType", "Regular Type", "Regular_Type", "regtype", g_iRegularType, value, 0, g_iMaxType);
			g_iRegularWave = iGetValue(g_sCurrentSubSection, "Waves", "Waves", "Waves", "Waves", key, "RegularWave", "Regular Wave", "Regular_Wave", "regwave", g_iRegularWave, value, 0, 1);

			if (StrEqual(g_sCurrentSubSection, "General", false) && value[0] != '\0')
			{
				if (StrEqual(key, "HealthCharacters", false) || StrEqual(key, "Health Characters", false) || StrEqual(key, "Health_Characters", false) || StrEqual(key, "hpchars", false))
				{
					strcopy(g_sHealthCharacters, sizeof(g_sHealthCharacters), value);
				}
				else if (StrEqual(key, "TypeRange", false) || StrEqual(key, "Type Range", false) || StrEqual(key, "Type_Range", false) || StrEqual(key, "types", false))
				{
					char sRange[2][5], sValue[10];
					strcopy(sValue, sizeof(sValue), value);
					ReplaceString(sValue, sizeof(sValue), " ", "");
					ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

					g_iMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 1, MT_MAXTYPES) : g_iMinType;
					g_iMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 1, MT_MAXTYPES) : g_iMaxType;
				}
			}

			if ((StrEqual(g_sCurrentSubSection, "Administration", false) || StrEqual(g_sCurrentSubSection, "admin", false)) && value[0] != '\0')
			{
				g_iAllowDeveloper = iGetValue(g_sCurrentSubSection, "Administration", "Administration", "Administration", "admin", key, "AllowDeveloper", "Allow Developer", "Allow_Developer", "developer", g_iAllowDeveloper, value, 0, 1);

				if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
				{
					g_iAccessFlags = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags;
				}
				else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
				{
					g_iImmunityFlags = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags;
				}
			}

			if (StrEqual(g_sCurrentSubSection, "Waves", false) && value[0] != '\0')
			{
				char sSet[3][5], sValue[15];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

				if (StrEqual(key, "FinaleTypes", false) || StrEqual(key, "Finale Types", false) || StrEqual(key, "Finale_Types", false) || StrEqual(key, "fintypes", false))
				{
					for (int iPos = 0; iPos < 3; iPos++)
					{
						if (sSet[iPos][0] == '\0')
						{
							continue;
						}

						g_iFinaleType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, g_iMaxType) : g_iFinaleType[iPos];
					}
				}
				else if (StrEqual(key, "FinaleWaves", false) || StrEqual(key, "Finale Waves", false) || StrEqual(key, "Finale_Waves", false) || StrEqual(key, "finwaves", false))
				{
					for (int iPos = 0; iPos < 3; iPos++)
					{
						if (sSet[iPos][0] == '\0')
						{
							continue;
						}

						g_iFinaleWave[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, 64) : g_iFinaleType[iPos];
					}
				}
			}

			if (g_iConfigMode < 2)
			{
				g_iGameModeTypes = iGetValue(g_sCurrentSubSection, "GameModes", "Game Modes", "Game_Modes", "modes", key, "GameModeTypes", "Game Mode Types", "Game_Mode_Types", "types", g_iGameModeTypes, value, 0, 15);
				g_iConfigEnable = iGetValue(g_sCurrentSubSection, "Custom", "Custom", "Custom", "Custom", key, "EnableCustomConfigs", "Enable Custom Configs", "Enable_Custom_Configs", "enabled", g_iConfigEnable, value, 0, 1);
				g_iConfigCreate = iGetValue(g_sCurrentSubSection, "Custom", "Custom", "Custom", "Custom", key, "CreateConfigTypes", "Create Config Types", "Create_Config_Types", "create", g_iConfigCreate, value, 0, 31);
				g_iConfigExecute = iGetValue(g_sCurrentSubSection, "Custom", "Custom", "Custom", "Custom", key, "ExecuteConfigTypes", "Execute Config Types", "Execute_Config_Types", "execute", g_iConfigExecute, value, 0, 31);

				if (StrEqual(g_sCurrentSubSection, "GameModes", false) || StrEqual(g_sCurrentSubSection, "Game Modes", false) || StrEqual(g_sCurrentSubSection, "Game_Modes", false) || StrEqual(g_sCurrentSubSection, "modes", false))
				{
					if (StrEqual(key, "EnabledGameModes", false) || StrEqual(key, "Enabled Game Modes", false) || StrEqual(key, "Enabled_Game_Modes", false) || StrEqual(key, "enabled", false))
					{
						strcopy(g_sEnabledGameModes, sizeof(g_sEnabledGameModes), value[0] == '\0' ? "" : value);
					}
					else if (StrEqual(key, "DisabledGameModes", false) || StrEqual(key, "Disabled Game Modes", false) || StrEqual(key, "Disabled_Game_Modes", false) || StrEqual(key, "disabled", false))
					{
						strcopy(g_sDisabledGameModes, sizeof(g_sDisabledGameModes), value[0] == '\0' ? "" : value);
					}
				}
			}

			Call_StartForward(g_gfConfigsLoadedForward);
			Call_PushString(g_sCurrentSubSection);
			Call_PushString(key);
			Call_PushString(value);
			Call_PushCell(0);
			Call_PushCell(-1);
			Call_Finish();
		}
		else if (g_iConfigMode < 3 && (StrContains(g_sCurrentSection, "Tank#", false) == 0 || StrContains(g_sCurrentSection, "Tank #", false) == 0 || StrContains(g_sCurrentSection, "Tank_#", false) == 0 || StrContains(g_sCurrentSection, "Tank", false) == 0 || g_sCurrentSection[0] == '#' || IsCharNumeric(g_sCurrentSection[0])))
		{
			for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
			{
				char sTankName[8][33];
				Format(sTankName[0], sizeof(sTankName[]), "Tank#%i", iIndex);
				Format(sTankName[1], sizeof(sTankName[]), "Tank #%i", iIndex);
				Format(sTankName[2], sizeof(sTankName[]), "Tank_#%i", iIndex);
				Format(sTankName[3], sizeof(sTankName[]), "Tank%i", iIndex);
				Format(sTankName[4], sizeof(sTankName[]), "Tank %i", iIndex);
				Format(sTankName[5], sizeof(sTankName[]), "Tank_%i", iIndex);
				Format(sTankName[6], sizeof(sTankName[]), "#%i", iIndex);
				Format(sTankName[7], sizeof(sTankName[]), "%i", iIndex);

				for (int iType = 0; iType < 8; iType++)
				{
					if (StrEqual(g_sCurrentSection, sTankName[iType], false))
					{
						g_iTankEnabled[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "TankEnabled", "Tank Enabled", "Tank_Enabled", "enabled", g_iTankEnabled[iIndex], value, 0, 1);
						g_flTankChance[iIndex] = flGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "TankChance", "Tank Chance", "Tank_Chance", "chance", g_flTankChance[iIndex], value, 0.0, 100.0);
						g_iTankNote[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "TankNote", "Tank Note", "Tank_Note", "note", g_iTankNote[iIndex], value, 0, 1);
						g_iSpawnEnabled[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "SpawnEnabled", "Spawn Enabled", "Spawn_Enabled", "spawn", g_iSpawnEnabled[iIndex], value, 0, 1);
						g_iMenuEnabled[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "MenuEnabled", "Menu Enabled", "Menu_Enabled", "menu", g_iMenuEnabled[iIndex], value, 0, 1);
						g_iAnnounceArrival2[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_iAnnounceArrival2[iIndex], value, 0, 31);
						g_iAnnounceDeath2[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_iAnnounceDeath2[iIndex], value, 0, 1);
						g_iDeathRevert2[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_iDeathRevert2[iIndex], value, 0, 1);
						g_iDetectPlugins2[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DetectPlugins", "Detect Plugins", "Detect_Plugins", "detect", g_iDetectPlugins2[iIndex], value, 0, 1);
						g_iDisplayHealth2[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_iDisplayHealth2[iIndex], value, 0, 7);
						g_iDisplayHealthType2[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_iDisplayHealthType2[iIndex], value, 0, 2);
						g_iMultiHealth2[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_iMultiHealth2[iIndex], value, 0, 3);
						g_iHumanSupport[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "HumanSupport", "Human Support", "Human_Support", "human", g_iHumanSupport[iIndex], value, 0, 1);
						g_iGlowEnabled[iIndex] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "glow", g_iGlowEnabled[iIndex], value, 0, 1);
						g_iTypeLimit[iIndex] = iGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TypeLimit", "Type Limit", "Type_Limit", "limit", g_iTypeLimit[iIndex], value, 0, 64);
						g_iFinaleTank[iIndex] = iGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "FinaleTank", "Finale Tank", "Finale_Tank", "finale", g_iFinaleTank[iIndex], value, 0, 1);
						g_iBossStages[iIndex] = iGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "BossStages", "Boss Stages", "Boss_Stages", "stages", g_iBossStages[iIndex], value, 1, 4);
						g_iRandomTank[iIndex] = iGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "RandomTank", "Random Tank", "Random_Tank", "random", g_iRandomTank[iIndex], value, 0, 1);
						g_flRandomInterval[iIndex] = flGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "RandomInterval", "Random Interval", "Random_Interval", "randinterval", g_flRandomInterval[iIndex], value, 0.1, 9999999999.0);
						g_flTransformDelay[iIndex] = flGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TransformDelay", "Transform Delay", "Transform_Delay", "transdelay", g_flTransformDelay[iIndex], value, 0.1, 9999999999.0);
						g_flTransformDuration[iIndex] = flGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TransformDuration", "Transform Duration", "Transform_Duration", "transduration", g_flTransformDuration[iIndex], value, 0.1, 9999999999.0);
						g_iSpawnMode[iIndex] = iGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "SpawnMode", "Spawn Mode", "Spawn_Mode", "mode", g_iSpawnMode[iIndex], value, 0, 3);
						g_iPropsAttached[iIndex] = iGetValue(g_sCurrentSubSection, "Props", "Props", "Props", "Props", key, "PropsAttached", "Props Attached", "Props_Attached", "attached", g_iPropsAttached[iIndex], value, 0, 63);
						g_iBodyEffects[iIndex] = iGetValue(g_sCurrentSubSection, "Particles", "Particles", "Particles", "Particles", key, "BodyEffects", "Body Effects", "Body_Effects", "body", g_iBodyEffects[iIndex], value, 0, 127);
						g_iRockEffects[iIndex] = iGetValue(g_sCurrentSubSection, "Particles", "Particles", "Particles", "Particles", key, "RockEffects", "Rock Effects", "Rock_Effects", "rock", g_iRockEffects[iIndex], value, 0, 15);
						g_flClawDamage[iIndex] = flGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_flClawDamage[iIndex], value, -1.0, 9999999999.0);
						g_iExtraHealth[iIndex] = iGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ExtraHealth", "Extra Health", "Extra_Health", "health", g_iExtraHealth[iIndex], value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
						g_flRockDamage[iIndex] = flGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_flRockDamage[iIndex], value, -1.0, 9999999999.0);
						g_flRunSpeed[iIndex] = flGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_flRunSpeed[iIndex], value, -1.0, 3.0);
						g_flThrowInterval[iIndex] = flGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_flThrowInterval[iIndex], value, -1.0, 9999999999.0);
						g_iBulletImmunity[iIndex] = iGetValue(g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "Immunities", key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_iBulletImmunity[iIndex], value, 0, 1);
						g_iExplosiveImmunity[iIndex] = iGetValue(g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "Immunities", key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_iExplosiveImmunity[iIndex], value, 0, 1);
						g_iFireImmunity[iIndex] = iGetValue(g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "Immunities", key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_iFireImmunity[iIndex], value, 0, 1);
						g_iMeleeImmunity[iIndex] = iGetValue(g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "Immunities", key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_iMeleeImmunity[iIndex], value, 0, 1);

						if (StrEqual(g_sCurrentSubSection, "General", false) && value[0] != '\0')
						{
							if (StrEqual(key, "TankName", false) || StrEqual(key, "Tank Name", false) || StrEqual(key, "Tank_Name", false) || StrEqual(key, "name", false))
							{
								strcopy(g_sTankName[iIndex], sizeof(g_sTankName[]), value);
							}
							else if (StrEqual(key, "HealthCharacters", false) || StrEqual(key, "Health Characters", false) || StrEqual(key, "Health_Characters", false) || StrEqual(key, "hpchars", false))
							{
								strcopy(g_sHealthCharacters2[iIndex], sizeof(g_sHealthCharacters2[]), value);
							}
							else if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
							{
								char sSet[4][4], sValue[16];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < 4; iPos++)
								{
									if (sSet[iPos][0] == '\0')
									{
										continue;
									}

									g_iSkinColor[iIndex][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
								}
							}
							else if (StrEqual(key, "GlowColor", false) || StrEqual(key, "Glow Color", false) || StrEqual(key, "Glow_Color", false))
							{
								char sSet[3][4], sValue[12];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < 3; iPos++)
								{
									if (sSet[iPos][0] == '\0')
									{
										continue;
									}

									g_iGlowColor[iIndex][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
								}
							}
						}

						if ((StrEqual(g_sCurrentSubSection, "Administration", false) || StrEqual(g_sCurrentSubSection, "admin", false)) && value[0] != '\0')
						{
							if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
							{
								g_iAccessFlags2[iIndex] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[iIndex];
							}
							else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
							{
								g_iImmunityFlags2[iIndex] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags2[iIndex];
							}
						}

						if (StrEqual(g_sCurrentSubSection, "Spawn", false) && value[0] != '\0')
						{
							if (StrEqual(key, "TransformTypes", false) || StrEqual(key, "Transform Types", false) || StrEqual(key, "Transform_Types", false) || StrEqual(key, "transtypes", false))
							{
								char sSet[10][5], sValue[50];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < 10; iPos++)
								{
									if (sSet[iPos][0] == '\0')
									{
										continue;
									}

									g_iTransformType[iIndex][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_iMinType, g_iMaxType) : g_iTransformType[iIndex][iPos];
								}
							}
							else
							{
								char sSet[4][6], sValue[24];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < 4; iPos++)
								{
									if (sSet[iPos][0] == '\0')
									{
										continue;
									}

									if (StrEqual(key, "BossHealthStages", false) || StrEqual(key, "Boss Health Stages", false) || StrEqual(key, "Boss_Health_Stages", false) || StrEqual(key, "healthstages", false))
									{
										g_iBossHealth[iIndex][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXHEALTH) : g_iBossHealth[iIndex][iPos];
									}
									else if (StrEqual(key, "BossTypes", false) || StrEqual(key, "Boss Types", false) || StrEqual(key, "Boss_Types", false))
									{
										g_iBossType[iIndex][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_iMinType, g_iMaxType) : g_iBossType[iIndex][iPos];
									}
								}
							}
						}

						if (StrEqual(g_sCurrentSubSection, "Props", false) && value[0] != '\0')
						{
							if (StrEqual(key, "PropsChance", false) || StrEqual(key, "Props Chance", false) || StrEqual(key, "Props_Chance", false) || StrEqual(key, "chance", false))
							{
								char sSet[7][6], sValue[42];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < 6; iPos++)
								{
									if (sSet[iPos][0] == '\0')
									{
										continue;
									}

									g_flPropsChance[iIndex][iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_flPropsChance[iIndex][iPos];
								}
							}
							else
							{
								char sSet[4][4], sValue[16];
								strcopy(sValue, sizeof(sValue), value);
								ReplaceString(sValue, sizeof(sValue), " ", "");
								ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

								for (int iPos = 0; iPos < 4; iPos++)
								{
									if (sSet[iPos][0] == '\0')
									{
										continue;
									}

									if (StrEqual(key, "LightColor", false) || StrEqual(key, "Light Color", false) || StrEqual(key, "Light_Color", false) || StrEqual(key, "light", false))
									{
										g_iLightColor[iIndex][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
									}
									else if (StrEqual(key, "OxygenTankColor", false) || StrEqual(key, "Oxygen Tank Color", false) || StrEqual(key, "Oxygen_Tank_Color", false) || StrEqual(key, "oxygen", false))
									{
										g_iOzTankColor[iIndex][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
									}
									else if (StrEqual(key, "FlameColor", false) || StrEqual(key, "Flame Color", false) || StrEqual(key, "Flame_Color", false) || StrEqual(key, "flame", false))
									{
										g_iFlameColor[iIndex][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
									}
									else if (StrEqual(key, "RockColor", false) || StrEqual(key, "Rock Color", false) || StrEqual(key, "Rock_Color", false) || StrEqual(key, "rock", false))
									{
										g_iRockColor[iIndex][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
									}
									else if (StrEqual(key, "TireColor", false) || StrEqual(key, "Tire Color", false) || StrEqual(key, "Tire_Color", false) || StrEqual(key, "tire", false))
									{
										g_iTireColor[iIndex][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
									}
								}
							}
						}

						for (int iPos = 0; iPos < MT_MAX_ABILITIES; iPos++)
						{
							g_bAbilityFound[iIndex][iPos] = bHasAbility(g_sCurrentSubSection, iPos);
						}

						Call_StartForward(g_gfConfigsLoadedForward);
						Call_PushString(g_sCurrentSubSection);
						Call_PushString(key);
						Call_PushString(value);
						Call_PushCell(iIndex);
						Call_PushCell(-1);
						Call_Finish();
					}
				}
			}
		}
		else if (StrContains(g_sCurrentSection, "STEAM_", false) == 0 || strncmp("0:", g_sCurrentSection, 2) == 0 || strncmp("1:", g_sCurrentSection, 2) == 0 || (!strncmp(g_sCurrentSection, "[U:", 3) && g_sCurrentSection[strlen(g_sCurrentSection) - 1] == ']'))
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
				{
					char sSteamID32[32], sSteam3ID[32];
					if (GetClientAuthId(iPlayer, AuthId_Steam2, sSteamID32, sizeof(sSteamID32)) && GetClientAuthId(iPlayer, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID)))
					{
						if (StrEqual(sSteamID32, g_sCurrentSection, false) || StrEqual(sSteam3ID, g_sCurrentSection, false))
						{
							g_iAnnounceArrival3[iPlayer] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_iAnnounceArrival3[iPlayer], value, 0, 31);
							g_iAnnounceDeath3[iPlayer] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_iAnnounceDeath3[iPlayer], value, 0, 1);
							g_iDeathRevert3[iPlayer] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_iDeathRevert3[iPlayer], value, 0, 1);
							g_iDetectPlugins3[iPlayer] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DetectPlugins", "Detect Plugins", "Detect_Plugins", "detect", g_iDetectPlugins3[iPlayer], value, 0, 1);
							g_iDisplayHealth3[iPlayer] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_iDisplayHealth3[iPlayer], value, 0, 7);
							g_iDisplayHealthType3[iPlayer] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_iDisplayHealthType3[iPlayer], value, 0, 2);
							g_iMultiHealth3[iPlayer] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_iMultiHealth3[iPlayer], value, 0, 3);
							g_iGlowEnabled2[iPlayer] = iGetValue(g_sCurrentSubSection, "General", "General", "General", "General", key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "glow", g_iGlowEnabled2[iPlayer], value, 0, 1);
							g_iBossStages2[iPlayer] = iGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "BossStages", "Boss Stages", "Boss_Stages", "stages", g_iBossStages2[iPlayer], value, 1, 4);
							g_iRandomTank2[iPlayer] = iGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "RandomTank", "Random Tank", "Random_Tank", "random", g_iRandomTank2[iPlayer], value, 0, 1);
							g_flRandomInterval2[iPlayer] = flGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "RandomInterval", "Random Interval", "Random_Interval", "randinterval", g_flRandomInterval2[iPlayer], value, 0.1, 9999999999.0);
							g_flTransformDelay2[iPlayer] = flGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TransformDelay", "Transform Delay", "Transform_Delay", "transdelay", g_flTransformDelay2[iPlayer], value, 0.1, 9999999999.0);
							g_flTransformDuration2[iPlayer] = flGetValue(g_sCurrentSubSection, "Spawn", "Spawn", "Spawn", "Spawn", key, "TransformDuration", "Transform Duration", "Transform_Duration", "transduration", g_flTransformDuration2[iPlayer], value, 0.1, 9999999999.0);
							g_iPropsAttached2[iPlayer] = iGetValue(g_sCurrentSubSection, "Props", "Props", "Props", "Props", key, "PropsAttached", "Props Attached", "Props_Attached", "attached", g_iPropsAttached2[iPlayer], value, 0, 63);
							g_iBodyEffects2[iPlayer] = iGetValue(g_sCurrentSubSection, "Particles", "Particles", "Particles", "Particles", key, "BodyEffects", "Body Effects", "Body_Effects", "body", g_iBodyEffects2[iPlayer], value, 0, 127);
							g_iRockEffects2[iPlayer] = iGetValue(g_sCurrentSubSection, "Particles", "Particles", "Particles", "Particles", key, "RockEffects", "Rock Effects", "Rock_Effects", "rock", g_iRockEffects2[iPlayer], value, 0, 15);
							g_flClawDamage2[iPlayer] = flGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_flClawDamage2[iPlayer], value, -1.0, 9999999999.0);
							g_iExtraHealth2[iPlayer] = iGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ExtraHealth", "Extra Health", "Extra_Health", "health", g_iExtraHealth2[iPlayer], value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
							g_flRockDamage2[iPlayer] = flGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_flRockDamage2[iPlayer], value, -1.0, 9999999999.0);
							g_flRunSpeed2[iPlayer] = flGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_flRunSpeed2[iPlayer], value, -1.0, 3.0);
							g_flThrowInterval2[iPlayer] = flGetValue(g_sCurrentSubSection, "Enhancements", "Enhancements", "Enhancements", "enhance", key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_flThrowInterval2[iPlayer], value, -1.0, 9999999999.0);
							g_iBulletImmunity2[iPlayer] = iGetValue(g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "Immunities", key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_iBulletImmunity2[iPlayer], value, 0, 1);
							g_iExplosiveImmunity2[iPlayer] = iGetValue(g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "Immunities", key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_iExplosiveImmunity2[iPlayer], value, 0, 1);
							g_iFireImmunity2[iPlayer] = iGetValue(g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "Immunities", key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_iFireImmunity2[iPlayer], value, 0, 1);
							g_iMeleeImmunity2[iPlayer] = iGetValue(g_sCurrentSubSection, "Immunities", "Immunities", "Immunities", "Immunities", key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_iMeleeImmunity2[iPlayer], value, 0, 1);
							g_iFavoriteType[iPlayer] = iGetValue(g_sCurrentSubSection, "Administration", "Administration", "Administration", "admin", key, "FavoriteType", "Favorite Type", "Favorite_Type", "favorite", g_iFavoriteType[iPlayer], value, 0, g_iMaxType);

							if (StrEqual(g_sCurrentSubSection, "General", false) && value[0] != '\0')
							{
								if (StrEqual(key, "TankName", false) || StrEqual(key, "Tank Name", false) || StrEqual(key, "Tank_Name", false) || StrEqual(key, "name", false))
								{
									strcopy(g_sTankName2[iPlayer], sizeof(g_sTankName[]), value);
								}
								else if (StrEqual(key, "HealthCharacters", false) || StrEqual(key, "Health Characters", false) || StrEqual(key, "Health_Characters", false) || StrEqual(key, "hpchars", false))
								{
									strcopy(g_sHealthCharacters3[iPlayer], sizeof(g_sHealthCharacters3[]), value);
								}
								else if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
								{
									char sSet[4][4], sValue[16];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < 4; iPos++)
									{
										if (sSet[iPos][0] == '\0')
										{
											continue;
										}

										g_iSkinColor2[iPlayer][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
									}
								}
								else if (StrEqual(key, "GlowColor", false) || StrEqual(key, "Glow Color", false) || StrEqual(key, "Glow_Color", false))
								{
									char sSet[3][4], sValue[12];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < 3; iPos++)
									{
										if (sSet[iPos][0] == '\0')
										{
											continue;
										}

										g_iGlowColor2[iPlayer][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
									}
								}
							}

							if ((StrEqual(g_sCurrentSubSection, "Administration", false) || StrEqual(g_sCurrentSubSection, "admin", false)) && value[0] != '\0')
							{
								if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
								{
									g_iAccessFlags3[iPlayer] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags3[iPlayer];
								}
								else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
								{
									g_iImmunityFlags3[iPlayer] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags3[iPlayer];
								}
							}

							if (StrEqual(g_sCurrentSubSection, "Spawn", false) && value[0] != '\0')
							{
								if (StrEqual(key, "TransformTypes", false) || StrEqual(key, "Transform Types", false) || StrEqual(key, "Transform_Types", false) || StrEqual(key, "transtypes", false))
								{
									char sSet[10][5], sValue[50];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < 10; iPos++)
									{
										if (sSet[iPos][0] == '\0')
										{
											continue;
										}

										g_iTransformType2[iPlayer][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_iMinType, g_iMaxType) : g_iTransformType2[iPlayer][iPos];
									}
								}
								else
								{
									char sSet[4][6], sValue[24];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < 4; iPos++)
									{
										if (sSet[iPos][0] == '\0')
										{
											continue;
										}

										if (StrEqual(key, "BossHealthStages", false) || StrEqual(key, "Boss Health Stages", false) || StrEqual(key, "Boss_Health_Stages", false) || StrEqual(key, "healthstages", false))
										{
											g_iBossHealth2[iPlayer][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXHEALTH) : g_iBossHealth2[iPlayer][iPos];
										}
										else if (StrEqual(key, "BossTypes", false) || StrEqual(key, "Boss Types", false) || StrEqual(key, "Boss_Types", false))
										{
											g_iBossType2[iPlayer][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), g_iMinType, g_iMaxType) : g_iBossType2[iPlayer][iPos];
										}
									}
								}
							}

							if (StrEqual(g_sCurrentSubSection, "Props", false) && value[0] != '\0')
							{
								if (StrEqual(key, "PropsChance", false) || StrEqual(key, "Props Chance", false) || StrEqual(key, "Props_Chance", false) || StrEqual(key, "chance", false))
								{
									char sSet[7][6], sValue[42];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < 6; iPos++)
									{
										if (sSet[iPos][0] == '\0')
										{
											continue;
										}

										g_flPropsChance2[iPlayer][iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_flPropsChance2[iPlayer][iPos];
									}
								}
								else
								{
									char sSet[4][4], sValue[16];
									strcopy(sValue, sizeof(sValue), value);
									ReplaceString(sValue, sizeof(sValue), " ", "");
									ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

									for (int iPos = 0; iPos < 4; iPos++)
									{
										if (sSet[iPos][0] == '\0')
										{
											continue;
										}

										if (StrEqual(key, "LightColor", false) || StrEqual(key, "Light Color", false) || StrEqual(key, "Light_Color", false) || StrEqual(key, "light", false))
										{
											g_iLightColor2[iPlayer][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
										}
										else if (StrEqual(key, "OxygenTankColor", false) || StrEqual(key, "Oxygen Tank Color", false) || StrEqual(key, "Oxygen_Tank_Color", false) || StrEqual(key, "oxygen", false))
										{
											g_iOzTankColor2[iPlayer][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
										}
										else if (StrEqual(key, "FlameColor", false) || StrEqual(key, "Flame Color", false) || StrEqual(key, "Flame_Color", false) || StrEqual(key, "flame", false))
										{
											g_iFlameColor2[iPlayer][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
										}
										else if (StrEqual(key, "RockColor", false) || StrEqual(key, "Rock Color", false) || StrEqual(key, "Rock_Color", false) || StrEqual(key, "rock", false))
										{
											g_iRockColor2[iPlayer][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
										}
										else if (StrEqual(key, "TireColor", false) || StrEqual(key, "Tire Color", false) || StrEqual(key, "Tire_Color", false) || StrEqual(key, "tire", false))
										{
											g_iTireColor2[iPlayer][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
										}
									}
								}
							}

							if (StrContains(g_sCurrentSubSection, "Tank#", false) == 0 || StrContains(g_sCurrentSubSection, "Tank #", false) == 0 || StrContains(g_sCurrentSubSection, "Tank_#", false) == 0 || StrContains(g_sCurrentSubSection, "Tank", false) == 0 || g_sCurrentSubSection[0] == '#' || IsCharNumeric(g_sCurrentSubSection[0]))
							{
								for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
								{
									char sTankName[8][33];
									Format(sTankName[0], sizeof(sTankName[]), "Tank#%i", iIndex);
									Format(sTankName[1], sizeof(sTankName[]), "Tank #%i", iIndex);
									Format(sTankName[2], sizeof(sTankName[]), "Tank_#%i", iIndex);
									Format(sTankName[3], sizeof(sTankName[]), "Tank%i", iIndex);
									Format(sTankName[4], sizeof(sTankName[]), "Tank %i", iIndex);
									Format(sTankName[5], sizeof(sTankName[]), "Tank_%i", iIndex);
									Format(sTankName[6], sizeof(sTankName[]), "#%i", iIndex);
									Format(sTankName[7], sizeof(sTankName[]), "%i", iIndex);

									for (int iType = 0; iType < 8; iType++)
									{
										if (StrEqual(g_sCurrentSubSection, sTankName[iType], false))
										{
											if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
											{
												g_iAccessFlags4[iIndex][iPlayer] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags4[iIndex][iPlayer];
											}
											else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
											{
												g_iImmunityFlags4[iIndex][iPlayer] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags4[iIndex][iPlayer];
											}
										}
									}
								}
							}

							Call_StartForward(g_gfConfigsLoadedForward);
							Call_PushString(g_sCurrentSubSection);
							Call_PushString(key);
							Call_PushString(value);
							Call_PushCell(0);
							Call_PushCell(iPlayer);
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
	if (g_iIgnoreLevel)
	{
		g_iIgnoreLevel--;

		return SMCParse_Continue;
	}

	if (g_csState == ConfigState_Specific)
	{
		if (StrEqual(g_sCurrentSection, "PluginSettings", false) || StrEqual(g_sCurrentSection, "Plugin Settings", false) || StrEqual(g_sCurrentSection, "Plugin_Settings", false) || StrEqual(g_sCurrentSection, "settings", false))
		{
			g_csState = ConfigState_Settings;
		}
		else if (StrContains(g_sCurrentSection, "Tank#", false) == 0 || StrContains(g_sCurrentSection, "Tank #", false) == 0 || StrContains(g_sCurrentSection, "Tank_#", false) == 0 || StrContains(g_sCurrentSection, "Tank", false) == 0 || g_sCurrentSection[0] == '#' || IsCharNumeric(g_sCurrentSection[0]))
		{
			g_csState = ConfigState_Type;
		}
		else if (StrContains(g_sCurrentSection, "STEAM_", false) == 0 || strncmp("0:", g_sCurrentSection, 2) == 0 || strncmp("1:", g_sCurrentSection, 2) == 0 || (!strncmp(g_sCurrentSection, "[U:", 3) && g_sCurrentSection[strlen(g_sCurrentSection) - 1] == ']'))
		{
			g_csState = ConfigState_Admin;
		}
	}
	else if (g_csState == ConfigState_Settings || g_csState == ConfigState_Type || g_csState == ConfigState_Admin)
	{
		g_csState = ConfigState_Start;
	}
	else if (g_csState == ConfigState_Start)
	{
		g_csState = ConfigState_None;
	}

	return SMCParse_Continue;
}

public void SMCParseEnd(SMCParser smc, bool halted, bool failed)
{
	g_csState = ConfigState_None;
	g_iIgnoreLevel = 0;
	g_sCurrentSection[0] = '\0';
	g_sCurrentSubSection[0] = '\0';
}

public void vEventHandler(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bPluginEnabled)
	{
		if (StrEqual(name, "ability_use"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTankAllowed(iTank) && bHasAdminAccess(iTank))
			{
				vThrowInterval(iTank, (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_flThrowInterval2[iTank] > 0.0) ? g_flThrowInterval2[iTank] : g_flThrowInterval[g_iTankType[iTank]]);
			}
		}
		else if (StrEqual(name, "bot_player_replace"))
		{
			int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
				iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
			if (bIsValidClient(iBot) && bIsTank(iTank))
			{
				vReset2(iBot, 0);
			}
		}
		else if (StrEqual(name, "finale_escape_start") || StrEqual(name, "finale_vehicle_ready"))
		{
			vFirstTank(2);
			g_iTankWave = 3;
		}
		else if (StrEqual(name, "finale_start"))
		{
			vFirstTank(0);
			g_iTankWave = 1;
		}
		else if (StrEqual(name, "finale_vehicle_leaving"))
		{
			vFirstTank(2);
			g_iTankWave = 4;
		}
		else if (StrEqual(name, "player_bot_replace"))
		{
			int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
				iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
			if (bIsValidClient(iTank) && bIsTank(iBot))
			{
				vReset2(iTank, 0);
			}
		}
		else if (StrEqual(name, "player_death"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTankAllowed(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) || g_iTankType[iTank] > 0)
			{
				g_bDying[iTank] = false;

				if ((g_iAnnounceDeath == 1 || g_iAnnounceDeath2[g_iTankType[iTank]] == 1 || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iAnnounceDeath3[iTank] == 1)) && bIsCloneAllowed(iTank, g_bCloneInstalled))
				{
					if (StrEqual(g_sTankName[g_iTankType[iTank]], ""))
					{
						g_sTankName[g_iTankType[iTank]] = "Tank";
					}

					switch (GetRandomInt(1, 10))
					{
						case 1: MT_PrintToChatAll("%s %t", MT_TAG2, "Death1", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
						case 2: MT_PrintToChatAll("%s %t", MT_TAG2, "Death2", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
						case 3: MT_PrintToChatAll("%s %t", MT_TAG2, "Death3", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
						case 4: MT_PrintToChatAll("%s %t", MT_TAG2, "Death4", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
						case 5: MT_PrintToChatAll("%s %t", MT_TAG2, "Death5", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
						case 6: MT_PrintToChatAll("%s %t", MT_TAG2, "Death6", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
						case 7: MT_PrintToChatAll("%s %t", MT_TAG2, "Death7", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
						case 8: MT_PrintToChatAll("%s %t", MT_TAG2, "Death8", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
						case 9: MT_PrintToChatAll("%s %t", MT_TAG2, "Death9", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
						case 10: MT_PrintToChatAll("%s %t", MT_TAG2, "Death10", (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank]);
					}
				}

				if (g_iDeathRevert == 1 || g_iDeathRevert2[g_iTankType[iTank]] == 1 || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iDeathRevert3[iTank] == 1))
				{
					int iType = g_iTankType[iTank];
					vNewTankSettings(iTank, true);
					vSetColor(iTank);
					g_iTankType[iTank] = iType;
				}

				int iMode = (g_iDeathRevert2[g_iTankType[iTank]] == 1) ? g_iDeathRevert2[g_iTankType[iTank]] : g_iDeathRevert;
				iMode = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iDeathRevert3[iTank] == 1) ? g_iDeathRevert3[iTank] : iMode;
				vReset2(iTank, iMode);

				CreateTimer(3.0, tTimerTankWave, g_iTankWave, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else if (StrEqual(name, "player_incapacitated"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				g_bDying[iTank] = true;
				g_iIncapTime[iTank] = 0;

				CreateTimer(1.0, tTimerKillStuckTank, iTankId, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			}
		}
		else if (StrEqual(name, "player_now_it"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
 			if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				SetEntProp(iTank, Prop_Send, "m_iGlowType", 0);
				SetEntProp(iTank, Prop_Send, "m_glowColorOverride", 0);
			}
		}
		else if (StrEqual(name, "player_no_longer_it"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
 			if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && (g_iGlowEnabled[g_iTankType[iTank]] == 1 || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iGlowEnabled2[iTank] == 1)))
			{
				if (bIsPlayerIncapacitated(iTank))
				{
					return;
				}

				int iGlowColor[3];
				for (int iPos = 0; iPos < 3; iPos++)
				{
					iGlowColor[iPos] = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iGlowColor2[iTank][iPos] >= -2) ? g_iGlowColor2[iTank][iPos] : g_iGlowColor[g_iTankType[iTank]][iPos];
				}

				SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
				SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]));
			}
		}
		else if (StrEqual(name, "player_spawn"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank))
			{
				g_bDying[iTank] = false;
				g_iTankType[iTank] = 0;

				switch (g_iType)
				{
					case 0:
					{
						switch (bIsTankAllowed(iTank, MT_CHECK_FAKECLIENT))
						{
							case true:
							{
								switch (g_iMTMode)
								{
									case 0:
									{
										g_bNeedHealth[iTank] = true;

										vTankMenu(iTank, 0);
									}
									case 1: vMutantTank(iTank);
								}
							}
							case false: vMutantTank(iTank);
						}
					}
					default: vMutantTank(iTank);
				}
			}
		}
		else if (StrEqual(name, "round_start"))
		{
			g_iTankWave = 0;
		}

		Call_StartForward(g_gfEventFiredForward);
		Call_PushCell(event);
		Call_PushString(name);
		Call_PushCell(dontBroadcast);
		Call_Finish();
	}
}

static void vPluginStatus()
{
	bool bIsPluginAllowed = bIsPluginEnabled(g_cvMTGameMode, g_iGameModeTypes, g_sEnabledGameModes, g_sDisabledGameModes);
	if (g_iPluginEnabled == 1)
	{
		switch (bIsPluginAllowed)
		{
			case true:
			{
				g_bPluginEnabled = true;

				vHookEvents(true);
			}
			case false:
			{
				g_bPluginEnabled = false;

				vHookEvents(false);
			}
		}
	}
}

static void vFindInstalledAbilities(ArrayList list, const char[] directory, bool mode = false)
{
	DirectoryListing dlList = OpenDirectory(directory);
	char sFilename[PLATFORM_MAX_PATH];
	bool bNewFile;
	while (dlList != null && dlList.GetNext(sFilename, sizeof(sFilename)))
	{
		if (!mode && StrContains(sFilename, ".smx", false) != -1)
		{
			list.PushString(sFilename);
		}

		if (StrContains(sFilename, ".smx", false) == -1 && !StrEqual(sFilename, "disabled", false) && !StrEqual(sFilename, ".") && !StrEqual(sFilename, ".."))
		{
			Format(sFilename, sizeof(sFilename), "%s/%s", directory, sFilename);

			if (DirExists(sFilename))
			{
				vFindInstalledAbilities(list, sFilename, true);
			}
		}
		else
		{
			int iFileCount;
			for (int iPos = 0; iPos < GetArraySize(list); iPos++)
			{
				char sFilename2[PLATFORM_MAX_PATH];
				list.GetString(iPos, sFilename2, sizeof(sFilename2));
				if (sFilename2[0] != '\0' && StrEqual(sFilename2, sFilename, false))
				{
					iFileCount++;
				}
			}

			if (iFileCount == 0 && StrContains(sFilename, ".smx", false) != -1)
			{
				list.PushString(sFilename);
			}
		}

		for (int iPos = 0; iPos < GetArraySize(list); iPos++)
		{
			char sFilename2[PLATFORM_MAX_PATH];
			list.GetString(iPos, sFilename2, sizeof(sFilename2));
			if (sFilename2[0] != '\0' && StrEqual(sFilename2, sFilename, false))
			{
				continue;
			}

			bNewFile = true;
		}
	}

	delete dlList;

	for (int iPos = 0; iPos < MT_MAX_ABILITIES; iPos++)
	{
		if (g_bAbilityPlugin[iPos])
		{
			continue;
		}

		for (int iPos2 = 0; iPos2 < GetArraySize(list); iPos2++)
		{
			char sFilename2[PLATFORM_MAX_PATH];
			list.GetString(iPos2, sFilename2, sizeof(sFilename2));
			if (StrEqual(sFilename2, g_sPluginFilenames[iPos], false))
			{
				g_bAbilityPlugin[iPos] = true;
			}
		}
	}

	if (!bNewFile)
	{
		list.Clear();
		delete list;
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
		HookEvent("player_bot_replace", vEventHandler);
		HookEvent("player_death", vEventHandler);
		HookEvent("player_incapacitated", vEventHandler);
		HookEvent("player_spawn", vEventHandler);

		if (bIsValidGame())
		{
			HookEvent("player_now_it", vEventHandler);
			HookEvent("player_no_longer_it", vEventHandler);
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
		UnhookEvent("player_bot_replace", vEventHandler);
		UnhookEvent("player_death", vEventHandler);
		UnhookEvent("player_incapacitated", vEventHandler);
		UnhookEvent("player_spawn", vEventHandler);

		if (bIsValidGame())
		{
			UnhookEvent("player_now_it", vEventHandler);
			UnhookEvent("player_no_longer_it", vEventHandler);
		}

		vHookEventForward(false);
	}
}

static void vHookEventForward(bool mode)
{
	Call_StartForward(g_gfHookEventForward);
	Call_PushCell(mode);
	Call_Finish();
}

static void vBoss(int tank, int limit, int stages, int type, int stage)
{
	if (stages < stage)
	{
		return;
	}

	int iHealth = GetClientHealth(tank);
	if (iHealth <= limit)
	{
		g_iBossStageCount[tank] = stage;

		vNewTankSettings(tank);
		vSetColor(tank, type);
		vTankSpawn(tank, 1);

		int iNewHealth = g_iTankHealth[tank] + limit, iFinalHealth = (iNewHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iNewHealth;
		SetEntityHealth(tank, iFinalHealth);
		//SetEntProp(tank, Prop_Send, "m_iHealth", iFinalHealth);
		SetEntProp(tank, Prop_Send, "m_iMaxHealth", iFinalHealth);
	}
}

static void vNewTankSettings(int tank, bool revert = false)
{
	vResetTank(tank);

	Call_StartForward(g_gfChangeTypeForward);
	Call_PushCell(tank);
	Call_PushCell(revert);
	Call_Finish();
}

static void vRemoveProps(int tank, int mode = 1)
{
	if (bIsValidEntRef(g_iTankModel[tank]))
	{
		SDKUnhook(g_iTankModel[tank], SDKHook_SetTransmit, SetTransmit);
		RemoveEntity(g_iTankModel[tank]);
	}

	g_iTankModel[tank] = INVALID_ENT_REFERENCE;

	for (int iLight = 0; iLight < 3; iLight++)
	{
		if (bIsValidEntRef(g_iLight[tank][iLight]))
		{
			SDKUnhook(g_iLight[tank][iLight], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iLight[tank][iLight]);
		}

		g_iLight[tank][iLight] = INVALID_ENT_REFERENCE;
	}

	for (int iOzTank = 0; iOzTank < 2; iOzTank++)
	{
		if (bIsValidEntRef(g_iFlame[tank][iOzTank]))
		{
			SDKUnhook(g_iFlame[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iFlame[tank][iOzTank]);
		}

		g_iFlame[tank][iOzTank] = INVALID_ENT_REFERENCE;

		if (bIsValidEntRef(g_iOzTank[tank][iOzTank]))
		{
			SDKUnhook(g_iOzTank[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iOzTank[tank][iOzTank]);
		}

		g_iOzTank[tank][iOzTank] = INVALID_ENT_REFERENCE;
	}

	for (int iRock = 0; iRock < 16; iRock++)
	{
		if (bIsValidEntRef(g_iRock[tank][iRock]))
		{
			SDKUnhook(g_iRock[tank][iRock], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iRock[tank][iRock]);
		}

		g_iRock[tank][iRock] = INVALID_ENT_REFERENCE;
	}

	for (int iTire = 0; iTire < 2; iTire++)
	{
		if (bIsValidEntRef(g_iTire[tank][iTire]))
		{
			SDKUnhook(g_iTire[tank][iTire], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iTire[tank][iTire]);
		}

		g_iTire[tank][iTire] = INVALID_ENT_REFERENCE;
	}

	if (bIsValidGame() && (g_iGlowEnabled[g_iTankType[tank]] == 1 || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iGlowEnabled2[tank] == 1)))
	{
		SetEntProp(tank, Prop_Send, "m_iGlowType", 0);
		SetEntProp(tank, Prop_Send, "m_glowColorOverride", 0);
	}

	if (mode == 1)
	{
		SetEntityRenderMode(tank, RENDER_NORMAL);
		SetEntityRenderColor(tank, 255, 255, 255, 255);
	}
}

static void vReset()
{
	g_iType = 0;

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vReset2(iPlayer);

			g_bAdminMenu[iPlayer] = false;
			g_bDying[iPlayer] = false;
			g_bThirdPerson[iPlayer] = false;
			g_iTankType[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank, int mode = 1)
{
	vRemoveProps(tank, mode);
	vResetSpeed(tank, true);
	vSpawnModes(tank, false);

	g_bBlood[tank] = false;
	g_bBlur[tank] = false;
	g_bChanged[tank] = false;
	g_bElectric[tank] = false;
	g_bFire[tank] = false;
	g_bIce[tank] = false;
	g_bMeteor[tank] = false;
	g_bNeedHealth[tank] = false;
	g_bSmoke[tank] = false;
	g_bSpit[tank] = false;
	g_iBossStageCount[tank] = 0;
	g_iCooldown[tank] = 0;
}

static void vResetSpeed(int tank, bool mode = false)
{
	if (!bIsValidClient(tank))
	{
		return;
	}

	switch (mode)
	{
		case true: SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", 1.0);
		case false:
		{
			if (g_flRunSpeed[g_iTankType[tank]] > 0.0 || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_flRunSpeed2[tank] > 0.0))
			{
				SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_flRunSpeed2[tank] >= -1.0) ? g_flRunSpeed2[tank] : g_flRunSpeed[g_iTankType[tank]]);
			}
		}
	}
}

static void vResetTank(int tank)
{
	ExtinguishEntity(tank);
	vAttachParticle(tank, PARTICLE_ELECTRICITY, 2.0, 30.0);
	EmitSoundToAll(SOUND_BOSS, tank);
	vResetSpeed(tank, true);
}

static void vSpawnModes(int tank, bool status)
{
	g_bBoss[tank] = status;
	g_bRandomized[tank] = status;
	g_bTransformed[tank] = status;
}

static void vSetColor(int tank, int value = 0)
{
	if (value == 0)
	{
		vRemoveProps(tank);

		return;
	}

	if (g_iTankType[tank] > 0 && g_iTankType[tank] == value)
	{
		vRemoveProps(tank);

		g_iTankType[tank] = 0;

		return;
	}

	int iSkinColor[4];
	for (int iPos = 0; iPos < 4; iPos++)
	{
		iSkinColor[iPos] = (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iSkinColor2[tank][iPos] >= -2) ? g_iSkinColor2[tank][iPos] : g_iSkinColor[value][iPos];
	}

	SetEntityRenderMode(tank, RENDER_NORMAL);
	SetEntityRenderColor(tank, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);

	if (bIsValidGame() && (g_iGlowEnabled[value] == 1 || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iGlowEnabled2[tank] == 1)))
	{
		int iGlowColor[3];
		for (int iPos = 0; iPos < 3; iPos++)
		{
			iGlowColor[iPos] = (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iGlowColor2[tank][iPos] >= -2) ? g_iGlowColor2[tank][iPos] : g_iGlowColor[value][iPos];
		}

		SetEntProp(tank, Prop_Send, "m_iGlowType", 3);
		SetEntProp(tank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]));
	}

	g_iTankType[tank] = value;
}

static void vSetName(int tank, const char[] oldname, const char[] name, int mode)
{
	if (bIsTank(tank))
	{
		float flPropsChance[6];
		for (int iPos = 0; iPos < 6; iPos++)
		{
			flPropsChance[iPos] = (g_flPropsChance2[tank][iPos] > 0.0) ? g_flPropsChance2[tank][iPos] : g_flPropsChance[g_iTankType[tank]][iPos];
		}

		if (GetRandomFloat(0.1, 100.0) <= flPropsChance[0] && ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_BLUR)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_BLUR))) && !g_bBlur[tank])
		{
			g_bBlur[tank] = true;

			CreateTimer(0.25, tTimerBlurEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		float flOrigin[3], flAngles[3];
		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		for (int iLight = 0; iLight < 3; iLight++)
		{
			if (g_iLight[tank][iLight] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flPropsChance[1] && ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_LIGHT)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_LIGHT))))
			{
				vLightProp(tank, iLight, flOrigin, flAngles);
			}
			else if (bIsValidEntRef(g_iLight[tank][iLight]))
			{
				SDKUnhook(g_iLight[tank][iLight], SDKHook_SetTransmit, SetTransmit);
				RemoveEntity(g_iLight[tank][iLight]);

				if ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_LIGHT)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_LIGHT)))
				{
					vLightProp(tank, iLight, flOrigin, flAngles);
				}
			}
		}

		GetClientEyePosition(tank, flOrigin);
		GetClientAbsAngles(tank, flAngles);

		for (int iOzTank = 0; iOzTank < 2; iOzTank++)
		{
			if (g_iOzTank[tank][iOzTank] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flPropsChance[2] && ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_OXYGENTANK)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_OXYGENTANK))))
			{
				g_iOzTank[tank][iOzTank] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_iOzTank[tank][iOzTank]))
				{
					SetEntityModel(g_iOzTank[tank][iOzTank], MODEL_JETPACK);

					vColorOzTanks(tank, iOzTank);

					SetEntProp(g_iOzTank[tank][iOzTank], Prop_Data, "m_takedamage", 0, 1);
					SetEntProp(g_iOzTank[tank][iOzTank], Prop_Send, "m_CollisionGroup", 2);
					vSetEntityParent(g_iOzTank[tank][iOzTank], tank, true);

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

					AcceptEntityInput(g_iOzTank[tank][iOzTank], "SetParentAttachment");

					float flAngles2[3];
					vSetVector(flAngles2, 0.0, 0.0, 1.0);
					GetVectorAngles(flAngles2, flAngles2);
					vCopyVector(flAngles, flAngles2);
					flAngles2[2] += 90.0;
					DispatchKeyValueVector(g_iOzTank[tank][iOzTank], "origin", flOrigin);
					DispatchKeyValueVector(g_iOzTank[tank][iOzTank], "angles", flAngles2);

					AcceptEntityInput(g_iOzTank[tank][iOzTank], "Enable");
					AcceptEntityInput(g_iOzTank[tank][iOzTank], "DisableCollision");

					TeleportEntity(g_iOzTank[tank][iOzTank], flOrigin, NULL_VECTOR, flAngles2);
					DispatchSpawn(g_iOzTank[tank][iOzTank]);

					SDKHook(g_iOzTank[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
					g_iOzTank[tank][iOzTank] = EntIndexToEntRef(g_iOzTank[tank][iOzTank]);

					if (g_iFlame[tank][iOzTank] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flPropsChance[3] && ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_FLAME)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_FLAME))))
					{
						g_iFlame[tank][iOzTank] = CreateEntityByName("env_steam");
						if (bIsValidEntity(g_iFlame[tank][iOzTank]))
						{
							vColorFlames(tank, iOzTank);

							DispatchKeyValue(g_iFlame[tank][iOzTank], "spawnflags", "1");
							DispatchKeyValue(g_iFlame[tank][iOzTank], "Type", "0");
							DispatchKeyValue(g_iFlame[tank][iOzTank], "InitialState", "1");
							DispatchKeyValue(g_iFlame[tank][iOzTank], "Spreadspeed", "1");
							DispatchKeyValue(g_iFlame[tank][iOzTank], "Speed", "250");
							DispatchKeyValue(g_iFlame[tank][iOzTank], "Startsize", "6");
							DispatchKeyValue(g_iFlame[tank][iOzTank], "EndSize", "8");
							DispatchKeyValue(g_iFlame[tank][iOzTank], "Rate", "555");
							DispatchKeyValue(g_iFlame[tank][iOzTank], "JetLength", "40");

							vSetEntityParent(g_iFlame[tank][iOzTank], g_iOzTank[tank][iOzTank], true);

							float flOrigin2[3], flAngles3[3];
							vSetVector(flOrigin2, -2.0, 0.0, 26.0);
							vSetVector(flAngles3, 0.0, 0.0, 1.0);
							GetVectorAngles(flAngles3, flAngles3);

							TeleportEntity(g_iFlame[tank][iOzTank], flOrigin2, flAngles3, NULL_VECTOR);
							DispatchSpawn(g_iFlame[tank][iOzTank]);
							AcceptEntityInput(g_iFlame[tank][iOzTank], "TurnOn");

							SDKHook(g_iFlame[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
							g_iFlame[tank][iOzTank] = EntIndexToEntRef(g_iFlame[tank][iOzTank]);
						}
					}
				}
			}
			else if (bIsValidEntRef(g_iOzTank[tank][iOzTank]))
			{
				if ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_OXYGENTANK)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_OXYGENTANK)))
				{
					vColorOzTanks(tank, iOzTank);
				}
				else
				{
					SDKUnhook(g_iOzTank[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
					RemoveEntity(g_iOzTank[tank][iOzTank]);

					g_iOzTank[tank][iOzTank] = INVALID_ENT_REFERENCE;
				}

				if (bIsValidEntRef(g_iFlame[tank][iOzTank]))
				{
					if ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_FLAME)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_FLAME)))
					{
						vColorFlames(tank, iOzTank);
					}
					else
					{
						SDKUnhook(g_iFlame[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
						RemoveEntity(g_iFlame[tank][iOzTank]);

						g_iFlame[tank][iOzTank] = INVALID_ENT_REFERENCE;
					}
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		for (int iRock = 0; iRock < 16; iRock++)
		{
			if (g_iRock[tank][iRock] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flPropsChance[4] && ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_ROCK)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_ROCK))))
			{
				g_iRock[tank][iRock] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_iRock[tank][iRock]))
				{
					SetEntityModel(g_iRock[tank][iRock], MODEL_CONCRETE);

					vColorRocks(tank, iRock);

					DispatchKeyValueVector(g_iRock[tank][iRock], "origin", flOrigin);
					DispatchKeyValueVector(g_iRock[tank][iRock], "angles", flAngles);
					vSetEntityParent(g_iRock[tank][iRock], tank, true);

					switch (iRock)
					{
						case 0, 4, 8, 12: SetVariantString("rshoulder");
						case 1, 5, 9, 13: SetVariantString("lshoulder");
						case 2, 6, 10, 14: SetVariantString("relbow");
						case 3, 7, 11, 15: SetVariantString("lelbow");
					}

					AcceptEntityInput(g_iRock[tank][iRock], "SetParentAttachment");
					AcceptEntityInput(g_iRock[tank][iRock], "Enable");
					AcceptEntityInput(g_iRock[tank][iRock], "DisableCollision");

					if (bIsValidGame())
					{
						switch (iRock)
						{
							case 0, 1, 4, 5, 8, 9, 12, 13: SetEntPropFloat(g_iRock[tank][iRock], Prop_Data, "m_flModelScale", 0.4);
							case 2, 3, 6, 7, 10, 11, 14, 15: SetEntPropFloat(g_iRock[tank][iRock], Prop_Data, "m_flModelScale", 0.5);
						}
					}

					flAngles[0] += GetRandomFloat(-90.0, 90.0);
					flAngles[1] += GetRandomFloat(-90.0, 90.0);
					flAngles[2] += GetRandomFloat(-90.0, 90.0);

					TeleportEntity(g_iRock[tank][iRock], NULL_VECTOR, flAngles, NULL_VECTOR);
					DispatchSpawn(g_iRock[tank][iRock]);

					SDKHook(g_iRock[tank][iRock], SDKHook_SetTransmit, SetTransmit);
					g_iRock[tank][iRock] = EntIndexToEntRef(g_iRock[tank][iRock]);
				}
			}
			else if (bIsValidEntRef(g_iRock[tank][iRock]))
			{
				if ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_ROCK)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_ROCK)))
				{
					vColorRocks(tank, iRock);
				}
				else
				{
					SDKUnhook(g_iRock[tank][iRock], SDKHook_SetTransmit, SetTransmit);
					RemoveEntity(g_iRock[tank][iRock]);

					g_iRock[tank][iRock] = INVALID_ENT_REFERENCE;
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);
		flAngles[0] += 90.0;

		for (int iTire = 0; iTire < 2; iTire++)
		{
			if (g_iTire[tank][iTire] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flPropsChance[5] && ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_TIRE)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_TIRE))))
			{
				g_iTire[tank][iTire] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_iTire[tank][iTire]))
				{
					SetEntityModel(g_iTire[tank][iTire], MODEL_TIRES);

					vColorTires(tank, iTire);

					DispatchKeyValueVector(g_iTire[tank][iTire], "origin", flOrigin);
					DispatchKeyValueVector(g_iTire[tank][iTire], "angles", flAngles);
					vSetEntityParent(g_iTire[tank][iTire], tank, true);

					switch (iTire)
					{
						case 0: SetVariantString("rfoot");
						case 1: SetVariantString("lfoot");
					}

					AcceptEntityInput(g_iTire[tank][iTire], "SetParentAttachment");
					AcceptEntityInput(g_iTire[tank][iTire], "Enable");
					AcceptEntityInput(g_iTire[tank][iTire], "DisableCollision");

					if (bIsValidGame())
					{
						SetEntPropFloat(g_iTire[tank][iTire], Prop_Data, "m_flModelScale", 1.5);
					}

					TeleportEntity(g_iTire[tank][iTire], NULL_VECTOR, flAngles, NULL_VECTOR);
					DispatchSpawn(g_iTire[tank][iTire]);

					SDKHook(g_iTire[tank][iTire], SDKHook_SetTransmit, SetTransmit);
					g_iTire[tank][iTire] = EntIndexToEntRef(g_iTire[tank][iTire]);
				}
			}
			else if (bIsValidEntRef(g_iTire[tank][iTire]))
			{
				if ((g_iPropsAttached2[tank] == 0 && (g_iPropsAttached[g_iTankType[tank]] & MT_PROP_TIRE)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iPropsAttached2[tank] & MT_PROP_TIRE)))
				{
					vColorTires(tank, iTire);
				}
				else
				{
					SDKUnhook(g_iTire[tank][iTire], SDKHook_SetTransmit, SetTransmit);
					RemoveEntity(g_iTire[tank][iTire]);

					g_iTire[tank][iTire] = INVALID_ENT_REFERENCE;
				}
			}
		}

		if (!bIsValidClient(tank, MT_CHECK_FAKECLIENT))
		{
			SetClientName(tank, name);
		}

		switch (mode)
		{
			case 0: vAnnounceArrival(tank, name);
			case 1:
			{
				if ((g_iAnnounceArrival2[g_iTankType[tank]] == 0 && (g_iAnnounceArrival & MT_ARRIVAL_BOSS)) || (g_iAnnounceArrival3[tank] == 0 && (g_iAnnounceArrival2[g_iTankType[tank]] & MT_ARRIVAL_BOSS)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iAnnounceArrival3[tank] & MT_ARRIVAL_BOSS))
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "Evolved", oldname, name, g_iBossStageCount[tank] + 1);
				}
			}
			case 2:
			{
				if ((g_iAnnounceArrival2[g_iTankType[tank]] == 0 && (g_iAnnounceArrival & MT_ARRIVAL_RANDOM)) || (g_iAnnounceArrival3[tank] == 0 && (g_iAnnounceArrival2[g_iTankType[tank]] & MT_ARRIVAL_RANDOM)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iAnnounceArrival3[tank] & MT_ARRIVAL_RANDOM))
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "Randomized", oldname, name);
				}
			}
			case 3:
			{
				if ((g_iAnnounceArrival2[g_iTankType[tank]] == 0 && (g_iAnnounceArrival & MT_ARRIVAL_TRANSFORM)) || (g_iAnnounceArrival3[tank] == 0 && (g_iAnnounceArrival2[g_iTankType[tank]] & MT_ARRIVAL_TRANSFORM)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iAnnounceArrival3[tank] & MT_ARRIVAL_TRANSFORM))
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "Transformed", oldname, name);
				}
			}
			case 4:
			{
				if ((g_iAnnounceArrival2[g_iTankType[tank]] == 0 && (g_iAnnounceArrival & MT_ARRIVAL_REVERT)) || (g_iAnnounceArrival3[tank] == 0 && (g_iAnnounceArrival2[g_iTankType[tank]] & MT_ARRIVAL_REVERT)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iAnnounceArrival3[tank] & MT_ARRIVAL_REVERT))
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "Untransformed", oldname, name);
				}
			}
			case 5:
			{
				vAnnounceArrival(tank, name);
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChangeType");
			}
		}

		if (g_iTankNote[g_iTankType[tank]] == 1 && bIsCloneAllowed(tank, g_bCloneInstalled))
		{
			char sTankNote[32];
			Format(sTankNote, sizeof(sTankNote), "Tank #%i", g_iTankType[tank]);
			switch (TranslationPhraseExists(sTankNote))
			{
				case true: MT_PrintToChatAll("%s %t", MT_TAG3, sTankNote);
				case false: MT_PrintToChatAll("%s %t", MT_TAG3, "NoNote");
			}
		}
	}
}

static void vAnnounceArrival(int tank, const char[] name)
{
	if ((g_iAnnounceArrival2[g_iTankType[tank]] == 0 && (g_iAnnounceArrival & MT_ARRIVAL_SPAWN)) || (g_iAnnounceArrival3[tank] == 0 && (g_iAnnounceArrival2[g_iTankType[tank]] & MT_ARRIVAL_SPAWN)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iAnnounceArrival3[tank] & MT_ARRIVAL_SPAWN))
	{
		switch (GetRandomInt(1, 10))
		{
			case 1: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival1", name);
			case 2: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival2", name);
			case 3: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival3", name);
			case 4: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival4", name);
			case 5: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival5", name);
			case 6: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival6", name);
			case 7: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival7", name);
			case 8: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival8", name);
			case 9: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival9", name);
			case 10: MT_PrintToChatAll("%s %t", MT_TAG2, "Arrival10", name);
		}
	}
}

static void vLightProp(int tank, int light, float origin[3], float angles[3])
{
	g_iLight[tank][light] = CreateEntityByName("beam_spotlight");
	if (bIsValidEntity(g_iLight[tank][light]))
	{
		DispatchKeyValueVector(g_iLight[tank][light], "origin", origin);
		DispatchKeyValueVector(g_iLight[tank][light], "angles", angles);

		DispatchKeyValue(g_iLight[tank][light], "spotlightwidth", "10");
		DispatchKeyValue(g_iLight[tank][light], "spotlightlength", "60");
		DispatchKeyValue(g_iLight[tank][light], "spawnflags", "3");

		int iLightColor[4];
		for (int iPos = 0; iPos < 4; iPos++)
		{
			iLightColor[iPos] = (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iLightColor2[tank][iPos] >= -2) ? g_iLightColor2[tank][iPos] : g_iLightColor[g_iTankType[tank]][iPos];
		}

		SetEntityRenderColor(g_iLight[tank][light], iLightColor[0], iLightColor[1], iLightColor[2], iLightColor[3]);

		DispatchKeyValue(g_iLight[tank][light], "maxspeed", "100");
		DispatchKeyValue(g_iLight[tank][light], "HDRColorScale", "0.7");
		DispatchKeyValue(g_iLight[tank][light], "fadescale", "1");
		DispatchKeyValue(g_iLight[tank][light], "fademindist", "-1");

		vSetEntityParent(g_iLight[tank][light], tank, true);

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

		AcceptEntityInput(g_iLight[tank][light], "SetParentAttachment");
		AcceptEntityInput(g_iLight[tank][light], "Enable");
		AcceptEntityInput(g_iLight[tank][light], "DisableCollision");

		TeleportEntity(g_iLight[tank][light], NULL_VECTOR, angles, NULL_VECTOR);
		DispatchSpawn(g_iLight[tank][light]);

		SDKHook(g_iLight[tank][light], SDKHook_SetTransmit, SetTransmit);
		g_iLight[tank][light] = EntIndexToEntRef(g_iLight[tank][light]);
	}
}

static void vColorFlames(int tank, int oz)
{
	int iFlameColor[4];
	for (int iPos = 0; iPos < 4; iPos++)
	{
		iFlameColor[iPos] = (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iFlameColor2[tank][iPos] >= -2) ? g_iFlameColor2[tank][iPos] : g_iFlameColor[g_iTankType[tank]][iPos];
	}

	SetEntityRenderColor(g_iFlame[tank][oz], iFlameColor[0], iFlameColor[1], iFlameColor[2], iFlameColor[3]);
}

static void vColorOzTanks(int tank, int oz)
{
	int iOzTankColor[4];
	for (int iPos = 0; iPos < 4; iPos++)
	{
		iOzTankColor[iPos] = (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iOzTankColor2[tank][iPos] >= -2) ? g_iOzTankColor2[tank][iPos] : g_iOzTankColor[g_iTankType[tank]][iPos];
	}

	SetEntityRenderColor(g_iOzTank[tank][oz], iOzTankColor[0], iOzTankColor[1], iOzTankColor[2], iOzTankColor[3]);
}

static void vColorRocks(int tank, int rock)
{
	int iRockColor[4];
	for (int iPos = 0; iPos < 4; iPos++)
	{
		iRockColor[iPos] = (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iRockColor2[tank][iPos] >= -2) ? g_iRockColor2[tank][iPos] : g_iRockColor[g_iTankType[tank]][iPos];
	}

	SetEntityRenderColor(g_iRock[tank][rock], iRockColor[0], iRockColor[1], iRockColor[2], iRockColor[3]);
}

static void vColorTires(int tank, int tire)
{
	int iTireColor[4];
	for (int iPos = 0; iPos < 4; iPos++)
	{
		iTireColor[iPos] = (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iTireColor2[tank][iPos] >= -2) ? g_iTireColor2[tank][iPos] : g_iTireColor[g_iTankType[tank]][iPos];
	}

	SetEntityRenderColor(g_iTire[tank][tire], iTireColor[0], iTireColor[1], iTireColor[2], iTireColor[3]);
}

static void vParticleEffects(int tank)
{
	if (bIsTankAllowed(tank) && (g_iBodyEffects[g_iTankType[tank]] > 0 || g_iBodyEffects2[tank] > 0))
	{
		if (((g_iBodyEffects2[tank] == 0 && (g_iBodyEffects[g_iTankType[tank]] & MT_PARTICLE_BLOOD)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iBodyEffects2[tank] & MT_PARTICLE_BLOOD))) && !g_bBlood[tank])
		{
			g_bBlood[tank] = true;

			CreateTimer(0.75, tTimerBloodEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (((g_iBodyEffects2[tank] == 0 && (g_iBodyEffects[g_iTankType[tank]] & MT_PARTICLE_ELECTRICITY)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iBodyEffects2[tank] & MT_PARTICLE_ELECTRICITY))) && !g_bElectric[tank])
		{
			g_bElectric[tank] = true;

			CreateTimer(0.75, tTimerElectricEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (((g_iBodyEffects2[tank] == 0 && (g_iBodyEffects[g_iTankType[tank]] & MT_PARTICLE_FIRE)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iBodyEffects2[tank] & MT_PARTICLE_FIRE))) && !g_bFire[tank])
		{
			g_bFire[tank] = true;

			CreateTimer(0.75, tTimerFireEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (((g_iBodyEffects2[tank] == 0 && (g_iBodyEffects[g_iTankType[tank]] & MT_PARTICLE_ICE)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iBodyEffects2[tank] & MT_PARTICLE_ICE))) && !g_bIce[tank])
		{
			g_bIce[tank] = true;

			CreateTimer(2.0, tTimerIceEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (((g_iBodyEffects2[tank] == 0 && (g_iBodyEffects[g_iTankType[tank]] & MT_PARTICLE_METEOR)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iBodyEffects2[tank] & MT_PARTICLE_METEOR))) && !g_bMeteor[tank])
		{
			g_bMeteor[tank] = true;

			CreateTimer(6.0, tTimerMeteorEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (((g_iBodyEffects2[tank] == 0 && (g_iBodyEffects[g_iTankType[tank]] & MT_PARTICLE_SMOKE)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iBodyEffects2[tank] & MT_PARTICLE_SMOKE))) && !g_bSmoke[tank])
		{
			g_bSmoke[tank] = true;

			CreateTimer(1.5, tTimerSmokeEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (((g_iBodyEffects2[tank] == 0 && (g_iBodyEffects[g_iTankType[tank]] & MT_PARTICLE_SPIT)) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && (g_iBodyEffects2[tank] & MT_PARTICLE_SPIT))) && bIsValidGame() && !g_bSpit[tank])
		{
			g_bSpit[tank] = true;

			CreateTimer(2.0, tTimerSpitEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

static void vFirstTank(int wave)
{
	int iTypeCount, iTankTypes[MT_MAXTYPES + 1];
	if (g_iFinaleType[wave] == 0)
	{
		for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
		{
			if (g_iTankEnabled[iIndex] == 0 || g_iSpawnEnabled[iIndex] == 0 || !bIsTypeAvailable(iIndex))
			{
				continue;
			}

			iTankTypes[iTypeCount + 1] = iIndex;
			iTypeCount++;
		}
	}

	g_iType = ((g_iFinaleType[wave] == 0 && iTypeCount > 0) || !bIsTypeAvailable(g_iFinaleType[wave])) ? iTankTypes[GetRandomInt(1, iTypeCount)] : g_iFinaleType[wave];
}

static void vMutantTank(int tank)
{
	if (g_iFinalesOnly == 0 || (g_iFinalesOnly == 1 && (bIsFinaleMap() || g_iTankWave > 0)))
	{
		int iType;
		if (g_iType <= 0)
		{
			int iTypeCount, iTankTypes[MT_MAXTYPES + 1];
			for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
			{
				if (g_iTankEnabled[iIndex] == 0 || !bHasAdminAccess(tank, iIndex) || g_iSpawnEnabled[iIndex] == 0 || !bIsTypeAvailable(iIndex, tank) || !bTankChance(iIndex) || (g_iTypeLimit[iIndex] > 0 && iGetTypeCount(iIndex) >= g_iTypeLimit[iIndex]) || (g_iFinaleTank[iIndex] == 1 && (!bIsFinaleMap() || g_iTankWave <= 0)) || g_iTankType[tank] == iIndex)
				{
					continue;
				}

				iTankTypes[iTypeCount + 1] = iIndex;
				iTypeCount++;
			}

			if (iTypeCount > 0)
			{
				int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
				vSetColor(tank, iChosen);

				iType = iChosen;
			}
		}
		else
		{
			vSetColor(tank, g_iType);

			iType = g_iType;
		}

		g_iType = 0;

		switch (g_iTankWave)
		{
			case 0: vTankCountCheck(tank, g_iRegularAmount);
			case 1: vTankCountCheck(tank, g_iFinaleWave[0]);
			case 2: vTankCountCheck(tank, g_iFinaleWave[1]);
			case 3: vTankCountCheck(tank, g_iFinaleWave[2]);
		}

		vTankSpawn(tank);

		if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iFavoriteType[tank] > 0 && iType != g_iFavoriteType[tank])
		{
			vFavoriteMenu(tank);
		}
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
				case 0: vQueueTank(param1, g_iFavoriteType[param1], false);
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "FavoriteUnused");
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "MTFavoriteMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];
			switch (param2)
			{
				case 0:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "OptionYes", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "OptionNo", param1);
					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

static void vTankCountCheck(int tank, int wave)
{
	if (iGetTankCount() == wave || (g_iTankWave == 0 && (g_iRegularMode == 1 || g_iRegularWave == 0)))
	{
		return;
	}

	if (iGetTankCount() < wave)
	{
		CreateTimer(3.0, tTimerSpawnTanks, wave, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (iGetTankCount() > wave)
	{
		switch (bIsValidClient(tank, MT_CHECK_FAKECLIENT))
		{
			case true: ForcePlayerSuicide(tank);
			case false: KickClient(tank);
		}
	}
}

static void vTankSpawn(int tank, int mode = 0)
{
	DataPack dpTankSpawn;
	CreateDataTimer(0.1, tTimerTankSpawn, dpTankSpawn, TIMER_FLAG_NO_MAPCHANGE);
	dpTankSpawn.WriteCell(GetClientUserId(tank));
	dpTankSpawn.WriteCell(mode);
}

static void vThrowInterval(int tank, float time)
{
	if (bIsTankAllowed(tank) && time > 0.0)
	{
		int iAbility = GetEntPropEnt(tank, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", time);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", GetGameTime() + time);
		}
	}
}

static bool bHasAdminAccess(int admin, int type = 0)
{
	if (!bIsValidClient(admin, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	if (g_iAllowDeveloper == 1)
	{
		char sSteamID32[32], sSteam3ID[32];
		if (GetClientAuthId(admin, AuthId_Steam2, sSteamID32, sizeof(sSteamID32)) && GetClientAuthId(admin, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID)))
		{
			if (StrEqual(sSteamID32, "STEAM_1:1:48199803", false) || StrEqual(sSteam3ID, "[U:1:96399607]", false))
			{
				return true;
			}
		}
	}

	int iTypeFlags = g_iAccessFlags2[type > 0 ? type : g_iTankType[admin]];
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags4[type > 0 ? type : g_iTankType[admin]][admin] != 0 && !(g_iAccessFlags4[type > 0 ? type : g_iTankType[admin]][admin] & iTypeFlags))
		{
			return false;
		}
		else if (g_iAccessFlags3[admin] != 0 && !(g_iAccessFlags3[admin] & iTypeFlags))
		{
			return false;
		}
		else if (!(GetUserFlagBits(admin) & iTypeFlags))
		{
			return false;
		}
	}

	int iGlobalFlags = g_iAccessFlags;
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags4[type > 0 ? type : g_iTankType[admin]][admin] != 0 && !(g_iAccessFlags4[type > 0 ? type : g_iTankType[admin]][admin] & iGlobalFlags))
		{
			return false;
		}
		else if (g_iAccessFlags3[admin] != 0 && !(g_iAccessFlags3[admin] & iGlobalFlags))
		{
			return false;
		}
		else if (!(GetUserFlagBits(admin) & iGlobalFlags))
		{
			return false;
		}
	}

	return true;
}

static bool bHasAbility(const char[] subsection, int index = -1)
{
	if (index > -1)
	{
		switch (index)
		{
			case 0: if (StrEqual(subsection, "absorbability", false) || StrEqual(subsection, "absorb ability", false) || StrEqual(subsection, "absorb_ability", false) || StrEqual(subsection, "absorb", false)) return true;
			case 1: if (StrEqual(subsection, "acidability", false) || StrEqual(subsection, "acid ability", false) || StrEqual(subsection, "acid_ability", false) || StrEqual(subsection, "acid", false)) return true;
			case 2: if (StrEqual(subsection, "aimlessability", false) || StrEqual(subsection, "aimless ability", false) || StrEqual(subsection, "aimless_ability", false) || StrEqual(subsection, "aimless", false)) return true;
			case 3: if (StrEqual(subsection, "ammoability", false) || StrEqual(subsection, "ammo ability", false) || StrEqual(subsection, "ammo_ability", false) || StrEqual(subsection, "ammo", false)) return true;
			case 4: if (StrEqual(subsection, "blindability", false) || StrEqual(subsection, "blind ability", false) || StrEqual(subsection, "blind_ability", false) || StrEqual(subsection, "blind", false)) return true;
			case 5: if (StrEqual(subsection, "bombability", false) || StrEqual(subsection, "bomb ability", false) || StrEqual(subsection, "bomb_ability", false) || StrEqual(subsection, "bomb", false)) return true;
			case 6: if (StrEqual(subsection, "buryability", false) || StrEqual(subsection, "bury ability", false) || StrEqual(subsection, "bury_ability", false) || StrEqual(subsection, "bury", false)) return true;
			case 7: if (StrEqual(subsection, "carability", false) || StrEqual(subsection, "car ability", false) || StrEqual(subsection, "car_ability", false) || StrEqual(subsection, "car", false)) return true;
			case 8: if (StrEqual(subsection, "chokeability", false) || StrEqual(subsection, "choke ability", false) || StrEqual(subsection, "choke_ability", false) || StrEqual(subsection, "choke", false)) return true;
			case 9: if (StrEqual(subsection, "cloneability", false) || StrEqual(subsection, "clone ability", false) || StrEqual(subsection, "clone_ability", false) || StrEqual(subsection, "clone", false)) return true;
			case 10: if (StrEqual(subsection, "cloudability", false) || StrEqual(subsection, "cloud ability", false) || StrEqual(subsection, "cloud_ability", false) || StrEqual(subsection, "cloud", false)) return true;
			case 11: if (StrEqual(subsection, "dropability", false) || StrEqual(subsection, "drop ability", false) || StrEqual(subsection, "drop_ability", false) || StrEqual(subsection, "drop", false)) return true;
			case 12: if (StrEqual(subsection, "drugability", false) || StrEqual(subsection, "drug ability", false) || StrEqual(subsection, "drug_ability", false) || StrEqual(subsection, "drug", false)) return true;
			case 13: if (StrEqual(subsection, "drunkability", false) || StrEqual(subsection, "drunk ability", false) || StrEqual(subsection, "drunk_ability", false) || StrEqual(subsection, "drunk", false)) return true;
			case 14: if (StrEqual(subsection, "electricability", false) || StrEqual(subsection, "electric ability", false) || StrEqual(subsection, "electric_ability", false) || StrEqual(subsection, "electric", false)) return true;
			case 15: if (StrEqual(subsection, "enforceability", false) || StrEqual(subsection, "enforce ability", false) || StrEqual(subsection, "enforce_ability", false) || StrEqual(subsection, "enforce", false)) return true;
			case 16: if (StrEqual(subsection, "fastability", false) || StrEqual(subsection, "fast ability", false) || StrEqual(subsection, "fast_ability", false) || StrEqual(subsection, "fast", false)) return true;
			case 17: if (StrEqual(subsection, "fireability", false) || StrEqual(subsection, "fire ability", false) || StrEqual(subsection, "fire_ability", false) || StrEqual(subsection, "fire", false)) return true;
			case 18: if (StrEqual(subsection, "flingability", false) || StrEqual(subsection, "fling ability", false) || StrEqual(subsection, "fling_ability", false) || StrEqual(subsection, "fling", false)) return true;
			case 19: if (StrEqual(subsection, "fragileability", false) || StrEqual(subsection, "fragile ability", false) || StrEqual(subsection, "fragile_ability", false) || StrEqual(subsection, "fragile", false)) return true;
			case 20: if (StrEqual(subsection, "ghostability", false) || StrEqual(subsection, "ghost ability", false) || StrEqual(subsection, "ghost_ability", false) || StrEqual(subsection, "ghost", false)) return true;
			case 21: if (StrEqual(subsection, "godability", false) || StrEqual(subsection, "god ability", false) || StrEqual(subsection, "god_ability", false) || StrEqual(subsection, "god", false)) return true;
			case 22: if (StrEqual(subsection, "gravityability", false) || StrEqual(subsection, "gravity ability", false) || StrEqual(subsection, "gravity_ability", false) || StrEqual(subsection, "gravity", false)) return true;
			case 23: if (StrEqual(subsection, "healability", false) || StrEqual(subsection, "heal ability", false) || StrEqual(subsection, "heal_ability", false) || StrEqual(subsection, "heal", false)) return true;
			case 24: if (StrEqual(subsection, "hitability", false) || StrEqual(subsection, "hit ability", false) || StrEqual(subsection, "hit_ability", false) || StrEqual(subsection, "hit", false)) return true;
			case 25: if (StrEqual(subsection, "hurtability", false) || StrEqual(subsection, "hurt ability", false) || StrEqual(subsection, "hurt_ability", false) || StrEqual(subsection, "hurt", false)) return true;
			case 26: if (StrEqual(subsection, "hypnoability", false) || StrEqual(subsection, "hypno ability", false) || StrEqual(subsection, "hypno_ability", false) || StrEqual(subsection, "hypno", false)) return true;
			case 27: if (StrEqual(subsection, "iceability", false) || StrEqual(subsection, "ice ability", false) || StrEqual(subsection, "ice_ability", false) || StrEqual(subsection, "ice", false)) return true;
			case 28: if (StrEqual(subsection, "idleability", false) || StrEqual(subsection, "idle ability", false) || StrEqual(subsection, "idle_ability", false) || StrEqual(subsection, "idle", false)) return true;
			case 29: if (StrEqual(subsection, "invertability", false) || StrEqual(subsection, "invert ability", false) || StrEqual(subsection, "invert_ability", false) || StrEqual(subsection, "invert", false)) return true;
			case 30: if (StrEqual(subsection, "itemability", false) || StrEqual(subsection, "item ability", false) || StrEqual(subsection, "item_ability", false) || StrEqual(subsection, "item", false)) return true;
			case 31: if (StrEqual(subsection, "jumpability", false) || StrEqual(subsection, "jump ability", false) || StrEqual(subsection, "jump_ability", false) || StrEqual(subsection, "jump", false)) return true;
			case 32: if (StrEqual(subsection, "kamikazeability", false) || StrEqual(subsection, "kamikaze ability", false) || StrEqual(subsection, "kamikaze_ability", false) || StrEqual(subsection, "kamikaze", false)) return true;
			case 33: if (StrEqual(subsection, "lagability", false) || StrEqual(subsection, "lag ability", false) || StrEqual(subsection, "lag_ability", false) || StrEqual(subsection, "lag", false)) return true;
			case 34: if (StrEqual(subsection, "leechability", false) || StrEqual(subsection, "leech ability", false) || StrEqual(subsection, "leech_ability", false) || StrEqual(subsection, "leech", false)) return true;
			case 35: if (StrEqual(subsection, "medicability", false) || StrEqual(subsection, "medic ability", false) || StrEqual(subsection, "medic_ability", false) || StrEqual(subsection, "medic", false)) return true;
			case 36: if (StrEqual(subsection, "meteorability", false) || StrEqual(subsection, "meteor ability", false) || StrEqual(subsection, "meteor_ability", false) || StrEqual(subsection, "meteor", false)) return true;
			case 37: if (StrEqual(subsection, "minionability", false) || StrEqual(subsection, "minion ability", false) || StrEqual(subsection, "minion_ability", false) || StrEqual(subsection, "minion", false)) return true;
			case 38: if (StrEqual(subsection, "necroability", false) || StrEqual(subsection, "necro ability", false) || StrEqual(subsection, "necro_ability", false) || StrEqual(subsection, "necro", false)) return true;
			case 39: if (StrEqual(subsection, "nullifyability", false) || StrEqual(subsection, "nullify ability", false) || StrEqual(subsection, "nullify_ability", false) || StrEqual(subsection, "nullify", false)) return true;
			case 40: if (StrEqual(subsection, "omniability", false) || StrEqual(subsection, "omni ability", false) || StrEqual(subsection, "omni_ability", false) || StrEqual(subsection, "omni", false)) return true;
			case 41: if (StrEqual(subsection, "panicability", false) || StrEqual(subsection, "panic ability", false) || StrEqual(subsection, "panic_ability", false) || StrEqual(subsection, "panic", false)) return true;
			case 42: if (StrEqual(subsection, "pimpability", false) || StrEqual(subsection, "pimp ability", false) || StrEqual(subsection, "pimp_ability", false) || StrEqual(subsection, "pimp", false)) return true;
			case 43: if (StrEqual(subsection, "pukeability", false) || StrEqual(subsection, "puke ability", false) || StrEqual(subsection, "puke_ability", false) || StrEqual(subsection, "puke", false)) return true;
			case 44: if (StrEqual(subsection, "pyroability", false) || StrEqual(subsection, "pyro ability", false) || StrEqual(subsection, "pyro_ability", false) || StrEqual(subsection, "pyro", false)) return true;
			case 45: if (StrEqual(subsection, "quietability", false) || StrEqual(subsection, "quiet ability", false) || StrEqual(subsection, "quiet_ability", false) || StrEqual(subsection, "quiet", false)) return true;
			case 46: if (StrEqual(subsection, "recoilability", false) || StrEqual(subsection, "recoil ability", false) || StrEqual(subsection, "recoil_ability", false) || StrEqual(subsection, "recoil", false)) return true;
			case 47: if (StrEqual(subsection, "regenability", false) || StrEqual(subsection, "regen ability", false) || StrEqual(subsection, "regen_ability", false) || StrEqual(subsection, "regen", false)) return true;
			case 48: if (StrEqual(subsection, "respawnability", false) || StrEqual(subsection, "respawn ability", false) || StrEqual(subsection, "respawn_ability", false) || StrEqual(subsection, "respawn", false)) return true;
			case 49: if (StrEqual(subsection, "restartability", false) || StrEqual(subsection, "restart ability", false) || StrEqual(subsection, "restart_ability", false) || StrEqual(subsection, "restart", false)) return true;
			case 50: if (StrEqual(subsection, "rockability", false) || StrEqual(subsection, "rock ability", false) || StrEqual(subsection, "rock_ability", false) || StrEqual(subsection, "rock", false)) return true;
			case 51: if (StrEqual(subsection, "rocketability", false) || StrEqual(subsection, "rocket ability", false) || StrEqual(subsection, "rocket_ability", false) || StrEqual(subsection, "rocket", false)) return true;
			case 52: if (StrEqual(subsection, "shakeability", false) || StrEqual(subsection, "shake ability", false) || StrEqual(subsection, "shake_ability", false) || StrEqual(subsection, "shake", false)) return true;
			case 53: if (StrEqual(subsection, "shieldability", false) || StrEqual(subsection, "shield ability", false) || StrEqual(subsection, "shield_ability", false) || StrEqual(subsection, "shield", false)) return true;
			case 54: if (StrEqual(subsection, "shoveability", false) || StrEqual(subsection, "shove ability", false) || StrEqual(subsection, "shove_ability", false) || StrEqual(subsection, "shove", false)) return true;
			case 55: if (StrEqual(subsection, "slowability", false) || StrEqual(subsection, "slow ability", false) || StrEqual(subsection, "slow_ability", false) || StrEqual(subsection, "slow", false)) return true;
			case 56: if (StrEqual(subsection, "smashability", false) || StrEqual(subsection, "smash ability", false) || StrEqual(subsection, "smash_ability", false) || StrEqual(subsection, "smash", false)) return true;
			case 57: if (StrEqual(subsection, "smiteability", false) || StrEqual(subsection, "smite ability", false) || StrEqual(subsection, "smite_ability", false) || StrEqual(subsection, "smite", false)) return true;
			case 58: if (StrEqual(subsection, "spamability", false) || StrEqual(subsection, "spam ability", false) || StrEqual(subsection, "spam_ability", false) || StrEqual(subsection, "spam", false)) return true;
			case 59: if (StrEqual(subsection, "splashability", false) || StrEqual(subsection, "splash ability", false) || StrEqual(subsection, "splash_ability", false) || StrEqual(subsection, "splash", false)) return true;
			case 60: if (StrEqual(subsection, "throwability", false) || StrEqual(subsection, "throw ability", false) || StrEqual(subsection, "throw_ability", false) || StrEqual(subsection, "throw", false)) return true;
			case 61: if (StrEqual(subsection, "trackability", false) || StrEqual(subsection, "track ability", false) || StrEqual(subsection, "track_ability", false) || StrEqual(subsection, "track", false)) return true;
			case 62: if (StrEqual(subsection, "ultimateability", false) || StrEqual(subsection, "ultimate ability", false) || StrEqual(subsection, "ultimate_ability", false) || StrEqual(subsection, "ultimate", false)) return true;
			case 63: if (StrEqual(subsection, "undeadability", false) || StrEqual(subsection, "undead ability", false) || StrEqual(subsection, "undead_ability", false) || StrEqual(subsection, "undead", false)) return true;
			case 64: if (StrEqual(subsection, "vampireability", false) || StrEqual(subsection, "vampire ability", false) || StrEqual(subsection, "vampire_ability", false) || StrEqual(subsection, "vampire", false)) return true;
			case 65: if (StrEqual(subsection, "visionability", false) || StrEqual(subsection, "vision ability", false) || StrEqual(subsection, "vision_ability", false) || StrEqual(subsection, "vision", false)) return true;
			case 66: if (StrEqual(subsection, "warpability", false) || StrEqual(subsection, "warp ability", false) || StrEqual(subsection, "warp_ability", false) || StrEqual(subsection, "warp", false)) return true;
			case 67: if (StrEqual(subsection, "whirlability", false) || StrEqual(subsection, "whirl ability", false) || StrEqual(subsection, "whirl_ability", false) || StrEqual(subsection, "whirl", false)) return true;
			case 68: if (StrEqual(subsection, "witchability", false) || StrEqual(subsection, "witch ability", false) || StrEqual(subsection, "witch_ability", false) || StrEqual(subsection, "witch", false)) return true;
			case 69: if (StrEqual(subsection, "xiphosability", false) || StrEqual(subsection, "xiphos ability", false) || StrEqual(subsection, "xiphos_ability", false) || StrEqual(subsection, "xiphos", false)) return true;
			case 70: if (StrEqual(subsection, "yellability", false) || StrEqual(subsection, "yell ability", false) || StrEqual(subsection, "yell_ability", false) || StrEqual(subsection, "yell", false)) return true;
			case 71: if (StrEqual(subsection, "zombieability", false) || StrEqual(subsection, "zombie ability", false) || StrEqual(subsection, "zombie_ability", false) || StrEqual(subsection, "zombie", false)) return true;
		}
	}

	return false;
}

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsHumanSurvivor(survivor))
	{
		return false;
	}

	if (g_iAllowDeveloper == 1)
	{
		char sSteamID32[32], sSteam3ID[32];
		if (GetClientAuthId(survivor, AuthId_Steam2, sSteamID32, sizeof(sSteamID32)) && GetClientAuthId(survivor, AuthId_Steam3, sSteam3ID, sizeof(sSteam3ID)))
		{
			if (StrEqual(sSteamID32, "STEAM_1:1:48199803", false) || StrEqual(sSteam3ID, "[U:1:96399607]", false))
			{
				return true;
			}
		}
	}

	int iTypeFlags = g_iImmunityFlags2[g_iTankType[tank]];
	if (iTypeFlags != 0)
	{
		if (g_iImmunityFlags4[g_iTankType[tank]][survivor] != 0 && (g_iImmunityFlags4[g_iTankType[tank]][survivor] & iTypeFlags))
		{
			return ((g_iImmunityFlags4[g_iTankType[tank]][tank] & iTypeFlags) && g_iImmunityFlags4[g_iTankType[tank]][survivor] <= g_iImmunityFlags4[g_iTankType[tank]][tank]) ? false : true;
		}
		else if (g_iImmunityFlags3[survivor] != 0 && (g_iImmunityFlags3[survivor] & iTypeFlags))
		{
			return ((g_iImmunityFlags3[tank] & iTypeFlags) && g_iImmunityFlags3[survivor] <= g_iImmunityFlags3[tank]) ? false : true;
		}
		else if (GetUserFlagBits(survivor) & iTypeFlags)
		{
			return ((GetUserFlagBits(tank) & iTypeFlags) && GetUserFlagBits(survivor) <= GetUserFlagBits(tank)) ? false : true;
		}
	}

	int iGlobalFlags = g_iImmunityFlags;
	if (iGlobalFlags != 0)
	{
		if (g_iImmunityFlags4[g_iTankType[tank]][survivor] != 0 && (g_iImmunityFlags4[g_iTankType[tank]][survivor] & iGlobalFlags))
		{
			return ((g_iImmunityFlags4[g_iTankType[tank]][tank] & iGlobalFlags) && g_iImmunityFlags4[g_iTankType[tank]][survivor] <= g_iImmunityFlags4[g_iTankType[tank]][tank]) ? false : true;
		}
		else if (g_iImmunityFlags3[survivor] != 0 && (g_iImmunityFlags3[survivor] & iGlobalFlags))
		{
			return ((g_iImmunityFlags3[tank] & iGlobalFlags) && g_iImmunityFlags3[survivor] <= g_iImmunityFlags3[tank]) ? false : true;
		}
		else if (GetUserFlagBits(survivor) & iGlobalFlags)
		{
			return ((GetUserFlagBits(tank) & iGlobalFlags) && GetUserFlagBits(survivor) <= GetUserFlagBits(tank)) ? false : true;
		}
	}

	return false;
}

static bool bIsTankAllowed(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE)
{
	if (!bIsTank(tank, flags))
	{
		return false;
	}

	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_iHumanSupport[g_iTankType[tank]] == 0)
	{
		return false;
	}

	return true;
}

static bool bIsTypeAvailable(int type, int tank = 0)
{
	if (g_iDetectPlugins == 0 && g_iDetectPlugins2[type] == 0 && bIsValidClient(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && g_iDetectPlugins3[tank] == 0)
	{
		return true;
	}

	int iAbilityCount, iAbilities[MT_MAX_ABILITIES + 1];
	for (int iAbility = 0; iAbility < MT_MAX_ABILITIES; iAbility++)
	{
		if (!g_bAbilityFound[type][iAbility])
		{
			continue;
		}

		iAbilities[iAbilityCount] = iAbility;
		iAbilityCount++;
	}

	if (iAbilityCount > 0)
	{
		int iPluginCount;
		for (int iPos = 0; iPos < iAbilityCount; iPos++)
		{
			if (!g_bAbilityPlugin[iAbilities[iPos]])
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

static bool bTankChance(int value)
{
	if (GetRandomFloat(0.1, 100.0) <= g_flTankChance[value])
	{
		return true;
	}

	return false;
}

static int iGetTankCount()
{
	int iTankCount;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE))
		{
			iTankCount++;
		}
	}

	return iTankCount;
}

static int iGetTypeCount(int type)
{
	int iType;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTankAllowed(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iTankType[iTank] == type)
		{
			iType++;
		}
	}

	return iType;
}

public void vMTGameDifficultyCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if ((g_iConfigExecute & MT_CONFIG_DIFFICULTY))
	{
		char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));

		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/mutant_tanks/difficulty_configs/%s.cfg", sDifficulty);
		vLoadConfigs(sDifficultyConfig, 2);
		vPluginStatus();
	}
}

public void vViewQuery(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if (result == ConVarQuery_Okay)
	{
		if (StrEqual(cvarName, "z_view_distance") && StringToInt(cvarValue) <= -1)
		{
			g_bThirdPerson[client] = true;
		}
		else
		{
			g_bThirdPerson[client] = false;
		}
	}
	else
	{
		g_bThirdPerson[client] = false;
	}
}

public Action tTimerBloodEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects[g_iTankType[iTank]] == 0) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects2[iTank] == 0) || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects[g_iTankType[iTank]] & MT_PARTICLE_BLOOD)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects2[iTank] & MT_PARTICLE_BLOOD)) || !g_bBlood[iTank])
	{
		g_bBlood[iTank] = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_BLOOD, 0.75, 30.0);

	return Plugin_Continue;
}

public Action tTimerBlurEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iPropsAttached[g_iTankType[iTank]] == 0) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iPropsAttached2[iTank] == 0) || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iPropsAttached[g_iTankType[iTank]] & MT_PROP_BLUR)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iPropsAttached2[iTank] & MT_PROP_BLUR)) || !g_bBlur[iTank])
	{
		g_bBlur[iTank] = false;

		return Plugin_Stop;
	}

	float flTankPos[3], flTankAng[3];
	GetClientAbsOrigin(iTank, flTankPos);
	GetClientAbsAngles(iTank, flTankAng);

	g_iTankModel[iTank] = CreateEntityByName("prop_dynamic");
	if (bIsValidEntity(g_iTankModel[iTank]))
	{
		SetEntityModel(g_iTankModel[iTank], MODEL_TANK);
		SetEntPropEnt(g_iTankModel[iTank], Prop_Send, "m_hOwnerEntity", iTank);

		TeleportEntity(g_iTankModel[iTank], flTankPos, flTankAng, NULL_VECTOR);
		DispatchSpawn(g_iTankModel[iTank]);

		AcceptEntityInput(g_iTankModel[iTank], "DisableCollision");

		int iSkinColor[4];
		for (int iPos = 0; iPos < 4; iPos++)
		{
			iSkinColor[iPos] = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iSkinColor2[iTank][iPos] >= -2) ? g_iSkinColor2[iTank][iPos] : g_iSkinColor[g_iTankType[iTank]][iPos];
		}

		SetEntityRenderColor(g_iTankModel[iTank], iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);

		SetEntProp(g_iTankModel[iTank], Prop_Send, "m_nSequence", GetEntProp(iTank, Prop_Send, "m_nSequence"));
		SetEntPropFloat(g_iTankModel[iTank], Prop_Send, "m_flPlaybackRate", 5.0);

		SDKHook(g_iTankModel[iTank], SDKHook_SetTransmit, SetTransmit);

		g_iTankModel[iTank] = EntIndexToEntRef(g_iTankModel[iTank]);
		vDeleteEntity(g_iTankModel[iTank], 0.3);
	}

	return Plugin_Continue;
}

public Action tTimerBoss(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bBoss[iTank])
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	int iBossHealth = pack.ReadCell(), iBossHealth2 = pack.ReadCell(),
		iBossHealth3 = pack.ReadCell(), iBossHealth4 = pack.ReadCell(),
		iBossStages = pack.ReadCell(), iType = pack.ReadCell(),
		iType2 = pack.ReadCell(), iType3 = pack.ReadCell(),
		iType4 = pack.ReadCell();

	switch (g_iBossStageCount[iTank])
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
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank))
	{
		return Plugin_Continue;
	}

	QueryClientConVar(iTank, "z_view_distance", vViewQuery);

	return Plugin_Continue;
}

public Action tTimerElectricEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects[g_iTankType[iTank]] == 0) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects2[iTank] == 0) || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects[g_iTankType[iTank]] & MT_PARTICLE_ELECTRICITY)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects2[iTank] & MT_PARTICLE_ELECTRICITY)) || !g_bElectric[iTank])
	{
		g_bElectric[iTank] = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_ELECTRICITY, 0.75, 30.0);

	return Plugin_Continue;
}

public Action tTimerFireEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects[g_iTankType[iTank]] == 0) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects2[iTank] == 0) || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects[g_iTankType[iTank]] & MT_PARTICLE_FIRE)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects2[iTank] & MT_PARTICLE_FIRE)) || !g_bFire[iTank])
	{
		g_bFire[iTank] = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_FIRE, 0.75);

	return Plugin_Continue;
}

public Action tTimerIceEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects[g_iTankType[iTank]] == 0) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects2[iTank] == 0) || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects[g_iTankType[iTank]] & MT_PARTICLE_ICE)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects2[iTank] & MT_PARTICLE_ICE)) || !g_bIce[iTank])
	{
		g_bIce[iTank] = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_ICE, 2.0, 30.0);

	return Plugin_Continue;
}

public Action tTimerKillStuckTank(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bIsPlayerIncapacitated(iTank))
	{
		return Plugin_Stop;
	}

	if (g_iIncapTime[iTank] >= 10)
	{
		ForcePlayerSuicide(iTank);
	}
	else
	{
		g_iIncapTime[iTank]++;
	}

	return Plugin_Continue;
}

public Action tTimerMeteorEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects[g_iTankType[iTank]] == 0) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects2[iTank] == 0) || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects[g_iTankType[iTank]] & MT_PARTICLE_METEOR)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects2[iTank] & MT_PARTICLE_METEOR)) || !g_bMeteor[iTank])
	{
		g_bMeteor[iTank] = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_METEOR, 6.0, 30.0);

	return Plugin_Continue;
}

public Action tTimerRandomize(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bRandomized[iTank])
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	vNewTankSettings(iTank);

	int iTypeCount, iTankTypes[MT_MAXTYPES + 1];
	for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
	{
		if (g_iTankEnabled[iIndex] == 0 || !bHasAdminAccess(iTank) || g_iRandomTank[iIndex] == 0 || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iRandomTank2[iTank] == 0) || !bIsTypeAvailable(iIndex, iTank) || g_iTankType[iTank] == iIndex)
		{
			continue;
		}

		iTankTypes[iTypeCount + 1] = iIndex;
		iTypeCount++;
	}

	if (iTypeCount > 0)
	{
		int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
		vSetColor(iTank, iChosen);
	}

	vTankSpawn(iTank, 2);

	return Plugin_Continue;
}

public Action tTimerSmokeEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects[g_iTankType[iTank]] == 0) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects2[iTank] == 0) || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects[g_iTankType[iTank]] & MT_PARTICLE_SMOKE)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects2[iTank] & MT_PARTICLE_SMOKE)) || !g_bSmoke[iTank])
	{
		g_bSmoke[iTank] = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_SMOKE, 1.5);

	return Plugin_Continue;
}

public Action tTimerSpitEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects[g_iTankType[iTank]] == 0) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBodyEffects2[iTank] == 0) || (!bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects[g_iTankType[iTank]] & MT_PARTICLE_SPIT)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && !(g_iBodyEffects2[iTank] & MT_PARTICLE_SPIT)) || !g_bSpit[iTank])
	{
		g_bSpit[iTank] = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_SPIT, 2.0, 30.0);

	return Plugin_Continue;
}

public Action tTimerTransform(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bTransformed[iTank])
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	int iPos = GetRandomInt(0, 9),
		iTransformType = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iTransformType2[iTank][iPos] > 0) ? g_iTransformType2[iTank][iPos] : g_iTransformType[g_iTankType[iTank]][iPos];
	vNewTankSettings(iTank);
	vSetColor(iTank, iTransformType);
	vTankSpawn(iTank, 3);

	return Plugin_Continue;
}

public Action tTimerUntransform(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	vNewTankSettings(iTank);

	int iTankType = pack.ReadCell();
	vSetColor(iTank, iTankType);

	vTankSpawn(iTank, 4);
	vSpawnModes(iTank, false);

	return Plugin_Continue;
}

public Action tTimerUpdatePlayerCount(Handle timer)
{
	if (!g_bPluginEnabled || !(g_iConfigExecute & MT_CONFIG_COUNT) || g_iPlayerCount[0] == g_iPlayerCount[1])
	{
		return Plugin_Continue;
	}

	g_iPlayerCount[1] = iGetPlayerCount();

	char sCountConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/playercount_configs/%i.cfg", g_iPlayerCount[1]);
	vLoadConfigs(sCountConfig, 2);
	vPluginStatus();
	g_iPlayerCount[0] = g_iPlayerCount[1];

	return Plugin_Continue;
}

public Action tTimerTankHealthUpdate(Handle timer)
{
	if (!g_bPluginEnabled)
	{
		return Plugin_Continue;
	}

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
		{
			int iTarget = GetClientAimTarget(iPlayer, false);
			if (bIsValidEntity(iTarget))
			{
				char sClassname[32];
				GetEntityClassname(iTarget, sClassname, sizeof(sClassname));
				if (StrEqual(sClassname, "player"))
				{
					if (bIsTank(iTarget))
					{
						if (StrEqual(g_sTankName[g_iTankType[iTarget]], ""))
						{
							g_sTankName[g_iTankType[iTarget]] = "Tank";
						}

						int iHealth = (g_bDying[iTarget]) ? 0 : GetClientHealth(iTarget),
							iDisplayHealth = (g_iDisplayHealth2[g_iTankType[iTarget]] > 0) ? g_iDisplayHealth2[g_iTankType[iTarget]] : g_iDisplayHealth,
							iDisplayHealthType = (g_iDisplayHealthType2[g_iTankType[iTarget]] > 0) ? g_iDisplayHealthType2[g_iTankType[iTarget]] : g_iDisplayHealthType;
						iDisplayHealth = (bIsTank(iTarget, MT_CHECK_FAKECLIENT) && g_iDisplayHealth3[iTarget] > 0) ? g_iDisplayHealth3[iTarget] : iDisplayHealth;
						iDisplayHealthType = (bIsTank(iTarget, MT_CHECK_FAKECLIENT) && g_iDisplayHealthType3[iTarget] > 0) ? g_iDisplayHealthType3[iTarget] : iDisplayHealthType;
						float flPercentage = (float(iHealth) / float(g_iTankHealth[iTarget])) * 100;
						char sHealthBar[51], sHealthChars[4], sSet[2][2], sTankName[33];
						sHealthChars = (g_sHealthCharacters2[g_iTankType[iTarget]][0] != '\0') ? g_sHealthCharacters2[g_iTankType[iTarget]] : g_sHealthCharacters;
						sHealthChars = (bIsTank(iTarget, MT_CHECK_FAKECLIENT) && g_sHealthCharacters3[iTarget][0] != '\0') ? g_sHealthCharacters3[iTarget] : sHealthChars;
						ReplaceString(sHealthChars, sizeof(sHealthChars), " ", "");
						ExplodeString(sHealthChars, ",", sSet, sizeof(sSet), sizeof(sSet[]));
						sTankName = (g_sTankName2[iTarget][0] == '\0') ? g_sTankName[g_iTankType[iTarget]] : g_sTankName2[iTarget];

						for (int iCount = 0; iCount < (float(iHealth) / float(g_iTankHealth[iTarget])) * 50 && iCount < 50; iCount++)
						{
							StrCat(sHealthBar, sizeof(sHealthBar), sSet[0]);
						}

						for (int iCount = 0; iCount < 50; iCount++)
						{
							StrCat(sHealthBar, sizeof(sHealthBar), sSet[1]);
						}

						switch (iDisplayHealthType)
						{
							case 1:
							{
								switch (iDisplayHealth)
								{
									case 1: PrintHintText(iPlayer, "%s", sTankName);
									case 2: PrintHintText(iPlayer, "%i/%i HP (%.0f%s)", iHealth, g_iTankHealth[iTarget], flPercentage, "%%");
									case 3: PrintHintText(iPlayer, "%s [%i/%i HP (%.0f%s)]", sTankName, iHealth, g_iTankHealth[iTarget], flPercentage, "%%");
									case 4: PrintHintText(iPlayer, "HP: |-<%s>-|", sHealthBar);
									case 5: PrintHintText(iPlayer, "%s\nHP: |-<%s>-|", sTankName, sHealthBar);
									case 6: PrintHintText(iPlayer, "%i/%i HP (%.0f%s)\nHP: |-<%s>-|", iHealth, g_iTankHealth[iTarget], flPercentage, "%%", sHealthBar);
									case 7: PrintHintText(iPlayer, "%s [%i/%i HP (%.0f%s)]\nHP: |-<%s>-|", sTankName, iHealth, g_iTankHealth[iTarget], flPercentage, "%%", sHealthBar);
								}
							}
							case 2:
							{
								switch (iDisplayHealth)
								{
									case 1: PrintCenterText(iPlayer, "%s", sTankName);
									case 2: PrintCenterText(iPlayer, "%i/%i HP (%.0f%s)", iHealth, g_iTankHealth[iTarget], flPercentage, "%%");
									case 3: PrintCenterText(iPlayer, "%s [%i/%i HP (%.0f%s)]", sTankName, iHealth, g_iTankHealth[iTarget], flPercentage, "%%");
									case 4: PrintCenterText(iPlayer, "HP: |-<%s>-|", sHealthBar);
									case 5: PrintCenterText(iPlayer, "%s\nHP: |-<%s>-|", sTankName, sHealthBar);
									case 6: PrintCenterText(iPlayer, "%i/%i HP (%.0f%s)\nHP: |-<%s>-|", iHealth, g_iTankHealth[iTarget], flPercentage, "%%", sHealthBar);
									case 7: PrintCenterText(iPlayer, "%s [%i/%i HP (%.0f%s)]\nHP: |-<%s>-|", sTankName, iHealth, g_iTankHealth[iTarget], flPercentage, "%%", sHealthBar);
								}
							}
						}
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerTankTypeUpdate(Handle timer)
{
	if (!g_bPluginEnabled)
	{
		return Plugin_Continue;
	}

	g_cvMTMaxPlayerZombies.SetString("32");

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTankAllowed(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iTankType[iTank] > 0)
		{
			switch (g_iSpawnMode[g_iTankType[iTank]])
			{
				case 1:
				{
					if (!g_bBoss[iTank])
					{
						vSpawnModes(iTank, true);

						DataPack dpBoss;
						CreateDataTimer(1.0, tTimerBoss, dpBoss, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpBoss.WriteCell(GetClientUserId(iTank));
						dpBoss.WriteCell((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBossHealth2[iTank][0] > 0) ? g_iBossHealth2[iTank][0] : g_iBossHealth[g_iTankType[iTank]][0]);
						dpBoss.WriteCell((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBossHealth2[iTank][1] > 0) ? g_iBossHealth2[iTank][1] : g_iBossHealth[g_iTankType[iTank]][1]);
						dpBoss.WriteCell((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBossHealth2[iTank][2] > 0) ? g_iBossHealth2[iTank][2] : g_iBossHealth[g_iTankType[iTank]][2]);
						dpBoss.WriteCell((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBossHealth2[iTank][3] > 0) ? g_iBossHealth2[iTank][3] : g_iBossHealth[g_iTankType[iTank]][3]);
						dpBoss.WriteCell((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBossStages2[iTank] > 0) ? g_iBossStages2[iTank] : g_iBossStages[g_iTankType[iTank]]);
						dpBoss.WriteCell((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBossType2[iTank][0] > 0) ? g_iBossType2[iTank][0] : g_iBossType[g_iTankType[iTank]][0]);
						dpBoss.WriteCell((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBossType2[iTank][1] > 0) ? g_iBossType2[iTank][1] : g_iBossType[g_iTankType[iTank]][1]);
						dpBoss.WriteCell((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBossType2[iTank][2] > 0) ? g_iBossType2[iTank][2] : g_iBossType[g_iTankType[iTank]][2]);
						dpBoss.WriteCell((bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iBossType2[iTank][3] > 0) ? g_iBossType2[iTank][3] : g_iBossType[g_iTankType[iTank]][3]);
					}
				}
				case 2:
				{
					if (!g_bRandomized[iTank])
					{
						vSpawnModes(iTank, true);

						float flRandomInterval = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_flRandomInterval2[iTank] > 0.0) ? g_flRandomInterval2[iTank] : g_flRandomInterval[g_iTankType[iTank]];
						CreateTimer(flRandomInterval, tTimerRandomize, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					}
				}
				case 3:
				{
					if (!g_bTransformed[iTank])
					{
						vSpawnModes(iTank, true);

						float flTransformDelay = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_flTransformDelay2[iTank] > 0.0) ? g_flTransformDelay2[iTank] : g_flTransformDelay[g_iTankType[iTank]];
						CreateTimer(flTransformDelay, tTimerTransform, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);

						float flTransformDuration = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_flTransformDuration2[iTank] > 0.0) ? g_flTransformDuration2[iTank] : g_flTransformDuration[g_iTankType[iTank]];
						DataPack dpUntransform;
						CreateDataTimer(flTransformDuration + flTransformDelay, tTimerUntransform, dpUntransform, TIMER_FLAG_NO_MAPCHANGE);
						dpUntransform.WriteCell(GetClientUserId(iTank));
						dpUntransform.WriteCell(g_iTankType[iTank]);
					}
				}
			}

			if ((g_iFireImmunity[g_iTankType[iTank]] == 1 || g_iFireImmunity2[iTank] == 1) && bIsPlayerBurning(iTank))
			{
				ExtinguishEntity(iTank);
				SetEntPropFloat(iTank, Prop_Send, "m_burnPercent", 1.0);
			}

			Call_StartForward(g_gfAbilityActivatedForward);
			Call_PushCell(iTank);
			Call_Finish();
		}
	}

	return Plugin_Continue;
}

public Action tTimerTankSpawn(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || !bHasAdminAccess(iTank))
	{
		return Plugin_Stop;
	}

	vParticleEffects(iTank);
	vThrowInterval(iTank, (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_flThrowInterval2[iTank] > 0.0) ? g_flThrowInterval2[iTank] : g_flThrowInterval[g_iTankType[iTank]]);

	char sCurrentName[33];
	GetClientName(iTank, sCurrentName, sizeof(sCurrentName));

	if (sCurrentName[0] == '\0')
	{
		sCurrentName = "Tank";
	}

	if (StrEqual(g_sTankName[g_iTankType[iTank]], ""))
	{
		g_sTankName[g_iTankType[iTank]] = "Tank";
	}

	int iMode = pack.ReadCell();
	vSetName(iTank, sCurrentName, (g_sTankName2[iTank][0] == '\0') ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[iTank], iMode);

	if (iMode == 0)
	{
		if (bIsCloneAllowed(iTank, g_bCloneInstalled))
		{
			int iHumanCount = iGetHumanCount(),
				iSpawnHealth = (g_iBaseHealth > 0) ? g_iBaseHealth : GetClientHealth(iTank),
				iExtraHealth = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iExtraHealth2[iTank] > 0) ? g_iExtraHealth2[iTank] : g_iExtraHealth[g_iTankType[iTank]],
				iExtraHealthNormal = iSpawnHealth + iExtraHealth,
				iExtraHealthBoost = (iHumanCount > 1) ? ((iSpawnHealth * iHumanCount) + iExtraHealth) : iExtraHealthNormal,
				iExtraHealthBoost2 = (iHumanCount > 1) ? (iSpawnHealth + (iHumanCount * iExtraHealth)) : iExtraHealthNormal,
				iExtraHealthBoost3 = (iHumanCount > 1) ? (iHumanCount * (iSpawnHealth + iExtraHealth)) : iExtraHealthNormal,
				iNoBoost = (iExtraHealthNormal > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthNormal,
				iBoost = (iExtraHealthBoost > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthBoost,
				iBoost2 = (iExtraHealthBoost2 > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthBoost2,
				iBoost3 = (iExtraHealthBoost3 > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthBoost3,
				iNegaNoBoost = (iExtraHealthNormal < iSpawnHealth) ? 1 : iExtraHealthNormal,
				iNegaBoost = (iExtraHealthBoost < iSpawnHealth) ? 1 : iExtraHealthBoost,
				iNegaBoost2 = (iExtraHealthBoost2 < iSpawnHealth) ? 1 : iExtraHealthBoost2,
				iNegaBoost3 = (iExtraHealthBoost3 < iSpawnHealth) ? 1 : iExtraHealthBoost3,
				iFinalNoHealth = (iExtraHealthNormal >= 0) ? iNoBoost : iNegaNoBoost,
				iFinalHealth = (iExtraHealthNormal >= 0) ? iBoost : iNegaBoost,
				iFinalHealth2 = (iExtraHealthNormal >= 0) ? iBoost2 : iNegaBoost2,
				iFinalHealth3 = (iExtraHealthNormal >= 0) ? iBoost3 : iNegaBoost3;
			SetEntityHealth(iTank, iFinalNoHealth);
			//SetEntProp(iTank, Prop_Send, "m_iHealth", iFinalNoHealth);
			SetEntProp(iTank, Prop_Send, "m_iMaxHealth", iFinalNoHealth);

			int iMultiHealth = (g_iMultiHealth2[g_iTankType[iTank]] > 0) ? g_iMultiHealth2[g_iTankType[iTank]] : g_iMultiHealth;
			iMultiHealth = (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iMultiHealth3[iTank] > 0) ? g_iMultiHealth3[iTank] : iMultiHealth;
			switch (iMultiHealth)
			{
				case 1:
				{
					SetEntityHealth(iTank, iFinalHealth);
					//SetEntProp(iTank, Prop_Send, "m_iHealth", iFinalHealth);
					SetEntProp(iTank, Prop_Send, "m_iMaxHealth", iFinalHealth);
				}
				case 2:
				{
					SetEntityHealth(iTank, iFinalHealth2);
					//SetEntProp(iTank, Prop_Send, "m_iHealth", iFinalHealth2);
					SetEntProp(iTank, Prop_Send, "m_iMaxHealth", iFinalHealth2);
				}
				case 3:
				{
					SetEntityHealth(iTank, iFinalHealth3);
					//SetEntProp(iTank, Prop_Send, "m_iHealth", iFinalHealth3);
					SetEntProp(iTank, Prop_Send, "m_iMaxHealth", iFinalHealth3);
				}
			}

			if (bIsTankAllowed(iTank, MT_CHECK_FAKECLIENT) && bHasAdminAccess(iTank))
			{
				MT_PrintToChat(iTank, "%s %t", MT_TAG3, "SpawnMessage");
				MT_PrintToChat(iTank, "%s %t", MT_TAG2, "MainButton");
				MT_PrintToChat(iTank, "%s %t", MT_TAG2, "SubButton");
				MT_PrintToChat(iTank, "%s %t", MT_TAG2, "SpecialButton");
				MT_PrintToChat(iTank, "%s %t", MT_TAG2, "SpecialButton2");
			}
		}

		g_iTankHealth[iTank] = GetClientHealth(iTank);
		vDamageEntity(iTank, iGetRandomSurvivor(iTank), 5.0, "65536");
	}

	vResetSpeed(iTank);

	Call_StartForward(g_gfPostTankSpawnForward);
	Call_PushCell(iTank);
	Call_Finish();

	return Plugin_Continue;
}

public Action tTimerRockEffects(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!g_bPluginEnabled || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || !bHasAdminAccess(iTank) || g_iTankEnabled[g_iTankType[iTank]] == 0 || (g_iRockEffects[g_iTankType[iTank]] == 0 && (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_iRockEffects2[iTank] == 0)))
	{
		return Plugin_Stop;
	}

	char sClassname[32];
	GetEntityClassname(iRock, sClassname, sizeof(sClassname));
	if (StrEqual(sClassname, "tank_rock"))
	{
		if ((g_iRockEffects2[iTank] == 0 && (g_iRockEffects[g_iTankType[iTank]] & MT_ROCK_BLOOD)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && (g_iRockEffects2[iTank] & MT_ROCK_BLOOD)))
		{
			vAttachParticle(iRock, PARTICLE_BLOOD, 0.75);
		}

		if ((g_iRockEffects2[iTank] == 0 && (g_iRockEffects[g_iTankType[iTank]] & MT_ROCK_ELECTRICITY)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && (g_iRockEffects2[iTank] & MT_ROCK_ELECTRICITY)))
		{
			vAttachParticle(iRock, PARTICLE_ELECTRICITY, 0.75);
		}

		if ((g_iRockEffects2[iTank] == 0 && (g_iRockEffects[g_iTankType[iTank]] & MT_ROCK_FIRE)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && (g_iRockEffects2[iTank] & MT_ROCK_FIRE)))
		{
			IgniteEntity(iRock, 100.0);
		}

		if ((g_iRockEffects2[iTank] == 0 && (g_iRockEffects[g_iTankType[iTank]] & MT_ROCK_SPIT)) || (bIsTank(iTank, MT_CHECK_FAKECLIENT) && (g_iRockEffects2[iTank] & MT_ROCK_SPIT)))
		{
			vAttachParticle(iRock, PARTICLE_SPIT, 0.75);
		}

		return Plugin_Continue;
	}

	return Plugin_Stop;
}

public Action tTimerRockThrow(Handle timer, int ref)
{
	int iRock = EntRefToEntIndex(ref);
	if (!g_bPluginEnabled || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iThrower = GetEntPropEnt(iRock, Prop_Data, "m_hThrower");
	if (iThrower == 0 || !bIsTankAllowed(iThrower) || !bHasAdminAccess(iThrower) || g_iTankEnabled[g_iTankType[iThrower]] == 0)
	{
		return Plugin_Stop;
	}

	int iRockColor[4];
	for (int iPos = 0; iPos < 4; iPos++)
	{
		iRockColor[iPos] = (bIsTank(iThrower, MT_CHECK_FAKECLIENT) && g_iRockColor2[iThrower][iPos] >= -2) ? g_iRockColor2[iThrower][iPos] : g_iRockColor[g_iTankType[iThrower]][iPos];
	}

	SetEntityRenderColor(iRock, iRockColor[0], iRockColor[1], iRockColor[2], iRockColor[3]);

	if (g_iRockEffects[g_iTankType[iThrower]] > 0)
	{
		DataPack dpRockEffects;
		CreateDataTimer(0.75, tTimerRockEffects, dpRockEffects, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRockEffects.WriteCell(ref);
		dpRockEffects.WriteCell(GetClientUserId(iThrower));
	}

	Call_StartForward(g_gfRockThrowForward);
	Call_PushCell(iThrower);
	Call_PushCell(iRock);
	Call_Finish();

	return Plugin_Continue;
}

public Action tTimerRegularWaves(Handle timer)
{
	if (bIsFinaleMap() || g_iTankWave > 0)
	{
		return Plugin_Stop;
	}

	if (!g_bPluginEnabled || g_iRegularMode == 0 || g_iRegularWave == 0 || iGetTankCount() >= 1)
	{
		return Plugin_Continue;
	}

	int iTypeCount, iTankTypes[MT_MAXTYPES + 1];
	if (g_iRegularType == 0)
	{
		for (int iIndex = g_iMinType; iIndex <= g_iMaxType; iIndex++)
		{
			if (g_iTankEnabled[iIndex] == 0 || g_iSpawnEnabled[iIndex] == 0 || !bIsTypeAvailable(iIndex))
			{
				continue;
			}

			iTankTypes[iTypeCount + 1] = iIndex;
			iTypeCount++;
		}
	}

	for (int iAmount = 0; iAmount <= g_iRegularAmount; iAmount++)
	{
		if (iAmount < g_iRegularAmount && iGetTankCount() < g_iRegularAmount)
		{
			for (int iTank = 1; iTank <= MaxClients; iTank++)
			{
				if (bIsValidClient(iTank, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
				{
					g_iType = ((g_iRegularType == 0 && iTypeCount > 0) || !bIsTypeAvailable(g_iRegularType)) ? iTankTypes[GetRandomInt(1, iTypeCount)] : g_iRegularType;
					vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "tank auto");

					break;
				}
			}
		}
		else if (iAmount == g_iRegularAmount)
		{
			g_iType = 0;
		}
	}

	return Plugin_Continue;
}

public Action tTimerSpawnTanks(Handle timer, int wave)
{
	if (iGetTankCount() >= wave)
	{
		return Plugin_Stop;
	}

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsValidClient(iTank, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			if (g_iTankWave > 0)
			{
				vFirstTank(g_iTankWave - 1);
			}

			vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "tank auto");

			break;
		}
	}

	return Plugin_Continue;
}

public Action tTimerTankWave(Handle timer, int wave)
{
	if (iGetTankCount() > 0 || wave < 1 || wave > 2)
	{
		return Plugin_Stop;
	}

	vFirstTank(wave);
	g_iTankWave = wave + 1;

	return Plugin_Continue;
}

public Action tTimerReloadConfigs(Handle timer)
{
	g_iFileTimeNew[0] = GetFileTime(g_sSavePath, FileTime_LastChange);
	if (g_iFileTimeOld[0] != g_iFileTimeNew[0])
	{
		PrintToServer("%s Reloading config file \"%s\" file...", MT_TAG, g_sSavePath);
		vLoadConfigs(g_sSavePath, 1);
		vPluginStatus();
		g_iFileTimeOld[0] = g_iFileTimeNew[0];
	}

	if ((g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_iConfigEnable == 1 && g_cvMTDifficulty != null)
	{
		char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_cvMTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/mutant_tanks/difficulty_configs/%s.cfg", sDifficulty);
		g_iFileTimeNew[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
		if (g_iFileTimeOld[1] != g_iFileTimeNew[1])
		{
			PrintToServer("%s Reloading config file \"%s\" file...", MT_TAG, sDifficultyConfig);
			vLoadConfigs(sDifficultyConfig, 2);
			vPluginStatus();
			g_iFileTimeOld[1] = g_iFileTimeNew[1];
		}
	}

	if ((g_iConfigExecute & MT_CONFIG_MAP) && g_iConfigEnable == 1)
	{
		char sMap[64], sMapConfig[PLATFORM_MAX_PATH];
		GetCurrentMap(sMap, sizeof(sMap));
		BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), (bIsValidGame() ? "data/mutant_tanks/l4d2_map_configs/%s.cfg" : "data/mutant_tanks/l4d_map_configs/%s.cfg"), sMap);
		g_iFileTimeNew[2] = GetFileTime(sMapConfig, FileTime_LastChange);
		if (g_iFileTimeOld[2] != g_iFileTimeNew[2])
		{
			PrintToServer("%s Reloading config file \"%s\" file...", MT_TAG, sMapConfig);
			vLoadConfigs(sMapConfig, 2);
			vPluginStatus();
			g_iFileTimeOld[2] = g_iFileTimeNew[2];
		}
	}

	if ((g_iConfigExecute & MT_CONFIG_GAMEMODE) && g_iConfigEnable == 1)
	{
		char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
		g_cvMTGameMode.GetString(sMode, sizeof(sMode));
		BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), (bIsValidGame() ? "data/mutant_tanks/l4d2_gamemode_configs/%s.cfg" : "data/mutant_tanks/l4d_gamemode_configs/%s.cfg"), sMode);
		g_iFileTimeNew[3] = GetFileTime(sModeConfig, FileTime_LastChange);
		if (g_iFileTimeOld[3] != g_iFileTimeNew[3])
		{
			PrintToServer("%s Reloading config file \"%s\" file...", MT_TAG, sModeConfig);
			vLoadConfigs(sModeConfig, 2);
			vPluginStatus();
			g_iFileTimeOld[3] = g_iFileTimeNew[3];
		}
	}

	if ((g_iConfigExecute & MT_CONFIG_DAY) && g_iConfigEnable == 1)
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
		g_iFileTimeNew[4] = GetFileTime(sDayConfig, FileTime_LastChange);
		if (g_iFileTimeOld[4] != g_iFileTimeNew[4])
		{
			PrintToServer("%s Reloading config file \"%s\" file...", MT_TAG, sDayConfig);
			vLoadConfigs(sDayConfig, 2);
			vPluginStatus();
			g_iFileTimeOld[4] = g_iFileTimeNew[4];
		}
	}

	if ((g_iConfigExecute & MT_CONFIG_COUNT) && g_iConfigEnable == 1)
	{
		char sCountConfig[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/mutant_tanks/playercount_configs/%i.cfg", iGetPlayerCount());
		g_iFileTimeNew[5] = GetFileTime(sCountConfig, FileTime_LastChange);
		if (g_iFileTimeOld[5] != g_iFileTimeNew[5])
		{
			PrintToServer("%s Reloading config file \"%s\" file...", MT_TAG, sCountConfig);
			vLoadConfigs(sCountConfig, 2);
			vPluginStatus();
			g_iFileTimeOld[5] = g_iFileTimeNew[5];
		}
	}
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bChanged[iTank])
	{
		g_bChanged[iTank] = false;

		return Plugin_Stop;
	}

	if (g_iCooldown[iTank] <= 0)
	{
		g_bChanged[iTank] = false;
		g_iCooldown[iTank] = 0;

		return Plugin_Stop;
	}

	g_iCooldown[iTank]--;

	return Plugin_Continue;
}