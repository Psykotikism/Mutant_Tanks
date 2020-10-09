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

#file "Hurt Ability v8.79"

public Plugin myinfo =
{
	name = "[MT] Hurt Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank repeatedly hurts survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Hurt Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_PAIN "player/tank/voice/pain/tank_fire_08.wav"
#define SOUND_ATTACK "player/pz/voice/attack/zombiedog_attack2.wav"

#define MT_MENU_HURT "Hurt Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flHurtChance;
	float g_flHurtDamage;
	float g_flHurtInterval;
	float g_flHurtRange;
	float g_flHurtRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHurtAbility;
	int g_iHurtDuration;
	int g_iHurtEffect;
	int g_iHurtHit;
	int g_iHurtHitMode;
	int g_iHurtMessage;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flHurtChance;
	float g_flHurtDamage;
	float g_flHurtInterval;
	float g_flHurtRange;
	float g_flHurtRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHurtAbility;
	int g_iHurtDuration;
	int g_iHurtEffect;
	int g_iHurtHit;
	int g_iHurtHitMode;
	int g_iHurtMessage;
	int g_iImmunityFlags;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flHurtChance;
	float g_flHurtDamage;
	float g_flHurtInterval;
	float g_flHurtRange;
	float g_flHurtRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHurtAbility;
	int g_iHurtDuration;
	int g_iHurtEffect;
	int g_iHurtHit;
	int g_iHurtHitMode;
	int g_iHurtMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_hurt", cmdHurtInfo, "View information about the Hurt ability.");

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
	PrecacheSound(SOUND_ATTACK, true);

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

public Action cmdHurtInfo(int client, int args)
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
		case false: vHurtMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vHurtMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iHurtMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Hurt Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iHurtMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHurtAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "HurtDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iHurtDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vHurtMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "HurtMenu", param1);
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
	menu.AddItem(MT_MENU_HURT, MT_MENU_HURT);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_HURT, false))
	{
		vHurtMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_HURT, false))
	{
		FormatEx(buffer, size, "%T", "HurtMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iHurtHitMode == 0 || g_esCache[attacker].g_iHurtHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHurtHit(victim, attacker, g_esCache[attacker].g_flHurtChance, g_esCache[attacker].g_iHurtHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iHurtHitMode == 0 || g_esCache[victim].g_iHurtHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vHurtHit(attacker, victim, g_esCache[victim].g_flHurtChance, g_esCache[victim].g_iHurtHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("hurtability");
	list2.PushString("hurt ability");
	list3.PushString("hurt_ability");
	list4.PushString("hurt");
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
				g_esAbility[iIndex].g_iHurtAbility = 0;
				g_esAbility[iIndex].g_iHurtEffect = 0;
				g_esAbility[iIndex].g_iHurtMessage = 0;
				g_esAbility[iIndex].g_flHurtChance = 33.3;
				g_esAbility[iIndex].g_flHurtDamage = 5.0;
				g_esAbility[iIndex].g_iHurtDuration = 5;
				g_esAbility[iIndex].g_iHurtHit = 0;
				g_esAbility[iIndex].g_iHurtHitMode = 0;
				g_esAbility[iIndex].g_flHurtInterval = 1.0;
				g_esAbility[iIndex].g_flHurtRange = 150.0;
				g_esAbility[iIndex].g_flHurtRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iHurtAbility = 0;
					g_esPlayer[iPlayer].g_iHurtEffect = 0;
					g_esPlayer[iPlayer].g_iHurtMessage = 0;
					g_esPlayer[iPlayer].g_flHurtChance = 0.0;
					g_esPlayer[iPlayer].g_flHurtDamage = 0.0;
					g_esPlayer[iPlayer].g_iHurtDuration = 0;
					g_esPlayer[iPlayer].g_iHurtHit = 0;
					g_esPlayer[iPlayer].g_iHurtHitMode = 0;
					g_esPlayer[iPlayer].g_flHurtInterval = 0.0;
					g_esPlayer[iPlayer].g_flHurtRange = 0.0;
					g_esPlayer[iPlayer].g_flHurtRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHurtAbility = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iHurtAbility, value, 0, 1);
		g_esPlayer[admin].g_iHurtEffect = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iHurtEffect, value, 0, 7);
		g_esPlayer[admin].g_iHurtMessage = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iHurtMessage, value, 0, 3);
		g_esPlayer[admin].g_flHurtChance = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtChance", "Hurt Chance", "Hurt_Chance", "chance", g_esPlayer[admin].g_flHurtChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flHurtDamage = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtDamage", "Hurt Damage", "Hurt_Damage", "damage", g_esPlayer[admin].g_flHurtDamage, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iHurtDuration = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtDuration", "Hurt Duration", "Hurt_Duration", "duration", g_esPlayer[admin].g_iHurtDuration, value, 1, 999999);
		g_esPlayer[admin].g_iHurtHit = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtHit", "Hurt Hit", "Hurt_Hit", "hit", g_esPlayer[admin].g_iHurtHit, value, 0, 1);
		g_esPlayer[admin].g_iHurtHitMode = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtHitMode", "Hurt Hit Mode", "Hurt_Hit_Mode", "hitmode", g_esPlayer[admin].g_iHurtHitMode, value, 0, 2);
		g_esPlayer[admin].g_flHurtInterval = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtInterval", "Hurt Interval", "Hurt_Interval", "interval", g_esPlayer[admin].g_flHurtInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flHurtRange = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtRange", "Hurt Range", "Hurt_Range", "range", g_esPlayer[admin].g_flHurtRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flHurtRangeChance = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtRangeChance", "Hurt Range Chance", "Hurt_Range_Chance", "rangechance", g_esPlayer[admin].g_flHurtRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "hurtability", false) || StrEqual(subsection, "hurt ability", false) || StrEqual(subsection, "hurt_ability", false) || StrEqual(subsection, "hurt", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHurtAbility = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iHurtAbility, value, 0, 1);
		g_esAbility[type].g_iHurtEffect = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iHurtEffect, value, 0, 7);
		g_esAbility[type].g_iHurtMessage = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iHurtMessage, value, 0, 3);
		g_esAbility[type].g_flHurtChance = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtChance", "Hurt Chance", "Hurt_Chance", "chance", g_esAbility[type].g_flHurtChance, value, 0.0, 100.0);
		g_esAbility[type].g_flHurtDamage = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtDamage", "Hurt Damage", "Hurt_Damage", "damage", g_esAbility[type].g_flHurtDamage, value, 1.0, 999999.0);
		g_esAbility[type].g_iHurtDuration = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtDuration", "Hurt Duration", "Hurt_Duration", "duration", g_esAbility[type].g_iHurtDuration, value, 1, 999999);
		g_esAbility[type].g_iHurtHit = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtHit", "Hurt Hit", "Hurt_Hit", "hit", g_esAbility[type].g_iHurtHit, value, 0, 1);
		g_esAbility[type].g_iHurtHitMode = iGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtHitMode", "Hurt Hit Mode", "Hurt_Hit_Mode", "hitmode", g_esAbility[type].g_iHurtHitMode, value, 0, 2);
		g_esAbility[type].g_flHurtInterval = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtInterval", "Hurt Interval", "Hurt_Interval", "interval", g_esAbility[type].g_flHurtInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flHurtRange = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtRange", "Hurt Range", "Hurt_Range", "range", g_esAbility[type].g_flHurtRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flHurtRangeChance = flGetKeyValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtRangeChance", "Hurt Range Chance", "Hurt_Range_Chance", "rangechance", g_esAbility[type].g_flHurtRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "hurtability", false) || StrEqual(subsection, "hurt ability", false) || StrEqual(subsection, "hurt_ability", false) || StrEqual(subsection, "hurt", false))
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
	g_esCache[tank].g_flHurtChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHurtChance, g_esAbility[type].g_flHurtChance);
	g_esCache[tank].g_flHurtDamage = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHurtDamage, g_esAbility[type].g_flHurtDamage);
	g_esCache[tank].g_flHurtInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHurtInterval, g_esAbility[type].g_flHurtInterval);
	g_esCache[tank].g_flHurtRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHurtRange, g_esAbility[type].g_flHurtRange);
	g_esCache[tank].g_flHurtRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHurtRangeChance, g_esAbility[type].g_flHurtRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHurtAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHurtAbility, g_esAbility[type].g_iHurtAbility);
	g_esCache[tank].g_iHurtDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHurtDuration, g_esAbility[type].g_iHurtDuration);
	g_esCache[tank].g_iHurtEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHurtEffect, g_esAbility[type].g_iHurtEffect);
	g_esCache[tank].g_iHurtHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHurtHit, g_esAbility[type].g_iHurtHit);
	g_esCache[tank].g_iHurtHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHurtHitMode, g_esAbility[type].g_iHurtHitMode);
	g_esCache[tank].g_iHurtMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHurtMessage, g_esAbility[type].g_iHurtMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveHurt(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iHurtAbility == 1)
	{
		vHurtAbility(tank);
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
			if (g_esCache[tank].g_iHurtAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vHurtAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveHurt(tank);
}

static void vHurtAbility(int tank)
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
				if (flDistance <= g_esCache[tank].g_flHurtRange)
				{
					vHurtHit(iSurvivor, tank, g_esCache[tank].g_flHurtRangeChance, g_esCache[tank].g_iHurtAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtAmmo");
	}
}

static void vHurtHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				DataPack dpHurt;
				CreateDataTimer(g_esCache[tank].g_flHurtInterval, tTimerHurt, dpHurt, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpHurt.WriteCell(GetClientUserId(survivor));
				dpHurt.WriteCell(GetClientUserId(tank));
				dpHurt.WriteCell(g_esPlayer[tank].g_iTankType);
				dpHurt.WriteCell(messages);
				dpHurt.WriteCell(enabled);
				dpHurt.WriteCell(GetTime());

				vEffect(survivor, tank, g_esCache[tank].g_iHurtEffect, flags);
				EmitSoundToAll(SOUND_PAIN, survivor);

				if (g_esCache[tank].g_iHurtMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Hurt", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtAmmo");
		}
	}
}

static void vRemoveHurt(int tank)
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

static void vReset2(int survivor, int tank, int messages)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	if (g_esCache[tank].g_iHurtMessage & messages)
	{
		MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Hurt2", survivor);
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

public Action tTimerHurt(Handle timer, DataPack pack)
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

	static int iTank, iType, iMessage;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static int iHurtEnabled, iTime;
	iHurtEnabled = pack.ReadCell();
	iTime = pack.ReadCell();
	if (iHurtEnabled == 0 || (iTime + g_esCache[iTank].g_iHurtDuration) < GetTime())
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	vDamageEntity(iSurvivor, iTank, g_esCache[iTank].g_flHurtDamage);
	EmitSoundToAll(SOUND_ATTACK, iSurvivor);

	return Plugin_Continue;
}