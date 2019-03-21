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
#include <sdkhooks>

#undef REQUIRE_PLUGIN
#include <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Pyro Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank ignites itself and gains a speed boost when on fire.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Pyro Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_PYRO "Pyro Ability"

bool g_bCloneInstalled, g_bPyro[MAXPLAYERS + 1], g_bPyro2[MAXPLAYERS + 1], g_bPyro3[MAXPLAYERS + 1];

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flPyroChance[MT_MAXTYPES + 1], g_flPyroDamageBoost[MT_MAXTYPES + 1], g_flPyroDuration[MT_MAXTYPES + 1], g_flPyroSpeedBoost[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iHumanMode[MT_MAXTYPES + 1], g_iPyroAbility[MT_MAXTYPES + 1], g_iPyroCount[MAXPLAYERS + 1], g_iPyroMessage[MT_MAXTYPES + 1], g_iPyroMode[MT_MAXTYPES + 1];

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

	RegConsoleCmd("sm_mt_pyro", cmdPyroInfo, "View information about the Pyro ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iPyroAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iPyroCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanMode[MT_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "PyroDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flPyroDuration[MT_GetTankType(param1)]);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_PYRO, MT_MENU_PYRO);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_PYRO, false))
	{
		vPyroMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && damage > 0.0)
	{
		if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled))
		{
			if (!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim))
			{
				return Plugin_Continue;
			}

			if (g_iPyroAbility[MT_GetTankType(victim)] == 1)
			{
				if (damagetype & DMG_BURN)
				{
					switch (g_iPyroMode[MT_GetTankType(victim)])
					{
						case 0: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(victim) + g_flPyroSpeedBoost[MT_GetTankType(victim)]);
						case 1: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", g_flPyroSpeedBoost[MT_GetTankType(victim)]);
					}

					if (!g_bPyro[victim])
					{
						g_bPyro[victim] = true;

						DataPack dpPyro;
						CreateDataTimer(1.0, tTimerPyro, dpPyro, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpPyro.WriteCell(GetClientUserId(victim));
						dpPyro.WriteCell(MT_GetTankType(victim));
						dpPyro.WriteFloat(GetEngineTime());

						if (g_iPyroMessage[MT_GetTankType(victim)] == 1)
						{
							char sTankName[33];
							MT_GetTankName(victim, MT_GetTankType(victim), sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Pyro2", sTankName);
						}
					}
				}
			}
		}
		else if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled))
		{
			if (!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker))
			{
				return Plugin_Continue;
			}

			if (g_iPyroAbility[MT_GetTankType(attacker)] == 1)
			{
				if (g_bPyro[attacker])
				{
					char sClassname[32];
					GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
					if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
					{
						switch (g_iPyroMode[MT_GetTankType(attacker)])
						{
							case 0: damage += g_flPyroDamageBoost[MT_GetTankType(attacker)];
							case 1: damage = g_flPyroDamageBoost[MT_GetTankType(attacker)];
						}

						return Plugin_Changed;
					}
				}
			}
		}
	}

	return Plugin_Continue;
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

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
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
		MT_FindAbility(type, 44, bHasAbilities(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro"));
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

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && g_bPyro[iTank])
		{
			ExtinguishEntity(iTank);
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemovePyro(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iPyroAbility[MT_GetTankType(tank)] == 1 && !g_bPyro2[tank])
	{
		vPyroAbility(tank);
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
			if (g_iPyroAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[MT_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bPyro2[tank] && !g_bPyro3[tank])
						{
							vPyroAbility(tank);
						}
						else if (g_bPyro2[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman3");
						}
						else if (g_bPyro3[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman4");
						}
					}
					case 1:
					{
						if (g_iPyroCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
						{
							if (!g_bPyro2[tank] && !g_bPyro3[tank])
							{
								g_bPyro2[tank] = true;
								g_iPyroCount[tank]++;

								DataPack dpPyro2;
								CreateDataTimer(0.5, tTimerPyro2, dpPyro2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
								dpPyro2.WriteCell(GetClientUserId(tank));
								dpPyro2.WriteCell(MT_GetTankType(tank));

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman", g_iPyroCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroAmmo");
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
			if (g_iPyroAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[MT_GetTankType(tank)] == 1 && g_bPyro2[tank] && !g_bPyro3[tank])
				{
					g_bPyro2[tank] = false;

					ExtinguishEntity(tank);
					SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(tank));

					vReset2(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemovePyro(tank);
}

static void vPyroAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iPyroCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flPyroChance[MT_GetTankType(tank)])
		{
			g_bPyro2[tank] = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				g_iPyroCount[tank]++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman", g_iPyroCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
			}

			IgniteEntity(tank, g_flPyroDuration[MT_GetTankType(tank)]);

			CreateTimer(g_flPyroDuration[MT_GetTankType(tank)], tTimerStopPyro, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (g_iPyroMessage[MT_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Pyro", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroAmmo");
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
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemovePyro(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bPyro3[tank] = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman5");

	if (g_iPyroCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bPyro3[tank] = false;
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
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iAbilityFlags))
		{
			return false;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iTypeFlags))
		{
			return false;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iGlobalFlags))
		{
			return false;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientTypeFlags & iAbilityFlags))
		{
			return false;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
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
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank))
	{
		g_bPyro[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (g_iPyroAbility[MT_GetTankType(iTank)] == 0 || !bIsPlayerBurning(iTank) || ((!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_iHumanAbility[MT_GetTankType(iTank)] == 1 && g_iHumanMode[MT_GetTankType(iTank)] == 0)) && (flTime + g_flPyroDuration[MT_GetTankType(iTank)] < GetEngineTime())) || !g_bPyro[iTank])
	{
		g_bPyro[iTank] = false;

		ExtinguishEntity(iTank);
		SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(iTank));

		if (g_iPyroMessage[MT_GetTankType(iTank)] == 1)
		{
			char sTankName[33];
			MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Pyro3", sTankName);
		}

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerPyro2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || g_iPyroAbility[MT_GetTankType(iTank)] == 0 || !g_bPyro2[iTank])
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
	if (!MT_IsTankSupported(iTank) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || g_iPyroAbility[MT_GetTankType(iTank)] == 0 || !g_bPyro2[iTank])
	{
		g_bPyro2[iTank] = false;

		return Plugin_Stop;
	}

	g_bPyro2[iTank] = false;

	SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(iTank));

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && !g_bPyro3[iTank])
	{
		vReset2(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bPyro3[iTank])
	{
		g_bPyro3[iTank] = false;

		return Plugin_Stop;
	}

	g_bPyro3[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "PyroHuman6");

	return Plugin_Continue;
}