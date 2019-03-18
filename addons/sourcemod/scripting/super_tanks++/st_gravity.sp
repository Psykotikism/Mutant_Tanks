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
	name = "[ST++] Gravity Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Gravity Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_GRAVITY "Gravity Ability"

bool g_bCloneInstalled, g_bGravity[MAXPLAYERS + 1], g_bGravity2[MAXPLAYERS + 1], g_bGravity3[MAXPLAYERS + 1], g_bGravity4[MAXPLAYERS + 1], g_bGravity5[MAXPLAYERS + 1], g_bGravity6[MAXPLAYERS + 1], g_bGravity7[MAXPLAYERS + 1];

float g_flGravityChance[ST_MAXTYPES + 1], g_flGravityDuration[ST_MAXTYPES + 1], g_flGravityForce[ST_MAXTYPES + 1], g_flGravityRange[ST_MAXTYPES + 1], g_flGravityRangeChance[ST_MAXTYPES + 1], g_flGravityValue[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iGravity[MAXPLAYERS + 1], g_iGravityAbility[ST_MAXTYPES + 1], g_iGravityCount[MAXPLAYERS + 1], g_iGravityCount2[MAXPLAYERS + 1], g_iGravityEffect[ST_MAXTYPES + 1], g_iGravityHit[ST_MAXTYPES + 1], g_iGravityHitMode[ST_MAXTYPES + 1], g_iGravityMessage[ST_MAXTYPES + 1], g_iGravityOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_gravity", cmdGravityInfo, "View information about the Gravity ability.");

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

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdGravityInfo(int client, int args)
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iGravityAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iGravityCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo2", g_iHumanAmmo[ST_GetTankType(param1)] - g_iGravityCount2[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				}
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "GravityDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flGravityDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

public void ST_OnDisplayMenu(Menu menu)
{
	menu.AddItem(ST_MENU_GRAVITY, ST_MENU_GRAVITY);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_GRAVITY, false))
	{
		vGravityMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iGravityHitMode[ST_GetTankType(attacker)] == 0 || g_iGravityHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || ST_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGravityHit(victim, attacker, g_flGravityChance[ST_GetTankType(attacker)], g_iGravityHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iGravityHitMode[ST_GetTankType(victim)] == 0 || g_iGravityHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || ST_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGravityHit(attacker, victim, g_flGravityChance[ST_GetTankType(victim)], g_iGravityHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
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

	if (type > 0)
	{
		ST_FindAbility(type, 22, bHasAbilities(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity"));
		g_iHumanAbility[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iGravityAbility[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iGravityAbility[type], value, 0, 3);
		g_iGravityEffect[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iGravityEffect[type], value, 0, 7);
		g_iGravityMessage[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iGravityMessage[type], value, 0, 7);
		g_flGravityChance[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityChance", "Gravity Chance", "Gravity_Chance", "chance", g_flGravityChance[type], value, 0.0, 100.0);
		g_flGravityDuration[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityDuration", "Gravity Duration", "Gravity_Duration", "duration", g_flGravityDuration[type], value, 0.1, 9999999999.0);
		g_flGravityForce[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityForce", "Gravity Force", "Gravity_Force", "force", g_flGravityForce[type], value, -100.0, 100.0);
		g_iGravityHit[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHit", "Gravity Hit", "Gravity_Hit", "hit", g_iGravityHit[type], value, 0, 1);
		g_iGravityHitMode[type] = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHitMode", "Gravity Hit Mode", "Gravity_Hit_Mode", "hitmode", g_iGravityHitMode[type], value, 0, 2);
		g_flGravityRange[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRange", "Gravity Range", "Gravity_Range", "range", g_flGravityRange[type], value, 1.0, 9999999999.0);
		g_flGravityRangeChance[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRangeChance", "Gravity Range Chance", "Gravity_Range_Chance", "rangechance", g_flGravityRangeChance[type], value, 0.0, 100.0);
		g_flGravityValue[type] = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityValue", "Gravity Value", "Gravity_Value", "value", g_flGravityValue[type], value, 0.1, 9999999999.0);

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

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
		{
			vRemoveGravity(iTank);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
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
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveGravity(iTank);

			vReset2(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iGravityAbility[ST_GetTankType(tank)] > 0)
	{
		vGravityAbility(tank, true);
		vGravityAbility(tank, false);
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
			if ((g_iGravityAbility[ST_GetTankType(tank)] == 2 || g_iGravityAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bGravity[tank] && !g_bGravity3[tank])
						{
							vGravityAbility(tank, false);
						}
						else if (g_bGravity[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman4");
						}
						else if (g_bGravity3[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman5");
						}
					}
					case 1:
					{
						if (g_iGravityCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
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

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman", g_iGravityCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityAmmo");
						}
					}
				}
			}
		}

		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if ((g_iGravityAbility[ST_GetTankType(tank)] == 1 || g_iGravityAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bGravity4[tank] && !g_bGravity5[tank])
				{
					vGravityAbility(tank, true);
				}
				else if (g_bGravity4[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman6");
				}
				else if (g_bGravity5[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman7");
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
			if ((g_iGravityAbility[ST_GetTankType(tank)] == 2 || g_iGravityAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bGravity[tank] && !g_bGravity3[tank])
				{
					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
	{
		vRemoveGravity(tank);
	}

	vReset2(tank, revert);
}

static void vGravity(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
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
	DispatchKeyValueFloat(g_iGravity[tank], "magnitude", g_flGravityForce[ST_GetTankType(tank)]);
	DispatchKeyValue(g_iGravity[tank], "spawnflags", "8");
	vSetEntityParent(g_iGravity[tank], tank, true);
	AcceptEntityInput(g_iGravity[tank], "Enable");
}

static void vGravityAbility(int tank, bool main)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_iGravityAbility[ST_GetTankType(tank)] == 1 || g_iGravityAbility[ST_GetTankType(tank)] == 3)
			{
				if (g_iGravityCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
				{
					g_bGravity6[tank] = false;
					g_bGravity7[tank] = false;

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
							if (flDistance <= g_flGravityRange[ST_GetTankType(tank)])
							{
								vGravityHit(iSurvivor, tank, g_flGravityRangeChance[ST_GetTankType(tank)], g_iGravityAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman8");
						}
					}
				}
				else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_iGravityAbility[ST_GetTankType(tank)] == 2 || g_iGravityAbility[ST_GetTankType(tank)] == 3) && !g_bGravity[tank])
			{
				if (g_iGravityCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
				{
					g_bGravity[tank] = true;

					g_iGravity[tank] = CreateEntityByName("point_push");
					if (bIsValidEntity(g_iGravity[tank]))
					{
						if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
						{
							g_iGravityCount[tank]++;

							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman", g_iGravityCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
						}

						vGravity(tank);

						DataPack dpGravity;
						CreateDataTimer(g_flGravityDuration[ST_GetTankType(tank)], tTimerGravity, dpGravity, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpGravity.WriteCell(GetClientUserId(tank));
						dpGravity.WriteCell(ST_GetTankType(tank));
						dpGravity.WriteFloat(GetEngineTime());

						if (g_iGravityMessage[ST_GetTankType(tank)] & ST_MESSAGE_SPECIAL)
						{
							char sTankName[33];
							ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity3", sTankName);
						}
					}
				}
				else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityAmmo");
				}
			}
		}
	}
}

static void vGravityHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_iGravityCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bGravity2[survivor])
			{
				g_bGravity2[survivor] = true;
				g_iGravityOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bGravity4[tank])
				{
					g_bGravity4[tank] = true;
					g_iGravityCount2[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman2", g_iGravityCount2[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				SetEntityGravity(survivor, g_flGravityValue[ST_GetTankType(tank)]);

				DataPack dpStopGravity;
				CreateDataTimer(g_flGravityDuration[ST_GetTankType(tank)], tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
				dpStopGravity.WriteCell(GetClientUserId(survivor));
				dpStopGravity.WriteCell(GetClientUserId(tank));
				dpStopGravity.WriteCell(messages);

				vEffect(survivor, tank, g_iGravityEffect[ST_GetTankType(tank)], flags);

				if (g_iGravityMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity", sTankName, survivor, g_flGravityValue[ST_GetTankType(tank)]);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bGravity4[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bGravity6[tank])
				{
					g_bGravity6[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman3");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bGravity7[tank])
		{
			g_bGravity7[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityAmmo2");
		}
	}
}

static void vRemoveGravity(int tank)
{
	if (bIsValidEntity(g_iGravity[tank]))
	{
		RemoveEntity(g_iGravity[tank]);
	}

	g_iGravity[tank] = INVALID_ENT_REFERENCE;

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bGravity2[iSurvivor] && g_iGravityOwner[iSurvivor] == tank)
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

	if (bIsValidEntity(g_iGravity[tank]))
	{
		RemoveEntity(g_iGravity[tank]);
	}

	g_iGravity[tank] = INVALID_ENT_REFERENCE;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman9");

	if (g_iGravityCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bGravity3[tank] = false;
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

public Action tTimerGravity(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bGravity[iTank])
	{
		g_bGravity[iTank] = false;

		if (bIsValidEntity(g_iGravity[iTank]))
		{
			RemoveEntity(g_iGravity[iTank]);
		}

		g_iGravity[iTank] = INVALID_ENT_REFERENCE;

		if (g_iGravityMessage[ST_GetTankType(iTank)] & ST_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity4", sTankName);
		}

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && (flTime + g_flGravityDuration[ST_GetTankType(iTank)]) < GetEngineTime() && !g_bGravity3[iTank])
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
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bGravity2[iSurvivor])
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

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && (ST_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bGravity5[iTank])
	{
		g_bGravity5[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "GravityHuman10");

		if (g_iGravityCount2[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown2, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bGravity5[iTank] = false;
		}
	}

	if (g_iGravityMessage[ST_GetTankType(iTank)] & iMessage)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bGravity3[iTank])
	{
		g_bGravity3[iTank] = false;

		return Plugin_Stop;
	}

	g_bGravity3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "GravityHuman11");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bGravity5[iTank])
	{
		g_bGravity5[iTank] = false;

		return Plugin_Stop;
	}

	g_bGravity5[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "GravityHuman12");

	return Plugin_Continue;
}