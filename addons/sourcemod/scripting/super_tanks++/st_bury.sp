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
	name = "[ST++] Bury Ability",
	author = ST_AUTHOR,
	description = "The Super Tank buries survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

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

#define ST_MENU_BURY "Bury Ability"

bool g_bBury[MAXPLAYERS + 1], g_bBury2[MAXPLAYERS + 1], g_bBury3[MAXPLAYERS + 1], g_bBury4[MAXPLAYERS + 1], g_bBury5[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flBuryChance[ST_MAXTYPES + 1], g_flBuryDuration[ST_MAXTYPES + 1], g_flBuryHeight[ST_MAXTYPES + 1], g_flBuryRange[ST_MAXTYPES + 1], g_flBuryRangeChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iBuryAbility[ST_MAXTYPES + 1], g_iBuryCount[MAXPLAYERS + 1], g_iBuryEffect[ST_MAXTYPES + 1], g_iBuryHit[ST_MAXTYPES + 1], g_iBuryHitMode[ST_MAXTYPES + 1], g_iBuryMessage[ST_MAXTYPES + 1], g_iBuryOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_bury", cmdBuryInfo, "View information about the Bury ability.");

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

public Action cmdBuryInfo(int client, int args)
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iBuryAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iBuryCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "BuryDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flBuryDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iBuryHitMode[ST_GetTankType(attacker)] == 0 || g_iBuryHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBuryHit(victim, attacker, g_flBuryChance[ST_GetTankType(attacker)], g_iBuryHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iBuryHitMode[ST_GetTankType(victim)] == 0 || g_iBuryHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBuryHit(attacker, victim, g_flBuryChance[ST_GetTankType(victim)], g_iBuryHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iBuryAbility[iIndex] = 0;
		g_iBuryEffect[iIndex] = 0;
		g_iBuryMessage[iIndex] = 0;
		g_flBuryChance[iIndex] = 33.3;
		g_flBuryDuration[iIndex] = 5.0;
		g_flBuryHeight[iIndex] = 50.0;
		g_iBuryHit[iIndex] = 0;
		g_iBuryHitMode[iIndex] = 0;
		g_flBuryRange[iIndex] = 150.0;
		g_flBuryRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 6, bHasAbilities(subsection, "buryability", "bury ability", "bury_ability", "bury"));
	g_iHumanAbility[type] = iGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iBuryAbility[type] = iGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iBuryAbility[type], value, 0, 0, 1);
	g_iBuryEffect[type] = iGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iBuryEffect[type], value, 0, 0, 7);
	g_iBuryMessage[type] = iGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iBuryMessage[type], value, 0, 0, 3);
	g_flBuryChance[type] = flGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryChance", "Bury Chance", "Bury_Chance", "chance", main, g_flBuryChance[type], value, 33.3, 0.0, 100.0);
	g_flBuryDuration[type] = flGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryDuration", "Bury Duration", "Bury_Duration", "duration", main, g_flBuryDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_flBuryHeight[type] = flGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryHeight", "Bury Height", "Bury_Height", "height", main, g_flBuryHeight[type], value, 50.0, 0.1, 9999999999.0);
	g_iBuryHit[type] = iGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryHit", "Bury Hit", "Bury_Hit", "hit", main, g_iBuryHit[type], value, 0, 0, 1);
	g_iBuryHitMode[type] = iGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryHitMode", "Bury Hit Mode", "Bury_Hit_Mode", "hitmode", main, g_iBuryHitMode[type], value, 0, 0, 2);
	g_flBuryRange[type] = flGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryRange", "Bury Range", "Bury_Range", "range", main, g_flBuryRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flBuryRangeChance[type] = flGetValue(subsection, "buryability", "bury ability", "bury_ability", "bury", key, "BuryRangeChance", "Bury Range Chance", "Bury_Range_Chance", "rangechance", main, g_flBuryRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
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
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveBury(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iBuryAbility[ST_GetTankType(tank)] == 1)
	{
		vBuryAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iBuryAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
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

public void ST_OnChangeType(int tank, bool revert)
{
	if (ST_IsTankSupported(tank))
	{
		vRemoveBury(tank);
	}
}

static void vBuryAbility(int tank)
{
	if (g_iBuryCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bBury4[tank] = false;
		g_bBury5[tank] = false;

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
				if (flDistance <= g_flBuryRange[ST_GetTankType(tank)])
				{
					vBuryHit(iSurvivor, tank, g_flBuryRangeChance[ST_GetTankType(tank)], g_iBuryAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryAmmo");
	}
}

static void vBuryHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor) && bIsEntityGrounded(survivor))
	{
		if (g_iBuryCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bBury[survivor])
			{
				g_bBury[survivor] = true;
				g_iBuryOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bBury2[tank])
				{
					g_bBury2[tank] = true;
					g_iBuryCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryHuman", g_iBuryCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				float flOrigin[3], flPos[3];
				GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);
				flOrigin[2] -= g_flBuryHeight[ST_GetTankType(tank)];
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
				CreateDataTimer(g_flBuryDuration[ST_GetTankType(tank)], tTimerStopBury, dpStopBury, TIMER_FLAG_NO_MAPCHANGE);
				dpStopBury.WriteCell(GetClientUserId(survivor));
				dpStopBury.WriteCell(GetClientUserId(tank));
				dpStopBury.WriteCell(messages);

				vEffect(survivor, tank, g_iBuryEffect[ST_GetTankType(tank)], flags);

				if (g_iBuryMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Bury", sTankName, survivor, flOrigin);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bBury2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bBury4[tank])
				{
					g_bBury4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bBury5[tank])
		{
			g_bBury5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "BuryAmmo");
		}
	}
}

static void vRemoveBury(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bBury[iSurvivor] && g_iBuryOwner[iSurvivor] == tank)
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	flOrigin[2] += g_flBuryHeight[ST_GetTankType(tank)];
	SetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);

	SetEntProp(survivor, Prop_Data, "m_takedamage", 2, 1);

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSurvivor(iPlayer, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !g_bBury[iPlayer] && iPlayer != survivor)
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
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bBury[iSurvivor])
	{
		vStopBury(iSurvivor, iTank);

		return Plugin_Stop;
	}

	g_bBury2[iTank] = false;

	vStopBury(iSurvivor, iTank);

	int iMessage = pack.ReadCell();

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bBury3[iTank])
	{
		g_bBury3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "BuryHuman6");

		if (g_iBuryCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bBury3[iTank] = false;
		}
	}

	if (g_iBuryMessage[ST_GetTankType(iTank)] & iMessage)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Bury2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bBury3[iTank])
	{
		g_bBury3[iTank] = false;

		return Plugin_Stop;
	}

	g_bBury3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "BuryHuman7");

	return Plugin_Continue;
}