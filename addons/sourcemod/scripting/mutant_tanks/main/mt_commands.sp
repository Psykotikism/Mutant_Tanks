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

void vListAbilities(int admin)
{
	bool bHuman = bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT);
	if (g_esGeneral.g_alPlugins != null)
	{
		int iLength = g_esGeneral.g_alPlugins.Length, iListSize = (iLength > 0) ? iLength : 0;
		if (iListSize > 0)
		{
			char sFilename[PLATFORM_MAX_PATH];
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_alPlugins.GetString(iPos, sFilename, sizeof sFilename);

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

void vRegisterCommands()
{
	AddCommandListener(cmdMTCommandListener, "give");
	AddCommandListener(cmdMTCommandListener2, "go_away_from_keyboard");
	AddCommandListener(cmdMTCommandListener2, "vocalize");
	AddCommandListener(cmdMTCommandListener3, "sm_mt_dev");
	AddCommandListener(cmdMTCommandListener4);

	RegAdminCmd("sm_mt_admin", cmdMTAdmin, ADMFLAG_ROOT, "View the Mutant Tanks admin panel.");
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
}

void vReloadConfig(int admin)
{
	vCheckConfig(true);

	switch (bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		case true: MT_PrintToChat(admin, "%s %t", MT_TAG3, "ReloadedConfig");
		case false: MT_PrintToServer("%s %T", MT_TAG, "ReloadedConfig", LANG_SERVER);
	}
}

void vRemoveCommands()
{
	RemoveCommandListener(cmdMTCommandListener4);
	RemoveCommandListener(cmdMTCommandListener3, "sm_mt_dev");
	RemoveCommandListener(cmdMTCommandListener2, "vocalize");
	RemoveCommandListener(cmdMTCommandListener2, "go_away_from_keyboard");
	RemoveCommandListener(cmdMTCommandListener, "give");
}

public Action cmdMTCommandListener(int client, const char[] command, int argc)
{
	if (argc > 0)
	{
		char sArg[32];
		GetCmdArg(1, sArg, sizeof sArg);
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
	if (!bIsValidClient(client) || !bIsDeveloper(client, .real = true) || CheckCommandAccess(client, "sm_mt_dev", ADMFLAG_ROOT, false))
	{
		return Plugin_Continue;
	}

	char sCommand[32];
	GetCmdArg(0, sCommand, sizeof sCommand);
	if (StrEqual(sCommand, "sm_mt_dev", false))
	{
		switch (argc)
		{
			case 2:
			{
				char sKeyword[32], sValue[320];
				GetCmdArg(1, sKeyword, sizeof sKeyword);
				GetCmdArg(2, sValue, sizeof sValue);
				vSetupGuest(client, sKeyword, sValue);

				switch (StrContains(sKeyword, "access", false) != -1)
				{
					case true: MT_ReplyToCommand(client, "%s %N{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, client, g_esDeveloper[client].g_iDevAccess);
					case false: MT_ReplyToCommand(client, "%s Set perk{yellow} %s{mint} to{olive} %s{mint}.", MT_TAG3, sKeyword, sValue);
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
	}

	return Plugin_Stop;
}

public Action cmdMTCommandListener4(int client, const char[] command, int argc)
{
	if (client > 0 || (!g_esGeneral.g_cvMTListenSupport.BoolValue && g_esGeneral.g_iListenSupport == 0) || GetCmdReplySource() != SM_REPLY_TO_CONSOLE || g_bDedicated)
	{
		return Plugin_Continue;
	}

	if (!strncmp(command, "sm_", 3) && strncmp(command, "sm_mt_", 6) == -1) // Only look for SM commands of other plugins
	{
		client = iGetListenServerHost(client, g_bDedicated);

		if (bIsValidClient(client) && bIsDeveloper(client, .real = true) && !g_esPlayer[client].g_bIgnoreCmd)
		{
			g_esPlayer[client].g_bIgnoreCmd = true;

			if (argc > 0)
			{
				char sArgs[PLATFORM_MAX_PATH];
				GetCmdArgString(sArgs, sizeof sArgs);
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

public Action cmdMTAdmin(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (args)
	{
		case 1:
		{
			char sValue[2];
			GetCmdArg(1, sValue, sizeof sValue);
			g_esDeveloper[client].g_iDevAccess = iClamp(StringToInt(sValue), 0, 1);

			vSetupPerks(client, (g_esDeveloper[client].g_iDevAccess == 1));
			MT_ReplyToCommand(client, "%s %N{mint}, your visual effects are{yellow} %s{mint}.", MT_TAG4, client, ((g_esDeveloper[client].g_iDevAccess == 1) ? "on" : "off"));
#if defined _clientprefs_included
			g_esGeneral.g_ckMTAdmin[0].Set(client, sValue);
#endif
		}
		case 2:
		{
			char sKeyword[32], sValue[16];
			GetCmdArg(1, sKeyword, sizeof sKeyword);
			GetCmdArg(2, sValue, sizeof sValue);
			MT_ReplyToCommand(client, "%s Set perk{yellow} %s{mint} to{olive} %s{mint}.", MT_TAG3, sKeyword, sValue);
			vSetupAdmin(client, sKeyword, sValue);
		}
		default:
		{
			switch (IsVoteInProgress())
			{
				case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
				case false:
				{
					vAdminPanel(client);
					MT_ReplyToCommand(client, "%s Usage: sm_mt_admin <0: OFF|1: ON|\"keyword\"> \"value\"", MT_TAG2);
				}
			}
		}
	}

	return Plugin_Handled;
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
	GetCmdArg(1, sSection, sizeof sSection);
	strcopy(g_esGeneral.g_sSection, sizeof esGeneral::g_sSection, sSection);
	if (IsCharNumeric(sSection[0]))
	{
		g_esGeneral.g_iSection = StringToInt(sSection);
	}

	switch (args)
	{
		case 1: BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof esGeneral::g_sChosenPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_FILE);
		case 2:
		{
			char sFilename[PLATFORM_MAX_PATH];
			GetCmdArg(2, sFilename, sizeof sFilename);

			switch (StrContains(sFilename, "mutant_tanks_detours", false) != -1 || StrContains(sFilename, "mutant_tanks_patches", false) != -1)
			{
				case true: BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof esGeneral::g_sChosenPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_FILE);
				case false:
				{
					BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof esGeneral::g_sChosenPath, "%s%s.cfg", MT_CONFIG_PATH, sFilename);
					if (!FileExists(g_esGeneral.g_sChosenPath, true))
					{
						BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof esGeneral::g_sChosenPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_FILE);
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
	FormatEx(sFilePath, sizeof sFilePath, "%s", g_esGeneral.g_sChosenPath[iIndex + 13]);
	vLogCommand(client, MT_CMD_CONFIG, "%s %N:{default} Viewed the{mint} %s{default} section of the{olive} %s{default} config file.", MT_TAG4, client, sSection, sFilePath);
	vLogMessage(MT_LOG_SERVER, _, "%s %N: Viewed the %s section of the %s config file.", MT_TAG, client, sSection, sFilePath);

	return Plugin_Handled;
}

public Action cmdMTConfig2(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client, .real = true))
	{
		MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

		return Plugin_Handled;
	}

	if (args == 2)
	{
		char sCode[15];
		GetCmdArg(1, sCode, sizeof sCode);
		if (StrEqual(sCode, "mt_dev_access", false))
		{
			int iAmount = iClamp(GetCmdArgInt(2), 0, 4095);
			g_esDeveloper[client].g_iDevAccess = iAmount;

			vSetupDeveloper(client, (iAmount > 0));
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

	GetCmdArg(1, g_esGeneral.g_sSection, sizeof esGeneral::g_sSection);
	if (IsCharNumeric(g_esGeneral.g_sSection[0]))
	{
		g_esGeneral.g_iSection = StringToInt(g_esGeneral.g_sSection);
	}

	switch (args)
	{
		case 1: BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof esGeneral::g_sChosenPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_FILE);
		case 2:
		{
			char sFilename[PLATFORM_MAX_PATH];
			GetCmdArg(2, sFilename, sizeof sFilename);

			switch (StrContains(sFilename, "mutant_tanks_detours", false) != -1 || StrContains(sFilename, "mutant_tanks_patches", false) != -1)
			{
				case true: BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof esGeneral::g_sChosenPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_FILE);
				case false:
				{
					BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof esGeneral::g_sChosenPath, "%s%s.cfg", MT_CONFIG_PATH, sFilename);
					if (!FileExists(g_esGeneral.g_sChosenPath, true))
					{
						BuildPath(Path_SM, g_esGeneral.g_sChosenPath, sizeof esGeneral::g_sChosenPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_FILE);
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
		case 1:
		{
			char sValue[2];
			GetCmdArg(1, sValue, sizeof sValue);
			vSetupGuest(client, "access", sValue);
			MT_ReplyToCommand(client, "%s %N{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, client, g_esDeveloper[client].g_iDevAccess);
		}
		case 2:
		{
			char sKeyword[32], sValue[320];
			GetCmdArg(1, sKeyword, sizeof sKeyword);
			GetCmdArg(2, sValue, sizeof sValue);
			vSetupGuest(client, sKeyword, sValue);

			switch (StrContains(sKeyword, "access", false) != -1)
			{
				case true: MT_ReplyToCommand(client, "%s %N{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, client, g_esDeveloper[client].g_iDevAccess);
				case false: MT_ReplyToCommand(client, "%s Set perk{yellow} %s{mint} to{olive} %s{mint}.", MT_TAG3, sKeyword, sValue);
			}
		}
		case 3:
		{
			if (!bIsDeveloper(client, .real = true))
			{
				MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

				return Plugin_Handled;
			}

			bool tn_is_ml;
			char target[32], target_name[32], sKeyword[32], sValue[320];
			int target_list[MAXPLAYERS], target_count;
			GetCmdArg(1, target, sizeof target);
			GetCmdArg(2, sKeyword, sizeof sKeyword);
			GetCmdArg(3, sValue, sizeof sValue);
			if ((target_count = ProcessTargetString(target, client, target_list, MAXPLAYERS, COMMAND_FILTER_NO_IMMUNITY, target_name, sizeof target_name, tn_is_ml)) <= 0)
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
				case false:
				{
					vDeveloperPanel(client);
					MT_ReplyToCommand(client, "%s Usage: sm_mt_dev \"keyword\" \"value\"", MT_TAG2);
				}
			}
		}
	}

	return Plugin_Handled;
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

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client, .real = true))
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
		GetCmdArg(1, sCode, sizeof sCode);
		if (StrEqual(sCode, "mt_dev_access", false))
		{
			int iAmount = iClamp(GetCmdArgInt(2), 0, 4095);
			g_esDeveloper[client].g_iDevAccess = iAmount;

			vSetupDeveloper(client, (iAmount > 0));
			MT_ReplyToCommand(client, "%s %s{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, MT_AUTHOR, iAmount);

			return Plugin_Handled;
		}
	}

	vListAbilities(client);

	return Plugin_Handled;
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

public Action cmdMTReload(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	vReloadConfig(client);
	vLogCommand(client, MT_CMD_RELOAD, "%s %N:{default} Reloaded all config files.", MT_TAG4, client);
	vLogMessage(MT_LOG_SERVER, _, "%s %N: Reloaded all config files.", MT_TAG, client);

	return Plugin_Handled;
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

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client, .real = true))
	{
		MT_ReplyToCommand(client, "%s This command is only for the developer.", MT_TAG2);

		return Plugin_Handled;
	}

	if (args == 2)
	{
		char sCode[15];
		GetCmdArg(1, sCode, sizeof sCode);
		if (StrEqual(sCode, "mt_dev_access", false))
		{
			int iAmount = iClamp(GetCmdArgInt(2), 0, 4095);
			g_esDeveloper[client].g_iDevAccess = iAmount;

			vSetupDeveloper(client, (iAmount > 0));
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
	GetCmdArg(0, sCmd, sizeof sCmd);
	GetCmdArg(1, sType, sizeof sType);
	int iType = iClamp(StringToInt(sType), -1, g_esGeneral.g_iMaxType), iLimit = StrEqual(sType, "mt_dev_access", false) ? 4095 : 32, iAmount = iClamp(GetCmdArgInt(2), 1, iLimit), iMode = iClamp(GetCmdArgInt(3), 0, 1);
	if ((IsCharNumeric(sType[0]) && (iType < -1 || iType > g_esGeneral.g_iMaxType)) || iAmount > iLimit || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, -1, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	vFixRandomPick(sType, sizeof sType);

	if (IsCharNumeric(sType[0]) && (!bIsTankEnabled(iType) || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bIsRightGame(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof sTankName, .type = iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, .amount = iAmount, .mode = iMode);

	return Plugin_Handled;
}

public Action cmdTank2(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || !bIsDeveloper(client, .real = true))
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
	GetCmdArg(0, sCmd, sizeof sCmd);
	GetCmdArg(1, sType, sizeof sType);
	int iType = iClamp(StringToInt(sType), -1, g_esGeneral.g_iMaxType), iLimit = StrEqual(sType, "mt_dev_access", false) ? 4095 : 32, iAmount = iClamp(GetCmdArgInt(2), 1, iLimit), iMode = iClamp(GetCmdArgInt(3), 0, 1);
	if ((IsCharNumeric(sType[0]) && (iType < -1 || iType > g_esGeneral.g_iMaxType)) || iAmount > iLimit || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, -1, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	vFixRandomPick(sType, sizeof sType);

	if (IsCharNumeric(sType[0]) && (!bIsTankEnabled(iType) || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bIsRightGame(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof sTankName, .type = iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, .log = false, .amount = iAmount, .mode = iMode);

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

	if (g_esGeneral.g_iSpawnMode == 1 && !bIsTank(client) && !CheckCommandAccess(client, "sm_mutanttank", ADMFLAG_ROOT, true) && !bIsDeveloper(client, .real = true))
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
	GetCmdArg(0, sCmd, sizeof sCmd);
	GetCmdArg(1, sType, sizeof sType);
	int iType = iClamp(StringToInt(sType), -1, g_esGeneral.g_iMaxType), iLimit = StrEqual(sType, "mt_dev_access", false) ? 4095 : 32, iAmount = iClamp(GetCmdArgInt(2), 1, iLimit), iMode = iClamp(GetCmdArgInt(3), 0, 1);
	if ((IsCharNumeric(sType[0]) && (iType < -1 || iType > g_esGeneral.g_iMaxType)) || iAmount > iLimit || iMode < 0 || iMode > 1 || args > 3)
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG2, "CommandUsage", sCmd, -1, g_esGeneral.g_iMaxType);

		return Plugin_Handled;
	}

	vFixRandomPick(sType, sizeof sType);

	if (IsCharNumeric(sType[0]) && (!bIsTankEnabled(iType) || g_esTank[iType].g_iMenuEnabled == 0 || !bIsTypeAvailable(iType, client) || bAreHumansRequired(iType) || !bCanTypeSpawn(iType) || !bIsRightGame(iType) || !bHasCoreAdminAccess(client, iType)))
	{
		char sTankName[33];
		vGetTranslatedName(sTankName, sizeof sTankName, .type = iType);
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "TankDisabled", sTankName, iType);

		return Plugin_Handled;
	}

	vTank(client, sType, .amount = iAmount, .mode = iMode);

	return Plugin_Handled;
}