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
	name = "[ST++] Omni Ability",
	author = ST_AUTHOR,
	description = "The Super Tank has omni-level access to other nearby Super Tanks' abilities.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Omni Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ST_MENU_OMNI "Omni Ability"

bool g_bCloneInstalled, g_bOmni[MAXPLAYERS + 1], g_bOmni2[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flOmniChance[ST_MAXTYPES + 1], g_flOmniDuration[ST_MAXTYPES + 1], g_flOmniRange[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iOmniAbility[ST_MAXTYPES + 1], g_iOmniCount[MAXPLAYERS + 1], g_iOmniMessage[ST_MAXTYPES + 1], g_iOmniMode[ST_MAXTYPES + 1], g_iOmniType[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_omni", cmdOmniInfo, "View information about the Omni ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveOmni(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdOmniInfo(int client, int args)
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
		case false: vOmniMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vOmniMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iOmniMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Omni Ability Information");
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

public int iOmniMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iOmniAbility[g_iOmniType[param1] > 0 ? g_iOmniType[param1] : ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[g_iOmniType[param1] > 0 ? g_iOmniType[param1] : ST_GetTankType(param1)] - g_iOmniCount[param1], g_iHumanAmmo[g_iOmniType[param1] > 0 ? g_iOmniType[param1] : ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[g_iOmniType[param1] > 0 ? g_iOmniType[param1] : ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[g_iOmniType[param1] > 0 ? g_iOmniType[param1] : ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "OmniDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flOmniDuration[g_iOmniType[param1] > 0 ? g_iOmniType[param1] : ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[g_iOmniType[param1] > 0 ? g_iOmniType[param1] : ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vOmniMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "OmniMenu", param1);
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
	menu.AddItem(ST_MENU_OMNI, ST_MENU_OMNI);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_OMNI, false))
	{
		vOmniMenu(client, 0);
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
		g_iHumanMode[iIndex] = 1;
		g_iOmniAbility[iIndex] = 0;
		g_iOmniMessage[iIndex] = 0;
		g_flOmniChance[iIndex] = 33.3;
		g_flOmniDuration[iIndex] = 5.0;
		g_iOmniMode[iIndex] = 0;
		g_flOmniRange[iIndex] = 500.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "omniability", false) || StrEqual(subsection, "omni ability", false) || StrEqual(subsection, "omni_ability", false) || StrEqual(subsection, "omni", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		ST_FindAbility(type, 40, bHasAbilities(subsection, "omniability", "omni ability", "omni_ability", "omni"));
		g_iHumanAbility[type] = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iOmniAbility[type] = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iOmniAbility[type], value, 0, 1);
		g_iOmniMessage[type] = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iOmniMessage[type], value, 0, 1);
		g_flOmniChance[type] = flGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniChance", "Omni Chance", "Omni_Chance", "chance", g_flOmniChance[type], value, 0.0, 100.0);
		g_flOmniDuration[type] = flGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniDuration", "Omni Duration", "Omni_Duration", "duration", g_flOmniDuration[type], value, 0.1, 9999999999.0);
		g_iOmniMode[type] = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniMode", "Omni Mode", "Omni_Mode", "mode", g_iOmniMode[type], value, 0, 1);
		g_flOmniRange[type] = flGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniRange", "Omni Range", "Omni_Range", "range", g_flOmniRange[type], value, 1.0, 9999999999.0);

		if (StrEqual(subsection, "omniability", false) || StrEqual(subsection, "omni ability", false) || StrEqual(subsection, "omni_ability", false) || StrEqual(subsection, "omni", false))
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
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveOmni(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iOmniAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1 && !g_bOmni[tank])
	{
		vOmniAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iOmniAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1 && g_iHumanAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bOmni[tank] && !g_bOmni2[tank])
						{
							vOmniAbility(tank);
						}
						else if (g_bOmni[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "OmniHuman3");
						}
						else if (g_bOmni2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "OmniHuman4");
						}
					}
					case 1:
					{
						if (g_iOmniCount[tank] < g_iHumanAmmo[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] && g_iHumanAmmo[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] > 0)
						{
							if (!g_bOmni[tank] && !g_bOmni2[tank])
							{
								g_bOmni[tank] = true;
								g_iOmniCount[tank]++;

								vOmni(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "OmniHuman", g_iOmniCount[tank], g_iHumanAmmo[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "OmniAmmo");
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
			if (g_iOmniAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1 && g_iHumanAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1 && g_bOmni[tank] && !g_bOmni2[tank])
				{
					g_bOmni[tank] = false;

					ST_SetTankType(tank, g_iOmniType[tank], view_as<bool>(g_iOmniMode[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)]));

					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveOmni(tank);
}

static void vOmni(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	g_iOmniType[tank] = ST_GetTankType(tank);

	float flTankPos[3];
	GetClientAbsOrigin(tank, flTankPos);

	int iTypeCount, iTypes[ST_MAXTYPES + 1];
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (ST_IsTankSupported(iTank, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && iTank != tank)
		{
			float flTankPos2[3];
			GetClientAbsOrigin(iTank, flTankPos2);

			float flDistance = GetVectorDistance(flTankPos, flTankPos2);
			if (flDistance <= g_flOmniRange[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)])
			{
				iTypes[iTypeCount + 1] = ST_GetTankType(iTank);
				iTypeCount++;
			}
		}
	}

	if (iTypeCount > 0)
	{
		ST_SetTankType(tank, iTypes[GetRandomInt(1, iTypeCount)], view_as<bool>(g_iOmniMode[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)]));
	}
	else
	{
		int iTypeCount2, iTypes2[ST_MAXTYPES + 1];
		for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
		{
			if (!ST_IsTypeEnabled(iIndex) || !ST_CanTankSpawn(iIndex) || g_iOmniType[tank] == iIndex)
			{
				continue;
			}

			iTypes2[iTypeCount2 + 1] = iIndex;
			iTypeCount2++;
		}

		ST_SetTankType(tank, iTypes2[GetRandomInt(1, iTypeCount2)], view_as<bool>(g_iOmniMode[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)]));
	}
}

static void vOmniAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iOmniCount[tank] < g_iHumanAmmo[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] && g_iHumanAmmo[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flOmniChance[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)])
		{
			g_bOmni[tank] = true;

			vOmni(tank);

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1)
			{
				g_iOmniCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "OmniHuman", g_iOmniCount[tank], g_iHumanAmmo[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)]);
			}

			CreateTimer(g_flOmniDuration[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)], tTimerStopOmni, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (g_iOmniMessage[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, g_iOmniType[tank], sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Omni", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "OmniHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "OmniAmmo");
	}
}

static void vRemoveOmni(int tank)
{
	g_bOmni[tank] = false;
	g_bOmni2[tank] = false;
	g_iOmniCount[tank] = 0;
	g_iOmniType[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveOmni(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bOmni[tank] = false;

	if (g_iOmniMessage[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] == 1)
	{
		char sTankName[33];
		ST_GetTankName(tank, g_iOmniType[tank], sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Omni2", sTankName);
	}
}

static void vReset3(int tank)
{
	g_bOmni2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "OmniHuman5");

	if (g_iOmniCount[tank] < g_iHumanAmmo[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] && g_iHumanAmmo[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[g_iOmniType[tank] > 0 ? g_iOmniType[tank] : ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bOmni2[tank] = false;
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

public Action tTimerStopOmni(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(g_iOmniType[iTank] > 0 ? g_iOmniType[iTank] : ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_iOmniType[iTank] = 0;

		vReset2(iTank);

		return Plugin_Stop;
	}

	vReset2(iTank);

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && (ST_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[g_iOmniType[iTank] > 0 ? g_iOmniType[iTank] : ST_GetTankType(iTank)] == 1 && !g_bOmni2[iTank])
	{
		vReset3(iTank);
	}

	ST_SetTankType(iTank, g_iOmniType[iTank], view_as<bool>(g_iOmniMode[g_iOmniType[iTank] > 0 ? g_iOmniType[iTank] : ST_GetTankType(iTank)]));
	g_iOmniType[iTank] = 0;

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bOmni2[iTank])
	{
		g_bOmni2[iTank] = false;

		return Plugin_Stop;
	}

	g_bOmni2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "OmniHuman6");

	return Plugin_Continue;
}