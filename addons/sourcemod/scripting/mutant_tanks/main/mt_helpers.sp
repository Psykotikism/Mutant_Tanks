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

void vFixRandomPick(char[] buffer, int size)
{
	if (StrEqual(buffer, "0"))
	{
		strcopy(buffer, size, "random");
	}
}

void vGetConfigColors(char[] buffer, int size, const char[] value, char delimiter = ',')
{
	switch (FindCharInString(value, delimiter) != -1)
	{
		case true: strcopy(buffer, size, value);
		case false:
		{
			if (g_esGeneral.g_alColorKeys[0] != null)
			{
				int iIndex = g_esGeneral.g_alColorKeys[0].FindString(value);

				switch (iIndex != -1 && g_esGeneral.g_alColorKeys[1] != null)
				{
					case true: g_esGeneral.g_alColorKeys[1].GetString(iIndex, buffer, size);
					case false: strcopy(buffer, size, value);
				}
			}
		}
	}
}

void vGetTranslatedName(char[] buffer, int size, int tank = 0, int type = 0)
{
	int iType = (type > 0) ? type : g_esPlayer[tank].g_iTankType;
	if (tank > 0 && g_esPlayer[tank].g_sTankName[0] != '\0')
	{
		char sPhrase[32], sPhrase2[32], sSteamIDFinal[32];
		FormatEx(sPhrase, sizeof sPhrase, "%s Name", g_esPlayer[tank].g_sSteamID32);
		FormatEx(sPhrase2, sizeof sPhrase2, "%s Name", g_esPlayer[tank].g_sSteam3ID);
		FormatEx(sSteamIDFinal, sizeof sSteamIDFinal, "%s", (TranslationPhraseExists(sPhrase) ? sPhrase : sPhrase2));

		switch (sSteamIDFinal[0] != '\0' && TranslationPhraseExists(sSteamIDFinal))
		{
			case true: strcopy(buffer, size, sSteamIDFinal);
			case false: strcopy(buffer, size, "NoName");
		}
	}
	else if (g_esTank[iType].g_sTankName[0] != '\0')
	{
		char sTankName[32];
		FormatEx(sTankName, sizeof sTankName, "Tank #%i Name", iType);

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

bool bAreHumansRequired(int type)
{
	int iCount = iGetHumanCount();
	return (g_esTank[type].g_iRequiresHumans > 0 && iCount < g_esTank[type].g_iRequiresHumans) || (g_esGeneral.g_iRequiresHumans > 0 && iCount < g_esGeneral.g_iRequiresHumans);
}

bool bCanTypeSpawn(int type = 0)
{
	int iCondition = (type > 0) ? g_esTank[type].g_iFinaleTank : g_esGeneral.g_iFinalesOnly;

	switch (iCondition)
	{
		case 0: return true;
		case 1: return g_esGeneral.g_bFinalMap || g_esGeneral.g_iTankWave > 0;
		case 2: return g_esGeneral.g_bNormalMap && g_esGeneral.g_iTankWave <= 0;
		case 3: return g_esGeneral.g_bFinalMap && g_esGeneral.g_iTankWave <= 0;
		case 4: return g_esGeneral.g_bFinalMap && g_esGeneral.g_iTankWave > 0;
	}

	return false;
}

bool bFoundSection(const char[] subsection, int index)
{
	int iListSize = g_esGeneral.g_alAbilitySections[index].Length;
	if (g_esGeneral.g_alAbilitySections[index] != null && iListSize > 0)
	{
		char sSection[32];
		for (int iPos = 0; iPos < iListSize; iPos++)
		{
			g_esGeneral.g_alAbilitySections[index].GetString(iPos, sSection, sizeof sSection);
			if (StrEqual(subsection, sSection, false))
			{
				return true;
			}
		}
	}

	return false;
}

bool bGetMissionName()
{
	if (g_esGeneral.g_hSDKGetMissionInfo != null)
	{
		Address adMissionInfo = SDKCall(g_esGeneral.g_hSDKGetMissionInfo);
		if (adMissionInfo != Address_Null && g_esGeneral.g_hSDKKeyValuesGetString != null)
		{
			char sTemp[64], sTemp2[64];
			SDKCall(g_esGeneral.g_hSDKKeyValuesGetString, adMissionInfo, sTemp, sizeof sTemp, "Name", "");
			SDKCall(g_esGeneral.g_hSDKKeyValuesGetString, adMissionInfo, sTemp2, sizeof sTemp2, "DisplayTitle", "");

			bool bSame = StrEqual(g_esGeneral.g_sCurrentMissionName, sTemp) || StrEqual(g_esGeneral.g_sCurrentMissionDisplayTitle, sTemp2);
			if (!bSame)
			{
				strcopy(g_esGeneral.g_sCurrentMissionName, sizeof esGeneral::g_sCurrentMissionName, sTemp);
				strcopy(g_esGeneral.g_sCurrentMissionDisplayTitle, sizeof esGeneral::g_sCurrentMissionDisplayTitle, sTemp2);
			}

			return bSame;
		}
	}

	return false;
}

bool bHasCoreAdminAccess(int admin, int type = 0)
{
	if (!bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || bIsDeveloper(admin, 1))
	{
		return true;
	}

	int iType = (type > 0) ? type : g_esPlayer[admin].g_iTankType,
		iTypePlayerFlags = g_esAdmin[iType].g_iAccessFlags[admin],
		iPlayerFlags = g_esPlayer[admin].g_iAccessFlags,
		iAdminFlags = GetUserFlagBits(admin),
		iTypeFlags = g_esTank[iType].g_iAccessFlags,
		iGlobalFlags = g_esGeneral.g_iAccessFlags;
	if ((iTypeFlags != 0 && ((!(iTypeFlags & iTypePlayerFlags) && !(iTypePlayerFlags & iTypeFlags)) || (!(iTypeFlags & iPlayerFlags) && !(iPlayerFlags & iTypeFlags)) || (!(iTypeFlags & iAdminFlags) && !(iAdminFlags & iTypeFlags))))
		|| (iGlobalFlags != 0 && ((!(iGlobalFlags & iTypePlayerFlags) && !(iTypePlayerFlags & iGlobalFlags)) || (!(iGlobalFlags & iPlayerFlags) && !(iPlayerFlags & iGlobalFlags)) || (!(iGlobalFlags & iAdminFlags) && !(iAdminFlags & iGlobalFlags)))))
	{
		return false;
	}

	return true;
}

bool bIsCoreAdminImmune(int survivor, int tank)
{
	if (!bIsHumanSurvivor(survivor))
	{
		return false;
	}

	if (bIsDeveloper(survivor, 1))
	{
		return true;
	}

	int iType = g_esPlayer[tank].g_iTankType,
		iTypePlayerFlags = g_esAdmin[iType].g_iImmunityFlags[survivor],
		iPlayerFlags = g_esPlayer[survivor].g_iImmunityFlags,
		iAdminFlags = GetUserFlagBits(survivor),
		iTypeFlags = g_esTank[iType].g_iImmunityFlags,
		iGlobalFlags = g_esGeneral.g_iImmunityFlags;
	return (iTypeFlags != 0 && ((iTypePlayerFlags != 0 && ((iTypeFlags & iTypePlayerFlags) || (iTypePlayerFlags & iTypeFlags))) || (iPlayerFlags != 0 && ((iTypeFlags & iPlayerFlags) || (iPlayerFlags & iTypeFlags))) || (iAdminFlags != 0 && ((iTypeFlags & iAdminFlags) || (iAdminFlags & iTypeFlags)))))
		|| (iGlobalFlags != 0 && ((iTypePlayerFlags != 0 && ((iGlobalFlags & iTypePlayerFlags) || (iTypePlayerFlags & iGlobalFlags))) || (iPlayerFlags != 0 && ((iGlobalFlags & iPlayerFlags) || (iPlayerFlags & iGlobalFlags))) || (iAdminFlags != 0 && ((iGlobalFlags & iAdminFlags) || (iAdminFlags & iGlobalFlags)))));
}

bool bIsCustomTank(int tank)
{
#if defined _mtclone_included
	return g_esGeneral.g_bCloneInstalled && MT_IsTankClone(tank);
#else
	return bIsSurvivor(tank, MT_CHECK_INDEX|MT_CHECK_INGAME); // will always return false
#endif
}

bool bIsCustomTankSupported(int tank)
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

bool bIsDayConfigFound(char[] buffer, int size)
{
	char sFolder[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	FormatEx(sFolder, sizeof sFolder, "%s%s", MT_CONFIG_PATH, MT_CONFIG_PATH_DAY);
	BuildPath(Path_SM, sPath, sizeof sPath, sFolder);

	char sDayNumber[2], sDay[10], sFilename[14];
	FormatTime(sDayNumber, sizeof sDayNumber, "%w", GetTime());
	vGetDayName(StringToInt(sDayNumber), sDay, sizeof sDay);
	FormatEx(sFilename, sizeof sFilename, "%s.cfg", sDay);

	char sDayConfig[PLATFORM_MAX_PATH];
	FormatEx(sDayConfig, sizeof sDayConfig, "%s%s", sPath, sFilename);
	if (MT_FileExists(sFolder, sFilename, sDayConfig, sDayConfig, sizeof sDayConfig))
	{
		strcopy(buffer, size, sDayConfig);

		return true;
	}

	return false;
}

/**
 * Developer tools for testing
 * 1 - 0 - no versus cooldown, visual effects (off by default)
 * 2 - 1 - immune to abilities, access to all tanks (off by default)
 * 4 - 2 - loadout on initial spawn
 * 8 - 3 - all rewards/effects
 * 16 - 4 - damage boost/resistance, less punch force, ammo regen
 * 32 - 5 - speed boost, jump height, auto-revive, life leech
 * 64 - 6 - no shove penalty, fast shove/attack rate/action durations, fast recover, full health when healing/reviving, ammo regen, ladder actions
 * 128 - 7 - infinite ammo, health regen, special ammo (off by default)
 * 256 - 8 - block puke/fling/shove/stagger/punch/acid puddle (off by default)
 * 512 - 9 - sledgehammer rounds, hollowpoint ammo, tank melee knockback, shove damage against tank/charger/witch
 * 1024 - 10 - respawn upon death, clean kills, block puke/acid puddle
 * 2048 - 11 - auto-insta-kill SI attackers, god mode, no damage, lady killer, special ammo (off by default)
 **/
bool bIsDeveloper(int developer, int bit = -1, bool real = false)
{
	bool bGuest = (bit == -1 && g_esDeveloper[developer].g_iDevAccess > 0) || (bit >= 0 && (g_esDeveloper[developer].g_iDevAccess & (1 << bit))),
		bReturn = false;
	if (bit == -1 || bGuest)
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

bool bIsDifficultyConfigFound(char[] buffer, int size)
{
	char sFolder[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	FormatEx(sFolder, sizeof sFolder, "%s%s", MT_CONFIG_PATH, MT_CONFIG_PATH_DIFFICULTY);
	BuildPath(Path_SM, sPath, sizeof sPath, sFolder);

	char sDifficulty[11], sFilename[15];
	g_esGeneral.g_cvMTDifficulty.GetString(sDifficulty, sizeof sDifficulty);
	FormatEx(sFilename, sizeof sFilename, "%s.cfg", sDifficulty);

	char sDifficultyConfig[PLATFORM_MAX_PATH];
	FormatEx(sDifficultyConfig, sizeof sDifficultyConfig, "%s%s", sPath, sFilename);
	if (MT_FileExists(sFolder, sFilename, sDifficultyConfig, sDifficultyConfig, sizeof sDifficultyConfig))
	{
		strcopy(buffer, size, sDifficultyConfig);

		return true;
	}

	return false;
}

bool bIsFinaleConfigFound(const char[] filename, char[] buffer, int size)
{
	char sFolder[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	FormatEx(sFolder, sizeof sFolder, "%s%s", MT_CONFIG_PATH, (g_bSecondGame ? MT_CONFIG_PATH_FINALE2 : MT_CONFIG_PATH_FINALE));
	BuildPath(Path_SM, sPath, sizeof sPath, sFolder);

	char sFinale[32], sFilename[36];
	strcopy(sFinale, sizeof sFinale, filename);
	FormatEx(sFilename, sizeof sFilename, "%s.cfg", sFinale);

	char sFinaleConfig[PLATFORM_MAX_PATH];
	FormatEx(sFinaleConfig, sizeof sFinaleConfig, "%s%s", sPath, sFilename);
	if (MT_FileExists(sFolder, sFilename, sFinaleConfig, sFinaleConfig, sizeof sFinaleConfig))
	{
		strcopy(buffer, size, sFinaleConfig);

		return true;
	}

	return false;
}

bool bIsFinalMap()
{
	bool bCheck = (g_esGeneral.g_hSDKIsMissionFinalMap != null && SDKCall(g_esGeneral.g_hSDKIsMissionFinalMap)) || (FindEntityByClassname(-1, "info_changelevel") == -1 && FindEntityByClassname(-1, "trigger_changelevel") == -1) || FindEntityByClassname(-1, "trigger_finale") != -1 || FindEntityByClassname(-1, "finale_trigger") != -1;
#if defined _l4dh_included
	return bCheck || (g_esGeneral.g_bLeft4DHooksInstalled && L4D_IsMissionFinalMap());
#else
	return bCheck;
#endif
}

bool bIsFirstMap()
{
	if (g_esGeneral.g_hSDKGetMissionFirstMap != null && g_esGeneral.g_hSDKKeyValuesGetString != null)
	{
		int iKeyvalue = SDKCall(g_esGeneral.g_hSDKGetMissionFirstMap, 0);
		if (iKeyvalue > 0)
		{
			char sMap[128], sCheck[128];
			GetCurrentMap(sMap, sizeof sMap);
			SDKCall(g_esGeneral.g_hSDKKeyValuesGetString, iKeyvalue, sCheck, sizeof sCheck, "map", "N/A");
			return StrEqual(sMap, sCheck);
		}
	}

	bool bCheck = g_bSecondGame && g_esGeneral.g_adDirector != Address_Null && SDKCall(g_esGeneral.g_hSDKIsFirstMapInScenario, g_esGeneral.g_adDirector);
#if defined _l4dh_included
	return bCheck || (g_esGeneral.g_bLeft4DHooksInstalled && L4D_IsFirstMapInScenario());
#else
	return bCheck;
#endif
}

bool bIsGameModeConfigFound(char[] buffer, int size)
{
	char sFolder[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	FormatEx(sFolder, sizeof sFolder, "%s%s", MT_CONFIG_PATH, (g_bSecondGame ? MT_CONFIG_PATH_GAMEMODE2 : MT_CONFIG_PATH_GAMEMODE));
	BuildPath(Path_SM, sPath, sizeof sPath, sFolder);

	char sMode[64], sFilename[68];
	g_esGeneral.g_cvMTGameMode.GetString(sMode, sizeof sMode);
	FormatEx(sFilename, sizeof sFilename, "%s.cfg", sMode);

	char sModeConfig[PLATFORM_MAX_PATH];
	FormatEx(sModeConfig, sizeof sModeConfig, "%s%s", sPath, sFilename);
	if (MT_FileExists(sFolder, sFilename, sModeConfig, sModeConfig, sizeof sModeConfig))
	{
		strcopy(buffer, size, sModeConfig);

		return true;
	}

	return false;
}

bool bIsMapConfigFound(char[] buffer, int size)
{
	char sFolder[PLATFORM_MAX_PATH], sPath[PLATFORM_MAX_PATH];
	FormatEx(sFolder, sizeof sFolder, "%s%s", MT_CONFIG_PATH, (g_bSecondGame ? MT_CONFIG_PATH_MAP2 : MT_CONFIG_PATH_MAP));
	BuildPath(Path_SM, sPath, sizeof sPath, sFolder);

	char sMap[128], sFilename[132];
	GetCurrentMap(sMap, sizeof sMap);
	FormatEx(sFilename, sizeof sFilename, "%s.cfg", sMap);

	char sMapConfig[PLATFORM_MAX_PATH];
	FormatEx(sMapConfig, sizeof sMapConfig, "%s%s", sPath, sFilename);
	if (MT_FileExists(sFolder, sFilename, sMapConfig, sMapConfig, sizeof sMapConfig))
	{
		strcopy(buffer, size, sMapConfig);

		return true;
	}

	return false;
}

bool bIsNormalMap()
{
	return bIsFirstMap() || FindEntityByClassname(-1, "info_changelevel") != -1 || FindEntityByClassname(-1, "trigger_changelevel") != -1 || (FindEntityByClassname(-1, "trigger_finale") == -1 && FindEntityByClassname(-1, "finale_trigger") == -1);
}

bool bIsPluginEnabled()
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
	g_esGeneral.g_cvMTGameMode.GetString(sGameMode, sizeof sGameMode);
	FormatEx(sFixed, sizeof sFixed, ",%s,", sGameMode);

	strcopy(sGameModes, sizeof sGameModes, g_esGeneral.g_sEnabledGameModes);
	g_esGeneral.g_cvMTEnabledGameModes.GetString(sGameModesCvar, sizeof sGameModesCvar);
	if (sGameModes[0] != '\0' || sGameModesCvar[0] != '\0')
	{
		if (sGameModes[0] != '\0')
		{
			FormatEx(sList, sizeof sList, ",%s,", sGameModes);
		}

		if (sGameModesCvar[0] != '\0')
		{
			FormatEx(sListCvar, sizeof sListCvar, ",%s,", sGameModesCvar);
		}

		if ((sList[0] != '\0' && StrContains(sList, sFixed, false) == -1) && (sListCvar[0] != '\0' && StrContains(sListCvar, sFixed, false) == -1))
		{
			return false;
		}
	}

	strcopy(sGameModes, sizeof sGameModes, g_esGeneral.g_sDisabledGameModes);
	g_esGeneral.g_cvMTDisabledGameModes.GetString(sGameModesCvar, sizeof sGameModesCvar);
	if (sGameModes[0] != '\0' || sGameModesCvar[0] != '\0')
	{
		if (sGameModes[0] != '\0')
		{
			FormatEx(sList, sizeof sList, ",%s,", sGameModes);
		}

		if (sGameModesCvar[0] != '\0')
		{
			FormatEx(sListCvar, sizeof sListCvar, ",%s,", sGameModesCvar);
		}

		if ((sList[0] != '\0' && StrContains(sList, sFixed, false) != -1) || (sListCvar[0] != '\0' && StrContains(sListCvar, sFixed, false) != -1))
		{
			return false;
		}
	}

	return true;
}

bool bIsRightGame(int type)
{
	switch (g_esTank[type].g_iGameType)
	{
		case 1: return !g_bSecondGame;
		case 2: return g_bSecondGame;
	}

	return true;
}

bool bIsSafeFalling(int survivor)
{
	if (g_esPlayer[survivor].g_bFalling)
	{
		float flOrigin[3];
		GetEntPropVector(survivor, Prop_Data, "m_vecOrigin", flOrigin);
		if (0.0 < (g_esPlayer[survivor].g_flPreFallZ - flOrigin[2]) < 900.0)
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

bool bIsSpawnEnabled(int type)
{
	if ((g_esGeneral.g_iSpawnEnabled <= 0 && g_esTank[type].g_iSpawnEnabled <= 0) || (g_esGeneral.g_iSpawnEnabled == 1 && g_esTank[type].g_iSpawnEnabled == 0))
	{
		return false;
	}

	return (g_esGeneral.g_iSpawnEnabled <= 0 && g_esTank[type].g_iSpawnEnabled == 1) || (g_esGeneral.g_iSpawnEnabled == 1 && g_esTank[type].g_iSpawnEnabled != 0);
}

bool bIsTankEnabled(int type)
{
	if ((g_esGeneral.g_iTankEnabled <= 0 && g_esTank[type].g_iTankEnabled <= 0) || (g_esGeneral.g_iTankEnabled == 1 && g_esTank[type].g_iTankEnabled == 0))
	{
		return false;
	}

	return (g_esGeneral.g_iTankEnabled <= 0 && g_esTank[type].g_iTankEnabled == 1) || (g_esGeneral.g_iTankEnabled == 1 && g_esTank[type].g_iTankEnabled != 0);
}

bool bIsTankSupported(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	if (!bIsTank(tank, flags) || (g_esPlayer[tank].g_iTankType <= 0) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esTank[g_esPlayer[tank].g_iTankType].g_iHumanSupport == 0))
	{
		return false;
	}

	return true;
}

bool bIsTankIdle(int tank, int type = 0)
{
	if (!bIsTank(tank) || bIsTank(tank, MT_CHECK_FAKECLIENT) || bIsInfectedGhost(tank) || g_esPlayer[tank].g_bStasis)
	{
		return false;
	}

	Address adTank = GetEntityAddress(tank);
	if (adTank == Address_Null || g_esGeneral.g_iIntentionOffset == -1)
	{
		return false;
	}

	Address adIntention = view_as<Address>(LoadFromAddress((adTank + view_as<Address>(g_esGeneral.g_iIntentionOffset)), NumberType_Int32));
	if (adIntention == Address_Null || g_esGeneral.g_iBehaviorOffset == -1)
	{
		return false;
	}

	Address adBehavior = view_as<Address>(LoadFromAddress((adIntention + view_as<Address>(g_esGeneral.g_iBehaviorOffset)), NumberType_Int32));
	if (adBehavior == Address_Null || g_esGeneral.g_iActionOffset == -1)
	{
		return false;
	}

	Address adAction = view_as<Address>(LoadFromAddress((adBehavior + view_as<Address>(g_esGeneral.g_iActionOffset)), NumberType_Int32));
	if (adAction == Address_Null || g_esGeneral.g_iChildActionOffset == -1)
	{
		return false;
	}

	Address adChildAction = Address_Null;
	while ((adChildAction = view_as<Address>(LoadFromAddress((adAction + view_as<Address>(g_esGeneral.g_iChildActionOffset)), NumberType_Int32))) != Address_Null)
	{
		adAction = adChildAction;
	}

	if (g_esGeneral.g_hSDKGetName == null)
	{
		return false;
	}

	char sAction[64];
	SDKCall(g_esGeneral.g_hSDKGetName, adAction, sAction, sizeof sAction);
	return (type != 2 && StrEqual(sAction, "TankIdle")) || (type != 1 && (StrEqual(sAction, "TankBehavior") || adAction == adBehavior));
}

bool bIsTankInThirdPerson(int tank)
{
	return g_esPlayer[tank].g_bThirdPerson || bIsPlayerInThirdPerson(tank);
}

bool bIsTypeAvailable(int type, int tank = 0)
{
	if ((tank > 0 && g_esCache[tank].g_iCheckAbilities == 0) && g_esGeneral.g_iCheckAbilities == 0 && g_esTank[type].g_iCheckAbilities == 0)
	{
		return true;
	}

	int iPluginCount = 0;
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

bool bIsVersusModeRound(int type)
{
	if (!(g_esGeneral.g_iCurrentMode == 2 || g_esGeneral.g_iCurrentMode == 8))
	{
		return false;
	}

	switch (type)
	{
		case 0: return !g_esGeneral.g_bNextRound && g_esGeneral.g_alCompTypes == null;
		case 1: return !g_esGeneral.g_bNextRound && g_esGeneral.g_alCompTypes != null;
		case 2: return g_esGeneral.g_bNextRound && g_esGeneral.g_alCompTypes != null && g_esGeneral.g_alCompTypes.Length > 0;
	}

	return false;
}

bool bRespawnSurvivor(int survivor, bool restore)
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

float flGetPunchForce(int survivor, float forcemodifier)
{
	bool bDeveloper = bIsDeveloper(survivor, 4);
	if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_GODMODE))
	{
		float flForce = (bDeveloper && g_esDeveloper[survivor].g_flDevPunchResistance > g_esPlayer[survivor].g_flPunchResistance) ? g_esDeveloper[survivor].g_flDevPunchResistance : g_esPlayer[survivor].g_flPunchResistance;
		if (forcemodifier < 0.0 || forcemodifier >= flForce)
		{
			return flForce;
		}
	}

	return forcemodifier;
}

float flGetScaledDamage(float damage)
{
	if (g_esGeneral.g_cvMTDifficulty != null && g_esGeneral.g_iScaleDamage == 1)
	{
		char sDifficulty[11];
		g_esGeneral.g_cvMTDifficulty.GetString(sDifficulty, sizeof sDifficulty);

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

int iChooseTank(int tank, int exclude, int min = -1, int max = -1, bool mutate = true)
{
	int iChosen = iChooseType(exclude, tank, min, max);
	if (iChosen > 0)
	{
		int iRealType = iGetRealType(iChosen, exclude, tank, min, max);
		if (iRealType > 0)
		{
			if (mutate)
			{
				vSetTankColor(tank, iRealType, false, .store = true);
			}

			return iRealType;
		}

		return iChosen;
	}

	return 0;
}

int iChooseType(int exclude, int tank = 0, int min = -1, int max = -1)
{
	bool bCondition = false;
	int iMin = (min >= 0) ? min : g_esGeneral.g_iMinType,
		iMax = (max >= 0) ? max : g_esGeneral.g_iMaxType,
		iTankTypes[MT_MAXTYPES + 1];
	if (iMax < iMin || (g_esGeneral.g_iCurrentMode == 4 && g_esGeneral.g_iSurvivalBlock != 2))
	{
		return 0;
	}

	int iTypeCount = 0;
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

int iFindSectionType(const char[] section, int type)
{
	if (FindCharInString(section, ',') != -1 || FindCharInString(section, '-') != -1)
	{
		char sSection[PLATFORM_MAX_PATH], sSet[16][10];
		int iType = 0, iSize = 0;
		strcopy(sSection, sizeof sSection, section);
		if (FindCharInString(section, ',') != -1)
		{
			char sRange[2][5];
			ExplodeString(sSection, ",", sSet, sizeof sSet, sizeof sSet[]);
			for (int iPos = 0; iPos < sizeof sSet; iPos++)
			{
				if (FindCharInString(sSet[iPos], '-') != -1)
				{
					ExplodeString(sSet[iPos], "-", sRange, sizeof sRange, sizeof sRange[]);
					iSize = StringToInt(sRange[1]);
					for (iType = StringToInt(sRange[0]); iType <= iSize; iType++)
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
		else if (FindCharInString(section, '-') != -1)
		{
			ExplodeString(sSection, "-", sSet, sizeof sSet, sizeof sSet[]);
			iSize = StringToInt(sSet[1]);
			for (iType = StringToInt(sSet[0]); iType <= iSize; iType++)
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

int iGetConfigSectionNumber(const char[] section, int size)
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

int iGetDecimalFromHex(int character)
{
	if (IsCharNumeric(character))
	{
		return (character - '0');
	}
	else if (IsCharAlpha(character))
	{
		int iLetter = CharToUpper(character);
		if (iLetter < 'A' || iLetter > 'F')
		{
			return -1;
		}

		return ((iLetter - 'A') + 10);
	}

	return -1;
}

int iGetMaxAmmo(int survivor, int type, int weapon, bool reserve, bool reset = false)
{
	bool bRewarded = bIsSurvivor(survivor) && (bIsDeveloper(survivor, 4) || bIsDeveloper(survivor, 6) || ((g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_AMMO) && g_esPlayer[survivor].g_iAmmoBoost == 1));
	int iType = (type > 0 || weapon <= MaxClients) ? type : GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
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

int iGetMaxWeaponSkins(int developer)
{
	int iActiveWeapon = GetEntPropEnt(developer, Prop_Send, "m_hActiveWeapon");
	if (bIsValidEntity(iActiveWeapon))
	{
		char sClassname[32];
		GetEntityClassname(iActiveWeapon, sClassname, sizeof sClassname);
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
			char sWeapon[32];
			GetEntPropString(iActiveWeapon, Prop_Data, "m_strMapSetScriptName", sWeapon, sizeof sWeapon);
			if (StrEqual(sWeapon, "cricket_bat") || StrEqual(sWeapon, "crowbar"))
			{
				return 1;
			}
		}
	}

	return -1;
}

int iGetMessageType(int setting)
{
	int iMessageCount = 0, iMessages[10], iFlag = 0;
	for (int iBit = 0; iBit < sizeof iMessages; iBit++)
	{
		iFlag = (1 << iBit);
		if (!(setting & iFlag))
		{
			continue;
		}

		iMessages[iMessageCount] = iFlag;
		iMessageCount++;
	}

	switch (iMessages[GetRandomInt(0, (iMessageCount - 1))])
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
		default: return GetRandomInt(1, sizeof iMessages);
	}
}

int iGetRandomRecipient(int recipient, int tank, int priority, bool none)
{
	bool bCondition = false;
	float flPercentage = 0.0;
	int iRecipient = recipient, iRecipientCount = 0;
	int[] iRecipients = new int[MaxClients + 1];
	if (g_esCache[tank].g_iShareRewards[priority] == 1 || g_esCache[tank].g_iShareRewards[priority] == 3)
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			bCondition = none ? (g_esPlayer[iSurvivor].g_iRewardTypes <= 0) : (g_esPlayer[iSurvivor].g_iRewardTypes > 0);
			flPercentage = ((float(g_esPlayer[iSurvivor].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100.0);
			if (bIsHumanSurvivor(iSurvivor) && bCondition && (1.0 <= flPercentage < g_esCache[tank].g_flRewardPercentage[priority]) && iSurvivor != recipient)
			{
				iRecipients[iRecipientCount] = iSurvivor;
				iRecipientCount++;
			}
		}
	}

	if (iRecipientCount > 0)
	{
		iRecipient = iRecipients[GetRandomInt(0, (iRecipientCount - 1))];
	}

	if ((g_esCache[tank].g_iShareRewards[priority] == 2 || g_esCache[tank].g_iShareRewards[priority] == 3) && (iRecipientCount == 0 || iRecipient == recipient))
	{
		bool bBot = false;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			bCondition = none ? (g_esPlayer[iSurvivor].g_iRewardTypes <= 0) : (g_esPlayer[iSurvivor].g_iRewardTypes > 0);
			flPercentage = ((float(g_esPlayer[iSurvivor].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100.0);
			if (bIsSurvivor(iSurvivor) && bCondition && (1.0 <= flPercentage < g_esCache[tank].g_flRewardPercentage[priority]) && iSurvivor != recipient)
			{
				bBot = (g_esCache[tank].g_iShareRewards[priority] == 2) ? !bIsValidClient(iSurvivor, MT_CHECK_FAKECLIENT) : true;
				if (bBot)
				{
					iRecipients[iRecipientCount] = iSurvivor;
					iRecipientCount++;
				}
			}
		}

		if (iRecipientCount > 0)
		{
			iRecipient = iRecipients[GetRandomInt(0, (iRecipientCount - 1))];
		}
	}

	return iRecipient;
}

int iGetRealType(int type, int exclude = 0, int tank = 0, int min = -1, int max = -1)
{
	Action aResult = Plugin_Continue;
	int iType = type;

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

int iGetTankCount(bool manual, bool include = false)
{
	switch (manual)
	{
		case true:
		{
			int iTankCount = 0;
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

int iGetTypeCount(int type = 0)
{
	bool bCheck = false;
	int iTypeCount = 0;
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

int iGetUsefulRewards(int survivor, int tank, int types, int priority)
{
	int iType = 0;
	if (g_esCache[tank].g_iUsefulRewards[priority] > 0)
	{
		if (bIsSurvivor(survivor, MT_CHECK_ALIVE))
		{
			int iAmmo = -1, iWeapon = GetPlayerWeaponSlot(survivor, 0);
			if (iWeapon > MaxClients)
			{
				iAmmo = GetEntProp(survivor, Prop_Send, "m_iAmmo", .element = iGetWeaponOffset(iWeapon));
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