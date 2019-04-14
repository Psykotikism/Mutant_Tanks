/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
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
#include <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Choke Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank chokes survivors in midair.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Choke Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_CHOKE "Choke Ability"

bool g_bChoke[MAXPLAYERS + 1], g_bChoke2[MAXPLAYERS + 1], g_bChoke3[MAXPLAYERS + 1], g_bChoke4[MAXPLAYERS + 1], g_bChoke5[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flChokeAngle[MAXPLAYERS + 1][3], g_flChokeChance[MT_MAXTYPES + 1], g_flChokeDamage[MT_MAXTYPES + 1], g_flChokeDelay[MT_MAXTYPES + 1], g_flChokeDuration[MT_MAXTYPES + 1], g_flChokeHeight[MT_MAXTYPES + 1], g_flChokeRange[MT_MAXTYPES + 1], g_flChokeRangeChance[MT_MAXTYPES + 1], g_flHumanCooldown[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iChokeAbility[MT_MAXTYPES + 1], g_iChokeCount[MAXPLAYERS + 1], g_iChokeEffect[MT_MAXTYPES + 1], g_iChokeHit[MT_MAXTYPES + 1], g_iChokeHitMode[MT_MAXTYPES + 1], g_iChokeMessage[MT_MAXTYPES + 1], g_iChokeOwner[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_choke", cmdChokeInfo, "View information about the Choke ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iChokeAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iChokeCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ChokeDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flChokeDuration[MT_GetTankType(param1)]);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_CHOKE, MT_MENU_CHOKE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_CHOKE, false))
	{
		vChokeMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iChokeHitMode[MT_GetTankType(attacker)] == 0 || g_iChokeHitMode[MT_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vChokeHit(victim, attacker, g_flChokeChance[MT_GetTankType(attacker)], g_iChokeHit[MT_GetTankType(attacker)], MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iChokeHitMode[MT_GetTankType(victim)] == 0 || g_iChokeHitMode[MT_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vChokeHit(attacker, victim, g_flChokeChance[MT_GetTankType(victim)], g_iChokeHit[MT_GetTankType(victim)], MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
			g_iImmunityFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iImmunityFlags[iIndex] = 0;
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

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "chokeability", false) || StrEqual(subsection, "choke ability", false) || StrEqual(subsection, "choke_ability", false) || StrEqual(subsection, "choke", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		MT_FindAbility(type, 8, bHasAbilities(subsection, "chokeability", "choke ability", "choke_ability", "choke"));
		g_iHumanAbility[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iChokeAbility[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iChokeAbility[type], value, 0, 1);
		g_iChokeEffect[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iChokeEffect[type], value, 0, 7);
		g_iChokeMessage[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iChokeMessage[type], value, 0, 3);
		g_flChokeChance[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeChance", "Choke Chance", "Choke_Chance", "chance", g_flChokeChance[type], value, 0.0, 100.0);
		g_flChokeDamage[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeDamage", "Choke Damage", "Choke_Damage", "damage", g_flChokeDamage[type], value, 1.0, 9999999999.0);
		g_flChokeDelay[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeDelay", "Choke Delay", "Choke_Delay", "delay", g_flChokeDelay[type], value, 0.1, 9999999999.0);
		g_flChokeDuration[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeDuration", "Choke Duration", "Choke_Duration", "duration", g_flChokeDuration[type], value, 0.1, 9999999999.0);
		g_flChokeHeight[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeHeight", "Choke Height", "Choke_Height", "height", g_flChokeHeight[type], value, 0.1, 9999999999.0);
		g_iChokeHit[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeHit", "Choke Hit", "Choke_Hit", "hit", g_iChokeHit[type], value, 0, 1);
		g_iChokeHitMode[type] = iGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeHitMode", "Choke Hit Mode", "Choke_Hit_Mode", "hitmode", g_iChokeHitMode[type], value, 0, 2);
		g_flChokeRange[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeRange", "Choke Range", "Choke_Range", "range", g_flChokeRange[type], value, 1.0, 9999999999.0);
		g_flChokeRangeChance[type] = flGetValue(subsection, "chokeability", "choke ability", "choke_ability", "choke", key, "ChokeRangeChance", "Choke Range Chance", "Choke_Range_Chance", "rangechance", g_flChokeRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "chokeability", false) || StrEqual(subsection, "choke ability", false) || StrEqual(subsection, "choke_ability", false) || StrEqual(subsection, "choke", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags[type];
			}
		}
	}
}

public void MT_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && g_bChoke[iSurvivor])
		{
			SetEntityMoveType(iSurvivor, MOVETYPE_WALK);
			SetEntityGravity(iSurvivor, 1.0);
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveChoke(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iChokeAbility[MT_GetTankType(tank)] == 1)
	{
		vChokeAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if (g_iChokeAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (!g_bChoke2[tank] && !g_bChoke3[tank])
				{
					vChokeAbility(tank);
				}
				else if (g_bChoke2[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChokeHuman3");
				}
				else if (g_bChoke3[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChokeHuman4");
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveChoke(tank);
}

static void vChokeAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iChokeCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		g_bChoke4[tank] = false;
		g_bChoke5[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_flChokeRange[MT_GetTankType(tank)])
				{
					vChokeHit(iSurvivor, tank, g_flChokeRangeChance[MT_GetTankType(tank)], g_iChokeAbility[MT_GetTankType(tank)], MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChokeHuman5");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChokeAmmo");
	}
}

static void vChokeHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iChokeCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bChoke[survivor])
			{
				g_bChoke[survivor] = true;
				g_iChokeOwner[survivor] = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && (flags & MT_ATTACK_RANGE) && !g_bChoke2[tank])
				{
					g_bChoke2[tank] = true;
					g_iChokeCount[tank]++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChokeHuman", g_iChokeCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
				}

				GetClientEyeAngles(survivor, g_flChokeAngle[survivor]);

				DataPack dpChokeLaunch;
				CreateDataTimer(g_flChokeDelay[MT_GetTankType(tank)], tTimerChokeLaunch, dpChokeLaunch, TIMER_FLAG_NO_MAPCHANGE);
				dpChokeLaunch.WriteCell(GetClientUserId(survivor));
				dpChokeLaunch.WriteCell(GetClientUserId(tank));
				dpChokeLaunch.WriteCell(MT_GetTankType(tank));
				dpChokeLaunch.WriteCell(enabled);
				dpChokeLaunch.WriteCell(messages);

				vEffect(survivor, tank, g_iChokeEffect[MT_GetTankType(tank)], flags);

				if (g_iChokeMessage[MT_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Choke", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_bChoke2[tank])
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bChoke4[tank])
				{
					g_bChoke4[tank] = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChokeHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bChoke5[tank])
		{
			g_bChoke5[tank] = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChokeAmmo");
		}
	}
}

static void vRemoveChoke(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && g_bChoke[iSurvivor] && g_iChokeOwner[iSurvivor] == tank)
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
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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

	if (g_iChokeMessage[MT_GetTankType(tank)] & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Choke2", survivor);
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

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[MT_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iAbilityFlags)) ? false : true;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iTypeFlags)) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iGlobalFlags)) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
	{
		return false;
	}

	int iAbilityFlags = g_iImmunityFlags[MT_GetTankType(survivor)];
	if (iAbilityFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iAbilityFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iTypeFlags = MT_GetImmunityFlags(2, MT_GetTankType(survivor));
	if (iTypeFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iTypeFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetImmunityFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iGlobalFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetImmunityFlags(4, MT_GetTankType(tank), survivor),
		iClientTypeFlags2 = MT_GetImmunityFlags(4, MT_GetTankType(tank), tank);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
		{
			return ((iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = MT_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
		{
			return ((iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return ((GetUserFlagBits(tank) & iAbilityFlags) && GetUserFlagBits(survivor) <= GetUserFlagBits(tank)) ? false : true;
	}

	return false;
}

public Action tTimerChokeLaunch(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor) || !g_bChoke[iSurvivor])
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iChokeEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, iTank) || iChokeEnabled == 0)
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iMessage = pack.ReadCell();

	float flVelocity[3];
	flVelocity[0] = 0.0;
	flVelocity[1] = 0.0;
	flVelocity[2] = g_flChokeHeight[MT_GetTankType(iTank)];

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityGravity(iSurvivor, 0.1);

	DataPack dpChokeDamage;
	CreateDataTimer(1.0, tTimerChokeDamage, dpChokeDamage, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpChokeDamage.WriteCell(GetClientUserId(iSurvivor));
	dpChokeDamage.WriteCell(GetClientUserId(iTank));
	dpChokeDamage.WriteCell(MT_GetTankType(iTank));
	dpChokeDamage.WriteCell(iMessage);
	dpChokeDamage.WriteCell(iChokeEnabled);
	dpChokeDamage.WriteFloat(GetEngineTime());

	return Plugin_Continue;
}

public Action tTimerChokeDamage(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, iTank) || !g_bChoke[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iChokeEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iChokeEnabled == 0 || (flTime + g_flChokeDuration[MT_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bChoke2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && (iMessage & MT_MESSAGE_RANGE) && !g_bChoke3[iTank])
		{
			g_bChoke3[iTank] = true;

			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ChokeHuman6");

			if (g_iChokeCount[iTank] < g_iHumanAmmo[MT_GetTankType(iTank)] && g_iHumanAmmo[MT_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[MT_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
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

	vDamageEntity(iSurvivor, iTank, g_flChokeDamage[MT_GetTankType(iTank)], "16384");

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bChoke3[iTank])
	{
		g_bChoke3[iTank] = false;

		return Plugin_Stop;
	}

	g_bChoke3[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ChokeHuman7");

	return Plugin_Continue;
}