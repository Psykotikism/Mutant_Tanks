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

//#file "Shove Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Shove Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank repeatedly shoves survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Shove Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_SHOVE "Shove Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flShoveChance;
	float g_flShoveDeathChance;
	float g_flShoveDeathRange;
	float g_flShoveInterval;
	float g_flShoveRange;
	float g_flShoveRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iOwner;
	int g_iShoveAbility;
	int g_iShoveDeath;
	int g_iShoveDuration;
	int g_iShoveEffect;
	int g_iShoveHit;
	int g_iShoveHitMode;
	int g_iShoveMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flShoveChance;
	float g_flShoveDeathChance;
	float g_flShoveDeathRange;
	float g_flShoveInterval;
	float g_flShoveRange;
	float g_flShoveRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iShoveAbility;
	int g_iShoveDeath;
	int g_iShoveDuration;
	int g_iShoveEffect;
	int g_iShoveHit;
	int g_iShoveHitMode;
	int g_iShoveMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flShoveChance;
	float g_flShoveDeathChance;
	float g_flShoveDeathRange;
	float g_flShoveInterval;
	float g_flShoveRange;
	float g_flShoveRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iShoveAbility;
	int g_iShoveDeath;
	int g_iShoveDuration;
	int g_iShoveEffect;
	int g_iShoveHit;
	int g_iShoveHitMode;
	int g_iShoveMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

Handle g_hSDKShovePlayer;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_shove", cmdShoveInfo, "View information about the Shove ability.");

	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnStaggered"))
	{
		SetFailState("Failed to find signature: CTerrorPlayer::OnStaggered");
	}

	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);

	g_hSDKShovePlayer = EndPrepSDKCall();
	if (g_hSDKShovePlayer == null)
	{
		MT_LogMessage(MT_LOG_SERVER, "%s Your \"CTerrorPlayer::OnStaggered\" signature is outdated.", MT_TAG);
	}

	delete gdMutantTanks;

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

public Action cmdShoveInfo(int client, int args)
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
		case false: vShoveMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vShoveMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iShoveMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Shove Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iShoveMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iShoveAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ShoveDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iShoveDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vShoveMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "ShoveMenu", param1);
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
	menu.AddItem(MT_MENU_SHOVE, MT_MENU_SHOVE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_SHOVE, false))
	{
		vShoveMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_SHOVE, false))
	{
		FormatEx(buffer, size, "%T", "ShoveMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iShoveHitMode == 0 || g_esCache[attacker].g_iShoveHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vShoveHit(victim, attacker, g_esCache[attacker].g_flShoveChance, g_esCache[attacker].g_iShoveHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iShoveHitMode == 0 || g_esCache[victim].g_iShoveHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vShoveHit(attacker, victim, g_esCache[victim].g_flShoveChance, g_esCache[victim].g_iShoveHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("shoveability");
	list2.PushString("shove ability");
	list3.PushString("shove_ability");
	list4.PushString("shove");
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
				g_esAbility[iIndex].g_iShoveAbility = 0;
				g_esAbility[iIndex].g_iShoveEffect = 0;
				g_esAbility[iIndex].g_iShoveMessage = 0;
				g_esAbility[iIndex].g_flShoveChance = 33.3;
				g_esAbility[iIndex].g_iShoveDeath = 0;
				g_esAbility[iIndex].g_flShoveDeathChance = 33.3;
				g_esAbility[iIndex].g_flShoveDeathRange = 200.0;
				g_esAbility[iIndex].g_iShoveDuration = 5;
				g_esAbility[iIndex].g_iShoveHit = 0;
				g_esAbility[iIndex].g_iShoveHitMode = 0;
				g_esAbility[iIndex].g_flShoveInterval = 1.0;
				g_esAbility[iIndex].g_flShoveRange = 150.0;
				g_esAbility[iIndex].g_flShoveRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iShoveAbility = 0;
					g_esPlayer[iPlayer].g_iShoveEffect = 0;
					g_esPlayer[iPlayer].g_iShoveMessage = 0;
					g_esPlayer[iPlayer].g_flShoveChance = 0.0;
					g_esPlayer[iPlayer].g_iShoveDeath = 0;
					g_esPlayer[iPlayer].g_flShoveDeathChance = 0.0;
					g_esPlayer[iPlayer].g_flShoveDeathRange = 0.0;
					g_esPlayer[iPlayer].g_iShoveDuration = 0;
					g_esPlayer[iPlayer].g_iShoveHit = 0;
					g_esPlayer[iPlayer].g_iShoveHitMode = 0;
					g_esPlayer[iPlayer].g_flShoveInterval = 0.0;
					g_esPlayer[iPlayer].g_flShoveRange = 0.0;
					g_esPlayer[iPlayer].g_flShoveRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iShoveAbility = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iShoveAbility, value, 0, 1);
		g_esPlayer[admin].g_iShoveEffect = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iShoveEffect, value, 0, 7);
		g_esPlayer[admin].g_iShoveMessage = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iShoveMessage, value, 0, 3);
		g_esPlayer[admin].g_flShoveChance = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveChance", "Shove Chance", "Shove_Chance", "chance", g_esPlayer[admin].g_flShoveChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iShoveDeath = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveDeath", "Shove Death", "Shove_Death", "death", g_esPlayer[admin].g_iShoveDeath, value, 0, 1);
		g_esPlayer[admin].g_flShoveDeathChance = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveDeathChance", "Shove Death Chance", "Shove_Death_Chance", "deathchance", g_esPlayer[admin].g_flShoveDeathChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flShoveDeathRange = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveDeathRange", "Shove Death Range", "Shove_Death_Range", "deathrange", g_esPlayer[admin].g_flShoveDeathRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iShoveDuration = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveDuration", "Shove Duration", "Shove_Duration", "duration", g_esPlayer[admin].g_iShoveDuration, value, 1, 999999);
		g_esPlayer[admin].g_iShoveHit = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveHit", "Shove Hit", "Shove_Hit", "hit", g_esPlayer[admin].g_iShoveHit, value, 0, 1);
		g_esPlayer[admin].g_iShoveHitMode = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveHitMode", "Shove Hit Mode", "Shove_Hit_Mode", "hitmode", g_esPlayer[admin].g_iShoveHitMode, value, 0, 2);
		g_esPlayer[admin].g_flShoveInterval = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveInterval", "Shove Interval", "Shove_Interval", "interval", g_esPlayer[admin].g_flShoveInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flShoveRange = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveRange", "Shove Range", "Shove_Range", "range", g_esPlayer[admin].g_flShoveRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flShoveRangeChance = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveRangeChance", "Shove Range Chance", "Shove_Range_Chance", "rangechance", g_esPlayer[admin].g_flShoveRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "shoveability", false) || StrEqual(subsection, "shove ability", false) || StrEqual(subsection, "shove_ability", false) || StrEqual(subsection, "shove", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iShoveAbility = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iShoveAbility, value, 0, 1);
		g_esAbility[type].g_iShoveEffect = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iShoveEffect, value, 0, 7);
		g_esAbility[type].g_iShoveMessage = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iShoveMessage, value, 0, 3);
		g_esAbility[type].g_flShoveChance = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveChance", "Shove Chance", "Shove_Chance", "chance", g_esAbility[type].g_flShoveChance, value, 0.0, 100.0);
		g_esAbility[type].g_iShoveDeath = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveDeath", "Shove Death", "Shove_Death", "death", g_esAbility[type].g_iShoveDeath, value, 0, 1);
		g_esAbility[type].g_flShoveDeathChance = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveDeathChance", "Shove Death Chance", "Shove_Death_Chance", "deathchance", g_esAbility[type].g_flShoveDeathChance, value, 0.0, 100.0);
		g_esAbility[type].g_flShoveDeathRange = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveDeathRange", "Shove Death Range", "Shove_Death_Range", "deathrange", g_esAbility[type].g_flShoveDeathRange, value, 1.0, 999999.0);
		g_esAbility[type].g_iShoveDuration = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveDuration", "Shove Duration", "Shove_Duration", "duration", g_esAbility[type].g_iShoveDuration, value, 1, 999999);
		g_esAbility[type].g_iShoveHit = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveHit", "Shove Hit", "Shove_Hit", "hit", g_esAbility[type].g_iShoveHit, value, 0, 1);
		g_esAbility[type].g_iShoveHitMode = iGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveHitMode", "Shove Hit Mode", "Shove_Hit_Mode", "hitmode", g_esAbility[type].g_iShoveHitMode, value, 0, 2);
		g_esAbility[type].g_flShoveInterval = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveInterval", "Shove Interval", "Shove_Interval", "interval", g_esAbility[type].g_flShoveInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flShoveRange = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveRange", "Shove Range", "Shove_Range", "range", g_esAbility[type].g_flShoveRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flShoveRangeChance = flGetKeyValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveRangeChance", "Shove Range Chance", "Shove_Range_Chance", "rangechance", g_esAbility[type].g_flShoveRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "shoveability", false) || StrEqual(subsection, "shove ability", false) || StrEqual(subsection, "shove_ability", false) || StrEqual(subsection, "shove", false))
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
	g_esCache[tank].g_flShoveChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flShoveChance, g_esAbility[type].g_flShoveChance);
	g_esCache[tank].g_flShoveDeathChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flShoveDeathChance, g_esAbility[type].g_flShoveDeathChance);
	g_esCache[tank].g_flShoveDeathRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flShoveDeathRange, g_esAbility[type].g_flShoveDeathRange);
	g_esCache[tank].g_flShoveInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flShoveInterval, g_esAbility[type].g_flShoveInterval);
	g_esCache[tank].g_flShoveRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flShoveRange, g_esAbility[type].g_flShoveRange);
	g_esCache[tank].g_flShoveRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flShoveRangeChance, g_esAbility[type].g_flShoveRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iShoveAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShoveAbility, g_esAbility[type].g_iShoveAbility);
	g_esCache[tank].g_iShoveDeath = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShoveDeath, g_esAbility[type].g_iShoveDeath);
	g_esCache[tank].g_iShoveDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShoveDuration, g_esAbility[type].g_iShoveDuration);
	g_esCache[tank].g_iShoveEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShoveEffect, g_esAbility[type].g_iShoveEffect);
	g_esCache[tank].g_iShoveHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShoveHit, g_esAbility[type].g_iShoveHit);
	g_esCache[tank].g_iShoveHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShoveHitMode, g_esAbility[type].g_iShoveHitMode);
	g_esCache[tank].g_iShoveMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShoveMessage, g_esAbility[type].g_iShoveMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vShoveRange(iTank);
			vRemoveShove(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iShoveAbility == 1)
	{
		vShoveAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iShoveAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vShoveAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShoveHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveShove(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	vShoveRange(tank);
}

static void vRemoveShove(int tank)
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

	if (g_esCache[tank].g_iShoveMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Shove2", survivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Shove2", LANG_SERVER, survivor);
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

static void vShoveAbility(int tank)
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
				if (flDistance <= g_esCache[tank].g_flShoveRange)
				{
					vShoveHit(iSurvivor, tank, g_esCache[tank].g_flShoveRangeChance, g_esCache[tank].g_iShoveAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShoveHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShoveAmmo");
	}
}

static void vShoveHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
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
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				g_esPlayer[survivor].g_bAffected = true;
				g_esPlayer[survivor].g_iOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShoveHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShoveHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				DataPack dpShove;
				CreateDataTimer(g_esCache[tank].g_flShoveInterval, tTimerShove, dpShove, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpShove.WriteCell(GetClientUserId(survivor));
				dpShove.WriteCell(GetClientUserId(tank));
				dpShove.WriteCell(g_esPlayer[tank].g_iTankType);
				dpShove.WriteCell(messages);
				dpShove.WriteCell(enabled);
				dpShove.WriteCell(GetTime());

				vEffect(survivor, tank, g_esCache[tank].g_iShoveEffect, flags);

				if (g_esCache[tank].g_iShoveMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Shove", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Shove", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShoveHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShoveAmmo");
		}
	}
}

static void vShoveRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(tank) && g_esCache[tank].g_iShoveDeath == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flShoveDeathChance)
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		static float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		static float flSurvivorPos[3], flDistance;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_esCache[tank].g_flShoveDeathRange)
				{
					SDKCall(g_hSDKShovePlayer, iSurvivor, tank, flTankPos);
				}
			}
		}
	}
}

public Action tTimerShove(Handle timer, DataPack pack)
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
	if (!MT_IsTankSupported(iTank) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static int iShoveEnabled, iTime;
	iShoveEnabled = pack.ReadCell();
	iTime = pack.ReadCell();
	if (iShoveEnabled == 0 || (iTime + g_esCache[iTank].g_iShoveDuration) < GetTime())
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static float flOrigin[3];
	GetClientAbsOrigin(iTank, flOrigin);
	SDKCall(g_hSDKShovePlayer, iSurvivor, iTank, flOrigin);

	return Plugin_Continue;
}