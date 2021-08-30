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

void vAdminPanel(int admin)
{
	char sDisplay[PLATFORM_MAX_PATH];
	FormatEx(sDisplay, sizeof sDisplay, "%s Admin Panel v%s", MT_CONFIG_SECTION_MAIN, MT_VERSION);

	Panel pAdminPanel = new Panel();
	pAdminPanel.SetTitle(sDisplay);
	pAdminPanel.DrawItem("", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);

	FormatEx(sDisplay, sizeof sDisplay, "Flashlight Color (\"light\"/\"flash\"): %s", g_esDeveloper[admin].g_sDevFlashlight);
	pAdminPanel.DrawText(sDisplay);

	if (g_bSecondGame)
	{
		FormatEx(sDisplay, sizeof sDisplay, "Glow Outline (\"glow\"/\"outline\"): %s", g_esDeveloper[admin].g_sDevGlowOutline);
		pAdminPanel.DrawText(sDisplay);
	}

	FormatEx(sDisplay, sizeof sDisplay, "Particle Effect(s) (\"effect\"/\"particle\"): %i", g_esDeveloper[admin].g_iDevParticle);
	pAdminPanel.DrawText(sDisplay);

	FormatEx(sDisplay, sizeof sDisplay, "Skin Color (\"skin\"/\"color\"): %s", g_esDeveloper[admin].g_sDevSkinColor);
	pAdminPanel.DrawText(sDisplay);

	pAdminPanel.DrawItem("", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
	pAdminPanel.CurrentKey = 10;
	pAdminPanel.DrawItem("Exit", ITEMDRAW_CONTROL);
	pAdminPanel.Send(admin, iAdminMenuHandler, MENU_TIME_FOREVER);

	delete pAdminPanel;
}

public int iAdminMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	// Do nothing...
}

void vConfigMenu(int admin, int item = 0)
{
	Menu mConfigMenu = new Menu(iConfigMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mConfigMenu.SetTitle("Config Parser Menu");

	int iCount = 0;

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
				smcConfig.GetErrorString(smcError, sSmcError, sizeof sSmcError);
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

		int iLength = g_esGeneral.g_alSections.Length, iListSize = (iLength > 0) ? iLength : 0;
		if (iListSize > 0)
		{
			char sSection[PLATFORM_MAX_PATH], sDisplay[PLATFORM_MAX_PATH];
			int iStartPos = 0, iIndex = 0;
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_alSections.GetString(iPos, sSection, sizeof sSection);
				if (sSection[0] != '\0')
				{
					switch (!strncmp(sSection, "Plugin", 6, false) || !strncmp(sSection, MT_CONFIG_SECTION_SETTINGS4, strlen(MT_CONFIG_SECTION_SETTINGS4), false) || !strncmp(sSection, "STEAM_", 6, false) || (!strncmp(sSection, "[U:", 3) && sSection[strlen(sSection) - 1] == ']') || StrContains(sSection, "all", false) != -1 || FindCharInString(sSection, ',') != -1 || FindCharInString(sSection, '-') != -1)
					{
						case true: mConfigMenu.AddItem(sSection, sSection);
						case false:
						{
							iStartPos = iGetConfigSectionNumber(sSection, sizeof sSection), iIndex = StringToInt(sSection[iStartPos]);
							FormatEx(sDisplay, sizeof sDisplay, "%s (%s)", g_esTank[iIndex].g_sTankName, sSection);
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
			menu.GetItem(param2, sInfo, sizeof sInfo);

			switch (!strncmp(sInfo, "Plugin", 6, false) || !strncmp(sInfo, MT_CONFIG_SECTION_SETTINGS4, strlen(MT_CONFIG_SECTION_SETTINGS4), false) || !strncmp(sInfo, "STEAM_", 6, false) || (!strncmp(sInfo, "[U:", 3) && sInfo[strlen(sInfo) - 1] == ']') || StrContains(sInfo, "all", false) != -1 || FindCharInString(sInfo, ',') != -1 || FindCharInString(sInfo, '-') != -1)
			{
				case true: g_esGeneral.g_sSection = sInfo;
				case false:
				{
					int iStartPos = iGetConfigSectionNumber(sInfo, sizeof sInfo);
					strcopy(g_esGeneral.g_sSection, sizeof esGeneral::g_sSection, sInfo[iStartPos]);
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
			FormatEx(sFilePath, sizeof sFilePath, "%s", g_esGeneral.g_sChosenPath[iIndex + 13]);
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
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "MTConfigMenu", param1);
			pConfig.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH], sInfo[33];
			menu.GetItem(param2, sInfo, sizeof sInfo);
			if (StrEqual(sInfo, MT_CONFIG_SECTION_SETTINGS2, false))
			{
				FormatEx(sMenuOption, sizeof sMenuOption, "%T", "MTSettingsItem", param1);

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

void vDeveloperPanel(int developer, int level = 0)
{
	g_esDeveloper[developer].g_iDevPanelLevel = level;

	char sDisplay[PLATFORM_MAX_PATH];
	FormatEx(sDisplay, sizeof sDisplay, "%s Developer Panel v%s", MT_CONFIG_SECTION_MAIN, MT_VERSION);
	float flValue;

	Panel pDevPanel = new Panel();
	pDevPanel.SetTitle(sDisplay);
	pDevPanel.DrawItem("", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);

	switch (level)
	{
		case 0:
		{
			FormatEx(sDisplay, sizeof sDisplay, "Access Level: %i", g_esDeveloper[developer].g_iDevAccess);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Action Duration: %.2f second(s)", g_esDeveloper[developer].g_flDevActionDuration);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Ammo Regen: %i Bullet/s", g_esDeveloper[developer].g_iDevAmmoRegen);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevAttackBoost;
			FormatEx(sDisplay, sizeof sDisplay, "Attack Boost: +%.2f%% (%.2f)", ((flValue * 100.0) - 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevDamageBoost;
			FormatEx(sDisplay, sizeof sDisplay, "Damage Boost: +%.2f%% (%.2f)", ((flValue * 100.0) - 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevDamageResistance;
			FormatEx(sDisplay, sizeof sDisplay, "Damage Resistance: %.2f%% (%.2f)", ((flValue * 100.0) - 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Fall Voiceline: %s", g_esDeveloper[developer].g_sDevFallVoiceline);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Flashlight Color: %s", g_esDeveloper[developer].g_sDevFlashlight);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof sDisplay, "Glow Outline: %s", g_esDeveloper[developer].g_sDevGlowOutline);
				pDevPanel.DrawText(sDisplay);
			}

			flValue = g_esDeveloper[developer].g_flDevHealPercent;
			FormatEx(sDisplay, sizeof sDisplay, "Heal Percent: %.2f%% (%.2f)", flValue, (flValue / 100.0));
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Health Regen: %i HP/s", g_esDeveloper[developer].g_iDevHealthRegen);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Infinite Ammo Slots: %i (0: OFF, 31: ALL)", g_esDeveloper[developer].g_iDevInfiniteAmmo);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Jump Height: %.2f HMU", g_esDeveloper[developer].g_flDevJumpHeight);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof sDisplay, "Life Leech: %i HP/Hit", g_esDeveloper[developer].g_iDevLifeLeech);
				pDevPanel.DrawText(sDisplay);
			}
		}
		case 1:
		{
			if (!g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof sDisplay, "Life Leech: %i HP/Hit", g_esDeveloper[developer].g_iDevLifeLeech);
				pDevPanel.DrawText(sDisplay);
			}

			FormatEx(sDisplay, sizeof sDisplay, "Loadout: %s", g_esDeveloper[developer].g_sDevLoadout);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof sDisplay, "Melee Range: %i HMU, Punch Resistance: %.2f", g_esDeveloper[developer].g_iDevMeleeRange, g_esDeveloper[developer].g_flDevPunchResistance);
				pDevPanel.DrawText(sDisplay);
			}

			FormatEx(sDisplay, sizeof sDisplay, "Particle Effect(s): %i", g_esDeveloper[developer].g_iDevParticle);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Revive Health: %i HP", g_esDeveloper[developer].g_iDevReviveHealth);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Reward Duration: %.2f second(s)", g_esDeveloper[developer].g_flDevRewardDuration);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Reward Types: %i", g_esDeveloper[developer].g_iDevRewardTypes);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevShoveDamage;
			FormatEx(sDisplay, sizeof sDisplay, "Shove Damage: %.2f%% (%.2f)", (flValue * 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			flValue = g_esDeveloper[developer].g_flDevShoveRate;
			FormatEx(sDisplay, sizeof sDisplay, "Shove Rate: %.2f%% (%.2f)", (flValue * 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			FormatEx(sDisplay, sizeof sDisplay, "Skin Color: %s", g_esDeveloper[developer].g_sDevSkinColor);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof sDisplay, "Special Ammo Type(s): %i (1: Incendiary ammo, 2: Explosive ammo, 3: Random)", g_esDeveloper[developer].g_iDevSpecialAmmo);
				pDevPanel.DrawText(sDisplay);
			}

			flValue = g_esDeveloper[developer].g_flDevSpeedBoost;
			FormatEx(sDisplay, sizeof sDisplay, "Speed Boost: +%.2f%% (%.2f)", ((flValue * 100.0) - 100.0), flValue);
			pDevPanel.DrawText(sDisplay);

			if (g_bSecondGame)
			{
				FormatEx(sDisplay, sizeof sDisplay, "Weapon Skin: %i (Max: %i)", g_esDeveloper[developer].g_iDevWeaponSkin, iGetMaxWeaponSkins(developer));
				pDevPanel.DrawText(sDisplay);
			}
		}
	}

	pDevPanel.DrawItem("", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
	pDevPanel.CurrentKey = 8;
	pDevPanel.DrawItem("Prev Page", ITEMDRAW_CONTROL);
	pDevPanel.CurrentKey = 9;
	pDevPanel.DrawItem("Next Page", ITEMDRAW_CONTROL);
	pDevPanel.CurrentKey = 10;
	pDevPanel.DrawItem("Exit", ITEMDRAW_CONTROL);
	pDevPanel.Send(developer, iDeveloperMenuHandler, MENU_TIME_FOREVER);

	delete pDevPanel;
}

public int iDeveloperMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select && (param2 == 8 || param2 == 9))
	{
		vDeveloperPanel(param1, ((g_esDeveloper[param1].g_iDevPanelLevel == 0) ? 1 : 0));
	}
}

void vFavoriteMenu(int admin)
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
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "MTFavoriteMenu", param1);
			pFavorite.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "OptionYes", param1);
					case 1: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "OptionNo", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

void vInfoMenu(int client, bool adminmenu = false, int item = 0)
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
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esTank[g_esPlayer[param1].g_iTankType].g_iHumanSupport == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof sInfo);
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
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "MTInfoMenu", param1);
			pInfo.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Details", param1);
					case 2: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
					default:
					{
						char sInfo[33];
						menu.GetItem(param2, sInfo, sizeof sInfo);

						Call_StartForward(g_esGeneral.g_gfMenuItemDisplayedForward);
						Call_PushCell(param1);
						Call_PushString(sInfo);
						Call_PushString(sMenuOption);
						Call_PushCell(sizeof sMenuOption);
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

void vPathMenu(int admin, bool adminmenu = false, int item = 0)
{
	Menu mPathMenu = new Menu(iPathMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display);
	mPathMenu.SetTitle("File Path Menu");

	int iCount = 0;
	if (g_esGeneral.g_alFilePaths != null)
	{
		int iLength = g_esGeneral.g_alFilePaths.Length, iListSize = (iLength > 0) ? iLength : 0;
		if (iListSize > 0)
		{
			char sFilePath[PLATFORM_MAX_PATH], sMenuName[64];
			int iIndex = -1;
			for (int iPos = 0; iPos < iListSize; iPos++)
			{
				g_esGeneral.g_alFilePaths.GetString(iPos, sFilePath, sizeof sFilePath);
				iIndex = StrContains(sFilePath, "mutant_tanks", false);
				FormatEx(sMenuName, sizeof sMenuName, "%s", sFilePath[iIndex + 13]);
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
			menu.GetItem(param2, sInfo, sizeof sInfo);
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
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "MTPathMenu", param1);
			pPath.SetTitle(sMenuTitle);
		}
	}

	return 0;
}

void vPrefsMenu(int client, int item = 0)
{
	Menu mPrefsMenu = new Menu(iPrefsMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mPrefsMenu.SetTitle("Mutant Tanks Preferences Menu");

	char sDisplay[PLATFORM_MAX_PATH], sInfo[3];
	FormatEx(sDisplay, sizeof sDisplay, "Screen Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_SCREEN) ? "ON" : "OFF"));
	IntToString(MT_VISUAL_SCREEN, sInfo, sizeof sInfo);
	mPrefsMenu.AddItem(sInfo, sDisplay);

	FormatEx(sDisplay, sizeof sDisplay, "Particle Effect Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_PARTICLE) ? "ON" : "OFF"));
	IntToString(MT_VISUAL_PARTICLE, sInfo, sizeof sInfo);
	mPrefsMenu.AddItem(sInfo, sDisplay);

	FormatEx(sDisplay, sizeof sDisplay, "Looping Voiceline Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_VOICELINE) ? "ON" : "OFF"));
	IntToString(MT_VISUAL_VOICELINE, sInfo, sizeof sInfo);
	mPrefsMenu.AddItem(sInfo, sDisplay);

	FormatEx(sDisplay, sizeof sDisplay, "Light Color Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_LIGHT) ? "ON" : "OFF"));
	IntToString(MT_VISUAL_LIGHT, sInfo, sizeof sInfo);
	mPrefsMenu.AddItem(sInfo, sDisplay);

	FormatEx(sDisplay, sizeof sDisplay, "Body Color Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_BODY) ? "ON" : "OFF"));
	IntToString(MT_VISUAL_BODY, sInfo, sizeof sInfo);
	mPrefsMenu.AddItem(sInfo, sDisplay);

	if (g_bSecondGame)
	{
		FormatEx(sDisplay, sizeof sDisplay, "Glow Outline Visual: %s", ((g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_GLOW) ? "ON" : "OFF"));
		IntToString(MT_VISUAL_GLOW, sInfo, sizeof sInfo);
		mPrefsMenu.AddItem(sInfo, sDisplay);
	}

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
			menu.GetItem(param2, sInfo, sizeof sInfo);
			int iBit = StringToInt(sInfo);
			if (g_esPlayer[param1].g_bApplyVisuals[param2])
			{
				g_esPlayer[param1].g_bApplyVisuals[param2] = false;
				g_esPlayer[param1].g_iRewardVisuals &= ~iBit;
#if defined _clientprefs_included
				char sValue[3];
				IntToString(g_esPlayer[param1].g_iRewardVisuals, sValue, sizeof sValue);
				g_esGeneral.g_ckMTPrefs.Set(param1, sValue);
#endif
				vToggleSurvivorEffects(param1, .type = param2, .toggle = false);
			}
			else
			{
				g_esPlayer[param1].g_bApplyVisuals[param2] = true;
				g_esPlayer[param1].g_iRewardVisuals |= iBit;
#if defined _clientprefs_included
				char sValue[3];
				IntToString(g_esPlayer[param1].g_iRewardVisuals, sValue, sizeof sValue);
				g_esGeneral.g_ckMTPrefs.Set(param1, sValue);
#endif
				vToggleSurvivorEffects(param1, .type = param2);
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
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "MTPrefsMenu", param1);
			pPrefs.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof sMenuOption, "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_SCREEN) ? "ScreenVisualOn" : "ScreenVisualOff"), param1);
					case 1: FormatEx(sMenuOption, sizeof sMenuOption, "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_PARTICLE) ? "ParticleVisualOn" : "ParticleVisualOff"), param1);
					case 2: FormatEx(sMenuOption, sizeof sMenuOption, "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_VOICELINE) ? "VoicelineVisualOn" : "VoicelineVisualOff"), param1);
					case 3: FormatEx(sMenuOption, sizeof sMenuOption, "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_LIGHT) ? "LightVisualOn" : "LightVisualOff"), param1);
					case 4: FormatEx(sMenuOption, sizeof sMenuOption, "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_BODY) ? "BodyVisualOn" : "BodyVisualOff"), param1);
					case 5: FormatEx(sMenuOption, sizeof sMenuOption, "%T", ((g_esPlayer[param1].g_iRewardVisuals & MT_VISUAL_GLOW) ? "GlowVisualOn" : "GlowVisualOff"), param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

void vTankMenu(int admin, bool adminmenu = false, int item = 0)
{
	Menu mTankMenu = new Menu(iTankMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display);
	mTankMenu.SetTitle("%s List", MT_CONFIG_SECTION_MAIN);

	char sIndex[5], sMenuItem[46], sTankName[33];

	switch (bIsTank(admin))
	{
		case true:
		{
			SetGlobalTransTarget(admin);
			FormatEx(sMenuItem, sizeof sMenuItem, "%T", "MTTankItem", admin, "MTDefaultItem", 0);
			mTankMenu.AddItem("Default", sMenuItem, ((g_esPlayer[admin].g_iTankType > 0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
		}
		case false:
		{
			for (int iIndex = -1; iIndex <= 0; iIndex++)
			{
				SetGlobalTransTarget(admin);
				FormatEx(sMenuItem, sizeof sMenuItem, "%T", "MTTankItem", admin, "NoName", iIndex);
				IntToString(iIndex, sIndex, sizeof sIndex);
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

		vGetTranslatedName(sTankName, sizeof sTankName, .type = iIndex);
		SetGlobalTransTarget(admin);
		FormatEx(sMenuItem, sizeof sMenuItem, "%T", "MTTankItem", admin, sTankName, iIndex);
		IntToString(iIndex, sIndex, sizeof sIndex);
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
			menu.GetItem(param2, sInfo, sizeof sInfo);
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
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "MTListMenu", param1);
			pList.SetTitle(sMenuTitle);
		}
	}

	return 0;
}