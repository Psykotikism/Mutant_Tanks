/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <sdkhooks>
#include <mutant_tanks>

#undef REQUIRE_PLUGIN
#tryinclude <mt_clone>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Zombie Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank spawns zombies.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Zombie Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_ZOMBIE "Zombie Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bZombie;
	bool g_bZombie2;

	int g_iAccessFlags2;
	int g_iZombieCount;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flHumanDuration;
	float g_flZombieChance;
	float g_flZombieInterval;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanMode;
	int g_iZombieAbility;
	int g_iZombieAmount;
	int g_iZombieMessage;
}

esAbilitySettings g_esAbility[MT_MAXTYPES + 1];

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

	RegConsoleCmd("sm_mt_zombie", cmdZombieInfo, "View information about the Zombie ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveZombie(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveZombie(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdZombieInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vZombieMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vZombieMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iZombieMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Zombie Ability Information");
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

public int iZombieMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iZombieAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iZombieCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ZombieDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vZombieMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ZombieMenu", param1);
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
	menu.AddItem(MT_MENU_ZOMBIE, MT_MENU_ZOMBIE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ZOMBIE, false))
	{
		vZombieMenu(client, 0);
	}
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("zombieability");
	list2.PushString("zombie ability");
	list3.PushString("zombie_ability");
	list4.PushString("zombie");
}

public void MT_OnConfigsLoad(int mode)
{
	if (mode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				g_esPlayer[iPlayer].g_iAccessFlags2 = 0;
			}
		}
	}
	else if (mode == 1)
	{
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			g_esAbility[iIndex].g_iAccessFlags = 0;
			g_esAbility[iIndex].g_iHumanAbility = 0;
			g_esAbility[iIndex].g_iHumanAmmo = 5;
			g_esAbility[iIndex].g_flHumanCooldown = 30.0;
			g_esAbility[iIndex].g_flHumanDuration = 5.0;
			g_esAbility[iIndex].g_iHumanMode = 1;
			g_esAbility[iIndex].g_iZombieAbility = 0;
			g_esAbility[iIndex].g_iZombieMessage = 0;
			g_esAbility[iIndex].g_iZombieAmount = 10;
			g_esAbility[iIndex].g_flZombieChance = 33.3;
			g_esAbility[iIndex].g_flZombieInterval = 5.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "zombieability", false) || StrEqual(subsection, "zombie ability", false) || StrEqual(subsection, "zombie_ability", false) || StrEqual(subsection, "zombie", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_flHumanDuration = flGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_flHumanDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iZombieAbility = iGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iZombieAbility, value, 0, 1);
		g_esAbility[type].g_iZombieMessage = iGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iZombieMessage, value, 0, 1);
		g_esAbility[type].g_iZombieAmount = iGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "ZombieAmount", "Zombie Amount", "Zombie_Amount", "amount", g_esAbility[type].g_iZombieAmount, value, 1, 100);
		g_esAbility[type].g_flZombieChance = flGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "ZombieChance", "Zombie Chance", "Zombie_Chance", "chance", g_esAbility[type].g_flZombieChance, value, 0.0, 100.0);
		g_esAbility[type].g_flZombieInterval = flGetValue(subsection, "zombieability", "zombie ability", "zombie_ability", "zombie", key, "ZombieInterval", "Zombie Interval", "Zombie_Interval", "interval", g_esAbility[type].g_flZombieInterval, value, 0.1, 999999.0);

		if (StrEqual(subsection, "zombieability", false) || StrEqual(subsection, "zombie ability", false) || StrEqual(subsection, "zombie_ability", false) || StrEqual(subsection, "zombie", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iAccessFlags;
			}
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveZombie(iTank);

			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(iTank)].g_iZombieAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esAbility[MT_GetTankType(iTank)].g_flZombieChance)
			{
				if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && ((MT_HasAdminAccess(iTank) && bHasAdminAccess(iTank)) || g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 0))
				{
					return;
				}

				vZombie(iTank);
			}
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility != 1) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iZombieAbility == 1 && !g_esPlayer[tank].g_bZombie)
	{
		vZombieAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iZombieAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esAbility[MT_GetTankType(tank)].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bZombie && !g_esPlayer[tank].g_bZombie2)
						{
							vZombieAbility(tank);
						}
						else if (g_esPlayer[tank].g_bZombie)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieHuman3");
						}
						else if (g_esPlayer[tank].g_bZombie2)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieHuman4");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iZombieCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bZombie && !g_esPlayer[tank].g_bZombie2)
							{
								g_esPlayer[tank].g_bZombie = true;
								g_esPlayer[tank].g_iZombieCount++;

								vZombie2(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieHuman", g_esPlayer[tank].g_iZombieCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bZombie)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieHuman3");
							}
							else if (g_esPlayer[tank].g_bZombie2)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieHuman4");
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iZombieAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (g_esAbility[MT_GetTankType(tank)].g_iHumanMode == 1 && g_esPlayer[tank].g_bZombie && !g_esPlayer[tank].g_bZombie2)
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveZombie(tank);
}

static void vRemoveZombie(int tank)
{
	g_esPlayer[tank].g_bZombie = false;
	g_esPlayer[tank].g_bZombie2 = false;
	g_esPlayer[tank].g_iZombieCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveZombie(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bZombie = false;
	g_esPlayer[tank].g_bZombie2 = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieHuman5");

	if (g_esPlayer[tank].g_iZombieCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bZombie2 = false;
	}
}

static void vZombie(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	for (int iZombie = 1; iZombie <= g_esAbility[MT_GetTankType(tank)].g_iZombieAmount; iZombie++)
	{
		vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "zombie area");
	}
}

static void vZombie2(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	DataPack dpZombie;
	CreateDataTimer(g_esAbility[MT_GetTankType(tank)].g_flZombieInterval, tTimerZombie, dpZombie, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpZombie.WriteCell(GetClientUserId(tank));
	dpZombie.WriteCell(MT_GetTankType(tank));
	dpZombie.WriteFloat(GetEngineTime());
}

static void vZombieAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iZombieCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esAbility[MT_GetTankType(tank)].g_flZombieChance)
		{
			g_esPlayer[tank].g_bZombie = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iZombieCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieHuman", g_esPlayer[tank].g_iZombieCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
			}

			vZombie2(tank);

			if (g_esAbility[MT_GetTankType(tank)].g_iZombieMessage == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Zombie", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ZombieAmmo");
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_esAbility[MT_GetTankType(admin)].g_iAccessFlags;
	if (iAbilityFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iAbilityFlags)) ? false : true;
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iTypeFlags)) ? false : true;
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iGlobalFlags)) ? false : true;
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

public Action tTimerZombie(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !MT_IsCorePluginEnabled() || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || g_esAbility[MT_GetTankType(iTank)].g_iZombieAbility == 0 || !g_esPlayer[iTank].g_bZombie)
	{
		g_esPlayer[iTank].g_bZombie = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0 && (flTime + g_esAbility[MT_GetTankType(iTank)].g_flHumanDuration) < GetEngineTime() && !g_esPlayer[iTank].g_bZombie2)
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	vZombie(iTank);

	if (g_esAbility[MT_GetTankType(iTank)].g_iZombieMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Zombie2", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bZombie2)
	{
		g_esPlayer[iTank].g_bZombie2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bZombie2 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ZombieHuman6");

	return Plugin_Continue;
}