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

enum ConfigState
{
	ConfigState_None, // no section yet
	ConfigState_Start, // reached "Mutant Tanks" section
	ConfigState_Settings, // reached "Plugin Settings" section
	ConfigState_Type, // reached "Tank #" section
	ConfigState_Admin, // reached "STEAM_" or "[U:" section
	ConfigState_Specific // reached specific sections
};

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

	if (StrEqual(name, MT_CONFIG_SECTION_SETTINGS, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS2, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS3, false) || StrEqual(name, MT_CONFIG_SECTION_SETTINGS4, false) || !strncmp(name, "STEAM_", 6, false)
		|| !strncmp("0:", name, 2) || !strncmp("1:", name, 2) || (!strncmp(name, "[U:", 3) && name[strlen(name) - 1] == ']') || StrContains(name, "all", false) != -1 || FindCharInString(name, ',') != -1 || FindCharInString(name, '-') != -1
		|| !strncmp(name, "Tank", 4, false) || name[0] == '#' || IsCharNumeric(name[0]))
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

void vParseConfig(int client)
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
			smcParser.GetErrorString(smcError, sSmcError, sizeof sSmcError);
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
		else if (g_esGeneral.g_iSection > 0 && (!strncmp(name, "Tank", 4, false) || name[0] == '#' || IsCharNumeric(name[0]) || StrContains(name, "all", false) != -1 || FindCharInString(name, ',') != -1 || FindCharInString(name, '-') != -1))
		{
			char sSection[33], sIndex[5], sType[5];
			strcopy(sSection, sizeof sSection, name);
			int iIndex = iFindSectionType(name, g_esGeneral.g_iSection), iStartPos = iGetConfigSectionNumber(sSection, sizeof sSection);
			IntToString(iIndex, sIndex, sizeof sIndex);
			IntToString(g_esGeneral.g_iSection, sType, sizeof sType);
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
		else if (StrEqual(name, g_esGeneral.g_sSection, false) && (StrContains(name, "all", false) != -1 || FindCharInString(name, ',') != -1 || FindCharInString(name, '-') != -1))
		{
			g_esGeneral.g_csState2 = ConfigState_Type;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
				case false: vLogMessage(MT_LOG_SERVER, false, (opt_quotes) ? ("%7s \"%s\"\n%7s {") : ("%7s %s\n%7s {"), "", name, "");
			}
		}
		else if ((!strncmp(name, "STEAM_", 6, false) || !strncmp("0:", name, 2) || !strncmp("1:", name, 2) || (!strncmp(name, "[U:", 3) && name[strlen(name) - 1] == ']')) && StrContains(name, g_esGeneral.g_sSection, false) != -1)
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
		char sKey[64], sValue[384];
		FormatEx(sKey, sizeof sKey, (key_quotes ? "\"%s\"" : "%s"), key);
		FormatEx(sValue, sizeof sValue, (value_quotes ? "\"%s\"" : "%s"), value);

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
		else if (g_esGeneral.g_iSection > 0 && (!strncmp(g_esGeneral.g_sSection, "Tank", 4, false) || g_esGeneral.g_sSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sSection[0]) || StrContains(g_esGeneral.g_sSection, "all", false) != -1 || FindCharInString(g_esGeneral.g_sSection, ',') != -1 || FindCharInString(g_esGeneral.g_sSection, '-') != -1))
		{
			g_esGeneral.g_csState2 = ConfigState_Type;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "%15s }", "");
				case false: vLogMessage(MT_LOG_SERVER, false, "%15s }", "");
			}
		}
		else if (StrContains(g_esGeneral.g_sSection, "all", false) != -1 || FindCharInString(g_esGeneral.g_sSection, ',') != -1 || FindCharInString(g_esGeneral.g_sSection, '-') != -1)
		{
			g_esGeneral.g_csState2 = ConfigState_Type;

			switch (bHuman)
			{
				case true: MT_PrintToChat(g_esGeneral.g_iParserViewer, "%15s }", "");
				case false: vLogMessage(MT_LOG_SERVER, false, "%15s }", "");
			}
		}
		else if (!strncmp(g_esGeneral.g_sSection, "STEAM_", 6, false) || !strncmp("0:", g_esGeneral.g_sSection, 2) || !strncmp("1:", g_esGeneral.g_sSection, 2) || (!strncmp(g_esGeneral.g_sSection, "[U:", 3) && g_esGeneral.g_sSection[strlen(g_esGeneral.g_sSection) - 1] == ']'))
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

void vLoadConfigs(const char[] savepath, int mode)
{
	vClearAbilityList();
	vClearColorKeysList();
	vClearPluginList();

	g_esGeneral.g_alColorKeys[0] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_esGeneral.g_alColorKeys[1] = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

	g_esGeneral.g_alPlugins = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	if (g_esGeneral.g_alPlugins != null)
	{
		Call_StartForward(g_esGeneral.g_gfPluginCheckForward);
		Call_PushCell(g_esGeneral.g_alPlugins);
		Call_Finish();
	}

	bool bFinish = true;
	Call_StartForward(g_esGeneral.g_gfAbilityCheckForward);

	for (int iPos = 0; iPos < sizeof esGeneral::g_alAbilitySections; iPos++)
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
		int iLength = g_esGeneral.g_alPlugins.Length, iListSize = (iLength > 0) ? iLength : 0;
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
		int iLength = g_esGeneral.g_alFilePaths.Length, iListSize = (iLength > 0) ? iLength : 0;
		if (iListSize > 0)
		{
			bool bAdd = true;
			char sFilePath[PLATFORM_MAX_PATH];
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_alFilePaths.GetString(iPos, sFilePath, sizeof sFilePath);
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
			smcLoader.GetErrorString(smcError, sSmcError, sizeof sSmcError);
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
		g_esGeneral.g_sBodyColorVisual = "-1;-1;-1;-1";
		g_esGeneral.g_sBodyColorVisual2 = "-1;-1;-1;-1";
		g_esGeneral.g_sBodyColorVisual3 = "-1;-1;-1;-1";
		g_esGeneral.g_sBodyColorVisual4 = "-1;-1;-1;-1";
		g_esGeneral.g_sFallVoicelineReward = "PlayerLaugh";
		g_esGeneral.g_sFallVoicelineReward2 = "PlayerLaugh";
		g_esGeneral.g_sFallVoicelineReward3 = "PlayerLaugh";
		g_esGeneral.g_sFallVoicelineReward4 = "PlayerLaugh";
		g_esGeneral.g_sItemReward = "first_aid_kit";
		g_esGeneral.g_sItemReward2 = "first_aid_kit";
		g_esGeneral.g_sItemReward3 = "first_aid_kit";
		g_esGeneral.g_sItemReward4 = "first_aid_kit";
		g_esGeneral.g_sLightColorVisual = "-1;-1;-1;-1";
		g_esGeneral.g_sLightColorVisual2 = "-1;-1;-1;-1";
		g_esGeneral.g_sLightColorVisual3 = "-1;-1;-1;-1";
		g_esGeneral.g_sLightColorVisual4 = "-1;-1;-1;-1";
		g_esGeneral.g_sLoopingVoicelineVisual = "PlayerDeath";
		g_esGeneral.g_sLoopingVoicelineVisual2 = "PlayerDeath";
		g_esGeneral.g_sLoopingVoicelineVisual3 = "PlayerDeath";
		g_esGeneral.g_sLoopingVoicelineVisual4 = "PlayerDeath";
		g_esGeneral.g_sOutlineColorVisual = "-1;-1;-1";
		g_esGeneral.g_sOutlineColorVisual2 = "-1;-1;-1";
		g_esGeneral.g_sOutlineColorVisual3 = "-1;-1;-1";
		g_esGeneral.g_sOutlineColorVisual4 = "-1;-1;-1";
		g_esGeneral.g_sScreenColorVisual = "-1;-1;-1;-1";
		g_esGeneral.g_sScreenColorVisual2 = "-1;-1;-1;-1";
		g_esGeneral.g_sScreenColorVisual3 = "-1;-1;-1;-1";
		g_esGeneral.g_sScreenColorVisual4 = "-1;-1;-1;-1";
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
		g_esGeneral.g_iGroundPound = 0;
		g_esGeneral.g_flHittableDamage = -1.0;
		g_esGeneral.g_flPunchForce = -1.0;
		g_esGeneral.g_flPunchThrow = 0.0;
		g_esGeneral.g_flRockDamage = -1.0;
		g_esGeneral.g_flRunSpeed = 0.0;
		g_esGeneral.g_iSkipIncap = 0;
		g_esGeneral.g_iSkipTaunt = 0;
		g_esGeneral.g_iSweepFist = 0;
		g_esGeneral.g_flThrowInterval = 0.0;
		g_esGeneral.g_iBulletImmunity = 0;
		g_esGeneral.g_iExplosiveImmunity = 0;
		g_esGeneral.g_iFireImmunity = 0;
		g_esGeneral.g_iHittableImmunity = 0;
		g_esGeneral.g_iMeleeImmunity = 0;
		g_esGeneral.g_iVomitImmunity = 0;
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

		for (int iPos = 0; iPos < sizeof esGeneral::g_iFinaleWave; iPos++)
		{
			g_esGeneral.g_iFinaleMaxTypes[iPos] = MT_MAXTYPES;
			g_esGeneral.g_iFinaleMinTypes[iPos] = 1;
			g_esGeneral.g_iFinaleWave[iPos] = 0;

			if (iPos < sizeof esGeneral::g_iRewardEnabled)
			{
				g_esGeneral.g_iRewardEnabled[iPos] = -1;
				g_esGeneral.g_iRewardBots[iPos] = -1;
				g_esGeneral.g_flRewardChance[iPos] = 33.3;
				g_esGeneral.g_flRewardDuration[iPos] = 10.0;
				g_esGeneral.g_iRewardEffect[iPos] = 15;
				g_esGeneral.g_iRewardNotify[iPos] = 3;
				g_esGeneral.g_flRewardPercentage[iPos] = 10.0;
				g_esGeneral.g_iRewardVisual[iPos] = 63;
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
				g_esGeneral.g_iLadderActionsReward[iPos] = 1;
				g_esGeneral.g_iLadyKillerReward[iPos] = 1;
				g_esGeneral.g_iLifeLeechReward[iPos] = 1;
				g_esGeneral.g_iMeleeRangeReward[iPos] = 150;
				g_esGeneral.g_iParticleEffectVisual[iPos] = 15;
				g_esGeneral.g_iPrefsNotify[iPos] = 1;
				g_esGeneral.g_flPunchResistanceReward[iPos] = 0.25;
				g_esGeneral.g_iRespawnLoadoutReward[iPos] = 1;
				g_esGeneral.g_iReviveHealthReward[iPos] = 100;
				g_esGeneral.g_iShareRewards[iPos] = 0;
				g_esGeneral.g_flShoveDamageReward[iPos] = 0.025;
				g_esGeneral.g_iShovePenaltyReward[iPos] = 1;
				g_esGeneral.g_flShoveRateReward[iPos] = 0.7;
				g_esGeneral.g_iSledgehammerRoundsReward[iPos] = 1;
				g_esGeneral.g_iSpecialAmmoReward[iPos] = 3;
				g_esGeneral.g_flSpeedBoostReward[iPos] = 1.25;
				g_esGeneral.g_iStackRewards[iPos] = 0;
				g_esGeneral.g_iThornsReward[iPos] = 1;
				g_esGeneral.g_iUsefulRewards[iPos] = 15;
			}

			if (iPos < sizeof esGeneral::g_iStackLimits)
			{
				g_esGeneral.g_iStackLimits[iPos] = 0;
			}

			if (iPos < sizeof esGeneral::g_flDifficultyDamage)
			{
				g_esGeneral.g_flDifficultyDamage[iPos] = 0.0;
			}
		}

		for (int iIndex = 0; iIndex <= MT_MAXTYPES; iIndex++)
		{
			g_esTank[iIndex].g_iAbilityCount = -1;
			g_esTank[iIndex].g_sGlowColor = "255,255,255";
			g_esTank[iIndex].g_sSkinColor = "255,255,255,255";
			g_esTank[iIndex].g_sFlameColor = "255,255,255,255";
			g_esTank[iIndex].g_sFlashlightColor = "255,255,255,255";
			g_esTank[iIndex].g_sOzTankColor = "255,255,255,255";
			g_esTank[iIndex].g_sPropTankColor = "255,255,255,255";
			g_esTank[iIndex].g_sRockColor = "255,255,255,255";
			g_esTank[iIndex].g_sTireColor = "255,255,255,255";
			g_esTank[iIndex].g_sTankName = "Tank";
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
			g_esTank[iIndex].g_sItemReward[0] = '\0';
			g_esTank[iIndex].g_sItemReward2[0] = '\0';
			g_esTank[iIndex].g_sItemReward3[0] = '\0';
			g_esTank[iIndex].g_sItemReward4[0] = '\0';
			g_esTank[iIndex].g_sLightColorVisual[0] = '\0';
			g_esTank[iIndex].g_sLightColorVisual2[0] = '\0';
			g_esTank[iIndex].g_sLightColorVisual3[0] = '\0';
			g_esTank[iIndex].g_sLightColorVisual4[0] = '\0';
			g_esTank[iIndex].g_sLoopingVoicelineVisual[0] = '\0';
			g_esTank[iIndex].g_sLoopingVoicelineVisual2[0] = '\0';
			g_esTank[iIndex].g_sLoopingVoicelineVisual3[0] = '\0';
			g_esTank[iIndex].g_sLoopingVoicelineVisual4[0] = '\0';
			g_esTank[iIndex].g_sOutlineColorVisual[0] = '\0';
			g_esTank[iIndex].g_sOutlineColorVisual2[0] = '\0';
			g_esTank[iIndex].g_sOutlineColorVisual3[0] = '\0';
			g_esTank[iIndex].g_sOutlineColorVisual4[0] = '\0';
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
			g_esTank[iIndex].g_iGroundPound = 0;
			g_esTank[iIndex].g_flHittableDamage = -1.0;
			g_esTank[iIndex].g_flPunchForce = -1.0;
			g_esTank[iIndex].g_flPunchThrow = 0.0;
			g_esTank[iIndex].g_flRockDamage = -1.0;
			g_esTank[iIndex].g_flRunSpeed = 0.0;
			g_esTank[iIndex].g_iSkipIncap = 0;
			g_esTank[iIndex].g_iSkipTaunt = 0;
			g_esTank[iIndex].g_iSweepFist = 0;
			g_esTank[iIndex].g_flThrowInterval = 0.0;
			g_esTank[iIndex].g_iBulletImmunity = 0;
			g_esTank[iIndex].g_iExplosiveImmunity = 0;
			g_esTank[iIndex].g_iFireImmunity = 0;
			g_esTank[iIndex].g_iHittableImmunity = 0;
			g_esTank[iIndex].g_iMeleeImmunity = 0;
			g_esTank[iIndex].g_iVomitImmunity = 0;

			for (int iPos = 0; iPos < sizeof esTank::g_iTransformType; iPos++)
			{
				g_esTank[iIndex].g_iTransformType[iPos] = (iPos + 1);

				if (iPos < sizeof esTank::g_iRewardEnabled)
				{
					g_esTank[iIndex].g_iRewardEnabled[iPos] = -1;
					g_esTank[iIndex].g_iRewardBots[iPos] = -1;
					g_esTank[iIndex].g_flRewardChance[iPos] = 0.0;
					g_esTank[iIndex].g_flRewardDuration[iPos] = 0.0;
					g_esTank[iIndex].g_iRewardEffect[iPos] = 0;
					g_esTank[iIndex].g_iRewardNotify[iPos] = 0;
					g_esTank[iIndex].g_flRewardPercentage[iPos] = 0.0;
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
					g_esTank[iIndex].g_iLadderActionsReward[iPos] = 0;
					g_esTank[iIndex].g_iLadyKillerReward[iPos] = 0;
					g_esTank[iIndex].g_iLifeLeechReward[iPos] = 0;
					g_esTank[iIndex].g_iMeleeRangeReward[iPos] = 0;
					g_esTank[iIndex].g_iParticleEffectVisual[iPos] = 0;
					g_esTank[iIndex].g_iPrefsNotify[iPos] = 0;
					g_esTank[iIndex].g_flPunchResistanceReward[iPos] = 0.0;
					g_esTank[iIndex].g_iRespawnLoadoutReward[iPos] = 0;
					g_esTank[iIndex].g_iReviveHealthReward[iPos] = 0;
					g_esTank[iIndex].g_iShareRewards[iPos] = 0;
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

				if (iPos < sizeof esTank::g_iStackLimits)
				{
					g_esTank[iIndex].g_iStackLimits[iPos] = 0;
				}

				if (iPos < sizeof esTank::g_flComboChance)
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

				if (iPos < sizeof esTank::g_flComboTypeChance)
				{
					g_esTank[iIndex].g_flComboTypeChance[iPos] = 0.0;
				}

				if (iPos < sizeof esTank::g_flPropsChance)
				{
					g_esTank[iIndex].g_flPropsChance[iPos] = 33.3;
				}

				if (iPos < sizeof esTank::g_iSkinColor)
				{
					g_esTank[iIndex].g_iSkinColor[iPos] = 255;
					g_esTank[iIndex].g_iBossHealth[iPos] = 5000 / (iPos + 1);
					g_esTank[iIndex].g_iBossType[iPos] = (iPos + 2);
					g_esTank[iIndex].g_iLightColor[iPos] = 255;
					g_esTank[iIndex].g_iOzTankColor[iPos] = 255;
					g_esTank[iIndex].g_iFlameColor[iPos] = 255;
					g_esTank[iIndex].g_iRockColor[iPos] = 255;
					g_esTank[iIndex].g_iTireColor[iPos] = 255;
					g_esTank[iIndex].g_iPropTankColor[iPos] = 255;
					g_esTank[iIndex].g_iFlashlightColor[iPos] = 255;
					g_esTank[iIndex].g_iCrownColor[iPos] = 255;
				}

				if (iPos < sizeof esTank::g_iGlowColor)
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
				g_esPlayer[iPlayer].g_sGlowColor[0] = '\0';
				g_esPlayer[iPlayer].g_sSkinColor[0] = '\0';
				g_esPlayer[iPlayer].g_sFlameColor[0] = '\0';
				g_esPlayer[iPlayer].g_sFlashlightColor[0] = '\0';
				g_esPlayer[iPlayer].g_sOzTankColor[0] = '\0';
				g_esPlayer[iPlayer].g_sPropTankColor[0] = '\0';
				g_esPlayer[iPlayer].g_sRockColor[0] = '\0';
				g_esPlayer[iPlayer].g_sTireColor[0] = '\0';
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
				g_esPlayer[iPlayer].g_sItemReward[0] = '\0';
				g_esPlayer[iPlayer].g_sItemReward2[0] = '\0';
				g_esPlayer[iPlayer].g_sItemReward3[0] = '\0';
				g_esPlayer[iPlayer].g_sItemReward4[0] = '\0';
				g_esPlayer[iPlayer].g_sLightColorVisual[0] = '\0';
				g_esPlayer[iPlayer].g_sLightColorVisual2[0] = '\0';
				g_esPlayer[iPlayer].g_sLightColorVisual3[0] = '\0';
				g_esPlayer[iPlayer].g_sLightColorVisual4[0] = '\0';
				g_esPlayer[iPlayer].g_sLoopingVoicelineVisual[0] = '\0';
				g_esPlayer[iPlayer].g_sLoopingVoicelineVisual2[0] = '\0';
				g_esPlayer[iPlayer].g_sLoopingVoicelineVisual3[0] = '\0';
				g_esPlayer[iPlayer].g_sLoopingVoicelineVisual4[0] = '\0';
				g_esPlayer[iPlayer].g_sOutlineColorVisual[0] = '\0';
				g_esPlayer[iPlayer].g_sOutlineColorVisual2[0] = '\0';
				g_esPlayer[iPlayer].g_sOutlineColorVisual3[0] = '\0';
				g_esPlayer[iPlayer].g_sOutlineColorVisual4[0] = '\0';
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
				g_esPlayer[iPlayer].g_iGroundPound = 0;
				g_esPlayer[iPlayer].g_flHittableDamage = -1.0;
				g_esPlayer[iPlayer].g_flPunchForce = -1.0;
				g_esPlayer[iPlayer].g_flPunchThrow = 0.0;
				g_esPlayer[iPlayer].g_flRockDamage = -1.0;
				g_esPlayer[iPlayer].g_flRunSpeed = 0.0;
				g_esPlayer[iPlayer].g_iSkipIncap = 0;
				g_esPlayer[iPlayer].g_iSkipTaunt = 0;
				g_esPlayer[iPlayer].g_iSweepFist = 0;
				g_esPlayer[iPlayer].g_flThrowInterval = 0.0;
				g_esPlayer[iPlayer].g_iBulletImmunity = 0;
				g_esPlayer[iPlayer].g_iExplosiveImmunity = 0;
				g_esPlayer[iPlayer].g_iFireImmunity = 0;
				g_esPlayer[iPlayer].g_iHittableImmunity = 0;
				g_esPlayer[iPlayer].g_iMeleeImmunity = 0;
				g_esPlayer[iPlayer].g_iVomitImmunity = 0;

				for (int iPos = 0; iPos < sizeof esPlayer::g_iTransformType; iPos++)
				{
					g_esPlayer[iPlayer].g_iTransformType[iPos] = 0;

					if (iPos < sizeof esPlayer::g_iRewardEnabled)
					{
						g_esPlayer[iPlayer].g_iRewardEnabled[iPos] = -1;
						g_esPlayer[iPlayer].g_iRewardBots[iPos] = -1;
						g_esPlayer[iPlayer].g_flRewardChance[iPos] = 0.0;
						g_esPlayer[iPlayer].g_flRewardDuration[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iRewardEffect[iPos] = 0;
						g_esPlayer[iPlayer].g_iRewardNotify[iPos] = 0;
						g_esPlayer[iPlayer].g_flRewardPercentage[iPos] = 0.0;
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
						g_esPlayer[iPlayer].g_iLadderActionsReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iLadyKillerReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iLifeLeechReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iMeleeRangeReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iParticleEffectVisual[iPos] = 0;
						g_esPlayer[iPlayer].g_iPrefsNotify[iPos] = 0;
						g_esPlayer[iPlayer].g_flPunchResistanceReward[iPos] = 0.0;
						g_esPlayer[iPlayer].g_iRespawnLoadoutReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iReviveHealthReward[iPos] = 0;
						g_esPlayer[iPlayer].g_iShareRewards[iPos] = 0;
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

					if (iPos < sizeof esPlayer::g_iStackLimits)
					{
						g_esPlayer[iPlayer].g_iStackLimits[iPos] = 0;
					}

					if (iPos < sizeof esPlayer::g_flComboChance)
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

					if (iPos < sizeof esPlayer::g_flComboTypeChance)
					{
						g_esPlayer[iPlayer].g_flComboTypeChance[iPos] = 0.0;
					}

					if (iPos < sizeof esPlayer::g_flPropsChance)
					{
						g_esPlayer[iPlayer].g_flPropsChance[iPos] = 0.0;
					}

					if (iPos < sizeof esPlayer::g_iSkinColor)
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

					if (iPos < sizeof esPlayer::g_iGlowColor)
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

			strcopy(g_esGeneral.g_sCurrentSection, sizeof esGeneral::g_sCurrentSection, name);
		}
		else if (!strncmp(name, "Tank", 4, false) || name[0] == '#' || IsCharNumeric(name[0]) || StrContains(name, "all", false) != -1 || FindCharInString(name, ',') != -1 || FindCharInString(name, '-') != -1)
		{
			g_esGeneral.g_csState = ConfigState_Type;

			strcopy(g_esGeneral.g_sCurrentSection, sizeof esGeneral::g_sCurrentSection, name);
		}
		else if (!strncmp(name, "STEAM_", 6, false) || !strncmp("0:", name, 2) || !strncmp("1:", name, 2) || (!strncmp(name, "[U:", 3) && name[strlen(name) - 1] == ']'))
		{
			g_esGeneral.g_csState = ConfigState_Admin;

			strcopy(g_esGeneral.g_sCurrentSection, sizeof esGeneral::g_sCurrentSection, name);
		}
		else
		{
			g_esGeneral.g_iIgnoreLevel++;
		}
	}
	else if (g_esGeneral.g_csState == ConfigState_Settings || g_esGeneral.g_csState == ConfigState_Type || g_esGeneral.g_csState == ConfigState_Admin)
	{
		g_esGeneral.g_csState = ConfigState_Specific;

		strcopy(g_esGeneral.g_sCurrentSubSection, sizeof esGeneral::g_sCurrentSubSection, name);
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
				g_esGeneral.g_iPluginEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "PluginEnabled", "Plugin Enabled", "Plugin_Enabled", "penabled", g_esGeneral.g_iPluginEnabled, value, 0, 1);
				g_esGeneral.g_iListenSupport = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "ListenSupport", "Listen Support", "Listen_Support", "listen", g_esGeneral.g_iListenSupport, value, 0, 1);
				g_esGeneral.g_iCheckAbilities = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "CheckAbilities", "Check Abilities", "Check_Abilities", "check", g_esGeneral.g_iCheckAbilities, value, 0, 1);
				g_esGeneral.g_iDeathRevert = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esGeneral.g_iDeathRevert, value, 0, 1);
				g_esGeneral.g_iFinalesOnly = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "FinalesOnly", "Finales Only", "Finales_Only", "finale", g_esGeneral.g_iFinalesOnly, value, 0, 4);
				g_esGeneral.g_flIdleCheck = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "IdleCheck", "Idle Check", "Idle_Check", "idle", g_esGeneral.g_flIdleCheck, value, 0.0, 999999.0);
				g_esGeneral.g_iIdleCheckMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "IdleCheckMode", "Idle Check Mode", "Idle_Check_Mode", "idlemode", g_esGeneral.g_iIdleCheckMode, value, 0, 2);
				g_esGeneral.g_iLogCommands = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "LogCommands", "Log Commands", "Log_Commands", "logcmds", g_esGeneral.g_iLogCommands, value, 0, 31);
				g_esGeneral.g_iLogMessages = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "LogMessages", "Log Messages", "Log_Messages", "logmsgs", g_esGeneral.g_iLogMessages, value, 0, 31);
				g_esGeneral.g_iRequiresHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGeneral.g_iRequiresHumans, value, 0, 32);
				g_esGeneral.g_iTankEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankEnabled", "Tank Enabled", "Tank_Enabled", "tenabled", g_esGeneral.g_iTankEnabled, value, -1, 1);
				g_esGeneral.g_iTankModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankModel", "Tank Model", "Tank_Model", "model", g_esGeneral.g_iTankModel, value, 0, 7);
				g_esGeneral.g_flBurnDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "BurnDuration", "Burn Duration", "Burn_Duration", "burndur", g_esGeneral.g_flBurnDuration, value, 0.0, 999999.0);
				g_esGeneral.g_flBurntSkin = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "BurntSkin", "Burnt Skin", "Burnt_Skin", "burnt", g_esGeneral.g_flBurntSkin, value, -1.0, 1.0);
				g_esGeneral.g_iSpawnEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "SpawnEnabled", "Spawn Enabled", "Spawn_Enabled", "spawn", g_esGeneral.g_iSpawnEnabled, value, -1, 1);
				g_esGeneral.g_iSpawnLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "SpawnLimit", "Spawn Limit", "Spawn_Limit", "limit", g_esGeneral.g_iSpawnLimit, value, 0, 32);
				g_esGeneral.g_iAnnounceArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esGeneral.g_iAnnounceArrival, value, 0, 31);
				g_esGeneral.g_iAnnounceDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esGeneral.g_iAnnounceDeath, value, 0, 2);
				g_esGeneral.g_iAnnounceKill = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "AnnounceKill", "Announce Kill", "Announce_Kill", "kill", g_esGeneral.g_iAnnounceKill, value, 0, 1);
				g_esGeneral.g_iArrivalMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "ArrivalMessage", "Arrival Message", "Arrival_Message", "arrivalmsg", g_esGeneral.g_iArrivalMessage, value, 0, 1023);
				g_esGeneral.g_iArrivalSound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "ArrivalSound", "Arrival Sound", "Arrival_Sound", "arrivalsnd", g_esGeneral.g_iArrivalSound, value, 0, 1);
				g_esGeneral.g_iDeathDetails = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "DeathDetails", "Death Details", "Death_Details", "deathdets", g_esGeneral.g_iDeathDetails, value, 0, 5);
				g_esGeneral.g_iDeathMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "DeathMessage", "Death Message", "Death_Message", "deathmsg", g_esGeneral.g_iDeathMessage, value, 0, 1023);
				g_esGeneral.g_iDeathSound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "DeathSound", "Death Sound", "Death_Sound", "deathsnd", g_esGeneral.g_iDeathSound, value, 0, 1);
				g_esGeneral.g_iKillMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "KillMessage", "Kill Message", "Kill_Message", "killmsg", g_esGeneral.g_iKillMessage, value, 0, 1023);
				g_esGeneral.g_iVocalizeArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "VocalizeArrival", "Vocalize Arrival", "Vocalize_Arrival", "arrivalvoc", g_esGeneral.g_iVocalizeArrival, value, 0, 1);
				g_esGeneral.g_iVocalizeDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "VocalizeDeath", "Vocalize Death", "Vocalize_Death", "deathvoc", g_esGeneral.g_iVocalizeDeath, value, 0, 1);
				g_esGeneral.g_iTeammateLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, key, "TeammateLimit", "Teammate Limit", "Teammate_Limit", "teamlimit", g_esGeneral.g_iTeammateLimit, value, 0, 32);
				g_esGeneral.g_iAggressiveTanks = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP2, key, "AggressiveTanks", "Aggressive Tanks", "Aggressive_Tanks", "aggressive", g_esGeneral.g_iAggressiveTanks, value, 0, 1);
				g_esGeneral.g_iCreditIgniters = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP2, key, "CreditIgniters", "Credit Igniters", "Credit_Igniters", "credit", g_esGeneral.g_iCreditIgniters, value, 0, 1);
				g_esGeneral.g_flForceSpawn = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP2, key, "ForceSpawn", "Force Spawn", "Force_Spawn", "force", g_esGeneral.g_flForceSpawn, value, 0.0, 999999.0);
				g_esGeneral.g_iStasisMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP2, key, "StasisMode", "Stasis Mode", "Stasis_Mode", "stasis", g_esGeneral.g_iStasisMode, value, 0, 1);
				g_esGeneral.g_flSurvivalDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP, MT_CONFIG_SECTION_COMP2, key, "SurvivalDelay", "Survival Delay", "Survival_Delay", "survdelay", g_esGeneral.g_flSurvivalDelay, value, 0.1, 999999.0);
				g_esGeneral.g_iScaleDamage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_DIFF, MT_CONFIG_SECTION_DIFF, MT_CONFIG_SECTION_DIFF, MT_CONFIG_SECTION_DIFF2, key, "ScaleDamage", "Scale Damage", "Scale_Damage", "scaledmg", g_esGeneral.g_iScaleDamage, value, 0, 1);
				g_esGeneral.g_iBaseHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "BaseHealth", "Base Health", "Base_Health", "basehp", g_esGeneral.g_iBaseHealth, value, 0, MT_MAXHEALTH);
				g_esGeneral.g_iDisplayHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esGeneral.g_iDisplayHealth, value, 0, 11);
				g_esGeneral.g_iDisplayHealthType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esGeneral.g_iDisplayHealthType, value, 0, 2);
				g_esGeneral.g_iExtraHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "ExtraHealth", "Extra Health", "Extra_Health", "extrahp", g_esGeneral.g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
				g_esGeneral.g_iMinimumHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esGeneral.g_iMinimumHumans, value, 1, 32);
				g_esGeneral.g_iMultiplyHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esGeneral.g_iMultiplyHealth, value, 0, 3);
				g_esGeneral.g_flAttackInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "AttackInterval", "Attack Interval", "Attack_Interval", "attack", g_esGeneral.g_flAttackInterval, value, 0.0, 999999.0);
				g_esGeneral.g_flClawDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_esGeneral.g_flClawDamage, value, -1.0, 999999.0);
				g_esGeneral.g_iGroundPound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "GroundPound", "Ground Pound", "Ground_Pound", "pound", g_esGeneral.g_iGroundPound, value, 0, 1);
				g_esGeneral.g_flHittableDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "HittableDamage", "Hittable Damage", "Hittable_Damage", "hittable", g_esGeneral.g_flHittableDamage, value, -1.0, 999999.0);
				g_esGeneral.g_flPunchForce = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "PunchForce", "Punch Force", "Punch_Force", "punchf", g_esGeneral.g_flPunchForce, value, -1.0, 999999.0);
				g_esGeneral.g_flPunchThrow = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "PunchThrow", "Punch Throw", "Punch_Throw", "puncht", g_esGeneral.g_flPunchThrow, value, 0.0, 100.0);
				g_esGeneral.g_flRockDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esGeneral.g_flRockDamage, value, -1.0, 999999.0);
				g_esGeneral.g_flRunSpeed = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esGeneral.g_flRunSpeed, value, 0.0, 3.0);
				g_esGeneral.g_iSkipIncap = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "SkipIncap", "Skip Incap", "Skip_Incap", "incap", g_esGeneral.g_iSkipIncap, value, 0, 1);
				g_esGeneral.g_iSkipTaunt = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "SkipTaunt", "Skip Taunt", "Skip_Taunt", "taunt", g_esGeneral.g_iSkipTaunt, value, 0, 1);
				g_esGeneral.g_iSweepFist = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "SweepFist", "Sweep Fist", "Sweep_Fist", "sweep", g_esGeneral.g_iSweepFist, value, 0, 1);
				g_esGeneral.g_flThrowInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esGeneral.g_flThrowInterval, value, 0.0, 999999.0);
				g_esGeneral.g_iBulletImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esGeneral.g_iBulletImmunity, value, 0, 1);
				g_esGeneral.g_iExplosiveImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esGeneral.g_iExplosiveImmunity, value, 0, 1);
				g_esGeneral.g_iFireImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esGeneral.g_iFireImmunity, value, 0, 1);
				g_esGeneral.g_iHittableImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "HittableImmunity", "Hittable Immunity", "Hittable_Immunity", "hittable", g_esGeneral.g_iHittableImmunity, value, 0, 1);
				g_esGeneral.g_iMeleeImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esGeneral.g_iMeleeImmunity, value, 0, 1);
				g_esGeneral.g_iVomitImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "VomitImmunity", "Vomit Immunity", "Vomit_Immunity", "vomit", g_esGeneral.g_iVomitImmunity, value, 0, 1);
				g_esGeneral.g_iHumanCooldown = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HUMAN, MT_CONFIG_SECTION_HUMAN2, MT_CONFIG_SECTION_HUMAN3, MT_CONFIG_SECTION_HUMAN4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "cooldown", g_esGeneral.g_iHumanCooldown, value, 0, 999999);
				g_esGeneral.g_iMasterControl = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HUMAN, MT_CONFIG_SECTION_HUMAN2, MT_CONFIG_SECTION_HUMAN3, MT_CONFIG_SECTION_HUMAN4, key, "MasterControl", "Master Control", "Master_Control", "master", g_esGeneral.g_iMasterControl, value, 0, 1);
				g_esGeneral.g_iSpawnMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HUMAN, MT_CONFIG_SECTION_HUMAN2, MT_CONFIG_SECTION_HUMAN3, MT_CONFIG_SECTION_HUMAN4, key, "SpawnMode", "Spawn Mode", "Spawn_Mode", "spawnmode", g_esGeneral.g_iSpawnMode, value, 0, 1);
				g_esGeneral.g_iLimitExtras = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, key, "LimitExtras", "Limit Extras", "Limit_Extras", "limitex", g_esGeneral.g_iLimitExtras, value, 0, 1);
				g_esGeneral.g_flExtrasDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, key, "ExtrasDelay", "Extras Delay", "Extras_Delay", "exdelay", g_esGeneral.g_flExtrasDelay, value, 0.1, 999999.0);
				g_esGeneral.g_iRegularAmount = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, key, "RegularAmount", "Regular Amount", "Regular_Amount", "regamount", g_esGeneral.g_iRegularAmount, value, 0, 32);
				g_esGeneral.g_flRegularDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, key, "RegularDelay", "Regular Delay", "Regular_Delay", "regdelay", g_esGeneral.g_flRegularDelay, value, 0.1, 999999.0);
				g_esGeneral.g_flRegularInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, key, "RegularInterval", "Regular Interval", "Regular_Interval", "reginterval", g_esGeneral.g_flRegularInterval, value, 0.1, 999999.0);
				g_esGeneral.g_iRegularLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, key, "RegularLimit", "Regular Limit", "Regular_Limit", "reglimit", g_esGeneral.g_iRegularLimit, value, 0, 999999);
				g_esGeneral.g_iRegularMode = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, key, "RegularMode", "Regular Mode", "Regular_Mode", "regmode", g_esGeneral.g_iRegularMode, value, 0, 1);
				g_esGeneral.g_iRegularWave = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, key, "RegularWave", "Regular Wave", "Regular_Wave", "regwave", g_esGeneral.g_iRegularWave, value, 0, 1);
				g_esGeneral.g_iFinaleAmount = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, MT_CONFIG_SECTION_WAVES, key, "FinaleAmount", "Finale Amount", "Finale_Amount", "finamount", g_esGeneral.g_iFinaleAmount, value, 0, 32);
				g_esGeneral.g_iAccessFlags = iGetAdminFlagsValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN2, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
				g_esGeneral.g_iImmunityFlags = iGetAdminFlagsValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN2, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);

				vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "HealthCharacters", "Health Characters", "Health_Characters", "hpchars", g_esGeneral.g_sHealthCharacters, sizeof esGeneral::g_sHealthCharacters, value);

				if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, false))
				{
					if (StrEqual(key, "TypeRange", false) || StrEqual(key, "Type Range", false) || StrEqual(key, "Type_Range", false) || StrEqual(key, "types", false))
					{
						char sValue[10], sRange[2][5];
						strcopy(sValue, sizeof sValue, value);
						ReplaceString(sValue, sizeof sValue, " ", "");
						ExplodeString(sValue, "-", sRange, sizeof sRange, sizeof sRange[]);

						g_esGeneral.g_iMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esGeneral.g_iMinType;
						g_esGeneral.g_iMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esGeneral.g_iMaxType;
					}
				}
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_COLORS, false))
				{
					if (g_esGeneral.g_alColorKeys[0] != null)
					{
						g_esGeneral.g_alColorKeys[0].PushString(key);
					}

					if (g_esGeneral.g_alColorKeys[1] != null)
					{
						g_esGeneral.g_alColorKeys[1].PushString(value);
					}
				}
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_REWARDS, false))
				{
					char sValue[1280], sSet[7][320];
					strcopy(sValue, sizeof sValue, value);
					ReplaceString(sValue, sizeof sValue, " ", "");
					ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
					for (int iPos = 0; iPos < sizeof esGeneral::g_iStackLimits; iPos++)
					{
						if (iPos < sizeof esGeneral::g_iRewardEnabled)
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
							g_esGeneral.g_iRewardVisual[iPos] = iGetClampedValue(key, "RewardVisual", "Reward Visual", "Reward_Visual", "visual", g_esGeneral.g_iRewardVisual[iPos], sSet[iPos], 0, 63);
							g_esGeneral.g_iAmmoBoostReward[iPos] = iGetClampedValue(key, "AmmoBoostReward", "Ammo Boost Reward", "Ammo_Boost_Reward", "ammoboost", g_esGeneral.g_iAmmoBoostReward[iPos], sSet[iPos], 0, 1);
							g_esGeneral.g_iAmmoRegenReward[iPos] = iGetClampedValue(key, "AmmoRegenReward", "Ammo Regen Reward", "Ammo_Regen_Reward", "ammoregen", g_esGeneral.g_iAmmoRegenReward[iPos], sSet[iPos], 0, 999999);
							g_esGeneral.g_iCleanKillsReward[iPos] = iGetClampedValue(key, "CleanKillsReward", "Clean Kills Reward", "Clean_Kills_Reward", "cleankills", g_esGeneral.g_iCleanKillsReward[iPos], sSet[iPos], 0, 1);
							g_esGeneral.g_iHealthRegenReward[iPos] = iGetClampedValue(key, "HealthRegenReward", "Health Regen Reward", "Health_Regen_Reward", "hpregen", g_esGeneral.g_iHealthRegenReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
							g_esGeneral.g_iHollowpointAmmoReward[iPos] = iGetClampedValue(key, "HollowpointAmmoReward", "Hollowpoint Ammo Reward", "Hollowpoint_Ammo_Reward", "hollowpoint", g_esGeneral.g_iHollowpointAmmoReward[iPos], sSet[iPos], 0, 1);
							g_esGeneral.g_iInfiniteAmmoReward[iPos] = iGetClampedValue(key, "InfiniteAmmoReward", "Infinite Ammo Reward", "Infinite_Ammo_Reward", "infammo", g_esGeneral.g_iInfiniteAmmoReward[iPos], sSet[iPos], 0, 31);
							g_esGeneral.g_iLadderActionsReward[iPos] = iGetClampedValue(key, "LadderActionsReward", "Ladder Actions Reward", "Ladder_Action_Reward", "ladderactions", g_esGeneral.g_iLadderActionsReward[iPos], sSet[iPos], 0, 999999);
							g_esGeneral.g_iLadyKillerReward[iPos] = iGetClampedValue(key, "LadyKillerReward", "Lady Killer Reward", "Lady_Killer_Reward", "ladykiller", g_esGeneral.g_iLadyKillerReward[iPos], sSet[iPos], 0, 1);
							g_esGeneral.g_iLifeLeechReward[iPos] = iGetClampedValue(key, "LifeLeechReward", "Life Leech Reward", "Life_Leech_Reward", "lifeleech", g_esGeneral.g_iLifeLeechReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
							g_esGeneral.g_iMeleeRangeReward[iPos] = iGetClampedValue(key, "MeleeRangeReward", "Melee Range Reward", "Melee_Range_Reward", "meleerange", g_esGeneral.g_iMeleeRangeReward[iPos], sSet[iPos], 0, 999999);
							g_esGeneral.g_iParticleEffectVisual[iPos] = iGetClampedValue(key, "ParticleEffectVisual", "Particle Effect Visual", "Particle_Effect_Visual", "particle", g_esGeneral.g_iParticleEffectVisual[iPos], sSet[iPos], 0, 15);
							g_esGeneral.g_iPrefsNotify[iPos] = iGetClampedValue(key, "PrefsNotify", "Prefs Notify", "Prefs_Notify", "pnotify", g_esGeneral.g_iPrefsNotify[iPos], sSet[iPos], 0, 1);
							g_esGeneral.g_iRespawnLoadoutReward[iPos] = iGetClampedValue(key, "RespawnLoadoutReward", "Respawn Loadout Reward", "Respawn_Loadout_Reward", "resloadout", g_esGeneral.g_iRespawnLoadoutReward[iPos], sSet[iPos], 0, 1);
							g_esGeneral.g_iReviveHealthReward[iPos] = iGetClampedValue(key, "ReviveHealthReward", "Revive Health Reward", "Revive_Health_Reward", "revivehp", g_esGeneral.g_iReviveHealthReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
							g_esGeneral.g_iShareRewards[iPos] = iGetClampedValue(key, "ShareRewards", "Share Rewards", "Share_Rewards", "share", g_esGeneral.g_iShareRewards[iPos], sSet[iPos], 0, 3);
							g_esGeneral.g_iShovePenaltyReward[iPos] = iGetClampedValue(key, "ShovePenaltyReward", "Shove Penalty Reward", "Shove_Penalty_Reward", "shovepenalty", g_esGeneral.g_iShovePenaltyReward[iPos], sSet[iPos], 0, 1);
							g_esGeneral.g_iSledgehammerRoundsReward[iPos] = iGetClampedValue(key, "SledgehammerRoundsReward", "Sledgehammer Rounds Reward", "Sledgehammer_Rounds_Reward", "sledgehammer", g_esGeneral.g_iSledgehammerRoundsReward[iPos], sSet[iPos], 0, 1);
							g_esGeneral.g_iSpecialAmmoReward[iPos] = iGetClampedValue(key, "SpecialAmmoReward", "Special Ammo Reward", "Special_Ammo_Reward", "specialammo", g_esGeneral.g_iSpecialAmmoReward[iPos], sSet[iPos], 0, 3);
							g_esGeneral.g_iStackRewards[iPos] = iGetClampedValue(key, "StackRewards", "Stack Rewards", "Stack_Rewards", "stack", g_esGeneral.g_iStackRewards[iPos], sSet[iPos], 0, 2147483647);
							g_esGeneral.g_iThornsReward[iPos] = iGetClampedValue(key, "ThornsReward", "Thorns Reward", "Thorns_Reward", "thorns", g_esGeneral.g_iThornsReward[iPos], sSet[iPos], 0, 1);
							g_esGeneral.g_iUsefulRewards[iPos] = iGetClampedValue(key, "UsefulRewards", "Useful Rewards", "Useful_Rewards", "useful", g_esGeneral.g_iUsefulRewards[iPos], sSet[iPos], 0, 15);

							vGetConfigColors(sValue, sizeof sValue, sSet[iPos], ';');
							vGetStringValue(key, "BodyColorVisual", "Body Color Visual", "Body_Color_Visual", "bodycolor", iPos, g_esGeneral.g_sBodyColorVisual, sizeof esGeneral::g_sBodyColorVisual, g_esGeneral.g_sBodyColorVisual2, sizeof esGeneral::g_sBodyColorVisual2, g_esGeneral.g_sBodyColorVisual3, sizeof esGeneral::g_sBodyColorVisual3, g_esGeneral.g_sBodyColorVisual4, sizeof esGeneral::g_sBodyColorVisual4, sValue);
							vGetStringValue(key, "FallVoicelineReward", "Fall Voiceline Reward", "Fall_Voiceline_Reward", "fallvoice", iPos, g_esGeneral.g_sFallVoicelineReward, sizeof esGeneral::g_sFallVoicelineReward, g_esGeneral.g_sFallVoicelineReward2, sizeof esGeneral::g_sFallVoicelineReward2, g_esGeneral.g_sFallVoicelineReward3, sizeof esGeneral::g_sFallVoicelineReward3, g_esGeneral.g_sFallVoicelineReward4, sizeof esGeneral::g_sFallVoicelineReward4, sSet[iPos]);
							vGetStringValue(key, "GlowColorVisual", "Glow Color Visual", "Glow_Color_Visual", "glowcolor", iPos, g_esGeneral.g_sOutlineColorVisual, sizeof esGeneral::g_sOutlineColorVisual, g_esGeneral.g_sOutlineColorVisual2, sizeof esGeneral::g_sOutlineColorVisual2, g_esGeneral.g_sOutlineColorVisual3, sizeof esGeneral::g_sOutlineColorVisual3, g_esGeneral.g_sOutlineColorVisual4, sizeof esGeneral::g_sOutlineColorVisual4, sValue);
							vGetStringValue(key, "ItemReward", "Item Reward", "Item_Reward", "item", iPos, g_esGeneral.g_sItemReward, sizeof esGeneral::g_sItemReward, g_esGeneral.g_sItemReward2, sizeof esGeneral::g_sItemReward2, g_esGeneral.g_sItemReward3, sizeof esGeneral::g_sItemReward3, g_esGeneral.g_sItemReward4, sizeof esGeneral::g_sItemReward4, sSet[iPos]);
							vGetStringValue(key, "LightColorVisual", "Light Color Visual", "Light_Color_Visual", "lightcolor", iPos, g_esGeneral.g_sLightColorVisual, sizeof esGeneral::g_sLightColorVisual, g_esGeneral.g_sLightColorVisual2, sizeof esGeneral::g_sLightColorVisual2, g_esGeneral.g_sLightColorVisual3, sizeof esGeneral::g_sLightColorVisual3, g_esGeneral.g_sLightColorVisual4, sizeof esGeneral::g_sLightColorVisual4, sValue);
							vGetStringValue(key, "LoopingVoicelineVisual", "Looping Voiceline Visual", "Looping_Voiceline_Visual", "loopvoice", iPos, g_esGeneral.g_sLoopingVoicelineVisual, sizeof esGeneral::g_sLoopingVoicelineVisual, g_esGeneral.g_sLoopingVoicelineVisual2, sizeof esGeneral::g_sLoopingVoicelineVisual2, g_esGeneral.g_sLoopingVoicelineVisual3, sizeof esGeneral::g_sLoopingVoicelineVisual3, g_esGeneral.g_sLoopingVoicelineVisual4, sizeof esGeneral::g_sLoopingVoicelineVisual4, sSet[iPos]);
							vGetStringValue(key, "ScreenColorVisual", "Screen Color Visual", "Screen_Color_Visual", "screencolor", iPos, g_esGeneral.g_sScreenColorVisual, sizeof esGeneral::g_sScreenColorVisual, g_esGeneral.g_sScreenColorVisual2, sizeof esGeneral::g_sScreenColorVisual2, g_esGeneral.g_sScreenColorVisual3, sizeof esGeneral::g_sScreenColorVisual3, g_esGeneral.g_sScreenColorVisual4, sizeof esGeneral::g_sScreenColorVisual4, sValue);
						}

						g_esGeneral.g_iStackLimits[iPos] = iGetClampedValue(key, "StackLimits", "Stack Limits", "Stack_Limits", "limits", g_esGeneral.g_iStackLimits[iPos], sSet[iPos], 0, 999999);
					}
				}
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_DIFF, false) || StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_DIFF2, false))
				{
					if (StrEqual(key, "DifficultyDamage", false) || StrEqual(key, "Difficulty Damage", false) || StrEqual(key, "Difficulty_Damage", false) || StrEqual(key, "diffdmg", false))
					{
						char sValue[36], sSet[4][9];
						strcopy(sValue, sizeof sValue, value);
						ReplaceString(sValue, sizeof sValue, " ", "");
						ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
						for (int iPos = 0; iPos < sizeof esGeneral::g_flDifficultyDamage; iPos++)
						{
							g_esGeneral.g_flDifficultyDamage[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 999999.0) : g_esGeneral.g_flDifficultyDamage[iPos];
						}
					}
				}
				else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_WAVES, false))
				{
					if (StrEqual(key, "RegularType", false) || StrEqual(key, "Regular Type", false) || StrEqual(key, "Regular_Type", false) || StrEqual(key, "regtype", false))
					{
						char sValue[10], sRange[2][5];
						strcopy(sValue, sizeof sValue, value);
						ReplaceString(sValue, sizeof sValue, " ", "");
						ExplodeString(sValue, "-", sRange, sizeof sRange, sizeof sRange[]);

						g_esGeneral.g_iRegularMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esGeneral.g_iRegularMinType;
						g_esGeneral.g_iRegularMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esGeneral.g_iRegularMaxType;
					}
					else if (StrEqual(key, "FinaleTypes", false) || StrEqual(key, "Finale Types", false) || StrEqual(key, "Finale_Types", false) || StrEqual(key, "fintypes", false))
					{
						char sValue[100], sRange[10][10], sSet[2][5];
						strcopy(sValue, sizeof sValue, value);
						ReplaceString(sValue, sizeof sValue, " ", "");
						ExplodeString(sValue, ",", sRange, sizeof sRange, sizeof sRange[]);
						for (int iPos = 0; iPos < sizeof sRange; iPos++)
						{
							if (sRange[iPos][0] == '\0')
							{
								continue;
							}

							ExplodeString(sRange[iPos], "-", sSet, sizeof sSet, sizeof sSet[]);
							g_esGeneral.g_iFinaleMinTypes[iPos] = (sSet[0][0] != '\0') ? iClamp(StringToInt(sSet[0]), 0, MT_MAXTYPES) : g_esGeneral.g_iFinaleMinTypes[iPos];
							g_esGeneral.g_iFinaleMaxTypes[iPos] = (sSet[1][0] != '\0') ? iClamp(StringToInt(sSet[1]), 0, MT_MAXTYPES) : g_esGeneral.g_iFinaleMaxTypes[iPos];
						}
					}
					else if (StrEqual(key, "FinaleWaves", false) || StrEqual(key, "Finale Waves", false) || StrEqual(key, "Finale_Waves", false) || StrEqual(key, "finwaves", false))
					{
						char sValue[30], sSet[10][3];
						strcopy(sValue, sizeof sValue, value);
						ReplaceString(sValue, sizeof sValue, " ", "");
						ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
						for (int iPos = 0; iPos < sizeof esGeneral::g_iFinaleWave; iPos++)
						{
							g_esGeneral.g_iFinaleWave[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 32) : g_esGeneral.g_iFinaleWave[iPos];
						}
					}
				}
				else if ((StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_CONVARS, false) || StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_CONVARS2, false)) && key[0] != '\0')
				{
					char sKey[128], sValue[PLATFORM_MAX_PATH];
					strcopy(sKey, sizeof sKey, key);
					ReplaceString(sKey, sizeof sKey, " ", "");

					strcopy(sValue, sizeof sValue, value);
					ReplaceString(sValue, sizeof sValue, " ", "");

					g_esGeneral.g_cvMTTempSetting = FindConVar(sKey);
					if (g_esGeneral.g_cvMTTempSetting != null)
					{
						if (g_esGeneral.g_cvMTTempSetting.Plugin != g_hPluginHandle)
						{
							int iFlags = g_esGeneral.g_cvMTTempSetting.Flags;
							g_esGeneral.g_cvMTTempSetting.Flags &= ~FCVAR_NOTIFY;
							g_esGeneral.g_cvMTTempSetting.SetString(sValue);
							g_esGeneral.g_cvMTTempSetting.Flags = iFlags;
							g_esGeneral.g_cvMTTempSetting = null;

							vLogMessage(MT_LOG_SERVER, _, "%s Changed cvar \"%s\" to \"%s\".", MT_TAG, sKey, sValue);
						}
						else
						{
							vLogMessage(MT_LOG_SERVER, _, "%s Unable to change cvar: %s", MT_TAG, sKey);
						}
					}
					else
					{
						vLogMessage(MT_LOG_SERVER, _, "%s Unable to find cvar: %s", MT_TAG, sKey);
					}
				}

				if (g_esGeneral.g_iConfigMode == 1)
				{
					g_esGeneral.g_iGameModeTypes = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GAMEMODES, MT_CONFIG_SECTION_GAMEMODES2, MT_CONFIG_SECTION_GAMEMODES3, MT_CONFIG_SECTION_GAMEMODES4, key, "GameModeTypes", "Game Mode Types", "Game_Mode_Types", "types", g_esGeneral.g_iGameModeTypes, value, 0, 15);
					g_esGeneral.g_iConfigEnable = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, key, "EnableCustomConfigs", "Enable Custom Configs", "Enable_Custom_Configs", "cenabled", g_esGeneral.g_iConfigEnable, value, 0, 1);
					g_esGeneral.g_iConfigCreate = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, key, "CreateConfigTypes", "Create Config Types", "Create_Config_Types", "create", g_esGeneral.g_iConfigCreate, value, 0, 255);
					g_esGeneral.g_iConfigExecute = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, MT_CONFIG_SECTION_CUSTOM, key, "ExecuteConfigTypes", "Execute Config Types", "Execute_Config_Types", "execute", g_esGeneral.g_iConfigExecute, value, 0, 255);

					vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GAMEMODES, MT_CONFIG_SECTION_GAMEMODES2, MT_CONFIG_SECTION_GAMEMODES3, MT_CONFIG_SECTION_GAMEMODES4, key, "EnabledGameModes", "Enabled Game Modes", "Enabled_Game_Modes", "gmenabled", g_esGeneral.g_sEnabledGameModes, sizeof esGeneral::g_sEnabledGameModes, value);
					vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GAMEMODES, MT_CONFIG_SECTION_GAMEMODES2, MT_CONFIG_SECTION_GAMEMODES3, MT_CONFIG_SECTION_GAMEMODES4, key, "DisabledGameModes", "Disabled Game Modes", "Disabled_Game_Modes", "gmdisabled", g_esGeneral.g_sDisabledGameModes, sizeof esGeneral::g_sDisabledGameModes, value);
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
			else if (!strncmp(g_esGeneral.g_sCurrentSection, "Tank", 4, false) || g_esGeneral.g_sCurrentSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || FindCharInString(g_esGeneral.g_sCurrentSection, ',') != -1 || FindCharInString(g_esGeneral.g_sCurrentSection, '-') != -1)
			{
				int iStartPos = 0, iIndex = 0, iRealType = 0;
				if (!strncmp(g_esGeneral.g_sCurrentSection, "Tank", 4, false) || g_esGeneral.g_sCurrentSection[0] == '#')
				{
					iStartPos = iGetConfigSectionNumber(g_esGeneral.g_sCurrentSection, sizeof esGeneral::g_sCurrentSection), iIndex = StringToInt(g_esGeneral.g_sCurrentSection[iStartPos]);
					vReadTankSettings(iIndex, g_esGeneral.g_sCurrentSubSection, key, value);
				}
				else if (IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || FindCharInString(g_esGeneral.g_sCurrentSection, ',') != -1 || FindCharInString(g_esGeneral.g_sCurrentSection, '-') != -1)
				{
					if (IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) && (FindCharInString(g_esGeneral.g_sCurrentSection, ',') == -1 || FindCharInString(g_esGeneral.g_sCurrentSection, '-') == -1))
					{
						iIndex = StringToInt(g_esGeneral.g_sCurrentSection);
						vReadTankSettings(iIndex, g_esGeneral.g_sCurrentSubSection, key, value);
					}
					else if (StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || FindCharInString(g_esGeneral.g_sCurrentSection, ',') != -1 || FindCharInString(g_esGeneral.g_sCurrentSection, '-') != -1)
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
		else if (g_esGeneral.g_iConfigMode == 3 && (!strncmp(g_esGeneral.g_sCurrentSection, "STEAM_", 6, false) || !strncmp("0:", g_esGeneral.g_sCurrentSection, 2) || !strncmp("1:", g_esGeneral.g_sCurrentSection, 2) || (!strncmp(g_esGeneral.g_sCurrentSection, "[U:", 3) && g_esGeneral.g_sCurrentSection[strlen(g_esGeneral.g_sCurrentSection) - 1] == ']')))
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
				{
					if (StrEqual(g_esPlayer[iPlayer].g_sSteamID32, g_esGeneral.g_sCurrentSection, false) || StrEqual(g_esPlayer[iPlayer].g_sSteam3ID, g_esGeneral.g_sCurrentSection, false))
					{
						g_esPlayer[iPlayer].g_iTankModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankModel", "Tank Model", "Tank_Model", "model", g_esPlayer[iPlayer].g_iTankModel, value, 0, 7);
						g_esPlayer[iPlayer].g_flBurnDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "BurnDuration", "Burn Duration", "Burn_Duration", "burndur", g_esPlayer[iPlayer].g_flBurnDuration, value, 0.0, 999999.0);
						g_esPlayer[iPlayer].g_flBurntSkin = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "BurntSkin", "Burnt Skin", "Burnt_Skin", "burnt", g_esPlayer[iPlayer].g_flBurntSkin, value, -1.0, 1.0);
						g_esPlayer[iPlayer].g_iTankNote = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankNote", "Tank Note", "Tank_Note", "note", g_esPlayer[iPlayer].g_iTankNote, value, 0, 1);
						g_esPlayer[iPlayer].g_iCheckAbilities = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "CheckAbilities", "Check Abilities", "Check_Abilities", "check", g_esPlayer[iPlayer].g_iCheckAbilities, value, 0, 1);
						g_esPlayer[iPlayer].g_iDeathRevert = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esPlayer[iPlayer].g_iDeathRevert, value, 0, 1);
						g_esPlayer[iPlayer].g_iAnnounceArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esPlayer[iPlayer].g_iAnnounceArrival, value, 0, 31);
						g_esPlayer[iPlayer].g_iAnnounceDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esPlayer[iPlayer].g_iAnnounceDeath, value, 0, 2);
						g_esPlayer[iPlayer].g_iAnnounceKill = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "AnnounceKill", "Announce Kill", "Announce_Kill", "kill", g_esPlayer[iPlayer].g_iAnnounceKill, value, 0, 1);
						g_esPlayer[iPlayer].g_iArrivalMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "ArrivalMessage", "Arrival Message", "Arrival_Message", "arrivalmsg", g_esPlayer[iPlayer].g_iArrivalMessage, value, 0, 1023);
						g_esPlayer[iPlayer].g_iArrivalSound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "ArrivalSound", "Arrival Sound", "Arrival_Sound", "arrivalsnd", g_esPlayer[iPlayer].g_iArrivalSound, value, 0, 1);
						g_esPlayer[iPlayer].g_iDeathDetails = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "DeathDetails", "Death Details", "Death_Details", "deathdets", g_esPlayer[iPlayer].g_iDeathDetails, value, 0, 5);
						g_esPlayer[iPlayer].g_iDeathMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "DeathMessage", "Death Message", "Death_Message", "deathmsg", g_esPlayer[iPlayer].g_iDeathMessage, value, 0, 1023);
						g_esPlayer[iPlayer].g_iDeathSound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "DeathSound", "Death Sound", "Death_Sound", "deathsnd", g_esPlayer[iPlayer].g_iDeathSound, value, 0, 1);
						g_esPlayer[iPlayer].g_iKillMessage = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "KillMessage", "Kill Message", "Kill_Message", "killmsg", g_esPlayer[iPlayer].g_iKillMessage, value, 0, 1023);
						g_esPlayer[iPlayer].g_iVocalizeArrival = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "VocalizeArrival", "Vocalize Arrival", "Vocalize_Arrival", "arrivalvoc", g_esPlayer[iPlayer].g_iVocalizeArrival, value, 0, 1);
						g_esPlayer[iPlayer].g_iVocalizeDeath = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "VocalizeDeath", "Vocalize Death", "Vocalize_Death", "deathvoc", g_esPlayer[iPlayer].g_iVocalizeDeath, value, 0, 1);
						g_esPlayer[iPlayer].g_iTeammateLimit = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, key, "TeammateLimit", "Teammate Limit", "Teammate_Limit", "teamlimit", g_esPlayer[iPlayer].g_iTeammateLimit, value, 0, 32);
						g_esPlayer[iPlayer].g_iGlowEnabled = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "genabled", g_esPlayer[iPlayer].g_iGlowEnabled, value, 0, 1);
						g_esPlayer[iPlayer].g_iGlowFlashing = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, key, "GlowFlashing", "Glow Flashing", "Glow_Flashing", "flashing", g_esPlayer[iPlayer].g_iGlowFlashing, value, 0, 1);
						g_esPlayer[iPlayer].g_iGlowType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, key, "GlowType", "Glow Type", "Glow_Type", "type", g_esPlayer[iPlayer].g_iGlowType, value, 0, 1);
						g_esPlayer[iPlayer].g_iBaseHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "BaseHealth", "Base Health", "Base_Health", "basehp", g_esPlayer[iPlayer].g_iBaseHealth, value, 0, MT_MAXHEALTH);
						g_esPlayer[iPlayer].g_iDisplayHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esPlayer[iPlayer].g_iDisplayHealth, value, 0, 11);
						g_esPlayer[iPlayer].g_iDisplayHealthType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esPlayer[iPlayer].g_iDisplayHealthType, value, 0, 2);
						g_esPlayer[iPlayer].g_iExtraHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "ExtraHealth", "Extra Health", "Extra_Health", "extrahp", g_esPlayer[iPlayer].g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
						g_esPlayer[iPlayer].g_iMinimumHumans = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esPlayer[iPlayer].g_iMinimumHumans, value, 1, 32);
						g_esPlayer[iPlayer].g_iMultiplyHealth = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esPlayer[iPlayer].g_iMultiplyHealth, value, 0, 3);
						g_esPlayer[iPlayer].g_iBossStages = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_BOSS, MT_CONFIG_SECTION_BOSS, MT_CONFIG_SECTION_BOSS, MT_CONFIG_SECTION_BOSS, key, "BossStages", "Boss Stages", "Boss_Stages", "bossstages", g_esPlayer[iPlayer].g_iBossStages, value, 1, 4);
						g_esPlayer[iPlayer].g_iRandomTank = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, key, "RandomTank", "Random Tank", "Random_Tank", "random", g_esPlayer[iPlayer].g_iRandomTank, value, 0, 1);
						g_esPlayer[iPlayer].g_flRandomDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, key, "RandomDuration", "Random Duration", "Random_Duration", "randduration", g_esPlayer[iPlayer].g_flRandomDuration, value, 0.1, 999999.0);
						g_esPlayer[iPlayer].g_flRandomInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, key, "RandomInterval", "Random Interval", "Random_Interval", "randinterval", g_esPlayer[iPlayer].g_flRandomInterval, value, 0.1, 999999.0);
						g_esPlayer[iPlayer].g_flTransformDelay = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, key, "TransformDelay", "Transform Delay", "Transform_Delay", "transdelay", g_esPlayer[iPlayer].g_flTransformDelay, value, 0.1, 999999.0);
						g_esPlayer[iPlayer].g_flTransformDuration = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, key, "TransformDuration", "Transform Duration", "Transform_Duration", "transduration", g_esPlayer[iPlayer].g_flTransformDuration, value, 0.1, 999999.0);
						g_esPlayer[iPlayer].g_iSpawnType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, key, "SpawnType", "Spawn Type", "Spawn_Type", "spawntype", g_esPlayer[iPlayer].g_iSpawnType, value, 0, 4);
						g_esPlayer[iPlayer].g_iRockModel = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, key, "RockModel", "Rock Model", "Rock_Model", "rockmodel", g_esPlayer[iPlayer].g_iRockModel, value, 0, 2);
						g_esPlayer[iPlayer].g_iPropsAttached = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, key, "PropsAttached", "Props Attached", "Props_Attached", "attached", g_esPlayer[iPlayer].g_iPropsAttached, value, 0, 511);
						g_esPlayer[iPlayer].g_iBodyEffects = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, key, "BodyEffects", "Body Effects", "Body_Effects", "body", g_esPlayer[iPlayer].g_iBodyEffects, value, 0, 127);
						g_esPlayer[iPlayer].g_iRockEffects = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, key, "RockEffects", "Rock Effects", "Rock_Effects", "rock", g_esPlayer[iPlayer].g_iRockEffects, value, 0, 15);
						g_esPlayer[iPlayer].g_flAttackInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "AttackInterval", "Attack Interval", "Attack_Interval", "attack", g_esPlayer[iPlayer].g_flAttackInterval, value, 0.0, 999999.0);
						g_esPlayer[iPlayer].g_flClawDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_esPlayer[iPlayer].g_flClawDamage, value, -1.0, 999999.0);
						g_esPlayer[iPlayer].g_iGroundPound = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "GroundPound", "Ground Pound", "Ground_Pound", "pound", g_esPlayer[iPlayer].g_iGroundPound, value, 0, 1);
						g_esPlayer[iPlayer].g_flHittableDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "HittableDamage", "Hittable Damage", "Hittable_Damage", "hittable", g_esPlayer[iPlayer].g_flHittableDamage, value, -1.0, 999999.0);
						g_esPlayer[iPlayer].g_flPunchForce = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "PunchForce", "Punch Force", "Punch_Force", "punchf", g_esPlayer[iPlayer].g_flPunchForce, value, -1.0, 999999.0);
						g_esPlayer[iPlayer].g_flPunchThrow = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "PunchThrow", "Punch Throw", "Punch_Throw", "puncht", g_esPlayer[iPlayer].g_flPunchThrow, value, 0.0, 100.0);
						g_esPlayer[iPlayer].g_flRockDamage = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esPlayer[iPlayer].g_flRockDamage, value, -1.0, 999999.0);
						g_esPlayer[iPlayer].g_flRunSpeed = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esPlayer[iPlayer].g_flRunSpeed, value, 0.0, 3.0);
						g_esPlayer[iPlayer].g_iSkipIncap = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "SkipIncap", "Skip Incap", "Skip_Incap", "incap", g_esPlayer[iPlayer].g_iSkipIncap, value, 0, 1);
						g_esPlayer[iPlayer].g_iSkipTaunt = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "SkipTaunt", "Skip Taunt", "Skip_Taunt", "taunt", g_esPlayer[iPlayer].g_iSkipTaunt, value, 0, 1);
						g_esPlayer[iPlayer].g_iSweepFist = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "SweepFist", "Sweep Fist", "Sweep_Fist", "sweep", g_esPlayer[iPlayer].g_iSweepFist, value, 0, 1);
						g_esPlayer[iPlayer].g_flThrowInterval = flGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esPlayer[iPlayer].g_flThrowInterval, value, 0.0, 999999.0);
						g_esPlayer[iPlayer].g_iBulletImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esPlayer[iPlayer].g_iBulletImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iExplosiveImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esPlayer[iPlayer].g_iExplosiveImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iFireImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esPlayer[iPlayer].g_iFireImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iHittableImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "HittableImmunity", "Hittable Immunity", "Hittable_Immunity", "hittable", g_esPlayer[iPlayer].g_iHittableImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iMeleeImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esPlayer[iPlayer].g_iMeleeImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iVomitImmunity = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "VomitImmunity", "Vomit Immunity", "Vomit_Immunity", "vomit", g_esPlayer[iPlayer].g_iVomitImmunity, value, 0, 1);
						g_esPlayer[iPlayer].g_iFavoriteType = iGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN2, key, "FavoriteType", "Favorite Type", "Favorite_Type", "favorite", g_esPlayer[iPlayer].g_iFavoriteType, value, 0, g_esGeneral.g_iMaxType);
						g_esPlayer[iPlayer].g_iAccessFlags = iGetAdminFlagsValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN2, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
						g_esPlayer[iPlayer].g_iImmunityFlags = iGetAdminFlagsValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN2, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);

						vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "HealthCharacters", "Health Characters", "Health_Characters", "hpchars", g_esPlayer[iPlayer].g_sHealthCharacters, sizeof esPlayer::g_sHealthCharacters, value);
						vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_COMBO, MT_CONFIG_SECTION_COMBO, MT_CONFIG_SECTION_COMBO, MT_CONFIG_SECTION_COMBO, key, "ComboSet", "Combo Set", "Combo_Set", "set", g_esPlayer[iPlayer].g_sComboSet, sizeof esPlayer::g_sComboSet, value);

						if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, false))
						{
							if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
							{
								char sValue[64], sSet[4][4];
								vGetConfigColors(sValue, sizeof sValue, value);
								strcopy(g_esPlayer[iPlayer].g_sSkinColor, sizeof esPlayer::g_sSkinColor, value);
								ReplaceString(sValue, sizeof sValue, " ", "");
								ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
								for (int iPos = 0; iPos < sizeof esPlayer::g_iSkinColor; iPos++)
								{
									g_esPlayer[iPlayer].g_iSkinColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
								}
							}
							else
							{
								vGetKeyValue(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankName", "Tank Name", "Tank_Name", "name", g_esPlayer[iPlayer].g_sTankName, sizeof esPlayer::g_sTankName, value);
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_REWARDS, false))
						{
							char sValue[1280], sSet[7][320];
							strcopy(sValue, sizeof sValue, value);
							ReplaceString(sValue, sizeof sValue, " ", "");
							ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
							for (int iPos = 0; iPos < sizeof esPlayer::g_iStackLimits; iPos++)
							{
								if (iPos < sizeof esPlayer::g_iRewardEnabled)
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
									g_esPlayer[iPlayer].g_iRewardVisual[iPos] = iGetClampedValue(key, "RewardVisual", "Reward Visual", "Reward_Visual", "visual", g_esPlayer[iPlayer].g_iRewardVisual[iPos], sSet[iPos], 0, 63);
									g_esPlayer[iPlayer].g_iAmmoBoostReward[iPos] = iGetClampedValue(key, "AmmoBoostReward", "Ammo Boost Reward", "Ammo_Boost_Reward", "ammoboost", g_esPlayer[iPlayer].g_iAmmoBoostReward[iPos], sSet[iPos], 0, 1);
									g_esPlayer[iPlayer].g_iAmmoRegenReward[iPos] = iGetClampedValue(key, "AmmoRegenReward", "Ammo Regen Reward", "Ammo_Regen_Reward", "ammoregen", g_esPlayer[iPlayer].g_iAmmoRegenReward[iPos], sSet[iPos], 0, 999999);
									g_esPlayer[iPlayer].g_iCleanKillsReward[iPos] = iGetClampedValue(key, "CleanKillsReward", "Clean Kills Reward", "Clean_Kills_Reward", "cleankills", g_esPlayer[iPlayer].g_iCleanKillsReward[iPos], sSet[iPos], 0, 1);
									g_esPlayer[iPlayer].g_iHealthRegenReward[iPos] = iGetClampedValue(key, "HealthRegenReward", "Health Regen Reward", "Health_Regen_Reward", "hpregen", g_esPlayer[iPlayer].g_iHealthRegenReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
									g_esPlayer[iPlayer].g_iHollowpointAmmoReward[iPos] = iGetClampedValue(key, "HollowpointAmmoReward", "Hollowpoint Ammo Reward", "Hollowpoint_Ammo_Reward", "hollowpoint", g_esPlayer[iPlayer].g_iHollowpointAmmoReward[iPos], sSet[iPos], 0, 1);
									g_esPlayer[iPlayer].g_iInfiniteAmmoReward[iPos] = iGetClampedValue(key, "InfiniteAmmoReward", "Infinite Ammo Reward", "Infinite_Ammo_Reward", "infammo", g_esPlayer[iPlayer].g_iInfiniteAmmoReward[iPos], sSet[iPos], 0, 31);
									g_esPlayer[iPlayer].g_iLadderActionsReward[iPos] = iGetClampedValue(key, "LadderActionsReward", "Ladder Actions Reward", "Ladder_Action_Reward", "ladderactions", g_esPlayer[iPlayer].g_iLadderActionsReward[iPos], sSet[iPos], 0, 999999);
									g_esPlayer[iPlayer].g_iLadyKillerReward[iPos] = iGetClampedValue(key, "LadyKillerReward", "Lady Killer Reward", "Lady_Killer_Reward", "ladykiller", g_esPlayer[iPlayer].g_iLadyKillerReward[iPos], sSet[iPos], 0, 1);
									g_esPlayer[iPlayer].g_iLifeLeechReward[iPos] = iGetClampedValue(key, "LifeLeechReward", "Life Leech Reward", "Life_Leech_Reward", "lifeleech", g_esPlayer[iPlayer].g_iLifeLeechReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
									g_esPlayer[iPlayer].g_iMeleeRangeReward[iPos] = iGetClampedValue(key, "MeleeRangeReward", "Melee Range Reward", "Melee_Range_Reward", "meleerange", g_esPlayer[iPlayer].g_iMeleeRangeReward[iPos], sSet[iPos], 0, 999999);
									g_esPlayer[iPlayer].g_iParticleEffectVisual[iPos] = iGetClampedValue(key, "ParticleEffectVisual", "Particle Effect Visual", "Particle_Effect_Visual", "particle", g_esPlayer[iPlayer].g_iParticleEffectVisual[iPos], sSet[iPos], 0, 15);
									g_esPlayer[iPlayer].g_iPrefsNotify[iPos] = iGetClampedValue(key, "PrefsNotify", "Prefs Notify", "Prefs_Notify", "pnotify", g_esPlayer[iPlayer].g_iPrefsNotify[iPos], sSet[iPos], 0, 1);
									g_esPlayer[iPlayer].g_iRespawnLoadoutReward[iPos] = iGetClampedValue(key, "RespawnLoadoutReward", "Respawn Loadout Reward", "Respawn_Loadout_Reward", "resloadout", g_esPlayer[iPlayer].g_iRespawnLoadoutReward[iPos], sSet[iPos], 0, 1);
									g_esPlayer[iPlayer].g_iReviveHealthReward[iPos] = iGetClampedValue(key, "ReviveHealthReward", "Revive Health Reward", "Revive_Health_Reward", "revivehp", g_esPlayer[iPlayer].g_iReviveHealthReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
									g_esPlayer[iPlayer].g_iShareRewards[iPos] = iGetClampedValue(key, "ShareRewards", "Share Rewards", "Share_Rewards", "share", g_esPlayer[iPlayer].g_iShareRewards[iPos], sSet[iPos], 0, 3);
									g_esPlayer[iPlayer].g_iShovePenaltyReward[iPos] = iGetClampedValue(key, "ShovePenaltyReward", "Shove Penalty Reward", "Shove_Penalty_Reward", "shovepenalty", g_esPlayer[iPlayer].g_iShovePenaltyReward[iPos], sSet[iPos], 0, 1);
									g_esPlayer[iPlayer].g_iSledgehammerRoundsReward[iPos] = iGetClampedValue(key, "SledgehammerRoundsReward", "Sledgehammer Rounds Reward", "Sledgehammer_Rounds_Reward", "sledgehammer", g_esPlayer[iPlayer].g_iSledgehammerRoundsReward[iPos], sSet[iPos], 0, 1);
									g_esPlayer[iPlayer].g_iSpecialAmmoReward[iPos] = iGetClampedValue(key, "SpecialAmmoReward", "Special Ammo Reward", "Special_Ammo_Reward", "specialammo", g_esPlayer[iPlayer].g_iSpecialAmmoReward[iPos], sSet[iPos], 0, 3);
									g_esPlayer[iPlayer].g_iStackRewards[iPos] = iGetClampedValue(key, "StackRewards", "Stack Rewards", "Stack_Rewards", "stack", g_esPlayer[iPlayer].g_iStackRewards[iPos], sSet[iPos], 0, 2147483647);
									g_esPlayer[iPlayer].g_iThornsReward[iPos] = iGetClampedValue(key, "ThornsReward", "Thorns Reward", "Thorns_Reward", "thorns", g_esPlayer[iPlayer].g_iThornsReward[iPos], sSet[iPos], 0, 1);
									g_esPlayer[iPlayer].g_iUsefulRewards[iPos] = iGetClampedValue(key, "UsefulRewards", "Useful Rewards", "Useful_Rewards", "useful", g_esPlayer[iPlayer].g_iUsefulRewards[iPos], sSet[iPos], 0, 15);

									vGetConfigColors(sValue, sizeof sValue, sSet[iPos], ';');
									vGetStringValue(key, "BodyColorVisual", "Body Color Visual", "Body_Color_Visual", "bodycolor", iPos, g_esPlayer[iPlayer].g_sBodyColorVisual, sizeof esPlayer::g_sBodyColorVisual, g_esPlayer[iPlayer].g_sBodyColorVisual2, sizeof esPlayer::g_sBodyColorVisual2, g_esPlayer[iPlayer].g_sBodyColorVisual3, sizeof esPlayer::g_sBodyColorVisual3, g_esPlayer[iPlayer].g_sBodyColorVisual4, sizeof esPlayer::g_sBodyColorVisual4, sValue);
									vGetStringValue(key, "FallVoicelineReward", "Fall Voiceline Reward", "Fall_Voiceline_Reward", "fallvoice", iPos, g_esPlayer[iPlayer].g_sFallVoicelineReward, sizeof esPlayer::g_sFallVoicelineReward, g_esPlayer[iPlayer].g_sFallVoicelineReward2, sizeof esPlayer::g_sFallVoicelineReward2, g_esPlayer[iPlayer].g_sFallVoicelineReward3, sizeof esPlayer::g_sFallVoicelineReward3, g_esPlayer[iPlayer].g_sFallVoicelineReward4, sizeof esPlayer::g_sFallVoicelineReward4, sSet[iPos]);
									vGetStringValue(key, "GlowColorVisual", "Glow Color Visual", "Glow_Color_Visual", "glowcolor", iPos, g_esPlayer[iPlayer].g_sOutlineColorVisual, sizeof esPlayer::g_sOutlineColorVisual, g_esPlayer[iPlayer].g_sOutlineColorVisual2, sizeof esPlayer::g_sOutlineColorVisual2, g_esPlayer[iPlayer].g_sOutlineColorVisual3, sizeof esPlayer::g_sOutlineColorVisual3, g_esPlayer[iPlayer].g_sOutlineColorVisual4, sizeof esPlayer::g_sOutlineColorVisual4, sValue);
									vGetStringValue(key, "ItemReward", "Item Reward", "Item_Reward", "item", iPos, g_esPlayer[iPlayer].g_sItemReward, sizeof esPlayer::g_sItemReward, g_esPlayer[iPlayer].g_sItemReward2, sizeof esPlayer::g_sItemReward2, g_esPlayer[iPlayer].g_sItemReward3, sizeof esPlayer::g_sItemReward3, g_esPlayer[iPlayer].g_sItemReward4, sizeof esPlayer::g_sItemReward4, sSet[iPos]);
									vGetStringValue(key, "LightColorVisual", "Light Color Visual", "Light_Color_Visual", "lightcolor", iPos, g_esPlayer[iPlayer].g_sLightColorVisual, sizeof esPlayer::g_sLightColorVisual, g_esPlayer[iPlayer].g_sLightColorVisual2, sizeof esPlayer::g_sLightColorVisual2, g_esPlayer[iPlayer].g_sLightColorVisual3, sizeof esPlayer::g_sLightColorVisual3, g_esPlayer[iPlayer].g_sLightColorVisual4, sizeof esPlayer::g_sLightColorVisual4, sValue);
									vGetStringValue(key, "LoopingVoicelineVisual", "Looping Voiceline Visual", "Looping_Voiceline_Visual", "loopvoice", iPos, g_esPlayer[iPlayer].g_sLoopingVoicelineVisual, sizeof esPlayer::g_sLoopingVoicelineVisual, g_esPlayer[iPlayer].g_sLoopingVoicelineVisual2, sizeof esPlayer::g_sLoopingVoicelineVisual2, g_esPlayer[iPlayer].g_sLoopingVoicelineVisual3, sizeof esPlayer::g_sLoopingVoicelineVisual3, g_esPlayer[iPlayer].g_sLoopingVoicelineVisual4, sizeof esPlayer::g_sLoopingVoicelineVisual4, sSet[iPos]);
									vGetStringValue(key, "ScreenColorVisual", "Screen Color Visual", "Screen_Color_Visual", "screencolor", iPos, g_esPlayer[iPlayer].g_sScreenColorVisual, sizeof esPlayer::g_sScreenColorVisual, g_esPlayer[iPlayer].g_sScreenColorVisual2, sizeof esPlayer::g_sScreenColorVisual2, g_esPlayer[iPlayer].g_sScreenColorVisual3, sizeof esPlayer::g_sScreenColorVisual3, g_esPlayer[iPlayer].g_sScreenColorVisual4, sizeof esPlayer::g_sScreenColorVisual4, sValue);
								}

								g_esPlayer[iPlayer].g_iStackLimits[iPos] = iGetClampedValue(key, "StackLimits", "Stack Limits", "Stack_Limits", "limits", g_esPlayer[iPlayer].g_iStackLimits[iPos], sSet[iPos], 0, 999999);
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_GLOW, false))
						{
							if (StrEqual(key, "GlowColor", false) || StrEqual(key, "Glow Color", false) || StrEqual(key, "Glow_Color", false))
							{
								char sValue[64], sSet[3][4];
								vGetConfigColors(sValue, sizeof sValue, value);
								strcopy(g_esPlayer[iPlayer].g_sGlowColor, sizeof esPlayer::g_sGlowColor, value);
								ReplaceString(sValue, sizeof sValue, " ", "");
								ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
								for (int iPos = 0; iPos < sizeof esPlayer::g_iGlowColor; iPos++)
								{
									g_esPlayer[iPlayer].g_iGlowColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
								}
							}
							else if (StrEqual(key, "GlowRange", false) || StrEqual(key, "Glow Range", false) || StrEqual(key, "Glow_Range", false))
							{
								char sValue[14], sRange[2][7];
								strcopy(sValue, sizeof sValue, value);
								ReplaceString(sValue, sizeof sValue, " ", "");
								ExplodeString(sValue, "-", sRange, sizeof sRange, sizeof sRange[]);

								g_esPlayer[iPlayer].g_iGlowMinRange = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, 999999) : g_esPlayer[iPlayer].g_iGlowMinRange;
								g_esPlayer[iPlayer].g_iGlowMaxRange = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, 999999) : g_esPlayer[iPlayer].g_iGlowMaxRange;
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_BOSS, false))
						{
							char sValue[44], sSet[4][11];
							strcopy(sValue, sizeof sValue, value);
							ReplaceString(sValue, sizeof sValue, " ", "");
							ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
							for (int iPos = 0; iPos < sizeof esPlayer::g_iBossHealth; iPos++)
							{
								g_esPlayer[iPlayer].g_iBossHealth[iPos] = iGetClampedValue(key, "BossHealthStages", "Boss Health Stages", "Boss_Health_Stages", "bosshpstages", g_esPlayer[iPlayer].g_iBossHealth[iPos], sSet[iPos], 1, MT_MAXHEALTH);
								g_esPlayer[iPlayer].g_iBossType[iPos] = iGetClampedValue(key, "BossTypes", "Boss Types", "Boss_Types", "bosstypes", g_esPlayer[iPlayer].g_iBossType[iPos], sSet[iPos], 1, MT_MAXTYPES);
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_COMBO, false))
						{
							if (StrEqual(key, "ComboTypeChance", false) || StrEqual(key, "Combo Type Chance", false) || StrEqual(key, "Combo_Type_Chance", false) || StrEqual(key, "typechance", false))
							{
								char sValue[42], sSet[7][6];
								strcopy(sValue, sizeof sValue, value);
								ReplaceString(sValue, sizeof sValue, " ", "");
								ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
								for (int iPos = 0; iPos < sizeof esPlayer::g_flComboTypeChance; iPos++)
								{
									g_esPlayer[iPlayer].g_flComboTypeChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esPlayer[iPlayer].g_flComboTypeChance[iPos];
								}
							}
							else
							{
								char sValue[140], sSet[10][14];
								strcopy(sValue, sizeof sValue, value);
								ReplaceString(sValue, sizeof sValue, " ", "");
								ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
								for (int iPos = 0; iPos < sizeof esPlayer::g_flComboChance; iPos++)
								{
									if (StrEqual(key, "ComboRadius", false) || StrEqual(key, "Combo Radius", false) || StrEqual(key, "Combo_Radius", false) || StrEqual(key, "radius", false))
									{
										char sRange[2][7], sSubset[14];
										strcopy(sSubset, sizeof sSubset, sSet[iPos]);
										ReplaceString(sSubset, sizeof sSubset, " ", "");
										ExplodeString(sSubset, ";", sRange, sizeof sRange, sizeof sRange[]);

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
								char sValue[50], sSet[10][5];
								strcopy(sValue, sizeof sValue, value);
								ReplaceString(sValue, sizeof sValue, " ", "");
								ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
								for (int iPos = 0; iPos < sizeof esPlayer::g_iTransformType; iPos++)
								{
									g_esPlayer[iPlayer].g_iTransformType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXTYPES) : g_esPlayer[iPlayer].g_iTransformType[iPos];
								}
							}
						}
						else if (StrEqual(g_esGeneral.g_sCurrentSubSection, MT_CONFIG_SECTION_PROPS, false))
						{
							if (StrEqual(key, "PropsChance", false) || StrEqual(key, "Props Chance", false) || StrEqual(key, "Props_Chance", false) || StrEqual(key, "chance", false))
							{
								char sValue[54], sSet[9][6];
								strcopy(sValue, sizeof sValue, value);
								ReplaceString(sValue, sizeof sValue, " ", "");
								ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
								for (int iPos = 0; iPos < sizeof esPlayer::g_flPropsChance; iPos++)
								{
									g_esPlayer[iPlayer].g_flPropsChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esPlayer[iPlayer].g_flPropsChance[iPos];
								}
							}
							else
							{
								char sValue[64], sSet[4][4];
								vGetConfigColors(sValue, sizeof sValue, value);
								vSaveConfigColors(key, "OxygenTankColor", "Oxygen Tank Color", "Oxygen_Tank_Color", "oxygen", g_esPlayer[iPlayer].g_sOzTankColor, sizeof esPlayer::g_sOzTankColor, value);
								vSaveConfigColors(key, "FlameColor", "Flame Color", "Flame_Color", "flame", g_esPlayer[iPlayer].g_sFlameColor, sizeof esPlayer::g_sFlameColor, value);
								vSaveConfigColors(key, "RockColor", "Rock Color", "Rock_Color", "rock", g_esPlayer[iPlayer].g_sRockColor, sizeof esPlayer::g_sRockColor, value);
								vSaveConfigColors(key, "TireColor", "Tire Color", "Tire_Color", "tire", g_esPlayer[iPlayer].g_sTireColor, sizeof esPlayer::g_sTireColor, value);
								vSaveConfigColors(key, "PropaneTankColor", "Propane Tank Color", "Propane_Tank_Color", "propane", g_esPlayer[iPlayer].g_sPropTankColor, sizeof esPlayer::g_sPropTankColor, value);
								vSaveConfigColors(key, "FlashlightColor", "Flashlight Color", "Flashlight_Color", "flashlight", g_esPlayer[iPlayer].g_sFlashlightColor, sizeof esPlayer::g_sFlashlightColor, value);
								ReplaceString(sValue, sizeof sValue, " ", "");
								ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
								for (int iPos = 0; iPos < sizeof esPlayer::g_iLightColor; iPos++)
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
						else if (!strncmp(g_esGeneral.g_sCurrentSubSection, "Tank", 4, false) || g_esGeneral.g_sCurrentSubSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sCurrentSubSection[0]) || StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1 || FindCharInString(g_esGeneral.g_sCurrentSubSection, ',') != -1 || FindCharInString(g_esGeneral.g_sCurrentSubSection, '-') != -1)
						{
							int iStartPos = 0, iIndex = 0, iRealType = 0;
							if (!strncmp(g_esGeneral.g_sCurrentSubSection, "Tank", 4, false) || g_esGeneral.g_sCurrentSubSection[0] == '#')
							{
								iStartPos = iGetConfigSectionNumber(g_esGeneral.g_sCurrentSubSection, sizeof esGeneral::g_sCurrentSubSection), iIndex = StringToInt(g_esGeneral.g_sCurrentSubSection[iStartPos]);
								vReadAdminSettings(iPlayer, iIndex, key, value);
							}
							else if (IsCharNumeric(g_esGeneral.g_sCurrentSubSection[0]) || StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1 || FindCharInString(g_esGeneral.g_sCurrentSubSection, ',') != -1 || FindCharInString(g_esGeneral.g_sCurrentSubSection, '-') != -1)
							{
								if (IsCharNumeric(g_esGeneral.g_sCurrentSubSection[0]) && (FindCharInString(g_esGeneral.g_sCurrentSubSection, ',') == -1 || FindCharInString(g_esGeneral.g_sCurrentSubSection, '-') == -1))
								{
									iIndex = StringToInt(g_esGeneral.g_sCurrentSubSection);
									vReadAdminSettings(iPlayer, iIndex, key, value);
								}
								else if (StrContains(g_esGeneral.g_sCurrentSubSection, "all", false) != -1 || FindCharInString(g_esGeneral.g_sCurrentSubSection, ',') != -1 || FindCharInString(g_esGeneral.g_sCurrentSubSection, '-') != -1)
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
		else if (!strncmp(g_esGeneral.g_sCurrentSection, "Tank", 4, false) || g_esGeneral.g_sCurrentSection[0] == '#' || IsCharNumeric(g_esGeneral.g_sCurrentSection[0]) || StrContains(g_esGeneral.g_sCurrentSection, "all", false) != -1 || FindCharInString(g_esGeneral.g_sCurrentSection, ',') != -1 || FindCharInString(g_esGeneral.g_sCurrentSection, '-') != -1)
		{
			g_esGeneral.g_csState = ConfigState_Type;
		}
		else if (!strncmp(g_esGeneral.g_sCurrentSection, "STEAM_", 6, false) || !strncmp("0:", g_esGeneral.g_sCurrentSection, 2) || !strncmp("1:", g_esGeneral.g_sCurrentSection, 2) || (!strncmp(g_esGeneral.g_sCurrentSection, "[U:", 3) && g_esGeneral.g_sCurrentSection[strlen(g_esGeneral.g_sCurrentSection) - 1] == ']'))
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