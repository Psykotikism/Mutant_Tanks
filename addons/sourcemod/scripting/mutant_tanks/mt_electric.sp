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
#include <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Electric Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank electrocutes survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Electric Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"

#define MT_MENU_ELECTRIC "Electric Ability"

bool g_bCloneInstalled, g_bElectric[MAXPLAYERS + 1], g_bElectric2[MAXPLAYERS + 1], g_bElectric3[MAXPLAYERS + 1], g_bElectric4[MAXPLAYERS + 1], g_bElectric5[MAXPLAYERS + 1];

float g_flElectricChance[MT_MAXTYPES + 1], g_flElectricDamage[MT_MAXTYPES + 1], g_flElectricDuration[MT_MAXTYPES + 1], g_flElectricInterval[MT_MAXTYPES + 1], g_flElectricRange[MT_MAXTYPES + 1], g_flElectricRangeChance[MT_MAXTYPES + 1], g_flHumanCooldown[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iElectricAbility[MT_MAXTYPES + 1], g_iElectricCount[MAXPLAYERS + 1], g_iElectricEffect[MT_MAXTYPES + 1], g_iElectricHit[MT_MAXTYPES + 1], g_iElectricHitMode[MT_MAXTYPES + 1], g_iElectricMessage[MT_MAXTYPES + 1], g_iElectricOwner[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_mt_electric", cmdElectricInfo, "View information about the Electric ability.");

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
	vPrecacheParticle(PARTICLE_ELECTRICITY);

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);

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

public Action cmdElectricInfo(int client, int args)
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
		case false: vElectricMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vElectricMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iElectricMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Electric Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iElectricMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iElectricAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iElectricCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ElectricDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flElectricDuration[MT_GetTankType(param1)]);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vElectricMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ElectricMenu", param1);
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
	menu.AddItem(MT_MENU_ELECTRIC, MT_MENU_ELECTRIC);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ELECTRIC, false))
	{
		vElectricMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iElectricHitMode[MT_GetTankType(attacker)] == 0 || g_iElectricHitMode[MT_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vElectricHit(victim, attacker, g_flElectricChance[MT_GetTankType(attacker)], g_iElectricHit[MT_GetTankType(attacker)], MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iElectricHitMode[MT_GetTankType(victim)] == 0 || g_iElectricHitMode[MT_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vElectricHit(attacker, victim, g_flElectricChance[MT_GetTankType(victim)], g_iElectricHit[MT_GetTankType(victim)], MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnConfigsLoad(int mode)
{
	if (mode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				g_iAccessFlags2[iPlayer] = 0;
				g_iImmunityFlags2[iPlayer] = 0;
			}
		}
	}
	else if (mode == 1)
	{
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			g_iAccessFlags[iIndex] = 0;
			g_iImmunityFlags[iIndex] = 0;
			g_iHumanAbility[iIndex] = 0;
			g_iHumanAmmo[iIndex] = 5;
			g_flHumanCooldown[iIndex] = 30.0;
			g_iElectricAbility[iIndex] = 0;
			g_iElectricEffect[iIndex] = 0;
			g_iElectricMessage[iIndex] = 0;
			g_flElectricChance[iIndex] = 33.3;
			g_flElectricDamage[iIndex] = 1.0;
			g_flElectricDuration[iIndex] = 5.0;
			g_iElectricHit[iIndex] = 0;
			g_iElectricHitMode[iIndex] = 0;
			g_flElectricInterval[iIndex] = 1.0;
			g_flElectricRange[iIndex] = 150.0;
			g_flElectricRangeChance[iIndex] = 15.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "electricability", false) || StrEqual(subsection, "electric ability", false) || StrEqual(subsection, "electric_ability", false) || StrEqual(subsection, "electric", false))
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

	if (mode < 3 && type > 0)
	{
		g_iHumanAbility[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 999999.0);
		g_iElectricAbility[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iElectricAbility[type], value, 0, 1);
		g_iElectricEffect[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iElectricEffect[type], value, 0, 7);
		g_iElectricMessage[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iElectricMessage[type], value, 0, 3);
		g_flElectricChance[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricChance", "Electric Chance", "Electric_Chance", "chance", g_flElectricChance[type], value, 0.0, 100.0);
		g_flElectricDamage[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricDamage", "Electric Damage", "Electric_Damage", "damage", g_flElectricDamage[type], value, 1.0, 999999.0);
		g_flElectricDuration[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricDuration", "Electric Duration", "Electric_Duration", "duration", g_flElectricDuration[type], value, 0.1, 999999.0);
		g_iElectricHit[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricHit", "Electric Hit", "Electric_Hit", "hit", g_iElectricHit[type], value, 0, 1);
		g_iElectricHitMode[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricHitMode", "Electric Hit Mode", "Electric_Hit_Mode", "hitmode", g_iElectricHitMode[type], value, 0, 2);
		g_flElectricInterval[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricInterval", "Electric Interval", "Electric_Interval", "interval", g_flElectricInterval[type], value, 0.1, 999999.0);
		g_flElectricRange[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricRange", "Electric Range", "Electric_Range", "range", g_flElectricRange[type], value, 1.0, 999999.0);
		g_flElectricRangeChance[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricRangeChance", "Electric Range Chance", "Electric_Range_Chance", "rangechance", g_flElectricRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "electricability", false) || StrEqual(subsection, "electric ability", false) || StrEqual(subsection, "electric_ability", false) || StrEqual(subsection, "electric", false))
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

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iElectricAbility[MT_GetTankType(iTank)] == 1)
			{
				if (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank))
				{
					vAttachParticle(iTank, PARTICLE_ELECTRICITY, 2.0, 30.0);
				}
			}

			vRemoveElectric(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iElectricAbility[MT_GetTankType(tank)] == 1)
	{
		vElectricAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if (g_iElectricAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (!g_bElectric2[tank] && !g_bElectric3[tank])
				{
					vElectricAbility(tank);
				}
				else if (g_bElectric2[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman3");
				}
				else if (g_bElectric3[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman4");
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveElectric(tank);
}

static void vElectricAbility(int tank)
{
	if (g_iElectricCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		g_bElectric4[tank] = false;
		g_bElectric5[tank] = false;

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
				if (flDistance <= g_flElectricRange[MT_GetTankType(tank)])
				{
					vElectricHit(iSurvivor, tank, g_flElectricRangeChance[MT_GetTankType(tank)], g_iElectricAbility[MT_GetTankType(tank)], MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman5");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricAmmo");
	}
}

static void vElectricHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iElectricCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bElectric[survivor])
			{
				g_bElectric[survivor] = true;
				g_iElectricOwner[survivor] = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && (flags & MT_ATTACK_RANGE) && !g_bElectric2[tank])
				{
					g_bElectric2[tank] = true;
					g_iElectricCount[tank]++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman", g_iElectricCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
				}

				DataPack dpElectric;
				CreateDataTimer(g_flElectricInterval[MT_GetTankType(tank)], tTimerElectric, dpElectric, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpElectric.WriteCell(GetClientUserId(survivor));
				dpElectric.WriteCell(GetClientUserId(tank));
				dpElectric.WriteCell(MT_GetTankType(tank));
				dpElectric.WriteCell(messages);
				dpElectric.WriteCell(enabled);
				dpElectric.WriteFloat(GetEngineTime());

				vAttachParticle(survivor, PARTICLE_ELECTRICITY, 2.0, 30.0);

				vEffect(survivor, tank, g_iElectricEffect[MT_GetTankType(tank)], flags);

				if (g_iElectricMessage[MT_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Electric", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_bElectric2[tank])
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bElectric4[tank])
				{
					g_bElectric4[tank] = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bElectric5[tank])
		{
			g_bElectric5[tank] = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricAmmo");
		}
	}
}

static void vRemoveElectric(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_bElectric[iSurvivor] && g_iElectricOwner[iSurvivor] == tank)
		{
			g_bElectric[iSurvivor] = false;
			g_iElectricOwner[iSurvivor] = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset3(iPlayer);

			g_iElectricOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bElectric[survivor] = false;
	g_iElectricOwner[survivor] = 0;

	if (g_iElectricMessage[MT_GetTankType(tank)] & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Electric2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bElectric[tank] = false;
	g_bElectric2[tank] = false;
	g_bElectric3[tank] = false;
	g_bElectric4[tank] = false;
	g_bElectric5[tank] = false;
	g_iElectricCount[tank] = 0;
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

public Action tTimerElectric(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bElectric[iSurvivor] = false;
		g_iElectricOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || !MT_HasAdminAccess(iTank) || !bHasAdminAccess(iTank) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, iTank) || !g_bElectric[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iElectricEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iElectricEnabled == 0 || (flTime + g_flElectricDuration[MT_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bElectric2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && (iMessage & MT_MESSAGE_RANGE) && !g_bElectric3[iTank])
		{
			g_bElectric3[iTank] = true;

			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ElectricHuman6");

			if (g_iElectricCount[iTank] < g_iHumanAmmo[MT_GetTankType(iTank)] && g_iHumanAmmo[MT_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[MT_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bElectric3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	vDamageEntity(iSurvivor, iTank, g_flElectricDamage[MT_GetTankType(iTank)], "256");

	vAttachParticle(iSurvivor, PARTICLE_ELECTRICITY, 2.0, 30.0);

	switch (GetRandomInt(1, 2))
	{
		case 1: EmitSoundToAll(SOUND_ELECTRICITY, iSurvivor);
		case 2: EmitSoundToAll(SOUND_ELECTRICITY2, iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bElectric3[iTank])
	{
		g_bElectric3[iTank] = false;

		return Plugin_Stop;
	}

	g_bElectric3[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ElectricHuman7");

	return Plugin_Continue;
}