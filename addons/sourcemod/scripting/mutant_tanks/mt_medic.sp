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

#undef REQUIRE_PLUGIN
#include <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Medic Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank heals special infected upon death.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Medic Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_MEDIC "Medic Ability"

bool g_bCloneInstalled, g_bMedic[MAXPLAYERS + 1], g_bMedic2[MAXPLAYERS + 1], g_bMedic3[MAXPLAYERS + 1];

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flHumanDuration[MT_MAXTYPES + 1], g_flMedicChance[MT_MAXTYPES + 1], g_flMedicInterval[MT_MAXTYPES + 1], g_flMedicRange[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iHumanMode[MT_MAXTYPES + 1], g_iMedicAbility[MT_MAXTYPES + 1], g_iMedicCount[MAXPLAYERS + 1], g_iMedicHealth[MT_MAXTYPES + 1][8], g_iMedicMaxHealth[MT_MAXTYPES + 1][8], g_iMedicMessage[MT_MAXTYPES + 1];

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

	RegConsoleCmd("sm_mt_medic", cmdMedicInfo, "View information about the Medic ability.");
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iMedicAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iMedicCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanMode[MT_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "MedicDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flHumanDuration[MT_GetTankType(param1)]);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_MEDIC, MT_MENU_MEDIC);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_MEDIC, false))
	{
		vMedicMenu(client, 0);
	}
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

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "medicability", false) || StrEqual(subsection, "medic ability", false) || StrEqual(subsection, "medic_ability", false) || StrEqual(subsection, "medic", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		g_iHumanAbility[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 999999.0);
		g_flHumanDuration[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_flHumanDuration[type], value, 0.1, 999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iMedicAbility[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iMedicAbility[type], value, 0, 3);
		g_iMedicMessage[type] = iGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iMedicMessage[type], value, 0, 3);
		g_flMedicChance[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "MedicChance", "Medic Chance", "Medic_Chance", "chance", g_flMedicChance[type], value, 0.0, 100.0);
		g_flMedicInterval[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "MedicInterval", "Medic Interval", "Medic_Interval", "interval", g_flMedicInterval[type], value, 0.1, 999999.0);
		g_flMedicRange[type] = flGetValue(subsection, "medicability", "medic ability", "medic_ability", "medic", key, "MedicRange", "Medic Range", "Medic_Range", "range", g_flMedicRange[type], value, 1.0, 999999.0);

		if (StrEqual(subsection, "medicability", false) || StrEqual(subsection, "medic ability", false) || StrEqual(subsection, "medic_ability", false) || StrEqual(subsection, "medic", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
		}

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
					g_iMedicHealth[type][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH) : g_iMedicHealth[type][iPos];
				}
				else if (StrEqual(key, "MedicMaxHealth", false) || StrEqual(key, "Medic Max Health", false) || StrEqual(key, "Medic_Max_Health", false) || StrEqual(key, "maxhealth", false))
				{
					g_iMedicMaxHealth[type][iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXHEALTH) : g_iMedicMaxHealth[type][iPos];
				}
			}
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
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && GetRandomFloat(0.1, 100.0) <= g_flMedicChance[MT_GetTankType(iTank)] && g_bMedic3[iTank])
			{
				if (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank))
				{
					vMedicAbility(iTank, true);
				}
			}

			vRemoveMedic(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iMedicAbility[MT_GetTankType(tank)] > 0 && GetRandomFloat(0.1, 100.0) <= g_flMedicChance[MT_GetTankType(tank)])
	{
		g_bMedic3[tank] = true;

		vMedicAbility(tank, false);
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
			if ((g_iMedicAbility[MT_GetTankType(tank)] == 2 || g_iMedicAbility[MT_GetTankType(tank)] == 3) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[MT_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bMedic[tank] && !g_bMedic2[tank])
						{
							vMedicAbility(tank, false);
						}
						else if (g_bMedic[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman4");
						}
						else if (g_bMedic2[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman5");
						}
					}
					case 1:
					{
						if (g_iMedicCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
						{
							if (!g_bMedic[tank] && !g_bMedic2[tank])
							{
								g_bMedic[tank] = true;
								g_iMedicCount[tank]++;

								vMedic(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman3", g_iMedicCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SPECIAL_KEY2 == MT_SPECIAL_KEY2)
		{
			if ((g_iMedicAbility[MT_GetTankType(tank)] == 1 || g_iMedicAbility[MT_GetTankType(tank)] == 3) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_bMedic3[tank])
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman2");
					case false:
					{
						g_bMedic3[tank] = true;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman");
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
			if ((g_iMedicAbility[MT_GetTankType(tank)] == 2 || g_iMedicAbility[MT_GetTankType(tank)] == 3) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[MT_GetTankType(tank)] == 1 && g_bMedic[tank] && !g_bMedic2[tank])
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iMedicAbility[MT_GetTankType(tank)] > 0 && GetRandomFloat(0.1, 100.0) <= g_flMedicChance[MT_GetTankType(tank)])
	{
		if (MT_HasAdminAccess(tank) || bHasAdminAccess(tank))
		{
			vMedicAbility(tank, true);
		}
	}

	vRemoveMedic(tank, revert);
}

static void vMedic(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	DataPack dpMedic;
	CreateDataTimer(g_flMedicInterval[MT_GetTankType(tank)], tTimerMedic, dpMedic, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpMedic.WriteCell(GetClientUserId(tank));
	dpMedic.WriteCell(MT_GetTankType(tank));
	dpMedic.WriteFloat(GetEngineTime());
}

static void vMedicAbility(int tank, bool main)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_iMedicAbility[MT_GetTankType(tank)] == 1 || g_iMedicAbility[MT_GetTankType(tank)] == 3)
			{
				float flTankPos[3];
				GetClientAbsOrigin(tank, flTankPos);

				for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
				{
					if ((MT_IsTankSupported(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) || bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE)) && tank != iInfected)
					{
						float flInfectedPos[3];
						GetClientAbsOrigin(iInfected, flInfectedPos);

						float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
						if (flDistance <= g_flMedicRange[MT_GetTankType(tank)])
						{
							int iHealth = GetClientHealth(iInfected),
								iNewHealth = iHealth + iGetHealth(tank, iInfected),
								iExtraHealth = (iNewHealth > iGetMaxHealth(tank, iInfected)) ? iGetMaxHealth(tank, iInfected) : iNewHealth,
								iExtraHealth2 = (iNewHealth < iHealth) ? 1 : iNewHealth,
								iRealHealth = (iNewHealth >= 0) ? iExtraHealth : iExtraHealth2;
							SetEntityHealth(iInfected, iRealHealth);
							//SetEntProp(iInfected, Prop_Send, "m_iHealth", iRealHealth);
						}
					}
				}

				if (g_iMedicMessage[MT_GetTankType(tank)] & MT_MESSAGE_MELEE)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Medic", sTankName);
				}
			}
		}
		case false:
		{
			if ((g_iMedicAbility[MT_GetTankType(tank)] == 2 || g_iMedicAbility[MT_GetTankType(tank)] == 3) && !g_bMedic[tank])
			{
				if (g_iMedicCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
				{
					g_bMedic[tank] = true;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
					{
						g_iMedicCount[tank]++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman3", g_iMedicCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
					}

					vMedic(tank);

					if (g_iMedicMessage[MT_GetTankType(tank)] & MT_MESSAGE_RANGE)
					{
						char sTankName[33];
						MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Medic2", sTankName);
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
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveMedic(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bMedic[tank] = false;
	g_bMedic2[tank] = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "MedicHuman6");

	if (g_iMedicCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bMedic2[tank] = false;
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
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iAbilityFlags)) ? false : true;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iTypeFlags)) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iGlobalFlags)) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

static int iGetHealth(int tank, int infected)
{
	switch (GetEntProp(infected, Prop_Send, "m_zombieClass"))
	{
		case 1: return g_iMedicHealth[MT_GetTankType(tank)][0];
		case 2: return g_iMedicHealth[MT_GetTankType(tank)][1];
		case 3: return g_iMedicHealth[MT_GetTankType(tank)][2];
		case 4: return g_iMedicHealth[MT_GetTankType(tank)][3];
		case 5: return bIsValidGame() ? g_iMedicHealth[MT_GetTankType(tank)][4] : g_iMedicHealth[MT_GetTankType(tank)][6];
		case 6: return g_iMedicHealth[MT_GetTankType(tank)][5];
		case 8: return g_iMedicHealth[MT_GetTankType(tank)][6];
	}

	return 0;
}

static int iGetMaxHealth(int tank, int infected)
{
	switch (GetEntProp(infected, Prop_Send, "m_zombieClass"))
	{
		case 1: return g_iMedicMaxHealth[MT_GetTankType(tank)][0];
		case 2: return g_iMedicMaxHealth[MT_GetTankType(tank)][1];
		case 3: return g_iMedicMaxHealth[MT_GetTankType(tank)][2];
		case 4: return g_iMedicMaxHealth[MT_GetTankType(tank)][3];
		case 5: return bIsValidGame() ? g_iMedicMaxHealth[MT_GetTankType(tank)][4] : g_iMedicMaxHealth[MT_GetTankType(tank)][6];
		case 6: return g_iMedicMaxHealth[MT_GetTankType(tank)][5];
		case 8: return g_iMedicMaxHealth[MT_GetTankType(tank)][6];
	}

	return 0;
}

public Action tTimerMedic(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || (g_iMedicAbility[MT_GetTankType(iTank)] != 2 && g_iMedicAbility[MT_GetTankType(iTank)] != 3) || !g_bMedic[iTank])
	{
		g_bMedic[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && g_iHumanMode[MT_GetTankType(iTank)] == 0 && (flTime + g_flHumanDuration[MT_GetTankType(iTank)]) < GetEngineTime() && !g_bMedic2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	float flTankPos[3];
	GetClientAbsOrigin(iTank, flTankPos);

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if ((MT_IsTankSupported(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) || bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE)) && iTank != iInfected)
		{
			float flInfectedPos[3];
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= g_flMedicRange[MT_GetTankType(iTank)])
			{
				int iHealth = GetClientHealth(iInfected),
					iNewHealth = iHealth + iGetHealth(iTank, iInfected),
					iExtraHealth = (iNewHealth > iGetMaxHealth(iTank, iInfected)) ? iGetMaxHealth(iTank, iInfected) : iNewHealth,
					iExtraHealth2 = (iNewHealth < iHealth) ? 1 : iNewHealth,
					iRealHealth = (iNewHealth >= 0) ? iExtraHealth : iExtraHealth2;
				//SetEntityHealth(iInfected, iRealHealth);
				SetEntProp(iInfected, Prop_Send, "m_iHealth", iRealHealth);
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bMedic2[iTank])
	{
		g_bMedic2[iTank] = false;

		return Plugin_Stop;
	}

	g_bMedic2[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "MedicHuman7");

	return Plugin_Continue;
}