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
	name = "[ST++] Medic Ability",
	author = ST_AUTHOR,
	description = "The Super Tank heals special infected upon death.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_MEDIC "Medic Ability"

bool g_bCloneInstalled, g_bMedic[MAXPLAYERS + 1], g_bMedic2[MAXPLAYERS + 1], g_bMedic3[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sMedicHealth[ST_MAXTYPES + 1][36], g_sMedicHealth2[ST_MAXTYPES + 1][36], g_sMedicMaxHealth[ST_MAXTYPES + 1][36], g_sMedicMaxHealth2[ST_MAXTYPES + 1][36], g_sMedicMessage[ST_MAXTYPES + 1][3], g_sMedicMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flHumanDuration2[ST_MAXTYPES + 1], g_flMedicChance[ST_MAXTYPES + 1], g_flMedicChance2[ST_MAXTYPES + 1], g_flMedicInterval[ST_MAXTYPES + 1], g_flMedicInterval2[ST_MAXTYPES + 1], g_flMedicRange[ST_MAXTYPES + 1], g_flMedicRange2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iMedicAbility[ST_MAXTYPES + 1], g_iMedicAbility2[ST_MAXTYPES + 1], g_iMedicCount[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Medic Ability\" only supports Left 4 Dead 1 & 2.");

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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iMedicAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iMedicCount[param1], iHumanAmmo(param1));
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons4");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "MedicDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flHumanDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Medic Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Medic Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Human Duration", 5.0);
					g_flHumanDuration[iIndex] = flClamp(g_flHumanDuration[iIndex], 0.1, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Medic Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iMedicAbility[iIndex] = kvSuperTanks.GetNum("Medic Ability/Ability Enabled", 0);
					g_iMedicAbility[iIndex] = iClamp(g_iMedicAbility[iIndex], 0, 3);
					kvSuperTanks.GetString("Medic Ability/Ability Message", g_sMedicMessage[iIndex], sizeof(g_sMedicMessage[]), "0");
					g_flMedicChance[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Chance", 33.3);
					g_flMedicChance[iIndex] = flClamp(g_flMedicChance[iIndex], 0.0, 100.0);
					kvSuperTanks.GetString("Medic Ability/Medic Health", g_sMedicHealth[iIndex], sizeof(g_sMedicHealth[]), "25,25,25,25,25,25");
					g_flMedicInterval[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Interval", 5.0);
					g_flMedicInterval[iIndex] = flClamp(g_flMedicInterval[iIndex], 0.1, 9999999999.0);
					kvSuperTanks.GetString("Medic Ability/Medic Max Health", g_sMedicMaxHealth[iIndex], sizeof(g_sMedicMaxHealth[]), "250,50,250,100,325,600");
					g_flMedicRange[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Range", 500.0);
					g_flMedicRange[iIndex] = flClamp(g_flMedicRange[iIndex], 1.0, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Medic Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Medic Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration2[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Human Duration", g_flHumanDuration[iIndex]);
					g_flHumanDuration2[iIndex] = flClamp(g_flHumanDuration2[iIndex], 0.1, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Medic Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iMedicAbility2[iIndex] = kvSuperTanks.GetNum("Medic Ability/Ability Enabled", g_iMedicAbility[iIndex]);
					g_iMedicAbility2[iIndex] = iClamp(g_iMedicAbility2[iIndex], 0, 3);
					kvSuperTanks.GetString("Medic Ability/Ability Message", g_sMedicMessage2[iIndex], sizeof(g_sMedicMessage2[]), g_sMedicMessage[iIndex]);
					g_flMedicChance2[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Chance", g_flMedicChance[iIndex]);
					g_flMedicChance2[iIndex] = flClamp(g_flMedicChance2[iIndex], 0.0, 100.0);
					kvSuperTanks.GetString("Medic Ability/Medic Health", g_sMedicHealth2[iIndex], sizeof(g_sMedicHealth2[]), g_sMedicHealth[iIndex]);
					g_flMedicInterval2[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Interval", g_flMedicInterval[iIndex]);
					g_flMedicInterval2[iIndex] = flClamp(g_flMedicInterval2[iIndex], 0.1, 9999999999.0);
					kvSuperTanks.GetString("Medic Ability/Medic Max Health", g_sMedicMaxHealth2[iIndex], sizeof(g_sMedicMaxHealth2[]), g_sMedicMaxHealth[iIndex]);
					g_flMedicRange2[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Range", g_flMedicRange[iIndex]);
					g_flMedicRange2[iIndex] = flClamp(g_flMedicRange2[iIndex], 1.0, 9999999999.0);
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
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			if (GetRandomFloat(0.1, 100.0) <= flMedicChance(iTank) && g_bMedic3[iTank])
			{
				vMedicAbility(iTank, true);
			}

			vRemoveMedic(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iMedicAbility(tank) > 0 && GetRandomFloat(0.1, 100.0) <= flMedicChance(tank))
	{
		g_bMedic3[tank] = true;

		vMedicAbility(tank, false);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iMedicAbility(tank) == 2 || iMedicAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
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
						if (g_iMedicCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bMedic[tank] && !g_bMedic2[tank])
							{
								g_bMedic[tank] = true;
								g_iMedicCount[tank]++;

								vMedic(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicHuman3", g_iMedicCount[tank], iHumanAmmo(tank));
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
			if ((iMedicAbility(tank) == 1 || iMedicAbility(tank) == 3) && iHumanAbility(tank) == 1)
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
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iMedicAbility(tank) == 2 || iMedicAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bMedic[tank] && !g_bMedic2[tank])
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && iMedicAbility(tank) > 0 && GetRandomFloat(0.1, 100.0) <= flMedicChance(tank))
	{
		vMedicAbility(tank, true);
	}

	vRemoveMedic(tank);
}

static void vHeal(int infected, int health, int extrahealth, int maxhealth)
{
	maxhealth = iClamp(maxhealth, 1, ST_MAXHEALTH);

	int iExtraHealth = (extrahealth > maxhealth) ? maxhealth : extrahealth,
		iExtraHealth2 = (extrahealth < health) ? 1 : extrahealth,
		iRealHealth = (extrahealth >= 0) ? iExtraHealth : iExtraHealth2;

	SetEntityHealth(infected, iRealHealth);
}

static void vMedic(int tank)
{
	float flMedicInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flMedicInterval[ST_TankType(tank)] : g_flMedicInterval2[ST_TankType(tank)];
	DataPack dpMedic;
	CreateDataTimer(flMedicInterval, tTimerMedic, dpMedic, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpMedic.WriteCell(GetClientUserId(tank));
	dpMedic.WriteFloat(GetEngineTime());
}

static void vMedicAbility(int tank, bool main)
{
	switch (main)
	{
		case true:
		{
			if (iMedicAbility(tank) == 1 || iMedicAbility(tank) == 3)
			{
				float flTankPos[3];
				GetClientAbsOrigin(tank, flTankPos);

				for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
				{
					if (bIsSpecialInfected(iInfected, "234"))
					{
						float flInfectedPos[3];
						GetClientAbsOrigin(iInfected, flInfectedPos);

						float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
						if (flDistance <= flMedicRange(tank))
						{
							char sHealth[6][6], sMedicHealth[36], sMaxHealth[6][6], sMedicMaxHealth[36];

							sMedicHealth = !g_bTankConfig[ST_TankType(tank)] ? g_sMedicHealth[ST_TankType(tank)] : g_sMedicHealth2[ST_TankType(tank)];
							ReplaceString(sMedicHealth, sizeof(sMedicHealth), " ", "");
							ExplodeString(sMedicHealth, ",", sHealth, sizeof(sHealth), sizeof(sHealth[]));

							sMedicMaxHealth = !g_bTankConfig[ST_TankType(tank)] ? g_sMedicMaxHealth[ST_TankType(tank)] : g_sMedicMaxHealth2[ST_TankType(tank)];
							ReplaceString(sMedicMaxHealth, sizeof(sMedicMaxHealth), " ", "");
							ExplodeString(sMedicMaxHealth, ",", sMaxHealth, sizeof(sMaxHealth), sizeof(sMaxHealth[]));

							int iHealth = GetClientHealth(iInfected),
								iSmokerHealth = (sHealth[0][0] != '\0') ? StringToInt(sHealth[0]) : 25,
								iSmokerMaxHealth = (sMaxHealth[0][0] != '\0') ? StringToInt(sMaxHealth[0]) : 250,
								iBoomerHealth = (sHealth[1][0] != '\0') ? StringToInt(sHealth[1]) : 25,
								iBoomerMaxHealth = (sMaxHealth[1][0] != '\0') ? StringToInt(sMaxHealth[1]) : 50,
								iHunterHealth = (sHealth[2][0] != '\0') ? StringToInt(sHealth[2]) : 25,
								iHunterMaxHealth = (sMaxHealth[2][0] != '\0') ? StringToInt(sMaxHealth[2]) : 250,
								iSpitterHealth = (sHealth[3][0] != '\0') ? StringToInt(sHealth[3]) : 25,
								iSpitterMaxHealth = (sMaxHealth[3][0] != '\0') ? StringToInt(sMaxHealth[3]) : 100,
								iJockeyHealth = (sHealth[4][0] != '\0') ? StringToInt(sHealth[4]) : 25,
								iJockeyMaxHealth = (sMaxHealth[4][0] != '\0') ? StringToInt(sMaxHealth[4]) : 325,
								iChargerHealth = (sHealth[5][0] != '\0') ? StringToInt(sHealth[5]) : 25,
								iChargerMaxHealth = (sMaxHealth[5][0] != '\0') ? StringToInt(sMaxHealth[5]) : 600;

							iSmokerHealth = iClamp(iSmokerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
							iSmokerMaxHealth = iClamp(iSmokerMaxHealth, 1, ST_MAXHEALTH);

							iBoomerHealth = iClamp(iBoomerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
							iBoomerMaxHealth = iClamp(iBoomerMaxHealth, 1, ST_MAXHEALTH);

							iHunterHealth = iClamp(iHunterHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
							iHunterMaxHealth = iClamp(iHunterMaxHealth, 1, ST_MAXHEALTH);

							iSpitterHealth = iClamp(iSpitterHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
							iSpitterMaxHealth = iClamp(iSpitterMaxHealth, 1, ST_MAXHEALTH);

							iJockeyHealth = iClamp(iJockeyHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
							iJockeyMaxHealth = iClamp(iJockeyMaxHealth, 1, ST_MAXHEALTH);

							iChargerHealth = iClamp(iChargerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
							iChargerMaxHealth = iClamp(iChargerMaxHealth, 1, ST_MAXHEALTH);

							switch (GetEntProp(tank, Prop_Send, "m_zombieClass"))
							{
								case 1: vHeal(iInfected, iHealth, iHealth + iSmokerHealth, iSmokerMaxHealth);
								case 2: vHeal(iInfected, iHealth, iHealth + iBoomerHealth, iBoomerMaxHealth);
								case 3: vHeal(iInfected, iHealth, iHealth + iHunterHealth, iHunterMaxHealth);
								case 4: vHeal(iInfected, iHealth, iHealth + iSpitterHealth, iSpitterMaxHealth);
								case 5: vHeal(iInfected, iHealth, iHealth + iJockeyHealth, iJockeyMaxHealth);
								case 6: vHeal(iInfected, iHealth, iHealth + iChargerHealth, iChargerMaxHealth);
							}
						}
					}
				}

				char sMedicMessage[3];
				sMedicMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sMedicMessage[ST_TankType(tank)] : g_sMedicMessage2[ST_TankType(tank)];
				if (StrContains(sMedicMessage, "1"))
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Medic", sTankName);
				}
			}
		}
		case false:
		{
			if ((iMedicAbility(tank) == 2 || iMedicAbility(tank) == 3) && !g_bMedic[tank])
			{
				if (g_iMedicCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
				{
					g_bMedic[tank] = true;

					if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
					{
						g_iMedicCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "MedicHuman3", g_iMedicCount[tank], iHumanAmmo(tank));

						vMedic(tank);

						char sMedicMessage[3];
						sMedicMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sMedicMessage[ST_TankType(tank)] : g_sMedicMessage2[ST_TankType(tank)];
						if (StrContains(sMedicMessage, "2"))
						{
							char sTankName[33];
							ST_TankName(tank, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Medic2", sTankName);
						}
					}
				}
			}
		}
	}
}

static void vRemoveMedic(int tank)
{
	g_bMedic[tank] = false;
	g_bMedic2[tank] = false;
	g_bMedic3[tank] = false;
	g_iMedicCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
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

	if (g_iMedicCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bMedic2[tank] = false;
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flHumanDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanDuration[ST_TankType(tank)] : g_flHumanDuration2[ST_TankType(tank)];
}

static float flMedicChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flMedicChance[ST_TankType(tank)] : g_flMedicChance2[ST_TankType(tank)];
}

static float flMedicRange(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flMedicRange[ST_TankType(tank)] : g_flMedicRange2[ST_TankType(tank)];
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

static int iMedicAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iMedicAbility[ST_TankType(tank)] : g_iMedicAbility2[ST_TankType(tank)];
}

public Action tTimerMedic(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || (iMedicAbility(iTank) != 2 && iMedicAbility(iTank) != 3) || !g_bMedic[iTank])
	{
		g_bMedic[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && (flTime + flHumanDuration(iTank)) < GetEngineTime() && !g_bMedic2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	float flTankPos[3];
	GetClientAbsOrigin(iTank, flTankPos);

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected, "234"))
		{
			float flInfectedPos[3];
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= flMedicRange(iTank))
			{
				int iHealth = GetClientHealth(iInfected),
					iNewHealth = iHealth + 1,
					iFinalHealth = (iNewHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth;

				SetEntityHealth(iInfected, iFinalHealth);
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bMedic2[iTank])
	{
		g_bMedic2[iTank] = false;

		return Plugin_Stop;
	}

	g_bMedic2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "MedicHuman7");

	return Plugin_Continue;
}