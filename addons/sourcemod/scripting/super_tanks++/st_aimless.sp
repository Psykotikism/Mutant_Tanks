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
	name = "[ST++] Aimless Ability",
	author = ST_AUTHOR,
	description = "The Super Tank prevents survivors from aiming.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Aimless Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_AIMLESS "Aimless Ability"

bool g_bAimless[MAXPLAYERS + 1], g_bAimless2[MAXPLAYERS + 1], g_bAimless3[MAXPLAYERS + 1], g_bAimless4[MAXPLAYERS + 1], g_bAimless5[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flAimlessAngle[MAXPLAYERS + 1][3], g_flAimlessChance[ST_MAXTYPES + 1], g_flAimlessDuration[ST_MAXTYPES + 1], g_flAimlessRange[ST_MAXTYPES + 1], g_flAimlessRangeChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iAimlessAbility[ST_MAXTYPES + 1], g_iAimlessCount[MAXPLAYERS + 1], g_iAimlessEffect[ST_MAXTYPES + 1], g_iAimlessHit[ST_MAXTYPES + 1], g_iAimlessHitMode[ST_MAXTYPES + 1], g_iAimlessMessage[ST_MAXTYPES + 1], g_iAimlessOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_aimless", cmdAimlessInfo, "View information about the Aimless ability.");

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

public Action cmdAimlessInfo(int client, int args)
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
		case false: vAimlessMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vAimlessMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iAimlessMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Aimless Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iAimlessMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iAimlessAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iAimlessCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AimlessDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flAimlessDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vAimlessMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "AimlessMenu", param1);
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
	menu.AddItem(ST_MENU_AIMLESS, ST_MENU_AIMLESS);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_AIMLESS, false))
	{
		vAimlessMenu(client, 0);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!ST_IsCorePluginEnabled())
	{
		return Plugin_Continue;
	}

	if (g_bAimless[client])
	{
		TeleportEntity(client, NULL_VECTOR, g_flAimlessAngle[client], NULL_VECTOR);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iAimlessHitMode[ST_GetTankType(attacker)] == 0 || g_iAimlessHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAimlessHit(victim, attacker, g_flAimlessChance[ST_GetTankType(attacker)], g_iAimlessHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iAimlessHitMode[ST_GetTankType(victim)] == 0 || g_iAimlessHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAimlessHit(attacker, victim, g_flAimlessChance[ST_GetTankType(victim)], g_iAimlessHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iAimlessAbility[iIndex] = 0;
		g_iAimlessEffect[iIndex] = 0;
		g_iAimlessMessage[iIndex] = 0;
		g_flAimlessChance[iIndex] = 33.3;
		g_flAimlessDuration[iIndex] = 5.0;
		g_iAimlessHit[iIndex] = 0;
		g_iAimlessHitMode[iIndex] = 0;
		g_flAimlessRange[iIndex] = 150.0;
		g_flAimlessRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iAimlessAbility[type] = iGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iAimlessAbility[type], value, 0, 0, 1);
	g_iAimlessEffect[type] = iGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iAimlessEffect[type], value, 0, 0, 7);
	g_iAimlessMessage[type] = iGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iAimlessMessage[type], value, 0, 0, 3);
	g_flAimlessChance[type] = flGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "AimlessChance", "Aimless Chance", "Aimless_Chance", "chance", main, g_flAimlessChance[type], value, 33.3, 0.0, 100.0);
	g_flAimlessDuration[type] = flGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "AimlessDuration", "Aimless Duration", "Aimless_Duration", "duration", main, g_flAimlessDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iAimlessHit[type] = iGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "AimlessHit", "Aimless Hit", "Aimless_Hit", "hit", main, g_iAimlessHit[type], value, 0, 0, 1);
	g_iAimlessHitMode[type] = iGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "AimlessHitMode", "Aimless Hit Mode", "Aimless_Hit_Mode", "hitmode", main, g_iAimlessHitMode[type], value, 0, 0, 2);
	g_flAimlessRange[type] = flGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "AimlessRange", "Aimless Range", "Aimless_Range", "range", main, g_flAimlessRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flAimlessRangeChance[type] = flGetValue(subsection, "aimlessability", "aimless ability", "aimless_ability", "aimless", key, "AimlessRangeChance", "Aimless Range Chance", "Aimless_Range_Chance", "rangechance", main, g_flAimlessRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveAimless(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iAimlessAbility[ST_GetTankType(tank)] == 1)
	{
		vAimlessAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iAimlessAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bAimless2[tank] && !g_bAimless3[tank])
				{
					vAimlessAbility(tank);
				}
				else if (g_bAimless2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AimlessHuman3");
				}
				else if (g_bAimless3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AimlessHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveAimless(tank);
}

static void vAimlessAbility(int tank)
{
	if (g_iAimlessCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bAimless4[tank] = false;
		g_bAimless5[tank] = false;

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
				if (flDistance <= g_flAimlessRange[ST_GetTankType(tank)])
				{
					vAimlessHit(iSurvivor, tank, g_flAimlessRangeChance[ST_GetTankType(tank)], g_iAimlessAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "AimlessHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "AimlessAmmo");
	}
}

static void vAimlessHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iAimlessCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bAimless[survivor])
			{
				g_bAimless[survivor] = true;
				g_iAimlessOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bAimless2[tank])
				{
					g_bAimless2[tank] = true;
					g_iAimlessCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AimlessHuman", g_iAimlessCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				GetClientEyeAngles(survivor, g_flAimlessAngle[survivor]);

				DataPack dpStopAimless;
				CreateDataTimer(g_flAimlessDuration[ST_GetTankType(tank)], tTimerStopAimless, dpStopAimless, TIMER_FLAG_NO_MAPCHANGE);
				dpStopAimless.WriteCell(GetClientUserId(survivor));
				dpStopAimless.WriteCell(GetClientUserId(tank));
				dpStopAimless.WriteCell(messages);

				vEffect(survivor, tank, g_iAimlessEffect[ST_GetTankType(tank)], flags);

				if (g_iAimlessMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Aimless", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bAimless2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bAimless4[tank])
				{
					g_bAimless4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AimlessHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bAimless5[tank])
		{
			g_bAimless5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "AimlessAmmo");
		}
	}
}

static void vRemoveAimless(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_bAimless[iSurvivor] && g_iAimlessOwner[iSurvivor] == tank)
		{
			g_bAimless[iSurvivor] = false;
			g_iAimlessOwner[iSurvivor] = 0;
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

			g_iAimlessOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bAimless[tank] = false;
	g_bAimless2[tank] = false;
	g_bAimless3[tank] = false;
	g_bAimless4[tank] = false;
	g_bAimless5[tank] = false;
	g_iAimlessCount[tank] = 0;
}

public Action tTimerStopAimless(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bAimless[iSurvivor])
	{
		g_bAimless[iSurvivor] = false;
		g_iAimlessOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bAimless[iSurvivor] = false;
		g_iAimlessOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bAimless[iSurvivor] = false;
	g_bAimless2[iTank] = false;
	g_iAimlessOwner[iSurvivor] = 0;

	int iMessage = pack.ReadCell();

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bAimless3[iTank])
	{
		g_bAimless3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "AimlessHuman6");

		if (g_iAimlessCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bAimless3[iTank] = false;
		}
	}

	if (g_iAimlessMessage[ST_GetTankType(iTank)] & iMessage)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Aimless2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bAimless3[iTank])
	{
		g_bAimless3[iTank] = false;

		return Plugin_Stop;
	}

	g_bAimless3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "AimlessHuman7");

	return Plugin_Continue;
}