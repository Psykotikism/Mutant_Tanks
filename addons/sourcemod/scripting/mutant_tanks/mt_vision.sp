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

public Plugin myinfo =
{
	name = "[MT] Vision Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank changes the survivors' field of view.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Vision Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_VISION "Vision Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flVisionChance;
	float g_flVisionRange;
	float g_flVisionRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iTankType;
	int g_iVisionAbility;
	int g_iVisionDuration;
	int g_iVisionEffect;
	int g_iVisionFOV;
	int g_iVisionHit;
	int g_iVisionHitMode;
	int g_iVisionMessage;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flVisionChance;
	float g_flVisionRange;
	float g_flVisionRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iVisionAbility;
	int g_iVisionDuration;
	int g_iVisionEffect;
	int g_iVisionFOV;
	int g_iVisionHit;
	int g_iVisionHitMode;
	int g_iVisionMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flVisionChance;
	float g_flVisionRange;
	float g_flVisionRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iVisionAbility;
	int g_iVisionDuration;
	int g_iVisionEffect;
	int g_iVisionFOV;
	int g_iVisionHit;
	int g_iVisionHitMode;
	int g_iVisionMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_vision", cmdVisionInfo, "View information about the Vision ability.");

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

	vReset3(client);
}

public void OnClientDisconnect_Post(int client)
{
	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdVisionInfo(int client, int args)
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
		case false: vVisionMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vVisionMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iVisionMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Vision Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iVisionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iVisionAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "VisionDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iVisionDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vVisionMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "VisionMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];

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
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 6:
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
	menu.AddItem(MT_MENU_VISION, MT_MENU_VISION);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_VISION, false))
	{
		vVisionMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iVisionHitMode == 0 || g_esCache[attacker].g_iVisionHitMode == 1) && bIsHumanSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vVisionHit(victim, attacker, g_esCache[attacker].g_flVisionChance, g_esCache[attacker].g_iVisionHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iVisionHitMode == 0 || g_esCache[victim].g_iVisionHitMode == 2) && bIsHumanSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vVisionHit(attacker, victim, g_esCache[victim].g_flVisionChance, g_esCache[victim].g_iVisionHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("visionability");
	list2.PushString("vision ability");
	list3.PushString("vision_ability");
	list4.PushString("vision");
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
				g_esAbility[iIndex].g_iVisionAbility = 0;
				g_esAbility[iIndex].g_iVisionEffect = 0;
				g_esAbility[iIndex].g_iVisionMessage = 0;
				g_esAbility[iIndex].g_flVisionChance = 33.3;
				g_esAbility[iIndex].g_iVisionDuration = 5;
				g_esAbility[iIndex].g_iVisionFOV = 160;
				g_esAbility[iIndex].g_iVisionHit = 0;
				g_esAbility[iIndex].g_iVisionHitMode = 0;
				g_esAbility[iIndex].g_flVisionRange = 150.0;
				g_esAbility[iIndex].g_flVisionRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iVisionAbility = 0;
					g_esPlayer[iPlayer].g_iVisionEffect = 0;
					g_esPlayer[iPlayer].g_iVisionMessage = 0;
					g_esPlayer[iPlayer].g_flVisionChance = 0.0;
					g_esPlayer[iPlayer].g_iVisionDuration = 0;
					g_esPlayer[iPlayer].g_iVisionFOV = 0;
					g_esPlayer[iPlayer].g_iVisionHit = 0;
					g_esPlayer[iPlayer].g_iVisionHitMode = 0;
					g_esPlayer[iPlayer].g_flVisionRange = 0.0;
					g_esPlayer[iPlayer].g_flVisionRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iVisionAbility = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iVisionAbility, value, 0, 1);
		g_esPlayer[admin].g_iVisionEffect = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iVisionEffect, value, 0, 7);
		g_esPlayer[admin].g_iVisionMessage = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iVisionMessage, value, 0, 3);
		g_esPlayer[admin].g_flVisionChance = flGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionChance", "Vision Chance", "Vision_Chance", "chance", g_esPlayer[admin].g_flVisionChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iVisionDuration = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionDuration", "Vision Duration", "Vision_Duration", "duration", g_esPlayer[admin].g_iVisionDuration, value, 1, 999999);
		g_esPlayer[admin].g_iVisionFOV = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionFOV", "Vision FOV", "Vision_FOV", "fov", g_esPlayer[admin].g_iVisionFOV, value, 1, 160);
		g_esPlayer[admin].g_iVisionHit = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionHit", "Vision Hit", "Vision_Hit", "hit", g_esPlayer[admin].g_iVisionHit, value, 0, 1);
		g_esPlayer[admin].g_iVisionHitMode = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionHitMode", "Vision Hit Mode", "Vision_Hit_Mode", "hitmode", g_esPlayer[admin].g_iVisionHitMode, value, 0, 2);
		g_esPlayer[admin].g_flVisionRange = flGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionRange", "Vision Range", "Vision_Range", "range", g_esPlayer[admin].g_flVisionRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flVisionRangeChance = flGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionRangeChance", "Vision Range Chance", "Vision_Range_Chance", "rangechance", g_esPlayer[admin].g_flVisionRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "visionability", false) || StrEqual(subsection, "vision ability", false) || StrEqual(subsection, "vision_ability", false) || StrEqual(subsection, "vision", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iVisionAbility = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iVisionAbility, value, 0, 1);
		g_esAbility[type].g_iVisionEffect = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iVisionEffect, value, 0, 7);
		g_esAbility[type].g_iVisionMessage = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iVisionMessage, value, 0, 3);
		g_esAbility[type].g_flVisionChance = flGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionChance", "Vision Chance", "Vision_Chance", "chance", g_esAbility[type].g_flVisionChance, value, 0.0, 100.0);
		g_esAbility[type].g_iVisionDuration = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionDuration", "Vision Duration", "Vision_Duration", "duration", g_esAbility[type].g_iVisionDuration, value, 1, 999999);
		g_esAbility[type].g_iVisionFOV = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionFOV", "Vision FOV", "Vision_FOV", "fov", g_esAbility[type].g_iVisionFOV, value, 1, 160);
		g_esAbility[type].g_iVisionHit = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionHit", "Vision Hit", "Vision_Hit", "hit", g_esAbility[type].g_iVisionHit, value, 0, 1);
		g_esAbility[type].g_iVisionHitMode = iGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionHitMode", "Vision Hit Mode", "Vision_Hit_Mode", "hitmode", g_esAbility[type].g_iVisionHitMode, value, 0, 2);
		g_esAbility[type].g_flVisionRange = flGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionRange", "Vision Range", "Vision_Range", "range", g_esAbility[type].g_flVisionRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flVisionRangeChance = flGetKeyValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionRangeChance", "Vision Range Chance", "Vision_Range_Chance", "rangechance", g_esAbility[type].g_flVisionRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "visionability", false) || StrEqual(subsection, "vision ability", false) || StrEqual(subsection, "vision_ability", false) || StrEqual(subsection, "vision", false))
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
	g_esCache[tank].g_flVisionChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flVisionChance, g_esAbility[type].g_flVisionChance);
	g_esCache[tank].g_flVisionRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flVisionRange, g_esAbility[type].g_flVisionRange);
	g_esCache[tank].g_flVisionRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flVisionRangeChance, g_esAbility[type].g_flVisionRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iVisionAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iVisionAbility, g_esAbility[type].g_iVisionAbility);
	g_esCache[tank].g_iVisionDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iVisionDuration, g_esAbility[type].g_iVisionDuration);
	g_esCache[tank].g_iVisionEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iVisionEffect, g_esAbility[type].g_iVisionEffect);
	g_esCache[tank].g_iVisionFOV = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iVisionFOV, g_esAbility[type].g_iVisionFOV);
	g_esCache[tank].g_iVisionHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iVisionHit, g_esAbility[type].g_iVisionHit);
	g_esCache[tank].g_iVisionHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iVisionHitMode, g_esAbility[type].g_iVisionHitMode);
	g_esCache[tank].g_iVisionMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iVisionMessage, g_esAbility[type].g_iVisionMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected)
		{
			SetEntProp(iSurvivor, Prop_Send, "m_iFOV", 90);
			SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", 90);
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
			vRemoveVision(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iVisionAbility == 1)
	{
		vVisionAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iVisionAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vVisionAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveVision(tank);
}

static void vRemoveVision(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset3(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	SetEntProp(survivor, Prop_Send, "m_iFOV", 90);
	SetEntProp(survivor, Prop_Send, "m_iDefaultFOV", 90);

	if (g_esCache[tank].g_iVisionMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Vision2", survivor, 90);
	}
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vVisionAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
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
			if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_esCache[tank].g_flVisionRange)
				{
					vVisionHit(iSurvivor, tank, g_esCache[tank].g_flVisionRangeChance, g_esCache[tank].g_iVisionAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionAmmo");
	}
}

static void vVisionHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				g_esPlayer[survivor].g_bAffected = true;
				g_esPlayer[survivor].g_iOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				DataPack dpVision;
				CreateDataTimer(0.1, tTimerVision, dpVision, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpVision.WriteCell(GetClientUserId(survivor));
				dpVision.WriteCell(GetClientUserId(tank));
				dpVision.WriteCell(g_esPlayer[tank].g_iTankType);
				dpVision.WriteCell(messages);
				dpVision.WriteCell(enabled);
				dpVision.WriteCell(GetTime());

				vEffect(survivor, tank, g_esCache[tank].g_iVisionEffect, flags);

				if (g_esCache[tank].g_iVisionMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Vision", sTankName, survivor, g_esCache[tank].g_iVisionFOV);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionAmmo");
		}
	}
}

public Action tTimerVision(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsHumanSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	static int iTank, iType, iMessage;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static int iVisionEnabled, iTime;
	iVisionEnabled = pack.ReadCell();
	iTime = pack.ReadCell();
	if (iVisionEnabled == 0 || (iTime + g_esCache[iTank].g_iVisionDuration) < GetTime())
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	SetEntProp(iSurvivor, Prop_Send, "m_iFOV", g_esCache[iTank].g_iVisionFOV);
	SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", g_esCache[iTank].g_iVisionFOV);

	return Plugin_Continue;
}