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

//#file "Quiet Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Quiet Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank silences itself around survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Quiet Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_QUIET "Quiet Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flQuietChance;
	float g_flQuietDuration;
	float g_flQuietRange;
	float g_flQuietRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iOwner;
	int g_iQuietAbility;
	int g_iQuietEffect;
	int g_iQuietHit;
	int g_iQuietHitMode;
	int g_iQuietMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flQuietChance;
	float g_flQuietDuration;
	float g_flQuietRange;
	float g_flQuietRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iQuietAbility;
	int g_iQuietEffect;
	int g_iQuietHit;
	int g_iQuietHitMode;
	int g_iQuietMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flQuietChance;
	float g_flQuietDuration;
	float g_flQuietRange;
	float g_flQuietRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iQuietAbility;
	int g_iQuietEffect;
	int g_iQuietHit;
	int g_iQuietHitMode;
	int g_iQuietMessage;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_quiet", cmdQuietInfo, "View information about the Quiet ability.");

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

	AddNormalSoundHook(SoundHook);
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

	RemoveNormalSoundHook(SoundHook);
}

public Action cmdQuietInfo(int client, int args)
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
		case false: vQuietMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vQuietMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iQuietMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Quiet Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iQuietMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iQuietAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "QuietDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esCache[param1].g_flQuietDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vQuietMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "QuietMenu", param1);
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
	menu.AddItem(MT_MENU_QUIET, MT_MENU_QUIET);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_QUIET, false))
	{
		vQuietMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_QUIET, false))
	{
		FormatEx(buffer, size, "%T", "QuietMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iQuietHitMode == 0 || g_esCache[attacker].g_iQuietHitMode == 1) && bIsHumanSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vQuietHit(victim, attacker, g_esCache[attacker].g_flQuietChance, g_esCache[attacker].g_iQuietHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iQuietHitMode == 0 || g_esCache[victim].g_iQuietHitMode == 2) && bIsHumanSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vQuietHit(attacker, victim, g_esCache[victim].g_flQuietChance, g_esCache[victim].g_iQuietHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public Action SoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (MT_IsCorePluginEnabled() && StrContains(sample, "player/tank", false) != -1)
	{
		for (int iSurvivor = 0; iSurvivor < numClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(clients[iSurvivor], MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[clients[iSurvivor]].g_bAffected)
			{
				for (int iPlayer = iSurvivor; iPlayer < numClients - 1; iPlayer++)
				{
					clients[iPlayer] = clients[iPlayer + 1];
				}

				numClients--;
				iSurvivor--;
			}
		}

		return (numClients > 0) ? Plugin_Changed : Plugin_Stop;
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
	list.PushString("quietability");
	list2.PushString("quiet ability");
	list3.PushString("quiet_ability");
	list4.PushString("quiet");
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
				g_esAbility[iIndex].g_iQuietAbility = 0;
				g_esAbility[iIndex].g_iQuietEffect = 0;
				g_esAbility[iIndex].g_iQuietMessage = 0;
				g_esAbility[iIndex].g_flQuietChance = 33.3;
				g_esAbility[iIndex].g_flQuietDuration = 5.0;
				g_esAbility[iIndex].g_iQuietHit = 0;
				g_esAbility[iIndex].g_iQuietHitMode = 0;
				g_esAbility[iIndex].g_flQuietRange = 150.0;
				g_esAbility[iIndex].g_flQuietRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iQuietAbility = 0;
					g_esPlayer[iPlayer].g_iQuietEffect = 0;
					g_esPlayer[iPlayer].g_iQuietMessage = 0;
					g_esPlayer[iPlayer].g_flQuietChance = 0.0;
					g_esPlayer[iPlayer].g_flQuietDuration = 0.0;
					g_esPlayer[iPlayer].g_iQuietHit = 0;
					g_esPlayer[iPlayer].g_iQuietHitMode = 0;
					g_esPlayer[iPlayer].g_flQuietRange = 0.0;
					g_esPlayer[iPlayer].g_flQuietRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iQuietAbility = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iQuietAbility, value, 0, 1);
		g_esPlayer[admin].g_iQuietEffect = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iQuietEffect, value, 0, 7);
		g_esPlayer[admin].g_iQuietMessage = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iQuietMessage, value, 0, 3);
		g_esPlayer[admin].g_flQuietChance = flGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietChance", "Quiet Chance", "Quiet_Chance", "chance", g_esPlayer[admin].g_flQuietChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flQuietDuration = flGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietDuration", "Quiet Duration", "Quiet_Duration", "duration", g_esPlayer[admin].g_flQuietDuration, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iQuietHit = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietHit", "Quiet Hit", "Quiet_Hit", "hit", g_esPlayer[admin].g_iQuietHit, value, 0, 1);
		g_esPlayer[admin].g_iQuietHitMode = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietHitMode", "Quiet Hit Mode", "Quiet_Hit_Mode", "hitmode", g_esPlayer[admin].g_iQuietHitMode, value, 0, 2);
		g_esPlayer[admin].g_flQuietRange = flGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietRange", "Quiet Range", "Quiet_Range", "range", g_esPlayer[admin].g_flQuietRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flQuietRangeChance = flGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietRangeChance", "Quiet Range Chance", "Quiet_Range_Chance", "rangechance", g_esPlayer[admin].g_flQuietRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "quietability", false) || StrEqual(subsection, "quiet ability", false) || StrEqual(subsection, "quiet_ability", false) || StrEqual(subsection, "quiet", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iQuietAbility = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iQuietAbility, value, 0, 1);
		g_esAbility[type].g_iQuietEffect = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iQuietEffect, value, 0, 7);
		g_esAbility[type].g_iQuietMessage = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iQuietMessage, value, 0, 3);
		g_esAbility[type].g_flQuietChance = flGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietChance", "Quiet Chance", "Quiet_Chance", "chance", g_esAbility[type].g_flQuietChance, value, 0.0, 100.0);
		g_esAbility[type].g_flQuietDuration = flGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietDuration", "Quiet Duration", "Quiet_Duration", "duration", g_esAbility[type].g_flQuietDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iQuietHit = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietHit", "Quiet Hit", "Quiet_Hit", "hit", g_esAbility[type].g_iQuietHit, value, 0, 1);
		g_esAbility[type].g_iQuietHitMode = iGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietHitMode", "Quiet Hit Mode", "Quiet_Hit_Mode", "hitmode", g_esAbility[type].g_iQuietHitMode, value, 0, 2);
		g_esAbility[type].g_flQuietRange = flGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietRange", "Quiet Range", "Quiet_Range", "range", g_esAbility[type].g_flQuietRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flQuietRangeChance = flGetKeyValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietRangeChance", "Quiet Range Chance", "Quiet_Range_Chance", "rangechance", g_esAbility[type].g_flQuietRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "quietability", false) || StrEqual(subsection, "quiet ability", false) || StrEqual(subsection, "quiet_ability", false) || StrEqual(subsection, "quiet", false))
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
	g_esCache[tank].g_flQuietChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flQuietChance, g_esAbility[type].g_flQuietChance);
	g_esCache[tank].g_flQuietDuration = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flQuietDuration, g_esAbility[type].g_flQuietDuration);
	g_esCache[tank].g_flQuietRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flQuietRange, g_esAbility[type].g_flQuietRange);
	g_esCache[tank].g_flQuietRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flQuietRangeChance, g_esAbility[type].g_flQuietRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iQuietAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iQuietAbility, g_esAbility[type].g_iQuietAbility);
	g_esCache[tank].g_iQuietEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iQuietEffect, g_esAbility[type].g_iQuietEffect);
	g_esCache[tank].g_iQuietHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iQuietHit, g_esAbility[type].g_iQuietHit);
	g_esCache[tank].g_iQuietHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iQuietHitMode, g_esAbility[type].g_iQuietHitMode);
	g_esCache[tank].g_iQuietMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iQuietMessage, g_esAbility[type].g_iQuietMessage);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveQuiet(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iQuietAbility == 1)
	{
		vQuietAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iQuietAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vQuietAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "QuietHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveQuiet(tank);
}

static void vQuietAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
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
				if (flDistance <= g_esCache[tank].g_flQuietRange)
				{
					vQuietHit(iSurvivor, tank, g_esCache[tank].g_flQuietRangeChance, g_esCache[tank].g_iQuietAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "QuietHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "QuietAmmo");
	}
}

static void vQuietHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "QuietHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "QuietHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				DataPack dpStopQuiet;
				CreateDataTimer(g_esCache[tank].g_flQuietDuration, tTimerStopQuiet, dpStopQuiet, TIMER_FLAG_NO_MAPCHANGE);
				dpStopQuiet.WriteCell(GetClientUserId(survivor));
				dpStopQuiet.WriteCell(GetClientUserId(tank));
				dpStopQuiet.WriteCell(messages);

				vEffect(survivor, tank, g_esCache[tank].g_iQuietEffect, flags);

				if (g_esCache[tank].g_iQuietMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Quiet", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "QuietHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "QuietAmmo");
		}
	}
}

static void vRemoveQuiet(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
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

public Action tTimerStopQuiet(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	g_esPlayer[iSurvivor].g_bAffected = false;
	g_esPlayer[iSurvivor].g_iOwner = 0;

	int iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iQuietMessage & iMessage)
	{
		char sTankName[33];
		MT_GetTankName(iTank, sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Quiet2", sTankName, iSurvivor);
	}

	return Plugin_Continue;
}