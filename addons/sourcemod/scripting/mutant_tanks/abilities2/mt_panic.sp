/**
 * Mutant Tanks: A L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2017-2025  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_PANIC_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_PANIC_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Panic Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank starts panic events and spawns zombies.",
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
			strcopy(error, err_max, "\"[MT] Panic Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();

	return APLRes_Success;
}

#define MODEL_CEDA "models/infected/common_male_ceda.mdl"
#define MODEL_CLOWN "models/infected/common_male_clown.mdl"
#define MODEL_FALLEN "models/infected/common_male_fallen_survivor.mdl"
#define MODEL_JIMMY "models/infected/common_male_jimmy.mdl"
#define MODEL_MUDMAN "models/infected/common_male_mud.mdl"
#define MODEL_RIOTCOP "models/infected/common_male_riot.mdl"
#define MODEL_ROADCREW "models/infected/common_male_roadcrew.mdl"
#else
	#if MT_PANIC_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_PANIC_SECTION "panicability"
#define MT_PANIC_SECTION2 "panic ability"
#define MT_PANIC_SECTION3 "panic_ability"
#define MT_PANIC_SECTION4 "panic"

#define MT_MENU_PANIC "Panic Ability"

enum struct esPanicPlayer
{
	bool g_bActivated;

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPanicChance;
	float g_flPanicInterval;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iPanicAbility;
	int g_iPanicAmount;
	int g_iPanicCooldown;
	int g_iPanicDuration;
	int g_iPanicMessage;
	int g_iPanicMode;
	int g_iPanicType;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esPanicPlayer g_esPanicPlayer[MAXPLAYERS + 1];

enum struct esPanicTeammate
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPanicChance;
	float g_flPanicInterval;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iPanicAbility;
	int g_iPanicAmount;
	int g_iPanicCooldown;
	int g_iPanicDuration;
	int g_iPanicMessage;
	int g_iPanicMode;
	int g_iPanicType;
	int g_iRequiresHumans;
}

esPanicTeammate g_esPanicTeammate[MAXPLAYERS + 1];

enum struct esPanicAbility
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPanicChance;
	float g_flPanicInterval;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iPanicAbility;
	int g_iPanicAmount;
	int g_iPanicCooldown;
	int g_iPanicDuration;
	int g_iPanicMessage;
	int g_iPanicMode;
	int g_iPanicType;
	int g_iRequiresHumans;
}

esPanicAbility g_esPanicAbility[MT_MAXTYPES + 1];

enum struct esPanicSpecial
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPanicChance;
	float g_flPanicInterval;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iPanicAbility;
	int g_iPanicAmount;
	int g_iPanicCooldown;
	int g_iPanicDuration;
	int g_iPanicMessage;
	int g_iPanicMode;
	int g_iPanicType;
	int g_iRequiresHumans;
}

esPanicSpecial g_esPanicSpecial[MT_MAXTYPES + 1];

enum struct esPanicCache
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPanicChance;
	float g_flPanicInterval;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iPanicAbility;
	int g_iPanicAmount;
	int g_iPanicCooldown;
	int g_iPanicDuration;
	int g_iPanicMessage;
	int g_iPanicMode;
	int g_iPanicType;
	int g_iRequiresHumans;
}

esPanicCache g_esPanicCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_panic", cmdPanicInfo, "View information about the Panic ability.");
}
#endif

#if defined MT_ABILITIES_MAIN2
void vPanicMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheModel(MODEL_CEDA, true);
	PrecacheModel(MODEL_CLOWN, true);
	PrecacheModel(MODEL_FALLEN, true);
	PrecacheModel(MODEL_JIMMY, true);
	PrecacheModel(MODEL_MUDMAN, true);
	PrecacheModel(MODEL_RIOTCOP, true);
	PrecacheModel(MODEL_ROADCREW, true);

	vPanicReset();
}

#if defined MT_ABILITIES_MAIN2
void vPanicClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	vRemovePanic(client);
}

#if defined MT_ABILITIES_MAIN2
void vPanicClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemovePanic(client);
}

#if defined MT_ABILITIES_MAIN2
void vPanicMapEnd()
#else
public void OnMapEnd()
#endif
{
	vPanicReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdPanicInfo(int client, int args)
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
		case false: vPanicMenu(client, MT_PANIC_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vPanicMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_PANIC_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iPanicMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Panic Ability Information");
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

int iPanicMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esPanicCache[param1].g_iPanicAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esPanicCache[param1].g_iHumanAmmo - g_esPanicPlayer[param1].g_iAmmoCount), g_esPanicCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3:
				{
					switch (g_esPanicCache[param1].g_iHumanMode)
					{
						case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode1");
						case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode2");
						case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode3");
					}
				}
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esPanicCache[param1].g_iHumanAbility == 1) ? g_esPanicCache[param1].g_iHumanCooldown : g_esPanicCache[param1].g_iPanicCooldown));
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "PanicDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", ((g_esPanicCache[param1].g_iHumanAbility == 1) ? g_esPanicCache[param1].g_iHumanDuration : g_esPanicCache[param1].g_iPanicDuration));
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esPanicCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vPanicMenu(param1, MT_PANIC_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pPanic = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "PanicMenu", param1);
			pPanic.SetTitle(sMenuTitle);
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
void vPanicDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_PANIC, MT_MENU_PANIC);
}

#if defined MT_ABILITIES_MAIN2
void vPanicMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_PANIC, false))
	{
		vPanicMenu(client, MT_PANIC_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_PANIC, false))
	{
		FormatEx(buffer, size, "%T", "PanicMenu2", client);
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_PANIC);
}

#if defined MT_ABILITIES_MAIN2
void vPanicAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_PANIC_SECTION);
	list2.PushString(MT_PANIC_SECTION2);
	list3.PushString(MT_PANIC_SECTION3);
	list4.PushString(MT_PANIC_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vPanicCombineAbilities(int tank, int type, const float random, const char[] combo)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPanicCache[tank].g_iHumanAbility != 2)
	{
		g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

		return;
	}

	g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_PANIC_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_PANIC_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_PANIC_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_PANIC_SECTION4);
	if (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esPanicCache[tank].g_iPanicAbility > 0 && g_esPanicCache[tank].g_iComboAbility == 1 && !g_esPanicPlayer[tank].g_bActivated)
		{
			char sAbilities[320], sSubset[10][32];
			strcopy(sAbilities, sizeof sAbilities, combo);
			ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

			float flDelay = 0.0;
			for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_PANIC_SECTION, false) || StrEqual(sSubset[iPos], MT_PANIC_SECTION2, false) || StrEqual(sSubset[iPos], MT_PANIC_SECTION3, false) || StrEqual(sSubset[iPos], MT_PANIC_SECTION4, false))
				{
					g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = iPos;

					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						flDelay = MT_GetCombinationSetting(tank, 4, iPos);

						switch (flDelay)
						{
							case 0.0: vPanic(tank, iPos);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerPanicCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteCell(iPos);
							}
						}
					}

					break;
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicConfigsLoad(int mode)
#else
public void MT_OnConfigsLoad(int mode)
#endif
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esPanicAbility[iIndex].g_iAccessFlags = 0;
				g_esPanicAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esPanicAbility[iIndex].g_iComboAbility = 0;
				g_esPanicAbility[iIndex].g_iComboPosition = -1;
				g_esPanicAbility[iIndex].g_iHumanAbility = 0;
				g_esPanicAbility[iIndex].g_iHumanAmmo = 5;
				g_esPanicAbility[iIndex].g_iHumanCooldown = 0;
				g_esPanicAbility[iIndex].g_iHumanDuration = 5;
				g_esPanicAbility[iIndex].g_iHumanMode = 1;
				g_esPanicAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esPanicAbility[iIndex].g_iRequiresHumans = 0;
				g_esPanicAbility[iIndex].g_iPanicAbility = 0;
				g_esPanicAbility[iIndex].g_iPanicMessage = 0;
				g_esPanicAbility[iIndex].g_iPanicAmount = 10;
				g_esPanicAbility[iIndex].g_flPanicChance = 33.3;
				g_esPanicAbility[iIndex].g_iPanicCooldown = 0;
				g_esPanicAbility[iIndex].g_iPanicDuration = 0;
				g_esPanicAbility[iIndex].g_flPanicInterval = 5.0;
				g_esPanicAbility[iIndex].g_iPanicMode = 0;
				g_esPanicAbility[iIndex].g_iPanicType = 0;

				g_esPanicSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esPanicSpecial[iIndex].g_iComboAbility = -1;
				g_esPanicSpecial[iIndex].g_iHumanAbility = -1;
				g_esPanicSpecial[iIndex].g_iHumanAmmo = -1;
				g_esPanicSpecial[iIndex].g_iHumanCooldown = -1;
				g_esPanicSpecial[iIndex].g_iHumanDuration = -1;
				g_esPanicSpecial[iIndex].g_iHumanMode = -1;
				g_esPanicSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esPanicSpecial[iIndex].g_iRequiresHumans = -1;
				g_esPanicSpecial[iIndex].g_iPanicAbility = -1;
				g_esPanicSpecial[iIndex].g_iPanicMessage = -1;
				g_esPanicSpecial[iIndex].g_iPanicAmount = -1;
				g_esPanicSpecial[iIndex].g_flPanicChance = -1.0;
				g_esPanicSpecial[iIndex].g_iPanicCooldown = -1;
				g_esPanicSpecial[iIndex].g_iPanicDuration = -1;
				g_esPanicSpecial[iIndex].g_flPanicInterval = -1.0;
				g_esPanicSpecial[iIndex].g_iPanicMode = -1;
				g_esPanicSpecial[iIndex].g_iPanicType = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esPanicPlayer[iPlayer].g_iAccessFlags = -1;
				g_esPanicPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esPanicPlayer[iPlayer].g_iComboAbility = -1;
				g_esPanicPlayer[iPlayer].g_iHumanAbility = -1;
				g_esPanicPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esPanicPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esPanicPlayer[iPlayer].g_iHumanDuration = -1;
				g_esPanicPlayer[iPlayer].g_iHumanMode = -1;
				g_esPanicPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esPanicPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esPanicPlayer[iPlayer].g_iPanicAbility = -1;
				g_esPanicPlayer[iPlayer].g_iPanicMessage = -1;
				g_esPanicPlayer[iPlayer].g_iPanicAmount = -1;
				g_esPanicPlayer[iPlayer].g_flPanicChance = -1.0;
				g_esPanicPlayer[iPlayer].g_iPanicCooldown = -1;
				g_esPanicPlayer[iPlayer].g_iPanicDuration = -1;
				g_esPanicPlayer[iPlayer].g_flPanicInterval = -1.0;
				g_esPanicPlayer[iPlayer].g_iPanicMode = -1;
				g_esPanicPlayer[iPlayer].g_iPanicType = -1;

				g_esPanicTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esPanicTeammate[iPlayer].g_iComboAbility = -1;
				g_esPanicTeammate[iPlayer].g_iHumanAbility = -1;
				g_esPanicTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esPanicTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esPanicTeammate[iPlayer].g_iHumanDuration = -1;
				g_esPanicTeammate[iPlayer].g_iHumanMode = -1;
				g_esPanicTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esPanicTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esPanicTeammate[iPlayer].g_iPanicAbility = -1;
				g_esPanicTeammate[iPlayer].g_iPanicMessage = -1;
				g_esPanicTeammate[iPlayer].g_iPanicAmount = -1;
				g_esPanicTeammate[iPlayer].g_flPanicChance = -1.0;
				g_esPanicTeammate[iPlayer].g_iPanicCooldown = -1;
				g_esPanicTeammate[iPlayer].g_iPanicDuration = -1;
				g_esPanicTeammate[iPlayer].g_flPanicInterval = -1.0;
				g_esPanicTeammate[iPlayer].g_iPanicMode = -1;
				g_esPanicTeammate[iPlayer].g_iPanicType = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esPanicTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esPanicTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esPanicTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPanicTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esPanicTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPanicTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esPanicTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPanicTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esPanicTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPanicTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esPanicTeammate[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPanicTeammate[admin].g_iHumanDuration, value, -1, 99999);
			g_esPanicTeammate[admin].g_iHumanMode = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPanicTeammate[admin].g_iHumanMode, value, -1, 2);
			g_esPanicTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPanicTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esPanicTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPanicTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esPanicTeammate[admin].g_iPanicAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPanicTeammate[admin].g_iPanicAbility, value, -1, 3);
			g_esPanicTeammate[admin].g_iPanicMessage = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPanicTeammate[admin].g_iPanicMessage, value, -1, 1);
			g_esPanicTeammate[admin].g_iPanicAmount = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicAmount", "Panic Amount", "Panic_Amount", "amount", g_esPanicTeammate[admin].g_iPanicAmount, value, -1, 100);
			g_esPanicTeammate[admin].g_flPanicChance = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicChance", "Panic Chance", "Panic_Chance", "chance", g_esPanicTeammate[admin].g_flPanicChance, value, -1.0, 100.0);
			g_esPanicTeammate[admin].g_iPanicCooldown = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicCooldown", "Panic Cooldown", "Panic_Cooldown", "cooldown", g_esPanicTeammate[admin].g_iPanicCooldown, value, -1, 99999);
			g_esPanicTeammate[admin].g_iPanicDuration = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicDuration", "Panic Duration", "Panic_Duration", "duration", g_esPanicTeammate[admin].g_iPanicDuration, value, -1, 99999);
			g_esPanicTeammate[admin].g_flPanicInterval = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicInterval", "Panic Interval", "Panic_Interval", "interval", g_esPanicTeammate[admin].g_flPanicInterval, value, -1.0, 99999.0);
			g_esPanicTeammate[admin].g_iPanicMode = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicMode", "Panic Mode", "Panic_Mode", "mode", g_esPanicTeammate[admin].g_iPanicMode, value, -1, 2);
			g_esPanicTeammate[admin].g_iPanicType = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicType", "Panic Type", "Panic_Type", "type", g_esPanicTeammate[admin].g_iPanicType, value, -1, 127);
		}
		else
		{
			g_esPanicPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esPanicPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esPanicPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPanicPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esPanicPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPanicPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esPanicPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPanicPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esPanicPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPanicPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esPanicPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPanicPlayer[admin].g_iHumanDuration, value, -1, 99999);
			g_esPanicPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPanicPlayer[admin].g_iHumanMode, value, -1, 2);
			g_esPanicPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPanicPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esPanicPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPanicPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esPanicPlayer[admin].g_iPanicAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPanicPlayer[admin].g_iPanicAbility, value, -1, 3);
			g_esPanicPlayer[admin].g_iPanicMessage = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPanicPlayer[admin].g_iPanicMessage, value, -1, 1);
			g_esPanicPlayer[admin].g_iPanicAmount = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicAmount", "Panic Amount", "Panic_Amount", "amount", g_esPanicPlayer[admin].g_iPanicAmount, value, -1, 100);
			g_esPanicPlayer[admin].g_flPanicChance = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicChance", "Panic Chance", "Panic_Chance", "chance", g_esPanicPlayer[admin].g_flPanicChance, value, -1.0, 100.0);
			g_esPanicPlayer[admin].g_iPanicCooldown = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicCooldown", "Panic Cooldown", "Panic_Cooldown", "cooldown", g_esPanicPlayer[admin].g_iPanicCooldown, value, -1, 99999);
			g_esPanicPlayer[admin].g_iPanicDuration = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicDuration", "Panic Duration", "Panic_Duration", "duration", g_esPanicPlayer[admin].g_iPanicDuration, value, -1, 99999);
			g_esPanicPlayer[admin].g_flPanicInterval = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicInterval", "Panic Interval", "Panic_Interval", "interval", g_esPanicPlayer[admin].g_flPanicInterval, value, -1.0, 99999.0);
			g_esPanicPlayer[admin].g_iPanicMode = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicMode", "Panic Mode", "Panic_Mode", "mode", g_esPanicPlayer[admin].g_iPanicMode, value, -1, 2);
			g_esPanicPlayer[admin].g_iPanicType = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicType", "Panic Type", "Panic_Type", "type", g_esPanicPlayer[admin].g_iPanicType, value, -1, 127);
			g_esPanicPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esPanicSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esPanicSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esPanicSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPanicSpecial[type].g_iComboAbility, value, -1, 1);
			g_esPanicSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPanicSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esPanicSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPanicSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esPanicSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPanicSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esPanicSpecial[type].g_iHumanDuration = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPanicSpecial[type].g_iHumanDuration, value, -1, 99999);
			g_esPanicSpecial[type].g_iHumanMode = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPanicSpecial[type].g_iHumanMode, value, -1, 2);
			g_esPanicSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPanicSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esPanicSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPanicSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esPanicSpecial[type].g_iPanicAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPanicSpecial[type].g_iPanicAbility, value, -1, 3);
			g_esPanicSpecial[type].g_iPanicMessage = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPanicSpecial[type].g_iPanicMessage, value, -1, 1);
			g_esPanicSpecial[type].g_iPanicAmount = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicAmount", "Panic Amount", "Panic_Amount", "amount", g_esPanicSpecial[type].g_iPanicAmount, value, -1, 100);
			g_esPanicSpecial[type].g_flPanicChance = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicChance", "Panic Chance", "Panic_Chance", "chance", g_esPanicSpecial[type].g_flPanicChance, value, -1.0, 100.0);
			g_esPanicSpecial[type].g_iPanicCooldown = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicCooldown", "Panic Cooldown", "Panic_Cooldown", "cooldown", g_esPanicSpecial[type].g_iPanicCooldown, value, -1, 99999);
			g_esPanicSpecial[type].g_iPanicDuration = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicDuration", "Panic Duration", "Panic_Duration", "duration", g_esPanicSpecial[type].g_iPanicDuration, value, -1, 99999);
			g_esPanicSpecial[type].g_flPanicInterval = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicInterval", "Panic Interval", "Panic_Interval", "interval", g_esPanicSpecial[type].g_flPanicInterval, value, -1.0, 99999.0);
			g_esPanicSpecial[type].g_iPanicMode = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicMode", "Panic Mode", "Panic_Mode", "mode", g_esPanicSpecial[type].g_iPanicMode, value, -1, 2);
			g_esPanicSpecial[type].g_iPanicType = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicType", "Panic Type", "Panic_Type", "type", g_esPanicSpecial[type].g_iPanicType, value, -1, 127);
		}
		else
		{
			g_esPanicAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esPanicAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esPanicAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPanicAbility[type].g_iComboAbility, value, -1, 1);
			g_esPanicAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPanicAbility[type].g_iHumanAbility, value, -1, 2);
			g_esPanicAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPanicAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esPanicAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPanicAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esPanicAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPanicAbility[type].g_iHumanDuration, value, -1, 99999);
			g_esPanicAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPanicAbility[type].g_iHumanMode, value, -1, 2);
			g_esPanicAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPanicAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esPanicAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPanicAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esPanicAbility[type].g_iPanicAbility = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPanicAbility[type].g_iPanicAbility, value, -1, 3);
			g_esPanicAbility[type].g_iPanicMessage = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPanicAbility[type].g_iPanicMessage, value, -1, 1);
			g_esPanicAbility[type].g_iPanicAmount = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicAmount", "Panic Amount", "Panic_Amount", "amount", g_esPanicAbility[type].g_iPanicAmount, value, -1, 100);
			g_esPanicAbility[type].g_flPanicChance = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicChance", "Panic Chance", "Panic_Chance", "chance", g_esPanicAbility[type].g_flPanicChance, value, -1.0, 100.0);
			g_esPanicAbility[type].g_iPanicCooldown = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicCooldown", "Panic Cooldown", "Panic_Cooldown", "cooldown", g_esPanicAbility[type].g_iPanicCooldown, value, -1, 99999);
			g_esPanicAbility[type].g_iPanicDuration = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicDuration", "Panic Duration", "Panic_Duration", "duration", g_esPanicAbility[type].g_iPanicDuration, value, -1, 99999);
			g_esPanicAbility[type].g_flPanicInterval = flGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicInterval", "Panic Interval", "Panic_Interval", "interval", g_esPanicAbility[type].g_flPanicInterval, value, -1.0, 99999.0);
			g_esPanicAbility[type].g_iPanicMode = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicMode", "Panic Mode", "Panic_Mode", "mode", g_esPanicAbility[type].g_iPanicMode, value, -1, 2);
			g_esPanicAbility[type].g_iPanicType = iGetKeyValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "PanicType", "Panic Type", "Panic_Type", "type", g_esPanicAbility[type].g_iPanicType, value, -1, 127);
			g_esPanicAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_PANIC_SECTION, MT_PANIC_SECTION2, MT_PANIC_SECTION3, MT_PANIC_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esPanicPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esPanicPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esPanicPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esPanicCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_flCloseAreasOnly, g_esPanicPlayer[tank].g_flCloseAreasOnly, g_esPanicSpecial[iType].g_flCloseAreasOnly, g_esPanicAbility[iType].g_flCloseAreasOnly, 1);
		g_esPanicCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iComboAbility, g_esPanicPlayer[tank].g_iComboAbility, g_esPanicSpecial[iType].g_iComboAbility, g_esPanicAbility[iType].g_iComboAbility, 1);
		g_esPanicCache[tank].g_flPanicChance = flGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_flPanicChance, g_esPanicPlayer[tank].g_flPanicChance, g_esPanicSpecial[iType].g_flPanicChance, g_esPanicAbility[iType].g_flPanicChance, 1);
		g_esPanicCache[tank].g_flPanicInterval = flGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_flPanicInterval, g_esPanicPlayer[tank].g_flPanicInterval, g_esPanicSpecial[iType].g_flPanicInterval, g_esPanicAbility[iType].g_flPanicInterval, 1);
		g_esPanicCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iHumanAbility, g_esPanicPlayer[tank].g_iHumanAbility, g_esPanicSpecial[iType].g_iHumanAbility, g_esPanicAbility[iType].g_iHumanAbility, 1);
		g_esPanicCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iHumanAmmo, g_esPanicPlayer[tank].g_iHumanAmmo, g_esPanicSpecial[iType].g_iHumanAmmo, g_esPanicAbility[iType].g_iHumanAmmo, 1);
		g_esPanicCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iHumanCooldown, g_esPanicPlayer[tank].g_iHumanCooldown, g_esPanicSpecial[iType].g_iHumanCooldown, g_esPanicAbility[iType].g_iHumanCooldown, 1);
		g_esPanicCache[tank].g_iHumanDuration = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iHumanDuration, g_esPanicPlayer[tank].g_iHumanDuration, g_esPanicSpecial[iType].g_iHumanDuration, g_esPanicAbility[iType].g_iHumanDuration, 1);
		g_esPanicCache[tank].g_iHumanMode = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iHumanMode, g_esPanicPlayer[tank].g_iHumanMode, g_esPanicSpecial[iType].g_iHumanMode, g_esPanicAbility[iType].g_iHumanMode, 1);
		g_esPanicCache[tank].g_iPanicAbility = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iPanicAbility, g_esPanicPlayer[tank].g_iPanicAbility, g_esPanicSpecial[iType].g_iPanicAbility, g_esPanicAbility[iType].g_iPanicAbility, 1);
		g_esPanicCache[tank].g_iPanicAmount = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iPanicAmount, g_esPanicPlayer[tank].g_iPanicAmount, g_esPanicSpecial[iType].g_iPanicAmount, g_esPanicAbility[iType].g_iPanicAmount, 1);
		g_esPanicCache[tank].g_iPanicCooldown = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iPanicCooldown, g_esPanicPlayer[tank].g_iPanicCooldown, g_esPanicSpecial[iType].g_iPanicCooldown, g_esPanicAbility[iType].g_iPanicCooldown, 1);
		g_esPanicCache[tank].g_iPanicDuration = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iPanicDuration, g_esPanicPlayer[tank].g_iPanicDuration, g_esPanicSpecial[iType].g_iPanicDuration, g_esPanicAbility[iType].g_iPanicDuration, 1);
		g_esPanicCache[tank].g_iPanicMessage = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iPanicMessage, g_esPanicPlayer[tank].g_iPanicMessage, g_esPanicSpecial[iType].g_iPanicMessage, g_esPanicAbility[iType].g_iPanicMessage, 1);
		g_esPanicCache[tank].g_iPanicMode = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iPanicMode, g_esPanicPlayer[tank].g_iPanicMode, g_esPanicSpecial[iType].g_iPanicMode, g_esPanicAbility[iType].g_iPanicMode, 1);
		g_esPanicCache[tank].g_iPanicType = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iPanicType, g_esPanicPlayer[tank].g_iPanicType, g_esPanicSpecial[iType].g_iPanicType, g_esPanicAbility[iType].g_iPanicType, 1);
		g_esPanicCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_flOpenAreasOnly, g_esPanicPlayer[tank].g_flOpenAreasOnly, g_esPanicSpecial[iType].g_flOpenAreasOnly, g_esPanicAbility[iType].g_flOpenAreasOnly, 1);
		g_esPanicCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esPanicTeammate[tank].g_iRequiresHumans, g_esPanicPlayer[tank].g_iRequiresHumans, g_esPanicSpecial[iType].g_iRequiresHumans, g_esPanicAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esPanicCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_flCloseAreasOnly, g_esPanicAbility[iType].g_flCloseAreasOnly, 1);
		g_esPanicCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iComboAbility, g_esPanicAbility[iType].g_iComboAbility, 1);
		g_esPanicCache[tank].g_flPanicChance = flGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_flPanicChance, g_esPanicAbility[iType].g_flPanicChance, 1);
		g_esPanicCache[tank].g_flPanicInterval = flGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_flPanicInterval, g_esPanicAbility[iType].g_flPanicInterval, 1);
		g_esPanicCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iHumanAbility, g_esPanicAbility[iType].g_iHumanAbility, 1);
		g_esPanicCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iHumanAmmo, g_esPanicAbility[iType].g_iHumanAmmo, 1);
		g_esPanicCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iHumanCooldown, g_esPanicAbility[iType].g_iHumanCooldown, 1);
		g_esPanicCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iHumanDuration, g_esPanicAbility[iType].g_iHumanDuration, 1);
		g_esPanicCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iHumanMode, g_esPanicAbility[iType].g_iHumanMode, 1);
		g_esPanicCache[tank].g_iPanicAbility = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iPanicAbility, g_esPanicAbility[iType].g_iPanicAbility, 1);
		g_esPanicCache[tank].g_iPanicAmount = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iPanicAmount, g_esPanicAbility[iType].g_iPanicAmount, 1);
		g_esPanicCache[tank].g_iPanicCooldown = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iPanicCooldown, g_esPanicAbility[iType].g_iPanicCooldown, 1);
		g_esPanicCache[tank].g_iPanicDuration = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iPanicDuration, g_esPanicAbility[iType].g_iPanicDuration, 1);
		g_esPanicCache[tank].g_iPanicMessage = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iPanicMessage, g_esPanicAbility[iType].g_iPanicMessage, 1);
		g_esPanicCache[tank].g_iPanicMode = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iPanicMode, g_esPanicAbility[iType].g_iPanicMode, 1);
		g_esPanicCache[tank].g_iPanicType = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iPanicType, g_esPanicAbility[iType].g_iPanicType, 1);
		g_esPanicCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_flOpenAreasOnly, g_esPanicAbility[iType].g_flOpenAreasOnly, 1);
		g_esPanicCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPanicPlayer[tank].g_iRequiresHumans, g_esPanicAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vPanicCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemovePanic(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vPanicEventFired(Event event, const char[] name)
#else
public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
#endif
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsInfected(iTank))
		{
			vPanicCopyStats2(iBot, iTank);
			vRemovePanic(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vPanicReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vPanicCopyStats2(iTank, iBot);
			vRemovePanic(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vPanicRange(iTank, false);
			vRemovePanic(iTank);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPanicPlayer[tank].g_iAccessFlags)) || g_esPanicCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esPanicCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esPanicCache[tank].g_iPanicAbility > 0 && g_esPanicCache[tank].g_iComboAbility == 0 && !g_esPanicPlayer[tank].g_bActivated)
	{
		vPanicAbility(tank);
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esPanicCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esPanicCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPanicPlayer[tank].g_iTankType, tank) || (g_esPanicCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPanicCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPanicPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_MAIN_KEY) && g_esPanicCache[tank].g_iPanicAbility > 0 && g_esPanicCache[tank].g_iHumanAbility == 1)
		{
			int iHumanMode = g_esPanicCache[tank].g_iHumanMode, iTime = GetTime();
			bool bRecharging = g_esPanicPlayer[tank].g_iCooldown != -1 && g_esPanicPlayer[tank].g_iCooldown >= iTime;

			switch (iHumanMode)
			{
				case 0:
				{
					if (!g_esPanicPlayer[tank].g_bActivated && !bRecharging)
					{
						vPanicAbility(tank);
					}
					else if (g_esPanicPlayer[tank].g_bActivated)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicHuman3");
					}
					else if (bRecharging)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicHuman4", (g_esPanicPlayer[tank].g_iCooldown - iTime));
					}
				}
				case 1, 2:
				{
					if ((iHumanMode == 2 && g_esPanicPlayer[tank].g_bActivated) || (g_esPanicPlayer[tank].g_iAmmoCount < g_esPanicCache[tank].g_iHumanAmmo && g_esPanicCache[tank].g_iHumanAmmo > 0))
					{
						if (!g_esPanicPlayer[tank].g_bActivated && !bRecharging)
						{
							g_esPanicPlayer[tank].g_bActivated = true;
							g_esPanicPlayer[tank].g_iAmmoCount++;

							vPanic2(tank);
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicHuman", g_esPanicPlayer[tank].g_iAmmoCount, g_esPanicCache[tank].g_iHumanAmmo);
						}
						else if (g_esPanicPlayer[tank].g_bActivated)
						{
							switch (iHumanMode)
							{
								case 1: MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicHuman3");
								case 2: vPanicReset2(tank);
							}
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicHuman4", (g_esPanicPlayer[tank].g_iCooldown - iTime));
						}
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicAmmo");
					}
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esPanicCache[tank].g_iHumanAbility == 1)
	{
		if ((button & MT_MAIN_KEY) && g_esPanicCache[tank].g_iHumanMode == 1 && g_esPanicPlayer[tank].g_bActivated && (g_esPanicPlayer[tank].g_iCooldown == -1 || g_esPanicPlayer[tank].g_iCooldown <= GetTime()))
		{
			vPanicReset2(tank);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPanicChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemovePanic(tank);
}

#if defined MT_ABILITIES_MAIN2
void vPanicPostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	vPanicRange(tank, true);
}

void vPanic(int tank, int pos = -1)
{
	if (g_esPanicPlayer[tank].g_iCooldown != -1 && g_esPanicPlayer[tank].g_iCooldown >= GetTime())
	{
		return;
	}

	g_esPanicPlayer[tank].g_bActivated = true;

	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPanicCache[tank].g_iHumanAbility == 1)
	{
		g_esPanicPlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicHuman", g_esPanicPlayer[tank].g_iAmmoCount, g_esPanicCache[tank].g_iHumanAmmo);
	}

	vPanic2(tank, pos);

	if (g_esPanicCache[tank].g_iPanicMessage == 1)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Panic", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Panic", LANG_SERVER, sTankName);
	}
}

void vPanic2(int tank, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esPanicCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esPanicCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPanicPlayer[tank].g_iTankType, tank) || (g_esPanicCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPanicCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPanicPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 6, pos) : g_esPanicCache[tank].g_flPanicInterval;
	if (flInterval > 0.0)
	{
		DataPack dpPanic;
		CreateDataTimer(flInterval, tTimerPanic, dpPanic, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpPanic.WriteCell(GetClientUserId(tank));
		dpPanic.WriteCell(g_esPanicPlayer[tank].g_iTankType);
		dpPanic.WriteCell(GetTime());
		dpPanic.WriteCell(pos);
	}
}

void vPanic3(int tank)
{
	if (bIsAreaNarrow(tank, g_esPanicCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esPanicCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPanicPlayer[tank].g_iTankType, tank) || (g_esPanicCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPanicCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPanicPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (g_esPanicCache[tank].g_iPanicAbility == 1 || g_esPanicCache[tank].g_iPanicAbility == 3)
	{
		switch (g_bSecondGame)
		{
			case true:
			{
				int iDirector = CreateEntityByName("info_director");
				if (IsValidEntity(iDirector))
				{
					DispatchSpawn(iDirector);
					AcceptEntityInput(iDirector, "ForcePanicEvent");
					RemoveEntity(iDirector);
				}
			}
			case false: vCheatCommand(tank, "director_force_panic_event");
		}
	}

	if (g_esPanicCache[tank].g_iPanicAbility == 2 || g_esPanicCache[tank].g_iPanicAbility == 3)
	{
		for (int iZombie = 1; iZombie <= g_esPanicCache[tank].g_iPanicAmount; iZombie++)
		{
			switch (g_esPanicCache[tank].g_iPanicMode)
			{
				case 0: vSpawnZombie(tank, (MT_GetRandomInt(1, 2) == 2));
				case 1: vSpawnZombie(tank, false);
				case 2: vSpawnZombie(tank, true);
			}
		}
	}
}

void vPanicAbility(int tank)
{
	if ((g_esPanicPlayer[tank].g_iCooldown != -1 && g_esPanicPlayer[tank].g_iCooldown >= GetTime()) || bIsAreaNarrow(tank, g_esPanicCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esPanicCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPanicPlayer[tank].g_iTankType, tank) || (g_esPanicCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPanicCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPanicPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esPanicPlayer[tank].g_iAmmoCount < g_esPanicCache[tank].g_iHumanAmmo && g_esPanicCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esPanicCache[tank].g_flPanicChance)
		{
			vPanic(tank);
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPanicCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicHuman2");
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPanicCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicAmmo");
	}
}

void vPanicRange(int tank, bool idle)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && g_esPanicCache[tank].g_iPanicAbility > 0 && GetRandomFloat(0.1, 100.0) <= g_esPanicCache[tank].g_flPanicChance)
	{
		if ((idle && MT_IsTankIdle(tank)) || bIsAreaNarrow(tank, g_esPanicCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esPanicCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPanicPlayer[tank].g_iTankType, tank) || (g_esPanicCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPanicCache[tank].g_iRequiresHumans) || (bIsInfected(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPanicPlayer[tank].g_iAccessFlags)) || g_esPanicCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		vPanic3(tank);
	}
}

void vPanicCopyStats2(int oldTank, int newTank)
{
	g_esPanicPlayer[newTank].g_iAmmoCount = g_esPanicPlayer[oldTank].g_iAmmoCount;
	g_esPanicPlayer[newTank].g_iCooldown = g_esPanicPlayer[oldTank].g_iCooldown;
}

void vRemovePanic(int tank)
{
	g_esPanicPlayer[tank].g_bActivated = false;
	g_esPanicPlayer[tank].g_iAmmoCount = 0;
	g_esPanicPlayer[tank].g_iCooldown = -1;
}

void vPanicReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemovePanic(iPlayer);
		}
	}
}

void vPanicReset2(int tank)
{
	g_esPanicPlayer[tank].g_bActivated = false;

	int iTime = GetTime(), iPos = g_esPanicAbility[g_esPanicPlayer[tank].g_iTankTypeRecorded].g_iComboPosition, iCooldown = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, iPos)) : g_esPanicCache[tank].g_iPanicCooldown;
	iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPanicCache[tank].g_iHumanAbility == 1 && g_esPanicPlayer[tank].g_iAmmoCount < g_esPanicCache[tank].g_iHumanAmmo && g_esPanicCache[tank].g_iHumanAmmo > 0) ? g_esPanicCache[tank].g_iHumanCooldown : iCooldown;
	g_esPanicPlayer[tank].g_iCooldown = (iTime + iCooldown);
	if (g_esPanicPlayer[tank].g_iCooldown != -1 && g_esPanicPlayer[tank].g_iCooldown >= iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PanicHuman5", (g_esPanicPlayer[tank].g_iCooldown - iTime));
	}
}

void vSpawnUncommon(int tank, const char[] model)
{
	int iCommon = CreateEntityByName("infected");
	if (bIsValidEntity(iCommon))
	{
		SetEntityModel(iCommon, model);
		SetEntProp(iCommon, Prop_Data, "m_nNextThinkTick", (RoundToNearest(GetGameTime() / GetTickInterval()) + 5));
		DispatchSpawn(iCommon);
		ActivateEntity(iCommon);

		float flOrigin[3], flAngles[3];
		GetClientAbsOrigin(tank, flOrigin);
		GetClientEyeAngles(tank, flAngles);

		flOrigin[0] += (50.0 * (Cosine(DegToRad(flAngles[1]))));
		flOrigin[1] += (50.0 * (Sine(DegToRad(flAngles[1]))));
		flOrigin[2] += 5.0;

		TeleportEntity(iCommon, flOrigin);
	}
}

void vSpawnZombie(int tank, bool uncommon)
{
	switch (uncommon)
	{
		case true:
		{
			switch (g_bSecondGame)
			{
				case true:
				{
					int iTypeCount = 0, iTypes[7], iFlag = 0;
					for (int iBit = 0; iBit < (sizeof iTypes); iBit++)
					{
						iFlag = (1 << iBit);
						if (!(g_esPanicCache[tank].g_iPanicType & iFlag))
						{
							continue;
						}

						iTypes[iTypeCount] = iFlag;
						iTypeCount++;
					}

					int iType = (iTypeCount > 0) ? iTypes[MT_GetRandomInt(0, (iTypeCount - 1))] : iTypes[0];

					switch (iType)
					{
						case 1: vSpawnUncommon(tank, MODEL_CEDA);
						case 2: vSpawnUncommon(tank, MODEL_JIMMY);
						case 4: vSpawnUncommon(tank, MODEL_FALLEN);
						case 8: vSpawnUncommon(tank, MODEL_CLOWN);
						case 16: vSpawnUncommon(tank, MODEL_MUDMAN);
						case 32: vSpawnUncommon(tank, MODEL_ROADCREW);
						case 64: vSpawnUncommon(tank, MODEL_RIOTCOP);
						default:
						{
							switch (MT_GetRandomInt(1, (sizeof iTypes)))
							{
								case 1: vSpawnUncommon(tank, MODEL_CEDA);
								case 2: vSpawnUncommon(tank, MODEL_JIMMY);
								case 3: vSpawnUncommon(tank, MODEL_FALLEN);
								case 4: vSpawnUncommon(tank, MODEL_CLOWN);
								case 5: vSpawnUncommon(tank, MODEL_MUDMAN);
								case 6: vSpawnUncommon(tank, MODEL_ROADCREW);
								case 7: vSpawnUncommon(tank, MODEL_RIOTCOP);
							}
						}
					}
				}
				case false: vSpawnZombie(tank, false);
			}
		}
		case false: vCheatCommand(tank, (g_bSecondGame ? "z_spawn_old" : "z_spawn"), "zombie area");
	}
}

Action tTimerPanicCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esPanicAbility[g_esPanicPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esPanicPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPanicPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esPanicCache[iTank].g_iPanicAbility == 0 || g_esPanicPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vPanic(iTank, iPos);

	return Plugin_Continue;
}

Action tTimerPanic(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esPanicCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esPanicCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPanicPlayer[iTank].g_iTankType, iTank) || (g_esPanicCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPanicCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esPanicAbility[g_esPanicPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esPanicPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPanicPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esPanicPlayer[iTank].g_iTankType || g_esPanicCache[iTank].g_iPanicAbility == 0 || !g_esPanicPlayer[iTank].g_bActivated)
	{
		g_esPanicPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	bool bHuman = bIsInfected(iTank, MT_CHECK_FAKECLIENT);
	int iTime = pack.ReadCell(), iCurrentTime = GetTime(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : g_esPanicCache[iTank].g_iPanicDuration;
	iDuration = (bHuman && g_esPanicCache[iTank].g_iHumanAbility == 1) ? g_esPanicCache[iTank].g_iHumanDuration : iDuration;
	if (iDuration > 0 && (!bHuman || (bHuman && g_esPanicCache[iTank].g_iHumanAbility == 1 && g_esPanicCache[iTank].g_iHumanMode == 0)) && (iTime + iDuration) < iCurrentTime && (g_esPanicPlayer[iTank].g_iCooldown == -1 || g_esPanicPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vPanicReset2(iTank);

		return Plugin_Stop;
	}

	vPanic3(iTank);

	if (g_esPanicCache[iTank].g_iPanicMessage == 1)
	{
		char sTankName[64];
		MT_GetTankName(iTank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Panic2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Panic2", LANG_SERVER, sTankName);
	}

	return Plugin_Continue;
}