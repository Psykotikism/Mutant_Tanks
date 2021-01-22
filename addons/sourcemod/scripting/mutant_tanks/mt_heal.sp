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
#include <sdkhooks>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Heal Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank gains health from other nearby infected and sets survivors to temporary health who will die when they reach 0 HP.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad, g_bSecondGame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Heal Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_HEARTBEAT	 "player/heartbeatloop.wav"

#define MT_CONFIG_SECTION "healability"
#define MT_CONFIG_SECTION2 "heal ability"
#define MT_CONFIG_SECTION3 "heal_ability"
#define MT_CONFIG_SECTION4 "heal"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_HEAL "Heal Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flHealAbsorbRange;
	float g_flHealBuffer;
	float g_flHealChance;
	float g_flHealInterval;
	float g_flHealRange;
	float g_flHealRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iAmmoCount2;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iHealAbility;
	int g_iHealCommon;
	int g_iHealEffect;
	int g_iHealHit;
	int g_iHealHitMode;
	int g_iHealMessage;
	int g_iHealSpecial;
	int g_iHealTank;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flHealAbsorbRange;
	float g_flHealBuffer;
	float g_flHealChance;
	float g_flHealInterval;
	float g_flHealRange;
	float g_flHealRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHealAbility;
	int g_iHealCommon;
	int g_iHealEffect;
	int g_iHealHit;
	int g_iHealHitMode;
	int g_iHealMessage;
	int g_iHealSpecial;
	int g_iHealTank;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flHealAbsorbRange;
	float g_flHealBuffer;
	float g_flHealChance;
	float g_flHealInterval;
	float g_flHealRange;
	float g_flHealRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHealAbility;
	int g_iHealCommon;
	int g_iHealEffect;
	int g_iHealHit;
	int g_iHealHitMode;
	int g_iHealMessage;
	int g_iHealSpecial;
	int g_iHealTank;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

ConVar g_cvMTMaxIncapCount;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_heal", cmdHealInfo, "View information about the Heal ability.");

	g_cvMTMaxIncapCount = FindConVar("survivor_max_incapacitated_count");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	PrecacheSound(SOUND_HEARTBEAT, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveHeal(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveHeal(client);
}

public void OnMapEnd()
{
	vReset();
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			vResetGlow(iTank);
		}
	}
}

public Action cmdHealInfo(int client, int args)
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
		case false: vHealMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vHealMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iHealMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Heal Ability Information");
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

public int iHealMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHealAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount2, g_esCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "HealDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vHealMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pHeal = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "HealMenu", param1);
			pHeal.SetTitle(sMenuTitle);
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
	menu.AddItem(MT_MENU_HEAL, MT_MENU_HEAL);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_HEAL, false))
	{
		vHealMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_HEAL, false))
	{
		FormatEx(buffer, size, "%T", "HealMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsValidEntity(inflictor) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iHealHitMode == 0 || g_esCache[attacker].g_iHealHitMode == 1) && bIsSurvivor(victim) && g_esCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHealHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esCache[attacker].g_flHealChance, g_esCache[attacker].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iHealHitMode == 0 || g_esCache[victim].g_iHealHitMode == 2) && bIsSurvivor(attacker) && g_esCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vHealHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esCache[victim].g_flHealChance, g_esCache[victim].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
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
	if (g_esCache[tank].g_iComboAbility == 1 && (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1))
	{
		static char sSubset[10][32];
		ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
		for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_CONFIG_SECTION, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION2, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION3, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION4, false))
			{
				static float flDelay;
				flDelay = MT_GetCombinationSetting(tank, 3, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esCache[tank].g_iHealAbility == 1 || g_esCache[tank].g_iHealAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vHealAbility(tank, true, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}
						else if (g_esCache[tank].g_iHealAbility == 2 || g_esCache[tank].g_iHealAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vHealAbility(tank, false, _, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteCell(iPos);
								}
							}
						}
					}
					case MT_COMBO_MELEEHIT:
					{
						static float flChance;
						flChance = MT_GetCombinationSetting(tank, 1, iPos);

						switch (flDelay)
						{
							case 0.0:
							{
								if ((g_esCache[tank].g_iHealHitMode == 0 || g_esCache[tank].g_iHealHitMode == 1) && (StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vHealHit(survivor, tank, random, flChance, g_esCache[tank].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esCache[tank].g_iHealHitMode == 0 || g_esCache[tank].g_iHealHitMode == 2) && StrEqual(classname, "weapon_melee"))
								{
									vHealHit(survivor, tank, random, flChance, g_esCache[tank].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerCombo3, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteString(classname);
							}
						}
					}
				}

				break;
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
				g_esAbility[iIndex].g_iImmunityFlags = 0;
				g_esAbility[iIndex].g_iComboAbility = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iHumanDuration = 5;
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iHealAbility = 0;
				g_esAbility[iIndex].g_iHealEffect = 0;
				g_esAbility[iIndex].g_iHealMessage = 0;
				g_esAbility[iIndex].g_flHealBuffer = 100.0;
				g_esAbility[iIndex].g_flHealChance = 33.3;
				g_esAbility[iIndex].g_flHealAbsorbRange = 500.0;
				g_esAbility[iIndex].g_iHealHit = 0;
				g_esAbility[iIndex].g_iHealHitMode = 0;
				g_esAbility[iIndex].g_flHealInterval = 5.0;
				g_esAbility[iIndex].g_flHealRange = 150.0;
				g_esAbility[iIndex].g_flHealRangeChance = 15.0;
				g_esAbility[iIndex].g_iHealCommon = 50;
				g_esAbility[iIndex].g_iHealSpecial = 100;
				g_esAbility[iIndex].g_iHealTank = 500;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iImmunityFlags = 0;
					g_esPlayer[iPlayer].g_iComboAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanDuration = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iHealAbility = 0;
					g_esPlayer[iPlayer].g_iHealEffect = 0;
					g_esPlayer[iPlayer].g_iHealMessage = 0;
					g_esPlayer[iPlayer].g_flHealBuffer = 0.0;
					g_esPlayer[iPlayer].g_flHealChance = 0.0;
					g_esPlayer[iPlayer].g_flHealAbsorbRange = 0.0;
					g_esPlayer[iPlayer].g_iHealHit = 0;
					g_esPlayer[iPlayer].g_iHealHitMode = 0;
					g_esPlayer[iPlayer].g_flHealInterval = 0.0;
					g_esPlayer[iPlayer].g_flHealRange = 0.0;
					g_esPlayer[iPlayer].g_flHealRangeChance = 0.0;
					g_esPlayer[iPlayer].g_iHealCommon = 0;
					g_esPlayer[iPlayer].g_iHealSpecial = 0;
					g_esPlayer[iPlayer].g_iHealTank = 0;
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
		g_esPlayer[admin].g_iHealAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iHealAbility, value, 0, 3);
		g_esPlayer[admin].g_iHealEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iHealEffect, value, 0, 7);
		g_esPlayer[admin].g_iHealMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iHealMessage, value, 0, 7);
		g_esPlayer[admin].g_flHealAbsorbRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealAbsorbRange", "Heal Absorb Range", "Heal_Absorb_Range", "absorbrange", g_esPlayer[admin].g_flHealAbsorbRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flHealBuffer = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealBuffer", "Heal Buffer", "Heal_Buffer", "buffer", g_esPlayer[admin].g_flHealBuffer, value, 1.0, float(MT_MAXHEALTH));
		g_esPlayer[admin].g_flHealChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealChance", "Heal Chance", "Heal_Chance", "chance", g_esPlayer[admin].g_flHealChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iHealHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealHit", "Heal Hit", "Heal_Hit", "hit", g_esPlayer[admin].g_iHealHit, value, 0, 1);
		g_esPlayer[admin].g_iHealHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealHitMode", "Heal Hit Mode", "Heal_Hit_Mode", "hitmode", g_esPlayer[admin].g_iHealHitMode, value, 0, 2);
		g_esPlayer[admin].g_flHealInterval = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealInterval", "Heal Interval", "Heal_Interval", "interval", g_esPlayer[admin].g_flHealInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flHealRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealRange", "Heal Range", "Heal_Range", "range", g_esPlayer[admin].g_flHealRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flHealRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealRangeChance", "Heal Range Chance", "Heal_Range_Chance", "rangechance", g_esPlayer[admin].g_flHealRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iHealCommon = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealthFromCommons", "Health From Commons", "Health_From_Commons", "commons", g_esPlayer[admin].g_iHealCommon, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		g_esPlayer[admin].g_iHealSpecial = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealthFromSpecials", "Health From Specials", "Health_From_Specials", "specials", g_esPlayer[admin].g_iHealSpecial, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		g_esPlayer[admin].g_iHealTank = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealthFromTanks", "Health From Tanks", "Health_From_Tanks", "tanks", g_esPlayer[admin].g_iHealTank, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
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
		g_esAbility[type].g_iHealAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iHealAbility, value, 0, 3);
		g_esAbility[type].g_iHealEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iHealEffect, value, 0, 7);
		g_esAbility[type].g_iHealMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iHealMessage, value, 0, 7);
		g_esAbility[type].g_flHealAbsorbRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealAbsorbRange", "Heal Absorb Range", "Heal_Absorb_Range", "absorbrange", g_esAbility[type].g_flHealAbsorbRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flHealBuffer = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealBuffer", "Heal Buffer", "Heal_Buffer", "buffer", g_esAbility[type].g_flHealBuffer, value, 1.0, float(MT_MAXHEALTH));
		g_esAbility[type].g_flHealChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealChance", "Heal Chance", "Heal_Chance", "chance", g_esAbility[type].g_flHealChance, value, 0.0, 100.0);
		g_esAbility[type].g_iHealHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealHit", "Heal Hit", "Heal_Hit", "hit", g_esAbility[type].g_iHealHit, value, 0, 1);
		g_esAbility[type].g_iHealHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealHitMode", "Heal Hit Mode", "Heal_Hit_Mode", "hitmode", g_esAbility[type].g_iHealHitMode, value, 0, 2);
		g_esAbility[type].g_flHealInterval = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealInterval", "Heal Interval", "Heal_Interval", "interval", g_esAbility[type].g_flHealInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flHealRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealRange", "Heal Range", "Heal_Range", "range", g_esAbility[type].g_flHealRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flHealRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealRangeChance", "Heal Range Chance", "Heal_Range_Chance", "rangechance", g_esAbility[type].g_flHealRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iHealCommon = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealthFromCommons", "Health From Commons", "Health_From_Commons", "commons", g_esAbility[type].g_iHealCommon, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		g_esAbility[type].g_iHealSpecial = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealthFromSpecials", "Health From Specials", "Health_From_Specials", "specials", g_esAbility[type].g_iHealSpecial, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		g_esAbility[type].g_iHealTank = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HealthFromTanks", "Health From Tanks", "Health_From_Tanks", "tanks", g_esAbility[type].g_iHealTank, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flHealAbsorbRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHealAbsorbRange, g_esAbility[type].g_flHealAbsorbRange);
	g_esCache[tank].g_flHealBuffer = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHealBuffer, g_esAbility[type].g_flHealBuffer);
	g_esCache[tank].g_flHealChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHealChance, g_esAbility[type].g_flHealChance);
	g_esCache[tank].g_flHealInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHealInterval, g_esAbility[type].g_flHealInterval);
	g_esCache[tank].g_flHealRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHealRange, g_esAbility[type].g_flHealRange);
	g_esCache[tank].g_flHealRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHealRangeChance, g_esAbility[type].g_flHealRangeChance);
	g_esCache[tank].g_iHealAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHealAbility, g_esAbility[type].g_iHealAbility);
	g_esCache[tank].g_iHealCommon = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHealCommon, g_esAbility[type].g_iHealCommon, 2);
	g_esCache[tank].g_iHealEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHealEffect, g_esAbility[type].g_iHealEffect);
	g_esCache[tank].g_iHealHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHealHit, g_esAbility[type].g_iHealHit);
	g_esCache[tank].g_iHealHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHealHitMode, g_esAbility[type].g_iHealHitMode);
	g_esCache[tank].g_iHealMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHealMessage, g_esAbility[type].g_iHealMessage);
	g_esCache[tank].g_iHealSpecial = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHealSpecial, g_esAbility[type].g_iHealSpecial, 2);
	g_esCache[tank].g_iHealTank = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHealTank, g_esAbility[type].g_iHealTank, 2);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanDuration, g_esAbility[type].g_iHumanDuration);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveHeal(oldTank);
	}
}

public void MT_OnHookEvent(bool hooked)
{
	switch (hooked)
	{
		case true: HookEvent("heal_success", MT_OnEventFired);
		case false: UnhookEvent("heal_success", MT_OnEventFired);
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
			vRemoveHeal(iBot);
		}
	}
	else if (StrEqual(name, "heal_success"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor))
		{
			g_esPlayer[iSurvivor].g_bAffected = false;

			SetEntProp(iSurvivor, Prop_Send, "m_currentReviveCount", 0);
			SetEntProp(iSurvivor, Prop_Send, "m_isGoingToDie", 0);

			if (g_bSecondGame)
			{
				SetEntProp(iSurvivor, Prop_Send, "m_bIsOnThirdStrike", 0);
			}

			vStopSound(iSurvivor, SOUND_HEARTBEAT);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveHeal(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_incapacitated") || StrEqual(name, "player_spawn"))
	{
		int iUserId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iUserId);
		if (bIsSurvivor(iPlayer))
		{
			vStopSound(iPlayer, SOUND_HEARTBEAT);
		}
		else if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveHeal(iPlayer);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iHealAbility > 0 && g_esCache[tank].g_iComboAbility == 0)
	{
		vHealAbility(tank, false);
		vHealAbility(tank, true, GetRandomFloat(0.1, 100.0));
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

		static int iTime;
		iTime = GetTime();
		if (button & MT_MAIN_KEY)
		{
			if ((g_esCache[tank].g_iHealAbility == 2 || g_esCache[tank].g_iHealAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vHealAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman4");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman5", g_esPlayer[tank].g_iCooldown - iTime);
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

								vHeal(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman4");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman5", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SUB_KEY)
		{
			if ((g_esCache[tank].g_iHealAbility == 1 || g_esCache[tank].g_iHealAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman6", g_esPlayer[tank].g_iCooldown2 - iTime);
					case false: vHealAbility(tank, true, GetRandomFloat(0.1, 100.0));
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
	vRemoveHeal(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iAmmoCount2 = g_esPlayer[oldTank].g_iAmmoCount2;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
	g_esPlayer[newTank].g_iCooldown2 = g_esPlayer[oldTank].g_iCooldown2;
}

static void vHeal(int tank, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static float flInterval;
	flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : g_esCache[tank].g_flHealInterval;
	DataPack dpHeal;
	CreateDataTimer(flInterval, tTimerHeal, dpHeal, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpHeal.WriteCell(GetClientUserId(tank));
	dpHeal.WriteCell(g_esPlayer[tank].g_iTankType);
	dpHeal.WriteCell(GetTime());
}

static void vHealAbility(int tank, bool main, float random = 0.0, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esCache[tank].g_iHealAbility == 1 || g_esCache[tank].g_iHealAbility == 3)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bFailed = false;
					g_esPlayer[tank].g_bNoAmmo = false;

					static float flTankPos[3];
					GetClientAbsOrigin(tank, flTankPos);

					static float flSurvivorPos[3], flRange, flChance;
					flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esCache[tank].g_flHealRange;
					flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esCache[tank].g_flHealRangeChance;
					static int iSurvivorCount;
					iSurvivorCount = 0;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
						{
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);
							if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange)
							{
								vHealHit(iSurvivor, tank, random, flChance, g_esCache[tank].g_iHealAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman7");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_esCache[tank].g_iHealAbility == 2 || g_esCache[tank].g_iHealAbility == 3) && !g_esPlayer[tank].g_bActivated)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bActivated = true;

					vHeal(tank, pos);

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
					{
						g_esPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
					}

					if (g_esCache[tank].g_iHealMessage & MT_MESSAGE_SPECIAL)
					{
						static char sTankName[33];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Heal2", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Heal2", LANG_SERVER, sTankName);
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo");
				}
			}
		}
	}
}

static void vHealHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor) && !bIsPlayerDisabled(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (random <= chance && GetEntProp(survivor, Prop_Data, "m_iHealth") > 0 && !g_esPlayer[survivor].g_bAffected)
			{
				g_esPlayer[survivor].g_bAffected = true;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
				{
					g_esPlayer[tank].g_iAmmoCount2++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman2", g_esPlayer[tank].g_iAmmoCount2, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown2 = (g_esPlayer[tank].g_iAmmoCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman9", g_esPlayer[tank].g_iCooldown2 - iTime);
					}
				}

				SetEntProp(survivor, Prop_Data, "m_iHealth", 1);
				SetEntPropFloat(survivor, Prop_Send, "m_healthBufferTime", GetGameTime());
				SetEntPropFloat(survivor, Prop_Send, "m_healthBuffer", g_esCache[tank].g_flHealBuffer);
				SetEntProp(survivor, Prop_Send, "m_currentReviveCount", g_cvMTMaxIncapCount.IntValue);
				SetEntProp(survivor, Prop_Send, "m_isGoingToDie", 1);

				if (g_bSecondGame)
				{
					SetEntProp(survivor, Prop_Send, "m_bIsOnThirdStrike", 1);
				}

				vEffect(survivor, tank, g_esCache[tank].g_iHealEffect, flags);

				if (g_esCache[tank].g_iHealMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Heal", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Heal", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo2");
		}
	}
}

static void vRemoveHeal(int tank)
{
	vResetGlow(tank);

	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iAmmoCount2 = 0;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCooldown2 = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveHeal(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;

	if (g_esCache[tank].g_iHealMessage & MT_MESSAGE_SPECIAL)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Heal3", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Heal3", LANG_SERVER, sTankName);
	}
}

static void vReset3(int tank)
{
	vResetGlow(tank);

	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman8", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static void vResetGlow(int tank)
{
	if (!bIsValidClient(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE))
	{
		return;
	}

	switch (MT_IsGlowEnabled(tank))
	{
		case true:
		{
			int iGlowColor[4];
			MT_GetTankColors(tank, 2, iGlowColor[0], iGlowColor[1], iGlowColor[2], iGlowColor[3]);
			vSetGlow(tank, iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]), (MT_IsGlowFlashing(tank) ? 1 : 0), MT_GetGlowRange(tank, false), MT_GetGlowRange(tank, true), (MT_GetGlowType(tank) == 1 ? 3 : 2));
		}
		case false: vSetGlow(tank, 0, 0, 0, 0, 0);
	}
}

static void vSetGlow(int tank, int color, int flashing, int min, int max, int type)
{
	if (!g_bSecondGame)
	{
		return;
	}

	SetEntProp(tank, Prop_Send, "m_glowColorOverride", color);
	SetEntProp(tank, Prop_Send, "m_bFlashing", flashing);
	SetEntProp(tank, Prop_Send, "m_nGlowRangeMin", min);
	SetEntProp(tank, Prop_Send, "m_nGlowRange", max);
	SetEntProp(tank, Prop_Send, "m_iGlowType", type);
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iHealAbility == 0 || g_esCache[iTank].g_iHealAbility == 2)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vHealAbility(iTank, true, flRandom, iPos);

	return Plugin_Continue;
}

public Action tTimerCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iHealAbility == 0 || g_esCache[iTank].g_iHealAbility == 1)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vHealAbility(iTank, false, _, iPos);

	return Plugin_Continue;
}

public Action tTimerCombo3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_bAffected)
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iHealHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof(sClassname));
	if ((g_esCache[iTank].g_iHealHitMode == 0 || g_esCache[iTank].g_iHealHitMode == 1) && (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vHealHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esCache[iTank].g_iHealHitMode == 0 || g_esCache[iTank].g_iHealHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
	{
		vHealHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}

	return Plugin_Continue;
}

public Action tTimerHeal(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || (g_esCache[iTank].g_iHealAbility != 2 && g_esCache[iTank].g_iHealAbility != 3) || !g_esPlayer[iTank].g_bActivated)
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	static int iTime, iCurrentTime;
	iTime = pack.ReadCell();
	iCurrentTime = GetTime();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (iTime + g_esCache[iTank].g_iHumanDuration) < iCurrentTime && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vReset2(iTank);
		vReset3(iTank);

		return Plugin_Stop;
	}

	static float flTankPos[3], flInfectedPos[3];
	static int iCommon, iCommonHealth, iExtraHealth, iExtraHealth2, iHealth, iHealType, iMaxHealth, iRealHealth, iSpecialHealth, iTankHealth;
	iCommon = -1;
	iHealType = 0;
	iMaxHealth = MT_TankMaxHealth(iTank, 1);

	while ((iCommon = FindEntityByClassname(iCommon, "infected")) != INVALID_ENT_REFERENCE)
	{
		GetClientAbsOrigin(iTank, flTankPos);
		GetEntPropVector(iCommon, Prop_Send, "m_vecOrigin", flInfectedPos);
		if (GetVectorDistance(flTankPos, flInfectedPos) <= g_esCache[iTank].g_flHealAbsorbRange)
		{
			iHealth = GetEntProp(iTank, Prop_Data, "m_iHealth");
			iCommonHealth = iHealth + g_esCache[iTank].g_iHealCommon;
			iExtraHealth = (iCommonHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iCommonHealth;
			iExtraHealth2 = (iCommonHealth < iHealth) ? 1 : iCommonHealth;
			iRealHealth = (iCommonHealth >= 0) ? iExtraHealth : iExtraHealth2;
			if (iHealth > 500)
			{
				MT_TankMaxHealth(iTank, 3, iMaxHealth + g_esCache[iTank].g_iHealCommon);
				SetEntProp(iTank, Prop_Data, "m_iHealth", iRealHealth);

				if (g_bSecondGame)
				{
					SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 185, 0));
					SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
					SetEntProp(iTank, Prop_Send, "m_nGlowRangeMin", MT_GetGlowRange(iTank, false));
					SetEntProp(iTank, Prop_Send, "m_nGlowRange", MT_GetGlowRange(iTank, true));
					SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
				}

				iHealType = 1;
			}
		}
	}

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);
			if (GetVectorDistance(flTankPos, flInfectedPos) <= g_esCache[iTank].g_flHealAbsorbRange)
			{
				iHealth = GetEntProp(iTank, Prop_Data, "m_iHealth");
				iSpecialHealth = iHealth + g_esCache[iTank].g_iHealSpecial;
				iExtraHealth = (iSpecialHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iSpecialHealth;
				iExtraHealth2 = (iSpecialHealth < iHealth) ? 1 : iSpecialHealth;
				iRealHealth = (iSpecialHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					MT_TankMaxHealth(iTank, 3, iMaxHealth + g_esCache[iTank].g_iHealSpecial);
					SetEntProp(iTank, Prop_Data, "m_iHealth", iRealHealth);

					if (iHealType < 2)
					{
						if (g_bSecondGame)
						{
							SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 220, 0));
							SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
							SetEntProp(iTank, Prop_Send, "m_nGlowRangeMin", MT_GetGlowRange(iTank, false));
							SetEntProp(iTank, Prop_Send, "m_nGlowRange", MT_GetGlowRange(iTank, true));
							SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
						}

						iHealType = 1;
					}
				}
			}
		}
		else if (MT_IsTankSupported(iInfected) && iInfected != iTank)
		{
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);
			if (GetVectorDistance(flTankPos, flInfectedPos) <= g_esCache[iTank].g_flHealAbsorbRange)
			{
				iHealth = GetEntProp(iTank, Prop_Data, "m_iHealth");
				iTankHealth = iHealth + g_esCache[iTank].g_iHealTank;
				iExtraHealth = (iTankHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iTankHealth;
				iExtraHealth2 = (iTankHealth < iHealth) ? 1 : iTankHealth;
				iRealHealth = (iTankHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					MT_TankMaxHealth(iTank, 3, iMaxHealth + g_esCache[iTank].g_iHealTank);
					SetEntProp(iTank, Prop_Data, "m_iHealth", iRealHealth);

					if (g_bSecondGame)
					{
						SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 255, 0));
						SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
						SetEntProp(iTank, Prop_Send, "m_nGlowRangeMin", MT_GetGlowRange(iTank, false));
						SetEntProp(iTank, Prop_Send, "m_nGlowRange", MT_GetGlowRange(iTank, true));
						SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
					}

					iHealType = 2;
				}
			}
		}
	}

	if (iHealType == 0 && g_bSecondGame)
	{
		vResetGlow(iTank);
	}

	return Plugin_Continue;
}