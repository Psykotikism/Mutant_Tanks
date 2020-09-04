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

#file "Drug Ability v8.77"

public Plugin myinfo =
{
	name = "[MT] Drug Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank drugs survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Drug Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_DRUG "Drug Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flDrugChance;
	float g_flDrugInterval;
	float g_flDrugRange;
	float g_flDrugRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iDrugAbility;
	int g_iDrugDuration;
	int g_iDrugEffect;
	int g_iDrugHit;
	int g_iDrugHitMode;
	int g_iDrugMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flDrugChance;
	float g_flDrugInterval;
	float g_flDrugRange;
	float g_flDrugRangeChance;

	int g_iAccessFlags;
	int g_iDrugAbility;
	int g_iDrugDuration;
	int g_iDrugEffect;
	int g_iDrugHit;
	int g_iDrugHitMode;
	int g_iDrugMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flDrugChance;
	float g_flDrugInterval;
	float g_flDrugRange;
	float g_flDrugRangeChance;

	int g_iDrugAbility;
	int g_iDrugDuration;
	int g_iDrugEffect;
	int g_iDrugHit;
	int g_iDrugHitMode;
	int g_iDrugMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
}

esCache g_esCache[MAXPLAYERS + 1];

float g_flDrugAngles[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0};

UserMsg g_umFadeUserMsgId;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_drug", cmdDrugInfo, "View information about the Drug ability.");

	g_umFadeUserMsgId = GetUserMessageId("Fade");

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

public Action cmdDrugInfo(int client, int args)
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
		case false: vDrugMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vDrugMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iDrugMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Drug Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iDrugMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iDrugAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "DrugDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iDrugDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vDrugMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "DrugMenu", param1);
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
	menu.AddItem(MT_MENU_DRUG, MT_MENU_DRUG);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_DRUG, false))
	{
		vDrugMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_DRUG, false))
	{
		FormatEx(buffer, size, "%T", "DrugMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iDrugHitMode == 0 || g_esCache[attacker].g_iDrugHitMode == 1) && bIsHumanSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vDrugHit(victim, attacker, g_esCache[attacker].g_flDrugChance, g_esCache[attacker].g_iDrugHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iDrugHitMode == 0 || g_esCache[victim].g_iDrugHitMode == 2) && bIsHumanSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vDrugHit(attacker, victim, g_esCache[victim].g_flDrugChance, g_esCache[victim].g_iDrugHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("drugability");
	list2.PushString("drug ability");
	list3.PushString("drug_ability");
	list4.PushString("drug");
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
				g_esAbility[iIndex].g_iDrugAbility = 0;
				g_esAbility[iIndex].g_iDrugEffect = 0;
				g_esAbility[iIndex].g_iDrugMessage = 0;
				g_esAbility[iIndex].g_flDrugChance = 33.3;
				g_esAbility[iIndex].g_iDrugDuration = 5;
				g_esAbility[iIndex].g_iDrugHit = 0;
				g_esAbility[iIndex].g_iDrugHitMode = 0;
				g_esAbility[iIndex].g_flDrugInterval = 1.0;
				g_esAbility[iIndex].g_flDrugRange = 150.0;
				g_esAbility[iIndex].g_flDrugRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iDrugAbility = 0;
					g_esPlayer[iPlayer].g_iDrugEffect = 0;
					g_esPlayer[iPlayer].g_iDrugMessage = 0;
					g_esPlayer[iPlayer].g_flDrugChance = 0.0;
					g_esPlayer[iPlayer].g_iDrugDuration = 0;
					g_esPlayer[iPlayer].g_iDrugHit = 0;
					g_esPlayer[iPlayer].g_iDrugHitMode = 0;
					g_esPlayer[iPlayer].g_flDrugInterval = 0.0;
					g_esPlayer[iPlayer].g_flDrugRange = 0.0;
					g_esPlayer[iPlayer].g_flDrugRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iDrugAbility = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iDrugAbility, value, 0, 1);
		g_esPlayer[admin].g_iDrugEffect = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iDrugEffect, value, 0, 7);
		g_esPlayer[admin].g_iDrugMessage = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iDrugMessage, value, 0, 3);
		g_esPlayer[admin].g_flDrugChance = flGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugChance", "Drug Chance", "Drug_Chance", "chance", g_esPlayer[admin].g_flDrugChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iDrugDuration = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugDuration", "Drug Duration", "Drug_Duration", "duration", g_esPlayer[admin].g_iDrugDuration, value, 1, 999999);
		g_esPlayer[admin].g_iDrugHit = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugHit", "Drug Hit", "Drug_Hit", "hit", g_esPlayer[admin].g_iDrugHit, value, 0, 1);
		g_esPlayer[admin].g_iDrugHitMode = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugHitMode", "Drug Hit Mode", "Drug_Hit_Mode", "hitmode", g_esPlayer[admin].g_iDrugHitMode, value, 0, 2);
		g_esPlayer[admin].g_flDrugInterval = flGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugInterval", "Drug Interval", "Drug_Interval", "interval", g_esPlayer[admin].g_flDrugInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flDrugRange = flGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugRange", "Drug Range", "Drug_Range", "range", g_esPlayer[admin].g_flDrugRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flDrugRangeChance = flGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugRangeChance", "Drug Range Chance", "Drug_Range_Chance", "rangechance", g_esPlayer[admin].g_flDrugRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "drugability", false) || StrEqual(subsection, "drug ability", false) || StrEqual(subsection, "drug_ability", false) || StrEqual(subsection, "drug", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iDrugAbility = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iDrugAbility, value, 0, 1);
		g_esAbility[type].g_iDrugEffect = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iDrugEffect, value, 0, 7);
		g_esAbility[type].g_iDrugMessage = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iDrugMessage, value, 0, 3);
		g_esAbility[type].g_flDrugChance = flGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugChance", "Drug Chance", "Drug_Chance", "chance", g_esAbility[type].g_flDrugChance, value, 0.0, 100.0);
		g_esAbility[type].g_iDrugDuration = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugDuration", "Drug Duration", "Drug_Duration", "duration", g_esAbility[type].g_iDrugDuration, value, 1, 999999);
		g_esAbility[type].g_iDrugHit = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugHit", "Drug Hit", "Drug_Hit", "hit", g_esAbility[type].g_iDrugHit, value, 0, 1);
		g_esAbility[type].g_iDrugHitMode = iGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugHitMode", "Drug Hit Mode", "Drug_Hit_Mode", "hitmode", g_esAbility[type].g_iDrugHitMode, value, 0, 2);
		g_esAbility[type].g_flDrugInterval = flGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugInterval", "Drug Interval", "Drug_Interval", "interval", g_esAbility[type].g_flDrugInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flDrugRange = flGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugRange", "Drug Range", "Drug_Range", "range", g_esAbility[type].g_flDrugRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flDrugRangeChance = flGetKeyValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugRangeChance", "Drug Range Chance", "Drug_Range_Chance", "rangechance", g_esAbility[type].g_flDrugRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "drugability", false) || StrEqual(subsection, "drug ability", false) || StrEqual(subsection, "drug_ability", false) || StrEqual(subsection, "drug", false))
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
	g_esCache[tank].g_flDrugChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDrugChance, g_esAbility[type].g_flDrugChance);
	g_esCache[tank].g_flDrugInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDrugInterval, g_esAbility[type].g_flDrugInterval);
	g_esCache[tank].g_flDrugRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDrugRange, g_esAbility[type].g_flDrugRange);
	g_esCache[tank].g_flDrugRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDrugRangeChance, g_esAbility[type].g_flDrugRangeChance);
	g_esCache[tank].g_iDrugAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrugAbility, g_esAbility[type].g_iDrugAbility);
	g_esCache[tank].g_iDrugDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrugDuration, g_esAbility[type].g_iDrugDuration);
	g_esCache[tank].g_iDrugEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrugEffect, g_esAbility[type].g_iDrugEffect);
	g_esCache[tank].g_iDrugHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrugHit, g_esAbility[type].g_iDrugHit);
	g_esCache[tank].g_iDrugHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrugHitMode, g_esAbility[type].g_iDrugHitMode);
	g_esCache[tank].g_iDrugMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDrugMessage, g_esAbility[type].g_iDrugMessage);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
		{
			vRemoveDrug(iTank);
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
			vRemoveDrug(iTank);
		}
	}

	if (StrEqual(name, "player_spawn"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsHumanSurvivor(iSurvivor))
		{
			vDrug(iSurvivor, false, g_flDrugAngles);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iDrugAbility == 1)
	{
		vDrugAbility(tank);
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
			if (g_esCache[tank].g_iDrugAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vDrugAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrugHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveDrug(tank);
}

static void vDrug(int survivor, bool toggle, float angles[20])
{
	static float flAngles[3];
	GetClientEyeAngles(survivor, flAngles);
	flAngles[2] = toggle ? angles[GetRandomInt(0, 100) % 20] : 0.0;
	TeleportEntity(survivor, NULL_VECTOR, flAngles, NULL_VECTOR);

	static int iClients[2], iColor[4] = {0, 0, 0, 128}, iColor2[4] = {0, 0, 0, 0}, iFlags;
	iClients[0] = survivor;
	iFlags = toggle ? 0x0002 : (0x0001|0x0010);

	if (toggle)
	{
		for (int iPos = 0; iPos < sizeof(iColor) - 1; iPos++)
		{
			iColor[iPos] = GetRandomInt(0, 255);
		}
	}

	static Handle hTarget;
	hTarget = StartMessageEx(g_umFadeUserMsgId, iClients, 1);

	switch (GetUserMessageType() == UM_Protobuf)
	{
		case true:
		{
			static Protobuf pbSet;
			pbSet = UserMessageToProtobuf(hTarget);
			pbSet.SetInt("duration", toggle ? 255: 1536);
			pbSet.SetInt("hold_time", toggle ? 255 : 1536);
			pbSet.SetInt("flags", iFlags);
			pbSet.SetColor("clr", toggle ? iColor : iColor2);
		}
		case false:
		{
			static BfWrite bfWrite;
			bfWrite = UserMessageToBfWrite(hTarget);
			bfWrite.WriteShort(toggle ? 255 : 1536);
			bfWrite.WriteShort(toggle ? 255 : 1536);
			bfWrite.WriteShort(iFlags);

			for (int iPos = 0; iPos < sizeof(iColor); iPos++)
			{
				bfWrite.WriteByte(toggle ? iColor[iPos] : iColor2[iPos]);
			}
		}
	}

	EndMessage();
}

static void vDrugAbility(int tank)
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
				if (flDistance <= g_esCache[tank].g_flDrugRange)
				{
					vDrugHit(iSurvivor, tank, g_esCache[tank].g_flDrugRangeChance, g_esCache[tank].g_iDrugAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrugHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrugAmmo");
	}
}

static void vDrugHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsHumanSurvivor(survivor))
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrugHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrugHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				DataPack dpDrug;
				CreateDataTimer(g_esCache[tank].g_flDrugInterval, tTimerDrug, dpDrug, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpDrug.WriteCell(GetClientUserId(survivor));
				dpDrug.WriteCell(GetClientUserId(tank));
				dpDrug.WriteCell(g_esPlayer[tank].g_iTankType);
				dpDrug.WriteCell(messages);
				dpDrug.WriteCell(enabled);
				dpDrug.WriteCell(GetTime());

				vEffect(survivor, tank, g_esCache[tank].g_iDrugEffect, flags);

				if (g_esCache[tank].g_iDrugMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Drug", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrugHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "DrugAmmo");
		}
	}
}

static void vRemoveDrug(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			vDrug(iSurvivor, false, g_flDrugAngles);

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

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset2(int survivor, int tank, int messages)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	vDrug(survivor, false, g_flDrugAngles);

	if (g_esCache[tank].g_iDrugMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Drug2", survivor);
	}
}

public Action tTimerDrug(Handle timer, DataPack pack)
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

	static int iDrugEnabled, iTime;
	iDrugEnabled = pack.ReadCell();
	iTime = pack.ReadCell();
	if (iDrugEnabled == 0 || (iTime + g_esCache[iTank].g_iDrugDuration) < GetTime())
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	vDrug(iSurvivor, true, g_flDrugAngles);

	return Plugin_Handled;
}