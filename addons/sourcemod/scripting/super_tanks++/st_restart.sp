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

bool g_bLateLoad;

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

#define ST_MENU_RESTART "Restart Ability"

bool g_bCloneInstalled, g_bRestart[MAXPLAYERS + 1], g_bRestart2[MAXPLAYERS + 1], g_bRestart3[MAXPLAYERS + 1], g_bRestart4, g_bRestartValid, g_bTankConfig[ST_MAXTYPES + 1];

char g_sRestartLoadout[ST_MAXTYPES + 1][325], g_sRestartLoadout2[ST_MAXTYPES + 1][325];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flRestartChance[ST_MAXTYPES + 1], g_flRestartChance2[ST_MAXTYPES + 1], g_flRestartPosition[3], g_flRestartRange[ST_MAXTYPES + 1], g_flRestartRange2[ST_MAXTYPES + 1], g_flRestartRangeChance[ST_MAXTYPES + 1], g_flRestartRangeChance2[ST_MAXTYPES + 1];

Handle g_hSDKRespawnPlayer;

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iRestartAbility[ST_MAXTYPES + 1], g_iRestartAbility2[ST_MAXTYPES + 1], g_iRestartCount[MAXPLAYERS + 1], g_iRestartEffect[ST_MAXTYPES + 1], g_iRestartEffect2[ST_MAXTYPES + 1], g_iRestartHit[ST_MAXTYPES + 1], g_iRestartHit2[ST_MAXTYPES + 1], g_iRestartHitMode[ST_MAXTYPES + 1], g_iRestartHitMode2[ST_MAXTYPES + 1], g_iRestartMessage[ST_MAXTYPES + 1], g_iRestartMessage2[ST_MAXTYPES + 1], g_iRestartMode[ST_MAXTYPES + 1], g_iRestartMode2[ST_MAXTYPES + 1];

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
			if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (!ST_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT))
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

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iRestartHitMode(attacker) == 0 || iRestartHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRestartHit(victim, attacker, flRestartChance(attacker), iRestartHit(attacker), ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iRestartHitMode(victim) == 0 || iRestartHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRestartHit(attacker, victim, flRestartChance(victim), iRestartHit(victim), ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}
		}
	}
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
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
					g_iRestartEffect[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Effect", 0);
					g_iRestartEffect[iIndex] = iClamp(g_iRestartEffect[iIndex], 0, 7);
					g_iRestartMessage[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Message", 0);
					g_iRestartMessage[iIndex] = iClamp(g_iRestartMessage[iIndex], 0, 3);
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
					g_iRestartEffect2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Effect", g_iRestartEffect[iIndex]);
					g_iRestartEffect2[iIndex] = iClamp(g_iRestartEffect2[iIndex], 0, 7);
					g_iRestartMessage2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Message", g_iRestartMessage[iIndex]);
					g_iRestartMessage2[iIndex] = iClamp(g_iRestartMessage2[iIndex], 0, 3);
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
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iRestartAbility(tank) == 1)
	{
		vRestartAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

		float flRestartRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flRestartRange[ST_GetTankType(tank)] : g_flRestartRange2[ST_GetTankType(tank)],
			flRestartRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flRestartRangeChance[ST_GetTankType(tank)] : g_flRestartRangeChance2[ST_GetTankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRestartRange)
				{
					vRestartHit(iSurvivor, tank, flRestartRangeChance, iRestartAbility(tank), ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartAmmo");
	}
}

static void vRestartHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iRestartCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && (flags & ST_ATTACK_RANGE) && !g_bRestart[tank])
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
				sRestartLoadout = !g_bTankConfig[ST_GetTankType(tank)] ? g_sRestartLoadout[ST_GetTankType(tank)] : g_sRestartLoadout2[ST_GetTankType(tank)];
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

				int iRestartMode = !g_bTankConfig[ST_GetTankType(tank)] ? g_iRestartMode[ST_GetTankType(tank)] : g_iRestartMode2[ST_GetTankType(tank)];
				if (g_bRestartValid && iRestartMode == 0)
				{
					TeleportEntity(survivor, g_flRestartPosition, NULL_VECTOR, NULL_VECTOR);
				}
				else
				{
					float flCurrentOrigin[3];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (!bIsSurvivor(iPlayer, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) || bIsPlayerIncapacitated(iPlayer) || iPlayer == survivor)
						{
							continue;
						}

						GetClientAbsOrigin(iPlayer, flCurrentOrigin);
						TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

						break;
					}
				}

				int iRestartEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_iRestartEffect[ST_GetTankType(tank)] : g_iRestartEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, iRestartEffect, flags);

				int iRestartMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_iRestartMessage[ST_GetTankType(tank)] : g_iRestartMessage2[ST_GetTankType(tank)];
				if (iRestartMessage & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Restart", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bRestart[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bRestart2[tank])
				{
					g_bRestart2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bRestart3[tank])
		{
			g_bRestart3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "RestartAmmo");
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flRestartChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flRestartChance[ST_GetTankType(tank)] : g_flRestartChance2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iRestartAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iRestartAbility[ST_GetTankType(tank)] : g_iRestartAbility2[ST_GetTankType(tank)];
}

static int iRestartHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iRestartHit[ST_GetTankType(tank)] : g_iRestartHit2[ST_GetTankType(tank)];
}

static int iRestartHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iRestartHitMode[ST_GetTankType(tank)] : g_iRestartHitMode2[ST_GetTankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bRestart[iTank])
	{
		g_bRestart[iTank] = false;

		return Plugin_Stop;
	}

	g_bRestart[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RestartHuman5");

	return Plugin_Continue;
}