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
	name = "[ST++] Nullify Ability",
	author = ST_AUTHOR,
	description = "The Super Tank nullifies all of the survivors' damage.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_NULLIFY "Nullify Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bNullify[MAXPLAYERS + 1], g_bNullify2[MAXPLAYERS + 1], g_bNullify3[MAXPLAYERS + 1], g_bNullify4[MAXPLAYERS + 1], g_bNullify5[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sNullifyEffect[ST_MAXTYPES + 1][4], g_sNullifyEffect2[ST_MAXTYPES + 1][4], g_sNullifyMessage[ST_MAXTYPES + 1][3], g_sNullifyMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flNullifyChance[ST_MAXTYPES + 1], g_flNullifyChance2[ST_MAXTYPES + 1], g_flNullifyDuration[ST_MAXTYPES + 1], g_flNullifyDuration2[ST_MAXTYPES + 1], g_flNullifyRange[ST_MAXTYPES + 1], g_flNullifyRange2[ST_MAXTYPES + 1], g_flNullifyRangeChance[ST_MAXTYPES + 1], g_flNullifyRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iNullifyAbility[ST_MAXTYPES + 1], g_iNullifyAbility2[ST_MAXTYPES + 1], g_iNullifyCount[MAXPLAYERS + 1], g_iNullifyHit[ST_MAXTYPES + 1], g_iNullifyHit2[ST_MAXTYPES + 1], g_iNullifyHitMode[ST_MAXTYPES + 1], g_iNullifyHitMode2[ST_MAXTYPES + 1], g_iNullifyOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Nullify Ability\" only supports Left 4 Dead 1 & 2.");

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
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_nullify", cmdNullifyInfo, "View information about the Nullify ability.");

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

public Action cmdNullifyInfo(int client, int args)
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
		case false: vNullifyMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vNullifyMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iNullifyMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Nullify Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iNullifyMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iNullifyAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iNullifyCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "NullifyDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flNullifyDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vNullifyMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "NullifyMenu", param1);
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
	menu.AddItem(ST_MENU_NULLIFY, ST_MENU_NULLIFY);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_NULLIFY, false))
	{
		vNullifyMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iNullifyHitMode(attacker) == 0 || iNullifyHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vNullifyHit(victim, attacker, flNullifyChance(attacker), iNullifyHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if ((iNullifyHitMode(victim) == 0 || iNullifyHitMode(victim) == 2) && StrEqual(sClassname, "weapon_melee"))
			{
				vNullifyHit(attacker, victim, flNullifyChance(victim), iNullifyHit(victim), "1", "2");
			}

			if (g_bNullify[attacker])
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iNullifyAbility[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", 0);
					g_iNullifyAbility[iIndex] = iClamp(g_iNullifyAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Nullify Ability/Ability Effect", g_sNullifyEffect[iIndex], sizeof(g_sNullifyEffect[]), "0");
					kvSuperTanks.GetString("Nullify Ability/Ability Message", g_sNullifyMessage[iIndex], sizeof(g_sNullifyMessage[]), "0");
					g_flNullifyChance[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Chance", 33.3);
					g_flNullifyChance[iIndex] = flClamp(g_flNullifyChance[iIndex], 0.0, 100.0);
					g_flNullifyDuration[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", 5.0);
					g_flNullifyDuration[iIndex] = flClamp(g_flNullifyDuration[iIndex], 0.1, 9999999999.0);
					g_iNullifyHit[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", 0);
					g_iNullifyHit[iIndex] = iClamp(g_iNullifyHit[iIndex], 0, 1);
					g_iNullifyHitMode[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit Mode", 0);
					g_iNullifyHitMode[iIndex] = iClamp(g_iNullifyHitMode[iIndex], 0, 2);
					g_flNullifyRange[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", 150.0);
					g_flNullifyRange[iIndex] = flClamp(g_flNullifyRange[iIndex], 1.0, 9999999999.0);
					g_flNullifyRangeChance[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range Chance", 15.0);
					g_flNullifyRangeChance[iIndex] = flClamp(g_flNullifyRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iNullifyAbility2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", g_iNullifyAbility[iIndex]);
					g_iNullifyAbility2[iIndex] = iClamp(g_iNullifyAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Nullify Ability/Ability Effect", g_sNullifyEffect2[iIndex], sizeof(g_sNullifyEffect2[]), g_sNullifyEffect[iIndex]);
					kvSuperTanks.GetString("Nullify Ability/Ability Message", g_sNullifyMessage2[iIndex], sizeof(g_sNullifyMessage2[]), g_sNullifyMessage[iIndex]);
					g_flNullifyChance2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Chance", g_flNullifyChance[iIndex]);
					g_flNullifyChance2[iIndex] = flClamp(g_flNullifyChance2[iIndex], 0.0, 100.0);
					g_flNullifyDuration2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", g_flNullifyDuration[iIndex]);
					g_flNullifyDuration2[iIndex] = flClamp(g_flNullifyDuration2[iIndex], 0.1, 9999999999.0);
					g_iNullifyHit2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", g_iNullifyHit[iIndex]);
					g_iNullifyHit2[iIndex] = iClamp(g_iNullifyHit2[iIndex], 0, 1);
					g_iNullifyHitMode2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit Mode", g_iNullifyHitMode[iIndex]);
					g_iNullifyHitMode2[iIndex] = iClamp(g_iNullifyHitMode2[iIndex], 0, 2);
					g_flNullifyRange2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", g_flNullifyRange[iIndex]);
					g_flNullifyRange2[iIndex] = flClamp(g_flNullifyRange2[iIndex], 1.0, 9999999999.0);
					g_flNullifyRangeChance2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range Chance", g_flNullifyRangeChance[iIndex]);
					g_flNullifyRangeChance2[iIndex] = flClamp(g_flNullifyRangeChance2[iIndex], 0.0, 100.0);
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
			vRemoveNullify(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iNullifyAbility(tank) == 1)
	{
		vNullifyAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iNullifyAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bNullify2[tank] && !g_bNullify3[tank])
				{
					vNullifyAbility(tank);
				}
				else if (g_bNullify2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyHuman3");
				}
				else if (g_bNullify3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveNullify(tank);
}

static void vNullifyAbility(int tank)
{
	if (g_iNullifyCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bNullify4[tank] = false;
		g_bNullify5[tank] = false;

		float flNullifyRange = !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyRange[ST_TankType(tank)] : g_flNullifyRange2[ST_TankType(tank)],
			flNullifyRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyRangeChance[ST_TankType(tank)] : g_flNullifyRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flNullifyRange)
				{
					vNullifyHit(iSurvivor, tank, flNullifyRangeChance, iNullifyAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyHuman5");
			}
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyAmmo");
	}
}

static void vNullifyHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iNullifyCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bNullify[survivor])
			{
				g_bNullify[survivor] = true;
				g_iNullifyOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bNullify2[tank])
				{
					g_bNullify2[tank] = true;
					g_iNullifyCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyHuman", g_iNullifyCount[tank], iHumanAmmo(tank));
				}

				DataPack dpStopNullify;
				CreateDataTimer(flNullifyDuration(tank), tTimerStopNullify, dpStopNullify, TIMER_FLAG_NO_MAPCHANGE);
				dpStopNullify.WriteCell(GetClientUserId(survivor));
				dpStopNullify.WriteCell(GetClientUserId(tank));
				dpStopNullify.WriteString(message);

				char sNullifyEffect[4];
				sNullifyEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sNullifyEffect[ST_TankType(tank)] : g_sNullifyEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sNullifyEffect, mode);

				char sNullifyMessage[3];
				sNullifyMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sNullifyMessage[ST_TankType(tank)] : g_sNullifyMessage2[ST_TankType(tank)];
				if (StrContains(sNullifyMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Nullify", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bNullify2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bNullify4[tank])
				{
					g_bNullify4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyHuman2");
				}
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bNullify5[tank])
		{
			g_bNullify5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyAmmo");
		}
	}
}

static void vRemoveNullify(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "24") && g_bNullify[iSurvivor] && g_iNullifyOwner[iSurvivor] == tank)
		{
			g_bNullify[iSurvivor] = false;
			g_iNullifyOwner[iSurvivor] = 0;
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

			g_iNullifyOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bNullify[tank] = false;
	g_bNullify2[tank] = false;
	g_bNullify3[tank] = false;
	g_bNullify4[tank] = false;
	g_bNullify5[tank] = false;
	g_iNullifyCount[tank] = 0;
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flNullifyChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyChance[ST_TankType(tank)] : g_flNullifyChance2[ST_TankType(tank)];
}

static float flNullifyDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyDuration[ST_TankType(tank)] : g_flNullifyDuration2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iNullifyAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyAbility[ST_TankType(tank)] : g_iNullifyAbility2[ST_TankType(tank)];
}

static int iNullifyHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyHit[ST_TankType(tank)] : g_iNullifyHit2[ST_TankType(tank)];
}

static int iNullifyHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyHitMode[ST_TankType(tank)] : g_iNullifyHitMode2[ST_TankType(tank)];
}

public Action tTimerStopNullify(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bNullify[iSurvivor])
	{
		g_bNullify[iSurvivor] = false;
		g_iNullifyOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bNullify[iSurvivor] = false;
		g_iNullifyOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bNullify[iSurvivor] = false;
	g_bNullify2[iTank] = false;
	g_iNullifyOwner[iSurvivor] = 0;

	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));

	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bNullify3[iTank])
	{
		g_bNullify3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "NullifyHuman6");

		if (g_iNullifyCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bNullify3[iTank] = false;
		}
	}

	char sNullifyMessage[3];
	sNullifyMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sNullifyMessage[ST_TankType(iTank)] : g_sNullifyMessage2[ST_TankType(iTank)];
	if (StrContains(sNullifyMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Nullify2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bNullify3[iTank])
	{
		g_bNullify3[iTank] = false;

		return Plugin_Stop;
	}

	g_bNullify3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "NullifyHuman7");

	return Plugin_Continue;
}