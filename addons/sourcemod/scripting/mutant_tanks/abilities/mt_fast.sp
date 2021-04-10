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

#if !defined MT_ABILITIES_MAIN
#error This plugin must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
#endif

#define MT_FAST_SECTION "fastability"
#define MT_FAST_SECTION2 "fast ability"
#define MT_FAST_SECTION3 "fast_ability"
#define MT_FAST_SECTION4 "fast"
#define MT_FAST_SECTIONS MT_FAST_SECTION, MT_FAST_SECTION2, MT_FAST_SECTION3, MT_FAST_SECTION4

#define MT_MENU_FAST "Fast Ability"

enum struct esFastPlayer
{
	bool g_bActivated;

	float g_flFastChance;
	float g_flFastSpeed;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iDuration;
	int g_iFastAbility;
	int g_iFastDuration;
	int g_iFastMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iTankType;
}

esFastPlayer g_esFastPlayer[MAXPLAYERS + 1];

enum struct esFastAbility
{
	float g_flFastChance;
	float g_flFastSpeed;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iFastAbility;
	int g_iFastDuration;
	int g_iFastMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esFastAbility g_esFastAbility[MT_MAXTYPES + 1];

enum struct esFastCache
{
	float g_flFastChance;
	float g_flFastSpeed;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iFastAbility;
	int g_iFastDuration;
	int g_iFastMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esFastCache g_esFastCache[MAXPLAYERS + 1];

void vFastMapStart()
{
	vFastReset();
}

void vFastClientPutInServer(int client)
{
	vRemoveFast(client);
}

void vFastClientDisconnect_Post(int client)
{
	vRemoveFast(client);
}

void vFastMapEnd()
{
	vFastReset();
}

void vFastMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_FAST_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iFastMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fast Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Button Mode", "Button Mode");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iFastMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esFastCache[param1].g_iFastAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esFastCache[param1].g_iHumanAmmo - g_esFastPlayer[param1].g_iAmmoCount, g_esFastCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esFastCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esFastCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "FastDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esFastCache[param1].g_iFastDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esFastCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vFastMenu(param1, MT_FAST_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pFast = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "FastMenu", param1);
			pFast.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);
					case 2: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					case 5: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 6: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					case 7: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

void vFastDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_FAST, MT_MENU_FAST);
}

void vFastMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_FAST, false))
	{
		vFastMenu(client, MT_FAST_SECTION4, 0);
	}
}

void vFastMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_FAST, false))
	{
		FormatEx(buffer, size, "%T", "FastMenu2", client);
	}
}

void vFastPlayerRunCmd(int client)
{
	if (!MT_IsTankSupported(client) || !g_esFastPlayer[client].g_bActivated || (bIsTank(client, MT_CHECK_FAKECLIENT) && g_esFastCache[client].g_iHumanMode == 1) || g_esFastPlayer[client].g_iDuration == -1)
	{
		return;
	}

	static int iTime;
	iTime = GetTime();
	if (g_esFastPlayer[client].g_iDuration < iTime)
	{
		if (bIsTank(client, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(client) || bHasAdminAccess(client, g_esFastAbility[g_esFastPlayer[client].g_iTankType].g_iAccessFlags, g_esFastPlayer[client].g_iAccessFlags)) && g_esFastCache[client].g_iHumanAbility == 1 && (g_esFastPlayer[client].g_iCooldown == -1 || g_esFastPlayer[client].g_iCooldown < iTime))
		{
			vFastReset3(client);
		}

		vFastReset2(client);
	}
}

void vFastPluginCheck(ArrayList &list)
{
	list.PushString(MT_MENU_FAST);
}

void vFastAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString(MT_FAST_SECTION);
	list2.PushString(MT_FAST_SECTION2);
	list3.PushString(MT_FAST_SECTION3);
	list4.PushString(MT_FAST_SECTION4);
}

void vFastCombineAbilities(int tank, int type, const float random, const char[] combo)
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esFastCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_FAST_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_FAST_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_FAST_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_FAST_SECTION4);
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esFastCache[tank].g_iFastAbility == 1 && g_esFastCache[tank].g_iComboAbility == 1 && !g_esFastPlayer[tank].g_bActivated)
		{
			static char sSubset[10][32];
			ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
			for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_FAST_SECTION, false) || StrEqual(sSubset[iPos], MT_FAST_SECTION2, false) || StrEqual(sSubset[iPos], MT_FAST_SECTION3, false) || StrEqual(sSubset[iPos], MT_FAST_SECTION4, false))
				{
					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						static float flDelay;
						flDelay = MT_GetCombinationSetting(tank, 3, iPos);

						switch (flDelay)
						{
							case 0.0: vFast(tank, iPos);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerFastCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteCell(iPos);
							}
						}

						break;
					}
				}
			}
		}
	}
}

void vFastConfigsLoad(int mode)
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esFastAbility[iIndex].g_iAccessFlags = 0;
				g_esFastAbility[iIndex].g_iComboAbility = 0;
				g_esFastAbility[iIndex].g_iHumanAbility = 0;
				g_esFastAbility[iIndex].g_iHumanAmmo = 5;
				g_esFastAbility[iIndex].g_iHumanCooldown = 30;
				g_esFastAbility[iIndex].g_iHumanMode = 1;
				g_esFastAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esFastAbility[iIndex].g_iRequiresHumans = 0;
				g_esFastAbility[iIndex].g_iFastAbility = 0;
				g_esFastAbility[iIndex].g_iFastMessage = 0;
				g_esFastAbility[iIndex].g_flFastChance = 33.3;
				g_esFastAbility[iIndex].g_iFastDuration = 5;
				g_esFastAbility[iIndex].g_flFastSpeed = 5.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esFastPlayer[iPlayer].g_iAccessFlags = 0;
					g_esFastPlayer[iPlayer].g_iComboAbility = 0;
					g_esFastPlayer[iPlayer].g_iHumanAbility = 0;
					g_esFastPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esFastPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esFastPlayer[iPlayer].g_iHumanMode = 0;
					g_esFastPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esFastPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esFastPlayer[iPlayer].g_iFastAbility = 0;
					g_esFastPlayer[iPlayer].g_iFastMessage = 0;
					g_esFastPlayer[iPlayer].g_flFastChance = 0.0;
					g_esFastPlayer[iPlayer].g_iFastDuration = 0;
					g_esFastPlayer[iPlayer].g_flFastSpeed = 0.0;
				}
			}
		}
	}
}

void vFastConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esFastPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esFastPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esFastPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esFastPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esFastPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esFastPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esFastPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esFastPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esFastPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esFastPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esFastPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_FAST_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esFastPlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esFastPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esFastPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esFastPlayer[admin].g_iFastAbility = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esFastPlayer[admin].g_iFastAbility, value, 0, 1);
		g_esFastPlayer[admin].g_iFastMessage = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esFastPlayer[admin].g_iFastMessage, value, 0, 1);
		g_esFastPlayer[admin].g_flFastChance = flGetKeyValue(subsection, MT_FAST_SECTIONS, key, "FastChance", "Fast Chance", "Fast_Chance", "chance", g_esFastPlayer[admin].g_flFastChance, value, 0.0, 100.0);
		g_esFastPlayer[admin].g_iFastDuration = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "FastDuration", "Fast Duration", "Fast_Duration", "duration", g_esFastPlayer[admin].g_iFastDuration, value, 1, 999999);
		g_esFastPlayer[admin].g_flFastSpeed = flGetKeyValue(subsection, MT_FAST_SECTIONS, key, "FastSpeed", "Fast Speed", "Fast_Speed", "speed", g_esFastPlayer[admin].g_flFastSpeed, value, 3.0, 10.0);

		if (StrEqual(subsection, MT_FAST_SECTION, false) || StrEqual(subsection, MT_FAST_SECTION2, false) || StrEqual(subsection, MT_FAST_SECTION3, false) || StrEqual(subsection, MT_FAST_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esFastPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esFastAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esFastAbility[type].g_iComboAbility, value, 0, 1);
		g_esFastAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esFastAbility[type].g_iHumanAbility, value, 0, 2);
		g_esFastAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esFastAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esFastAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esFastAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esFastAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esFastAbility[type].g_iHumanMode, value, 0, 1);
		g_esFastAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_FAST_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esFastAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esFastAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esFastAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esFastAbility[type].g_iFastAbility = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esFastAbility[type].g_iFastAbility, value, 0, 1);
		g_esFastAbility[type].g_iFastMessage = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esFastAbility[type].g_iFastMessage, value, 0, 1);
		g_esFastAbility[type].g_flFastChance = flGetKeyValue(subsection, MT_FAST_SECTIONS, key, "FastChance", "Fast Chance", "Fast_Chance", "chance", g_esFastAbility[type].g_flFastChance, value, 0.0, 100.0);
		g_esFastAbility[type].g_iFastDuration = iGetKeyValue(subsection, MT_FAST_SECTIONS, key, "FastDuration", "Fast Duration", "Fast_Duration", "duration", g_esFastAbility[type].g_iFastDuration, value, 1, 999999);
		g_esFastAbility[type].g_flFastSpeed = flGetKeyValue(subsection, MT_FAST_SECTIONS, key, "FastSpeed", "Fast Speed", "Fast_Speed", "speed", g_esFastAbility[type].g_flFastSpeed, value, 3.0, 10.0);

		if (StrEqual(subsection, MT_FAST_SECTION, false) || StrEqual(subsection, MT_FAST_SECTION2, false) || StrEqual(subsection, MT_FAST_SECTION3, false) || StrEqual(subsection, MT_FAST_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esFastAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}
}

void vFastSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	g_esFastCache[tank].g_flFastChance = flGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_flFastChance, g_esFastAbility[type].g_flFastChance);
	g_esFastCache[tank].g_flFastSpeed = flGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_flFastSpeed, g_esFastAbility[type].g_flFastSpeed);
	g_esFastCache[tank].g_iFastAbility = iGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_iFastAbility, g_esFastAbility[type].g_iFastAbility);
	g_esFastCache[tank].g_iFastDuration = iGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_iFastDuration, g_esFastAbility[type].g_iFastDuration);
	g_esFastCache[tank].g_iFastMessage = iGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_iFastMessage, g_esFastAbility[type].g_iFastMessage);
	g_esFastCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_iComboAbility, g_esFastAbility[type].g_iComboAbility);
	g_esFastCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_iHumanAbility, g_esFastAbility[type].g_iHumanAbility);
	g_esFastCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_iHumanAmmo, g_esFastAbility[type].g_iHumanAmmo);
	g_esFastCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_iHumanCooldown, g_esFastAbility[type].g_iHumanCooldown);
	g_esFastCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_iHumanMode, g_esFastAbility[type].g_iHumanMode);
	g_esFastCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_flOpenAreasOnly, g_esFastAbility[type].g_flOpenAreasOnly);
	g_esFastCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esFastPlayer[tank].g_iRequiresHumans, g_esFastAbility[type].g_iRequiresHumans);
	g_esFastPlayer[tank].g_iTankType = apply ? type : 0;
}

void vFastCopyStats(int oldTank, int newTank)
{
	vFastCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveFast(oldTank);
	}
}

void vFastPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esFastPlayer[iTank].g_bActivated)
		{
			SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
	}
}

void vFastEventFired(Event event, const char[] name)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vFastCopyStats2(iBot, iTank);
			vRemoveFast(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vFastCopyStats2(iTank, iBot);
			vRemoveFast(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveFast(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vFastReset();
	}
}

void vFastAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esFastAbility[g_esFastPlayer[tank].g_iTankType].g_iAccessFlags, g_esFastPlayer[tank].g_iAccessFlags)) || g_esFastCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esFastCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esFastCache[tank].g_iFastAbility == 1 && g_esFastCache[tank].g_iComboAbility == 0 && !g_esFastPlayer[tank].g_bActivated)
	{
		vFastAbility(tank);
	}
}

void vFastButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esFastCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esFastPlayer[tank].g_iTankType) || (g_esFastCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esFastCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esFastAbility[g_esFastPlayer[tank].g_iTankType].g_iAccessFlags, g_esFastPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_MAIN_KEY)
		{
			if (g_esFastCache[tank].g_iFastAbility == 1 && g_esFastCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esFastPlayer[tank].g_iCooldown != -1 && g_esFastPlayer[tank].g_iCooldown > iTime;

				switch (g_esFastCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esFastPlayer[tank].g_bActivated && !bRecharging)
						{
							vFastAbility(tank);
						}
						else if (g_esFastPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastHuman4", g_esFastPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esFastPlayer[tank].g_iAmmoCount < g_esFastCache[tank].g_iHumanAmmo && g_esFastCache[tank].g_iHumanAmmo > 0))
						{
							if (!g_esFastPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esFastPlayer[tank].g_bActivated = true;
								g_esFastPlayer[tank].g_iAmmoCount++;

								SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", g_esFastCache[tank].g_flFastSpeed);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastHuman", g_esFastPlayer[tank].g_iAmmoCount, g_esFastCache[tank].g_iHumanAmmo);
							}
							else if (g_esFastPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastHuman4", g_esFastPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastAmmo");
						}
					}
				}
			}
		}
	}
}

void vFastButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esFastCache[tank].g_iHumanAbility == 1)
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esFastCache[tank].g_iHumanMode == 1 && g_esFastPlayer[tank].g_bActivated && (g_esFastPlayer[tank].g_iCooldown == -1 || g_esFastPlayer[tank].g_iCooldown < GetTime()))
			{
				vFastReset2(tank);
				vFastReset3(tank);
			}
		}
	}
}

void vFastChangeType(int tank)
{
	vRemoveFast(tank);
}

void vFastCopyStats2(int oldTank, int newTank)
{
	g_esFastPlayer[newTank].g_iAmmoCount = g_esFastPlayer[oldTank].g_iAmmoCount;
	g_esFastPlayer[newTank].g_iCooldown = g_esFastPlayer[oldTank].g_iCooldown;
}

void vFast(int tank, int pos = -1)
{
	static int iDuration;
	iDuration = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 4, pos)) : g_esFastCache[tank].g_iFastDuration;
	g_esFastPlayer[tank].g_bActivated = true;
	g_esFastPlayer[tank].g_iDuration = GetTime() + iDuration;

	static float flSpeed;
	flSpeed = (pos != -1) ? MT_GetCombinationSetting(tank, 13, pos) : g_esFastCache[tank].g_flFastSpeed;
	SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", flSpeed);

	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esFastCache[tank].g_iHumanAbility == 1)
	{
		g_esFastPlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastHuman", g_esFastPlayer[tank].g_iAmmoCount, g_esFastCache[tank].g_iHumanAmmo);
	}

	if (g_esFastCache[tank].g_iFastMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Fast", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Fast", LANG_SERVER, sTankName);
	}
}

void vFastAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esFastCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esFastPlayer[tank].g_iTankType) || (g_esFastCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esFastCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esFastAbility[g_esFastPlayer[tank].g_iTankType].g_iAccessFlags, g_esFastPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esFastPlayer[tank].g_iAmmoCount < g_esFastCache[tank].g_iHumanAmmo && g_esFastCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esFastCache[tank].g_flFastChance)
		{
			vFast(tank);
		}
		else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esFastCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastHuman2");
		}
	}
	else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esFastCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastAmmo");
	}
}

void vRemoveFast(int tank)
{
	g_esFastPlayer[tank].g_bActivated = false;
	g_esFastPlayer[tank].g_iAmmoCount = 0;
	g_esFastPlayer[tank].g_iCooldown = -1;
	g_esFastPlayer[tank].g_iDuration = -1;
}

void vFastReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveFast(iPlayer);
		}
	}
}

void vFastReset2(int tank)
{
	g_esFastPlayer[tank].g_bActivated = false;
	g_esFastPlayer[tank].g_iDuration = -1;

	SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(tank));

	if (g_esFastCache[tank].g_iFastMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Fast2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Fast2", LANG_SERVER, sTankName);
	}
}

void vFastReset3(int tank)
{
	int iTime = GetTime();
	g_esFastPlayer[tank].g_iCooldown = (g_esFastPlayer[tank].g_iAmmoCount < g_esFastCache[tank].g_iHumanAmmo && g_esFastCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esFastCache[tank].g_iHumanCooldown) : -1;
	if (g_esFastPlayer[tank].g_iCooldown != -1 && g_esFastPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FastHuman5", g_esFastPlayer[tank].g_iCooldown - iTime);
	}
}

public Action tTimerFastCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esFastAbility[g_esFastPlayer[iTank].g_iTankType].g_iAccessFlags, g_esFastPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esFastPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esFastCache[iTank].g_iFastAbility == 0 || g_esFastPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vFast(iTank, iPos);

	return Plugin_Continue;
}