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

//#file "Pimp Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Pimp Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank pimp slaps survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Pimp Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_PIMP "Pimp Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flPimpChance;
	float g_flPimpInterval;
	float g_flPimpRange;
	float g_flPimpRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iOwner;
	int g_iPimpAbility;
	int g_iPimpDamage;
	int g_iPimpDuration;
	int g_iPimpEffect;
	int g_iPimpHit;
	int g_iPimpHitMode;
	int g_iPimpMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flPimpChance;
	float g_flPimpInterval;
	float g_flPimpRange;
	float g_flPimpRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iPimpAbility;
	int g_iPimpDamage;
	int g_iPimpDuration;
	int g_iPimpEffect;
	int g_iPimpHit;
	int g_iPimpHitMode;
	int g_iPimpMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flPimpChance;
	float g_flPimpInterval;
	float g_flPimpRange;
	float g_flPimpRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iPimpAbility;
	int g_iPimpDamage;
	int g_iPimpDuration;
	int g_iPimpEffect;
	int g_iPimpHit;
	int g_iPimpHitMode;
	int g_iPimpMessage;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_pimp", cmdPimpInfo, "View information about the Pimp ability.");

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

	vRemovePimp(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemovePimp(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdPimpInfo(int client, int args)
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
		case false: vPimpMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vPimpMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iPimpMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Pimp Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iPimpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iPimpAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "PimpDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iPimpDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vPimpMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "PimpMenu", param1);
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
	menu.AddItem(MT_MENU_PIMP, MT_MENU_PIMP);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_PIMP, false))
	{
		vPimpMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_PIMP, false))
	{
		FormatEx(buffer, size, "%T", "PimpMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iPimpHitMode == 0 || g_esCache[attacker].g_iPimpHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPimpHit(victim, attacker, g_esCache[attacker].g_flPimpChance, g_esCache[attacker].g_iPimpHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iPimpHitMode == 0 || g_esCache[victim].g_iPimpHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPimpHit(attacker, victim, g_esCache[victim].g_flPimpChance, g_esCache[victim].g_iPimpHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("pimpability");
	list2.PushString("pimp ability");
	list3.PushString("pimp_ability");
	list4.PushString("pimp");
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
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iPimpAbility = 0;
				g_esAbility[iIndex].g_iPimpEffect = 0;
				g_esAbility[iIndex].g_iPimpMessage = 0;
				g_esAbility[iIndex].g_flPimpChance = 33.3;
				g_esAbility[iIndex].g_iPimpDamage = 1;
				g_esAbility[iIndex].g_iPimpDuration = 5;
				g_esAbility[iIndex].g_iPimpHit = 0;
				g_esAbility[iIndex].g_iPimpHitMode = 0;
				g_esAbility[iIndex].g_flPimpInterval = 1.0;
				g_esAbility[iIndex].g_flPimpRange = 150.0;
				g_esAbility[iIndex].g_flPimpRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iPimpAbility = 0;
					g_esPlayer[iPlayer].g_iPimpEffect = 0;
					g_esPlayer[iPlayer].g_iPimpMessage = 0;
					g_esPlayer[iPlayer].g_flPimpChance = 0.0;
					g_esPlayer[iPlayer].g_iPimpDamage = 0;
					g_esPlayer[iPlayer].g_iPimpDuration = 0;
					g_esPlayer[iPlayer].g_iPimpHit = 0;
					g_esPlayer[iPlayer].g_iPimpHitMode = 0;
					g_esPlayer[iPlayer].g_flPimpInterval = 0.0;
					g_esPlayer[iPlayer].g_flPimpRange = 0.0;
					g_esPlayer[iPlayer].g_flPimpRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 1);
		g_esPlayer[admin].g_iPimpAbility = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iPimpAbility, value, 0, 1);
		g_esPlayer[admin].g_iPimpEffect = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iPimpEffect, value, 0, 7);
		g_esPlayer[admin].g_iPimpMessage = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iPimpMessage, value, 0, 3);
		g_esPlayer[admin].g_flPimpChance = flGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpChance", "Pimp Chance", "Pimp_Chance", "chance", g_esPlayer[admin].g_flPimpChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iPimpDamage = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpDamage", "Pimp Damage", "Pimp_Damage", "damage", g_esPlayer[admin].g_iPimpDamage, value, 1, 999999);
		g_esPlayer[admin].g_iPimpDuration = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpDuration", "Pimp Duration", "Pimp_Duration", "duration", g_esPlayer[admin].g_iPimpDuration, value, 1, 999999);
		g_esPlayer[admin].g_iPimpHit = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpHit", "Pimp Hit", "Pimp_Hit", "hit", g_esPlayer[admin].g_iPimpHit, value, 0, 1);
		g_esPlayer[admin].g_iPimpHitMode = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpHitMode", "Pimp Hit Mode", "Pimp_Hit_Mode", "hitmode", g_esPlayer[admin].g_iPimpHitMode, value, 0, 2);
		g_esPlayer[admin].g_flPimpInterval = flGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpInterval", "Pimp Interval", "Pimp_Interval", "interval", g_esPlayer[admin].g_flPimpInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flPimpRange = flGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpRange", "Pimp Range", "Pimp_Range", "range", g_esPlayer[admin].g_flPimpRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flPimpRangeChance = flGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpRangeChance", "Pimp Range Chance", "Pimp_Range_Chance", "rangechance", g_esPlayer[admin].g_flPimpRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "pimpability", false) || StrEqual(subsection, "pimp ability", false) || StrEqual(subsection, "pimp_ability", false) || StrEqual(subsection, "pimp", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 1);
		g_esAbility[type].g_iPimpAbility = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iPimpAbility, value, 0, 1);
		g_esAbility[type].g_iPimpEffect = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iPimpEffect, value, 0, 7);
		g_esAbility[type].g_iPimpMessage = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iPimpMessage, value, 0, 3);
		g_esAbility[type].g_flPimpChance = flGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpChance", "Pimp Chance", "Pimp_Chance", "chance", g_esAbility[type].g_flPimpChance, value, 0.0, 100.0);
		g_esAbility[type].g_iPimpDamage = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpDamage", "Pimp Damage", "Pimp_Damage", "damage", g_esAbility[type].g_iPimpDamage, value, 1, 999999);
		g_esAbility[type].g_iPimpDuration = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpDuration", "Pimp Duration", "Pimp_Duration", "duration", g_esAbility[type].g_iPimpDuration, value, 1, 999999);
		g_esAbility[type].g_iPimpHit = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpHit", "Pimp Hit", "Pimp_Hit", "hit", g_esAbility[type].g_iPimpHit, value, 0, 1);
		g_esAbility[type].g_iPimpHitMode = iGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpHitMode", "Pimp Hit Mode", "Pimp_Hit_Mode", "hitmode", g_esAbility[type].g_iPimpHitMode, value, 0, 2);
		g_esAbility[type].g_flPimpInterval = flGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpInterval", "Pimp Interval", "Pimp_Interval", "interval", g_esAbility[type].g_flPimpInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flPimpRange = flGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpRange", "Pimp Range", "Pimp_Range", "range", g_esAbility[type].g_flPimpRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flPimpRangeChance = flGetKeyValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpRangeChance", "Pimp Range Chance", "Pimp_Range_Chance", "rangechance", g_esAbility[type].g_flPimpRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "pimpability", false) || StrEqual(subsection, "pimp ability", false) || StrEqual(subsection, "pimp_ability", false) || StrEqual(subsection, "pimp", false))
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
	g_esCache[tank].g_flPimpChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPimpChance, g_esAbility[type].g_flPimpChance);
	g_esCache[tank].g_flPimpInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPimpInterval, g_esAbility[type].g_flPimpInterval);
	g_esCache[tank].g_flPimpRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPimpRange, g_esAbility[type].g_flPimpRange);
	g_esCache[tank].g_flPimpRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPimpRangeChance, g_esAbility[type].g_flPimpRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iPimpAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPimpAbility, g_esAbility[type].g_iPimpAbility);
	g_esCache[tank].g_iPimpDamage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPimpDamage, g_esAbility[type].g_iPimpDamage);
	g_esCache[tank].g_iPimpDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPimpDuration, g_esAbility[type].g_iPimpDuration);
	g_esCache[tank].g_iPimpEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPimpEffect, g_esAbility[type].g_iPimpEffect);
	g_esCache[tank].g_iPimpHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPimpHit, g_esAbility[type].g_iPimpHit);
	g_esCache[tank].g_iPimpHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPimpHitMode, g_esAbility[type].g_iPimpHitMode);
	g_esCache[tank].g_iPimpMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPimpMessage, g_esAbility[type].g_iPimpMessage);
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
			vRemovePimp(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iPimpAbility == 1)
	{
		vPimpAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iPimpAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vPimpAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "PimpHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemovePimp(tank);
}

static void vPimpAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
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
				if (flDistance <= g_esCache[tank].g_flPimpRange)
				{
					vPimpHit(iSurvivor, tank, g_esCache[tank].g_flPimpRangeChance, g_esCache[tank].g_iPimpAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "PimpHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PimpAmmo");
	}
}

static void vPimpHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "PimpHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "PimpHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				DataPack dpPimp;
				CreateDataTimer(g_esCache[tank].g_flPimpInterval, tTimerPimp, dpPimp, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpPimp.WriteCell(GetClientUserId(survivor));
				dpPimp.WriteCell(GetClientUserId(tank));
				dpPimp.WriteCell(g_esPlayer[tank].g_iTankType);
				dpPimp.WriteCell(messages);
				dpPimp.WriteCell(enabled);
				dpPimp.WriteCell(GetTime());

				vEffect(survivor, tank, g_esCache[tank].g_iPimpEffect, flags);

				if (g_esCache[tank].g_iPimpMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Pimp", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "PimpHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "PimpAmmo");
		}
	}
}

static void vRemovePimp(int tank)
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

	if (g_esCache[tank].g_iPimpMessage & messages)
	{
		MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Pimp2", survivor);
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

public Action tTimerPimp(Handle timer, DataPack pack)
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
	if (!MT_IsTankSupported(iTank) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static int iPimpEnabled, iTime;
	iPimpEnabled = pack.ReadCell();
	iTime = pack.ReadCell();
	if (iPimpEnabled == 0 || (iTime + g_esCache[iTank].g_iPimpDuration) < GetTime() || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	SlapPlayer(iSurvivor, g_esCache[iTank].g_iPimpDamage, true);

	return Plugin_Continue;
}