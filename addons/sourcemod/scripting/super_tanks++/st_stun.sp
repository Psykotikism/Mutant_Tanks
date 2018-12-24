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

// Super Tanks++: Stun Ability
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
	name = "[ST++] Stun Ability",
	author = ST_AUTHOR,
	description = "The Super Tank stuns and slows survivors down.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_STUN "Stun Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bStun[MAXPLAYERS + 1], g_bStun2[MAXPLAYERS + 1], g_bStun3[MAXPLAYERS + 1], g_bStun4[MAXPLAYERS + 1], g_bStun5[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sStunEffect[ST_MAXTYPES + 1][4], g_sStunEffect2[ST_MAXTYPES + 1][4], g_sStunMessage[ST_MAXTYPES + 1][3], g_sStunMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flStunChance[ST_MAXTYPES + 1], g_flStunChance2[ST_MAXTYPES + 1], g_flStunDuration[ST_MAXTYPES + 1], g_flStunDuration2[ST_MAXTYPES + 1], g_flStunRange[ST_MAXTYPES + 1], g_flStunRange2[ST_MAXTYPES + 1], g_flStunRangeChance[ST_MAXTYPES + 1], g_flStunRangeChance2[ST_MAXTYPES + 1], g_flStunSpeed[ST_MAXTYPES + 1], g_flStunSpeed2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iStunAbility[ST_MAXTYPES + 1], g_iStunAbility2[ST_MAXTYPES + 1], g_iStunCount[MAXPLAYERS + 1], g_iStunHit[ST_MAXTYPES + 1], g_iStunHit2[ST_MAXTYPES + 1], g_iStunHitMode[ST_MAXTYPES + 1], g_iStunHitMode2[ST_MAXTYPES + 1], g_iStunOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Stun Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_stun", cmdStunInfo, "View information about the Stun ability.");

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

public Action cmdStunInfo(int client, int args)
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
		case false: vStunMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vStunMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iStunMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Stun Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iStunMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iStunAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iStunCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "StunDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flStunDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vStunMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "StunMenu", param1);
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
	menu.AddItem(ST_MENU_STUN, ST_MENU_STUN);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_STUN, false))
	{
		vStunMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iStunHitMode(attacker) == 0 || iStunHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vStunHit(victim, attacker, flStunChance(attacker), iStunHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iStunHitMode(victim) == 0 || iStunHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vStunHit(attacker, victim, flStunChance(victim), iStunHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Stun Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Stun Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 1, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iStunAbility[iIndex] = kvSuperTanks.GetNum("Stun Ability/Ability Enabled", 0);
					g_iStunAbility[iIndex] = iClamp(g_iStunAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Stun Ability/Ability Effect", g_sStunEffect[iIndex], sizeof(g_sStunEffect[]), "0");
					kvSuperTanks.GetString("Stun Ability/Ability Message", g_sStunMessage[iIndex], sizeof(g_sStunMessage[]), "0");
					g_flStunChance[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Chance", 33.3);
					g_flStunChance[iIndex] = flClamp(g_flStunChance[iIndex], 0.0, 100.0);
					g_flStunDuration[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Duration", 5.0);
					g_flStunDuration[iIndex] = flClamp(g_flStunDuration[iIndex], 0.1, 9999999999.0);
					g_iStunHit[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit", 0);
					g_iStunHit[iIndex] = iClamp(g_iStunHit[iIndex], 0, 1);
					g_iStunHitMode[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit Mode", 0);
					g_iStunHitMode[iIndex] = iClamp(g_iStunHitMode[iIndex], 0, 2);
					g_flStunRange[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range", 150.0);
					g_flStunRange[iIndex] = flClamp(g_flStunRange[iIndex], 1.0, 9999999999.0);
					g_flStunRangeChance[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range Chance", 15.0);
					g_flStunRangeChance[iIndex] = flClamp(g_flStunRangeChance[iIndex], 0.0, 100.0);
					g_flStunSpeed[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Speed", 0.25);
					g_flStunSpeed[iIndex] = flClamp(g_flStunSpeed[iIndex], 0.1, 0.9);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 1, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iStunAbility2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Ability Enabled", g_iStunAbility[iIndex]);
					g_iStunAbility2[iIndex] = iClamp(g_iStunAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Stun Ability/Ability Effect", g_sStunEffect2[iIndex], sizeof(g_sStunEffect2[]), g_sStunEffect[iIndex]);
					kvSuperTanks.GetString("Stun Ability/Ability Message", g_sStunMessage2[iIndex], sizeof(g_sStunMessage2[]), g_sStunMessage[iIndex]);
					g_flStunChance2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Chance", g_flStunChance[iIndex]);
					g_flStunChance2[iIndex] = flClamp(g_flStunChance2[iIndex], 0.0, 100.0);
					g_flStunDuration2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Duration", g_flStunDuration[iIndex]);
					g_flStunDuration2[iIndex] = flClamp(g_flStunDuration2[iIndex], 0.1, 9999999999.0);
					g_iStunHit2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit", g_iStunHit[iIndex]);
					g_iStunHit2[iIndex] = iClamp(g_iStunHit2[iIndex], 0, 1);
					g_iStunHitMode2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit Mode", g_iStunHitMode[iIndex]);
					g_iStunHitMode2[iIndex] = iClamp(g_iStunHitMode2[iIndex], 0, 2);
					g_flStunRange2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range", g_flStunRange[iIndex]);
					g_flStunRange2[iIndex] = flClamp(g_flStunRange2[iIndex], 1.0, 9999999999.0);
					g_flStunRangeChance2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range Chance", g_flStunRangeChance[iIndex]);
					g_flStunRangeChance2[iIndex] = flClamp(g_flStunRangeChance2[iIndex], 0.0, 100.0);
					g_flStunSpeed2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Speed", g_flStunSpeed[iIndex]);
					g_flStunSpeed2[iIndex] = flClamp(g_flStunSpeed2[iIndex], 0.1, 0.9);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, "234"))
		{
			vRemoveStun(iTank);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveStun(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iStunAbility(tank) == 1)
	{
		vStunAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iStunAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bStun2[tank] && !g_bStun3[tank])
				{
					vStunAbility(tank);
				}
				else if (g_bStun2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "StunHuman3");
				}
				else if (g_bStun3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "StunHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveStun(tank);
}

static void vRemoveStun(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234") && g_bStun[iSurvivor] && g_iStunOwner[iSurvivor] == tank)
		{
			g_bStun[iSurvivor] = false;
			g_iStunOwner[iSurvivor] = 0;

			SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
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
		}
	}
}

static void vReset2(int tank)
{
	g_bStun[tank] = false;
	g_bStun2[tank] = false;
	g_bStun3[tank] = false;
	g_bStun4[tank] = false;
	g_bStun5[tank] = false;
	g_iStunCount[tank] = 0;
}

static void vStunAbility(int tank)
{
	if (g_iStunCount[tank] < iHumanAmmo(tank))
	{
		g_bStun4[tank] = false;
		g_bStun5[tank] = false;

		float flStunRange = !g_bTankConfig[ST_TankType(tank)] ? g_flStunRange[ST_TankType(tank)] : g_flStunRange2[ST_TankType(tank)],
			flStunRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flStunRangeChance[ST_TankType(tank)] : g_flStunRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flStunRange)
				{
					vStunHit(iSurvivor, tank, flStunRangeChance, iStunAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "StunHuman5");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "StunAmmo");
	}
}

static void vStunHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iStunCount[tank] < iHumanAmmo(tank))
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bStun[survivor])
			{
				g_bStun[survivor] = true;
				g_iStunOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bStun2[tank])
				{
					g_bStun2[tank] = true;
					g_iStunCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "StunHuman", g_iStunCount[tank], iHumanAmmo(tank));
				}

				float flStunSpeed = !g_bTankConfig[ST_TankType(tank)] ? g_flStunSpeed[ST_TankType(tank)] : g_flStunSpeed2[ST_TankType(tank)];
				SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", flStunSpeed);

				DataPack dpStopStun;
				CreateDataTimer(flStunDuration(tank), tTimerStopStun, dpStopStun, TIMER_FLAG_NO_MAPCHANGE);
				dpStopStun.WriteCell(GetClientUserId(survivor));
				dpStopStun.WriteCell(GetClientUserId(tank));
				dpStopStun.WriteString(message);

				char sStunEffect[4];
				sStunEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sStunEffect[ST_TankType(tank)] : g_sStunEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sStunEffect, mode);

				char sStunMessage[3];
				sStunMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sStunMessage[ST_TankType(tank)] : g_sStunMessage2[ST_TankType(tank)];
				if (StrContains(sStunMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Stun", sTankName, survivor, flStunSpeed);
				}
			}
			else if (StrEqual(mode, "3") && !g_bStun2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bStun4[tank])
				{
					g_bStun4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "StunHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bStun5[tank])
			{
				g_bStun5[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "StunAmmo");
			}
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flStunChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flStunChance[ST_TankType(tank)] : g_flStunChance2[ST_TankType(tank)];
}

static float flStunDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flStunDuration[ST_TankType(tank)] : g_flStunDuration2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iStunAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iStunAbility[ST_TankType(tank)] : g_iStunAbility2[ST_TankType(tank)];
}

static int iStunHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iStunHit[ST_TankType(tank)] : g_iStunHit2[ST_TankType(tank)];
}

static int iStunHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iStunHitMode[ST_TankType(tank)] : g_iStunHitMode2[ST_TankType(tank)];
}

public Action tTimerStopStun(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bStun[iSurvivor] = false;
		g_iStunOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bStun[iSurvivor])
	{
		g_bStun[iSurvivor] = false;
		g_iStunOwner[iSurvivor] = 0;

		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);

		return Plugin_Stop;
	}

	g_bStun[iSurvivor] = false;
	g_bStun2[iTank] = false;
	g_iStunOwner[iSurvivor] = 0;

	SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);

	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));

	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bStun3[iTank])
	{
		g_bStun3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "StunHuman6");

		if (g_iStunCount[iTank] < iHumanAmmo(iTank))
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bStun3[iTank] = false;
		}
	}

	char sStunMessage[3];
	sStunMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sStunMessage[ST_TankType(iTank)] : g_sStunMessage2[ST_TankType(iTank)];
	if (StrContains(sStunMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Stun2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bStun3[iTank])
	{
		g_bStun3[iTank] = false;

		return Plugin_Stop;
	}

	g_bStun3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "StunHuman7");

	return Plugin_Continue;
}