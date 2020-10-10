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

#file "Gravity Ability v8.79"

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

#define SOUND_BELL "plats/churchbell_end.wav"

#define MT_MENU_GRAVITY "Gravity Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flGravityChance;
	float g_flGravityForce;
	float g_flGravityRange;
	float g_flGravityRangeChance;
	float g_flGravityValue;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iCount;
	int g_iCount2;
	int g_iDuration;
	int g_iGravity;
	int g_iGravityAbility;
	int g_iGravityDuration;
	int g_iGravityEffect;
	int g_iGravityHit;
	int g_iGravityHitMode;
	int g_iGravityMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iOwner;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flGravityChance;
	float g_flGravityForce;
	float g_flGravityRange;
	float g_flGravityRangeChance;
	float g_flGravityValue;

	int g_iAccessFlags;
	int g_iGravityAbility;
	int g_iGravityDuration;
	int g_iGravityEffect;
	int g_iGravityHit;
	int g_iGravityHitMode;
	int g_iGravityMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flGravityChance;
	float g_flGravityForce;
	float g_flGravityRange;
	float g_flGravityRangeChance;
	float g_flGravityValue;

	int g_iGravityAbility;
	int g_iGravityDuration;
	int g_iGravityEffect;
	int g_iGravityHit;
	int g_iGravityHitMode;
	int g_iGravityMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

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
	PrecacheSound(SOUND_BELL, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset2(client);
}

public void OnClientDisconnect_Post(int client)
{
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iGravityAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
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
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GravityDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iGravityDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vGravityMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "GravityMenu", param1);
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
	menu.AddItem(MT_MENU_GRAVITY, MT_MENU_GRAVITY);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_GRAVITY, false))
	{
		vGravityMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_GRAVITY, false))
	{
		FormatEx(buffer, size, "%T", "GravityMenu2", client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(client) || !g_esPlayer[client].g_bActivated || (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && g_esCache[client].g_iHumanMode == 1) || g_esPlayer[client].g_iDuration == -1)
	{
		return Plugin_Continue;
	}

	static int iTime;
	iTime = GetTime();
	if (g_esPlayer[client].g_iDuration < iTime)
	{
		if (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(client) || bHasAdminAccess(client, g_esAbility[g_esPlayer[client].g_iTankType].g_iAccessFlags, g_esPlayer[client].g_iAccessFlags)) && g_esCache[client].g_iHumanAbility == 1 && (g_esPlayer[client].g_iCooldown == -1 || g_esPlayer[client].g_iCooldown < GetTime()))
		{
			vReset4(client);
		}

		vReset3(client);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iGravityHitMode == 0 || g_esCache[attacker].g_iGravityHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGravityHit(victim, attacker, g_esCache[attacker].g_flGravityChance, g_esCache[attacker].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iGravityHitMode == 0 || g_esCache[victim].g_iGravityHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGravityHit(attacker, victim, g_esCache[victim].g_flGravityChance, g_esCache[victim].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iGravityAbility = 0;
				g_esAbility[iIndex].g_iGravityEffect = 0;
				g_esAbility[iIndex].g_iGravityMessage = 0;
				g_esAbility[iIndex].g_flGravityChance = 33.3;
				g_esAbility[iIndex].g_iGravityDuration = 5;
				g_esAbility[iIndex].g_flGravityForce = -50.0;
				g_esAbility[iIndex].g_flGravityRange = 150.0;
				g_esAbility[iIndex].g_iGravityHit = 0;
				g_esAbility[iIndex].g_iGravityHitMode = 0;
				g_esAbility[iIndex].g_flGravityRangeChance = 15.0;
				g_esAbility[iIndex].g_flGravityValue = 0.3;
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
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iGravityAbility = 0;
					g_esPlayer[iPlayer].g_iGravityEffect = 0;
					g_esPlayer[iPlayer].g_iGravityMessage = 0;
					g_esPlayer[iPlayer].g_flGravityChance = 0.0;
					g_esPlayer[iPlayer].g_iGravityDuration = 0;
					g_esPlayer[iPlayer].g_flGravityForce = 0.0;
					g_esPlayer[iPlayer].g_flGravityRange = 0.0;
					g_esPlayer[iPlayer].g_iGravityHit = 0;
					g_esPlayer[iPlayer].g_iGravityHitMode = 0;
					g_esPlayer[iPlayer].g_flGravityRangeChance = 0.0;
					g_esPlayer[iPlayer].g_flGravityValue = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 1);
		g_esPlayer[admin].g_iGravityAbility = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iGravityAbility, value, 0, 3);
		g_esPlayer[admin].g_iGravityEffect = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iGravityEffect, value, 0, 7);
		g_esPlayer[admin].g_iGravityMessage = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iGravityMessage, value, 0, 7);
		g_esPlayer[admin].g_flGravityChance = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityChance", "Gravity Chance", "Gravity_Chance", "chance", g_esPlayer[admin].g_flGravityChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iGravityDuration = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityDuration", "Gravity Duration", "Gravity_Duration", "duration", g_esPlayer[admin].g_iGravityDuration, value, 1, 999999);
		g_esPlayer[admin].g_flGravityForce = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityForce", "Gravity Force", "Gravity_Force", "force", g_esPlayer[admin].g_flGravityForce, value, -100.0, 100.0);
		g_esPlayer[admin].g_iGravityHit = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHit", "Gravity Hit", "Gravity_Hit", "hit", g_esPlayer[admin].g_iGravityHit, value, 0, 1);
		g_esPlayer[admin].g_iGravityHitMode = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHitMode", "Gravity Hit Mode", "Gravity_Hit_Mode", "hitmode", g_esPlayer[admin].g_iGravityHitMode, value, 0, 2);
		g_esPlayer[admin].g_flGravityRange = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRange", "Gravity Range", "Gravity_Range", "range", g_esPlayer[admin].g_flGravityRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flGravityRangeChance = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRangeChance", "Gravity Range Chance", "Gravity_Range_Chance", "rangechance", g_esPlayer[admin].g_flGravityRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flGravityValue = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityValue", "Gravity Value", "Gravity_Value", "value", g_esPlayer[admin].g_flGravityValue, value, 0.1, 999999.0);

		if (StrEqual(subsection, "gravityability", false) || StrEqual(subsection, "gravity ability", false) || StrEqual(subsection, "gravity_ability", false) || StrEqual(subsection, "gravity", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 1);
		g_esAbility[type].g_iGravityAbility = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iGravityAbility, value, 0, 3);
		g_esAbility[type].g_iGravityEffect = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iGravityEffect, value, 0, 7);
		g_esAbility[type].g_iGravityMessage = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iGravityMessage, value, 0, 7);
		g_esAbility[type].g_flGravityChance = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityChance", "Gravity Chance", "Gravity_Chance", "chance", g_esAbility[type].g_flGravityChance, value, 0.0, 100.0);
		g_esAbility[type].g_iGravityDuration = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityDuration", "Gravity Duration", "Gravity_Duration", "duration", g_esAbility[type].g_iGravityDuration, value, 1, 999999);
		g_esAbility[type].g_flGravityForce = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityForce", "Gravity Force", "Gravity_Force", "force", g_esAbility[type].g_flGravityForce, value, -100.0, 100.0);
		g_esAbility[type].g_iGravityHit = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHit", "Gravity Hit", "Gravity_Hit", "hit", g_esAbility[type].g_iGravityHit, value, 0, 1);
		g_esAbility[type].g_iGravityHitMode = iGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityHitMode", "Gravity Hit Mode", "Gravity_Hit_Mode", "hitmode", g_esAbility[type].g_iGravityHitMode, value, 0, 2);
		g_esAbility[type].g_flGravityRange = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRange", "Gravity Range", "Gravity_Range", "range", g_esAbility[type].g_flGravityRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flGravityRangeChance = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityRangeChance", "Gravity Range Chance", "Gravity_Range_Chance", "rangechance", g_esAbility[type].g_flGravityRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_flGravityValue = flGetKeyValue(subsection, "gravityability", "gravity ability", "gravity_ability", "gravity", key, "GravityValue", "Gravity Value", "Gravity_Value", "value", g_esAbility[type].g_flGravityValue, value, 0.1, 999999.0);

		if (StrEqual(subsection, "gravityability", false) || StrEqual(subsection, "gravity ability", false) || StrEqual(subsection, "gravity_ability", false) || StrEqual(subsection, "gravity", false))
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
	g_esCache[tank].g_flGravityChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGravityChance, g_esAbility[type].g_flGravityChance);
	g_esCache[tank].g_flGravityForce = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGravityForce, g_esAbility[type].g_flGravityForce);
	g_esCache[tank].g_flGravityRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGravityRange, g_esAbility[type].g_flGravityRange);
	g_esCache[tank].g_flGravityRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGravityRangeChance, g_esAbility[type].g_flGravityRangeChance);
	g_esCache[tank].g_flGravityValue = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGravityValue, g_esAbility[type].g_flGravityValue);
	g_esCache[tank].g_iGravityAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGravityAbility, g_esAbility[type].g_iGravityAbility);
	g_esCache[tank].g_iGravityDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGravityDuration, g_esAbility[type].g_iGravityDuration);
	g_esCache[tank].g_iGravityEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGravityEffect, g_esAbility[type].g_iGravityEffect);
	g_esCache[tank].g_iGravityHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGravityHit, g_esAbility[type].g_iGravityHit);
	g_esCache[tank].g_iGravityHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGravityHitMode, g_esAbility[type].g_iGravityHitMode);
	g_esCache[tank].g_iGravityMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGravityMessage, g_esAbility[type].g_iGravityMessage);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
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
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iGravityAbility > 0)
	{
		vGravityAbility(tank, true);
		vGravityAbility(tank, false);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		static int iTime;
		iTime = GetTime();
		if (button & MT_MAIN_KEY)
		{
			if ((g_esCache[tank].g_iGravityAbility == 2 || g_esCache[tank].g_iGravityAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vGravityAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman4");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman5", g_esPlayer[tank].g_iCooldown - iTime);
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

								g_esPlayer[tank].g_iGravity = CreateEntityByName("point_push");
								if (bIsValidEntity(g_esPlayer[tank].g_iGravity))
								{
									vGravity(tank);
								}

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman4");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman5", g_esPlayer[tank].g_iCooldown - iTime);
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

		if (button & MT_SUB_KEY)
		{
			if ((g_esCache[tank].g_iGravityAbility == 1 || g_esCache[tank].g_iGravityAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime)
				{
					case true: vGravityAbility(tank, true);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman6", g_esPlayer[tank].g_iCooldown2 - iTime);
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				vReset3(tank);
				vReset4(tank);
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
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static float flOrigin[3], flAngles[3];
	GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
	GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);
	flAngles[0] += -90.0;

	DispatchKeyValueVector(g_esPlayer[tank].g_iGravity, "origin", flOrigin);
	DispatchKeyValueVector(g_esPlayer[tank].g_iGravity, "angles", flAngles);
	DispatchKeyValue(g_esPlayer[tank].g_iGravity, "radius", "750");
	DispatchKeyValueFloat(g_esPlayer[tank].g_iGravity, "magnitude", g_esCache[tank].g_flGravityForce);
	DispatchKeyValue(g_esPlayer[tank].g_iGravity, "spawnflags", "8");
	vSetEntityParent(g_esPlayer[tank].g_iGravity, tank, true);
	AcceptEntityInput(g_esPlayer[tank].g_iGravity, "Enable");
	g_esPlayer[tank].g_iGravity = EntIndexToEntRef(g_esPlayer[tank].g_iGravity);
}

static void vGravityAbility(int tank, bool main)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esCache[tank].g_iGravityAbility == 1 || g_esCache[tank].g_iGravityAbility == 3)
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
							if (flDistance <= g_esCache[tank].g_flGravityRange)
							{
								vGravityHit(iSurvivor, tank, g_esCache[tank].g_flGravityRangeChance, g_esCache[tank].g_iGravityAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman7");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_esCache[tank].g_iGravityAbility == 2 || g_esCache[tank].g_iGravityAbility == 3) && !g_esPlayer[tank].g_bActivated)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_iGravity = CreateEntityByName("point_push");
					if (bIsValidEntity(g_esPlayer[tank].g_iGravity))
					{
						g_esPlayer[tank].g_bActivated = true;
						g_esPlayer[tank].g_iDuration = GetTime() + g_esCache[tank].g_iGravityDuration;

						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
						{
							g_esPlayer[tank].g_iCount++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
						}

						vGravity(tank);

						if (g_esCache[tank].g_iGravityMessage & MT_MESSAGE_SPECIAL)
						{
							static char sTankName[33];
							MT_GetTankName(tank, sTankName);
							MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Gravity3", sTankName);
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo");
				}
			}
		}
	}
}

static void vGravityHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				g_esPlayer[survivor].g_bAffected = true;
				g_esPlayer[survivor].g_iOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
				{
					g_esPlayer[tank].g_iCount2++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman2", g_esPlayer[tank].g_iCount2, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown2 = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman9", g_esPlayer[tank].g_iCooldown2 - iTime);
					}
				}

				SetEntityGravity(survivor, g_esCache[tank].g_flGravityValue);

				DataPack dpStopGravity;
				CreateDataTimer(float(g_esCache[tank].g_iGravityDuration), tTimerStopGravity2, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
				dpStopGravity.WriteCell(GetClientUserId(survivor));
				dpStopGravity.WriteCell(GetClientUserId(tank));
				dpStopGravity.WriteCell(messages);

				vEffect(survivor, tank, g_esCache[tank].g_iGravityEffect, flags);
				EmitSoundToAll(SOUND_BELL, survivor);

				if (g_esCache[tank].g_iGravityMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Gravity", sTankName, survivor, g_esCache[tank].g_flGravityValue);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo2");
		}
	}
}

static void vRemoveGravity(int tank)
{
	vRemoveGravity2(tank);

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;

			SetEntityGravity(iSurvivor, 1.0);
		}
	}
}

static void vRemoveGravity2(int tank)
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
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset2(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

static void vReset2(int tank, bool revert = false)
{
	if (!revert)
	{
		g_esPlayer[tank].g_bActivated = false;
	}

	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCooldown2 = -1;
	g_esPlayer[tank].g_iDuration = -1;
	g_esPlayer[tank].g_iGravity = INVALID_ENT_REFERENCE;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCount2 = 0;
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iDuration = -1;

	vRemoveGravity2(tank);

	if (g_esCache[tank].g_iGravityMessage & MT_MESSAGE_SPECIAL)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Gravity4", sTankName);
	}
}

static void vReset4(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman8", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

public Action tTimerStopGravity2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		SetEntityGravity(iSurvivor, 1.0);

		return Plugin_Stop;
	}

	g_esPlayer[iSurvivor].g_bAffected = false;
	g_esPlayer[iSurvivor].g_iOwner = 0;

	SetEntityGravity(iSurvivor, 1.0);

	int iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iGravityMessage & iMessage)
	{
		MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Gravity2", iSurvivor);
	}

	return Plugin_Continue;
}