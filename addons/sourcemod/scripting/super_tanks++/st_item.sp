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

bool g_bCloneInstalled, g_bItem[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sItemLoadout[ST_MAXTYPES + 1][325], g_sItemLoadout2[ST_MAXTYPES + 1][325];

float g_flItemChance[ST_MAXTYPES + 1], g_flItemChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iItemAbility[ST_MAXTYPES + 1], g_iItemAbility2[ST_MAXTYPES + 1], g_iItemMessage[ST_MAXTYPES + 1], g_iItemMessage2[ST_MAXTYPES + 1], g_iItemMode[ST_MAXTYPES + 1], g_iItemMode2[ST_MAXTYPES + 1];

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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iItemAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons4");
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ItemDetails");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Item Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iItemAbility[iIndex] = kvSuperTanks.GetNum("Item Ability/Ability Enabled", 0);
					g_iItemAbility[iIndex] = iClamp(g_iItemAbility[iIndex], 0, 1);
					g_iItemMessage[iIndex] = kvSuperTanks.GetNum("Item Ability/Ability Message", 0);
					g_iItemMessage[iIndex] = iClamp(g_iItemMessage[iIndex], 0, 1);
					g_flItemChance[iIndex] = kvSuperTanks.GetFloat("Item Ability/Item Chance", 33.3);
					g_flItemChance[iIndex] = flClamp(g_flItemChance[iIndex], 0.0, 100.0);
					kvSuperTanks.GetString("Item Ability/Item Loadout", g_sItemLoadout[iIndex], sizeof(g_sItemLoadout[]), "rifle, pistol, first_aid_kit, pain_pills");
					g_iItemMode[iIndex] = kvSuperTanks.GetNum("Item Ability/Item Mode", 0);
					g_iItemMode[iIndex] = iClamp(g_iItemMode[iIndex], 0, 1);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Item Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iItemAbility2[iIndex] = kvSuperTanks.GetNum("Item Ability/Ability Enabled", g_iItemAbility[iIndex]);
					g_iItemAbility2[iIndex] = iClamp(g_iItemAbility2[iIndex], 0, 1);
					g_iItemMessage2[iIndex] = kvSuperTanks.GetNum("Item Ability/Ability Message", g_iItemMessage[iIndex]);
					g_iItemMessage2[iIndex] = iClamp(g_iItemMessage2[iIndex], 0, 1);
					g_flItemChance2[iIndex] = kvSuperTanks.GetFloat("Item Ability/Item Chance", g_flItemChance[iIndex]);
					g_flItemChance2[iIndex] = flClamp(g_flItemChance2[iIndex], 0.0, 100.0);
					kvSuperTanks.GetString("Item Ability/Item Loadout", g_sItemLoadout2[iIndex], sizeof(g_sItemLoadout2[]), g_sItemLoadout[iIndex]);
					g_iItemMode2[iIndex] = kvSuperTanks.GetNum("Item Ability/Item Mode", g_iItemMode[iIndex]);
					g_iItemMode2[iIndex] = iClamp(g_iItemMode2[iIndex], 0, 1);
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
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && ST_IsCloneSupported(iTank, g_bCloneInstalled) && iItemAbility(iTank) == 1 && GetRandomFloat(0.1, 100.0) <= flItemChance(iTank) && g_bItem[iTank])
		{
			vItemAbility(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iItemAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flItemChance(tank) && !g_bItem[tank])
	{
		g_bItem[tank] = true;
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY2 == ST_SPECIAL_KEY2)
		{
			if (iItemAbility(tank) == 1 && iHumanAbility(tank) == 1)
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

public void ST_OnChangeType(int tank)
{
	if (ST_IsTankSupported(tank) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iItemAbility(tank) == 1)
	{
		vItemAbility(tank);
	}
}

static void vItemAbility(int tank)
{
	g_bItem[tank] = false;

	char sItems[5][64], sItemLoadout[325];
	sItemLoadout = !g_bTankConfig[ST_GetTankType(tank)] ? g_sItemLoadout[ST_GetTankType(tank)] : g_sItemLoadout2[ST_GetTankType(tank)];
	ReplaceString(sItemLoadout, sizeof(sItemLoadout), " ", "");
	ExplodeString(sItemLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
		{
			int iItemMode = !g_bTankConfig[ST_GetTankType(tank)] ? g_iItemMode[ST_GetTankType(tank)] : g_iItemMode2[ST_GetTankType(tank)];
			switch (iItemMode)
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
						if (StrContains(sItemLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
						{
							vCheatCommand(iSurvivor, "give", sItems[iItem]);
						}
					}
				}
			}
		}
	}

	int iItemMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_iItemMessage[ST_GetTankType(tank)] : g_iItemMessage2[ST_GetTankType(tank)];
	if (iItemMessage == 1)
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

static float flItemChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flItemChance[ST_GetTankType(tank)] : g_flItemChance2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iItemAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iItemAbility[ST_GetTankType(tank)] : g_iItemAbility2[ST_GetTankType(tank)];
}