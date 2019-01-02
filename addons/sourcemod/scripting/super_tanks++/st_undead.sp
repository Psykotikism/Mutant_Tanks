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
	name = "[ST++] Undead Ability",
	author = ST_AUTHOR,
	description = "The Super Tank cannot die.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_UNDEAD "Undead Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bUndead[MAXPLAYERS + 1], g_bUndead2[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flUndeadChance[ST_MAXTYPES + 1], g_flUndeadChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iUndeadAbility[ST_MAXTYPES + 1], g_iUndeadAbility2[ST_MAXTYPES + 1], g_iUndeadAmount[ST_MAXTYPES + 1], g_iUndeadAmount2[ST_MAXTYPES + 1], g_iUndeadCount[MAXPLAYERS + 1], g_iUndeadCount2[MAXPLAYERS + 1], g_iUndeadHealth[MAXPLAYERS + 1], g_iUndeadMessage[ST_MAXTYPES + 1], g_iUndeadMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Undead Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_undead", cmdUndeadInfo, "View information about the Undead ability.");

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

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveUndead(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdUndeadInfo(int client, int args)
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
		case false: vUndeadMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vUndeadMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iUndeadMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Undead Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iUndeadMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iUndeadAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iUndeadCount2[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "UndeadDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vUndeadMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "UndeadMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
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
	menu.AddItem(ST_MENU_UNDEAD, ST_MENU_UNDEAD);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_UNDEAD, false))
	{
		vUndeadMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && g_bUndead[victim])
		{
			if (GetClientHealth(victim) <= damage)
			{
				damage = 0.0;
				SetEntityHealth(victim, g_iUndeadHealth[victim]);

				if (ST_TankAllowed(victim, "5") && iHumanAbility(victim) == 1 && !g_bUndead2[victim])
				{
					g_bUndead[victim] = false;
					g_bUndead2[victim] = true;

					ST_PrintToChat(victim, "%s %t", ST_TAG3, "UndeadHuman5");

					if (g_iUndeadCount2[victim] < iHumanAmmo(victim) && iHumanAmmo(victim) > 0)
					{
						CreateTimer(flHumanCooldown(victim), tTimerResetCooldown, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bUndead2[victim] = false;
					}
				}

				if (iUndeadMessage(victim) == 1)
				{
					char sTankName[33];
					ST_TankName(victim, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Undead2", sTankName);
				}
			}

			return Plugin_Changed;
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Undead Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Undead Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Undead Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iUndeadAbility[iIndex] = kvSuperTanks.GetNum("Undead Ability/Ability Enabled", 0);
					g_iUndeadAbility[iIndex] = iClamp(g_iUndeadAbility[iIndex], 0, 1);
					g_iUndeadMessage[iIndex] = kvSuperTanks.GetNum("Undead Ability/Ability Message", 0);
					g_iUndeadMessage[iIndex] = iClamp(g_iUndeadMessage[iIndex], 0, 1);
					g_iUndeadAmount[iIndex] = kvSuperTanks.GetNum("Undead Ability/Undead Amount", 1);
					g_iUndeadAmount[iIndex] = iClamp(g_iUndeadAmount[iIndex], 1, 9999999999);
					g_flUndeadChance[iIndex] = kvSuperTanks.GetFloat("Undead Ability/Undead Chance", 33.3);
					g_flUndeadChance[iIndex] = flClamp(g_flUndeadChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Undead Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Undead Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Undead Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iUndeadAbility2[iIndex] = kvSuperTanks.GetNum("Undead Ability/Ability Enabled", g_iUndeadAbility[iIndex]);
					g_iUndeadAbility2[iIndex] = iClamp(g_iUndeadAbility2[iIndex], 0, 1);
					g_iUndeadMessage2[iIndex] = kvSuperTanks.GetNum("Undead Ability/Ability Message", g_iUndeadMessage[iIndex]);
					g_iUndeadMessage2[iIndex] = iClamp(g_iUndeadMessage2[iIndex], 0, 1);
					g_iUndeadAmount2[iIndex] = kvSuperTanks.GetNum("Undead Ability/Undead Amount", g_iUndeadAmount[iIndex]);
					g_iUndeadAmount2[iIndex] = iClamp(g_iUndeadAmount2[iIndex], 1, 9999999999);
					g_flUndeadChance2[iIndex] = kvSuperTanks.GetFloat("Undead Ability/Undead Chance", g_flUndeadChance[iIndex]);
					g_flUndeadChance2[iIndex] = flClamp(g_flUndeadChance2[iIndex], 0.0, 100.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024"))
		{
			vRemoveUndead(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iUndeadAbility(tank) == 1 && !g_bUndead[tank])
	{
		vUndeadAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY == ST_SPECIAL_KEY)
		{
			if (iUndeadAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bUndead[tank] && !g_bUndead2[tank])
				{
					vUndeadAbility(tank);
				}
				else if (g_bUndead[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "UndeadHuman3");
				}
				else if (g_bUndead2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "UndeadHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveUndead(tank);
}

public void ST_OnPreset(int tank)
{
	if (ST_TankAllowed(tank))
	{
		g_iUndeadHealth[tank] = GetClientHealth(tank);
	}
}

static void vRemoveUndead(int tank)
{
	g_bUndead[tank] = false;
	g_bUndead2[tank] = false;
	g_iUndeadCount[tank] = 0;
	g_iUndeadCount2[tank] = 0;
	g_iUndeadHealth[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveUndead(iPlayer);
		}
	}
}

static void vUndeadAbility(int tank)
{
	int iUndeadAmount = !g_bTankConfig[ST_TankType(tank)] ? g_iUndeadAmount[ST_TankType(tank)] : g_iUndeadAmount2[ST_TankType(tank)];
	if (g_iUndeadCount[tank] < iUndeadAmount && g_iUndeadCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flUndeadChance = !g_bTankConfig[ST_TankType(tank)] ? g_flUndeadChance[ST_TankType(tank)] : g_flUndeadChance2[ST_TankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flUndeadChance)
		{
			g_bUndead[tank] = true;
			g_iUndeadCount[tank]++;

			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				g_iUndeadCount2[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "UndeadHuman", g_iUndeadCount2[tank], iHumanAmmo(tank));
			}

			if (iUndeadMessage(tank) == 1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Undead", sTankName);
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "UndeadHuman2");
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "UndeadAmmo");
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iUndeadAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iUndeadAbility[ST_TankType(tank)] : g_iUndeadAbility2[ST_TankType(tank)];
}

static int iUndeadMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iUndeadMessage[ST_TankType(tank)] : g_iUndeadMessage2[ST_TankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bUndead2[iTank])
	{
		g_bUndead2[iTank] = false;

		return Plugin_Stop;
	}

	g_bUndead2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "UndeadHuman6");

	return Plugin_Continue;
}