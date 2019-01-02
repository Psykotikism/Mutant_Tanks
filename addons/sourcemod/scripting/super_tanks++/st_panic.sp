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
	name = "[ST++] Panic Ability",
	author = ST_AUTHOR,
	description = "The Super Tank starts panic events.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_PANIC "Panic Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bPanic[MAXPLAYERS + 1], g_bPanic2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flHumanDuration2[ST_MAXTYPES + 1], g_flPanicChance[ST_MAXTYPES + 1], g_flPanicChance2[ST_MAXTYPES + 1], g_flPanicInterval[ST_MAXTYPES + 1], g_flPanicInterval2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iPanicAbility[ST_MAXTYPES + 1], g_iPanicAbility2[ST_MAXTYPES + 1], g_iPanicCount[MAXPLAYERS + 1], g_iPanicMessage[ST_MAXTYPES + 1], g_iPanicMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Panic Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_panic", cmdPanicInfo, "View information about the Panic ability.");

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
	vRemovePanic(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdPanicInfo(int client, int args)
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
		case false: vPanicMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vPanicMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iPanicMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Panic Ability Information");
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

public int iPanicMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iPanicAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iPanicCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "PanicDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flHumanDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vPanicMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "PanicMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 7:
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
	menu.AddItem(ST_MENU_PANIC, ST_MENU_PANIC);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_PANIC, false))
	{
		vPanicMenu(client, 0);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Panic Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Panic Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Human Duration", 5.0);
					g_flHumanDuration[iIndex] = flClamp(g_flHumanDuration[iIndex], 0.1, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Panic Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iPanicAbility[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", 0);
					g_iPanicAbility[iIndex] = iClamp(g_iPanicAbility[iIndex], 0, 3);
					g_iPanicMessage[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Message", 0);
					g_iPanicMessage[iIndex] = iClamp(g_iPanicMessage[iIndex], 0, 1);
					g_flPanicChance[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Chance", 33.3);
					g_flPanicChance[iIndex] = flClamp(g_flPanicChance[iIndex], 0.0, 100.0);
					g_flPanicInterval[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", 5.0);
					g_flPanicInterval[iIndex] = flClamp(g_flPanicInterval[iIndex], 0.1, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Human Duration", g_flHumanDuration[iIndex]);
					g_flHumanDuration2[iIndex] = flClamp(g_flHumanDuration2[iIndex], 0.1, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iPanicAbility2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", g_iPanicAbility[iIndex]);
					g_iPanicAbility2[iIndex] = iClamp(g_iPanicAbility2[iIndex], 0, 3);
					g_iPanicMessage2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Message", g_iPanicMessage[iIndex]);
					g_iPanicMessage2[iIndex] = iClamp(g_iPanicMessage2[iIndex], 0, 1);
					g_flPanicChance2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Chance", g_flPanicChance[iIndex]);
					g_flPanicChance2[iIndex] = flClamp(g_flPanicChance2[iIndex], 0.0, 100.0);
					g_flPanicInterval2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", g_flPanicInterval[iIndex]);
					g_flPanicInterval2[iIndex] = flClamp(g_flPanicInterval2[iIndex], 0.1, 9999999999.0);
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
			if (ST_CloneAllowed(iTank, g_bCloneInstalled) && iPanicAbility(iTank) == 1 && GetRandomFloat(0.1, 100.0) <= flPanicChance(iTank))
			{
				vCheatCommand(iTank, "director_force_panic_event");
			}

			vRemovePanic(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iPanicAbility(tank) == 1 && !g_bPanic[tank])
	{
		vPanicAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iPanicAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bPanic[tank] && !g_bPanic2[tank])
						{
							vPanicAbility(tank);
						}
						else if (g_bPanic[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "PanicHuman3");
						}
						else if (g_bPanic2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "PanicHuman4");
						}
					}
					case 1:
					{
						if (g_iPanicCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bPanic[tank] && !g_bPanic2[tank])
							{
								g_bPanic[tank] = true;
								g_iPanicCount[tank]++;

								vPanic(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "PanicHuman", g_iPanicCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "PanicAmmo");
						}
					}
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iPanicAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bPanic[tank] && !g_bPanic2[tank])
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemovePanic(tank);
}

static void vPanic(int tank)
{
	float flPanicInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flPanicInterval[ST_TankType(tank)] : g_flPanicInterval2[ST_TankType(tank)];
	DataPack dpPanic;
	CreateDataTimer(flPanicInterval, tTimerPanic, dpPanic, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpPanic.WriteCell(GetClientUserId(tank));
	dpPanic.WriteFloat(GetEngineTime());
}

static void vPanicAbility(int tank)
{
	if (g_iPanicCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= flPanicChance(tank))
		{
			g_bPanic[tank] = true;

			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				g_iPanicCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "PanicHuman", g_iPanicCount[tank], iHumanAmmo(tank));
			}

			vPanic(tank);

			if (iPanicMessage(tank) == 1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Panic", sTankName);
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "PanicHuman2");
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "PanicAmmo");
	}
}

static void vRemovePanic(int tank)
{
	g_bPanic[tank] = false;
	g_bPanic2[tank] = false;
	g_iPanicCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemovePanic(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bPanic[tank] = false;
	g_bPanic2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "PanicHuman5");

	if (g_iPanicCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bPanic2[tank] = false;
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flHumanDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanDuration[ST_TankType(tank)] : g_flHumanDuration2[ST_TankType(tank)];
}

static float flPanicChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flPanicChance[ST_TankType(tank)] : g_flPanicChance2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iHumanMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanMode[ST_TankType(tank)] : g_iHumanMode2[ST_TankType(tank)];
}

static int iPanicAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicAbility[ST_TankType(tank)] : g_iPanicAbility2[ST_TankType(tank)];
}

static int iPanicMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicMessage[ST_TankType(tank)] : g_iPanicMessage2[ST_TankType(tank)];
}

public Action tTimerPanic(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || iPanicAbility(iTank) == 0 || !g_bPanic[iTank])
	{
		g_bPanic[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && (flTime + flHumanDuration(iTank)) < GetEngineTime() && !g_bPanic2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	vCheatCommand(iTank, "director_force_panic_event");

	if (iPanicMessage(iTank) == 1)
	{
		char sTankName[33];
		ST_TankName(iTank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Panic2", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bPanic2[iTank])
	{
		g_bPanic2[iTank] = false;

		return Plugin_Stop;
	}

	g_bPanic2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "PanicHuman6");

	return Plugin_Continue;
}