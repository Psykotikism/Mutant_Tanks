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
#include <left4dhooks>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

//#file "Restart Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Restart Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank forces survivors to restart at the beginning of the map or near a teammate with a new loadout.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Restart Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	MarkNativeAsOptional("MT_IsCloneSupported");

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_RESTART "Restart Ability"

enum struct esPlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;
	bool g_bRecorded;

	char g_sRestartLoadout[325];

	float g_flPosition[3];
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	char g_sRestartLoadout[325];

	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	char g_sRestartLoadout[325];

	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
}

esCache g_esCache[MAXPLAYERS + 1];

Handle g_hSDKRespawnPlayer;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_restart", cmdRestartInfo, "View information about the Restart ability.");

	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");

		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::RoundRespawn"))
	{
		SetFailState("Failed to find signature: CTerrorPlayer::RoundRespawn");
	}

	g_hSDKRespawnPlayer = EndPrepSDKCall();
	if (g_hSDKRespawnPlayer == null)
	{
		MT_LogMessage(MT_LOG_SERVER, "%s Your \"CTerrorPlayer::RoundRespawn\" signature is outdated.", MT_TAG);
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

	vRemoveRestart(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveRestart(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRestartInfo(int client, int args)
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
		case false: vRestartMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRestartMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRestartMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Restart Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRestartMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iRestartAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RestartDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vRestartMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "RestartMenu", param1);
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
	menu.AddItem(MT_MENU_RESTART, MT_MENU_RESTART);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_RESTART, false))
	{
		vRestartMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_RESTART, false))
	{
		FormatEx(buffer, size, "%T", "RestartMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iRestartHitMode == 0 || g_esCache[attacker].g_iRestartHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRestartHit(victim, attacker, g_esCache[attacker].g_flRestartChance, g_esCache[attacker].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iRestartHitMode == 0 || g_esCache[victim].g_iRestartHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRestartHit(attacker, victim, g_esCache[victim].g_flRestartChance, g_esCache[victim].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("restartability");
	list2.PushString("restart ability");
	list3.PushString("restart_ability");
	list4.PushString("restart");
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
				g_esAbility[iIndex].g_iOpenAreasOnly = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iRestartAbility = 0;
				g_esAbility[iIndex].g_iRestartEffect = 0;
				g_esAbility[iIndex].g_iRestartMessage = 0;
				g_esAbility[iIndex].g_flRestartChance = 33.3;
				g_esAbility[iIndex].g_iRestartHit = 0;
				g_esAbility[iIndex].g_iRestartHitMode = 0;
				g_esAbility[iIndex].g_sRestartLoadout = "smg,pistol,pain_pills";
				g_esAbility[iIndex].g_iRestartMode = 1;
				g_esAbility[iIndex].g_flRestartRange = 150.0;
				g_esAbility[iIndex].g_flRestartRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iRestartAbility = 0;
					g_esPlayer[iPlayer].g_iRestartEffect = 0;
					g_esPlayer[iPlayer].g_iRestartMessage = 0;
					g_esPlayer[iPlayer].g_flRestartChance = 0.0;
					g_esPlayer[iPlayer].g_iRestartHit = 0;
					g_esPlayer[iPlayer].g_iRestartHitMode = 0;
					g_esPlayer[iPlayer].g_sRestartLoadout[0] = '\0';
					g_esPlayer[iPlayer].g_iRestartMode = 0;
					g_esPlayer[iPlayer].g_flRestartRange = 0.0;
					g_esPlayer[iPlayer].g_flRestartRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iRestartAbility = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iRestartAbility, value, 0, 1);
		g_esPlayer[admin].g_iRestartEffect = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iRestartEffect, value, 0, 7);
		g_esPlayer[admin].g_iRestartMessage = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iRestartMessage, value, 0, 3);
		g_esPlayer[admin].g_flRestartChance = flGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartChance", "Restart Chance", "Restart_Chance", "chance", g_esPlayer[admin].g_flRestartChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iRestartHit = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartHit", "Restart Hit", "Restart_Hit", "hit", g_esPlayer[admin].g_iRestartHit, value, 0, 1);
		g_esPlayer[admin].g_iRestartHitMode = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartHitMode", "Restart Hit Mode", "Restart_Hit_Mode", "hitmode", g_esPlayer[admin].g_iRestartHitMode, value, 0, 2);
		g_esPlayer[admin].g_iRestartMode = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartMode", "Restart Mode", "Restart_Mode", "mode", g_esPlayer[admin].g_iRestartMode, value, 0, 1);
		g_esPlayer[admin].g_flRestartRange = flGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartRange", "Restart Range", "Restart_Range", "range", g_esPlayer[admin].g_flRestartRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flRestartRangeChance = flGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartRangeChance", "Restart Range Chance", "Restart_Range_Chance", "rangechance", g_esPlayer[admin].g_flRestartRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "restartability", false) || StrEqual(subsection, "restart ability", false) || StrEqual(subsection, "restart_ability", false) || StrEqual(subsection, "restart", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RestartLoadout", false) || StrEqual(key, "Restart Loadout", false) || StrEqual(key, "Restart_Loadout", false) || StrEqual(key, "loadout", false))
			{
				strcopy(g_esPlayer[admin].g_sRestartLoadout, sizeof(esAbility::g_sRestartLoadout), value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iRestartAbility = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iRestartAbility, value, 0, 1);
		g_esAbility[type].g_iRestartEffect = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iRestartEffect, value, 0, 7);
		g_esAbility[type].g_iRestartMessage = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iRestartMessage, value, 0, 3);
		g_esAbility[type].g_flRestartChance = flGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartChance", "Restart Chance", "Restart_Chance", "chance", g_esAbility[type].g_flRestartChance, value, 0.0, 100.0);
		g_esAbility[type].g_iRestartHit = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartHit", "Restart Hit", "Restart_Hit", "hit", g_esAbility[type].g_iRestartHit, value, 0, 1);
		g_esAbility[type].g_iRestartHitMode = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartHitMode", "Restart Hit Mode", "Restart_Hit_Mode", "hitmode", g_esAbility[type].g_iRestartHitMode, value, 0, 2);
		g_esAbility[type].g_iRestartMode = iGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartMode", "Restart Mode", "Restart_Mode", "mode", g_esAbility[type].g_iRestartMode, value, 0, 1);
		g_esAbility[type].g_flRestartRange = flGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartRange", "Restart Range", "Restart_Range", "range", g_esAbility[type].g_flRestartRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flRestartRangeChance = flGetKeyValue(subsection, "restartability", "restart ability", "restart_ability", "restart", key, "RestartRangeChance", "Restart Range Chance", "Restart_Range_Chance", "rangechance", g_esAbility[type].g_flRestartRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "restartability", false) || StrEqual(subsection, "restart ability", false) || StrEqual(subsection, "restart_ability", false) || StrEqual(subsection, "restart", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RestartLoadout", false) || StrEqual(key, "Restart Loadout", false) || StrEqual(key, "Restart_Loadout", false) || StrEqual(key, "loadout", false))
			{
				strcopy(g_esAbility[type].g_sRestartLoadout, sizeof(esAbility::g_sRestartLoadout), value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	vGetSettingValue(apply, bHuman, g_esCache[tank].g_sRestartLoadout, sizeof(esCache::g_sRestartLoadout), g_esPlayer[tank].g_sRestartLoadout, g_esAbility[type].g_sRestartLoadout);
	g_esCache[tank].g_flRestartChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRestartChance, g_esAbility[type].g_flRestartChance);
	g_esCache[tank].g_flRestartRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRestartRange, g_esAbility[type].g_flRestartRange);
	g_esCache[tank].g_flRestartRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRestartRangeChance, g_esAbility[type].g_flRestartRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iRestartAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRestartAbility, g_esAbility[type].g_iRestartAbility);
	g_esCache[tank].g_iRestartEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRestartEffect, g_esAbility[type].g_iRestartEffect);
	g_esCache[tank].g_iRestartHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRestartHit, g_esAbility[type].g_iRestartHit);
	g_esCache[tank].g_iRestartHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRestartHitMode, g_esAbility[type].g_iRestartHitMode);
	g_esCache[tank].g_iRestartMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRestartMessage, g_esAbility[type].g_iRestartMessage);
	g_esCache[tank].g_iRestartMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRestartMode, g_esAbility[type].g_iRestartMode);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveRestart(iTank);
		}
	}

	if (StrEqual(name, "player_spawn"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor) && !g_esPlayer[iSurvivor].g_bRecorded && L4D_IsInFirstCheckpoint(iSurvivor))
		{
			g_esPlayer[iSurvivor].g_bRecorded = true;

			GetClientAbsOrigin(iSurvivor, g_esPlayer[iSurvivor].g_flPosition);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iRestartAbility == 1)
	{
		vRestartAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iRestartAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vRestartAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveRestart(tank);
}

static void vRemoveRestart(int tank)
{
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_bRecorded = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vRemoveWeapon(int survivor, int slot)
{
	int iSlot = GetPlayerWeaponSlot(survivor, slot);
	if (iSlot > 0)
	{
		RemovePlayerItem(survivor, iSlot);
		RemoveEntity(iSlot);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveRestart(iPlayer);
		}
	}
}

static void vRestartAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
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
				if (flDistance <= g_esCache[tank].g_flRestartRange)
				{
					vRestartHit(iSurvivor, tank, g_esCache[tank].g_flRestartRangeChance, g_esCache[tank].g_iRestartAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartAmmo");
	}
}

static void vRestartHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				SDKCall(g_hSDKRespawnPlayer, survivor);

				static char sItems[5][64];
				ReplaceString(g_esCache[tank].g_sRestartLoadout, sizeof(esAbility::g_sRestartLoadout), " ", "");
				ExplodeString(g_esCache[tank].g_sRestartLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));

				for (int iWeapon = 0; iWeapon < sizeof(sItems); iWeapon++)
				{
					vRemoveWeapon(survivor, iWeapon);
				}

				for (int iItem = 0; iItem < sizeof(sItems); iItem++)
				{
					if (StrContains(g_esCache[tank].g_sRestartLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
					{
						vCheatCommand(survivor, "give", sItems[iItem]);
					}
				}

				if (g_esPlayer[survivor].g_bRecorded && g_esCache[tank].g_iRestartMode == 0)
				{
					TeleportEntity(survivor, g_esPlayer[survivor].g_flPosition, NULL_VECTOR, NULL_VECTOR);
				}
				else
				{
					static float flCurrentOrigin[3];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (!bIsSurvivor(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) || bIsPlayerIncapacitated(iPlayer) || iPlayer == survivor)
						{
							continue;
						}

						GetClientAbsOrigin(iPlayer, flCurrentOrigin);
						TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

						break;
					}
				}

				vEffect(survivor, tank, g_esCache[tank].g_iRestartEffect, flags);

				if (g_esCache[tank].g_iRestartMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Restart", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Restart", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartAmmo");
		}
	}
}