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

#include <sourcemod>
#include <sdkhooks>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Kamikaze Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank kills itself along with a survivor victim.",
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
			strcopy(error, err_max, "\"[MT] Kamikaze Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_GROWL2 "player/tank/voice/growl/tank_climb_01.wav" // Only available in L4D2
#define SOUND_GROWL1 "player/tank/voice/growl/hulk_growl_1.wav" // Only available in L4D1
#define SOUND_SMASH2 "player/charger/hit/charger_smash_02.wav" // Only available in L4D2
#define SOUND_SMASH1 "player/tank/hit/hulk_punch_1.wav"

#define MT_CONFIG_SECTION "kamikazeability"
#define MT_CONFIG_SECTION2 "kamikaze ability"
#define MT_CONFIG_SECTION3 "kamikaze_ability"
#define MT_CONFIG_SECTION4 "kamikaze"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_KAMIKAZE "Kamikaze Ability"

enum struct esPlayer
{
	bool g_bFailed;
	bool g_bRewarded;

	float g_flKamikazeChance;
	float g_flKamikazeRange;
	float g_flKamikazeRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iKamikazeAbility;
	int g_iKamikazeBody;
	int g_iKamikazeEffect;
	int g_iKamikazeHit;
	int g_iKamikazeHitMode;
	int g_iKamikazeMessage;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flKamikazeChance;
	float g_flKamikazeRange;
	float g_flKamikazeRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iKamikazeAbility;
	int g_iKamikazeBody;
	int g_iKamikazeEffect;
	int g_iKamikazeHit;
	int g_iKamikazeHitMode;
	int g_iKamikazeMessage;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flKamikazeChance;
	float g_flKamikazeRange;
	float g_flKamikazeRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iKamikazeAbility;
	int g_iKamikazeBody;
	int g_iKamikazeEffect;
	int g_iKamikazeHit;
	int g_iKamikazeHitMode;
	int g_iKamikazeMessage;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_kamikaze", cmdKamikazeInfo, "View information about the Kamikaze ability.");

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
	iPrecacheParticle(PARTICLE_BLOOD);

	if (g_bSecondGame)
	{
		PrecacheSound(SOUND_GROWL2, true);
		PrecacheSound(SOUND_SMASH2, true);
	}
	else
	{
		PrecacheSound(SOUND_GROWL1, true);
		PrecacheSound(SOUND_SMASH1, true);
	}

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveKamikaze(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveKamikaze(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdKamikazeInfo(int client, int args)
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
		case false: vKamikazeMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vKamikazeMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iKamikazeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Kamikaze Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iKamikazeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iKamikazeAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "KamikazeDetails");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vKamikazeMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pKamikaze = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "KamikazeMenu", param1);
			pKamikaze.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					case 2: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_KAMIKAZE, MT_MENU_KAMIKAZE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_KAMIKAZE, false))
	{
		vKamikazeMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_KAMIKAZE, false))
	{
		FormatEx(buffer, size, "%T", "KamikazeMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsValidEntity(inflictor) && damage > 0.0)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iKamikazeHitMode == 0 || g_esCache[attacker].g_iKamikazeHitMode == 1) && bIsSurvivor(victim) && g_esCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vKamikazeHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esCache[attacker].g_flKamikazeChance, g_esCache[attacker].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iKamikazeHitMode == 0 || g_esCache[victim].g_iKamikazeHitMode == 2) && bIsSurvivor(attacker) && g_esCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vKamikazeHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esCache[victim].g_flKamikazeChance, g_esCache[victim].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
						if (g_esCache[tank].g_iKamikazeAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vKamikazeAbility(tank, random, iPos);
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
					}
					case MT_COMBO_MELEEHIT:
					{
						static float flChance;
						flChance = MT_GetCombinationSetting(tank, 1, iPos);

						switch (flDelay)
						{
							case 0.0:
							{
								if ((g_esCache[tank].g_iKamikazeHitMode == 0 || g_esCache[tank].g_iKamikazeHitMode == 1) && (StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vKamikazeHit(survivor, tank, random, flChance, g_esCache[tank].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esCache[tank].g_iKamikazeHitMode == 0 || g_esCache[tank].g_iKamikazeHitMode == 2) && StrEqual(classname, "weapon_melee"))
								{
									vKamikazeHit(survivor, tank, random, flChance, g_esCache[tank].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
				g_esAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iKamikazeAbility = 0;
				g_esAbility[iIndex].g_iKamikazeBody = 1;
				g_esAbility[iIndex].g_iKamikazeEffect = 0;
				g_esAbility[iIndex].g_iKamikazeMessage = 0;
				g_esAbility[iIndex].g_flKamikazeChance = 33.3;
				g_esAbility[iIndex].g_iKamikazeHit = 0;
				g_esAbility[iIndex].g_iKamikazeHitMode = 0;
				g_esAbility[iIndex].g_flKamikazeRange = 150.0;
				g_esAbility[iIndex].g_flKamikazeRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iKamikazeAbility = 0;
					g_esPlayer[iPlayer].g_iKamikazeBody = 0;
					g_esPlayer[iPlayer].g_iKamikazeEffect = 0;
					g_esPlayer[iPlayer].g_iKamikazeMessage = 0;
					g_esPlayer[iPlayer].g_flKamikazeChance = 0.0;
					g_esPlayer[iPlayer].g_iKamikazeHit = 0;
					g_esPlayer[iPlayer].g_iKamikazeHitMode = 0;
					g_esPlayer[iPlayer].g_flKamikazeRange = 0.0;
					g_esPlayer[iPlayer].g_flKamikazeRangeChance = 0.0;
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
		g_esPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iKamikazeAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iKamikazeAbility, value, 0, 1);
		g_esPlayer[admin].g_iKamikazeEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iKamikazeEffect, value, 0, 7);
		g_esPlayer[admin].g_iKamikazeMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iKamikazeMessage, value, 0, 3);
		g_esPlayer[admin].g_iKamikazeBody = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeBody", "Kamikaze Body", "Kamikaze_Body", "body", g_esPlayer[admin].g_iKamikazeBody, value, 0, 1);
		g_esPlayer[admin].g_flKamikazeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeChance", "Kamikaze Chance", "Kamikaze_Chance", "chance", g_esPlayer[admin].g_flKamikazeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iKamikazeHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeHit", "Kamikaze Hit", "Kamikaze_Hit", "hit", g_esPlayer[admin].g_iKamikazeHit, value, 0, 1);
		g_esPlayer[admin].g_iKamikazeHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeHitMode", "Kamikaze Hit Mode", "Kamikaze_Hit_Mode", "hitmode", g_esPlayer[admin].g_iKamikazeHitMode, value, 0, 2);
		g_esPlayer[admin].g_flKamikazeRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeRange", "Kamikaze Range", "Kamikaze_Range", "range", g_esPlayer[admin].g_flKamikazeRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flKamikazeRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeRangeChance", "Kamikaze Range Chance", "Kamikaze_Range_Chance", "rangechance", g_esPlayer[admin].g_flKamikazeRangeChance, value, 0.0, 100.0);

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
		g_esAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iKamikazeAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iKamikazeAbility, value, 0, 1);
		g_esAbility[type].g_iKamikazeEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iKamikazeEffect, value, 0, 7);
		g_esAbility[type].g_iKamikazeMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iKamikazeMessage, value, 0, 3);
		g_esAbility[type].g_iKamikazeBody = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeBody", "Kamikaze Body", "Kamikaze_Body", "body", g_esAbility[type].g_iKamikazeBody, value, 0, 1);
		g_esAbility[type].g_flKamikazeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeChance", "Kamikaze Chance", "Kamikaze_Chance", "chance", g_esAbility[type].g_flKamikazeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iKamikazeHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeHit", "Kamikaze Hit", "Kamikaze_Hit", "hit", g_esAbility[type].g_iKamikazeHit, value, 0, 1);
		g_esAbility[type].g_iKamikazeHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeHitMode", "Kamikaze Hit Mode", "Kamikaze_Hit_Mode", "hitmode", g_esAbility[type].g_iKamikazeHitMode, value, 0, 2);
		g_esAbility[type].g_flKamikazeRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeRange", "Kamikaze Range", "Kamikaze_Range", "range", g_esAbility[type].g_flKamikazeRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flKamikazeRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "KamikazeRangeChance", "Kamikaze Range Chance", "Kamikaze_Range_Chance", "rangechance", g_esAbility[type].g_flKamikazeRangeChance, value, 0.0, 100.0);

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
	bool bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flKamikazeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flKamikazeChance, g_esAbility[type].g_flKamikazeChance);
	g_esCache[tank].g_flKamikazeRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flKamikazeRange, g_esAbility[type].g_flKamikazeRange);
	g_esCache[tank].g_flKamikazeRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flKamikazeRangeChance, g_esAbility[type].g_flKamikazeRangeChance);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iKamikazeAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iKamikazeAbility, g_esAbility[type].g_iKamikazeAbility);
	g_esCache[tank].g_iKamikazeEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iKamikazeEffect, g_esAbility[type].g_iKamikazeEffect);
	g_esCache[tank].g_iKamikazeBody = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iKamikazeBody, g_esAbility[type].g_iKamikazeBody);
	g_esCache[tank].g_iKamikazeHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iKamikazeHit, g_esAbility[type].g_iKamikazeHit);
	g_esCache[tank].g_iKamikazeHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iKamikazeHitMode, g_esAbility[type].g_iKamikazeHitMode);
	g_esCache[tank].g_iKamikazeMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iKamikazeMessage, g_esAbility[type].g_iKamikazeMessage);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{

	if (oldTank != newTank)
	{
		vRemoveKamikaze(oldTank);
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
			vRemoveKamikaze(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vRemoveKamikaze(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
		if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveKamikaze(iPlayer);
		}
		else if (bIsSurvivor(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_bSecondGame)
		{
			int iBody = -1;
			while ((iBody = FindEntityByClassname(iBody, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				float flSurvivorPos[3], flBodyPos[3];
				GetClientAbsOrigin(iPlayer, flSurvivorPos);
				GetEntPropVector(iBody, Prop_Send, "m_vecOrigin", flBodyPos);
				if (GetEntProp(iBody, Prop_Send, "m_nCharacterType") == GetEntProp(iPlayer, Prop_Send, "m_survivorCharacter") && GetVectorDistance(flSurvivorPos, flBodyPos) == 0.0)
				{
					SetEntPropEnt(iBody, Prop_Send, "m_hOwnerEntity", iPlayer);
				}
			}
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vReset();
	}
}

public Action MT_OnRewardSurvivor(int survivor, int tank, int &type, int priority, float &duration, bool apply)
{
	if (bIsSurvivor(survivor) && (type & MT_REWARD_GODMODE))
	{
		g_esPlayer[survivor].g_bRewarded = apply;
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iKamikazeAbility == 1 && g_esCache[tank].g_iComboAbility == 0)
	{
		vKamikazeAbility(tank, GetRandomFloat(0.1, 100.0));
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

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iKamikazeAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				vKamikazeAbility(tank, GetRandomFloat(0.1, 100.0));
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveKamikaze(tank);
}

static void vKamikazeAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	g_esPlayer[tank].g_bFailed = false;

	static float flTankPos[3], flSurvivorPos[3], flRange, flChance;
	GetClientAbsOrigin(tank, flTankPos);
	flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esCache[tank].g_flKamikazeRange;
	flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esCache[tank].g_flKamikazeRangeChance;
	static int iSurvivorCount;
	iSurvivorCount = 0;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
		{
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);
			if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange)
			{
				vKamikazeHit(iSurvivor, tank, random, flChance, g_esCache[tank].g_iKamikazeAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

				iSurvivorCount++;
			}
		}
	}

	if (iSurvivorCount == 0)
	{
		if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "KamikazeHuman3");
		}
	}
}

static void vKamikazeHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !g_esPlayer[survivor].g_bRewarded)
	{
		if (random <= chance)
		{
			if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE))
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "KamikazeHuman");
			}

			vAttachParticle(survivor, PARTICLE_BLOOD, 0.1);
			vAttachParticle(tank, PARTICLE_BLOOD, 0.1);
			ForcePlayerSuicide(survivor);
			ForcePlayerSuicide(tank);
			vEffect(survivor, tank, g_esCache[tank].g_iKamikazeEffect, flags);
			EmitSoundToAll((g_bSecondGame) ? SOUND_SMASH2 : SOUND_SMASH1, survivor);
			EmitSoundToAll((g_bSecondGame) ? SOUND_GROWL2 : SOUND_GROWL1, survivor);

			if (g_esCache[tank].g_iKamikazeBody == 1)
			{
				RequestFrame(vRemoveKamikazeBody, GetClientUserId(survivor));
			}

			if (g_esCache[tank].g_iKamikazeMessage & messages)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Kamikaze", sTankName, survivor);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Kamikaze", LANG_SERVER, sTankName, survivor);
			}
		}
		else if ((flags & MT_ATTACK_RANGE))
		{
			if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
			{
				g_esPlayer[tank].g_bFailed = true;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "KamikazeHuman2");
			}
		}
	}
}

static void vRemoveKamikaze(int tank)
{
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bRewarded = false;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveKamikaze(iPlayer);
		}
	}
}

public void vRemoveKamikazeBody(int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (!bIsSurvivor(iSurvivor, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return;
	}

	int iBody = -1;
	while ((iBody = FindEntityByClassname(iBody, "survivor_death_model")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iBody, Prop_Send, "m_hOwnerEntity");
		if (iSurvivor == iOwner)
		{
			RemoveEntity(iBody);
		}
	}
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iKamikazeAbility == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vKamikazeAbility(iTank, flRandom, iPos);

	return Plugin_Continue;
}

public Action tTimerCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iKamikazeHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof(sClassname));
	if ((g_esCache[iTank].g_iKamikazeHitMode == 0 || g_esCache[iTank].g_iKamikazeHitMode == 1) && (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vKamikazeHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esCache[iTank].g_iKamikazeHitMode == 0 || g_esCache[iTank].g_iKamikazeHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
	{
		vKamikazeHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}

	return Plugin_Continue;
}