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
	name = "[ST++] Quiet Ability",
	author = ST_AUTHOR,
	description = "The Super Tank silences itself around survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_QUIET "Quiet Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bQuiet[MAXPLAYERS + 1], g_bQuiet2[MAXPLAYERS + 1], g_bQuiet3[MAXPLAYERS + 1], g_bQuiet4[MAXPLAYERS + 1], g_bQuiet5[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sQuietEffect[ST_MAXTYPES + 1][4], g_sQuietEffect2[ST_MAXTYPES + 1][4], g_sQuietMessage[ST_MAXTYPES + 1][3], g_sQuietMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flQuietChance[ST_MAXTYPES + 1], g_flQuietChance2[ST_MAXTYPES + 1], g_flQuietDuration[ST_MAXTYPES + 1], g_flQuietDuration2[ST_MAXTYPES + 1], g_flQuietRange[ST_MAXTYPES + 1], g_flQuietRange2[ST_MAXTYPES + 1], g_flQuietRangeChance[ST_MAXTYPES + 1], g_flQuietRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iQuietAbility[ST_MAXTYPES + 1], g_iQuietAbility2[ST_MAXTYPES + 1], g_iQuietCount[MAXPLAYERS + 1], g_iQuietHit[ST_MAXTYPES + 1], g_iQuietHit2[ST_MAXTYPES + 1], g_iQuietHitMode[ST_MAXTYPES + 1], g_iQuietHitMode2[ST_MAXTYPES + 1], g_iQuietOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Quiet Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_quiet", cmdQuietInfo, "View information about the Quiet ability.");

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

	AddNormalSoundHook(SoundHook);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();

	RemoveNormalSoundHook(SoundHook);
}

public Action cmdQuietInfo(int client, int args)
{
	if (!ST_IsCorePluginEnabled())
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
		case false: vQuietMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vQuietMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iQuietMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Quiet Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iQuietMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iQuietAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iQuietCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "QuietDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flQuietDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vQuietMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "QuietMenu", param1);
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
	menu.AddItem(ST_MENU_QUIET, ST_MENU_QUIET);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_QUIET, false))
	{
		vQuietMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iQuietHitMode(attacker) == 0 || iQuietHitMode(attacker) == 1) && ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vQuietHit(victim, attacker, flQuietChance(attacker), iQuietHit(attacker), "1", "1");
			}
		}
		else if ((iQuietHitMode(victim) == 0 || iQuietHitMode(victim) == 2) && ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vQuietHit(attacker, victim, flQuietChance(victim), iQuietHit(victim), "1", "2");
			}
		}
	}
}

public Action SoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (ST_IsCorePluginEnabled() && StrContains(sample, "player/tank", false) != -1)
	{
		for (int iSurvivor = 0; iSurvivor < numClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(clients[iSurvivor], "024") && g_bQuiet[clients[iSurvivor]])
			{
				for (int iPlayers = iSurvivor; iPlayers < numClients - 1; iPlayers++)
				{
					clients[iPlayers] = clients[iPlayers + 1];
				}

				numClients--;
				iSurvivor--;
			}
		}

		return (numClients > 0) ? Plugin_Changed : Plugin_Stop;
	}

	return Plugin_Continue;
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iQuietAbility[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Ability Enabled", 0);
					g_iQuietAbility[iIndex] = iClamp(g_iQuietAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Quiet Ability/Ability Effect", g_sQuietEffect[iIndex], sizeof(g_sQuietEffect[]), "0");
					kvSuperTanks.GetString("Quiet Ability/Ability Message", g_sQuietMessage[iIndex], sizeof(g_sQuietMessage[]), "0");
					g_flQuietChance[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Chance", 33.3);
					g_flQuietChance[iIndex] = flClamp(g_flQuietChance[iIndex], 0.0, 100.0);
					g_flQuietDuration[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Duration", 5.0);
					g_flQuietDuration[iIndex] = flClamp(g_flQuietDuration[iIndex], 0.1, 9999999999.0);
					g_iQuietHit[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Hit", 0);
					g_iQuietHit[iIndex] = iClamp(g_iQuietHit[iIndex], 0, 1);
					g_iQuietHitMode[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Hit Mode", 0);
					g_iQuietHitMode[iIndex] = iClamp(g_iQuietHitMode[iIndex], 0, 2);
					g_flQuietRange[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Range", 150.0);
					g_flQuietRange[iIndex] = flClamp(g_flQuietRange[iIndex], 1.0, 9999999999.0);
					g_flQuietRangeChance[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Range Chance", 15.0);
					g_flQuietRangeChance[iIndex] = flClamp(g_flQuietRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iQuietAbility2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Ability Enabled", g_iQuietAbility[iIndex]);
					g_iQuietAbility2[iIndex] = iClamp(g_iQuietAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Quiet Ability/Ability Effect", g_sQuietEffect2[iIndex], sizeof(g_sQuietEffect2[]), g_sQuietEffect[iIndex]);
					kvSuperTanks.GetString("Quiet Ability/Ability Message", g_sQuietMessage2[iIndex], sizeof(g_sQuietMessage2[]), g_sQuietMessage[iIndex]);
					g_flQuietChance2[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Chance", g_flQuietChance[iIndex]);
					g_flQuietChance2[iIndex] = flClamp(g_flQuietChance2[iIndex], 0.0, 100.0);
					g_flQuietDuration2[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Duration", g_flQuietDuration[iIndex]);
					g_flQuietDuration2[iIndex] = flClamp(g_flQuietDuration2[iIndex], 0.1, 9999999999.0);
					g_iQuietHit2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Hit", g_iQuietHit[iIndex]);
					g_iQuietHit2[iIndex] = iClamp(g_iQuietHit2[iIndex], 0, 1);
					g_iQuietHitMode2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Hit Mode", g_iQuietHitMode[iIndex]);
					g_iQuietHitMode2[iIndex] = iClamp(g_iQuietHitMode2[iIndex], 0, 2);
					g_flQuietRange2[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Range", g_flQuietRange[iIndex]);
					g_flQuietRange2[iIndex] = flClamp(g_flQuietRange2[iIndex], 1.0, 9999999999.0);
					g_flQuietRangeChance2[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Range Chance", g_flQuietRangeChance[iIndex]);
					g_flQuietRangeChance2[iIndex] = flClamp(g_flQuietRangeChance2[iIndex], 0.0, 100.0);
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
		if (ST_IsTankSupported(iTank, "024"))
		{
			vRemoveQuiet(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iQuietAbility(tank) == 1)
	{
		vQuietAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iQuietAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bQuiet2[tank] && !g_bQuiet3[tank])
				{
					vQuietAbility(tank);
				}
				else if (g_bQuiet2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietHuman3");
				}
				else if (g_bQuiet3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveQuiet(tank);
}

static void vQuietAbility(int tank)
{
	if (g_iQuietCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bQuiet4[tank] = false;
		g_bQuiet5[tank] = false;

		float flQuietRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flQuietRange[ST_GetTankType(tank)] : g_flQuietRange2[ST_GetTankType(tank)],
			flQuietRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flQuietRangeChance[ST_GetTankType(tank)] : g_flQuietRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flQuietRange)
				{
					vQuietHit(iSurvivor, tank, flQuietRangeChance, iQuietAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietAmmo");
	}
}

static void vQuietHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iQuietCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bQuiet[survivor])
			{
				g_bQuiet[survivor] = true;
				g_iQuietOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bQuiet2[tank])
				{
					g_bQuiet2[tank] = true;
					g_iQuietCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietHuman", g_iQuietCount[tank], iHumanAmmo(tank));
				}

				DataPack dpStopQuiet;
				CreateDataTimer(flQuietDuration(tank), tTimerStopQuiet, dpStopQuiet, TIMER_FLAG_NO_MAPCHANGE);
				dpStopQuiet.WriteCell(GetClientUserId(survivor));
				dpStopQuiet.WriteCell(GetClientUserId(tank));
				dpStopQuiet.WriteString(message);

				char sQuietEffect[4];
				sQuietEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sQuietEffect[ST_GetTankType(tank)] : g_sQuietEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sQuietEffect, mode);

				char sQuietMessage[3];
				sQuietMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sQuietMessage[ST_GetTankType(tank)] : g_sQuietMessage2[ST_GetTankType(tank)];
				if (StrContains(sQuietMessage, message) != -1)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Quiet", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bQuiet2[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bQuiet4[tank])
				{
					g_bQuiet4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bQuiet5[tank])
		{
			g_bQuiet5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietAmmo");
		}
	}
}

static void vRemoveQuiet(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "24") && g_bQuiet[iSurvivor] && g_iQuietOwner[iSurvivor] == tank)
		{
			g_bQuiet[iSurvivor] = false;
			g_iQuietOwner[iSurvivor] = 0;
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

			g_iQuietOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bQuiet[tank] = false;
	g_bQuiet2[tank] = false;
	g_bQuiet3[tank] = false;
	g_bQuiet4[tank] = false;
	g_bQuiet5[tank] = false;
	g_iQuietCount[tank] = 0;
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flQuietChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flQuietChance[ST_GetTankType(tank)] : g_flQuietChance2[ST_GetTankType(tank)];
}

static float flQuietDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flQuietDuration[ST_GetTankType(tank)] : g_flQuietDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iQuietAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iQuietAbility[ST_GetTankType(tank)] : g_iQuietAbility2[ST_GetTankType(tank)];
}

static int iQuietHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iQuietHit[ST_GetTankType(tank)] : g_iQuietHit2[ST_GetTankType(tank)];
}

static int iQuietHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iQuietHitMode[ST_GetTankType(tank)] : g_iQuietHitMode2[ST_GetTankType(tank)];
}

public Action tTimerStopQuiet(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor) || !g_bQuiet[iSurvivor])
	{
		g_bQuiet[iSurvivor] = false;
		g_iQuietOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled))
	{
		g_bQuiet[iSurvivor] = false;
		g_iQuietOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bQuiet[iSurvivor] = false;
	g_bQuiet2[iTank] = false;
	g_iQuietOwner[iSurvivor] = 0;

	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));

	if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bQuiet3[iTank])
	{
		g_bQuiet3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "QuietHuman6");

		if (g_iQuietCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bQuiet3[iTank] = false;
		}
	}

	char sQuietMessage[3];
	sQuietMessage = !g_bTankConfig[ST_GetTankType(iTank)] ? g_sQuietMessage[ST_GetTankType(iTank)] : g_sQuietMessage2[ST_GetTankType(iTank)];
	if (StrContains(sQuietMessage, sMessage) != -1)
	{
		char sTankName[33];
		ST_GetTankName(iTank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Quiet2", sTankName, iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bQuiet3[iTank])
	{
		g_bQuiet3[iTank] = false;

		return Plugin_Stop;
	}

	g_bQuiet3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "QuietHuman7");

	return Plugin_Continue;
}