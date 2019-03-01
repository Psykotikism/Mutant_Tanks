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
	name = "[ST++] Throw Ability",
	author = ST_AUTHOR,
	description = "The Super Tank throws cars, special infected, Witches, or itself.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Throw Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"

#define ST_MENU_THROW "Throw Ability"

bool g_bCloneInstalled, g_bThrow[MAXPLAYERS + 1], g_bThrow2[MAXPLAYERS + 1];

ConVar g_cvSTTankThrowForce;

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flThrowChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iThrowAbility[ST_MAXTYPES + 1], g_iThrowCarOptions[ST_MAXTYPES + 1], g_iThrowCount[MAXPLAYERS + 1], g_iThrowInfectedOptions[ST_MAXTYPES + 1], g_iThrowMessage[ST_MAXTYPES + 1];

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
					ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iThrowAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				}
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iThrowCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons3");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ThrowDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iThrowAbility[iIndex] = 0;
		g_iThrowMessage[iIndex] = 0;
		g_iThrowCarOptions[iIndex] = 0;
		g_flThrowChance[iIndex] = 33.3;
		g_iThrowInfectedOptions[iIndex] = 0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iThrowAbility[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iThrowAbility[type], value, 0, 0, 15);
	g_iThrowMessage[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iThrowMessage[type], value, 0, 0, 15);
	g_iThrowCarOptions[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowCarOptions", "Throw Car Options", "Throw_Car_Options", "car", main, g_iThrowCarOptions[type], value, 0, 0, 7);
	g_flThrowChance[type] = flGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowChance", "Throw Chance", "Throw_Chance", "chance", main, g_flThrowChance[type], value, 33.3, 0.0, 100.0);
	g_iThrowInfectedOptions[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowInfectedOptions", "Throw Infected Options", "Throw_Infected_Options", "infected", main, g_iThrowInfectedOptions[type], value, 0, 0, 127);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveThrow(iTank);
		}
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY == ST_SPECIAL_KEY)
		{
			if (g_iThrowAbility[ST_GetTankType(tank)] == 0 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bThrow[tank] && !g_bThrow2[tank])
				{
					if (g_iThrowCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
					{
						g_bThrow[tank] = true;
						g_iThrowCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "ThrowHuman", g_iThrowCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
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

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveThrow(tank);
}

public void ST_OnRockThrow(int tank, int rock)
{
	if (ST_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iThrowAbility[ST_GetTankType(tank)] > 0 && GetRandomFloat(0.1, 100.0) <= g_flThrowChance[ST_GetTankType(tank)])
	{
		DataPack dpThrow;
		CreateDataTimer(0.1, tTimerThrow, dpThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpThrow.WriteCell(EntIndexToEntRef(rock));
		dpThrow.WriteCell(GetClientUserId(tank));
		dpThrow.WriteCell(ST_GetTankType(tank));
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveThrow(iPlayer);
		}
	}
}

public Action tTimerThrow(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || (g_iThrowAbility[ST_GetTankType(iTank)] == 0))
	{
		return Plugin_Stop;
	}

	if (!ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(iTank)] == 0)
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
		int iAbilityCount, iAbilities[5];
		for (int iBit = 0; iBit < 4; iBit++)
		{
			int iFlag = (1 << iBit);
			if (!(g_iThrowAbility[ST_GetTankType(iTank)] & iFlag))
			{
				continue;
			}

			iAbilities[iAbilityCount] = iFlag;
			iAbilityCount++;
		}

		if (iAbilityCount > 0)
		{
			switch (iAbilities[GetRandomInt(0, iAbilityCount - 1)])
			{
				case 1:
				{
					int iCar = CreateEntityByName("prop_physics");
					if (bIsValidEntity(iCar))
					{
						int iOptionCount, iOptions[4];
						for (int iBit = 0; iBit < 3; iBit++)
						{
							int iFlag = (1 << iBit);
							if (!(g_iThrowCarOptions[ST_GetTankType(iTank)] & iFlag))
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
						for (int iPos = 0; iPos < 3; iPos++)
						{
							iCarColor[iPos] = GetRandomInt(0, 255);
						}

						SetEntityRenderColor(iCar, iCarColor[0], iCarColor[1], iCarColor[2], 255);

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

						if (g_iThrowMessage[ST_GetTankType(iTank)] & ST_MESSAGE_MELEE)
						{
							char sTankName[33];
							ST_GetTankName(iTank, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Throw", sTankName);
						}
					}
				}
				case 2:
				{
					int iInfected = CreateFakeClient("Infected");
					if (iInfected > 0)
					{
						int iOptionCount, iOptions[8];
						for (int iBit = 0; iBit < 7; iBit++)
						{
							int iFlag = (1 << iBit);
							if (!(g_iThrowInfectedOptions[ST_GetTankType(iTank)] & iFlag))
							{
								continue;
							}

							iOptions[iOptionCount] = iFlag;
							iOptionCount++;
						}

						switch (iOptions[GetRandomInt(0, iOptionCount - 1)])
						{
							case 1: vSpawnInfected(iInfected, "smoker");
							case 2: vSpawnInfected(iInfected, "boomer");
							case 4: vSpawnInfected(iInfected, "hunter");
							case 8: vSpawnInfected(iInfected, bIsValidGame() ? "spitter" : "boomer");
							case 16: vSpawnInfected(iInfected, bIsValidGame() ? "jockey" : "hunter");
							case 32: vSpawnInfected(iInfected, bIsValidGame() ? "charger" : "smoker");
							case 64: vSpawnInfected(iInfected, "tank");
							default:
							{
								switch (GetRandomInt(1, 7))
								{
									case 1: vSpawnInfected(iInfected, "smoker");
									case 2: vSpawnInfected(iInfected, "boomer");
									case 3: vSpawnInfected(iInfected, "hunter");
									case 4: vSpawnInfected(iInfected, bIsValidGame() ? "spitter" : "boomer");
									case 5: vSpawnInfected(iInfected, bIsValidGame() ? "jockey" : "hunter");
									case 6: vSpawnInfected(iInfected, bIsValidGame() ? "charger" : "smoker");
									case 7: vSpawnInfected(iInfected, "tank");
								}
							}
						}

						float flPos[3];
						GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
						RemoveEntity(iRock);

						NormalizeVector(flVelocity, flVelocity);
						ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);

						TeleportEntity(iInfected, flPos, NULL_VECTOR, flVelocity);

						if (g_iThrowMessage[ST_GetTankType(iTank)] & ST_MESSAGE_RANGE)
						{
							char sTankName[33];
							ST_GetTankName(iTank, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Throw2", sTankName);
						}
					}
				}
				case 4:
				{
					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					RemoveEntity(iRock);

					NormalizeVector(flVelocity, flVelocity);
					ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);

					TeleportEntity(iTank, flPos, NULL_VECTOR, flVelocity);

					if (g_iThrowMessage[ST_GetTankType(iTank)] & ST_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						ST_GetTankName(iTank, sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Throw3", sTankName);
					}
				}
				case 8:
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

					if (g_iThrowMessage[ST_GetTankType(iTank)] & ST_MESSAGE_SPECIAL2)
					{
						char sTankName[33];
						ST_GetTankName(iTank, sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Throw4", sTankName);
					}
				}
			}
		}

		g_bThrow[iTank] = false;

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] && !g_bThrow2[iTank])
		{
			g_bThrow2[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ThrowHuman4");

			if (g_iThrowCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
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
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bThrow2[iTank])
	{
		g_bThrow2[iTank] = false;

		return Plugin_Stop;
	}

	g_bThrow2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ThrowHuman5");

	return Plugin_Continue;
}