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

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Necro Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ST_MENU_NECRO "Necro Ability"

bool g_bCloneInstalled, g_bNecro[MAXPLAYERS + 1], g_bNecro2[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flNecroChance[ST_MAXTYPES + 1], g_flNecroRange[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iNecroAbility[ST_MAXTYPES + 1], g_iNecroCount[MAXPLAYERS + 1], g_iNecroMessage[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_necro", cmdNecroInfo, "View information about the Necro ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveNecro(client);

	g_bNecro[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdNecroInfo(int client, int args)
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iNecroAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iNecroCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons3");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "NecroDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flHumanDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

public void ST_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_flHumanDuration[iIndex] = 5.0;
		g_iHumanMode[iIndex] = 1;
		g_iNecroAbility[iIndex] = 0;
		g_iNecroMessage[iIndex] = 0;
		g_flNecroChance[iIndex] = 33.3;
		g_flNecroRange[iIndex] = 500.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "necroability", false) || StrEqual(subsection, "necro ability", false) || StrEqual(subsection, "necro_ability", false) || StrEqual(subsection, "necro", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		ST_FindAbility(type, 38, bHasAbilities(subsection, "necroability", "necro ability", "necro_ability", "necro"));
		g_iHumanAbility[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_flHumanDuration[type] = flGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_flHumanDuration[type], value, 0.1, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iNecroAbility[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iNecroAbility[type], value, 0, 1);
		g_iNecroMessage[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iNecroMessage[type], value, 0, 1);
		g_flNecroChance[type] = flGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "NecroChance", "Necro Chance", "Necro_Chance", "chance", g_flNecroChance[type], value, 0.0, 100.0);
		g_flNecroRange[type] = flGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "NecroRange", "Necro Range", "Necro_Range", "range", g_flNecroRange[type], value, 1.0, 9999999999.0);

		if (StrEqual(subsection, "necroability", false) || StrEqual(subsection, "necro ability", false) || StrEqual(subsection, "necro_ability", false) || StrEqual(subsection, "necro", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iInfectedId = event.GetInt("userid"), iInfected = GetClientOfUserId(iInfectedId);
		if (bIsSpecialInfected(iInfected, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			float flInfectedPos[3];
			GetClientAbsOrigin(iInfected, flInfectedPos);

			for (int iTank = 1; iTank <= MaxClients; iTank++)
			{
				if (ST_IsTankSupported(iTank) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_bNecro[iTank])
				{
					if (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank))
					{
						continue;
					}

					if (g_iNecroAbility[ST_GetTankType(iTank)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flNecroChance[ST_GetTankType(iTank)])
					{
						float flTankPos[3];
						GetClientAbsOrigin(iTank, flTankPos);

						float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
						if (flDistance <= g_flNecroRange[ST_GetTankType(iTank)])
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

		if (ST_IsTankSupported(iInfected, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveNecro(iInfected);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iNecroAbility[ST_GetTankType(tank)] == 1 && !g_bNecro[tank])
	{
		vNecroAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iNecroAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
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
						if (g_iNecroCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bNecro[tank] && !g_bNecro2[tank])
							{
								g_bNecro[tank] = true;
								g_iNecroCount[tank]++;
								
								ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman", g_iNecroCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
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
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iNecroAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bNecro[tank] && !g_bNecro2[tank])
				{
					g_bNecro[tank] = false;
								
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveNecro(tank);
}

static void vNecro(int tank, float pos[3], const char[] type)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	bool bExists[MAXPLAYERS + 1];

	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		bExists[iNecro] = false;
		if (bIsSpecialInfected(iNecro, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			bExists[iNecro] = true;
		}
	}

	vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", type);

	int iInfected;
	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		if (bIsSpecialInfected(iNecro, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && !bExists[iNecro])
		{
			iInfected = iNecro;

			break;
		}
	}

	if (iInfected > 0)
	{
		TeleportEntity(iInfected, pos, NULL_VECTOR, NULL_VECTOR);

		if (g_iNecroMessage[ST_GetTankType(tank)] == 1)
		{
			char sTankName[33];
			ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Necro", sTankName);
		}
	}
}

static void vNecroAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iNecroCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flNecroChance[ST_GetTankType(tank)])
		{
			g_bNecro[tank] = true;

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bNecro2[tank])
			{
				g_iNecroCount[tank]++;

				CreateTimer(g_flHumanDuration[ST_GetTankType(tank)], tTimerStopNecro, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman", g_iNecroCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroAmmo");
	}
}

static void vRemoveNecro(int tank)
{
	g_bNecro2[tank] = false;
	g_iNecroCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveNecro(iPlayer);

			g_bNecro[iPlayer] = false;
		}
	}
}

static void vReset2(int tank)
{
	g_bNecro2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "NecroHuman5");

	if (g_iNecroCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bNecro2[tank] = false;
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, ST_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[ST_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iAbilityFlags))
		{
			return false;
		}
	}

	int iTypeFlags = ST_GetAccessFlags(2, ST_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iTypeFlags))
		{
			return false;
		}
	}

	int iGlobalFlags = ST_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iGlobalFlags))
		{
			return false;
		}
	}

	int iClientTypeFlags = ST_GetAccessFlags(4, ST_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientTypeFlags & iAbilityFlags))
		{
			return false;
		}
	}

	int iClientGlobalFlags = ST_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientGlobalFlags & iAbilityFlags))
		{
			return false;
		}
	}

	return true;
}

public Action tTimerStopNecro(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bNecro[iTank])
	{
		g_bNecro[iTank] = false;

		return Plugin_Stop;
	}

	g_bNecro[iTank] = false;

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && (ST_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && !g_bNecro2[iTank])
	{
		vReset2(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bNecro2[iTank])
	{
		g_bNecro2[iTank] = false;

		return Plugin_Stop;
	}

	g_bNecro2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "NecroHuman6");

	return Plugin_Continue;
}