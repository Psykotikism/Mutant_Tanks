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

//#file "Nullify Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Nullify Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank nullifies all of the survivors' damage.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Nullify Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_NULLIFY "Nullify Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flNullifyChance;
	float g_flNullifyDuration;
	float g_flNullifyRange;
	float g_flNullifyRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iNullifyAbility;
	int g_iNullifyEffect;
	int g_iNullifyHit;
	int g_iNullifyHitMode;
	int g_iNullifyMessage;
	int g_iOwner;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flNullifyChance;
	float g_flNullifyDuration;
	float g_flNullifyRange;
	float g_flNullifyRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iNullifyAbility;
	int g_iNullifyEffect;
	int g_iNullifyHit;
	int g_iNullifyHitMode;
	int g_iNullifyMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flNullifyChance;
	float g_flNullifyDuration;
	float g_flNullifyRange;
	float g_flNullifyRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iNullifyAbility;
	int g_iNullifyEffect;
	int g_iNullifyHit;
	int g_iNullifyHitMode;
	int g_iNullifyMessage;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

bool g_bCloneInstalled;

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_nullify", cmdNullifyInfo, "View information about the Nullify ability.");

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

	vReset2(client);
}

public void OnClientDisconnect_Post(int client)
{
	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdNullifyInfo(int client, int args)
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
		case false: vNullifyMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vNullifyMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iNullifyMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Nullify Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iNullifyMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iNullifyAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "NullifyDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esCache[param1].g_flNullifyDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vNullifyMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "NullifyMenu", param1);
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
	menu.AddItem(MT_MENU_NULLIFY, MT_MENU_NULLIFY);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_NULLIFY, false))
	{
		vNullifyMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_NULLIFY, false))
	{
		FormatEx(buffer, size, "%T", "NullifyMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_esCache[attacker].g_iNullifyHitMode == 0 || g_esCache[attacker].g_iNullifyHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vNullifyHit(victim, attacker, g_esCache[attacker].g_flNullifyChance, g_esCache[attacker].g_iNullifyHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if ((g_esCache[victim].g_iNullifyHitMode == 0 || g_esCache[victim].g_iNullifyHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
			{
				if ((MT_HasAdminAccess(victim) || bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) && !MT_IsAdminImmune(attacker, victim) && !bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
				{
					vNullifyHit(attacker, victim, g_esCache[victim].g_flNullifyChance, g_esCache[victim].g_iNullifyHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
				}
			}

			if (g_esPlayer[attacker].g_bAffected)
			{
				return Plugin_Handled;
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
	list.PushString("nullifyability");
	list2.PushString("nullify ability");
	list3.PushString("nullify_ability");
	list4.PushString("nullify");
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
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iNullifyAbility = 0;
				g_esAbility[iIndex].g_iNullifyEffect = 0;
				g_esAbility[iIndex].g_iNullifyMessage = 0;
				g_esAbility[iIndex].g_flNullifyChance = 33.3;
				g_esAbility[iIndex].g_flNullifyDuration = 5.0;
				g_esAbility[iIndex].g_iNullifyHit = 0;
				g_esAbility[iIndex].g_iNullifyHitMode = 0;
				g_esAbility[iIndex].g_flNullifyRange = 150.0;
				g_esAbility[iIndex].g_flNullifyRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iNullifyAbility = 0;
					g_esPlayer[iPlayer].g_iNullifyEffect = 0;
					g_esPlayer[iPlayer].g_iNullifyMessage = 0;
					g_esPlayer[iPlayer].g_flNullifyChance = 0.0;
					g_esPlayer[iPlayer].g_flNullifyDuration = 0.0;
					g_esPlayer[iPlayer].g_iNullifyHit = 0;
					g_esPlayer[iPlayer].g_iNullifyHitMode = 0;
					g_esPlayer[iPlayer].g_flNullifyRange = 0.0;
					g_esPlayer[iPlayer].g_flNullifyRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iNullifyAbility = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iNullifyAbility, value, 0, 1);
		g_esPlayer[admin].g_iNullifyEffect = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iNullifyEffect, value, 0, 7);
		g_esPlayer[admin].g_iNullifyMessage = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iNullifyMessage, value, 0, 3);
		g_esPlayer[admin].g_flNullifyChance = flGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyChance", "Nullify Chance", "Nullify_Chance", "chance", g_esPlayer[admin].g_flNullifyChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flNullifyDuration = flGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyDuration", "Nullify Duration", "Nullify_Duration", "duration", g_esPlayer[admin].g_flNullifyDuration, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iNullifyHit = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyHit", "Nullify Hit", "Nullify_Hit", "hit", g_esPlayer[admin].g_iNullifyHit, value, 0, 1);
		g_esPlayer[admin].g_iNullifyHitMode = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyHitMode", "Nullify Hit Mode", "Nullify_Hit_Mode", "hitmode", g_esPlayer[admin].g_iNullifyHitMode, value, 0, 2);
		g_esPlayer[admin].g_flNullifyRange = flGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyRange", "Nullify Range", "Nullify_Range", "range", g_esPlayer[admin].g_flNullifyRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flNullifyRangeChance = flGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyRangeChance", "Nullify Range Chance", "Nullify_Range_Chance", "rangechance", g_esPlayer[admin].g_flNullifyRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "nullifyability", false) || StrEqual(subsection, "nullify ability", false) || StrEqual(subsection, "nullify_ability", false) || StrEqual(subsection, "nullify", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iNullifyAbility = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iNullifyAbility, value, 0, 1);
		g_esAbility[type].g_iNullifyEffect = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iNullifyEffect, value, 0, 7);
		g_esAbility[type].g_iNullifyMessage = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iNullifyMessage, value, 0, 3);
		g_esAbility[type].g_flNullifyChance = flGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyChance", "Nullify Chance", "Nullify_Chance", "chance", g_esAbility[type].g_flNullifyChance, value, 0.0, 100.0);
		g_esAbility[type].g_flNullifyDuration = flGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyDuration", "Nullify Duration", "Nullify_Duration", "duration", g_esAbility[type].g_flNullifyDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iNullifyHit = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyHit", "Nullify Hit", "Nullify_Hit", "hit", g_esAbility[type].g_iNullifyHit, value, 0, 1);
		g_esAbility[type].g_iNullifyHitMode = iGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyHitMode", "Nullify Hit Mode", "Nullify_Hit_Mode", "hitmode", g_esAbility[type].g_iNullifyHitMode, value, 0, 2);
		g_esAbility[type].g_flNullifyRange = flGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyRange", "Nullify Range", "Nullify_Range", "range", g_esAbility[type].g_flNullifyRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flNullifyRangeChance = flGetKeyValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyRangeChance", "Nullify Range Chance", "Nullify_Range_Chance", "rangechance", g_esAbility[type].g_flNullifyRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "nullifyability", false) || StrEqual(subsection, "nullify ability", false) || StrEqual(subsection, "nullify_ability", false) || StrEqual(subsection, "nullify", false))
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
	g_esCache[tank].g_flNullifyChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flNullifyChance, g_esAbility[type].g_flNullifyChance);
	g_esCache[tank].g_flNullifyDuration = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flNullifyDuration, g_esAbility[type].g_flNullifyDuration);
	g_esCache[tank].g_flNullifyRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flNullifyRange, g_esAbility[type].g_flNullifyRange);
	g_esCache[tank].g_flNullifyRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flNullifyRangeChance, g_esAbility[type].g_flNullifyRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iNullifyAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iNullifyAbility, g_esAbility[type].g_iNullifyAbility);
	g_esCache[tank].g_iNullifyEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iNullifyEffect, g_esAbility[type].g_iNullifyEffect);
	g_esCache[tank].g_iNullifyHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iNullifyHit, g_esAbility[type].g_iNullifyHit);
	g_esCache[tank].g_iNullifyHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iNullifyHitMode, g_esAbility[type].g_iNullifyHitMode);
	g_esCache[tank].g_iNullifyMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iNullifyMessage, g_esAbility[type].g_iNullifyMessage);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveNullify(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esCache[tank].g_iNullifyAbility == 1)
	{
		vNullifyAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iNullifyAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vNullifyAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "NullifyHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveNullify(tank);
}

static void vNullifyAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
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
				if (flDistance <= g_esCache[tank].g_flNullifyRange)
				{
					vNullifyHit(iSurvivor, tank, g_esCache[tank].g_flNullifyRangeChance, g_esCache[tank].g_iNullifyAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "NullifyHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "NullifyAmmo");
	}
}

static void vNullifyHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "NullifyHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "NullifyHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				DataPack dpStopNullify;
				CreateDataTimer(g_esCache[tank].g_flNullifyDuration, tTimerStopNullify, dpStopNullify, TIMER_FLAG_NO_MAPCHANGE);
				dpStopNullify.WriteCell(GetClientUserId(survivor));
				dpStopNullify.WriteCell(GetClientUserId(tank));
				dpStopNullify.WriteCell(messages);

				vEffect(survivor, tank, g_esCache[tank].g_iNullifyEffect, flags);

				if (g_esCache[tank].g_iNullifyMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Nullify", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Nullify", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "NullifyHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "NullifyAmmo");
		}
	}
}

static void vRemoveNullify(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset2(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

public Action tTimerStopNullify(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	g_esPlayer[iSurvivor].g_bAffected = false;
	g_esPlayer[iSurvivor].g_iOwner = 0;

	int iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iNullifyMessage & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Nullify2", iSurvivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Nullify2", LANG_SERVER, iSurvivor);
	}

	return Plugin_Continue;
}