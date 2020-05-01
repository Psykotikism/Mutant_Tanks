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
	name = "[MT] Ghost Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank cloaks itself and disarms survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Ghost Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_CONCRETE_CHUNK "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_TREE_TRUNK "models/props_foliage/tree_trunk.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"

#define SOUND_INFECTED "npc/infected/action/die/male/death_42.wav"
#define SOUND_INFECTED2 "npc/infected/action/die/male/death_43.wav"

#define MT_MENU_GHOST "Ghost Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bGhost;
	bool g_bGhost2;
	bool g_bGhost3;
	bool g_bGhost4;
	bool g_bGhost5;
	bool g_bGhost6;

	int g_iAccessFlags2;
	int g_iGhostAlpha;
	int g_iGhostCount;
	int g_iGhostCount2;
	int g_iImmunityFlags2;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flGhostChance;
	float g_flGhostFadeDelay;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flHumanCooldown;
	float g_flHumanDuration;

	int g_iAccessFlags;
	int g_iGhostAbility;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeLimit;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostWeaponSlots;
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

	RegConsoleCmd("sm_mt_ghost", cmdGhostInfo, "View information about the Ghost ability.");

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
	PrecacheSound(SOUND_INFECTED, true);
	PrecacheSound(SOUND_INFECTED2, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveGhost(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdGhostInfo(int client, int args)
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
		case false: vGhostMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vGhostMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iGhostMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Ghost Ability Information");
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

public int iGhostMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iGhostAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iGhostCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iGhostCount2, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GhostDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vGhostMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "GhostMenu", param1);
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
	menu.AddItem(MT_MENU_GHOST, MT_MENU_GHOST);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_GHOST, false))
	{
		vGhostMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_esAbility[MT_GetTankType(attacker)].g_iGhostHitMode == 0 || g_esAbility[MT_GetTankType(attacker)].g_iGhostHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGhostHit(victim, attacker, g_esAbility[MT_GetTankType(attacker)].g_flGhostChance, g_esAbility[MT_GetTankType(attacker)].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_esAbility[MT_GetTankType(victim)].g_iGhostHitMode == 0 || g_esAbility[MT_GetTankType(victim)].g_iGhostHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGhostHit(attacker, victim, g_esAbility[MT_GetTankType(victim)].g_flGhostChance, g_esAbility[MT_GetTankType(victim)].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("ghostability");
	list2.PushString("ghost ability");
	list3.PushString("ghost_ability");
	list4.PushString("ghost");
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
			g_esAbility[iIndex].g_flHumanDuration = 5.0;
			g_esAbility[iIndex].g_iHumanMode = 1;
			g_esAbility[iIndex].g_iGhostAbility = 0;
			g_esAbility[iIndex].g_iGhostEffect = 0;
			g_esAbility[iIndex].g_iGhostMessage = 0;
			g_esAbility[iIndex].g_flGhostChance = 33.3;
			g_esAbility[iIndex].g_iGhostFadeAlpha = 2;
			g_esAbility[iIndex].g_flGhostFadeDelay = 5.0;
			g_esAbility[iIndex].g_iGhostFadeLimit = 0;
			g_esAbility[iIndex].g_flGhostFadeRate = 0.1;
			g_esAbility[iIndex].g_iGhostHit = 0;
			g_esAbility[iIndex].g_iGhostHitMode = 0;
			g_esAbility[iIndex].g_flGhostRange = 150.0;
			g_esAbility[iIndex].g_flGhostRangeChance = 15.0;
			g_esAbility[iIndex].g_iGhostWeaponSlots = 0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "ghostability", false) || StrEqual(subsection, "ghost ability", false) || StrEqual(subsection, "ghomt_ability", false) || StrEqual(subsection, "ghost", false))
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
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_flHumanDuration = flGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_flHumanDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iGhostAbility = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iGhostAbility, value, 0, 3);
		g_esAbility[type].g_iGhostEffect = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iGhostEffect, value, 0, 7);
		g_esAbility[type].g_iGhostMessage = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iGhostMessage, value, 0, 7);
		g_esAbility[type].g_flGhostChance = flGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostChance", "Ghost Chance", "Ghomt_Chance", "chance", g_esAbility[type].g_flGhostChance, value, 0.0, 100.0);
		g_esAbility[type].g_iGhostFadeAlpha = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostFadeAlpha", "Ghost Fade Alpha", "Ghomt_Fade_Alpha", "fadealpha", g_esAbility[type].g_iGhostFadeAlpha, value, 0, 255);
		g_esAbility[type].g_flGhostFadeDelay = flGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostFadeDelay", "Ghost Fade Delay", "Ghomt_Fade_Delay", "fadedelay", g_esAbility[type].g_flGhostFadeDelay, value, 0.1, 999999.0);
		g_esAbility[type].g_iGhostFadeLimit = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostFadeLimit", "Ghost Fade Limit", "Ghomt_Fade_Limit", "fadelimit", g_esAbility[type].g_iGhostFadeLimit, value, 0, 255);
		g_esAbility[type].g_flGhostFadeRate = flGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostFadeRate", "Ghost Fade Rate", "Ghomt_Fade_Rate", "faderate", g_esAbility[type].g_flGhostFadeRate, value, 0.1, 999999.0);
		g_esAbility[type].g_iGhostHit = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostHit", "Ghost Hit", "Ghomt_Hit", "hit", g_esAbility[type].g_iGhostHit, value, 0, 1);
		g_esAbility[type].g_iGhostHitMode = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostHitMode", "Ghost Hit Mode", "Ghomt_Hit_Mode", "hitmode", g_esAbility[type].g_iGhostHitMode, value, 0, 2);
		g_esAbility[type].g_flGhostRange = flGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostRange", "Ghost Range", "Ghomt_Range", "range", g_esAbility[type].g_flGhostRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flGhostRangeChance = flGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostRangeChance", "Ghost Range Chance", "Ghomt_Range_Chance", "rangechance", g_esAbility[type].g_flGhostRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iGhostWeaponSlots = iGetValue(subsection, "ghostability", "ghost ability", "ghomt_ability", "ghost", key, "GhostWeaponSlots", "Ghost Weapon Slots", "Ghomt_Weapon_Slots", "slots", g_esAbility[type].g_iGhostWeaponSlots, value, 0, 31);

		if (StrEqual(subsection, "ghostability", false) || StrEqual(subsection, "ghost ability", false) || StrEqual(subsection, "ghomt_ability", false) || StrEqual(subsection, "ghost", false))
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

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vGhostRender(iTank, RENDER_NORMAL);
			vRemoveGhost(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iGhostAbility > 0)
	{
		vGhostAbility(tank, true);
		vGhostAbility(tank, false);
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
			if ((g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esAbility[MT_GetTankType(tank)].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bGhost && !g_esPlayer[tank].g_bGhost3)
						{
							vGhostAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bGhost)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman4");
						}
						else if (g_esPlayer[tank].g_bGhost3)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman5");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iGhostCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bGhost && !g_esPlayer[tank].g_bGhost3)
							{
								g_esPlayer[tank].g_bGhost = true;
								g_esPlayer[tank].g_iGhostCount++;

								vGhost(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman", g_esPlayer[tank].g_iGhostCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bGhost)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman4");
							}
							else if (g_esPlayer[tank].g_bGhost3)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman5");
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if ((g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 1 || g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_bGhost4)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman6");
					case false: vGhostAbility(tank, true);
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
			if ((g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (g_esAbility[MT_GetTankType(tank)].g_iHumanMode == 1 && g_esPlayer[tank].g_bGhost && !g_esPlayer[tank].g_bGhost3)
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vGhostRender(tank, RENDER_NORMAL);
	vRemoveGhost(tank);
}

static void vGhost(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	DataPack dpGhost;
	CreateDataTimer(g_esAbility[MT_GetTankType(tank)].g_flGhostFadeRate, tTimerGhost, dpGhost, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpGhost.WriteCell(GetClientUserId(tank));
	dpGhost.WriteCell(MT_GetTankType(tank));
	dpGhost.WriteFloat(GetEngineTime());

	SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
}

static void vGhostAbility(int tank, bool main)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 1 || g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 3)
			{
				if (g_esPlayer[tank].g_iGhostCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
				{
					g_esPlayer[tank].g_bGhost5 = false;
					g_esPlayer[tank].g_bGhost6 = false;

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
							if (flDistance <= g_esAbility[MT_GetTankType(tank)].g_flGhostRange)
							{
								vGhostHit(iSurvivor, tank, g_esAbility[MT_GetTankType(tank)].g_flGhostRangeChance, g_esAbility[MT_GetTankType(tank)].g_iGhostAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman7");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iGhostAbility == 3) && !g_esPlayer[tank].g_bGhost)
			{
				if (g_esPlayer[tank].g_iGhostCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
				{
					g_esPlayer[tank].g_bGhost = true;
					g_esPlayer[tank].g_iGhostAlpha = 255;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
					{
						g_esPlayer[tank].g_iGhostCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman", g_esPlayer[tank].g_iGhostCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
					}

					vGhost(tank);

					if (g_esAbility[MT_GetTankType(tank)].g_iGhostMessage & MT_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Ghost2", sTankName);
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo");
				}
			}
		}
	}
}

static void vGhostHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_esPlayer[tank].g_iGhostCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bGhost4)
				{
					g_esPlayer[tank].g_bGhost4 = true;
					g_esPlayer[tank].g_iGhostCount2++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman2", g_esPlayer[tank].g_iGhostCount2, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);

					if (g_esPlayer[tank].g_iGhostCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
					{
						CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown2, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_esPlayer[tank].g_bGhost4 = false;
					}
				}

				for (int iBit = 0; iBit < 5; iBit++)
				{
					if ((g_esAbility[MT_GetTankType(tank)].g_iGhostWeaponSlots & (1 << iBit)) || g_esAbility[MT_GetTankType(tank)].g_iGhostWeaponSlots == 0)
					{
						if (GetPlayerWeaponSlot(survivor, iBit) > 0)
						{
							SDKHooks_DropWeapon(survivor, GetPlayerWeaponSlot(survivor, iBit), NULL_VECTOR, NULL_VECTOR);
						}
					}
				}

				switch (GetRandomInt(1, 2))
				{
					case 1: EmitSoundToClient(survivor, SOUND_INFECTED, tank);
					case 2: EmitSoundToClient(survivor, SOUND_INFECTED2, tank);
				}

				vEffect(survivor, tank, g_esAbility[MT_GetTankType(tank)].g_iGhostEffect, flags);

				if (g_esAbility[MT_GetTankType(tank)].g_iGhostMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Ghost", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bGhost4)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bGhost5)
				{
					g_esPlayer[tank].g_bGhost5 = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bGhost6)
		{
			g_esPlayer[tank].g_bGhost6 = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo2");
		}
	}
}

static void vGhostRender(int tank, RenderMode mode, int alpha = 255)
{
	int iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		char sModel[128];
		GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		if (StrEqual(sModel, MODEL_JETPACK, false) || StrEqual(sModel, MODEL_CONCRETE_CHUNK, false) || StrEqual(sModel, MODEL_TREE_TRUNK, false) || StrEqual(sModel, MODEL_TIRES, false) || StrEqual(sModel, MODEL_TANK, false))
		{
			int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == tank)
			{
				if (StrEqual(sModel, MODEL_JETPACK, false))
				{
					int iOzTankColor[4];
					MT_GetPropColors(tank, 2, iOzTankColor[0], iOzTankColor[1], iOzTankColor[2], iOzTankColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iOzTankColor[0], iOzTankColor[1], iOzTankColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_CONCRETE_CHUNK, false) || StrEqual(sModel, MODEL_TREE_TRUNK, false))
				{
					int iRockColor[4];
					MT_GetPropColors(tank, 4, iRockColor[0], iRockColor[1], iRockColor[2], iRockColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iRockColor[0], iRockColor[1], iRockColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_TIRES, false))
				{
					int iTireColor[4];
					MT_GetPropColors(tank, 5, iTireColor[0], iTireColor[1], iTireColor[2], iTireColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iTireColor[0], iTireColor[1], iTireColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_TANK, false))
				{
					int iSkinColor[4];
					MT_GetTankColors(tank, 1, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iSkinColor[0], iSkinColor[1], iSkinColor[2], alpha);
				}
			}
		}
	}

	while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == tank)
		{
			int iLightColor[4];
			MT_GetPropColors(tank, 1, iLightColor[0], iLightColor[1], iLightColor[2], iLightColor[3]);
			SetEntityRenderMode(iProp, mode);
			SetEntityRenderColor(iProp, iLightColor[0], iLightColor[1], iLightColor[2], alpha);
		}
	}

	while ((iProp = FindEntityByClassname(iProp, "env_steam")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == tank)
		{
			int iFlameColor[4];
			MT_GetPropColors(tank, 3, iFlameColor[0], iFlameColor[1], iFlameColor[2], iFlameColor[3]);
			SetEntityRenderMode(iProp, mode);
			SetEntityRenderColor(iProp, iFlameColor[0], iFlameColor[1], iFlameColor[2], alpha);
		}
	}
}

static void vRemoveGhost(int tank)
{
	g_esPlayer[tank].g_bGhost = false;
	g_esPlayer[tank].g_bGhost2 = false;
	g_esPlayer[tank].g_bGhost3 = false;
	g_esPlayer[tank].g_bGhost4 = false;
	g_esPlayer[tank].g_bGhost5 = false;
	g_esPlayer[tank].g_bGhost6 = false;
	g_esPlayer[tank].g_iGhostAlpha = 255;
	g_esPlayer[tank].g_iGhostCount = 0;
	g_esPlayer[tank].g_iGhostCount2 = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveGhost(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bGhost = false;
	g_esPlayer[tank].g_bGhost3 = true;
	g_esPlayer[tank].g_iGhostAlpha = 255;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman8");

	if (g_esPlayer[tank].g_iGhostCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bGhost3 = false;
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

public Action tTimerGhost(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || (g_esAbility[MT_GetTankType(iTank)].g_iGhostAbility != 2 && g_esAbility[MT_GetTankType(iTank)].g_iGhostAbility != 3) || !g_esPlayer[iTank].g_bGhost)
	{
		g_esPlayer[iTank].g_bGhost = false;
		g_esPlayer[iTank].g_iGhostAlpha = 255;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0 && (flTime + g_esAbility[MT_GetTankType(iTank)].g_flHumanDuration) < GetEngineTime() && !g_esPlayer[iTank].g_bGhost3)
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_iGhostAlpha -= g_esAbility[MT_GetTankType(iTank)].g_iGhostFadeAlpha;

	if (g_esPlayer[iTank].g_iGhostAlpha < g_esAbility[MT_GetTankType(iTank)].g_iGhostFadeLimit)
	{
		g_esPlayer[iTank].g_iGhostAlpha = g_esAbility[MT_GetTankType(iTank)].g_iGhostFadeLimit;
		if (!g_esPlayer[iTank].g_bGhost2)
		{
			g_esPlayer[iTank].g_bGhost2 = true;

			CreateTimer(g_esAbility[MT_GetTankType(iTank)].g_flGhostFadeDelay, tTimerStopGhost, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	int iSkinColor[4];
	MT_GetTankColors(iTank, 1, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);

	vGhostRender(iTank, RENDER_TRANSCOLOR, g_esPlayer[iTank].g_iGhostAlpha);

	SetEntityRenderMode(iTank, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iTank, iSkinColor[0], iSkinColor[1], iSkinColor[2], g_esPlayer[iTank].g_iGhostAlpha);

	return Plugin_Continue;
}

public Action tTimerStopGhost(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bGhost2)
	{
		g_esPlayer[iTank].g_bGhost2 = false;
		g_esPlayer[iTank].g_iGhostAlpha = 255;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bGhost2 = false;
	g_esPlayer[iTank].g_iGhostAlpha = 255;

	if (g_esAbility[MT_GetTankType(iTank)].g_iGhostMessage & MT_MESSAGE_SPECIAL)
	{
		char sTankName[33];
		MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Ghost3", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bGhost3)
	{
		g_esPlayer[iTank].g_bGhost3 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bGhost3 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "GhostHuman9");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bGhost4)
	{
		g_esPlayer[iTank].g_bGhost4 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bGhost4 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "GhostHuman10");

	return Plugin_Continue;
}