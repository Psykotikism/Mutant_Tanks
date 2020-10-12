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

//#file "Ammo Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Ammo Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank takes away survivors' ammunition.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Ammo Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_AMMO "Ammo Ability"

enum struct esPlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flAmmoChance;
	float g_flAmmoRange;
	float g_flAmmoRangeChance;

	int g_iAccessFlags;
	int g_iAmmoAbility;
	int g_iAmmoAmount;
	int g_iAmmoEffect;
	int g_iAmmoHit;
	int g_iAmmoHitMode;
	int g_iAmmoMessage;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flAmmoChance;
	float g_flAmmoRange;
	float g_flAmmoRangeChance;

	int g_iAccessFlags;
	int g_iAmmoAbility;
	int g_iAmmoAmount;
	int g_iAmmoEffect;
	int g_iAmmoHit;
	int g_iAmmoHitMode;
	int g_iAmmoMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flAmmoChance;
	float g_flAmmoRange;
	float g_flAmmoRangeChance;

	int g_iAmmoAbility;
	int g_iAmmoAmount;
	int g_iAmmoEffect;
	int g_iAmmoHit;
	int g_iAmmoHitMode;
	int g_iAmmoMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_ammo", cmdAmmoInfo, "View information about the Ammo ability.");

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

	vRemoveAmmo(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveAmmo(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdAmmoInfo(int client, int args)
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
		case false: vAmmoMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vAmmoMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iAmmoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Ammo Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iAmmoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iAmmoAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AmmoDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vAmmoMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "AmmoMenu", param1);
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
	menu.AddItem(MT_MENU_AMMO, MT_MENU_AMMO);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_AMMO, false))
	{
		vAmmoMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_AMMO, false))
	{
		FormatEx(buffer, size, "%T", "AmmoMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iAmmoHitMode == 0 || g_esCache[attacker].g_iAmmoHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAmmoHit(victim, attacker, g_esCache[attacker].g_flAmmoChance, g_esCache[attacker].g_iAmmoHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iAmmoHitMode == 0 || g_esCache[victim].g_iAmmoHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAmmoHit(attacker, victim, g_esCache[victim].g_flAmmoChance, g_esCache[victim].g_iAmmoHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("ammoability");
	list2.PushString("ammo ability");
	list3.PushString("ammo_ability");
	list4.PushString("ammo");
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
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iAmmoAbility = 0;
				g_esAbility[iIndex].g_iAmmoEffect = 0;
				g_esAbility[iIndex].g_iAmmoMessage = 0;
				g_esAbility[iIndex].g_flAmmoChance = 33.3;
				g_esAbility[iIndex].g_iAmmoAmount = 0;
				g_esAbility[iIndex].g_iAmmoHit = 0;
				g_esAbility[iIndex].g_iAmmoHitMode = 0;
				g_esAbility[iIndex].g_flAmmoRange = 150.0;
				g_esAbility[iIndex].g_flAmmoRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iAmmoAbility = 0;
					g_esPlayer[iPlayer].g_iAmmoEffect = 0;
					g_esPlayer[iPlayer].g_iAmmoMessage = 0;
					g_esPlayer[iPlayer].g_flAmmoChance = 0.0;
					g_esPlayer[iPlayer].g_iAmmoAmount = 0;
					g_esPlayer[iPlayer].g_iAmmoHit = 0;
					g_esPlayer[iPlayer].g_iAmmoHitMode = 0;
					g_esPlayer[iPlayer].g_flAmmoRange = 0.0;
					g_esPlayer[iPlayer].g_flAmmoRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iAmmoAbility = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iAmmoAbility, value, 0, 1);
		g_esPlayer[admin].g_iAmmoEffect = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iAmmoEffect, value, 0, 7);
		g_esPlayer[admin].g_iAmmoMessage = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iAmmoMessage, value, 0, 3);
		g_esPlayer[admin].g_flAmmoChance = flGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoChance", "Ammo Chance", "Ammo_Chance", "chance", g_esPlayer[admin].g_flAmmoChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iAmmoAmount = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoCount", "Ammo Count", "Ammo_Count", "count", g_esPlayer[admin].g_iAmmoAmount, value, 0, 25);
		g_esPlayer[admin].g_iAmmoHit = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoHit", "Ammo Hit", "Ammo_Hit", "hit", g_esPlayer[admin].g_iAmmoHit, value, 0, 1);
		g_esPlayer[admin].g_iAmmoHitMode = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoHitMode", "Ammo Hit Mode", "Ammo_Hit_Mode", "hitmode", g_esPlayer[admin].g_iAmmoHitMode, value, 0, 2);
		g_esPlayer[admin].g_flAmmoRange = flGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoRange", "Ammo Range", "Ammo_Range", "range", g_esPlayer[admin].g_flAmmoRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flAmmoRangeChance = flGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoRangeChance", "Ammo Range Chance", "Ammo_Range_Chance", "rangechance", g_esPlayer[admin].g_flAmmoRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "ammoability", false) || StrEqual(subsection, "ammo ability", false) || StrEqual(subsection, "ammo_ability", false) || StrEqual(subsection, "ammo", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iAmmoAbility = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iAmmoAbility, value, 0, 1);
		g_esAbility[type].g_iAmmoEffect = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iAmmoEffect, value, 0, 7);
		g_esAbility[type].g_iAmmoMessage = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iAmmoMessage, value, 0, 3);
		g_esAbility[type].g_flAmmoChance = flGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoChance", "Ammo Chance", "Ammo_Chance", "chance", g_esAbility[type].g_flAmmoChance, value, 0.0, 100.0);
		g_esAbility[type].g_iAmmoAmount = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoCount", "Ammo Count", "Ammo_Count", "count", g_esAbility[type].g_iAmmoAmount, value, 0, 25);
		g_esAbility[type].g_iAmmoHit = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoHit", "Ammo Hit", "Ammo_Hit", "hit", g_esAbility[type].g_iAmmoHit, value, 0, 1);
		g_esAbility[type].g_iAmmoHitMode = iGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoHitMode", "Ammo Hit Mode", "Ammo_Hit_Mode", "hitmode", g_esAbility[type].g_iAmmoHitMode, value, 0, 2);
		g_esAbility[type].g_flAmmoRange = flGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoRange", "Ammo Range", "Ammo_Range", "range", g_esAbility[type].g_flAmmoRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flAmmoRangeChance = flGetKeyValue(subsection, "ammoability", "ammo ability", "ammo_ability", "ammo", key, "AmmoRangeChance", "Ammo Range Chance", "Ammo_Range_Chance", "rangechance", g_esAbility[type].g_flAmmoRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "ammoability", false) || StrEqual(subsection, "ammo ability", false) || StrEqual(subsection, "ammo_ability", false) || StrEqual(subsection, "ammo", false))
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
	g_esCache[tank].g_flAmmoChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAmmoChance, g_esAbility[type].g_flAmmoChance);
	g_esCache[tank].g_flAmmoRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAmmoRange, g_esAbility[type].g_flAmmoRange);
	g_esCache[tank].g_flAmmoRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAmmoRangeChance, g_esAbility[type].g_flAmmoRangeChance);
	g_esCache[tank].g_iAmmoAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAmmoAbility, g_esAbility[type].g_iAmmoAbility);
	g_esCache[tank].g_iAmmoAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAmmoAmount, g_esAbility[type].g_iAmmoAmount);
	g_esCache[tank].g_iAmmoEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAmmoEffect, g_esAbility[type].g_iAmmoEffect);
	g_esCache[tank].g_iAmmoHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAmmoHit, g_esAbility[type].g_iAmmoHit);
	g_esCache[tank].g_iAmmoHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAmmoHitMode, g_esAbility[type].g_iAmmoHitMode);
	g_esCache[tank].g_iAmmoMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAmmoMessage, g_esAbility[type].g_iAmmoMessage);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
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
			vRemoveAmmo(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iAmmoAbility == 1)
	{
		vAmmoAbility(tank);
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

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iAmmoAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vAmmoAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveAmmo(tank);
}

static void vAmmoAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
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
				if (flDistance <= g_esCache[tank].g_flAmmoRange)
				{
					vAmmoHit(iSurvivor, tank, g_esCache[tank].g_flAmmoRangeChance, g_esCache[tank].g_iAmmoAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoAmmo");
	}
}

static void vAmmoHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (0 < iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && GetPlayerWeaponSlot(survivor, 0) > 0)
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static int iActiveWeapon;
				iActiveWeapon = GetEntPropEnt(survivor, Prop_Data, "m_hActiveWeapon");
				if (bIsValidEntity(iActiveWeapon))
				{
					static char sWeapon[32];
					GetEntityClassname(iActiveWeapon, sWeapon, sizeof(sWeapon));
					if (StrEqual(sWeapon, "weapon_rifle") || StrEqual(sWeapon, "weapon_rifle_desert") || StrEqual(sWeapon, "weapon_rifle_ak47") || StrEqual(sWeapon, "weapon_rifle_sg552"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 3);
					}
					else if (StrEqual(sWeapon, "weapon_smg") || StrEqual(sWeapon, "weapon_smg_silenced") || StrEqual(sWeapon, "weapon_smg_mp5"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 5);
					}
					else if (StrEqual(sWeapon, "weapon_pumpshotgun"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 7);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 6);
						}
					}
					else if (StrEqual(sWeapon, "weapon_shotgun_chrome"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 7);
					}
					else if (StrEqual(sWeapon, "weapon_autoshotgun"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 8);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 6);
						}
					}
					else if (StrEqual(sWeapon, "weapon_shotgun_spas"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 8);
					}
					else if (StrEqual(sWeapon, "weapon_hunting_rifle"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 9);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 2);
						}
					}
					else if (StrEqual(sWeapon, "weapon_sniper_scout") || StrEqual(sWeapon, "weapon_sniper_military") || StrEqual(sWeapon, "weapon_sniper_awp"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 10);
					}
					else if (StrEqual(sWeapon, "weapon_grenade_launcher"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", g_esCache[tank].g_iAmmoAmount, _, 17);
					}
				}

				SetEntProp(GetPlayerWeaponSlot(survivor, 0), Prop_Data, "m_iClip1", g_esCache[tank].g_iAmmoAmount, 1);

				vEffect(survivor, tank, g_esCache[tank].g_iAmmoEffect, flags);

				if (g_esCache[tank].g_iAmmoMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Ammo", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoAmmo");
		}
	}
}

static void vRemoveAmmo(int tank)
{
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveAmmo(iPlayer);
		}
	}
}