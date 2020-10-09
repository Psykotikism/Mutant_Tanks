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

#file "Blind Ability v8.79"

public Plugin myinfo =
{
	name = "[MT] Blind Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank blinds survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Blind Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_GROAN "ambient/random_amb_sounds/randbridgegroan_03.wav"

#define MT_MENU_BLIND "Blind Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flBlindChance;
	float g_flBlindDuration;
	float g_flBlindRange;
	float g_flBlindRangeChance;

	int g_iAccessFlags;
	int g_iBlindAbility;
	int g_iBlindEffect;
	int g_iBlindHit;
	int g_iBlindHitMode;
	int g_iBlindIntensity;
	int g_iBlindMessage;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flBlindChance;
	float g_flBlindDuration;
	float g_flBlindRange;
	float g_flBlindRangeChance;

	int g_iAccessFlags;
	int g_iBlindAbility;
	int g_iBlindEffect;
	int g_iBlindHit;
	int g_iBlindHitMode;
	int g_iBlindIntensity;
	int g_iBlindMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flBlindChance;
	float g_flBlindDuration;
	float g_flBlindRange;
	float g_flBlindRangeChance;

	int g_iBlindAbility;
	int g_iBlindEffect;
	int g_iBlindHit;
	int g_iBlindHitMode;
	int g_iBlindIntensity;
	int g_iBlindMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
}

esCache g_esCache[MAXPLAYERS + 1];

UserMsg g_umFadeUserMsgId;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_blind", cmdBlindInfo, "View information about the Blind ability.");

	g_umFadeUserMsgId = GetUserMessageId("Fade");

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
	PrecacheSound(SOUND_GROAN, true);

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

public Action cmdBlindInfo(int client, int args)
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
		case false: vBlindMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vBlindMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iBlindMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Blind Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iBlindMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iBlindAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "BlindDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esCache[param1].g_flBlindDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vBlindMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "BlindMenu", param1);
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
	menu.AddItem(MT_MENU_BLIND, MT_MENU_BLIND);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_BLIND, false))
	{
		vBlindMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_BLIND, false))
	{
		FormatEx(buffer, size, "%T", "BlindMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iBlindHitMode == 0 || g_esCache[attacker].g_iBlindHitMode == 1) && bIsHumanSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBlindHit(victim, attacker, g_esCache[attacker].g_flBlindChance, g_esCache[attacker].g_iBlindHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iBlindHitMode == 0 || g_esCache[victim].g_iBlindHitMode == 2) && bIsHumanSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBlindHit(attacker, victim, g_esCache[victim].g_flBlindChance, g_esCache[victim].g_iBlindHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("blindability");
	list2.PushString("blind ability");
	list3.PushString("blind_ability");
	list4.PushString("blind");
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
				g_esAbility[iIndex].g_iBlindAbility = 0;
				g_esAbility[iIndex].g_iBlindEffect = 0;
				g_esAbility[iIndex].g_iBlindMessage = 0;
				g_esAbility[iIndex].g_flBlindChance = 33.3;
				g_esAbility[iIndex].g_flBlindDuration = 5.0;
				g_esAbility[iIndex].g_iBlindHit = 0;
				g_esAbility[iIndex].g_iBlindHitMode = 0;
				g_esAbility[iIndex].g_iBlindIntensity = 255;
				g_esAbility[iIndex].g_flBlindRange = 150.0;
				g_esAbility[iIndex].g_flBlindRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iBlindAbility = 0;
					g_esPlayer[iPlayer].g_iBlindEffect = 0;
					g_esPlayer[iPlayer].g_iBlindMessage = 0;
					g_esPlayer[iPlayer].g_flBlindChance = 0.0;
					g_esPlayer[iPlayer].g_flBlindDuration = 0.0;
					g_esPlayer[iPlayer].g_iBlindHit = 0;
					g_esPlayer[iPlayer].g_iBlindHitMode = 0;
					g_esPlayer[iPlayer].g_iBlindIntensity = 0;
					g_esPlayer[iPlayer].g_flBlindRange = 0.0;
					g_esPlayer[iPlayer].g_flBlindRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iBlindAbility = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iBlindAbility, value, 0, 1);
		g_esPlayer[admin].g_iBlindEffect = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iBlindEffect, value, 0, 7);
		g_esPlayer[admin].g_iBlindMessage = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iBlindMessage, value, 0, 3);
		g_esPlayer[admin].g_flBlindChance = flGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindChance", "Blind Chance", "Blind_Chance", "chance", g_esPlayer[admin].g_flBlindChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flBlindDuration = flGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindDuration", "Blind Duration", "Blind_Duration", "duration", g_esPlayer[admin].g_flBlindDuration, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iBlindHit = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindHit", "Blind Hit", "Blind_Hit", "hit", g_esPlayer[admin].g_iBlindHit, value, 0, 1);
		g_esPlayer[admin].g_iBlindHitMode = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindHitMode", "Blind Hit Mode", "Blind_Hit_Mode", "hitmode", g_esPlayer[admin].g_iBlindHitMode, value, 0, 2);
		g_esPlayer[admin].g_iBlindIntensity = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindIntensity", "Blind Intensity", "Blind_Intensity", "intensity", g_esPlayer[admin].g_iBlindIntensity, value, 0, 255);
		g_esPlayer[admin].g_flBlindRange = flGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindRange", "Blind Range", "Blind_Range", "range", g_esPlayer[admin].g_flBlindRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flBlindRangeChance = flGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindRangeChance", "Blind Range Chance", "Blind_Range_Chance", "rangechance", g_esPlayer[admin].g_flBlindRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "blindability", false) || StrEqual(subsection, "blind ability", false) || StrEqual(subsection, "blind_ability", false) || StrEqual(subsection, "blind", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iBlindAbility = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iBlindAbility, value, 0, 1);
		g_esAbility[type].g_iBlindEffect = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iBlindEffect, value, 0, 7);
		g_esAbility[type].g_iBlindMessage = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iBlindMessage, value, 0, 3);
		g_esAbility[type].g_flBlindChance = flGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindChance", "Blind Chance", "Blind_Chance", "chance", g_esAbility[type].g_flBlindChance, value, 0.0, 100.0);
		g_esAbility[type].g_flBlindDuration = flGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindDuration", "Blind Duration", "Blind_Duration", "duration", g_esAbility[type].g_flBlindDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iBlindHit = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindHit", "Blind Hit", "Blind_Hit", "hit", g_esAbility[type].g_iBlindHit, value, 0, 1);
		g_esAbility[type].g_iBlindHitMode = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindHitMode", "Blind Hit Mode", "Blind_Hit_Mode", "hitmode", g_esAbility[type].g_iBlindHitMode, value, 0, 2);
		g_esAbility[type].g_iBlindIntensity = iGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindIntensity", "Blind Intensity", "Blind_Intensity", "intensity", g_esAbility[type].g_iBlindIntensity, value, 0, 255);
		g_esAbility[type].g_flBlindRange = flGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindRange", "Blind Range", "Blind_Range", "range", g_esAbility[type].g_flBlindRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flBlindRangeChance = flGetKeyValue(subsection, "blindability", "blind ability", "blind_ability", "blind", key, "BlindRangeChance", "Blind Range Chance", "Blind_Range_Chance", "rangechance", g_esAbility[type].g_flBlindRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "blindability", false) || StrEqual(subsection, "blind ability", false) || StrEqual(subsection, "blind_ability", false) || StrEqual(subsection, "blind", false))
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
	g_esCache[tank].g_flBlindChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBlindChance, g_esAbility[type].g_flBlindChance);
	g_esCache[tank].g_flBlindDuration = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBlindDuration, g_esAbility[type].g_flBlindDuration);
	g_esCache[tank].g_flBlindRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBlindRange, g_esAbility[type].g_flBlindRange);
	g_esCache[tank].g_flBlindRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBlindRangeChance, g_esAbility[type].g_flBlindRangeChance);
	g_esCache[tank].g_iBlindAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBlindAbility, g_esAbility[type].g_iBlindAbility);
	g_esCache[tank].g_iBlindEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBlindEffect, g_esAbility[type].g_iBlindEffect);
	g_esCache[tank].g_iBlindHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBlindHit, g_esAbility[type].g_iBlindHit);
	g_esCache[tank].g_iBlindHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBlindHitMode, g_esAbility[type].g_iBlindHitMode);
	g_esCache[tank].g_iBlindIntensity = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBlindIntensity, g_esAbility[type].g_iBlindIntensity);
	g_esCache[tank].g_iBlindMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBlindMessage, g_esAbility[type].g_iBlindMessage);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
		{
			vRemoveBlind(iTank);
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
			vRemoveBlind(iTank);
		}
	}

	if (StrEqual(name, "player_spawn"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsHumanSurvivor(iSurvivor))
		{
			vBlind(iSurvivor, 0);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iBlindAbility == 1)
	{
		vBlindAbility(tank);
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
			if (g_esCache[tank].g_iBlindAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vBlindAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "BlindHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveBlind(tank);
}

static void vBlind(int survivor, int intensity)
{
	static int iTargets[2], iFlags, iColor[4] = {0, 0, 0, 0};
	iTargets[0] = survivor;
	iFlags = intensity == 0 ? (0x0001|0x0010) : (0x0002|0x0008);
	iColor[3] = intensity;

	static Handle hTarget;
	hTarget = StartMessageEx(g_umFadeUserMsgId, iTargets, 1);

	switch (GetUserMessageType() == UM_Protobuf)
	{
		case true:
		{
			static Protobuf pbSet;
			pbSet = UserMessageToProtobuf(hTarget);
			pbSet.SetInt("duration", 1536);
			pbSet.SetInt("hold_time", 1536);
			pbSet.SetInt("flags", iFlags);
			pbSet.SetColor("clr", iColor);
		}
		case false:
		{
			static BfWrite bfWrite;
			bfWrite = UserMessageToBfWrite(hTarget);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(iFlags);

			for (int iPos = 0; iPos < sizeof(iColor); iPos++)
			{
				bfWrite.WriteByte(iColor[iPos]);
			}
		}
	}

	EndMessage();
}

static void vBlindAbility(int tank)
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
				if (flDistance <= g_esCache[tank].g_flBlindRange)
				{
					vBlindHit(iSurvivor, tank, g_esCache[tank].g_flBlindRangeChance, g_esCache[tank].g_iBlindAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "BlindHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "BlindAmmo");
	}
}

static void vBlindHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsHumanSurvivor(survivor))
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "BlindHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "BlindHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static int iSurvivorId, iTankId;
				iSurvivorId = GetClientUserId(survivor);
				iTankId = GetClientUserId(tank);

				DataPack dpBlind;
				CreateDataTimer(1.0, tTimerBlind, dpBlind, TIMER_FLAG_NO_MAPCHANGE);
				dpBlind.WriteCell(iSurvivorId);
				dpBlind.WriteCell(iTankId);
				dpBlind.WriteCell(g_esPlayer[tank].g_iTankType);
				dpBlind.WriteCell(enabled);

				DataPack dpStopBlind;
				CreateDataTimer(g_esCache[tank].g_flBlindDuration + 1.0, tTimerStopBlind, dpStopBlind, TIMER_FLAG_NO_MAPCHANGE);
				dpStopBlind.WriteCell(iSurvivorId);
				dpStopBlind.WriteCell(iTankId);
				dpStopBlind.WriteCell(messages);

				vEffect(survivor, tank, g_esCache[tank].g_iBlindEffect, flags);
				EmitSoundToAll(SOUND_GROAN, survivor);

				if (g_esCache[tank].g_iBlindMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Blind", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "BlindHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "BlindAmmo");
		}
	}
}

static void vRemoveBlind(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			vBlind(iSurvivor, 0);

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
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

public Action tTimerBlind(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsHumanSurvivor(iSurvivor) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	static int iTank, iType, iBlindEnabled;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iBlindEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || !MT_HasAdminAccess(iTank) || !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || iBlindEnabled == 0)
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	vBlind(iSurvivor, g_esCache[iTank].g_iBlindIntensity);

	return Plugin_Continue;
}

public Action tTimerStopBlind(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor))
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

		vBlind(iSurvivor, 0);

		return Plugin_Stop;
	}

	g_esPlayer[iSurvivor].g_bAffected = false;
	g_esPlayer[iSurvivor].g_iOwner = 0;

	vBlind(iSurvivor, 0);

	int iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iBlindMessage & iMessage)
	{
		MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Blind2", iSurvivor);
	}

	return Plugin_Continue;
}