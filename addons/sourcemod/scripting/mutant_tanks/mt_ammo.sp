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
	name = "[MT] Ammo Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank takes away survivors' ammunition.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Ammo Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_AMMO "Ammo Ability"

bool g_bAmmo[MAXPLAYERS + 1], g_bAmmo2[MAXPLAYERS + 1], g_bAmmo3[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flAmmoChance[MT_MAXTYPES + 1], g_flAmmoRange[MT_MAXTYPES + 1], g_flAmmoRangeChance[MT_MAXTYPES + 1], g_flHumanCooldown[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iAmmoAbility[MT_MAXTYPES + 1], g_iAmmoAmount[MT_MAXTYPES + 1], g_iAmmoCount[MAXPLAYERS + 1], g_iAmmoEffect[MT_MAXTYPES + 1], g_iAmmoHit[MT_MAXTYPES + 1], g_iAmmoHitMode[MT_MAXTYPES + 1], g_iAmmoMessage[MT_MAXTYPES + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_mt_ammo", cmdAmmoInfo, "View information about the Ammo ability.");

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

	vRemoveAmmo(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdAmmoInfo(int client, int args)
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
		case false: vAmmoMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vAmmoMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iAmmoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Ammo Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iAmmoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iAmmoAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iAmmoCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AmmoDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				vAmmoMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "AmmoMenu", param1);
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
	menu.AddItem(MT_MENU_AMMO, MT_MENU_AMMO);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_AMMO, false))
	{
		vAmmoMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iAmmoHitMode[MT_GetTankType(attacker)] == 0 || g_iAmmoHitMode[MT_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAmmoHit(victim, attacker, g_flAmmoChance[MT_GetTankType(attacker)], g_iAmmoHit[MT_GetTankType(attacker)], MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iAmmoHitMode[MT_GetTankType(victim)] == 0 || g_iAmmoHitMode[MT_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAmmoHit(attacker, victim, g_flAmmoChance[MT_GetTankType(victim)], g_iAmmoHit[MT_GetTankType(victim)], MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
		g_iAmmoAbility[iIndex] = 0;
		g_iAmmoEffect[iIndex] = 0;
		g_iAmmoMessage[iIndex] = 0;
		g_flAmmoChance[iIndex] = 33.3;
		g_iAmmoAmount[iIndex] = 0;
		g_iAmmoHit[iIndex] = 0;
		g_iAmmoHitMode[iIndex] = 0;
		g_flAmmoRange[iIndex] = 150.0;
		g_flAmmoRangeChance[iIndex] = 15.0;
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "ammoability", false) || StrEqual(subsection, "ammo ability", false) || StrEqual(subsection, "ammo_ability", false) || StrEqual(subsection, "ammo", false))
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
		MT_FindAbility(type, 3, bHasAbilities(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo"));
		g_iHumanAbility[type] = iGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iAmmoAbility[type] = iGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iAmmoAbility[type], value, 0, 1);
		g_iAmmoEffect[type] = iGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iAmmoEffect[type], value, 0, 7);
		g_iAmmoMessage[type] = iGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iAmmoMessage[type], value, 0, 3);
		g_flAmmoChance[type] = flGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoChance", "Ammo Chance", "Ammo_Chance", "chance", g_flAmmoChance[type], value, 0.0, 100.0);
		g_iAmmoAmount[type] = iGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoCount", "Ammo Count", "Ammo_Count", "count", g_iAmmoAmount[type], value, 0, 25);
		g_iAmmoHit[type] = iGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoHit", "Ammo Hit", "Ammo_Hit", "hit", g_iAmmoHit[type], value, 0, 1);
		g_iAmmoHitMode[type] = iGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoHitMode", "Ammo Hit Mode", "Ammo_Hit_Mode", "hitmode", g_iAmmoHitMode[type], value, 0, 2);
		g_flAmmoRange[type] = flGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoRange", "Ammo Range", "Ammo_Range", "range", g_flAmmoRange[type], value, 1.0, 9999999999.0);
		g_flAmmoRangeChance[type] = flGetValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoRangeChance", "Ammo Range Chance", "Ammo_Range_Chance", "rangechance", g_flAmmoRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "ammoability", false) || StrEqual(subsection, "ammo ability", false) || StrEqual(subsection, "ammo_ability", false) || StrEqual(subsection, "ammo", false))
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
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveAmmo(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iAmmoAbility[MT_GetTankType(tank)] == 1)
	{
		vAmmoAbility(tank);
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
			if (g_iAmmoAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_bAmmo[tank])
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman3");
					case false: vAmmoAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveAmmo(tank);
}

static void vAmmoAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iAmmoCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		g_bAmmo2[tank] = false;
		g_bAmmo3[tank] = false;

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
				if (flDistance <= g_flAmmoRange[MT_GetTankType(tank)])
				{
					vAmmoHit(iSurvivor, tank, g_flAmmoRangeChance[MT_GetTankType(tank)], g_iAmmoAbility[MT_GetTankType(tank)], MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoAmmo");
	}
}

static void vAmmoHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && GetPlayerWeaponSlot(survivor, 0) > 0)
	{
		if (g_iAmmoCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && (flags & MT_ATTACK_RANGE) && !g_bAmmo[tank])
				{
					g_bAmmo[tank] = true;
					g_iAmmoCount[tank]++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman", g_iAmmoCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);

					if (g_iAmmoCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
					{
						CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bAmmo[tank] = false;
					}
				}

				char sWeapon[32];
				int iActiveWeapon = GetEntPropEnt(survivor, Prop_Data, "m_hActiveWeapon");
				GetEntityClassname(iActiveWeapon, sWeapon, sizeof(sWeapon));
				if (bIsValidEntity(iActiveWeapon))
				{
					if (StrEqual(sWeapon, "weapon_rifle") || StrEqual(sWeapon, "weapon_rifle_desert") || StrEqual(sWeapon, "weapon_rifle_ak47") || StrEqual(sWeapon, "weapon_rifle_sg552"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 3);
					}
					else if (StrEqual(sWeapon, "weapon_smg") || StrEqual(sWeapon, "weapon_smg_silenced") || StrEqual(sWeapon, "weapon_smg_mp5"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 5);
					}
					else if (StrEqual(sWeapon, "weapon_pumpshotgun"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 7);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 6);
						}
					}
					else if (StrEqual(sWeapon, "weapon_shotgun_chrome"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 7);
					}
					else if (StrEqual(sWeapon, "weapon_autoshotgun"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 8);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 6);
						}
					}
					else if (StrEqual(sWeapon, "weapon_shotgun_spas"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 8);
					}
					else if (StrEqual(sWeapon, "weapon_hunting_rifle"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 9);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 2);
						}
					}
					else if (StrEqual(sWeapon, "weapon_sniper_scout") || StrEqual(sWeapon, "weapon_sniper_military") || StrEqual(sWeapon, "weapon_sniper_awp"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 10);
					}
					else if (StrEqual(sWeapon, "weapon_grenade_launcher"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[MT_GetTankType(tank)], _, 17);
					}
				}

				SetEntProp(GetPlayerWeaponSlot(survivor, 0), Prop_Data, "m_iClip1", g_iAmmoAmount[MT_GetTankType(tank)], 1);

				vEffect(survivor, tank, g_iAmmoEffect[MT_GetTankType(tank)], flags);

				if (g_iAmmoMessage[MT_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Ammo", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_bAmmo[tank])
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bAmmo2[tank])
				{
					g_bAmmo2[tank] = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bAmmo3[tank])
		{
			g_bAmmo3[tank] = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoAmmo");
		}
	}
}

static void vRemoveAmmo(int tank)
{
	g_bAmmo[tank] = false;
	g_bAmmo2[tank] = false;
	g_bAmmo3[tank] = false;
	g_iAmmoCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveAmmo(iPlayer);
		}
	}
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
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iAbilityFlags))
		{
			return false;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iTypeFlags))
		{
			return false;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iGlobalFlags))
		{
			return false;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientTypeFlags & iAbilityFlags))
		{
			return false;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
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

	return false;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bAmmo[iTank])
	{
		g_bAmmo[iTank] = false;

		return Plugin_Stop;
	}

	g_bAmmo[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "AmmoHuman5");

	return Plugin_Continue;
}