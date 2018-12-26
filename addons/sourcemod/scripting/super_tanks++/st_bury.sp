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
	name = "[ST++] Bury Ability",
	author = ST_AUTHOR,
	description = "The Super Tank buries survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_BURY "Bury Ability"

bool g_bBury[MAXPLAYERS + 1], g_bBury2[MAXPLAYERS + 1], g_bBury3[MAXPLAYERS + 1], g_bBury4[MAXPLAYERS + 1], g_bBury5[MAXPLAYERS + 1], g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sBuryEffect[ST_MAXTYPES + 1][4], g_sBuryEffect2[ST_MAXTYPES + 1][4], g_sBuryMessage[ST_MAXTYPES + 1][3], g_sBuryMessage2[ST_MAXTYPES + 1][3];

float g_flBuryChance[ST_MAXTYPES + 1], g_flBuryChance2[ST_MAXTYPES + 1], g_flBuryDuration[ST_MAXTYPES + 1], g_flBuryDuration2[ST_MAXTYPES + 1], g_flBuryHeight[ST_MAXTYPES + 1], g_flBuryHeight2[ST_MAXTYPES + 1], g_flBuryRange[ST_MAXTYPES + 1], g_flBuryRange2[ST_MAXTYPES + 1], g_flBuryRangeChance[ST_MAXTYPES + 1], g_flBuryRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iBuryAbility[ST_MAXTYPES + 1], g_iBuryAbility2[ST_MAXTYPES + 1], g_iBuryCount[MAXPLAYERS + 1], g_iBuryHit[ST_MAXTYPES + 1], g_iBuryHit2[ST_MAXTYPES + 1], g_iBuryHitMode[ST_MAXTYPES + 1], g_iBuryHitMode2[ST_MAXTYPES + 1], g_iBuryOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Bury Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_bury", cmdBuryInfo, "View information about the Bury ability.");

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

public Action cmdBuryInfo(int client, int args)
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
		case false: vBuryMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vBuryMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iBuryMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Bury Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iBuryMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iBuryAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iBuryCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "BuryDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flBuryDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vBuryMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "BuryMenu", param1);
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
	menu.AddItem(ST_MENU_BURY, ST_MENU_BURY);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_BURY, false))
	{
		vBuryMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iBuryHitMode(attacker) == 0 || iBuryHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBuryHit(victim, attacker, flBuryChance(attacker), iBuryHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iBuryHitMode(victim) == 0 || iBuryHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBuryHit(attacker, victim, flBuryChance(victim), iBuryHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Bury Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Bury Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iBuryAbility[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Enabled", 0);
					g_iBuryAbility[iIndex] = iClamp(g_iBuryAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Bury Ability/Ability Effect", g_sBuryEffect[iIndex], sizeof(g_sBuryEffect[]), "0");
					kvSuperTanks.GetString("Bury Ability/Ability Message", g_sBuryMessage[iIndex], sizeof(g_sBuryMessage[]), "0");
					g_flBuryChance[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Chance", 33.3);
					g_flBuryChance[iIndex] = flClamp(g_flBuryChance[iIndex], 0.0, 100.0);
					g_flBuryDuration[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Duration", 5.0);
					g_flBuryDuration[iIndex] = flClamp(g_flBuryDuration[iIndex], 0.1, 9999999999.0);
					g_flBuryHeight[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Height", 50.0);
					g_flBuryHeight[iIndex] = flClamp(g_flBuryHeight[iIndex], 0.1, 9999999999.0);
					g_iBuryHit[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit", 0);
					g_iBuryHit[iIndex] = iClamp(g_iBuryHit[iIndex], 0, 1);
					g_iBuryHitMode[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit Mode", 0);
					g_iBuryHitMode[iIndex] = iClamp(g_iBuryHitMode[iIndex], 0, 2);
					g_flBuryRange[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range", 150.0);
					g_flBuryRange[iIndex] = flClamp(g_flBuryRange[iIndex], 1.0, 9999999999.0);
					g_flBuryRangeChance[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range Chance", 15.0);
					g_flBuryRangeChance[iIndex] = flClamp(g_flBuryRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iBuryAbility2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Enabled", g_iBuryAbility[iIndex]);
					g_iBuryAbility2[iIndex] = iClamp(g_iBuryAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Bury Ability/Ability Effect", g_sBuryEffect2[iIndex], sizeof(g_sBuryEffect2[]), g_sBuryEffect[iIndex]);
					kvSuperTanks.GetString("Bury Ability/Ability Message", g_sBuryMessage2[iIndex], sizeof(g_sBuryMessage2[]), g_sBuryMessage[iIndex]);
					g_flBuryChance2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Chance", g_flBuryChance[iIndex]);
					g_flBuryChance2[iIndex] = flClamp(g_flBuryChance2[iIndex], 0.0, 100.0);
					g_flBuryDuration2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Duration", g_flBuryDuration[iIndex]);
					g_flBuryDuration2[iIndex] = flClamp(g_flBuryDuration2[iIndex], 0.1, 9999999999.0);
					g_flBuryHeight2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Height", g_flBuryHeight[iIndex]);
					g_flBuryHeight2[iIndex] = flClamp(g_flBuryHeight2[iIndex], 0.1, 9999999999.0);
					g_iBuryHit2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit", g_iBuryHit[iIndex]);
					g_iBuryHit2[iIndex] = iClamp(g_iBuryHit2[iIndex], 0, 1);
					g_iBuryHitMode2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit Mode", g_iBuryHitMode[iIndex]);
					g_iBuryHitMode2[iIndex] = iClamp(g_iBuryHitMode2[iIndex], 0, 2);
					g_flBuryRange2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range", g_flBuryRange[iIndex]);
					g_flBuryRange2[iIndex] = flClamp(g_flBuryRange2[iIndex], 1.0, 9999999999.0);
					g_flBuryRangeChance2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range Chance", g_flBuryRangeChance[iIndex]);
					g_flBuryRangeChance2[iIndex] = flClamp(g_flBuryRangeChance2[iIndex], 0.0, 100.0);
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
			vRemoveBury(iTank);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024"))
		{
			vRemoveBury(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iBuryAbility(tank) == 1)
	{
		vBuryAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iBuryAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bBury2[tank] && !g_bBury3[tank])
				{
					vBuryAbility(tank);
				}
				else if (g_bBury2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryHuman3");
				}
				else if (g_bBury3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveBury(tank);
	}
}

static void vBuryAbility(int tank)
{
	if (g_iBuryCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bBury4[tank] = false;
		g_bBury5[tank] = false;

		float flBuryRange = !g_bTankConfig[ST_TankType(tank)] ? g_flBuryRange[ST_TankType(tank)] : g_flBuryRange2[ST_TankType(tank)],
			flBuryRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flBuryRangeChance[ST_TankType(tank)] : g_flBuryRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flBuryRange)
				{
					vBuryHit(iSurvivor, tank, flBuryRangeChance, iBuryAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryHuman5");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryAmmo");
	}
}

static void vBuryHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor) && bIsEntityGrounded(survivor))
	{
		if (g_iBuryCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bBury[survivor])
			{
				g_bBury[survivor] = true;
				g_iBuryOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bBury2[tank])
				{
					g_bBury2[tank] = true;
					g_iBuryCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryHuman", g_iBuryCount[tank], iHumanAmmo(tank));
				}

				float flOrigin[3], flPos[3];
				GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);
				flOrigin[2] -= flBuryHeight(tank);
				SetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);

				if (!bIsPlayerIncapacitated(survivor))
				{
					SetEntProp(survivor, Prop_Send, "m_isIncapacitated", 1);
					SetEntProp(survivor, Prop_Data, "m_takedamage", 0, 1);
				}

				GetClientEyePosition(survivor, flPos);

				if (GetEntityMoveType(survivor) != MOVETYPE_NONE)
				{
					SetEntityMoveType(survivor, MOVETYPE_NONE);
				}

				DataPack dpStopBury;
				CreateDataTimer(flBuryDuration(tank), tTimerStopBury, dpStopBury, TIMER_FLAG_NO_MAPCHANGE);
				dpStopBury.WriteCell(GetClientUserId(survivor));
				dpStopBury.WriteCell(GetClientUserId(tank));
				dpStopBury.WriteString(message);

				char sBuryEffect[4];
				sBuryEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sBuryEffect[ST_TankType(tank)] : g_sBuryEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sBuryEffect, mode);

				char sBuryMessage[3];
				sBuryMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sBuryMessage[ST_TankType(tank)] : g_sBuryMessage2[ST_TankType(tank)];
				if (StrContains(sBuryMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Bury", sTankName, survivor, flOrigin);
				}
			}
			else if (StrEqual(mode, "3") && !g_bBury2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bBury4[tank])
				{
					g_bBury4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bBury5[tank])
			{
				g_bBury5[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryAmmo");
			}
		}
	}
}

static void vRemoveBury(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234") && g_bBury[iSurvivor] && g_iBuryOwner[iSurvivor] == tank)
		{
			vStopBury(iSurvivor, tank);
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

			g_iBuryOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bBury[tank] = false;
	g_bBury2[tank] = false;
	g_bBury3[tank] = false;
	g_bBury4[tank] = false;
	g_bBury5[tank] = false;
	g_iBuryCount[tank] = 0;
}

static void vStopBury(int survivor, int tank)
{
	g_bBury[survivor] = false;
	g_iBuryOwner[survivor] = 0;

	float flOrigin[3], flCurrentOrigin[3];
	GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);
	flOrigin[2] += flBuryHeight(tank);
	SetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);

	SetEntProp(survivor, Prop_Data, "m_takedamage", 2, 1);

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSurvivor(iPlayer, "234") && !g_bBury[iPlayer] && iPlayer != survivor)
		{
			GetClientAbsOrigin(iPlayer, flCurrentOrigin);
			TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

			break;
		}
	}

	if (GetEntityMoveType(survivor) == MOVETYPE_NONE)
	{
		SetEntityMoveType(survivor, MOVETYPE_WALK);
	}
}

static float flBuryChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flBuryChance[ST_TankType(tank)] : g_flBuryChance2[ST_TankType(tank)];
}

static float flBuryDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flBuryDuration[ST_TankType(tank)] : g_flBuryDuration2[ST_TankType(tank)];
}

static float flBuryHeight(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flBuryHeight[ST_TankType(tank)] : g_flBuryHeight2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iBuryAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBuryAbility[ST_TankType(tank)] : g_iBuryAbility2[ST_TankType(tank)];
}

static int iBuryHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBuryHit[ST_TankType(tank)] : g_iBuryHit2[ST_TankType(tank)];
}

static int iBuryHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBuryHitMode[ST_TankType(tank)] : g_iBuryHitMode2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

public Action tTimerStopBury(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bBury[iSurvivor] = false;
		g_iBuryOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bBury[iSurvivor])
	{
		vStopBury(iSurvivor, iTank);

		return Plugin_Stop;
	}

	g_bBury2[iTank] = false;

	vStopBury(iSurvivor, iTank);

	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));

	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bBury3[iTank])
	{
		g_bBury3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "BuryHuman6");

		if (g_iBuryCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bBury3[iTank] = false;
		}
	}

	char sBuryMessage[3];
	sBuryMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sBuryMessage[ST_TankType(iTank)] : g_sBuryMessage2[ST_TankType(iTank)];
	if (StrContains(sBuryMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Bury2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bBury3[iTank])
	{
		g_bBury3[iTank] = false;

		return Plugin_Stop;
	}

	g_bBury3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "BuryHuman7");

	return Plugin_Continue;
}