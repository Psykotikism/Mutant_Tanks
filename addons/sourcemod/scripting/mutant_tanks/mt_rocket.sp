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
	name = "[MT] Rocket Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank sends survivors into space.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Rocket Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SPRITE_FIRE "sprites/sprite_fire01.vmt"

#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"
#define SOUND_FIRE "weapons/molotov/fire_ignite_1.wav"
#define SOUND_LAUNCH "player/boomer/explode/explo_medium_14.wav"

#define MT_MENU_ROCKET "Rocket Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flRocketChance;
	float g_flRocketDelay;
	float g_flRocketRange;
	float g_flRocketRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iRocketAbility;
	int g_iRocketEffect;
	int g_iRocketHit;
	int g_iRocketHitMode;
	int g_iRocketMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flRocketChance;
	float g_flRocketDelay;
	float g_flRocketRange;
	float g_flRocketRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRocketAbility;
	int g_iRocketEffect;
	int g_iRocketHit;
	int g_iRocketHitMode;
	int g_iRocketMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flRocketChance;
	float g_flRocketDelay;
	float g_flRocketRange;
	float g_flRocketRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRocketAbility;
	int g_iRocketEffect;
	int g_iRocketHit;
	int g_iRocketHitMode;
	int g_iRocketMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

int g_iRocketSprite = -1;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_rocket", cmdRocketInfo, "View information about the Rocket ability.");

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
	g_iRocketSprite = PrecacheModel(SPRITE_FIRE, true);

	PrecacheSound(SOUND_EXPLOSION, true);
	PrecacheSound(SOUND_FIRE, true);
	PrecacheSound(SOUND_LAUNCH, true);

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

public Action cmdRocketInfo(int client, int args)
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
		case false: vRocketMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRocketMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRocketMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Rocket Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRocketMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iRocketAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RocketDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vRocketMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "RocketMenu", param1);
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
	menu.AddItem(MT_MENU_ROCKET, MT_MENU_ROCKET);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ROCKET, false))
	{
		vRocketMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage > 0.0)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iRocketHitMode == 0 || g_esCache[attacker].g_iRocketHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRocketHit(victim, attacker, g_esCache[attacker].g_flRocketChance, g_esCache[attacker].g_iRocketHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iRocketHitMode == 0 || g_esCache[victim].g_iRocketHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRocketHit(attacker, victim, g_esCache[victim].g_flRocketChance, g_esCache[victim].g_iRocketHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("rocketability");
	list2.PushString("rocket ability");
	list3.PushString("rocket_ability");
	list4.PushString("rocket");
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
				g_esAbility[iIndex].g_iRocketAbility = 0;
				g_esAbility[iIndex].g_iRocketEffect = 0;
				g_esAbility[iIndex].g_iRocketMessage = 0;
				g_esAbility[iIndex].g_flRocketChance = 33.3;
				g_esAbility[iIndex].g_flRocketDelay = 1.0;
				g_esAbility[iIndex].g_iRocketHit = 0;
				g_esAbility[iIndex].g_iRocketHitMode = 0;
				g_esAbility[iIndex].g_flRocketRange = 150.0;
				g_esAbility[iIndex].g_flRocketRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iRocketAbility = 0;
					g_esPlayer[iPlayer].g_iRocketEffect = 0;
					g_esPlayer[iPlayer].g_iRocketMessage = 0;
					g_esPlayer[iPlayer].g_flRocketChance = 0.0;
					g_esPlayer[iPlayer].g_flRocketDelay = 0.0;
					g_esPlayer[iPlayer].g_iRocketHit = 0;
					g_esPlayer[iPlayer].g_iRocketHitMode = 0;
					g_esPlayer[iPlayer].g_flRocketRange = 0.0;
					g_esPlayer[iPlayer].g_flRocketRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRocketAbility = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iRocketAbility, value, 0, 1);
		g_esPlayer[admin].g_iRocketEffect = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iRocketEffect, value, 0, 7);
		g_esPlayer[admin].g_iRocketMessage = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iRocketMessage, value, 0, 3);
		g_esPlayer[admin].g_flRocketChance = flGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketChance", "Rocket Chance", "Rocket_Chance", "chance", g_esPlayer[admin].g_flRocketChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flRocketDelay = flGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketDelay", "Rocket Delay", "Rocket_Delay", "delay", g_esPlayer[admin].g_flRocketDelay, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iRocketHit = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketHit", "Rocket Hit", "Rocket_Hit", "hit", g_esPlayer[admin].g_iRocketHit, value, 0, 1);
		g_esPlayer[admin].g_iRocketHitMode = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketHitMode", "Rocket Hit Mode", "Rocket_Hit_Mode", "hitmode", g_esPlayer[admin].g_iRocketHitMode, value, 0, 2);
		g_esPlayer[admin].g_flRocketRange = flGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketRange", "Rocket Range", "Rocket_Range", "range", g_esPlayer[admin].g_flRocketRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flRocketRangeChance = flGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketRangeChance", "Rocket Range Chance", "Rocket_Range_Chance", "rangechance", g_esPlayer[admin].g_flRocketRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "rocketability", false) || StrEqual(subsection, "rocket ability", false) || StrEqual(subsection, "rocket_ability", false) || StrEqual(subsection, "rocket", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRocketAbility = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iRocketAbility, value, 0, 1);
		g_esAbility[type].g_iRocketEffect = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iRocketEffect, value, 0, 7);
		g_esAbility[type].g_iRocketMessage = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iRocketMessage, value, 0, 3);
		g_esAbility[type].g_flRocketChance = flGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketChance", "Rocket Chance", "Rocket_Chance", "chance", g_esAbility[type].g_flRocketChance, value, 0.0, 100.0);
		g_esAbility[type].g_flRocketDelay = flGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketDelay", "Rocket Delay", "Rocket_Delay", "delay", g_esAbility[type].g_flRocketDelay, value, 0.1, 999999.0);
		g_esAbility[type].g_iRocketHit = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketHit", "Rocket Hit", "Rocket_Hit", "hit", g_esAbility[type].g_iRocketHit, value, 0, 1);
		g_esAbility[type].g_iRocketHitMode = iGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketHitMode", "Rocket Hit Mode", "Rocket_Hit_Mode", "hitmode", g_esAbility[type].g_iRocketHitMode, value, 0, 2);
		g_esAbility[type].g_flRocketRange = flGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketRange", "Rocket Range", "Rocket_Range", "range", g_esAbility[type].g_flRocketRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flRocketRangeChance = flGetKeyValue(subsection, "rocketability", "rocket ability", "rocket_ability", "rocket", key, "RocketRangeChance", "Rocket Range Chance", "Rocket_Range_Chance", "rangechance", g_esAbility[type].g_flRocketRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "rocketability", false) || StrEqual(subsection, "rocket ability", false) || StrEqual(subsection, "rocket_ability", false) || StrEqual(subsection, "rocket", false))
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
	g_esCache[tank].g_flRocketChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRocketChance, g_esAbility[type].g_flRocketChance);
	g_esCache[tank].g_flRocketDelay = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRocketDelay, g_esAbility[type].g_flRocketDelay);
	g_esCache[tank].g_flRocketRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRocketRange, g_esAbility[type].g_flRocketRange);
	g_esCache[tank].g_flRocketRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRocketRangeChance, g_esAbility[type].g_flRocketRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iRocketAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketAbility, g_esAbility[type].g_iRocketAbility);
	g_esCache[tank].g_iRocketEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketEffect, g_esAbility[type].g_iRocketEffect);
	g_esCache[tank].g_iRocketHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketHit, g_esAbility[type].g_iRocketHit);
	g_esCache[tank].g_iRocketHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketHitMode, g_esAbility[type].g_iRocketHitMode);
	g_esCache[tank].g_iRocketMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRocketMessage, g_esAbility[type].g_iRocketMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected)
		{
			SetEntityGravity(iSurvivor, 1.0);
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
			vRemoveRocket(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iRocketAbility == 1)
	{
		vRocketAbility(tank);
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
			if (g_esCache[tank].g_iRocketAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vRocketAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveRocket(tank);
}

static void vRemoveRocket(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
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

static void vReset2(int survivor)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	SetEntityGravity(survivor, 1.0);
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vRocketAbility(int tank)
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
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_esCache[tank].g_flRocketRange)
				{
					vRocketHit(iSurvivor, tank, g_esCache[tank].g_flRocketRangeChance, g_esCache[tank].g_iRocketAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketAmmo");
	}
}

static void vRocketHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
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
				static int iFlame;
				iFlame = CreateEntityByName("env_steam");
				if (!bIsValidEntity(iFlame))
				{
					return;
				}

				g_esPlayer[survivor].g_bAffected = true;
				g_esPlayer[survivor].g_iOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static float flPosition[3], flAngles[3];
				GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flPosition);
				flPosition[2] += 30.0;
				flAngles[0] = 90.0;
				flAngles[1] = 0.0;
				flAngles[2] = 0.0;

				DispatchKeyValue(iFlame, "spawnflags", "1");
				DispatchKeyValue(iFlame, "Type", "0");
				DispatchKeyValue(iFlame, "InitialState", "1");
				DispatchKeyValue(iFlame, "Spreadspeed", "10");
				DispatchKeyValue(iFlame, "Speed", "800");
				DispatchKeyValue(iFlame, "Startsize", "10");
				DispatchKeyValue(iFlame, "EndSize", "250");
				DispatchKeyValue(iFlame, "Rate", "15");
				DispatchKeyValue(iFlame, "JetLength", "400");

				SetEntityRenderColor(iFlame, 180, 70, 10, 180);

				TeleportEntity(iFlame, flPosition, flAngles, NULL_VECTOR);
				DispatchSpawn(iFlame);
				vSetEntityParent(iFlame, survivor);

				iFlame = EntIndexToEntRef(iFlame);
				vDeleteEntity(iFlame, 3.0);

				EmitSoundToAll(SOUND_FIRE, survivor, _, _, _, 1.0);

				DataPack dpRocketLaunch;
				CreateDataTimer(g_esCache[tank].g_flRocketDelay, tTimerRocketLaunch, dpRocketLaunch, TIMER_FLAG_NO_MAPCHANGE);
				dpRocketLaunch.WriteCell(GetClientUserId(survivor));
				dpRocketLaunch.WriteCell(GetClientUserId(tank));
				dpRocketLaunch.WriteCell(g_esPlayer[tank].g_iTankType);
				dpRocketLaunch.WriteCell(enabled);

				DataPack dpRocketDetonate;
				CreateDataTimer(g_esCache[tank].g_flRocketDelay + 1.5, tTimerRocketDetonate, dpRocketDetonate, TIMER_FLAG_NO_MAPCHANGE);
				dpRocketDetonate.WriteCell(GetClientUserId(survivor));
				dpRocketDetonate.WriteCell(GetClientUserId(tank));
				dpRocketDetonate.WriteCell(g_esPlayer[tank].g_iTankType);
				dpRocketDetonate.WriteCell(enabled);
				dpRocketDetonate.WriteCell(messages);

				vEffect(survivor, tank, g_esCache[tank].g_iRocketEffect, flags);
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RocketAmmo");
		}
	}
}

public Action tTimerRocketLaunch(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	static int iTank, iType, iRocketEnabled;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iRocketEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || iRocketEnabled == 0 || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor);

		return Plugin_Stop;
	}

	static float flVelocity[3];
	flVelocity[0] = 0.0;
	flVelocity[1] = 0.0;
	flVelocity[2] = 800.0;

	EmitSoundToAll(SOUND_EXPLOSION, iSurvivor, _, _, _, 1.0);
	EmitSoundToAll(SOUND_LAUNCH, iSurvivor, _, _, _, 1.0);

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityGravity(iSurvivor, 0.1);

	return Plugin_Continue;
}

public Action tTimerRocketDetonate(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	static int iTank, iType, iRocketEnabled;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iRocketEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || iRocketEnabled == 0 || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor);

		return Plugin_Stop;
	}

	static float flPosition[3];
	GetClientAbsOrigin(iSurvivor, flPosition);

	TE_SetupExplosion(flPosition, g_iRocketSprite, 10.0, 1, 0, 600, 5000);
	TE_SendToAll();

	ForcePlayerSuicide(iSurvivor);
	SetEntityGravity(iSurvivor, 1.0);

	g_esPlayer[iSurvivor].g_bAffected = false;
	g_esPlayer[iSurvivor].g_iOwner = 0;

	static int iMessage;
	iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iRocketMessage & iMessage)
	{
		static char sTankName[33];
		MT_GetTankName(iTank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Rocket", sTankName, iSurvivor);
	}

	return Plugin_Continue;
}