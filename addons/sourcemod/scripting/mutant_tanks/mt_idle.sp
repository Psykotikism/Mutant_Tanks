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
#include <dhooks>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Idle Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank forces survivors to go idle.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Idle Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_CONFIG_SECTION "idleability"
#define MT_CONFIG_SECTION2 "idle ability"
#define MT_CONFIG_SECTION3 "idle_ability"
#define MT_CONFIG_SECTION4 "idle"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_IDLE "Idle Ability"

enum struct esGeneral
{
	bool g_bApplyFix;
	bool g_bIgnoreSpec;

	DynamicDetour g_ddIdlePlayerDetour;
	DynamicDetour g_ddSpecPlayerDetour;

	Handle g_hSDKIdlePlayer;
	Handle g_hSDKObservePlayer;
	Handle g_hSDKSpecPlayer;

	int g_iSurvivorBot;
}

esGeneral g_esGeneral;

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flIdleChance;
	float g_flIdleRange;
	float g_flIdleRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iIdleAbility;
	int g_iIdleEffect;
	int g_iIdleHit;
	int g_iIdleHitMode;
	int g_iIdleMessage;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flIdleChance;
	float g_flIdleRange;
	float g_flIdleRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iIdleAbility;
	int g_iIdleEffect;
	int g_iIdleHit;
	int g_iIdleHitMode;
	int g_iIdleMessage;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flIdleChance;
	float g_flIdleRange;
	float g_flIdleRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iIdleAbility;
	int g_iIdleEffect;
	int g_iIdleHit;
	int g_iIdleHitMode;
	int g_iIdleMessage;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_idle", cmdIdleInfo, "View information about the Idle ability.");

	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");

		return;
	}

	g_esGeneral.g_ddIdlePlayerDetour = DynamicDetour.FromConf(gdMutantTanks, "CTerrorPlayer::GoAwayFromKeyboard");
	if (g_esGeneral.g_ddIdlePlayerDetour == null)
	{
		SetFailState("Failed to find signature: CTerrorPlayer::GoAwayFromKeyboard");
	}

	g_esGeneral.g_ddSpecPlayerDetour = DynamicDetour.FromConf(gdMutantTanks, "SurvivorBot::SetHumanSpectator");
	if (g_esGeneral.g_ddSpecPlayerDetour == null)
	{
		SetFailState("Failed to find signature: SurvivorBot::SetHumanSpectator");
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::GoAwayFromKeyboard"))
	{
		SetFailState("Failed to find signature: CTerrorPlayer::GoAwayFromKeyboard");
	}

	g_esGeneral.g_hSDKIdlePlayer = EndPrepSDKCall();
	if (g_esGeneral.g_hSDKIdlePlayer == null)
	{
		MT_LogMessage(MT_LOG_SERVER, "%s Your \"CTerrorPlayer::GoAwayFromKeyboard\" signature is outdated.", MT_TAG);
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "SurvivorBot::SetHumanSpectator"))
	{
		SetFailState("Failed to find signature: SurvivorBot::SetHumanSpectator");
	}

	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);

	g_esGeneral.g_hSDKSpecPlayer = EndPrepSDKCall();
	if (g_esGeneral.g_hSDKSpecPlayer == null)
	{
		MT_LogMessage(MT_LOG_SERVER, "%s Your \"SurvivorBot::SetHumanSpectator\" signature is outdated.", MT_TAG);
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CTerrorPlayer::SetObserverTarget"))
	{
		SetFailState("Failed to load offset: CTerrorPlayer::SetObserverTarget");
	}

	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);

	g_esGeneral.g_hSDKObservePlayer = EndPrepSDKCall();
	if (g_esGeneral.g_hSDKObservePlayer == null)
	{
		MT_LogMessage(MT_LOG_SERVER, "%s Your \"CTerrorPlayer::SetObserverTarget\" offsets are outdated.", MT_TAG);
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
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveIdle(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveIdle(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdIdleInfo(int client, int args)
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
		case false: vIdleMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vIdleMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iIdleMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Idle Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iIdleMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iIdleAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "IdleDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vIdleMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pIdle = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "IdleMenu", param1);
			pIdle.SetTitle(sMenuTitle);
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
	menu.AddItem(MT_MENU_IDLE, MT_MENU_IDLE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_IDLE, false))
	{
		vIdleMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_IDLE, false))
	{
		FormatEx(buffer, size, "%T", "IdleMenu2", client);
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (g_esGeneral.g_bApplyFix && classname[0] == 's' && StrEqual(classname, "survivor_bot", false))
	{
		g_esGeneral.g_iSurvivorBot = entity;
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsValidEntity(inflictor) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iIdleHitMode == 0 || g_esCache[attacker].g_iIdleHitMode == 1) && bIsHumanSurvivor(victim) && g_esCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vIdleHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esCache[attacker].g_flIdleChance, g_esCache[attacker].g_iIdleHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iIdleHitMode == 0 || g_esCache[victim].g_iIdleHitMode == 2) && bIsHumanSurvivor(attacker) && g_esCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vIdleHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esCache[victim].g_flIdleChance, g_esCache[victim].g_iIdleHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public MRESReturn mreIdlePlayerPre(int pThis, DHookReturn hReturn)
{
	if (g_esGeneral.g_bApplyFix)
	{
		LogError("Something went wrong with \"CTerrorPlayer::GoAwayFromKeyboard\"");
	}

	g_esGeneral.g_bApplyFix = true;
}

public MRESReturn mreIdlePlayerPost(int pThis, DHookReturn hReturn)
{
	if (g_esGeneral.g_bApplyFix && g_esGeneral.g_iSurvivorBot > 0 && !bIsValidClient(g_esGeneral.g_iSurvivorBot, MT_CHECK_FAKECLIENT))
	{
		g_esGeneral.g_bIgnoreSpec = true;

		SDKCall(g_esGeneral.g_hSDKSpecPlayer, g_esGeneral.g_iSurvivorBot, pThis);
		SDKCall(g_esGeneral.g_hSDKObservePlayer, pThis, g_esGeneral.g_iSurvivorBot);

		vOfferTakeover(pThis, g_esGeneral.g_iSurvivorBot);

		g_esPlayer[g_esGeneral.g_iSurvivorBot].g_bAffected = false;
		g_esGeneral.g_bIgnoreSpec = false;
	}

	g_esGeneral.g_iSurvivorBot = 0;
	g_esGeneral.g_bApplyFix = false;

	return MRES_Ignored;
}

public MRESReturn mreSpecPlayerPre(int pThis, DHookParam hParams)
{
	if (!g_esGeneral.g_bApplyFix || g_esGeneral.g_bIgnoreSpec || g_esGeneral.g_iSurvivorBot <= 0)
	{
		return MRES_Ignored;
	}

	return MRES_Supercede;
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
						if (g_esCache[tank].g_iIdleAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vIdleAbility(tank, random, iPos);
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
								if ((g_esCache[tank].g_iIdleHitMode == 0 || g_esCache[tank].g_iIdleHitMode == 1) && (StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vIdleHit(survivor, tank, random, flChance, g_esCache[tank].g_iIdleHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esCache[tank].g_iIdleHitMode == 0 || g_esCache[tank].g_iIdleHitMode == 2) && StrEqual(classname, "weapon_melee"))
								{
									vIdleHit(survivor, tank, random, flChance, g_esCache[tank].g_iIdleHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iIdleAbility = 0;
				g_esAbility[iIndex].g_iIdleEffect = 0;
				g_esAbility[iIndex].g_iIdleMessage = 0;
				g_esAbility[iIndex].g_flIdleChance = 33.3;
				g_esAbility[iIndex].g_iIdleHit = 0;
				g_esAbility[iIndex].g_iIdleHitMode = 0;
				g_esAbility[iIndex].g_flIdleRange = 150.0;
				g_esAbility[iIndex].g_flIdleRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iIdleAbility = 0;
					g_esPlayer[iPlayer].g_iIdleEffect = 0;
					g_esPlayer[iPlayer].g_iIdleMessage = 0;
					g_esPlayer[iPlayer].g_flIdleChance = 0.0;
					g_esPlayer[iPlayer].g_iIdleHit = 0;
					g_esPlayer[iPlayer].g_iIdleHitMode = 0;
					g_esPlayer[iPlayer].g_flIdleRange = 0.0;
					g_esPlayer[iPlayer].g_flIdleRangeChance = 0.0;
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
		g_esPlayer[admin].g_iIdleAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iIdleAbility, value, 0, 1);
		g_esPlayer[admin].g_iIdleEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iIdleEffect, value, 0, 7);
		g_esPlayer[admin].g_iIdleMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iIdleMessage, value, 0, 3);
		g_esPlayer[admin].g_flIdleChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleChance", "Idle Chance", "Idle_Chance", "chance", g_esPlayer[admin].g_flIdleChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iIdleHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleHit", "Idle Hit", "Idle_Hit", "hit", g_esPlayer[admin].g_iIdleHit, value, 0, 1);
		g_esPlayer[admin].g_iIdleHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleHitMode", "Idle Hit Mode", "Idle_Hit_Mode", "hitmode", g_esPlayer[admin].g_iIdleHitMode, value, 0, 2);
		g_esPlayer[admin].g_flIdleRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleRange", "Idle Range", "Idle_Range", "range", g_esPlayer[admin].g_flIdleRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flIdleRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleRangeChance", "Idle Range Chance", "Idle_Range_Chance", "rangechance", g_esPlayer[admin].g_flIdleRangeChance, value, 0.0, 100.0);

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
		g_esAbility[type].g_iIdleAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iIdleAbility, value, 0, 1);
		g_esAbility[type].g_iIdleEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iIdleEffect, value, 0, 7);
		g_esAbility[type].g_iIdleMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iIdleMessage, value, 0, 3);
		g_esAbility[type].g_flIdleChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleChance", "Idle Chance", "Idle_Chance", "chance", g_esAbility[type].g_flIdleChance, value, 0.0, 100.0);
		g_esAbility[type].g_iIdleHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleHit", "Idle Hit", "Idle_Hit", "hit", g_esAbility[type].g_iIdleHit, value, 0, 1);
		g_esAbility[type].g_iIdleHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleHitMode", "Idle Hit Mode", "Idle_Hit_Mode", "hitmode", g_esAbility[type].g_iIdleHitMode, value, 0, 2);
		g_esAbility[type].g_flIdleRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleRange", "Idle Range", "Idle_Range", "range", g_esAbility[type].g_flIdleRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flIdleRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "IdleRangeChance", "Idle Range Chance", "Idle_Range_Chance", "rangechance", g_esAbility[type].g_flIdleRangeChance, value, 0.0, 100.0);

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
	g_esCache[tank].g_flIdleChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flIdleChance, g_esAbility[type].g_flIdleChance);
	g_esCache[tank].g_flIdleRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flIdleRange, g_esAbility[type].g_flIdleRange);
	g_esCache[tank].g_flIdleRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flIdleRangeChance, g_esAbility[type].g_flIdleRangeChance);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iIdleAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iIdleAbility, g_esAbility[type].g_iIdleAbility);
	g_esCache[tank].g_iIdleEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iIdleEffect, g_esAbility[type].g_iIdleEffect);
	g_esCache[tank].g_iIdleHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iIdleHit, g_esAbility[type].g_iIdleHit);
	g_esCache[tank].g_iIdleHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iIdleHitMode, g_esAbility[type].g_iIdleHitMode);
	g_esCache[tank].g_iIdleMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iIdleMessage, g_esAbility[type].g_iIdleMessage);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveIdle(oldTank);
	}
}

public void MT_OnHookEvent(bool hooked)
{
	switch (hooked)
	{
		case true:
		{
			if (!g_esGeneral.g_ddIdlePlayerDetour.Enable(Hook_Pre, mreIdlePlayerPre))
			{
				SetFailState("Failed to enable detour pre: CTerrorPlayer::GoAwayFromKeyboard");
			}

			if (!g_esGeneral.g_ddIdlePlayerDetour.Enable(Hook_Post, mreIdlePlayerPost))
			{
				SetFailState("Failed to enable detour post: CTerrorPlayer::GoAwayFromKeyboard");
			}

			if (!g_esGeneral.g_ddSpecPlayerDetour.Enable(Hook_Pre, mreSpecPlayerPre))
			{
				SetFailState("Failed to enable detour pre: SurvivorBot::SetHumanSpectator");
			}
		}
		case false:
		{
			if (!g_esGeneral.g_ddIdlePlayerDetour.Disable(Hook_Pre, mreIdlePlayerPre))
			{
				SetFailState("Failed to disable detour pre: CTerrorPlayer::GoAwayFromKeyboard");
			}

			if (!g_esGeneral.g_ddIdlePlayerDetour.Disable(Hook_Post, mreIdlePlayerPost))
			{
				SetFailState("Failed to disable detour post: CTerrorPlayer::GoAwayFromKeyboard");
			}

			if (!g_esGeneral.g_ddSpecPlayerDetour.Disable(Hook_Pre, mreSpecPlayerPre))
			{
				SetFailState("Failed to disable detour pre: SurvivorBot::SetHumanSpectator");
			}
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
			vCopyStats(iBot, iTank);
			vRemoveIdle(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveIdle(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(iTank))
		{
			vRemoveIdle(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start"))
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

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iIdleAbility == 1 && g_esCache[tank].g_iComboAbility == 0)
	{
		vIdleAbility(tank, GetRandomFloat(0.1, 100.0));
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
			if (g_esCache[tank].g_iIdleAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "IdleHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vIdleAbility(tank, GetRandomFloat(0.1, 100.0));
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveIdle(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vIdleAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		g_esPlayer[tank].g_bFailed = false;
		g_esPlayer[tank].g_bNoAmmo = false;

		static float flTankPos[3], flSurvivorPos[3], flRange, flChance;
		GetClientAbsOrigin(tank, flTankPos);
		flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esCache[tank].g_flIdleRange;
		flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esCache[tank].g_flIdleRangeChance;
		static int iSurvivorCount;
		iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange)
				{
					vIdleHit(iSurvivor, tank, random, flChance, g_esCache[tank].g_iIdleAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "IdleHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "IdleAmmo");
	}
}

static void vIdleHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsHumanSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (random <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iAmmoCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "IdleHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "IdleHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				switch (iGetHumanCount() > 1)
				{
					case true: FakeClientCommand(survivor, "go_away_from_keyboard");
					case false: SDKCall(g_esGeneral.g_hSDKIdlePlayer, survivor);
				}

				if (bIsBotIdle(survivor))
				{
					g_esPlayer[survivor].g_bAffected = true;

					vEffect(survivor, tank, g_esCache[tank].g_iIdleEffect, flags);

					if (g_esCache[tank].g_iIdleMessage & messages)
					{
						static char sTankName[33];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Idle", sTankName, survivor);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Idle", LANG_SERVER, sTankName, survivor);
					}
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "IdleHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "IdleAmmo");
		}
	}
}

static void vOfferTakeover(int survivor, int bot)
{
	static char sValue[2];
	static int iCharacter;
	iCharacter = GetEntProp(bot, Prop_Send, "m_survivorCharacter", 1);
	IntToString(iCharacter, sValue, sizeof(sValue));

	static BfWrite bfWrite;
	bfWrite = view_as<BfWrite>(StartMessageOne("VGUIMenu", survivor));
	bfWrite.WriteString("takeover_survivor_bar");
	bfWrite.WriteByte(true);
	bfWrite.WriteByte(1);
	bfWrite.WriteString("character");
	bfWrite.WriteString(sValue);

	EndMessage();
}

static void vRemoveIdle(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
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
			vRemoveIdle(iPlayer);
		}
	}
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iIdleAbility == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vIdleAbility(iTank, flRandom, iPos);

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
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iIdleHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof(sClassname));
	if ((g_esCache[iTank].g_iIdleHitMode == 0 || g_esCache[iTank].g_iIdleHitMode == 1) && (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vIdleHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iIdleHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esCache[iTank].g_iIdleHitMode == 0 || g_esCache[iTank].g_iIdleHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
	{
		vIdleHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iIdleHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}

	return Plugin_Continue;
}