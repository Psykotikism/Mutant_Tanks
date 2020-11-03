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

//#file "Acid Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Acid Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates acid puddles.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Acid Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define MT_CONFIG_SECTION "acidability"
#define MT_CONFIG_SECTION2 "acid ability"
#define MT_CONFIG_SECTION3 "acid_ability"
#define MT_CONFIG_SECTION4 "acid"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_ACID "Acid Ability"

enum struct esGeneral
{
	Handle g_hSDKAcidPlayer;
	Handle g_hSDKPukePlayer;
}

esGeneral g_esGeneral;

enum struct esPlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flAcidChance;
	float g_flAcidDeathChance;
	float g_flAcidDeathRange;
	float g_flAcidRange;
	float g_flAcidRangeChance;
	float g_flAcidRockChance;

	int g_iAccessFlags;
	int g_iAcidAbility;
	int g_iAcidDeath;
	int g_iAcidEffect;
	int g_iAcidHit;
	int g_iAcidHitMode;
	int g_iAcidMessage;
	int g_iAcidRockBreak;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flAcidChance;
	float g_flAcidDeathChance;
	float g_flAcidDeathRange;
	float g_flAcidRange;
	float g_flAcidRangeChance;
	float g_flAcidRockChance;

	int g_iAccessFlags;
	int g_iAcidAbility;
	int g_iAcidDeath;
	int g_iAcidEffect;
	int g_iAcidHit;
	int g_iAcidHitMode;
	int g_iAcidMessage;
	int g_iAcidRockBreak;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flAcidChance;
	float g_flAcidDeathChance;
	float g_flAcidDeathRange;
	float g_flAcidRange;
	float g_flAcidRangeChance;
	float g_flAcidRockChance;

	int g_iAccessFlags;
	int g_iAcidAbility;
	int g_iAcidDeath;
	int g_iAcidEffect;
	int g_iAcidHit;
	int g_iAcidHitMode;
	int g_iAcidMessage;
	int g_iAcidRockBreak;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_acid", cmdAcidInfo, "View information about the Acid ability.");

	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");

		return;
	}

	switch (bIsValidGame())
	{
		case true:
		{
			StartPrepSDKCall(SDKCall_Static);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CSpitterProjectile::Create"))
			{
				SetFailState("Failed to find signature: CSpitterProjectile::Create");
			}

			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
			PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);

			g_esGeneral.g_hSDKAcidPlayer = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKAcidPlayer == null)
			{
				MT_LogMessage(MT_LOG_SERVER, "%s Your \"CSpitterProjectile::Create\" signature is outdated.", MT_TAG);
			}
		}
		case false:
		{
			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnVomitedUpon"))
			{
				SetFailState("Failed to find signature: CTerrorPlayer::OnVomitedUpon");
			}

			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);

			g_esGeneral.g_hSDKPukePlayer = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKPukePlayer == null)
			{
				MT_LogMessage(MT_LOG_SERVER, "%s Your \"CTerrorPlayer::OnVomitedUpon\" signature is outdated.", MT_TAG);
			}
		}
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

	vRemoveAcid(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveAcid(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdAcidInfo(int client, int args)
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
		case false: vAcidMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vAcidMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iAcidMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Acid Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iAcidMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iAcidAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AcidDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vAcidMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "AcidMenu", param1);
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
	menu.AddItem(MT_MENU_ACID, MT_MENU_ACID);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ACID, false))
	{
		vAcidMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_ACID, false))
	{
		FormatEx(buffer, size, "%T", "AcidMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iAcidHitMode == 0 || g_esCache[attacker].g_iAcidHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAcidHit(victim, attacker, g_esCache[attacker].g_flAcidChance, g_esCache[attacker].g_iAcidHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iAcidHitMode == 0 || g_esCache[victim].g_iAcidHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAcidHit(attacker, victim, g_esCache[victim].g_flAcidChance, g_esCache[victim].g_iAcidHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
				g_esAbility[iIndex].g_iAcidAbility = 0;
				g_esAbility[iIndex].g_iAcidEffect = 0;
				g_esAbility[iIndex].g_iAcidMessage = 0;
				g_esAbility[iIndex].g_flAcidChance = 33.3;
				g_esAbility[iIndex].g_iAcidDeath = 0;
				g_esAbility[iIndex].g_flAcidDeathChance = 33.3;
				g_esAbility[iIndex].g_flAcidDeathRange = 200.0;
				g_esAbility[iIndex].g_iAcidHit = 0;
				g_esAbility[iIndex].g_iAcidHitMode = 0;
				g_esAbility[iIndex].g_flAcidRange = 150.0;
				g_esAbility[iIndex].g_flAcidRangeChance = 15.0;
				g_esAbility[iIndex].g_iAcidRockBreak = 0;
				g_esAbility[iIndex].g_flAcidRockChance = 33.3;
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
					g_esPlayer[iPlayer].g_iAcidAbility = 0;
					g_esPlayer[iPlayer].g_iAcidEffect = 0;
					g_esPlayer[iPlayer].g_iAcidMessage = 0;
					g_esPlayer[iPlayer].g_flAcidChance = 0.0;
					g_esPlayer[iPlayer].g_iAcidDeath = 0;
					g_esPlayer[iPlayer].g_flAcidDeathChance = 0.0;
					g_esPlayer[iPlayer].g_flAcidDeathRange = 0.0;
					g_esPlayer[iPlayer].g_iAcidHit = 0;
					g_esPlayer[iPlayer].g_iAcidHitMode = 0;
					g_esPlayer[iPlayer].g_flAcidRange = 0.0;
					g_esPlayer[iPlayer].g_flAcidRangeChance = 0.0;
					g_esPlayer[iPlayer].g_iAcidRockBreak = 0;
					g_esPlayer[iPlayer].g_flAcidRockChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iAcidAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iAcidAbility, value, 0, 1);
		g_esPlayer[admin].g_iAcidEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iAcidEffect, value, 0, 7);
		g_esPlayer[admin].g_iAcidMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iAcidMessage, value, 0, 7);
		g_esPlayer[admin].g_flAcidChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidChance", "Acid Chance", "Acid_Chance", "chance", g_esPlayer[admin].g_flAcidChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iAcidDeath = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidDeath", "Acid Death", "Acid_Death", "death", g_esPlayer[admin].g_iAcidDeath, value, 0, 1);
		g_esPlayer[admin].g_flAcidDeathChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidDeathChance", "Acid Death Chance", "Acid_Death_Chance", "deathchance", g_esPlayer[admin].g_flAcidDeathChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flAcidDeathRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidDeathRange", "Acid Death Range", "Acid_Death_Range", "deathrange", g_esPlayer[admin].g_flAcidDeathRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iAcidHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidHit", "Acid Hit", "Acid_Hit", "hit", g_esPlayer[admin].g_iAcidHit, value, 0, 1);
		g_esPlayer[admin].g_iAcidHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidHitMode", "Acid Hit Mode", "Acid_Hit_Mode", "hitmode", g_esPlayer[admin].g_iAcidHitMode, value, 0, 2);
		g_esPlayer[admin].g_flAcidRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidRange", "Acid Range", "Acid_Range", "range", g_esPlayer[admin].g_flAcidRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flAcidRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidRangeChance", "Acid Range Chance", "Acid_Range_Chance", "rangechance", g_esPlayer[admin].g_flAcidRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iAcidRockBreak = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidRockBreak", "Acid Rock Break", "Acid_Rock_Break", "rock", g_esPlayer[admin].g_iAcidRockBreak, value, 0, 1);
		g_esPlayer[admin].g_flAcidRockChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidRockChance", "Acid Rock Chance", "Acid_Rock_Chance", "rockchance", g_esPlayer[admin].g_flAcidRockChance, value, 0.0, 100.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iAcidAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iAcidAbility, value, 0, 1);
		g_esAbility[type].g_iAcidEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iAcidEffect, value, 0, 7);
		g_esAbility[type].g_iAcidMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iAcidMessage, value, 0, 7);
		g_esAbility[type].g_flAcidChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidChance", "Acid Chance", "Acid_Chance", "chance", g_esAbility[type].g_flAcidChance, value, 0.0, 100.0);
		g_esAbility[type].g_iAcidDeath = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidDeath", "Acid Death", "Acid_Death", "death", g_esAbility[type].g_iAcidDeath, value, 0, 1);
		g_esAbility[type].g_flAcidDeathChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidDeathChance", "Acid Death Chance", "Acid_Death_Chance", "deathchance", g_esAbility[type].g_flAcidDeathChance, value, 0.0, 100.0);
		g_esAbility[type].g_flAcidDeathRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidDeathRange", "Acid Death Range", "Acid_Death_Range", "deathrange", g_esAbility[type].g_flAcidDeathRange, value, 1.0, 999999.0);
		g_esAbility[type].g_iAcidHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidHit", "Acid Hit", "Acid_Hit", "hit", g_esAbility[type].g_iAcidHit, value, 0, 1);
		g_esAbility[type].g_iAcidHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidHitMode", "Acid Hit Mode", "Acid_Hit_Mode", "hitmode", g_esAbility[type].g_iAcidHitMode, value, 0, 2);
		g_esAbility[type].g_flAcidRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidRange", "Acid Range", "Acid_Range", "range", g_esAbility[type].g_flAcidRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flAcidRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidRangeChance", "Acid Range Chance", "Acid_Range_Chance", "rangechance", g_esAbility[type].g_flAcidRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iAcidRockBreak = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidRockBreak", "Acid Rock Break", "Acid_Rock_Break", "rock", g_esAbility[type].g_iAcidRockBreak, value, 0, 1);
		g_esAbility[type].g_flAcidRockChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AcidRockChance", "Acid Rock Chance", "Acid_Rock_Chance", "rockchance", g_esAbility[type].g_flAcidRockChance, value, 0.0, 100.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
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
	g_esCache[tank].g_flAcidChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAcidChance, g_esAbility[type].g_flAcidChance);
	g_esCache[tank].g_flAcidDeathChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAcidDeathChance, g_esAbility[type].g_flAcidDeathChance);
	g_esCache[tank].g_flAcidDeathRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAcidDeathRange, g_esAbility[type].g_flAcidDeathRange);
	g_esCache[tank].g_flAcidRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAcidRange, g_esAbility[type].g_flAcidRange);
	g_esCache[tank].g_flAcidRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAcidRangeChance, g_esAbility[type].g_flAcidRangeChance);
	g_esCache[tank].g_flAcidRockChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAcidRockChance, g_esAbility[type].g_flAcidRockChance);
	g_esCache[tank].g_iAcidAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAcidAbility, g_esAbility[type].g_iAcidAbility);
	g_esCache[tank].g_iAcidDeath = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAcidDeath, g_esAbility[type].g_iAcidDeath);
	g_esCache[tank].g_iAcidEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAcidEffect, g_esAbility[type].g_iAcidEffect);
	g_esCache[tank].g_iAcidHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAcidHit, g_esAbility[type].g_iAcidHit);
	g_esCache[tank].g_iAcidHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAcidHitMode, g_esAbility[type].g_iAcidHitMode);
	g_esCache[tank].g_iAcidMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAcidMessage, g_esAbility[type].g_iAcidMessage);
	g_esCache[tank].g_iAcidRockBreak = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAcidRockBreak, g_esAbility[type].g_iAcidRockBreak);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveAcid(oldTank);
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
			vCopyStats(iBot, iTank);
			vRemoveAcid(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveAcid(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vAcidRange(iTank, false);
			vRemoveAcid(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start"))
	{
		vReset();
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iAcidAbility == 1)
	{
		vAcidAbility(tank);
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
			if (g_esCache[tank].g_iAcidAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "AcidHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vAcidAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveAcid(tank);

	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && bIsValidGame() && g_esCache[tank].g_iAcidAbility == 1)
	{
		if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
		{
			return;
		}

		vAcid(tank, tank);
	}
}

public void MT_OnPostTankSpawn(int tank)
{
	vAcidRange(tank, true);
}

public void MT_OnRockBreak(int tank, int rock)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iAcidRockBreak == 1 && bIsValidGame())
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flAcidRockChance)
		{
			static float flOrigin[3], flAngles[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flOrigin);
			flOrigin[2] += 40.0;

			SDKCall(g_esGeneral.g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, tank, 2.0);

			if (g_esCache[tank].g_iAcidMessage & MT_MESSAGE_SPECIAL)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Acid2", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Acid2", LANG_SERVER, sTankName);
			}
		}
	}
}

static void vAcid(int survivor, int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static float flOrigin[3], flAngles[3];
	GetClientAbsOrigin(survivor, flOrigin);
	GetClientAbsAngles(survivor, flAngles);

	SDKCall(g_esGeneral.g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, tank, 2.0);
}

static void vAcidAbility(int tank)
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
				if (flDistance <= g_esCache[tank].g_flAcidRange)
				{
					vAcidHit(iSurvivor, tank, g_esCache[tank].g_flAcidRangeChance, g_esCache[tank].g_iAcidAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "AcidHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "AcidAmmo");
	}
}

static void vAcidHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
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

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "AcidHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "AcidHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static char sTankName[33];
				MT_GetTankName(tank, sTankName);

				switch (bIsValidGame())
				{
					case true:
					{
						vAcid(survivor, tank);

						if (g_esCache[tank].g_iAcidMessage & messages)
						{
							MT_PrintToChatAll("%s %t", MT_TAG2, "Acid", sTankName, survivor);
							MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Acid", LANG_SERVER, sTankName, survivor);
						}
					}
					case false:
					{
						SDKCall(g_esGeneral.g_hSDKPukePlayer, survivor, tank, true);

						if (g_esCache[tank].g_iAcidMessage & messages)
						{
							MT_PrintToChatAll("%s %t", MT_TAG2, "Puke", sTankName, survivor);
							MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Puke", LANG_SERVER, sTankName, survivor);
						}
					}
				}

				vEffect(survivor, tank, g_esCache[tank].g_iAcidEffect, flags);
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "AcidHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "AcidAmmo");
		}
	}
}

static void vAcidRange(int tank, bool idle)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iAcidDeath == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flAcidDeathChance)
	{
		if ((idle && MT_IsTankIdle(tank)) || bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		switch (bIsValidGame())
		{
			case true: vAcid(tank, tank);
			case false:
			{
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
						if (flDistance <= g_esCache[tank].g_flAcidDeathRange)
						{
							SDKCall(g_esGeneral.g_hSDKPukePlayer, iSurvivor, tank, true);
						}
					}
				}
			}
		}
	}
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
	g_esPlayer[newTank].g_iCount = g_esPlayer[oldTank].g_iCount;
}

static void vRemoveAcid(int tank)
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
			vRemoveAcid(iPlayer);
		}
	}
}