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

//#file "Warp Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Warp Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank warps to survivors and warps survivors to random teammates.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Warp Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_parent"

#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"

#define MT_CONFIG_SECTION "warpability"
#define MT_CONFIG_SECTION2 "warp ability"
#define MT_CONFIG_SECTION3 "warp_ability"
#define MT_CONFIG_SECTION4 "warp"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_WARP "Warp Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flWarpChance;
	float g_flWarpInterval;
	float g_flWarpRange;
	float g_flWarpRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iCount;
	int g_iCount2;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iWarpAbility;
	int g_iWarpEffect;
	int g_iWarpHit;
	int g_iWarpHitMode;
	int g_iWarpMessage;
	int g_iWarpMode;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flWarpChance;
	float g_flWarpInterval;
	float g_flWarpRange;
	float g_flWarpRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iWarpAbility;
	int g_iWarpEffect;
	int g_iWarpHit;
	int g_iWarpHitMode;
	int g_iWarpMessage;
	int g_iWarpMode;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flWarpChance;
	float g_flWarpInterval;
	float g_flWarpRange;
	float g_flWarpRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iWarpAbility;
	int g_iWarpEffect;
	int g_iWarpHit;
	int g_iWarpHitMode;
	int g_iWarpMessage;
	int g_iWarpMode;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_warp", cmdWarpInfo, "View information about the Warp ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveWarp(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveWarp(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdWarpInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vWarpMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vWarpMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iWarpMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Warp Ability Information");
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

public int iWarpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iWarpAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount2, g_esCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "WarpDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vWarpMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "WarpMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH];

			switch (param2)
			{
				case 0:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 7:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);

					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_WARP, MT_MENU_WARP);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_WARP, false))
	{
		vWarpMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_WARP, false))
	{
		FormatEx(buffer, size, "%T", "WarpMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iWarpHitMode == 0 || g_esCache[attacker].g_iWarpHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWarpHit(victim, attacker, g_esCache[attacker].g_flWarpChance, g_esCache[attacker].g_iWarpHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iWarpHitMode == 0 || g_esCache[victim].g_iWarpHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vWarpHit(attacker, victim, g_esCache[victim].g_flWarpChance, g_esCache[victim].g_iWarpHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iHumanDuration = 5;
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iOpenAreasOnly = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iWarpAbility = 0;
				g_esAbility[iIndex].g_iWarpEffect = 0;
				g_esAbility[iIndex].g_iWarpMessage = 0;
				g_esAbility[iIndex].g_flWarpChance = 33.3;
				g_esAbility[iIndex].g_iWarpHit = 0;
				g_esAbility[iIndex].g_iWarpHitMode = 0;
				g_esAbility[iIndex].g_flWarpInterval = 5.0;
				g_esAbility[iIndex].g_iWarpMode = 0;
				g_esAbility[iIndex].g_flWarpRange = 150.0;
				g_esAbility[iIndex].g_flWarpRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanDuration = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iWarpAbility = 0;
					g_esPlayer[iPlayer].g_iWarpEffect = 0;
					g_esPlayer[iPlayer].g_iWarpMessage = 0;
					g_esPlayer[iPlayer].g_flWarpChance = 0.0;
					g_esPlayer[iPlayer].g_iWarpHit = 0;
					g_esPlayer[iPlayer].g_iWarpHitMode = 0;
					g_esPlayer[iPlayer].g_flWarpInterval = 0.0;
					g_esPlayer[iPlayer].g_iWarpMode = 0;
					g_esPlayer[iPlayer].g_flWarpRange = 0.0;
					g_esPlayer[iPlayer].g_flWarpRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPlayer[admin].g_iHumanDuration, value, 1, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iWarpAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iWarpAbility, value, 0, 3);
		g_esPlayer[admin].g_iWarpEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iWarpEffect, value, 0, 7);
		g_esPlayer[admin].g_iWarpMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iWarpMessage, value, 0, 7);
		g_esPlayer[admin].g_flWarpChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpChance", "Warp Chance", "Warp_Chance", "chance", g_esPlayer[admin].g_flWarpChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iWarpHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpHit", "Warp Hit", "Warp_Hit", "hit", g_esPlayer[admin].g_iWarpHit, value, 0, 1);
		g_esPlayer[admin].g_iWarpHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpHitMode", "Warp Hit Mode", "Warp_Hit_Mode", "hitmode", g_esPlayer[admin].g_iWarpHitMode, value, 0, 2);
		g_esPlayer[admin].g_flWarpInterval = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpInterval", "Warp Interval", "Warp_Interval", "interval", g_esPlayer[admin].g_flWarpInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iWarpMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpMode", "Warp Mode", "Warp_Mode", "mode", g_esPlayer[admin].g_iWarpMode, value, 0, 3);
		g_esPlayer[admin].g_flWarpRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpRange", "Warp Range", "Warp_Range", "range", g_esPlayer[admin].g_flWarpRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flWarpRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpRangeChance", "Warp Range Chance", "Warp_Range_Chance", "rangechance", g_esPlayer[admin].g_flWarpRangeChance, value, 0.0, 100.0);

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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_iHumanDuration, value, 1, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iWarpAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iWarpAbility, value, 0, 3);
		g_esAbility[type].g_iWarpEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iWarpEffect, value, 0, 7);
		g_esAbility[type].g_iWarpMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iWarpMessage, value, 0, 7);
		g_esAbility[type].g_flWarpChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpChance", "Warp Chance", "Warp_Chance", "chance", g_esAbility[type].g_flWarpChance, value, 0.0, 100.0);
		g_esAbility[type].g_iWarpHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpHit", "Warp Hit", "Warp_Hit", "hit", g_esAbility[type].g_iWarpHit, value, 0, 1);
		g_esAbility[type].g_iWarpHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpHitMode", "Warp Hit Mode", "Warp_Hit_Mode", "hitmode", g_esAbility[type].g_iWarpHitMode, value, 0, 2);
		g_esAbility[type].g_flWarpInterval = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpInterval", "Warp Interval", "Warp_Interval", "interval", g_esAbility[type].g_flWarpInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_iWarpMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpMode", "Warp Mode", "Warp_Mode", "mode", g_esAbility[type].g_iWarpMode, value, 0, 3);
		g_esAbility[type].g_flWarpRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpRange", "Warp Range", "Warp_Range", "range", g_esAbility[type].g_flWarpRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flWarpRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WarpRangeChance", "Warp Range Chance", "Warp_Range_Chance", "rangechance", g_esAbility[type].g_flWarpRangeChance, value, 0.0, 100.0);

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
	g_esCache[tank].g_flWarpChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWarpChance, g_esAbility[type].g_flWarpChance);
	g_esCache[tank].g_flWarpInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWarpInterval, g_esAbility[type].g_flWarpInterval);
	g_esCache[tank].g_flWarpRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWarpRange, g_esAbility[type].g_flWarpRange);
	g_esCache[tank].g_flWarpRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWarpRangeChance, g_esAbility[type].g_flWarpRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanDuration, g_esAbility[type].g_iHumanDuration);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iWarpAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWarpAbility, g_esAbility[type].g_iWarpAbility);
	g_esCache[tank].g_iWarpEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWarpEffect, g_esAbility[type].g_iWarpEffect);
	g_esCache[tank].g_iWarpHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWarpHit, g_esAbility[type].g_iWarpHit);
	g_esCache[tank].g_iWarpHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWarpHitMode, g_esAbility[type].g_iWarpHitMode);
	g_esCache[tank].g_iWarpMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWarpMessage, g_esAbility[type].g_iWarpMessage);
	g_esCache[tank].g_iWarpMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWarpMode, g_esAbility[type].g_iWarpMode);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveWarp(oldTank);
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
			vRemoveWarp(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveWarp(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vWarpRange(iTank);
			vRemoveWarp(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start"))
	{
		vReset();
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iWarpAbility > 0)
	{
		vWarpAbility(tank, true);
		vWarpAbility(tank, false);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		static int iTime;
		iTime = GetTime();
		if (button & MT_MAIN_KEY)
		{
			if ((g_esCache[tank].g_iWarpAbility == 2 || g_esCache[tank].g_iWarpAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vWarpAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman4");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman5", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esPlayer[tank].g_bActivated = true;
								g_esPlayer[tank].g_iCount++;

								vWarp(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman4");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman5", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SUB_KEY)
		{
			if ((g_esCache[tank].g_iWarpAbility == 1 || g_esCache[tank].g_iWarpAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman6", g_esPlayer[tank].g_iCooldown2 - iTime);
					case false: vWarpAbility(tank, true);
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				vReset2(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveWarp(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	vWarpRange(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
	g_esPlayer[newTank].g_iCooldown2 = g_esPlayer[oldTank].g_iCooldown2;
	g_esPlayer[newTank].g_iCount = g_esPlayer[oldTank].g_iCount;
	g_esPlayer[newTank].g_iCount2 = g_esPlayer[oldTank].g_iCount2;
}

static void vRemoveWarp(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCooldown2 = -1;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCount2 = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveWarp(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;

	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman8", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static void vWarp(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	DataPack dpWarp;
	CreateDataTimer(g_esCache[tank].g_flWarpInterval, tTimerWarp, dpWarp, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpWarp.WriteCell(GetClientUserId(tank));
	dpWarp.WriteCell(g_esPlayer[tank].g_iTankType);
	dpWarp.WriteCell(GetTime());
}

static void vWarp2(int tank, int other)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static float flTankOrigin[3], flTankAngles[3];
	GetClientAbsOrigin(tank, flTankOrigin);
	GetClientAbsAngles(tank, flTankAngles);

	static float flOtherOrigin[3], flOtherAngles[3];
	GetClientAbsOrigin(other, flOtherOrigin);
	GetClientAbsAngles(other, flOtherAngles);

	vAttachParticle(tank, PARTICLE_ELECTRICITY, 1.0, 0.0);
	EmitSoundToAll(SOUND_ELECTRICITY, tank);
	TeleportEntity(tank, flOtherOrigin, flOtherAngles, NULL_VECTOR);

	if (g_esCache[tank].g_iWarpMode == 1 || g_esCache[tank].g_iWarpMode == 3)
	{
		vAttachParticle(other, PARTICLE_ELECTRICITY, 1.0, 0.0);
		EmitSoundToAll(SOUND_ELECTRICITY2, other);
		TeleportEntity(other, flTankOrigin, flTankAngles, NULL_VECTOR);
	}

	if (g_esCache[tank].g_iWarpMessage & MT_MESSAGE_SPECIAL)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Warp3", sTankName, other);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Warp3", LANG_SERVER, sTankName, other);
	}
}

static void vWarpAbility(int tank, bool main)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esCache[tank].g_iWarpAbility == 1 || g_esCache[tank].g_iWarpAbility == 3)
			{
				if (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
				{
					g_esPlayer[tank].g_bFailed = false;
					g_esPlayer[tank].g_bNoAmmo = false;

					static float flTankPos[3];
					GetClientAbsOrigin(tank, flTankPos);

					static float flSurvivorPos[3], flDistance;
					static int iSurvivorCount;
					iSurvivorCount = 0;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
						{
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);

							flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
							if (flDistance <= g_esCache[tank].g_flWarpRange)
							{
								vWarpHit(iSurvivor, tank, g_esCache[tank].g_flWarpRangeChance, g_esCache[tank].g_iWarpAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman7");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpAmmo");
				}
			}
		}
		case false:
		{
			if ((g_esCache[tank].g_iWarpAbility == 2 || g_esCache[tank].g_iWarpAbility == 3) && !g_esPlayer[tank].g_bActivated)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bActivated = true;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
					{
						g_esPlayer[tank].g_iCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
					}

					vWarp(tank);

					if (g_esCache[tank].g_iWarpMessage & MT_MESSAGE_SPECIAL)
					{
						static char sTankName[33];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Warp2", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Warp2", LANG_SERVER, sTankName);
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpAmmo");
				}
			}
		}
	}
}

static void vWarpHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				static char sTankName[33];
				static float flCurrentOrigin[3];
				for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
				{
					if (bIsSurvivor(iPlayer) && !bIsPlayerIncapacitated(iPlayer) && iPlayer != survivor)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
						{
							g_esPlayer[tank].g_iCount2++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman2", g_esPlayer[tank].g_iCount2, g_esCache[tank].g_iHumanAmmo);

							g_esPlayer[tank].g_iCooldown2 = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
							if (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman9", g_esPlayer[tank].g_iCooldown2 - iTime);
							}
						}

						GetClientAbsOrigin(iPlayer, flCurrentOrigin);
						TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

						if (g_esCache[tank].g_iWarpMessage & messages)
						{
							MT_GetTankName(tank, sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Warp", sTankName, survivor, iPlayer);
							MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Warp", LANG_SERVER, sTankName, survivor, iPlayer);
						}

						break;
					}
				}

				vEffect(survivor, tank, g_esCache[tank].g_iWarpEffect, flags);
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpAmmo2");
		}
	}
}

static void vWarpRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iWarpAbility == 1)
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		vAttachParticle(tank, PARTICLE_ELECTRICITY, 1.0, 0.0);
		EmitSoundToAll(SOUND_ELECTRICITY, tank);
	}
}

public Action tTimerWarp(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || (g_esCache[iTank].g_iWarpAbility != 2 && g_esCache[iTank].g_iWarpAbility != 3) || !g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	static int iTime, iCurrentTime;
	iTime = pack.ReadCell();
	iCurrentTime = GetTime();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (iTime + g_esCache[iTank].g_iHumanDuration) < iCurrentTime && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	switch (g_esCache[iTank].g_iWarpMode)
	{
		case 0, 1:
		{
			static int iSurvivor;
			iSurvivor = iGetRandomSurvivor(iTank);
			if (bIsSurvivor(iSurvivor))
			{
				vWarp2(iTank, iSurvivor);
			}
		}
		case 2, 3:
		{
			static int iTank2;
			iTank2 = iGetRandomTank(iTank);
			if (bIsTank(iTank2))
			{
				vWarp2(iTank, iTank2);
			}
		}
	}

	return Plugin_Continue;
}