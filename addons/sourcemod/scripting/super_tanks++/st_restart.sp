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
	name = "[ST++] Restart Ability",
	author = ST_AUTHOR,
	description = "The Super Tank forces survivors to restart at the beginning of the map or near a teammate with a new loadout.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_RESTART "Restart Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bRestart[MAXPLAYERS + 1], g_bRestart2[MAXPLAYERS + 1], g_bRestart3[MAXPLAYERS + 1], g_bRestart4, g_bRestartValid, g_bTankConfig[ST_MAXTYPES + 1];

char g_sRestartEffect[ST_MAXTYPES + 1][4], g_sRestartEffect2[ST_MAXTYPES + 1][4], g_sRestartLoadout[ST_MAXTYPES + 1][325], g_sRestartLoadout2[ST_MAXTYPES + 1][325], g_sRestartMessage[ST_MAXTYPES + 1][3], g_sRestartMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flRestartChance[ST_MAXTYPES + 1], g_flRestartChance2[ST_MAXTYPES + 1], g_flRestartPosition[3], g_flRestartRange[ST_MAXTYPES + 1], g_flRestartRange2[ST_MAXTYPES + 1], g_flRestartRangeChance[ST_MAXTYPES + 1], g_flRestartRangeChance2[ST_MAXTYPES + 1];

Handle g_hSDKRespawnPlayer;

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iRestartAbility[ST_MAXTYPES + 1], g_iRestartAbility2[ST_MAXTYPES + 1], g_iRestartCount[MAXPLAYERS + 1], g_iRestartHit[ST_MAXTYPES + 1], g_iRestartHit2[ST_MAXTYPES + 1], g_iRestartHitMode[ST_MAXTYPES + 1], g_iRestartHitMode2[ST_MAXTYPES + 1], g_iRestartMode[ST_MAXTYPES + 1], g_iRestartMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Restart Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_restart", cmdRestartInfo, "View information about the Restart ability.");

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "RoundRespawn");
	g_hSDKRespawnPlayer = EndPrepSDKCall();

	if (g_hSDKRespawnPlayer == null)
	{
		PrintToServer("%s Your \"RoundRespawn\" signature is outdated.", ST_TAG);
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

	vRemoveRestart(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRestartInfo(int client, int args)
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
		case false: vRestartMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRestartMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRestartMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Restart Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRestartMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iRestartAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iRestartCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "RestartDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vRestartMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "RestartMenu", param1);
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
	menu.AddItem(ST_MENU_RESTART, ST_MENU_RESTART);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_RESTART, false))
	{
		vRestartMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iRestartHitMode(attacker) == 0 || iRestartHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRestartHit(victim, attacker, flRestartChance(attacker), iRestartHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iRestartHitMode(victim) == 0 || iRestartHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRestartHit(attacker, victim, flRestartChance(victim), iRestartHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Restart Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Restart Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iRestartAbility[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Enabled", 0);
					g_iRestartAbility[iIndex] = iClamp(g_iRestartAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Restart Ability/Ability Effect", g_sRestartEffect[iIndex], sizeof(g_sRestartEffect[]), "0");
					kvSuperTanks.GetString("Restart Ability/Ability Message", g_sRestartMessage[iIndex], sizeof(g_sRestartMessage[]), "0");
					g_flRestartChance[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Chance", 33.3);
					g_flRestartChance[iIndex] = flClamp(g_flRestartChance[iIndex], 0.0, 100.0);
					g_iRestartHit[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit", 0);
					g_iRestartHit[iIndex] = iClamp(g_iRestartHit[iIndex], 0, 1);
					g_iRestartHitMode[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit Mode", 0);
					g_iRestartHitMode[iIndex] = iClamp(g_iRestartHitMode[iIndex], 0, 2);
					kvSuperTanks.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout[iIndex], sizeof(g_sRestartLoadout[]), "smg, pistol, pain_pills");
					g_iRestartMode[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Mode", 1);
					g_iRestartMode[iIndex] = iClamp(g_iRestartMode[iIndex], 0, 1);
					g_flRestartRange[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range", 150.0);
					g_flRestartRange[iIndex] = flClamp(g_flRestartRange[iIndex], 1.0, 9999999999.0);
					g_flRestartRangeChance[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range Chance", 15.0);
					g_flRestartRangeChance[iIndex] = flClamp(g_flRestartRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iRestartAbility2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Enabled", g_iRestartAbility[iIndex]);
					g_iRestartAbility2[iIndex] = iClamp(g_iRestartAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Restart Ability/Ability Effect", g_sRestartEffect2[iIndex], sizeof(g_sRestartEffect2[]), g_sRestartEffect[iIndex]);
					kvSuperTanks.GetString("Restart Ability/Ability Message", g_sRestartMessage2[iIndex], sizeof(g_sRestartMessage2[]), g_sRestartMessage[iIndex]);
					g_flRestartChance2[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Chance", g_flRestartChance[iIndex]);
					g_flRestartChance2[iIndex] = flClamp(g_flRestartChance2[iIndex], 0.0, 100.0);
					g_iRestartHit2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit", g_iRestartHit[iIndex]);
					g_iRestartHit2[iIndex] = iClamp(g_iRestartHit2[iIndex], 0, 1);
					g_iRestartHitMode2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit Mode", g_iRestartHitMode[iIndex]);
					g_iRestartHitMode2[iIndex] = iClamp(g_iRestartHitMode2[iIndex], 0, 2);
					kvSuperTanks.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout2[iIndex], sizeof(g_sRestartLoadout2[]), g_sRestartLoadout[iIndex]);
					g_iRestartMode2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Mode", g_iRestartMode[iIndex]);
					g_iRestartMode2[iIndex] = iClamp(g_iRestartMode2[iIndex], 0, 1);
					g_flRestartRange2[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range", g_flRestartRange[iIndex]);
					g_flRestartRange2[iIndex] = flClamp(g_flRestartRange2[iIndex], 1.0, 9999999999.0);
					g_flRestartRangeChance2[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range Chance", g_flRestartRangeChance[iIndex]);
					g_flRestartRangeChance2[iIndex] = flClamp(g_flRestartRangeChance2[iIndex], 0.0, 100.0);
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
			vRemoveRestart(iTank);
		}
	}
	else if (StrEqual(name, "player_spawn"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor) && !g_bRestart4)
		{
			g_bRestart4 = true;
			g_bRestartValid = true;
			GetClientAbsOrigin(iSurvivor, g_flRestartPosition);

			if (g_flRestartPosition[0] == 0.0 && g_flRestartPosition[1] == 0.0 && g_flRestartPosition[2] == 0.0)
			{
				g_bRestartValid = false;
			}
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iRestartAbility(tank) == 1)
	{
		vRestartAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iRestartAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bRestart[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartHuman3");
					case false: vRestartAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveRestart(tank);
}

static void vRemoveRestart(int tank)
{
	g_bRestart[tank] = false;
	g_bRestart2[tank] = false;
	g_bRestart3[tank] = false;
	g_iRestartCount[tank] = 0;
}

static void vRemoveWeapon(int survivor, int slot)
{
	int iSlot = GetPlayerWeaponSlot(survivor, slot);
	if (iSlot > 0)
	{
		RemovePlayerItem(survivor, iSlot);
		RemoveEntity(iSlot);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveRestart(iPlayer);
		}
	}

	g_bRestart4 = false;
}

static void vRestartAbility(int tank)
{
	if (g_iRestartCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bRestart2[tank] = false;
		g_bRestart3[tank] = false;

		float flRestartRange = !g_bTankConfig[ST_TankType(tank)] ? g_flRestartRange[ST_TankType(tank)] : g_flRestartRange2[ST_TankType(tank)],
			flRestartRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flRestartRangeChance[ST_TankType(tank)] : g_flRestartRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flRestartRange)
				{
					vRestartHit(iSurvivor, tank, flRestartRangeChance, iRestartAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartHuman4");
			}
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartAmmo");
	}
}

static void vRestartHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iRestartCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bRestart[tank])
				{
					g_bRestart[tank] = true;
					g_iRestartCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartHuman", g_iRestartCount[tank], iHumanAmmo(tank));

					if (g_iRestartCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bRestart[tank] = false;
					}
				}

				SDKCall(g_hSDKRespawnPlayer, survivor);

				char sRestartLoadout[325], sItems[5][64];
				sRestartLoadout = !g_bTankConfig[ST_TankType(tank)] ? g_sRestartLoadout[ST_TankType(tank)] : g_sRestartLoadout2[ST_TankType(tank)];
				ReplaceString(sRestartLoadout, sizeof(sRestartLoadout), " ", "");
				ExplodeString(sRestartLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));

				for (int iWeapon = 0; iWeapon < 5; iWeapon++)
				{
					vRemoveWeapon(survivor, iWeapon);
				}

				for (int iItem = 0; iItem < sizeof(sItems); iItem++)
				{
					if (StrContains(sRestartLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
					{
						vCheatCommand(survivor, "give", sItems[iItem]);
					}
				}

				int iRestartMode = !g_bTankConfig[ST_TankType(tank)] ? g_iRestartMode[ST_TankType(tank)] : g_iRestartMode2[ST_TankType(tank)];
				if (g_bRestartValid && iRestartMode == 0)
				{
					TeleportEntity(survivor, g_flRestartPosition, NULL_VECTOR, NULL_VECTOR);
				}
				else
				{
					float flCurrentOrigin[3];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (!bIsSurvivor(iPlayer, "234") || bIsPlayerIncapacitated(iPlayer) || iPlayer == survivor)
						{
							continue;
						}

						GetClientAbsOrigin(iPlayer, flCurrentOrigin);
						TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

						break;
					}
				}

				char sRestartEffect[4];
				sRestartEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sRestartEffect[ST_TankType(tank)] : g_sRestartEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sRestartEffect, mode);

				char sRestartMessage[3];
				sRestartMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sRestartMessage[ST_TankType(tank)] : g_sRestartMessage2[ST_TankType(tank)];
				if (StrContains(sRestartMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Restart", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bRestart[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bRestart2[tank])
				{
					g_bRestart2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartHuman2");
				}
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bRestart3[tank])
		{
			g_bRestart3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartAmmo");
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flRestartChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flRestartChance[ST_TankType(tank)] : g_flRestartChance2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iRestartAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRestartAbility[ST_TankType(tank)] : g_iRestartAbility2[ST_TankType(tank)];
}

static int iRestartHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRestartHit[ST_TankType(tank)] : g_iRestartHit2[ST_TankType(tank)];
}

static int iRestartHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRestartHitMode[ST_TankType(tank)] : g_iRestartHitMode2[ST_TankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bRestart[iTank])
	{
		g_bRestart[iTank] = false;

		return Plugin_Stop;
	}

	g_bRestart[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RestartHuman5");

	return Plugin_Continue;
}