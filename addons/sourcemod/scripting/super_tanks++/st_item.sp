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
	name = "[ST++] Item Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gives survivors items upon death.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Item Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ST_MENU_ITEM "Item Ability"

bool g_bCloneInstalled, g_bItem[MAXPLAYERS + 1];

char g_sItemLoadout[ST_MAXTYPES + 1][325];

float g_flItemChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iItemAbility[ST_MAXTYPES + 1], g_iItemMessage[ST_MAXTYPES + 1], g_iItemMode[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_item", cmdItemInfo, "View information about the Item ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	g_bItem[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdItemInfo(int client, int args)
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
		case false: vItemMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vItemMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iItemMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Item Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iItemMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iItemAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons4");
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ItemDetails");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vItemMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ItemMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 3:
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
	menu.AddItem(ST_MENU_ITEM, ST_MENU_ITEM);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ITEM, false))
	{
		vItemMenu(client, 0);
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iItemAbility[iIndex] = 0;
		g_iItemMessage[iIndex] = 0;
		g_flItemChance[iIndex] = 33.3;
		Format(g_sItemLoadout[iIndex], sizeof(g_sItemLoadout[]), "rifle,pistol,first_aid_kit,pain_pills");
		g_iItemMode[iIndex] = 0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "itemability", "item ability", "item_ability", "item", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iItemAbility[type] = iGetValue(subsection, "itemability", "item ability", "item_ability", "item", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iItemAbility[type], value, 0, 0, 1);
	g_iItemMessage[type] = iGetValue(subsection, "itemability", "item ability", "item_ability", "item", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iItemMessage[type], value, 0, 0, 1);
	g_flItemChance[type] = flGetValue(subsection, "itemability", "item ability", "item_ability", "item", key, "ItemChance", "Item Chance", "Item_Chance", "chance", main, g_flItemChance[type], value, 33.3, 0.0, 100.0);
	g_iItemMode[type] = iGetValue(subsection, "itemability", "item ability", "item_ability", "item", key, "ItemMode", "Item Mode", "Item_Mode", "mode", main, g_iItemMode[type], value, 0, 0, 1);

	if ((StrEqual(subsection, "itemability", false) || StrEqual(subsection, "item ability", false) || StrEqual(subsection, "item_ability", false) || StrEqual(subsection, "item", false)) && (StrEqual(key, "ItemLoadout", false) || StrEqual(key, "Item Loadout", false) || StrEqual(key, "Item_Loadout", false) || StrEqual(key, "loadout", false)) && value[0] != '\0')
	{
		strcopy(g_sItemLoadout[type], sizeof(g_sItemLoadout[]), value);
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iItemAbility[ST_GetTankType(iTank)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flItemChance[ST_GetTankType(iTank)] && g_bItem[iTank])
		{
			vItemAbility(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iItemAbility[ST_GetTankType(tank)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flItemChance[ST_GetTankType(tank)] && !g_bItem[tank])
	{
		g_bItem[tank] = true;
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY2 == ST_SPECIAL_KEY2)
		{
			if (g_iItemAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bItem[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "ItemHuman2");
					case false:
					{
						g_bItem[tank] = true;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "ItemHuman");
					}
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	if (ST_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iItemAbility[ST_GetTankType(tank)] == 1)
	{
		vItemAbility(tank);
	}
}

static void vItemAbility(int tank)
{
	g_bItem[tank] = false;

	char sItems[5][64];
	ReplaceString(g_sItemLoadout[ST_GetTankType(tank)], sizeof(g_sItemLoadout[]), " ", "");
	ExplodeString(g_sItemLoadout[ST_GetTankType(tank)], ",", sItems, sizeof(sItems), sizeof(sItems[]));

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
		{
			switch (g_iItemMode[ST_GetTankType(tank)])
			{
				case 0:
				{
					switch (GetRandomInt(1, 5))
					{
						case 1: vCheatCommand(iSurvivor, "give", sItems[0]);
						case 2: vCheatCommand(iSurvivor, "give", sItems[1]);
						case 3: vCheatCommand(iSurvivor, "give", sItems[2]);
						case 4: vCheatCommand(iSurvivor, "give", sItems[3]);
						case 5: vCheatCommand(iSurvivor, "give", sItems[4]);
					}
				}
				case 1:
				{
					for (int iItem = 0; iItem < sizeof(sItems); iItem++)
					{
						if (StrContains(g_sItemLoadout[ST_GetTankType(tank)], sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
						{
							vCheatCommand(iSurvivor, "give", sItems[iItem]);
						}
					}
				}
			}
		}
	}

	if (g_iItemMessage[ST_GetTankType(tank)] == 1)
	{
		char sTankName[33];
		ST_GetTankName(tank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Item", sTankName);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			g_bItem[iPlayer] = false;
		}
	}
}