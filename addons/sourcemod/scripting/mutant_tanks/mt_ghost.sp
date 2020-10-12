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
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

//#file "Ghost Ability v8.80"

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
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"

#define SOUND_DEATH "npc/infected/action/die/male/death_42.wav"
#define SOUND_DEATH2 "npc/infected/action/die/male/death_43.wav"

#define MT_MENU_GHOST "Ghost Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bActivated2;
	bool g_bAffected[MAXPLAYERS + 1];
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iCount;
	int g_iCount2;
	int g_iDuration;
	int g_iGhostAbility;
	int g_iGhostAlpha;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;

	int g_iAccessFlags;
	int g_iGhostAbility;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;

	int g_iGhostAbility;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

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
	PrecacheSound(SOUND_DEATH, true);
	PrecacheSound(SOUND_DEATH2, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveGhost(client);
}

public void OnClientDisconnect_Post(int client)
{
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
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iGhostAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount2, g_esCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GhostDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vGhostMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "GhostMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH];

			switch (param2)
			{
				case 0:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 7:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);

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

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_GHOST, false))
	{
		FormatEx(buffer, size, "%T", "GhostMenu2", client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(client) || !g_esPlayer[client].g_bActivated2 || g_esPlayer[client].g_iDuration == -1)
	{
		return Plugin_Continue;
	}

	static int iTime;
	iTime = GetTime();
	if (g_esPlayer[client].g_iDuration < iTime)
	{
		if (g_esCache[client].g_iGhostMessage & MT_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			MT_GetTankName(client, sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Ghost3", sTankName);
		}

		g_esPlayer[client].g_bActivated2 = false;
		g_esPlayer[client].g_iGhostAlpha = 255;
		g_esPlayer[client].g_iDuration = -1;
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iGhostHitMode == 0 || g_esCache[attacker].g_iGhostHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGhostHit(victim, attacker, g_esCache[attacker].g_flGhostChance, g_esCache[attacker].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iGhostHitMode == 0 || g_esCache[victim].g_iGhostHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGhostHit(attacker, victim, g_esCache[victim].g_flGhostChance, g_esCache[victim].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esAbility[iIndex].g_iAccessFlags = 0;
				g_esAbility[iIndex].g_iImmunityFlags = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iHumanDuration = 5;
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iGhostAbility = 0;
				g_esAbility[iIndex].g_iGhostEffect = 0;
				g_esAbility[iIndex].g_iGhostMessage = 0;
				g_esAbility[iIndex].g_flGhostChance = 33.3;
				g_esAbility[iIndex].g_iGhostFadeAlpha = 2;
				g_esAbility[iIndex].g_iGhostFadeDelay = 5;
				g_esAbility[iIndex].g_iGhostFadeLimit = 0;
				g_esAbility[iIndex].g_flGhostFadeRate = 0.1;
				g_esAbility[iIndex].g_iGhostHit = 0;
				g_esAbility[iIndex].g_iGhostHitMode = 0;
				g_esAbility[iIndex].g_flGhostRange = 150.0;
				g_esAbility[iIndex].g_flGhostRangeChance = 15.0;
				g_esAbility[iIndex].g_iGhostSpecials = 1;
				g_esAbility[iIndex].g_flGhostSpecialsChance = 33.3;
				g_esAbility[iIndex].g_flGhostSpecialsRange = 500.0;
				g_esAbility[iIndex].g_iGhostWeaponSlots = 0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iImmunityFlags = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanDuration = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iGhostAbility = 0;
					g_esPlayer[iPlayer].g_iGhostEffect = 0;
					g_esPlayer[iPlayer].g_iGhostMessage = 0;
					g_esPlayer[iPlayer].g_flGhostChance = 0.0;
					g_esPlayer[iPlayer].g_iGhostFadeAlpha = 0;
					g_esPlayer[iPlayer].g_iGhostFadeDelay = 0;
					g_esPlayer[iPlayer].g_iGhostFadeLimit = 0;
					g_esPlayer[iPlayer].g_flGhostFadeRate = 0.0;
					g_esPlayer[iPlayer].g_iGhostHit = 0;
					g_esPlayer[iPlayer].g_iGhostHitMode = 0;
					g_esPlayer[iPlayer].g_flGhostRange = 0.0;
					g_esPlayer[iPlayer].g_flGhostRangeChance = 0.0;
					g_esPlayer[iPlayer].g_iGhostSpecials = 0;
					g_esPlayer[iPlayer].g_flGhostSpecialsChance = 0.0;
					g_esPlayer[iPlayer].g_flGhostSpecialsRange = 0.0;
					g_esPlayer[iPlayer].g_iGhostWeaponSlots = 0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPlayer[admin].g_iHumanDuration, value, 1, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iGhostAbility = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iGhostAbility, value, 0, 3);
		g_esPlayer[admin].g_iGhostEffect = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iGhostEffect, value, 0, 7);
		g_esPlayer[admin].g_iGhostMessage = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iGhostMessage, value, 0, 7);
		g_esPlayer[admin].g_flGhostChance = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostChance", "Ghost Chance", "Ghost_Chance", "chance", g_esPlayer[admin].g_flGhostChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iGhostFadeAlpha = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostFadeAlpha", "Ghost Fade Alpha", "Ghost_Fade_Alpha", "fadealpha", g_esPlayer[admin].g_iGhostFadeAlpha, value, 0, 255);
		g_esPlayer[admin].g_iGhostFadeDelay = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostFadeDelay", "Ghost Fade Delay", "Ghost_Fade_Delay", "fadedelay", g_esPlayer[admin].g_iGhostFadeDelay, value, 1, 999999);
		g_esPlayer[admin].g_iGhostFadeLimit = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostFadeLimit", "Ghost Fade Limit", "Ghost_Fade_Limit", "fadelimit", g_esPlayer[admin].g_iGhostFadeLimit, value, 0, 255);
		g_esPlayer[admin].g_flGhostFadeRate = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostFadeRate", "Ghost Fade Rate", "Ghost_Fade_Rate", "faderate", g_esPlayer[admin].g_flGhostFadeRate, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iGhostHit = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostHit", "Ghost Hit", "Ghost_Hit", "hit", g_esPlayer[admin].g_iGhostHit, value, 0, 1);
		g_esPlayer[admin].g_iGhostHitMode = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostHitMode", "Ghost Hit Mode", "Ghost_Hit_Mode", "hitmode", g_esPlayer[admin].g_iGhostHitMode, value, 0, 2);
		g_esPlayer[admin].g_flGhostRange = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostRange", "Ghost Range", "Ghost_Range", "range", g_esPlayer[admin].g_flGhostRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flGhostRangeChance = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostRangeChance", "Ghost Range Chance", "Ghost_Range_Chance", "rangechance", g_esPlayer[admin].g_flGhostRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iGhostSpecials = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostSpecials", "Ghost Specials", "Ghost_Specials", "specials", g_esPlayer[admin].g_iGhostSpecials, value, 0, 1);
		g_esPlayer[admin].g_flGhostSpecialsChance = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostSpecialsChance", "Ghost Specials Chance", "Ghost_Specials_Chance", "specialschance", g_esPlayer[admin].g_flGhostSpecialsChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flGhostSpecialsRange = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostSpecialsRange", "Ghost Specials Range", "Ghost_Specials_Range", "specialsrange", g_esPlayer[admin].g_flGhostSpecialsRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iGhostWeaponSlots = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostWeaponSlots", "Ghost Weapon Slots", "Ghost_Weapon_Slots", "slots", g_esPlayer[admin].g_iGhostWeaponSlots, value, 0, 31);

		if (StrEqual(subsection, "ghostability", false) || StrEqual(subsection, "ghost ability", false) || StrEqual(subsection, "ghost_ability", false) || StrEqual(subsection, "ghost", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanDuration = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_iHumanDuration, value, 1, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iGhostAbility = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iGhostAbility, value, 0, 3);
		g_esAbility[type].g_iGhostEffect = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iGhostEffect, value, 0, 7);
		g_esAbility[type].g_iGhostMessage = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iGhostMessage, value, 0, 7);
		g_esAbility[type].g_flGhostChance = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostChance", "Ghost Chance", "Ghost_Chance", "chance", g_esAbility[type].g_flGhostChance, value, 0.0, 100.0);
		g_esAbility[type].g_iGhostFadeAlpha = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostFadeAlpha", "Ghost Fade Alpha", "Ghost_Fade_Alpha", "fadealpha", g_esAbility[type].g_iGhostFadeAlpha, value, 0, 255);
		g_esAbility[type].g_iGhostFadeDelay = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostFadeDelay", "Ghost Fade Delay", "Ghost_Fade_Delay", "fadedelay", g_esAbility[type].g_iGhostFadeDelay, value, 1, 999999);
		g_esAbility[type].g_iGhostFadeLimit = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostFadeLimit", "Ghost Fade Limit", "Ghost_Fade_Limit", "fadelimit", g_esAbility[type].g_iGhostFadeLimit, value, 0, 255);
		g_esAbility[type].g_flGhostFadeRate = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostFadeRate", "Ghost Fade Rate", "Ghost_Fade_Rate", "faderate", g_esAbility[type].g_flGhostFadeRate, value, 0.1, 999999.0);
		g_esAbility[type].g_iGhostHit = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostHit", "Ghost Hit", "Ghost_Hit", "hit", g_esAbility[type].g_iGhostHit, value, 0, 1);
		g_esAbility[type].g_iGhostHitMode = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostHitMode", "Ghost Hit Mode", "Ghost_Hit_Mode", "hitmode", g_esAbility[type].g_iGhostHitMode, value, 0, 2);
		g_esAbility[type].g_flGhostRange = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostRange", "Ghost Range", "Ghost_Range", "range", g_esAbility[type].g_flGhostRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flGhostRangeChance = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostRangeChance", "Ghost Range Chance", "Ghost_Range_Chance", "rangechance", g_esAbility[type].g_flGhostRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iGhostSpecials = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostSpecials", "Ghost Specials", "Ghost_Specials", "specials", g_esAbility[type].g_iGhostSpecials, value, 0, 1);
		g_esAbility[type].g_flGhostSpecialsChance = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostSpecialsChance", "Ghost Specials Chance", "Ghost_Specials_Chance", "specialschance", g_esAbility[type].g_flGhostSpecialsChance, value, 0.0, 100.0);
		g_esAbility[type].g_flGhostSpecialsRange = flGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostSpecialsRange", "Ghost Specials Range", "Ghost_Specials_Range", "specialsrange", g_esAbility[type].g_flGhostSpecialsRange, value, 1.0, 999999.0);
		g_esAbility[type].g_iGhostWeaponSlots = iGetKeyValue(subsection, "ghostability", "ghost ability", "ghost_ability", "ghost", key, "GhostWeaponSlots", "Ghost Weapon Slots", "Ghost_Weapon_Slots", "slots", g_esAbility[type].g_iGhostWeaponSlots, value, 0, 31);

		if (StrEqual(subsection, "ghostability", false) || StrEqual(subsection, "ghost ability", false) || StrEqual(subsection, "ghost_ability", false) || StrEqual(subsection, "ghost", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flGhostChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostChance, g_esAbility[type].g_flGhostChance);
	g_esCache[tank].g_flGhostFadeRate = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostFadeRate, g_esAbility[type].g_flGhostFadeRate);
	g_esCache[tank].g_flGhostRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostRange, g_esAbility[type].g_flGhostRange);
	g_esCache[tank].g_flGhostRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostRangeChance, g_esAbility[type].g_flGhostRangeChance);
	g_esCache[tank].g_flGhostSpecialsChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostSpecialsChance, g_esAbility[type].g_flGhostSpecialsChance);
	g_esCache[tank].g_flGhostSpecialsRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostSpecialsRange, g_esAbility[type].g_flGhostSpecialsRange);
	g_esCache[tank].g_iGhostAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostAbility, g_esAbility[type].g_iGhostAbility);
	g_esCache[tank].g_iGhostEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostEffect, g_esAbility[type].g_iGhostEffect);
	g_esCache[tank].g_iGhostFadeAlpha = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostFadeAlpha, g_esAbility[type].g_iGhostFadeAlpha);
	g_esCache[tank].g_iGhostFadeDelay = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostFadeDelay, g_esAbility[type].g_iGhostFadeDelay);
	g_esCache[tank].g_iGhostFadeLimit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostFadeLimit, g_esAbility[type].g_iGhostFadeLimit);
	g_esCache[tank].g_iGhostHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostHit, g_esAbility[type].g_iGhostHit);
	g_esCache[tank].g_iGhostHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostHitMode, g_esAbility[type].g_iGhostHitMode);
	g_esCache[tank].g_iGhostMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostMessage, g_esAbility[type].g_iGhostMessage);
	g_esCache[tank].g_iGhostSpecials = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostSpecials, g_esAbility[type].g_iGhostSpecials);
	g_esCache[tank].g_iGhostWeaponSlots = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostWeaponSlots, g_esAbility[type].g_iGhostWeaponSlots);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanDuration, g_esAbility[type].g_iHumanDuration);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveGhost(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iGhostAbility > 0)
	{
		vGhostAbility(tank, true);
		vGhostAbility(tank, false);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		static int iTime;
		iTime = GetTime();
		if (button & MT_MAIN_KEY)
		{
			if ((g_esCache[tank].g_iGhostAbility == 2 || g_esCache[tank].g_iGhostAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vGhostAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman4");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman5", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esPlayer[tank].g_bActivated = true;
								g_esPlayer[tank].g_iCount++;

								vGhost(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman4");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman5", g_esPlayer[tank].g_iCooldown - iTime);
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

		if (button & MT_SUB_KEY)
		{
			if ((g_esCache[tank].g_iGhostAbility == 1 || g_esCache[tank].g_iGhostAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman6", g_esPlayer[tank].g_iCooldown2 - iTime);
					case false: vGhostAbility(tank, true);
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				vReset2(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRenderProps(tank, RENDER_NORMAL);
	vRemoveGhost(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
	{
		vRenderProps(tank, RENDER_NORMAL);
	}
}

static void vGhost(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	DataPack dpGhost;
	CreateDataTimer(g_esCache[tank].g_flGhostFadeRate, tTimerGhost, dpGhost, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpGhost.WriteCell(GetClientUserId(tank));
	dpGhost.WriteCell(g_esPlayer[tank].g_iTankType);
	dpGhost.WriteCell(GetTime());
	dpGhost.WriteFloat(GetRandomFloat(0.1, 100.0));

	SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
}

static void vGhostAbility(int tank, bool main)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esCache[tank].g_iGhostAbility == 1 || g_esCache[tank].g_iGhostAbility == 3)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bFailed = false;
					g_esPlayer[tank].g_bNoAmmo = false;

					static float flTankPos[3];
					GetClientAbsOrigin(tank, flTankPos);

					static float flSurvivorPos[3], flDistance;
					static int iSurvivorCount;
					iSurvivorCount = 0;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
						{
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);

							flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
							if (flDistance <= g_esCache[tank].g_flGhostRange)
							{
								vGhostHit(iSurvivor, tank, g_esCache[tank].g_flGhostRangeChance, g_esCache[tank].g_iGhostAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman7");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_esCache[tank].g_iGhostAbility == 2 || g_esCache[tank].g_iGhostAbility == 3) && !g_esPlayer[tank].g_bActivated)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bActivated = true;
					g_esPlayer[tank].g_iGhostAlpha = 255;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
					{
						g_esPlayer[tank].g_iCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
					}

					vGhost(tank);

					if (g_esCache[tank].g_iGhostMessage & MT_MESSAGE_SPECIAL)
					{
						static char sTankName[33];
						MT_GetTankName(tank, sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Ghost2", sTankName);
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo");
				}
			}
		}
	}
}

static void vGhostHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
				{
					g_esPlayer[tank].g_iCount2++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman2", g_esPlayer[tank].g_iCount2, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown2 = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman9", g_esPlayer[tank].g_iCooldown2 - iTime);
					}
				}

				for (int iBit = 0; iBit < 5; iBit++)
				{
					if (((g_esCache[tank].g_iGhostWeaponSlots & (1 << iBit)) || g_esCache[tank].g_iGhostWeaponSlots == 0) && GetPlayerWeaponSlot(survivor, iBit) > 0)
					{
						SDKHooks_DropWeapon(survivor, GetPlayerWeaponSlot(survivor, iBit), NULL_VECTOR, NULL_VECTOR);
					}
				}

				vEffect(survivor, tank, g_esCache[tank].g_iGhostEffect, flags);

				switch (GetRandomInt(1, 2))
				{
					case 1: EmitSoundToClient(survivor, SOUND_DEATH, tank);
					case 2: EmitSoundToClient(survivor, SOUND_DEATH2, tank);
				}

				if (g_esCache[tank].g_iGhostMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Ghost", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo2");
		}
	}
}

static void vRemoveGhost(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_bActivated2 = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCooldown2 = -1;
	g_esPlayer[tank].g_iDuration = -1;
	g_esPlayer[tank].g_iGhostAlpha = 255;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCount2 = 0;

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		g_esPlayer[tank].g_bAffected[iInfected] = false;
	}
}

static void vRenderProps(int tank, RenderMode mode, int alpha = 255)
{
	static int iProp;
	iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		static char sModel[128];
		GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		if (StrEqual(sModel, MODEL_JETPACK, false) || StrEqual(sModel, MODEL_CONCRETE_CHUNK, false) || StrEqual(sModel, MODEL_TREE_TRUNK, false) || StrEqual(sModel, MODEL_TIRES, false) || StrEqual(sModel, MODEL_PROPANETANK, false) || StrEqual(sModel, MODEL_TANK, false))
		{
			static int iOwner;
			iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == tank)
			{
				if (StrEqual(sModel, MODEL_JETPACK, false))
				{
					static int iOzTankColor[4];
					MT_GetPropColors(tank, 2, iOzTankColor[0], iOzTankColor[1], iOzTankColor[2], iOzTankColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iOzTankColor[0], iOzTankColor[1], iOzTankColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_CONCRETE_CHUNK, false) || StrEqual(sModel, MODEL_TREE_TRUNK, false))
				{
					static int iRockColor[4];
					MT_GetPropColors(tank, 4, iRockColor[0], iRockColor[1], iRockColor[2], iRockColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iRockColor[0], iRockColor[1], iRockColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_TIRES, false))
				{
					static int iTireColor[4];
					MT_GetPropColors(tank, 5, iTireColor[0], iTireColor[1], iTireColor[2], iTireColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iTireColor[0], iTireColor[1], iTireColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_PROPANETANK, false))
				{
					static int iPropTankColor[4];
					MT_GetPropColors(tank, 6, iPropTankColor[0], iPropTankColor[1], iPropTankColor[2], iPropTankColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iPropTankColor[0], iPropTankColor[1], iPropTankColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_TANK, false))
				{
					static int iSkinColor[4];
					MT_GetTankColors(tank, 1, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iSkinColor[0], iSkinColor[1], iSkinColor[2], alpha);
				}
			}
		}
	}

	while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
	{
		static int iOwner;
		iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == tank)
		{
			static int iLightColor[4];
			MT_GetPropColors(tank, 1, iLightColor[0], iLightColor[1], iLightColor[2], iLightColor[3]);
			SetEntityRenderMode(iProp, mode);
			SetEntityRenderColor(iProp, iLightColor[0], iLightColor[1], iLightColor[2], alpha);
		}
	}

	while ((iProp = FindEntityByClassname(iProp, "env_steam")) != INVALID_ENT_REFERENCE)
	{
		static int iOwner;
		iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == tank)
		{
			static int iFlameColor[4];
			MT_GetPropColors(tank, 3, iFlameColor[0], iFlameColor[1], iFlameColor[2], iFlameColor[3]);
			SetEntityRenderMode(iProp, mode);
			SetEntityRenderColor(iProp, iFlameColor[0], iFlameColor[1], iFlameColor[2], alpha);
		}
	}
}

static void vRenderSpecials(int tank, bool mode, int red, int green, int blue)
{
	if (!MT_IsTankSupported(tank))
	{
		return;
	}

	static float flTankPos[3];
	GetClientAbsOrigin(tank, flTankPos);

	static float flInfectedPos[3], flDistance;
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
		{
			if (!mode && !g_esPlayer[tank].g_bAffected[iInfected])
			{
				continue;
			}

			g_esPlayer[tank].g_bAffected[iInfected] = mode;

			GetClientAbsOrigin(iInfected, flInfectedPos);

			flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= g_esCache[tank].g_flGhostSpecialsRange)
			{
				SetEntityRenderMode(iInfected, RENDER_TRANSCOLOR);
				SetEntityRenderColor(iInfected, red, green, blue, g_esPlayer[tank].g_iGhostAlpha);
			}
		}
	}
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
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iGhostAlpha = 255;

	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman8", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

public Action tTimerGhost(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || (g_esCache[iTank].g_iGhostAbility != 2 && g_esCache[iTank].g_iGhostAbility != 3) || !g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;
		g_esPlayer[iTank].g_iGhostAlpha = 255;

		vRenderSpecials(iTank, false, 255, 255, 255);

		return Plugin_Stop;
	}

	static int iTime, iCurrenTime;
	iTime = pack.ReadCell();
	iCurrenTime = GetTime();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (iTime + g_esCache[iTank].g_iHumanDuration) < iCurrenTime && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrenTime))
	{
		vRenderSpecials(iTank, false, 255, 255, 255);
		vReset2(iTank);

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_iGhostAlpha -= g_esCache[iTank].g_iGhostFadeAlpha;

	if (g_esPlayer[iTank].g_iGhostAlpha < g_esCache[iTank].g_iGhostFadeLimit)
	{
		g_esPlayer[iTank].g_iGhostAlpha = g_esCache[iTank].g_iGhostFadeLimit;
		if (!g_esPlayer[iTank].g_bActivated2)
		{
			g_esPlayer[iTank].g_bActivated2 = true;
			g_esPlayer[iTank].g_iDuration = iCurrenTime + g_esCache[iTank].g_iGhostFadeDelay;
		}
	}

	static int iSkinColor[4];
	MT_GetTankColors(iTank, 1, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);

	vRenderProps(iTank, RENDER_TRANSCOLOR, g_esPlayer[iTank].g_iGhostAlpha);

	SetEntityRenderMode(iTank, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iTank, iSkinColor[0], iSkinColor[1], iSkinColor[2], g_esPlayer[iTank].g_iGhostAlpha);

	static float flRandom;
	flRandom = pack.ReadFloat();
	if (g_esCache[iTank].g_iGhostSpecials == 1 && flRandom <= g_esCache[iTank].g_flGhostSpecialsChance)
	{
		vRenderSpecials(iTank, true, iSkinColor[0], iSkinColor[1], iSkinColor[2]);
	}

	return Plugin_Continue;
}