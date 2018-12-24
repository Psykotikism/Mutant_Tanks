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
	name = "[ST++] Fling Ability",
	author = ST_AUTHOR,
	description = "The Super Tank flings survivors high into the air.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_FLING "Fling Ability"

bool g_bCloneInstalled, g_bFling[MAXPLAYERS + 1], g_bFling2[MAXPLAYERS + 1], g_bFling3[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sFlingEffect[ST_MAXTYPES + 1][4], g_sFlingEffect2[ST_MAXTYPES + 1][4], g_sFlingMessage[ST_MAXTYPES + 1][3], g_sFlingMessage2[ST_MAXTYPES + 1][3];

float g_flFlingChance[ST_MAXTYPES + 1], g_flFlingChance2[ST_MAXTYPES + 1], g_flFlingRange[ST_MAXTYPES + 1], g_flFlingRange2[ST_MAXTYPES + 1], g_flFlingRangeChance[ST_MAXTYPES + 1], g_flFlingRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

Handle g_hSDKFlingPlayer, g_hSDKPukePlayer;

int g_iFlingAbility[ST_MAXTYPES + 1], g_iFlingAbility2[ST_MAXTYPES + 1], g_iFlingCount[MAXPLAYERS + 1], g_iFlingHit[ST_MAXTYPES + 1], g_iFlingHit2[ST_MAXTYPES + 1], g_iFlingHitMode[ST_MAXTYPES + 1], g_iFlingHitMode2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Fling Ability\" only supports Left 4 Dead 1 & 2.");

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
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_fling", cmdFlingInfo, "View information about the Fling ability.");

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	if (bIsValidGame())
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_Fling");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		g_hSDKFlingPlayer = EndPrepSDKCall();

		if (g_hSDKFlingPlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_Fling\" signature is outdated.", ST_TAG);
		}
	}
	else
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hSDKPukePlayer = EndPrepSDKCall();

		if (g_hSDKPukePlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_TAG);
		}
	}

	delete gdSuperTanks;

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

	vRemoveFling(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFlingInfo(int client, int args)
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
		case false: vFlingMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFlingMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFlingMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fling Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iFlingMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iFlingAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iFlingCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "FlingDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vFlingMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "FlingMenu", param1);
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
	menu.AddItem(ST_MENU_FLING, ST_MENU_FLING);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_FLING, false))
	{
		vFlingMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iFlingHitMode(attacker) == 0 || iFlingHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vFlingHit(victim, attacker, flFlingChance(attacker), iFlingHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iFlingHitMode(victim) == 0 || iFlingHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vFlingHit(attacker, victim, flFlingChance(victim), iFlingHit(victim), "1", "2");
			}
		}
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Fling Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Fling Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 1, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iFlingAbility[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", 0);
					g_iFlingAbility[iIndex] = iClamp(g_iFlingAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Fling Ability/Ability Effect", g_sFlingEffect[iIndex], sizeof(g_sFlingEffect[]), "0");
					kvSuperTanks.GetString("Fling Ability/Ability Message", g_sFlingMessage[iIndex], sizeof(g_sFlingMessage[]), "0");
					g_flFlingChance[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Chance", 33.3);
					g_flFlingChance[iIndex] = flClamp(g_flFlingChance[iIndex], 0.0, 100.0);
					g_iFlingHit[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", 0);
					g_iFlingHit[iIndex] = iClamp(g_iFlingHit[iIndex], 0, 1);
					g_iFlingHitMode[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit Mode", 0);
					g_iFlingHitMode[iIndex] = iClamp(g_iFlingHitMode[iIndex], 0, 2);
					g_flFlingRange[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", 150.0);
					g_flFlingRange[iIndex] = flClamp(g_flFlingRange[iIndex], 1.0, 9999999999.0);
					g_flFlingRangeChance[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range Chance", 15.0);
					g_flFlingRangeChance[iIndex] = flClamp(g_flFlingRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 1, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iFlingAbility2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", g_iFlingAbility[iIndex]);
					g_iFlingAbility2[iIndex] = iClamp(g_iFlingAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Fling Ability/Ability Effect", g_sFlingEffect2[iIndex], sizeof(g_sFlingEffect2[]), g_sFlingEffect[iIndex]);
					kvSuperTanks.GetString("Fling Ability/Ability Message", g_sFlingMessage2[iIndex], sizeof(g_sFlingMessage2[]), g_sFlingMessage[iIndex]);
					g_flFlingChance2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Chance", g_flFlingChance[iIndex]);
					g_flFlingChance2[iIndex] = flClamp(g_flFlingChance2[iIndex], 0.0, 100.0);
					g_iFlingHit2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", g_iFlingHit[iIndex]);
					g_iFlingHit2[iIndex] = iClamp(g_iFlingHit2[iIndex], 0, 1);
					g_iFlingHitMode2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit Mode", g_iFlingHitMode[iIndex]);
					g_iFlingHitMode2[iIndex] = iClamp(g_iFlingHitMode2[iIndex], 0, 2);
					g_flFlingRange2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", g_flFlingRange[iIndex]);
					g_flFlingRange2[iIndex] = flClamp(g_flFlingRange2[iIndex], 1.0, 9999999999.0);
					g_flFlingRangeChance2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range Chance", g_flFlingRangeChance[iIndex]);
					g_flFlingRangeChance2[iIndex] = flClamp(g_flFlingRangeChance2[iIndex], 0.0, 100.0);
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
			vRemoveFling(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iFlingAbility(tank) == 1)
	{
		vFlingAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iFlingAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bFling[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingHuman3");
					case false: vFlingAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveFling(tank);
}

static void vFlingAbility(int tank)
{
	if (g_iFlingCount[tank] < iHumanAmmo(tank))
	{
		g_bFling2[tank] = false;
		g_bFling3[tank] = false;

		float flFlingRange = !g_bTankConfig[ST_TankType(tank)] ? g_flFlingRange[ST_TankType(tank)] : g_flFlingRange2[ST_TankType(tank)],
			flFlingRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flFlingRangeChance[ST_TankType(tank)] : g_flFlingRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flFlingRange)
				{
					vFlingHit(iSurvivor, tank, flFlingRangeChance, iFlingAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingHuman4");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingAmmo");
	}
}

static void vFlingHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iFlingCount[tank] < iHumanAmmo(tank))
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bFling[tank])
				{
					g_bFling[tank] = true;
					g_iFlingCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingHuman", g_iFlingCount[tank], iHumanAmmo(tank));

					if (g_iFlingCount[tank] < iHumanAmmo(tank))
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bFling[tank] = false;
					}
				}

				char sTankName[33], sFlingMessage[3];
				ST_TankName(tank, sTankName);
				sFlingMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sFlingMessage[ST_TankType(tank)] : g_sFlingMessage2[ST_TankType(tank)];

				if (bIsValidGame())
				{
					float flSurvivorPos[3], flSurvivorVelocity[3], flTankPos[3], flDistance[3], flRatio[3], flVelocity[3];
					GetClientAbsOrigin(survivor, flSurvivorPos);
					GetClientAbsOrigin(tank, flTankPos);

					flDistance[0] = (flTankPos[0] - flSurvivorPos[0]);
					flDistance[1] = (flTankPos[1] - flSurvivorPos[1]);
					flDistance[2] = (flTankPos[2] - flSurvivorPos[2]);
					GetEntPropVector(survivor, Prop_Data, "m_vecVelocity", flSurvivorVelocity);
					flRatio[0] = flDistance[0] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));
					flRatio[1] = flDistance[1] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));
					flVelocity[0] = (flRatio[0] * -1) * 500.0;
					flVelocity[1] = (flRatio[1] * -1) * 500.0;
					flVelocity[2] = 500.0;

					SDKCall(g_hSDKFlingPlayer, survivor, flVelocity, 76, tank, 7.0);

					if (StrContains(sFlingMessage, message) != -1)
					{
						ST_PrintToChatAll("%s %t", ST_TAG2, "Fling", sTankName, survivor);
					}
				}
				else
				{
					SDKCall(g_hSDKPukePlayer, survivor, tank, true);

					if (StrContains(sFlingMessage, message) != -1)
					{
						ST_PrintToChatAll("%s %t", ST_TAG2, "Puke", sTankName, survivor);
					}
				}

				char sFlingEffect[4];
				sFlingEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sFlingEffect[ST_TankType(tank)] : g_sFlingEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sFlingEffect, mode);
			}
			else if (StrEqual(mode, "3") && !g_bFling[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bFling2[tank])
				{
					g_bFling2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bFling3[tank])
			{
				g_bFling3[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingAmmo");
			}
		}
	}
}

static void vRemoveFling(int tank)
{
	g_bFling[tank] = false;
	g_bFling2[tank] = false;
	g_bFling3[tank] = false;
	g_iFlingCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveFling(iPlayer);
		}
	}
}

static float flFlingChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flFlingChance[ST_TankType(tank)] : g_flFlingChance2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iFlingAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFlingAbility[ST_TankType(tank)] : g_iFlingAbility2[ST_TankType(tank)];
}

static int iFlingHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFlingHit[ST_TankType(tank)] : g_iFlingHit2[ST_TankType(tank)];
}

static int iFlingHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFlingHitMode[ST_TankType(tank)] : g_iFlingHitMode2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bFling[iTank])
	{
		g_bFling[iTank] = false;

		return Plugin_Stop;
	}

	g_bFling[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "FlingHuman5");

	return Plugin_Continue;
}