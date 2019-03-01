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
	name = "[ST++] Leech Ability",
	author = ST_AUTHOR,
	description = "The Super Tank leeches health off of survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Leech Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_LEECH "Leech Ability"

bool g_bCloneInstalled, g_bLeech[MAXPLAYERS + 1], g_bLeech2[MAXPLAYERS + 1], g_bLeech3[MAXPLAYERS + 1], g_bLeech4[MAXPLAYERS + 1], g_bLeech5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flLeechChance[ST_MAXTYPES + 1], g_flLeechDuration[ST_MAXTYPES + 1], g_flLeechInterval[ST_MAXTYPES + 1], g_flLeechRange[ST_MAXTYPES + 1], g_flLeechRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iLeechAbility[ST_MAXTYPES + 1], g_iLeechCount[MAXPLAYERS + 1], g_iLeechEffect[ST_MAXTYPES + 1], g_iLeechHit[ST_MAXTYPES + 1], g_iLeechHitMode[ST_MAXTYPES + 1], g_iLeechMessage[ST_MAXTYPES + 1], g_iLeechOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_leech", cmdLeechInfo, "View information about the Leech ability.");

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

	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdLeechInfo(int client, int args)
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
		case false: vLeechMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vLeechMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iLeechMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Leech Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iLeechMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iLeechAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iLeechCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "LeechDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flLeechDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vLeechMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "LeechMenu", param1);
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
	menu.AddItem(ST_MENU_LEECH, ST_MENU_LEECH);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_LEECH, false))
	{
		vLeechMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iLeechHitMode[ST_GetTankType(attacker)] == 0 || g_iLeechHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vLeechHit(victim, attacker, g_flLeechChance[ST_GetTankType(attacker)], g_iLeechHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iLeechHitMode[ST_GetTankType(victim)] == 0 || g_iLeechHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vLeechHit(attacker, victim, g_flLeechChance[ST_GetTankType(victim)], g_iLeechHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iLeechAbility[iIndex] = 0;
		g_iLeechEffect[iIndex] = 0;
		g_iLeechMessage[iIndex] = 0;
		g_flLeechChance[iIndex] = 33.3;
		g_flLeechDuration[iIndex] = 5.0;
		g_iLeechHit[iIndex] = 0;
		g_iLeechHitMode[iIndex] = 0;
		g_flLeechInterval[iIndex] = 1.0;
		g_flLeechRange[iIndex] = 150.0;
		g_flLeechRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iLeechAbility[type] = iGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iLeechAbility[type], value, 0, 0, 1);
	g_iLeechEffect[type] = iGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iLeechEffect[type], value, 0, 0, 7);
	g_iLeechMessage[type] = iGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iLeechMessage[type], value, 0, 0, 3);
	g_flLeechChance[type] = flGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechChance", "Leech Chance", "Leech_Chance", "chance", main, g_flLeechChance[type], value, 33.3, 0.0, 100.0);
	g_flLeechDuration[type] = flGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechDuration", "Leech Duration", "Leech_Duration", "duration", main, g_flLeechDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iLeechHit[type] = iGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechHit", "Leech Hit", "Leech_Hit", "hit", main, g_iLeechHit[type], value, 0, 0, 1);
	g_iLeechHitMode[type] = iGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechHitMode", "Leech Hit Mode", "Leech_Hit_Mode", "hitmode", main, g_iLeechHitMode[type], value, 0, 0, 2);
	g_flLeechInterval[type] = flGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechInterval", "Leech Interval", "Leech_Interval", "interval", main, g_flLeechInterval[type], value, 1.0, 0.1, 9999999999.0);
	g_flLeechRange[type] = flGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechRange", "Leech Range", "Leech_Range", "range", main, g_flLeechRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flLeechRangeChance[type] = flGetValue(subsection, "leechability", "leech ability", "leech_ability", "leech", key, "LeechRangeChance", "Leech Range Chance", "Leech_Range_Chance", "rangechance", main, g_flLeechRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveLeech(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iLeechAbility[ST_GetTankType(tank)] == 1)
	{
		vLeechAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iLeechAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bLeech2[tank] && !g_bLeech3[tank])
				{
					vLeechAbility(tank);
				}
				else if (g_bLeech2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechHuman3");
				}
				else if (g_bLeech3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveLeech(tank);
}

static void vLeechAbility(int tank)
{
	if (g_iLeechCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bLeech4[tank] = false;
		g_bLeech5[tank] = false;

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
				if (flDistance <= g_flLeechRange[ST_GetTankType(tank)])
				{
					vLeechHit(iSurvivor, tank, g_flLeechRangeChance[ST_GetTankType(tank)], g_iLeechAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechAmmo");
	}
}

static void vLeechHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iLeechCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bLeech[survivor])
			{
				g_bLeech[survivor] = true;
				g_iLeechOwner[survivor] = tank;

				DataPack dpLeech;
				CreateDataTimer(g_flLeechInterval[ST_GetTankType(tank)], tTimerLeech, dpLeech, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpLeech.WriteCell(GetClientUserId(survivor));
				dpLeech.WriteCell(GetClientUserId(tank));
				dpLeech.WriteCell(ST_GetTankType(tank));
				dpLeech.WriteCell(messages);
				dpLeech.WriteCell(enabled);
				dpLeech.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iLeechEffect[ST_GetTankType(tank)], flags);

				if (g_iLeechMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Leech", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bLeech2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bLeech4[tank])
				{
					g_bLeech4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bLeech5[tank])
		{
			g_bLeech5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechAmmo");
		}
	}
}

static void vRemoveLeech(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bLeech[iSurvivor] && g_iLeechOwner[iSurvivor] == tank)
		{
			g_bLeech[iSurvivor] = false;
			g_iLeechOwner[iSurvivor] = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vReset3(iPlayer);

			g_iLeechOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bLeech[survivor] = false;
	g_iLeechOwner[survivor] = 0;

	if (g_iLeechMessage[ST_GetTankType(tank)] & messages)
	{
		char sTankName[33];
		ST_GetTankName(tank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Leech2", sTankName, survivor);
	}
}

static void vReset3(int tank)
{
	g_bLeech[tank] = false;
	g_bLeech2[tank] = false;
	g_bLeech3[tank] = false;
	g_bLeech4[tank] = false;
	g_bLeech5[tank] = false;
	g_iLeechCount[tank] = 0;
}

public Action tTimerLeech(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bLeech[iSurvivor] = false;
		g_iLeechOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bLeech[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iLeechEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iLeechEnabled == 0 || (flTime + g_flLeechDuration[ST_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bLeech2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bLeech3[iTank])
		{
			g_bLeech3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "LeechHuman6");

			if (g_iLeechCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bLeech3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	int iSurvivorHealth = GetClientHealth(iSurvivor), iTankHealth = GetClientHealth(iTank), iNewHealth = iSurvivorHealth - 1, iNewHealth2 = iTankHealth + 1,
		iFinalHealth = (iNewHealth < 1) ? 1 : iNewHealth, iFinalHealth2 = (iNewHealth2 > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth2;
	SetEntityHealth(iSurvivor, iFinalHealth);
	SetEntityHealth(iTank, iFinalHealth2);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bLeech3[iTank])
	{
		g_bLeech3[iTank] = false;

		return Plugin_Stop;
	}

	g_bLeech3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "LeechHuman7");

	return Plugin_Continue;
}