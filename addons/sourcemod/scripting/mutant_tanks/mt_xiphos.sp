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

#file "Xiphos Ability v8.79"

public Plugin myinfo =
{
	name = "[MT] Xiphos Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank can steal health from survivors and vice-versa.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Xiphos Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_XIPHOS "Xiphos Ability"

enum struct esPlayer
{
	float g_flXiphosChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iXiphosAbility;
	int g_iXiphosEffect;
	int g_iXiphosMaxHealth;
	int g_iXiphosMessage;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flXiphosChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iXiphosAbility;
	int g_iXiphosEffect;
	int g_iXiphosMaxHealth;
	int g_iXiphosMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flXiphosChance;

	int g_iHumanAbility;
	int g_iRequiresHumans;
	int g_iXiphosAbility;
	int g_iXiphosEffect;
	int g_iXiphosMaxHealth;
	int g_iXiphosMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_xiphos", cmdXiphosInfo, "View information about the Xiphos ability.");

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

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action cmdXiphosInfo(int client, int args)
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
		case false: vXiphosMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vXiphosMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iXiphosMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Xiphos Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iXiphosMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iXiphosAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "XiphosDetails");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vXiphosMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "XiphosMenu", param1);
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
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 2:
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
	menu.AddItem(MT_MENU_XIPHOS, MT_MENU_XIPHOS);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_XIPHOS, false))
	{
		vXiphosMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_XIPHOS, false))
	{
		FormatEx(buffer, size, "%T", "XiphosMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && g_esCache[attacker].g_iXiphosAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[attacker].g_flXiphosChance && bIsSurvivor(victim))
		{
			if (MT_DoesTypeRequireHumans(g_esPlayer[attacker].g_iTankType) || (g_esCache[attacker].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			static char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				if (!MT_IsTankSupported(attacker, MT_CHECK_FAKECLIENT) || g_esCache[attacker].g_iHumanAbility == 1)
				{
					static int iDamage, iHealth, iNewHealth, iFinalHealth;
					iDamage = RoundToNearest(damage);
					iHealth = GetClientHealth(attacker);
					iNewHealth = iHealth + iDamage;
					iFinalHealth = (iNewHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iNewHealth;
					//SetEntityHealth(attacker, iFinalHealth);
					SetEntProp(attacker, Prop_Data, "m_iHealth", iFinalHealth);

					vEffect(victim, attacker, g_esCache[attacker].g_iXiphosEffect, 1);

					if (g_esCache[attacker].g_iXiphosMessage == 1)
					{
						static char sTankName[33];
						MT_GetTankName(attacker, sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Xiphos", sTankName, victim);
					}
				}
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && g_esCache[victim].g_iXiphosAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[victim].g_flXiphosChance && bIsSurvivor(attacker))
		{
			if (MT_DoesTypeRequireHumans(g_esPlayer[victim].g_iTankType) || (g_esCache[victim].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (!MT_IsTankSupported(victim, MT_CHECK_FAKECLIENT) || g_esCache[victim].g_iHumanAbility == 1)
			{
				static int iDamage, iHealth, iNewHealth, iFinalHealth;
				iDamage = RoundToNearest(damage);
				iHealth = GetClientHealth(attacker);
				iNewHealth = iHealth + iDamage;
				iFinalHealth = (iNewHealth > g_esCache[victim].g_iXiphosMaxHealth) ? g_esCache[victim].g_iXiphosMaxHealth : iNewHealth;
				//SetEntityHealth(attacker, iFinalHealth);
				SetEntProp(attacker, Prop_Data, "m_iHealth", iFinalHealth);

				if (g_esCache[victim].g_iXiphosMessage == 1)
				{
					static char sTankName[33];
					MT_GetTankName(victim, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Xiphos2", attacker, sTankName);
				}
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
	list.PushString("xiphosability");
	list2.PushString("xiphos ability");
	list3.PushString("xiphos_ability");
	list4.PushString("xiphos");
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
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iXiphosAbility = 0;
				g_esAbility[iIndex].g_iXiphosEffect = 0;
				g_esAbility[iIndex].g_iXiphosMessage = 0;
				g_esAbility[iIndex].g_flXiphosChance = 33.3;
				g_esAbility[iIndex].g_iXiphosMaxHealth = 100;
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
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iXiphosAbility = 0;
					g_esPlayer[iPlayer].g_iXiphosEffect = 0;
					g_esPlayer[iPlayer].g_iXiphosMessage = 0;
					g_esPlayer[iPlayer].g_flXiphosChance = 0.0;
					g_esPlayer[iPlayer].g_iXiphosMaxHealth = 0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 1);
		g_esPlayer[admin].g_iXiphosAbility = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iXiphosAbility, value, 0, 1);
		g_esPlayer[admin].g_iXiphosEffect = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iXiphosEffect, value, 0, 1);
		g_esPlayer[admin].g_iXiphosMessage = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iXiphosMessage, value, 0, 1);
		g_esPlayer[admin].g_flXiphosChance = flGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "XiphosChance", "Xiphos Chance", "Xiphos_Chance", "chance", g_esPlayer[admin].g_flXiphosChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iXiphosMaxHealth = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "XiphosMaxHealth", "Xiphos Max Health", "Xiphos_Max_Health", "maxhealth", g_esPlayer[admin].g_iXiphosMaxHealth, value, 1, MT_MAXHEALTH);

		if (StrEqual(subsection, "xiphosability", false) || StrEqual(subsection, "xiphos ability", false) || StrEqual(subsection, "xiphos_ability", false) || StrEqual(subsection, "xiphos", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 1);
		g_esAbility[type].g_iXiphosAbility = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iXiphosAbility, value, 0, 1);
		g_esAbility[type].g_iXiphosEffect = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iXiphosEffect, value, 0, 1);
		g_esAbility[type].g_iXiphosMessage = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iXiphosMessage, value, 0, 1);
		g_esAbility[type].g_flXiphosChance = flGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "XiphosChance", "Xiphos Chance", "Xiphos_Chance", "chance", g_esAbility[type].g_flXiphosChance, value, 0.0, 100.0);
		g_esAbility[type].g_iXiphosMaxHealth = iGetKeyValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "XiphosMaxHealth", "Xiphos Max Health", "Xiphos_Max_Health", "maxhealth", g_esAbility[type].g_iXiphosMaxHealth, value, 1, MT_MAXHEALTH);

		if (StrEqual(subsection, "xiphosability", false) || StrEqual(subsection, "xiphos ability", false) || StrEqual(subsection, "xiphos_ability", false) || StrEqual(subsection, "xiphos", false))
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
	g_esCache[tank].g_flXiphosChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flXiphosChance, g_esAbility[type].g_flXiphosChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iXiphosAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iXiphosAbility, g_esAbility[type].g_iXiphosAbility);
	g_esCache[tank].g_iXiphosEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iXiphosEffect, g_esAbility[type].g_iXiphosEffect);
	g_esCache[tank].g_iXiphosMaxHealth = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iXiphosMaxHealth, g_esAbility[type].g_iXiphosMaxHealth);
	g_esCache[tank].g_iXiphosMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iXiphosMessage, g_esAbility[type].g_iXiphosMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}