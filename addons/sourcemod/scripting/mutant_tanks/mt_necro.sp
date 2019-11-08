/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
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
#include <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Necro Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank resurrects nearby special infected that die.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Necro Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_NECRO "Necro Ability"

bool g_bCloneInstalled, g_bNecro[MAXPLAYERS + 1], g_bNecro2[MAXPLAYERS + 1];

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flHumanDuration[MT_MAXTYPES + 1], g_flNecroChance[MT_MAXTYPES + 1], g_flNecroRange[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iHumanMode[MT_MAXTYPES + 1], g_iNecroAbility[MT_MAXTYPES + 1], g_iNecroCount[MAXPLAYERS + 1], g_iNecroMessage[MT_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_necro", cmdNecroInfo, "View information about the Necro ability.");
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
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iNecroAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iNecroCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons3");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanMode[MT_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "NecroDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flHumanDuration[MT_GetTankType(param1)]);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_NECRO, MT_MENU_NECRO);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_NECRO, false))
	{
		vNecroMenu(client, 0);
	}
}

public void MT_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
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

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
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
		g_iHumanAbility[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 999999.0);
		g_flHumanDuration[type] = flGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_flHumanDuration[type], value, 0.1, 999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iNecroAbility[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iNecroAbility[type], value, 0, 1);
		g_iNecroMessage[type] = iGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iNecroMessage[type], value, 0, 1);
		g_flNecroChance[type] = flGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "NecroChance", "Necro Chance", "Necro_Chance", "chance", g_flNecroChance[type], value, 0.0, 100.0);
		g_flNecroRange[type] = flGetValue(subsection, "necroability", "necro ability", "necro_ability", "necro", key, "NecroRange", "Necro Range", "Necro_Range", "range", g_flNecroRange[type], value, 1.0, 999999.0);

		if (StrEqual(subsection, "necroability", false) || StrEqual(subsection, "necro ability", false) || StrEqual(subsection, "necro_ability", false) || StrEqual(subsection, "necro", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iInfectedId = event.GetInt("userid"), iInfected = GetClientOfUserId(iInfectedId);
		if (bIsSpecialInfected(iInfected, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			float flInfectedPos[3];
			GetClientAbsOrigin(iInfected, flInfectedPos);

			for (int iTank = 1; iTank <= MaxClients; iTank++)
			{
				if (MT_IsTankSupported(iTank) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_bNecro[iTank])
				{
					if (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank))
					{
						continue;
					}

					if (g_iNecroAbility[MT_GetTankType(iTank)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flNecroChance[MT_GetTankType(iTank)])
					{
						float flTankPos[3];
						GetClientAbsOrigin(iTank, flTankPos);

						float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
						if (flDistance <= g_flNecroRange[MT_GetTankType(iTank)])
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

		if (MT_IsTankSupported(iInfected, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveNecro(iInfected);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iNecroAbility[MT_GetTankType(tank)] == 1 && !g_bNecro[tank])
	{
		vNecroAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_iNecroAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[MT_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bNecro[tank] && !g_bNecro2[tank])
						{
							vNecroAbility(tank);
						}
						else if (g_bNecro[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "NecroHuman3");
						}
						else if (g_bNecro2[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "NecroHuman4");
						}
					}
					case 1:
					{
						if (g_iNecroCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
						{
							if (!g_bNecro[tank] && !g_bNecro2[tank])
							{
								g_bNecro[tank] = true;
								g_iNecroCount[tank]++;
								
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "NecroHuman", g_iNecroCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "NecroAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_iNecroAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[MT_GetTankType(tank)] == 1 && g_bNecro[tank] && !g_bNecro2[tank])
				{
					g_bNecro[tank] = false;
								
					vReset2(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveNecro(tank);
}

static void vNecro(int tank, float pos[3], const char[] type)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	bool bExists[MAXPLAYERS + 1];

	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		bExists[iNecro] = false;
		if (bIsSpecialInfected(iNecro, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			bExists[iNecro] = true;
		}
	}

	vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", type);

	int iInfected;
	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		if (bIsSpecialInfected(iNecro, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && !bExists[iNecro])
		{
			iInfected = iNecro;

			break;
		}
	}

	if (iInfected > 0)
	{
		TeleportEntity(iInfected, pos, NULL_VECTOR, NULL_VECTOR);

		if (g_iNecroMessage[MT_GetTankType(tank)] == 1)
		{
			char sTankName[33];
			MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Necro", sTankName);
		}
	}
}

static void vNecroAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iNecroCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flNecroChance[MT_GetTankType(tank)])
		{
			g_bNecro[tank] = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bNecro2[tank])
			{
				g_iNecroCount[tank]++;

				CreateTimer(g_flHumanDuration[MT_GetTankType(tank)], tTimerStopNecro, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "NecroHuman", g_iNecroCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "NecroHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "NecroAmmo");
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
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveNecro(iPlayer);

			g_bNecro[iPlayer] = false;
		}
	}
}

static void vReset2(int tank)
{
	g_bNecro2[tank] = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "NecroHuman5");

	if (g_iNecroCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bNecro2[tank] = false;
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[MT_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iAbilityFlags)) ? false : true;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iTypeFlags)) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iGlobalFlags)) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

public Action tTimerStopNecro(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bNecro[iTank])
	{
		g_bNecro[iTank] = false;

		return Plugin_Stop;
	}

	g_bNecro[iTank] = false;

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && g_iHumanMode[MT_GetTankType(iTank)] == 0 && !g_bNecro2[iTank])
	{
		vReset2(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bNecro2[iTank])
	{
		g_bNecro2[iTank] = false;

		return Plugin_Stop;
	}

	g_bNecro2[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "NecroHuman6");

	return Plugin_Continue;
}