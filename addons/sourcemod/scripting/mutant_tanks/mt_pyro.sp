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

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bPyro;
	bool g_bPyro2;
	bool g_bPyro3;

	int g_iAccessFlags2;
	int g_iPyroCount;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flPyroChance;
	float g_flPyroDamageBoost;
	float g_flPyroDuration;
	float g_flPyroSpeedBoost;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanMode;
	int g_iPyroAbility;
	int g_iPyroMessage;
	int g_iPyroMode;
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

	RegConsoleCmd("sm_mt_pyro", cmdPyroInfo, "View information about the Pyro ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
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

public void OnClientDisconnect_Post(int client)
{
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

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iPyroAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iPyroCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "PyroDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flPyroDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
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
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled))
		{
			if (!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim))
			{
				return Plugin_Continue;
			}

			if (g_esAbility[MT_GetTankType(victim)].g_iPyroAbility == 1)
			{
				if (damagetype & DMG_BURN)
				{
					switch (g_esAbility[MT_GetTankType(victim)].g_iPyroMode)
					{
						case 0: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(victim) + g_esAbility[MT_GetTankType(victim)].g_flPyroSpeedBoost);
						case 1: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", g_esAbility[MT_GetTankType(victim)].g_flPyroSpeedBoost);
					}

					if (!g_esPlayer[victim].g_bPyro)
					{
						g_esPlayer[victim].g_bPyro = true;

						DataPack dpPyro;
						CreateDataTimer(1.0, tTimerPyro, dpPyro, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpPyro.WriteCell(GetClientUserId(victim));
						dpPyro.WriteCell(MT_GetTankType(victim));
						dpPyro.WriteFloat(GetEngineTime());

						if (g_esAbility[MT_GetTankType(victim)].g_iPyroMessage == 1)
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

			if (g_esAbility[MT_GetTankType(attacker)].g_iPyroAbility == 1)
			{
				if (g_esPlayer[attacker].g_bPyro)
				{
					char sClassname[32];
					GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
					if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
					{
						switch (g_esAbility[MT_GetTankType(attacker)].g_iPyroMode)
						{
							case 0: damage += g_esAbility[MT_GetTankType(attacker)].g_flPyroDamageBoost;
							case 1: damage = g_esAbility[MT_GetTankType(attacker)].g_flPyroDamageBoost;
						}

						return Plugin_Changed;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("pyroability");
	list2.PushString("pyro ability");
	list3.PushString("pyro_ability");
	list4.PushString("pyro");
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
			g_esAbility[iIndex].g_iHumanMode = 1;
			g_esAbility[iIndex].g_iPyroAbility = 0;
			g_esAbility[iIndex].g_iPyroMessage = 0;
			g_esAbility[iIndex].g_flPyroChance = 33.3;
			g_esAbility[iIndex].g_flPyroDamageBoost = 1.0;
			g_esAbility[iIndex].g_flPyroDuration = 5.0;
			g_esAbility[iIndex].g_iPyroMode = 0;
			g_esAbility[iIndex].g_flPyroSpeedBoost = 1.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "pyroability", false) || StrEqual(subsection, "pyro ability", false) || StrEqual(subsection, "pyro_ability", false) || StrEqual(subsection, "pyro", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iPyroAbility = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iPyroAbility, value, 0, 1);
		g_esAbility[type].g_iPyroMessage = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iPyroMessage, value, 0, 1);
		g_esAbility[type].g_flPyroChance = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroChance", "Pyro Chance", "Pyro_Chance", "chance", g_esAbility[type].g_flPyroChance, value, 0.0, 100.0);
		g_esAbility[type].g_flPyroDamageBoost = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroDamageBoost", "Pyro Damage Boost", "Pyro_Damage_Boost", "dmgboost", g_esAbility[type].g_flPyroDamageBoost, value, 0.1, 999999.0);
		g_esAbility[type].g_flPyroDuration = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroDuration", "Pyro Duration", "Pyro_Duration", "duration", g_esAbility[type].g_flPyroDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iPyroMode = iGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "Pyro Mode", "PyroMode", "Pyro_Mode", "mode", g_esAbility[type].g_iPyroMode, value, 0, 1);
		g_esAbility[type].g_flPyroSpeedBoost = flGetValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroSpeedBoost", "Pyro Speed Boost", "Pyro_Speed_Boost", "speedboost", g_esAbility[type].g_flPyroSpeedBoost, value, 0.1, 3.0);

		if (StrEqual(subsection, "pyroability", false) || StrEqual(subsection, "pyro ability", false) || StrEqual(subsection, "pyro_ability", false) || StrEqual(subsection, "pyro", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iAccessFlags;
			}
		}
	}
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iTank].g_bPyro)
		{
			ExtinguishEntity(iTank);
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
			vRemovePyro(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility != 1) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iPyroAbility == 1 && !g_esPlayer[tank].g_bPyro2)
	{
		vPyroAbility(tank);
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
			if (g_esAbility[MT_GetTankType(tank)].g_iPyroAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esAbility[MT_GetTankType(tank)].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bPyro2 && !g_esPlayer[tank].g_bPyro3)
						{
							vPyroAbility(tank);
						}
						else if (g_esPlayer[tank].g_bPyro2)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman3");
						}
						else if (g_esPlayer[tank].g_bPyro3)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman4");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iPyroCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bPyro2 && !g_esPlayer[tank].g_bPyro3)
							{
								g_esPlayer[tank].g_bPyro2 = true;
								g_esPlayer[tank].g_iPyroCount++;

								DataPack dpPyro2;
								CreateDataTimer(0.5, tTimerPyro2, dpPyro2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
								dpPyro2.WriteCell(GetClientUserId(tank));
								dpPyro2.WriteCell(MT_GetTankType(tank));

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman", g_esPlayer[tank].g_iPyroCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bPyro2)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman3");
							}
							else if (g_esPlayer[tank].g_bPyro3)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman4");
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
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iPyroAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (g_esAbility[MT_GetTankType(tank)].g_iHumanMode == 1 && g_esPlayer[tank].g_bPyro2 && !g_esPlayer[tank].g_bPyro3)
				{
					g_esPlayer[tank].g_bPyro2 = false;

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

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iPyroCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esAbility[MT_GetTankType(tank)].g_flPyroChance)
		{
			g_esPlayer[tank].g_bPyro2 = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iPyroCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman", g_esPlayer[tank].g_iPyroCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
			}

			IgniteEntity(tank, g_esAbility[MT_GetTankType(tank)].g_flPyroDuration);

			CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flPyroDuration, tTimerStopPyro, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (g_esAbility[MT_GetTankType(tank)].g_iPyroMessage == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Pyro", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroAmmo");
	}
}

static void vRemovePyro(int tank)
{
	g_esPlayer[tank].g_bPyro = false;
	g_esPlayer[tank].g_bPyro2 = false;
	g_esPlayer[tank].g_bPyro3 = false;
	g_esPlayer[tank].g_iPyroCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemovePyro(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bPyro3 = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman5");

	if (g_esPlayer[tank].g_iPyroCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bPyro3 = false;
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

public Action tTimerPyro(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank))
	{
		g_esPlayer[iTank].g_bPyro = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (g_esAbility[MT_GetTankType(iTank)].g_iPyroAbility == 0 || !bIsPlayerBurning(iTank) || ((!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0)) && (flTime + g_esAbility[MT_GetTankType(iTank)].g_flPyroDuration < GetEngineTime())) || !g_esPlayer[iTank].g_bPyro)
	{
		g_esPlayer[iTank].g_bPyro = false;

		ExtinguishEntity(iTank);
		SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(iTank));

		if (g_esAbility[MT_GetTankType(iTank)].g_iPyroMessage == 1)
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
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || g_esAbility[MT_GetTankType(iTank)].g_iPyroAbility == 0 || !g_esPlayer[iTank].g_bPyro2)
	{
		g_esPlayer[iTank].g_bPyro2 = false;

		return Plugin_Stop;
	}

	IgniteEntity(iTank, 1.0);

	return Plugin_Continue;
}

public Action tTimerStopPyro(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || g_esAbility[MT_GetTankType(iTank)].g_iPyroAbility == 0 || !g_esPlayer[iTank].g_bPyro2)
	{
		g_esPlayer[iTank].g_bPyro2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bPyro2 = false;

	SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(iTank));

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && !g_esPlayer[iTank].g_bPyro3)
	{
		vReset2(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bPyro3)
	{
		g_esPlayer[iTank].g_bPyro3 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bPyro3 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "PyroHuman6");

	return Plugin_Continue;
}