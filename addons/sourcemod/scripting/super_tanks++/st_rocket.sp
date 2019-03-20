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
	name = "[ST++] Rocket Ability",
	author = ST_AUTHOR,
	description = "The Super Tank sends survivors into space.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Rocket Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SPRITE_FIRE "sprites/sprite_fire01.vmt"

#define SOUND_EXPLOSION "ambient/explosions/exp2.wav"
#define SOUND_FIRE "weapons/rpg/rocketfire1.wav"
#define SOUND_LAUNCH "npc/env_headcrabcanister/launch.wav"

#define ST_MENU_ROCKET "Rocket Ability"

bool g_bCloneInstalled, g_bRocket[MAXPLAYERS + 1], g_bRocket2[MAXPLAYERS + 1], g_bRocket3[MAXPLAYERS + 1], g_bRocket4[MAXPLAYERS + 1], g_bRocket5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flRocketChance[ST_MAXTYPES + 1], g_flRocketDelay[ST_MAXTYPES + 1], g_flRocketRange[ST_MAXTYPES + 1], g_flRocketRangeChance[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iRocketAbility[ST_MAXTYPES + 1], g_iRocketCount[MAXPLAYERS + 1], g_iRocketEffect[ST_MAXTYPES + 1], g_iRocketHit[ST_MAXTYPES + 1], g_iRocketHitMode[ST_MAXTYPES + 1], g_iRocketMessage[ST_MAXTYPES + 1], g_iRocketOwner[MAXPLAYERS + 1], g_iRocketSprite = -1;

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

	RegConsoleCmd("sm_st_rocket", cmdRocketInfo, "View information about the Rocket ability.");

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
	g_iRocketSprite = PrecacheModel(SPRITE_FIRE, true);

	PrecacheSound(SOUND_EXPLOSION, true);
	PrecacheSound(SOUND_FIRE, true);
	PrecacheSound(SOUND_LAUNCH, true);

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

public Action cmdRocketInfo(int client, int args)
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
		case false: vRocketMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRocketMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRocketMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Rocket Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRocketMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iRocketAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iRocketCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "RocketDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vRocketMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "RocketMenu", param1);
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
	menu.AddItem(ST_MENU_ROCKET, ST_MENU_ROCKET);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ROCKET, false))
	{
		vRocketMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iRocketHitMode[ST_GetTankType(attacker)] == 0 || g_iRocketHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || ST_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRocketHit(victim, attacker, g_flRocketChance[ST_GetTankType(attacker)], g_iRocketHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iRocketHitMode[ST_GetTankType(victim)] == 0 || g_iRocketHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || ST_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRocketHit(attacker, victim, g_flRocketChance[ST_GetTankType(victim)], g_iRocketHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iRocketAbility[iIndex] = 0;
		g_iRocketEffect[iIndex] = 0;
		g_iRocketMessage[iIndex] = 0;
		g_flRocketChance[iIndex] = 33.3;
		g_flRocketDelay[iIndex] = 1.0;
		g_iRocketHit[iIndex] = 0;
		g_iRocketHitMode[iIndex] = 0;
		g_flRocketRange[iIndex] = 150.0;
		g_flRocketRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "rocketability", false) || StrEqual(subsection, "rocket ability", false) || StrEqual(subsection, "rocket_ability", false) || StrEqual(subsection, "rocket", false))
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
		ST_FindAbility(type, 51, bHasAbilities(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket"));
		g_iHumanAbility[type] = iGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iRocketAbility[type] = iGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iRocketAbility[type], value, 0, 1);
		g_iRocketEffect[type] = iGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iRocketEffect[type], value, 0, 7);
		g_iRocketMessage[type] = iGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iRocketMessage[type], value, 0, 3);
		g_flRocketChance[type] = flGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketChance", "Rocket Chance", "Rocket_Chance", "chance", g_flRocketChance[type], value, 0.0, 100.0);
		g_flRocketDelay[type] = flGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketDelay", "Rocket Delay", "Rocket_Delay", "delay", g_flRocketDelay[type], value, 0.1, 9999999999.0);
		g_iRocketHit[type] = iGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketHit", "Rocket Hit", "Rocket_Hit", "hit", g_iRocketHit[type], value, 0, 1);
		g_iRocketHitMode[type] = iGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketHitMode", "Rocket Hit Mode", "Rocket_Hit_Mode", "hitmode", g_iRocketHitMode[type], value, 0, 2);
		g_flRocketRange[type] = flGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketRange", "Rocket Range", "Rocket_Range", "range", g_flRocketRange[type], value, 1.0, 9999999999.0);
		g_flRocketRangeChance[type] = flGetValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketRangeChance", "Rocket Range Chance", "Rocket_Range_Chance", "rangechance", g_flRocketRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "rocketability", false) || StrEqual(subsection, "rocket ability", false) || StrEqual(subsection, "rocket_ability", false) || StrEqual(subsection, "rocket", false))
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

public void ST_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bRocket[iSurvivor])
		{
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
			vRemoveRocket(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iRocketAbility[ST_GetTankType(tank)] == 1)
	{
		vRocketAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iRocketAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bRocket2[tank] && !g_bRocket3[tank])
				{
					vRocketAbility(tank);
				}
				else if (g_bRocket2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RocketHuman3");
				}
				else if (g_bRocket3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RocketHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveRocket(tank);
}

static void vRemoveRocket(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bRocket[iSurvivor] && g_iRocketOwner[iSurvivor] == tank)
		{
			g_bRocket[iSurvivor] = false;
			g_iRocketOwner[iSurvivor] = 0;
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

			g_iRocketOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor)
{
	g_bRocket[survivor] = false;
	g_iRocketOwner[survivor] = 0;

	SetEntityGravity(survivor, 1.0);
}

static void vReset3(int tank)
{
	g_bRocket[tank] = false;
	g_bRocket2[tank] = false;
	g_bRocket3[tank] = false;
	g_bRocket4[tank] = false;
	g_bRocket5[tank] = false;
	g_iRocketCount[tank] = 0;
}

static void vRocketAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iRocketCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bRocket4[tank] = false;
		g_bRocket5[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !ST_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_flRocketRange[ST_GetTankType(tank)])
				{
					vRocketHit(iSurvivor, tank, g_flRocketRangeChance[ST_GetTankType(tank)], g_iRocketAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "RocketHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "RocketAmmo");
	}
}

static void vRocketHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iRocketCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bRocket[survivor])
			{
				int iFlame = CreateEntityByName("env_steam");
				if (!bIsValidEntity(iFlame))
				{
					return;
				}

				g_bRocket[survivor] = true;
				g_iRocketOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bRocket2[tank])
				{
					g_bRocket2[tank] = true;
					g_iRocketCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RocketHuman", g_iRocketCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				float flPosition[3], flAngles[3];
				GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flPosition);
				flPosition[2] += 30.0;
				flAngles[0] = 90.0;
				flAngles[1] = 0.0;
				flAngles[2] = 0.0;

				DispatchKeyValue(iFlame, "spawnflags", "1");
				DispatchKeyValue(iFlame, "Type", "0");
				DispatchKeyValue(iFlame, "InitialState", "1");
				DispatchKeyValue(iFlame, "Spreadspeed", "10");
				DispatchKeyValue(iFlame, "Speed", "800");
				DispatchKeyValue(iFlame, "Startsize", "10");
				DispatchKeyValue(iFlame, "EndSize", "250");
				DispatchKeyValue(iFlame, "Rate", "15");
				DispatchKeyValue(iFlame, "JetLength", "400");

				SetEntityRenderColor(iFlame, 180, 70, 10, 180);

				TeleportEntity(iFlame, flPosition, flAngles, NULL_VECTOR);
				DispatchSpawn(iFlame);
				vSetEntityParent(iFlame, survivor);

				iFlame = EntIndexToEntRef(iFlame);
				vDeleteEntity(iFlame, 3.0);

				EmitSoundToAll(SOUND_FIRE, survivor, _, _, _, 1.0);

				DataPack dpRocketLaunch;
				CreateDataTimer(g_flRocketDelay[ST_GetTankType(tank)], tTimerRocketLaunch, dpRocketLaunch, TIMER_FLAG_NO_MAPCHANGE);
				dpRocketLaunch.WriteCell(GetClientUserId(survivor));
				dpRocketLaunch.WriteCell(GetClientUserId(tank));
				dpRocketLaunch.WriteCell(ST_GetTankType(tank));
				dpRocketLaunch.WriteCell(enabled);

				DataPack dpRocketDetonate;
				CreateDataTimer(g_flRocketDelay[ST_GetTankType(tank)] + 1.5, tTimerRocketDetonate, dpRocketDetonate, TIMER_FLAG_NO_MAPCHANGE);
				dpRocketDetonate.WriteCell(GetClientUserId(survivor));
				dpRocketDetonate.WriteCell(GetClientUserId(tank));
				dpRocketDetonate.WriteCell(ST_GetTankType(tank));
				dpRocketDetonate.WriteCell(enabled);
				dpRocketDetonate.WriteCell(messages);

				vEffect(survivor, tank, g_iRocketEffect[ST_GetTankType(tank)], flags);
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bRocket2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bRocket4[tank])
				{
					g_bRocket4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RocketHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bRocket5[tank])
		{
			g_bRocket5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "RocketAmmo");
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

public Action tTimerRocketLaunch(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bRocket[iSurvivor] = false;
		g_iRocketOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iRocketEnabled = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || ST_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, iTank) || iRocketEnabled == 0 || !g_bRocket[iSurvivor])
	{
		g_bRocket2[iTank] = false;

		vReset2(iSurvivor);

		return Plugin_Stop;
	}

	float flVelocity[3];
	flVelocity[0] = 0.0;
	flVelocity[1] = 0.0;
	flVelocity[2] = 800.0;

	EmitSoundToAll(SOUND_EXPLOSION, iSurvivor, _, _, _, 1.0);
	EmitSoundToAll(SOUND_LAUNCH, iSurvivor, _, _, _, 1.0);

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityGravity(iSurvivor, 0.1);

	return Plugin_Continue;
}

public Action tTimerRocketDetonate(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bRocket[iSurvivor] = false;
		g_iRocketOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iRocketEnabled = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || ST_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, iTank) || iRocketEnabled == 0 || !g_bRocket[iSurvivor])
	{
		g_bRocket2[iTank] = false;

		vReset2(iSurvivor);

		return Plugin_Stop;
	}

	float flPosition[3];
	GetClientAbsOrigin(iSurvivor, flPosition);

	TE_SetupExplosion(flPosition, g_iRocketSprite, 10.0, 1, 0, 600, 5000);
	TE_SendToAll();

	ForcePlayerSuicide(iSurvivor);
	SetEntityGravity(iSurvivor, 1.0);

	int iMessage = pack.ReadCell();
	if (g_iRocketMessage[ST_GetTankType(iTank)] & iMessage)
	{
		char sTankName[33];
		ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Rocket", sTankName, iSurvivor);
	}

	g_bRocket[iSurvivor] = false;
	g_bRocket2[iTank] = false;
	g_iRocketOwner[iSurvivor] = 0;

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bRocket3[iTank])
	{
		g_bRocket3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RocketHuman6");

		if (g_iRocketCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bRocket3[iTank] = false;
		}
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bRocket3[iTank])
	{
		g_bRocket3[iTank] = false;

		return Plugin_Stop;
	}

	g_bRocket3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RocketHuman7");

	return Plugin_Continue;
}