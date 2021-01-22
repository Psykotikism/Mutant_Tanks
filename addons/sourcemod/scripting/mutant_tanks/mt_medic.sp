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
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Medic Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank heals nearby special infected.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bSecondGame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Medic Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	return APLRes_Success;
}

#define MT_CONFIG_SECTION "medicability"
#define MT_CONFIG_SECTION2 "medic ability"
#define MT_CONFIG_SECTION3 "medic_ability"
#define MT_CONFIG_SECTION4 "medic"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_MEDIC "Medic Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flMedicChance;
	float g_flMedicInterval;
	float g_flMedicRange;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iMedicAbility;
	int g_iMedicField;
	int g_iMedicFieldColor[4];
	int g_iMedicHealth[7];
	int g_iMedicMaxHealth[7];
	int g_iMedicMessage;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flMedicChance;
	float g_flMedicInterval;
	float g_flMedicRange;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iMedicAbility;
	int g_iMedicField;
	int g_iMedicFieldColor[4];
	int g_iMedicHealth[7];
	int g_iMedicMaxHealth[7];
	int g_iMedicMessage;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flMedicChance;
	float g_flMedicInterval;
	float g_flMedicRange;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iMedicAbility;
	int g_iMedicField;
	int g_iMedicFieldColor[4];
	int g_iMedicHealth[7];
	int g_iMedicMaxHealth[7];
	int g_iMedicMessage;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

int g_iMedicBeamSprite = -1, g_iMedicHaloSprite = -1;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_medic", cmdMedicInfo, "View information about the Medic ability.");
}

public void OnMapStart()
{
	g_iMedicBeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
	g_iMedicHaloSprite = PrecacheModel("sprites/glow01.vmt", true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveMedic(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveMedic(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdMedicInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

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
		case false: vMedicMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vMedicMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iMedicMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Medic Ability Information");
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

public int iMedicMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iMedicAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "MedicDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vMedicMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pMedic = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MedicMenu", param1);
			pMedic.SetTitle(sMenuTitle);
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_MEDIC, MT_MENU_MEDIC);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_MEDIC, false))
	{
		vMedicMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_MEDIC, false))
	{
		FormatEx(buffer, size, "%T", "MedicMenu2", client);
	}
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString(MT_CONFIG_SECTION);
	list2.PushString(MT_CONFIG_SECTION2);
	list3.PushString(MT_CONFIG_SECTION3);
	list4.PushString(MT_CONFIG_SECTION4);
}

public void MT_OnCombineAbilities(int tank, int type, float random, const char[] combo, int survivor, int weapon, const char[] classname)
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION4);
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esCache[tank].g_iMedicAbility == 1 && g_esCache[tank].g_iComboAbility == 1 && !g_esPlayer[tank].g_bActivated)
		{
			static char sSubset[10][32];
			ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
			for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_CONFIG_SECTION, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION2, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION3, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION4, false))
				{
					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						static float flDelay;
						flDelay = MT_GetCombinationSetting(tank, 3, iPos);

						switch (flDelay)
						{
							case 0.0: vMedic(tank, iPos);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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

public void MT_OnConfigsLoad(int mode)
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esAbility[iIndex].g_iAccessFlags = 0;
				g_esAbility[iIndex].g_iComboAbility = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iHumanDuration = 5;
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iMedicAbility = 0;
				g_esAbility[iIndex].g_iMedicMessage = 0;
				g_esAbility[iIndex].g_flMedicChance = 33.3;
				g_esAbility[iIndex].g_iMedicField = 1;
				g_esAbility[iIndex].g_iMedicFieldColor[0] = 0;
				g_esAbility[iIndex].g_iMedicFieldColor[1] = 255;
				g_esAbility[iIndex].g_iMedicFieldColor[2] = 0;
				g_esAbility[iIndex].g_iMedicFieldColor[3] = 255;
				g_esAbility[iIndex].g_flMedicInterval = 5.0;
				g_esAbility[iIndex].g_iMedicMaxHealth[0] = 250;
				g_esAbility[iIndex].g_iMedicMaxHealth[1] = 50;
				g_esAbility[iIndex].g_iMedicMaxHealth[2] = 250;
				g_esAbility[iIndex].g_iMedicMaxHealth[3] = 100;
				g_esAbility[iIndex].g_iMedicMaxHealth[4] = 325;
				g_esAbility[iIndex].g_iMedicMaxHealth[5] = 600;
				g_esAbility[iIndex].g_iMedicMaxHealth[6] = 8000;
				g_esAbility[iIndex].g_flMedicRange = 500.0;

				for (int iPos = 0; iPos < sizeof(esAbility::g_iMedicHealth); iPos++)
				{
					g_esAbility[iIndex].g_iMedicHealth[iPos] = 25;
				}
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iComboAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanDuration = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iMedicAbility = 0;
					g_esPlayer[iPlayer].g_iMedicMessage = 0;
					g_esPlayer[iPlayer].g_flMedicChance = 0.0;
					g_esPlayer[iPlayer].g_iMedicField = 0;
					g_esPlayer[iPlayer].g_iMedicFieldColor[3] = 255;
					g_esPlayer[iPlayer].g_flMedicInterval = 0.0;
					g_esPlayer[iPlayer].g_flMedicRange = 0.0;

					for (int iPos = 0; iPos < sizeof(esPlayer::g_iMedicHealth); iPos++)
					{
						g_esPlayer[iPlayer].g_iMedicHealth[iPos] = 0;
						g_esPlayer[iPlayer].g_iMedicMaxHealth[iPos] = 0;

						if (iPos < sizeof(esPlayer::g_iMedicFieldColor) - 1)
						{
							g_esPlayer[iPlayer].g_iMedicFieldColor[iPos] = -1;
						}
					}
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPlayer[admin].g_iHumanDuration, value, 1, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iMedicAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iMedicAbility, value, 0, 1);
		g_esPlayer[admin].g_iMedicMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iMedicMessage, value, 0, 1);
		g_esPlayer[admin].g_flMedicChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MedicChance", "Medic Chance", "Medic_Chance", "chance", g_esPlayer[admin].g_flMedicChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iMedicField = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MedicField", "Medic Field", "Medic_Field", "field", g_esPlayer[admin].g_iMedicField, value, 0, 1);
		g_esPlayer[admin].g_flMedicInterval = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MedicInterval", "Medic Interval", "Medic_Interval", "interval", g_esPlayer[admin].g_flMedicInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flMedicRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MedicRange", "Medic Range", "Medic_Range", "range", g_esPlayer[admin].g_flMedicRange, value, 1.0, 999999.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "MedicFieldColor", false) || StrEqual(key, "Medic Field Color", false) || StrEqual(key, "Medic_Field_Color", false) || StrEqual(key, "fieldcolor", false))
			{
				static char sSet[3][4], sValue[12];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(sSet) - 1; iPos++)
				{
					g_esPlayer[admin].g_iMedicFieldColor[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
				}

				g_esPlayer[admin].g_iMedicFieldColor[3] = 255;
			}
			else
			{
				static char sSet[7][6], sValue[42];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(sSet); iPos++)
				{
					if (StrEqual(key, "MedicHealth", false) || StrEqual(key, "Medic Health", false) || StrEqual(key, "Medic_Health", false) || StrEqual(key, "health", false))
					{
						g_esPlayer[admin].g_iMedicHealth[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH) : g_esPlayer[admin].g_iMedicHealth[iPos];
					}
					else if (StrEqual(key, "MedicMaxHealth", false) || StrEqual(key, "Medic Max Health", false) || StrEqual(key, "Medic_Max_Health", false) || StrEqual(key, "maxhealth", false))
					{
						g_esPlayer[admin].g_iMedicMaxHealth[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXHEALTH) : g_esPlayer[admin].g_iMedicMaxHealth[iPos];
					}
				}
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAbility[type].g_iComboAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_iHumanDuration, value, 1, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iMedicAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iMedicAbility, value, 0, 1);
		g_esAbility[type].g_iMedicMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iMedicMessage, value, 0, 1);
		g_esAbility[type].g_flMedicChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MedicChance", "Medic Chance", "Medic_Chance", "chance", g_esAbility[type].g_flMedicChance, value, 0.0, 100.0);
		g_esAbility[type].g_iMedicField = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MedicField", "Medic Field", "Medic_Field", "field", g_esAbility[type].g_iMedicField, value, 0, 1);
		g_esAbility[type].g_flMedicInterval = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MedicInterval", "Medic Interval", "Medic_Interval", "interval", g_esAbility[type].g_flMedicInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flMedicRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MedicRange", "Medic Range", "Medic_Range", "range", g_esAbility[type].g_flMedicRange, value, 1.0, 999999.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "MedicFieldColor", false) || StrEqual(key, "Medic Field Color", false) || StrEqual(key, "Medic_Field_Color", false) || StrEqual(key, "fieldcolor", false))
			{
				static char sSet[3][4], sValue[12];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(sSet) - 1; iPos++)
				{
					g_esAbility[type].g_iMedicFieldColor[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
				}

				g_esAbility[type].g_iMedicFieldColor[3] = 255;
			}
			else
			{
				static char sSet[7][6], sValue[42];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(sSet); iPos++)
				{
					if (StrEqual(key, "MedicHealth", false) || StrEqual(key, "Medic Health", false) || StrEqual(key, "Medic_Health", false) || StrEqual(key, "health", false))
					{
						g_esAbility[type].g_iMedicHealth[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH) : g_esAbility[type].g_iMedicHealth[iPos];
					}
					else if (StrEqual(key, "MedicMaxHealth", false) || StrEqual(key, "Medic Max Health", false) || StrEqual(key, "Medic_Max_Health", false) || StrEqual(key, "maxhealth", false))
					{
						g_esAbility[type].g_iMedicMaxHealth[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXHEALTH) : g_esAbility[type].g_iMedicMaxHealth[iPos];
					}
				}
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flMedicChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flMedicChance, g_esAbility[type].g_flMedicChance);
	g_esCache[tank].g_flMedicInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flMedicInterval, g_esAbility[type].g_flMedicInterval);
	g_esCache[tank].g_flMedicRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flMedicRange, g_esAbility[type].g_flMedicRange);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanDuration, g_esAbility[type].g_iHumanDuration);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iMedicAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMedicAbility, g_esAbility[type].g_iMedicAbility);
	g_esCache[tank].g_iMedicField = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMedicField, g_esAbility[type].g_iMedicField);
	g_esCache[tank].g_iMedicMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMedicMessage, g_esAbility[type].g_iMedicMessage);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;

	for (int iPos = 0; iPos < sizeof(esCache::g_iMedicHealth); iPos++)
	{
		g_esCache[tank].g_iMedicHealth[iPos] = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMedicHealth[iPos], g_esAbility[type].g_iMedicHealth[iPos]);
		g_esCache[tank].g_iMedicMaxHealth[iPos] = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMedicMaxHealth[iPos], g_esAbility[type].g_iMedicMaxHealth[iPos]);
	
		if (iPos < sizeof(esCache::g_iMedicFieldColor))
		{
			g_esCache[tank].g_iMedicFieldColor[iPos] = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMedicFieldColor[iPos], g_esAbility[type].g_iMedicFieldColor[iPos]);
		}
	}
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveMedic(oldTank);
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vCopyStats(iBot, iTank);
			vRemoveMedic(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveMedic(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveMedic(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vReset();
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iMedicAbility == 1 && g_esCache[tank].g_iComboAbility == 0 && !g_esPlayer[tank].g_bActivated)
	{
		vMedicAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iMedicAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vMedicAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman4", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esPlayer[tank].g_bActivated = true;
								g_esPlayer[tank].g_iAmmoCount++;

								vMedic2(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				vReset2(tank);
				vReset3(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveMedic(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vMedic(int tank, int pos = -1)
{
	g_esPlayer[tank].g_bActivated = true;

	vMedic2(tank, pos);

	if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		g_esPlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
	}

	if (g_esCache[tank].g_iMedicMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Medic", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Medic", LANG_SERVER, sTankName);
	}
}

static void vMedic2(int tank, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static float flInterval;
	flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : g_esCache[tank].g_flMedicInterval;
	DataPack dpMedic;
	CreateDataTimer(flInterval, tTimerMedic, dpMedic, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpMedic.WriteCell(GetClientUserId(tank));
	dpMedic.WriteCell(g_esPlayer[tank].g_iTankType);
	dpMedic.WriteCell(GetTime());
	dpMedic.WriteCell(pos);
}

static void vMedicAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flMedicChance)
		{
			vMedic(tank);
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicAmmo");
	}
}

static void vRemoveMedic(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveMedic(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;

	if (g_esCache[tank].g_iMedicMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Medic3", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Medic3", LANG_SERVER, sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static int iGetHealth(int tank, int infected)
{
	static int iClass;
	iClass = GetEntProp(infected, Prop_Send, "m_zombieClass");

	switch (iClass)
	{
		case 1: return g_esCache[tank].g_iMedicHealth[iClass - 1];
		case 2: return g_esCache[tank].g_iMedicHealth[iClass - 1];
		case 3: return g_esCache[tank].g_iMedicHealth[iClass - 1];
		case 4: return g_esCache[tank].g_iMedicHealth[iClass - 1];
		case 5: return g_bSecondGame ? g_esCache[tank].g_iMedicHealth[iClass - 1] : g_esCache[tank].g_iMedicHealth[iClass + 1];
		case 6: return g_esCache[tank].g_iMedicHealth[iClass - 1];
		case 8: return g_esCache[tank].g_iMedicHealth[iClass - 2];
	}

	return 0;
}

static int iGetMaxHealth(int tank, int infected)
{
	static int iClass;
	iClass = GetEntProp(infected, Prop_Send, "m_zombieClass");

	switch (iClass)
	{
		case 1: return g_esCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 2: return g_esCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 3: return g_esCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 4: return g_esCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 5: return g_bSecondGame ? g_esCache[tank].g_iMedicMaxHealth[iClass - 1] : g_esCache[tank].g_iMedicMaxHealth[iClass + 1];
		case 6: return g_esCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 8: return g_esCache[tank].g_iMedicMaxHealth[iClass - 2];
	}

	return 0;
}

static int[] iGetRandomColors(int tank)
{
	for (int iPos = 0; iPos < sizeof(esCache::g_iMedicFieldColor) - 1; iPos++)
	{
		g_esCache[tank].g_iMedicFieldColor[iPos] = iGetRandomColor(g_esCache[tank].g_iMedicFieldColor[iPos]);
	}

	g_esCache[tank].g_iMedicFieldColor[3] = 255;

	return g_esCache[tank].g_iMedicFieldColor;
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iMedicAbility == 0 || g_esPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vMedic(iTank, iPos);

	return Plugin_Continue;
}

public Action tTimerMedic(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || g_esCache[iTank].g_iMedicAbility == 0 || !g_esPlayer[iTank].g_bActivated)
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	static int iTime, iPos, iCurrentTime;
	iTime = pack.ReadCell();
	iPos = pack.ReadCell();
	iCurrentTime = GetTime();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (iTime + g_esCache[iTank].g_iHumanDuration) < iCurrentTime && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vReset2(iTank);
		vReset3(iTank);

		return Plugin_Stop;
	}

	static float flTankPos[3], flInfectedPos[3], flRange;
	GetClientAbsOrigin(iTank, flTankPos);
	flRange = (iPos != -1) ? MT_GetCombinationSetting(iTank, 8, iPos) : g_esCache[iTank].g_flMedicRange;

	if (g_esCache[iTank].g_iMedicField == 1)
	{
		flTankPos[2] += 10.0;
		TE_SetupBeamRingPoint(flTankPos, 50.0, flRange, g_iMedicBeamSprite, g_iMedicHaloSprite, 0, 0, 1.0, 3.0, 0.0, iGetRandomColors(iTank), 0, 0);
		TE_SendToAll();
	}

	static int iHealth, iMaxHealth, iNewHealth, iExtraHealth, iExtraHealth2, iRealHealth;
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if ((MT_IsTankSupported(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE) || bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE)) && iTank != iInfected)
		{
			GetClientAbsOrigin(iInfected, flInfectedPos);
			if (GetVectorDistance(flTankPos, flInfectedPos) <= flRange)
			{
				iHealth = GetEntProp(iInfected, Prop_Data, "m_iHealth");
				iMaxHealth = MT_TankMaxHealth(iInfected, 1);
				iNewHealth = iHealth + iGetHealth(iTank, iInfected);
				iExtraHealth = (iNewHealth > iGetMaxHealth(iTank, iInfected)) ? iGetMaxHealth(iTank, iInfected) : iNewHealth;
				iExtraHealth2 = (iNewHealth < iHealth) ? 1 : iNewHealth;
				iRealHealth = (iNewHealth >= 0) ? iExtraHealth : iExtraHealth2;
				MT_TankMaxHealth(iInfected, 3, iMaxHealth + iGetHealth(iTank, iInfected));
				SetEntProp(iInfected, Prop_Data, "m_iHealth", iRealHealth);

				if (g_esCache[iTank].g_iMedicMessage == 1)
				{
					static char sTankName[33];
					MT_GetTankName(iTank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Medic2", sTankName, iInfected);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Medic2", LANG_SERVER, sTankName, iInfected);
				}
			}
		}
	}

	return Plugin_Continue;
}