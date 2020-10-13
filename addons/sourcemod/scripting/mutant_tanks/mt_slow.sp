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

//#file "Slow Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Slow Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank slows survivors down.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Slow Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_DRIP "ambient/water/distant_drip2.wav"
#define SOUND_RAGE "npc/infected/action/rage/female/rage_68.wav"

#define MT_MENU_SLOW "Slow Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flSlowChance;
	float g_flSlowDuration;
	float g_flSlowRange;
	float g_flSlowRangeChance;
	float g_flSlowSpeed;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iOwner;
	int g_iSlowAbility;
	int g_iSlowEffect;
	int g_iSlowHit;
	int g_iSlowHitMode;
	int g_iSlowMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flSlowChance;
	float g_flSlowDuration;
	float g_flSlowRange;
	float g_flSlowRangeChance;
	float g_flSlowSpeed;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iSlowAbility;
	int g_iSlowEffect;
	int g_iSlowHit;
	int g_iSlowHitMode;
	int g_iSlowMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flSlowChance;
	float g_flSlowDuration;
	float g_flSlowRange;
	float g_flSlowRangeChance;
	float g_flSlowSpeed;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iSlowAbility;
	int g_iSlowEffect;
	int g_iSlowHit;
	int g_iSlowHitMode;
	int g_iSlowMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_slow", cmdSlowInfo, "View information about the Slow ability.");

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
	PrecacheSound(SOUND_DRIP, true);
	PrecacheSound(SOUND_RAGE, true);

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

public Action cmdSlowInfo(int client, int args)
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
		case false: vSlowMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vSlowMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iSlowMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Slow Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iSlowMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iSlowAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "SlowDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esCache[param1].g_flSlowDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vSlowMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "SlowMenu", param1);
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
	menu.AddItem(MT_MENU_SLOW, MT_MENU_SLOW);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_SLOW, false))
	{
		vSlowMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_SLOW, false))
	{
		FormatEx(buffer, size, "%T", "SlowMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iSlowHitMode == 0 || g_esCache[attacker].g_iSlowHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSlowHit(victim, attacker, g_esCache[attacker].g_flSlowChance, g_esCache[attacker].g_iSlowHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iSlowHitMode == 0 || g_esCache[victim].g_iSlowHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSlowHit(attacker, victim, g_esCache[victim].g_flSlowChance, g_esCache[victim].g_iSlowHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("slowability");
	list2.PushString("slow ability");
	list3.PushString("slow_ability");
	list4.PushString("slow");
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
				g_esAbility[iIndex].g_iSlowAbility = 0;
				g_esAbility[iIndex].g_iSlowEffect = 0;
				g_esAbility[iIndex].g_iSlowMessage = 0;
				g_esAbility[iIndex].g_flSlowChance = 33.3;
				g_esAbility[iIndex].g_flSlowDuration = 5.0;
				g_esAbility[iIndex].g_iSlowHit = 0;
				g_esAbility[iIndex].g_iSlowHitMode = 0;
				g_esAbility[iIndex].g_flSlowRange = 150.0;
				g_esAbility[iIndex].g_flSlowRangeChance = 15.0;
				g_esAbility[iIndex].g_flSlowSpeed = 0.25;
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
					g_esPlayer[iPlayer].g_iSlowAbility = 0;
					g_esPlayer[iPlayer].g_iSlowEffect = 0;
					g_esPlayer[iPlayer].g_iSlowMessage = 0;
					g_esPlayer[iPlayer].g_flSlowChance = 0.0;
					g_esPlayer[iPlayer].g_flSlowDuration = 0.0;
					g_esPlayer[iPlayer].g_iSlowHit = 0;
					g_esPlayer[iPlayer].g_iSlowHitMode = 0;
					g_esPlayer[iPlayer].g_flSlowRange = 0.0;
					g_esPlayer[iPlayer].g_flSlowRangeChance = 0.0;
					g_esPlayer[iPlayer].g_flSlowSpeed = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iSlowAbility = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iSlowAbility, value, 0, 1);
		g_esPlayer[admin].g_iSlowEffect = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iSlowEffect, value, 0, 7);
		g_esPlayer[admin].g_iSlowMessage = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iSlowMessage, value, 0, 7);
		g_esPlayer[admin].g_flSlowChance = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowChance", "Slow Chance", "Slow_Chance", "chance", g_esPlayer[admin].g_flSlowChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flSlowDuration = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowDuration", "Slow Duration", "Slow_Duration", "duration", g_esPlayer[admin].g_flSlowDuration, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iSlowHit = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowHit", "Slow Hit", "Slow_Hit", "hit", g_esPlayer[admin].g_iSlowHit, value, 0, 1);
		g_esPlayer[admin].g_iSlowHitMode = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowHitMode", "Slow Hit Mode", "Slow_Hit_Mode", "hitmode", g_esPlayer[admin].g_iSlowHitMode, value, 0, 2);
		g_esPlayer[admin].g_flSlowRange = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowRange", "Slow Range", "Slow_Range", "range", g_esPlayer[admin].g_flSlowRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flSlowRangeChance = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowRangeChance", "Slow Range Chance", "Slow_Range_Chance", "rangechance", g_esPlayer[admin].g_flSlowRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flSlowSpeed = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowSpeed", "Slow Speed", "Slow_Speed", "speed", g_esPlayer[admin].g_flSlowSpeed, value, 0.1, 0.9);

		if (StrEqual(subsection, "slowability", false) || StrEqual(subsection, "slow ability", false) || StrEqual(subsection, "slow_ability", false) || StrEqual(subsection, "slow", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iSlowAbility = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iSlowAbility, value, 0, 1);
		g_esAbility[type].g_iSlowEffect = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iSlowEffect, value, 0, 7);
		g_esAbility[type].g_iSlowMessage = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iSlowMessage, value, 0, 7);
		g_esAbility[type].g_flSlowChance = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowChance", "Slow Chance", "Slow_Chance", "chance", g_esAbility[type].g_flSlowChance, value, 0.0, 100.0);
		g_esAbility[type].g_flSlowDuration = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowDuration", "Slow Duration", "Slow_Duration", "duration", g_esAbility[type].g_flSlowDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iSlowHit = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowHit", "Slow Hit", "Slow_Hit", "hit", g_esAbility[type].g_iSlowHit, value, 0, 1);
		g_esAbility[type].g_iSlowHitMode = iGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowHitMode", "Slow Hit Mode", "Slow_Hit_Mode", "hitmode", g_esAbility[type].g_iSlowHitMode, value, 0, 2);
		g_esAbility[type].g_flSlowRange = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowRange", "Slow Range", "Slow_Range", "range", g_esAbility[type].g_flSlowRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flSlowRangeChance = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowRangeChance", "Slow Range Chance", "Slow_Range_Chance", "rangechance", g_esAbility[type].g_flSlowRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_flSlowSpeed = flGetKeyValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowSpeed", "Slow Speed", "Slow_Speed", "speed", g_esAbility[type].g_flSlowSpeed, value, 0.1, 0.9);

		if (StrEqual(subsection, "slowability", false) || StrEqual(subsection, "slow ability", false) || StrEqual(subsection, "slow_ability", false) || StrEqual(subsection, "slow", false))
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
	g_esCache[tank].g_flSlowChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSlowChance, g_esAbility[type].g_flSlowChance);
	g_esCache[tank].g_flSlowDuration = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSlowDuration, g_esAbility[type].g_flSlowDuration);
	g_esCache[tank].g_flSlowRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSlowRange, g_esAbility[type].g_flSlowRange);
	g_esCache[tank].g_flSlowRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSlowRangeChance, g_esAbility[type].g_flSlowRangeChance);
	g_esCache[tank].g_flSlowSpeed = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSlowSpeed, g_esAbility[type].g_flSlowSpeed);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iSlowAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSlowAbility, g_esAbility[type].g_iSlowAbility);
	g_esCache[tank].g_iSlowEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSlowEffect, g_esAbility[type].g_iSlowEffect);
	g_esCache[tank].g_iSlowHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSlowHit, g_esAbility[type].g_iSlowHit);
	g_esCache[tank].g_iSlowHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSlowHitMode, g_esAbility[type].g_iSlowHitMode);
	g_esCache[tank].g_iSlowMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSlowMessage, g_esAbility[type].g_iSlowMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
		{
			vRemoveSlow(iTank);
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveSlow(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iSlowAbility == 1)
	{
		vSlowAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iSlowAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vSlowAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "SlowHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveSlow(tank);
}

static void vRemoveSlow(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;

			SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
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

static void vSlowAbility(int tank)
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
				if (flDistance <= g_esCache[tank].g_flSlowRange)
				{
					vSlowHit(iSurvivor, tank, g_esCache[tank].g_flSlowRangeChance, g_esCache[tank].g_iSlowAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "SlowHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SlowAmmo");
	}
}

static void vSlowHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "SlowHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "SlowHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", g_esCache[tank].g_flSlowSpeed);

				DataPack dpStopSlow;
				CreateDataTimer(g_esCache[tank].g_flSlowDuration, tTimerStopSlow, dpStopSlow, TIMER_FLAG_NO_MAPCHANGE);
				dpStopSlow.WriteCell(GetClientUserId(survivor));
				dpStopSlow.WriteCell(GetClientUserId(tank));
				dpStopSlow.WriteCell(messages);

				vEffect(survivor, tank, g_esCache[tank].g_iSlowEffect, flags);
				EmitSoundToAll(SOUND_RAGE, survivor);

				if (g_esCache[tank].g_iSlowMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Slow", sTankName, survivor, g_esCache[tank].g_flSlowSpeed);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Slow", sTankName, survivor, g_esCache[tank].g_flSlowSpeed);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "SlowHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "SlowAmmo");
		}
	}
}

public Action tTimerStopSlow(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		EmitSoundToAll(SOUND_DRIP, iSurvivor);

		return Plugin_Stop;
	}

	g_esPlayer[iSurvivor].g_bAffected = false;
	g_esPlayer[iSurvivor].g_iOwner = 0;

	SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
	EmitSoundToAll(SOUND_DRIP, iSurvivor);

	int iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iSlowMessage & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Slow2", iSurvivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Slow2", iSurvivor);
	}

	return Plugin_Continue;
}