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
#include <sdkhooks>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Fragile Ability",
	author = ST_AUTHOR,
	description = "The Super Tank takes more damage.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Fragile Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_FRAGILE "Fragile Ability"

bool g_bCloneInstalled, g_bFragile[MAXPLAYERS + 1], g_bFragile2[MAXPLAYERS + 1];

float g_flFragileBulletMultiplier[ST_MAXTYPES + 1], g_flFragileChance[ST_MAXTYPES + 1], g_flFragileDuration[ST_MAXTYPES + 1], g_flFragileExplosiveMultiplier[ST_MAXTYPES + 1], g_flFragileFireMultiplier[ST_MAXTYPES + 1], g_flFragileMeleeMultiplier[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iFragileAbility[ST_MAXTYPES + 1], g_iFragileCount[MAXPLAYERS + 1], g_iFragileMessage[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_fragile", cmdFragileInfo, "View information about the Fragile ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveFragile(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFragileInfo(int client, int args)
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
		case false: vFragileMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFragileMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFragileMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fragile Ability Information");
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

public int iFragileMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iFragileAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iFragileCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "FragileDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flFragileDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vFragileMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "FragileMenu", param1);
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
	menu.AddItem(ST_MENU_FRAGILE, ST_MENU_FRAGILE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_FRAGILE, false))
	{
		vFragileMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && g_bFragile[victim])
		{
			if (damagetype & DMG_BULLET)
			{
				damage *= g_flFragileBulletMultiplier[ST_GetTankType(victim)];
			}
			else if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
			{
				damage *= g_flFragileExplosiveMultiplier[ST_GetTankType(victim)];
			}
			else if (damagetype & DMG_BURN)
			{
				damage *= g_flFragileFireMultiplier[ST_GetTankType(victim)];
			}
			else if (damagetype & DMG_SLASH || damagetype & DMG_CLUB)
			{
				damage *= g_flFragileMeleeMultiplier[ST_GetTankType(victim)];
			}

			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iHumanMode[iIndex] = 1;
		g_iFragileAbility[iIndex] = 0;
		g_iFragileMessage[iIndex] = 0;
		g_flFragileBulletMultiplier[iIndex] = 5.0;
		g_flFragileChance[iIndex] = 33.3;
		g_flFragileDuration[iIndex] = 5.0;
		g_flFragileExplosiveMultiplier[iIndex] = 5.0;
		g_flFragileFireMultiplier[iIndex] = 3.0;
		g_flFragileMeleeMultiplier[iIndex] = 1.5;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 19, bHasAbilities(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile"));
	g_iHumanAbility[type] = iGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iHumanMode[type] = iGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", main, g_iHumanMode[type], value, 1, 0, 1);
	g_iFragileAbility[type] = iGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iFragileAbility[type], value, 0, 0, 1);
	g_iFragileMessage[type] = iGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iFragileMessage[type], value, 0, 0, 1);
	g_flFragileBulletMultiplier[type] = flGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "FragileBulletMultiplier", "Fragile Bullet Multiplier", "Fragile_Bullet_Multiplier", "bullet", main, g_flFragileBulletMultiplier[type], value, 5.0, 1.0, 9999999999.0);
	g_flFragileChance[type] = flGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "FragileChance", "Fragile Chance", "Fragile_Chance", "chance", main, g_flFragileChance[type], value, 33.3, 0.0, 100.0);
	g_flFragileDuration[type] = flGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "FragileDuration", "Fragile Duration", "Fragile_Duration", "duration", main, g_flFragileDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_flFragileExplosiveMultiplier[type] = flGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "FragileExplosiveMultiplier", "Fragile Explosive Multiplier", "Fragile_Explosive_Multiplier", "explosive", main, g_flFragileExplosiveMultiplier[type], value, 5.0, 1.0, 9999999999.0);
	g_flFragileFireMultiplier[type] = flGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "FragileFireMultiplier", "Fragile Fire Multiplier", "Fragile_Fire_Multiplier", "fire", main, g_flFragileFireMultiplier[type], value, 3.0, 1.0, 9999999999.0);
	g_flFragileMeleeMultiplier[type] = flGetValue(subsection, "fragileability", "fragile ability", "fragile_ability", "fragile", key, "FragileMeleeMultiplier", "Fragile Melee Multiplier", "Fragile_Melee_Multiplier", "melee", main, g_flFragileMeleeMultiplier[type], value, 1.5, 1.0, 9999999999.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveFragile(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iFragileAbility[ST_GetTankType(tank)] == 1 && !g_bFragile[tank])
	{
		vFragileAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iFragileAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bFragile[tank] && !g_bFragile2[tank])
						{
							vFragileAbility(tank);
						}
						else if (g_bFragile[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "FragileHuman3");
						}
						else if (g_bFragile2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "FragileHuman4");
						}
					}
					case 1:
					{
						if (g_iFragileCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bFragile[tank] && !g_bFragile2[tank])
							{
								g_bFragile[tank] = true;
								g_iFragileCount[tank]++;

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "FragileHuman", g_iFragileCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "FragileAmmo");
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
			if (g_iFragileAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bFragile[tank] && !g_bFragile2[tank])
				{
					g_bFragile[tank] = false;

					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveFragile(tank);
}

static void vFragileAbility(int tank)
{
	if (g_iFragileCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flFragileChance[ST_GetTankType(tank)])
		{
			g_bFragile[tank] = true;

			CreateTimer(g_flFragileDuration[ST_GetTankType(tank)], tTimerStopFragile, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				g_iFragileCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "FragileHuman", g_iFragileCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
			}

			if (g_iFragileMessage[ST_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Fragile", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "FragileHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "FragileAmmo");
	}
}

static void vRemoveFragile(int tank)
{
	g_bFragile[tank] = false;
	g_bFragile2[tank] = false;
	g_iFragileCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveFragile(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bFragile2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "FragileHuman5");

	if (g_iFragileCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bFragile2[tank] = false;
	}
}

public Action tTimerStopFragile(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bFragile[iTank])
	{
		g_bFragile[iTank] = false;

		return Plugin_Stop;
	}

	g_bFragile[iTank] = false;

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && !g_bFragile2[iTank])
	{
		vReset2(iTank);
	}

	if (g_iFragileMessage[ST_GetTankType(iTank)] == 1)
	{
		char sTankName[33];
		ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Fragile2", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bFragile2[iTank])
	{
		g_bFragile2[iTank] = false;

		return Plugin_Stop;
	}

	g_bFragile2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "FragileHuman6");

	return Plugin_Continue;
}