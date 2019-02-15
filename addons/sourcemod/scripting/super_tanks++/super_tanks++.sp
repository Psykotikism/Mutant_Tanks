/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
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
#include <super_tanks++>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Super Tanks++",
	author = ST_AUTHOR,
	description = "Super Tanks++ makes fighting Tanks great again!",
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
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

#define SOUND_BOSS "items/suitchargeok1.wav"

bool g_bAdminMenu[MAXPLAYERS + 1], g_bBlood[MAXPLAYERS + 1], g_bBlur[MAXPLAYERS + 1], g_bBoss[MAXPLAYERS + 1], g_bChanged[MAXPLAYERS + 1], g_bCloneInstalled, g_bElectric[MAXPLAYERS + 1], g_bFire[MAXPLAYERS + 1], g_bGeneralConfig, g_bIce[MAXPLAYERS + 1], g_bLateLoad, g_bMeteor[MAXPLAYERS + 1], g_bNeedHealth[MAXPLAYERS + 1], g_bPluginEnabled,
	g_bRandomized[MAXPLAYERS + 1], g_bSmoke[MAXPLAYERS + 1], g_bSpawned[MAXPLAYERS + 1], g_bSpit[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1], g_bThirdPerson[MAXPLAYERS + 1], g_bTransformed[MAXPLAYERS + 1];

char g_sAnnounceArrival[6], g_sAnnounceArrival2[6], g_sBossHealthStages[ST_MAXTYPES + 1][25], g_sBossHealthStages2[ST_MAXTYPES + 1][25], g_sBossTypes[ST_MAXTYPES + 1][20], g_sBossTypes2[ST_MAXTYPES + 1][20], g_sConfigCreate[6], g_sConfigExecute[6], g_sDisabledGameModes[513], g_sEnabledGameModes[513], g_sFinaleWaves[9], g_sFinaleWaves2[9],
	g_sParticleEffects[ST_MAXTYPES + 1][8], g_sParticleEffects2[ST_MAXTYPES + 1][8], g_sPropsAttached[ST_MAXTYPES + 1][7], g_sPropsAttached2[ST_MAXTYPES + 1][7], g_sPropsChance[ST_MAXTYPES + 1][35], g_sPropsChance2[ST_MAXTYPES + 1][35], g_sRockEffects[ST_MAXTYPES + 1][5], g_sRockEffects2[ST_MAXTYPES + 1][5], g_sSavePath[PLATFORM_MAX_PATH],
	g_sTankName[ST_MAXTYPES + 1][33], g_sTankName2[ST_MAXTYPES + 1][33], g_sTransformTypes[ST_MAXTYPES + 1][80], g_sTransformTypes2[ST_MAXTYPES + 1][80], g_sTypeRange[8], g_sTypeRange2[8];

ConVar g_cvSTDifficulty, g_cvSTGameMode, g_cvSTGameTypes, g_cvSTMaxPlayerZombies;

float g_flClawDamage[ST_MAXTYPES + 1], g_flClawDamage2[ST_MAXTYPES + 1], g_flRandomInterval[ST_MAXTYPES + 1], g_flRandomInterval2[ST_MAXTYPES + 1], g_flRegularInterval, g_flRegularInterval2, g_flRockDamage[ST_MAXTYPES + 1], g_flRockDamage2[ST_MAXTYPES + 1], g_flRunSpeed[ST_MAXTYPES + 1], g_flRunSpeed2[ST_MAXTYPES + 1], g_flTankChance[ST_MAXTYPES + 1],
	g_flTankChance2[ST_MAXTYPES + 1], g_flThrowInterval[ST_MAXTYPES + 1], g_flThrowInterval2[ST_MAXTYPES + 1], g_flTransformDelay[ST_MAXTYPES + 1], g_flTransformDelay2[ST_MAXTYPES + 1], g_flTransformDuration[ST_MAXTYPES + 1], g_flTransformDuration2[ST_MAXTYPES + 1];

Handle g_hAbilityActivatedForward, g_hButtonPressedForward, g_hButtonReleasedForward, g_hChangeTypeForward, g_hConfigsLoadedForward, g_hDisplayMenuForward, g_hEventFiredForward, g_hHookEventForward, g_hMenuItemSelectedForward, g_hPluginEndForward, g_hPresetForward, g_hRockBreakForward, g_hRockThrowForward;

int g_iAnnounceDeath, g_iAnnounceDeath2, g_iBaseHealth, g_iBaseHealth2, g_iBossStageCount[MAXPLAYERS + 1], g_iBossStages[ST_MAXTYPES + 1], g_iBossStages2[ST_MAXTYPES + 1], g_iBulletImmunity[ST_MAXTYPES + 1], g_iBulletImmunity2[ST_MAXTYPES + 1], g_iConfigEnable, g_iCooldown[MAXPLAYERS + 1], g_iDeathRevert, g_iDeathRevert2, g_iDisplayHealth, g_iDisplayHealth2,
	g_iExplosiveImmunity[ST_MAXTYPES + 1], g_iExplosiveImmunity2[ST_MAXTYPES + 1], g_iExtraHealth[ST_MAXTYPES + 1], g_iExtraHealth2[ST_MAXTYPES + 1], g_iFileTimeOld[7], g_iFileTimeNew[7], g_iFinalesOnly, g_iFinalesOnly2, g_iFinaleTank[ST_MAXTYPES + 1], g_iFinaleTank2[ST_MAXTYPES + 1], g_iFireImmunity[ST_MAXTYPES + 1], g_iFireImmunity2[ST_MAXTYPES + 1],
	g_iFlame[MAXPLAYERS + 1][3], g_iFlameRed[ST_MAXTYPES + 1], g_iFlameRed2[ST_MAXTYPES + 1], g_iFlameGreen[ST_MAXTYPES + 1], g_iFlameGreen2[ST_MAXTYPES + 1], g_iFlameBlue[ST_MAXTYPES + 1], g_iFlameBlue2[ST_MAXTYPES + 1], g_iFlameAlpha[ST_MAXTYPES + 1], g_iFlameAlpha2[ST_MAXTYPES + 1], g_iGameModeTypes, g_iGlowEnabled[ST_MAXTYPES + 1],
	g_iGlowEnabled2[ST_MAXTYPES + 1], g_iGlowRed[ST_MAXTYPES + 1], g_iGlowRed2[ST_MAXTYPES + 1], g_iGlowGreen[ST_MAXTYPES + 1], g_iGlowGreen2[ST_MAXTYPES + 1], g_iGlowBlue[ST_MAXTYPES + 1], g_iGlowBlue2[ST_MAXTYPES + 1], g_iHumanCooldown, g_iHumanCooldown2, g_iHumanSupport[ST_MAXTYPES + 1], g_iHumanSupport2[ST_MAXTYPES + 1], g_iJetpack[MAXPLAYERS + 1][3],
	g_iJetpackRed[ST_MAXTYPES + 1], g_iJetpackRed2[ST_MAXTYPES + 1], g_iJetpackGreen[ST_MAXTYPES + 1], g_iJetpackGreen2[ST_MAXTYPES + 1], g_iJetpackBlue[ST_MAXTYPES + 1], g_iJetpackBlue2[ST_MAXTYPES + 1], g_iJetpackAlpha[ST_MAXTYPES + 1], g_iJetpackAlpha2[ST_MAXTYPES + 1], g_iLastButtons[MAXPLAYERS + 1], g_iLight[MAXPLAYERS + 1][4],
	g_iLightRed[ST_MAXTYPES + 1], g_iLightRed2[ST_MAXTYPES + 1], g_iLightGreen[ST_MAXTYPES + 1], g_iLightGreen2[ST_MAXTYPES + 1], g_iLightBlue[ST_MAXTYPES + 1], g_iLightBlue2[ST_MAXTYPES + 1], g_iLightAlpha[ST_MAXTYPES + 1], g_iLightAlpha2[ST_MAXTYPES + 1], g_iMasterControl, g_iMasterControl2, g_iMeleeImmunity[ST_MAXTYPES + 1],
	g_iMeleeImmunity2[ST_MAXTYPES + 1], g_iMenuEnabled[ST_MAXTYPES + 1], g_iMenuEnabled2[ST_MAXTYPES + 1], g_iMultiHealth, g_iMultiHealth2, g_iParticleEffect[ST_MAXTYPES + 1], g_iParticleEffect2[ST_MAXTYPES + 1], g_iPlayerCount[2], g_iPluginEnabled, g_iPluginEnabled2, g_iRandomTank[ST_MAXTYPES + 1], g_iRandomTank2[ST_MAXTYPES + 1], g_iRegularAmount,
	g_iRegularAmount2, g_iRegularWave, g_iRegularWave2, g_iRockEffect[ST_MAXTYPES + 1], g_iRockEffect2[ST_MAXTYPES + 1], g_iRock[MAXPLAYERS + 1][17], g_iRockRed[ST_MAXTYPES + 1], g_iRockRed2[ST_MAXTYPES + 1], g_iRockGreen[ST_MAXTYPES + 1], g_iRockGreen2[ST_MAXTYPES + 1], g_iRockBlue[ST_MAXTYPES + 1], g_iRockBlue2[ST_MAXTYPES + 1],
	g_iRockAlpha[ST_MAXTYPES + 1], g_iRockAlpha2[ST_MAXTYPES + 1], g_iSkinRed[ST_MAXTYPES + 1], g_iSkinRed2[ST_MAXTYPES + 1], g_iSkinGreen[ST_MAXTYPES + 1], g_iSkinGreen2[ST_MAXTYPES + 1], g_iSkinBlue[ST_MAXTYPES + 1], g_iSkinBlue2[ST_MAXTYPES + 1], g_iSkinAlpha[ST_MAXTYPES + 1], g_iSkinAlpha2[ST_MAXTYPES + 1], g_iSpawnEnabled[ST_MAXTYPES + 1],
	g_iSpawnEnabled2[ST_MAXTYPES + 1], g_iSpawnMode[ST_MAXTYPES + 1], g_iSpawnMode2[ST_MAXTYPES + 1], g_iSTMode, g_iSTMode2, g_iTankEnabled[ST_MAXTYPES + 1], g_iTankEnabled2[ST_MAXTYPES + 1], g_iTankHealth[MAXPLAYERS + 1], g_iTankModel[MAXPLAYERS + 1], g_iTankNote[ST_MAXTYPES + 1], g_iTankNote2[ST_MAXTYPES + 1], g_iTankType[MAXPLAYERS + 1], g_iTankWave,
	g_iTire[MAXPLAYERS + 1][3], g_iTireRed[ST_MAXTYPES + 1], g_iTireRed2[ST_MAXTYPES + 1], g_iTireGreen[ST_MAXTYPES + 1], g_iTireGreen2[ST_MAXTYPES + 1], g_iTireBlue[ST_MAXTYPES + 1], g_iTireBlue2[ST_MAXTYPES + 1], g_iTireAlpha[ST_MAXTYPES + 1], g_iTireAlpha2[ST_MAXTYPES + 1], g_iType, g_iTypeLimit[ST_MAXTYPES + 1], g_iTypeLimit2[ST_MAXTYPES + 1];

TopMenu g_tmSTMenu;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"Super Tanks++\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	CreateNative("ST_CanTankSpawn", aNative_CanTankSpawn);
	CreateNative("ST_GetCurrentFinaleWave", aNative_GetCurrentFinaleWave);
	CreateNative("ST_GetMaxType", aNative_GetMaxType);
	CreateNative("ST_GetMinType", aNative_GetMinType);
	CreateNative("ST_GetPropColors", aNative_GetPropColors);
	CreateNative("ST_GetRunSpeed", aNative_GetRunSpeed);
	CreateNative("ST_GetTankColors", aNative_GetTankColors);
	CreateNative("ST_GetTankName", aNative_GetTankName);
	CreateNative("ST_GetTankType", aNative_GetTankType);
	CreateNative("ST_HasChanceToSpawn", aNative_HasChanceToSpawn);
	CreateNative("ST_HideEntity", aNative_HideEntity);
	CreateNative("ST_IsCorePluginEnabled", aNative_IsCorePluginEnabled);
	CreateNative("ST_IsGlowEnabled", aNative_IsGlowEnabled);
	CreateNative("ST_IsTankSupported", aNative_IsTankSupported);
	CreateNative("ST_IsTypeEnabled", aNative_IsTypeEnabled);
	CreateNative("ST_SpawnTank", aNative_SpawnTank);

	RegPluginLibrary("super_tanks++");

	g_bLateLoad = late;

	return APLRes_Success;
}

public any aNative_CanTankSpawn(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	if (iSpawnEnabled(iType) == 1)
	{
		return true;
	}

	return false;
}

public any aNative_GetCurrentFinaleWave(Handle plugin, int numParams)
{
	return g_iTankWave;
}

public any aNative_GetMaxType(Handle plugin, int numParams)
{
	return iGetMaxType();
}

public any aNative_GetMinType(Handle plugin, int numParams)
{
	return iGetMinType();
}

public any aNative_GetPropColors(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, "024"))
	{
		int iMode = GetNativeCell(2), iRed, iGreen, iBlue, iAlpha;
		switch (iMode)
		{
			case 1:
			{
				iRed = !g_bTankConfig[g_iTankType[iTank]] ? g_iLightRed[g_iTankType[iTank]] : g_iLightRed2[g_iTankType[iTank]];
				iGreen = !g_bTankConfig[g_iTankType[iTank]] ? g_iLightGreen[g_iTankType[iTank]] : g_iLightGreen2[g_iTankType[iTank]];
				iBlue = !g_bTankConfig[g_iTankType[iTank]] ? g_iLightBlue[g_iTankType[iTank]] : g_iLightBlue2[g_iTankType[iTank]];
				iAlpha = !g_bTankConfig[g_iTankType[iTank]] ? g_iLightAlpha[g_iTankType[iTank]] : g_iLightAlpha2[g_iTankType[iTank]];

			}
			case 2:
			{
				iRed = !g_bTankConfig[g_iTankType[iTank]] ? g_iJetpackRed[g_iTankType[iTank]] : g_iJetpackRed2[g_iTankType[iTank]];
				iGreen = !g_bTankConfig[g_iTankType[iTank]] ? g_iJetpackGreen[g_iTankType[iTank]] : g_iJetpackGreen2[g_iTankType[iTank]];
				iBlue = !g_bTankConfig[g_iTankType[iTank]] ? g_iJetpackBlue[g_iTankType[iTank]] : g_iJetpackBlue2[g_iTankType[iTank]];
				iAlpha = !g_bTankConfig[g_iTankType[iTank]] ? g_iJetpackAlpha[g_iTankType[iTank]] : g_iJetpackAlpha2[g_iTankType[iTank]];
			}
			case 3:
			{
				iRed = !g_bTankConfig[g_iTankType[iTank]] ? g_iFlameRed[g_iTankType[iTank]] : g_iFlameRed2[g_iTankType[iTank]];
				iGreen = !g_bTankConfig[g_iTankType[iTank]] ? g_iFlameGreen[g_iTankType[iTank]] : g_iFlameGreen2[g_iTankType[iTank]];
				iBlue = !g_bTankConfig[g_iTankType[iTank]] ? g_iFlameBlue[g_iTankType[iTank]] : g_iFlameBlue2[g_iTankType[iTank]];
				iAlpha = !g_bTankConfig[g_iTankType[iTank]] ? g_iFlameAlpha[g_iTankType[iTank]] : g_iFlameAlpha2[g_iTankType[iTank]];

			}
			case 4:
			{
				iRed = !g_bTankConfig[g_iTankType[iTank]] ? g_iRockRed[g_iTankType[iTank]] : g_iRockRed2[g_iTankType[iTank]];
				iGreen = !g_bTankConfig[g_iTankType[iTank]] ? g_iRockGreen[g_iTankType[iTank]] : g_iRockGreen2[g_iTankType[iTank]];
				iBlue = !g_bTankConfig[g_iTankType[iTank]] ? g_iRockBlue[g_iTankType[iTank]] : g_iRockBlue2[g_iTankType[iTank]];
				iAlpha = !g_bTankConfig[g_iTankType[iTank]] ? g_iRockAlpha[g_iTankType[iTank]] : g_iRockAlpha2[g_iTankType[iTank]];
			}
			case 5:
			{
				iRed = !g_bTankConfig[g_iTankType[iTank]] ? g_iTireRed[g_iTankType[iTank]] : g_iTireRed2[g_iTankType[iTank]];
				iGreen = !g_bTankConfig[g_iTankType[iTank]] ? g_iTireGreen[g_iTankType[iTank]] : g_iTireGreen2[g_iTankType[iTank]];
				iBlue = !g_bTankConfig[g_iTankType[iTank]] ? g_iTireBlue[g_iTankType[iTank]] : g_iTireBlue2[g_iTankType[iTank]];
				iAlpha = !g_bTankConfig[g_iTankType[iTank]] ? g_iTireAlpha[g_iTankType[iTank]] : g_iTireAlpha2[g_iTankType[iTank]];

			}
		}

		SetNativeCellRef(3, iRed);
		SetNativeCellRef(4, iGreen);
		SetNativeCellRef(5, iBlue);
		SetNativeCellRef(6, iAlpha);
	}
}

public any aNative_GetRunSpeed(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, "024") && flRunSpeed(iTank) > 0.0)
	{
		return flRunSpeed(iTank);
	}

	return 1.0;
}

public any aNative_GetTankColors(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, "024"))
	{
		int iMode = GetNativeCell(2), iRed, iGreen, iBlue, iAlpha;
		switch (iMode)
		{
			case 1:
			{
				iRed = !g_bTankConfig[g_iTankType[iTank]] ? g_iSkinRed[g_iTankType[iTank]] : g_iSkinRed2[g_iTankType[iTank]];
				iGreen = !g_bTankConfig[g_iTankType[iTank]] ? g_iSkinGreen[g_iTankType[iTank]] : g_iSkinGreen2[g_iTankType[iTank]];
				iBlue = !g_bTankConfig[g_iTankType[iTank]] ? g_iSkinBlue[g_iTankType[iTank]] : g_iSkinBlue2[g_iTankType[iTank]];
				iAlpha = !g_bTankConfig[g_iTankType[iTank]] ? g_iSkinAlpha[g_iTankType[iTank]] : g_iSkinAlpha2[g_iTankType[iTank]];
			}
			case 2:
			{
				iRed = !g_bTankConfig[g_iTankType[iTank]] ? g_iGlowRed[g_iTankType[iTank]] : g_iGlowRed2[g_iTankType[iTank]];
				iGreen = !g_bTankConfig[g_iTankType[iTank]] ? g_iGlowGreen[g_iTankType[iTank]] : g_iGlowGreen2[g_iTankType[iTank]];
				iBlue = !g_bTankConfig[g_iTankType[iTank]] ? g_iGlowBlue[g_iTankType[iTank]] : g_iGlowBlue2[g_iTankType[iTank]];
			}
		}

		SetNativeCellRef(3, iRed);
		SetNativeCellRef(4, iGreen);
		SetNativeCellRef(5, iBlue);
		SetNativeCellRef(6, iAlpha);
	}
}

public any aNative_GetTankName(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, "024"))
	{
		char sTankName[33];
		sTankName = !g_bTankConfig[g_iTankType[iTank]] ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[g_iTankType[iTank]];
		SetNativeString(2, sTankName, sizeof(sTankName));
	}
}

public any aNative_GetTankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, "024"))
	{
		return g_iTankType[iTank];
	}

	return 0;
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

public any aNative_IsCorePluginEnabled(Handle plugin, int numParams)
{
	if (g_bPluginEnabled)
	{
		return true;
	}

	return false;
}

public any aNative_IsGlowEnabled(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank, "024") && iGlowEnabled(g_iTankType[iTank]) == 1)
	{
		return true;
	}

	return false;
}

public any aNative_IsTankSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	char sChecks[7];
	GetNativeString(2, sChecks, sizeof(sChecks));
	if (bIsTankAllowed(iTank, sChecks))
	{
		return true;
	}

	return false;
}

public any aNative_IsTypeEnabled(Handle plugin, int numParams)
{
	int iType = GetNativeCell(1);
	if (iTankEnabled(iType) == 1)
	{
		return true;
	}

	return false;
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
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "adminmenu", false))
	{
		g_tmSTMenu = null;
	}
	else if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	g_hAbilityActivatedForward = CreateGlobalForward("ST_OnAbilityActivated", ET_Ignore, Param_Cell);
	g_hButtonPressedForward = CreateGlobalForward("ST_OnButtonPressed", ET_Ignore, Param_Cell, Param_Cell);
	g_hButtonReleasedForward = CreateGlobalForward("ST_OnButtonReleased", ET_Ignore, Param_Cell, Param_Cell);
	g_hChangeTypeForward = CreateGlobalForward("ST_OnChangeType", ET_Ignore, Param_Cell);
	g_hConfigsLoadedForward = CreateGlobalForward("ST_OnConfigsLoaded", ET_Ignore, Param_String, Param_Cell);
	g_hDisplayMenuForward = CreateGlobalForward("ST_OnDisplayMenu", ET_Ignore, Param_Cell);
	g_hEventFiredForward = CreateGlobalForward("ST_OnEventFired", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	g_hHookEventForward = CreateGlobalForward("ST_OnHookEvent", ET_Ignore, Param_Cell, Param_Cell);
	g_hMenuItemSelectedForward = CreateGlobalForward("ST_OnMenuItemSelected", ET_Ignore, Param_Cell, Param_String);
	g_hPluginEndForward = CreateGlobalForward("ST_OnPluginEnd", ET_Ignore);
	g_hPresetForward = CreateGlobalForward("ST_OnPreset", ET_Ignore, Param_Cell);
	g_hRockBreakForward = CreateGlobalForward("ST_OnRockBreak", ET_Ignore, Param_Cell, Param_Cell);
	g_hRockThrowForward = CreateGlobalForward("ST_OnRockThrow", ET_Ignore, Param_Cell, Param_Cell);

	vMultiTargetFilters(1);

	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_info", cmdSTInfo, "View information about Super Tanks++.");
	RegAdminCmd("sm_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Super Tank.");
	RegConsoleCmd("sm_supertank", cmdTank, "Choose a Super Tank.");

	CreateConVar("st_pluginversion", ST_VERSION, "Super Tanks++ Version", FCVAR_NOTIFY);
	AutoExecConfig(true, "super_tanks++");

	g_cvSTDifficulty = FindConVar("z_difficulty");
	g_cvSTGameMode = FindConVar("mp_gamemode");
	g_cvSTGameTypes = FindConVar("sv_gametypes");
	g_cvSTMaxPlayerZombies = FindConVar("z_max_player_zombies");

	g_cvSTDifficulty.AddChangeHook(vSTGameDifficultyCvar);

	CreateDirectory("addons/sourcemod/data/super_tanks++/", 511);
	BuildPath(Path_SM, g_sSavePath, sizeof(g_sSavePath), "data/super_tanks++/super_tanks++.cfg");
	vLoadConfigs(g_sSavePath, true);
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
			if (bIsValidClient(iPlayer, "24"))
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

	PrecacheSound(SOUND_BOSS);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset2(client);

	g_bAdminMenu[client] = false;
	g_bThirdPerson[client] = false;
	g_iPlayerCount[0] = iGetPlayerCount();
	g_iTankType[client] = 0;

	CreateTimer(1.0, tTimerCheckView, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public void OnClientDisconnect_Post(int client)
{
	g_iLastButtons[client] = 0;
}

public void OnConfigsExecuted()
{
	g_iType = 0;

	vLoadConfigs(g_sSavePath, true);

	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (IsMapValid(sMapName))
	{
		vPluginStatus();

		float flRegularInterval = !g_bGeneralConfig ? g_flRegularInterval : g_flRegularInterval2;
		CreateTimer(flRegularInterval, tTimerRegularWaves, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerReloadConfigs, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(0.1, tTimerTankHealthUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerTankTypeUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerUpdatePlayerCount, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	if (StrContains(g_sConfigCreate, "1") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory("addons/sourcemod/data/super_tanks++/difficulty_configs/", 511);

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

	if (StrContains(g_sConfigCreate, "2") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory((bIsValidGame() ? "addons/sourcemod/data/super_tanks++/l4d2_map_configs/" : "addons/sourcemod/data/super_tanks++/l4d_map_configs/"), 511);

		char sMapNames[128];
		ArrayList alADTMaps = new ArrayList(16, 0);

		int iSerial = -1;
		ReadMapList(alADTMaps, iSerial, "default", MAPLIST_FLAG_MAPSFOLDER);
		ReadMapList(alADTMaps, iSerial, "allexistingmaps__", MAPLIST_FLAG_MAPSFOLDER|MAPLIST_FLAG_NO_DEFAULT);

		int iMapCount = GetArraySize(alADTMaps);
		if (iMapCount > 0)
		{
			for (int iMap = 0; iMap < iMapCount; iMap++)
			{
				alADTMaps.GetString(iMap, sMapNames, sizeof(sMapNames));
				vCreateConfigFile((bIsValidGame() ? "l4d2_map_configs/" : "l4d_map_configs/"), sMapNames);
			}
		}

		delete alADTMaps;
	}

	if (StrContains(g_sConfigCreate, "3") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory((bIsValidGame() ? "addons/sourcemod/data/super_tanks++/l4d2_gamemode_configs/" : "addons/sourcemod/data/super_tanks++/l4d_gamemode_configs/"), 511);

		char sGameType[2049], sTypes[64][32];
		g_cvSTGameTypes.GetString(sGameType, sizeof(sGameType));
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

	if (StrContains(g_sConfigCreate, "4") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory("addons/sourcemod/data/super_tanks++/daily_configs/", 511);

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

	if (StrContains(g_sConfigCreate, "5") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory("addons/sourcemod/data/super_tanks++/playercount_configs/", 511);

		char sPlayerCount[32];
		for (int iCount = 0; iCount <= MAXPLAYERS + 1; iCount++)
		{
			IntToString(iCount, sPlayerCount, sizeof(sPlayerCount));
			vCreateConfigFile("playercount_configs/", sPlayerCount);
		}
	}

	if (StrContains(g_sConfigExecute, "1") != -1 && g_iConfigEnable == 1 && g_cvSTDifficulty != null)
	{
		char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_cvSTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));

		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
		vLoadConfigs(sDifficultyConfig);
		vPluginStatus();
		g_iFileTimeOld[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
	}

	if (StrContains(g_sConfigExecute, "2") != -1 && g_iConfigEnable == 1)
	{
		char sMap[64], sMapConfig[PLATFORM_MAX_PATH];
		GetCurrentMap(sMap, sizeof(sMap));

		BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), (bIsValidGame() ? "data/super_tanks++/l4d2_map_configs/%s.cfg" : "data/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
		vLoadConfigs(sMapConfig);
		vPluginStatus();
		g_iFileTimeOld[2] = GetFileTime(sMapConfig, FileTime_LastChange);
	}

	if (StrContains(g_sConfigExecute, "3") != -1 && g_iConfigEnable == 1)
	{
		char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
		g_cvSTGameMode.GetString(sMode, sizeof(sMode));

		BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), (bIsValidGame() ? "data/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "data/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
		vLoadConfigs(sModeConfig);
		vPluginStatus();
		g_iFileTimeOld[3] = GetFileTime(sModeConfig, FileTime_LastChange);
	}

	if (StrContains(g_sConfigExecute, "4") != -1 && g_iConfigEnable == 1)
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

		BuildPath(Path_SM, sDayConfig, sizeof(sDayConfig), "data/super_tanks++/daily_configs/%s.cfg", sDay);
		vLoadConfigs(sDayConfig);
		vPluginStatus();
		g_iFileTimeOld[4] = GetFileTime(sDayConfig, FileTime_LastChange);
	}

	if (StrContains(g_sConfigExecute, "5") != -1 && g_iConfigEnable == 1)
	{
		char sCountConfig[PLATFORM_MAX_PATH];

		BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/super_tanks++/playercount_configs/%i.cfg", iGetPlayerCount());
		vLoadConfigs(sCountConfig);
		vPluginStatus();
		g_iFileTimeOld[5] = GetFileTime(sCountConfig, FileTime_LastChange);
	}
}

public void OnMapEnd()
{
	vReset();
}

public void OnPluginEnd()
{
	vMultiTargetFilters(0);

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, "234"))
		{
			vRemoveProps(iTank);
		}
	}

	Call_StartForward(g_hPluginEndForward);
	Call_Finish();
}

public void OnAdminMenuReady(Handle topmenu)
{
	TopMenu tmSTMenu = TopMenu.FromHandle(topmenu);
	if (topmenu == g_tmSTMenu)
	{
		return;
	}

	g_tmSTMenu = tmSTMenu;

	TopMenuObject st_commands = g_tmSTMenu.AddCategory("SuperTanks++", iSTAdminMenuHandler);
	if (st_commands != INVALID_TOPMENUOBJECT)
	{
		g_tmSTMenu.AddItem("sm_tank", vSuperTanksMenu, st_commands, "sm_tank", ADMFLAG_ROOT);
		g_tmSTMenu.AddItem("sm_st_info", vSTInfoMenu, st_commands, "sm_st_info", ADMFLAG_GENERIC);
	}
}

public int iSTAdminMenuHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayTitle, TopMenuAction_DisplayOption: Format(buffer, maxlength, "Super Tanks++");
	}

	return 0;
}

public void vSuperTanksMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: Format(buffer, maxlength, "%T", "STMenu", param);
		case TopMenuAction_SelectOption:
		{
			g_bAdminMenu[param] = true;

			vTankMenu(param, 0);
		}
	}
}

public void vSTInfoMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: Format(buffer, maxlength, "%T", "STInfoMenu", param);
		case TopMenuAction_SelectOption:
		{
			g_bAdminMenu[param] = true;

			vInfoMenu(param, 0);
		}
	}
}

public Action cmdSTInfo(int client, int args)
{
	if (!g_bPluginEnabled)
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, "0245"))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
		case false: vInfoMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vInfoMenu(int client, int item)
{
	Menu mInfoMenu = new Menu(iInfoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mInfoMenu.SetTitle("Super Tanks++ Information");
	mInfoMenu.AddItem("Status", "Status");
	mInfoMenu.AddItem("Details", "Details");
	mInfoMenu.AddItem("Human Support", "Human Support");
	Call_StartForward(g_hDisplayMenuForward);
	Call_PushCell(mInfoMenu);
	Call_Finish();
	g_bAdminMenu[client] ? (mInfoMenu.ExitBackButton = true) : (mInfoMenu.ExitBackButton = false);
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

				if (param2 == MenuCancel_ExitBack && g_tmSTMenu != null)
				{
					g_tmSTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
			}
		}
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, !g_bPluginEnabled ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "GeneralDetails");
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanSupport(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			Call_StartForward(g_hMenuItemSelectedForward);
			Call_PushCell(param1);
			Call_PushString(sInfo);
			Call_Finish();

			if (param2 < 3 && bIsValidClient(param1, "24"))
			{
				vInfoMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "STInfoMenu", param1);
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

public Action cmdTank(int client, int args)
{
	if (!g_bPluginEnabled)
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (iSTMode() == 1 && !CheckCommandAccess(client, "sm_tank", ADMFLAG_ROOT))
	{
		ReplyToCommand(client, "%s %t", ST_TAG2, "NoAccess");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, "0245"))
	{
		ReplyToCommand(client, "%s %t", ST_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	char sType[32], sAmount[32], sMode[32];
	GetCmdArg(1, sType, sizeof(sType));
	int iType = StringToInt(sType);
	GetCmdArg(2, sAmount, sizeof(sAmount));
	int iAmount = StringToInt(sAmount);
	GetCmdArg(3, sMode, sizeof(sMode));
	int iMode = StringToInt(sMode);

	iType = iClamp(iType, iGetMinType(), iGetMaxType());
	if (args < 1)
	{
		switch (IsVoteInProgress())
		{
			case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
			case false: vTankMenu(client, 0);
		}

		return Plugin_Handled;
	}
	else if (iAmount == 0)
	{
		iAmount = 1;
	}
	else if ((IsCharNumeric(iType) && (iType < iGetMinType() || iType > iGetMaxType())) || iAmount > 32 || iMode < 0 || iMode > 1 || args > 3)
	{
		ReplyToCommand(client, "%s Usage: sm_tank <type %i-%i> <amount: 1-32> <0: spawn at crosshair|1: spawn automatically>", ST_TAG2, iGetMinType(), iGetMaxType());

		return Plugin_Handled;
	}

	if (IsCharNumeric(iType) && (iTankEnabled(iType) == 0 || iMenuEnabled(iType) == 0))
	{
		char sTankName[33];
		sTankName = !g_bTankConfig[iType] ? g_sTankName[iType] : g_sTankName2[iType];
		ReplyToCommand(client, "%s %s\x04 (Tank #%i)\x01 is disabled.", ST_TAG4, sTankName, iType);

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
			int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
			for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
			{
				char sTankName[33];
				sTankName = !g_bTankConfig[iIndex] ? g_sTankName[iIndex] : g_sTankName2[iIndex];
				if (iTankEnabled(iIndex) == 0 || iMenuEnabled(iIndex) == 0 || StrContains(sTankName, type, false) == -1)
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
					ST_PrintToChat(admin, "%s %t", ST_TAG3, "RequestFailed");

					return;
				}
				default:
				{
					ST_PrintToChat(admin, "%s %t", ST_TAG3, "MultipleMatches");

					g_iType = iTankTypes[GetRandomInt(1, iTypeCount)];
				}
			}
		}
		default: g_iType = iClamp(iType, iGetMinType(), iGetMaxType());
	}

	switch (bIsTank(admin))
	{
		case true:
		{
			switch (bIsTank(admin, "5"))
			{
				case true:
				{
					switch (spawn)
					{
						case true: vSpawnTank(admin, g_iType, amount, mode);
						case false:
						{
							if ((GetClientButtons(admin) & IN_SPEED == IN_SPEED) && CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT))
							{
								vChangeTank(admin, amount, mode);
							}
							else
							{
								switch (g_bChanged[admin])
								{
									case true: ST_PrintToChat(admin, "%s %t", ST_TAG3, "HumanCooldown", g_iCooldown[admin]);
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

										if (bIsTank(admin, "5"))
										{
											vExternalView(admin, 1.5);
										}

										int iMasterControl = !g_bGeneralConfig ? g_iMasterControl : g_iMasterControl2;
										if (iMasterControl == 0 && !CheckCommandAccess(admin, "st_admin", ADMFLAG_ROOT))
										{
											g_iCooldown[admin] = !g_bGeneralConfig ? g_iHumanCooldown : g_iHumanCooldown2;
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
			switch (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT))
			{
				case true: vChangeTank(admin, amount, mode);
				case false: ST_PrintToChat(admin, "%s %t", ST_TAG2, "NoAccess");
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

				if (bIsTank(iTarget, "5"))
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

static void vQueueTank(int admin, int type, bool mode = true, int user = 0)
{
	if (user == 0)
	{
		user = admin;
	}

	char sType[32];
	IntToString(type, sType, sizeof(sType));
	vTank(admin, sType, mode, user);
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
	mTankMenu.SetTitle("Super Tanks++ Menu");

	if (g_iTankType[admin] > 0)
	{
		mTankMenu.AddItem("Default Tank", "Default Tank");
	}

	for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
	{
		if (iTankEnabled(iIndex) == 0 || iMenuEnabled(iIndex) == 0)
		{
			continue;
		}

		char sTankName[33], sMenuItem[46];
		sTankName = !g_bTankConfig[iIndex] ? g_sTankName[iIndex] : g_sTankName2[iIndex];
		Format(sMenuItem, sizeof(sMenuItem), "%s (Tank #%i)", sTankName, iIndex);
		mTankMenu.AddItem(sTankName, sMenuItem);
	}

	g_bAdminMenu[admin] ? (mTankMenu.ExitBackButton = true) : (mTankMenu.ExitBackButton = false);
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

				if (param2 == MenuCancel_ExitBack && g_tmSTMenu != null)
				{
					g_tmSTMenu.Display(param1, TopMenuPosition_LastCategory);
				}
			}
		}
		case MenuAction_Select:
		{
			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			switch (StrEqual(sInfo, "Default Tank"))
			{
				case true: vQueueTank(param1, g_iTankType[param1], false);
				case false:
				{
					for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
					{
						if (iTankEnabled(iIndex) == 0 || iMenuEnabled(iIndex) == 0)
						{
							continue;
						}

						char sTankName[33];
						sTankName = !g_bTankConfig[iIndex] ? g_sTankName[iIndex] : g_sTankName2[iIndex];
						if (StrEqual(sInfo, sTankName))
						{
							vQueueTank(param1, iIndex, false);

							break;
						}
					}
				}
			}

			if (bIsValidClient(param1, "24"))
			{
				vTankMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "STMenu", param1);
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
			if (iThrower == 0 || !bIsTankAllowed(iThrower) || iTankEnabled(g_iTankType[iThrower]) == 0)
			{
				return;
			}

			Call_StartForward(g_hRockBreakForward);
			Call_PushCell(iThrower);
			Call_PushCell(entity);
			Call_Finish();
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!g_bPluginEnabled && !bIsValidClient(client, "02345"))
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
				Call_StartForward(g_hButtonPressedForward);
				Call_PushCell(client);
				Call_PushCell(iButton);
				Call_Finish();
			}
		}
		else if ((g_iLastButtons[client] & iButton))
		{
			Call_StartForward(g_hButtonReleasedForward);
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
	if (g_bPluginEnabled && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (bIsTankAllowed(attacker) && bIsSurvivor(victim))
		{
			float flClawDamage = !g_bTankConfig[g_iTankType[attacker]] ? g_flClawDamage[g_iTankType[attacker]] : g_flClawDamage2[g_iTankType[attacker]],
				flRockDamage = !g_bTankConfig[g_iTankType[attacker]] ? g_flRockDamage[g_iTankType[attacker]] : g_flRockDamage2[g_iTankType[attacker]];
			if (StrEqual(sClassname, "weapon_tank_claw") && flClawDamage >= 0.0)
			{
				damage = flClawDamage;

				return Plugin_Changed;
			}
			else if (StrEqual(sClassname, "tank_rock") && flRockDamage >= 0.0)
			{
				damage = flRockDamage;

				return Plugin_Changed;
			}
		}
		else if (bIsInfected(victim, "0234"))
		{
			if (bIsTankAllowed(victim))
			{
				int iBulletImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iBulletImmunity[g_iTankType[victim]] : g_iBulletImmunity2[g_iTankType[victim]],
					iExplosiveImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iExplosiveImmunity[g_iTankType[victim]] : g_iExplosiveImmunity2[g_iTankType[victim]],
					iMeleeImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iMeleeImmunity[g_iTankType[victim]] : g_iMeleeImmunity2[g_iTankType[victim]];

				if ((damagetype & DMG_BULLET && iBulletImmunity == 1) ||
					((damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA) && iExplosiveImmunity == 1) ||
					(damagetype & DMG_BURN && iFireImmunity(victim) == 1) ||
					((damagetype & DMG_SLASH || damagetype & DMG_CLUB) && iMeleeImmunity == 1))
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
	if (ST_IsCorePluginEnabled() && iOwner == client && !bIsTankThirdPerson(client) && !g_bThirdPerson[client])
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void vEventHandler(Event event, const char[] name, bool dontBroadcast)
{
	if (g_bPluginEnabled)
	{
		if (StrEqual(name, "ability_use"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTankAllowed(iTank))
			{
				vThrowInterval(iTank, flThrowInterval(iTank));
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
			g_iTankWave = 3;
		}
		else if (StrEqual(name, "finale_start"))
		{
			g_iTankWave = 1;
		}
		else if (StrEqual(name, "finale_vehicle_leaving"))
		{
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
			if (bIsTankAllowed(iTank, "024"))
			{
				int iAnnounceDeath = !g_bGeneralConfig ? g_iAnnounceDeath : g_iAnnounceDeath2;
				if (iAnnounceDeath == 1 && ST_IsCloneSupported(iTank, g_bCloneInstalled))
				{
					char sTankName[33];
					sTankName = !g_bTankConfig[g_iTankType[iTank]] ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[g_iTankType[iTank]];
					if (StrEqual(sTankName, ""))
					{
						sTankName = "Tank";
					}

					switch (GetRandomInt(1, 10))
					{
						case 1: ST_PrintToChatAll("%s %t", ST_TAG2, "Death1", sTankName);
						case 2: ST_PrintToChatAll("%s %t", ST_TAG2, "Death2", sTankName);
						case 3: ST_PrintToChatAll("%s %t", ST_TAG2, "Death3", sTankName);
						case 4: ST_PrintToChatAll("%s %t", ST_TAG2, "Death4", sTankName);
						case 5: ST_PrintToChatAll("%s %t", ST_TAG2, "Death5", sTankName);
						case 6: ST_PrintToChatAll("%s %t", ST_TAG2, "Death6", sTankName);
						case 7: ST_PrintToChatAll("%s %t", ST_TAG2, "Death7", sTankName);
						case 8: ST_PrintToChatAll("%s %t", ST_TAG2, "Death8", sTankName);
						case 9: ST_PrintToChatAll("%s %t", ST_TAG2, "Death9", sTankName);
						case 10: ST_PrintToChatAll("%s %t", ST_TAG2, "Death10", sTankName);
					}
				}

				int iDeathRevert = !g_bGeneralConfig ? g_iDeathRevert : g_iDeathRevert2;
				if (iDeathRevert == 1)
				{
					vNewTankSettings(iTank);
					vSetColor(iTank);
				}

				vReset2(iTank, iDeathRevert);

				CreateTimer(3.0, tTimerTankWave, g_iTankWave, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else if (StrEqual(name, "player_incapacitated"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank, "024"))
			{
				CreateTimer(0.5, tTimerKillStuckTank, iTankId, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else if (StrEqual(name, "player_spawn"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank))
			{
				g_iTankType[iTank] = 0;

				switch (g_iType)
				{
					case 0:
					{
						switch (bIsTank(iTank, "5"))
						{
							case true:
							{
								switch (iSTMode())
								{
									case 0:
									{
										g_bNeedHealth[iTank] = true;
										vTankMenu(iTank, 0);
									}
									case 1: vSuperTank(iTank);
								}
							}
							case false: vSuperTank(iTank);
						}
					}
					default: vSuperTank(iTank);
				}
			}
		}
		else if (StrEqual(name, "round_start"))
		{
			g_iTankWave = 0;
		}

		Call_StartForward(g_hEventFiredForward);
		Call_PushCell(event);
		Call_PushString(name);
		Call_PushCell(dontBroadcast);
		Call_Finish();
	}
}

static void vPluginStatus()
{
	bool bIsPluginAllowed = bIsPluginEnabled(g_cvSTGameMode, g_iGameModeTypes, g_sEnabledGameModes, g_sDisabledGameModes);
	if (iPluginEnabled() == 1)
	{
		switch (bIsPluginAllowed)
		{
			case true:
			{
				vHookEvents(true);
				g_bPluginEnabled = true;
			}
			case false:
			{
				vHookEvents(false);
				g_bPluginEnabled = false;
			}
		}
	}
}

static void vHookEvents(bool hook)
{
	static bool bHooked;
	if (hook && !bHooked)
	{
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
		vHookEventForward(true);
		bHooked = true;
	}
	else if (!hook && bHooked)
	{
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
		vHookEventForward(false);
		bHooked = false;
	}
}

static void vHookEventForward(bool mode)
{
	Call_StartForward(g_hHookEventForward);
	Call_PushCell(mode);
	Call_Finish();
}

static void vLoadConfigs(const char[] savepath, bool main = false)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	if (kvSuperTanks.JumpToKey("Plugin Settings"))
	{
		switch (main)
		{
			case true:
			{
				g_bGeneralConfig = false;

				g_iPluginEnabled = kvSuperTanks.GetNum("General/Plugin Enabled", 1);
				g_iPluginEnabled = iClamp(g_iPluginEnabled, 0, 1);
				kvSuperTanks.GetString("General/Announce Arrival", g_sAnnounceArrival, sizeof(g_sAnnounceArrival), "12345");
				g_iAnnounceDeath = kvSuperTanks.GetNum("General/Announce Death", 1);
				g_iAnnounceDeath = iClamp(g_iAnnounceDeath, 0, 1);
				g_iBaseHealth = kvSuperTanks.GetNum("General/Base Health", 0);
				g_iBaseHealth = iClamp(g_iBaseHealth, 0, ST_MAXHEALTH);
				g_iDeathRevert = kvSuperTanks.GetNum("General/Death Revert", 0);
				g_iDeathRevert = iClamp(g_iDeathRevert, 0, 1);
				g_iDisplayHealth = kvSuperTanks.GetNum("General/Display Health", 3);
				g_iDisplayHealth = iClamp(g_iDisplayHealth, 0, 3);
				g_iFinalesOnly = kvSuperTanks.GetNum("General/Finales Only", 0);
				g_iFinalesOnly = iClamp(g_iFinalesOnly, 0, 1);
				g_iMultiHealth = kvSuperTanks.GetNum("General/Multiply Health", 0);
				g_iMultiHealth = iClamp(g_iMultiHealth, 0, 3);
				kvSuperTanks.GetString("General/Type Range", g_sTypeRange, sizeof(g_sTypeRange), "1-500");

				g_iHumanCooldown = kvSuperTanks.GetNum("Human Support/Human Cooldown", 600);
				g_iHumanCooldown = iClamp(g_iHumanCooldown, 0, 9999999999);
				g_iMasterControl = kvSuperTanks.GetNum("Human Support/Master Control", 0);
				g_iMasterControl = iClamp(g_iMasterControl, 0, 1);
				g_iSTMode = kvSuperTanks.GetNum("Human Support/Spawn Mode", 1);
				g_iSTMode = iClamp(g_iSTMode, 0, 1);

				g_iRegularAmount = kvSuperTanks.GetNum("Waves/Regular Amount", 2);
				g_iRegularAmount = iClamp(g_iRegularAmount, 1, 64);
				g_flRegularInterval = kvSuperTanks.GetFloat("Waves/Regular Interval", 300.0);
				g_flRegularInterval = flClamp(g_flRegularInterval, 0.1, 9999999999.0);
				g_iRegularWave = kvSuperTanks.GetNum("Waves/Regular Wave", 0);
				g_iRegularWave = iClamp(g_iRegularWave, 0, 1);
				kvSuperTanks.GetString("Waves/Finale Waves", g_sFinaleWaves, sizeof(g_sFinaleWaves), "2,3,4");

				g_iGameModeTypes = kvSuperTanks.GetNum("Game Modes/Game Mode Types", 0);
				g_iGameModeTypes = iClamp(g_iGameModeTypes, 0, 15);
				kvSuperTanks.GetString("Game Modes/Enabled Game Modes", g_sEnabledGameModes, sizeof(g_sEnabledGameModes), "");
				kvSuperTanks.GetString("Game Modes/Disabled Game Modes", g_sDisabledGameModes, sizeof(g_sDisabledGameModes), "");

				g_iConfigEnable = kvSuperTanks.GetNum("Custom/Enable Custom Configs", 0);
				g_iConfigEnable = iClamp(g_iConfigEnable, 0, 1);
				kvSuperTanks.GetString("Custom/Create Config Types", g_sConfigCreate, sizeof(g_sConfigCreate), "12345");
				kvSuperTanks.GetString("Custom/Execute Config Types", g_sConfigExecute, sizeof(g_sConfigExecute), "1");
			}
			case false:
			{
				g_bGeneralConfig = true;

				g_iPluginEnabled2 = kvSuperTanks.GetNum("General/Plugin Enabled", g_iPluginEnabled);
				g_iPluginEnabled2 = iClamp(g_iPluginEnabled2, 0, 1);
				kvSuperTanks.GetString("General/Announce Arrival", g_sAnnounceArrival2, sizeof(g_sAnnounceArrival2), g_sAnnounceArrival);
				g_iAnnounceDeath2 = kvSuperTanks.GetNum("General/Announce Death", g_iAnnounceDeath);
				g_iAnnounceDeath2 = iClamp(g_iAnnounceDeath2, 0, 1);
				g_iBaseHealth2 = kvSuperTanks.GetNum("General/Base Health", g_iBaseHealth);
				g_iBaseHealth2 = iClamp(g_iBaseHealth2, 0, ST_MAXHEALTH);
				g_iDeathRevert2 = kvSuperTanks.GetNum("General/Death Revert", g_iDeathRevert);
				g_iDeathRevert2 = iClamp(g_iDeathRevert2, 0, 1);
				g_iDisplayHealth2 = kvSuperTanks.GetNum("General/Display Health", g_iDisplayHealth);
				g_iDisplayHealth2 = iClamp(g_iDisplayHealth2, 0, 3);
				g_iFinalesOnly2 = kvSuperTanks.GetNum("General/Finales Only", g_iFinalesOnly);
				g_iFinalesOnly2 = iClamp(g_iFinalesOnly2, 0, 1);
				g_iMultiHealth2 = kvSuperTanks.GetNum("General/Multiply Health", g_iMultiHealth);
				g_iMultiHealth2 = iClamp(g_iMultiHealth2, 0, 3);
				kvSuperTanks.GetString("General/Type Range", g_sTypeRange2, sizeof(g_sTypeRange2), g_sTypeRange);

				g_iHumanCooldown2 = kvSuperTanks.GetNum("Human Support/Human Cooldown", g_iHumanCooldown);
				g_iHumanCooldown2 = iClamp(g_iHumanCooldown2, 0, 9999999999);
				g_iMasterControl2 = kvSuperTanks.GetNum("Human Support/Master Control", g_iMasterControl);
				g_iMasterControl2 = iClamp(g_iMasterControl2, 0, 1);
				g_iSTMode2 = kvSuperTanks.GetNum("Human Support/Spawn Mode", g_iSTMode);
				g_iSTMode2 = iClamp(g_iSTMode2, 0, 1);

				g_iRegularAmount2 = kvSuperTanks.GetNum("Waves/Regular Amount", g_iRegularAmount);
				g_iRegularAmount2 = iClamp(g_iRegularAmount2, 1, 64);
				g_flRegularInterval2 = kvSuperTanks.GetFloat("Waves/Regular Interval", g_flRegularInterval);
				g_flRegularInterval2 = flClamp(g_flRegularInterval2, 0.1, 9999999999.0);
				g_iRegularWave2 = kvSuperTanks.GetNum("Waves/Regular Wave", g_iRegularWave);
				g_iRegularWave2 = iClamp(g_iRegularWave2, 0, 1);
				kvSuperTanks.GetString("Waves/Finale Waves", g_sFinaleWaves2, sizeof(g_sFinaleWaves2), g_sFinaleWaves);
			}
		}

		kvSuperTanks.Rewind();
	}

	for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
	{
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%i", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			switch (main)
			{
				case true:
				{
					g_bTankConfig[iIndex] = false;

					kvSuperTanks.GetString("General/Tank Name", g_sTankName[iIndex], sizeof(g_sTankName[]), sTankName);
					g_iTankEnabled[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", 0);
					g_iTankEnabled[iIndex] = iClamp(g_iTankEnabled[iIndex], 0, 1);
					g_flTankChance[iIndex] = kvSuperTanks.GetFloat("General/Tank Chance", 100.0);
					g_flTankChance[iIndex] = flClamp(g_flTankChance[iIndex], 0.0, 100.0);
					g_iTankNote[iIndex] = kvSuperTanks.GetNum("General/Tank Note", 0);
					g_iTankNote[iIndex] = iClamp(g_iTankNote[iIndex], 0, 1);
					g_iSpawnEnabled[iIndex] = kvSuperTanks.GetNum("General/Spawn Enabled", 1);
					g_iSpawnEnabled[iIndex] = iClamp(g_iSpawnEnabled[iIndex], 0, 1);
					g_iMenuEnabled[iIndex] = kvSuperTanks.GetNum("General/Menu Enabled", 1);
					g_iMenuEnabled[iIndex] = iClamp(g_iMenuEnabled[iIndex], 0, 1);
					g_iHumanSupport[iIndex] = kvSuperTanks.GetNum("General/Human Support", 0);
					g_iHumanSupport[iIndex] = iClamp(g_iHumanSupport[iIndex], 0, 1);
					kvSuperTanks.GetColor("General/Skin Color", g_iSkinRed[iIndex], g_iSkinGreen[iIndex], g_iSkinBlue[iIndex], g_iSkinAlpha[iIndex]);
					g_iGlowEnabled[iIndex] = kvSuperTanks.GetNum("General/Glow Enabled", 0);
					g_iGlowEnabled[iIndex] = iClamp(g_iGlowEnabled[iIndex], 0, 1);
					int iAlpha;
					kvSuperTanks.GetColor("General/Glow Color", g_iGlowRed[iIndex], g_iGlowGreen[iIndex], g_iGlowBlue[iIndex], iAlpha);

					g_iTypeLimit[iIndex] = kvSuperTanks.GetNum("Spawn/Type Limit", 32);
					g_iTypeLimit[iIndex] = iClamp(g_iTypeLimit[iIndex], 0, 64);
					g_iFinaleTank[iIndex] = kvSuperTanks.GetNum("Spawn/Finale Tank", 0);
					g_iFinaleTank[iIndex] = iClamp(g_iFinaleTank[iIndex], 0, 1);
					kvSuperTanks.GetString("Spawn/Boss Health Stages", g_sBossHealthStages[iIndex], sizeof(g_sBossHealthStages[]), "5000,2500,1500,1000");
					g_iBossStages[iIndex] = kvSuperTanks.GetNum("Spawn/Boss Stages", 3);
					g_iBossStages[iIndex] = iClamp(g_iBossStages[iIndex], 1, 4);
					kvSuperTanks.GetString("Spawn/Boss Types", g_sBossTypes[iIndex], sizeof(g_sBossTypes[]), "2,3,4,5");
					g_iRandomTank[iIndex] = kvSuperTanks.GetNum("Spawn/Random Tank", 1);
					g_iRandomTank[iIndex] = iClamp(g_iRandomTank[iIndex], 0, 1);
					g_flRandomInterval[iIndex] = kvSuperTanks.GetFloat("Spawn/Random Interval", 5.0);
					g_flRandomInterval[iIndex] = flClamp(g_flRandomInterval[iIndex], 0.1, 9999999999.0);
					g_flTransformDelay[iIndex] = kvSuperTanks.GetFloat("Spawn/Transform Delay", 10.0);
					g_flTransformDelay[iIndex] = flClamp(g_flTransformDelay[iIndex], 0.1, 9999999999.0);
					g_flTransformDuration[iIndex] = kvSuperTanks.GetFloat("Spawn/Transform Duration", 10.0);
					g_flTransformDuration[iIndex] = flClamp(g_flTransformDuration[iIndex], 0.1, 9999999999.0);
					kvSuperTanks.GetString("Spawn/Transform Types", g_sTransformTypes[iIndex], sizeof(g_sTransformTypes[]), "1,2,3,4,5,6,7,8,9,10");
					g_iSpawnMode[iIndex] = kvSuperTanks.GetNum("Spawn/Spawn Mode", 0);
					g_iSpawnMode[iIndex] = iClamp(g_iSpawnMode[iIndex], 0, 3);

					kvSuperTanks.GetString("Props/Props Attached", g_sPropsAttached[iIndex], sizeof(g_sPropsAttached[]), "23456");
					kvSuperTanks.GetString("Props/Props Chance", g_sPropsChance[iIndex], sizeof(g_sPropsChance[]), "33.3,33.3,33.3,33.3,33.3,33.3");
					kvSuperTanks.GetColor("Props/Light Color", g_iLightRed[iIndex], g_iLightGreen[iIndex], g_iLightBlue[iIndex], g_iLightAlpha[iIndex]);
					kvSuperTanks.GetColor("Props/Oxygen Tank Color", g_iJetpackRed[iIndex], g_iJetpackGreen[iIndex], g_iJetpackBlue[iIndex], g_iJetpackAlpha[iIndex]);
					kvSuperTanks.GetColor("Props/Flame Color", g_iFlameRed[iIndex], g_iFlameGreen[iIndex], g_iFlameBlue[iIndex], g_iFlameAlpha[iIndex]);
					kvSuperTanks.GetColor("Props/Rock Color", g_iRockRed[iIndex], g_iRockGreen[iIndex], g_iRockBlue[iIndex], g_iRockAlpha[iIndex]);
					kvSuperTanks.GetColor("Props/Tire Color", g_iTireRed[iIndex], g_iTireGreen[iIndex], g_iTireBlue[iIndex], g_iTireAlpha[iIndex]);

					g_iParticleEffect[iIndex] = kvSuperTanks.GetNum("Particles/Body Particle", 0);
					g_iParticleEffect[iIndex] = iClamp(g_iParticleEffect[iIndex], 0, 1);
					kvSuperTanks.GetString("Particles/Body Effects", g_sParticleEffects[iIndex], sizeof(g_sParticleEffects[]), "1234567");
					g_iRockEffect[iIndex] = kvSuperTanks.GetNum("Particles/Rock Particle", 0);
					g_iRockEffect[iIndex] = iClamp(g_iRockEffect[iIndex], 0, 1);
					kvSuperTanks.GetString("Particles/Rock Effects", g_sRockEffects[iIndex], sizeof(g_sRockEffects[]), "1234");

					g_flClawDamage[iIndex] = kvSuperTanks.GetFloat("Enhancements/Claw Damage", -1.0);
					g_flClawDamage[iIndex] = flClamp(g_flClawDamage[iIndex], -1.0, 9999999999.0);
					g_iExtraHealth[iIndex] = kvSuperTanks.GetNum("Enhancements/Extra Health", 0);
					g_iExtraHealth[iIndex] = iClamp(g_iExtraHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					g_flRockDamage[iIndex] = kvSuperTanks.GetFloat("Enhancements/Rock Damage", -1.0);
					g_flRockDamage[iIndex] = flClamp(g_flRockDamage[iIndex], -1.0, 9999999999.0);
					g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", -1.0);
					g_flRunSpeed[iIndex] = flClamp(g_flRunSpeed[iIndex], -1.0, 3.0);
					g_flThrowInterval[iIndex] = kvSuperTanks.GetFloat("Enhancements/Throw Interval", -1.0);
					g_flThrowInterval[iIndex] = flClamp(g_flThrowInterval[iIndex], -1.0, 9999999999.0);

					g_iBulletImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Bullet Immunity", 0);
					g_iBulletImmunity[iIndex] = iClamp(g_iBulletImmunity[iIndex], 0, 1);
					g_iExplosiveImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Explosive Immunity", 0);
					g_iExplosiveImmunity[iIndex] = iClamp(g_iExplosiveImmunity[iIndex], 0, 1);
					g_iFireImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Fire Immunity", 0);
					g_iFireImmunity[iIndex] = iClamp(g_iFireImmunity[iIndex], 0, 1);
					g_iMeleeImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Melee Immunity", 0);
					g_iMeleeImmunity[iIndex] = iClamp(g_iMeleeImmunity[iIndex], 0, 1);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					kvSuperTanks.GetString("General/Tank Name", g_sTankName2[iIndex], sizeof(g_sTankName2[]), g_sTankName[iIndex]);
					g_iTankEnabled2[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", g_iTankEnabled[iIndex]);
					g_iTankEnabled2[iIndex] = iClamp(g_iTankEnabled2[iIndex], 0, 1);
					g_flTankChance2[iIndex] = kvSuperTanks.GetFloat("General/Tank Chance", g_flTankChance[iIndex]);
					g_flTankChance2[iIndex] = flClamp(g_flTankChance2[iIndex], 0.0, 100.0);
					g_iTankNote2[iIndex] = kvSuperTanks.GetNum("General/Tank Note", g_iTankNote[iIndex]);
					g_iTankNote2[iIndex] = iClamp(g_iTankNote2[iIndex], 0, 1);
					g_iSpawnEnabled2[iIndex] = kvSuperTanks.GetNum("General/Spawn Enabled", g_iSpawnEnabled[iIndex]);
					g_iSpawnEnabled2[iIndex] = iClamp(g_iSpawnEnabled2[iIndex], 0, 1);
					g_iMenuEnabled2[iIndex] = kvSuperTanks.GetNum("General/Menu Enabled", g_iMenuEnabled[iIndex]);
					g_iMenuEnabled2[iIndex] = iClamp(g_iMenuEnabled2[iIndex], 0, 1);
					g_iHumanSupport2[iIndex] = kvSuperTanks.GetNum("General/Human Support", g_iHumanSupport[iIndex]);
					g_iHumanSupport2[iIndex] = iClamp(g_iHumanSupport2[iIndex], 0, 1);
					kvSuperTanks.GetColor("General/Skin Color", g_iSkinRed2[iIndex], g_iSkinGreen2[iIndex], g_iSkinBlue2[iIndex], g_iSkinAlpha2[iIndex]);
					g_iGlowEnabled2[iIndex] = kvSuperTanks.GetNum("General/Glow Enabled", g_iGlowEnabled[iIndex]);
					g_iGlowEnabled2[iIndex] = iClamp(g_iGlowEnabled2[iIndex], 0, 1);
					int iAlpha;
					kvSuperTanks.GetColor("General/Glow Color", g_iGlowRed2[iIndex], g_iGlowGreen2[iIndex], g_iGlowBlue2[iIndex], iAlpha);

					g_iTypeLimit2[iIndex] = kvSuperTanks.GetNum("Spawn/Type Limit", g_iTypeLimit[iIndex]);
					g_iTypeLimit2[iIndex] = iClamp(g_iTypeLimit2[iIndex], 0, 64);
					g_iFinaleTank2[iIndex] = kvSuperTanks.GetNum("Spawn/Finale Tank", g_iFinaleTank[iIndex]);
					g_iFinaleTank2[iIndex] = iClamp(g_iFinaleTank2[iIndex], 0, 1);
					kvSuperTanks.GetString("Spawn/Boss Health Stages", g_sBossHealthStages2[iIndex], sizeof(g_sBossHealthStages2[]), g_sBossHealthStages[iIndex]);
					g_iBossStages2[iIndex] = kvSuperTanks.GetNum("Spawn/Boss Stages", g_iBossStages[iIndex]);
					g_iBossStages2[iIndex] = iClamp(g_iBossStages2[iIndex], 1, 4);
					kvSuperTanks.GetString("Spawn/Boss Types", g_sBossTypes2[iIndex], sizeof(g_sBossTypes2[]), g_sBossTypes[iIndex]);
					g_iRandomTank2[iIndex] = kvSuperTanks.GetNum("Spawn/Random Tank", g_iRandomTank[iIndex]);
					g_iRandomTank2[iIndex] = iClamp(g_iRandomTank2[iIndex], 0, 1);
					g_flRandomInterval2[iIndex] = kvSuperTanks.GetFloat("Spawn/Random Interval", g_flRandomInterval[iIndex]);
					g_flRandomInterval2[iIndex] = flClamp(g_flRandomInterval2[iIndex], 0.1, 9999999999.0);
					g_flTransformDelay2[iIndex] = kvSuperTanks.GetFloat("Spawn/Transform Delay", g_flTransformDelay[iIndex]);
					g_flTransformDelay2[iIndex] = flClamp(g_flTransformDelay2[iIndex], 0.1, 9999999999.0);
					g_flTransformDuration2[iIndex] = kvSuperTanks.GetFloat("Spawn/Transform Duration", g_flTransformDuration[iIndex]);
					g_flTransformDuration2[iIndex] = flClamp(g_flTransformDuration2[iIndex], 0.1, 9999999999.0);
					kvSuperTanks.GetString("Spawn/Transform Types", g_sTransformTypes2[iIndex], sizeof(g_sTransformTypes2[]), g_sTransformTypes[iIndex]);
					g_iSpawnMode2[iIndex] = kvSuperTanks.GetNum("Spawn/Spawn Mode", g_iSpawnMode[iIndex]);
					g_iSpawnMode2[iIndex] = iClamp(g_iSpawnMode2[iIndex], 0, 3);

					kvSuperTanks.GetString("Props/Props Attached", g_sPropsAttached2[iIndex], sizeof(g_sPropsAttached2[]), g_sPropsAttached[iIndex]);
					kvSuperTanks.GetString("Props/Props Chance", g_sPropsChance2[iIndex], sizeof(g_sPropsChance2[]), g_sPropsChance[iIndex]);
					kvSuperTanks.GetColor("Props/Light Color", g_iLightRed2[iIndex], g_iLightGreen2[iIndex], g_iLightBlue2[iIndex], g_iLightAlpha2[iIndex]);
					kvSuperTanks.GetColor("Props/Oxygen Tank Color", g_iJetpackRed2[iIndex], g_iJetpackGreen2[iIndex], g_iJetpackBlue2[iIndex], g_iJetpackAlpha2[iIndex]);
					kvSuperTanks.GetColor("Props/Flame Color", g_iFlameRed2[iIndex], g_iFlameGreen2[iIndex], g_iFlameBlue2[iIndex], g_iFlameAlpha2[iIndex]);
					kvSuperTanks.GetColor("Props/Rock Color", g_iRockRed2[iIndex], g_iRockGreen2[iIndex], g_iRockBlue2[iIndex], g_iRockAlpha2[iIndex]);
					kvSuperTanks.GetColor("Props/Tire Color", g_iTireRed2[iIndex], g_iTireGreen2[iIndex], g_iTireBlue2[iIndex], g_iTireAlpha2[iIndex]);

					g_iParticleEffect2[iIndex] = kvSuperTanks.GetNum("Particles/Body Particle", g_iParticleEffect[iIndex]);
					g_iParticleEffect2[iIndex] = iClamp(g_iParticleEffect2[iIndex], 0, 1);
					kvSuperTanks.GetString("Particles/Body Effects", g_sParticleEffects2[iIndex], sizeof(g_sParticleEffects2[]), g_sParticleEffects[iIndex]);
					g_iRockEffect2[iIndex] = kvSuperTanks.GetNum("Particles/Rock Particle", g_iRockEffect[iIndex]);
					g_iRockEffect2[iIndex] = iClamp(g_iRockEffect2[iIndex], 0, 1);
					kvSuperTanks.GetString("Particles/Rock Effects", g_sRockEffects2[iIndex], sizeof(g_sRockEffects2[]), g_sRockEffects[iIndex]);

					g_flClawDamage2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Claw Damage", g_flClawDamage[iIndex]);
					g_flClawDamage2[iIndex] = flClamp(g_flClawDamage2[iIndex], -1.0, 9999999999.0);
					g_iExtraHealth2[iIndex] = kvSuperTanks.GetNum("Enhancements/Extra Health", g_iExtraHealth[iIndex]);
					g_iExtraHealth2[iIndex] = iClamp(g_iExtraHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					g_flRockDamage2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Rock Damage", g_flRockDamage[iIndex]);
					g_flRockDamage2[iIndex] = flClamp(g_flRockDamage2[iIndex], -1.0, 9999999999.0);
					g_flRunSpeed2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", g_flRunSpeed[iIndex]);
					g_flRunSpeed2[iIndex] = flClamp(g_flRunSpeed2[iIndex], -1.0, 3.0);
					g_flThrowInterval2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Throw Interval", g_flThrowInterval[iIndex]);
					g_flThrowInterval2[iIndex] = flClamp(g_flThrowInterval2[iIndex], -1.0, 9999999999.0);

					g_iBulletImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Bullet Immunity", g_iBulletImmunity[iIndex]);
					g_iBulletImmunity2[iIndex] = iClamp(g_iBulletImmunity2[iIndex], 0, 1);
					g_iExplosiveImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Explosive Immunity", g_iExplosiveImmunity[iIndex]);
					g_iExplosiveImmunity2[iIndex] = iClamp(g_iExplosiveImmunity2[iIndex], 0, 1);
					g_iFireImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Fire Immunity", g_iFireImmunity[iIndex]);
					g_iFireImmunity2[iIndex] = iClamp(g_iFireImmunity2[iIndex], 0, 1);
					g_iMeleeImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Melee Immunity", g_iMeleeImmunity[iIndex]);
					g_iMeleeImmunity2[iIndex] = iClamp(g_iMeleeImmunity2[iIndex], 0, 1);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;

	Call_StartForward(g_hConfigsLoadedForward);
	Call_PushString(savepath);
	Call_PushCell(main);
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

		int iNewHealth = g_iTankHealth[tank] + limit, iFinalHealth = (iNewHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth;
		SetEntityHealth(tank, iFinalHealth);
	}
}

static void vNewTankSettings(int tank)
{
	ExtinguishEntity(tank);
	vAttachParticle(tank, PARTICLE_ELECTRICITY, 2.0, 30.0);
	EmitSoundToAll(SOUND_BOSS, tank);
	vResetSpeed(tank, true);

	Call_StartForward(g_hChangeTypeForward);
	Call_PushCell(tank);
	Call_Finish();
}

static void vRemoveProps(int tank, int mode = 1)
{
	if (bIsValidEntity(g_iTankModel[tank]))
	{
		SDKUnhook(g_iTankModel[tank], SDKHook_SetTransmit, SetTransmit);
		RemoveEntity(g_iTankModel[tank]);
	}

	g_iTankModel[tank] = INVALID_ENT_REFERENCE;

	for (int iLight = 0; iLight < 3; iLight++)
	{
		if (bIsValidEntity(g_iLight[tank][iLight]))
		{
			SDKUnhook(g_iLight[tank][iLight], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iLight[tank][iLight]);
		}

		g_iLight[tank][iLight] = INVALID_ENT_REFERENCE;
	}

	for (int iOzTank = 0; iOzTank < 2; iOzTank++)
	{
		if (bIsValidEntity(g_iFlame[tank][iOzTank]))
		{
			SDKUnhook(g_iFlame[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iFlame[tank][iOzTank]);
		}

		g_iFlame[tank][iOzTank] = INVALID_ENT_REFERENCE;

		if (bIsValidEntity(g_iJetpack[tank][iOzTank]))
		{
			SDKUnhook(g_iJetpack[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iJetpack[tank][iOzTank]);
		}

		g_iJetpack[tank][iOzTank] = INVALID_ENT_REFERENCE;
	}

	for (int iRock = 0; iRock < 16; iRock++)
	{
		if (bIsValidEntity(g_iRock[tank][iRock]))
		{
			SDKUnhook(g_iRock[tank][iRock], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iRock[tank][iRock]);
		}

		g_iRock[tank][iRock] = INVALID_ENT_REFERENCE;
	}

	for (int iTire = 0; iTire < 2; iTire++)
	{
		if (bIsValidEntity(g_iTire[tank][iTire]))
		{
			SDKUnhook(g_iTire[tank][iTire], SDKHook_SetTransmit, SetTransmit);
			RemoveEntity(g_iTire[tank][iTire]);
		}

		g_iTire[tank][iTire] = INVALID_ENT_REFERENCE;
	}

	if (bIsValidGame() && iGlowEnabled(g_iTankType[tank]) == 1)
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
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset2(iPlayer);

			g_bAdminMenu[iPlayer] = false;
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
			if (flRunSpeed(tank) > 0.0)
			{
				SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", flRunSpeed(tank));
			}
		}
	}
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

	int iSkinRed = !g_bTankConfig[value] ? g_iSkinRed[value] : g_iSkinRed2[value],
		iSkinGreen = !g_bTankConfig[value] ? g_iSkinGreen[value] : g_iSkinGreen2[value],
		iSkinBlue = !g_bTankConfig[value] ? g_iSkinBlue[value] : g_iSkinBlue2[value],
		iSkinAlpha = !g_bTankConfig[value] ? g_iSkinAlpha[value] : g_iSkinAlpha2[value];
	SetEntityRenderMode(tank, RENDER_NORMAL);
	SetEntityRenderColor(tank, iSkinRed, iSkinGreen, iSkinBlue, iSkinAlpha);

	if (iGlowEnabled(value) == 1 && bIsValidGame())
	{
		int iGlowRed = !g_bTankConfig[value] ? g_iGlowRed[value] : g_iGlowRed2[value],
			iGlowGreen = !g_bTankConfig[value] ? g_iGlowGreen[value] : g_iGlowGreen2[value],
			iGlowBlue = !g_bTankConfig[value] ? g_iGlowBlue[value] : g_iGlowBlue2[value];
		SetEntProp(tank, Prop_Send, "m_iGlowType", 3);
		SetEntProp(tank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGlowRed, iGlowGreen, iGlowBlue));
	}

	g_iTankType[tank] = value;
}

static void vSetName(int tank, const char[] oldname, const char[] name, int mode)
{
	if (bIsTank(tank))
	{
		char sSet[6][4], sPropsChance[35], sPropsAttached[7];
		sPropsChance = !g_bTankConfig[g_iTankType[tank]] ? g_sPropsChance[g_iTankType[tank]] : g_sPropsChance2[g_iTankType[tank]];
		ReplaceString(sPropsChance, sizeof(sPropsChance), " ", "");
		ExplodeString(sPropsChance, ",", sSet, sizeof(sSet), sizeof(sSet[]));

		float flChance = (sSet[0][0] != '\0') ? StringToFloat(sSet[0]) : 33.3;
		flChance = flClamp(flChance, 0.0, 100.0);

		float flChance2 = (sSet[1][0] != '\0') ? StringToFloat(sSet[1]) : 33.3;
		flChance2 = flClamp(flChance2, 0.0, 100.0);

		float flChance3 = (sSet[2][0] != '\0') ? StringToFloat(sSet[2]) : 33.3;
		flChance3 = flClamp(flChance3, 0.0, 100.0);

		float flChance4 = (sSet[3][0] != '\0') ? StringToFloat(sSet[3]) : 33.3;
		flChance4 = flClamp(flChance4, 0.0, 100.0);

		float flChance5 = (sSet[4][0] != '\0') ? StringToFloat(sSet[4]) : 33.3;
		flChance5 = flClamp(flChance5, 0.0, 100.0);

		float flChance6 = (sSet[5][0] != '\0') ? StringToFloat(sSet[5]) : 33.3;
		flChance6 = flClamp(flChance6, 0.0, 100.0);

		sPropsAttached = !g_bTankConfig[g_iTankType[tank]] ? g_sPropsAttached[g_iTankType[tank]] : g_sPropsAttached2[g_iTankType[tank]];

		if (GetRandomFloat(0.1, 100.0) <= flChance && StrContains(sPropsAttached, "1") != -1 && !g_bBlur[tank])
		{
			g_bBlur[tank] = true;
			CreateTimer(0.25, tTimerBlurEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		float flOrigin[3], flAngles[3];

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		for (int iLight = 0; iLight < 3; iLight++)
		{
			if (g_iLight[tank][iLight] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flChance2 && StrContains(sPropsAttached, "2") != -1)
			{
				vLightProp(tank, iLight, flOrigin, flAngles);
			}
			else if (bIsValidEntity(g_iLight[tank][iLight]))
			{
				SDKUnhook(g_iLight[tank][iLight], SDKHook_SetTransmit, SetTransmit);
				RemoveEntity(g_iLight[tank][iLight]);

				if (StrContains(sPropsAttached, "2") != -1)
				{
					vLightProp(tank, iLight, flOrigin, flAngles);
				}
			}
		}

		GetClientEyePosition(tank, flOrigin);
		GetClientAbsAngles(tank, flAngles);

		for (int iOzTank = 0; iOzTank < 2; iOzTank++)
		{
			if (g_iJetpack[tank][iOzTank] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flChance3 && StrContains(sPropsAttached, "3") != -1)
			{
				g_iJetpack[tank][iOzTank] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_iJetpack[tank][iOzTank]))
				{
					SetEntityModel(g_iJetpack[tank][iOzTank], MODEL_JETPACK);

					vColorOzTanks(tank, iOzTank);

					SetEntProp(g_iJetpack[tank][iOzTank], Prop_Data, "m_takedamage", 0, 1);
					SetEntProp(g_iJetpack[tank][iOzTank], Prop_Send, "m_CollisionGroup", 2);
					vSetEntityParent(g_iJetpack[tank][iOzTank], tank, true);

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

					AcceptEntityInput(g_iJetpack[tank][iOzTank], "SetParentAttachment");

					float flAngles2[3];
					vSetVector(flAngles2, 0.0, 0.0, 1.0);
					GetVectorAngles(flAngles2, flAngles2);
					vCopyVector(flAngles, flAngles2);
					flAngles2[2] += 90.0;
					DispatchKeyValueVector(g_iJetpack[tank][iOzTank], "origin", flOrigin);
					DispatchKeyValueVector(g_iJetpack[tank][iOzTank], "angles", flAngles2);

					AcceptEntityInput(g_iJetpack[tank][iOzTank], "Enable");
					AcceptEntityInput(g_iJetpack[tank][iOzTank], "DisableCollision");

					TeleportEntity(g_iJetpack[tank][iOzTank], flOrigin, NULL_VECTOR, flAngles2);
					DispatchSpawn(g_iJetpack[tank][iOzTank]);

					if (g_iFlame[tank][iOzTank] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flChance4 && StrContains(sPropsAttached, "4") != -1)
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

							vSetEntityParent(g_iFlame[tank][iOzTank], g_iJetpack[tank][iOzTank], true);

							float flOrigin2[3], flAngles3[3];
							vSetVector(flOrigin2, -2.0, 0.0, 26.0);
							vSetVector(flAngles3, 0.0, 0.0, 1.0);
							GetVectorAngles(flAngles3, flAngles3);

							TeleportEntity(g_iFlame[tank][iOzTank], flOrigin2, flAngles3, NULL_VECTOR);
							DispatchSpawn(g_iFlame[tank][iOzTank]);
							AcceptEntityInput(g_iFlame[tank][iOzTank], "TurnOn");

							SDKHook(g_iFlame[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
						}
					}

					SDKHook(g_iJetpack[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
				}
			}
			else if (bIsValidEntity(g_iJetpack[tank][iOzTank]))
			{
				if (StrContains(sPropsAttached, "3") != -1)
				{
					vColorOzTanks(tank, iOzTank);
				}
				else
				{
					SDKUnhook(g_iJetpack[tank][iOzTank], SDKHook_SetTransmit, SetTransmit);
					RemoveEntity(g_iJetpack[tank][iOzTank]);

					g_iJetpack[tank][iOzTank] = INVALID_ENT_REFERENCE;
				}

				if (bIsValidEntity(g_iFlame[tank][iOzTank]))
				{
					if (StrContains(sPropsAttached, "4") != -1)
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
			if (g_iRock[tank][iRock] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flChance5 && StrContains(sPropsAttached, "5") != -1)
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
				}
			}
			else if (bIsValidEntity(g_iRock[tank][iRock]))
			{
				if (StrContains(sPropsAttached, "5") != -1)
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
			if (g_iTire[tank][iTire] == INVALID_ENT_REFERENCE && GetRandomFloat(0.1, 100.0) <= flChance6 && StrContains(sPropsAttached, "6") != -1)
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
				}
			}
			else if (bIsValidEntity(g_iTire[tank][iTire]))
			{
				if (StrContains(sPropsAttached, "6") != -1)
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

		if (!bIsValidClient(tank, "5"))
		{
			SetClientName(tank, name);
		}

		char sAnnounceArrival[6];
		sAnnounceArrival = !g_bGeneralConfig ? g_sAnnounceArrival : g_sAnnounceArrival2;
		switch (mode)
		{
			case 0: vAnnounceArrival(sAnnounceArrival, name);
			case 1:
			{
				if (StrContains(sAnnounceArrival, "2") != -1)
				{
					ST_PrintToChatAll("%s %t", ST_TAG2, "Evolved", oldname, name, g_iBossStageCount[tank] + 1);
				}
			}
			case 2:
			{
				if (StrContains(sAnnounceArrival, "3") != -1)
				{
					ST_PrintToChatAll("%s %t", ST_TAG2, "Randomized", oldname, name);
				}
			}
			case 3:
			{
				if (StrContains(sAnnounceArrival, "4") != -1)
				{
					ST_PrintToChatAll("%s %t", ST_TAG2, "Transformed", oldname, name);
				}
			}
			case 4:
			{
				if (StrContains(sAnnounceArrival, "5") != -1)
				{
					ST_PrintToChatAll("%s %t", ST_TAG2, "Untransformed", oldname, name);
				}
			}
			case 5:
			{
				vAnnounceArrival(sAnnounceArrival, name);
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChangeType");
			}
		}

		int iTankNote = !g_bTankConfig[g_iTankType[tank]] ? g_iTankNote[g_iTankType[tank]] : g_iTankNote2[g_iTankType[tank]];
		if (iTankNote == 1 && ST_IsCloneSupported(tank, g_bCloneInstalled))
		{
			char sTankNote[32];
			Format(sTankNote, sizeof(sTankNote), "Tank #%i", g_iTankType[tank]);
			switch (TranslationPhraseExists(sTankNote))
			{
				case true: ST_PrintToChatAll("%s %t", ST_TAG3, sTankNote);
				case false: ST_PrintToChatAll("%s %t", ST_TAG3, "NoNote");
			}
		}
	}
}

static void vAnnounceArrival(const char[] arrival, const char[] name)
{
	if (StrContains(arrival, "1") != -1)
	{
		switch (GetRandomInt(1, 10))
		{
			case 1: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival1", name);
			case 2: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival2", name);
			case 3: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival3", name);
			case 4: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival4", name);
			case 5: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival5", name);
			case 6: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival6", name);
			case 7: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival7", name);
			case 8: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival8", name);
			case 9: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival9", name);
			case 10: ST_PrintToChatAll("%s %t", ST_TAG2, "Arrival10", name);
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

		int iLightRed = !g_bTankConfig[g_iTankType[tank]] ? g_iLightRed[g_iTankType[tank]] : g_iLightRed2[g_iTankType[tank]],
			iLightGreen = !g_bTankConfig[g_iTankType[tank]] ? g_iLightGreen[g_iTankType[tank]] : g_iLightGreen2[g_iTankType[tank]],
			iLightBlue = !g_bTankConfig[g_iTankType[tank]] ? g_iLightBlue[g_iTankType[tank]] : g_iLightBlue2[g_iTankType[tank]],
			iLightAlpha = !g_bTankConfig[g_iTankType[tank]] ? g_iLightAlpha[g_iTankType[tank]] : g_iLightAlpha2[g_iTankType[tank]];
		SetEntityRenderColor(g_iLight[tank][light], iLightRed, iLightGreen, iLightBlue, iLightAlpha);

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
	}
}

static void vColorFlames(int tank, int oz)
{
	int iFlameRed = !g_bTankConfig[g_iTankType[tank]] ? g_iFlameRed[g_iTankType[tank]] : g_iFlameRed2[g_iTankType[tank]],
		iFlameGreen = !g_bTankConfig[g_iTankType[tank]] ? g_iFlameGreen[g_iTankType[tank]] : g_iFlameGreen2[g_iTankType[tank]],
		iFlameBlue = !g_bTankConfig[g_iTankType[tank]] ? g_iFlameBlue[g_iTankType[tank]] : g_iFlameBlue2[g_iTankType[tank]],
		iFlameAlpha = !g_bTankConfig[g_iTankType[tank]] ? g_iFlameAlpha[g_iTankType[tank]] : g_iFlameAlpha2[g_iTankType[tank]];
	SetEntityRenderColor(g_iFlame[tank][oz], iFlameRed, iFlameGreen, iFlameBlue, iFlameAlpha);
}

static void vColorOzTanks(int tank, int oz)
{
	int iJetpackRed = !g_bTankConfig[g_iTankType[tank]] ? g_iJetpackRed[g_iTankType[tank]] : g_iJetpackRed2[g_iTankType[tank]],
		iJetpackGreen = !g_bTankConfig[g_iTankType[tank]] ? g_iJetpackGreen[g_iTankType[tank]] : g_iJetpackGreen2[g_iTankType[tank]],
		iJetpackBlue = !g_bTankConfig[g_iTankType[tank]] ? g_iJetpackBlue[g_iTankType[tank]] : g_iJetpackBlue2[g_iTankType[tank]],
		iJetpackAlpha = !g_bTankConfig[g_iTankType[tank]] ? g_iJetpackAlpha[g_iTankType[tank]] : g_iJetpackAlpha2[g_iTankType[tank]];
	SetEntityRenderColor(g_iJetpack[tank][oz], iJetpackRed, iJetpackGreen, iJetpackBlue, iJetpackAlpha);
}

static void vColorRocks(int tank, int rock)
{
	int iRockRed = !g_bTankConfig[g_iTankType[tank]] ? g_iRockRed[g_iTankType[tank]] : g_iRockRed2[g_iTankType[tank]],
		iRockGreen = !g_bTankConfig[g_iTankType[tank]] ? g_iRockGreen[g_iTankType[tank]] : g_iRockGreen2[g_iTankType[tank]],
		iRockBlue = !g_bTankConfig[g_iTankType[tank]] ? g_iRockBlue[g_iTankType[tank]] : g_iRockBlue2[g_iTankType[tank]],
		iRockAlpha = !g_bTankConfig[g_iTankType[tank]] ? g_iRockAlpha[g_iTankType[tank]] : g_iRockAlpha2[g_iTankType[tank]];
	SetEntityRenderColor(g_iRock[tank][rock], iRockRed, iRockGreen, iRockBlue, iRockAlpha);
}

static void vColorTires(int tank, int tire)
{
	int iTireRed = !g_bTankConfig[g_iTankType[tank]] ? g_iTireRed[g_iTankType[tank]] : g_iTireRed2[g_iTankType[tank]],
		iTireGreen = !g_bTankConfig[g_iTankType[tank]] ? g_iTireGreen[g_iTankType[tank]] : g_iTireGreen2[g_iTankType[tank]],
		iTireBlue = !g_bTankConfig[g_iTankType[tank]] ? g_iTireBlue[g_iTankType[tank]] : g_iTireBlue2[g_iTankType[tank]],
		iTireAlpha = !g_bTankConfig[g_iTankType[tank]] ? g_iTireAlpha[g_iTankType[tank]] : g_iTireAlpha2[g_iTankType[tank]];
	SetEntityRenderColor(g_iTire[tank][tire], iTireRed, iTireGreen, iTireBlue, iTireAlpha);
}

static void vParticleEffects(int tank)
{
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[tank]] ? g_sParticleEffects[g_iTankType[tank]] : g_sParticleEffects2[g_iTankType[tank]];
	if (bIsTankAllowed(tank) && iParticleEffect(tank) == 1)
	{
		if (StrContains(sParticleEffects, "1") != -1 && !g_bBlood[tank])
		{
			g_bBlood[tank] = true;
			CreateTimer(0.75, tTimerBloodEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (StrContains(sParticleEffects, "2") != -1 && !g_bElectric[tank])
		{
			g_bElectric[tank] = true;
			CreateTimer(0.75, tTimerElectricEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (StrContains(sParticleEffects, "3") != -1 && !g_bFire[tank])
		{
			g_bFire[tank] = true;
			CreateTimer(0.75, tTimerFireEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (StrContains(sParticleEffects, "4") != -1 && !g_bIce[tank])
		{
			g_bIce[tank] = true;
			CreateTimer(2.0, tTimerIceEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (StrContains(sParticleEffects, "5") != -1 && !g_bMeteor[tank])
		{
			g_bMeteor[tank] = true;
			CreateTimer(6.0, tTimerMeteorEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (StrContains(sParticleEffects, "6") != -1 && !g_bSmoke[tank])
		{
			g_bSmoke[tank] = true;
			CreateTimer(1.5, tTimerSmokeEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (StrContains(sParticleEffects, "7") != -1 && bIsValidGame() && !g_bSpit[tank])
		{
			g_bSpit[tank] = true;
			CreateTimer(2.0, tTimerSpitEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

static void vSuperTank(int tank)
{
	int iFinalesOnly = !g_bGeneralConfig ? g_iFinalesOnly : g_iFinalesOnly2;
	if (iFinalesOnly == 0 || (iFinalesOnly == 1 && (bIsFinaleMap() || g_iTankWave > 0)))
	{
		if (g_iType <= 0)
		{
			int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
			for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
			{
				if (iTankEnabled(iIndex) == 0 || iSpawnEnabled(iIndex) == 0 || !bTankChance(iIndex) || (iTypeLimit(iIndex) > 0 && iGetTypeCount(iIndex) >= iTypeLimit(iIndex)) || (iFinaleTank(iIndex) == 1 && (!bIsFinaleMap() || g_iTankWave <= 0)) || g_iTankType[tank] == iIndex)
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
				g_bSpawned[tank] = false;
			}
		}
		else
		{
			vSetColor(tank, g_iType);
			g_bSpawned[tank] = true;
		}

		g_iType = 0;

		char sNumbers[3][3], sFinaleWaves[9];
		sFinaleWaves = !g_bGeneralConfig ? g_sFinaleWaves : g_sFinaleWaves2;
		ReplaceString(sFinaleWaves, sizeof(sFinaleWaves), " ", "");
		ExplodeString(sFinaleWaves, ",", sNumbers, sizeof(sNumbers), sizeof(sNumbers[]));

		int iWave = (sNumbers[0][0] != '\0') ? StringToInt(sNumbers[0]) : 1;
		iWave = iClamp(iWave, 1, 64);

		int iWave2 = (sNumbers[1][0] != '\0') ? StringToInt(sNumbers[1]) : 2;
		iWave2 = iClamp(iWave2, 1, 64);

		int iWave3 = (sNumbers[2][0] != '\0') ? StringToInt(sNumbers[2]) : 3;
		iWave3 = iClamp(iWave3, 1, 64);

		switch (g_iTankWave)
		{
			case 1: vTankCountCheck(tank, iWave);
			case 2: vTankCountCheck(tank, iWave2);
			case 3: vTankCountCheck(tank, iWave3);
		}

		vTankSpawn(tank);
	}
}

static void vTankCountCheck(int tank, int wave)
{
	if (iGetTankCount() == wave)
	{
		return;
	}

	if (iGetTankCount() < wave)
	{
		CreateTimer(3.0, tTimerSpawnTanks, wave, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (iGetTankCount() > wave)
	{
		switch (bIsValidClient(tank, "5"))
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
	if (bIsTankAllowed(tank) && !bIsTankAllowed(tank, "5") && time > 0.0)
	{
		int iAbility = GetEntPropEnt(tank, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", time);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", GetGameTime() + time);
		}
	}
}

static bool bIsTankAllowed(int tank, const char[] mode = "0234")
{
	if (!bIsTank(tank, mode))
	{
		return false;
	}

	if (bIsTank(tank, "5") && iHumanSupport(tank) == 0)
	{
		return false;
	}

	return true;
}

static bool bTankChance(int value)
{
	float flTankChance = !g_bTankConfig[value] ? g_flTankChance[value] : g_flTankChance2[value];
	if (GetRandomFloat(0.1, 100.0) <= flTankChance)
	{
		return true;
	}

	return false;
}

static float flRunSpeed(int tank)
{
	return !g_bTankConfig[g_iTankType[tank]] ? g_flRunSpeed[g_iTankType[tank]] : g_flRunSpeed2[g_iTankType[tank]];
}

static float flThrowInterval(int tank)
{
	return !g_bTankConfig[g_iTankType[tank]] ? g_flThrowInterval[g_iTankType[tank]] : g_flThrowInterval2[g_iTankType[tank]];
}

static int iFinaleTank(int value)
{
	return !g_bTankConfig[value] ? g_iFinaleTank[value] : g_iFinaleTank2[value];
}

static int iFireImmunity(int tank)
{
	return !g_bTankConfig[g_iTankType[tank]] ? g_iFireImmunity[g_iTankType[tank]] : g_iFireImmunity2[g_iTankType[tank]];
}

static int iGetMaxType()
{
	char sTypeRange[8], sRange[2][4];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ReplaceString(sTypeRange, sizeof(sTypeRange), " ", "");
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));

	int iMaxType = (sRange[1][0] != '\0') ? StringToInt(sRange[1]) : ST_MAXTYPES;
	iMaxType = iClamp(iMaxType, 1, ST_MAXTYPES);

	return iMaxType;
}

static int iGetMinType()
{
	char sTypeRange[8], sRange[2][4];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ReplaceString(sTypeRange, sizeof(sTypeRange), " ", "");
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));

	int iMinType = (sRange[0][0] != '\0') ? StringToInt(sRange[0]) : 1;
	iMinType = iClamp(iMinType, 1, ST_MAXTYPES);

	return iMinType;
}

static int iGetTankCount()
{
	int iTankCount;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, "234") && !g_bSpawned[iTank])
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
		if (bIsTankAllowed(iTank, "234") && ST_IsCloneSupported(iTank, g_bCloneInstalled) && g_iTankType[iTank] == type)
		{
			iType++;
		}
	}

	return iType;
}

static int iGlowEnabled(int value)
{
	return !g_bTankConfig[value] ? g_iGlowEnabled[value] : g_iGlowEnabled2[value];
}

static int iHumanSupport(int tank)
{
	return !g_bTankConfig[g_iTankType[tank]] ? g_iHumanSupport[g_iTankType[tank]] : g_iHumanSupport2[g_iTankType[tank]];
}

static int iMenuEnabled(int value)
{
	return !g_bTankConfig[value] ? g_iMenuEnabled[value] : g_iMenuEnabled2[value];
}

static int iParticleEffect(int tank)
{
	return !g_bTankConfig[g_iTankType[tank]] ? g_iParticleEffect[g_iTankType[tank]] : g_iParticleEffect2[g_iTankType[tank]];
}

static int iPluginEnabled()
{
	return !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
}

static int iRockEffect(int tank)
{
	return !g_bTankConfig[g_iTankType[tank]] ? g_iRockEffect[g_iTankType[tank]] : g_iRockEffect2[g_iTankType[tank]];
}

static int iSpawnEnabled(int value)
{
	return !g_bTankConfig[value] ? g_iSpawnEnabled[value] : g_iSpawnEnabled2[value];
}

static int iSpawnMode(int value)
{
	return !g_bTankConfig[value] ? g_iSpawnMode[value] : g_iSpawnMode2[value];
}

static int iSTMode()
{
	return !g_bGeneralConfig ? g_iSTMode : g_iSTMode2;
}

static int iTankEnabled(int value)
{
	return !g_bTankConfig[value] ? g_iTankEnabled[value] : g_iTankEnabled2[value];
}

static int iTypeLimit(int type)
{
	return !g_bTankConfig[type] ? g_iTypeLimit[type] : g_iTypeLimit2[type];
}

public void vSTGameDifficultyCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (StrContains(g_sConfigExecute, "1") != -1)
	{
		char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_cvSTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));

		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
		vLoadConfigs(sDifficultyConfig);
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
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "1") == -1 || !g_bBlood[iTank])
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
	char sPropsAttached[7];
	sPropsAttached = !g_bTankConfig[g_iTankType[iTank]] ? g_sPropsAttached[g_iTankType[iTank]] : g_sPropsAttached2[g_iTankType[iTank]];
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || StrContains(sPropsAttached, "1") == -1 || !g_bBlur[iTank])
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

		int iSkinRed = !g_bTankConfig[g_iTankType[iTank]] ? g_iSkinRed[g_iTankType[iTank]] : g_iSkinRed2[g_iTankType[iTank]],
			iSkinGreen = !g_bTankConfig[g_iTankType[iTank]] ? g_iSkinGreen[g_iTankType[iTank]] : g_iSkinGreen2[g_iTankType[iTank]],
			iSkinBlue = !g_bTankConfig[g_iTankType[iTank]] ? g_iSkinBlue[g_iTankType[iTank]] : g_iSkinBlue2[g_iTankType[iTank]],
			iSkinAlpha = !g_bTankConfig[g_iTankType[iTank]] ? g_iSkinAlpha[g_iTankType[iTank]] : g_iSkinAlpha2[g_iTankType[iTank]];
		SetEntityRenderColor(g_iTankModel[iTank], iSkinRed, iSkinGreen, iSkinBlue, iSkinAlpha);

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
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bBoss[iTank])
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
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "2") == -1 || !g_bElectric[iTank])
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
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "3") == -1 || !g_bFire[iTank])
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
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "4") == -1 || !g_bIce[iTank])
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

	ForcePlayerSuicide(iTank);

	return Plugin_Continue;
}

public Action tTimerMeteorEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "5") == -1 || !g_bMeteor[iTank])
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
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bRandomized[iTank])
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	vNewTankSettings(iTank);

	int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
	for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
	{
		int iRandomTank = !g_bTankConfig[iIndex] ? g_iRandomTank[iIndex] : g_iRandomTank2[iIndex];
		if (iTankEnabled(iIndex) == 0 || iRandomTank == 0 || g_iTankType[iTank] == iIndex)
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
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "6") == -1 || !g_bSmoke[iTank])
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
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "7") == -1 || !g_bSpit[iTank])
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
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bTransformed[iTank])
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	vNewTankSettings(iTank);

	char sTransform[10][5], sTransformTypes[80];
	sTransformTypes = !g_bTankConfig[g_iTankType[iTank]] ? g_sTransformTypes[g_iTankType[iTank]] : g_sTransformTypes2[g_iTankType[iTank]];
	ReplaceString(sTransformTypes, sizeof(sTransformTypes), " ", "");
	ExplodeString(sTransformTypes, ",", sTransform, sizeof(sTransform), sizeof(sTransform[]));

	int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
	for (int iTypes = 0; iTypes < sizeof(sTransform); iTypes++)
	{
		if (sTransform[iTypes][0] == '\0')
		{
			continue;
		}

		iTankTypes[iTypeCount + 1] = StringToInt(sTransform[iTypes]);
		iTypeCount++;
	}

	if (iTypeCount > 0)
	{
		int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
		vSetColor(iTank, iChosen);
	}

	vTankSpawn(iTank, 3);

	return Plugin_Continue;
}

public Action tTimerUntransform(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || !ST_IsCloneSupported(iTank, g_bCloneInstalled))
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
	if (!g_bPluginEnabled || StrContains(g_sConfigExecute, "5") == -1 || g_iPlayerCount[0] == g_iPlayerCount[1])
	{
		return Plugin_Continue;
	}

	g_iPlayerCount[1] = iGetPlayerCount();
	if (g_iPlayerCount[0] != g_iPlayerCount[1])
	{
		char sCountConfig[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/super_tanks++/playercount_configs/%i.cfg", g_iPlayerCount[1]);
		vLoadConfigs(sCountConfig);
		vPluginStatus();
		g_iPlayerCount[0] = g_iPlayerCount[1];
	}

	return Plugin_Continue;
}

public Action tTimerTankHealthUpdate(Handle timer)
{
	if (!g_bPluginEnabled)
	{
		return Plugin_Continue;
	}

	int iDisplayHealth = !g_bGeneralConfig ? g_iDisplayHealth : g_iDisplayHealth2;
	if (iDisplayHealth > 0)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, "2345"))
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
							char sTankName[33];
							sTankName = !g_bTankConfig[g_iTankType[iTarget]] ? g_sTankName[g_iTankType[iTarget]] : g_sTankName2[g_iTankType[iTarget]];
							if (StrEqual(sTankName, ""))
							{
								sTankName = "Tank";
							}

							int iHealth = GetClientHealth(iTarget);
							switch (iDisplayHealth)
							{
								case 1: PrintHintText(iPlayer, "%s", sTankName);
								case 2: PrintHintText(iPlayer, "%i HP", iHealth);
								case 3: PrintHintText(iPlayer, "%s (%i HP)", sTankName, iHealth);
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

	g_cvSTMaxPlayerZombies.SetString("32");

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTankAllowed(iTank, "234") && ST_IsCloneSupported(iTank, g_bCloneInstalled) && g_iTankType[iTank] > 0)
		{
			switch (iSpawnMode(g_iTankType[iTank]))
			{
				case 1:
				{
					if (!g_bBoss[iTank])
					{
						vSpawnModes(iTank, true);

						char sSet[4][6], sBossHealthStages[25], sSet2[4][5], sBossTypes[20];
						sBossHealthStages = !g_bTankConfig[g_iTankType[iTank]] ? g_sBossHealthStages[g_iTankType[iTank]] : g_sBossHealthStages2[g_iTankType[iTank]];
						ReplaceString(sBossHealthStages, sizeof(sBossHealthStages), " ", "");
						ExplodeString(sBossHealthStages, ",", sSet, sizeof(sSet), sizeof(sSet[]));

						int iBossHealth = (sSet[0][0] != '\0') ? StringToInt(sSet[0]) : 5000;
						iBossHealth = iClamp(iBossHealth, 1, ST_MAXHEALTH);

						int iBossHealth2 = (sSet[1][0] != '\0') ? StringToInt(sSet[1]) : 2500;
						iBossHealth2 = iClamp(iBossHealth2, 1, ST_MAXHEALTH);

						int iBossHealth3 = (sSet[2][0] != '\0') ? StringToInt(sSet[2]) : 1500;
						iBossHealth3 = iClamp(iBossHealth3, 1, ST_MAXHEALTH);

						int iBossHealth4 = (sSet[3][0] != '\0') ? StringToInt(sSet[3]) : 1000;
						iBossHealth4 = iClamp(iBossHealth4, 1, ST_MAXHEALTH);

						int iBossStages = !g_bTankConfig[g_iTankType[iTank]] ? g_iBossStages[g_iTankType[iTank]] : g_iBossStages2[g_iTankType[iTank]];

						sBossTypes = !g_bTankConfig[ST_GetTankType(iTank)] ? g_sBossTypes[ST_GetTankType(iTank)] : g_sBossTypes2[ST_GetTankType(iTank)];
						ReplaceString(sBossTypes, sizeof(sBossTypes), " ", "");
						ExplodeString(sBossTypes, ",", sSet2, sizeof(sSet2), sizeof(sSet2[]));

						int iType = (sSet2[0][0] != '\0') ? StringToInt(sSet2[0]) : 2;
						iType = iClamp(iType, 1, 500);

						int iType2 = (sSet2[1][0] != '\0') ? StringToInt(sSet2[1]) : 3;
						iType2 = iClamp(iType2, 1, 500);

						int iType3 = (sSet2[2][0] != '\0') ? StringToInt(sSet2[2]) : 4;
						iType3 = iClamp(iType3, 1, 500);

						int iType4 = (sSet2[3][0] != '\0') ? StringToInt(sSet2[3]) : 5;
						iType4 = iClamp(iType4, 1, 500);

						DataPack dpBoss;
						CreateDataTimer(1.0, tTimerBoss, dpBoss, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpBoss.WriteCell(GetClientUserId(iTank));
						dpBoss.WriteCell(iBossHealth);
						dpBoss.WriteCell(iBossHealth2);
						dpBoss.WriteCell(iBossHealth3);
						dpBoss.WriteCell(iBossHealth4);
						dpBoss.WriteCell(iBossStages);
						dpBoss.WriteCell(iType);
						dpBoss.WriteCell(iType2);
						dpBoss.WriteCell(iType3);
						dpBoss.WriteCell(iType4);
					}
				}
				case 2:
				{
					if (!g_bRandomized[iTank])
					{
						vSpawnModes(iTank, true);

						float flRandomInterval = !g_bTankConfig[g_iTankType[iTank]] ? g_flRandomInterval[g_iTankType[iTank]] : g_flRandomInterval2[g_iTankType[iTank]];
						CreateTimer(flRandomInterval, tTimerRandomize, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					}
				}
				case 3:
				{
					if (!g_bTransformed[iTank])
					{
						vSpawnModes(iTank, true);

						float flTransformDelay = !g_bTankConfig[g_iTankType[iTank]] ? g_flTransformDelay[g_iTankType[iTank]] : g_flTransformDelay2[g_iTankType[iTank]],
							flTransformDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flTransformDuration[g_iTankType[iTank]] : g_flTransformDuration2[g_iTankType[iTank]];

						CreateTimer(flTransformDelay, tTimerTransform, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);

						DataPack dpUntransform;
						CreateDataTimer(flTransformDuration + flTransformDelay, tTimerUntransform, dpUntransform, TIMER_FLAG_NO_MAPCHANGE);
						dpUntransform.WriteCell(GetClientUserId(iTank));
						dpUntransform.WriteCell(g_iTankType[iTank]);
					}
				}
			}

			if (iFireImmunity(iTank) == 1 && bIsPlayerBurning(iTank))
			{
				ExtinguishEntity(iTank);
				SetEntPropFloat(iTank, Prop_Send, "m_burnPercent", 1.0);
			}

			Call_StartForward(g_hAbilityActivatedForward);
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
	if (!bIsTankAllowed(iTank))
	{
		return Plugin_Stop;
	}

	vParticleEffects(iTank);
	vThrowInterval(iTank, flThrowInterval(iTank));

	char sCurrentName[33], sTankName[33];
	GetClientName(iTank, sCurrentName, sizeof(sCurrentName));
	if (sCurrentName[0] == '\0')
	{
		sCurrentName = "Tank";
	}

	sTankName = !g_bTankConfig[g_iTankType[iTank]] ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[g_iTankType[iTank]];
	if (StrEqual(sTankName, ""))
	{
		sTankName = "Tank";
	}

	int iMode = pack.ReadCell();
	vSetName(iTank, sCurrentName, sTankName, iMode);

	if (iMode == 0 && ST_IsCloneSupported(iTank, g_bCloneInstalled))
	{
		int iHumanCount = iGetHumanCount(),
			iHealth = GetClientHealth(iTank),
			iBaseHealth = !g_bGeneralConfig ? g_iBaseHealth : g_iBaseHealth2,
			iSpawnHealth = (iBaseHealth > 0) ? iBaseHealth : iHealth,
			iMultiHealth = !g_bGeneralConfig ? g_iMultiHealth : g_iMultiHealth2,
			iExtraHealth = !g_bTankConfig[g_iTankType[iTank]] ? g_iExtraHealth[g_iTankType[iTank]] : g_iExtraHealth2[g_iTankType[iTank]],
			iExtraHealthNormal = iSpawnHealth + iExtraHealth,
			iExtraHealthBoost = (iHumanCount > 1) ? ((iSpawnHealth * iHumanCount) + iExtraHealth) : iExtraHealthNormal,
			iExtraHealthBoost2 = (iHumanCount > 1) ? (iSpawnHealth + (iHumanCount * iExtraHealth)) : iExtraHealthNormal,
			iExtraHealthBoost3 = (iHumanCount > 1) ? (iHumanCount * (iSpawnHealth + iExtraHealth)) : iExtraHealthNormal,
			iNoBoost = (iExtraHealthNormal > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthNormal,
			iBoost = (iExtraHealthBoost > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthBoost,
			iBoost2 = (iExtraHealthBoost2 > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthBoost2,
			iBoost3 = (iExtraHealthBoost3 > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthBoost3,
			iNegaNoBoost = (iExtraHealthNormal < iSpawnHealth) ? 1 : iExtraHealthNormal,
			iNegaBoost = (iExtraHealthBoost < iSpawnHealth) ? 1 : iExtraHealthBoost,
			iNegaBoost2 = (iExtraHealthBoost2 < iSpawnHealth) ? 1 : iExtraHealthBoost2,
			iNegaBoost3 = (iExtraHealthBoost3 < iSpawnHealth) ? 1 : iExtraHealthBoost3,
			iFinalNoHealth = (iExtraHealthNormal >= 0) ? iNoBoost : iNegaNoBoost,
			iFinalHealth = (iExtraHealthNormal >= 0) ? iBoost : iNegaBoost,
			iFinalHealth2 = (iExtraHealthNormal >= 0) ? iBoost2 : iNegaBoost2,
			iFinalHealth3 = (iExtraHealthNormal >= 0) ? iBoost3 : iNegaBoost3;

		switch (iMultiHealth)
		{
			case 0: SetEntityHealth(iTank, iFinalNoHealth);
			case 1: SetEntityHealth(iTank, iFinalHealth);
			case 2: SetEntityHealth(iTank, iFinalHealth2);
			case 3: SetEntityHealth(iTank, iFinalHealth3);
		}

		g_iTankHealth[iTank] = iHealth;

		if (bIsTankAllowed(iTank, "5"))
		{
			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SpawnMessage");
			ST_PrintToChat(iTank, "%s %t", ST_TAG2, "MainButton");
			ST_PrintToChat(iTank, "%s %t", ST_TAG2, "SubButton");
			ST_PrintToChat(iTank, "%s %t", ST_TAG2, "SpecialButton");
			ST_PrintToChat(iTank, "%s %t", ST_TAG2, "SpecialButton2");
		}
	}

	vResetSpeed(iTank);

	Call_StartForward(g_hPresetForward);
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
	if (!bIsTankAllowed(iTank) || iTankEnabled(g_iTankType[iTank]) == 0 || iRockEffect(iTank) == 0)
	{
		return Plugin_Stop;
	}

	char sClassname[32], sRockEffects[5];
	GetEntityClassname(iRock, sClassname, sizeof(sClassname));
	pack.ReadString(sRockEffects, sizeof(sRockEffects));
	if (StrEqual(sClassname, "tank_rock"))
	{
		if (StrContains(sRockEffects, "1") != -1)
		{
			vAttachParticle(iRock, PARTICLE_BLOOD, 0.75);
		}

		if (StrContains(sRockEffects, "2") != -1)
		{
			vAttachParticle(iRock, PARTICLE_ELECTRICITY, 0.75);
		}

		if (StrContains(sRockEffects, "3") != -1)
		{
			IgniteEntity(iRock, 100.0);
		}

		if (StrContains(sRockEffects, "4") != -1)
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
	if (!g_bPluginEnabled || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iThrower = GetEntPropEnt(iRock, Prop_Data, "m_hThrower");
	if (iThrower == 0 || !bIsTankAllowed(iThrower) || iTankEnabled(g_iTankType[iThrower]) == 0)
	{
		return Plugin_Stop;
	}

	int iRockRed = !g_bTankConfig[g_iTankType[iThrower]] ? g_iRockRed[g_iTankType[iThrower]] : g_iRockRed2[g_iTankType[iThrower]],
		iRockGreen = !g_bTankConfig[g_iTankType[iThrower]] ? g_iRockGreen[g_iTankType[iThrower]] : g_iRockGreen2[g_iTankType[iThrower]],
		iRockBlue = !g_bTankConfig[g_iTankType[iThrower]] ? g_iRockBlue[g_iTankType[iThrower]] : g_iRockBlue2[g_iTankType[iThrower]],
		iRockAlpha = !g_bTankConfig[g_iTankType[iThrower]] ? g_iRockAlpha[g_iTankType[iThrower]] : g_iRockAlpha2[g_iTankType[iThrower]];
	SetEntityRenderColor(iRock, iRockRed, iRockGreen, iRockBlue, iRockAlpha);

	char sRockEffects[5];
	sRockEffects = !g_bTankConfig[g_iTankType[iThrower]] ? g_sRockEffects[g_iTankType[iThrower]] : g_sRockEffects2[g_iTankType[iThrower]];
	ReplaceString(sRockEffects, sizeof(sRockEffects), " ", "");
	if (iRockEffect(iThrower) == 1 && sRockEffects[0] != '\0')
	{
		DataPack dpRockEffects;
		CreateDataTimer(0.75, tTimerRockEffects, dpRockEffects, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRockEffects.WriteCell(ref);
		dpRockEffects.WriteCell(GetClientUserId(iThrower));
		dpRockEffects.WriteString(sRockEffects);
	}

	Call_StartForward(g_hRockThrowForward);
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

	int iRegularWave = !g_bGeneralConfig ? g_iRegularWave : g_iRegularWave2,
		iRegularAmount = !g_bGeneralConfig ? g_iRegularAmount : g_iRegularAmount2;
	if (!g_bPluginEnabled || iRegularWave == 0 || iGetTankCount() >= iRegularAmount)
	{
		return Plugin_Continue;
	}

	for (int iAmount = 0; iAmount < iRegularAmount; iAmount++)
	{
		if (iGetTankCount() < iRegularAmount)
		{
			for (int iTank = 1; iTank <= MaxClients; iTank++)
			{
				if (bIsValidClient(iTank, "24"))
				{
					vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "tank auto");

					break;
				}
			}
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
		if (bIsValidClient(iTank, "24"))
		{
			vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "tank auto");

			break;
		}
	}

	return Plugin_Continue;
}

public Action tTimerTankWave(Handle timer, int wave)
{
	if (iGetTankCount() > 0)
	{
		return Plugin_Stop;
	}

	switch (wave)
	{
		case 1: g_iTankWave = 2;
		case 2: g_iTankWave = 3;
	}

	return Plugin_Continue;
}

public Action tTimerReloadConfigs(Handle timer)
{
	g_iFileTimeNew[0] = GetFileTime(g_sSavePath, FileTime_LastChange);
	if (g_iFileTimeOld[0] != g_iFileTimeNew[0])
	{
		PrintToServer("%s Reloading config file (%s)...", ST_TAG, g_sSavePath);
		vLoadConfigs(g_sSavePath, true);
		vPluginStatus();
		g_iFileTimeOld[0] = g_iFileTimeNew[0];
	}

	if (StrContains(g_sConfigExecute, "1") != -1 && g_iConfigEnable == 1 && g_cvSTDifficulty != null)
	{
		char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_cvSTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
		g_iFileTimeNew[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
		if (g_iFileTimeOld[1] != g_iFileTimeNew[1])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_TAG, sDifficultyConfig);
			vLoadConfigs(sDifficultyConfig);
			vPluginStatus();
			g_iFileTimeOld[1] = g_iFileTimeNew[1];
		}
	}

	if (StrContains(g_sConfigExecute, "2") != -1 && g_iConfigEnable == 1)
	{
		char sMap[64], sMapConfig[PLATFORM_MAX_PATH];
		GetCurrentMap(sMap, sizeof(sMap));
		BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), (bIsValidGame() ? "data/super_tanks++/l4d2_map_configs/%s.cfg" : "data/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
		g_iFileTimeNew[2] = GetFileTime(sMapConfig, FileTime_LastChange);
		if (g_iFileTimeOld[2] != g_iFileTimeNew[2])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_TAG, sMapConfig);
			vLoadConfigs(sMapConfig);
			vPluginStatus();
			g_iFileTimeOld[2] = g_iFileTimeNew[2];
		}
	}

	if (StrContains(g_sConfigExecute, "3") != -1 && g_iConfigEnable == 1)
	{
		char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
		g_cvSTGameMode.GetString(sMode, sizeof(sMode));
		BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), (bIsValidGame() ? "data/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "data/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
		g_iFileTimeNew[3] = GetFileTime(sModeConfig, FileTime_LastChange);
		if (g_iFileTimeOld[3] != g_iFileTimeNew[3])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_TAG, sModeConfig);
			vLoadConfigs(sModeConfig);
			vPluginStatus();
			g_iFileTimeOld[3] = g_iFileTimeNew[3];
		}
	}

	if (StrContains(g_sConfigExecute, "4") != -1 && g_iConfigEnable == 1)
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

		BuildPath(Path_SM, sDayConfig, sizeof(sDayConfig), "data/super_tanks++/daily_configs/%s.cfg", sDay);
		g_iFileTimeNew[4] = GetFileTime(sDayConfig, FileTime_LastChange);
		if (g_iFileTimeOld[4] != g_iFileTimeNew[4])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_TAG, sDayConfig);
			vLoadConfigs(sDayConfig);
			vPluginStatus();
			g_iFileTimeOld[4] = g_iFileTimeNew[4];
		}
	}

	if (StrContains(g_sConfigExecute, "5") != -1 && g_iConfigEnable == 1)
	{
		char sCountConfig[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/super_tanks++/playercount_configs/%i.cfg", iGetPlayerCount());
		g_iFileTimeNew[5] = GetFileTime(sCountConfig, FileTime_LastChange);
		if (g_iFileTimeOld[5] != g_iFileTimeNew[5])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_TAG, sCountConfig);
			vLoadConfigs(sCountConfig);
			vPluginStatus();
			g_iFileTimeOld[5] = g_iFileTimeNew[5];
		}
	}
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !bIsTankAllowed(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bChanged[iTank])
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