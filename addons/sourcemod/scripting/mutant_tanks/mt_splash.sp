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
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

//#file "Splash Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Splash Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank constantly deals splash damage to nearby survivors.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Splash Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_SPLASH "Splash Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flSplashChance;
	float g_flSplashDamage;
	float g_flSplashInterval;
	float g_flSplashRange;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iSplashAbility;
	int g_iSplashMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flSplashChance;
	float g_flSplashDamage;
	float g_flSplashInterval;
	float g_flSplashRange;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iSplashAbility;
	int g_iSplashMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flSplashChance;
	float g_flSplashDamage;
	float g_flSplashInterval;
	float g_flSplashRange;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iSplashAbility;
	int g_iSplashMessage;
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

	RegConsoleCmd("sm_mt_splash", cmdSplashInfo, "View information about the Splash ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveSplash(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveSplash(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdSplashInfo(int client, int args)
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
		case false: vSplashMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vSplashMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iSplashMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Splash Ability Information");
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

public int iSplashMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iSplashAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "SplashDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vSplashMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "SplashMenu", param1);
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
	menu.AddItem(MT_MENU_SPLASH, MT_MENU_SPLASH);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_SPLASH, false))
	{
		vSplashMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_SPLASH, false))
	{
		FormatEx(buffer, size, "%T", "SplashMenu2", client);
	}
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("splashability");
	list2.PushString("splash ability");
	list3.PushString("splash_ability");
	list4.PushString("splash");
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
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iSplashAbility = 0;
				g_esAbility[iIndex].g_iSplashMessage = 0;
				g_esAbility[iIndex].g_flSplashChance = 33.3;
				g_esAbility[iIndex].g_flSplashDamage = 5.0;
				g_esAbility[iIndex].g_flSplashInterval = 5.0;
				g_esAbility[iIndex].g_flSplashRange = 500.0;
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
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iSplashAbility = 0;
					g_esPlayer[iPlayer].g_iSplashMessage = 0;
					g_esPlayer[iPlayer].g_flSplashChance = 0.0;
					g_esPlayer[iPlayer].g_flSplashDamage = 0.0;
					g_esPlayer[iPlayer].g_flSplashInterval = 0.0;
					g_esPlayer[iPlayer].g_flSplashRange = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPlayer[admin].g_iHumanDuration, value, 1, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iSplashAbility = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iSplashAbility, value, 0, 1);
		g_esPlayer[admin].g_iSplashMessage = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iSplashMessage, value, 0, 1);
		g_esPlayer[admin].g_flSplashChance = flGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashChance", "Splash Chance", "Splash_Chance", "chance", g_esPlayer[admin].g_flSplashChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flSplashDamage = flGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashDamage", "Splash Damage", "Splash_Damage", "damage", g_esPlayer[admin].g_flSplashDamage, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flSplashInterval = flGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashInterval", "Splash Interval", "Splash_Interval", "interval", g_esPlayer[admin].g_flSplashInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flSplashRange = flGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashRange", "Splash Range", "Splash_Range", "range", g_esPlayer[admin].g_flSplashRange, value, 1.0, 999999.0);

		if (StrEqual(subsection, "splashability", false) || StrEqual(subsection, "splash ability", false) || StrEqual(subsection, "splash_ability", false) || StrEqual(subsection, "splash", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanDuration = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_iHumanDuration, value, 1, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iSplashAbility = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iSplashAbility, value, 0, 1);
		g_esAbility[type].g_iSplashMessage = iGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iSplashMessage, value, 0, 1);
		g_esAbility[type].g_flSplashChance = flGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashChance", "Splash Chance", "Splash_Chance", "chance", g_esAbility[type].g_flSplashChance, value, 0.0, 100.0);
		g_esAbility[type].g_flSplashDamage = flGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashDamage", "Splash Damage", "Splash_Damage", "damage", g_esAbility[type].g_flSplashDamage, value, 1.0, 999999.0);
		g_esAbility[type].g_flSplashInterval = flGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashInterval", "Splash Interval", "Splash_Interval", "interval", g_esAbility[type].g_flSplashInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flSplashRange = flGetKeyValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashRange", "Splash Range", "Splash_Range", "range", g_esAbility[type].g_flSplashRange, value, 1.0, 999999.0);

		if (StrEqual(subsection, "splashability", false) || StrEqual(subsection, "splash ability", false) || StrEqual(subsection, "splash_ability", false) || StrEqual(subsection, "splash", false))
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
	g_esCache[tank].g_flSplashChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSplashChance, g_esAbility[type].g_flSplashChance);
	g_esCache[tank].g_flSplashDamage = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSplashDamage, g_esAbility[type].g_flSplashDamage);
	g_esCache[tank].g_flSplashInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSplashInterval, g_esAbility[type].g_flSplashInterval);
	g_esCache[tank].g_flSplashRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSplashRange, g_esAbility[type].g_flSplashRange);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanDuration, g_esAbility[type].g_iHumanDuration);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iSplashAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSplashAbility, g_esAbility[type].g_iSplashAbility);
	g_esCache[tank].g_iSplashMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSplashMessage, g_esAbility[type].g_iSplashMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_esCache[iTank].g_iSplashAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[iTank].g_flSplashChance)
		{
			if (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags))
			{
				vSplash(iTank, 0.4, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveSplash(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esCache[tank].g_iSplashAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vSplashAbility(tank);
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

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iSplashAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vSplashAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashHuman4", g_esPlayer[tank].g_iCooldown - iTime);
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

								vSplash(tank, g_esCache[tank].g_flSplashInterval, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashAmmo");
						}
					}
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
				vReset2(tank);
				vReset3(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveSplash(tank);
}

static void vRemoveSplash(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveSplash(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;

	if (g_esCache[tank].g_iSplashMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Splash2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Splash2", LANG_SERVER, sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static void vSplash(int tank, float time, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	DataPack dpSplash;
	CreateDataTimer(time, tTimerSplash, dpSplash, flags);
	dpSplash.WriteCell(GetClientUserId(tank));
	dpSplash.WriteCell(g_esPlayer[tank].g_iTankType);
	dpSplash.WriteCell(GetTime());
}

static void vSplashAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flSplashChance)
		{
			g_esPlayer[tank].g_bActivated = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
			}

			vSplash(tank, g_esCache[tank].g_flSplashInterval, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			if (g_esCache[tank].g_iSplashMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Splash", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Splash", LANG_SERVER, sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SplashAmmo");
	}
}

public Action tTimerSplash(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != g_esPlayer[iTank].g_iTankType || g_esCache[iTank].g_iSplashAbility == 0 || !g_esPlayer[iTank].g_bActivated)
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	static int iTime, iCurrentTime;
	iTime = pack.ReadCell();
	iCurrentTime = GetTime();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (iTime + g_esCache[iTank].g_iHumanDuration) < iCurrentTime && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vReset2(iTank);
		vReset3(iTank);

		return Plugin_Stop;
	}

	static float flTankPos[3];
	GetClientAbsOrigin(iTank, flTankPos);

	static float flSurvivorPos[3], flDistance;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, iTank) && !bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
		{
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);

			flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
			if (flDistance <= g_esCache[iTank].g_flSplashRange)
			{
				vDamageEntity(iSurvivor, iTank, g_esCache[iTank].g_flSplashDamage, "65536");
			}
		}
	}

	return Plugin_Continue;
}