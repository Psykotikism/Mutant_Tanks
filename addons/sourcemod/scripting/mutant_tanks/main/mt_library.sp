/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2021  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#if !defined MT_CORE_MAIN
	#error This file must be inside "scripting/mutant_tanks/main" while compiling "mutant_tanks.sp" to work.
#endif

void vRegisterForwards()
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
}

void vRegisterNatives()
{
	CreateNative("MT_CanTypeSpawn", aNative_CanTypeSpawn);
	CreateNative("MT_DetonateTankRock", aNative_DetonateTankRock);
	CreateNative("MT_DoesSurvivorHaveRewardType", aNative_DoesSurvivorHaveRewardType);
	CreateNative("MT_DoesTypeRequireHumans", aNative_DoesTypeRequireHumans);
	CreateNative("MT_GetAccessFlags", aNative_GetAccessFlags);
	CreateNative("MT_GetCombinationSetting", aNative_GetCombinationSetting);
	CreateNative("MT_GetConfigColors", aNative_GetConfigColors);
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
}

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

public any aNative_GetConfigColors(Handle plugin, int numParams)
{
	int iSize = GetNativeCell(2);
	char[] sColor = new char[iSize], sValue = new char[iSize];
	GetNativeString(3, sColor, iSize);
	vGetConfigColors(sValue, iSize, sColor);
	SetNativeString(1, sValue, iSize);
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
		bool bRainbow[6] = {false, false, false, false, false, false};
		bRainbow[0] = StrEqual(g_esCache[iTank].g_sOzTankColor, "rainbow", false);
		bRainbow[1] = StrEqual(g_esCache[iTank].g_sFlameColor, "rainbow", false);
		bRainbow[2] = StrEqual(g_esCache[iTank].g_sRockColor, "rainbow", false);
		bRainbow[3] = StrEqual(g_esCache[iTank].g_sTireColor, "rainbow", false);
		bRainbow[4] = StrEqual(g_esCache[iTank].g_sPropTankColor, "rainbow", false);
		bRainbow[5] = StrEqual(g_esCache[iTank].g_sFlashlightColor, "rainbow", false);
		int iColor[4];
		for (int iPos = 0; iPos < sizeof iColor; iPos++)
		{
			switch (iType)
			{
				case 1: iGetRandomColor(g_esCache[iTank].g_iLightColor[iPos]);
				case 2: iColor[iPos] = bRainbow[iType - 2] ? -2 : iGetRandomColor(g_esCache[iTank].g_iOzTankColor[iPos]);
				case 3: iColor[iPos] = bRainbow[iType - 2] ? -2 : iGetRandomColor(g_esCache[iTank].g_iFlameColor[iPos]);
				case 4: iColor[iPos] = bRainbow[iType - 2] ? -2 : iGetRandomColor(g_esCache[iTank].g_iRockColor[iPos]);
				case 5: iColor[iPos] = bRainbow[iType - 2] ? -2 : iGetRandomColor(g_esCache[iTank].g_iTireColor[iPos]);
				case 6: iColor[iPos] = bRainbow[iType - 2] ? -2 : iGetRandomColor(g_esCache[iTank].g_iPropTankColor[iPos]);
				case 7: iColor[iPos] = bRainbow[iType - 2] ? -2 : iGetRandomColor(g_esCache[iTank].g_iFlashlightColor[iPos]);
				case 8: iGetRandomColor(g_esCache[iTank].g_iCrownColor[iPos]);
			}

			SetNativeCellRef((iPos + 3), iColor[iPos]);
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
		bool bRainbow[2] = {false, false};
		bRainbow[0] = StrEqual(g_esCache[iTank].g_sSkinColor, "rainbow", false);
		bRainbow[1] = StrEqual(g_esCache[iTank].g_sGlowColor, "rainbow", false);
		int iColor[4];
		for (int iPos = 0; iPos < sizeof iColor; iPos++)
		{
			switch (iType)
			{
				case 1: iColor[iPos] = bRainbow[iType - 1] ? -2 : iGetRandomColor(g_esCache[iTank].g_iSkinColor[iPos]);
				case 2:
				{
					if (iPos < sizeof esCache::g_iGlowColor)
					{
						iColor[iPos] = bRainbow[iType - 1] ? -2 : iGetRandomColor(g_esCache[iTank].g_iGlowColor[iPos]);
					}
				}
			}

			SetNativeCellRef((iPos + 3), iColor[iPos]);
		}
	}
}

public any aNative_GetTankName(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof sTankName, iTank);
		SetNativeString(2, sTankName, sizeof sTankName);
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
		char sBuffer[PLATFORM_MAX_PATH];
		int iSize = 0, iResult = FormatNativeString(0, 2, 3, sizeof sBuffer, iSize, sBuffer);
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
				vSetTankColor(iTank, iType, .revert = (g_esPlayer[iTank].g_iTankType == iType));
				vTankSpawn(iTank, 5);
			}
			case false:
			{
				vResetTank3(iTank);
				vChangeTypeForward(iTank, g_esPlayer[iTank].g_iTankType, iType, (g_esPlayer[iTank].g_iTankType == iType));

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
	GetNativeArray(3, flDirection, sizeof flDirection);
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
		vQueueTank(iTank, iType, .log = false);
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

void vChangeTypeForward(int tank, int oldType, int newType, bool revert)
{
	Call_StartForward(g_esGeneral.g_gfChangeTypeForward);
	Call_PushCell(tank);
	Call_PushCell(oldType);
	Call_PushCell(newType);
	Call_PushCell(revert);
	Call_Finish();
}

void vCombineAbilitiesForward(int tank, int type, int survivor = 0, int weapon = 0, const char[] classname = "")
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

void vHookEventForward(bool mode)
{
	Call_StartForward(g_esGeneral.g_gfHookEventForward);
	Call_PushCell(mode);
	Call_Finish();
}

void vResetTimersForward(int mode = 0, int tank = 0)
{
	Call_StartForward(g_esGeneral.g_gfResetTimersForward);
	Call_PushCell(mode);
	Call_PushCell(tank);
	Call_Finish();
}