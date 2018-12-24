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

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Necro Ability",
	author = ST_AUTHOR,
	description = "The Super Tank resurrects nearby special infected that die.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_NECRO "Necro Ability"

bool g_bCloneInstalled, g_bNecro[MAXPLAYERS + 1], g_bNecro2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flHumanDuration2[ST_MAXTYPES + 1], g_flNecroChance[ST_MAXTYPES + 1], g_flNecroChance2[ST_MAXTYPES + 1], g_flNecroRange[ST_MAXTYPES + 1], g_flNecroRange2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iNecroAbility[ST_MAXTYPES + 1], g_iNecroAbility2[ST_MAXTYPES + 1], g_iNecroCount[MAXPLAYERS + 1], g_iNecroMessage[ST_MAXTYPES + 1], g_iNecroMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Necro Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

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

	RegConsoleCmd("sm_st_necro", cmdNecroInfo, "View information about the Necro ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveNecro(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdNecroInfo(int client, int args)
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
		case false: vNecroMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vNecroMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iNecroMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Necro Ability Information");
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

public int iNecroMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iNecroAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iNecroCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons3");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "NecroDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flHumanDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vNecroMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "NecroMenu", param1);
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
	menu.AddItem(ST_MENU_NECRO, ST_MENU_NECRO);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_NECRO, false))
	{
		vNecroMenu(client, 0);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Necro Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Necro Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 1, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Human Cooldown", 60.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Human Duration", 5.0);
					g_flHumanDuration[iIndex] = flClamp(g_flHumanDuration[iIndex], 0.1, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Necro Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iNecroAbility[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Enabled", 0);
					g_iNecroAbility[iIndex] = iClamp(g_iNecroAbility[iIndex], 0, 1);
					g_iNecroMessage[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Message", 0);
					g_iNecroMessage[iIndex] = iClamp(g_iNecroMessage[iIndex], 0, 1);
					g_flNecroChance[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Chance", 33.3);
					g_flNecroChance[iIndex] = flClamp(g_flNecroChance[iIndex], 0.0, 100.0);
					g_flNecroRange[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Range", 500.0);
					g_flNecroRange[iIndex] = flClamp(g_flNecroRange[iIndex], 1.0, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 1, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration2[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Human Duration", g_flHumanDuration[iIndex]);
					g_flHumanDuration2[iIndex] = flClamp(g_flHumanDuration2[iIndex], 0.1, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iNecroAbility2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Enabled", g_iNecroAbility[iIndex]);
					g_iNecroAbility2[iIndex] = iClamp(g_iNecroAbility2[iIndex], 0, 1);
					g_iNecroMessage2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Message", g_iNecroMessage[iIndex]);
					g_iNecroMessage2[iIndex] = iClamp(g_iNecroMessage2[iIndex], 0, 1);
					g_flNecroChance2[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Chance", g_flNecroChance[iIndex]);
					g_flNecroChance2[iIndex] = flClamp(g_flNecroChance2[iIndex], 0.0, 100.0);
					g_flNecroRange2[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Range", g_flNecroRange[iIndex]);
					g_flNecroRange2[iIndex] = flClamp(g_flNecroRange2[iIndex], 1.0, 9999999999.0);
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
		int iInfectedId = event.GetInt("userid"), iInfected = GetClientOfUserId(iInfectedId);
		if (bIsSpecialInfected(iInfected, "024"))
		{
			float flInfectedPos[3];
			GetClientAbsOrigin(iInfected, flInfectedPos);

			for (int iTank = 1; iTank <= MaxClients; iTank++)
			{
				if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && g_bNecro[iTank])
				{
					if (iNecroAbility(iTank) == 1 && GetRandomFloat(0.1, 100.0) <= flNecroChance(iTank))
					{
						float flNecroRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flNecroRange[ST_TankType(iTank)] : g_flNecroRange2[ST_TankType(iTank)],
							flTankPos[3];
						GetClientAbsOrigin(iTank, flTankPos);

						float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
						if (flDistance <= flNecroRange)
						{
							switch (GetEntProp(iInfected, Prop_Send, "m_zombieClass"))
							{
								case 1: vNecro(iTank, flInfectedPos, "smoker");
								case 2: vNecro(iTank, flInfectedPos, "boomer");
								case 3: vNecro(iTank, flInfectedPos, "hunter");
								case 4: vNecro(iTank, flInfectedPos, "spitter");
								case 5: vNecro(iTank, flInfectedPos, "jockey");
								case 6: vNecro(iTank, flInfectedPos, "charger");
							}
						}
					}
				}
			}
		}

		if (ST_TankAllowed(iInfected, "024") && ST_CloneAllowed(iInfected, g_bCloneInstalled))
		{
			vRemoveNecro(iInfected);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iNecroAbility(tank) == 1 && !g_bNecro[tank])
	{
		vNecroAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iNecroAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bNecro[tank] && !g_bNecro2[tank])
						{
							vNecroAbility(tank);
						}
						else if (g_bNecro[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman3");
						}
						else if (g_bNecro2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman4");
						}
					}
					case 1:
					{
						if (g_iNecroCount[tank] < iHumanAmmo(tank))
						{
							if (!g_bNecro[tank] && !g_bNecro2[tank])
							{
								g_bNecro[tank] = true;
								g_iNecroCount[tank]++;
								
								ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman", g_iNecroCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroAmmo");
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
			if (iNecroAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bNecro[tank] && !g_bNecro2[tank])
				{
					g_bNecro[tank] = false;
								
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveNecro(tank);
}

static void vNecro(int tank, float pos[3], const char[] type)
{
	int iNecroMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iNecroMessage[ST_TankType(tank)] : g_iNecroMessage2[ST_TankType(tank)];
	bool bExists[MAXPLAYERS + 1];

	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		bExists[iNecro] = false;
		if (bIsSpecialInfected(iNecro, "24"))
		{
			bExists[iNecro] = true;
		}
	}

	vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", type);

	int iInfected;
	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		if (bIsSpecialInfected(iNecro, "24") && !bExists[iNecro])
		{
			iInfected = iNecro;

			break;
		}
	}

	if (iInfected > 0)
	{
		TeleportEntity(iInfected, pos, NULL_VECTOR, NULL_VECTOR);

		if (iNecroMessage == 1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Necro", sTankName);
		}
	}
}

static void vNecroAbility(int tank)
{
	if (g_iNecroCount[tank] < iHumanAmmo(tank))
	{
		if (GetRandomFloat(0.1, 100.0) <= flNecroChance(tank))
		{
			g_bNecro[tank] = true;

			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bNecro2[tank])
			{
				g_iNecroCount[tank]++;

				CreateTimer(flHumanDuration(tank), tTimerStopNecro, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman", g_iNecroCount[tank], iHumanAmmo(tank));
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman2");
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroAmmo");
	}
}

static void vRemoveNecro(int tank)
{
	g_bNecro[tank] = false;
	g_bNecro2[tank] = false;
	g_iNecroCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveNecro(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bNecro2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman5");

	if (g_iNecroCount[tank] < iHumanAmmo(tank))
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bNecro2[tank] = false;
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

static float flNecroChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flNecroChance[ST_TankType(tank)] : g_flNecroChance2[ST_TankType(tank)];
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

static int iNecroAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNecroAbility[ST_TankType(tank)] : g_iNecroAbility2[ST_TankType(tank)];
}

public Action tTimerStopNecro(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bNecro[iTank])
	{
		g_bNecro[iTank] = false;

		return Plugin_Stop;
	}

	g_bNecro[iTank] = false;

	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && !g_bNecro2[iTank])
	{
		vReset2(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bNecro2[iTank])
	{
		g_bNecro2[iTank] = false;

		return Plugin_Stop;
	}

	g_bNecro2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "NecroHuman6");

	return Plugin_Continue;
}