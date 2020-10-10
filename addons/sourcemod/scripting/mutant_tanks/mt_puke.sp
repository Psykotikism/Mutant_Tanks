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

#file "Puke Ability v8.79"

public Plugin myinfo =
{
	name = "[MT] Puke Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank pukes on survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Puke Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define MT_MENU_PUKE "Puke Ability"

enum struct esPlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flPukeChance;
	float g_flPukeDeathChance;
	float g_flPukeDeathRange;
	float g_flPukeRange;
	float g_flPukeRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iPukeAbility;
	int g_iPukeDeath;
	int g_iPukeEffect;
	int g_iPukeHit;
	int g_iPukeHitMode;
	int g_iPukeMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flPukeChance;
	float g_flPukeDeathChance;
	float g_flPukeDeathRange;
	float g_flPukeRange;
	float g_flPukeRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iPukeAbility;
	int g_iPukeDeath;
	int g_iPukeEffect;
	int g_iPukeHit;
	int g_iPukeHitMode;
	int g_iPukeMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flPukeChance;
	float g_flPukeDeathChance;
	float g_flPukeDeathRange;
	float g_flPukeRange;
	float g_flPukeRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iPukeAbility;
	int g_iPukeDeath;
	int g_iPukeEffect;
	int g_iPukeHit;
	int g_iPukeHitMode;
	int g_iPukeMessage;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

Handle g_hSDKPukePlayer;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_puke", cmdPukeInfo, "View information about the Puke ability.");

	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");

		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnVomitedUpon"))
	{
		SetFailState("Failed to find signature: CTerrorPlayer::OnVomitedUpon");
	}

	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);

	g_hSDKPukePlayer = EndPrepSDKCall();
	if (g_hSDKPukePlayer == null)
	{
		MT_LogMessage(MT_LOG_SERVER, "%s Your \"CTerrorPlayer::OnVomitedUpon\" signature is outdated.", MT_TAG);
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
	iPrecacheParticle(PARTICLE_BLOOD);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemovePuke(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemovePuke(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdPukeInfo(int client, int args)
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
		case false: vPukeMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vPukeMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iPukeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Puke Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iPukeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iPukeAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "PukeDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vPukeMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "PukeMenu", param1);
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
	menu.AddItem(MT_MENU_PUKE, MT_MENU_PUKE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_PUKE, false))
	{
		vPukeMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_PUKE, false))
	{
		FormatEx(buffer, size, "%T", "PukeMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iPukeHitMode == 0 || g_esCache[attacker].g_iPukeHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPukeHit(victim, attacker, g_esCache[attacker].g_flPukeChance, g_esCache[attacker].g_iPukeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iPukeHitMode == 0 || g_esCache[victim].g_iPukeHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPukeHit(attacker, victim, g_esCache[victim].g_flPukeChance, g_esCache[victim].g_iPukeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("pukeability");
	list2.PushString("puke ability");
	list3.PushString("puke_ability");
	list4.PushString("puke");
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
				g_esAbility[iIndex].g_iPukeAbility = 0;
				g_esAbility[iIndex].g_iPukeEffect = 0;
				g_esAbility[iIndex].g_iPukeMessage = 0;
				g_esAbility[iIndex].g_flPukeChance = 33.3;
				g_esAbility[iIndex].g_iPukeDeath = 0;
				g_esAbility[iIndex].g_flPukeDeathChance = 33.3;
				g_esAbility[iIndex].g_flPukeDeathRange = 200.0;
				g_esAbility[iIndex].g_iPukeHit = 0;
				g_esAbility[iIndex].g_iPukeHitMode = 0;
				g_esAbility[iIndex].g_flPukeRange = 150.0;
				g_esAbility[iIndex].g_flPukeRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iPukeAbility = 0;
					g_esPlayer[iPlayer].g_iPukeEffect = 0;
					g_esPlayer[iPlayer].g_iPukeMessage = 0;
					g_esPlayer[iPlayer].g_flPukeChance = 0.0;
					g_esPlayer[iPlayer].g_iPukeDeath = 0;
					g_esPlayer[iPlayer].g_flPukeDeathChance = 0.0;
					g_esPlayer[iPlayer].g_flPukeDeathRange = 0.0;
					g_esPlayer[iPlayer].g_iPukeHit = 0;
					g_esPlayer[iPlayer].g_iPukeHitMode = 0;
					g_esPlayer[iPlayer].g_flPukeRange = 0.0;
					g_esPlayer[iPlayer].g_flPukeRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 1);
		g_esPlayer[admin].g_iPukeAbility = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iPukeAbility, value, 0, 1);
		g_esPlayer[admin].g_iPukeEffect = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iPukeEffect, value, 0, 7);
		g_esPlayer[admin].g_iPukeMessage = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iPukeMessage, value, 0, 3);
		g_esPlayer[admin].g_flPukeChance = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeChance", "Puke Chance", "Puke_Chance", "chance", g_esPlayer[admin].g_flPukeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iPukeDeath = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeDeath", "Puke Death", "Puke_Death", "death", g_esPlayer[admin].g_iPukeDeath, value, 0, 1);
		g_esPlayer[admin].g_flPukeDeathChance = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeDeathChance", "Puke Death Chance", "Puke_Death_Chance", "deathchance", g_esPlayer[admin].g_flPukeDeathChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flPukeDeathRange = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeDeathRange", "Puke Death Range", "Puke_Death_Range", "deathrange", g_esPlayer[admin].g_flPukeDeathRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iPukeHit = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeHit", "Puke Hit", "Puke_Hit", "hit", g_esPlayer[admin].g_iPukeHit, value, 0, 1);
		g_esPlayer[admin].g_iPukeHitMode = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeHitMode", "Puke Hit Mode", "Puke_Hit_Mode", "hitmode", g_esPlayer[admin].g_iPukeHitMode, value, 0, 2);
		g_esPlayer[admin].g_flPukeRange = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeRange", "Puke Range", "Puke_Range", "range", g_esPlayer[admin].g_flPukeRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flPukeRangeChance = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeRangeChance", "Puke Range Chance", "Puke_Range_Chance", "rangechance", g_esPlayer[admin].g_flPukeRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "pukeability", false) || StrEqual(subsection, "puke ability", false) || StrEqual(subsection, "puke_ability", false) || StrEqual(subsection, "puke", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 1);
		g_esAbility[type].g_iPukeAbility = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iPukeAbility, value, 0, 1);
		g_esAbility[type].g_iPukeEffect = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iPukeEffect, value, 0, 7);
		g_esAbility[type].g_iPukeMessage = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iPukeMessage, value, 0, 3);
		g_esAbility[type].g_flPukeChance = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeChance", "Puke Chance", "Puke_Chance", "chance", g_esAbility[type].g_flPukeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iPukeDeath = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeDeath", "Puke Death", "Puke_Death", "death", g_esAbility[type].g_iPukeDeath, value, 0, 1);
		g_esAbility[type].g_flPukeDeathChance = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeDeathChance", "Puke Death Chance", "Puke_Death_Chance", "deathchance", g_esAbility[type].g_flPukeDeathChance, value, 0.0, 100.0);
		g_esAbility[type].g_flPukeDeathRange = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeDeathRange", "Puke Death Range", "Puke_Death_Range", "deathrange", g_esAbility[type].g_flPukeDeathRange, value, 1.0, 999999.0);
		g_esAbility[type].g_iPukeHit = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeHit", "Puke Hit", "Puke_Hit", "hit", g_esAbility[type].g_iPukeHit, value, 0, 1);
		g_esAbility[type].g_iPukeHitMode = iGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeHitMode", "Puke Hit Mode", "Puke_Hit_Mode", "hitmode", g_esAbility[type].g_iPukeHitMode, value, 0, 2);
		g_esAbility[type].g_flPukeRange = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeRange", "Puke Range", "Puke_Range", "range", g_esAbility[type].g_flPukeRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flPukeRangeChance = flGetKeyValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeRangeChance", "Puke Range Chance", "Puke_Range_Chance", "rangechance", g_esAbility[type].g_flPukeRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "pukeability", false) || StrEqual(subsection, "puke ability", false) || StrEqual(subsection, "puke_ability", false) || StrEqual(subsection, "puke", false))
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
	g_esCache[tank].g_flPukeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPukeChance, g_esAbility[type].g_flPukeChance);
	g_esCache[tank].g_flPukeDeathChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPukeDeathChance, g_esAbility[type].g_flPukeDeathChance);
	g_esCache[tank].g_flPukeDeathRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPukeDeathRange, g_esAbility[type].g_flPukeDeathRange);
	g_esCache[tank].g_flPukeRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPukeRange, g_esAbility[type].g_flPukeRange);
	g_esCache[tank].g_flPukeRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPukeRangeChance, g_esAbility[type].g_flPukeRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iPukeAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPukeAbility, g_esAbility[type].g_iPukeAbility);
	g_esCache[tank].g_iPukeDeath = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPukeDeath, g_esAbility[type].g_iPukeDeath);
	g_esCache[tank].g_iPukeEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPukeEffect, g_esAbility[type].g_iPukeEffect);
	g_esCache[tank].g_iPukeHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPukeHit, g_esAbility[type].g_iPukeHit);
	g_esCache[tank].g_iPukeHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPukeHitMode, g_esAbility[type].g_iPukeHitMode);
	g_esCache[tank].g_iPukeMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPukeMessage, g_esAbility[type].g_iPukeMessage);
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
			vPukeRange(iTank);
			vRemovePuke(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iPukeAbility == 1)
	{
		vPukeAbility(tank);
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

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iPukeAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vPukeAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemovePuke(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	vPukeRange(tank);
}

static void vPukeAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
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
				if (flDistance <= g_esCache[tank].g_flPukeRange)
				{
					vPukeHit(iSurvivor, tank, g_esCache[tank].g_flPukeRangeChance, g_esCache[tank].g_iPukeAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeAmmo");
	}
}

static void vPukeHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				SDKCall(g_hSDKPukePlayer, survivor, tank, true);

				vEffect(survivor, tank, g_esCache[tank].g_iPukeEffect, flags);

				if (g_esCache[tank].g_iPukeMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Puke", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeAmmo");
		}
	}
}

static void vPukeRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(tank) && g_esCache[tank].g_iPukeDeath == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPukeDeathChance)
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		vAttachParticle(tank, PARTICLE_BLOOD, 0.1, 0.0);

		static float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		static float flSurvivorPos[3], flDistance;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_esCache[tank].g_flPukeDeathRange)
				{
					SDKCall(g_hSDKPukePlayer, iSurvivor, tank, true);
				}
			}
		}
	}
}

static void vRemovePuke(int tank)
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
			vRemovePuke(iPlayer);
		}
	}
}