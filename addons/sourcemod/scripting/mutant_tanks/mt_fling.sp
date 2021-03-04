/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2021  Alfred "Crasher_3637/Psyk0tik" Llagas
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

public Plugin myinfo =
{
	name = "[MT] Fling Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank flings survivors high into the air.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad, g_bSecondGame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Fling Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define MT_CONFIG_SECTION "flingability"
#define MT_CONFIG_SECTION2 "fling ability"
#define MT_CONFIG_SECTION3 "fling_ability"
#define MT_CONFIG_SECTION4 "fling"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_FLING "Fling Ability"

enum struct esGeneral
{
	Handle g_hSDKFling;
	Handle g_hSDKVomitUpon;
}

esGeneral g_esGeneral;

enum struct esPlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flFlingChance;
	float g_flFlingDeathChance;
	float g_flFlingDeathRange;
	float g_flFlingForce;
	float g_flFlingRange;
	float g_flFlingRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iFlingAbility;
	int g_iFlingDeath;
	int g_iFlingEffect;
	int g_iFlingHit;
	int g_iFlingHitMode;
	int g_iFlingMessage;
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
	float g_flFlingChance;
	float g_flFlingDeathChance;
	float g_flFlingDeathRange;
	float g_flFlingForce;
	float g_flFlingRange;
	float g_flFlingRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iFlingAbility;
	int g_iFlingDeath;
	int g_iFlingEffect;
	int g_iFlingHit;
	int g_iFlingHitMode;
	int g_iFlingMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flFlingChance;
	float g_flFlingDeathChance;
	float g_flFlingDeathRange;
	float g_flFlingForce;
	float g_flFlingRange;
	float g_flFlingRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iFlingAbility;
	int g_iFlingDeath;
	int g_iFlingEffect;
	int g_iFlingHit;
	int g_iFlingHitMode;
	int g_iFlingMessage;
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
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_fling", cmdFlingInfo, "View information about the Fling ability.");

	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");

		delete gdMutantTanks;
	}

	switch (g_bSecondGame)
	{
		case true:
		{
			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::Fling"))
			{
				SetFailState("Failed to find signature: CTerrorPlayer::Fling");

				delete gdMutantTanks;
			}

			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);

			g_esGeneral.g_hSDKFling = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKFling == null)
			{
				LogError("%s Your \"CTerrorPlayer::Fling\" signature is outdated.", MT_TAG);
			}
		}
		case false:
		{
			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnVomitedUpon"))
			{
				SetFailState("Failed to find signature: CTerrorPlayer::OnVomitedUpon");

				delete gdMutantTanks;
			}

			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);

			g_esGeneral.g_hSDKVomitUpon = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKVomitUpon == null)
			{
				LogError("%s Your \"CTerrorPlayer::OnVomitedUpon\" signature is outdated.", MT_TAG);
			}
		}
	}

	delete gdMutantTanks;

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
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

	vRemoveFling(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveFling(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFlingInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vFlingMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFlingMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFlingMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fling Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iFlingMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iFlingAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "FlingDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vFlingMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pFling = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "FlingMenu", param1);
			pFling.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);
					case 2: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 5: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_FLING, MT_MENU_FLING);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_FLING, false))
	{
		vFlingMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_FLING, false))
	{
		FormatEx(buffer, size, "%T", "FlingMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsValidEntity(inflictor) && damage > 0.0)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iFlingHitMode == 0 || g_esCache[attacker].g_iFlingHitMode == 1) && bIsSurvivor(victim) && g_esCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vFlingHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esCache[attacker].g_flFlingChance, g_esCache[attacker].g_iFlingHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iFlingHitMode == 0 || g_esCache[victim].g_iFlingHitMode == 2) && bIsSurvivor(attacker) && g_esCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vFlingHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esCache[victim].g_flFlingChance, g_esCache[victim].g_iFlingHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString(MT_CONFIG_SECTION);
	list2.PushString(MT_CONFIG_SECTION2);
	list3.PushString(MT_CONFIG_SECTION3);
	list4.PushString(MT_CONFIG_SECTION4);
}

public void MT_OnCombineAbilities(int tank, int type, float random, const char[] combo, int survivor, int weapon, const char[] classname)
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION4);
	if (g_esCache[tank].g_iComboAbility == 1 && (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1))
	{
		static char sSubset[10][32];
		ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
		for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_CONFIG_SECTION, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION2, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION3, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION4, false))
			{
				static float flDelay;
				flDelay = MT_GetCombinationSetting(tank, 3, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esCache[tank].g_iFlingAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vFlingAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}
					}
					case MT_COMBO_MELEEHIT:
					{
						static float flChance;
						flChance = MT_GetCombinationSetting(tank, 1, iPos);

						switch (flDelay)
						{
							case 0.0:
							{
								if ((g_esCache[tank].g_iFlingHitMode == 0 || g_esCache[tank].g_iFlingHitMode == 1) && (StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vFlingHit(survivor, tank, random, flChance, g_esCache[tank].g_iFlingHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esCache[tank].g_iFlingHitMode == 0 || g_esCache[tank].g_iFlingHitMode == 2) && StrEqual(classname, "weapon_melee"))
								{
									vFlingHit(survivor, tank, random, flChance, g_esCache[tank].g_iFlingHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteString(classname);
							}
						}
					}
					case MT_COMBO_POSTSPAWN: vFlingRange(tank, 0, random, iPos);
					case MT_COMBO_UPONDEATH: vFlingRange(tank, 0, random, iPos);
				}

				break;
			}
		}
	}
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
				g_esAbility[iIndex].g_iComboAbility = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iFlingAbility = 0;
				g_esAbility[iIndex].g_iFlingEffect = 0;
				g_esAbility[iIndex].g_iFlingMessage = 0;
				g_esAbility[iIndex].g_flFlingChance = 33.3;
				g_esAbility[iIndex].g_iFlingDeath = 0;
				g_esAbility[iIndex].g_flFlingDeathChance = 33.3;
				g_esAbility[iIndex].g_flFlingDeathRange = 200.0;
				g_esAbility[iIndex].g_flFlingForce = 300.0;
				g_esAbility[iIndex].g_iFlingHit = 0;
				g_esAbility[iIndex].g_iFlingHitMode = 0;
				g_esAbility[iIndex].g_flFlingRange = 150.0;
				g_esAbility[iIndex].g_flFlingRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iComboAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iFlingAbility = 0;
					g_esPlayer[iPlayer].g_iFlingEffect = 0;
					g_esPlayer[iPlayer].g_iFlingMessage = 0;
					g_esPlayer[iPlayer].g_flFlingChance = 0.0;
					g_esPlayer[iPlayer].g_iFlingDeath = 0;
					g_esPlayer[iPlayer].g_flFlingDeathChance = 0.0;
					g_esPlayer[iPlayer].g_flFlingDeathRange = 0.0;
					g_esPlayer[iPlayer].g_flFlingForce = 0.0;
					g_esPlayer[iPlayer].g_iFlingHit = 0;
					g_esPlayer[iPlayer].g_iFlingHitMode = 0;
					g_esPlayer[iPlayer].g_flFlingRange = 0.0;
					g_esPlayer[iPlayer].g_flFlingRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iFlingAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iFlingAbility, value, 0, 1);
		g_esPlayer[admin].g_iFlingEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iFlingEffect, value, 0, 7);
		g_esPlayer[admin].g_iFlingMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iFlingMessage, value, 0, 3);
		g_esPlayer[admin].g_flFlingChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingChance", "Fling Chance", "Fling_Chance", "chance", g_esPlayer[admin].g_flFlingChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iFlingDeath = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingDeath", "Fling Death", "Fling_Death", "death", g_esPlayer[admin].g_iFlingDeath, value, 0, 1);
		g_esPlayer[admin].g_flFlingDeathChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingDeathChance", "Fling Death Chance", "Fling_Death_Chance", "deathchance", g_esPlayer[admin].g_flFlingDeathChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flFlingDeathRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingDeathRange", "Fling Death Range", "Fling_Death_Range", "deathrange", g_esPlayer[admin].g_flFlingDeathRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flFlingForce = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingForce", "Fling Force", "Fling_Force", "force", g_esPlayer[admin].g_flFlingForce, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iFlingHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingHit", "Fling Hit", "Fling_Hit", "hit", g_esPlayer[admin].g_iFlingHit, value, 0, 1);
		g_esPlayer[admin].g_iFlingHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingHitMode", "Fling Hit Mode", "Fling_Hit_Mode", "hitmode", g_esPlayer[admin].g_iFlingHitMode, value, 0, 2);
		g_esPlayer[admin].g_flFlingRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingRange", "Fling Range", "Fling_Range", "range", g_esPlayer[admin].g_flFlingRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flFlingRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingRangeChance", "Fling Range Chance", "Fling_Range_Chance", "rangechance", g_esPlayer[admin].g_flFlingRangeChance, value, 0.0, 100.0);

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
		g_esAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAbility[type].g_iComboAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iFlingAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iFlingAbility, value, 0, 1);
		g_esAbility[type].g_iFlingEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iFlingEffect, value, 0, 7);
		g_esAbility[type].g_iFlingMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iFlingMessage, value, 0, 3);
		g_esAbility[type].g_flFlingChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingChance", "Fling Chance", "Fling_Chance", "chance", g_esAbility[type].g_flFlingChance, value, 0.0, 100.0);
		g_esAbility[type].g_iFlingDeath = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingDeath", "Fling Death", "Fling_Death", "death", g_esAbility[type].g_iFlingDeath, value, 0, 1);
		g_esAbility[type].g_flFlingDeathChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingDeathChance", "Fling Death Chance", "Fling_Death_Chance", "deathchance", g_esAbility[type].g_flFlingDeathChance, value, 0.0, 100.0);
		g_esAbility[type].g_flFlingDeathRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingDeathRange", "Fling Death Range", "Fling_Death_Range", "deathrange", g_esAbility[type].g_flFlingDeathRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flFlingForce = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingForce", "Fling Force", "Fling_Force", "force", g_esAbility[type].g_flFlingForce, value, 1.0, 999999.0);
		g_esAbility[type].g_iFlingHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingHit", "Fling Hit", "Fling_Hit", "hit", g_esAbility[type].g_iFlingHit, value, 0, 1);
		g_esAbility[type].g_iFlingHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingHitMode", "Fling Hit Mode", "Fling_Hit_Mode", "hitmode", g_esAbility[type].g_iFlingHitMode, value, 0, 2);
		g_esAbility[type].g_flFlingRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingRange", "Fling Range", "Fling_Range", "range", g_esAbility[type].g_flFlingRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flFlingRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FlingRangeChance", "Fling Range Chance", "Fling_Range_Chance", "rangechance", g_esAbility[type].g_flFlingRangeChance, value, 0.0, 100.0);

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
	bool bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flFlingChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFlingChance, g_esAbility[type].g_flFlingChance);
	g_esCache[tank].g_flFlingDeathChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFlingDeathChance, g_esAbility[type].g_flFlingDeathChance);
	g_esCache[tank].g_flFlingDeathRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFlingDeathRange, g_esAbility[type].g_flFlingDeathRange);
	g_esCache[tank].g_flFlingForce = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFlingForce, g_esAbility[type].g_flFlingForce);
	g_esCache[tank].g_flFlingRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFlingRange, g_esAbility[type].g_flFlingRange);
	g_esCache[tank].g_flFlingRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFlingRangeChance, g_esAbility[type].g_flFlingRangeChance);
	g_esCache[tank].g_iFlingAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFlingAbility, g_esAbility[type].g_iFlingAbility);
	g_esCache[tank].g_iFlingDeath = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFlingDeath, g_esAbility[type].g_iFlingDeath);
	g_esCache[tank].g_iFlingEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFlingEffect, g_esAbility[type].g_iFlingEffect);
	g_esCache[tank].g_iFlingHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFlingHit, g_esAbility[type].g_iFlingHit);
	g_esCache[tank].g_iFlingHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFlingHitMode, g_esAbility[type].g_iFlingHitMode);
	g_esCache[tank].g_iFlingMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFlingMessage, g_esAbility[type].g_iFlingMessage);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveFling(oldTank);
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
			vRemoveFling(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveFling(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vFlingRange(iTank, 1, GetRandomFloat(0.1, 100.0));
			vRemoveFling(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vReset();
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iFlingAbility == 1 && g_esCache[tank].g_iComboAbility == 0)
	{
		vFlingAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iFlingAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlingHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vFlingAbility(tank, GetRandomFloat(0.1, 100.0));
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveFling(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	vFlingRange(tank, 1, GetRandomFloat(0.1, 100.0));
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vFling(int survivor, int tank)
{
	static float flSurvivorPos[3], flTankPos[3], flDistance[3], flRatio[3], flVelocity[3];
	GetClientAbsOrigin(survivor, flSurvivorPos);
	GetClientAbsOrigin(tank, flTankPos);

	flDistance[0] = (flTankPos[0] - flSurvivorPos[0]);
	flDistance[1] = (flTankPos[1] - flSurvivorPos[1]);
	flDistance[2] = (flTankPos[2] - flSurvivorPos[2]);

	flRatio[0] = flDistance[0] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));
	flRatio[1] = flDistance[1] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));

	flVelocity[0] = (flRatio[0] * -1) * g_esCache[tank].g_flFlingForce;
	flVelocity[1] = (flRatio[1] * -1) * g_esCache[tank].g_flFlingForce;
	flVelocity[2] = g_esCache[tank].g_flFlingForce;

	SDKCall(g_esGeneral.g_hSDKFling, survivor, flVelocity, 76, tank, 3.0);
}

static void vFlingAbility(int tank, float random, int pos = -1)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
	{
		return;
	}

	if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		g_esPlayer[tank].g_bFailed = false;
		g_esPlayer[tank].g_bNoAmmo = false;

		static float flTankPos[3], flSurvivorPos[3], flRange, flChance;
		GetClientAbsOrigin(tank, flTankPos);
		flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esCache[tank].g_flFlingRange;
		flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esCache[tank].g_flFlingRangeChance;
		static int iSurvivorCount;
		iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bIsPlayerDisabled(iSurvivor) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange)
				{
					vFlingHit(iSurvivor, tank, random, flChance, g_esCache[tank].g_iFlingAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlingHuman4");
			}
		}
	}
	else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlingAmmo");
	}
}

static void vFlingHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !bIsPlayerDisabled(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_GODMODE))
	{
		if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (random <= chance)
			{
				if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iAmmoCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlingHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlingHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				vEffect(survivor, tank, g_esCache[tank].g_iFlingEffect, flags);

				static char sTankName[33];
				MT_GetTankName(tank, sTankName);

				switch (g_bSecondGame)
				{
					case true:
					{
						if (g_esGeneral.g_hSDKFling != null)
						{
							vFling(survivor, tank);

							if (g_esCache[tank].g_iFlingMessage & messages)
							{
								MT_PrintToChatAll("%s %t", MT_TAG2, "Fling", sTankName, survivor);
								MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Fling", LANG_SERVER, sTankName, survivor);
							}
						}
					}
					case false:
					{
						if (g_esGeneral.g_hSDKVomitUpon != null)
						{
							SDKCall(g_esGeneral.g_hSDKVomitUpon, survivor, tank, true);

							if (g_esCache[tank].g_iFlingMessage & messages)
							{
								MT_PrintToChatAll("%s %t", MT_TAG2, "Puke", sTankName, survivor);
								MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Puke", LANG_SERVER, sTankName, survivor);
							}
						}
					}
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlingHuman2");
				}
			}
		}
		else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlingAmmo");
		}
	}
}

static void vFlingRange(int tank, int value, float random, int pos = -1)
{
	static float flChance;
	flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 11, pos) : g_esCache[tank].g_flFlingDeathChance;
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iFlingDeath == 1 && random <= flChance)
	{
		if (g_esCache[tank].g_iComboAbility == value || bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		switch (g_bSecondGame)
		{
			case true:
			{
				if (g_esGeneral.g_hSDKFling == null)
				{
					return;
				}
			}
			case false:
			{
				if (g_esGeneral.g_hSDKVomitUpon == null)
				{
					return;
				}

				vAttachParticle(tank, PARTICLE_BLOOD, 0.1);
			}
		}

		static float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		static float flSurvivorPos[3], flDistance, flRange;
		flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esCache[tank].g_flFlingDeathRange;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bIsPlayerDisabled(iSurvivor) && !MT_DoesSurvivorHaveRewardType(iSurvivor, MT_REWARD_GODMODE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRange)
				{
					switch (g_bSecondGame)
					{
						case true: vFling(iSurvivor, tank);
						case false: SDKCall(g_esGeneral.g_hSDKVomitUpon, iSurvivor, tank, true);
					}
				}
			}
		}
	}
}

static void vRemoveFling(int tank)
{
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveFling(iPlayer);
		}
	}
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iFlingAbility == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vFlingAbility(iTank, flRandom, iPos);

	return Plugin_Continue;
}

public Action tTimerCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iFlingHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof(sClassname));
	if ((g_esCache[iTank].g_iFlingHitMode == 0 || g_esCache[iTank].g_iFlingHitMode == 1) && (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vFlingHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iFlingHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esCache[iTank].g_iFlingHitMode == 0 || g_esCache[iTank].g_iFlingHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
	{
		vFlingHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iFlingHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}

	return Plugin_Continue;
}