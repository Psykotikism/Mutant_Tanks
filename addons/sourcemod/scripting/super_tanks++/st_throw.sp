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
	name = "[ST++] Throw Ability",
	author = ST_AUTHOR,
	description = "The Super Tank throws cars, special infected, Witches, or itself.",
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"

#define ST_MENU_THROW "Throw Ability"

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1], g_bThrow[MAXPLAYERS + 1], g_bThrow2[MAXPLAYERS + 1];

char g_sThrowAbility[ST_MAXTYPES + 1][9], g_sThrowAbility2[ST_MAXTYPES + 1][9], g_sThrowCarOptions[ST_MAXTYPES + 1][7], g_sThrowCarOptions2[ST_MAXTYPES + 1][7], g_sThrowInfectedOptions[ST_MAXTYPES + 1][15], g_sThrowInfectedOptions2[ST_MAXTYPES + 1][15], g_sThrowMessage[ST_MAXTYPES + 1][5], g_sThrowMessage2[ST_MAXTYPES + 1][5];

ConVar g_cvSTTankThrowForce;

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flThrowChance[ST_MAXTYPES + 1], g_flThrowChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iThrowCount[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Throw Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_throw", cmdThrowInfo, "View information about the Throw ability.");

	g_cvSTTankThrowForce = FindConVar("z_tank_throw_force");
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
	vRemoveThrow(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdThrowInfo(int client, int args)
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
		case false: vThrowMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vThrowMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iThrowMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Throw Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iThrowMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0:
				{
					char sThrowAbility[9];
					sThrowAbility = !g_bTankConfig[ST_TankType(param1)] ? g_sThrowAbility[ST_TankType(param1)] : g_sThrowAbility2[ST_TankType(param1)];
					ST_PrintToChat(param1, "%s %t", ST_TAG3, StrEqual(sThrowAbility, "") ? "AbilityStatus1" : "AbilityStatus2");
				}
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iThrowCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons3");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ThrowDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vThrowMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ThrowMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
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
	menu.AddItem(ST_MENU_THROW, ST_MENU_THROW);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_THROW, false))
	{
		vThrowMenu(client, 0);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Throw Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Throw Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 1, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Throw Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					kvSuperTanks.GetString("Throw Ability/Ability Enabled", g_sThrowAbility[iIndex], sizeof(g_sThrowAbility[]), "0");
					kvSuperTanks.GetString("Throw Ability/Ability Message", g_sThrowMessage[iIndex], sizeof(g_sThrowMessage[]), "0");
					kvSuperTanks.GetString("Throw Ability/Throw Car Options", g_sThrowCarOptions[iIndex], sizeof(g_sThrowCarOptions[]), "123");
					g_flThrowChance[iIndex] = kvSuperTanks.GetFloat("Throw Ability/Throw Chance", 33.3);
					g_flThrowChance[iIndex] = flClamp(g_flThrowChance[iIndex], 0.0, 100.0);
					kvSuperTanks.GetString("Throw Ability/Throw Infected Options", g_sThrowInfectedOptions[iIndex], sizeof(g_sThrowInfectedOptions[]), "1234567");
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Throw Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Throw Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 1, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Throw Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					kvSuperTanks.GetString("Throw Ability/Ability Enabled", g_sThrowAbility2[iIndex], sizeof(g_sThrowAbility2[]), g_sThrowAbility[iIndex]);
					kvSuperTanks.GetString("Throw Ability/Ability Message", g_sThrowMessage2[iIndex], sizeof(g_sThrowMessage2[]), g_sThrowMessage[iIndex]);
					kvSuperTanks.GetString("Throw Ability/Throw Car Options", g_sThrowCarOptions2[iIndex], sizeof(g_sThrowCarOptions2[]), g_sThrowCarOptions[iIndex]);
					g_flThrowChance2[iIndex] = kvSuperTanks.GetFloat("Throw Ability/Throw Chance", g_flThrowChance[iIndex]);
					g_flThrowChance2[iIndex] = flClamp(g_flThrowChance2[iIndex], 0.0, 100.0);
					kvSuperTanks.GetString("Throw Ability/Throw Infected Options", g_sThrowInfectedOptions2[iIndex], sizeof(g_sThrowInfectedOptions2[]), g_sThrowInfectedOptions[iIndex]);
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
		if (ST_TankAllowed(iTank, "0245") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveThrow(iTank);
		}
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY == ST_SPECIAL_KEY)
		{
			char sThrowAbility[9];
			sThrowAbility = !g_bTankConfig[ST_TankType(tank)] ? g_sThrowAbility[ST_TankType(tank)] : g_sThrowAbility2[ST_TankType(tank)];
			if (!StrEqual(sThrowAbility, "") && iHumanAbility(tank) == 1)
			{
				if (!g_bThrow[tank] && !g_bThrow2[tank])
				{
					if (g_iThrowCount[tank] < iHumanAmmo(tank))
					{
						g_bThrow[tank] = true;
						g_iThrowCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "ThrowHuman", g_iThrowCount[tank], iHumanAmmo(tank));
					}
					else
					{
						ST_PrintToChat(tank, "%s %t", ST_TAG3, "ThrowAmmo");
					}
				}
				else if (g_bThrow[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ThrowHuman2");
				}
				else if (g_bThrow2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ThrowHuman3");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveThrow(tank);
}

public void ST_OnRockThrow(int tank, int rock)
{
	char sThrowAbility[9];
	sThrowAbility = !g_bTankConfig[ST_TankType(tank)] ? g_sThrowAbility[ST_TankType(tank)] : g_sThrowAbility2[ST_TankType(tank)];
	float flThrowChance = !g_bTankConfig[ST_TankType(tank)] ? g_flThrowChance[ST_TankType(tank)] : g_flThrowChance2[ST_TankType(tank)];
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && !StrEqual(sThrowAbility, "") && GetRandomFloat(0.1, 100.0) <= flThrowChance)
	{
		DataPack dpThrow;
		CreateDataTimer(0.1, tTimerThrow, dpThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpThrow.WriteCell(EntIndexToEntRef(rock));
		dpThrow.WriteCell(GetClientUserId(tank));
	}
}

static void vRemoveThrow(int tank)
{
	g_bThrow[tank] = false;
	g_bThrow2[tank] = false;
	g_iThrowCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveThrow(iPlayer);
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

public Action tTimerThrow(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!ST_PluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sThrowAbility[9];
	sThrowAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowAbility[ST_TankType(iTank)] : g_sThrowAbility2[ST_TankType(iTank)];
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || StrEqual(sThrowAbility, ""))
	{
		return Plugin_Stop;
	}

	if (!ST_TankAllowed(iTank, "5") || iHumanAbility(iTank) == 0)
	{
		g_bThrow[iTank] = true;
	}

	if (!g_bThrow[iTank])
	{
		return Plugin_Stop;
	}

	float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);

	float flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		char sAbilities = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowAbility[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowAbility[ST_TankType(iTank)]) - 1)] : g_sThrowAbility2[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowAbility2[ST_TankType(iTank)]) - 1)];
		switch (sAbilities)
		{
			case '1':
			{
				int iCar = CreateEntityByName("prop_physics");
				if (bIsValidEntity(iCar))
				{
					char sNumbers = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowCarOptions[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowCarOptions[ST_TankType(iTank)]) - 1)] : g_sThrowCarOptions2[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowCarOptions2[ST_TankType(iTank)]) - 1)];
					switch (sNumbers)
					{
						case '1': SetEntityModel(iCar, MODEL_CAR);
						case '2': SetEntityModel(iCar, MODEL_CAR2);
						case '3': SetEntityModel(iCar, MODEL_CAR3);
						default: SetEntityModel(iCar, MODEL_CAR);
					}

					int iRed = GetRandomInt(0, 255), iGreen = GetRandomInt(0, 255), iBlue = GetRandomInt(0, 255);
					SetEntityRenderColor(iCar, iRed, iGreen, iBlue, 255);

					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					RemoveEntity(iRock);

					NormalizeVector(flVelocity, flVelocity);
					ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);

					DispatchSpawn(iCar);
					TeleportEntity(iCar, flPos, NULL_VECTOR, flVelocity);

					CreateTimer(2.0, tTimerSetCarVelocity, EntIndexToEntRef(iCar), TIMER_FLAG_NO_MAPCHANGE);

					iCar = EntIndexToEntRef(iCar);
					vDeleteEntity(iCar, 10.0);

					char sThrowMessage[5];
					sThrowMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowMessage[ST_TankType(iTank)] : g_sThrowMessage2[ST_TankType(iTank)];
					if (StrContains(sThrowMessage, "1") != -1)
					{
						char sTankName[33];
						ST_TankName(iTank, sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Throw", sTankName);
					}
				}
			}
			case '2':
			{
				int iInfected = CreateFakeClient("Infected");
				if (iInfected > 0)
				{
					char sNumbers = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowInfectedOptions[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowInfectedOptions[ST_TankType(iTank)]) - 1)] : g_sThrowInfectedOptions2[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowInfectedOptions2[ST_TankType(iTank)]) - 1)];
					switch (sNumbers)
					{
						case '1': vSpawnInfected(iInfected, "smoker");
						case '2': vSpawnInfected(iInfected, "boomer");
						case '3': vSpawnInfected(iInfected, "hunter");
						case '4':
						{
							if (bIsValidGame())
							{
								vSpawnInfected(iInfected, "spitter");
							}
							else
							{
								vSpawnInfected(iInfected, "boomer");
							}
						}
						case '5':
						{
							if (bIsValidGame())
							{
								vSpawnInfected(iInfected, "jockey");
							}
							else
							{
								vSpawnInfected(iInfected, "hunter");
							}
						}
						case '6':
						{
							if (bIsValidGame())
							{
								vSpawnInfected(iInfected, "charger");
							}
							else
							{
								vSpawnInfected(iInfected, "smoker");
							}
						}
						case '7': vSpawnInfected(iInfected, "tank");
						default: vSpawnInfected(iInfected, "hunter");
					}

					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					RemoveEntity(iRock);

					NormalizeVector(flVelocity, flVelocity);
					ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);

					TeleportEntity(iInfected, flPos, NULL_VECTOR, flVelocity);

					char sThrowMessage[5];
					sThrowMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowMessage[ST_TankType(iTank)] : g_sThrowMessage2[ST_TankType(iTank)];
					if (StrContains(sThrowMessage, "2") != -1)
					{
						char sTankName[33];
						ST_TankName(iTank, sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Throw2", sTankName);
					}
				}
			}
			case '3':
			{
				float flPos[3];
				GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
				RemoveEntity(iRock);

				NormalizeVector(flVelocity, flVelocity);
				ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);

				TeleportEntity(iTank, flPos, NULL_VECTOR, flVelocity);

				char sThrowMessage[5];
				sThrowMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowMessage[ST_TankType(iTank)] : g_sThrowMessage2[ST_TankType(iTank)];
				if (StrContains(sThrowMessage, "3") != -1)
				{
					char sTankName[33];
					ST_TankName(iTank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Throw3", sTankName);
				}
			}
			case '4':
			{
				int iWitch = CreateEntityByName("witch");
				if (bIsValidEntity(iWitch))
				{
					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					RemoveEntity(iRock);

					NormalizeVector(flVelocity, flVelocity);
					ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);

					DispatchSpawn(iWitch);
					ActivateEntity(iWitch);
					SetEntProp(iWitch, Prop_Send, "m_hOwnerEntity", iTank);

					TeleportEntity(iWitch, flPos, NULL_VECTOR, flVelocity);
				}

				char sThrowMessage[5];
				sThrowMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowMessage[ST_TankType(iTank)] : g_sThrowMessage2[ST_TankType(iTank)];
				if (StrContains(sThrowMessage, "4") != -1)
				{
					char sTankName[33];
					ST_TankName(iTank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Throw4", sTankName);
				}
			}
		}

		g_bThrow[iTank] = false;

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) && !g_bThrow2[iTank])
		{
			g_bThrow2[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ThrowHuman4");

			if (g_iThrowCount[iTank] < iHumanAmmo(iTank))
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bThrow2[iTank] = false;
			}
		}

		return Plugin_Stop;
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
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bThrow2[iTank])
	{
		g_bThrow2[iTank] = false;

		return Plugin_Stop;
	}

	g_bThrow2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ThrowHuman5");

	return Plugin_Continue;
}