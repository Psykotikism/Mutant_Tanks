/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2022  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_SPLATTER_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_SPLATTER_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Splatter Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank covers everyone's screens with splatters.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bSecondGame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Splatter Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();

	return APLRes_Success;
}
#else
	#if MT_SPLATTER_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_SPLATTER_SECTION "splatterability"
#define MT_SPLATTER_SECTION2 "splatter ability"
#define MT_SPLATTER_SECTION3 "splatter_ability"
#define MT_SPLATTER_SECTION4 "splatter"

#define MT_MENU_SPLATTER "Splatter Ability"

char g_sParticles[][] =
{
	"screen_adrenaline",
	"screen_adrenaline_b",
	"screen_hurt",
	"screen_hurt_b",
	"screen_blood_splatter",
	"screen_blood_splatter_a",
	"screen_blood_splatter_b",
	"screen_blood_splatter_melee_b",
	"screen_blood_splatter_melee",
	"screen_blood_splatter_melee_blunt",
	"smoker_screen_effect",
	"smoker_screen_effect_b",
	"screen_mud_splatter",
	"screen_mud_splatter_a",
	"screen_bashed",
	"screen_bashed_b",
	"screen_bashed_d",
	"burning_character_screen",
	"storm_lightning_screenglow"
};

enum struct esSplatterPlayer
{
	bool g_bActivated;

	float g_flOpenAreasOnly;
	float g_flSplatterChance;
	float g_flSplatterInterval;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iSplatterAbility;
	int g_iSplatterMessage;
	int g_iSplatterType;
	int g_iTankType;
}

esSplatterPlayer g_esSplatterPlayer[MAXPLAYERS + 1];

enum struct esSplatterAbility
{
	float g_flOpenAreasOnly;
	float g_flSplatterChance;
	float g_flSplatterInterval;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iSplatterAbility;
	int g_iSplatterMessage;
	int g_iSplatterType;
}

esSplatterAbility g_esSplatterAbility[MT_MAXTYPES + 1];

enum struct esSplatterCache
{
	float g_flOpenAreasOnly;
	float g_flSplatterChance;
	float g_flSplatterInterval;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iSplatterAbility;
	int g_iSplatterMessage;
	int g_iSplatterType;
}

esSplatterCache g_esSplatterCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_splatter", cmdSplatterInfo, "View information about the Splatter ability.");
}
#endif

#if defined MT_ABILITIES_MAIN2
void vSplatterMapStart()
#else
public void OnMapStart()
#endif
{
	if (g_bSecondGame)
	{
		for (int iPos = 0; iPos < (sizeof g_sParticles); iPos++)
		{
			iPrecacheParticle(g_sParticles[iPos]);
		}
	}

	vSplatterReset();
}

#if defined MT_ABILITIES_MAIN2
void vSplatterClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	vRemoveSplatter(client);
}

#if defined MT_ABILITIES_MAIN2
void vSplatterClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveSplatter(client);
}

#if defined MT_ABILITIES_MAIN2
void vSplatterMapEnd()
#else
public void OnMapEnd()
#endif
{
	vSplatterReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdSplatterInfo(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG5, "PluginDisabled");

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
		case false: vSplatterMenu(client, MT_SPLATTER_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vSplatterMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_SPLATTER_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iSplatterMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Splatter Ability Information");
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

int iSplatterMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esSplatterCache[param1].g_iSplatterAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esSplatterCache[param1].g_iHumanAmmo - g_esSplatterPlayer[param1].g_iAmmoCount), g_esSplatterCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esSplatterCache[param1].g_iHumanMode == 0) ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esSplatterCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "SplatterDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esSplatterCache[param1].g_iHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esSplatterCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vSplatterMenu(param1, MT_SPLATTER_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pSplatter = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "SplatterMenu", param1);
			pSplatter.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Ammunition", param1);
					case 2: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Buttons", param1);
					case 3: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "ButtonMode", param1);
					case 4: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Cooldown", param1);
					case 5: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Details", param1);
					case 6: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Duration", param1);
					case 7: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN2
void vSplatterDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_SPLATTER, MT_MENU_SPLATTER);
}

#if defined MT_ABILITIES_MAIN2
void vSplatterMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_SPLATTER, false))
	{
		vSplatterMenu(client, MT_SPLATTER_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vSplatterMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_SPLATTER, false))
	{
		FormatEx(buffer, size, "%T", "SplatterMenu2", client);
	}
}

#if defined MT_ABILITIES_MAIN2
void vSplatterPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_SPLATTER);
}

#if defined MT_ABILITIES_MAIN2
void vSplatterAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_SPLATTER_SECTION);
	list2.PushString(MT_SPLATTER_SECTION2);
	list3.PushString(MT_SPLATTER_SECTION3);
	list4.PushString(MT_SPLATTER_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vSplatterCombineAbilities(int tank, int type, const float random, const char[] combo)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (!g_bSecondGame || (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSplatterCache[tank].g_iHumanAbility != 2))
	{
		return;
	}

	char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof sAbilities, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_SPLATTER_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_SPLATTER_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_SPLATTER_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_SPLATTER_SECTION4);
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esSplatterCache[tank].g_iSplatterAbility == 1 && g_esSplatterCache[tank].g_iComboAbility == 1 && !g_esSplatterPlayer[tank].g_bActivated)
		{
			char sSubset[10][32];
			ExplodeString(combo, ",", sSubset, sizeof sSubset, sizeof sSubset[]);
			for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_SPLATTER_SECTION, false) || StrEqual(sSubset[iPos], MT_SPLATTER_SECTION2, false) || StrEqual(sSubset[iPos], MT_SPLATTER_SECTION3, false) || StrEqual(sSubset[iPos], MT_SPLATTER_SECTION4, false))
				{
					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						float flDelay = MT_GetCombinationSetting(tank, 3, iPos);

						switch (flDelay)
						{
							case 0.0: vSplatter(tank, iPos);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerSplatterCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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

#if defined MT_ABILITIES_MAIN2
void vSplatterConfigsLoad(int mode)
#else
public void MT_OnConfigsLoad(int mode)
#endif
{
	switch (mode)
	{
		case 1:
		{
			int iMaxType = MT_GetMaxType();
			for (int iIndex = MT_GetMinType(); iIndex <= iMaxType; iIndex++)
			{
				g_esSplatterAbility[iIndex].g_iAccessFlags = 0;
				g_esSplatterAbility[iIndex].g_iComboAbility = 0;
				g_esSplatterAbility[iIndex].g_iHumanAbility = 0;
				g_esSplatterAbility[iIndex].g_iHumanAmmo = 5;
				g_esSplatterAbility[iIndex].g_iHumanCooldown = 30;
				g_esSplatterAbility[iIndex].g_iHumanDuration = 5;
				g_esSplatterAbility[iIndex].g_iHumanMode = 1;
				g_esSplatterAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esSplatterAbility[iIndex].g_iRequiresHumans = 1;
				g_esSplatterAbility[iIndex].g_iSplatterAbility = 0;
				g_esSplatterAbility[iIndex].g_iSplatterMessage = 0;
				g_esSplatterAbility[iIndex].g_flSplatterChance = 33.3;
				g_esSplatterAbility[iIndex].g_flSplatterInterval = 5.0;
				g_esSplatterAbility[iIndex].g_iSplatterType = 0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esSplatterPlayer[iPlayer].g_iAccessFlags = 0;
					g_esSplatterPlayer[iPlayer].g_iComboAbility = 0;
					g_esSplatterPlayer[iPlayer].g_iHumanAbility = 0;
					g_esSplatterPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esSplatterPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esSplatterPlayer[iPlayer].g_iHumanDuration = 0;
					g_esSplatterPlayer[iPlayer].g_iHumanMode = 0;
					g_esSplatterPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esSplatterPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esSplatterPlayer[iPlayer].g_iSplatterAbility = 0;
					g_esSplatterPlayer[iPlayer].g_iSplatterMessage = 0;
					g_esSplatterPlayer[iPlayer].g_flSplatterChance = 0.0;
					g_esSplatterPlayer[iPlayer].g_flSplatterInterval = 0.0;
					g_esSplatterPlayer[iPlayer].g_iSplatterType = 0;
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vSplatterConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
#endif
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esSplatterPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esSplatterPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esSplatterPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esSplatterPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esSplatterPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esSplatterPlayer[admin].g_iHumanAmmo, value, 0, 99999);
		g_esSplatterPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esSplatterPlayer[admin].g_iHumanCooldown, value, 0, 99999);
		g_esSplatterPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esSplatterPlayer[admin].g_iHumanDuration, value, 1, 99999);
		g_esSplatterPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esSplatterPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esSplatterPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esSplatterPlayer[admin].g_flOpenAreasOnly, value, 0.0, 99999.0);
		g_esSplatterPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esSplatterPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esSplatterPlayer[admin].g_iSplatterAbility = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esSplatterPlayer[admin].g_iSplatterAbility, value, 0, 3);
		g_esSplatterPlayer[admin].g_iSplatterMessage = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esSplatterPlayer[admin].g_iSplatterMessage, value, 0, 1);
		g_esSplatterPlayer[admin].g_flSplatterChance = flGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "SplatterChance", "Splatter Chance", "Splatter_Chance", "chance", g_esSplatterPlayer[admin].g_flSplatterChance, value, 0.0, 100.0);
		g_esSplatterPlayer[admin].g_flSplatterInterval = flGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "SplatterInterval", "Splatter Interval", "Splatter_Interval", "interval", g_esSplatterPlayer[admin].g_flSplatterInterval, value, 0.1, 99999.0);
		g_esSplatterPlayer[admin].g_iSplatterType = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "SplatterType", "Splatter Type", "Splatter_Type", "type", g_esSplatterPlayer[admin].g_iSplatterType, value, 0, sizeof g_sParticles);
		g_esSplatterPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
	}

	if (mode < 3 && type > 0)
	{
		g_esSplatterAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esSplatterAbility[type].g_iComboAbility, value, 0, 1);
		g_esSplatterAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esSplatterAbility[type].g_iHumanAbility, value, 0, 2);
		g_esSplatterAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esSplatterAbility[type].g_iHumanAmmo, value, 0, 99999);
		g_esSplatterAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esSplatterAbility[type].g_iHumanCooldown, value, 0, 99999);
		g_esSplatterAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esSplatterAbility[type].g_iHumanDuration, value, 1, 99999);
		g_esSplatterAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esSplatterAbility[type].g_iHumanMode, value, 0, 1);
		g_esSplatterAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esSplatterAbility[type].g_flOpenAreasOnly, value, 0.0, 99999.0);
		g_esSplatterAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esSplatterAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esSplatterAbility[type].g_iSplatterAbility = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esSplatterAbility[type].g_iSplatterAbility, value, 0, 3);
		g_esSplatterAbility[type].g_iSplatterMessage = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esSplatterAbility[type].g_iSplatterMessage, value, 0, 1);
		g_esSplatterAbility[type].g_flSplatterChance = flGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "SplatterChance", "Splatter Chance", "Splatter_Chance", "chance", g_esSplatterAbility[type].g_flSplatterChance, value, 0.0, 100.0);
		g_esSplatterAbility[type].g_flSplatterInterval = flGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "SplatterInterval", "Splatter Interval", "Splatter_Interval", "interval", g_esSplatterAbility[type].g_flSplatterInterval, value, 0.1, 99999.0);
		g_esSplatterAbility[type].g_iSplatterType = iGetKeyValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "SplatterType", "Splatter Type", "Splatter_Type", "type", g_esSplatterAbility[type].g_iSplatterType, value, 0, sizeof g_sParticles);
		g_esSplatterAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_SPLATTER_SECTION, MT_SPLATTER_SECTION2, MT_SPLATTER_SECTION3, MT_SPLATTER_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
	}
}

#if defined MT_ABILITIES_MAIN2
void vSplatterSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	g_esSplatterCache[tank].g_flSplatterChance = flGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_flSplatterChance, g_esSplatterAbility[type].g_flSplatterChance);
	g_esSplatterCache[tank].g_flSplatterInterval = flGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_flSplatterInterval, g_esSplatterAbility[type].g_flSplatterInterval);
	g_esSplatterCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iComboAbility, g_esSplatterAbility[type].g_iComboAbility);
	g_esSplatterCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iHumanAbility, g_esSplatterAbility[type].g_iHumanAbility);
	g_esSplatterCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iHumanAmmo, g_esSplatterAbility[type].g_iHumanAmmo);
	g_esSplatterCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iHumanCooldown, g_esSplatterAbility[type].g_iHumanCooldown);
	g_esSplatterCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iHumanDuration, g_esSplatterAbility[type].g_iHumanDuration);
	g_esSplatterCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iHumanMode, g_esSplatterAbility[type].g_iHumanMode);
	g_esSplatterCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_flOpenAreasOnly, g_esSplatterAbility[type].g_flOpenAreasOnly);
	g_esSplatterCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iRequiresHumans, g_esSplatterAbility[type].g_iRequiresHumans);
	g_esSplatterCache[tank].g_iSplatterAbility = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iSplatterAbility, g_esSplatterAbility[type].g_iSplatterAbility);
	g_esSplatterCache[tank].g_iSplatterMessage = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iSplatterMessage, g_esSplatterAbility[type].g_iSplatterMessage);
	g_esSplatterCache[tank].g_iSplatterType = iGetSettingValue(apply, bHuman, g_esSplatterPlayer[tank].g_iSplatterType, g_esSplatterAbility[type].g_iSplatterType);
	g_esSplatterPlayer[tank].g_iTankType = apply ? type : 0;
}

#if defined MT_ABILITIES_MAIN2
void vSplatterCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vSplatterCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveSplatter(oldTank);
	}
}

#if defined MT_ABILITIES_MAIN2
void vSplatterEventFired(Event event, const char[] name)
#else
public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
#endif
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vSplatterCopyStats2(iBot, iTank);
			vRemoveSplatter(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vSplatterCopyStats2(iTank, iBot);
			vRemoveSplatter(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (g_bSecondGame && MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vSplatterRange(iTank, false);
			vRemoveSplatter(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vSplatterReset();
	}
}

#if defined MT_ABILITIES_MAIN2
void vSplatterAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (!g_bSecondGame || (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSplatterAbility[g_esSplatterPlayer[tank].g_iTankType].g_iAccessFlags, g_esSplatterPlayer[tank].g_iAccessFlags)) || g_esSplatterCache[tank].g_iHumanAbility == 0)))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esSplatterCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esSplatterCache[tank].g_iSplatterAbility == 1 && g_esSplatterCache[tank].g_iComboAbility == 0 && !g_esSplatterPlayer[tank].g_bActivated)
	{
		vSplatterAbility(tank);
	}
}

#if defined MT_ABILITIES_MAIN2
void vSplatterButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (!g_bSecondGame || bIsAreaNarrow(tank, g_esSplatterCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esSplatterPlayer[tank].g_iTankType) || (g_esSplatterCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSplatterCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSplatterAbility[g_esSplatterPlayer[tank].g_iTankType].g_iAccessFlags, g_esSplatterPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_MAIN_KEY)
		{
			if (g_esSplatterCache[tank].g_iSplatterAbility == 1 && g_esSplatterCache[tank].g_iHumanAbility == 1)
			{
				int iTime = GetTime();
				bool bRecharging = g_esSplatterPlayer[tank].g_iCooldown != -1 && g_esSplatterPlayer[tank].g_iCooldown > iTime;

				switch (g_esSplatterCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esSplatterPlayer[tank].g_bActivated && !bRecharging)
						{
							vSplatterAbility(tank);
						}
						else if (g_esSplatterPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterHuman4", (g_esSplatterPlayer[tank].g_iCooldown - iTime));
						}
					}
					case 1:
					{
						if (g_esSplatterPlayer[tank].g_iAmmoCount < g_esSplatterCache[tank].g_iHumanAmmo && g_esSplatterCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esSplatterPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esSplatterPlayer[tank].g_bActivated = true;
								g_esSplatterPlayer[tank].g_iAmmoCount++;

								vSplatter2(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterHuman", g_esSplatterPlayer[tank].g_iAmmoCount, g_esSplatterCache[tank].g_iHumanAmmo);
							}
							else if (g_esSplatterPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterHuman4", (g_esSplatterPlayer[tank].g_iCooldown - iTime));
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterAmmo");
						}
					}
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vSplatterButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esSplatterCache[tank].g_iHumanAbility == 1)
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esSplatterCache[tank].g_iHumanMode == 1 && g_esSplatterPlayer[tank].g_bActivated && (g_esSplatterPlayer[tank].g_iCooldown == -1 || g_esSplatterPlayer[tank].g_iCooldown < GetTime()))
			{
				vSplatterReset2(tank);
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vSplatterChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveSplatter(tank);
}

#if defined MT_ABILITIES_MAIN2
void vSplatterPostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	vSplatterRange(tank, true);
}

void vSplatterCopyStats2(int oldTank, int newTank)
{
	g_esSplatterPlayer[newTank].g_iAmmoCount = g_esSplatterPlayer[oldTank].g_iAmmoCount;
	g_esSplatterPlayer[newTank].g_iCooldown = g_esSplatterPlayer[oldTank].g_iCooldown;
}

void vRemoveSplatter(int tank)
{
	g_esSplatterPlayer[tank].g_bActivated = false;
	g_esSplatterPlayer[tank].g_iAmmoCount = 0;
	g_esSplatterPlayer[tank].g_iCooldown = -1;
}

void vSplatterReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveSplatter(iPlayer);
		}
	}
}

void vSplatterReset2(int tank)
{
	g_esSplatterPlayer[tank].g_bActivated = false;

	int iTime = GetTime();
	g_esSplatterPlayer[tank].g_iCooldown = (g_esSplatterPlayer[tank].g_iAmmoCount < g_esSplatterCache[tank].g_iHumanAmmo && g_esSplatterCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esSplatterCache[tank].g_iHumanCooldown) : -1;
	if (g_esSplatterPlayer[tank].g_iCooldown != -1 && g_esSplatterPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterHuman5", (g_esSplatterPlayer[tank].g_iCooldown - iTime));
	}
}

void vSplatter(int tank, int pos = -1)
{
	g_esSplatterPlayer[tank].g_bActivated = true;

	vSplatter2(tank, pos);

	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSplatterCache[tank].g_iHumanAbility == 1)
	{
		g_esSplatterPlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterHuman", g_esSplatterPlayer[tank].g_iAmmoCount, g_esSplatterCache[tank].g_iHumanAmmo);
	}

	if (g_esSplatterCache[tank].g_iSplatterMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Splatter", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Splatter", LANG_SERVER, sTankName);
	}
}

void vSplatter2(int tank, int pos = -1)
{
	if (!g_bSecondGame || bIsAreaNarrow(tank, g_esSplatterCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esSplatterPlayer[tank].g_iTankType) || (g_esSplatterCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSplatterCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSplatterAbility[g_esSplatterPlayer[tank].g_iTankType].g_iAccessFlags, g_esSplatterPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : g_esSplatterCache[tank].g_flSplatterInterval;
	DataPack dpSplatter;
	CreateDataTimer(flInterval, tTimerSplatter, dpSplatter, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpSplatter.WriteCell(GetClientUserId(tank));
	dpSplatter.WriteCell(g_esSplatterPlayer[tank].g_iTankType);
	dpSplatter.WriteCell(GetTime());
}

void vSplatterAbility(int tank)
{
	if (!g_bSecondGame || bIsAreaNarrow(tank, g_esSplatterCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esSplatterPlayer[tank].g_iTankType) || (g_esSplatterCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSplatterCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSplatterAbility[g_esSplatterPlayer[tank].g_iTankType].g_iAccessFlags, g_esSplatterPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esSplatterPlayer[tank].g_iAmmoCount < g_esSplatterCache[tank].g_iHumanAmmo && g_esSplatterCache[tank].g_iHumanAmmo > 0))
	{
		if (MT_GetRandomFloat(0.1, 100.0) <= g_esSplatterCache[tank].g_flSplatterChance)
		{
			vSplatter(tank);
		}
		else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSplatterCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterHuman2");
		}
	}
	else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSplatterCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplatterAmmo");
	}
}

void vSplatterRange(int tank, bool idle)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && g_esSplatterCache[tank].g_iSplatterAbility == 1 && MT_GetRandomFloat(0.1, 100.0) <= g_esSplatterCache[tank].g_flSplatterChance)
	{
		if (!g_bSecondGame || (idle && MT_IsTankIdle(tank)) || bIsAreaNarrow(tank, g_esSplatterCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esSplatterPlayer[tank].g_iTankType) || (g_esSplatterCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSplatterCache[tank].g_iRequiresHumans) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSplatterAbility[g_esSplatterPlayer[tank].g_iTankType].g_iAccessFlags, g_esSplatterPlayer[tank].g_iAccessFlags)) || g_esSplatterCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		char sParticle[40];
		FormatEx(sParticle, sizeof sParticle, "%s", (g_esSplatterCache[tank].g_iSplatterType > 0) ? g_sParticles[g_esSplatterCache[tank].g_iSplatterType - 1] : g_sParticles[MT_GetRandomInt(0, (sizeof g_sParticles - 1))]);
		vAttachParticle(tank, sParticle, 10.0, .teleport = false);
	}
}

Action tTimerSplatterCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!g_bSecondGame || !MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esSplatterAbility[g_esSplatterPlayer[iTank].g_iTankType].g_iAccessFlags, g_esSplatterPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esSplatterPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esSplatterCache[iTank].g_iSplatterAbility == 0 || g_esSplatterPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vSplatter(iTank, iPos);

	return Plugin_Continue;
}

Action tTimerSplatter(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!g_bSecondGame || !MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esSplatterCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esSplatterPlayer[iTank].g_iTankType) || (g_esSplatterCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSplatterCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esSplatterAbility[g_esSplatterPlayer[iTank].g_iTankType].g_iAccessFlags, g_esSplatterPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esSplatterPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esSplatterPlayer[iTank].g_iTankType || g_esSplatterCache[iTank].g_iSplatterAbility == 0 || !g_esSplatterPlayer[iTank].g_bActivated)
	{
		g_esSplatterPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	int iTime = pack.ReadCell(), iCurrentTime = GetTime();
	if (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_esSplatterCache[iTank].g_iHumanAbility == 1 && g_esSplatterCache[iTank].g_iHumanMode == 0 && (iTime + g_esSplatterCache[iTank].g_iHumanDuration) < iCurrentTime && (g_esSplatterPlayer[iTank].g_iCooldown == -1 || g_esSplatterPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vSplatterReset2(iTank);

		return Plugin_Stop;
	}

	char sParticle[40];
	FormatEx(sParticle, sizeof sParticle, "%s", (g_esSplatterCache[iTank].g_iSplatterType > 0) ? g_sParticles[g_esSplatterCache[iTank].g_iSplatterType - 1] : g_sParticles[MT_GetRandomInt(0, (sizeof g_sParticles - 1))]);
	vAttachParticle(iTank, sParticle, 10.0, .teleport = false);

	if (g_esSplatterCache[iTank].g_iSplatterMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(iTank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Splatter2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Splatter2", LANG_SERVER, sTankName);
	}

	return Plugin_Continue;
}