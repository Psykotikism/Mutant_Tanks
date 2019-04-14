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
	name = "[MT] Throw Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank throws cars, special infected, Witches, or itself.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Throw Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"

#define MT_MENU_THROW "Throw Ability"

bool g_bCloneInstalled, g_bThrow[MAXPLAYERS + 1], g_bThrow2[MAXPLAYERS + 1];

ConVar g_cvMTTankThrowForce;

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flThrowChance[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iThrowAbility[MT_MAXTYPES + 1], g_iThrowCarOptions[MT_MAXTYPES + 1], g_iThrowCount[MAXPLAYERS + 1], g_iThrowInfectedOptions[MT_MAXTYPES + 1], g_iThrowMessage[MT_MAXTYPES + 1];

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

	RegConsoleCmd("sm_mt_throw", cmdThrowInfo, "View information about the Throw ability.");

	g_cvMTTankThrowForce = FindConVar("z_tank_throw_force");
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
					MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iThrowAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				}
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iThrowCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons3");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ThrowDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_THROW, MT_MENU_THROW);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_THROW, false))
	{
		vThrowMenu(client, 0);
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
		g_iThrowAbility[iIndex] = 0;
		g_iThrowMessage[iIndex] = 0;
		g_iThrowCarOptions[iIndex] = 0;
		g_flThrowChance[iIndex] = 33.3;
		g_iThrowInfectedOptions[iIndex] = 0;
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "throwability", false) || StrEqual(subsection, "throw ability", false) || StrEqual(subsection, "throw_ability", false) || StrEqual(subsection, "throw", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		MT_FindAbility(type, 60, bHasAbilities(subsection, "throwability", "throw ability", "throw_ability", "throw"));
		g_iHumanAbility[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iThrowAbility[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iThrowAbility[type], value, 0, 15);
		g_iThrowMessage[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iThrowMessage[type], value, 0, 15);
		g_iThrowCarOptions[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowCarOptions", "Throw Car Options", "Throw_Car_Options", "car", g_iThrowCarOptions[type], value, 0, 7);
		g_flThrowChance[type] = flGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowChance", "Throw Chance", "Throw_Chance", "chance", g_flThrowChance[type], value, 0.0, 100.0);
		g_iThrowInfectedOptions[type] = iGetValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowInfectedOptions", "Throw Infected Options", "Throw_Infected_Options", "infected", g_iThrowInfectedOptions[type], value, 0, 127);

		if (StrEqual(subsection, "throwability", false) || StrEqual(subsection, "throw ability", false) || StrEqual(subsection, "throw_ability", false) || StrEqual(subsection, "throw", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
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
			vRemoveThrow(iTank);
		}
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

		if (button & MT_SPECIAL_KEY == MT_SPECIAL_KEY)
		{
			if (g_iThrowAbility[MT_GetTankType(tank)] == 0 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (!g_bThrow[tank] && !g_bThrow2[tank])
				{
					if (g_iThrowCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
					{
						g_bThrow[tank] = true;
						g_iThrowCount[tank]++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowHuman", g_iThrowCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowAmmo");
					}
				}
				else if (g_bThrow[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowHuman2");
				}
				else if (g_bThrow2[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowHuman3");
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveThrow(tank);
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iThrowAbility[MT_GetTankType(tank)] > 0 && GetRandomFloat(0.1, 100.0) <= g_flThrowChance[MT_GetTankType(tank)])
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		DataPack dpThrow;
		CreateDataTimer(0.1, tTimerThrow, dpThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpThrow.WriteCell(EntIndexToEntRef(rock));
		dpThrow.WriteCell(GetClientUserId(tank));
		dpThrow.WriteCell(MT_GetTankType(tank));
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
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveThrow(iPlayer);
		}
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

public Action tTimerThrow(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || (g_iThrowAbility[MT_GetTankType(iTank)] == 0))
	{
		return Plugin_Stop;
	}

	if (!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(iTank)] == 0)
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
			if (!(g_iThrowAbility[MT_GetTankType(iTank)] & iFlag))
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
							if (!(g_iThrowCarOptions[MT_GetTankType(iTank)] & iFlag))
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
						ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

						DispatchSpawn(iCar);
						TeleportEntity(iCar, flPos, NULL_VECTOR, flVelocity);
						
						iCar = EntIndexToEntRef(iCar);
						CreateTimer(2.0, tTimerSetCarVelocity, iCar, TIMER_FLAG_NO_MAPCHANGE);
						vDeleteEntity(iCar, 10.0);

						if (g_iThrowMessage[MT_GetTankType(iTank)] & MT_MESSAGE_MELEE)
						{
							char sTankName[33];
							MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Throw", sTankName);
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
							if (!(g_iThrowInfectedOptions[MT_GetTankType(iTank)] & iFlag))
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
						ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

						TeleportEntity(iInfected, flPos, NULL_VECTOR, flVelocity);

						if (g_iThrowMessage[MT_GetTankType(iTank)] & MT_MESSAGE_RANGE)
						{
							char sTankName[33];
							MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Throw2", sTankName);
						}
					}
				}
				case 4:
				{
					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					RemoveEntity(iRock);

					NormalizeVector(flVelocity, flVelocity);
					ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

					TeleportEntity(iTank, flPos, NULL_VECTOR, flVelocity);

					if (g_iThrowMessage[MT_GetTankType(iTank)] & MT_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Throw3", sTankName);
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
						ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

						DispatchSpawn(iWitch);
						ActivateEntity(iWitch);
						SetEntProp(iWitch, Prop_Send, "m_hOwnerEntity", iTank);

						TeleportEntity(iWitch, flPos, NULL_VECTOR, flVelocity);
					}

					if (g_iThrowMessage[MT_GetTankType(iTank)] & MT_MESSAGE_SPECIAL2)
					{
						char sTankName[33];
						MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Throw4", sTankName);
					}
				}
			}
		}

		g_bThrow[iTank] = false;

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iTank)] && !g_bThrow2[iTank])
		{
			g_bThrow2[iTank] = true;

			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ThrowHuman4");

			if (g_iThrowCount[iTank] < g_iHumanAmmo[MT_GetTankType(iTank)] && g_iHumanAmmo[MT_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[MT_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
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
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bThrow2[iTank])
	{
		g_bThrow2[iTank] = false;

		return Plugin_Stop;
	}

	g_bThrow2[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ThrowHuman5");

	return Plugin_Continue;
}