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
	name = "[MT] Car Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates car showers.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Car Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"

#define MT_MENU_CAR "Car Ability"

bool g_bCar[MAXPLAYERS + 1], g_bCar2[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flCarChance[MT_MAXTYPES + 1], g_flCarDuration[MT_MAXTYPES + 1], g_flCarRadius[MT_MAXTYPES + 1][2], g_flHumanCooldown[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iCarAbility[MT_MAXTYPES + 1], g_iCarCount[MAXPLAYERS + 1], g_iCarMessage[MT_MAXTYPES + 1], g_iCarOptions[MT_MAXTYPES + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iHumanMode[MT_MAXTYPES + 1];

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

	RegConsoleCmd("sm_mt_car", cmdCarInfo, "View information about the Car ability.");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_CAR, true);
	PrecacheModel(MODEL_CAR2, true);
	PrecacheModel(MODEL_CAR3, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveCar(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdCarInfo(int client, int args)
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
		case false: vCarMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vCarMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iCarMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Car Ability Information");
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

public int iCarMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iCarAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iCarCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanMode[MT_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "CarDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flCarDuration[MT_GetTankType(param1)]);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				vCarMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "CarMenu", param1);
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
	menu.AddItem(MT_MENU_CAR, MT_MENU_CAR);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_CAR, false))
	{
		vCarMenu(client, 0);
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
		g_iHumanMode[iIndex] = 1;
		g_iCarAbility[iIndex] = 0;
		g_iCarMessage[iIndex] = 0;
		g_flCarChance[iIndex] = 33.3;
		g_flCarDuration[iIndex] = 5.0;
		g_iCarOptions[iIndex] = 0;
		g_flCarRadius[iIndex][0] = -180.0;
		g_flCarRadius[iIndex][1] = 180.0;
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "carability", false) || StrEqual(subsection, "car ability", false) || StrEqual(subsection, "car_ability", false) || StrEqual(subsection, "car", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		MT_FindAbility(type, 7, bHasAbilities(subsection, "carability", "car ability", "car_ability", "car"));
		g_iHumanAbility[type] = iGetValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iCarAbility[type] = iGetValue(subsection, "carability", "car ability", "car_ability", "car", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iCarAbility[type], value, 0, 1);
		g_iCarMessage[type] = iGetValue(subsection, "carability", "car ability", "car_ability", "car", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iCarMessage[type], value, 0, 1);
		g_flCarChance[type] = flGetValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarChance", "Car Chance", "Car_Chance", "chance", g_flCarChance[type], value, 0.0, 100.0);
		g_flCarDuration[type] = flGetValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarDuration", "Car Duration", "Car_Duration", "duration", g_flCarDuration[type], value, 0.1, 9999999999.0);
		g_iCarOptions[type] = iGetValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarOptions", "Car Options", "Car_Options", "options", g_iCarOptions[type], value, 0, 7);

		if (StrEqual(subsection, "carability", false) || StrEqual(subsection, "car ability", false) || StrEqual(subsection, "car_ability", false) || StrEqual(subsection, "car", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
		}

		if ((StrEqual(subsection, "carability", false) || StrEqual(subsection, "car ability", false) || StrEqual(subsection, "car_ability", false) || StrEqual(subsection, "car", false)) && (StrEqual(key, "CarRadius", false) || StrEqual(key, "Car Radius", false) || StrEqual(key, "Car_Radius", false) || StrEqual(key, "radius", false)) && value[0] != '\0')
		{
			char sSet[2][7], sValue[14];
			strcopy(sValue, sizeof(sValue), value);
			ReplaceString(sValue, sizeof(sValue), " ", "");
			ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

			g_flCarRadius[type][0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 0.0) : g_flCarRadius[type][0];
			g_flCarRadius[type][1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), 0.0, 200.0) : g_flCarRadius[type][1];
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
			vRemoveCar(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iCarAbility[MT_GetTankType(tank)] == 1 && !g_bCar[tank])
	{
		vCarAbility(tank);
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
			if (g_iCarAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[MT_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bCar[tank] && !g_bCar2[tank])
						{
							vCarAbility(tank);
						}
						else if (g_bCar[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman3");
						}
						else if (g_bCar2[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman4");
						}
					}
					case 1:
					{
						if (g_iCarCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
						{
							if (!g_bCar[tank] && !g_bCar2[tank])
							{
								g_bCar[tank] = true;
								g_iCarCount[tank]++;

								vCar(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman", g_iCarCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarAmmo");
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
			if (g_iCarAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[MT_GetTankType(tank)] == 1 && g_bCar[tank] && !g_bCar2[tank])
				{
					g_bCar[tank] = false;

					vReset2(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveCar(tank);
}

static void vCar(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	DataPack dpCar;
	CreateDataTimer(0.6, tTimerCar, dpCar, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpCar.WriteCell(GetClientUserId(tank));
	dpCar.WriteCell(MT_GetTankType(tank));
	dpCar.WriteFloat(GetEngineTime());
}

static void vCarAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iCarCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flCarChance[MT_GetTankType(tank)])
		{
			g_bCar[tank] = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bCar2[tank])
			{
				g_bCar2[tank] = true;
				g_iCarCount[tank]++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman", g_iCarCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
			}

			vCar(tank);

			if (g_iCarMessage[MT_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Car", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarAmmo");
	}
}

static void vRemoveCar(int tank)
{
	g_bCar[tank] = false;
	g_bCar2[tank] = false;
	g_iCarCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveCar(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bCar2[tank] = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman5");

	if (g_iCarCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bCar2[tank] = false;
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

public Action tTimerCar(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || !g_bCar[iTank])
	{
		g_bCar[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (g_iCarAbility[MT_GetTankType(iTank)] == 0 || ((!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_iHumanAbility[MT_GetTankType(iTank)] == 1 && g_iHumanMode[MT_GetTankType(iTank)] == 0)) && (flTime + g_flCarDuration[MT_GetTankType(iTank)]) < GetEngineTime()))
	{
		g_bCar[iTank] = false;

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && g_iHumanMode[MT_GetTankType(iTank)] == 0 && !g_bCar2[iTank])
		{
			vReset2(iTank);
		}

		if (g_iCarMessage[MT_GetTankType(iTank)] == 1)
		{
			char sTankName[33];
			MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Car2", sTankName);
		}

		return Plugin_Stop;
	}

	float flPos[3];
	GetClientEyePosition(iTank, flPos);

	float flAngles[3];
	flAngles[0] = GetRandomFloat(-20.0, 20.0);
	flAngles[1] = GetRandomFloat(-20.0, 20.0);
	flAngles[2] = 60.0;

	GetVectorAngles(flAngles, flAngles);
	float flHitpos[3];
	iGetRayHitPos(flPos, flAngles, flHitpos, iTank, true, 2);

	float flDistance = GetVectorDistance(flPos, flHitpos);
	if (flDistance > 1600.0)
	{
		flDistance = 1600.0;
	}

	float flVector[3];
	MakeVectorFromPoints(flPos, flHitpos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, flDistance - 40.0);
	AddVectors(flPos, flVector, flHitpos);

	if (flDistance > 100.0)
	{
		int iCar = CreateEntityByName("prop_physics");
		if (bIsValidEntity(iCar))
		{
			int iOptionCount, iOptions[4];
			for (int iBit = 0; iBit < 3; iBit++)
			{
				int iFlag = (1 << iBit);
				if (!(g_iCarOptions[MT_GetTankType(iTank)] & iFlag))
				{
					continue;
				}

				iOptions[iOptionCount] = iFlag;
				iOptionCount++;
			}

			switch (iOptions[GetRandomInt(0, iOptionCount - 1)])
			{
				case 1: SetEntityModel(iCar, MODEL_CAR);
				case 2: SetEntityModel(iCar, MODEL_CAR2);
				case 4: SetEntityModel(iCar, MODEL_CAR3);
				default:
				{
					switch (GetRandomInt(1, 3))
					{
						case 1: SetEntityModel(iCar, MODEL_CAR);
						case 2: SetEntityModel(iCar, MODEL_CAR2);
						case 3: SetEntityModel(iCar, MODEL_CAR3);
					}
				}
			}

			int iCarColor[3];
			float flAngles2[3];
			for (int iPos = 0; iPos < 3; iPos++)
			{
				iCarColor[iPos] = GetRandomInt(0, 255);
				flAngles2[iPos] = GetRandomFloat(g_flCarRadius[MT_GetTankType(iTank)][0], g_flCarRadius[MT_GetTankType(iTank)][1]);
			}

			SetEntityRenderColor(iCar, iCarColor[0], iCarColor[1], iCarColor[2], 255);

			float flVelocity[3];
			flVelocity[0] = GetRandomFloat(0.0, 350.0);
			flVelocity[1] = GetRandomFloat(0.0, 350.0);
			flVelocity[2] = GetRandomFloat(0.0, 30.0);

			DispatchSpawn(iCar);
			TeleportEntity(iCar, flHitpos, flAngles2, flVelocity);

			CreateTimer(6.0, tTimerSetCarVelocity, EntIndexToEntRef(iCar), TIMER_FLAG_NO_MAPCHANGE);

			iCar = EntIndexToEntRef(iCar);
			vDeleteEntity(iCar, 30.0);
		}
	}

	return Plugin_Continue;
}

public Action tTimerSetCarVelocity(Handle timer, int ref)
{
	int iCar = EntRefToEntIndex(ref);
	if (iCar == INVALID_ENT_REFERENCE || !bIsValidEntity(iCar))
	{
		return Plugin_Stop;
	}

	TeleportEntity(iCar, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bCar2[iTank])
	{
		g_bCar2[iTank] = false;

		return Plugin_Stop;
	}

	g_bCar2[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "CarHuman6");

	return Plugin_Continue;
}