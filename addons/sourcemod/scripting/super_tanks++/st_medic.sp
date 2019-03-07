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
	name = "[ST++] Medic Ability",
	author = ST_AUTHOR,
	description = "The Super Tank heals special infected upon death.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Medic Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ST_MENU_MEDIC "Medic Ability"

bool g_bCloneInstalled, g_bMedic[MAXPLAYERS + 1], g_bMedic2[MAXPLAYERS + 1], g_bMedic3[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flMedicChance[ST_MAXTYPES + 1], g_flMedicInterval[ST_MAXTYPES + 1], g_flMedicRange[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iMedicAbility[ST_MAXTYPES + 1], g_iMedicCount[MAXPLAYERS + 1], g_iMedicHealth[ST_MAXTYPES + 1][8], g_iMedicMaxHealth[ST_MAXTYPES + 1][8], g_iMedicMessage[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_medic", cmdMedicInfo, "View information about the Medic ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveMedic(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdMedicInfo(int client, int args)
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
		case false: vMedicMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vMedicMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iMedicMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Medic Ability Information");
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

public int iMedicMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iMedicAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iMedicCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons4");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "MedicDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flHumanDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vMedicMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "MedicMenu", param1);
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
	menu.AddItem(ST_MENU_MEDIC, ST_MENU_MEDIC);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_MEDIC, false))
	{
		vMedicMenu(client, 0);
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_flHumanDuration[iIndex] = 5.0;
		g_iHumanMode[iIndex] = 1;
		g_iMedicAbility[iIndex] = 0;
		g_iMedicMessage[iIndex] = 0;
		g_flMedicChance[iIndex] = 33.3;
		g_flMedicInterval[iIndex] = 5.0;
		g_iMedicMaxHealth[iIndex][0] = 250;
		g_iMedicMaxHealth[iIndex][1] = 50;
		g_iMedicMaxHealth[iIndex][2] = 250;
		g_iMedicMaxHealth[iIndex][3] = 100;
		g_iMedicMaxHealth[iIndex][4] = 325;
		g_iMedicMaxHealth[iIndex][5] = 600;
		g_iMedicMaxHealth[iIndex][6] = 8000;
		g_flMedicRange[iIndex] = 500.0;

		for (int iPos = 0; iPos < 6; iPos++)
		{
			g_iMedicHealth[iIndex][iPos] = 25;
		}
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 35, bHasAbilities(subsection, "medicability", "medic ability", "medic_ability", "medic"));
	g_iHumanAbility[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_flHumanDuration[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", main, g_flHumanDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iHumanMode[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", main, g_iHumanMode[type], value, 1, 0, 1);
	g_iMedicAbility[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iMedicAbility[type], value, 0, 0, 3);
	g_iMedicMessage[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iMedicMessage[type], value, 0, 0, 3);
	g_flMedicChance[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "MedicChance", "Medic Chance", "Medic_Chance", "chance", main, g_flMedicChance[type], value, 33.3, 0.0, 100.0);
	g_flMedicInterval[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "MedicInterval", "Medic Interval", "Medic_Interval", "interval", main, g_flMedicInterval[type], value, 5.0, 0.1, 9999999999.0);
	g_flMedicRange[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "MedicRange", "Medic Range", "Medic_Range", "range", main, g_flMedicRange[type], value, 500.0, 1.0, 9999999999.0);

	if ((StrEqual(subsection, "medicability", false) || StrEqual(subsection, "medic ability", false) || StrEqual(subsection, "medic_ability", false) || StrEqual(subsection, "medic", false)) && value[0] != '\0')
	{
		char sSet[7][6], sValue[42];
		strcopy(sValue, sizeof(sValue), value);
		ReplaceString(sValue, sizeof(sValue), " ", "");
		ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

		for (int iPos = 0; iPos < 7; iPos++)
		{
			if (StrEqual(key, "MedicHealth", false) || StrEqual(key, "Medic Health", false) || StrEqual(key, "Medic_Health", false) || StrEqual(key, "health", false))
			{
				g_iMedicHealth[type][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH) : g_iMedicHealth[type][iPos];
			}
			else if (StrEqual(key, "MedicMaxHealth", false) || StrEqual(key, "Medic Max Health", false) || StrEqual(key, "Medic_Max_Health", false) || StrEqual(key, "maxhealth", false))
			{
				g_iMedicMaxHealth[type][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, ST_MAXHEALTH) : g_iMedicMaxHealth[type][iPos];
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
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && GetRandomFloat(0.1, 100.0) <= g_flMedicChance[ST_GetTankType(iTank)] && g_bMedic3[iTank])
			{
				vMedicAbility(iTank, true);
			}

			vRemoveMedic(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iMedicAbility[ST_GetTankType(tank)] > 0 && GetRandomFloat(0.1, 100.0) <= g_flMedicChance[ST_GetTankType(tank)])
	{
		g_bMedic3[tank] = true;

		vMedicAbility(tank, false);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((g_iMedicAbility[ST_GetTankType(tank)] == 2 || g_iMedicAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bMedic[tank] && !g_bMedic2[tank])
						{
							vMedicAbility(tank, false);
						}
						else if (g_bMedic[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicHuman4");
						}
						else if (g_bMedic2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicHuman5");
						}
					}
					case 1:
					{
						if (g_iMedicCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bMedic[tank] && !g_bMedic2[tank])
							{
								g_bMedic[tank] = true;
								g_iMedicCount[tank]++;

								vMedic(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicHuman3", g_iMedicCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicAmmo");
						}
					}
				}
			}
		}

		if (button & ST_SPECIAL_KEY2 == ST_SPECIAL_KEY2)
		{
			if ((g_iMedicAbility[ST_GetTankType(tank)] == 1 || g_iMedicAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bMedic3[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicHuman2");
					case false:
					{
						g_bMedic3[tank] = true;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicHuman");
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
			if ((g_iMedicAbility[ST_GetTankType(tank)] == 2 || g_iMedicAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bMedic[tank] && !g_bMedic2[tank])
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	if (ST_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iMedicAbility[ST_GetTankType(tank)] > 0 && GetRandomFloat(0.1, 100.0) <= g_flMedicChance[ST_GetTankType(tank)])
	{
		vMedicAbility(tank, true);
	}

	vRemoveMedic(tank, revert);
}

static void vMedic(int tank)
{
	DataPack dpMedic;
	CreateDataTimer(g_flMedicInterval[ST_GetTankType(tank)], tTimerMedic, dpMedic, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpMedic.WriteCell(GetClientUserId(tank));
	dpMedic.WriteCell(ST_GetTankType(tank));
	dpMedic.WriteFloat(GetEngineTime());
}

static void vMedicAbility(int tank, bool main)
{
	switch (main)
	{
		case true:
		{
			if (g_iMedicAbility[ST_GetTankType(tank)] == 1 || g_iMedicAbility[ST_GetTankType(tank)] == 3)
			{
				float flTankPos[3];
				GetClientAbsOrigin(tank, flTankPos);

				for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
				{
					if ((ST_IsTankSupported(iInfected, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) || bIsSpecialInfected(iInfected, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE)) && tank != iInfected)
					{
						float flInfectedPos[3];
						GetClientAbsOrigin(iInfected, flInfectedPos);

						float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
						if (flDistance <= g_flMedicRange[ST_GetTankType(tank)])
						{
							int iHealth = GetClientHealth(iInfected),
								iNewHealth = iHealth + iGetHealth(tank, iInfected),
								iExtraHealth = (iNewHealth > iGetMaxHealth(tank, iInfected)) ? iGetMaxHealth(tank, iInfected) : iNewHealth,
								iExtraHealth2 = (iNewHealth < iHealth) ? 1 : iNewHealth,
								iRealHealth = (iNewHealth >= 0) ? iExtraHealth : iExtraHealth2;
							SetEntityHealth(iInfected, iRealHealth);
						}
					}
				}

				if (g_iMedicMessage[ST_GetTankType(tank)] & ST_MESSAGE_MELEE)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Medic", sTankName);
				}
			}
		}
		case false:
		{
			if ((g_iMedicAbility[ST_GetTankType(tank)] == 2 || g_iMedicAbility[ST_GetTankType(tank)] == 3) && !g_bMedic[tank])
			{
				if (g_iMedicCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
				{
					g_bMedic[tank] = true;

					if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
					{
						g_iMedicCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicHuman3", g_iMedicCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
					}

					vMedic(tank);

					if (g_iMedicMessage[ST_GetTankType(tank)] & ST_MESSAGE_RANGE)
					{
						char sTankName[33];
						ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Medic2", sTankName);
					}
				}
			}
		}
	}
}

static void vRemoveMedic(int tank, bool revert = false)
{
	if (!revert)
	{
		g_bMedic3[tank] = false;
	}

	g_bMedic[tank] = false;
	g_bMedic2[tank] = false;
	g_iMedicCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveMedic(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bMedic[tank] = false;
	g_bMedic2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicHuman6");

	if (g_iMedicCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bMedic2[tank] = false;
	}
}

static int iGetHealth(int tank, int infected)
{
	switch (GetEntProp(infected, Prop_Send, "m_zombieClass"))
	{
		case 1: return g_iMedicHealth[ST_GetTankType(tank)][0];
		case 2: return g_iMedicHealth[ST_GetTankType(tank)][1];
		case 3: return g_iMedicHealth[ST_GetTankType(tank)][2];
		case 4: return g_iMedicHealth[ST_GetTankType(tank)][3];
		case 5: return bIsValidGame() ? g_iMedicHealth[ST_GetTankType(tank)][4] : g_iMedicHealth[ST_GetTankType(tank)][6];
		case 6: return g_iMedicHealth[ST_GetTankType(tank)][5];
		case 8: return g_iMedicHealth[ST_GetTankType(tank)][6];
	}

	return 0;
}

static int iGetMaxHealth(int tank, int infected)
{
	switch (GetEntProp(infected, Prop_Send, "m_zombieClass"))
	{
		case 1: return g_iMedicMaxHealth[ST_GetTankType(tank)][0];
		case 2: return g_iMedicMaxHealth[ST_GetTankType(tank)][1];
		case 3: return g_iMedicMaxHealth[ST_GetTankType(tank)][2];
		case 4: return g_iMedicMaxHealth[ST_GetTankType(tank)][3];
		case 5: return bIsValidGame() ? g_iMedicMaxHealth[ST_GetTankType(tank)][4] : g_iMedicMaxHealth[ST_GetTankType(tank)][6];
		case 6: return g_iMedicMaxHealth[ST_GetTankType(tank)][5];
		case 8: return g_iMedicMaxHealth[ST_GetTankType(tank)][6];
	}

	return 0;
}

public Action tTimerMedic(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || (g_iMedicAbility[ST_GetTankType(iTank)] != 2 && g_iMedicAbility[ST_GetTankType(iTank)] != 3) || !g_bMedic[iTank])
	{
		g_bMedic[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && (flTime + g_flHumanDuration[ST_GetTankType(iTank)]) < GetEngineTime() && !g_bMedic2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	float flTankPos[3];
	GetClientAbsOrigin(iTank, flTankPos);

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if ((ST_IsTankSupported(iInfected, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) || bIsSpecialInfected(iInfected, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE)) && iTank != iInfected)
		{
			float flInfectedPos[3];
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= g_flMedicRange[ST_GetTankType(iTank)])
			{
				int iHealth = GetClientHealth(iInfected),
					iNewHealth = iHealth + iGetHealth(iTank, iInfected),
					iExtraHealth = (iNewHealth > iGetMaxHealth(iTank, iInfected)) ? iGetMaxHealth(iTank, iInfected) : iNewHealth,
					iExtraHealth2 = (iNewHealth < iHealth) ? 1 : iNewHealth,
					iRealHealth = (iNewHealth >= 0) ? iExtraHealth : iExtraHealth2;
				SetEntityHealth(iInfected, iRealHealth);
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bMedic2[iTank])
	{
		g_bMedic2[iTank] = false;

		return Plugin_Stop;
	}

	g_bMedic2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "MedicHuman7");

	return Plugin_Continue;
}