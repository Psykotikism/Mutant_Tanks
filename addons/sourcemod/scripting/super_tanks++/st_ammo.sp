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
	name = "[ST++] Ammo Ability",
	author = ST_AUTHOR,
	description = "The Super Tank takes away survivors' ammunition.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Ammo Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_AMMO "Ammo Ability"

bool g_bAmmo[MAXPLAYERS + 1], g_bAmmo2[MAXPLAYERS + 1], g_bAmmo3[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flAmmoChance[ST_MAXTYPES + 1], g_flAmmoRange[ST_MAXTYPES + 1], g_flAmmoRangeChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iAmmoAbility[ST_MAXTYPES + 1], g_iAmmoAmount[ST_MAXTYPES + 1], g_iAmmoCount[MAXPLAYERS + 1], g_iAmmoEffect[ST_MAXTYPES + 1], g_iAmmoHit[ST_MAXTYPES + 1], g_iAmmoHitMode[ST_MAXTYPES + 1], g_iAmmoMessage[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_ammo", cmdAmmoInfo, "View information about the Ammo ability.");

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

	vRemoveAmmo(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdAmmoInfo(int client, int args)
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iAmmoAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iAmmoCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AmmoDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

public void ST_OnDisplayMenu(Menu menu)
{
	menu.AddItem(ST_MENU_AMMO, ST_MENU_AMMO);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_AMMO, false))
	{
		vAmmoMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iAmmoHitMode[ST_GetTankType(attacker)] == 0 || g_iAmmoHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || ST_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAmmoHit(victim, attacker, g_flAmmoChance[ST_GetTankType(attacker)], g_iAmmoHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iAmmoHitMode[ST_GetTankType(victim)] == 0 || g_iAmmoHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || ST_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAmmoHit(attacker, victim, g_flAmmoChance[ST_GetTankType(victim)], g_iAmmoHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
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
		ST_FindAbility(type, 3, bHasAbilities(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo"));
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

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveAmmo(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iAmmoAbility[ST_GetTankType(tank)] == 1)
	{
		vAmmoAbility(tank);
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
			if (g_iAmmoAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bAmmo[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoHuman3");
					case false: vAmmoAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveAmmo(tank);
}

static void vAmmoAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iAmmoCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bAmmo2[tank] = false;
		g_bAmmo3[tank] = false;

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
				if (flDistance <= g_flAmmoRange[ST_GetTankType(tank)])
				{
					vAmmoHit(iSurvivor, tank, g_flAmmoRangeChance[ST_GetTankType(tank)], g_iAmmoAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoAmmo");
	}
}

static void vAmmoHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && GetPlayerWeaponSlot(survivor, 0) > 0)
	{
		if (g_iAmmoCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bAmmo[tank])
				{
					g_bAmmo[tank] = true;
					g_iAmmoCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoHuman", g_iAmmoCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);

					if (g_iAmmoCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
					{
						CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
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
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 3);
					}
					else if (StrEqual(sWeapon, "weapon_smg") || StrEqual(sWeapon, "weapon_smg_silenced") || StrEqual(sWeapon, "weapon_smg_mp5"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 5);
					}
					else if (StrEqual(sWeapon, "weapon_pumpshotgun"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 7);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 6);
						}
					}
					else if (StrEqual(sWeapon, "weapon_shotgun_chrome"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 7);
					}
					else if (StrEqual(sWeapon, "weapon_autoshotgun"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 8);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 6);
						}
					}
					else if (StrEqual(sWeapon, "weapon_shotgun_spas"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 8);
					}
					else if (StrEqual(sWeapon, "weapon_hunting_rifle"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 9);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 2);
						}
					}
					else if (StrEqual(sWeapon, "weapon_sniper_scout") || StrEqual(sWeapon, "weapon_sniper_military") || StrEqual(sWeapon, "weapon_sniper_awp"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 10);
					}
					else if (StrEqual(sWeapon, "weapon_grenade_launcher"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_iAmmoAmount[ST_GetTankType(tank)], _, 17);
					}
				}

				SetEntProp(GetPlayerWeaponSlot(survivor, 0), Prop_Data, "m_iClip1", g_iAmmoAmount[ST_GetTankType(tank)], 1);

				vEffect(survivor, tank, g_iAmmoEffect[ST_GetTankType(tank)], flags);

				if (g_iAmmoMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Ammo", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bAmmo[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bAmmo2[tank])
				{
					g_bAmmo2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bAmmo3[tank])
		{
			g_bAmmo3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoAmmo");
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveAmmo(iPlayer);
		}
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT))
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
	if (!bIsValidClient(survivor, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT))
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

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bAmmo[iTank])
	{
		g_bAmmo[iTank] = false;

		return Plugin_Stop;
	}

	g_bAmmo[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "AmmoHuman5");

	return Plugin_Continue;
}