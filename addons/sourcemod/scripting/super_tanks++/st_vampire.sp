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

// Super Tanks++: Vampire Ability
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
	name = "[ST++] Vampire Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains health from hurting survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_VAMPIRE "Vampire Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

float g_flVampireChance[ST_MAXTYPES + 1], g_flVampireChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iVampireAbility[ST_MAXTYPES + 1], g_iVampireAbility2[ST_MAXTYPES + 1], g_iVampireEffect[ST_MAXTYPES + 1], g_iVampireEffect2[ST_MAXTYPES + 1], g_iVampireMessage[ST_MAXTYPES + 1], g_iVampireMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Vampire Ability\" only supports Left 4 Dead 1 & 2.");

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
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_vampire", cmdVampireInfo, "View information about the Vampire ability.");

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
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action cmdVampireInfo(int client, int args)
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
		case false: vVampireMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vVampireMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iVampireMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Vampire Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iVampireMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iVampireAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "VampireDetails");
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vVampireMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "VampireMenu", param1);
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
	menu.AddItem(ST_MENU_VAMPIRE, ST_MENU_VAMPIRE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_VAMPIRE, false))
	{
		vVampireMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
		{
			float flVampireChance = !g_bTankConfig[ST_TankType(attacker)] ? g_flVampireChance[ST_TankType(attacker)] : g_flVampireChance2[ST_TankType(attacker)];
			if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && iVampireAbility(attacker) == 1 && GetRandomFloat(0.1, 100.0) <= flVampireChance && bIsSurvivor(victim))
			{
				if (!ST_TankAllowed(attacker, "5") || (ST_TankAllowed(attacker, "5") && iHumanAbility(attacker) == 1))
				{
					int iDamage = RoundToNearest(damage), iHealth = GetClientHealth(attacker), iNewHealth = iHealth + iDamage,
						iFinalHealth = (iNewHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth;
					SetEntityHealth(attacker, iFinalHealth);

					int iVampireEffect = !g_bTankConfig[ST_TankType(attacker)] ? g_iVampireEffect[ST_TankType(attacker)] : g_iVampireEffect2[ST_TankType(attacker)];
					char sVampireEffect[2];
					IntToString(iVampireEffect, sVampireEffect, sizeof(sVampireEffect));
					vEffect(victim, attacker, sVampireEffect, "1");

					int iVampireMessage = !g_bTankConfig[ST_TankType(attacker)] ? g_iVampireMessage[ST_TankType(attacker)] : g_iVampireMessage2[ST_TankType(attacker)];
					if (iVampireMessage == 1)
					{
						char sTankName[33];
						ST_TankName(attacker, sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Vampire", sTankName, victim);
					}
				}
			}
		}
	}
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iVampireAbility[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Enabled", 0);
					g_iVampireAbility[iIndex] = iClamp(g_iVampireAbility[iIndex], 0, 1);
					g_iVampireEffect[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Effect", 0);
					g_iVampireEffect[iIndex] = iClamp(g_iVampireEffect[iIndex], 0, 1);
					g_iVampireMessage[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Message", 0);
					g_iVampireMessage[iIndex] = iClamp(g_iVampireMessage[iIndex], 0, 1);
					g_flVampireChance[iIndex] = kvSuperTanks.GetFloat("Vampire Ability/Vampire Chance", 33.3);
					g_flVampireChance[iIndex] = flClamp(g_flVampireChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iVampireAbility2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Enabled", g_iVampireAbility[iIndex]);
					g_iVampireAbility2[iIndex] = iClamp(g_iVampireAbility2[iIndex], 0, 1);
					g_iVampireEffect2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Effect", g_iVampireEffect[iIndex]);
					g_iVampireEffect2[iIndex] = iClamp(g_iVampireEffect2[iIndex], 0, 1);
					g_iVampireMessage2[iIndex] = kvSuperTanks.GetNum("Vampire Ability/Ability Message", g_iVampireMessage[iIndex]);
					g_iVampireMessage2[iIndex] = iClamp(g_iVampireMessage2[iIndex], 0, 1);
					g_flVampireChance2[iIndex] = kvSuperTanks.GetFloat("Vampire Ability/Vampire Chance", g_flVampireChance[iIndex]);
					g_flVampireChance2[iIndex] = flClamp(g_flVampireChance2[iIndex], 0.0, 100.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iVampireAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVampireAbility[ST_TankType(tank)] : g_iVampireAbility2[ST_TankType(tank)];
}