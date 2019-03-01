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
	name = "[ST++] Choke Ability",
	author = ST_AUTHOR,
	description = "The Super Tank chokes survivors in midair.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Choke Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_CHOKE "Choke Ability"

bool g_bChoke[MAXPLAYERS + 1], g_bChoke2[MAXPLAYERS + 1], g_bChoke3[MAXPLAYERS + 1], g_bChoke4[MAXPLAYERS + 1], g_bChoke5[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flChokeAngle[MAXPLAYERS + 1][3], g_flChokeChance[ST_MAXTYPES + 1], g_flChokeDamage[ST_MAXTYPES + 1], g_flChokeDelay[ST_MAXTYPES + 1], g_flChokeDuration[ST_MAXTYPES + 1], g_flChokeHeight[ST_MAXTYPES + 1], g_flChokeRange[ST_MAXTYPES + 1], g_flChokeRangeChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iChokeAbility[ST_MAXTYPES + 1], g_iChokeCount[MAXPLAYERS + 1], g_iChokeEffect[ST_MAXTYPES + 1], g_iChokeHit[ST_MAXTYPES + 1], g_iChokeHitMode[ST_MAXTYPES + 1], g_iChokeMessage[ST_MAXTYPES + 1], g_iChokeOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_choke", cmdChokeInfo, "View information about the Choke ability.");

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

public Action cmdChokeInfo(int client, int args)
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
		case false: vChokeMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vChokeMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iChokeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Choke Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iChokeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iChokeAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iChokeCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ChokeDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flChokeDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vChokeMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ChokeMenu", param1);
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
	menu.AddItem(ST_MENU_CHOKE, ST_MENU_CHOKE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_CHOKE, false))
	{
		vChokeMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iChokeHitMode[ST_GetTankType(attacker)] == 0 || g_iChokeHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vChokeHit(victim, attacker, g_flChokeChance[ST_GetTankType(attacker)], g_iChokeHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iChokeHitMode[ST_GetTankType(victim)] == 0 || g_iChokeHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vChokeHit(attacker, victim, g_flChokeChance[ST_GetTankType(victim)], g_iChokeHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iChokeAbility[iIndex] = 0;
		g_iChokeEffect[iIndex] = 0;
		g_iChokeMessage[iIndex] = 0;
		g_flChokeChance[iIndex] = 33.3;
		g_flChokeDamage[iIndex] = 5.0;
		g_flChokeDelay[iIndex] = 1.0;
		g_flChokeDuration[iIndex] = 5.0;
		g_flChokeHeight[iIndex] = 300.0;
		g_iChokeHit[iIndex] = 0;
		g_iChokeHitMode[iIndex] = 0;
		g_flChokeRange[iIndex] = 150.0;
		g_flChokeRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iChokeAbility[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iChokeAbility[type], value, 0, 0, 1);
	g_iChokeEffect[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iChokeEffect[type], value, 0, 0, 7);
	g_iChokeMessage[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iChokeMessage[type], value, 0, 0, 3);
	g_flChokeChance[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeChance", "Choke Chance", "Choke_Chance", "chance", main, g_flChokeChance[type], value, 33.3, 0.0, 100.0);
	g_flChokeDamage[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeDamage", "Choke Damage", "Choke_Damage", "damage", main, g_flChokeDamage[type], value, 5.0, 1.0, 9999999999.0);
	g_flChokeDelay[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeDelay", "Choke Delay", "Choke_Delay", "delay", main, g_flChokeDelay[type], value, 1.0, 0.1, 9999999999.0);
	g_flChokeDuration[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeDuration", "Choke Duration", "Choke_Duration", "duration", main, g_flChokeDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_flChokeHeight[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeHeight", "Choke Height", "Choke_Height", "height", main, g_flChokeHeight[type], value, 300.0, 0.1, 9999999999.0);
	g_iChokeHit[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeHit", "Choke Hit", "Choke_Hit", "hit", main, g_iChokeHit[type], value, 0, 0, 1);
	g_iChokeHitMode[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeHitMode", "Choke Hit Mode", "Choke_Hit_Mode", "hitmode", main, g_iChokeHitMode[type], value, 0, 0, 2);
	g_flChokeRange[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeRange", "Choke Range", "Choke_Range", "range", main, g_flChokeRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flChokeRangeChance[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeRangeChance", "Choke Range Chance", "Choke_Range_Chance", "rangechance", main, g_flChokeRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bChoke[iSurvivor])
		{
			SetEntityMoveType(iSurvivor, MOVETYPE_WALK);
			SetEntityGravity(iSurvivor, 1.0);
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
			vRemoveChoke(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iChokeAbility[ST_GetTankType(tank)] == 1)
	{
		vChokeAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iChokeAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bChoke2[tank] && !g_bChoke3[tank])
				{
					vChokeAbility(tank);
				}
				else if (g_bChoke2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman3");
				}
				else if (g_bChoke3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveChoke(tank);
}

static void vChokeAbility(int tank)
{
	if (g_iChokeCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bChoke4[tank] = false;
		g_bChoke5[tank] = false;

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
				if (flDistance <= g_flChokeRange[ST_GetTankType(tank)])
				{
					vChokeHit(iSurvivor, tank, g_flChokeRangeChance[ST_GetTankType(tank)], g_iChokeAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeAmmo");
	}
}

static void vChokeHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iChokeCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bChoke[survivor])
			{
				g_bChoke[survivor] = true;
				g_iChokeOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bChoke2[tank])
				{
					g_bChoke2[tank] = true;
					g_iChokeCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman", g_iChokeCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				GetClientEyeAngles(survivor, g_flChokeAngle[survivor]);

				DataPack dpChokeLaunch;
				CreateDataTimer(g_flChokeDelay[ST_GetTankType(tank)], tTimerChokeLaunch, dpChokeLaunch, TIMER_FLAG_NO_MAPCHANGE);
				dpChokeLaunch.WriteCell(GetClientUserId(survivor));
				dpChokeLaunch.WriteCell(GetClientUserId(tank));
				dpChokeLaunch.WriteCell(ST_GetTankType(tank));
				dpChokeLaunch.WriteCell(enabled);
				dpChokeLaunch.WriteCell(messages);

				vEffect(survivor, tank, g_iChokeEffect[ST_GetTankType(tank)], flags);

				if (g_iChokeMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Choke", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bChoke2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bChoke4[tank])
				{
					g_bChoke4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bChoke5[tank])
		{
			g_bChoke5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeAmmo");
		}
	}
}

static void vRemoveChoke(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_bChoke[iSurvivor] && g_iChokeOwner[iSurvivor] == tank)
		{
			g_bChoke[iSurvivor] = false;
			g_iChokeOwner[iSurvivor] = 0;
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

			g_iChokeOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bChoke[survivor] = false;
	g_iChokeOwner[survivor] = 0;

	SetEntityMoveType(survivor, MOVETYPE_WALK);
	SetEntityGravity(survivor, 1.0);

	if (g_iChokeMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Choke2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bChoke[tank] = false;
	g_bChoke2[tank] = false;
	g_bChoke3[tank] = false;
	g_bChoke4[tank] = false;
	g_bChoke5[tank] = false;
	g_iChokeCount[tank] = 0;
}

public Action tTimerChokeLaunch(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor) || !g_bChoke[iSurvivor])
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iChokeEnabled = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || iChokeEnabled == 0)
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iMessage = pack.ReadCell();

	float flVelocity[3];
	flVelocity[0] = 0.0;
	flVelocity[1] = 0.0;
	flVelocity[2] = g_flChokeHeight[ST_GetTankType(iTank)];

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityGravity(iSurvivor, 0.1);

	DataPack dpChokeDamage;
	CreateDataTimer(1.0, tTimerChokeDamage, dpChokeDamage, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpChokeDamage.WriteCell(GetClientUserId(iSurvivor));
	dpChokeDamage.WriteCell(GetClientUserId(iTank));
	dpChokeDamage.WriteCell(ST_GetTankType(iTank));
	dpChokeDamage.WriteCell(iMessage);
	dpChokeDamage.WriteCell(iChokeEnabled);
	dpChokeDamage.WriteFloat(GetEngineTime());

	return Plugin_Continue;
}

public Action tTimerChokeDamage(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bChoke[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iChokeEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iChokeEnabled == 0 || (flTime + g_flChokeDuration[ST_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bChoke2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bChoke3[iTank])
		{
			g_bChoke3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ChokeHuman6");

			if (g_iChokeCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bChoke3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));

	SetEntityMoveType(iSurvivor, MOVETYPE_NONE);
	SetEntityGravity(iSurvivor, 1.0);

	vDamageEntity(iSurvivor, iTank, g_flChokeDamage[ST_GetTankType(iTank)], "16384");

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bChoke3[iTank])
	{
		g_bChoke3[iTank] = false;

		return Plugin_Stop;
	}

	g_bChoke3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ChokeHuman7");

	return Plugin_Continue;
}