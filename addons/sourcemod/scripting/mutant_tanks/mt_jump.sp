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

#file "Jump Ability v8.79"

public Plugin myinfo =
{
	name = "[MT] Jump Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank jumps periodically or sporadically and makes survivors jump uncontrollably.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Jump Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_JUMP "Jump Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flJumpChance;
	float g_flJumpHeight;
	float g_flJumpInterval;
	float g_flJumpRange;
	float g_flJumpRangeChance;
	float g_flJumpSporadicChance;
	float g_flJumpSporadicHeight;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iCount;
	int g_iCount2;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iJumpAbility;
	int g_iJumpDuration;
	int g_iJumpEffect;
	int g_iJumpHit;
	int g_iJumpHitMode;
	int g_iJumpMessage;
	int g_iJumpMode;
	int g_iOwner;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flJumpChance;
	float g_flJumpHeight;
	float g_flJumpInterval;
	float g_flJumpRange;
	float g_flJumpRangeChance;
	float g_flJumpSporadicChance;
	float g_flJumpSporadicHeight;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iJumpAbility;
	int g_iJumpDuration;
	int g_iJumpEffect;
	int g_iJumpHit;
	int g_iJumpHitMode;
	int g_iJumpMessage;
	int g_iJumpMode;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flJumpChance;
	float g_flJumpHeight;
	float g_flJumpInterval;
	float g_flJumpRange;
	float g_flJumpRangeChance;
	float g_flJumpSporadicChance;
	float g_flJumpSporadicHeight;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iJumpAbility;
	int g_iJumpDuration;
	int g_iJumpEffect;
	int g_iJumpHit;
	int g_iJumpHitMode;
	int g_iJumpMessage;
	int g_iJumpMode;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_jump", cmdJumpInfo, "View information about the Jump ability.");

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

	vReset4(client);
}

public void OnClientDisconnect_Post(int client)
{
	vReset4(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdJumpInfo(int client, int args)
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
		case false: vJumpMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vJumpMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iJumpMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Jump Ability Information");
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

public int iJumpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iJumpAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
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
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "JumpDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iJumpDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vJumpMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "JumpMenu", param1);
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
	menu.AddItem(MT_MENU_JUMP, MT_MENU_JUMP);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_JUMP, false))
	{
		vJumpMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_JUMP, false))
	{
		FormatEx(buffer, size, "%T", "JumpMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iJumpHitMode == 0 || g_esCache[attacker].g_iJumpHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vJumpHit(victim, attacker, g_esCache[attacker].g_flJumpChance, g_esCache[attacker].g_iJumpHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iJumpHitMode == 0 || g_esCache[victim].g_iJumpHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vJumpHit(attacker, victim, g_esCache[victim].g_flJumpChance, g_esCache[victim].g_iJumpHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("jumpability");
	list2.PushString("jump ability");
	list3.PushString("jump_ability");
	list4.PushString("jump");
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
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iJumpAbility = 0;
				g_esAbility[iIndex].g_iJumpEffect = 0;
				g_esAbility[iIndex].g_iJumpMessage = 0;
				g_esAbility[iIndex].g_flJumpChance = 33.3;
				g_esAbility[iIndex].g_iJumpDuration = 5;
				g_esAbility[iIndex].g_flJumpHeight = 300.0;
				g_esAbility[iIndex].g_iJumpHit = 0;
				g_esAbility[iIndex].g_iJumpHitMode = 0;
				g_esAbility[iIndex].g_flJumpInterval = 1.0;
				g_esAbility[iIndex].g_iJumpMode = 0;
				g_esAbility[iIndex].g_flJumpRange = 150.0;
				g_esAbility[iIndex].g_flJumpRangeChance = 15.0;
				g_esAbility[iIndex].g_flJumpSporadicChance = 33.3;
				g_esAbility[iIndex].g_flJumpSporadicHeight = 750.0;
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
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iJumpAbility = 0;
					g_esPlayer[iPlayer].g_iJumpEffect = 0;
					g_esPlayer[iPlayer].g_iJumpMessage = 0;
					g_esPlayer[iPlayer].g_flJumpChance = 0.0;
					g_esPlayer[iPlayer].g_iJumpDuration = 0;
					g_esPlayer[iPlayer].g_flJumpHeight = 0.0;
					g_esPlayer[iPlayer].g_iJumpHit = 0;
					g_esPlayer[iPlayer].g_iJumpHitMode = 0;
					g_esPlayer[iPlayer].g_flJumpInterval = 0.0;
					g_esPlayer[iPlayer].g_iJumpMode = 0;
					g_esPlayer[iPlayer].g_flJumpRange = 0.0;
					g_esPlayer[iPlayer].g_flJumpRangeChance = 0.0;
					g_esPlayer[iPlayer].g_flJumpSporadicChance = 0.0;
					g_esPlayer[iPlayer].g_flJumpSporadicHeight = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iJumpAbility = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iJumpAbility, value, 0, 3);
		g_esPlayer[admin].g_iJumpEffect = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iJumpEffect, value, 0, 7);
		g_esPlayer[admin].g_iJumpMessage = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iJumpMessage, value, 0, 7);
		g_esPlayer[admin].g_flJumpChance = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpChance", "Jump Chance", "Jump_Chance", "chance", g_esPlayer[admin].g_flJumpChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iJumpDuration = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpDuration", "Jump Duration", "Jump_Duration", "duration", g_esPlayer[admin].g_iJumpDuration, value, 1, 999999);
		g_esPlayer[admin].g_flJumpHeight = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHeight", "Jump Height", "Jump_Height", "height", g_esPlayer[admin].g_flJumpHeight, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iJumpHit = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHit", "Jump Hit", "Jump_Hit", "hit", g_esPlayer[admin].g_iJumpHit, value, 0, 1);
		g_esPlayer[admin].g_iJumpHitMode = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHitMode", "Jump Hit Mode", "Jump_Hit_Mode", "hitmode", g_esPlayer[admin].g_iJumpHitMode, value, 0, 2);
		g_esPlayer[admin].g_flJumpInterval = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpInterval", "Jump Interval", "Jump_Interval", "interval", g_esPlayer[admin].g_flJumpInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iJumpMode = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpMode", "Jump Mode", "Jump_Mode", "mode", g_esPlayer[admin].g_iJumpMode, value, 0, 1);
		g_esPlayer[admin].g_flJumpRange = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpRange", "Jump Range", "Jump_Range", "range", g_esPlayer[admin].g_flJumpRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flJumpRangeChance = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpRangeChance", "Jump Range Chance", "Jump_Range_Chance", "rangechance", g_esPlayer[admin].g_flJumpRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flJumpSporadicChance = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpSporadicChance", "Jump Sporadic Chance", "Jump_Sporadic_Chance", "sporadicchance", g_esPlayer[admin].g_flJumpSporadicChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flJumpSporadicHeight = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpSporadicHeight", "Jump Sporadic Height", "Jump_Sporadic_Height", "sporadicheight", g_esPlayer[admin].g_flJumpSporadicHeight, value, 0.1, 999999.0);

		if (StrEqual(subsection, "jumpability", false) || StrEqual(subsection, "jump ability", false) || StrEqual(subsection, "jump_ability", false) || StrEqual(subsection, "jump", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iJumpAbility = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iJumpAbility, value, 0, 3);
		g_esAbility[type].g_iJumpEffect = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iJumpEffect, value, 0, 7);
		g_esAbility[type].g_iJumpMessage = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iJumpMessage, value, 0, 7);
		g_esAbility[type].g_flJumpChance = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpChance", "Jump Chance", "Jump_Chance", "chance", g_esAbility[type].g_flJumpChance, value, 0.0, 100.0);
		g_esAbility[type].g_iJumpDuration = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpDuration", "Jump Duration", "Jump_Duration", "duration", g_esAbility[type].g_iJumpDuration, value, 1, 999999);
		g_esAbility[type].g_flJumpHeight = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHeight", "Jump Height", "Jump_Height", "height", g_esAbility[type].g_flJumpHeight, value, 0.1, 999999.0);
		g_esAbility[type].g_iJumpHit = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHit", "Jump Hit", "Jump_Hit", "hit", g_esAbility[type].g_iJumpHit, value, 0, 1);
		g_esAbility[type].g_iJumpHitMode = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHitMode", "Jump Hit Mode", "Jump_Hit_Mode", "hitmode", g_esAbility[type].g_iJumpHitMode, value, 0, 2);
		g_esAbility[type].g_flJumpInterval = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpInterval", "Jump Interval", "Jump_Interval", "interval", g_esAbility[type].g_flJumpInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_iJumpMode = iGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpMode", "Jump Mode", "Jump_Mode", "mode", g_esAbility[type].g_iJumpMode, value, 0, 1);
		g_esAbility[type].g_flJumpRange = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpRange", "Jump Range", "Jump_Range", "range", g_esAbility[type].g_flJumpRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flJumpRangeChance = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpRangeChance", "Jump Range Chance", "Jump_Range_Chance", "rangechance", g_esAbility[type].g_flJumpRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_flJumpSporadicChance = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpSporadicChance", "Jump Sporadic Chance", "Jump_Sporadic_Chance", "sporadicchance", g_esAbility[type].g_flJumpSporadicChance, value, 0.0, 100.0);
		g_esAbility[type].g_flJumpSporadicHeight = flGetKeyValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpSporadicHeight", "Jump Sporadic Height", "Jump_Sporadic_Height", "sporadicheight", g_esAbility[type].g_flJumpSporadicHeight, value, 0.1, 999999.0);

		if (StrEqual(subsection, "jumpability", false) || StrEqual(subsection, "jump ability", false) || StrEqual(subsection, "jump_ability", false) || StrEqual(subsection, "jump", false))
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
	g_esCache[tank].g_flJumpChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flJumpChance, g_esAbility[type].g_flJumpChance);
	g_esCache[tank].g_flJumpHeight = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flJumpHeight, g_esAbility[type].g_flJumpHeight);
	g_esCache[tank].g_flJumpInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flJumpInterval, g_esAbility[type].g_flJumpInterval);
	g_esCache[tank].g_flJumpRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flJumpRange, g_esAbility[type].g_flJumpRange);
	g_esCache[tank].g_flJumpRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flJumpRangeChance, g_esAbility[type].g_flJumpRangeChance);
	g_esCache[tank].g_flJumpSporadicChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flJumpSporadicChance, g_esAbility[type].g_flJumpSporadicChance);
	g_esCache[tank].g_flJumpSporadicHeight = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flJumpSporadicHeight, g_esAbility[type].g_flJumpSporadicHeight);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iJumpAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iJumpAbility, g_esAbility[type].g_iJumpAbility);
	g_esCache[tank].g_iJumpDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iJumpDuration, g_esAbility[type].g_iJumpDuration);
	g_esCache[tank].g_iJumpEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iJumpEffect, g_esAbility[type].g_iJumpEffect);
	g_esCache[tank].g_iJumpHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iJumpHit, g_esAbility[type].g_iJumpHit);
	g_esCache[tank].g_iJumpHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iJumpHitMode, g_esAbility[type].g_iJumpHitMode);
	g_esCache[tank].g_iJumpMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iJumpMessage, g_esAbility[type].g_iJumpMessage);
	g_esCache[tank].g_iJumpMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iJumpMode, g_esAbility[type].g_iJumpMode);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveJump(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iJumpAbility > 0)
	{
		vJumpAbility(tank, true);
		vJumpAbility(tank, false);
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

		static int iTime;
		iTime = GetTime();
		if (button & MT_MAIN_KEY)
		{
			if ((g_esCache[tank].g_iJumpAbility == 2 || g_esCache[tank].g_iJumpAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vJumpAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman4");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman5", g_esPlayer[tank].g_iCooldown - iTime);
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

								vJump2(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman4");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman5", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SUB_KEY)
		{
			if ((g_esCache[tank].g_iJumpAbility == 1 || g_esCache[tank].g_iJumpAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime)
				{
					case true: vJumpAbility(tank, true);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman6", g_esPlayer[tank].g_iCooldown2 - iTime);
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				vReset3(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveJump(tank);
}

static void vJump(int survivor, int tank)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	static float flVelocity[3];
	GetEntPropVector(survivor, Prop_Data, "m_vecVelocity", flVelocity);
	flVelocity[2] += g_esCache[tank].g_flJumpHeight;

	TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
}

static void vJump2(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
	{
		return;
	}

	static int iTankId, iTime;
	iTankId = GetClientUserId(tank);
	iTime = GetTime();

	switch (g_esCache[tank].g_iJumpMode)
	{
		case 0:
		{
			DataPack dpJump;
			CreateDataTimer(g_esCache[tank].g_flJumpInterval, tTimerJump, dpJump, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpJump.WriteCell(iTankId);
			dpJump.WriteCell(g_esPlayer[tank].g_iTankType);
			dpJump.WriteCell(iTime);
		}
		case 1:
		{
			DataPack dpJump2;
			CreateDataTimer(1.0, tTimerJump2, dpJump2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpJump2.WriteCell(iTankId);
			dpJump2.WriteCell(g_esPlayer[tank].g_iTankType);
			dpJump2.WriteCell(iTime);
		}
	}
}

static void vJumpAbility(int tank, bool main)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esCache[tank].g_iJumpAbility == 1 || g_esCache[tank].g_iJumpAbility == 3)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
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
							if (flDistance <= g_esCache[tank].g_flJumpRange)
							{
								vJumpHit(iSurvivor, tank, g_esCache[tank].g_flJumpRangeChance, g_esCache[tank].g_iJumpAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman7");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo");
				}
			}
		}
		case false:
		{
			if ((g_esCache[tank].g_iJumpAbility == 2 || g_esCache[tank].g_iJumpAbility == 3) && !g_esPlayer[tank].g_bActivated)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bActivated = true;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
					{
						g_esPlayer[tank].g_iCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
					}

					vJump2(tank);

					if (g_esCache[tank].g_iJumpMessage & MT_MESSAGE_SPECIAL)
					{
						static char sTankName[33];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Jump3", sTankName);
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo");
				}
			}
		}
	}
}

static void vJumpHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				g_esPlayer[survivor].g_bAffected = true;
				g_esPlayer[survivor].g_iOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
				{
					g_esPlayer[tank].g_iCount2++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman2", g_esPlayer[tank].g_iCount2, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown2 = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman9", g_esPlayer[tank].g_iCooldown2 - iTime);
					}
				}

				DataPack dpJump3;
				CreateDataTimer(0.25, tTimerJump3, dpJump3, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpJump3.WriteCell(GetClientUserId(survivor));
				dpJump3.WriteCell(GetClientUserId(tank));
				dpJump3.WriteCell(g_esPlayer[tank].g_iTankType);
				dpJump3.WriteCell(messages);
				dpJump3.WriteCell(enabled);
				dpJump3.WriteCell(GetTime());

				vEffect(survivor, tank, g_esCache[tank].g_iJumpEffect, flags);

				if (g_esCache[tank].g_iJumpMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Jump", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo2");
		}
	}
}

static void vRemoveJump(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;
		}
	}

	vReset4(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset4(iPlayer);
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	if (g_esCache[tank].g_iJumpMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Jump2", survivor);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman8", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static void vReset4(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCooldown2 = -1;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCount2 = 0;
}

static float flGetNearestSurvivor(int tank)
{
	static float flDistance;
	if (bIsTank(tank))
	{
		static float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		static float flSurvivorPos[3];
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);

				break;
			}
		}
	}

	return flDistance;
}

public Action tTimerJump(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || (g_esCache[iTank].g_iJumpAbility != 2 && g_esCache[iTank].g_iJumpAbility != 3) || !g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	static int iTime, iCurrentTime;
	iTime = pack.ReadCell();
	iCurrentTime = GetTime();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (iTime + g_esCache[iTank].g_iJumpDuration) < iCurrentTime && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	if (!bIsEntityGrounded(iTank))
	{
		return Plugin_Continue;
	}

	vJump(iTank, iTank);

	return Plugin_Continue;
}

public Action tTimerJump2(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || (g_esCache[iTank].g_iJumpAbility != 2 && g_esCache[iTank].g_iJumpAbility != 3) || !g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	static int iTime, iCurrentTime;
	iTime = pack.ReadCell();
	iCurrentTime = GetTime();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (iTime + g_esCache[iTank].g_iJumpDuration) < iCurrentTime && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	if (GetRandomFloat(0.1, 100.0) > g_esCache[iTank].g_flJumpSporadicChance)
	{
		return Plugin_Continue;
	}

	static float flNearestSurvivor;
	flNearestSurvivor = flGetNearestSurvivor(iTank);
	if (flNearestSurvivor > 100.0 && flNearestSurvivor < 1000.0)
	{
		static float flVelocity[3];
		GetEntPropVector(iTank, Prop_Data, "m_vecVelocity", flVelocity);

		if (flVelocity[0] > 0.0 && flVelocity[0] < 500.0)
		{
			flVelocity[0] += 500.0;
		}
		else if (flVelocity[0] < 0.0 && flVelocity[0] > -500.0)
		{
			flVelocity[0] += -500.0;
		}
		if (flVelocity[1] > 0.0 && flVelocity[1] < 500.0)
		{
			flVelocity[1] += 500.0;
		}
		else if (flVelocity[1] < 0.0 && flVelocity[1] > -500.0)
		{
			flVelocity[1] += -500.0;
		}

		flVelocity[2] += g_esCache[iTank].g_flJumpSporadicHeight;
		TeleportEntity(iTank, NULL_VECTOR, NULL_VECTOR, flVelocity);
	}

	return Plugin_Continue;
}

public Action tTimerJump3(Handle timer, DataPack pack)
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
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static int iJumpEnabled, iTime;
	iJumpEnabled = pack.ReadCell();
	iTime = pack.ReadCell();
	if ((iJumpEnabled != 1 && iJumpEnabled != 3) || (iTime + g_esCache[iTank].g_iJumpDuration) < GetTime())
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	if (!bIsEntityGrounded(iSurvivor))
	{
		return Plugin_Continue;
	}

	vJump(iSurvivor, iTank);

	return Plugin_Continue;
}