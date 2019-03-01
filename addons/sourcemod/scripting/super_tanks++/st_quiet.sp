/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2019  Alfred "Crasher_3637/Psyk0tik" Llagas
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

bool g_bLateLoad;

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

#define ST_MENU_QUIET "Quiet Ability"

bool g_bCloneInstalled, g_bQuiet[MAXPLAYERS + 1], g_bQuiet2[MAXPLAYERS + 1], g_bQuiet3[MAXPLAYERS + 1], g_bQuiet4[MAXPLAYERS + 1], g_bQuiet5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flQuietChance[ST_MAXTYPES + 1], g_flQuietDuration[ST_MAXTYPES + 1], g_flQuietRange[ST_MAXTYPES + 1], g_flQuietRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iQuietAbility[ST_MAXTYPES + 1], g_iQuietCount[MAXPLAYERS + 1], g_iQuietEffect[ST_MAXTYPES + 1], g_iQuietHit[ST_MAXTYPES + 1], g_iQuietHitMode[ST_MAXTYPES + 1], g_iQuietMessage[ST_MAXTYPES + 1], g_iQuietOwner[MAXPLAYERS + 1];

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

	if (!bIsValidClient(client, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT))
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iQuietAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iQuietCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "QuietDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flQuietDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iQuietHitMode[ST_GetTankType(attacker)] == 0 || g_iQuietHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vQuietHit(victim, attacker, g_flQuietChance[ST_GetTankType(attacker)], g_iQuietHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iQuietHitMode[ST_GetTankType(victim)] == 0 || g_iQuietHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vQuietHit(attacker, victim, g_flQuietChance[ST_GetTankType(victim)], g_iQuietHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
			if (bIsHumanSurvivor(clients[iSurvivor], ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_bQuiet[clients[iSurvivor]])
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

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iQuietAbility[iIndex] = 0;
		g_iQuietEffect[iIndex] = 0;
		g_iQuietMessage[iIndex] = 0;
		g_flQuietChance[iIndex] = 33.3;
		g_flQuietDuration[iIndex] = 5.0;
		g_iQuietHit[iIndex] = 0;
		g_iQuietHitMode[iIndex] = 0;
		g_flQuietRange[iIndex] = 150.0;
		g_flQuietRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iQuietAbility[type] = iGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iQuietAbility[type], value, 0, 0, 1);
	g_iQuietEffect[type] = iGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iQuietEffect[type], value, 0, 0, 7);
	g_iQuietMessage[type] = iGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iQuietMessage[type], value, 0, 0, 3);
	g_flQuietChance[type] = flGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietChance", "Quiet Chance", "Quiet_Chance", "chance", main, g_flQuietChance[type], value, 33.3, 0.0, 100.0);
	g_flQuietDuration[type] = flGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietDuration", "Quiet Duration", "Quiet_Duration", "duration", main, g_flQuietDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iQuietHit[type] = iGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietHit", "Quiet Hit", "Quiet_Hit", "hit", main, g_iQuietHit[type], value, 0, 0, 1);
	g_iQuietHitMode[type] = iGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietHitMode", "Quiet Hit Mode", "Quiet_Hit_Mode", "hitmode", main, g_iQuietHitMode[type], value, 0, 0, 2);
	g_flQuietRange[type] = flGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietRange", "Quiet Range", "Quiet_Range", "range", main, g_flQuietRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flQuietRangeChance[type] = flGetValue(subsection, "quietability", "quiet ability", "quiet_ability", "quiet", key, "QuietRangeChance", "Quiet Range Chance", "Quiet_Range_Chance", "rangechance", main, g_flQuietRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveQuiet(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iQuietAbility[ST_GetTankType(tank)] == 1)
	{
		vQuietAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iQuietAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
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

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveQuiet(tank);
}

static void vQuietAbility(int tank)
{
	if (g_iQuietCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bQuiet4[tank] = false;
		g_bQuiet5[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_flQuietRange[ST_GetTankType(tank)])
				{
					vQuietHit(iSurvivor, tank, g_flQuietRangeChance[ST_GetTankType(tank)], g_iQuietAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietAmmo");
	}
}

static void vQuietHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iQuietCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bQuiet[survivor])
			{
				g_bQuiet[survivor] = true;
				g_iQuietOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bQuiet2[tank])
				{
					g_bQuiet2[tank] = true;
					g_iQuietCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietHuman", g_iQuietCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpStopQuiet;
				CreateDataTimer(g_flQuietDuration[ST_GetTankType(tank)], tTimerStopQuiet, dpStopQuiet, TIMER_FLAG_NO_MAPCHANGE);
				dpStopQuiet.WriteCell(GetClientUserId(survivor));
				dpStopQuiet.WriteCell(GetClientUserId(tank));
				dpStopQuiet.WriteCell(messages);

				vEffect(survivor, tank, g_iQuietEffect[ST_GetTankType(tank)], flags);

				if (g_iQuietMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Quiet", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bQuiet2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bQuiet4[tank])
				{
					g_bQuiet4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "QuietHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bQuiet5[tank])
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
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_bQuiet[iSurvivor] && g_iQuietOwner[iSurvivor] == tank)
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bQuiet[iSurvivor] = false;
		g_iQuietOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bQuiet[iSurvivor] = false;
	g_bQuiet2[iTank] = false;
	g_iQuietOwner[iSurvivor] = 0;

	int iMessage = pack.ReadCell();

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bQuiet3[iTank])
	{
		g_bQuiet3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "QuietHuman6");

		if (g_iQuietCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bQuiet3[iTank] = false;
		}
	}

	if (g_iQuietMessage[ST_GetTankType(iTank)] & iMessage)
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
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bQuiet3[iTank])
	{
		g_bQuiet3[iTank] = false;

		return Plugin_Stop;
	}

	g_bQuiet3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "QuietHuman7");

	return Plugin_Continue;
}