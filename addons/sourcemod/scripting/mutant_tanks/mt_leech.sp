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

//#file "Leech Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Leech Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank leeches health off of survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Leech Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_LEECH "Leech Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flLeechChance;
	float g_flLeechInterval;
	float g_flLeechRange;
	float g_flLeechRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iLeechAbility;
	int g_iLeechDuration;
	int g_iLeechEffect;
	int g_iLeechHit;
	int g_iLeechHitMode;
	int g_iLeechMessage;
	int g_iOpenAreasOnly;
	int g_iOwner;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flLeechChance;
	float g_flLeechInterval;
	float g_flLeechRange;
	float g_flLeechRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iLeechAbility;
	int g_iLeechDuration;
	int g_iLeechEffect;
	int g_iLeechHit;
	int g_iLeechHitMode;
	int g_iLeechMessage;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flLeechChance;
	float g_flLeechInterval;
	float g_flLeechRange;
	float g_flLeechRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iLeechAbility;
	int g_iLeechDuration;
	int g_iLeechEffect;
	int g_iLeechHit;
	int g_iLeechHitMode;
	int g_iLeechMessage;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_leech", cmdLeechInfo, "View information about the Leech ability.");

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

public Action cmdLeechInfo(int client, int args)
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
		case false: vLeechMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vLeechMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iLeechMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Leech Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iLeechMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iLeechAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "LeechDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iLeechDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vLeechMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "LeechMenu", param1);
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
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 6:
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
	menu.AddItem(MT_MENU_LEECH, MT_MENU_LEECH);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_LEECH, false))
	{
		vLeechMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_LEECH, false))
	{
		FormatEx(buffer, size, "%T", "LeechMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iLeechHitMode == 0 || g_esCache[attacker].g_iLeechHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vLeechHit(victim, attacker, g_esCache[attacker].g_flLeechChance, g_esCache[attacker].g_iLeechHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iLeechHitMode == 0 || g_esCache[victim].g_iLeechHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vLeechHit(attacker, victim, g_esCache[victim].g_flLeechChance, g_esCache[victim].g_iLeechHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("leechability");
	list2.PushString("leech ability");
	list3.PushString("leech_ability");
	list4.PushString("leech");
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
				g_esAbility[iIndex].g_iOpenAreasOnly = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iLeechAbility = 0;
				g_esAbility[iIndex].g_iLeechEffect = 0;
				g_esAbility[iIndex].g_iLeechMessage = 0;
				g_esAbility[iIndex].g_flLeechChance = 33.3;
				g_esAbility[iIndex].g_iLeechDuration = 5;
				g_esAbility[iIndex].g_iLeechHit = 0;
				g_esAbility[iIndex].g_iLeechHitMode = 0;
				g_esAbility[iIndex].g_flLeechInterval = 1.0;
				g_esAbility[iIndex].g_flLeechRange = 150.0;
				g_esAbility[iIndex].g_flLeechRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iLeechAbility = 0;
					g_esPlayer[iPlayer].g_iLeechEffect = 0;
					g_esPlayer[iPlayer].g_iLeechMessage = 0;
					g_esPlayer[iPlayer].g_flLeechChance = 0.0;
					g_esPlayer[iPlayer].g_iLeechDuration = 0;
					g_esPlayer[iPlayer].g_iLeechHit = 0;
					g_esPlayer[iPlayer].g_iLeechHitMode = 0;
					g_esPlayer[iPlayer].g_flLeechInterval = 0.0;
					g_esPlayer[iPlayer].g_flLeechRange = 0.0;
					g_esPlayer[iPlayer].g_flLeechRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iLeechAbility = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iLeechAbility, value, 0, 1);
		g_esPlayer[admin].g_iLeechEffect = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iLeechEffect, value, 0, 7);
		g_esPlayer[admin].g_iLeechMessage = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iLeechMessage, value, 0, 3);
		g_esPlayer[admin].g_flLeechChance = flGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechChance", "Leech Chance", "Leech_Chance", "chance", g_esPlayer[admin].g_flLeechChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iLeechDuration = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechDuration", "Leech Duration", "Leech_Duration", "duration", g_esPlayer[admin].g_iLeechDuration, value, 1, 999999);
		g_esPlayer[admin].g_iLeechHit = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechHit", "Leech Hit", "Leech_Hit", "hit", g_esPlayer[admin].g_iLeechHit, value, 0, 1);
		g_esPlayer[admin].g_iLeechHitMode = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechHitMode", "Leech Hit Mode", "Leech_Hit_Mode", "hitmode", g_esPlayer[admin].g_iLeechHitMode, value, 0, 2);
		g_esPlayer[admin].g_flLeechInterval = flGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechInterval", "Leech Interval", "Leech_Interval", "interval", g_esPlayer[admin].g_flLeechInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flLeechRange = flGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechRange", "Leech Range", "Leech_Range", "range", g_esPlayer[admin].g_flLeechRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flLeechRangeChance = flGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechRangeChance", "Leech Range Chance", "Leech_Range_Chance", "rangechance", g_esPlayer[admin].g_flLeechRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "leechability", false) || StrEqual(subsection, "leech ability", false) || StrEqual(subsection, "leech_ability", false) || StrEqual(subsection, "leech", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iLeechAbility = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iLeechAbility, value, 0, 1);
		g_esAbility[type].g_iLeechEffect = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iLeechEffect, value, 0, 7);
		g_esAbility[type].g_iLeechMessage = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iLeechMessage, value, 0, 3);
		g_esAbility[type].g_flLeechChance = flGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechChance", "Leech Chance", "Leech_Chance", "chance", g_esAbility[type].g_flLeechChance, value, 0.0, 100.0);
		g_esAbility[type].g_iLeechDuration = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechDuration", "Leech Duration", "Leech_Duration", "duration", g_esAbility[type].g_iLeechDuration, value, 1, 999999);
		g_esAbility[type].g_iLeechHit = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechHit", "Leech Hit", "Leech_Hit", "hit", g_esAbility[type].g_iLeechHit, value, 0, 1);
		g_esAbility[type].g_iLeechHitMode = iGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechHitMode", "Leech Hit Mode", "Leech_Hit_Mode", "hitmode", g_esAbility[type].g_iLeechHitMode, value, 0, 2);
		g_esAbility[type].g_flLeechInterval = flGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechInterval", "Leech Interval", "Leech_Interval", "interval", g_esAbility[type].g_flLeechInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flLeechRange = flGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechRange", "Leech Range", "Leech_Range", "range", g_esAbility[type].g_flLeechRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flLeechRangeChance = flGetKeyValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechRangeChance", "Leech Range Chance", "Leech_Range_Chance", "rangechance", g_esAbility[type].g_flLeechRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "leechability", false) || StrEqual(subsection, "leech ability", false) || StrEqual(subsection, "leech_ability", false) || StrEqual(subsection, "leech", false))
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
	g_esCache[tank].g_flLeechChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLeechChance, g_esAbility[type].g_flLeechChance);
	g_esCache[tank].g_flLeechInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLeechInterval, g_esAbility[type].g_flLeechInterval);
	g_esCache[tank].g_flLeechRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLeechRange, g_esAbility[type].g_flLeechRange);
	g_esCache[tank].g_flLeechRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLeechRangeChance, g_esAbility[type].g_flLeechRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iLeechAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLeechAbility, g_esAbility[type].g_iLeechAbility);
	g_esCache[tank].g_iLeechDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLeechDuration, g_esAbility[type].g_iLeechDuration);
	g_esCache[tank].g_iLeechEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLeechEffect, g_esAbility[type].g_iLeechEffect);
	g_esCache[tank].g_iLeechHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLeechHit, g_esAbility[type].g_iLeechHit);
	g_esCache[tank].g_iLeechHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLeechHitMode, g_esAbility[type].g_iLeechHitMode);
	g_esCache[tank].g_iLeechMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLeechMessage, g_esAbility[type].g_iLeechMessage);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveLeech(oldTank);
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
			vRemoveLeech(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveLeech(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveLeech(iTank);
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

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iLeechAbility == 1)
	{
		vLeechAbility(tank);
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

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iLeechAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vLeechAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "LeechHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveLeech(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
	g_esPlayer[newTank].g_iCount = g_esPlayer[oldTank].g_iCount;
}

static void vLeechAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
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
				if (flDistance <= g_esCache[tank].g_flLeechRange)
				{
					vLeechHit(iSurvivor, tank, g_esCache[tank].g_flLeechRangeChance, g_esCache[tank].g_iLeechAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "LeechHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "LeechAmmo");
	}
}

static void vLeechHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				g_esPlayer[survivor].g_bAffected = true;
				g_esPlayer[survivor].g_iOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "LeechHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "LeechHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				DataPack dpLeech;
				CreateDataTimer(g_esCache[tank].g_flLeechInterval, tTimerLeech, dpLeech, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpLeech.WriteCell(GetClientUserId(survivor));
				dpLeech.WriteCell(GetClientUserId(tank));
				dpLeech.WriteCell(g_esPlayer[tank].g_iTankType);
				dpLeech.WriteCell(messages);
				dpLeech.WriteCell(enabled);
				dpLeech.WriteCell(GetTime());

				vEffect(survivor, tank, g_esCache[tank].g_iLeechEffect, flags);

				if (g_esCache[tank].g_iLeechMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Leech", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Leech", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "LeechHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "LeechAmmo");
		}
	}
}

static void vRemoveLeech(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
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
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset3(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	if (g_esCache[tank].g_iLeechMessage & messages)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Leech2", sTankName, survivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Leech2", LANG_SERVER, sTankName, survivor);
	}
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

public Action tTimerLeech(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	static int iTank, iType, iMessage;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static int iLeechEnabled, iTime;
	iLeechEnabled = pack.ReadCell();
	iTime = pack.ReadCell();
	if (iLeechEnabled == 0 || (iTime + g_esCache[iTank].g_iLeechDuration) < GetTime())
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static int iTankHealth, iNewHealth, iFinalHealth;
	iTankHealth = GetClientHealth(iTank);
	iNewHealth = iTankHealth + 1;
	iFinalHealth = (iNewHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iNewHealth;
	//SetEntityHealth(iTank, iFinalHealth);
	SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalHealth);
	vDamageEntity(iSurvivor, iTank, 1.0, "2");

	return Plugin_Continue;
}