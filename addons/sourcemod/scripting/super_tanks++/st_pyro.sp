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
	name = "[ST++] Pyro Ability",
	author = ST_AUTHOR,
	description = "The Super Tank ignites itself and gains a speed boost when on fire.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Pyro Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_PYRO "Pyro Ability"

bool g_bCloneInstalled, g_bPyro[MAXPLAYERS + 1], g_bPyro2[MAXPLAYERS + 1], g_bPyro3[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flPyroChance[ST_MAXTYPES + 1], g_flPyroDamageBoost[ST_MAXTYPES + 1], g_flPyroDuration[ST_MAXTYPES + 1], g_flPyroSpeedBoost[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iPyroAbility[ST_MAXTYPES + 1], g_iPyroCount[MAXPLAYERS + 1], g_iPyroMessage[ST_MAXTYPES + 1], g_iPyroMode[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_pyro", cmdPyroInfo, "View information about the Pyro ability.");

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

	vRemovePyro(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdPyroInfo(int client, int args)
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
		case false: vPyroMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vPyroMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iPyroMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Pyro Ability Information");
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

public int iPyroMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iPyroAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iPyroCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "PyroDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flPyroDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vPyroMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "PyroMenu", param1);
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
	menu.AddItem(ST_MENU_PYRO, ST_MENU_PYRO);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_PYRO, false))
	{
		vPyroMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled))
		{
			if (!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim))
			{
				return Plugin_Continue;
			}

			if (g_iPyroAbility[ST_GetTankType(victim)] == 1)
			{
				if (damagetype & DMG_BURN)
				{
					switch (g_iPyroMode[ST_GetTankType(victim)])
					{
						case 0: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", ST_GetRunSpeed(victim) + g_flPyroSpeedBoost[ST_GetTankType(victim)]);
						case 1: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", g_flPyroSpeedBoost[ST_GetTankType(victim)]);
					}

					if (!g_bPyro[victim])
					{
						g_bPyro[victim] = true;

						DataPack dpPyro;
						CreateDataTimer(1.0, tTimerPyro, dpPyro, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpPyro.WriteCell(GetClientUserId(victim));
						dpPyro.WriteCell(ST_GetTankType(victim));
						dpPyro.WriteFloat(GetEngineTime());

						if (g_iPyroMessage[ST_GetTankType(victim)] == 1)
						{
							char sTankName[33];
							ST_GetTankName(victim, ST_GetTankType(victim), sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Pyro2", sTankName);
						}
					}
				}
			}
		}
		else if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled))
		{
			if (!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker))
			{
				return Plugin_Continue;
			}

			if (g_iPyroAbility[ST_GetTankType(attacker)] == 1)
			{
				if (g_bPyro[attacker])
				{
					char sClassname[32];
					GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
					if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
					{
						switch (g_iPyroMode[ST_GetTankType(attacker)])
						{
							case 0: damage += g_flPyroDamageBoost[ST_GetTankType(attacker)];
							case 1: damage = g_flPyroDamageBoost[ST_GetTankType(attacker)];
						}

						return Plugin_Changed;
					}
				}
			}
		}
	}

	return Plugin_Continue;
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
		g_iPyroAbility[iIndex] = 0;
		g_iPyroMessage[iIndex] = 0;
		g_flPyroChance[iIndex] = 33.3;
		g_flPyroDamageBoost[iIndex] = 1.0;
		g_flPyroDuration[iIndex] = 5.0;
		g_iPyroMode[iIndex] = 0;
		g_flPyroSpeedBoost[iIndex] = 1.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "pyroability", false) || StrEqual(subsection, "pyro ability", false) || StrEqual(subsection, "pyro_ability", false) || StrEqual(subsection, "pyro", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		ST_FindAbility(type, 44, bHasAbilities(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro"));
		g_iHumanAbility[type] = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iPyroAbility[type] = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iPyroAbility[type], value, 0, 1);
		g_iPyroMessage[type] = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iPyroMessage[type], value, 0, 1);
		g_flPyroChance[type] = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroChance", "Pyro Chance", "Pyro_Chance", "chance", g_flPyroChance[type], value, 0.0, 100.0);
		g_flPyroDamageBoost[type] = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroDamageBoost", "Pyro Damage Boost", "Pyro_Damage_Boost", "dmgboost", g_flPyroDamageBoost[type], value, 0.1, 9999999999.0);
		g_flPyroDuration[type] = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroDuration", "Pyro Duration", "Pyro_Duration", "duration", g_flPyroDuration[type], value, 0.1, 9999999999.0);
		g_iPyroMode[type] = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "Pyro Mode", "PyroMode", "Pyro_Mode", "mode", g_iPyroMode[type], value, 0, 1);
		g_flPyroSpeedBoost[type] = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroSpeedBoost", "Pyro Speed Boost", "Pyro_Speed_Boost", "speedboost", g_flPyroSpeedBoost[type], value, 0.1, 3.0);

		if (StrEqual(subsection, "pyroability", false) || StrEqual(subsection, "pyro ability", false) || StrEqual(subsection, "pyro_ability", false) || StrEqual(subsection, "pyro", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
		}
	}
}

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bPyro[iTank])
		{
			ExtinguishEntity(iTank);
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
			vRemovePyro(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iPyroAbility[ST_GetTankType(tank)] == 1 && !g_bPyro2[tank])
	{
		vPyroAbility(tank);
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
			if (g_iPyroAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bPyro2[tank] && !g_bPyro3[tank])
						{
							vPyroAbility(tank);
						}
						else if (g_bPyro2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman3");
						}
						else if (g_bPyro3[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman4");
						}
					}
					case 1:
					{
						if (g_iPyroCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bPyro2[tank] && !g_bPyro3[tank])
							{
								g_bPyro2[tank] = true;
								g_iPyroCount[tank]++;

								DataPack dpPyro2;
								CreateDataTimer(0.5, tTimerPyro2, dpPyro2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
								dpPyro2.WriteCell(GetClientUserId(tank));
								dpPyro2.WriteCell(ST_GetTankType(tank));

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman", g_iPyroCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroAmmo");
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
			if (g_iPyroAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bPyro2[tank] && !g_bPyro3[tank])
				{
					g_bPyro2[tank] = false;

					ExtinguishEntity(tank);
					SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", ST_GetRunSpeed(tank));

					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemovePyro(tank);
}

static void vPyroAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iPyroCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flPyroChance[ST_GetTankType(tank)])
		{
			g_bPyro2[tank] = true;

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				g_iPyroCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman", g_iPyroCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
			}

			IgniteEntity(tank, g_flPyroDuration[ST_GetTankType(tank)]);

			CreateTimer(g_flPyroDuration[ST_GetTankType(tank)], tTimerStopPyro, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (g_iPyroMessage[ST_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Pyro", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroAmmo");
	}
}

static void vRemovePyro(int tank)
{
	g_bPyro[tank] = false;
	g_bPyro2[tank] = false;
	g_bPyro3[tank] = false;
	g_iPyroCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemovePyro(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bPyro3[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman5");

	if (g_iPyroCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bPyro3[tank] = false;
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT))
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

public Action tTimerPyro(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank))
	{
		g_bPyro[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (g_iPyroAbility[ST_GetTankType(iTank)] == 0 || !bIsPlayerBurning(iTank) || ((!ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) || (g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0)) && (flTime + g_flPyroDuration[ST_GetTankType(iTank)] < GetEngineTime())) || !g_bPyro[iTank])
	{
		g_bPyro[iTank] = false;

		ExtinguishEntity(iTank);
		SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", ST_GetRunSpeed(iTank));

		if (g_iPyroMessage[ST_GetTankType(iTank)] == 1)
		{
			char sTankName[33];
			ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Pyro3", sTankName);
		}

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerPyro2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || g_iPyroAbility[ST_GetTankType(iTank)] == 0 || !g_bPyro2[iTank])
	{
		g_bPyro2[iTank] = false;

		return Plugin_Stop;
	}

	IgniteEntity(iTank, 1.0);

	return Plugin_Continue;
}

public Action tTimerStopPyro(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || g_iPyroAbility[ST_GetTankType(iTank)] == 0 || !g_bPyro2[iTank])
	{
		g_bPyro2[iTank] = false;

		return Plugin_Stop;
	}

	g_bPyro2[iTank] = false;

	SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", ST_GetRunSpeed(iTank));

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && (ST_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && !g_bPyro3[iTank])
	{
		vReset2(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bPyro3[iTank])
	{
		g_bPyro3[iTank] = false;

		return Plugin_Stop;
	}

	g_bPyro3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "PyroHuman6");

	return Plugin_Continue;
}