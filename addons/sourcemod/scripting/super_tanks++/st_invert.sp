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
	name = "[ST++] Invert Ability",
	author = ST_AUTHOR,
	description = "The Super Tank inverts the survivors' movement keys.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_INVERT "Invert Ability"

bool g_bCloneInstalled, g_bInvert[MAXPLAYERS + 1], g_bInvert2[MAXPLAYERS + 1], g_bInvert3[MAXPLAYERS + 1], g_bInvert4[MAXPLAYERS + 1], g_bInvert5[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sInvertEffect[ST_MAXTYPES + 1][4], g_sInvertEffect2[ST_MAXTYPES + 1][4], g_sInvertMessage[ST_MAXTYPES + 1][3], g_sInvertMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flInvertChance[ST_MAXTYPES + 1], g_flInvertChance2[ST_MAXTYPES + 1], g_flInvertDuration[ST_MAXTYPES + 1], g_flInvertDuration2[ST_MAXTYPES + 1], g_flInvertRange[ST_MAXTYPES + 1], g_flInvertRange2[ST_MAXTYPES + 1], g_flInvertRangeChance[ST_MAXTYPES + 1], g_flInvertRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iInvertAbility[ST_MAXTYPES + 1], g_iInvertAbility2[ST_MAXTYPES + 1], g_iInvertCount[MAXPLAYERS + 1], g_iInvertHit[ST_MAXTYPES + 1], g_iInvertHit2[ST_MAXTYPES + 1], g_iInvertHitMode[ST_MAXTYPES + 1], g_iInvertHitMode2[ST_MAXTYPES + 1], g_iInvertOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Invert Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_invert", cmdInvertInfo, "View information about the Invert ability.");

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

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdInvertInfo(int client, int args)
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
		case false: vInvertMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vInvertMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iInvertMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Invert Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iInvertMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iInvertAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iInvertCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "InvertDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flInvertDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vInvertMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "InvertMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
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
	menu.AddItem(ST_MENU_INVERT, ST_MENU_INVERT);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_INVERT, false))
	{
		vInvertMenu(client, 0);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!ST_PluginEnabled())
	{
		return Plugin_Continue;
	}

	if (g_bInvert[client])
	{
		vel[0] = -vel[0];
		if (buttons & IN_FORWARD)
		{
			buttons &= ~IN_FORWARD;
			buttons |= IN_BACK;
		}
		else if (buttons & IN_BACK)
		{
			buttons &= ~IN_BACK;
			buttons |= IN_FORWARD;
		}

		vel[1] = -vel[1];
		if (buttons & IN_MOVELEFT)
		{
			buttons &= ~IN_MOVELEFT;
			buttons |= IN_MOVERIGHT;
		}
		else if (buttons & IN_MOVERIGHT)
		{
			buttons &= ~IN_MOVERIGHT;
			buttons |= IN_MOVELEFT;
		}

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iInvertHitMode(attacker) == 0 || iInvertHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vInvertHit(victim, attacker, flInvertChance(attacker), iInvertHit(attacker), "1", "1");
			}
		}
		else if ((iInvertHitMode(victim) == 0 || iInvertHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vInvertHit(attacker, victim, flInvertChance(victim), iInvertHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Invert Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Invert Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iInvertAbility[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", 0);
					g_iInvertAbility[iIndex] = iClamp(g_iInvertAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Invert Ability/Ability Effect", g_sInvertEffect[iIndex], sizeof(g_sInvertEffect[]), "0");
					kvSuperTanks.GetString("Invert Ability/Ability Message", g_sInvertMessage[iIndex], sizeof(g_sInvertMessage[]), "0");
					g_flInvertChance[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Chance", 33.3);
					g_flInvertChance[iIndex] = flClamp(g_flInvertChance[iIndex], 0.0, 100.0);
					g_flInvertDuration[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Duration", 5.0);
					g_flInvertDuration[iIndex] = flClamp(g_flInvertDuration[iIndex], 0.1, 9999999999.0);
					g_iInvertHit[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit", 0);
					g_iInvertHit[iIndex] = iClamp(g_iInvertHit[iIndex], 0, 1);
					g_iInvertHitMode[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit Mode", 0);
					g_iInvertHitMode[iIndex] = iClamp(g_iInvertHitMode[iIndex], 0, 2);
					g_flInvertRange[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range", 150.0);
					g_flInvertRange[iIndex] = flClamp(g_flInvertRange[iIndex], 1.0, 9999999999.0);
					g_flInvertRangeChance[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range Chance", 15.0);
					g_flInvertRangeChance[iIndex] = flClamp(g_flInvertRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iInvertAbility2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", g_iInvertAbility[iIndex]);
					g_iInvertAbility2[iIndex] = iClamp(g_iInvertAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Invert Ability/Ability Effect", g_sInvertEffect2[iIndex], sizeof(g_sInvertEffect2[]), g_sInvertEffect[iIndex]);
					kvSuperTanks.GetString("Invert Ability/Ability Message", g_sInvertMessage2[iIndex], sizeof(g_sInvertMessage2[]), g_sInvertMessage[iIndex]);
					g_flInvertChance2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Chance", g_flInvertChance[iIndex]);
					g_flInvertChance2[iIndex] = flClamp(g_flInvertChance2[iIndex], 0.0, 100.0);
					g_flInvertDuration2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Duration", g_flInvertDuration[iIndex]);
					g_flInvertDuration2[iIndex] = flClamp(g_flInvertDuration2[iIndex], 0.1, 9999999999.0);
					g_iInvertHit2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit", g_iInvertHit[iIndex]);
					g_iInvertHit2[iIndex] = iClamp(g_iInvertHit2[iIndex], 0, 1);
					g_iInvertHitMode2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit Mode", g_iInvertHitMode[iIndex]);
					g_iInvertHitMode2[iIndex] = iClamp(g_iInvertHitMode2[iIndex], 0, 2);
					g_flInvertRange2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range", g_flInvertRange[iIndex]);
					g_flInvertRange2[iIndex] = flClamp(g_flInvertRange2[iIndex], 1.0, 9999999999.0);
					g_flInvertRangeChance2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range Chance", g_flInvertRangeChance[iIndex]);
					g_flInvertRangeChance2[iIndex] = flClamp(g_flInvertRangeChance2[iIndex], 0.0, 100.0);
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
			vRemoveInvert(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iInvertAbility(tank) == 1)
	{
		vInvertAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iInvertAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bInvert2[tank] && !g_bInvert3[tank])
				{
					vInvertAbility(tank);
				}
				else if (g_bInvert2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "InvertHuman3");
				}
				else if (g_bInvert3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "InvertHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveInvert(tank);
}

static void vInvertAbility(int tank)
{
	if (g_iInvertCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bInvert4[tank] = false;
		g_bInvert5[tank] = false;

		float flInvertRange = !g_bTankConfig[ST_TankType(tank)] ? g_flInvertRange[ST_TankType(tank)] : g_flInvertRange2[ST_TankType(tank)],
			flInvertRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flInvertRangeChance[ST_TankType(tank)] : g_flInvertRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flInvertRange)
				{
					vInvertHit(iSurvivor, tank, flInvertRangeChance, iInvertAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "InvertHuman5");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "InvertAmmo");
	}
}

static void vInvertHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iInvertCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bInvert[survivor])
			{
				g_bInvert[survivor] = true;
				g_iInvertOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bInvert2[tank])
				{
					g_bInvert2[tank] = true;
					g_iInvertCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "InvertHuman", g_iInvertCount[tank], iHumanAmmo(tank));
				}

				DataPack dpStopInvert;
				CreateDataTimer(flInvertDuration(tank), tTimerStopInvert, dpStopInvert, TIMER_FLAG_NO_MAPCHANGE);
				dpStopInvert.WriteCell(GetClientUserId(survivor));
				dpStopInvert.WriteCell(GetClientUserId(tank));
				dpStopInvert.WriteString(message);

				char sInvertEffect[4];
				sInvertEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sInvertEffect[ST_TankType(tank)] : g_sInvertEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sInvertEffect, mode);

				char sInvertMessage[3];
				sInvertMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sInvertMessage[ST_TankType(tank)] : g_sInvertMessage2[ST_TankType(tank)];
				if (StrContains(sInvertMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Invert", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bInvert2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bInvert4[tank])
				{
					g_bInvert4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "InvertHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bInvert5[tank])
			{
				g_bInvert5[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "InvertAmmo");
			}
		}
	}
}

static void vRemoveInvert(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "24") && g_bInvert[iSurvivor] && g_iInvertOwner[iSurvivor] == tank)
		{
			g_bInvert[iSurvivor] = false;
			g_iInvertOwner[iSurvivor] = 0;
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset2(iPlayer);

			g_iInvertOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bInvert[tank] = false;
	g_bInvert2[tank] = false;
	g_bInvert3[tank] = false;
	g_bInvert4[tank] = false;
	g_bInvert5[tank] = false;
	g_iInvertCount[tank] = 0;
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flInvertChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flInvertChance[ST_TankType(tank)] : g_flInvertChance2[ST_TankType(tank)];
}

static float flInvertDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flInvertDuration[ST_TankType(tank)] : g_flInvertDuration2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iInvertAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertAbility[ST_TankType(tank)] : g_iInvertAbility2[ST_TankType(tank)];
}

static int iInvertHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertHit[ST_TankType(tank)] : g_iInvertHit2[ST_TankType(tank)];
}

static int iInvertHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertHitMode[ST_TankType(tank)] : g_iInvertHitMode2[ST_TankType(tank)];
}

public Action tTimerStopInvert(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bInvert[iSurvivor])
	{
		g_bInvert[iSurvivor] = false;
		g_iInvertOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bInvert[iSurvivor] = false;
		g_iInvertOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bInvert[iSurvivor] = false;
	g_bInvert2[iTank] = false;
	g_iInvertOwner[iSurvivor] = 0;

	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));

	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bInvert3[iTank])
	{
		g_bInvert3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "InvertHuman6");

		if (g_iInvertCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bInvert3[iTank] = false;
		}
	}

	char sInvertMessage[3];
	sInvertMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sInvertMessage[ST_TankType(iTank)] : g_sInvertMessage2[ST_TankType(iTank)];
	if (StrContains(sInvertMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Invert2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bInvert3[iTank])
	{
		g_bInvert3[iTank] = false;

		return Plugin_Stop;
	}

	g_bInvert3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "InvertHuman7");

	return Plugin_Continue;
}