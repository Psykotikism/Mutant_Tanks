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

//#file "Omni Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Omni Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank has omni-level access to other nearby Mutant Tanks' abilities.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Omni Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_OMNI "Omni Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flOmniChance;
	float g_flOmniRange;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iDuration;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iOmniAbility;
	int g_iOmniDuration;
	int g_iOmniMessage;
	int g_iOmniMode;
	int g_iOmniType;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flOmniChance;
	float g_flOmniRange;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iOmniAbility;
	int g_iOmniDuration;
	int g_iOmniMessage;
	int g_iOmniMode;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flOmniChance;
	float g_flOmniRange;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iOmniAbility;
	int g_iOmniDuration;
	int g_iOmniMessage;
	int g_iOmniMode;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

enum struct esOmni
{
	float g_flOmniChance;
	float g_flOmniRange;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iOmniAbility;
	int g_iOmniDuration;
	int g_iOmniMessage;
	int g_iOmniMode;
	int g_iRequiresHumans;
}

esOmni g_esOmni[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_omni", cmdOmniInfo, "View information about the Omni ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveOmni(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveOmni(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdOmniInfo(int client, int args)
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
		case false: vOmniMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vOmniMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iOmniMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Omni Ability Information");
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

public int iOmniMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esOmni[param1].g_iOmniAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esOmni[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esOmni[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esOmni[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esOmni[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "OmniDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esOmni[param1].g_iOmniDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esOmni[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vOmniMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "OmniMenu", param1);
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
	menu.AddItem(MT_MENU_OMNI, MT_MENU_OMNI);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_OMNI, false))
	{
		vOmniMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_OMNI, false))
	{
		FormatEx(buffer, size, "%T", "OmniMenu2", client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(client) || !g_esPlayer[client].g_bActivated || (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && g_esOmni[client].g_iHumanMode == 1) || g_esPlayer[client].g_iDuration == -1)
	{
		return Plugin_Continue;
	}

	static int iTime;
	iTime = GetTime();
	if (g_esPlayer[client].g_iDuration < iTime)
	{
		if (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(client) || bHasAdminAccess(client, g_esOmni[client].g_iAccessFlags, g_esPlayer[client].g_iAccessFlags)) && g_esOmni[client].g_iHumanAbility == 1 && (g_esPlayer[client].g_iCooldown == -1 || g_esPlayer[client].g_iCooldown < iTime))
		{
			vReset3(client);
		}

		vReset2(client);
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
	list.PushString("omniability");
	list2.PushString("omni ability");
	list3.PushString("omni_ability");
	list4.PushString("omni");
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
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iOmniAbility = 0;
				g_esAbility[iIndex].g_iOmniMessage = 0;
				g_esAbility[iIndex].g_flOmniChance = 33.3;
				g_esAbility[iIndex].g_iOmniDuration = 5;
				g_esAbility[iIndex].g_iOmniMode = 0;
				g_esAbility[iIndex].g_flOmniRange = 500.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iOmniAbility = 0;
					g_esPlayer[iPlayer].g_iOmniMessage = 0;
					g_esPlayer[iPlayer].g_flOmniChance = 0.0;
					g_esPlayer[iPlayer].g_iOmniDuration = 0;
					g_esPlayer[iPlayer].g_iOmniMode = 0;
					g_esPlayer[iPlayer].g_flOmniRange = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iOmniAbility = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iOmniAbility, value, 0, 1);
		g_esPlayer[admin].g_iOmniMessage = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iOmniMessage, value, 0, 1);
		g_esPlayer[admin].g_flOmniChance = flGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniChance", "Omni Chance", "Omni_Chance", "chance", g_esPlayer[admin].g_flOmniChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iOmniDuration = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniDuration", "Omni Duration", "Omni_Duration", "duration", g_esPlayer[admin].g_iOmniDuration, value, 1, 999999);
		g_esPlayer[admin].g_iOmniMode = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniMode", "Omni Mode", "Omni_Mode", "mode", g_esPlayer[admin].g_iOmniMode, value, 0, 1);
		g_esPlayer[admin].g_flOmniRange = flGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniRange", "Omni Range", "Omni_Range", "range", g_esPlayer[admin].g_flOmniRange, value, 1.0, 999999.0);

		if (StrEqual(subsection, "omniability", false) || StrEqual(subsection, "omni ability", false) || StrEqual(subsection, "omni_ability", false) || StrEqual(subsection, "omni", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iOmniAbility = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iOmniAbility, value, 0, 1);
		g_esAbility[type].g_iOmniMessage = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iOmniMessage, value, 0, 1);
		g_esAbility[type].g_flOmniChance = flGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniChance", "Omni Chance", "Omni_Chance", "chance", g_esAbility[type].g_flOmniChance, value, 0.0, 100.0);
		g_esAbility[type].g_iOmniDuration = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniDuration", "Omni Duration", "Omni_Duration", "duration", g_esAbility[type].g_iOmniDuration, value, 1, 999999);
		g_esAbility[type].g_iOmniMode = iGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniMode", "Omni Mode", "Omni_Mode", "mode", g_esAbility[type].g_iOmniMode, value, 0, 1);
		g_esAbility[type].g_flOmniRange = flGetKeyValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniRange", "Omni Range", "Omni_Range", "range", g_esAbility[type].g_flOmniRange, value, 1.0, 999999.0);

		if (StrEqual(subsection, "omniability", false) || StrEqual(subsection, "omni ability", false) || StrEqual(subsection, "omni_ability", false) || StrEqual(subsection, "omni", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flOmniChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOmniChance, g_esAbility[type].g_flOmniChance);
	g_esCache[tank].g_flOmniRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOmniRange, g_esAbility[type].g_flOmniRange);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iOmniAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOmniAbility, g_esAbility[type].g_iOmniAbility);
	g_esCache[tank].g_iOmniDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOmniDuration, g_esAbility[type].g_iOmniDuration);
	g_esCache[tank].g_iOmniMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOmniMessage, g_esAbility[type].g_iOmniMessage);
	g_esCache[tank].g_iOmniMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOmniMode, g_esAbility[type].g_iOmniMode);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

static void vCacheOriginalSettings(int tank)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	int iType = (g_esPlayer[tank].g_iOmniType > 0) ? g_esPlayer[tank].g_iOmniType : g_esPlayer[tank].g_iTankType;
	g_esOmni[tank].g_flOmniChance = flGetSettingValue(true, bHuman, g_esPlayer[tank].g_flOmniChance, g_esAbility[iType].g_flOmniChance);
	g_esOmni[tank].g_flOmniRange = flGetSettingValue(true, bHuman, g_esPlayer[tank].g_flOmniRange, g_esAbility[iType].g_flOmniRange);
	g_esOmni[tank].g_iAccessFlags = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iAccessFlags, g_esAbility[iType].g_iAccessFlags);
	g_esOmni[tank].g_iHumanAbility = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[iType].g_iHumanAbility);
	g_esOmni[tank].g_iHumanAmmo = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[iType].g_iHumanAmmo);
	g_esOmni[tank].g_iHumanCooldown = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[iType].g_iHumanCooldown);
	g_esOmni[tank].g_iHumanMode = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[iType].g_iHumanMode);
	g_esOmni[tank].g_iOmniAbility = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iOmniAbility, g_esAbility[iType].g_iOmniAbility);
	g_esOmni[tank].g_iOmniDuration = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iOmniDuration, g_esAbility[iType].g_iOmniDuration);
	g_esOmni[tank].g_iOmniMessage = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iOmniMessage, g_esAbility[iType].g_iOmniMessage);
	g_esOmni[tank].g_iOmniMode = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iOmniMode, g_esAbility[iType].g_iOmniMode);
	g_esOmni[tank].g_iRequiresHumans = iGetSettingValue(true, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[iType].g_iRequiresHumans);
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveOmni(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esOmni[tank].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esOmni[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esOmni[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esOmni[tank].g_iOmniAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vOmniAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_MAIN_KEY)
		{
			if (g_esOmni[tank].g_iOmniAbility == 1 && g_esOmni[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esOmni[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vOmniAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman4", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iCount < g_esOmni[tank].g_iHumanAmmo && g_esOmni[tank].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esPlayer[tank].g_bActivated = true;
								g_esPlayer[tank].g_iCount++;

								vOmni(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman", g_esPlayer[tank].g_iCount, g_esOmni[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniAmmo");
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
			if (g_esOmni[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				vReset2(tank);
				vReset3(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveOmni(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	vCacheOriginalSettings(tank);
}

static void vOmni(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	g_esPlayer[tank].g_iOmniType = g_esPlayer[tank].g_iTankType;
	vCacheOriginalSettings(tank);

	static float flTankPos[3];
	GetClientAbsOrigin(tank, flTankPos);

	static float flTankPos2[3], flDistance;
	static int iTypeCount, iTypes[MT_MAXTYPES + 1];
	iTypeCount = 0;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (MT_IsTankSupported(iTank, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && MT_IsCustomTankSupported(iTank) && iTank != tank)
		{
			GetClientAbsOrigin(iTank, flTankPos2);

			flDistance = GetVectorDistance(flTankPos, flTankPos2);
			if (flDistance <= g_esOmni[tank].g_flOmniRange && g_esCache[iTank].g_iOmniAbility == 0)
			{
				iTypes[iTypeCount + 1] = g_esPlayer[iTank].g_iTankType;
				iTypeCount++;
			}
		}
	}

	if (iTypeCount > 0)
	{
		MT_SetTankType(tank, iTypes[GetRandomInt(1, iTypeCount)], view_as<bool>(g_esOmni[tank].g_iOmniMode));
	}
	else
	{
		static int iTypeCount2, iTypes2[MT_MAXTYPES + 1];
		iTypeCount2 = 0;
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			if (!MT_IsTypeEnabled(iIndex) || !MT_CanTypeSpawn(iIndex) || MT_DoesTypeRequireHumans(iIndex) || g_esPlayer[tank].g_iOmniType == iIndex)
			{
				continue;
			}

			iTypes2[iTypeCount2 + 1] = iIndex;
			iTypeCount2++;
		}

		if (iTypeCount2 > 0)
		{
			MT_SetTankType(tank, iTypes2[GetRandomInt(1, iTypeCount2)], view_as<bool>(g_esOmni[tank].g_iOmniMode));
		}
	}
}

static void vOmniAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flOmniChance)
		{
			g_esPlayer[tank].g_bActivated = true;
			g_esPlayer[tank].g_iDuration = GetTime() + g_esCache[tank].g_iOmniDuration;

			vOmni(tank);

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esOmni[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman", g_esPlayer[tank].g_iCount, g_esOmni[tank].g_iHumanAmmo);
			}

			if (g_esOmni[tank].g_iOmniMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Omni", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Omni", LANG_SERVER, sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniAmmo");
	}
}

static void vRemoveOmni(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iDuration = -1;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iOmniType = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveOmni(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iDuration = -1;

	MT_SetTankType(tank, g_esPlayer[tank].g_iOmniType, view_as<bool>(g_esOmni[tank].g_iOmniMode));
	g_esPlayer[tank].g_iOmniType = 0;

	if (g_esOmni[tank].g_iOmniMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Omni2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Omni2", LANG_SERVER, sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esOmni[tank].g_iHumanAmmo && g_esOmni[tank].g_iHumanAmmo > 0) ? (iTime + g_esOmni[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}