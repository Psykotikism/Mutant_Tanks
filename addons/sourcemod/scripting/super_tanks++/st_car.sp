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
	name = "[ST++] Car Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates car showers.",
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"

#define ST_MENU_CAR "Car Ability"

bool g_bCar[MAXPLAYERS + 1], g_bCar2[MAXPLAYERS + 1], g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];

char g_sCarOptions[ST_MAXTYPES + 1][7], g_sCarOptions2[ST_MAXTYPES + 1][7], g_sCarRadius[ST_MAXTYPES + 1][13], g_sCarRadius2[ST_MAXTYPES + 1][13];

float g_flCarChance[ST_MAXTYPES + 1], g_flCarChance2[ST_MAXTYPES + 1], g_flCarDuration[ST_MAXTYPES + 1], g_flCarDuration2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iCarAbility[ST_MAXTYPES + 1], g_iCarAbility2[ST_MAXTYPES + 1], g_iCarCount[MAXPLAYERS + 1], g_iCarMessage[ST_MAXTYPES + 1], g_iCarMessage2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Car Ability\" only supports Left 4 Dead 1 & 2.");

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
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_car", cmdCarInfo, "View information about the Car ability.");
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iCarAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iCarCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "CarDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flCarDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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

public void ST_OnDisplayMenu(Menu menu)
{
	menu.AddItem(ST_MENU_CAR, ST_MENU_CAR);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_CAR, false))
	{
		vCarMenu(client, 0);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Car Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Car Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Car Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Car Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iCarAbility[iIndex] = kvSuperTanks.GetNum("Car Ability/Ability Enabled", 0);
					g_iCarAbility[iIndex] = iClamp(g_iCarAbility[iIndex], 0, 1);
					g_iCarMessage[iIndex] = kvSuperTanks.GetNum("Car Ability/Ability Message", 0);
					g_iCarMessage[iIndex] = iClamp(g_iCarMessage[iIndex], 0, 1);
					g_flCarChance[iIndex] = kvSuperTanks.GetFloat("Car Ability/Car Chance", 33.3);
					g_flCarChance[iIndex] = flClamp(g_flCarChance[iIndex], 0.0, 100.0);
					g_flCarDuration[iIndex] = kvSuperTanks.GetFloat("Car Ability/Car Duration", 5.0);
					g_flCarDuration[iIndex] = flClamp(g_flCarDuration[iIndex], 0.1, 9999999999.0);
					kvSuperTanks.GetString("Car Ability/Car Options", g_sCarOptions[iIndex], sizeof(g_sCarOptions[]), "123");
					kvSuperTanks.GetString("Car Ability/Car Radius", g_sCarRadius[iIndex], sizeof(g_sCarRadius[]), "-180.0,180.0");
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Car Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Car Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Car Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Car Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iCarAbility2[iIndex] = kvSuperTanks.GetNum("Car Ability/Ability Enabled", g_iCarAbility[iIndex]);
					g_iCarAbility2[iIndex] = iClamp(g_iCarAbility2[iIndex], 0, 1);
					g_iCarMessage2[iIndex] = kvSuperTanks.GetNum("Car Ability/Ability Message", g_iCarMessage[iIndex]);
					g_iCarMessage2[iIndex] = iClamp(g_iCarMessage2[iIndex], 0, 1);
					g_flCarChance2[iIndex] = kvSuperTanks.GetFloat("Car Ability/Car Chance", g_flCarChance[iIndex]);
					g_flCarChance2[iIndex] = flClamp(g_flCarChance2[iIndex], 0.0, 100.0);
					g_flCarDuration2[iIndex] = kvSuperTanks.GetFloat("Car Ability/Car Duration", g_flCarDuration[iIndex]);
					g_flCarDuration2[iIndex] = flClamp(g_flCarDuration2[iIndex], 0.1, 9999999999.0);
					kvSuperTanks.GetString("Car Ability/Car Options", g_sCarOptions2[iIndex], sizeof(g_sCarOptions2[]), g_sCarOptions[iIndex]);
					kvSuperTanks.GetString("Car Ability/Car Radius", g_sCarRadius2[iIndex], sizeof(g_sCarRadius2[]), g_sCarRadius[iIndex]);
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
		if (ST_TankAllowed(iTank, "024"))
		{
			vRemoveCar(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iCarAbility(tank) == 1 && !g_bCar[tank])
	{
		vCarAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iCarAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bCar[tank] && !g_bCar2[tank])
						{
							vCarAbility(tank);
						}
						else if (g_bCar[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "CarHuman3");
						}
						else if (g_bCar2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "CarHuman4");
						}
					}
					case 1:
					{
						if (g_iCarCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bCar[tank] && !g_bCar2[tank])
							{
								g_bCar[tank] = true;
								g_iCarCount[tank]++;

								vCar(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "CarHuman", g_iCarCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "CarAmmo");
						}
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
			if (iCarAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bCar[tank] && !g_bCar2[tank])
				{
					g_bCar[tank] = false;

					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveCar(tank);
}

static void vCar(int tank)
{
	DataPack dpCarUpdate;
	CreateDataTimer(0.6, tTimerCarUpdate, dpCarUpdate, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpCarUpdate.WriteCell(GetClientUserId(tank));
	dpCarUpdate.WriteFloat(GetEngineTime());
}

static void vCarAbility(int tank)
{
	if (g_iCarCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flCarChance = !g_bTankConfig[ST_TankType(tank)] ? g_flCarChance[ST_TankType(tank)] : g_flCarChance2[ST_TankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flCarChance)
		{
			g_bCar[tank] = true;

			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bCar2[tank])
			{
				g_bCar2[tank] = true;
				g_iCarCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "CarHuman", g_iCarCount[tank], iHumanAmmo(tank));
			}

			vCar(tank);

			if (iCarMessage(tank) == 1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Car", sTankName);
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "CarHuman2");
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "CarAmmo");
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
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveCar(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bCar2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "CarHuman5");

	if (g_iCarCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bCar2[tank] = false;
	}
}

static float flCarDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flCarDuration[ST_TankType(tank)] : g_flCarDuration2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iCarAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iCarAbility[ST_TankType(tank)] : g_iCarAbility2[ST_TankType(tank)];
}

static int iCarMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iCarMessage[ST_TankType(tank)] : g_iCarMessage2[ST_TankType(tank)];
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

public Action tTimerCarUpdate(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bCar[iTank])
	{
		g_bCar[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (iCarAbility(iTank) == 0 || ((!ST_TankAllowed(iTank, "5") || (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0)) && (flTime + flCarDuration(iTank)) < GetEngineTime()))
	{
		g_bCar[iTank] = false;

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && !g_bCar2[iTank])
		{
			vReset2(iTank);
		}

		if (iCarMessage(iTank) == 1)
		{
			char sTankName[33];
			ST_TankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Car2", sTankName);
		}

		return Plugin_Stop;
	}

	char sRadius[2][7], sCarRadius[13];
	sCarRadius = !g_bTankConfig[ST_TankType(iTank)] ? g_sCarRadius[ST_TankType(iTank)] : g_sCarRadius2[ST_TankType(iTank)];
	ReplaceString(sCarRadius, sizeof(sCarRadius), " ", "");
	ExplodeString(sCarRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));

	float flMin = (sRadius[0][0] != '\0') ? StringToFloat(sRadius[0]) : -200.0,
		flMax = (sRadius[1][0] != '\0') ? StringToFloat(sRadius[1]) : 200.0;
	flMin = flClamp(flMin, -200.0, 0.0);
	flMax = flClamp(flMax, 0.0, 200.0);

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
			char sNumbers = !g_bTankConfig[ST_TankType(iTank)] ? g_sCarOptions[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sCarOptions[ST_TankType(iTank)]) - 1)] : g_sCarOptions2[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sCarOptions2[ST_TankType(iTank)]) - 1)];
			switch (sNumbers)
			{
				case '1': SetEntityModel(iCar, MODEL_CAR);
				case '2': SetEntityModel(iCar, MODEL_CAR2);
				case '3': SetEntityModel(iCar, MODEL_CAR3);
				default: SetEntityModel(iCar, MODEL_CAR);
			}

			int iRed = GetRandomInt(0, 255), iGreen = GetRandomInt(0, 255), iBlue = GetRandomInt(0, 255);
			SetEntityRenderColor(iCar, iRed, iGreen, iBlue, 255);

			float flAngles2[3];
			flAngles2[0] = GetRandomFloat(flMin, flMax);
			flAngles2[1] = GetRandomFloat(flMin, flMax);
			flAngles2[2] = GetRandomFloat(flMin, flMax);

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
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bCar2[iTank])
	{
		g_bCar2[iTank] = false;

		return Plugin_Stop;
	}

	g_bCar2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "CarHuman6");

	return Plugin_Continue;
}