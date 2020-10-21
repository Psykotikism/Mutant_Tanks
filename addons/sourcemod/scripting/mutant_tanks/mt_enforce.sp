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

//#file "Enforce Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Enforce Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank forces survivors to only use a certain weapon slot.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Enforce Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_ENFORCE "Enforce Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flEnforceChance;
	float g_flEnforceDuration;
	float g_flEnforceRange;
	float g_flEnforceRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iEnforceAbility;
	int g_iEnforceEffect;
	int g_iEnforceHit;
	int g_iEnforceHitMode;
	int g_iEnforceMessage;
	int g_iEnforceSlot;
	int g_iEnforceWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iOwner;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flEnforceChance;
	float g_flEnforceDuration;
	float g_flEnforceRange;
	float g_flEnforceRangeChance;

	int g_iAccessFlags;
	int g_iEnforceAbility;
	int g_iEnforceEffect;
	int g_iEnforceHit;
	int g_iEnforceHitMode;
	int g_iEnforceMessage;
	int g_iEnforceWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flEnforceChance;
	float g_flEnforceDuration;
	float g_flEnforceRange;
	float g_flEnforceRangeChance;

	int g_iEnforceAbility;
	int g_iEnforceEffect;
	int g_iEnforceHit;
	int g_iEnforceHitMode;
	int g_iEnforceMessage;
	int g_iEnforceWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_enforce", cmdEnforceInfo, "View information about the Enforce ability.");

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

public Action cmdEnforceInfo(int client, int args)
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
		case false: vEnforceMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vEnforceMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iEnforceMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Enforce Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iEnforceMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iEnforceAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "EnforceDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esCache[param1].g_flEnforceDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vEnforceMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "EnforceMenu", param1);
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
	menu.AddItem(MT_MENU_ENFORCE, MT_MENU_ENFORCE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ENFORCE, false))
	{
		vEnforceMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_ENFORCE, false))
	{
		FormatEx(buffer, size, "%T", "EnforceMenu2", client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled())
	{
		return Plugin_Continue;
	}

	if (bIsSurvivor(client) && g_esPlayer[client].g_bAffected)
	{
		weapon = GetPlayerWeaponSlot(client, g_esPlayer[client].g_iEnforceSlot);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iEnforceHitMode == 0 || g_esCache[attacker].g_iEnforceHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vEnforceHit(victim, attacker, g_esCache[attacker].g_flEnforceChance, g_esCache[attacker].g_iEnforceHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iEnforceHitMode == 0 || g_esCache[victim].g_iEnforceHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vEnforceHit(attacker, victim, g_esCache[victim].g_flEnforceChance, g_esCache[victim].g_iEnforceHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("enforceability");
	list2.PushString("enforce ability");
	list3.PushString("enforce_ability");
	list4.PushString("enforce");
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
				g_esAbility[iIndex].g_iEnforceAbility = 0;
				g_esAbility[iIndex].g_iEnforceEffect = 0;
				g_esAbility[iIndex].g_iEnforceMessage = 0;
				g_esAbility[iIndex].g_flEnforceChance = 33.3;
				g_esAbility[iIndex].g_flEnforceDuration = 5.0;
				g_esAbility[iIndex].g_iEnforceHit = 0;
				g_esAbility[iIndex].g_iEnforceHitMode = 0;
				g_esAbility[iIndex].g_flEnforceRange = 150.0;
				g_esAbility[iIndex].g_flEnforceRangeChance = 15.0;
				g_esAbility[iIndex].g_iEnforceWeaponSlots = 0;
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
					g_esPlayer[iPlayer].g_iEnforceAbility = 0;
					g_esPlayer[iPlayer].g_iEnforceEffect = 0;
					g_esPlayer[iPlayer].g_iEnforceMessage = 0;
					g_esPlayer[iPlayer].g_flEnforceChance = 0.0;
					g_esPlayer[iPlayer].g_flEnforceDuration = 0.0;
					g_esPlayer[iPlayer].g_iEnforceHit = 0;
					g_esPlayer[iPlayer].g_iEnforceHitMode = 0;
					g_esPlayer[iPlayer].g_flEnforceRange = 0.0;
					g_esPlayer[iPlayer].g_flEnforceRangeChance = 0.0;
					g_esPlayer[iPlayer].g_iEnforceWeaponSlots = 0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iEnforceAbility = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iEnforceAbility, value, 0, 1);
		g_esPlayer[admin].g_iEnforceEffect = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iEnforceEffect, value, 0, 7);
		g_esPlayer[admin].g_iEnforceMessage = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iEnforceMessage, value, 0, 3);
		g_esPlayer[admin].g_flEnforceChance = flGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceChance", "Enforce Chance", "Enforce_Chance", "chance", g_esPlayer[admin].g_flEnforceChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flEnforceDuration = flGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceDuration", "Enforce Duration", "Enforce_Duration", "duration", g_esPlayer[admin].g_flEnforceDuration, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iEnforceHit = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceHit", "Enforce Hit", "Enforce_Hit", "hit", g_esPlayer[admin].g_iEnforceHit, value, 0, 1);
		g_esPlayer[admin].g_iEnforceHitMode = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceHitMode", "Enforce Hit Mode", "Enforce_Hit_Mode", "hitmode", g_esPlayer[admin].g_iEnforceHitMode, value, 0, 2);
		g_esPlayer[admin].g_flEnforceRange = flGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceRange", "Enforce Range", "Enforce_Range", "range", g_esPlayer[admin].g_flEnforceRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flEnforceRangeChance = flGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceRangeChance", "Enforce Range Chance", "Enforce_Range_Chance", "rangechance", g_esPlayer[admin].g_flEnforceRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iEnforceWeaponSlots = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceWeaponSlots", "Enforce Weapon Slots", "Enforce_Weapon_Slots", "slots", g_esPlayer[admin].g_iEnforceWeaponSlots, value, 0, 31);

		if (StrEqual(subsection, "enforceability", false) || StrEqual(subsection, "enforce ability", false) || StrEqual(subsection, "enforce_ability", false) || StrEqual(subsection, "enforce", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iEnforceAbility = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iEnforceAbility, value, 0, 1);
		g_esAbility[type].g_iEnforceEffect = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iEnforceEffect, value, 0, 7);
		g_esAbility[type].g_iEnforceMessage = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iEnforceMessage, value, 0, 3);
		g_esAbility[type].g_flEnforceChance = flGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceChance", "Enforce Chance", "Enforce_Chance", "chance", g_esAbility[type].g_flEnforceChance, value, 0.0, 100.0);
		g_esAbility[type].g_flEnforceDuration = flGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceDuration", "Enforce Duration", "Enforce_Duration", "duration", g_esAbility[type].g_flEnforceDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iEnforceHit = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceHit", "Enforce Hit", "Enforce_Hit", "hit", g_esAbility[type].g_iEnforceHit, value, 0, 1);
		g_esAbility[type].g_iEnforceHitMode = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceHitMode", "Enforce Hit Mode", "Enforce_Hit_Mode", "hitmode", g_esAbility[type].g_iEnforceHitMode, value, 0, 2);
		g_esAbility[type].g_flEnforceRange = flGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceRange", "Enforce Range", "Enforce_Range", "range", g_esAbility[type].g_flEnforceRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flEnforceRangeChance = flGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceRangeChance", "Enforce Range Chance", "Enforce_Range_Chance", "rangechance", g_esAbility[type].g_flEnforceRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iEnforceWeaponSlots = iGetKeyValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceWeaponSlots", "Enforce Weapon Slots", "Enforce_Weapon_Slots", "slots", g_esAbility[type].g_iEnforceWeaponSlots, value, 0, 31);

		if (StrEqual(subsection, "enforceability", false) || StrEqual(subsection, "enforce ability", false) || StrEqual(subsection, "enforce_ability", false) || StrEqual(subsection, "enforce", false))
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
	g_esCache[tank].g_flEnforceChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flEnforceChance, g_esAbility[type].g_flEnforceChance);
	g_esCache[tank].g_flEnforceDuration = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flEnforceDuration, g_esAbility[type].g_flEnforceDuration);
	g_esCache[tank].g_flEnforceRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flEnforceRange, g_esAbility[type].g_flEnforceRange);
	g_esCache[tank].g_flEnforceRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flEnforceRangeChance, g_esAbility[type].g_flEnforceRangeChance);
	g_esCache[tank].g_iEnforceAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iEnforceAbility, g_esAbility[type].g_iEnforceAbility);
	g_esCache[tank].g_iEnforceEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iEnforceEffect, g_esAbility[type].g_iEnforceEffect);
	g_esCache[tank].g_iEnforceHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iEnforceHit, g_esAbility[type].g_iEnforceHit);
	g_esCache[tank].g_iEnforceHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iEnforceHitMode, g_esAbility[type].g_iEnforceHitMode);
	g_esCache[tank].g_iEnforceMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iEnforceMessage, g_esAbility[type].g_iEnforceMessage);
	g_esCache[tank].g_iEnforceWeaponSlots = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iEnforceWeaponSlots, g_esAbility[type].g_iEnforceWeaponSlots);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
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
			vRemoveEnforce(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iEnforceAbility == 1)
	{
		vEnforceAbility(tank);
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
			if (g_esCache[tank].g_iEnforceAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vEnforceAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "EnforceHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveEnforce(tank);
}

static void vEnforceAbility(int tank)
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
				if (flDistance <= g_esCache[tank].g_flEnforceRange)
				{
					vEnforceHit(iSurvivor, tank, g_esCache[tank].g_flEnforceRangeChance, g_esCache[tank].g_iEnforceAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "EnforceHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "EnforceAmmo");
	}
}

static void vEnforceHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "EnforceHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "EnforceHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static int iSlotCount, iSlots[5], iFlag;
				iSlotCount = 0;
				for (int iBit = 0; iBit < sizeof(iSlots); iBit++)
				{
					iFlag = (1 << iBit);
					if (!(g_esCache[tank].g_iEnforceWeaponSlots & iFlag))
					{
						continue;
					}

					iSlots[iSlotCount] = iFlag;
					iSlotCount++;
				}

				switch (iSlots[GetRandomInt(0, iSlotCount - 1)])
				{
					case 1: g_esPlayer[survivor].g_iEnforceSlot = 0;
					case 2: g_esPlayer[survivor].g_iEnforceSlot = 1;
					case 4: g_esPlayer[survivor].g_iEnforceSlot = 2;
					case 8: g_esPlayer[survivor].g_iEnforceSlot = 3;
					case 16: g_esPlayer[survivor].g_iEnforceSlot = 4;
					default:
					{
						switch (GetRandomInt(1, 5))
						{
							case 1: g_esPlayer[survivor].g_iEnforceSlot = 0;
							case 2: g_esPlayer[survivor].g_iEnforceSlot = 1;
							case 3: g_esPlayer[survivor].g_iEnforceSlot = 2;
							case 4: g_esPlayer[survivor].g_iEnforceSlot = 3;
							case 5: g_esPlayer[survivor].g_iEnforceSlot = 4;
						}
					}
				}

				DataPack dpStopEnforce;
				CreateDataTimer(g_esCache[tank].g_flEnforceDuration, tTimerStopEnforce, dpStopEnforce, TIMER_FLAG_NO_MAPCHANGE);
				dpStopEnforce.WriteCell(GetClientUserId(survivor));
				dpStopEnforce.WriteCell(GetClientUserId(tank));
				dpStopEnforce.WriteCell(messages);

				vEffect(survivor, tank, g_esCache[tank].g_iEnforceEffect, flags);

				if (g_esCache[tank].g_iEnforceMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Enforce", sTankName, survivor, g_esPlayer[survivor].g_iEnforceSlot + 1);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Enforce", LANG_SERVER, sTankName, survivor, g_esPlayer[survivor].g_iEnforceSlot + 1);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "EnforceHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "EnforceAmmo");
		}
	}
}

static void vRemoveEnforce(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;
			g_esPlayer[iSurvivor].g_iEnforceSlot = INVALID_ENT_REFERENCE;
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
			g_esPlayer[iPlayer].g_iEnforceSlot = INVALID_ENT_REFERENCE;
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

static void vReset3(int survivor)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;
	g_esPlayer[survivor].g_iEnforceSlot = INVALID_ENT_REFERENCE;
}

public Action tTimerStopEnforce(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset3(iSurvivor);

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !MT_IsCustomTankSupported(iTank))
	{
		vReset3(iSurvivor);

		return Plugin_Stop;
	}

	vReset3(iSurvivor);

	int iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iEnforceMessage & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Enforce2", iSurvivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Enforce2", LANG_SERVER, iSurvivor);
	}

	return Plugin_Continue;
}