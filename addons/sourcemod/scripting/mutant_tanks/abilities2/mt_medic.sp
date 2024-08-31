/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2024  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_MEDIC_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_MEDIC_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Medic Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank heals nearby special infected.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLaggedMovementInstalled, g_bSecondGame;

/**
 * Third-party natives
 **/

// [L4D & L4D2] Lagged Movement - Plugin Conflict Resolver: https://forums.alliedmods.net/showthread.php?t=340345
native any L4D_LaggedMovement(int client, float value, bool force = false);

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

	g_bDedicated = IsDedicatedServer();

	return APLRes_Success;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "LaggedMovement"))
	{
		g_bLaggedMovementInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "LaggedMovement"))
	{
		g_bLaggedMovementInstalled = false;
	}
}

#define SPRITE_GLOW "sprites/glow01.vmt"
#define SPRITE_LASERBEAM "sprites/laserbeam.vmt"
#else
	#if MT_MEDIC_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_MEDIC_SECTION "medicability"
#define MT_MEDIC_SECTION2 "medic ability"
#define MT_MEDIC_SECTION3 "medic_ability"
#define MT_MEDIC_SECTION4 "medic"

#define MT_MENU_MEDIC "Medic Ability"

enum struct esMedicPlayer
{
	bool g_bActivated;

	float g_flCloseAreasOnly;
	float g_flDamageBuff;
	float g_flDefaultSpeed;
	float g_flMedicBuffDamage;
	float g_flMedicBuffResistance;
	float g_flMedicBuffSpeed;
	float g_flMedicChance;
	float g_flMedicInterval;
	float g_flMedicRange;
	float g_flMedicRockChance;
	float g_flOpenAreasOnly;
	float g_flResistanceBuff;

	Handle g_hBuffTimer;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRockCooldown;
	int g_iMedicAbility;
	int g_iMedicCooldown;
	int g_iMedicDuration;
	int g_iMedicField;
	int g_iMedicFieldColor[4];
	int g_iMedicHealth[7];
	int g_iMedicMaxHealth[7];
	int g_iMedicMessage;
	int g_iMedicRockBreak;
	int g_iMedicRockCooldown;
	int g_iMedicSight;
	int g_iMedicSymbiosis;
	int g_iRequiresHumans;
	int g_iRockCooldown;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esMedicPlayer g_esMedicPlayer[MAXPLAYERS + 1];

enum struct esMedicTeammate
{
	float g_flCloseAreasOnly;
	float g_flMedicBuffDamage;
	float g_flMedicBuffResistance;
	float g_flMedicBuffSpeed;
	float g_flMedicChance;
	float g_flMedicInterval;
	float g_flMedicRange;
	float g_flMedicRockChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRockCooldown;
	int g_iMedicAbility;
	int g_iMedicCooldown;
	int g_iMedicDuration;
	int g_iMedicField;
	int g_iMedicFieldColor[4];
	int g_iMedicHealth[7];
	int g_iMedicMaxHealth[7];
	int g_iMedicMessage;
	int g_iMedicRockBreak;
	int g_iMedicRockCooldown;
	int g_iMedicSight;
	int g_iMedicSymbiosis;
	int g_iRequiresHumans;
}

esMedicTeammate g_esMedicTeammate[MAXPLAYERS + 1];

enum struct esMedicAbility
{
	float g_flCloseAreasOnly;
	float g_flMedicBuffDamage;
	float g_flMedicBuffResistance;
	float g_flMedicBuffSpeed;
	float g_flMedicChance;
	float g_flMedicInterval;
	float g_flMedicRange;
	float g_flMedicRockChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRockCooldown;
	int g_iMedicAbility;
	int g_iMedicCooldown;
	int g_iMedicDuration;
	int g_iMedicField;
	int g_iMedicFieldColor[4];
	int g_iMedicHealth[7];
	int g_iMedicMaxHealth[7];
	int g_iMedicMessage;
	int g_iMedicRockBreak;
	int g_iMedicRockCooldown;
	int g_iMedicSight;
	int g_iMedicSymbiosis;
	int g_iRequiresHumans;
}

esMedicAbility g_esMedicAbility[MT_MAXTYPES + 1];

enum struct esMedicSpecial
{
	float g_flCloseAreasOnly;
	float g_flMedicBuffDamage;
	float g_flMedicBuffResistance;
	float g_flMedicBuffSpeed;
	float g_flMedicChance;
	float g_flMedicInterval;
	float g_flMedicRange;
	float g_flMedicRockChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRockCooldown;
	int g_iMedicAbility;
	int g_iMedicCooldown;
	int g_iMedicDuration;
	int g_iMedicField;
	int g_iMedicFieldColor[4];
	int g_iMedicHealth[7];
	int g_iMedicMaxHealth[7];
	int g_iMedicMessage;
	int g_iMedicRockBreak;
	int g_iMedicRockCooldown;
	int g_iMedicSight;
	int g_iMedicSymbiosis;
	int g_iRequiresHumans;
}

esMedicSpecial g_esMedicSpecial[MT_MAXTYPES + 1];

enum struct esMedicCache
{
	float g_flCloseAreasOnly;
	float g_flMedicBuffDamage;
	float g_flMedicBuffResistance;
	float g_flMedicBuffSpeed;
	float g_flMedicChance;
	float g_flMedicInterval;
	float g_flMedicRange;
	float g_flMedicRockChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRockCooldown;
	int g_iMedicAbility;
	int g_iMedicCooldown;
	int g_iMedicDuration;
	int g_iMedicField;
	int g_iMedicFieldColor[4];
	int g_iMedicHealth[7];
	int g_iMedicMaxHealth[7];
	int g_iMedicMessage;
	int g_iMedicRockBreak;
	int g_iMedicRockCooldown;
	int g_iMedicSight;
	int g_iMedicSymbiosis;
	int g_iRequiresHumans;
}

esMedicCache g_esMedicCache[MAXPLAYERS + 1];

int g_iMedicBeamSprite = -1, g_iMedicHaloSprite = -1;

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_medic", cmdMedicInfo, "View information about the Medic ability.");
}
#endif

#if defined MT_ABILITIES_MAIN2
void vMedicMapStart()
#else
public void OnMapStart()
#endif
{
	g_iMedicBeamSprite = PrecacheModel(SPRITE_LASERBEAM, true);
	g_iMedicHaloSprite = PrecacheModel(SPRITE_GLOW, true);

	vMedicReset();
}

#if defined MT_ABILITIES_MAIN2
void vMedicClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnMedicTakeDamage);
	vRemoveMedic(client);
}

#if defined MT_ABILITIES_MAIN2
void vMedicClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveMedic(client);
}

#if defined MT_ABILITIES_MAIN2
void vMedicMapEnd()
#else
public void OnMapEnd()
#endif
{
	vMedicReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdMedicInfo(int client, int args)
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
		case false: vMedicMenu(client, MT_MEDIC_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vMedicMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_MEDIC_SECTION4, name, false) == -1)
	{
		return;
	}

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
	mAbilityMenu.AddItem("Rock Cooldown", "Rock Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iMedicMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esMedicCache[param1].g_iMedicAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esMedicCache[param1].g_iHumanAmmo - g_esMedicPlayer[param1].g_iAmmoCount), g_esMedicCache[param1].g_iHumanAmmo);
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esMedicCache[param1].g_iHumanMode == 0) ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esMedicCache[param1].g_iHumanAbility == 1) ? g_esMedicCache[param1].g_iHumanCooldown : g_esMedicCache[param1].g_iMedicCooldown));
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "MedicDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", ((g_esMedicCache[param1].g_iHumanAbility == 1) ? g_esMedicCache[param1].g_iHumanDuration : g_esMedicCache[param1].g_iMedicDuration));
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esMedicCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 8: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRockCooldown", ((g_esMedicCache[param1].g_iHumanAbility == 1) ? g_esMedicCache[param1].g_iHumanRockCooldown : g_esMedicCache[param1].g_iMedicRockCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vMedicMenu(param1, MT_MEDIC_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pMedic = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "MedicMenu", param1);
			pMedic.SetTitle(sMenuTitle);
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
					case 8: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "RockCooldown", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN2
void vMedicDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_MEDIC, MT_MENU_MEDIC);
}

#if defined MT_ABILITIES_MAIN2
void vMedicMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_MEDIC, false))
	{
		vMedicMenu(client, MT_MEDIC_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vMedicMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_MEDIC, false))
	{
		FormatEx(buffer, size, "%T", "MedicMenu2", client);
	}
}

Action OnMedicTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		if (bIsInfected(victim) && g_esMedicPlayer[victim].g_flResistanceBuff > 0.0)
		{
			damage *= g_esMedicPlayer[victim].g_flResistanceBuff;

			return Plugin_Changed;
		}
		else if (bIsInfected(attacker) && g_esMedicPlayer[attacker].g_flDamageBuff > 0.0)
		{
			damage *= g_esMedicPlayer[attacker].g_flDamageBuff;

			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vMedicPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_MEDIC);
}

#if defined MT_ABILITIES_MAIN2
void vMedicAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_MEDIC_SECTION);
	list2.PushString(MT_MEDIC_SECTION2);
	list3.PushString(MT_MEDIC_SECTION3);
	list4.PushString(MT_MEDIC_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vMedicCombineAbilities(int tank, int type, const float random, const char[] combo, int weapon)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esMedicCache[tank].g_iHumanAbility != 2)
	{
		g_esMedicAbility[g_esMedicPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

		return;
	}

	g_esMedicAbility[g_esMedicPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_MEDIC_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_MEDIC_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_MEDIC_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_MEDIC_SECTION4);
	if (g_esMedicCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_MEDIC_SECTION, false) || StrEqual(sSubset[iPos], MT_MEDIC_SECTION2, false) || StrEqual(sSubset[iPos], MT_MEDIC_SECTION3, false) || StrEqual(sSubset[iPos], MT_MEDIC_SECTION4, false))
			{
				g_esMedicAbility[g_esMedicPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = iPos;

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esMedicCache[tank].g_iMedicAbility == 1 && !g_esMedicPlayer[tank].g_bActivated && random <= MT_GetCombinationSetting(tank, 1, iPos))
						{
							flDelay = MT_GetCombinationSetting(tank, 4, iPos);

							switch (flDelay)
							{
								case 0.0: vMedic(tank, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerMedicCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteCell(iPos);
								}
							}
						}
					}
					case MT_COMBO_ROCKBREAK:
					{
						if (g_esMedicCache[tank].g_iMedicRockBreak == 1 && bIsValidEntity(weapon))
						{
							vMedicRockBreak2(tank, weapon, random, iPos);
						}
					}
				}

				break;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vMedicConfigsLoad(int mode)
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
				g_esMedicAbility[iIndex].g_iAccessFlags = 0;
				g_esMedicAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esMedicAbility[iIndex].g_iComboAbility = 0;
				g_esMedicAbility[iIndex].g_iComboPosition = -1;
				g_esMedicAbility[iIndex].g_iHumanAbility = 0;
				g_esMedicAbility[iIndex].g_iHumanAmmo = 5;
				g_esMedicAbility[iIndex].g_iHumanCooldown = 0;
				g_esMedicAbility[iIndex].g_iHumanDuration = 5;
				g_esMedicAbility[iIndex].g_iHumanMode = 1;
				g_esMedicAbility[iIndex].g_iHumanRockCooldown = 0;
				g_esMedicAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esMedicAbility[iIndex].g_iRequiresHumans = 0;
				g_esMedicAbility[iIndex].g_iMedicAbility = 0;
				g_esMedicAbility[iIndex].g_iMedicMessage = 0;
				g_esMedicAbility[iIndex].g_flMedicBuffDamage = 1.25;
				g_esMedicAbility[iIndex].g_flMedicBuffResistance = 0.75;
				g_esMedicAbility[iIndex].g_flMedicBuffSpeed = 1.25;
				g_esMedicAbility[iIndex].g_flMedicChance = 33.3;
				g_esMedicAbility[iIndex].g_iMedicCooldown = 0;
				g_esMedicAbility[iIndex].g_iMedicDuration = 0;
				g_esMedicAbility[iIndex].g_iMedicField = 1;
				g_esMedicAbility[iIndex].g_iMedicFieldColor[0] = 0;
				g_esMedicAbility[iIndex].g_iMedicFieldColor[1] = 255;
				g_esMedicAbility[iIndex].g_iMedicFieldColor[2] = 0;
				g_esMedicAbility[iIndex].g_iMedicFieldColor[3] = 255;
				g_esMedicAbility[iIndex].g_flMedicInterval = 5.0;
				g_esMedicAbility[iIndex].g_iMedicMaxHealth[0] = 250;
				g_esMedicAbility[iIndex].g_iMedicMaxHealth[1] = 50;
				g_esMedicAbility[iIndex].g_iMedicMaxHealth[2] = 250;
				g_esMedicAbility[iIndex].g_iMedicMaxHealth[3] = 100;
				g_esMedicAbility[iIndex].g_iMedicMaxHealth[4] = 325;
				g_esMedicAbility[iIndex].g_iMedicMaxHealth[5] = 600;
				g_esMedicAbility[iIndex].g_iMedicMaxHealth[6] = 8000;
				g_esMedicAbility[iIndex].g_flMedicRange = 500.0;
				g_esMedicAbility[iIndex].g_iMedicRockBreak = 0;
				g_esMedicAbility[iIndex].g_flMedicRockChance = 33.3;
				g_esMedicAbility[iIndex].g_iMedicRockCooldown = 0;
				g_esMedicAbility[iIndex].g_iMedicSight = 0;
				g_esMedicAbility[iIndex].g_iMedicSymbiosis = 1;

				for (int iPos = 0; iPos < (sizeof esMedicAbility::g_iMedicHealth); iPos++)
				{
					g_esMedicAbility[iIndex].g_iMedicHealth[iPos] = 25;
				}

				g_esMedicSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esMedicSpecial[iIndex].g_iComboAbility = -1;
				g_esMedicSpecial[iIndex].g_iHumanAbility = -1;
				g_esMedicSpecial[iIndex].g_iHumanAmmo = -1;
				g_esMedicSpecial[iIndex].g_iHumanCooldown = -1;
				g_esMedicSpecial[iIndex].g_iHumanDuration = -1;
				g_esMedicSpecial[iIndex].g_iHumanMode = -1;
				g_esMedicSpecial[iIndex].g_iHumanRockCooldown = -1;
				g_esMedicSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esMedicSpecial[iIndex].g_iRequiresHumans = -1;
				g_esMedicSpecial[iIndex].g_iMedicAbility = -1;
				g_esMedicSpecial[iIndex].g_iMedicMessage = -1;
				g_esMedicSpecial[iIndex].g_flMedicBuffDamage = -1.0;
				g_esMedicSpecial[iIndex].g_flMedicBuffResistance = -1.0;
				g_esMedicSpecial[iIndex].g_flMedicBuffSpeed = -1.0;
				g_esMedicSpecial[iIndex].g_flMedicChance = -1.0;
				g_esMedicSpecial[iIndex].g_iMedicCooldown = -1;
				g_esMedicSpecial[iIndex].g_iMedicDuration = -1;
				g_esMedicSpecial[iIndex].g_iMedicField = -1;
				g_esMedicSpecial[iIndex].g_iMedicFieldColor[0] = -1;
				g_esMedicSpecial[iIndex].g_iMedicFieldColor[1] = -1;
				g_esMedicSpecial[iIndex].g_iMedicFieldColor[2] = -1;
				g_esMedicSpecial[iIndex].g_iMedicFieldColor[3] = -1;
				g_esMedicSpecial[iIndex].g_flMedicInterval = -1.0;
				g_esMedicSpecial[iIndex].g_iMedicMaxHealth[0] = -1;
				g_esMedicSpecial[iIndex].g_iMedicMaxHealth[1] = -1;
				g_esMedicSpecial[iIndex].g_iMedicMaxHealth[2] = -1;
				g_esMedicSpecial[iIndex].g_iMedicMaxHealth[3] = -1;
				g_esMedicSpecial[iIndex].g_iMedicMaxHealth[4] = -1;
				g_esMedicSpecial[iIndex].g_iMedicMaxHealth[5] = -1;
				g_esMedicSpecial[iIndex].g_iMedicMaxHealth[6] = -1;
				g_esMedicSpecial[iIndex].g_flMedicRange = -1.0;
				g_esMedicSpecial[iIndex].g_iMedicRockBreak = -1;
				g_esMedicSpecial[iIndex].g_flMedicRockChance = -1.0;
				g_esMedicSpecial[iIndex].g_iMedicRockCooldown = -1;
				g_esMedicSpecial[iIndex].g_iMedicSight = -1;
				g_esMedicSpecial[iIndex].g_iMedicSymbiosis = -1;

				for (int iPos = 0; iPos < (sizeof esMedicSpecial::g_iMedicHealth); iPos++)
				{
					g_esMedicSpecial[iIndex].g_iMedicHealth[iPos] = -1;
				}
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esMedicPlayer[iPlayer].g_iAccessFlags = -1;
				g_esMedicPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esMedicPlayer[iPlayer].g_iComboAbility = -1;
				g_esMedicPlayer[iPlayer].g_iHumanAbility = -1;
				g_esMedicPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esMedicPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esMedicPlayer[iPlayer].g_iHumanDuration = -1;
				g_esMedicPlayer[iPlayer].g_iHumanMode = -1;
				g_esMedicPlayer[iPlayer].g_iHumanRockCooldown = -1;
				g_esMedicPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esMedicPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esMedicPlayer[iPlayer].g_iMedicAbility = -1;
				g_esMedicPlayer[iPlayer].g_iMedicMessage = -1;
				g_esMedicPlayer[iPlayer].g_flMedicBuffDamage = -1.0;
				g_esMedicPlayer[iPlayer].g_flMedicBuffResistance = -1.0;
				g_esMedicPlayer[iPlayer].g_flMedicBuffSpeed = -1.0;
				g_esMedicPlayer[iPlayer].g_flMedicChance = -1.0;
				g_esMedicPlayer[iPlayer].g_iMedicCooldown = -1;
				g_esMedicPlayer[iPlayer].g_iMedicDuration = -1;
				g_esMedicPlayer[iPlayer].g_iMedicField = -1;
				g_esMedicPlayer[iPlayer].g_iMedicFieldColor[3] = 255;
				g_esMedicPlayer[iPlayer].g_flMedicInterval = -1.0;
				g_esMedicPlayer[iPlayer].g_flMedicRange = -1.0;
				g_esMedicPlayer[iPlayer].g_iMedicRockBreak = -1;
				g_esMedicPlayer[iPlayer].g_flMedicRockChance = -1.0;
				g_esMedicPlayer[iPlayer].g_iMedicRockCooldown = -1;
				g_esMedicPlayer[iPlayer].g_iMedicSight = -1;
				g_esMedicPlayer[iPlayer].g_iMedicSymbiosis = -1;

				for (int iPos = 0; iPos < (sizeof esMedicPlayer::g_iMedicHealth); iPos++)
				{
					g_esMedicPlayer[iPlayer].g_iMedicHealth[iPos] = -1;
					g_esMedicPlayer[iPlayer].g_iMedicMaxHealth[iPos] = -1;

					if (iPos < (sizeof esMedicPlayer::g_iMedicFieldColor - 1))
					{
						g_esMedicPlayer[iPlayer].g_iMedicFieldColor[iPos] = -1;
					}
				}

				g_esMedicTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esMedicTeammate[iPlayer].g_iComboAbility = -1;
				g_esMedicTeammate[iPlayer].g_iHumanAbility = -1;
				g_esMedicTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esMedicTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esMedicTeammate[iPlayer].g_iHumanDuration = -1;
				g_esMedicTeammate[iPlayer].g_iHumanMode = -1;
				g_esMedicTeammate[iPlayer].g_iHumanRockCooldown = -1;
				g_esMedicTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esMedicTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esMedicTeammate[iPlayer].g_iMedicAbility = -1;
				g_esMedicTeammate[iPlayer].g_iMedicMessage = -1;
				g_esMedicTeammate[iPlayer].g_flMedicBuffDamage = -1.0;
				g_esMedicTeammate[iPlayer].g_flMedicBuffResistance = -1.0;
				g_esMedicTeammate[iPlayer].g_flMedicBuffSpeed = -1.0;
				g_esMedicTeammate[iPlayer].g_flMedicChance = -1.0;
				g_esMedicTeammate[iPlayer].g_iMedicCooldown = -1;
				g_esMedicTeammate[iPlayer].g_iMedicDuration = -1;
				g_esMedicTeammate[iPlayer].g_iMedicField = -1;
				g_esMedicTeammate[iPlayer].g_iMedicFieldColor[3] = 255;
				g_esMedicTeammate[iPlayer].g_flMedicInterval = -1.0;
				g_esMedicTeammate[iPlayer].g_flMedicRange = -1.0;
				g_esMedicTeammate[iPlayer].g_iMedicRockBreak = -1;
				g_esMedicTeammate[iPlayer].g_flMedicRockChance = -1.0;
				g_esMedicTeammate[iPlayer].g_iMedicRockCooldown = -1;
				g_esMedicTeammate[iPlayer].g_iMedicSight = -1;
				g_esMedicTeammate[iPlayer].g_iMedicSymbiosis = -1;

				for (int iPos = 0; iPos < (sizeof esMedicTeammate::g_iMedicHealth); iPos++)
				{
					g_esMedicTeammate[iPlayer].g_iMedicHealth[iPos] = -1;
					g_esMedicTeammate[iPlayer].g_iMedicMaxHealth[iPos] = -1;

					if (iPos < (sizeof esMedicTeammate::g_iMedicFieldColor - 1))
					{
						g_esMedicTeammate[iPlayer].g_iMedicFieldColor[iPos] = -1;
					}
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vMedicConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esMedicTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esMedicTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esMedicTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esMedicTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esMedicTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esMedicTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esMedicTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esMedicTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esMedicTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esMedicTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esMedicTeammate[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esMedicTeammate[admin].g_iHumanDuration, value, -1, 99999);
			g_esMedicTeammate[admin].g_iHumanMode = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esMedicTeammate[admin].g_iHumanMode, value, -1, 1);
			g_esMedicTeammate[admin].g_iHumanRockCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanRockCooldown", "Human Rock Cooldown", "Human_Rock_Cooldown", "hrockcooldown", g_esMedicTeammate[admin].g_iHumanRockCooldown, value, -1, 99999);
			g_esMedicTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esMedicTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esMedicTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esMedicTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esMedicTeammate[admin].g_iMedicAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esMedicTeammate[admin].g_iMedicAbility, value, -1, 1);
			g_esMedicTeammate[admin].g_iMedicMessage = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esMedicTeammate[admin].g_iMedicMessage, value, -1, 1);
			g_esMedicTeammate[admin].g_iMedicSight = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esMedicTeammate[admin].g_iMedicSight, value, -1, 5);
			g_esMedicTeammate[admin].g_flMedicBuffDamage = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffDamage", "Medic Buff Damage", "Medic_Buff_Damage", "buffdmg", g_esMedicTeammate[admin].g_flMedicBuffDamage, value, -1.0, 99999.0);
			g_esMedicTeammate[admin].g_flMedicBuffResistance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffResistance", "Medic Buff Resistance", "Medic_Buff_Resistance", "buffres", g_esMedicTeammate[admin].g_flMedicBuffResistance, value, -1.0, 1.0);
			g_esMedicTeammate[admin].g_flMedicBuffSpeed = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffSpeed", "Medic Buff Speed", "Medic_Buff_Speed", "buffspeed", g_esMedicTeammate[admin].g_flMedicBuffSpeed, value, -1.0, 10.0);
			g_esMedicTeammate[admin].g_flMedicChance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicChance", "Medic Chance", "Medic_Chance", "chance", g_esMedicTeammate[admin].g_flMedicChance, value, -1.0, 100.0);
			g_esMedicTeammate[admin].g_iMedicCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicCooldown", "Medic Cooldown", "Medic_Cooldown", "cooldown", g_esMedicTeammate[admin].g_iMedicCooldown, value, -1, 99999);
			g_esMedicTeammate[admin].g_iMedicDuration = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicDuration", "Medic Duration", "Medic_Duration", "duration", g_esMedicTeammate[admin].g_iMedicDuration, value, -1, 99999);
			g_esMedicTeammate[admin].g_iMedicField = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicField", "Medic Field", "Medic_Field", "field", g_esMedicTeammate[admin].g_iMedicField, value, -1, 1);
			g_esMedicTeammate[admin].g_flMedicInterval = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicInterval", "Medic Interval", "Medic_Interval", "interval", g_esMedicTeammate[admin].g_flMedicInterval, value, -1.0, 99999.0);
			g_esMedicTeammate[admin].g_flMedicRange = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRange", "Medic Range", "Medic_Range", "range", g_esMedicTeammate[admin].g_flMedicRange, value, -1.0, 99999.0);
			g_esMedicTeammate[admin].g_iMedicRockBreak = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicPin", "Medic Pin", "Medic_Pin", "pin", g_esMedicTeammate[admin].g_iMedicRockBreak, value, -1, 1);
			g_esMedicTeammate[admin].g_flMedicRockChance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicPinChance", "Medic Pin Chance", "Medic_Pin_Chance", "pinchance", g_esMedicTeammate[admin].g_flMedicRockChance, value, -1.0, 100.0);
			g_esMedicTeammate[admin].g_iMedicRockCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicPinCooldown", "Medic Pin Cooldown", "Medic_Pin_Cooldown", "pincooldown", g_esMedicTeammate[admin].g_iMedicRockCooldown, value, -1, 99999);
			g_esMedicTeammate[admin].g_iMedicSymbiosis = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicSymbiosis", "Medic Symbiosis", "Medic_Symbiosis", "symbiosis", g_esMedicTeammate[admin].g_iMedicSymbiosis, value, -1, 1);
		}
		else
		{
			g_esMedicPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esMedicPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esMedicPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esMedicPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esMedicPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esMedicPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esMedicPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esMedicPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esMedicPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esMedicPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esMedicPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esMedicPlayer[admin].g_iHumanDuration, value, -1, 99999);
			g_esMedicPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esMedicPlayer[admin].g_iHumanMode, value, -1, 1);
			g_esMedicPlayer[admin].g_iHumanRockCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanRockCooldown", "Human Rock Cooldown", "Human_Rock_Cooldown", "hrockcooldown", g_esMedicPlayer[admin].g_iHumanRockCooldown, value, -1, 99999);
			g_esMedicPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esMedicPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esMedicPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esMedicPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esMedicPlayer[admin].g_iMedicAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esMedicPlayer[admin].g_iMedicAbility, value, -1, 1);
			g_esMedicPlayer[admin].g_iMedicMessage = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esMedicPlayer[admin].g_iMedicMessage, value, -1, 1);
			g_esMedicPlayer[admin].g_iMedicSight = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esMedicPlayer[admin].g_iMedicSight, value, -1, 5);
			g_esMedicPlayer[admin].g_flMedicBuffDamage = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffDamage", "Medic Buff Damage", "Medic_Buff_Damage", "buffdmg", g_esMedicPlayer[admin].g_flMedicBuffDamage, value, -1.0, 99999.0);
			g_esMedicPlayer[admin].g_flMedicBuffResistance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffResistance", "Medic Buff Resistance", "Medic_Buff_Resistance", "buffres", g_esMedicPlayer[admin].g_flMedicBuffResistance, value, -1.0, 1.0);
			g_esMedicPlayer[admin].g_flMedicBuffSpeed = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffSpeed", "Medic Buff Speed", "Medic_Buff_Speed", "buffspeed", g_esMedicPlayer[admin].g_flMedicBuffSpeed, value, -1.0, 10.0);
			g_esMedicPlayer[admin].g_flMedicChance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicChance", "Medic Chance", "Medic_Chance", "chance", g_esMedicPlayer[admin].g_flMedicChance, value, -1.0, 100.0);
			g_esMedicPlayer[admin].g_iMedicCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicCooldown", "Medic Cooldown", "Medic_Cooldown", "cooldown", g_esMedicPlayer[admin].g_iMedicCooldown, value, -1, 99999);
			g_esMedicPlayer[admin].g_iMedicDuration = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicDuration", "Medic Duration", "Medic_Duration", "duration", g_esMedicPlayer[admin].g_iMedicDuration, value, -1, 99999);
			g_esMedicPlayer[admin].g_iMedicField = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicField", "Medic Field", "Medic_Field", "field", g_esMedicPlayer[admin].g_iMedicField, value, -1, 1);
			g_esMedicPlayer[admin].g_flMedicInterval = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicInterval", "Medic Interval", "Medic_Interval", "interval", g_esMedicPlayer[admin].g_flMedicInterval, value, -1.0, 99999.0);
			g_esMedicPlayer[admin].g_flMedicRange = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRange", "Medic Range", "Medic_Range", "range", g_esMedicPlayer[admin].g_flMedicRange, value, -1.0, 99999.0);
			g_esMedicPlayer[admin].g_iMedicRockBreak = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRockBreak", "Medic Rock Break", "Medic_Rock_Break", "rock", g_esMedicPlayer[admin].g_iMedicRockBreak, value, -1, 1);
			g_esMedicPlayer[admin].g_flMedicRockChance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRockChance", "Medic Rock Chance", "Medic_Rock_Chance", "rockchance", g_esMedicPlayer[admin].g_flMedicRockChance, value, -1.0, 100.0);
			g_esMedicPlayer[admin].g_iMedicRockCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRockCooldown", "Medic Rock Cooldown", "Medic_Rock_Cooldown", "rockcooldown", g_esMedicPlayer[admin].g_iMedicRockCooldown, value, -1, 99999);
			g_esMedicPlayer[admin].g_iMedicSymbiosis = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicSymbiosis", "Medic Symbiosis", "Medic_Symbiosis", "symbiosis", g_esMedicPlayer[admin].g_iMedicSymbiosis, value, -1, 1);
			g_esMedicPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		}

		if (StrEqual(subsection, MT_MEDIC_SECTION, false) || StrEqual(subsection, MT_MEDIC_SECTION2, false) || StrEqual(subsection, MT_MEDIC_SECTION3, false) || StrEqual(subsection, MT_MEDIC_SECTION4, false))
		{
			if (StrEqual(key, "MedicFieldColor", false) || StrEqual(key, "Medic Field Color", false) || StrEqual(key, "Medic_Field_Color", false) || StrEqual(key, "fieldcolor", false))
			{
				char sSet[3][4], sValue[12];
				MT_GetConfigColors(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < (sizeof sSet - 1); iPos++)
				{
					switch (special && specsection[0] != '\0')
					{
						case true: g_esMedicTeammate[admin].g_iMedicFieldColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
						case false: g_esMedicPlayer[admin].g_iMedicFieldColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
				}

				switch (special && specsection[0] != '\0')
				{
					case true: g_esMedicTeammate[admin].g_iMedicFieldColor[3] = 255;
					case false: g_esMedicPlayer[admin].g_iMedicFieldColor[3] = 255;
				}
			}
			else
			{
				char sSet[7][11], sValue[77];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < (sizeof sSet); iPos++)
				{
					if (special && specsection[0] != '\0')
					{
						g_esMedicTeammate[admin].g_iMedicHealth[iPos] = iGetClampedValue(key, "MedicHealth", "Medic Health", "Medic_Health", "health", g_esMedicTeammate[admin].g_iMedicHealth[iPos], sSet[iPos], MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
						g_esMedicTeammate[admin].g_iMedicMaxHealth[iPos] = iGetClampedValue(key, "MedicMaxHealth", "Medic Max Health", "Medic_Max_Health", "maxhealth", g_esMedicTeammate[admin].g_iMedicMaxHealth[iPos], sSet[iPos], -1, MT_MAXHEALTH);
					}
					else
					{
						g_esMedicPlayer[admin].g_iMedicHealth[iPos] = iGetClampedValue(key, "MedicHealth", "Medic Health", "Medic_Health", "health", g_esMedicPlayer[admin].g_iMedicHealth[iPos], sSet[iPos], MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
						g_esMedicPlayer[admin].g_iMedicMaxHealth[iPos] = iGetClampedValue(key, "MedicMaxHealth", "Medic Max Health", "Medic_Max_Health", "maxhealth", g_esMedicPlayer[admin].g_iMedicMaxHealth[iPos], sSet[iPos], -1, MT_MAXHEALTH);
					}
				}
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esMedicSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esMedicSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esMedicSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esMedicSpecial[type].g_iComboAbility, value, -1, 1);
			g_esMedicSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esMedicSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esMedicSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esMedicSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esMedicSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esMedicSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esMedicSpecial[type].g_iHumanDuration = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esMedicSpecial[type].g_iHumanDuration, value, -1, 99999);
			g_esMedicSpecial[type].g_iHumanMode = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esMedicSpecial[type].g_iHumanMode, value, -1, 1);
			g_esMedicSpecial[type].g_iHumanRockCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanRockCooldown", "Human Rock Cooldown", "Human_Rock_Cooldown", "hrockcooldown", g_esMedicSpecial[type].g_iHumanRockCooldown, value, -1, 99999);
			g_esMedicSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esMedicSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esMedicSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esMedicSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esMedicSpecial[type].g_iMedicAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esMedicSpecial[type].g_iMedicAbility, value, -1, 1);
			g_esMedicSpecial[type].g_iMedicMessage = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esMedicSpecial[type].g_iMedicMessage, value, -1, 1);
			g_esMedicSpecial[type].g_iMedicSight = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esMedicSpecial[type].g_iMedicSight, value, -1, 5);
			g_esMedicSpecial[type].g_flMedicBuffDamage = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffDamage", "Medic Buff Damage", "Medic_Buff_Damage", "buffdmg", g_esMedicSpecial[type].g_flMedicBuffDamage, value, -1.0, 99999.0);
			g_esMedicSpecial[type].g_flMedicBuffResistance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffResistance", "Medic Buff Resistance", "Medic_Buff_Resistance", "buffres", g_esMedicSpecial[type].g_flMedicBuffResistance, value, -1.0, 1.0);
			g_esMedicSpecial[type].g_flMedicBuffSpeed = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffSpeed", "Medic Buff Speed", "Medic_Buff_Speed", "buffspeed", g_esMedicSpecial[type].g_flMedicBuffSpeed, value, -1.0, 10.0);
			g_esMedicSpecial[type].g_flMedicChance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicChance", "Medic Chance", "Medic_Chance", "chance", g_esMedicSpecial[type].g_flMedicChance, value, -1.0, 100.0);
			g_esMedicSpecial[type].g_iMedicCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicCooldown", "Medic Cooldown", "Medic_Cooldown", "cooldown", g_esMedicSpecial[type].g_iMedicCooldown, value, -1, 99999);
			g_esMedicSpecial[type].g_iMedicDuration = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicDuration", "Medic Duration", "Medic_Duration", "duration", g_esMedicSpecial[type].g_iMedicDuration, value, -1, 99999);
			g_esMedicSpecial[type].g_iMedicField = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicField", "Medic Field", "Medic_Field", "field", g_esMedicSpecial[type].g_iMedicField, value, -1, 1);
			g_esMedicSpecial[type].g_flMedicInterval = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicInterval", "Medic Interval", "Medic_Interval", "interval", g_esMedicSpecial[type].g_flMedicInterval, value, -1.0, 99999.0);
			g_esMedicSpecial[type].g_flMedicRange = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRange", "Medic Range", "Medic_Range", "range", g_esMedicSpecial[type].g_flMedicRange, value, -1.0, 99999.0);
			g_esMedicSpecial[type].g_iMedicRockBreak = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicPin", "Medic Pin", "Medic_Pin", "pin", g_esMedicSpecial[type].g_iMedicRockBreak, value, -1, 1);
			g_esMedicSpecial[type].g_flMedicRockChance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicPinChance", "Medic Pin Chance", "Medic_Pin_Chance", "pinchance", g_esMedicSpecial[type].g_flMedicRockChance, value, -1.0, 100.0);
			g_esMedicSpecial[type].g_iMedicRockCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicPinCooldown", "Medic Pin Cooldown", "Medic_Pin_Cooldown", "pincooldown", g_esMedicSpecial[type].g_iMedicRockCooldown, value, -1, 99999);
			g_esMedicSpecial[type].g_iMedicSymbiosis = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicSymbiosis", "Medic Symbiosis", "Medic_Symbiosis", "symbiosis", g_esMedicSpecial[type].g_iMedicSymbiosis, value, -1, 1);
		}
		else
		{
			g_esMedicAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esMedicAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esMedicAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esMedicAbility[type].g_iComboAbility, value, -1, 1);
			g_esMedicAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esMedicAbility[type].g_iHumanAbility, value, -1, 2);
			g_esMedicAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esMedicAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esMedicAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esMedicAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esMedicAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esMedicAbility[type].g_iHumanDuration, value, -1, 99999);
			g_esMedicAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esMedicAbility[type].g_iHumanMode, value, -1, 1);
			g_esMedicAbility[type].g_iHumanRockCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "HumanRockCooldown", "Human Rock Cooldown", "Human_Rock_Cooldown", "hrockcooldown", g_esMedicAbility[type].g_iHumanRockCooldown, value, -1, 99999);
			g_esMedicAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esMedicAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esMedicAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esMedicAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esMedicAbility[type].g_iMedicAbility = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esMedicAbility[type].g_iMedicAbility, value, -1, 1);
			g_esMedicAbility[type].g_iMedicMessage = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esMedicAbility[type].g_iMedicMessage, value, -1, 1);
			g_esMedicAbility[type].g_iMedicSight = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esMedicAbility[type].g_iMedicSight, value, -1, 1);
			g_esMedicAbility[type].g_flMedicBuffDamage = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffDamage", "Medic Buff Damage", "Medic_Buff_Damage", "buffdmg", g_esMedicAbility[type].g_flMedicBuffDamage, value, -1.0, 99999.0);
			g_esMedicAbility[type].g_flMedicBuffResistance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffResistance", "Medic Buff Resistance", "Medic_Buff_Resistance", "buffres", g_esMedicAbility[type].g_flMedicBuffResistance, value, -1.0, 1.0);
			g_esMedicAbility[type].g_flMedicBuffSpeed = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicBuffSpeed", "Medic Buff Speed", "Medic_Buff_Speed", "buffspeed", g_esMedicAbility[type].g_flMedicBuffSpeed, value, -1.0, 10.0);
			g_esMedicAbility[type].g_flMedicChance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicChance", "Medic Chance", "Medic_Chance", "chance", g_esMedicAbility[type].g_flMedicChance, value, -1.0, 100.0);
			g_esMedicAbility[type].g_iMedicCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicCooldown", "Medic Cooldown", "Medic_Cooldown", "cooldown", g_esMedicAbility[type].g_iMedicCooldown, value, -1, 99999);
			g_esMedicAbility[type].g_iMedicDuration = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicDuration", "Medic Duration", "Medic_Duration", "duration", g_esMedicAbility[type].g_iMedicDuration, value, -1, 99999);
			g_esMedicAbility[type].g_iMedicField = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicField", "Medic Field", "Medic_Field", "field", g_esMedicAbility[type].g_iMedicField, value, -1, 1);
			g_esMedicAbility[type].g_flMedicInterval = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicInterval", "Medic Interval", "Medic_Interval", "interval", g_esMedicAbility[type].g_flMedicInterval, value, -1.0, 99999.0);
			g_esMedicAbility[type].g_flMedicRange = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRange", "Medic Range", "Medic_Range", "range", g_esMedicAbility[type].g_flMedicRange, value, -1.0, 99999.0);
			g_esMedicAbility[type].g_iMedicRockBreak = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRockBreak", "Medic Rock Break", "Medic_Rock_Break", "rock", g_esMedicAbility[type].g_iMedicRockBreak, value, -1, 1);
			g_esMedicAbility[type].g_flMedicRockChance = flGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRockChance", "Medic Rock Chance", "Medic_Rock_Chance", "rockchance", g_esMedicAbility[type].g_flMedicRockChance, value, -1.0, 100.0);
			g_esMedicAbility[type].g_iMedicRockCooldown = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicRockCooldown", "Medic Rock Cooldown", "Medic_Rock_Cooldown", "rockcooldown", g_esMedicAbility[type].g_iMedicRockCooldown, value, -1, 99999);
			g_esMedicAbility[type].g_iMedicSymbiosis = iGetKeyValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "MedicSymbiosis", "Medic Symbiosis", "Medic_Symbiosis", "symbiosis", g_esMedicAbility[type].g_iMedicSymbiosis, value, -1, 1);
			g_esMedicAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_MEDIC_SECTION, MT_MEDIC_SECTION2, MT_MEDIC_SECTION3, MT_MEDIC_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		}

		if (StrEqual(subsection, MT_MEDIC_SECTION, false) || StrEqual(subsection, MT_MEDIC_SECTION2, false) || StrEqual(subsection, MT_MEDIC_SECTION3, false) || StrEqual(subsection, MT_MEDIC_SECTION4, false))
		{
			if (StrEqual(key, "MedicFieldColor", false) || StrEqual(key, "Medic Field Color", false) || StrEqual(key, "Medic_Field_Color", false) || StrEqual(key, "fieldcolor", false))
			{
				char sSet[3][4], sValue[12];
				MT_GetConfigColors(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < (sizeof sSet - 1); iPos++)
				{
					switch (special && specsection[0] != '\0')
					{
						case true: g_esMedicSpecial[type].g_iMedicFieldColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
						case false: g_esMedicAbility[type].g_iMedicFieldColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
				}

				switch (special && specsection[0] != '\0')
				{
					case true: g_esMedicSpecial[type].g_iMedicFieldColor[3] = 255;
					case false: g_esMedicAbility[type].g_iMedicFieldColor[3] = 255;
				}
			}
			else
			{
				char sSet[7][11], sValue[77];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < (sizeof sSet); iPos++)
				{
					if (special && specsection[0] != '\0')
					{
						g_esMedicSpecial[type].g_iMedicHealth[iPos] = iGetClampedValue(key, "MedicHealth", "Medic Health", "Medic_Health", "health", g_esMedicSpecial[type].g_iMedicHealth[iPos], sSet[iPos], MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
						g_esMedicSpecial[type].g_iMedicMaxHealth[iPos] = iGetClampedValue(key, "MedicMaxHealth", "Medic Max Health", "Medic_Max_Health", "maxhealth", g_esMedicSpecial[type].g_iMedicMaxHealth[iPos], sSet[iPos], -1, MT_MAXHEALTH);
					}
					else
					{
						g_esMedicAbility[type].g_iMedicHealth[iPos] = iGetClampedValue(key, "MedicHealth", "Medic Health", "Medic_Health", "health", g_esMedicAbility[type].g_iMedicHealth[iPos], sSet[iPos], MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
						g_esMedicAbility[type].g_iMedicMaxHealth[iPos] = iGetClampedValue(key, "MedicMaxHealth", "Medic Max Health", "Medic_Max_Health", "maxhealth", g_esMedicAbility[type].g_iMedicMaxHealth[iPos], sSet[iPos], -1, MT_MAXHEALTH);
					}
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vMedicSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT), bInfected = bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME);
	g_esMedicPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esMedicPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esMedicPlayer[tank].g_iTankTypeRecorded;

	if (bInfected)
	{
		g_esMedicCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_flCloseAreasOnly, g_esMedicPlayer[tank].g_flCloseAreasOnly, g_esMedicSpecial[iType].g_flCloseAreasOnly, g_esMedicAbility[iType].g_flCloseAreasOnly, 1);
		g_esMedicCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iComboAbility, g_esMedicPlayer[tank].g_iComboAbility, g_esMedicSpecial[iType].g_iComboAbility, g_esMedicAbility[iType].g_iComboAbility, 1);
		g_esMedicCache[tank].g_flMedicBuffDamage = flGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_flMedicBuffDamage, g_esMedicPlayer[tank].g_flMedicBuffDamage, g_esMedicSpecial[iType].g_flMedicBuffDamage, g_esMedicAbility[iType].g_flMedicBuffDamage, 1);
		g_esMedicCache[tank].g_flMedicBuffResistance = flGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_flMedicBuffResistance, g_esMedicPlayer[tank].g_flMedicBuffResistance, g_esMedicSpecial[iType].g_flMedicBuffResistance, g_esMedicAbility[iType].g_flMedicBuffResistance, 1);
		g_esMedicCache[tank].g_flMedicBuffSpeed = flGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_flMedicBuffSpeed, g_esMedicPlayer[tank].g_flMedicBuffSpeed, g_esMedicSpecial[iType].g_flMedicBuffSpeed, g_esMedicAbility[iType].g_flMedicBuffSpeed, 1);
		g_esMedicCache[tank].g_flMedicChance = flGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_flMedicChance, g_esMedicPlayer[tank].g_flMedicChance, g_esMedicSpecial[iType].g_flMedicChance, g_esMedicAbility[iType].g_flMedicChance, 1);
		g_esMedicCache[tank].g_flMedicInterval = flGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_flMedicInterval, g_esMedicPlayer[tank].g_flMedicInterval, g_esMedicSpecial[iType].g_flMedicInterval, g_esMedicAbility[iType].g_flMedicInterval, 1);
		g_esMedicCache[tank].g_flMedicRange = flGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_flMedicRange, g_esMedicPlayer[tank].g_flMedicRange, g_esMedicSpecial[iType].g_flMedicRange, g_esMedicAbility[iType].g_flMedicRange, 1);
		g_esMedicCache[tank].g_flMedicRockChance = flGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_flMedicRockChance, g_esMedicPlayer[tank].g_flMedicRockChance, g_esMedicSpecial[iType].g_flMedicRockChance, g_esMedicAbility[iType].g_flMedicRockChance, 1);
		g_esMedicCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iHumanAbility, g_esMedicPlayer[tank].g_iHumanAbility, g_esMedicSpecial[iType].g_iHumanAbility, g_esMedicAbility[iType].g_iHumanAbility, 1);
		g_esMedicCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iHumanAmmo, g_esMedicPlayer[tank].g_iHumanAmmo, g_esMedicSpecial[iType].g_iHumanAmmo, g_esMedicAbility[iType].g_iHumanAmmo, 1);
		g_esMedicCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iHumanCooldown, g_esMedicPlayer[tank].g_iHumanCooldown, g_esMedicSpecial[iType].g_iHumanCooldown, g_esMedicAbility[iType].g_iHumanCooldown, 1);
		g_esMedicCache[tank].g_iHumanDuration = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iHumanDuration, g_esMedicPlayer[tank].g_iHumanDuration, g_esMedicSpecial[iType].g_iHumanDuration, g_esMedicAbility[iType].g_iHumanDuration, 1);
		g_esMedicCache[tank].g_iHumanMode = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iHumanMode, g_esMedicPlayer[tank].g_iHumanMode, g_esMedicSpecial[iType].g_iHumanMode, g_esMedicAbility[iType].g_iHumanMode, 1);
		g_esMedicCache[tank].g_iHumanRockCooldown = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iHumanRockCooldown, g_esMedicPlayer[tank].g_iHumanRockCooldown, g_esMedicSpecial[iType].g_iHumanRockCooldown, g_esMedicAbility[iType].g_iHumanRockCooldown, 1);
		g_esMedicCache[tank].g_iMedicAbility = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicAbility, g_esMedicPlayer[tank].g_iMedicAbility, g_esMedicSpecial[iType].g_iMedicAbility, g_esMedicAbility[iType].g_iMedicAbility, 1);
		g_esMedicCache[tank].g_iMedicCooldown = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicCooldown, g_esMedicPlayer[tank].g_iMedicCooldown, g_esMedicSpecial[iType].g_iMedicCooldown, g_esMedicAbility[iType].g_iMedicCooldown, 1);
		g_esMedicCache[tank].g_iMedicDuration = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicDuration, g_esMedicPlayer[tank].g_iMedicDuration, g_esMedicSpecial[iType].g_iMedicDuration, g_esMedicAbility[iType].g_iMedicDuration, 1);
		g_esMedicCache[tank].g_iMedicField = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicField, g_esMedicPlayer[tank].g_iMedicField, g_esMedicSpecial[iType].g_iMedicField, g_esMedicAbility[iType].g_iMedicField, 1);
		g_esMedicCache[tank].g_iMedicMessage = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicMessage, g_esMedicPlayer[tank].g_iMedicMessage, g_esMedicSpecial[iType].g_iMedicMessage, g_esMedicAbility[iType].g_iMedicMessage, 1);
		g_esMedicCache[tank].g_iMedicRockBreak = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicRockBreak, g_esMedicPlayer[tank].g_iMedicRockBreak, g_esMedicSpecial[iType].g_iMedicRockBreak, g_esMedicAbility[iType].g_iMedicRockBreak, 1);
		g_esMedicCache[tank].g_iMedicRockCooldown = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicRockCooldown, g_esMedicPlayer[tank].g_iMedicRockCooldown, g_esMedicSpecial[iType].g_iMedicRockCooldown, g_esMedicAbility[iType].g_iMedicRockCooldown, 1);
		g_esMedicCache[tank].g_iMedicSight = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicSight, g_esMedicPlayer[tank].g_iMedicSight, g_esMedicSpecial[iType].g_iMedicSight, g_esMedicAbility[iType].g_iMedicSight, 1);
		g_esMedicCache[tank].g_iMedicSymbiosis = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicSymbiosis, g_esMedicPlayer[tank].g_iMedicSymbiosis, g_esMedicSpecial[iType].g_iMedicSymbiosis, g_esMedicAbility[iType].g_iMedicSymbiosis, 1);
		g_esMedicCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_flOpenAreasOnly, g_esMedicPlayer[tank].g_flOpenAreasOnly, g_esMedicSpecial[iType].g_flOpenAreasOnly, g_esMedicAbility[iType].g_flOpenAreasOnly, 1);
		g_esMedicCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iRequiresHumans, g_esMedicPlayer[tank].g_iRequiresHumans, g_esMedicSpecial[iType].g_iRequiresHumans, g_esMedicAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esMedicCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_flCloseAreasOnly, g_esMedicAbility[iType].g_flCloseAreasOnly, 1);
		g_esMedicCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iComboAbility, g_esMedicAbility[iType].g_iComboAbility, 1);
		g_esMedicCache[tank].g_flMedicBuffDamage = flGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_flMedicBuffDamage, g_esMedicAbility[iType].g_flMedicBuffDamage, 1);
		g_esMedicCache[tank].g_flMedicBuffResistance = flGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_flMedicBuffResistance, g_esMedicAbility[iType].g_flMedicBuffResistance, 1);
		g_esMedicCache[tank].g_flMedicBuffSpeed = flGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_flMedicBuffSpeed, g_esMedicAbility[iType].g_flMedicBuffSpeed, 1);
		g_esMedicCache[tank].g_flMedicChance = flGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_flMedicChance, g_esMedicAbility[iType].g_flMedicChance, 1);
		g_esMedicCache[tank].g_flMedicInterval = flGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_flMedicInterval, g_esMedicAbility[iType].g_flMedicInterval, 1);
		g_esMedicCache[tank].g_flMedicRange = flGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_flMedicRange, g_esMedicAbility[iType].g_flMedicRange, 1);
		g_esMedicCache[tank].g_flMedicRockChance = flGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_flMedicRockChance, g_esMedicAbility[iType].g_flMedicRockChance, 1);
		g_esMedicCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iHumanAbility, g_esMedicAbility[iType].g_iHumanAbility, 1);
		g_esMedicCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iHumanAmmo, g_esMedicAbility[iType].g_iHumanAmmo, 1);
		g_esMedicCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iHumanCooldown, g_esMedicAbility[iType].g_iHumanCooldown, 1);
		g_esMedicCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iHumanDuration, g_esMedicAbility[iType].g_iHumanDuration, 1);
		g_esMedicCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iHumanMode, g_esMedicAbility[iType].g_iHumanMode, 1);
		g_esMedicCache[tank].g_iHumanRockCooldown = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iHumanRockCooldown, g_esMedicAbility[iType].g_iHumanRockCooldown, 1);
		g_esMedicCache[tank].g_iMedicAbility = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicAbility, g_esMedicAbility[iType].g_iMedicAbility, 1);
		g_esMedicCache[tank].g_iMedicCooldown = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicCooldown, g_esMedicAbility[iType].g_iMedicCooldown, 1);
		g_esMedicCache[tank].g_iMedicDuration = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicDuration, g_esMedicAbility[iType].g_iMedicDuration, 1);
		g_esMedicCache[tank].g_iMedicField = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicField, g_esMedicAbility[iType].g_iMedicField, 1);
		g_esMedicCache[tank].g_iMedicMessage = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicMessage, g_esMedicAbility[iType].g_iMedicMessage, 1);
		g_esMedicCache[tank].g_iMedicRockBreak = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicRockBreak, g_esMedicAbility[iType].g_iMedicRockBreak, 1);
		g_esMedicCache[tank].g_iMedicRockCooldown = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicRockCooldown, g_esMedicAbility[iType].g_iMedicRockCooldown, 1);
		g_esMedicCache[tank].g_iMedicSight = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicSight, g_esMedicAbility[iType].g_iMedicSight, 1);
		g_esMedicCache[tank].g_iMedicSymbiosis = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicSymbiosis, g_esMedicAbility[iType].g_iMedicSymbiosis, 1);
		g_esMedicCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_flOpenAreasOnly, g_esMedicAbility[iType].g_flOpenAreasOnly, 1);
		g_esMedicCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iRequiresHumans, g_esMedicAbility[iType].g_iRequiresHumans, 1);
	}

	for (int iPos = 0; iPos < (sizeof esMedicCache::g_iMedicHealth); iPos++)
	{
		if (bInfected)
		{
			g_esMedicCache[tank].g_iMedicHealth[iPos] = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicHealth[iPos], g_esMedicPlayer[tank].g_iMedicHealth[iPos], g_esMedicSpecial[iType].g_iMedicHealth[iPos], g_esMedicAbility[iType].g_iMedicHealth[iPos], 1);
			g_esMedicCache[tank].g_iMedicMaxHealth[iPos] = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicMaxHealth[iPos], g_esMedicPlayer[tank].g_iMedicMaxHealth[iPos], g_esMedicSpecial[iType].g_iMedicMaxHealth[iPos], g_esMedicAbility[iType].g_iMedicMaxHealth[iPos], 1);
		}
		else
		{
			g_esMedicCache[tank].g_iMedicHealth[iPos] = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicHealth[iPos], g_esMedicAbility[iType].g_iMedicHealth[iPos], 1);
			g_esMedicCache[tank].g_iMedicMaxHealth[iPos] = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicMaxHealth[iPos], g_esMedicAbility[iType].g_iMedicMaxHealth[iPos], 1);
		}

		if (iPos < (sizeof esMedicCache::g_iMedicFieldColor))
		{
			switch (bInfected)
			{
				case true: g_esMedicCache[tank].g_iMedicFieldColor[iPos] = iGetSubSettingValue(apply, bHuman, g_esMedicTeammate[tank].g_iMedicFieldColor[iPos], g_esMedicPlayer[tank].g_iMedicFieldColor[iPos], g_esMedicSpecial[iType].g_iMedicFieldColor[iPos], g_esMedicAbility[iType].g_iMedicFieldColor[iPos], 1);
				case false: g_esMedicCache[tank].g_iMedicFieldColor[iPos] = iGetSettingValue(apply, bHuman, g_esMedicPlayer[tank].g_iMedicFieldColor[iPos], g_esMedicAbility[iType].g_iMedicFieldColor[iPos], 1);
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vMedicCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vMedicCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveMedic(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vMedicEventFired(Event event, const char[] name)
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
			vMedicCopyStats2(iBot, iTank);
			vRemoveMedic(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vMedicReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vMedicCopyStats2(iTank, iBot);
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
}

#if defined MT_ABILITIES_MAIN2
void vMedicAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMedicAbility[g_esMedicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esMedicPlayer[tank].g_iAccessFlags)) || g_esMedicCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esMedicCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esMedicCache[tank].g_iMedicAbility == 1 && g_esMedicCache[tank].g_iComboAbility == 0 && !g_esMedicPlayer[tank].g_bActivated)
	{
		vMedicAbility(tank);
	}
}

#if defined MT_ABILITIES_MAIN2
void vMedicButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esMedicCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esMedicCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esMedicPlayer[tank].g_iTankType, tank) || (g_esMedicCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMedicCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMedicAbility[g_esMedicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esMedicPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_MAIN_KEY) && g_esMedicCache[tank].g_iMedicAbility == 1 && g_esMedicCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();
			bool bRecharging = g_esMedicPlayer[tank].g_iCooldown != -1 && g_esMedicPlayer[tank].g_iCooldown >= iTime;

			switch (g_esMedicCache[tank].g_iHumanMode)
			{
				case 0:
				{
					if (!g_esMedicPlayer[tank].g_bActivated && !bRecharging)
					{
						vMedicAbility(tank);
					}
					else if (g_esMedicPlayer[tank].g_bActivated)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman3");
					}
					else if (bRecharging)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman4", (g_esMedicPlayer[tank].g_iCooldown - iTime));
					}
				}
				case 1:
				{
					if (g_esMedicPlayer[tank].g_iAmmoCount < g_esMedicCache[tank].g_iHumanAmmo && g_esMedicCache[tank].g_iHumanAmmo > 0)
					{
						if (!g_esMedicPlayer[tank].g_bActivated && !bRecharging)
						{
							g_esMedicPlayer[tank].g_bActivated = true;
							g_esMedicPlayer[tank].g_iAmmoCount++;

							vMedic2(tank);
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman", g_esMedicPlayer[tank].g_iAmmoCount, g_esMedicCache[tank].g_iHumanAmmo);
						}
						else if (g_esMedicPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman4", (g_esMedicPlayer[tank].g_iCooldown - iTime));
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

#if defined MT_ABILITIES_MAIN2
void vMedicButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esMedicCache[tank].g_iHumanAbility == 1)
	{
		if ((button & MT_MAIN_KEY) && g_esMedicCache[tank].g_iHumanMode == 1 && g_esMedicPlayer[tank].g_bActivated && (g_esMedicPlayer[tank].g_iCooldown == -1 || g_esMedicPlayer[tank].g_iCooldown <= GetTime()))
		{
			vMedicReset2(tank);
			vMedicReset3(tank);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vMedicChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveMedic(tank);
}

#if defined MT_ABILITIES_MAIN2
void vMedicRockBreak(int tank, int rock)
#else
public void MT_OnRockBreak(int tank, int rock)
#endif
{
	if (bIsAreaNarrow(tank, g_esMedicCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esMedicCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esMedicPlayer[tank].g_iTankType, tank) || (g_esMedicCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMedicCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMedicAbility[g_esMedicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esMedicPlayer[tank].g_iAccessFlags)) || g_esMedicCache[tank].g_iHumanAbility == 0)))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && g_esMedicCache[tank].g_iMedicRockBreak == 1 && g_esMedicCache[tank].g_iComboAbility == 0)
	{
		vMedicRockBreak2(tank, rock, GetRandomFloat(0.1, 100.0));
	}
}

void vMedic(int tank, int pos = -1)
{
	if (g_esMedicPlayer[tank].g_iCooldown != -1 && g_esMedicPlayer[tank].g_iCooldown >= GetTime())
	{
		return;
	}

	g_esMedicPlayer[tank].g_bActivated = true;

	vMedic2(tank, pos);

	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esMedicCache[tank].g_iHumanAbility == 1)
	{
		g_esMedicPlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman", g_esMedicPlayer[tank].g_iAmmoCount, g_esMedicCache[tank].g_iHumanAmmo);
	}

	if (g_esMedicCache[tank].g_iMedicMessage == 1)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Medic", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Medic", LANG_SERVER, sTankName);
	}
}

void vMedic2(int tank, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esMedicCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esMedicCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esMedicPlayer[tank].g_iTankType, tank) || (g_esMedicCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMedicCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMedicAbility[g_esMedicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esMedicPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 6, pos) : g_esMedicCache[tank].g_flMedicInterval;
	if (flInterval > 0.0)
	{
		DataPack dpMedic;
		CreateDataTimer(flInterval, tTimerMedic, dpMedic, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpMedic.WriteCell(GetClientUserId(tank));
		dpMedic.WriteCell(g_esMedicPlayer[tank].g_iTankType);
		dpMedic.WriteCell(GetTime());
		dpMedic.WriteCell(pos);
	}
}

void vMedic3(int tank, float origin[3], int duration, int pos = -1)
{
	float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esMedicCache[tank].g_flMedicRange;
	if (g_esMedicCache[tank].g_iMedicField == 1)
	{
		origin[2] += 10.0;
		TE_SetupBeamRingPoint(origin, 50.0, flRange, g_iMedicBeamSprite, g_iMedicHaloSprite, 0, 0, 1.0, 3.0, 0.0, iGetRandomColors(tank), 0, 0);
		TE_SendToAll();
	}

	float flInfectedPos[3];
	int iCount = 0;
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (((MT_IsTankSupported(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bIsPlayerIncapacitated(iInfected)) || bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE)) && tank != iInfected)
		{
			GetClientAbsOrigin(iInfected, flInfectedPos);
			if (GetVectorDistance(origin, flInfectedPos) <= flRange && bIsVisibleToPlayer(tank, iInfected, g_esMedicCache[tank].g_iMedicSight, .range = flRange))
			{
				vMedic4(iInfected, tank, duration);

				iCount++;
			}
		}
	}

	if (g_esMedicCache[tank].g_iMedicSymbiosis == 1 && iCount > 0)
	{
		vMedic4(tank, tank, duration);
	}
}

void vMedic4(int special, int tank, int duration)
{
	int iHealth = 0, iValue = 0, iLimit = 0, iMaxHealth = 0, iNewHealth = 0, iLeftover = 0, iExtraHealth = 0, iExtraHealth2 = 0, iRealHealth = 0, iTotalHealth = 0;
	iHealth = GetEntProp(special, Prop_Data, "m_iHealth");
	iValue = iGetHealth(tank, special);
	iLimit = iGetMaxHealth(tank, special);
	iMaxHealth = (special == tank) ? MT_TankMaxHealth(special, 1) : GetEntProp(special, Prop_Data, "m_iMaxHealth");
	iNewHealth = (iHealth + iValue);
	iLeftover = (iNewHealth > iLimit) ? (iNewHealth - iLimit) : iNewHealth;
	iExtraHealth = iClamp(iNewHealth, 1, iLimit);
	iExtraHealth2 = (iNewHealth < iHealth) ? 1 : iNewHealth;
	iRealHealth = (iNewHealth >= 0) ? iExtraHealth : iExtraHealth2;
	iTotalHealth = (iNewHealth > iLimit) ? iLeftover : iValue;
	SetEntProp(special, Prop_Data, "m_iHealth", iRealHealth);

	if (special == tank)
	{
		MT_TankMaxHealth(special, 3, (iMaxHealth + iTotalHealth));
	}

	g_esMedicPlayer[special].g_flDamageBuff = g_esMedicCache[tank].g_flMedicBuffDamage;
	g_esMedicPlayer[special].g_flDefaultSpeed = MT_GetRunSpeed(tank);
	g_esMedicPlayer[special].g_flResistanceBuff = g_esMedicCache[tank].g_flMedicBuffResistance;

	if (g_esMedicCache[tank].g_flMedicBuffSpeed > 0.0)
	{
		float flSpeed = (g_esMedicPlayer[special].g_flDefaultSpeed * g_esMedicCache[tank].g_flMedicBuffSpeed);
		SetEntPropFloat(special, Prop_Send, "m_flLaggedMovementValue", (g_bLaggedMovementInstalled ? L4D_LaggedMovement(special, flSpeed) : flSpeed));
	}

	float flDuration = float(duration);
	if (flDuration > 0.0)
	{
		delete g_esMedicPlayer[special].g_hBuffTimer;

		g_esMedicPlayer[special].g_hBuffTimer = CreateTimer(flDuration, tTimerRemoveBuffs, GetClientUserId(special), TIMER_FLAG_NO_MAPCHANGE);
	}

	if (g_esMedicCache[tank].g_iMedicMessage == 1)
	{
		char sTankName[64], sInfectedName[33];
		MT_GetTankName(tank, sTankName);
		if (MT_IsTankSupported(special, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			MT_GetTankName(special, sInfectedName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Medic3", sTankName, sInfectedName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Medic3", LANG_SERVER, sTankName, sInfectedName);
		}
		else
		{
			MT_PrintToChatAll("%s %t", MT_TAG2, "Medic2", sTankName, special);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Medic2", LANG_SERVER, sTankName, special);
		}
	}
}

void vMedicAbility(int tank)
{
	if ((g_esMedicPlayer[tank].g_iCooldown != -1 && g_esMedicPlayer[tank].g_iCooldown >= GetTime()) || bIsAreaNarrow(tank, g_esMedicCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esMedicCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esMedicPlayer[tank].g_iTankType, tank) || (g_esMedicCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMedicCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMedicAbility[g_esMedicPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esMedicPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esMedicPlayer[tank].g_iAmmoCount < g_esMedicCache[tank].g_iHumanAmmo && g_esMedicCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esMedicCache[tank].g_flMedicChance)
		{
			vMedic(tank);
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esMedicCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman2");
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esMedicCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicAmmo");
	}
}

void vMedicRockBreak2(int tank, int rock, float random, int pos = -1)
{
	float flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 14, pos) : g_esMedicCache[tank].g_flMedicRockChance;
	if (random <= flChance)
	{
		int iTime = GetTime(), iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esMedicCache[tank].g_iHumanAbility == 1) ? g_esMedicCache[tank].g_iHumanRockCooldown : g_esMedicCache[tank].g_iMedicRockCooldown;
		iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 15, pos)) : iCooldown;
		if (g_esMedicPlayer[tank].g_iRockCooldown == -1 || g_esMedicPlayer[tank].g_iRockCooldown <= iTime)
		{
			g_esMedicPlayer[tank].g_iRockCooldown = (iTime + iCooldown);
			if (g_esMedicPlayer[tank].g_iRockCooldown != -1 && g_esMedicPlayer[tank].g_iRockCooldown >= iTime)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman5", (g_esMedicPlayer[tank].g_iRockCooldown - iTime));
			}
		}
		else if (g_esMedicPlayer[tank].g_iRockCooldown != -1 && g_esMedicPlayer[tank].g_iRockCooldown >= iTime)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman3", (g_esMedicPlayer[tank].g_iRockCooldown - iTime));

			return;
		}

		bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
		float flPos[3];
		GetEntPropVector(rock, Prop_Data, "m_vecOrigin", flPos);
		int iDuration = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 5, pos)) : g_esMedicCache[tank].g_iMedicDuration;
		iDuration = (bHuman && g_esMedicCache[tank].g_iHumanAbility == 1) ? g_esMedicCache[tank].g_iHumanDuration : iDuration;
		vMedic3(tank, flPos, iDuration, pos);

		if (g_esMedicCache[tank].g_iMedicMessage & MT_MESSAGE_SPECIAL)
		{
			char sTankName[64];
			MT_GetTankName(tank, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Medic2", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Medic2", LANG_SERVER, sTankName);
		}
	}
}

void vMedicCopyStats2(int oldTank, int newTank)
{
	g_esMedicPlayer[newTank].g_iAmmoCount = g_esMedicPlayer[oldTank].g_iAmmoCount;
	g_esMedicPlayer[newTank].g_iCooldown = g_esMedicPlayer[oldTank].g_iCooldown;
	g_esMedicPlayer[newTank].g_iRockCooldown = g_esMedicPlayer[oldTank].g_iRockCooldown;
}

void vRemoveMedic(int tank)
{
	g_esMedicPlayer[tank].g_bActivated = false;
	g_esMedicPlayer[tank].g_hBuffTimer = null;
	g_esMedicPlayer[tank].g_flDamageBuff = 0.0;
	g_esMedicPlayer[tank].g_flDefaultSpeed = 0.0;
	g_esMedicPlayer[tank].g_flResistanceBuff = 0.0;
	g_esMedicPlayer[tank].g_iAmmoCount = 0;
	g_esMedicPlayer[tank].g_iCooldown = -1;
	g_esMedicPlayer[tank].g_iRockCooldown = -1;
}

void vMedicReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveMedic(iPlayer);
		}
	}
}

void vMedicReset2(int tank)
{
	g_esMedicPlayer[tank].g_bActivated = false;

	if (g_esMedicCache[tank].g_iMedicMessage == 1)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Medic4", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Medic4", LANG_SERVER, sTankName);
	}
}

void vMedicReset3(int tank)
{
	int iTime = GetTime(), iPos = g_esMedicAbility[g_esMedicPlayer[tank].g_iTankTypeRecorded].g_iComboPosition, iCooldown = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, iPos)) : g_esMedicCache[tank].g_iMedicCooldown;
	iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esMedicCache[tank].g_iHumanAbility == 1 && g_esMedicCache[tank].g_iHumanMode == 0 && g_esMedicPlayer[tank].g_iAmmoCount < g_esMedicCache[tank].g_iHumanAmmo && g_esMedicCache[tank].g_iHumanAmmo > 0) ? g_esMedicCache[tank].g_iHumanCooldown : iCooldown;
	g_esMedicPlayer[tank].g_iCooldown = (iTime + iCooldown);
	if (g_esMedicPlayer[tank].g_iCooldown != -1 && g_esMedicPlayer[tank].g_iCooldown >= iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman5", (g_esMedicPlayer[tank].g_iCooldown - iTime));
	}
}

int iGetHealth(int tank, int infected)
{
	int iClass = GetEntProp(infected, Prop_Send, "m_zombieClass");

	switch (iClass)
	{
		case 1: return g_esMedicCache[tank].g_iMedicHealth[iClass - 1];
		case 2: return g_esMedicCache[tank].g_iMedicHealth[iClass - 1];
		case 3: return g_esMedicCache[tank].g_iMedicHealth[iClass - 1];
		case 4: return g_esMedicCache[tank].g_iMedicHealth[iClass - 1];
		case 5: return g_bSecondGame ? g_esMedicCache[tank].g_iMedicHealth[iClass - 1] : g_esMedicCache[tank].g_iMedicHealth[iClass + 1];
		case 6: return g_esMedicCache[tank].g_iMedicHealth[iClass - 1];
		case 8: return g_esMedicCache[tank].g_iMedicHealth[iClass - 2];
	}

	return 0;
}

int iGetMaxHealth(int tank, int infected)
{
	int iClass = GetEntProp(infected, Prop_Send, "m_zombieClass");

	switch (iClass)
	{
		case 1: return g_esMedicCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 2: return g_esMedicCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 3: return g_esMedicCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 4: return g_esMedicCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 5: return g_bSecondGame ? g_esMedicCache[tank].g_iMedicMaxHealth[iClass - 1] : g_esMedicCache[tank].g_iMedicMaxHealth[iClass + 1];
		case 6: return g_esMedicCache[tank].g_iMedicMaxHealth[iClass - 1];
		case 8: return g_esMedicCache[tank].g_iMedicMaxHealth[iClass - 2];
	}

	return 0;
}

int[] iGetRandomColors(int tank)
{
	for (int iPos = 0; iPos < (sizeof esMedicCache::g_iMedicFieldColor - 1); iPos++)
	{
		g_esMedicCache[tank].g_iMedicFieldColor[iPos] = iGetRandomColor(g_esMedicCache[tank].g_iMedicFieldColor[iPos]);
	}

	g_esMedicCache[tank].g_iMedicFieldColor[3] = 255;

	return g_esMedicCache[tank].g_iMedicFieldColor;
}

void tTimerMedicCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esMedicAbility[g_esMedicPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esMedicPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esMedicPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esMedicCache[iTank].g_iMedicAbility == 0 || g_esMedicPlayer[iTank].g_bActivated)
	{
		return;
	}

	int iPos = pack.ReadCell();
	vMedic(iTank, iPos);
}

Action tTimerMedic(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsPlayerIncapacitated(iTank) || bIsAreaNarrow(iTank, g_esMedicCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esMedicCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esMedicPlayer[iTank].g_iTankType, iTank) || (g_esMedicCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMedicCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esMedicAbility[g_esMedicPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esMedicPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esMedicPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esMedicPlayer[iTank].g_iTankType || g_esMedicCache[iTank].g_iMedicAbility == 0 || !g_esMedicPlayer[iTank].g_bActivated)
	{
		vMedicReset2(iTank);

		return Plugin_Stop;
	}

	bool bHuman = bIsInfected(iTank, MT_CHECK_FAKECLIENT);
	int iTime = pack.ReadCell(), iCurrentTime = GetTime(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : g_esMedicCache[iTank].g_iMedicDuration;
	iDuration = (bHuman && g_esMedicCache[iTank].g_iHumanAbility == 1) ? g_esMedicCache[iTank].g_iHumanDuration : iDuration;
	if (iDuration > 0 && (!bHuman || (bHuman && g_esMedicCache[iTank].g_iHumanAbility == 1 && g_esMedicCache[iTank].g_iHumanMode == 0)) && (iTime + iDuration) < iCurrentTime && (g_esMedicPlayer[iTank].g_iCooldown == -1 || g_esMedicPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vMedicReset2(iTank);
		vMedicReset3(iTank);

		return Plugin_Stop;
	}

	float flTankPos[3];
	GetClientAbsOrigin(iTank, flTankPos);
	vMedic3(iTank, flTankPos, iDuration, iPos);

	return Plugin_Continue;
}

void tTimerRemoveBuffs(Handle timer, int userid)
{
	int iInfected = GetClientOfUserId(userid);
	if (!bIsInfected(iInfected))
	{
		g_esMedicPlayer[iInfected].g_hBuffTimer = null;

		return;
	}

	float flSpeed = bIsInfected(iInfected) ? g_esMedicPlayer[iInfected].g_flDefaultSpeed : 1.0;
	g_esMedicPlayer[iInfected].g_hBuffTimer = null;
	g_esMedicPlayer[iInfected].g_flDamageBuff = 0.0;
	g_esMedicPlayer[iInfected].g_flResistanceBuff = 0.0;
	g_esMedicPlayer[iInfected].g_flDefaultSpeed = 0.0;

	SetEntPropFloat(iInfected, Prop_Send, "m_flLaggedMovementValue", (g_bLaggedMovementInstalled ? L4D_LaggedMovement(iInfected, flSpeed) : flSpeed));
}