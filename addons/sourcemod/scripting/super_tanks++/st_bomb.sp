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

// Super Tanks++: Bomb Ability
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Bomb Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates explosions.",
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

#define ST_MENU_BOMB "Bomb Ability"

bool g_bBomb[MAXPLAYERS + 1], g_bBomb2[MAXPLAYERS + 1], g_bBomb3[MAXPLAYERS + 1], g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sBombEffect[ST_MAXTYPES + 1][4], g_sBombEffect2[ST_MAXTYPES + 1][4], g_sBombMessage[ST_MAXTYPES + 1][4], g_sBombMessage2[ST_MAXTYPES + 1][4];

float g_flBombChance[ST_MAXTYPES + 1], g_flBombChance2[ST_MAXTYPES + 1], g_flBombRange[ST_MAXTYPES + 1], g_flBombRange2[ST_MAXTYPES + 1], g_flBombRangeChance[ST_MAXTYPES + 1], g_flBombRangeChance2[ST_MAXTYPES + 1], g_flBombRockChance[ST_MAXTYPES + 1], g_flBombRockChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iBombAbility[ST_MAXTYPES + 1], g_iBombAbility2[ST_MAXTYPES + 1], g_iBombCount[MAXPLAYERS + 1], g_iBombHit[ST_MAXTYPES + 1], g_iBombHit2[ST_MAXTYPES + 1], g_iBombHitMode[ST_MAXTYPES + 1], g_iBombHitMode2[ST_MAXTYPES + 1], g_iBombRockBreak[ST_MAXTYPES + 1], g_iBombRockBreak2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Bomb Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_bomb", cmdBombInfo, "View information about the Bomb ability.");

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
	PrecacheModel(MODEL_PROPANETANK, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveBomb(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdBombInfo(int client, int args)
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
		case false: vBombMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vBombMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iBombMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Bomb Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iBombMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iBombAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iBombCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "BombDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vBombMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "BombMenu", param1);
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
	menu.AddItem(ST_MENU_BOMB, ST_MENU_BOMB);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_BOMB, false))
	{
		vBombMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iBombHitMode(attacker) == 0 || iBombHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBombHit(victim, attacker, flBombChance(attacker), iBombHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iBombHitMode(victim) == 0 || iBombHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBombHit(attacker, victim, flBombChance(victim), iBombHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 1, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iBombAbility[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Enabled", 0);
					g_iBombAbility[iIndex] = iClamp(g_iBombAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Bomb Ability/Ability Effect", g_sBombEffect[iIndex], sizeof(g_sBombEffect[]), "0");
					kvSuperTanks.GetString("Bomb Ability/Ability Message", g_sBombMessage[iIndex], sizeof(g_sBombMessage[]), "0");
					g_flBombChance[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Chance", 33.3);
					g_flBombChance[iIndex] = flClamp(g_flBombChance[iIndex], 0.0, 100.0);
					g_iBombHit[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit", 0);
					g_iBombHit[iIndex] = iClamp(g_iBombHit[iIndex], 0, 1);
					g_iBombHitMode[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit Mode", 0);
					g_iBombHitMode[iIndex] = iClamp(g_iBombHitMode[iIndex], 0, 2);
					g_flBombRange[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", 150.0);
					g_flBombRange[iIndex] = flClamp(g_flBombRange[iIndex], 1.0, 9999999999.0);
					g_flBombRangeChance[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range Chance", 15.0);
					g_flBombRangeChance[iIndex] = flClamp(g_flBombRangeChance[iIndex], 0.0, 100.0);
					g_iBombRockBreak[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", 0);
					g_iBombRockBreak[iIndex] = iClamp(g_iBombRockBreak[iIndex], 0, 1);
					g_flBombRockChance[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Rock Chance", 33.3);
					g_flBombRockChance[iIndex] = flClamp(g_flBombRockChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 1, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iBombAbility2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Enabled", g_iBombAbility[iIndex]);
					g_iBombAbility2[iIndex] = iClamp(g_iBombAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Bomb Ability/Ability Effect", g_sBombEffect2[iIndex], sizeof(g_sBombEffect2[]), g_sBombEffect[iIndex]);
					kvSuperTanks.GetString("Bomb Ability/Ability Message", g_sBombMessage2[iIndex], sizeof(g_sBombMessage2[]), g_sBombMessage[iIndex]);
					g_flBombChance2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Chance", g_flBombChance[iIndex]);
					g_flBombChance2[iIndex] = flClamp(g_flBombChance2[iIndex], 0.0, 100.0);
					g_iBombHit2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit", g_iBombHit[iIndex]);
					g_iBombHit2[iIndex] = iClamp(g_iBombHit2[iIndex], 0, 1);
					g_iBombHitMode2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit Mode", g_iBombHitMode[iIndex]);
					g_iBombHitMode2[iIndex] = iClamp(g_iBombHitMode2[iIndex], 0, 2);
					g_flBombRange2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", g_flBombRange[iIndex]);
					g_flBombRange2[iIndex] = flClamp(g_flBombRange2[iIndex], 1.0, 9999999999.0);
					g_flBombRangeChance2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range Chance", g_flBombRangeChance[iIndex]);
					g_flBombRangeChance2[iIndex] = flClamp(g_flBombRangeChance2[iIndex], 0.0, 100.0);
					g_iBombRockBreak2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", g_iBombRockBreak[iIndex]);
					g_iBombRockBreak2[iIndex] = iClamp(g_iBombRockBreak2[iIndex], 0, 1);
					g_flBombRockChance2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Rock Chance", g_flBombRockChance[iIndex]);
					g_flBombRockChance2[iIndex] = flClamp(g_flBombRockChance2[iIndex], 0.0, 100.0);
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
			if (iBombAbility(iTank) == 1)
			{
				float flPos[3];
				GetClientAbsOrigin(iTank, flPos);
				vSpecialAttack(iTank, flPos, 10.0, MODEL_PROPANETANK);
			}

			vRemoveBomb(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iBombAbility(tank) == 1)
	{
		vBombAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iBombAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bBomb[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombHuman3");
					case false: vBombAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && iBombAbility(tank) == 1)
	{
		float flPos[3];
		GetClientAbsOrigin(tank, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);
	}

	vRemoveBomb(tank);
}

public void ST_OnRockBreak(int tank, int rock)
{
	int iBombRockBreak = !g_bTankConfig[ST_TankType(tank)] ? g_iBombRockBreak[ST_TankType(tank)] : g_iBombRockBreak2[ST_TankType(tank)];
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && iBombRockBreak == 1)
	{
		float flBombRockChance = !g_bTankConfig[ST_TankType(tank)] ? g_flBombRockChance[ST_TankType(tank)] : g_flBombRockChance2[ST_TankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flBombRockChance)
		{
			float flPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
			vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);

			char sBombMessage[4];
			sBombMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sBombMessage[ST_TankType(tank)] : g_sBombMessage2[ST_TankType(tank)];
			if (StrContains(sBombMessage, "3") != -1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Bomb2", sTankName);
			}
		}
	}
}

static void vBombAbility(int tank)
{
	if (g_iBombCount[tank] < iHumanAmmo(tank))
	{
		g_bBomb2[tank] = false;
		g_bBomb3[tank] = false;

		float flBombRange = !g_bTankConfig[ST_TankType(tank)] ? g_flBombRange[ST_TankType(tank)] : g_flBombRange2[ST_TankType(tank)],
			flBombRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flBombRangeChance[ST_TankType(tank)] : g_flBombRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flBombRange)
				{
					vBombHit(iSurvivor, tank, flBombRangeChance, iBombAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombHuman4");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombAmmo");
	}
}

static void vBombHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iBombCount[tank] < iHumanAmmo(tank))
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bBomb[tank])
				{
					g_bBomb[tank] = true;
					g_iBombCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombHuman", g_iBombCount[tank], iHumanAmmo(tank));

					if (g_iBombCount[tank] < iHumanAmmo(tank))
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bBomb[tank] = false;
					}
				}

				float flPos[3];
				GetClientAbsOrigin(survivor, flPos);
				vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);

				char sBombEffect[4];
				sBombEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sBombEffect[ST_TankType(tank)] : g_sBombEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sBombEffect, mode);

				char sBombMessage[4];
				sBombMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sBombMessage[ST_TankType(tank)] : g_sBombMessage2[ST_TankType(tank)];
				if (StrContains(sBombMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Bomb", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bBomb[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bBomb2[tank])
				{
					g_bBomb2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bBomb3[tank])
			{
				g_bBomb3[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombAmmo");
			}
		}
	}
}

static void vRemoveBomb(int tank)
{
	g_bBomb[tank] = false;
	g_bBomb2[tank] = false;
	g_bBomb3[tank] = false;
	g_iBombCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveBomb(iPlayer);
		}
	}
}

static float flBombChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flBombChance[ST_TankType(tank)] : g_flBombChance2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iBombAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBombAbility[ST_TankType(tank)] : g_iBombAbility2[ST_TankType(tank)];
}

static int iBombHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBombHit[ST_TankType(tank)] : g_iBombHit2[ST_TankType(tank)];
}

static int iBombHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBombHitMode[ST_TankType(tank)] : g_iBombHitMode2[ST_TankType(tank)];
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
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bBomb[iTank])
	{
		g_bBomb[iTank] = false;

		return Plugin_Stop;
	}

	g_bBomb[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "BombHuman5");

	return Plugin_Continue;
}