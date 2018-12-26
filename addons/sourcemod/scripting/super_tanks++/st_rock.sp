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
	name = "[ST++] Rock Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates rock showers.",
	version = ST_VERSION,
	url = ST_URL
};

#define SOUND_ROCK "player/tank/attack/thrown_missile_loop_1.wav"

#define ST_MENU_ROCK "Rock Ability"

bool g_bCloneInstalled, g_bRock[MAXPLAYERS + 1], g_bRock2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sRockRadius[ST_MAXTYPES + 1][11], g_sRockRadius2[ST_MAXTYPES + 1][11];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flRockChance[ST_MAXTYPES + 1], g_flRockChance2[ST_MAXTYPES + 1], g_flRockDuration[ST_MAXTYPES + 1], g_flRockDuration2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iRock[MAXPLAYERS + 1], g_iRockAbility[ST_MAXTYPES + 1], g_iRockAbility2[ST_MAXTYPES + 1], g_iRockCount[MAXPLAYERS + 1], g_iRockDamage[ST_MAXTYPES + 1], g_iRockDamage2[ST_MAXTYPES + 1], g_iRockMessage[ST_MAXTYPES + 1], g_iRockMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Rock Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_rock", cmdRockInfo, "View information about the Rock ability.");
}

public void OnMapStart()
{
	PrecacheSound(SOUND_ROCK, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveRock(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRockInfo(int client, int args)
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
		case false: vRockMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRockMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRockMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Rock Ability Information");
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

public int iRockMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iRockAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iRockCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "RockDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flRockDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vRockMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "RockMenu", param1);
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
	menu.AddItem(ST_MENU_ROCK, ST_MENU_ROCK);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ROCK, false))
	{
		vRockMenu(client, 0);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Rock Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Rock Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Rock Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iRockAbility[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Enabled", 0);
					g_iRockAbility[iIndex] = iClamp(g_iRockAbility[iIndex], 0, 1);
					g_iRockMessage[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Message", 0);
					g_iRockMessage[iIndex] = iClamp(g_iRockMessage[iIndex], 0, 1);
					g_flRockChance[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Chance", 33.3);
					g_flRockChance[iIndex] = flClamp(g_flRockChance[iIndex], 0.0, 100.0);
					g_iRockDamage[iIndex] = kvSuperTanks.GetNum("Rock Ability/Rock Damage", 5);
					g_iRockDamage[iIndex] = iClamp(g_iRockDamage[iIndex], 1, 9999999999);
					g_flRockDuration[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Duration", 5.0);
					g_flRockDuration[iIndex] = flClamp(g_flRockDuration[iIndex], 0.1, 9999999999.0);
					kvSuperTanks.GetString("Rock Ability/Rock Radius", g_sRockRadius[iIndex], sizeof(g_sRockRadius[]), "-1.25,1.25");
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iRockAbility2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Enabled", g_iRockAbility[iIndex]);
					g_iRockAbility2[iIndex] = iClamp(g_iRockAbility2[iIndex], 0, 1);
					g_iRockMessage2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Message", g_iRockMessage[iIndex]);
					g_iRockMessage2[iIndex] = iClamp(g_iRockMessage2[iIndex], 0, 1);
					g_flRockChance2[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Chance", g_flRockChance[iIndex]);
					g_flRockChance2[iIndex] = flClamp(g_flRockChance2[iIndex], 0.0, 100.0);
					g_iRockDamage2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Rock Damage", g_iRockDamage[iIndex]);
					g_iRockDamage2[iIndex] = iClamp(g_iRockDamage2[iIndex], 1, 9999999999);
					g_flRockDuration2[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Duration", g_flRockDuration[iIndex]);
					g_flRockDuration2[iIndex] = flClamp(g_flRockDuration2[iIndex], 0.1, 9999999999.0);
					kvSuperTanks.GetString("Rock Ability/Rock Radius", g_sRockRadius2[iIndex], sizeof(g_sRockRadius2[]), g_sRockRadius[iIndex]);
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
			vRemoveRock(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iRockAbility(tank) == 1 && !g_bRock[tank])
	{
		vRockAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iRockAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bRock[tank] && !g_bRock2[tank])
						{
							vRockAbility(tank);
						}
						else if (g_bRock[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "RockHuman3");
						}
						else if (g_bRock2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "RockHuman4");
						}
					}
					case 1:
					{
						if (g_iRockCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bRock[tank] && !g_bRock2[tank])
							{
								g_iRock[tank] = CreateEntityByName("env_rock_launcher");
								if (bIsValidEntity(g_iRock[tank]))
								{
									g_bRock[tank] = true;
									g_iRockCount[tank]++;

									vRock(tank);

									ST_PrintToChat(tank, "%s %t", ST_TAG3, "RockHuman", g_iRockCount[tank], iHumanAmmo(tank));
								}
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "RockAmmo");
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
			if (iRockAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bRock[tank] && !g_bRock2[tank])
				{
					vReset2(tank, g_iRock[tank]);

					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveRock(tank);
}

static void vRemoveRock(int tank)
{
	g_bRock[tank] = false;
	g_bRock2[tank] = false;
	g_iRock[tank] = 0;
	g_iRockCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveRock(iPlayer);
		}
	}
}

static void vReset2(int tank, int rock)
{
	g_bRock[tank] = false;

	RemoveEntity(rock);

	CreateTimer(3.0, tTimerStopRockSound, _, TIMER_FLAG_NO_MAPCHANGE);
}

static void vReset3(int tank)
{
	g_bRock2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "RockHuman5");

	if (g_iRockCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bRock2[tank] = false;
	}
}

static void vRock(int tank)
{
	char sDamage[11];
	int iRockDamage = !g_bTankConfig[ST_TankType(tank)] ? g_iRockDamage[ST_TankType(tank)] : g_iRockDamage2[ST_TankType(tank)];
	IntToString(iRockDamage, sDamage, sizeof(sDamage));
	DispatchSpawn(g_iRock[tank]);
	DispatchKeyValue(g_iRock[tank], "rockdamageoverride", sDamage);

	DataPack dpRockUpdate;
	CreateDataTimer(0.2, tTimerRockUpdate, dpRockUpdate, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpRockUpdate.WriteCell(EntIndexToEntRef(g_iRock[tank]));
	dpRockUpdate.WriteCell(GetClientUserId(tank));
	dpRockUpdate.WriteFloat(GetEngineTime());
}

static void vRockAbility(int tank)
{
	if (g_iRockCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flRockChance = !g_bTankConfig[ST_TankType(tank)] ? g_flRockChance[ST_TankType(tank)] : g_flRockChance2[ST_TankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flRockChance)
		{
			g_iRock[tank] = CreateEntityByName("env_rock_launcher");
			if (!bIsValidEntity(g_iRock[tank]))
			{
				return;
			}

			g_bRock[tank] = true;

			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				g_iRockCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "RockHuman", g_iRockCount[tank], iHumanAmmo(tank));
			}

			vRock(tank);

			if (iRockMessage(tank) == 1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Rock", sTankName);
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "RockHuman2");
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "RockAmmo");
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flRockDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flRockDuration[ST_TankType(tank)] : g_flRockDuration2[ST_TankType(tank)];
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

static int iRockAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRockAbility[ST_TankType(tank)] : g_iRockAbility2[ST_TankType(tank)];
}

static int iRockMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRockMessage[ST_TankType(tank)] : g_iRockMessage2[ST_TankType(tank)];
}

public Action tTimerRockUpdate(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		g_bRock[iTank] = false;

		return Plugin_Stop;
	}

	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bRock[iTank])
	{
		vReset2(iTank, iRock);

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (iRockAbility(iTank) == 0 || ((!ST_TankAllowed(iTank, "5") || (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0)) && (flTime + flRockDuration(iTank)) < GetEngineTime()))
	{
		vReset2(iTank, iRock);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && !g_bRock2[iTank])
		{
			vReset3(iTank);
		}

		if (iRockMessage(iTank) == 1)
		{
			char sTankName[33];
			ST_TankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Rock2", sTankName);
		}

		return Plugin_Stop;
	}

	char sRadius[2][6], sRockRadius[11];
	sRockRadius = !g_bTankConfig[ST_TankType(iTank)] ? g_sRockRadius[ST_TankType(iTank)] : g_sRockRadius2[ST_TankType(iTank)];
	ReplaceString(sRockRadius, sizeof(sRockRadius), " ", "");
	ExplodeString(sRockRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));

	float flMin = (sRadius[0][0] != '\0') ? StringToFloat(sRadius[0]) : -5.0,
		flMax = (sRadius[1][0] != '\0') ? StringToFloat(sRadius[1]) : 5.0;
	flMin = flClamp(flMin, -5.0, 0.0);
	flMax = flClamp(flMax, 0.0, 5.0);

	float flPos[3];
	GetClientEyePosition(iTank, flPos);
	flPos[2] += 20.0;

	float flAngles[3];
	flAngles[0] = GetRandomFloat(-1.0, 1.0);
	flAngles[1] = GetRandomFloat(-1.0, 1.0);
	flAngles[2] = 2.0;
	GetVectorAngles(flAngles, flAngles);
	float flHitPos[3];
	iGetRayHitPos(flPos, flAngles, flHitPos, iTank, true, 2);

	float flDistance = GetVectorDistance(flPos, flHitPos), flVector[3];
	if (flDistance > 800.0)
	{
		flDistance = 800.0;
	}

	MakeVectorFromPoints(flPos, flHitPos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, flDistance - 40.0);
	AddVectors(flPos, flVector, flHitPos);

	if (flDistance > 300.0)
	{ 
		float flAngles2[3];
		flAngles2[0] = GetRandomFloat(flMin, flMax);
		flAngles2[1] = GetRandomFloat(flMin, flMax);
		flAngles2[2] = -2.0;
		GetVectorAngles(flAngles2, flAngles2);

		TeleportEntity(iRock, flHitPos, flAngles2, NULL_VECTOR);
		AcceptEntityInput(iRock, "LaunchRock");
	}

	return Plugin_Continue;
}

public Action tTimerStopRockSound(Handle timer)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			StopSound(iPlayer, SNDCHAN_BODY, SOUND_ROCK);
		}
	}
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bRock2[iTank])
	{
		g_bRock2[iTank] = false;

		return Plugin_Stop;
	}

	g_bRock2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RockHuman6");

	return Plugin_Continue;
}