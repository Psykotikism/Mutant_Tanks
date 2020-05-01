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
#tryinclude <mt_clone>
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

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bGravity;
	bool g_bGravity2;
	bool g_bGravity3;
	bool g_bGravity4;
	bool g_bGravity5;
	bool g_bGravity6;
	bool g_bGravity7;

	float g_flOriginalGravity;

	int g_iGravity;
	int g_iAccessFlags2;
	int g_iGravityCount;
	int g_iGravityCount2;
	int g_iGravityOwner;
	int g_iImmunityFlags2;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flGravityChance;
	float g_flGravityDuration;
	float g_flGravityForce;
	float g_flGravityRange;
	float g_flGravityRangeChance;
	float g_flGravityValue;
	float g_flHumanCooldown;

	int g_iAccessFlags;
	int g_iGravityAbility;
	int g_iGravityEffect;
	int g_iGravityHit;
	int g_iGravityHitMode;
	int g_iGravityMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanMode;
	int g_iImmunityFlags;
}

esAbilitySettings g_esAbility[MT_MAXTYPES + 1];

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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iGravityAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iGravityCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iGravityCount2, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GravityDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flGravityDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
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
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_esAbility[MT_GetTankType(attacker)].g_iGravityHitMode == 0 || g_esAbility[MT_GetTankType(attacker)].g_iGravityHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGravityHit(victim, attacker, g_esAbility[MT_GetTankType(attacker)].g_flGravityChance, g_esAbility[MT_GetTankType(attacker)].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_esAbility[MT_GetTankType(victim)].g_iGravityHitMode == 0 || g_esAbility[MT_GetTankType(victim)].g_iGravityHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGravityHit(attacker, victim, g_esAbility[MT_GetTankType(victim)].g_flGravityChance, g_esAbility[MT_GetTankType(victim)].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("gravityability");
	list2.PushString("gravity ability");
	list3.PushString("gravity_ability");
	list4.PushString("gravity");
}

public void MT_OnConfigsLoad(int mode)
{
	if (mode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				g_esPlayer[iPlayer].g_iAccessFlags2 = 0;
				g_esPlayer[iPlayer].g_iImmunityFlags2 = 0;
			}
		}
	}
	else if (mode == 1)
	{
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			g_esAbility[iIndex].g_iAccessFlags = 0;
			g_esAbility[iIndex].g_iImmunityFlags = 0;
			g_esAbility[iIndex].g_iHumanAbility = 0;
			g_esAbility[iIndex].g_iHumanAmmo = 5;
			g_esAbility[iIndex].g_flHumanCooldown = 30.0;
			g_esAbility[iIndex].g_iHumanMode = 1;
			g_esAbility[iIndex].g_iGravityAbility = 0;
			g_esAbility[iIndex].g_iGravityEffect = 0;
			g_esAbility[iIndex].g_iGravityMessage = 0;
			g_esAbility[iIndex].g_flGravityChance = 33.3;
			g_esAbility[iIndex].g_flGravityDuration = 5.0;
			g_esAbility[iIndex].g_flGravityForce = -50.0;
			g_esAbility[iIndex].g_flGravityRange = 150.0;
			g_esAbility[iIndex].g_iGravityHit = 0;
			g_esAbility[iIndex].g_iGravityHitMode = 0;
			g_esAbility[iIndex].g_flGravityRangeChance = 15.0;
			g_esAbility[iIndex].g_flGravityValue = 0.3;
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
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iImmunityFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iGravityAbility = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iGravityAbility, value, 0, 3);
		g_esAbility[type].g_iGravityEffect = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iGravityEffect, value, 0, 7);
		g_esAbility[type].g_iGravityMessage = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iGravityMessage, value, 0, 7);
		g_esAbility[type].g_flGravityChance = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityChance", "Gravity Chance", "Gravity_Chance", "chance", g_esAbility[type].g_flGravityChance, value, 0.0, 100.0);
		g_esAbility[type].g_flGravityDuration = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityDuration", "Gravity Duration", "Gravity_Duration", "duration", g_esAbility[type].g_flGravityDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_flGravityForce = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityForce", "Gravity Force", "Gravity_Force", "force", g_esAbility[type].g_flGravityForce, value, -100.0, 100.0);
		g_esAbility[type].g_iGravityHit = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHit", "Gravity Hit", "Gravity_Hit", "hit", g_esAbility[type].g_iGravityHit, value, 0, 1);
		g_esAbility[type].g_iGravityHitMode = iGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHitMode", "Gravity Hit Mode", "Gravity_Hit_Mode", "hitmode", g_esAbility[type].g_iGravityHitMode, value, 0, 2);
		g_esAbility[type].g_flGravityRange = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRange", "Gravity Range", "Gravity_Range", "range", g_esAbility[type].g_flGravityRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flGravityRangeChance = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRangeChance", "Gravity Range Chance", "Gravity_Range_Chance", "rangechance", g_esAbility[type].g_flGravityRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_flGravityValue = flGetValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityValue", "Gravity Value", "Gravity_Value", "value", g_esAbility[type].g_flGravityValue, value, 0.1, 999999.0);

		if (StrEqual(subsection, "gravityability", false) || StrEqual(subsection, "gravity ability", false) || StrEqual(subsection, "gravity_ability", false) || StrEqual(subsection, "gravity", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iAccessFlags;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iImmunityFlags;
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
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveGravity(iTank);

			vReset2(iTank);
		}
	}

	if (StrEqual(name, "player_spawn"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_ALIVE))
		{
			g_esPlayer[iSurvivor].g_flOriginalGravity = GetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue");
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iGravityAbility > 0)
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
			if ((g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esAbility[MT_GetTankType(tank)].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bGravity && !g_esPlayer[tank].g_bGravity3)
						{
							vGravityAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bGravity)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman4");
						}
						else if (g_esPlayer[tank].g_bGravity3)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman5");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iGravityCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bGravity && !g_esPlayer[tank].g_bGravity3)
							{
								g_esPlayer[tank].g_bGravity = true;
								g_esPlayer[tank].g_iGravityCount++;

								g_esPlayer[tank].g_iGravity = CreateEntityByName("point_push");
								if (bIsValidEntity(g_esPlayer[tank].g_iGravity))
								{
									vGravity(tank);
								}

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman", g_esPlayer[tank].g_iGravityCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bGravity)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman4");
							}
							else if (g_esPlayer[tank].g_bGravity3)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman5");
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
			if ((g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 1 || g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (!g_esPlayer[tank].g_bGravity4 && !g_esPlayer[tank].g_bGravity5)
				{
					vGravityAbility(tank, true);
				}
				else if (g_esPlayer[tank].g_bGravity4)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman6");
				}
				else if (g_esPlayer[tank].g_bGravity5)
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
			if ((g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (g_esAbility[MT_GetTankType(tank)].g_iHumanMode == 1 && g_esPlayer[tank].g_bGravity && !g_esPlayer[tank].g_bGravity3)
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

	DispatchKeyValueVector(g_esPlayer[tank].g_iGravity, "origin", flOrigin);
	DispatchKeyValueVector(g_esPlayer[tank].g_iGravity, "angles", flAngles);
	DispatchKeyValue(g_esPlayer[tank].g_iGravity, "radius", "750");
	DispatchKeyValueFloat(g_esPlayer[tank].g_iGravity, "magnitude", g_esAbility[MT_GetTankType(tank)].g_flGravityForce);
	DispatchKeyValue(g_esPlayer[tank].g_iGravity, "spawnflags", "8");
	vSetEntityParent(g_esPlayer[tank].g_iGravity, tank, true);
	AcceptEntityInput(g_esPlayer[tank].g_iGravity, "Enable");
	g_esPlayer[tank].g_iGravity = EntIndexToEntRef(g_esPlayer[tank].g_iGravity);
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
			if (g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 1 || g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 3)
			{
				if (g_esPlayer[tank].g_iGravityCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
				{
					g_esPlayer[tank].g_bGravity6 = false;
					g_esPlayer[tank].g_bGravity7 = false;

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
							if (flDistance <= g_esAbility[MT_GetTankType(tank)].g_flGravityRange)
							{
								vGravityHit(iSurvivor, tank, g_esAbility[MT_GetTankType(tank)].g_flGravityRangeChance, g_esAbility[MT_GetTankType(tank)].g_iGravityAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman8");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iGravityAbility == 3) && !g_esPlayer[tank].g_bGravity)
			{
				if (g_esPlayer[tank].g_iGravityCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
				{
					g_esPlayer[tank].g_bGravity = true;

					g_esPlayer[tank].g_iGravity = CreateEntityByName("point_push");
					if (bIsValidEntity(g_esPlayer[tank].g_iGravity))
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
						{
							g_esPlayer[tank].g_iGravityCount++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman", g_esPlayer[tank].g_iGravityCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
						}

						vGravity(tank);

						DataPack dpGravity;
						CreateDataTimer(g_esAbility[MT_GetTankType(tank)].g_flGravityDuration, tTimerGravity, dpGravity, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpGravity.WriteCell(GetClientUserId(tank));
						dpGravity.WriteCell(MT_GetTankType(tank));
						dpGravity.WriteFloat(GetEngineTime());

						if (g_esAbility[MT_GetTankType(tank)].g_iGravityMessage & MT_MESSAGE_SPECIAL)
						{
							char sTankName[33];
							MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity3", sTankName);
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
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
		if (g_esPlayer[tank].g_iGravityCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bGravity2)
			{
				g_esPlayer[survivor].g_bGravity2 = true;
				g_esPlayer[survivor].g_iGravityOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bGravity4)
				{
					g_esPlayer[tank].g_bGravity4 = true;
					g_esPlayer[tank].g_iGravityCount2++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman2", g_esPlayer[tank].g_iGravityCount2, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
				}

				g_esPlayer[survivor].g_flOriginalGravity = GetEntityGravity(survivor);
				SetEntityGravity(survivor, g_esAbility[MT_GetTankType(tank)].g_flGravityValue);

				DataPack dpStopGravity;
				CreateDataTimer(g_esAbility[MT_GetTankType(tank)].g_flGravityDuration, tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
				dpStopGravity.WriteCell(GetClientUserId(survivor));
				dpStopGravity.WriteCell(GetClientUserId(tank));
				dpStopGravity.WriteCell(messages);

				vEffect(survivor, tank, g_esAbility[MT_GetTankType(tank)].g_iGravityEffect, flags);

				if (g_esAbility[MT_GetTankType(tank)].g_iGravityMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity", sTankName, survivor, g_esAbility[MT_GetTankType(tank)].g_flGravityValue);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bGravity4)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bGravity6)
				{
					g_esPlayer[tank].g_bGravity6 = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bGravity7)
		{
			g_esPlayer[tank].g_bGravity7 = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo2");
		}
	}
}

static void vRemoveGravity(int tank)
{
	if (bIsValidEntRef(g_esPlayer[tank].g_iGravity))
	{
		g_esPlayer[tank].g_iGravity = EntRefToEntIndex(g_esPlayer[tank].g_iGravity);
		if (bIsValidEntity(g_esPlayer[tank].g_iGravity))
		{
			RemoveEntity(g_esPlayer[tank].g_iGravity);
		}
	}

	g_esPlayer[tank].g_iGravity = INVALID_ENT_REFERENCE;

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bGravity2 && g_esPlayer[iSurvivor].g_iGravityOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bGravity2 = false;
			g_esPlayer[iSurvivor].g_iGravityOwner = 0;

			SetEntityGravity(iSurvivor, g_esPlayer[iSurvivor].g_flOriginalGravity);
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

			g_esPlayer[iPlayer].g_iGravityOwner = 0;
		}
	}
}

static void vReset2(int tank, bool revert = false)
{
	if (!revert)
	{
		g_esPlayer[tank].g_bGravity = false;
	}

	g_esPlayer[tank].g_bGravity2 = false;
	g_esPlayer[tank].g_bGravity3 = false;
	g_esPlayer[tank].g_bGravity4 = false;
	g_esPlayer[tank].g_bGravity5 = false;
	g_esPlayer[tank].g_bGravity6 = false;
	g_esPlayer[tank].g_bGravity7 = false;
	g_esPlayer[tank].g_flOriginalGravity = 1.0;
	g_esPlayer[tank].g_iGravity = INVALID_ENT_REFERENCE;
	g_esPlayer[tank].g_iGravityCount = 0;
	g_esPlayer[tank].g_iGravityCount2 = 0;
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bGravity = false;
	g_esPlayer[tank].g_bGravity3 = true;

	if (bIsValidEntRef(g_esPlayer[tank].g_iGravity))
	{
		g_esPlayer[tank].g_iGravity = EntRefToEntIndex(g_esPlayer[tank].g_iGravity);
		if (bIsValidEntity(g_esPlayer[tank].g_iGravity))
		{
			RemoveEntity(g_esPlayer[tank].g_iGravity);
		}
	}

	g_esPlayer[tank].g_iGravity = INVALID_ENT_REFERENCE;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman9");

	if (g_esPlayer[tank].g_iGravityCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bGravity3 = false;
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_esAbility[MT_GetTankType(admin)].g_iAccessFlags;
	if (iAbilityFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iAbilityFlags)) ? false : true;
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iTypeFlags)) ? false : true;
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iGlobalFlags)) ? false : true;
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
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

	int iAbilityFlags = g_esAbility[MT_GetTankType(tank)].g_iImmunityFlags;
	if (iAbilityFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iAbilityFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iTypeFlags = MT_GetImmunityFlags(2, MT_GetTankType(tank));
	if (iTypeFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iTypeFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iGlobalFlags = MT_GetImmunityFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iGlobalFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iClientTypeFlags = MT_GetImmunityFlags(4, MT_GetTankType(tank), survivor),
		iClientTypeFlags2 = MT_GetImmunityFlags(4, MT_GetTankType(tank), tank);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
	{
		return (iClientTypeFlags2 != 0 && (iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
	}

	int iClientGlobalFlags = MT_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = MT_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
	{
		return (iClientGlobalFlags2 != 0 && (iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
	}

	int iSurvivorFlags = GetUserFlagBits(survivor), iTankFlags = GetUserFlagBits(tank);
	if (iAbilityFlags != 0 && iSurvivorFlags != 0 && (iSurvivorFlags & iAbilityFlags))
	{
		return (iTankFlags != 0 && iSurvivorFlags <= iTankFlags) ? false : true;
	}

	return false;
}

public Action tTimerGravity(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || !g_esPlayer[iTank].g_bGravity)
	{
		g_esPlayer[iTank].g_bGravity = false;

		if (bIsValidEntRef(g_esPlayer[iTank].g_iGravity))
		{
			g_esPlayer[iTank].g_iGravity = EntRefToEntIndex(g_esPlayer[iTank].g_iGravity);
			if (bIsValidEntity(g_esPlayer[iTank].g_iGravity))
			{
				RemoveEntity(g_esPlayer[iTank].g_iGravity);
			}
		}

		g_esPlayer[iTank].g_iGravity = INVALID_ENT_REFERENCE;

		if (g_esAbility[MT_GetTankType(iTank)].g_iGravityMessage & MT_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity4", sTankName);
		}

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0 && (flTime + g_esAbility[MT_GetTankType(iTank)].g_flGravityDuration) < GetEngineTime() && !g_esPlayer[iTank].g_bGravity3)
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
		g_esPlayer[iSurvivor].g_bGravity2 = false;
		g_esPlayer[iSurvivor].g_iGravityOwner = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iSurvivor].g_bGravity2)
	{
		g_esPlayer[iSurvivor].g_bGravity2 = false;
		g_esPlayer[iSurvivor].g_iGravityOwner = 0;

		SetEntityGravity(iSurvivor, g_esPlayer[iSurvivor].g_flOriginalGravity);

		return Plugin_Stop;
	}

	g_esPlayer[iSurvivor].g_bGravity2 = false;
	g_esPlayer[iTank].g_bGravity4 = false;
	g_esPlayer[iSurvivor].g_iGravityOwner = 0;

	SetEntityGravity(iSurvivor, g_esPlayer[iSurvivor].g_flOriginalGravity);

	int iMessage = pack.ReadCell();

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && (iMessage & MT_MESSAGE_RANGE) && !g_esPlayer[iTank].g_bGravity5)
	{
		g_esPlayer[iTank].g_bGravity5 = true;

		MT_PrintToChat(iTank, "%s %t", MT_TAG3, "GravityHuman10");

		if (g_esPlayer[iTank].g_iGravityCount2 < g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo > 0)
		{
			CreateTimer(g_esAbility[MT_GetTankType(iTank)].g_flHumanCooldown, tTimerResetCooldown2, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_esPlayer[iTank].g_bGravity5 = false;
		}
	}

	if (g_esAbility[MT_GetTankType(iTank)].g_iGravityMessage & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bGravity3)
	{
		g_esPlayer[iTank].g_bGravity3 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bGravity3 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "GravityHuman11");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bGravity5)
	{
		g_esPlayer[iTank].g_bGravity5 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bGravity5 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "GravityHuman12");

	return Plugin_Continue;
}