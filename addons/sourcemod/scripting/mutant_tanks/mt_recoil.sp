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
	name = "[MT] Recoil Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank gives survivors strong gun recoil.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Recoil Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_RECOIL "Recoil Ability"

bool g_bCloneInstalled, g_bRecoil[MAXPLAYERS + 1], g_bRecoil2[MAXPLAYERS + 1], g_bRecoil3[MAXPLAYERS + 1], g_bRecoil4[MAXPLAYERS + 1], g_bRecoil5[MAXPLAYERS + 1];

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flRecoilChance[MT_MAXTYPES + 1], g_flRecoilDuration[MT_MAXTYPES + 1], g_flRecoilRange[MT_MAXTYPES + 1], g_flRecoilRangeChance[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iRecoilAbility[MT_MAXTYPES + 1], g_iRecoilCount[MAXPLAYERS + 1], g_iRecoilEffect[MT_MAXTYPES + 1], g_iRecoilHit[MT_MAXTYPES + 1], g_iRecoilHitMode[MT_MAXTYPES + 1], g_iRecoilMessage[MT_MAXTYPES + 1], g_iRecoilOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_mt_recoil", cmdRecoilInfo, "View information about the Recoil ability.");

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

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRecoilInfo(int client, int args)
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
		case false: vRecoilMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRecoilMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRecoilMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Recoil Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRecoilMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iRecoilAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iRecoilCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RecoilDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flRecoilDuration[MT_GetTankType(param1)]);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				vRecoilMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "RecoilMenu", param1);
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
	menu.AddItem(MT_MENU_RECOIL, MT_MENU_RECOIL);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_RECOIL, false))
	{
		vRecoilMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iRecoilHitMode[MT_GetTankType(attacker)] == 0 || g_iRecoilHitMode[MT_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRecoilHit(victim, attacker, g_flRecoilChance[MT_GetTankType(attacker)], g_iRecoilHit[MT_GetTankType(attacker)], MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iRecoilHitMode[MT_GetTankType(victim)] == 0 || g_iRecoilHitMode[MT_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRecoilHit(attacker, victim, g_flRecoilChance[MT_GetTankType(victim)], g_iRecoilHit[MT_GetTankType(victim)], MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
		g_iRecoilAbility[iIndex] = 0;
		g_iRecoilEffect[iIndex] = 0;
		g_iRecoilMessage[iIndex] = 0;
		g_flRecoilChance[iIndex] = 33.3;
		g_flRecoilDuration[iIndex] = 5.0;
		g_iRecoilHit[iIndex] = 0;
		g_iRecoilHitMode[iIndex] = 0;
		g_flRecoilRange[iIndex] = 150.0;
		g_flRecoilRangeChance[iIndex] = 15.0;
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "recoilability", false) || StrEqual(subsection, "recoil ability", false) || StrEqual(subsection, "recoil_ability", false) || StrEqual(subsection, "recoil", false))
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
		g_iHumanAbility[type] = iGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iRecoilAbility[type] = iGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iRecoilAbility[type], value, 0, 1);
		g_iRecoilEffect[type] = iGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iRecoilEffect[type], value, 0, 7);
		g_iRecoilMessage[type] = iGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iRecoilMessage[type], value, 0, 3);
		g_flRecoilChance[type] = flGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "RecoilChance", "Recoil Chance", "Recoil_Chance", "chance", g_flRecoilChance[type], value, 0.0, 100.0);
		g_flRecoilDuration[type] = flGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "RecoilDuration", "Recoil Duration", "Recoil_Duration", "duration", g_flRecoilDuration[type], value, 0.1, 9999999999.0);
		g_iRecoilHit[type] = iGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "RecoilHit", "Recoil Hit", "Recoil_Hit", "hit", g_iRecoilHit[type], value, 0, 1);
		g_iRecoilHitMode[type] = iGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "RecoilHitMode", "Recoil Hit Mode", "Recoil_Hit_Mode", "hitmode", g_iRecoilHitMode[type], value, 0, 2);
		g_flRecoilRange[type] = flGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "RecoilRange", "Recoil Range", "Recoil_Range", "range", g_flRecoilRange[type], value, 1.0, 9999999999.0);
		g_flRecoilRangeChance[type] = flGetValue(subsection, "recoilability", "recoil ability", "recoil_ability", "recoil", key, "RecoilRangeChance", "Recoil Range Chance", "Recoil_Range_Chance", "rangechance", g_flRecoilRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "recoilability", false) || StrEqual(subsection, "recoil ability", false) || StrEqual(subsection, "recoil_ability", false) || StrEqual(subsection, "recoil", false))
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

public void MT_OnHookEvent(bool mode)
{
	switch (mode)
	{
		case true: HookEvent("weapon_fire", MT_OnEventFired);
		case false: UnhookEvent("weapon_fire", MT_OnEventFired);
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveRecoil(iTank);
		}
	}
	else if (StrEqual(name, "weapon_fire"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor) && bIsGunWeapon(iSurvivor) && g_bRecoil[iSurvivor])
		{
			float flRecoil[3];
			flRecoil[0] = GetRandomFloat(-20.0, -80.0);
			flRecoil[1] = GetRandomFloat(-25.0, 25.0);
			flRecoil[2] = GetRandomFloat(-25.0, 25.0);
			SetEntPropVector(iSurvivor, Prop_Send, "m_vecPunchAngle", flRecoil);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iRecoilAbility[MT_GetTankType(tank)] == 1)
	{
		vRecoilAbility(tank);
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
			if (g_iRecoilAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (!g_bRecoil2[tank] && !g_bRecoil3[tank])
				{
					vRecoilAbility(tank);
				}
				else if (g_bRecoil2[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecoilHuman3");
				}
				else if (g_bRecoil3[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecoilHuman4");
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveRecoil(tank);
}

static void vRecoilAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iRecoilCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		g_bRecoil4[tank] = false;
		g_bRecoil5[tank] = false;

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
				if (flDistance <= g_flRecoilRange[MT_GetTankType(tank)])
				{
					vRecoilHit(iSurvivor, tank, g_flRecoilRangeChance[MT_GetTankType(tank)], g_iRecoilAbility[MT_GetTankType(tank)], MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecoilHuman5");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecoilAmmo");
	}
}

static void vRecoilHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iRecoilCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bRecoil[survivor])
			{
				g_bRecoil[survivor] = true;
				g_iRecoilOwner[survivor] = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && (flags & MT_ATTACK_RANGE) && !g_bRecoil2[tank])
				{
					g_bRecoil2[tank] = true;
					g_iRecoilCount[tank]++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecoilHuman", g_iRecoilCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
				}

				DataPack dpStopRecoil;
				CreateDataTimer(g_flRecoilDuration[MT_GetTankType(tank)], tTimerStopRecoil, dpStopRecoil, TIMER_FLAG_NO_MAPCHANGE);
				dpStopRecoil.WriteCell(GetClientUserId(survivor));
				dpStopRecoil.WriteCell(GetClientUserId(tank));
				dpStopRecoil.WriteCell(messages);

				vEffect(survivor, tank, g_iRecoilEffect[MT_GetTankType(tank)], flags);

				if (g_iRecoilMessage[MT_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Recoil", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_bRecoil2[tank])
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bRecoil4[tank])
				{
					g_bRecoil4[tank] = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecoilHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bRecoil5[tank])
		{
			g_bRecoil5[tank] = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecoilAmmo");
		}
	}
}

static void vRemoveRecoil(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && g_bRecoil[iSurvivor] && g_iRecoilOwner[iSurvivor] == tank)
		{
			g_bRecoil[iSurvivor] = false;
			g_iRecoilOwner[iSurvivor] = 0;
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vReset2(iPlayer);

			g_iRecoilOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bRecoil[tank] = false;
	g_bRecoil2[tank] = false;
	g_bRecoil3[tank] = false;
	g_bRecoil4[tank] = false;
	g_bRecoil5[tank] = false;
	g_iRecoilCount[tank] = 0;
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

public Action tTimerStopRecoil(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor) || !g_bRecoil[iSurvivor])
	{
		g_bRecoil[iSurvivor] = false;
		g_iRecoilOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bRecoil[iSurvivor] = false;
		g_iRecoilOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bRecoil[iSurvivor] = false;
	g_bRecoil2[iTank] = false;
	g_iRecoilOwner[iSurvivor] = 0;

	int iMessage = pack.ReadCell();

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && (iMessage & MT_MESSAGE_RANGE) && !g_bRecoil3[iTank])
	{
		g_bRecoil3[iTank] = true;

		MT_PrintToChat(iTank, "%s %t", MT_TAG3, "RecoilHuman6");

		if (g_iRecoilCount[iTank] < g_iHumanAmmo[MT_GetTankType(iTank)] && g_iHumanAmmo[MT_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[MT_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bRecoil3[iTank] = false;
		}
	}

	if (g_iRecoilMessage[MT_GetTankType(iTank)] & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Recoil2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bRecoil3[iTank])
	{
		g_bRecoil3[iTank] = false;

		return Plugin_Stop;
	}

	g_bRecoil3[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "RecoilHuman7");

	return Plugin_Continue;
}