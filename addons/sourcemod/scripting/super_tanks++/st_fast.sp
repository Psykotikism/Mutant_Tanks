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
	name = "[ST++] Fast Ability",
	author = ST_AUTHOR,
	description = "The Super Tank runs really fast like the Flash.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Fast Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ST_MENU_FAST "Fast Ability"

bool g_bCloneInstalled, g_bFast[MAXPLAYERS + 1], g_bFast2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flFastChance[ST_MAXTYPES + 1], g_flFastChance2[ST_MAXTYPES + 1], g_flFastDuration[ST_MAXTYPES + 1], g_flFastDuration2[ST_MAXTYPES + 1], g_flFastSpeed[ST_MAXTYPES + 1], g_flFastSpeed2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iFastAbility[ST_MAXTYPES + 1], g_iFastAbility2[ST_MAXTYPES + 1], g_iFastCount[MAXPLAYERS + 1], g_iFastMessage[ST_MAXTYPES + 1], g_iFastMessage2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_fast", cmdFastInfo, "View information about the Fast ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveFast(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFastInfo(int client, int args)
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
		case false: vFastMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFastMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFastMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fast Ability Information");
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

public int iFastMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iFastAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iFastCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "FastDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flFastDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vFastMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "FastMenu", param1);
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
	menu.AddItem(ST_MENU_FAST, ST_MENU_FAST);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_FAST, false))
	{
		vFastMenu(client, 0);
	}
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Fast Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Fast Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Fast Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Fast Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iFastAbility[iIndex] = kvSuperTanks.GetNum("Fast Ability/Ability Enabled", 0);
					g_iFastAbility[iIndex] = iClamp(g_iFastAbility[iIndex], 0, 1);
					g_iFastMessage[iIndex] = kvSuperTanks.GetNum("Fast Ability/Ability Message", 0);
					g_iFastMessage[iIndex] = iClamp(g_iFastMessage[iIndex], 0, 1);
					g_flFastChance[iIndex] = kvSuperTanks.GetFloat("Fast Ability/Fast Chance", 33.3);
					g_flFastChance[iIndex] = flClamp(g_flFastChance[iIndex], 0.0, 100.0);
					g_flFastDuration[iIndex] = kvSuperTanks.GetFloat("Fast Ability/Fast Duration", 5.0);
					g_flFastDuration[iIndex] = flClamp(g_flFastDuration[iIndex], 0.1, 9999999999.0);
					g_flFastSpeed[iIndex] = kvSuperTanks.GetFloat("Fast Ability/Fast Speed", 5.0);
					g_flFastSpeed[iIndex] = flClamp(g_flFastSpeed[iIndex], 3.0, 10.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Fast Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Fast Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Fast Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Fast Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iFastAbility2[iIndex] = kvSuperTanks.GetNum("Fast Ability/Ability Enabled", g_iFastAbility[iIndex]);
					g_iFastAbility2[iIndex] = iClamp(g_iFastAbility2[iIndex], 0, 1);
					g_iFastMessage2[iIndex] = kvSuperTanks.GetNum("Fast Ability/Ability Message", g_iFastMessage[iIndex]);
					g_iFastMessage2[iIndex] = iClamp(g_iFastMessage2[iIndex], 0, 1);
					g_flFastChance2[iIndex] = kvSuperTanks.GetFloat("Fast Ability/Fast Chance", g_flFastChance[iIndex]);
					g_flFastChance2[iIndex] = flClamp(g_flFastChance2[iIndex], 0.0, 100.0);
					g_flFastDuration2[iIndex] = kvSuperTanks.GetFloat("Fast Ability/Fast Duration", g_flFastDuration[iIndex]);
					g_flFastDuration2[iIndex] = flClamp(g_flFastDuration2[iIndex], 0.1, 9999999999.0);
					g_flFastSpeed2[iIndex] = kvSuperTanks.GetFloat("Fast Ability/Fast Speed", g_flFastSpeed[iIndex]);
					g_flFastSpeed2[iIndex] = flClamp(g_flFastSpeed2[iIndex], 3.0, 10.0);
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
		if (bIsTank(iTank, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bFast[iTank])
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
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveFast(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iFastAbility(tank) == 1 && !g_bFast[tank])
	{
		vFastAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iFastAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bFast[tank] && !g_bFast2[tank])
						{
							vFastAbility(tank);
						}
						else if (g_bFast[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "FastHuman3");
						}
						else if (g_bFast2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "FastHuman4");
						}
					}
					case 1:
					{
						if (g_iFastCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bFast[tank] && !g_bFast2[tank])
							{
								g_bFast[tank] = true;
								g_iFastCount[tank]++;

								SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", flFastSpeed(tank));

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "FastHuman", g_iFastCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "FastAmmo");
						}
					}
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iFastAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bFast[tank] && !g_bFast2[tank])
				{
					g_bFast[tank] = false;

					SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", ST_GetRunSpeed(tank));

					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveFast(tank);
}

static void vFastAbility(int tank)
{
	if (g_iFastCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flFastChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flFastChance[ST_GetTankType(tank)] : g_flFastChance2[ST_GetTankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flFastChance)
		{
			g_bFast[tank] = true;

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
			{
				g_iFastCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "FastHuman", g_iFastCount[tank], iHumanAmmo(tank));
			}

			SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", flFastSpeed(tank));

			CreateTimer(flFastDuration(tank), tTimerStopFast, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (iFastMessage(tank) == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Fast", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "FastHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "FastAmmo");
	}
}

static void vRemoveFast(int tank)
{
	g_bFast[tank] = false;
	g_bFast2[tank] = false;
	g_iFastCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveFast(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bFast[tank] = false;

	if (iFastMessage(tank) == 1)
	{
		char sTankName[33];
		ST_GetTankName(tank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Fast2", sTankName);
	}
}

static void vReset3(int tank)
{
	g_bFast2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "FastHuman5");

	if (g_iFastCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bFast2[tank] = false;
	}
}

static float flFastDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flFastDuration[ST_GetTankType(tank)] : g_flFastDuration2[ST_GetTankType(tank)];
}

static float flFastSpeed(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flFastSpeed[ST_GetTankType(tank)] : g_flFastSpeed2[ST_GetTankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static int iFastAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iFastAbility[ST_GetTankType(tank)] : g_iFastAbility2[ST_GetTankType(tank)];
}

static int iFastMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iFastMessage[ST_GetTankType(tank)] : g_iFastMessage2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iHumanMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanMode[ST_GetTankType(tank)] : g_iHumanMode2[ST_GetTankType(tank)];
}

public Action tTimerStopFast(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled))
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	vReset2(iTank);

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1 && !g_bFast2[iTank])
	{
		vReset3(iTank);
	}

	SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", ST_GetRunSpeed(iTank));

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bFast2[iTank])
	{
		g_bFast2[iTank] = false;

		return Plugin_Stop;
	}

	g_bFast2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "FastHuman6");

	return Plugin_Continue;
}