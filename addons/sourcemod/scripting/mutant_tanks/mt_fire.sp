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

#file "Fire Ability v8.79"

public Plugin myinfo =
{
	name = "[MT] Fire Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates fires.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Fire Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"

#define SOUND_EXPLODE "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_1.wav"

#define MT_MENU_FIRE "Fire Ability"

enum struct esPlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flFireChance;
	float g_flFireDeathChance;
	float g_flFireRange;
	float g_flFireRangeChance;
	float g_flFireRockChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iFireAbility;
	int g_iFireDeath;
	int g_iFireEffect;
	int g_iFireHit;
	int g_iFireHitMode;
	int g_iFireMessage;
	int g_iFireRockBreak;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flFireChance;
	float g_flFireDeathChance;
	float g_flFireRange;
	float g_flFireRangeChance;
	float g_flFireRockChance;

	int g_iAccessFlags;
	int g_iFireAbility;
	int g_iFireDeath;
	int g_iFireEffect;
	int g_iFireHit;
	int g_iFireHitMode;
	int g_iFireMessage;
	int g_iFireRockBreak;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flFireChance;
	float g_flFireDeathChance;
	float g_flFireRange;
	float g_flFireRangeChance;
	float g_flFireRockChance;

	int g_iFireAbility;
	int g_iFireDeath;
	int g_iFireEffect;
	int g_iFireHit;
	int g_iFireHitMode;
	int g_iFireMessage;
	int g_iFireRockBreak;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_fire", cmdFireInfo, "View information about the Fire ability.");

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

	PrecacheSound(SOUND_EXPLODE, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveFire(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveFire(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFireInfo(int client, int args)
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
		case false: vFireMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFireMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFireMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fire Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iFireMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iFireAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "FireDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vFireMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "FireMenu", param1);
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
	menu.AddItem(MT_MENU_FIRE, MT_MENU_FIRE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_FIRE, false))
	{
		vFireMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_FIRE, false))
	{
		FormatEx(buffer, size, "%T", "FireMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iFireHitMode == 0 || g_esCache[attacker].g_iFireHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vFireHit(victim, attacker, g_esCache[attacker].g_flFireChance, g_esCache[attacker].g_iFireHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iFireHitMode == 0 || g_esCache[victim].g_iFireHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vFireHit(attacker, victim, g_esCache[victim].g_flFireChance, g_esCache[victim].g_iFireHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("fireability");
	list2.PushString("fire ability");
	list3.PushString("fire_ability");
	list4.PushString("fire");
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
				g_esAbility[iIndex].g_iFireAbility = 0;
				g_esAbility[iIndex].g_iFireEffect = 0;
				g_esAbility[iIndex].g_iFireMessage = 0;
				g_esAbility[iIndex].g_flFireChance = 33.3;
				g_esAbility[iIndex].g_iFireDeath = 0;
				g_esAbility[iIndex].g_flFireDeathChance = 200.0;
				g_esAbility[iIndex].g_iFireHit = 0;
				g_esAbility[iIndex].g_iFireHitMode = 0;
				g_esAbility[iIndex].g_flFireRange = 150.0;
				g_esAbility[iIndex].g_flFireRangeChance = 15.0;
				g_esAbility[iIndex].g_iFireRockBreak = 0;
				g_esAbility[iIndex].g_flFireRockChance = 33.3;
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
					g_esPlayer[iPlayer].g_iFireAbility = 0;
					g_esPlayer[iPlayer].g_iFireEffect = 0;
					g_esPlayer[iPlayer].g_iFireMessage = 0;
					g_esPlayer[iPlayer].g_flFireChance = 0.0;
					g_esPlayer[iPlayer].g_iFireDeath = 0;
					g_esPlayer[iPlayer].g_flFireDeathChance = 0.0;
					g_esPlayer[iPlayer].g_iFireHit = 0;
					g_esPlayer[iPlayer].g_iFireHitMode = 0;
					g_esPlayer[iPlayer].g_flFireRange = 0.0;
					g_esPlayer[iPlayer].g_flFireRangeChance = 0.0;
					g_esPlayer[iPlayer].g_iFireRockBreak = 0;
					g_esPlayer[iPlayer].g_flFireRockChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iFireAbility = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iFireAbility, value, 0, 1);
		g_esPlayer[admin].g_iFireEffect = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iFireEffect, value, 0, 7);
		g_esPlayer[admin].g_iFireMessage = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iFireMessage, value, 0, 7);
		g_esPlayer[admin].g_flFireChance = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireChance", "Fire Chance", "Fire_Chance", "chance", g_esPlayer[admin].g_flFireChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iFireDeath = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireDeath", "Fire Death", "Fire_Death", "death", g_esPlayer[admin].g_iFireDeath, value, 0, 1);
		g_esPlayer[admin].g_flFireDeathChance = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireDeathChance", "Fire Death Chance", "Fire_Death_Chance", "deathchance", g_esPlayer[admin].g_flFireDeathChance, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iFireHit = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireHit", "Fire Hit", "Fire_Hit", "hit", g_esPlayer[admin].g_iFireHit, value, 0, 1);
		g_esPlayer[admin].g_iFireHitMode = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireHitMode", "Fire Hit Mode", "Fire_Hit_Mode", "hitmode", g_esPlayer[admin].g_iFireHitMode, value, 0, 2);
		g_esPlayer[admin].g_flFireRange = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireRange", "Fire Range", "Fire_Range", "range", g_esPlayer[admin].g_flFireRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flFireRangeChance = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireRangeChance", "Fire Range Chance", "Fire_Range_Chance", "rangechance", g_esPlayer[admin].g_flFireRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iFireRockBreak = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireRockBreak", "Fire Rock Break", "Fire_Rock_Break", "rock", g_esPlayer[admin].g_iFireRockBreak, value, 0, 1);
		g_esPlayer[admin].g_flFireRockChance = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireRockChance", "Fire Rock Chance", "Fire_Rock_Chance", "rockchance", g_esPlayer[admin].g_flFireRockChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "fireability", false) || StrEqual(subsection, "fire ability", false) || StrEqual(subsection, "fire_ability", false) || StrEqual(subsection, "fire", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iFireAbility = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iFireAbility, value, 0, 1);
		g_esAbility[type].g_iFireEffect = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iFireEffect, value, 0, 7);
		g_esAbility[type].g_iFireMessage = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iFireMessage, value, 0, 7);
		g_esAbility[type].g_flFireChance = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireChance", "Fire Chance", "Fire_Chance", "chance", g_esAbility[type].g_flFireChance, value, 0.0, 100.0);
		g_esAbility[type].g_iFireDeath = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireDeath", "Fire Death", "Fire_Death", "death", g_esAbility[type].g_iFireDeath, value, 0, 1);
		g_esAbility[type].g_flFireDeathChance = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireDeathChance", "Fire Death Chance", "Fire_Death_Chance", "deathchance", g_esAbility[type].g_flFireDeathChance, value, 1.0, 999999.0);
		g_esAbility[type].g_iFireHit = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireHit", "Fire Hit", "Fire_Hit", "hit", g_esAbility[type].g_iFireHit, value, 0, 1);
		g_esAbility[type].g_iFireHitMode = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireHitMode", "Fire Hit Mode", "Fire_Hit_Mode", "hitmode", g_esAbility[type].g_iFireHitMode, value, 0, 2);
		g_esAbility[type].g_flFireRange = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireRange", "Fire Range", "Fire_Range", "range", g_esAbility[type].g_flFireRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flFireRangeChance = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireRangeChance", "Fire Range Chance", "Fire_Range_Chance", "rangechance", g_esAbility[type].g_flFireRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iFireRockBreak = iGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireRockBreak", "Fire Rock Break", "Fire_Rock_Break", "rock", g_esAbility[type].g_iFireRockBreak, value, 0, 1);
		g_esAbility[type].g_flFireRockChance = flGetKeyValue(subsection, "fireability", "fire ability", "fire_ability", "fire", key, "FireRockChance", "Fire Rock Chance", "Fire_Rock_Chance", "rockchance", g_esAbility[type].g_flFireRockChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "fireability", false) || StrEqual(subsection, "fire ability", false) || StrEqual(subsection, "fire_ability", false) || StrEqual(subsection, "fire", false))
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
	g_esCache[tank].g_flFireChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFireChance, g_esAbility[type].g_flFireChance);
	g_esCache[tank].g_flFireDeathChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFireDeathChance, g_esAbility[type].g_flFireDeathChance);
	g_esCache[tank].g_flFireRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFireRange, g_esAbility[type].g_flFireRange);
	g_esCache[tank].g_flFireRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFireRangeChance, g_esAbility[type].g_flFireRangeChance);
	g_esCache[tank].g_flFireRockChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFireRockChance, g_esAbility[type].g_flFireRockChance);
	g_esCache[tank].g_iFireAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFireAbility, g_esAbility[type].g_iFireAbility);
	g_esCache[tank].g_iFireDeath = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFireDeath, g_esAbility[type].g_iFireDeath);
	g_esCache[tank].g_iFireEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFireEffect, g_esAbility[type].g_iFireEffect);
	g_esCache[tank].g_iFireHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFireHit, g_esAbility[type].g_iFireHit);
	g_esCache[tank].g_iFireHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFireHitMode, g_esAbility[type].g_iFireHitMode);
	g_esCache[tank].g_iFireMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFireMessage, g_esAbility[type].g_iFireMessage);
	g_esCache[tank].g_iFireRockBreak = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFireRockBreak, g_esAbility[type].g_iFireRockBreak);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vFireRange(iTank);
			vRemoveFire(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iFireAbility == 1)
	{
		vFireAbility(tank);
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
			if (g_esCache[tank].g_iFireAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "FireHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vFireAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveFire(tank);

	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank) && g_esCache[tank].g_iFireAbility == 1)
	{
		if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
		{
			return;
		}

		static float flPos[3];
		GetClientAbsOrigin(tank, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);
	}
}

public void MT_OnPostTankSpawn(int tank)
{
	vFireRange(tank);
}

public void MT_OnRockBreak(int tank, int rock)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank) && g_esCache[tank].g_iFireRockBreak == 1)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flFireRockChance)
		{
			static float flPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
			vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);

			if (g_esCache[tank].g_iFireMessage & MT_MESSAGE_SPECIAL)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Fire2", sTankName);
			}
		}
	}
}

static void vFireAbility(int tank)
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
				if (flDistance <= g_esCache[tank].g_flFireRange)
				{
					vFireHit(iSurvivor, tank, g_esCache[tank].g_flFireRangeChance, g_esCache[tank].g_iFireAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "FireHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FireAmmo");
	}
}

static void vFireHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
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
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "FireHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "FireHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static float flPos[3];
				GetClientAbsOrigin(survivor, flPos);
				vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);

				vEffect(survivor, tank, g_esCache[tank].g_iFireEffect, flags);
				EmitSoundToAll(SOUND_EXPLODE, survivor);

				if (g_esCache[tank].g_iFireMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Fire", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "FireHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "FireAmmo");
		}
	}
}

static void vFireRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(tank) && g_esCache[tank].g_iFireDeath == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flFireDeathChance)
	{
		if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((MT_HasAdminAccess(tank) && bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
		{
			return;
		}

		static float flPos[3];
		GetClientAbsOrigin(tank, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);
	}
}

static void vRemoveFire(int tank)
{
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveFire(iPlayer);
		}
	}
}