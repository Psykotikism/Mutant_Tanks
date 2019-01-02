/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
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
	name = "[ST++] Hit Ability",
	author = ST_AUTHOR,
	description = "The Super Tank only takes damage in certain parts of its body.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_HIT "Hit Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

float g_flHitDamageMultiplier[ST_MAXTYPES + 1], g_flHitDamageMultiplier2[ST_MAXTYPES + 1];

int g_iHitAbility[ST_MAXTYPES + 1], g_iHitAbility2[ST_MAXTYPES + 1], g_iHitGroup[ST_MAXTYPES + 1], g_iHitGroup2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Hit Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

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

	RegConsoleCmd("sm_st_hit", cmdHitInfo, "View information about the Hit ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, "24"))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, TraceAttack);
}

public Action cmdHitInfo(int client, int args)
{
	if (!ST_PluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, "0245"))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
		case false: vHitMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vHitMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iHitMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Hit Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iHitMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHitAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "HitDetails");
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vHitMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "HitMenu", param1);
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
	menu.AddItem(ST_MENU_HIT, ST_MENU_HIT);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_HIT, false))
	{
		vHitMenu(client, 0);
	}
}

public Action TraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && iHitAbility(victim) == 1 && bIsSurvivor(attacker))
		{
			int iHitGroup = !g_bTankConfig[ST_TankType(victim)] ? g_iHitGroup[ST_TankType(victim)] : g_iHitGroup2[ST_TankType(victim)];
			if (hitgroup == iHitGroup)
			{
				float flHitDamageMultiplier = !g_bTankConfig[ST_TankType(victim)] ? g_flHitDamageMultiplier[ST_TankType(victim)] : g_flHitDamageMultiplier2[ST_TankType(victim)];
				damage *= flHitDamageMultiplier;

				return Plugin_Changed;
			}
			else
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%i", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			switch (main)
			{
				case true:
				{
					g_bTankConfig[iIndex] = false;

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Hit Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHitAbility[iIndex] = kvSuperTanks.GetNum("Hit Ability/Ability Enabled", 0);
					g_iHitAbility[iIndex] = iClamp(g_iHitAbility[iIndex], 0, 1);
					g_flHitDamageMultiplier[iIndex] = kvSuperTanks.GetFloat("Hit Ability/Hit Damage Multiplier", 1.5);
					g_flHitDamageMultiplier[iIndex] = flClamp(g_flHitDamageMultiplier[iIndex], 1.0, 9999999999.0);
					g_iHitGroup[iIndex] = kvSuperTanks.GetNum("Hit Ability/Hit Group", 1);
					g_iHitGroup[iIndex] = iClamp(g_iHitGroup[iIndex], 1, 7);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Hit Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHitAbility2[iIndex] = kvSuperTanks.GetNum("Hit Ability/Ability Enabled", g_iHitAbility[iIndex]);
					g_iHitAbility2[iIndex] = iClamp(g_iHitAbility2[iIndex], 0, 1);
					g_flHitDamageMultiplier2[iIndex] = kvSuperTanks.GetFloat("Hit Ability/Hit Damage Multiplier", g_flHitDamageMultiplier[iIndex]);
					g_flHitDamageMultiplier2[iIndex] = flClamp(g_flHitDamageMultiplier2[iIndex], 1.0, 9999999999.0);
					g_iHitGroup2[iIndex] = kvSuperTanks.GetNum("Hit Ability/Hit Group", g_iHitGroup[iIndex]);
					g_iHitGroup2[iIndex] = iClamp(g_iHitGroup2[iIndex], 1, 7);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

static int iHitAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHitAbility[ST_TankType(tank)] : g_iHitAbility2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}