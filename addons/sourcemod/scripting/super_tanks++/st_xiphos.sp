/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2019  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <sdkhooks>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Xiphos Ability",
	author = ST_AUTHOR,
	description = "The Super Tank can steal health from survivors and vice-versa.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Xiphos Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_XIPHOS "Xiphos Ability"

bool g_bCloneInstalled;

float g_flXiphosChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iXiphosAbility[ST_MAXTYPES + 1], g_iXiphosEffect[ST_MAXTYPES + 1], g_iXiphosMaxHealth[ST_MAXTYPES + 1], g_iXiphosMessage[ST_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_xiphos", cmdXiphosInfo, "View information about the Xiphos ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (!ST_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iXiphosAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "XiphosDetails");
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vXiphosMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "XiphosMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];
			switch (param2)
			{
				case 0:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public void ST_OnDisplayMenu(Menu menu)
{
	menu.AddItem(ST_MENU_XIPHOS, ST_MENU_XIPHOS);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_XIPHOS, false))
	{
		vXiphosMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && g_iXiphosAbility[ST_GetTankType(attacker)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flXiphosChance[ST_GetTankType(attacker)] && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				if (!ST_IsTankSupported(attacker, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(attacker)] == 1)
				{
					int iDamage = RoundToNearest(damage), iHealth = GetClientHealth(attacker), iNewHealth = iHealth + iDamage,
						iFinalHealth = (iNewHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth;
					SetEntityHealth(attacker, iFinalHealth);

					vEffect(victim, attacker, g_iXiphosEffect[ST_GetTankType(attacker)], 1);

					if (g_iXiphosMessage[ST_GetTankType(attacker)] == 1)
					{
						char sTankName[33];
						ST_GetTankName(attacker, ST_GetTankType(attacker), sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Xiphos", sTankName, victim);
					}
				}
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && g_iXiphosAbility[ST_GetTankType(victim)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flXiphosChance[ST_GetTankType(victim)] && bIsSurvivor(attacker))
		{
			if (!ST_IsTankSupported(victim, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(victim)] == 1)
			{
				int iDamage = RoundToNearest(damage), iHealth = GetClientHealth(attacker), iNewHealth = iHealth + iDamage,
					iFinalHealth = (iNewHealth > g_iXiphosMaxHealth[ST_GetTankType(victim)]) ? g_iXiphosMaxHealth[ST_GetTankType(victim)] : iNewHealth;
				SetEntityHealth(attacker, iFinalHealth);

				if (g_iXiphosMessage[ST_GetTankType(victim)] == 1)
				{
					char sTankName[33];
					ST_GetTankName(victim, ST_GetTankType(victim), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Xiphos2", attacker, sTankName);
				}
			}
		}
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iXiphosAbility[iIndex] = 0;
		g_iXiphosEffect[iIndex] = 0;
		g_iXiphosMessage[iIndex] = 0;
		g_flXiphosChance[iIndex] = 33.3;
		g_iXiphosMaxHealth[iIndex] = 100;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 69, bHasAbilities(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos"));
	g_iHumanAbility[type] = iGetValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iXiphosAbility[type] = iGetValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iXiphosAbility[type], value, 0, 0, 1);
	g_iXiphosEffect[type] = iGetValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iXiphosEffect[type], value, 0, 0, 1);
	g_iXiphosMessage[type] = iGetValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iXiphosMessage[type], value, 0, 0, 1);
	g_flXiphosChance[type] = flGetValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "XiphosChance", "Xiphos Chance", "Xiphos_Chance", "chance", main, g_flXiphosChance[type], value, 33.3, 0.0, 100.0);
	g_iXiphosMaxHealth[type] = iGetValue(subsection, "xiphosability", "xiphos ability", "xiphos_ability", "xiphos", key, "XiphosMaxHealth", "Xiphos Max Health", "Xiphos_Max_Health", "maxhealth", main, g_iXiphosMaxHealth[type], value, 100, 1, ST_MAXHEALTH);
}