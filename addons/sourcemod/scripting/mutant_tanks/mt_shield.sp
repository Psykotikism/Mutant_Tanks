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
	name = "[MT] Shield Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank protects itself with a shield and throws propane tanks or gas cans.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Shield Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"

#define MT_MENU_SHIELD "Shield Ability"

bool g_bCloneInstalled, g_bShield[MAXPLAYERS + 1], g_bShield2[MAXPLAYERS + 1];

ConVar g_cvMTTankThrowForce;

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flHumanDuration[MT_MAXTYPES + 1], g_flShieldChance[MT_MAXTYPES + 1], g_flShieldDelay[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iHumanMode[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iShield[MAXPLAYERS + 1], g_iShieldAbility[MT_MAXTYPES + 1], g_iShieldColor[MT_MAXTYPES + 1][4], g_iShieldCount[MAXPLAYERS + 1], g_iShieldMessage[MT_MAXTYPES + 1], g_iShieldType[MT_MAXTYPES + 1];

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

	RegConsoleCmd("sm_mt_shield", cmdShieldInfo, "View information about the Shield ability.");

	g_cvMTTankThrowForce = FindConVar("z_tank_throw_force");

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
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_PROPANETANK, true);
	PrecacheModel(MODEL_SHIELD, true);

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

public Action cmdShieldInfo(int client, int args)
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
		case false: vShieldMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vShieldMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iShieldMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Shield Ability Information");
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

public int iShieldMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iShieldAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iShieldCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanMode[MT_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ShieldDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flHumanDuration[MT_GetTankType(param1)]);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vShieldMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ShieldMenu", param1);
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
	menu.AddItem(MT_MENU_SHIELD, MT_MENU_SHIELD);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_SHIELD, false))
	{
		vShieldMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage > 0.0)
	{
		if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (g_bShield[victim])
			{
				switch (g_iShieldType[MT_GetTankType(victim)])
				{
					case 0:
					{
						if (damagetype & DMG_BULLET)
						{
							vShieldAbility(victim, false);
						}

						return Plugin_Handled;

					}
					case 1:
					{
						if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
						{
							vShieldAbility(victim, false);
						}

						return Plugin_Handled;
					}
					case 2:
					{
						if (damagetype & DMG_BURN)
						{
							vShieldAbility(victim, false);
						}

						return Plugin_Handled;
					}
					case 3:
					{
						if (damagetype & DMG_SLASH || damagetype & DMG_CLUB)
						{
							vShieldAbility(victim, false);
						}

						return Plugin_Handled;
					}
				}
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
			g_flHumanDuration[iIndex] = 5.0;
			g_iHumanMode[iIndex] = 1;
			g_iShieldAbility[iIndex] = 0;
			g_iShieldMessage[iIndex] = 0;
			g_flShieldChance[iIndex] = 33.3;
			g_flShieldDelay[iIndex] = 5.0;
			g_iShieldType[iIndex] = 1;

			for (int iPos = 0; iPos < 4; iPos++)
			{
				g_iShieldColor[iIndex][iPos] = 255;
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "shieldability", false) || StrEqual(subsection, "shield ability", false) || StrEqual(subsection, "shield_ability", false) || StrEqual(subsection, "shield", false))
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
		g_iHumanAbility[type] = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 999999.0);
		g_flHumanDuration[type] = flGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_flHumanDuration[type], value, 0.1, 999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iShieldAbility[type] = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iShieldAbility[type], value, 0, 1);
		g_iShieldMessage[type] = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iShieldMessage[type], value, 0, 1);
		g_flShieldChance[type] = flGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "ShieldChance", "Shield Chance", "Shield_Chance", "chance", g_flShieldChance[type], value, 0.0, 100.0);
		g_flShieldDelay[type] = flGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "ShieldDelay", "Shield Delay", "Shield_Delay", "delay", g_flShieldDelay[type], value, 0.1, 999999.0);
		g_iShieldType[type] = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "ShieldType", "Shield Type", "Shield_Type", "type", g_iShieldType[type], value, 0, 3);

		if (StrEqual(subsection, "shieldability", false) || StrEqual(subsection, "shield ability", false) || StrEqual(subsection, "shield_ability", false) || StrEqual(subsection, "shield", false))
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

		if ((StrEqual(subsection, "shieldability", false) || StrEqual(subsection, "shield ability", false) || StrEqual(subsection, "shield_ability", false) || StrEqual(subsection, "shield", false)) && (StrEqual(key, "ShieldColor", false) || StrEqual(key, "Shield Color", false) || StrEqual(key, "Shield_Color", false) || StrEqual(key, "color", false)) && value[0] != '\0')
		{
			char sSet[4][4], sValue[16];
			strcopy(sValue, sizeof(sValue), value);
			ReplaceString(sValue, sizeof(sValue), " ", "");
			ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

			for (int iPos = 0; iPos < 4; iPos++)
			{
				if (sSet[iPos][0] == '\0')
				{
					continue;
				}

				g_iShieldColor[type][iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
			}
		}
	}
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_bShield[iTank])
		{
			vRemoveShield(iTank);
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
			vRemoveShield(iBot);

			vReset2(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vRemoveShield(iTank);

			vReset2(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveShield(iTank);

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

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iShieldAbility[MT_GetTankType(tank)] == 1 && !g_bShield[tank] && !g_bShield2[tank])
	{
		vShieldAbility(tank, true);
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
			if (g_iShieldAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[MT_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bShield[tank] && !g_bShield2[tank])
						{
							vShieldAbility(tank, true);
						}
						else if (g_bShield[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman3");
						}
						else if (g_bShield2[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman4");
						}
					}
					case 1:
					{
						if (g_iShieldCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
						{
							if (!g_bShield[tank] && !g_bShield2[tank])
							{
								g_bShield[tank] = true;
								g_iShieldCount[tank]++;

								g_iShield[tank] = CreateEntityByName("prop_dynamic");
								if (bIsValidEntity(g_iShield[tank]))
								{
									vShield(tank);
								}

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman", g_iShieldCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldAmmo");
						}
					}
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
			if (g_iShieldAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[MT_GetTankType(tank)] == 1 && g_bShield[tank] && !g_bShield2[tank])
				{
					vRemoveShield(tank);

					g_bShield[tank] = false;

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
		vRemoveShield(tank);
	}

	vReset2(tank, revert);
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iShieldAbility[MT_GetTankType(tank)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flShieldChance[MT_GetTankType(tank)])
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		DataPack dpShieldThrow;
		CreateDataTimer(0.1, tTimerShieldThrow, dpShieldThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShieldThrow.WriteCell(EntIndexToEntRef(rock));
		dpShieldThrow.WriteCell(GetClientUserId(tank));
		dpShieldThrow.WriteCell(MT_GetTankType(tank));
	}
}

static void vRemoveShield(int tank)
{
	if (bIsValidEntRef(g_iShield[tank]))
	{
		MT_HideEntity(g_iShield[tank], false);
		RemoveEntity(g_iShield[tank]);
	}

	g_iShield[tank] = INVALID_ENT_REFERENCE;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset2(iPlayer);
		}
	}
}

static void vReset2(int tank, bool revert = false)
{
	if (!revert)
	{
		g_bShield[tank] = false;
	}

	g_bShield2[tank] = false;
	g_iShield[tank] = INVALID_ENT_REFERENCE;
	g_iShieldCount[tank] = 0;
}

static void vReset3(int tank)
{
	if (!g_bShield2[tank])
	{
		g_bShield2[tank] = true;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman5");

		if (g_iShieldCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bShield2[tank] = false;
		}
	}
}

static void vShield(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	float flOrigin[3];
	GetClientAbsOrigin(tank, flOrigin);
	flOrigin[2] -= 120.0;

	SetEntityModel(g_iShield[tank], MODEL_SHIELD);

	DispatchKeyValueVector(g_iShield[tank], "origin", flOrigin);
	DispatchSpawn(g_iShield[tank]);
	vSetEntityParent(g_iShield[tank], tank, true);

	SetEntityRenderMode(g_iShield[tank], RENDER_TRANSTEXTURE);
	SetEntityRenderColor(g_iShield[tank], g_iShieldColor[MT_GetTankType(tank)][0], g_iShieldColor[MT_GetTankType(tank)][1], g_iShieldColor[MT_GetTankType(tank)][2], g_iShieldColor[MT_GetTankType(tank)][3]);

	SetEntProp(g_iShield[tank], Prop_Send, "m_CollisionGroup", 1);

	MT_HideEntity(g_iShield[tank], true);
	g_iShield[tank] = EntIndexToEntRef(g_iShield[tank]);
}

static void vShieldAbility(int tank, bool shield)
{
	switch (shield)
	{
		case true:
		{
			if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
			{
				return;
			}

			if (g_iShieldCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
			{
				if (GetRandomFloat(0.1, 100.0) <= g_flShieldChance[MT_GetTankType(tank)])
				{
					g_iShield[tank] = CreateEntityByName("prop_dynamic");
					if (bIsValidEntity(g_iShield[tank]))
					{
						vShield(tank);

						g_bShield[tank] = true;

						ExtinguishEntity(tank);

						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
						{
							g_iShieldCount[tank]++;

							CreateTimer(g_flHumanDuration[MT_GetTankType(tank)], tTimerStopShield, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman", g_iShieldCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
						}

						if (g_iShieldMessage[MT_GetTankType(tank)] == 1)
						{
							char sTankName[33];
							MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Shield", sTankName);
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman2");
				}
			}
			else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldAmmo");
			}
		}
		case false:
		{
			vRemoveShield(tank);

			g_bShield[tank] = false;

			switch (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
			{
				case true: vReset3(tank);
				case false:
				{
					if (!g_bShield2[tank])
					{
						g_bShield2[tank] = true;

						CreateTimer(g_flShieldDelay[MT_GetTankType(tank)], tTimerShield, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}

			if (g_iShieldMessage[MT_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Shield2", sTankName);
			}
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

public Action tTimerShield(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || g_iShieldAbility[MT_GetTankType(iTank)] == 0 || !g_bShield2[iTank])
	{
		g_bShield2[iTank] = false;

		return Plugin_Stop;
	}

	g_bShield2[iTank] = false;

	vShieldAbility(iTank, true);

	return Plugin_Continue;
}

public Action tTimerShieldThrow(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || g_iShieldAbility[MT_GetTankType(iTank)] == 0 || !g_bShield[iTank])
	{
		return Plugin_Stop;
	}

	if (g_iShieldType[MT_GetTankType(iTank)] != 1 && g_iShieldType[MT_GetTankType(iTank)] != 2)
	{
		return Plugin_Stop;
	}

	float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);

	float flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		int iThrowable = CreateEntityByName("prop_physics");
		if (bIsValidEntity(iThrowable))
		{
			switch (g_iShieldType[MT_GetTankType(iTank)])
			{
				case 1: SetEntityModel(iThrowable, MODEL_PROPANETANK);
				case 2: SetEntityModel(iThrowable, MODEL_GASCAN);
			}

			float flPos[3];
			GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
			RemoveEntity(iRock);

			NormalizeVector(flVelocity, flVelocity);
			ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

			DispatchSpawn(iThrowable);
			TeleportEntity(iThrowable, flPos, NULL_VECTOR, flVelocity);
		}

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerStopShield(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bShield[iTank])
	{
		vShieldAbility(iTank, false);

		return Plugin_Stop;
	}

	vShieldAbility(iTank, false);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bShield2[iTank])
	{
		g_bShield2[iTank] = false;

		return Plugin_Stop;
	}

	g_bShield2[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ShieldHuman6");

	return Plugin_Continue;
}