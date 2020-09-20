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

#file "Whirl Ability v8.78"

public Plugin myinfo =
{
	name = "[MT] Whirl Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank makes survivors' screens whirl.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Whirl Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SPRITE_DOT "sprites/dot.vmt"

#define MT_MENU_WHIRL "Whirl Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flWhirlChance;
	float g_flWhirlRange;
	float g_flWhirlRangeChance;
	float g_flWhirlSpeed;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iTankType;
	int g_iWhirlAbility;
	int g_iWhirlAxis;
	int g_iWhirlDuration;
	int g_iWhirlEffect;
	int g_iWhirlHit;
	int g_iWhirlHitMode;
	int g_iWhirlMessage;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flWhirlChance;
	float g_flWhirlRange;
	float g_flWhirlRangeChance;
	float g_flWhirlSpeed;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iWhirlAbility;
	int g_iWhirlAxis;
	int g_iWhirlDuration;
	int g_iWhirlEffect;
	int g_iWhirlHit;
	int g_iWhirlHitMode;
	int g_iWhirlMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flWhirlChance;
	float g_flWhirlRange;
	float g_flWhirlRangeChance;
	float g_flWhirlSpeed;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iWhirlAbility;
	int g_iWhirlAxis;
	int g_iWhirlDuration;
	int g_iWhirlEffect;
	int g_iWhirlHit;
	int g_iWhirlHitMode;
	int g_iWhirlMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_whirl", cmdWhirlInfo, "View information about the Whirl ability.");

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
	PrecacheModel(SPRITE_DOT, true);

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

public Action cmdWhirlInfo(int client, int args)
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
		case false: vWhirlMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vWhirlMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iWhirlMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Whirl Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iWhirlMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iWhirlAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "WhirlDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iWhirlDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vWhirlMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "WhirlMenu", param1);
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
	menu.AddItem(MT_MENU_WHIRL, MT_MENU_WHIRL);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_WHIRL, false))
	{
		vWhirlMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_WHIRL, false))
	{
		FormatEx(buffer, size, "%T", "WhirlMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iWhirlHitMode == 0 || g_esCache[attacker].g_iWhirlHitMode == 1) && bIsHumanSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWhirlHit(victim, attacker, g_esCache[attacker].g_flWhirlChance, g_esCache[attacker].g_iWhirlHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iWhirlHitMode == 0 || g_esCache[victim].g_iWhirlHitMode == 2) && bIsHumanSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vWhirlHit(attacker, victim, g_esCache[victim].g_flWhirlChance, g_esCache[victim].g_iWhirlHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("whirlability");
	list2.PushString("whirl ability");
	list3.PushString("whirl_ability");
	list4.PushString("whirl");
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
				g_esAbility[iIndex].g_iWhirlAbility = 0;
				g_esAbility[iIndex].g_iWhirlEffect = 0;
				g_esAbility[iIndex].g_iWhirlMessage = 0;
				g_esAbility[iIndex].g_iWhirlAxis = 0;
				g_esAbility[iIndex].g_flWhirlChance = 33.3;
				g_esAbility[iIndex].g_iWhirlDuration = 5;
				g_esAbility[iIndex].g_iWhirlHit = 0;
				g_esAbility[iIndex].g_iWhirlHitMode = 0;
				g_esAbility[iIndex].g_flWhirlRange = 150.0;
				g_esAbility[iIndex].g_flWhirlRangeChance = 15.0;
				g_esAbility[iIndex].g_flWhirlSpeed = 500.0;
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
					g_esPlayer[iPlayer].g_iWhirlAbility = 0;
					g_esPlayer[iPlayer].g_iWhirlEffect = 0;
					g_esPlayer[iPlayer].g_iWhirlMessage = 0;
					g_esPlayer[iPlayer].g_iWhirlAxis = 0;
					g_esPlayer[iPlayer].g_flWhirlChance = 0.0;
					g_esPlayer[iPlayer].g_iWhirlDuration = 0;
					g_esPlayer[iPlayer].g_iWhirlHit = 0;
					g_esPlayer[iPlayer].g_iWhirlHitMode = 0;
					g_esPlayer[iPlayer].g_flWhirlRange = 0.0;
					g_esPlayer[iPlayer].g_flWhirlRangeChance = 0.0;
					g_esPlayer[iPlayer].g_flWhirlSpeed = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iWhirlAbility = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iWhirlAbility, value, 0, 1);
		g_esPlayer[admin].g_iWhirlEffect = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iWhirlEffect, value, 0, 7);
		g_esPlayer[admin].g_iWhirlMessage = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iWhirlMessage, value, 0, 3);
		g_esPlayer[admin].g_iWhirlAxis = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlAxis", "Whirl Axis", "Whirl_Axis", "axis", g_esPlayer[admin].g_iWhirlAxis, value, 0, 7);
		g_esPlayer[admin].g_flWhirlChance = flGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlChance", "Whirl Chance", "Whirl_Chance", "chance", g_esPlayer[admin].g_flWhirlChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iWhirlDuration = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlDuration", "Whirl Duration", "Whirl_Duration", "duration", g_esPlayer[admin].g_iWhirlDuration, value, 1, 999999);
		g_esPlayer[admin].g_iWhirlHit = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlHit", "Whirl Hit", "Whirl_Hit", "hit", g_esPlayer[admin].g_iWhirlHit, value, 0, 1);
		g_esPlayer[admin].g_iWhirlHitMode = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlHitMode", "Whirl Hit Mode", "Whirl_Hit_Mode", "hitmode", g_esPlayer[admin].g_iWhirlHitMode, value, 0, 2);
		g_esPlayer[admin].g_flWhirlRange = flGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlRange", "Whirl Range", "Whirl_Range", "range", g_esPlayer[admin].g_flWhirlRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flWhirlRangeChance = flGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlRangeChance", "Whirl Range Chance", "Whirl_Range_Chance", "rangechance", g_esPlayer[admin].g_flWhirlRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flWhirlSpeed = flGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlSpeed", "Whirl Speed", "Whirl_Speed", "speed", g_esPlayer[admin].g_flWhirlSpeed, value, 1.0, 999999.0);

		if (StrEqual(subsection, "whirlability", false) || StrEqual(subsection, "whirl ability", false) || StrEqual(subsection, "whirl_ability", false) || StrEqual(subsection, "whirl", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iWhirlAbility = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iWhirlAbility, value, 0, 1);
		g_esAbility[type].g_iWhirlEffect = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iWhirlEffect, value, 0, 7);
		g_esAbility[type].g_iWhirlMessage = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iWhirlMessage, value, 0, 3);
		g_esAbility[type].g_iWhirlAxis = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlAxis", "Whirl Axis", "Whirl_Axis", "axis", g_esAbility[type].g_iWhirlAxis, value, 0, 7);
		g_esAbility[type].g_flWhirlChance = flGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlChance", "Whirl Chance", "Whirl_Chance", "chance", g_esAbility[type].g_flWhirlChance, value, 0.0, 100.0);
		g_esAbility[type].g_iWhirlDuration = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlDuration", "Whirl Duration", "Whirl_Duration", "duration", g_esAbility[type].g_iWhirlDuration, value, 1, 999999);
		g_esAbility[type].g_iWhirlHit = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlHit", "Whirl Hit", "Whirl_Hit", "hit", g_esAbility[type].g_iWhirlHit, value, 0, 1);
		g_esAbility[type].g_iWhirlHitMode = iGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlHitMode", "Whirl Hit Mode", "Whirl_Hit_Mode", "hitmode", g_esAbility[type].g_iWhirlHitMode, value, 0, 2);
		g_esAbility[type].g_flWhirlRange = flGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlRange", "Whirl Range", "Whirl_Range", "range", g_esAbility[type].g_flWhirlRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flWhirlRangeChance = flGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlRangeChance", "Whirl Range Chance", "Whirl_Range_Chance", "rangechance", g_esAbility[type].g_flWhirlRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_flWhirlSpeed = flGetKeyValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlSpeed", "Whirl Speed", "Whirl_Speed", "speed", g_esAbility[type].g_flWhirlSpeed, value, 1.0, 999999.0);

		if (StrEqual(subsection, "whirlability", false) || StrEqual(subsection, "whirl ability", false) || StrEqual(subsection, "whirl_ability", false) || StrEqual(subsection, "whirl", false))
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
	g_esCache[tank].g_flWhirlChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWhirlChance, g_esAbility[type].g_flWhirlChance);
	g_esCache[tank].g_flWhirlRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWhirlRange, g_esAbility[type].g_flWhirlRange);
	g_esCache[tank].g_flWhirlRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWhirlRangeChance, g_esAbility[type].g_flWhirlRangeChance);
	g_esCache[tank].g_flWhirlSpeed = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWhirlSpeed, g_esAbility[type].g_flWhirlSpeed);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iWhirlAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWhirlAbility, g_esAbility[type].g_iWhirlAbility);
	g_esCache[tank].g_iWhirlAxis = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWhirlAxis, g_esAbility[type].g_iWhirlAxis);
	g_esCache[tank].g_iWhirlDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWhirlDuration, g_esAbility[type].g_iWhirlDuration);
	g_esCache[tank].g_iWhirlEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWhirlEffect, g_esAbility[type].g_iWhirlEffect);
	g_esCache[tank].g_iWhirlHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWhirlHit, g_esAbility[type].g_iWhirlHit);
	g_esCache[tank].g_iWhirlHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWhirlHitMode, g_esAbility[type].g_iWhirlHitMode);
	g_esCache[tank].g_iWhirlMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWhirlMessage, g_esAbility[type].g_iWhirlMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected)
		{
			SetClientViewEntity(iSurvivor, iSurvivor);
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
			vRemoveWhirl(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iWhirlAbility == 1)
	{
		vWhirlAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iWhirlAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vWhirlAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "WhirlHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveWhirl(tank);
}

static void vRemoveWhirl(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
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

static void vReset2(int survivor, int tank, int camera, int messages)
{
	vStopWhirl(survivor, camera);

	SetClientViewEntity(survivor, survivor);

	if (g_esCache[tank].g_iWhirlMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Whirl2", survivor);
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

static void vStopWhirl(int survivor, int camera)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	RemoveEntity(camera);
}

static void vWhirlAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
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
			if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_esCache[tank].g_flWhirlRange)
				{
					vWhirlHit(iSurvivor, tank, g_esCache[tank].g_flWhirlRangeChance, g_esCache[tank].g_iWhirlAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "WhirlHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "WhirlAmmo");
	}
}

static void vWhirlHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
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
				static int iCamera;
				iCamera = CreateEntityByName("env_sprite");
				if (bIsValidEntity(iCamera))
				{
					g_esPlayer[survivor].g_bAffected = true;
					g_esPlayer[survivor].g_iOwner = tank;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
					{
						g_esPlayer[tank].g_iCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "WhirlHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

						g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
						if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WhirlHuman5", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}

					static float flEyePos[3], flAngles[3];
					GetClientEyePosition(survivor, flEyePos);
					GetClientEyeAngles(survivor, flAngles);

					SetEntityModel(iCamera, SPRITE_DOT);
					SetEntityRenderMode(iCamera, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iCamera, 0, 0, 0, 0);
					DispatchSpawn(iCamera);

					TeleportEntity(iCamera, flEyePos, flAngles, NULL_VECTOR);
					TeleportEntity(survivor, NULL_VECTOR, flAngles, NULL_VECTOR);

					vSetEntityParent(iCamera, survivor);
					SetClientViewEntity(survivor, iCamera);

					static int iAxis, iAxisCount, iAxes[3], iFlag;
					iAxisCount = 0;
					for (int iBit = 0; iBit < sizeof(iAxes); iBit++)
					{
						iFlag = (1 << iBit);
						if (!(g_esCache[tank].g_iWhirlAxis & iFlag))
						{
							continue;
						}

						iAxes[iAxisCount] = iFlag;
						iAxisCount++;
					}

					switch (iAxes[GetRandomInt(0, iAxisCount - 1)])
					{
						case 1: iAxis = 0;
						case 2: iAxis = 1;
						case 4: iAxis = 2;
						default: iAxis = GetRandomInt(0, 2);
					}

					DataPack dpWhirl;
					CreateDataTimer(0.1, tTimerWhirl, dpWhirl, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					dpWhirl.WriteCell(EntIndexToEntRef(iCamera));
					dpWhirl.WriteCell(GetClientUserId(survivor));
					dpWhirl.WriteCell(GetClientUserId(tank));
					dpWhirl.WriteCell(g_esPlayer[tank].g_iTankType);
					dpWhirl.WriteCell(messages);
					dpWhirl.WriteCell(enabled);
					dpWhirl.WriteCell(iAxis);
					dpWhirl.WriteCell(GetTime());

					vEffect(survivor, tank, g_esCache[tank].g_iWhirlEffect, flags);

					if (g_esCache[tank].g_iWhirlMessage & messages)
					{
						static char sTankName[33];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Whirl", sTankName, survivor);
					}
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "WhirlHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "WhirlAmmo");
		}
	}
}

public Action tTimerWhirl(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iCamera, iSurvivor;
	iCamera = EntRefToEntIndex(pack.ReadCell());
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iCamera == INVALID_ENT_REFERENCE || !bIsValidEntity(iCamera))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		if (bIsHumanSurvivor(iSurvivor))
		{
			SetClientViewEntity(iSurvivor, iSurvivor);
		}

		return Plugin_Stop;
	}

	if (!bIsHumanSurvivor(iSurvivor))
	{
		vStopWhirl(iSurvivor, iCamera);

		return Plugin_Stop;
	}

	static int iTank, iType, iMessage;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iCamera, iMessage);

		return Plugin_Stop;
	}

	static int iWhirlEnabled, iWhirlAxis, iTime;
	iWhirlEnabled = pack.ReadCell();
	iWhirlAxis = pack.ReadCell();
	iTime = pack.ReadCell();
	if (iWhirlEnabled == 0 || (iTime + g_esCache[iTank].g_iWhirlDuration) < GetTime())
	{
		vReset2(iSurvivor, iTank, iCamera, iMessage);

		return Plugin_Stop;
	}

	static float flAngles[3];
	GetEntPropVector(iCamera, Prop_Send, "m_angRotation", flAngles);
	flAngles[iWhirlAxis] += g_esCache[iTank].g_flWhirlSpeed;
	TeleportEntity(iCamera, NULL_VECTOR, flAngles, NULL_VECTOR);

	return Plugin_Continue;
}