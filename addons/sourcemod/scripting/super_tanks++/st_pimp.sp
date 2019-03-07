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
	name = "[ST++] Pimp Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pimp slaps survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Pimp Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_PIMP "Pimp Ability"

bool g_bCloneInstalled, g_bPimp[MAXPLAYERS + 1], g_bPimp2[MAXPLAYERS + 1], g_bPimp3[MAXPLAYERS + 1], g_bPimp4[MAXPLAYERS + 1], g_bPimp5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flPimpChance[ST_MAXTYPES + 1], g_flPimpDuration[ST_MAXTYPES + 1], g_flPimpInterval[ST_MAXTYPES + 1], g_flPimpRange[ST_MAXTYPES + 1], g_flPimpRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iPimpAbility[ST_MAXTYPES + 1], g_iPimpCount[MAXPLAYERS + 1], g_iPimpDamage[ST_MAXTYPES + 1], g_iPimpEffect[ST_MAXTYPES + 1], g_iPimpHit[ST_MAXTYPES + 1], g_iPimpHitMode[ST_MAXTYPES + 1], g_iPimpMessage[ST_MAXTYPES + 1], g_iPimpOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_pimp", cmdPimpInfo, "View information about the Pimp ability.");

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

	vRemovePimp(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdPimpInfo(int client, int args)
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
		case false: vPimpMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vPimpMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iPimpMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Pimp Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iPimpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iPimpAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iPimpCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "PimpDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flPimpDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vPimpMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "PimpMenu", param1);
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
	menu.AddItem(ST_MENU_PIMP, ST_MENU_PIMP);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_PIMP, false))
	{
		vPimpMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iPimpHitMode[ST_GetTankType(attacker)] == 0 || g_iPimpHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPimpHit(victim, attacker, g_flPimpChance[ST_GetTankType(attacker)], g_iPimpHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iPimpHitMode[ST_GetTankType(victim)] == 0 || g_iPimpHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPimpHit(attacker, victim, g_flPimpChance[ST_GetTankType(victim)], g_iPimpHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iPimpAbility[iIndex] = 0;
		g_iPimpEffect[iIndex] = 0;
		g_iPimpMessage[iIndex] = 0;
		g_flPimpChance[iIndex] = 33.3;
		g_iPimpDamage[iIndex] = 1;
		g_flPimpDuration[iIndex] = 5.0;
		g_iPimpHit[iIndex] = 0;
		g_iPimpHitMode[iIndex] = 0;
		g_flPimpInterval[iIndex] = 1.0;
		g_flPimpRange[iIndex] = 150.0;
		g_flPimpRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 42, bHasAbilities(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp"));
	g_iHumanAbility[type] = iGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iPimpAbility[type] = iGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iPimpAbility[type], value, 0, 0, 1);
	g_iPimpEffect[type] = iGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iPimpEffect[type], value, 0, 0, 7);
	g_iPimpMessage[type] = iGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iPimpMessage[type], value, 0, 0, 3);
	g_flPimpChance[type] = flGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpChance", "Pimp Chance", "Pimp_Chance", "chance", main, g_flPimpChance[type], value, 33.3, 0.0, 100.0);
	g_iPimpDamage[type] = iGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpDamage", "Pimp Damage", "Pimp_Damage", "damage", main, g_iPimpDamage[type], value, 1, 1, 9999999999);
	g_flPimpDuration[type] = flGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpDuration", "Pimp Duration", "Pimp_Duration", "duration", main, g_flPimpDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iPimpHit[type] = iGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpHit", "Pimp Hit", "Pimp_Hit", "hit", main, g_iPimpHit[type], value, 0, 0, 1);
	g_iPimpHitMode[type] = iGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpHitMode", "Pimp Hit Mode", "Pimp_Hit_Mode", "hitmode", main, g_iPimpHitMode[type], value, 0, 0, 2);
	g_flPimpInterval[type] = flGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpInterval", "Pimp Interval", "Pimp_Interval", "interval", main, g_flPimpInterval[type], value, 1.0, 0.1, 9999999999.0);
	g_flPimpRange[type] = flGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpRange", "Pimp Range", "Pimp_Range", "range", main, g_flPimpRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flPimpRangeChance[type] = flGetValue(subsection, "pimpability", "pimp ability", "pimp_ability", "pimp", key, "PimpRangeChance", "Pimp Range Chance", "Pimp_Range_Chance", "rangechance", main, g_flPimpRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemovePimp(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iPimpAbility[ST_GetTankType(tank)] == 1)
	{
		vPimpAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iPimpAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bPimp2[tank] && !g_bPimp3[tank])
				{
					vPimpAbility(tank);
				}
				else if (g_bPimp2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman3");
				}
				else if (g_bPimp3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemovePimp(tank);
}

static void vPimpAbility(int tank)
{
	if (g_iPimpCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bPimp4[tank] = false;
		g_bPimp5[tank] = false;

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
				if (flDistance <= g_flPimpRange[ST_GetTankType(tank)])
				{
					vPimpHit(iSurvivor, tank, g_flPimpRangeChance[ST_GetTankType(tank)], g_iPimpAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpAmmo");
	}
}

static void vPimpHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iPimpCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bPimp[survivor])
			{
				g_bPimp[survivor] = true;
				g_iPimpOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bPimp2[tank])
				{
					g_bPimp2[tank] = true;
					g_iPimpCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman", g_iPimpCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpPimp;
				CreateDataTimer(g_flPimpInterval[ST_GetTankType(tank)], tTimerPimp, dpPimp, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpPimp.WriteCell(GetClientUserId(survivor));
				dpPimp.WriteCell(GetClientUserId(tank));
				dpPimp.WriteCell(ST_GetTankType(tank));
				dpPimp.WriteCell(messages);
				dpPimp.WriteCell(enabled);
				dpPimp.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iPimpEffect[ST_GetTankType(tank)], flags);

				if (g_iPimpMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Pimp", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bPimp2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bPimp4[tank])
				{
					g_bPimp4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bPimp5[tank])
		{
			g_bPimp5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "PimpAmmo");
		}
	}
}

static void vRemovePimp(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bPimp[iSurvivor] && g_iPimpOwner[iSurvivor] == tank)
		{
			g_bPimp[iSurvivor] = false;
			g_iPimpOwner[iSurvivor] = 0;
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

			g_iPimpOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bPimp[survivor] = false;
	g_iPimpOwner[survivor] = 0;

	if (g_iPimpMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Pimp2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bPimp[tank] = false;
	g_bPimp2[tank] = false;
	g_bPimp3[tank] = false;
	g_bPimp4[tank] = false;
	g_bPimp5[tank] = false;
	g_iPimpCount[tank] = 0;
}

public Action tTimerPimp(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bPimp[iSurvivor] = false;
		g_iPimpOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bPimp[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iPimpEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iPimpEnabled == 0 || (flTime + g_flPimpDuration[ST_GetTankType(iTank)]) < GetEngineTime() || !g_bPimp[iSurvivor])
	{
		g_bPimp2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bPimp3[iTank])
		{
			g_bPimp3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "PimpHuman6");

			if (g_iPimpCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bPimp3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	SlapPlayer(iSurvivor, g_iPimpDamage[ST_GetTankType(iTank)], true);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bPimp3[iTank])
	{
		g_bPimp3[iTank] = false;

		return Plugin_Stop;
	}

	g_bPimp3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "PimpHuman7");

	return Plugin_Continue;
}