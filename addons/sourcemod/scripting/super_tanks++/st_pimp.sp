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
	name = "[ST++] Pimp Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pimp slaps survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_PIMP "Pimp Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bPimp[MAXPLAYERS + 1], g_bPimp2[MAXPLAYERS + 1], g_bPimp3[MAXPLAYERS + 1], g_bPimp4[MAXPLAYERS + 1], g_bPimp5[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sPimpEffect[ST_MAXTYPES + 1][4], g_sPimpEffect2[ST_MAXTYPES + 1][4], g_sPimpMessage[ST_MAXTYPES + 1][3], g_sPimpMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flPimpChance[ST_MAXTYPES + 1], g_flPimpChance2[ST_MAXTYPES + 1], g_flPimpDuration[ST_MAXTYPES + 1], g_flPimpDuration2[ST_MAXTYPES + 1], g_flPimpInterval[ST_MAXTYPES + 1], g_flPimpInterval2[ST_MAXTYPES + 1], g_flPimpRange[ST_MAXTYPES + 1], g_flPimpRange2[ST_MAXTYPES + 1], g_flPimpRangeChance[ST_MAXTYPES + 1], g_flPimpRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iPimpAbility[ST_MAXTYPES + 1], g_iPimpAbility2[ST_MAXTYPES + 1], g_iPimpCount[MAXPLAYERS + 1], g_iPimpDamage[ST_MAXTYPES + 1], g_iPimpDamage2[ST_MAXTYPES + 1], g_iPimpHit[ST_MAXTYPES + 1], g_iPimpHit2[ST_MAXTYPES + 1], g_iPimpHitMode[ST_MAXTYPES + 1], g_iPimpHitMode2[ST_MAXTYPES + 1], g_iPimpOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Pimp Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_pimp", cmdPimpInfo, "View information about the Pimp ability.");

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

	vRemovePimp(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdPimpInfo(int client, int args)
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
		case false: vPimpMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vPimpMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iPimpMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Pimp Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iPimpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iPimpAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iPimpCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "PimpDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flPimpDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vPimpMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "PimpMenu", param1);
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
	menu.AddItem(ST_MENU_PIMP, ST_MENU_PIMP);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_PIMP, false))
	{
		vPimpMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iPimpHitMode(attacker) == 0 || iPimpHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPimpHit(victim, attacker, flPimpChance(attacker), iPimpHit(attacker), "1", "1");
			}
		}
		else if ((iPimpHitMode(victim) == 0 || iPimpHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPimpHit(attacker, victim, flPimpChance(victim), iPimpHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iPimpAbility[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Enabled", 0);
					g_iPimpAbility[iIndex] = iClamp(g_iPimpAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Pimp Ability/Ability Effect", g_sPimpEffect[iIndex], sizeof(g_sPimpEffect[]), "0");
					kvSuperTanks.GetString("Pimp Ability/Ability Message", g_sPimpMessage[iIndex], sizeof(g_sPimpMessage[]), "0");
					g_flPimpChance[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Chance", 33.3);
					g_flPimpChance[iIndex] = flClamp(g_flPimpChance[iIndex], 0.0, 100.0);
					g_iPimpDamage[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Damage", 1);
					g_iPimpDamage[iIndex] = iClamp(g_iPimpDamage[iIndex], 1, 9999999999);
					g_flPimpDuration[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Duration", 5.0);
					g_flPimpDuration[iIndex] = flClamp(g_flPimpDuration[iIndex], 0.1, 9999999999.0);
					g_iPimpHit[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit", 0);
					g_iPimpHit[iIndex] = iClamp(g_iPimpHit[iIndex], 0, 1);
					g_iPimpHitMode[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit Mode", 0);
					g_iPimpHitMode[iIndex] = iClamp(g_iPimpHitMode[iIndex], 0, 2);
					g_flPimpInterval[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Interval", 1.0);
					g_flPimpInterval[iIndex] = flClamp(g_flPimpInterval[iIndex], 0.1, 9999999999.0);
					g_flPimpRange[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range", 150.0);
					g_flPimpRange[iIndex] = flClamp(g_flPimpRange[iIndex], 1.0, 9999999999.0);
					g_flPimpRangeChance[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range Chance", 15.0);
					g_flPimpRangeChance[iIndex] = flClamp(g_flPimpRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iPimpAbility2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Enabled", g_iPimpAbility[iIndex]);
					g_iPimpAbility2[iIndex] = iClamp(g_iPimpAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Pimp Ability/Ability Effect", g_sPimpEffect2[iIndex], sizeof(g_sPimpEffect2[]), g_sPimpEffect[iIndex]);
					kvSuperTanks.GetString("Pimp Ability/Ability Message", g_sPimpMessage2[iIndex], sizeof(g_sPimpMessage2[]), g_sPimpMessage[iIndex]);
					g_flPimpChance2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Chance", g_flPimpChance[iIndex]);
					g_flPimpChance2[iIndex] = flClamp(g_flPimpChance2[iIndex], 0.0, 100.0);
					g_iPimpDamage2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Damage", g_iPimpDamage[iIndex]);
					g_iPimpDamage2[iIndex] = iClamp(g_iPimpDamage2[iIndex], 1, 9999999999);
					g_flPimpDuration2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Duration", g_flPimpDuration[iIndex]);
					g_flPimpDuration2[iIndex] = flClamp(g_flPimpDuration2[iIndex], 0.1, 9999999999.0);
					g_iPimpHit2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit", g_iPimpHit[iIndex]);
					g_iPimpHit2[iIndex] = iClamp(g_iPimpHit2[iIndex], 0, 1);
					g_iPimpHitMode2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit Mode", g_iPimpHitMode[iIndex]);
					g_iPimpHitMode2[iIndex] = iClamp(g_iPimpHitMode2[iIndex], 0, 2);
					g_flPimpInterval2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Interval", g_flPimpInterval[iIndex]);
					g_flPimpInterval2[iIndex] = flClamp(g_flPimpInterval2[iIndex], 0.1, 9999999999.0);
					g_flPimpRange2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range", g_flPimpRange[iIndex]);
					g_flPimpRange2[iIndex] = flClamp(g_flPimpRange2[iIndex], 1.0, 9999999999.0);
					g_flPimpRangeChance2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range Chance", g_flPimpRangeChance[iIndex]);
					g_flPimpRangeChance2[iIndex] = flClamp(g_flPimpRangeChance2[iIndex], 0.0, 100.0);
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
			vRemovePimp(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iPimpAbility(tank) == 1)
	{
		vPimpAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iPimpAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bPimp2[tank] && !g_bPimp3[tank])
				{
					vPimpAbility(tank);
				}
				else if (g_bPimp2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman3");
				}
				else if (g_bPimp3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemovePimp(tank);
}

static void vPimpAbility(int tank)
{
	if (g_iPimpCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bPimp4[tank] = false;
		g_bPimp5[tank] = false;

		float flPimpRange = !g_bTankConfig[ST_TankType(tank)] ? g_flPimpRange[ST_TankType(tank)] : g_flPimpRange2[ST_TankType(tank)],
			flPimpRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flPimpRangeChance[ST_TankType(tank)] : g_flPimpRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flPimpRange)
				{
					vPimpHit(iSurvivor, tank, flPimpRangeChance, iPimpAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman5");
			}
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpAmmo");
	}
}

static void vPimpHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iPimpCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bPimp[survivor])
			{
				g_bPimp[survivor] = true;
				g_iPimpOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bPimp2[tank])
				{
					g_bPimp2[tank] = true;
					g_iPimpCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman", g_iPimpCount[tank], iHumanAmmo(tank));
				}

				float flPimpInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flPimpInterval[ST_TankType(tank)] : g_flPimpInterval2[ST_TankType(tank)];
				DataPack dpPimp;
				CreateDataTimer(flPimpInterval, tTimerPimp, dpPimp, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpPimp.WriteCell(GetClientUserId(survivor));
				dpPimp.WriteCell(GetClientUserId(tank));
				dpPimp.WriteString(message);
				dpPimp.WriteCell(enabled);
				dpPimp.WriteFloat(GetEngineTime());

				char sPimpEffect[4];
				sPimpEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sPimpEffect[ST_TankType(tank)] : g_sPimpEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sPimpEffect, mode);

				char sPimpMessage[3];
				sPimpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sPimpMessage[ST_TankType(tank)] : g_sPimpMessage2[ST_TankType(tank)];
				if (StrContains(sPimpMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Pimp", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bPimp2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bPimp4[tank])
				{
					g_bPimp4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman2");
				}
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bPimp5[tank])
		{
			g_bPimp5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpAmmo");
		}
	}
}

static void vRemovePimp(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bPimp[iSurvivor] && g_iPimpOwner[iSurvivor] == tank)
		{
			g_bPimp[iSurvivor] = false;
			g_iPimpOwner[iSurvivor] = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset3(iPlayer);

			g_iPimpOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bPimp[survivor] = false;
	g_iPimpOwner[survivor] = 0;

	char sPimpMessage[3];
	sPimpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sPimpMessage[ST_TankType(tank)] : g_sPimpMessage2[ST_TankType(tank)];
	if (StrContains(sPimpMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Pimp2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bPimp[tank] = false;
	g_bPimp2[tank] = false;
	g_bPimp3[tank] = false;
	g_bPimp4[tank] = false;
	g_bPimp5[tank] = false;
	g_iPimpCount[tank] = 0;
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flPimpChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flPimpChance[ST_TankType(tank)] : g_flPimpChance2[ST_TankType(tank)];
}

static float flPimpDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flPimpDuration[ST_TankType(tank)] : g_flPimpDuration2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iPimpAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPimpAbility[ST_TankType(tank)] : g_iPimpAbility2[ST_TankType(tank)];
}

static int iPimpHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPimpHit[ST_TankType(tank)] : g_iPimpHit2[ST_TankType(tank)];
}

static int iPimpHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPimpHitMode[ST_TankType(tank)] : g_iPimpHitMode2[ST_TankType(tank)];
}

public Action tTimerPimp(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bPimp[iSurvivor] = false;
		g_iPimpOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bPimp[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iPimpEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iPimpEnabled == 0 || (flTime + flPimpDuration(iTank)) < GetEngineTime() || !g_bPimp[iSurvivor])
	{
		g_bPimp2[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bPimp3[iTank])
		{
			g_bPimp3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "PimpHuman6");

			if (g_iPimpCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bPimp3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	int iPimpDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iPimpDamage[ST_TankType(iTank)] : g_iPimpDamage2[ST_TankType(iTank)];
	SlapPlayer(iSurvivor, iPimpDamage, true);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bPimp3[iTank])
	{
		g_bPimp3[iTank] = false;

		return Plugin_Stop;
	}

	g_bPimp3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "PimpHuman7");

	return Plugin_Continue;
}