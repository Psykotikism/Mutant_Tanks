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
	name = "[ST++] Slow Ability",
	author = ST_AUTHOR,
	description = "The Super Tank slows survivors down.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_SLOW "Slow Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bSlow[MAXPLAYERS + 1], g_bSlow2[MAXPLAYERS + 1], g_bSlow3[MAXPLAYERS + 1], g_bSlow4[MAXPLAYERS + 1], g_bSlow5[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flSlowChance[ST_MAXTYPES + 1], g_flSlowChance2[ST_MAXTYPES + 1], g_flSlowDuration[ST_MAXTYPES + 1], g_flSlowDuration2[ST_MAXTYPES + 1], g_flSlowRange[ST_MAXTYPES + 1], g_flSlowRange2[ST_MAXTYPES + 1], g_flSlowRangeChance[ST_MAXTYPES + 1], g_flSlowRangeChance2[ST_MAXTYPES + 1], g_flSlowSpeed[ST_MAXTYPES + 1], g_flSlowSpeed2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iSlowAbility[ST_MAXTYPES + 1], g_iSlowAbility2[ST_MAXTYPES + 1], g_iSlowCount[MAXPLAYERS + 1], g_iSlowEffect[ST_MAXTYPES + 1], g_iSlowEffect2[ST_MAXTYPES + 1], g_iSlowHit[ST_MAXTYPES + 1], g_iSlowHit2[ST_MAXTYPES + 1], g_iSlowHitMode[ST_MAXTYPES + 1], g_iSlowHitMode2[ST_MAXTYPES + 1], g_iSlowMessage[ST_MAXTYPES + 1], g_iSlowMessage2[ST_MAXTYPES + 1], g_iSlowOwner[MAXPLAYERS + 1];

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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iSlowAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iSlowCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "SlowDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flSlowDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
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

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iSlowHitMode(attacker) == 0 || iSlowHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSlowHit(victim, attacker, flSlowChance(attacker), iSlowHit(attacker), ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iSlowHitMode(victim) == 0 || iSlowHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSlowHit(attacker, victim, flSlowChance(victim), iSlowHit(victim), ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Slow Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Slow Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iSlowAbility[iIndex] = kvSuperTanks.GetNum("Slow Ability/Ability Enabled", 0);
					g_iSlowAbility[iIndex] = iClamp(g_iSlowAbility[iIndex], 0, 1);
					g_iSlowEffect[iIndex] = kvSuperTanks.GetNum("Slow Ability/Ability Effect", 0);
					g_iSlowEffect[iIndex] = iClamp(g_iSlowEffect[iIndex], 0, 7);
					g_iSlowMessage[iIndex] = kvSuperTanks.GetNum("Slow Ability/Ability Message", 0);
					g_iSlowMessage[iIndex] = iClamp(g_iSlowMessage[iIndex], 0, 7);
					g_flSlowChance[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Chance", 33.3);
					g_flSlowChance[iIndex] = flClamp(g_flSlowChance[iIndex], 0.0, 100.0);
					g_flSlowDuration[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Duration", 5.0);
					g_flSlowDuration[iIndex] = flClamp(g_flSlowDuration[iIndex], 0.1, 9999999999.0);
					g_iSlowHit[iIndex] = kvSuperTanks.GetNum("Slow Ability/Slow Hit", 0);
					g_iSlowHit[iIndex] = iClamp(g_iSlowHit[iIndex], 0, 1);
					g_iSlowHitMode[iIndex] = kvSuperTanks.GetNum("Slow Ability/Slow Hit Mode", 0);
					g_iSlowHitMode[iIndex] = iClamp(g_iSlowHitMode[iIndex], 0, 2);
					g_flSlowRange[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Range", 150.0);
					g_flSlowRange[iIndex] = flClamp(g_flSlowRange[iIndex], 1.0, 9999999999.0);
					g_flSlowRangeChance[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Range Chance", 15.0);
					g_flSlowRangeChance[iIndex] = flClamp(g_flSlowRangeChance[iIndex], 0.0, 100.0);
					g_flSlowSpeed[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Speed", 0.25);
					g_flSlowSpeed[iIndex] = flClamp(g_flSlowSpeed[iIndex], 0.1, 0.9);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Slow Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Slow Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iSlowAbility2[iIndex] = kvSuperTanks.GetNum("Slow Ability/Ability Enabled", g_iSlowAbility[iIndex]);
					g_iSlowAbility2[iIndex] = iClamp(g_iSlowAbility2[iIndex], 0, 1);
					g_iSlowEffect2[iIndex] = kvSuperTanks.GetNum("Slow Ability/Ability Effect", g_iSlowEffect[iIndex]);
					g_iSlowEffect2[iIndex] = iClamp(g_iSlowEffect2[iIndex], 0, 7);
					g_iSlowMessage2[iIndex] = kvSuperTanks.GetNum("Slow Ability/Ability Message", g_iSlowMessage[iIndex]);
					g_iSlowMessage2[iIndex] = iClamp(g_iSlowMessage2[iIndex], 0, 7);
					g_flSlowChance2[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Chance", g_flSlowChance[iIndex]);
					g_flSlowChance2[iIndex] = flClamp(g_flSlowChance2[iIndex], 0.0, 100.0);
					g_flSlowDuration2[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Duration", g_flSlowDuration[iIndex]);
					g_flSlowDuration2[iIndex] = flClamp(g_flSlowDuration2[iIndex], 0.1, 9999999999.0);
					g_iSlowHit2[iIndex] = kvSuperTanks.GetNum("Slow Ability/Slow Hit", g_iSlowHit[iIndex]);
					g_iSlowHit2[iIndex] = iClamp(g_iSlowHit2[iIndex], 0, 1);
					g_iSlowHitMode2[iIndex] = kvSuperTanks.GetNum("Slow Ability/Slow Hit Mode", g_iSlowHitMode[iIndex]);
					g_iSlowHitMode2[iIndex] = iClamp(g_iSlowHitMode2[iIndex], 0, 2);
					g_flSlowRange2[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Range", g_flSlowRange[iIndex]);
					g_flSlowRange2[iIndex] = flClamp(g_flSlowRange2[iIndex], 1.0, 9999999999.0);
					g_flSlowRangeChance2[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Range Chance", g_flSlowRangeChance[iIndex]);
					g_flSlowRangeChance2[iIndex] = flClamp(g_flSlowRangeChance2[iIndex], 0.0, 100.0);
					g_flSlowSpeed2[iIndex] = kvSuperTanks.GetFloat("Slow Ability/Slow Speed", g_flSlowSpeed[iIndex]);
					g_flSlowSpeed2[iIndex] = flClamp(g_flSlowSpeed2[iIndex], 0.1, 0.9);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
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
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iSlowAbility(tank) == 1)
	{
		vSlowAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iSlowAbility(tank) == 1 && iHumanAbility(tank) == 1)
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

public void ST_OnChangeType(int tank)
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
	if (g_iSlowCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bSlow4[tank] = false;
		g_bSlow5[tank] = false;

		float flSlowRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flSlowRange[ST_GetTankType(tank)] : g_flSlowRange2[ST_GetTankType(tank)],
			flSlowRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flSlowRangeChance[ST_GetTankType(tank)] : g_flSlowRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flSlowRange)
				{
					vSlowHit(iSurvivor, tank, flSlowRangeChance, iSlowAbility(tank), ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowAmmo");
	}
}

static void vSlowHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iSlowCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bSlow[survivor])
			{
				g_bSlow[survivor] = true;
				g_iSlowOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bSlow2[tank])
				{
					g_bSlow2[tank] = true;
					g_iSlowCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowHuman", g_iSlowCount[tank], iHumanAmmo(tank));
				}

				float flSlowSpeed = !g_bTankConfig[ST_GetTankType(tank)] ? g_flSlowSpeed[ST_GetTankType(tank)] : g_flSlowSpeed2[ST_GetTankType(tank)];
				SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", flSlowSpeed);

				DataPack dpStopSlow;
				CreateDataTimer(flSlowDuration(tank), tTimerStopSlow, dpStopSlow, TIMER_FLAG_NO_MAPCHANGE);
				dpStopSlow.WriteCell(GetClientUserId(survivor));
				dpStopSlow.WriteCell(GetClientUserId(tank));
				dpStopSlow.WriteCell(messages);

				int iSlowEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_iSlowEffect[ST_GetTankType(tank)] : g_iSlowEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, iSlowEffect, flags);

				if (iSlowMessage(tank) & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Slow", sTankName, survivor, flSlowSpeed);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bSlow2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bSlow4[tank])
				{
					g_bSlow4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bSlow5[tank])
		{
			g_bSlow5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "SlowAmmo");
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flSlowChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flSlowChance[ST_GetTankType(tank)] : g_flSlowChance2[ST_GetTankType(tank)];
}

static float flSlowDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flSlowDuration[ST_GetTankType(tank)] : g_flSlowDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iSlowAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iSlowAbility[ST_GetTankType(tank)] : g_iSlowAbility2[ST_GetTankType(tank)];
}

static int iSlowHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iSlowHit[ST_GetTankType(tank)] : g_iSlowHit2[ST_GetTankType(tank)];
}

static int iSlowHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iSlowHitMode[ST_GetTankType(tank)] : g_iSlowHitMode2[ST_GetTankType(tank)];
}

static int iSlowMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iSlowMessage[ST_GetTankType(tank)] : g_iSlowMessage2[ST_GetTankType(tank)];
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
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bSlow[iSurvivor])
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

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bSlow3[iTank])
	{
		g_bSlow3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SlowHuman6");

		if (g_iSlowCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bSlow3[iTank] = false;
		}
	}

	if (iSlowMessage(iTank) & iMessage)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Slow2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bSlow3[iTank])
	{
		g_bSlow3[iTank] = false;

		return Plugin_Stop;
	}

	g_bSlow3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SlowHuman7");

	return Plugin_Continue;
}