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
	name = "[MT] Gravity Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Gravity Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_GRAVITY "Gravity Ability"

bool g_bCloneInstalled, g_bGravity[MAXPLAYERS + 1], g_bGravity2[MAXPLAYERS + 1], g_bGravity3[MAXPLAYERS + 1], g_bGravity4[MAXPLAYERS + 1], g_bGravity5[MAXPLAYERS + 1], g_bGravity6[MAXPLAYERS + 1], g_bGravity7[MAXPLAYERS + 1];

float g_flGravityChance[MT_MAXTYPES + 1], g_flGravityDuration[MT_MAXTYPES + 1], g_flGravityForce[MT_MAXTYPES + 1], g_flGravityRange[MT_MAXTYPES + 1], g_flGravityRangeChance[MT_MAXTYPES + 1], g_flGravityValue[MT_MAXTYPES + 1], g_flHumanCooldown[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iGravity[MAXPLAYERS + 1], g_iGravityAbility[MT_MAXTYPES + 1], g_iGravityCount[MAXPLAYERS + 1], g_iGravityCount2[MAXPLAYERS + 1], g_iGravityEffect[MT_MAXTYPES + 1], g_iGravityHit[MT_MAXTYPES + 1], g_iGravityHitMode[MT_MAXTYPES + 1], g_iGravityMessage[MT_MAXTYPES + 1], g_iGravityOwner[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iHumanMode[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_mt_gravity", cmdGravityInfo, "View information about the Gravity ability.");

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

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdGravityInfo(int client, int args)
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
		case false: vGravityMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vGravityMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iGravityMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Gravity Ability Information");
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

public int iGravityMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iGravityAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iGravityCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_iHumanAmmo[MT_GetTankType(param1)] - g_iGravityCount2[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanMode[MT_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GravityDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flGravityDuration[MT_GetTankType(param1)]);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vGravityMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "GravityMenu", param1);
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_GRAVITY, MT_MENU_GRAVITY);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_GRAVITY, false))
	{
		vGravityMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iGravityHitMode[MT_GetTankType(attacker)] == 0 || g_iGravityHitMode[MT_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGravityHit(victim, attacker, g_flGravityChance[MT_GetTankType(attacker)], g_iGravityHit[MT_GetTankType(attacker)], MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iGravityHitMode[MT_GetTankType(victim)] == 0 || g_iGravityHitMode[MT_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGravityHit(attacker, victim, g_flGravityChance[MT_GetTankType(victim)], g_iGravityHit[MT_GetTankType(victim)], MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
			g_iHumanMode[iIndex] = 1;
			g_iGravityAbility[iIndex] = 0;
			g_iGravityEffect[iIndex] = 0;
			g_iGravityMessage[iIndex] = 0;
			g_flGravityChance[iIndex] = 33.3;
			g_flGravityDuration[iIndex] = 5.0;
			g_flGravityForce[iIndex] = -50.0;
			g_flGravityRange[iIndex] = 150.0;
			g_iGravityHit[iIndex] = 0;
			g_iGravityHitMode[iIndex] = 0;
			g_flGravityRangeChance[iIndex] = 15.0;
			g_flGravityValue[iIndex] = 0.3;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "gravityability", false) || StrEqual(subsection, "gravity ability", false) || StrEqual(subsection, "gravity_ability", false) || StrEqual(subsection, "gravity", false))
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
		g_iHumanAbility[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iGravityAbility[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iGravityAbility[type], value, 0, 3);
		g_iGravityEffect[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iGravityEffect[type], value, 0, 7);
		g_iGravityMessage[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iGravityMessage[type], value, 0, 7);
		g_flGravityChance[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityChance", "Gravity Chance", "Gravity_Chance", "chance", g_flGravityChance[type], value, 0.0, 100.0);
		g_flGravityDuration[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityDuration", "Gravity Duration", "Gravity_Duration", "duration", g_flGravityDuration[type], value, 0.1, 999999.0);
		g_flGravityForce[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityForce", "Gravity Force", "Gravity_Force", "force", g_flGravityForce[type], value, -100.0, 100.0);
		g_iGravityHit[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHit", "Gravity Hit", "Gravity_Hit", "hit", g_iGravityHit[type], value, 0, 1);
		g_iGravityHitMode[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHitMode", "Gravity Hit Mode", "Gravity_Hit_Mode", "hitmode", g_iGravityHitMode[type], value, 0, 2);
		g_flGravityRange[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRange", "Gravity Range", "Gravity_Range", "range", g_flGravityRange[type], value, 1.0, 999999.0);
		g_flGravityRangeChance[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRangeChance", "Gravity Range Chance", "Gravity_Range_Chance", "rangechance", g_flGravityRangeChance[type], value, 0.0, 100.0);
		g_flGravityValue[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityValue", "Gravity Value", "Gravity_Value", "value", g_flGravityValue[type], value, 0.1, 999999.0);

		if (StrEqual(subsection, "gravityability", false) || StrEqual(subsection, "gravity ability", false) || StrEqual(subsection, "gravity_ability", false) || StrEqual(subsection, "gravity", false))
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
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
		{
			vRemoveGravity(iTank);
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vRemoveGravity(iBot);

			vReset2(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vRemoveGravity(iTank);

			vReset2(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveGravity(iTank);

			vReset2(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iGravityAbility[MT_GetTankType(tank)] > 0)
	{
		vGravityAbility(tank, true);
		vGravityAbility(tank, false);
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

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if ((g_iGravityAbility[MT_GetTankType(tank)] == 2 || g_iGravityAbility[MT_GetTankType(tank)] == 3) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[MT_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bGravity[tank] && !g_bGravity3[tank])
						{
							vGravityAbility(tank, false);
						}
						else if (g_bGravity[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman4");
						}
						else if (g_bGravity3[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman5");
						}
					}
					case 1:
					{
						if (g_iGravityCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
						{
							if (!g_bGravity[tank] && !g_bGravity3[tank])
							{
								g_bGravity[tank] = true;
								g_iGravityCount[tank]++;

								g_iGravity[tank] = CreateEntityByName("point_push");
								if (bIsValidEntity(g_iGravity[tank]))
								{
									vGravity(tank);
								}

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman", g_iGravityCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if ((g_iGravityAbility[MT_GetTankType(tank)] == 1 || g_iGravityAbility[MT_GetTankType(tank)] == 3) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (!g_bGravity4[tank] && !g_bGravity5[tank])
				{
					vGravityAbility(tank, true);
				}
				else if (g_bGravity4[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman6");
				}
				else if (g_bGravity5[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman7");
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if ((g_iGravityAbility[MT_GetTankType(tank)] == 2 || g_iGravityAbility[MT_GetTankType(tank)] == 3) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[MT_GetTankType(tank)] == 1 && g_bGravity[tank] && !g_bGravity3[tank])
				{
					vReset3(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
	{
		vRemoveGravity(tank);
	}

	vReset2(tank, revert);
}

static void vGravity(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	float flOrigin[3], flAngles[3];
	GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
	GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);
	flAngles[0] += -90.0;

	DispatchKeyValueVector(g_iGravity[tank], "origin", flOrigin);
	DispatchKeyValueVector(g_iGravity[tank], "angles", flAngles);
	DispatchKeyValue(g_iGravity[tank], "radius", "750");
	DispatchKeyValueFloat(g_iGravity[tank], "magnitude", g_flGravityForce[MT_GetTankType(tank)]);
	DispatchKeyValue(g_iGravity[tank], "spawnflags", "8");
	vSetEntityParent(g_iGravity[tank], tank, true);
	AcceptEntityInput(g_iGravity[tank], "Enable");
	g_iGravity[tank] = EntIndexToEntRef(g_iGravity[tank]);
}

static void vGravityAbility(int tank, bool main)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_iGravityAbility[MT_GetTankType(tank)] == 1 || g_iGravityAbility[MT_GetTankType(tank)] == 3)
			{
				if (g_iGravityCount2[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
				{
					g_bGravity6[tank] = false;
					g_bGravity7[tank] = false;

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
							if (flDistance <= g_flGravityRange[MT_GetTankType(tank)])
							{
								vGravityHit(iSurvivor, tank, g_flGravityRangeChance[MT_GetTankType(tank)], g_iGravityAbility[MT_GetTankType(tank)], MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman8");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_iGravityAbility[MT_GetTankType(tank)] == 2 || g_iGravityAbility[MT_GetTankType(tank)] == 3) && !g_bGravity[tank])
			{
				if (g_iGravityCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
				{
					g_bGravity[tank] = true;

					g_iGravity[tank] = CreateEntityByName("point_push");
					if (bIsValidEntity(g_iGravity[tank]))
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
						{
							g_iGravityCount[tank]++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman", g_iGravityCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
						}

						vGravity(tank);

						DataPack dpGravity;
						CreateDataTimer(g_flGravityDuration[MT_GetTankType(tank)], tTimerGravity, dpGravity, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpGravity.WriteCell(GetClientUserId(tank));
						dpGravity.WriteCell(MT_GetTankType(tank));
						dpGravity.WriteFloat(GetEngineTime());

						if (g_iGravityMessage[MT_GetTankType(tank)] & MT_MESSAGE_SPECIAL)
						{
							char sTankName[33];
							MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity3", sTankName);
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo");
				}
			}
		}
	}
}

static void vGravityHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_iGravityCount2[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bGravity2[survivor])
			{
				g_bGravity2[survivor] = true;
				g_iGravityOwner[survivor] = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && (flags & MT_ATTACK_RANGE) && !g_bGravity4[tank])
				{
					g_bGravity4[tank] = true;
					g_iGravityCount2[tank]++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman2", g_iGravityCount2[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
				}

				SetEntityGravity(survivor, g_flGravityValue[MT_GetTankType(tank)]);

				DataPack dpStopGravity;
				CreateDataTimer(g_flGravityDuration[MT_GetTankType(tank)], tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
				dpStopGravity.WriteCell(GetClientUserId(survivor));
				dpStopGravity.WriteCell(GetClientUserId(tank));
				dpStopGravity.WriteCell(messages);

				vEffect(survivor, tank, g_iGravityEffect[MT_GetTankType(tank)], flags);

				if (g_iGravityMessage[MT_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity", sTankName, survivor, g_flGravityValue[MT_GetTankType(tank)]);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_bGravity4[tank])
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bGravity6[tank])
				{
					g_bGravity6[tank] = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bGravity7[tank])
		{
			g_bGravity7[tank] = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo2");
		}
	}
}

static void vRemoveGravity(int tank)
{
	if (bIsValidEntRef(g_iGravity[tank]))
	{
		RemoveEntity(g_iGravity[tank]);
	}

	g_iGravity[tank] = INVALID_ENT_REFERENCE;

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_bGravity2[iSurvivor] && g_iGravityOwner[iSurvivor] == tank)
		{
			g_bGravity2[iSurvivor] = false;
			g_iGravityOwner[iSurvivor] = 0;

			SetEntityGravity(iSurvivor, 1.0);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset2(iPlayer);

			g_iGravityOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank, bool revert = false)
{
	if (!revert)
	{
		g_bGravity[tank] = false;
	}

	g_bGravity2[tank] = false;
	g_bGravity3[tank] = false;
	g_bGravity4[tank] = false;
	g_bGravity5[tank] = false;
	g_bGravity6[tank] = false;
	g_bGravity7[tank] = false;
	g_iGravity[tank] = INVALID_ENT_REFERENCE;
	g_iGravityCount[tank] = 0;
	g_iGravityCount2[tank] = 0;
}

static void vReset3(int tank)
{
	g_bGravity[tank] = false;
	g_bGravity3[tank] = true;

	if (bIsValidEntRef(g_iGravity[tank]))
	{
		RemoveEntity(g_iGravity[tank]);
	}

	g_iGravity[tank] = INVALID_ENT_REFERENCE;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman9");

	if (g_iGravityCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bGravity3[tank] = false;
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

public Action tTimerGravity(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || !g_bGravity[iTank])
	{
		g_bGravity[iTank] = false;

		if (bIsValidEntRef(g_iGravity[iTank]))
		{
			RemoveEntity(g_iGravity[iTank]);
		}

		g_iGravity[iTank] = INVALID_ENT_REFERENCE;

		if (g_iGravityMessage[MT_GetTankType(iTank)] & MT_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity4", sTankName);
		}

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && g_iHumanMode[MT_GetTankType(iTank)] == 0 && (flTime + g_flGravityDuration[MT_GetTankType(iTank)]) < GetEngineTime() && !g_bGravity3[iTank])
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerStopGravity(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bGravity2[iSurvivor] = false;
		g_iGravityOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bGravity2[iSurvivor])
	{
		g_bGravity2[iSurvivor] = false;
		g_iGravityOwner[iSurvivor] = 0;

		SetEntityGravity(iSurvivor, 1.0);

		return Plugin_Stop;
	}

	g_bGravity2[iSurvivor] = false;
	g_bGravity4[iTank] = false;
	g_iGravityOwner[iSurvivor] = 0;

	SetEntityGravity(iSurvivor, 1.0);

	int iMessage = pack.ReadCell();

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && (iMessage & MT_MESSAGE_RANGE) && !g_bGravity5[iTank])
	{
		g_bGravity5[iTank] = true;

		MT_PrintToChat(iTank, "%s %t", MT_TAG3, "GravityHuman10");

		if (g_iGravityCount2[iTank] < g_iHumanAmmo[MT_GetTankType(iTank)] && g_iHumanAmmo[MT_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[MT_GetTankType(iTank)], tTimerResetCooldown2, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bGravity5[iTank] = false;
		}
	}

	if (g_iGravityMessage[MT_GetTankType(iTank)] & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bGravity3[iTank])
	{
		g_bGravity3[iTank] = false;

		return Plugin_Stop;
	}

	g_bGravity3[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "GravityHuman11");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bGravity5[iTank])
	{
		g_bGravity5[iTank] = false;

		return Plugin_Stop;
	}

	g_bGravity5[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "GravityHuman12");

	return Plugin_Continue;
}