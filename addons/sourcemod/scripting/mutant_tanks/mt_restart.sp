/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
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
#include <left4dhooks>
#include <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Restart Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank forces survivors to restart at the beginning of the map or near a teammate with a new loadout.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Restart Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_RESTART "Restart Ability"

enum struct esGeneralSettings
{
	bool g_bCloneInstalled;
	bool g_bDhooksInstalled;

	Handle g_hSDKRespawnPlayer;
}

esGeneralSettings g_esGeneral;

enum struct esPlayerSettings
{
	bool g_bRestart;
	bool g_bRestart2;
	bool g_bRestart3;
	bool g_bRestart4;

	float g_flRestartPosition[3];

	int g_iAccessFlags2;
	int g_iImmunityFlags2;
	int g_iRestartCount;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	char g_sRestartLoadout[325];

	float g_flHumanCooldown;
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iImmunityFlags;
	int g_iRestartAbility;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
}

esAbilitySettings g_esAbility[MT_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_esGeneral.g_bDhooksInstalled = LibraryExists("left4dhooks");
	g_esGeneral.g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "left4dhooks", false))
	{
		g_esGeneral.g_bDhooksInstalled = true;
	}
	else if (StrEqual(name, "mt_clone", false))
	{
		g_esGeneral.g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "left4dhooks", false))
	{
		g_esGeneral.g_bDhooksInstalled = false;
	}
	else if (StrEqual(name, "mt_clone", false))
	{
		g_esGeneral.g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_restart", cmdRestartInfo, "View information about the Restart ability.");

	GameData gdMutantTanks = new GameData("mutant_tanks");

	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");

		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "RoundRespawn"))
	{
		SetFailState("Failed to find signature: RoundRespawn");
	}

	g_esGeneral.g_hSDKRespawnPlayer = EndPrepSDKCall();

	if (g_esGeneral.g_hSDKRespawnPlayer == null)
	{
		PrintToServer("%s Your \"RoundRespawn\" signature is outdated.", MT_TAG);
	}

	delete gdMutantTanks;

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
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

	vRemoveRestart(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRestartInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vRestartMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRestartMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRestartMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Restart Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRestartMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iRestartAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iRestartCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RestartDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vRestartMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "RestartMenu", param1);
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
	menu.AddItem(MT_MENU_RESTART, MT_MENU_RESTART);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_RESTART, false))
	{
		vRestartMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_esGeneral.g_bCloneInstalled) && (g_esAbility[MT_GetTankType(attacker)].g_iRestartHitMode == 0 || g_esAbility[MT_GetTankType(attacker)].g_iRestartHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRestartHit(victim, attacker, g_esAbility[MT_GetTankType(attacker)].g_flRestartChance, g_esAbility[MT_GetTankType(attacker)].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_esGeneral.g_bCloneInstalled) && (g_esAbility[MT_GetTankType(victim)].g_iRestartHitMode == 0 || g_esAbility[MT_GetTankType(victim)].g_iRestartHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRestartHit(attacker, victim, g_esAbility[MT_GetTankType(victim)].g_flRestartChance, g_esAbility[MT_GetTankType(victim)].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("restartability");
	list2.PushString("restart ability");
	list3.PushString("restart_ability");
	list4.PushString("restart");
}

public void MT_OnConfigsLoad(int mode)
{
	if (mode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				g_esPlayer[iPlayer].g_iAccessFlags2 = 0;
				g_esPlayer[iPlayer].g_iImmunityFlags2 = 0;
			}
		}
	}
	else if (mode == 1)
	{
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			g_esAbility[iIndex].g_iAccessFlags = 0;
			g_esAbility[iIndex].g_iImmunityFlags = 0;
			g_esAbility[iIndex].g_iHumanAbility = 0;
			g_esAbility[iIndex].g_iHumanAmmo = 5;
			g_esAbility[iIndex].g_flHumanCooldown = 30.0;
			g_esAbility[iIndex].g_iRestartAbility = 0;
			g_esAbility[iIndex].g_iRestartEffect = 0;
			g_esAbility[iIndex].g_iRestartMessage = 0;
			g_esAbility[iIndex].g_flRestartChance = 33.3;
			g_esAbility[iIndex].g_iRestartHit = 0;
			g_esAbility[iIndex].g_iRestartHitMode = 0;
			Format(g_esAbility[iIndex].g_sRestartLoadout, sizeof(g_esAbility[].g_sRestartLoadout), "smg,pistol,pain_pills");
			g_esAbility[iIndex].g_iRestartMode = 1;
			g_esAbility[iIndex].g_flRestartRange = 150.0;
			g_esAbility[iIndex].g_flRestartRangeChance = 15.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "restartability", false) || StrEqual(subsection, "restart ability", false) || StrEqual(subsection, "restart_ability", false) || StrEqual(subsection, "restart", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iImmunityFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iRestartAbility = iGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iRestartAbility, value, 0, 1);
		g_esAbility[type].g_iRestartEffect = iGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iRestartEffect, value, 0, 7);
		g_esAbility[type].g_iRestartMessage = iGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iRestartMessage, value, 0, 3);
		g_esAbility[type].g_flRestartChance = flGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartChance", "Restart Chance", "Restart_Chance", "chance", g_esAbility[type].g_flRestartChance, value, 0.0, 100.0);
		g_esAbility[type].g_iRestartHit = iGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartHit", "Restart Hit", "Restart_Hit", "hit", g_esAbility[type].g_iRestartHit, value, 0, 1);
		g_esAbility[type].g_iRestartHitMode = iGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartHitMode", "Restart Hit Mode", "Restart_Hit_Mode", "hitmode", g_esAbility[type].g_iRestartHitMode, value, 0, 2);
		g_esAbility[type].g_iRestartMode = iGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartMode", "Restart Mode", "Restart_Mode", "mode", g_esAbility[type].g_iRestartMode, value, 0, 1);
		g_esAbility[type].g_flRestartRange = flGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartRange", "Restart Range", "Restart_Range", "range", g_esAbility[type].g_flRestartRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flRestartRangeChance = flGetValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartRangeChance", "Restart Range Chance", "Restart_Range_Chance", "rangechance", g_esAbility[type].g_flRestartRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "restartability", false) || StrEqual(subsection, "restart ability", false) || StrEqual(subsection, "restart_ability", false) || StrEqual(subsection, "restart", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iAccessFlags;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iImmunityFlags;
			}
		}

		if ((StrEqual(subsection, "restartability", false) || StrEqual(subsection, "restart ability", false) || StrEqual(subsection, "restart_ability", false) || StrEqual(subsection, "restart", false)) && (StrEqual(key, "RestartLoadout", false) || StrEqual(key, "Restart Loadout", false) || StrEqual(key, "Restart_Loadout", false) || StrEqual(key, "loadout", false)) && value[0] != '\0')
		{
			strcopy(g_esAbility[type].g_sRestartLoadout, sizeof(g_esAbility[].g_sRestartLoadout), value);
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveRestart(iTank);
		}
	}

	if (StrEqual(name, "player_spawn"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor) && (!g_esPlayer[iSurvivor].g_bRestart4 || (g_esGeneral.g_bDhooksInstalled && L4D_IsInFirstCheckpoint(iSurvivor))))
		{
			g_esPlayer[iSurvivor].g_bRestart4 = true;

			GetClientAbsOrigin(iSurvivor, g_esPlayer[iSurvivor].g_flRestartPosition);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_esGeneral.g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iRestartAbility == 1)
	{
		vRestartAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_esGeneral.g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iRestartAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_bRestart)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman3");
					case false: vRestartAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveRestart(tank);
}

static void vRemoveRestart(int tank)
{
	g_esPlayer[tank].g_bRestart = false;
	g_esPlayer[tank].g_bRestart2 = false;
	g_esPlayer[tank].g_bRestart3 = false;
	g_esPlayer[tank].g_bRestart4 = false;
	g_esPlayer[tank].g_iRestartCount = 0;
}

static void vRemoveWeapon(int survivor, int slot)
{
	int iSlot = GetPlayerWeaponSlot(survivor, slot);
	if (iSlot > 0)
	{
		RemovePlayerItem(survivor, iSlot);
		RemoveEntity(iSlot);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveRestart(iPlayer);
		}
	}
}

static void vRestartAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_esPlayer[tank].g_iRestartCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		g_esPlayer[tank].g_bRestart2 = false;
		g_esPlayer[tank].g_bRestart3 = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_esAbility[MT_GetTankType(tank)].g_flRestartRange)
				{
					vRestartHit(iSurvivor, tank, g_esAbility[MT_GetTankType(tank)].g_flRestartRangeChance, g_esAbility[MT_GetTankType(tank)].g_iRestartAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartAmmo");
	}
}

static void vRestartHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_esPlayer[tank].g_iRestartCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bRestart)
				{
					g_esPlayer[tank].g_bRestart = true;
					g_esPlayer[tank].g_iRestartCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman", g_esPlayer[tank].g_iRestartCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);

					if (g_esPlayer[tank].g_iRestartCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
					{
						CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_esPlayer[tank].g_bRestart = false;
					}
				}

				SDKCall(g_esGeneral.g_hSDKRespawnPlayer, survivor);

				char sItems[5][64];
				ReplaceString(g_esAbility[MT_GetTankType(tank)].g_sRestartLoadout, sizeof(g_esAbility[].g_sRestartLoadout), " ", "");
				ExplodeString(g_esAbility[MT_GetTankType(tank)].g_sRestartLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));

				for (int iWeapon = 0; iWeapon < 5; iWeapon++)
				{
					vRemoveWeapon(survivor, iWeapon);
				}

				for (int iItem = 0; iItem < sizeof(sItems); iItem++)
				{
					if (StrContains(g_esAbility[MT_GetTankType(tank)].g_sRestartLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
					{
						vCheatCommand(survivor, "give", sItems[iItem]);
					}
				}

				if (g_esPlayer[survivor].g_bRestart4 && g_esAbility[MT_GetTankType(tank)].g_iRestartMode == 0)
				{
					TeleportEntity(survivor, g_esPlayer[survivor].g_flRestartPosition, NULL_VECTOR, NULL_VECTOR);
				}
				else
				{
					float flCurrentOrigin[3];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (!bIsSurvivor(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) || bIsPlayerIncapacitated(iPlayer) || iPlayer == survivor)
						{
							continue;
						}

						GetClientAbsOrigin(iPlayer, flCurrentOrigin);
						TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

						break;
					}
				}

				vEffect(survivor, tank, g_esAbility[MT_GetTankType(tank)].g_iRestartEffect, flags);

				if (g_esAbility[MT_GetTankType(tank)].g_iRestartMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Restart", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bRestart)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bRestart2)
				{
					g_esPlayer[tank].g_bRestart2 = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bRestart3)
		{
			g_esPlayer[tank].g_bRestart3 = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartAmmo");
		}
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_esAbility[MT_GetTankType(admin)].g_iAccessFlags;
	if (iAbilityFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iAbilityFlags)) ? false : true;
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iTypeFlags)) ? false : true;
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iGlobalFlags)) ? false : true;
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
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

	int iAbilityFlags = g_esAbility[MT_GetTankType(tank)].g_iImmunityFlags;
	if (iAbilityFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iAbilityFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iTypeFlags = MT_GetImmunityFlags(2, MT_GetTankType(tank));
	if (iTypeFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iTypeFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iGlobalFlags = MT_GetImmunityFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iGlobalFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iClientTypeFlags = MT_GetImmunityFlags(4, MT_GetTankType(tank), survivor),
		iClientTypeFlags2 = MT_GetImmunityFlags(4, MT_GetTankType(tank), tank);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
	{
		return (iClientTypeFlags2 != 0 && (iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
	}

	int iClientGlobalFlags = MT_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = MT_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
	{
		return (iClientGlobalFlags2 != 0 && (iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
	}

	int iSurvivorFlags = GetUserFlagBits(survivor), iTankFlags = GetUserFlagBits(tank);
	if (iAbilityFlags != 0 && iSurvivorFlags != 0 && (iSurvivorFlags & iAbilityFlags))
	{
		return (iTankFlags != 0 && iSurvivorFlags <= iTankFlags) ? false : true;
	}

	return false;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_esGeneral.g_bCloneInstalled) || !g_esPlayer[iTank].g_bRestart)
	{
		g_esPlayer[iTank].g_bRestart = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bRestart = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "RestartHuman5");

	return Plugin_Continue;
}