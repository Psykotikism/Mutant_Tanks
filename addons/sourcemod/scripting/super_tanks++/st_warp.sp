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
	name = "[ST++] Warp Ability",
	author = ST_AUTHOR,
	description = "The Super Tank warps to survivors and warps survivors to random teammates.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Warp Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"

#define ST_MENU_WARP "Warp Ability"

bool g_bCloneInstalled, g_bWarp[MAXPLAYERS + 1], g_bWarp2[MAXPLAYERS + 1], g_bWarp3[MAXPLAYERS + 1], g_bWarp4[MAXPLAYERS + 1], g_bWarp5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flWarpChance[ST_MAXTYPES + 1], g_flWarpInterval[ST_MAXTYPES + 1], g_flWarpRange[ST_MAXTYPES + 1], g_flWarpRangeChance[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iWarpAbility[ST_MAXTYPES + 1], g_iWarpCount[MAXPLAYERS + 1], g_iWarpCount2[MAXPLAYERS + 1], g_iWarpEffect[ST_MAXTYPES + 1], g_iWarpHit[ST_MAXTYPES + 1], g_iWarpHitMode[ST_MAXTYPES + 1], g_iWarpMessage[ST_MAXTYPES + 1], g_iWarpMode[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_warp", cmdWarpInfo, "View information about the Warp ability.");

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
	vPrecacheParticle(PARTICLE_ELECTRICITY);

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveWarp(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdWarpInfo(int client, int args)
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
		case false: vWarpMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vWarpMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iWarpMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Warp Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Button Mode", "Button Mode");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iWarpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iWarpAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iWarpCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo2", g_iHumanAmmo[ST_GetTankType(param1)] - g_iWarpCount2[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				}
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "WarpDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flHumanDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vWarpMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "WarpMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 7:
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
	menu.AddItem(ST_MENU_WARP, ST_MENU_WARP);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_WARP, false))
	{
		vWarpMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iWarpHitMode[ST_GetTankType(attacker)] == 0 || g_iWarpHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || ST_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWarpHit(victim, attacker, g_flWarpChance[ST_GetTankType(attacker)], g_iWarpHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iWarpHitMode[ST_GetTankType(victim)] == 0 || g_iWarpHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || ST_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vWarpHit(attacker, victim, g_flWarpChance[ST_GetTankType(victim)], g_iWarpHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_flHumanDuration[iIndex] = 5.0;
		g_iHumanMode[iIndex] = 1;
		g_iWarpAbility[iIndex] = 0;
		g_iWarpEffect[iIndex] = 0;
		g_iWarpMessage[iIndex] = 0;
		g_flWarpChance[iIndex] = 33.3;
		g_iWarpHit[iIndex] = 0;
		g_iWarpHitMode[iIndex] = 0;
		g_flWarpInterval[iIndex] = 5.0;
		g_iWarpMode[iIndex] = 0;
		g_flWarpRange[iIndex] = 150.0;
		g_flWarpRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "wrapability", false) || StrEqual(subsection, "wrap ability", false) || StrEqual(subsection, "wrap_ability", false) || StrEqual(subsection, "wrap", false))
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
		ST_FindAbility(type, 66, bHasAbilities(subsection, "warpability", "warp ability", "warp_ability", "warp"));
		g_iHumanAbility[type] = iGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_flHumanDuration[type] = flGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_flHumanDuration[type], value, 0.1, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iWarpAbility[type] = iGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iWarpAbility[type], value, 0, 3);
		g_iWarpEffect[type] = iGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iWarpEffect[type], value, 0, 7);
		g_iWarpMessage[type] = iGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iWarpMessage[type], value, 0, 7);
		g_flWarpChance[type] = flGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "WarpChance", "Warp Chance", "Warp_Chance", "chance", g_flWarpChance[type], value, 0.0, 100.0);
		g_iWarpHit[type] = iGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "WarpHit", "Warp Hit", "Warp_Hit", "hit", g_iWarpHit[type], value, 0, 1);
		g_iWarpHitMode[type] = iGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "WarpHitMode", "Warp Hit Mode", "Warp_Hit_Mode", "hitmode", g_iWarpHitMode[type], value, 0, 2);
		g_flWarpInterval[type] = flGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "WarpInterval", "Warp Interval", "Warp_Interval", "interval", g_flWarpInterval[type], value, 0.1, 9999999999.0);
		g_iWarpMode[type] = iGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "WarpMode", "Warp Mode", "Warp_Mode", "mode", g_iWarpMode[type], value, 0, 1);
		g_flWarpRange[type] = flGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "WarpRange", "Warp Range", "Warp_Range", "range", g_flWarpRange[type], value, 1.0, 9999999999.0);
		g_flWarpRangeChance[type] = flGetValue(subsection, "warpability", "warp ability", "warp_ability", "warp", key, "WarpRangeChance", "Warp Range Chance", "Warp_Range_Chance", "rangechance", g_flWarpRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "wrapability", false) || StrEqual(subsection, "wrap ability", false) || StrEqual(subsection, "wrap_ability", false) || StrEqual(subsection, "wrap", false))
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
			vRemoveWarp(iTank);

			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iWarpAbility[ST_GetTankType(iTank)] == 1)
			{
				if (ST_HasAdminAccess(iTank) || bHasAdminAccess(iTank))
				{
					vAttachParticle(iTank, PARTICLE_ELECTRICITY, 1.0, 0.0);
					EmitSoundToAll(SOUND_ELECTRICITY, iTank);
				}
			}
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iWarpAbility[ST_GetTankType(tank)] > 0)
	{
		vWarpAbility(tank, true);
		vWarpAbility(tank, false);
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
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((g_iWarpAbility[ST_GetTankType(tank)] == 2 || g_iWarpAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bWarp[tank] && !g_bWarp2[tank])
						{
							vWarpAbility(tank, false);
						}
						else if (g_bWarp[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman4");
						}
						else if (g_bWarp2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman5");
						}
					}
					case 1:
					{
						if (g_iWarpCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bWarp[tank] && !g_bWarp2[tank])
							{
								g_bWarp[tank] = true;
								g_iWarpCount[tank]++;

								vWarp(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman", g_iWarpCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpAmmo");
						}
					}
				}
			}
		}

		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if ((g_iWarpAbility[ST_GetTankType(tank)] == 1 || g_iWarpAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bWarp3[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman6");
					case false: vWarpAbility(tank, true);
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((g_iWarpAbility[ST_GetTankType(tank)] == 2 || g_iWarpAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bWarp[tank] && !g_bWarp2[tank])
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveWarp(tank);
}

static void vRemoveWarp(int tank)
{
	g_bWarp[tank] = false;
	g_bWarp2[tank] = false;
	g_bWarp3[tank] = false;
	g_bWarp4[tank] = false;
	g_bWarp5[tank] = false;
	g_iWarpCount[tank] = 0;
	g_iWarpCount2[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveWarp(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bWarp[tank] = false;
	g_bWarp2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman8");

	if (g_iWarpCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bWarp2[tank] = false;
	}
}

static void vWarp(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	DataPack dpWarp;
	CreateDataTimer(g_flWarpInterval[ST_GetTankType(tank)], tTimerWarp, dpWarp, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpWarp.WriteCell(GetClientUserId(tank));
	dpWarp.WriteCell(ST_GetTankType(tank));
	dpWarp.WriteFloat(GetEngineTime());
}

static void vWarpAbility(int tank, bool main)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_iWarpAbility[ST_GetTankType(tank)] == 1 || g_iWarpAbility[ST_GetTankType(tank)] == 3)
			{
				if (g_iWarpCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
				{
					g_bWarp4[tank] = false;
					g_bWarp5[tank] = false;

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
							if (flDistance <= g_flWarpRange[ST_GetTankType(tank)])
							{
								vWarpHit(iSurvivor, tank, g_flWarpRangeChance[ST_GetTankType(tank)], g_iWarpAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman7");
						}
					}
				}
				else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpAmmo");
				}
			}
		}
		case false:
		{
			if ((g_iWarpAbility[ST_GetTankType(tank)] == 2 || g_iWarpAbility[ST_GetTankType(tank)] == 3) && !g_bWarp[tank])
			{
				if (g_iWarpCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
				{
					g_bWarp[tank] = true;

					if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
					{
						g_iWarpCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman", g_iWarpCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
					}

					vWarp(tank);

					if (g_iWarpMessage[ST_GetTankType(tank)] & ST_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Warp2", sTankName);
					}
				}
				else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpAmmo");
				}
			}
		}
	}
}

static void vWarpHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_iWarpCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				float flCurrentOrigin[3];
				for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
				{
					if (bIsSurvivor(iPlayer) && !bIsPlayerIncapacitated(iPlayer) && iPlayer != survivor)
					{
						if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bWarp3[tank])
						{
							g_bWarp3[tank] = true;
							g_iWarpCount2[tank]++;

							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman2", g_iWarpCount2[tank], g_iHumanAmmo[ST_GetTankType(tank)]);

							if (g_iWarpCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
							{
								CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown2, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
							}
							else
							{
								g_bWarp3[tank] = false;
							}
						}

						GetClientAbsOrigin(iPlayer, flCurrentOrigin);
						TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

						if (g_iWarpMessage[ST_GetTankType(tank)] & messages)
						{
							char sTankName[33];
							ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Warp", sTankName, survivor, iPlayer);
						}

						break;
					}
				}

				vEffect(survivor, tank, g_iWarpEffect[ST_GetTankType(tank)], flags);
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bWarp3[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bWarp4[tank])
				{
					g_bWarp4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman3");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bWarp5[tank])
		{
			g_bWarp5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpAmmo2");
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

public Action tTimerWarp(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || (g_iWarpAbility[ST_GetTankType(iTank)] != 2 && g_iWarpAbility[ST_GetTankType(iTank)] != 3) || !g_bWarp[iTank])
	{
		g_bWarp[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && (flTime + g_flHumanDuration[ST_GetTankType(iTank)]) < GetEngineTime() && !g_bWarp2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	int iSurvivor = iGetRandomSurvivor(iTank);
	if (iSurvivor > 0)
	{
		float flTankOrigin[3], flTankAngles[3];
		GetClientAbsOrigin(iTank, flTankOrigin);
		GetClientAbsAngles(iTank, flTankAngles);

		float flSurvivorOrigin[3], flSurvivorAngles[3];
		GetClientAbsOrigin(iSurvivor, flSurvivorOrigin);
		GetClientAbsAngles(iSurvivor, flSurvivorAngles);

		vAttachParticle(iTank, PARTICLE_ELECTRICITY, 1.0, 0.0);
		EmitSoundToAll(SOUND_ELECTRICITY, iTank);
		TeleportEntity(iTank, flSurvivorOrigin, flSurvivorAngles, NULL_VECTOR);

		if (g_iWarpMode[ST_GetTankType(iTank)] == 1)
		{
			vAttachParticle(iSurvivor, PARTICLE_ELECTRICITY, 1.0, 0.0);
			EmitSoundToAll(SOUND_ELECTRICITY2, iSurvivor);
			TeleportEntity(iSurvivor, flTankOrigin, flTankAngles, NULL_VECTOR);
		}

		if (g_iWarpMessage[ST_GetTankType(iTank)] & ST_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Warp3", sTankName);
		}
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bWarp2[iTank])
	{
		g_bWarp2[iTank] = false;

		return Plugin_Stop;
	}

	g_bWarp2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WarpHuman9");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bWarp3[iTank])
	{
		g_bWarp3[iTank] = false;

		return Plugin_Stop;
	}

	g_bWarp3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WarpHuman10");

	return Plugin_Continue;
}