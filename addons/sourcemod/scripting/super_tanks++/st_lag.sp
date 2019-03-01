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
	name = "[ST++] Lag Ability",
	author = ST_AUTHOR,
	description = "The Super Tank makes survivors lag.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Lag Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_LAG "Lag Ability"

bool g_bCloneInstalled, g_bLag[MAXPLAYERS + 1], g_bLag2[MAXPLAYERS + 1], g_bLag3[MAXPLAYERS + 1], g_bLag4[MAXPLAYERS + 1], g_bLag5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flLagChance[ST_MAXTYPES + 1], g_flLagDuration[ST_MAXTYPES + 1], g_flLagPosition[MAXPLAYERS + 1][4], g_flLagRange[ST_MAXTYPES + 1], g_flLagRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iLagAbility[ST_MAXTYPES + 1], g_iLagCount[MAXPLAYERS + 1], g_iLagEffect[ST_MAXTYPES + 1], g_iLagHit[ST_MAXTYPES + 1], g_iLagMessage[ST_MAXTYPES + 1], g_iLagHitMode[ST_MAXTYPES + 1], g_iLagOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_lag", cmdLagInfo, "View information about the Lag ability.");

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

public Action cmdLagInfo(int client, int args)
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
		case false: vLagMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vLagMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iLagMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Lag Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iLagMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iLagAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iLagCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "LagDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flLagDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vLagMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "LagMenu", param1);
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
	menu.AddItem(ST_MENU_LAG, ST_MENU_LAG);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_LAG, false))
	{
		vLagMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iLagHitMode[ST_GetTankType(attacker)] == 0 || g_iLagHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vLagHit(victim, attacker, g_flLagChance[ST_GetTankType(attacker)], g_iLagHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iLagHitMode[ST_GetTankType(victim)] == 0 || g_iLagHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vLagHit(attacker, victim, g_flLagChance[ST_GetTankType(victim)], g_iLagHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iLagAbility[iIndex] = 0;
		g_iLagEffect[iIndex] = 0;
		g_iLagMessage[iIndex] = 0;
		g_flLagChance[iIndex] = 33.3;
		g_flLagDuration[iIndex] = 5.0;
		g_iLagHit[iIndex] = 0;
		g_iLagHitMode[iIndex] = 0;
		g_flLagRange[iIndex] = 150.0;
		g_flLagRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iLagAbility[type] = iGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iLagAbility[type], value, 0, 0, 1);
	g_iLagEffect[type] = iGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iLagEffect[type], value, 0, 0, 7);
	g_iLagMessage[type] = iGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iLagMessage[type], value, 0, 0, 3);
	g_flLagChance[type] = flGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "LagChance", "Lag Chance", "Lag_Chance", "chance", main, g_flLagChance[type], value, 33.3, 0.0, 100.0);
	g_flLagDuration[type] = flGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "LagDuration", "Lag Duration", "Lag_Duration", "duration", main, g_flLagDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iLagHit[type] = iGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "LagHit", "Lag Hit", "Lag_Hit", "hit", main, g_iLagHit[type], value, 0, 0, 1);
	g_iLagHitMode[type] = iGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "LagHitMode", "Lag Hit Mode", "Lag_Hit_Mode", "hitmode", main, g_iLagHitMode[type], value, 0, 0, 2);
	g_flLagRange[type] = flGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "LagRange", "Lag Range", "Lag_Range", "range", main, g_flLagRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flLagRangeChance[type] = flGetValue(subsection, "lagability", "lag ability", "lag_ability", "lag", key, "LagRangeChance", "Lag Range Chance", "Lag_Range_Chance", "rangechance", main, g_flLagRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveLag(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iLagAbility[ST_GetTankType(tank)] == 1)
	{
		vLagAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iLagAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bLag2[tank] && !g_bLag3[tank])
				{
					vLagAbility(tank);
				}
				else if (g_bLag2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman3");
				}
				else if (g_bLag3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveLag(tank);
}

static void vLagAbility(int tank)
{
	if (g_iLagCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bLag4[tank] = false;
		g_bLag5[tank] = false;

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
				if (flDistance <= g_flLagRange[ST_GetTankType(tank)])
				{
					vLagHit(iSurvivor, tank, g_flLagRangeChance[ST_GetTankType(tank)], g_iLagAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagAmmo");
	}
}

static void vLagHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iLagCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bLag[survivor])
			{
				g_bLag[survivor] = true;
				g_iLagOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bLag2[tank])
				{
					g_bLag2[tank] = true;
					g_iLagCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman", g_iLagCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				float flPos[3];
				GetClientAbsOrigin(survivor, flPos);
				for (int iPos = 0; iPos < 3; iPos++)
				{
					g_flLagPosition[survivor][iPos + 1] = flPos[iPos];
				}

				DataPack dpLagTeleport;
				CreateDataTimer(1.0, tTimerLagTeleport, dpLagTeleport, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpLagTeleport.WriteCell(GetClientUserId(survivor));
				dpLagTeleport.WriteCell(GetClientUserId(tank));
				dpLagTeleport.WriteCell(ST_GetTankType(tank));
				dpLagTeleport.WriteCell(messages);
				dpLagTeleport.WriteCell(enabled);
				dpLagTeleport.WriteFloat(GetEngineTime());

				DataPack dpLagPosition;
				CreateDataTimer(0.5, tTimerLagPosition, dpLagPosition, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpLagPosition.WriteCell(GetClientUserId(survivor));
				dpLagPosition.WriteCell(GetClientUserId(tank));
				dpLagPosition.WriteCell(ST_GetTankType(tank));
				dpLagPosition.WriteCell(enabled);
				dpLagPosition.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iLagEffect[ST_GetTankType(tank)], flags);

				if (g_iLagMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Lag", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bLag2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bLag4[tank])
				{
					g_bLag4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bLag5[tank])
		{
			g_bLag5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagAmmo");
		}
	}
}

static void vRemoveLag(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bLag[iSurvivor] && g_iLagOwner[iSurvivor] == tank)
		{
			g_bLag[iSurvivor] = false;
			g_iLagOwner[iSurvivor] = 0;
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

			g_iLagOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bLag[survivor] = false;
	g_iLagOwner[survivor] = 0;

	if (g_iLagMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Lag2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bLag[tank] = false;
	g_bLag2[tank] = false;
	g_bLag3[tank] = false;
	g_bLag4[tank] = false;
	g_bLag5[tank] = false;
	g_iLagCount[tank] = 0;
}

public Action tTimerLagTeleport(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bLag[iSurvivor] = false;
		g_iLagOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bLag[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iLagEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iLagEnabled == 0 || (flTime + g_flLagDuration[ST_GetTankType(iTank)] < GetEngineTime()))
	{
		g_bLag2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bLag3[iTank])
		{
			g_bLag3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "LagHuman6");

			if (g_iLagCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bLag3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	float flPos[3];
	for (int iPos = 0; iPos < 3; iPos++)
	{
		flPos[iPos] = g_flLagPosition[iSurvivor][iPos + 1];
	}

	TeleportEntity(iSurvivor, flPos, NULL_VECTOR, NULL_VECTOR);

	return Plugin_Continue;
}

public Action tTimerLagPosition(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor) || !g_bLag[iSurvivor])
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank))
	{
		return Plugin_Stop;
	}

	int iLagEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iLagEnabled == 0 || (flTime + g_flLagDuration[ST_GetTankType(iTank)] < GetEngineTime()))
	{
		return Plugin_Stop;
	}

	float flPos[3];
	GetClientAbsOrigin(iSurvivor, flPos);
	for (int iPos = 0; iPos < 3; iPos++)
	{
		g_flLagPosition[iSurvivor][iPos + 1] = flPos[iPos];
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bLag3[iTank])
	{
		g_bLag3[iTank] = false;

		return Plugin_Stop;
	}

	g_bLag3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "LagHuman7");

	return Plugin_Continue;
}