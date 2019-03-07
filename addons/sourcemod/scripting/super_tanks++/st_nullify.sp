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
	name = "[ST++] Nullify Ability",
	author = ST_AUTHOR,
	description = "The Super Tank nullifies all of the survivors' damage.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

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

#define ST_MENU_NULLIFY "Nullify Ability"

bool g_bCloneInstalled, g_bNullify[MAXPLAYERS + 1], g_bNullify2[MAXPLAYERS + 1], g_bNullify3[MAXPLAYERS + 1], g_bNullify4[MAXPLAYERS + 1], g_bNullify5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flNullifyChance[ST_MAXTYPES + 1], g_flNullifyDuration[ST_MAXTYPES + 1], g_flNullifyRange[ST_MAXTYPES + 1], g_flNullifyRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iNullifyAbility[ST_MAXTYPES + 1], g_iNullifyCount[MAXPLAYERS + 1], g_iNullifyEffect[ST_MAXTYPES + 1], g_iNullifyHit[ST_MAXTYPES + 1], g_iNullifyHitMode[ST_MAXTYPES + 1], g_iNullifyMessage[ST_MAXTYPES + 1], g_iNullifyOwner[MAXPLAYERS + 1];

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

public Action cmdNullifyInfo(int client, int args)
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iNullifyAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iNullifyCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "NullifyDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flNullifyDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iNullifyHitMode[ST_GetTankType(attacker)] == 0 || g_iNullifyHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vNullifyHit(victim, attacker, g_flNullifyChance[ST_GetTankType(attacker)], g_iNullifyHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if ((g_iNullifyHitMode[ST_GetTankType(victim)] == 0 || g_iNullifyHitMode[ST_GetTankType(victim)] == 2) && StrEqual(sClassname, "weapon_melee"))
			{
				vNullifyHit(attacker, victim, g_flNullifyChance[ST_GetTankType(victim)], g_iNullifyHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}

			if (g_bNullify[attacker])
			{
				return Plugin_Handled;
			}
		}
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
		g_iNullifyAbility[iIndex] = 0;
		g_iNullifyEffect[iIndex] = 0;
		g_iNullifyMessage[iIndex] = 0;
		g_flNullifyChance[iIndex] = 33.3;
		g_flNullifyDuration[iIndex] = 5.0;
		g_iNullifyHit[iIndex] = 0;
		g_iNullifyHitMode[iIndex] = 0;
		g_flNullifyRange[iIndex] = 150.0;
		g_flNullifyRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 39, bHasAbilities(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify"));
	g_iHumanAbility[type] = iGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iNullifyAbility[type] = iGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iNullifyAbility[type], value, 0, 0, 1);
	g_iNullifyEffect[type] = iGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iNullifyEffect[type], value, 0, 0, 7);
	g_iNullifyMessage[type] = iGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iNullifyMessage[type], value, 0, 0, 3);
	g_flNullifyChance[type] = flGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyChance", "Nullify Chance", "Nullify_Chance", "chance", main, g_flNullifyChance[type], value, 33.3, 0.0, 100.0);
	g_flNullifyDuration[type] = flGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyDuration", "Nullify Duration", "Nullify_Duration", "duration", main, g_flNullifyDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iNullifyHit[type] = iGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyHit", "Nullify Hit", "Nullify_Hit", "hit", main, g_iNullifyHit[type], value, 0, 0, 1);
	g_iNullifyHitMode[type] = iGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyHitMode", "Nullify Hit Mode", "Nullify_Hit_Mode", "hitmode", main, g_iNullifyHitMode[type], value, 0, 0, 2);
	g_flNullifyRange[type] = flGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyRange", "Nullify Range", "Nullify_Range", "range", main, g_flNullifyRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flNullifyRangeChance[type] = flGetValue(subsection, "nullifyability", "nullify ability", "nullify_ability", "nullify", key, "NullifyRangeChance", "Nullify Range Chance", "Nullify_Range_Chance", "rangechance", main, g_flNullifyRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveNullify(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iNullifyAbility[ST_GetTankType(tank)] == 1)
	{
		vNullifyAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iNullifyAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
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

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveNullify(tank);
}

static void vNullifyAbility(int tank)
{
	if (g_iNullifyCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bNullify4[tank] = false;
		g_bNullify5[tank] = false;

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
				if (flDistance <= g_flNullifyRange[ST_GetTankType(tank)])
				{
					vNullifyHit(iSurvivor, tank, g_flNullifyRangeChance[ST_GetTankType(tank)], g_iNullifyAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyAmmo");
	}
}

static void vNullifyHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iNullifyCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bNullify[survivor])
			{
				g_bNullify[survivor] = true;
				g_iNullifyOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bNullify2[tank])
				{
					g_bNullify2[tank] = true;
					g_iNullifyCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyHuman", g_iNullifyCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpStopNullify;
				CreateDataTimer(g_flNullifyDuration[ST_GetTankType(tank)], tTimerStopNullify, dpStopNullify, TIMER_FLAG_NO_MAPCHANGE);
				dpStopNullify.WriteCell(GetClientUserId(survivor));
				dpStopNullify.WriteCell(GetClientUserId(tank));
				dpStopNullify.WriteCell(messages);

				vEffect(survivor, tank, g_iNullifyEffect[ST_GetTankType(tank)], flags);

				if (g_iNullifyMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Nullify", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bNullify2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bNullify4[tank])
				{
					g_bNullify4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "NullifyHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bNullify5[tank])
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
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_bNullify[iSurvivor] && g_iNullifyOwner[iSurvivor] == tank)
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bNullify[iSurvivor] = false;
		g_iNullifyOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bNullify[iSurvivor] = false;
	g_bNullify2[iTank] = false;
	g_iNullifyOwner[iSurvivor] = 0;

	int iMessage = pack.ReadCell();

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bNullify3[iTank])
	{
		g_bNullify3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "NullifyHuman6");

		if (g_iNullifyCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bNullify3[iTank] = false;
		}
	}

	if (g_iNullifyMessage[ST_GetTankType(iTank)] & iMessage)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Nullify2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bNullify3[iTank])
	{
		g_bNullify3[iTank] = false;

		return Plugin_Stop;
	}

	g_bNullify3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "NullifyHuman7");

	return Plugin_Continue;
}