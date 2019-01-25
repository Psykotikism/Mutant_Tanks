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

#define ST_MENU_PYRO "Pyro Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bPyro[MAXPLAYERS + 1], g_bPyro2[MAXPLAYERS + 1], g_bPyro3[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flPyroChance[ST_MAXTYPES + 1], g_flPyroChance2[ST_MAXTYPES + 1], g_flPyroDamageBoost[ST_MAXTYPES + 1], g_flPyroDamageBoost2[ST_MAXTYPES + 1], g_flPyroDuration[ST_MAXTYPES + 1], g_flPyroDuration2[ST_MAXTYPES + 1], g_flPyroSpeedBoost[ST_MAXTYPES + 1], g_flPyroSpeedBoost2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iPyroAbility[ST_MAXTYPES + 1], g_iPyroAbility2[ST_MAXTYPES + 1], g_iPyroCount[MAXPLAYERS + 1], g_iPyroMessage[ST_MAXTYPES + 1], g_iPyroMessage2[ST_MAXTYPES + 1], g_iPyroMode[ST_MAXTYPES + 1], g_iPyroMode2[ST_MAXTYPES + 1];

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
			if (bIsValidClient(iPlayer, "24"))
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

	if (!bIsValidClient(client, "0245"))
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iPyroAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iPyroCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "PyroDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flPyroDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled))
		{
			if (iPyroAbility(victim) == 1)
			{
				if (damagetype & DMG_BURN)
				{
					float flPyroSpeedBoost = !g_bTankConfig[ST_GetTankType(victim)] ? g_flPyroSpeedBoost[ST_GetTankType(victim)] : g_flPyroSpeedBoost2[ST_GetTankType(victim)];
					switch (iPyroMode(victim))
					{
						case 0: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", ST_GetRunSpeed(victim) + flPyroSpeedBoost);
						case 1: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", flPyroSpeedBoost);
					}

					if (!g_bPyro[victim])
					{
						g_bPyro[victim] = true;

						DataPack dpPyro;
						CreateDataTimer(1.0, tTimerPyro, dpPyro, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpPyro.WriteCell(GetClientUserId(victim));
						dpPyro.WriteCell(ST_GetTankType(victim));
						dpPyro.WriteFloat(GetEngineTime());

						if (iPyroMessage(victim) == 1)
						{
							char sTankName[33];
							ST_GetTankName(victim, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Pyro2", sTankName);
						}
					}
				}
			}
		}
		else if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled))
		{
			if (iPyroAbility(attacker) == 1)
			{
				if (g_bPyro[attacker])
				{
					char sClassname[32];
					GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
					if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
					{
						float flPyroDamageBoost = !g_bTankConfig[ST_GetTankType(attacker)] ? g_flPyroDamageBoost[ST_GetTankType(attacker)] : g_flPyroDamageBoost2[ST_GetTankType(attacker)];
						switch (iPyroMode(attacker))
						{
							case 0: damage += flPyroDamageBoost;
							case 1: damage = flPyroDamageBoost;
						}

						return Plugin_Changed;
					}
				}
			}
		}
	}

	return Plugin_Continue;
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iPyroAbility[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", 0);
					g_iPyroAbility[iIndex] = iClamp(g_iPyroAbility[iIndex], 0, 1);
					g_iPyroMessage[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Message", 0);
					g_iPyroMessage[iIndex] = iClamp(g_iPyroMessage[iIndex], 0, 1);
					g_flPyroChance[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Chance", 33.3);
					g_flPyroChance[iIndex] = flClamp(g_flPyroChance[iIndex], 0.0, 100.0);
					g_flPyroDamageBoost[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Damage Boost", 1.0);
					g_flPyroDamageBoost[iIndex] = flClamp(g_flPyroDamageBoost[iIndex], 0.1, 9999999999.0);
					g_flPyroDuration[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Duration", 5.0);
					g_flPyroDuration[iIndex] = flClamp(g_flPyroDuration[iIndex], 0.1, 9999999999.0);
					g_iPyroMode[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Mode", 0);
					g_iPyroMode[iIndex] = iClamp(g_iPyroMode[iIndex], 0, 1);
					g_flPyroSpeedBoost[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Speed Boost", 1.0);
					g_flPyroSpeedBoost[iIndex] = flClamp(g_flPyroSpeedBoost[iIndex], 0.1, 3.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iPyroAbility2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", g_iPyroAbility[iIndex]);
					g_iPyroAbility2[iIndex] = iClamp(g_iPyroAbility2[iIndex], 0, 1);
					g_iPyroMessage2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Message", g_iPyroMessage[iIndex]);
					g_iPyroMessage2[iIndex] = iClamp(g_iPyroMessage2[iIndex], 0, 1);
					g_flPyroChance2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Chance", g_flPyroChance[iIndex]);
					g_flPyroChance2[iIndex] = flClamp(g_flPyroChance2[iIndex], 0.0, 100.0);
					g_flPyroDamageBoost2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Damage Boost", g_flPyroDamageBoost[iIndex]);
					g_flPyroDamageBoost2[iIndex] = flClamp(g_flPyroDamageBoost2[iIndex], 0.1, 9999999999.0);
					g_flPyroDuration2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Duration", g_flPyroDuration[iIndex]);
					g_flPyroDuration2[iIndex] = flClamp(g_flPyroDuration2[iIndex], 0.1, 9999999999.0);
					g_iPyroMode2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Mode", g_iPyroMode[iIndex]);
					g_iPyroMode2[iIndex] = iClamp(g_iPyroMode2[iIndex], 0, 1);
					g_flPyroSpeedBoost2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Speed Boost", g_flPyroSpeedBoost[iIndex]);
					g_flPyroSpeedBoost2[iIndex] = flClamp(g_flPyroSpeedBoost2[iIndex], 0.1, 3.0);
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
		if (bIsTank(iTank, "234") && g_bPyro[iTank])
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
		if (ST_IsTankSupported(iTank, "024"))
		{
			vRemovePyro(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iPyroAbility(tank) == 1 && !g_bPyro2[tank])
	{
		vPyroAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iPyroAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
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
						if (g_iPyroCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bPyro2[tank] && !g_bPyro3[tank])
							{
								g_bPyro2[tank] = true;
								g_iPyroCount[tank]++;

								DataPack dpPyro2;
								CreateDataTimer(0.5, tTimerPyro2, dpPyro2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
								dpPyro2.WriteCell(GetClientUserId(tank));
								dpPyro2.WriteCell(ST_GetTankType(tank));

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman", g_iPyroCount[tank], iHumanAmmo(tank));
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
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iPyroAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bPyro2[tank] && !g_bPyro3[tank])
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

public void ST_OnChangeType(int tank)
{
	vRemovePyro(tank);
}

static void vPyroAbility(int tank)
{
	if (g_iPyroCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flPyroChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flPyroChance[ST_GetTankType(tank)] : g_flPyroChance2[ST_GetTankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flPyroChance)
		{
			g_bPyro2[tank] = true;

			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				g_iPyroCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman", g_iPyroCount[tank], iHumanAmmo(tank));
			}

			IgniteEntity(tank, flPyroDuration(tank));

			CreateTimer(flPyroDuration(tank), tTimerStopPyro, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (iPyroMessage(tank) == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Pyro", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
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
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemovePyro(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bPyro3[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "PyroHuman5");

	if (g_iPyroCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bPyro3[tank] = false;
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flPyroDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flPyroDuration[ST_GetTankType(tank)] : g_flPyroDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iHumanMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanMode[ST_GetTankType(tank)] : g_iHumanMode2[ST_GetTankType(tank)];
}

static int iPyroAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iPyroAbility[ST_GetTankType(tank)] : g_iPyroAbility2[ST_GetTankType(tank)];
}

static int iPyroMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iPyroMessage[ST_GetTankType(tank)] : g_iPyroMessage2[ST_GetTankType(tank)];
}

static int iPyroMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iPyroMode[ST_GetTankType(tank)] : g_iPyroMode2[ST_GetTankType(tank)];
}

public Action tTimerPyro(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank))
	{
		g_bPyro[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (iPyroAbility(iTank) == 0 || !bIsPlayerBurning(iTank) || ((!ST_IsTankSupported(iTank, "5") || (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0)) && (flTime + flPyroDuration(iTank) < GetEngineTime())) || !g_bPyro[iTank])
	{
		g_bPyro[iTank] = false;

		ExtinguishEntity(iTank);
		SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", ST_GetRunSpeed(iTank));

		if (iPyroMessage(iTank) == 1)
		{
			char sTankName[33];
			ST_GetTankName(iTank, sTankName);
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
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || iPyroAbility(iTank) == 0 || !g_bPyro2[iTank])
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
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iPyroAbility(iTank) == 0 || !g_bPyro2[iTank])
	{
		g_bPyro2[iTank] = false;

		return Plugin_Stop;
	}

	g_bPyro2[iTank] = false;

	SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", ST_GetRunSpeed(iTank));

	if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && !g_bPyro3[iTank])
	{
		vReset2(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bPyro3[iTank])
	{
		g_bPyro3[iTank] = false;

		return Plugin_Stop;
	}

	g_bPyro3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "PyroHuman6");

	return Plugin_Continue;
}