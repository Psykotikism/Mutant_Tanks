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
	name = "[ST++] God Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains temporary immunity to all types of damage.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_GOD "God Ability"

bool g_bCloneInstalled, g_bGod[MAXPLAYERS + 1], g_bGod2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flGodChance[ST_MAXTYPES + 1], g_flGodChance2[ST_MAXTYPES + 1], g_flGodDuration[ST_MAXTYPES + 1], g_flGodDuration2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iGodAbility[ST_MAXTYPES + 1], g_iGodAbility2[ST_MAXTYPES + 1], g_iGodCount[MAXPLAYERS + 1], g_iGodMessage[ST_MAXTYPES + 1], g_iGodMessage2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] God Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_god", cmdGodInfo, "View information about the God ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveGod(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdGodInfo(int client, int args)
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
		case false: vGodMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vGodMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iGodMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("God Ability Information");
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

public int iGodMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iGodAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iGodCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "GodDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flGodDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vGodMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "GodMenu", param1);
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
	menu.AddItem(ST_MENU_GOD, ST_MENU_GOD);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_GOD, false))
	{
		vGodMenu(client, 0);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("God Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("God Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("God Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("God Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iGodAbility[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Enabled", 0);
					g_iGodAbility[iIndex] = iClamp(g_iGodAbility[iIndex], 0, 1);
					g_iGodMessage[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Message", 0);
					g_iGodMessage[iIndex] = iClamp(g_iGodMessage[iIndex], 0, 1);
					g_flGodChance[iIndex] = kvSuperTanks.GetFloat("God Ability/God Chance", 33.3);
					g_flGodChance[iIndex] = flClamp(g_flGodChance[iIndex], 0.0, 100.0);
					g_flGodDuration[iIndex] = kvSuperTanks.GetFloat("God Ability/God Duration", 5.0);
					g_flGodDuration[iIndex] = flClamp(g_flGodDuration[iIndex], 0.1, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("God Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("God Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("God Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("God Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iGodAbility2[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Enabled", g_iGodAbility[iIndex]);
					g_iGodAbility2[iIndex] = iClamp(g_iGodAbility2[iIndex], 0, 1);
					g_iGodMessage2[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Message", g_iGodMessage[iIndex]);
					g_iGodMessage2[iIndex] = iClamp(g_iGodMessage2[iIndex], 0, 1);
					g_flGodChance2[iIndex] = kvSuperTanks.GetFloat("God Ability/God Chance", g_flGodChance[iIndex]);
					g_flGodChance2[iIndex] = flClamp(g_flGodChance2[iIndex], 0.0, 100.0);
					g_flGodDuration2[iIndex] = kvSuperTanks.GetFloat("God Ability/God Duration", g_flGodDuration[iIndex]);
					g_flGodDuration2[iIndex] = flClamp(g_flGodDuration2[iIndex], 0.1, 9999999999.0);
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
		if (bIsTank(iTank, "234") && g_bGod[iTank])
		{
			SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024"))
		{
			if (g_bGod[iTank])
			{
				tTimerStopGod(null, GetClientUserId(iTank));
			}

			g_iGodCount[iTank] = 0;
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iGodAbility(tank) == 1 && !g_bGod[tank])
	{
		vGodAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iGodAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bGod[tank] && !g_bGod2[tank])
						{
							vGodAbility(tank);
						}
						else if (g_bGod[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GodHuman3");
						}
						else if (g_bGod2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GodHuman4");
						}
					}
					case 1:
					{
						if (g_iGodCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bGod[tank] && !g_bGod2[tank])
							{
								g_bGod[tank] = true;
								g_iGodCount[tank]++;

								SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "GodHuman", g_iGodCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GodAmmo");
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
			if (iGodAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bGod[tank] && !g_bGod2[tank])
				{
					g_bGod[tank] = false;

					SetEntProp(tank, Prop_Data, "m_takedamage", 2, 1);

					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		SetEntProp(tank, Prop_Data, "m_takedamage", 2, 1);
	}

	vRemoveGod(tank);
}

static void vGodAbility(int tank)
{
	if (g_iGodCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flGodChance = !g_bTankConfig[ST_TankType(tank)] ? g_flGodChance[ST_TankType(tank)] : g_flGodChance2[ST_TankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flGodChance)
		{
			g_bGod[tank] = true;

			SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);

			CreateTimer(flGodDuration(tank), tTimerStopGod, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				g_iGodCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "GodHuman", g_iGodCount[tank], iHumanAmmo(tank));
			}

			if (iGodMessage(tank) == 1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "God", sTankName);
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "GodHuman2");
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "GodAmmo");
	}
}

static void vRemoveGod(int tank)
{
	g_bGod[tank] = false;
	g_bGod2[tank] = false;
	g_iGodCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveGod(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bGod2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "GodHuman5");

	if (g_iGodCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bGod2[tank] = false;
	}
}

static float flGodDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flGodDuration[ST_TankType(tank)] : g_flGodDuration2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iGodAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGodAbility[ST_TankType(tank)] : g_iGodAbility2[ST_TankType(tank)];
}

static int iGodMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGodMessage[ST_TankType(tank)] : g_iGodMessage2[ST_TankType(tank)];
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

public Action tTimerStopGod(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bGod[iTank] = false;

		return Plugin_Stop;
	}

	g_bGod[iTank] = false;

	SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);

	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && !g_bGod2[iTank])
	{
		vReset2(iTank);
	}

	if (iGodMessage(iTank) == 1)
	{
		char sTankName[33];
		ST_TankName(iTank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "God2", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bGod2[iTank])
	{
		g_bGod2[iTank] = false;

		return Plugin_Stop;
	}

	g_bGod2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "GodHuman6");

	return Plugin_Continue;
}