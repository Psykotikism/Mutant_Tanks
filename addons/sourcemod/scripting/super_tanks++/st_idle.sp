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
	name = "[ST++] Idle Ability",
	author = ST_AUTHOR,
	description = "The Super Tank forces survivors to go idle.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Idle Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_IDLE "Idle Ability"

bool g_bCloneInstalled, g_bIdle[MAXPLAYERS + 1], g_bIdle2[MAXPLAYERS + 1], g_bIdle3[MAXPLAYERS + 1], g_bIdle4[MAXPLAYERS + 1], g_bIdled[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flIdleChance[ST_MAXTYPES + 1], g_flIdleRange[ST_MAXTYPES + 1], g_flIdleRangeChance[ST_MAXTYPES + 1];

Handle g_hSDKIdlePlayer, g_hSDKSpecPlayer;

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iIdleAbility[ST_MAXTYPES + 1], g_iIdleCount[MAXPLAYERS + 1], g_iIdleEffect[ST_MAXTYPES + 1], g_iIdleHit[ST_MAXTYPES + 1], g_iIdleHitMode[ST_MAXTYPES + 1], g_iIdleMessage[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_idle", cmdIdleInfo, "View information about the Idle ability.");

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer::GoAwayFromKeyboard");
	g_hSDKIdlePlayer = EndPrepSDKCall();

	if (g_hSDKIdlePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer::GoAwayFromKeyboard\" signature is outdated.", ST_TAG);
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "SetHumanSpec");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	g_hSDKSpecPlayer = EndPrepSDKCall();

	if (g_hSDKSpecPlayer == null)
	{
		PrintToServer("%s Your \"SetHumanSpec\" signature is outdated.", ST_TAG);
	}

	delete gdSuperTanks;

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

	vRemoveIdle(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdIdleInfo(int client, int args)
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
		case false: vIdleMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vIdleMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iIdleMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Idle Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iIdleMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iIdleAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iIdleCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "IdleDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vIdleMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "IdleMenu", param1);
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

public void ST_OnDisplayMenu(Menu menu)
{
	menu.AddItem(ST_MENU_IDLE, ST_MENU_IDLE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_IDLE, false))
	{
		vIdleMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iIdleHitMode[ST_GetTankType(attacker)] == 0 || g_iIdleHitMode[ST_GetTankType(attacker)] == 1) && bIsHumanSurvivor(victim))
		{
			if ((!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || ST_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vIdleHit(victim, attacker, g_flIdleChance[ST_GetTankType(attacker)], g_iIdleHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iIdleHitMode[ST_GetTankType(victim)] == 0 || g_iIdleHitMode[ST_GetTankType(victim)] == 2) && bIsHumanSurvivor(attacker))
		{
			if ((!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || ST_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vIdleHit(attacker, victim, g_flIdleChance[ST_GetTankType(victim)], g_iIdleHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void ST_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
			g_iImmunityFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iImmunityFlags[iIndex] = 0;
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iIdleAbility[iIndex] = 0;
		g_iIdleEffect[iIndex] = 0;
		g_iIdleMessage[iIndex] = 0;
		g_flIdleChance[iIndex] = 33.3;
		g_iIdleHit[iIndex] = 0;
		g_iIdleHitMode[iIndex] = 0;
		g_flIdleRange[iIndex] = 150.0;
		g_flIdleRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "idleability", false) || StrEqual(subsection, "idle ability", false) || StrEqual(subsection, "idle_ability", false) || StrEqual(subsection, "idle", false))
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
		ST_FindAbility(type, 28, bHasAbilities(subsection, "idleability", "idle ability", "idle_ability", "idle"));
		g_iHumanAbility[type] = iGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iIdleAbility[type] = iGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iIdleAbility[type], value, 0, 1);
		g_iIdleEffect[type] = iGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iIdleEffect[type], value, 0, 7);
		g_iIdleMessage[type] = iGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iIdleMessage[type], value, 0, 7);
		g_flIdleChance[type] = flGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "IdleChance", "Idle Chance", "Idle_Chance", "chance", g_flIdleChance[type], value, 0.0, 100.0);
		g_iIdleHit[type] = iGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "IdleHit", "Idle Hit", "Idle_Hit", "hit", g_iIdleHit[type], value, 0, 1);
		g_iIdleHitMode[type] = iGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "IdleHitMode", "Idle Hit Mode", "Idle_Hit_Mode", "hitmode", g_iIdleHitMode[type], value, 0, 2);
		g_flIdleRange[type] = flGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "IdleRange", "Idle Range", "Idle_Range", "range", g_flIdleRange[type], value, 1.0, 9999999999.0);
		g_flIdleRangeChance[type] = flGetValue(subsection, "idleability", "idle ability", "idle_ability", "idle", key, "IdleRangeChance", "Idle Range Chance", "Idle_Range_Chance", "rangechance", g_flIdleRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "idleability", false) || StrEqual(subsection, "idle ability", false) || StrEqual(subsection, "idle_ability", false) || StrEqual(subsection, "idle", false))
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

public void ST_OnHookEvent(bool mode)
{
	switch (mode)
	{
		case true: HookEvent("player_afk", ST_OnEventFired, EventHookMode_Pre);
		case false: UnhookEvent("player_afk", ST_OnEventFired, EventHookMode_Pre);
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_afk"))
	{
		int iIdlerId = event.GetInt("player"), iIdler = GetClientOfUserId(iIdlerId);
		g_bIdled[iIdler] = true;
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iSurvivorId = event.GetInt("player"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsIdlePlayer(iBot, iSurvivor)) 
		{
			DataPack dpIdleFix;
			CreateDataTimer(0.2, tTimerIdleFix, dpIdleFix, TIMER_FLAG_NO_MAPCHANGE);
			dpIdleFix.WriteCell(iSurvivorId);
			dpIdleFix.WriteCell(iBotId);

			if (g_bIdle[iSurvivor])
			{
				g_bIdle[iSurvivor] = false;
			}
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveIdle(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iIdleAbility[ST_GetTankType(tank)] == 1)
	{
		vIdleAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iIdleAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bIdle2[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "IdleHuman3");
					case false: vIdleAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveIdle(tank);
}

static void vIdleAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iIdleCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bIdle3[tank] = false;
		g_bIdle4[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !ST_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_flIdleRange[ST_GetTankType(tank)])
				{
					vIdleHit(iSurvivor, tank, g_flIdleRangeChance[ST_GetTankType(tank)], g_iIdleAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "IdleHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "IdleAmmo");
	}
}

static void vIdleHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsHumanSurvivor(survivor))
	{
		if (g_iIdleCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bIdle[survivor])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bIdle2[tank])
				{
					g_bIdle2[tank] = true;
					g_iIdleCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "IdleHuman", g_iIdleCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);

					if (g_iIdleCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
					{
						CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bIdle2[tank] = false;
					}
				}

				switch (iGetHumanCount() > 1)
				{
					case true: FakeClientCommand(survivor, "go_away_from_keyboard");
					case false: SDKCall(g_hSDKIdlePlayer, survivor);
				}

				if (bIsBotIdle(survivor))
				{
					g_bIdle[survivor] = true;
					g_bIdled[survivor] = true;

					vEffect(survivor, tank, g_iIdleEffect[ST_GetTankType(tank)], flags);

					if (g_iIdleMessage[ST_GetTankType(tank)] & messages)
					{
						char sTankName[33];
						ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Idle", sTankName, survivor);
					}
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bIdle2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bIdle3[tank])
				{
					g_bIdle3[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "IdleHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bIdle4[tank])
		{
			g_bIdle4[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "IdleAmmo");
		}
	}
}

static void vRemoveIdle(int tank)
{
	g_bIdle[tank] = false;
	g_bIdle2[tank] = false;
	g_bIdle3[tank] = false;
	g_bIdle4[tank] = false;
	g_bIdled[tank] = false;
	g_iIdleCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveIdle(iPlayer);
		}
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, ST_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[ST_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iAbilityFlags))
		{
			return false;
		}
	}

	int iTypeFlags = ST_GetAccessFlags(2, ST_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iTypeFlags))
		{
			return false;
		}
	}

	int iGlobalFlags = ST_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iGlobalFlags))
		{
			return false;
		}
	}

	int iClientTypeFlags = ST_GetAccessFlags(4, ST_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientTypeFlags & iAbilityFlags))
		{
			return false;
		}
	}

	int iClientGlobalFlags = ST_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientGlobalFlags & iAbilityFlags))
		{
			return false;
		}
	}

	return true;
}

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, ST_CHECK_FAKECLIENT))
	{
		return false;
	}

	int iAbilityFlags = g_iImmunityFlags[ST_GetTankType(survivor)];
	if (iAbilityFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iAbilityFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iTypeFlags = ST_GetImmunityFlags(2, ST_GetTankType(survivor));
	if (iTypeFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iTypeFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iGlobalFlags = ST_GetImmunityFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iGlobalFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iClientTypeFlags = ST_GetImmunityFlags(4, ST_GetTankType(tank), survivor),
		iClientTypeFlags2 = ST_GetImmunityFlags(4, ST_GetTankType(tank), tank);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
		{
			return ((iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
		}
	}

	int iClientGlobalFlags = ST_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = ST_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
		{
			return ((iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
		}
	}

	return false;
}

public Action tTimerIdleFix(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell()), iBot = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsValidClient(iSurvivor, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) || !bIsValidClient(iBot, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) || !g_bIdled[iSurvivor])
	{
		return Plugin_Stop;
	}

	if (!bIsValidClient(iSurvivor, ST_CHECK_FAKECLIENT) || GetClientTeam(iSurvivor) != 1 || iGetIdleBot(iSurvivor))
	{
		g_bIdled[iSurvivor] = false;
	}

	if (!bIsBotIdleSurvivor(iBot) || GetClientTeam(iBot) != 2)
	{
		iBot = iGetBotSurvivor();
	}

	if (iBot < 1)
	{
		g_bIdled[iSurvivor] = false;
	}

	if (g_bIdled[iSurvivor])
	{
		g_bIdled[iSurvivor] = false;

		SDKCall(g_hSDKSpecPlayer, iBot, iSurvivor);

		SetEntProp(iSurvivor, Prop_Send, "m_iObserverMode", 5);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bIdle2[iTank])
	{
		g_bIdle2[iTank] = false;

		return Plugin_Stop;
	}

	g_bIdle2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "IdleHuman5");

	return Plugin_Continue;
}