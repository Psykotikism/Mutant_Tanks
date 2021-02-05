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
	name = "[MT] Rocket Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank sends survivors into space.",
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
			strcopy(error, err_max, "\"[MT] Rocket Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"
#define SOUND_FIRE "weapons/molotov/fire_ignite_1.wav"
#define SOUND_LAUNCH "player/boomer/explode/explo_medium_14.wav"

#define MT_CONFIG_SECTION "rocketability"
#define MT_CONFIG_SECTION2 "rocket ability"
#define MT_CONFIG_SECTION3 "rocket_ability"
#define MT_CONFIG_SECTION4 "rocket"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_ROCKET "Rocket Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;
	bool g_bRewarded;

	float g_flOpenAreasOnly;
	float g_flRocketChance;
	float g_flRocketDelay;
	float g_flRocketRange;
	float g_flRocketRangeChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iRequiresHumans;
	int g_iRocketAbility;
	int g_iRocketBody;
	int g_iRocketEffect;
	int g_iRocketHit;
	int g_iRocketHitMode;
	int g_iRocketMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flOpenAreasOnly;
	float g_flRocketChance;
	float g_flRocketDelay;
	float g_flRocketRange;
	float g_flRocketRangeChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iRocketAbility;
	int g_iRocketBody;
	int g_iRocketEffect;
	int g_iRocketHit;
	int g_iRocketHitMode;
	int g_iRocketMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flOpenAreasOnly;
	float g_flRocketChance;
	float g_flRocketDelay;
	float g_flRocketRange;
	float g_flRocketRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iRocketAbility;
	int g_iRocketBody;
	int g_iRocketEffect;
	int g_iRocketHit;
	int g_iRocketHitMode;
	int g_iRocketMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

int g_iRocketSprite = -1;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_rocket", cmdRocketInfo, "View information about the Rocket ability.");

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
	g_iRocketSprite = PrecacheModel("sprites/sprite_fire01.vmt", true);

	PrecacheSound(SOUND_EXPLOSION, true);
	PrecacheSound(SOUND_FIRE, true);
	PrecacheSound(SOUND_LAUNCH, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset3(client);
}

public void OnClientDisconnect_Post(int client)
{
	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRocketInfo(int client, int args)
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
		case false: vRocketMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRocketMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRocketMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Rocket Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRocketMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iRocketAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RocketDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vRocketMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pRocket = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "RocketMenu", param1);
			pRocket.SetTitle(sMenuTitle);
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
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 5: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_ROCKET, MT_MENU_ROCKET);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ROCKET, false))
	{
		vRocketMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_ROCKET, false))
	{
		FormatEx(buffer, size, "%T", "RocketMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsValidEntity(inflictor) && damage > 0.0)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iRocketHitMode == 0 || g_esCache[attacker].g_iRocketHitMode == 1) && bIsSurvivor(victim) && g_esCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRocketHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esCache[attacker].g_flRocketChance, g_esCache[attacker].g_iRocketHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iRocketHitMode == 0 || g_esCache[victim].g_iRocketHitMode == 2) && bIsSurvivor(attacker) && g_esCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRocketHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esCache[victim].g_flRocketChance, g_esCache[victim].g_iRocketHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
						if (g_esCache[tank].g_iRocketAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vRocketAbility(tank, random);
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
								if ((g_esCache[tank].g_iRocketHitMode == 0 || g_esCache[tank].g_iRocketHitMode == 1) && (StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vRocketHit(survivor, tank, random, flChance, g_esCache[tank].g_iRocketHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esCache[tank].g_iRocketHitMode == 0 || g_esCache[tank].g_iRocketHitMode == 2) && StrEqual(classname, "weapon_melee"))
								{
									vRocketHit(survivor, tank, random, flChance, g_esCache[tank].g_iRocketHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iRocketAbility = 0;
				g_esAbility[iIndex].g_iRocketBody = 1;
				g_esAbility[iIndex].g_iRocketEffect = 0;
				g_esAbility[iIndex].g_iRocketMessage = 0;
				g_esAbility[iIndex].g_flRocketChance = 33.3;
				g_esAbility[iIndex].g_flRocketDelay = 1.0;
				g_esAbility[iIndex].g_iRocketHit = 0;
				g_esAbility[iIndex].g_iRocketHitMode = 0;
				g_esAbility[iIndex].g_flRocketRange = 150.0;
				g_esAbility[iIndex].g_flRocketRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iRocketAbility = 0;
					g_esPlayer[iPlayer].g_iRocketBody = 0;
					g_esPlayer[iPlayer].g_iRocketEffect = 0;
					g_esPlayer[iPlayer].g_iRocketMessage = 0;
					g_esPlayer[iPlayer].g_flRocketChance = 0.0;
					g_esPlayer[iPlayer].g_flRocketDelay = 0.0;
					g_esPlayer[iPlayer].g_iRocketHit = 0;
					g_esPlayer[iPlayer].g_iRocketHitMode = 0;
					g_esPlayer[iPlayer].g_flRocketRange = 0.0;
					g_esPlayer[iPlayer].g_flRocketRangeChance = 0.0;
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
		g_esPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iRocketAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iRocketAbility, value, 0, 1);
		g_esPlayer[admin].g_iRocketEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iRocketEffect, value, 0, 7);
		g_esPlayer[admin].g_iRocketMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iRocketMessage, value, 0, 3);
		g_esPlayer[admin].g_iRocketBody = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketBody", "Rocket Body", "Rocket_Body", "body", g_esPlayer[admin].g_iRocketBody, value, 0, 1);
		g_esPlayer[admin].g_flRocketChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketChance", "Rocket Chance", "Rocket_Chance", "chance", g_esPlayer[admin].g_flRocketChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flRocketDelay = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketDelay", "Rocket Delay", "Rocket_Delay", "delay", g_esPlayer[admin].g_flRocketDelay, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iRocketHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketHit", "Rocket Hit", "Rocket_Hit", "hit", g_esPlayer[admin].g_iRocketHit, value, 0, 1);
		g_esPlayer[admin].g_iRocketHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketHitMode", "Rocket Hit Mode", "Rocket_Hit_Mode", "hitmode", g_esPlayer[admin].g_iRocketHitMode, value, 0, 2);
		g_esPlayer[admin].g_flRocketRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketRange", "Rocket Range", "Rocket_Range", "range", g_esPlayer[admin].g_flRocketRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flRocketRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketRangeChance", "Rocket Range Chance", "Rocket_Range_Chance", "rangechance", g_esPlayer[admin].g_flRocketRangeChance, value, 0.0, 100.0);

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
		g_esAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iRocketAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iRocketAbility, value, 0, 1);
		g_esAbility[type].g_iRocketEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iRocketEffect, value, 0, 7);
		g_esAbility[type].g_iRocketMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iRocketMessage, value, 0, 3);
		g_esAbility[type].g_iRocketBody = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketBody", "Rocket Body", "Rocket_Body", "body", g_esAbility[type].g_iRocketBody, value, 0, 1);
		g_esAbility[type].g_flRocketChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketChance", "Rocket Chance", "Rocket_Chance", "chance", g_esAbility[type].g_flRocketChance, value, 0.0, 100.0);
		g_esAbility[type].g_flRocketDelay = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketDelay", "Rocket Delay", "Rocket_Delay", "delay", g_esAbility[type].g_flRocketDelay, value, 0.1, 999999.0);
		g_esAbility[type].g_iRocketHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketHit", "Rocket Hit", "Rocket_Hit", "hit", g_esAbility[type].g_iRocketHit, value, 0, 1);
		g_esAbility[type].g_iRocketHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketHitMode", "Rocket Hit Mode", "Rocket_Hit_Mode", "hitmode", g_esAbility[type].g_iRocketHitMode, value, 0, 2);
		g_esAbility[type].g_flRocketRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketRange", "Rocket Range", "Rocket_Range", "range", g_esAbility[type].g_flRocketRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flRocketRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RocketRangeChance", "Rocket Range Chance", "Rocket_Range_Chance", "rangechance", g_esAbility[type].g_flRocketRangeChance, value, 0.0, 100.0);

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
	g_esCache[tank].g_flRocketChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRocketChance, g_esAbility[type].g_flRocketChance);
	g_esCache[tank].g_flRocketDelay = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRocketDelay, g_esAbility[type].g_flRocketDelay);
	g_esCache[tank].g_flRocketRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRocketRange, g_esAbility[type].g_flRocketRange);
	g_esCache[tank].g_flRocketRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRocketRangeChance, g_esAbility[type].g_flRocketRangeChance);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iRocketAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketAbility, g_esAbility[type].g_iRocketAbility);
	g_esCache[tank].g_iRocketBody = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketBody, g_esAbility[type].g_iRocketBody);
	g_esCache[tank].g_iRocketEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketEffect, g_esAbility[type].g_iRocketEffect);
	g_esCache[tank].g_iRocketHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketHit, g_esAbility[type].g_iRocketHit);
	g_esCache[tank].g_iRocketHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketHitMode, g_esAbility[type].g_iRocketHitMode);
	g_esCache[tank].g_iRocketMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketMessage, g_esAbility[type].g_iRocketMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveRocket(oldTank);
	}
}

public void MT_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iSurvivor].g_bAffected)
		{
			SetEntityGravity(iSurvivor, 1.0);
		}
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
			vRemoveRocket(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveRocket(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
		if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveRocket(iPlayer);
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

public void MT_OnRewardSurvivor(int survivor, int tank, int type, int priority, float duration, bool apply)
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

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iRocketAbility == 1 && g_esCache[tank].g_iComboAbility == 0)
	{
		vRocketAbility(tank, GetRandomFloat(0.1, 100.0));
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
			if (g_esCache[tank].g_iRocketAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vRocketAbility(tank, GetRandomFloat(0.1, 100.0));
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveRocket(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vRemoveRocket(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vReset3(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

static void vReset2(int survivor)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	SetEntityGravity(survivor, 1.0);
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_bRewarded = false;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vRocketAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		g_esPlayer[tank].g_bFailed = false;
		g_esPlayer[tank].g_bNoAmmo = false;

		static float flTankPos[3], flSurvivorPos[3], flRange, flChance;
		GetClientAbsOrigin(tank, flTankPos);
		flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esCache[tank].g_flRocketRange;
		flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esCache[tank].g_flRocketRangeChance;
		static int iSurvivorCount;
		iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange)
				{
					vRocketHit(iSurvivor, tank, random, flChance, g_esCache[tank].g_iRocketAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman4");
			}
		}
	}
	else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketAmmo");
	}
}

static void vRocketHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !g_esPlayer[survivor].g_bRewarded)
	{
		if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (random <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				static int iFlame;
				iFlame = CreateEntityByName("env_steam");
				if (bIsValidEntity(iFlame))
				{
					g_esPlayer[survivor].g_bAffected = true;
					g_esPlayer[survivor].g_iOwner = tank;

					if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
					{
						g_esPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);

						g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
						if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman5", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}

					static float flPosition[3], flAngles[3];
					GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flPosition);
					flPosition[2] += 30.0;
					flAngles[0] = 90.0;
					flAngles[1] = 0.0;
					flAngles[2] = 0.0;

					DispatchKeyValue(iFlame, "spawnflags", "1");
					DispatchKeyValue(iFlame, "Type", "0");
					DispatchKeyValue(iFlame, "InitialState", "1");
					DispatchKeyValue(iFlame, "Spreadspeed", "10");
					DispatchKeyValue(iFlame, "Speed", "800");
					DispatchKeyValue(iFlame, "Startsize", "10");
					DispatchKeyValue(iFlame, "EndSize", "250");
					DispatchKeyValue(iFlame, "Rate", "15");
					DispatchKeyValue(iFlame, "JetLength", "400");

					SetEntityRenderColor(iFlame, 180, 70, 10, 180);

					TeleportEntity(iFlame, flPosition, flAngles, NULL_VECTOR);
					DispatchSpawn(iFlame);
					vSetEntityParent(iFlame, survivor);

					iFlame = EntIndexToEntRef(iFlame);
					vDeleteEntity(iFlame, 3.0);

					EmitSoundToAll(SOUND_FIRE, survivor, _, _, _, 1.0);

					static float flDelay;
					flDelay = (pos != -1) ? 0.1 : g_esCache[tank].g_flRocketDelay;

					DataPack dpRocketLaunch;
					CreateDataTimer(flDelay, tTimerRocketLaunch, dpRocketLaunch, TIMER_FLAG_NO_MAPCHANGE);
					dpRocketLaunch.WriteCell(GetClientUserId(survivor));
					dpRocketLaunch.WriteCell(GetClientUserId(tank));
					dpRocketLaunch.WriteCell(g_esPlayer[tank].g_iTankType);
					dpRocketLaunch.WriteCell(enabled);

					DataPack dpRocketDetonate;
					CreateDataTimer(flDelay + 1.5, tTimerRocketDetonate, dpRocketDetonate, TIMER_FLAG_NO_MAPCHANGE);
					dpRocketDetonate.WriteCell(GetClientUserId(survivor));
					dpRocketDetonate.WriteCell(GetClientUserId(tank));
					dpRocketDetonate.WriteCell(g_esPlayer[tank].g_iTankType);
					dpRocketDetonate.WriteCell(enabled);
					dpRocketDetonate.WriteCell(messages);

					vEffect(survivor, tank, g_esCache[tank].g_iRocketEffect, flags);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman2");
				}
			}
		}
		else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketAmmo");
		}
	}
}

public void vRemoveRocketBody(int userid)
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
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iRocketAbility == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vRocketAbility(iTank, flRandom, iPos);

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
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iRocketHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof(sClassname));
	if ((g_esCache[iTank].g_iRocketHitMode == 0 || g_esCache[iTank].g_iRocketHitMode == 1) && (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vRocketHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iRocketHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esCache[iTank].g_iRocketHitMode == 0 || g_esCache[iTank].g_iRocketHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
	{
		vRocketHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iRocketHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}

	return Plugin_Continue;
}

public Action tTimerRocketLaunch(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_bRewarded)
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	static int iTank, iType, iRocketEnabled;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iRocketEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || iRocketEnabled == 0 || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor);

		return Plugin_Stop;
	}

	static float flVelocity[3];
	flVelocity[0] = 0.0;
	flVelocity[1] = 0.0;
	flVelocity[2] = 800.0;

	EmitSoundToAll(SOUND_EXPLOSION, iSurvivor, _, _, _, 1.0);
	EmitSoundToAll(SOUND_LAUNCH, iSurvivor, _, _, _, 1.0);

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityGravity(iSurvivor, 0.1);

	return Plugin_Continue;
}

public Action tTimerRocketDetonate(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_bRewarded)
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	static int iTank, iType, iRocketEnabled;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iRocketEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || iRocketEnabled == 0 || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor);

		return Plugin_Stop;
	}

	static float flPosition[3];
	GetClientAbsOrigin(iSurvivor, flPosition);

	TE_SetupExplosion(flPosition, g_iRocketSprite, 10.0, 1, 0, 600, 5000);
	TE_SendToAll();

	SetEntityGravity(iSurvivor, 1.0);
	ForcePlayerSuicide(iSurvivor);

	if (g_esCache[iTank].g_iRocketBody == 1)
	{
		RequestFrame(vRemoveRocketBody, GetClientUserId(iSurvivor));
	}

	g_esPlayer[iSurvivor].g_bAffected = false;
	g_esPlayer[iSurvivor].g_iOwner = 0;

	static int iMessage;
	iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iRocketMessage & iMessage)
	{
		static char sTankName[33];
		MT_GetTankName(iTank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Rocket", sTankName, iSurvivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Rocket", LANG_SERVER, sTankName, iSurvivor);
	}

	return Plugin_Continue;
}
