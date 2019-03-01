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
	name = "[ST++] Slow Ability",
	author = ST_AUTHOR,
	description = "The Super Tank slows survivors down.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_SLOW "Slow Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bSlow[MAXPLAYERS + 1], g_bSlow2[MAXPLAYERS + 1], g_bSlow3[MAXPLAYERS + 1], g_bSlow4[MAXPLAYERS + 1], g_bSlow5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flSlowChance[ST_MAXTYPES + 1], g_flSlowDuration[ST_MAXTYPES + 1], g_flSlowRange[ST_MAXTYPES + 1], g_flSlowRangeChance[ST_MAXTYPES + 1], g_flSlowSpeed[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iSlowAbility[ST_MAXTYPES + 1], g_iSlowCount[MAXPLAYERS + 1], g_iSlowEffect[ST_MAXTYPES + 1], g_iSlowHit[ST_MAXTYPES + 1], g_iSlowHitMode[ST_MAXTYPES + 1], g_iSlowMessage[ST_MAXTYPES + 1], g_iSlowOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Slow Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_slow", cmdSlowInfo, "View information about the Slow ability.");

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

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdSlowInfo(int client, int args)
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
		case false: vSlowMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vSlowMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iSlowMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Slow Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iSlowMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iSlowAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iSlowCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "SlowDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flSlowDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vSlowMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "SlowMenu", param1);
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
	menu.AddItem(ST_MENU_SLOW, ST_MENU_SLOW);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_SLOW, false))
	{
		vSlowMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iSlowHitMode[ST_GetTankType(attacker)] == 0 || g_iSlowHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSlowHit(victim, attacker, g_flSlowChance[ST_GetTankType(attacker)], g_iSlowHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iSlowHitMode[ST_GetTankType(victim)] == 0 || g_iSlowHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSlowHit(attacker, victim, g_flSlowChance[ST_GetTankType(victim)], g_iSlowHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}
		}
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iSlowAbility[iIndex] = 0;
		g_iSlowEffect[iIndex] = 0;
		g_iSlowMessage[iIndex] = 0;
		g_flSlowChance[iIndex] = 33.3;
		g_flSlowDuration[iIndex] = 5.0;
		g_iSlowHit[iIndex] = 0;
		g_iSlowHitMode[iIndex] = 0;
		g_flSlowRange[iIndex] = 150.0;
		g_flSlowRangeChance[iIndex] = 15.0;
		g_flSlowSpeed[iIndex] = 0.25;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iSlowAbility[type] = iGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iSlowAbility[type], value, 0, 0, 1);
	g_iSlowEffect[type] = iGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iSlowEffect[type], value, 0, 0, 7);
	g_iSlowMessage[type] = iGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iSlowMessage[type], value, 0, 0, 7);
	g_flSlowChance[type] = flGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowChance", "Slow Chance", "Slow_Chance", "chance", main, g_flSlowChance[type], value, 33.3, 0.0, 100.0);
	g_flSlowDuration[type] = flGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowDuration", "Slow Duration", "Slow_Duration", "duration", main, g_flSlowDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iSlowHit[type] = iGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowHit", "Slow Hit", "Slow_Hit", "hit", main, g_iSlowHit[type], value, 0, 0, 1);
	g_iSlowHitMode[type] = iGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowHitMode", "Slow Hit Mode", "Slow_Hit_Mode", "hitmode", main, g_iSlowHitMode[type], value, 0, 0, 2);
	g_flSlowRange[type] = flGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowRange", "Slow Range", "Slow_Range", "range", main, g_flSlowRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flSlowRangeChance[type] = flGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowRangeChance", "Slow Range Chance", "Slow_Range_Chance", "rangechance", main, g_flSlowRangeChance[type], value, 15.0, 0.0, 100.0);
	g_flSlowSpeed[type] = flGetValue(subsection, "slowability", "slow ability", "slow_ability", "slow", key, "SlowSpeed", "Slow Speed", "Slow_Speed", "speed", main, g_flSlowSpeed[type], value, 0.25, 0.1, 0.9);
}

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
		{
			vRemoveSlow(iTank);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveSlow(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iSlowAbility[ST_GetTankType(tank)] == 1)
	{
		vSlowAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iSlowAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bSlow2[tank] && !g_bSlow3[tank])
				{
					vSlowAbility(tank);
				}
				else if (g_bSlow2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowHuman3");
				}
				else if (g_bSlow3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveSlow(tank);
}

static void vRemoveSlow(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bSlow[iSurvivor] && g_iSlowOwner[iSurvivor] == tank)
		{
			g_bSlow[iSurvivor] = false;
			g_iSlowOwner[iSurvivor] = 0;

			SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
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
		}
	}
}

static void vReset2(int tank)
{
	g_bSlow[tank] = false;
	g_bSlow2[tank] = false;
	g_bSlow3[tank] = false;
	g_bSlow4[tank] = false;
	g_bSlow5[tank] = false;
	g_iSlowCount[tank] = 0;
}

static void vSlowAbility(int tank)
{
	if (g_iSlowCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bSlow4[tank] = false;
		g_bSlow5[tank] = false;

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
				if (flDistance <= g_flSlowRange[ST_GetTankType(tank)])
				{
					vSlowHit(iSurvivor, tank, g_flSlowRangeChance[ST_GetTankType(tank)], g_iSlowAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowAmmo");
	}
}

static void vSlowHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iSlowCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bSlow[survivor])
			{
				g_bSlow[survivor] = true;
				g_iSlowOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bSlow2[tank])
				{
					g_bSlow2[tank] = true;
					g_iSlowCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowHuman", g_iSlowCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", g_flSlowSpeed[ST_GetTankType(tank)]);

				DataPack dpStopSlow;
				CreateDataTimer(g_flSlowDuration[ST_GetTankType(tank)], tTimerStopSlow, dpStopSlow, TIMER_FLAG_NO_MAPCHANGE);
				dpStopSlow.WriteCell(GetClientUserId(survivor));
				dpStopSlow.WriteCell(GetClientUserId(tank));
				dpStopSlow.WriteCell(messages);

				vEffect(survivor, tank, g_iSlowEffect[ST_GetTankType(tank)], flags);

				if (g_iSlowMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Slow", sTankName, survivor, g_flSlowSpeed[ST_GetTankType(tank)]);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bSlow2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bSlow4[tank])
				{
					g_bSlow4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bSlow5[tank])
		{
			g_bSlow5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowAmmo");
		}
	}
}

public Action tTimerStopSlow(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bSlow[iSurvivor] = false;
		g_iSlowOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bSlow[iSurvivor])
	{
		g_bSlow[iSurvivor] = false;
		g_iSlowOwner[iSurvivor] = 0;

		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);

		return Plugin_Stop;
	}

	g_bSlow[iSurvivor] = false;
	g_bSlow2[iTank] = false;
	g_iSlowOwner[iSurvivor] = 0;

	SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);

	int iMessage = pack.ReadCell();

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bSlow3[iTank])
	{
		g_bSlow3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SlowHuman6");

		if (g_iSlowCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bSlow3[iTank] = false;
		}
	}

	if (g_iSlowMessage[ST_GetTankType(iTank)] & iMessage)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Slow2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bSlow3[iTank])
	{
		g_bSlow3[iTank] = false;

		return Plugin_Stop;
	}

	g_bSlow3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SlowHuman7");

	return Plugin_Continue;
}