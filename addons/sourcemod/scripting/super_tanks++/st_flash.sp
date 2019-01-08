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
	name = "[ST++] Flash Ability",
	author = ST_AUTHOR,
	description = "The Super Tank runs really fast like the Flash.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_FLASH "Flash Ability"

bool g_bCloneInstalled, g_bFlash[MAXPLAYERS + 1], g_bFlash2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flFlashChance[ST_MAXTYPES + 1], g_flFlashChance2[ST_MAXTYPES + 1], g_flFlashDuration[ST_MAXTYPES + 1], g_flFlashDuration2[ST_MAXTYPES + 1], g_flFlashSpeed[ST_MAXTYPES + 1], g_flFlashSpeed2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flRunSpeed[ST_MAXTYPES + 1], g_flRunSpeed2[ST_MAXTYPES + 1];

int g_iFlashAbility[ST_MAXTYPES + 1], g_iFlashAbility2[ST_MAXTYPES + 1], g_iFlashCount[MAXPLAYERS + 1], g_iFlashMessage[ST_MAXTYPES + 1], g_iFlashMessage2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Flash Ability\" only supports Left 4 Dead 1 & 2.");

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
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_flash", cmdFlashInfo, "View information about the Flash ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveFlash(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFlashInfo(int client, int args)
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
		case false: vFlashMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFlashMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFlashMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Flash Ability Information");
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

public int iFlashMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iFlashAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iFlashCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "FlashDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flFlashDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vFlashMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "FlashMenu", param1);
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
	menu.AddItem(ST_MENU_FLASH, ST_MENU_FLASH);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_FLASH, false))
	{
		vFlashMenu(client, 0);
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

					g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", -1.0);
					g_flRunSpeed[iIndex] = flClamp(g_flRunSpeed[iIndex], -1.0, 3.0);

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Flash Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Flash Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Flash Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iFlashAbility[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Enabled", 0);
					g_iFlashAbility[iIndex] = iClamp(g_iFlashAbility[iIndex], 0, 1);
					g_iFlashMessage[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Message", 0);
					g_iFlashMessage[iIndex] = iClamp(g_iFlashMessage[iIndex], 0, 1);
					g_flFlashChance[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Chance", 33.3);
					g_flFlashChance[iIndex] = flClamp(g_flFlashChance[iIndex], 0.0, 100.0);
					g_flFlashDuration[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Duration", 5.0);
					g_flFlashDuration[iIndex] = flClamp(g_flFlashDuration[iIndex], 0.1, 9999999999.0);
					g_flFlashSpeed[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Speed", 5.0);
					g_flFlashSpeed[iIndex] = flClamp(g_flFlashSpeed[iIndex], 3.0, 10.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_flRunSpeed2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", g_flRunSpeed[iIndex]);
					g_flRunSpeed2[iIndex] = flClamp(g_flRunSpeed2[iIndex], -1.0, 3.0);

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iFlashAbility2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Enabled", g_iFlashAbility[iIndex]);
					g_iFlashAbility2[iIndex] = iClamp(g_iFlashAbility2[iIndex], 0, 1);
					g_iFlashMessage2[iIndex] = kvSuperTanks.GetNum("Flash Ability/Ability Message", g_iFlashMessage[iIndex]);
					g_iFlashMessage2[iIndex] = iClamp(g_iFlashMessage2[iIndex], 0, 1);
					g_flFlashChance2[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Chance", g_flFlashChance[iIndex]);
					g_flFlashChance2[iIndex] = flClamp(g_flFlashChance2[iIndex], 0.0, 100.0);
					g_flFlashDuration2[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Duration", g_flFlashDuration[iIndex]);
					g_flFlashDuration2[iIndex] = flClamp(g_flFlashDuration2[iIndex], 0.1, 9999999999.0);
					g_flFlashSpeed2[iIndex] = kvSuperTanks.GetFloat("Flash Ability/Flash Speed", g_flFlashSpeed[iIndex]);
					g_flFlashSpeed2[iIndex] = flClamp(g_flFlashSpeed2[iIndex], 3.0, 10.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, "234") && g_bFlash[iTank])
		{
			SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024"))
		{
			vRemoveFlash(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iFlashAbility(tank) == 1 && !g_bFlash[tank])
	{
		vFlashAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iFlashAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bFlash[tank] && !g_bFlash2[tank])
						{
							vFlashAbility(tank);
						}
						else if (g_bFlash[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlashHuman3");
						}
						else if (g_bFlash2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlashHuman4");
						}
					}
					case 1:
					{
						if (g_iFlashCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bFlash[tank] && !g_bFlash2[tank])
							{
								g_bFlash[tank] = true;
								g_iFlashCount[tank]++;

								SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", flFlashSpeed(tank));

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlashHuman", g_iFlashCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlashAmmo");
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
			if (iFlashAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bFlash[tank] && !g_bFlash2[tank])
				{
					g_bFlash[tank] = false;

					SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", flRunSpeed(tank));

					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveFlash(tank);
}

static void vFlashAbility(int tank)
{
	if (g_iFlashCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flFlashChance = !g_bTankConfig[ST_TankType(tank)] ? g_flFlashChance[ST_TankType(tank)] : g_flFlashChance2[ST_TankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flFlashChance)
		{
			g_bFlash[tank] = true;

			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				g_iFlashCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlashHuman", g_iFlashCount[tank], iHumanAmmo(tank));
			}

			SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", flFlashSpeed(tank));

			CreateTimer(flFlashDuration(tank), tTimerStopFlash, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (iFlashMessage(tank) == 1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Flash", sTankName);
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlashHuman2");
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlashAmmo");
	}
}

static void vRemoveFlash(int tank)
{
	g_bFlash[tank] = false;
	g_bFlash2[tank] = false;
	g_iFlashCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveFlash(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bFlash[tank] = false;

	if (iFlashMessage(tank) == 1)
	{
		char sTankName[33];
		ST_TankName(tank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Flash2", sTankName);
	}
}

static void vReset3(int tank)
{
	g_bFlash2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlashHuman5");

	if (g_iFlashCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bFlash2[tank] = false;
	}
}

static float flFlashDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flFlashDuration[ST_TankType(tank)] : g_flFlashDuration2[ST_TankType(tank)];
}

static float flFlashSpeed(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flFlashSpeed[ST_TankType(tank)] : g_flFlashSpeed2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flRunSpeed(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flRunSpeed[ST_TankType(tank)] : g_flRunSpeed2[ST_TankType(tank)];
}

static int iFlashAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFlashAbility[ST_TankType(tank)] : g_iFlashAbility2[ST_TankType(tank)];
}

static int iFlashMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFlashMessage[ST_TankType(tank)] : g_iFlashMessage2[ST_TankType(tank)];
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

public Action tTimerStopFlash(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	vReset2(iTank);

	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && !g_bFlash2[iTank])
	{
		vReset3(iTank);
	}

	SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", flRunSpeed(iTank));

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bFlash2[iTank])
	{
		g_bFlash2[iTank] = false;

		return Plugin_Stop;
	}

	g_bFlash2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "FlashHuman6");

	return Plugin_Continue;
}