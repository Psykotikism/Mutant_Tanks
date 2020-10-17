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

//#file "Smite Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Smite Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank smites survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Smite Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SPRITE_GLOW "sprites/glow.vmt"

#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"

#define MT_MENU_SMITE "Smite Ability"

enum struct esPlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flSmiteChance;
	float g_flSmiteRange;
	float g_flSmiteRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iSmiteAbility;
	int g_iSmiteEffect;
	int g_iSmiteHit;
	int g_iSmiteHitMode;
	int g_iSmiteMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flSmiteChance;
	float g_flSmiteRange;
	float g_flSmiteRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iSmiteAbility;
	int g_iSmiteEffect;
	int g_iSmiteHit;
	int g_iSmiteHitMode;
	int g_iSmiteMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flSmiteChance;
	float g_flSmiteRange;
	float g_flSmiteRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iSmiteAbility;
	int g_iSmiteEffect;
	int g_iSmiteHit;
	int g_iSmiteHitMode;
	int g_iSmiteMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

bool g_bCloneInstalled;

int g_iSmiteSprite = -1;

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

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_smite", cmdSmiteInfo, "View information about the Smite ability.");

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
	g_iSmiteSprite = PrecacheModel(SPRITE_GLOW, true);

	PrecacheSound(SOUND_EXPLOSION, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveSmite(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveSmite(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdSmiteInfo(int client, int args)
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
		case false: vSmiteMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vSmiteMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iSmiteMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Smite Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iSmiteMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iSmiteAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "SmiteDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vSmiteMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "SmiteMenu", param1);
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
	menu.AddItem(MT_MENU_SMITE, MT_MENU_SMITE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_SMITE, false))
	{
		vSmiteMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_SMITE, false))
	{
		FormatEx(buffer, size, "%T", "SmiteMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage > 0.0)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_esCache[attacker].g_iSmiteHitMode == 0 || g_esCache[attacker].g_iSmiteHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSmiteHit(victim, attacker, g_esCache[attacker].g_flSmiteChance, g_esCache[attacker].g_iSmiteHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_esCache[victim].g_iSmiteHitMode == 0 || g_esCache[victim].g_iSmiteHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSmiteHit(attacker, victim, g_esCache[victim].g_flSmiteChance, g_esCache[victim].g_iSmiteHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("smiteability");
	list2.PushString("smite ability");
	list3.PushString("smite_ability");
	list4.PushString("smite");
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
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iSmiteAbility = 0;
				g_esAbility[iIndex].g_iSmiteEffect = 0;
				g_esAbility[iIndex].g_iSmiteMessage = 0;
				g_esAbility[iIndex].g_flSmiteChance = 33.3;
				g_esAbility[iIndex].g_iSmiteHit = 0;
				g_esAbility[iIndex].g_iSmiteHitMode = 0;
				g_esAbility[iIndex].g_flSmiteRange = 150.0;
				g_esAbility[iIndex].g_flSmiteRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iSmiteAbility = 0;
					g_esPlayer[iPlayer].g_iSmiteEffect = 0;
					g_esPlayer[iPlayer].g_iSmiteMessage = 0;
					g_esPlayer[iPlayer].g_flSmiteChance = 0.0;
					g_esPlayer[iPlayer].g_iSmiteHit = 0;
					g_esPlayer[iPlayer].g_iSmiteHitMode = 0;
					g_esPlayer[iPlayer].g_flSmiteRange = 0.0;
					g_esPlayer[iPlayer].g_flSmiteRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iSmiteAbility = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iSmiteAbility, value, 0, 1);
		g_esPlayer[admin].g_iSmiteEffect = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iSmiteEffect, value, 0, 7);
		g_esPlayer[admin].g_iSmiteMessage = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iSmiteMessage, value, 0, 3);
		g_esPlayer[admin].g_flSmiteChance = flGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteChance", "Smite Chance", "Smite_Chance", "chance", g_esPlayer[admin].g_flSmiteChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iSmiteHit = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteHit", "Smite Hit", "Smite_Hit", "hit", g_esPlayer[admin].g_iSmiteHit, value, 0, 1);
		g_esPlayer[admin].g_iSmiteHitMode = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteHitMode", "Smite Hit Mode", "Smite_Hit_Mode", "hitmode", g_esPlayer[admin].g_iSmiteHitMode, value, 0, 2);
		g_esPlayer[admin].g_flSmiteRange = flGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteRange", "Smite Range", "Smite_Range", "range", g_esPlayer[admin].g_flSmiteRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flSmiteRangeChance = flGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteRangeChance", "Smite Range Chance", "Smite_Range_Chance", "rangechance", g_esPlayer[admin].g_flSmiteRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "smiteability", false) || StrEqual(subsection, "smite ability", false) || StrEqual(subsection, "smite_ability", false) || StrEqual(subsection, "smite", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iSmiteAbility = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iSmiteAbility, value, 0, 1);
		g_esAbility[type].g_iSmiteEffect = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iSmiteEffect, value, 0, 7);
		g_esAbility[type].g_iSmiteMessage = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iSmiteMessage, value, 0, 3);
		g_esAbility[type].g_flSmiteChance = flGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteChance", "Smite Chance", "Smite_Chance", "chance", g_esAbility[type].g_flSmiteChance, value, 0.0, 100.0);
		g_esAbility[type].g_iSmiteHit = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteHit", "Smite Hit", "Smite_Hit", "hit", g_esAbility[type].g_iSmiteHit, value, 0, 1);
		g_esAbility[type].g_iSmiteHitMode = iGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteHitMode", "Smite Hit Mode", "Smite_Hit_Mode", "hitmode", g_esAbility[type].g_iSmiteHitMode, value, 0, 2);
		g_esAbility[type].g_flSmiteRange = flGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteRange", "Smite Range", "Smite_Range", "range", g_esAbility[type].g_flSmiteRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flSmiteRangeChance = flGetKeyValue(subsection, "smiteability", "smite ability", "smite_ability", "smite", key, "SmiteRangeChance", "Smite Range Chance", "Smite_Range_Chance", "rangechance", g_esAbility[type].g_flSmiteRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "smiteability", false) || StrEqual(subsection, "smite ability", false) || StrEqual(subsection, "smite_ability", false) || StrEqual(subsection, "smite", false))
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
	g_esCache[tank].g_flSmiteChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSmiteChance, g_esAbility[type].g_flSmiteChance);
	g_esCache[tank].g_flSmiteRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSmiteRange, g_esAbility[type].g_flSmiteRange);
	g_esCache[tank].g_flSmiteRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flSmiteRangeChance, g_esAbility[type].g_flSmiteRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iSmiteAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSmiteAbility, g_esAbility[type].g_iSmiteAbility);
	g_esCache[tank].g_iSmiteEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSmiteEffect, g_esAbility[type].g_iSmiteEffect);
	g_esCache[tank].g_iSmiteHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSmiteHit, g_esAbility[type].g_iSmiteHit);
	g_esCache[tank].g_iSmiteHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSmiteHitMode, g_esAbility[type].g_iSmiteHitMode);
	g_esCache[tank].g_iSmiteMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iSmiteMessage, g_esAbility[type].g_iSmiteMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveSmite(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esCache[tank].g_iSmiteAbility == 1)
	{
		vSmiteAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iSmiteAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vSmiteAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveSmite(tank);
}

static void vRemoveSmite(int tank)
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
			vRemoveSmite(iPlayer);
		}
	}
}

static void vSmite(int survivor)
{
	float flPosition[3], flStartPosition[3];
	int iColor[4] = {255, 255, 255, 255};

	GetClientAbsOrigin(survivor, flPosition);
	flPosition[2] -= 26;
	flStartPosition[0] = flPosition[0] + GetRandomInt(-500, 500);
	flStartPosition[1] = flPosition[1] + GetRandomInt(-500, 500);
	flStartPosition[2] = flPosition[2] + 800;

	TE_SetupBeamPoints(flStartPosition, flPosition, g_iSmiteSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
	TE_SendToAll();

	TE_SetupSparks(flPosition, view_as<float>({0.0, 0.0, 0.0}), 5000, 1000);
	TE_SendToAll();

	TE_SetupEnergySplash(flPosition, view_as<float>({0.0, 0.0, 0.0}), false);
	TE_SendToAll();

	EmitAmbientSound(SOUND_EXPLOSION, flStartPosition, survivor, SNDLEVEL_RAIDSIREN);
}

static void vSmiteAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
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
				if (flDistance <= g_esCache[tank].g_flSmiteRange)
				{
					vSmiteHit(iSurvivor, tank, g_esCache[tank].g_flSmiteRangeChance, g_esCache[tank].g_iSmiteAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteAmmo");
	}
}

static void vSmiteHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				vSmite(survivor);
				ForcePlayerSuicide(survivor);

				vEffect(survivor, tank, g_esCache[tank].g_iSmiteEffect, flags);

				if (g_esCache[tank].g_iSmiteMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Smite", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Smite", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteAmmo");
		}
	}
}