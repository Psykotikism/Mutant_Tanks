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
	name = "[MT] Shield Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank protects itself with a shield and throws propane tanks or gas cans.",
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
			strcopy(error, err_max, "\"[MT] Shield Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"

#define SOUND_METAL "physics/metal/metal_solid_impact_hard5.wav"

#define MT_CONFIG_SECTION "shieldability"
#define MT_CONFIG_SECTION2 "shield ability"
#define MT_CONFIG_SECTION3 "shield_ability"
#define MT_CONFIG_SECTION4 "shield"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_SHIELD_BULLET (1 << 0) // requires bullet damage
#define MT_SHIELD_EXPLOSIVE (1 << 1) // requires explosive damage
#define MT_SHIELD_FIRE (1 << 2) // requires fire damage
#define MT_SHIELD_MELEE (1 << 3) // requires melee damage

#define MT_MENU_SHIELD "Shield Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bRewarded;
	bool g_bRewarded2;

	char g_sShieldHealthChars[4];

	float g_flHealth;
	float g_flOpenAreasOnly;
	float g_flShieldChance;
	float g_flShieldHealth;
	float g_flShieldThrowChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iDuration;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iShield;
	int g_iShieldAbility;
	int g_iShieldColor[4];
	int g_iShieldDelay;
	int g_iShieldDisplayHP;
	int g_iShieldDisplayHPType;
	int g_iShieldGlow;
	int g_iShieldMessage;
	int g_iShieldType;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	char g_sShieldHealthChars[4];

	float g_flOpenAreasOnly;
	float g_flShieldChance;
	float g_flShieldHealth;
	float g_flShieldThrowChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iShieldAbility;
	int g_iShieldColor[4];
	int g_iShieldDelay;
	int g_iShieldDisplayHP;
	int g_iShieldDisplayHPType;
	int g_iShieldGlow;
	int g_iShieldMessage;
	int g_iShieldType;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	char g_sShieldHealthChars[4];

	float g_flOpenAreasOnly;
	float g_flShieldChance;
	float g_flShieldHealth;
	float g_flShieldThrowChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iShieldAbility;
	int g_iShieldColor[4];
	int g_iShieldDelay;
	int g_iShieldDisplayHP;
	int g_iShieldDisplayHPType;
	int g_iShieldGlow;
	int g_iShieldMessage;
	int g_iShieldType;
}

esCache g_esCache[MAXPLAYERS + 1];

ConVar g_cvMTTankThrowForce;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_shield", cmdShieldInfo, "View information about the Shield ability.");

	g_cvMTTankThrowForce = FindConVar("z_tank_throw_force");

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
	PrecacheModel(MODEL_SHIELD, true);

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

public Action cmdShieldInfo(int client, int args)
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
		case false: vShieldMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vShieldMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iShieldMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Shield Ability Information");
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

public int iShieldMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iShieldAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ShieldDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vShieldMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pShield = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "ShieldMenu", param1);
			pShield.SetTitle(sMenuTitle);
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
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					case 5: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 6: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					case 7: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_SHIELD, MT_MENU_SHIELD);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_SHIELD, false))
	{
		vShieldMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_SHIELD, false))
	{
		FormatEx(buffer, size, "%T", "ShieldMenu2", client);
	}
}

public void OnGameFrame()
{
	if (MT_IsCorePluginEnabled())
	{
		static char sClassname[32], sHealthBar[51], sSet[2][2], sTankName[33];
		static float flPercentage;
		static int iTarget;
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT))
			{
				iTarget = GetClientAimTarget(iPlayer);
				if (bIsTank(iTarget))
				{
					GetEntityClassname(iTarget, sClassname, sizeof(sClassname));
					if (StrEqual(sClassname, "player") && g_esPlayer[iTarget].g_bActivated && g_esPlayer[iTarget].g_flHealth > 0.0 && g_esCache[iTarget].g_flShieldHealth > 0.0)
					{
						MT_GetTankName(iTarget, sTankName);

						sHealthBar[0] = '\0';
						flPercentage = (g_esPlayer[iTarget].g_flHealth / g_esCache[iTarget].g_flShieldHealth) * 100;

						ReplaceString(g_esCache[iTarget].g_sShieldHealthChars, sizeof(esCache::g_sShieldHealthChars), " ", "");
						ExplodeString(g_esCache[iTarget].g_sShieldHealthChars, ",", sSet, sizeof(sSet), sizeof(sSet[]));

						for (int iCount = 0; iCount < (g_esPlayer[iTarget].g_flHealth / g_esCache[iTarget].g_flShieldHealth) * sizeof(sHealthBar) - 1 && iCount < sizeof(sHealthBar) - 1; iCount++)
						{
							StrCat(sHealthBar, sizeof(sHealthBar), sSet[0]);
						}

						for (int iCount = 0; iCount < sizeof(sHealthBar) - 1; iCount++)
						{
							StrCat(sHealthBar, sizeof(sHealthBar), sSet[1]);
						}

						switch (g_esCache[iTarget].g_iShieldDisplayHPType)
						{
							case 1:
							{
								switch (g_esCache[iTarget].g_iShieldDisplayHP)
								{
									case 1: PrintHintText(iPlayer, "%t", "ShieldOwner", sTankName);
									case 2: PrintHintText(iPlayer, "Shield: %.0f HP", g_esPlayer[iTarget].g_flHealth);
									case 3: PrintHintText(iPlayer, "Shield: %.0f/%.0f HP (%.0f%s)", g_esPlayer[iTarget].g_flHealth, g_esCache[iTarget].g_flShieldHealth, flPercentage, "%%");
									case 4: PrintHintText(iPlayer, "Shield\nHP: |-<%s>-|", sHealthBar);
									case 5: PrintHintText(iPlayer, "%t (%.0f HP)", "ShieldOwner", sTankName, g_esPlayer[iTarget].g_flHealth);
									case 6: PrintHintText(iPlayer, "%t [%.0f/%.0f HP (%.0f%s)]", "ShieldOwner", sTankName, g_esPlayer[iTarget].g_flHealth, g_esCache[iTarget].g_flShieldHealth, flPercentage, "%%");
									case 7: PrintHintText(iPlayer, "%t\nHP: |-<%s>-|", "ShieldOwner", sTankName, sHealthBar);
									case 8: PrintHintText(iPlayer, "Shield: %.0f HP\nHP: |-<%s>-|", g_esPlayer[iTarget].g_flHealth, sHealthBar);
									case 9: PrintHintText(iPlayer, "Shield: %.0f/%.0f HP (%.0f%s)\nHP: |-<%s>-|", g_esPlayer[iTarget].g_flHealth, g_esCache[iTarget].g_flShieldHealth, flPercentage, "%%", sHealthBar);
									case 10: PrintHintText(iPlayer, "%t (%.0f HP)\nHP: |-<%s>-|", "ShieldOwner", sTankName, g_esPlayer[iTarget].g_flHealth, sHealthBar);
									case 11: PrintHintText(iPlayer, "%t [%.0f/%.0f HP (%.0f%s)]\nHP: |-<%s>-|", "ShieldOwner", sTankName, g_esPlayer[iTarget].g_flHealth, g_esCache[iTarget].g_flShieldHealth, flPercentage, "%%", sHealthBar);
								}
							}
							case 2:
							{
								switch (g_esCache[iTarget].g_iShieldDisplayHP)
								{
									case 1: PrintCenterText(iPlayer, "%t", "ShieldOwner", sTankName);
									case 2: PrintCenterText(iPlayer, "Shield: %.0f HP", g_esPlayer[iTarget].g_flHealth);
									case 3: PrintCenterText(iPlayer, "Shield: %.0f/%.0f HP (%.0f%s)", g_esPlayer[iTarget].g_flHealth, g_esCache[iTarget].g_flShieldHealth, flPercentage, "%%");
									case 4: PrintCenterText(iPlayer, "Shield\nHP: |-<%s>-|", sHealthBar);
									case 5: PrintCenterText(iPlayer, "%t (%.0f HP)", "ShieldOwner", sTankName, g_esPlayer[iTarget].g_flHealth);
									case 6: PrintCenterText(iPlayer, "%t [%.0f/%.0f HP (%.0f%s)]", "ShieldOwner", sTankName, g_esPlayer[iTarget].g_flHealth, g_esCache[iTarget].g_flShieldHealth, flPercentage, "%%");
									case 7: PrintCenterText(iPlayer, "%t\nHP: |-<%s>-|", "ShieldOwner", sTankName, sHealthBar);
									case 8: PrintCenterText(iPlayer, "Shield: %.0f HP\nHP: |-<%s>-|", g_esPlayer[iTarget].g_flHealth, sHealthBar);
									case 9: PrintCenterText(iPlayer, "Shield: %.0f/%.0f HP (%.0f%s)\nHP: |-<%s>-|", g_esPlayer[iTarget].g_flHealth, g_esCache[iTarget].g_flShieldHealth, flPercentage, "%%", sHealthBar);
									case 10: PrintCenterText(iPlayer, "%t (%.0f HP)\nHP: |-<%s>-|", "ShieldOwner", sTankName, g_esPlayer[iTarget].g_flHealth, sHealthBar);
									case 11: PrintCenterText(iPlayer, "%t [%.0f/%.0f HP (%.0f%s)]\nHP: |-<%s>-|", "ShieldOwner", sTankName, g_esPlayer[iTarget].g_flHealth, g_esCache[iTarget].g_flShieldHealth, flPercentage, "%%", sHealthBar);
								}
							}
						}
					}
				}
			}
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(client) || (bIsTank(client, MT_CHECK_FAKECLIENT) && g_esCache[client].g_iHumanMode == 1) || (g_esPlayer[client].g_iDuration == -1 && g_esPlayer[client].g_iCooldown2 == -1))
	{
		return Plugin_Continue;
	}

	static int iTime;
	iTime = GetTime();
	if (g_esPlayer[client].g_bActivated && g_esPlayer[client].g_iDuration != -1 && g_esPlayer[client].g_iDuration < iTime)
	{
		if (bIsTank(client, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(client) || bHasAdminAccess(client, g_esAbility[g_esPlayer[client].g_iTankType].g_iAccessFlags, g_esPlayer[client].g_iAccessFlags)) && g_esCache[client].g_iHumanAbility == 1 && g_esCache[client].g_iHumanMode == 0 && (g_esPlayer[client].g_iCooldown == -1 || g_esPlayer[client].g_iCooldown < iTime))
		{
			vReset3(client);
		}

		vShieldAbility(client, false);
	}
	else if (g_esPlayer[client].g_iCooldown2 != -1 && g_esPlayer[client].g_iCooldown2 < iTime)
	{
		vShieldAbility(client, true);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && g_esPlayer[victim].g_bActivated && damage > 0.0)
	{
		static bool bSurvivor;
		bSurvivor = bIsSurvivor(attacker);
		if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || (bSurvivor && (MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))))
		{
			vShieldAbility(victim, false);

			return Plugin_Continue;
		}

		if (bSurvivor)
		{
			static bool bBulletDamage, bExplosiveDamage, bFireDamage, bMeleeDamage;
			bBulletDamage = (damagetype & DMG_BULLET) && (g_esCache[victim].g_iShieldType & MT_SHIELD_BULLET);
			bExplosiveDamage = ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA)) && (g_esCache[victim].g_iShieldType & MT_SHIELD_EXPLOSIVE);
			bFireDamage = (damagetype & DMG_BURN) && (g_esCache[victim].g_iShieldType & MT_SHIELD_FIRE);
			bMeleeDamage = ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB)) && (g_esCache[victim].g_iShieldType & MT_SHIELD_MELEE);
			if (g_esPlayer[attacker].g_bRewarded || bBulletDamage || bExplosiveDamage || bFireDamage || bMeleeDamage)
			{
				g_esPlayer[victim].g_flHealth -= damage;
				if (g_esCache[victim].g_flShieldHealth == 0.0 || g_esPlayer[victim].g_flHealth < 1.0)
				{
					vShieldAbility(victim, false);
				}
			}
		}

		EmitSoundToAll(SOUND_METAL, victim);

		if (damagetype & DMG_BURN)
		{
			ExtinguishEntity(victim);
		}

		if (((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB)) && !(g_esCache[victim].g_iShieldType & MT_SHIELD_MELEE))
		{
			static float flTankPos[3];
			GetClientAbsOrigin(victim, flTankPos);

			switch (bSurvivor && g_esPlayer[attacker].g_bRewarded2)
			{
				case true: vPushNearbyEntities(victim, flTankPos, 300.0, 100.0);
				case false: vPushNearbyEntities(victim, flTankPos);
			}
		}

		return Plugin_Handled;
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
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esCache[tank].g_iShieldAbility == 1 && g_esCache[tank].g_iComboAbility == 1 && !g_esPlayer[tank].g_bActivated)
		{
			static char sSubset[10][32];
			ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
			for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_CONFIG_SECTION, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION2, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION3, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION4, false))
				{
					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						static float flDelay;
						flDelay = MT_GetCombinationSetting(tank, 3, iPos);

						switch (flDelay)
						{
							case 0.0: vShieldAbility(tank, true);
							default: CreateTimer(flDelay, tTimerCombo, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
						}

						break;
					}
				}
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
				g_esAbility[iIndex].g_iHumanDuration = 5;
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iShieldAbility = 0;
				g_esAbility[iIndex].g_iShieldMessage = 0;
				g_esAbility[iIndex].g_flShieldChance = 33.3;
				g_esAbility[iIndex].g_iShieldDelay = 5;
				g_esAbility[iIndex].g_iShieldDisplayHP = 11;
				g_esAbility[iIndex].g_iShieldDisplayHPType = 2;
				g_esAbility[iIndex].g_iShieldGlow = 1;
				g_esAbility[iIndex].g_flShieldHealth = 0.0;
				g_esAbility[iIndex].g_sShieldHealthChars = "],=";
				g_esAbility[iIndex].g_flShieldThrowChance = 100.0;
				g_esAbility[iIndex].g_iShieldType = 2;

				for (int iPos = 0; iPos < sizeof(esAbility::g_iShieldColor); iPos++)
				{
					g_esAbility[iIndex].g_iShieldColor[iPos] = 255;
				}
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
					g_esPlayer[iPlayer].g_iHumanDuration = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iShieldAbility = 0;
					g_esPlayer[iPlayer].g_iShieldMessage = 0;
					g_esPlayer[iPlayer].g_flShieldChance = 0.0;
					g_esPlayer[iPlayer].g_iShieldDelay = 0;
					g_esPlayer[iPlayer].g_iShieldDisplayHP = 0;
					g_esPlayer[iPlayer].g_iShieldDisplayHPType = 0;
					g_esPlayer[iPlayer].g_iShieldGlow = 0;
					g_esPlayer[iPlayer].g_flShieldHealth = 0.0;
					g_esPlayer[iPlayer].g_sShieldHealthChars[0] = '\0';
					g_esPlayer[iPlayer].g_flShieldThrowChance = 0.0;
					g_esPlayer[iPlayer].g_iShieldType = 0;

					for (int iPos = 0; iPos < sizeof(esPlayer::g_iShieldColor); iPos++)
					{
						g_esPlayer[iPlayer].g_iShieldColor[iPos] = -1;
					}
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
		g_esPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPlayer[admin].g_iHumanDuration, value, 1, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iShieldAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iShieldAbility, value, 0, 1);
		g_esPlayer[admin].g_iShieldMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iShieldMessage, value, 0, 1);
		g_esPlayer[admin].g_flShieldChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldChance", "Shield Chance", "Shield_Chance", "chance", g_esPlayer[admin].g_flShieldChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iShieldDelay = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldDelay", "Shield Delay", "Shield_Delay", "delay", g_esPlayer[admin].g_iShieldDelay, value, 1, 999999);
		g_esPlayer[admin].g_iShieldDisplayHP = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldDisplayHealth", "Shield Display Health", "Shield_Display_Health", "displayhp", g_esPlayer[admin].g_iShieldDisplayHP, value, 0, 11);
		g_esPlayer[admin].g_iShieldDisplayHPType = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldDisplayHealthType", "Shield Display Health Type", "Shield_Display_Health_Type", "displaytype", g_esPlayer[admin].g_iShieldDisplayHPType, value, 0, 2);
		g_esPlayer[admin].g_iShieldGlow = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldGlow", "Shield Glow", "Shield_Glow", "glow", g_esPlayer[admin].g_iShieldGlow, value, 0, 1);
		g_esPlayer[admin].g_flShieldHealth = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldHealth", "Shield Health", "Shield_Health", "health", g_esPlayer[admin].g_flShieldHealth, value, 0.0, 999999.0);
		g_esPlayer[admin].g_flShieldThrowChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldThrowChance", "Shield Throw Chance", "Shield_Throw_Chance", "throwchance", g_esPlayer[admin].g_flShieldThrowChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iShieldType = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldType", "Shield Type", "Shield_Type", "type", g_esPlayer[admin].g_iShieldType, value, 0, 15);

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
			else if (StrEqual(key, "ShieldColor", false) || StrEqual(key, "Shield Color", false) || StrEqual(key, "Shield_Color", false) || StrEqual(key, "color", false))
			{
				static char sSet[4][4], sValue[16];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(sSet); iPos++)
				{
					if (sSet[iPos][0] == '\0')
					{
						continue;
					}

					g_esPlayer[admin].g_iShieldColor[iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
				}
			}
			else if (StrEqual(key, "ShieldHealthCharacters", false) || StrEqual(key, "Shield Health Characters", false) || StrEqual(key, "Shield_Characters", false) || StrEqual(key, "hpchars", false))
			{
				strcopy(g_esPlayer[admin].g_sShieldHealthChars, sizeof(esPlayer::g_sShieldHealthChars), value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAbility[type].g_iComboAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_iHumanDuration, value, 1, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iShieldAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iShieldAbility, value, 0, 1);
		g_esAbility[type].g_iShieldMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iShieldMessage, value, 0, 1);
		g_esAbility[type].g_flShieldChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldChance", "Shield Chance", "Shield_Chance", "chance", g_esAbility[type].g_flShieldChance, value, 0.0, 100.0);
		g_esAbility[type].g_iShieldDelay = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldDelay", "Shield Delay", "Shield_Delay", "delay", g_esAbility[type].g_iShieldDelay, value, 1, 999999);
		g_esAbility[type].g_iShieldDisplayHP = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldDisplayHealth", "Shield Display Health", "Shield_Display_Health", "displayhp", g_esAbility[type].g_iShieldDisplayHP, value, 0, 11);
		g_esAbility[type].g_iShieldDisplayHPType = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldDisplayHealthType", "Shield Display Health Type", "Shield_Display_Health_Type", "displaytype", g_esAbility[type].g_iShieldDisplayHPType, value, 0, 2);
		g_esAbility[type].g_iShieldGlow = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldGlow", "Shield Glow", "Shield_Glow", "glow", g_esAbility[type].g_iShieldGlow, value, 0, 1);
		g_esAbility[type].g_flShieldHealth = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldHealth", "Shield Health", "Shield_Health", "health", g_esAbility[type].g_flShieldHealth, value, 0.0, 999999.0);
		g_esAbility[type].g_flShieldThrowChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldThrowChance", "Shield Throw Chance", "Shield_Throw_Chance", "throwchance", g_esAbility[type].g_flShieldThrowChance, value, 0.0, 100.0);
		g_esAbility[type].g_iShieldType = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ShieldType", "Shield Type", "Shield_Type", "type", g_esAbility[type].g_iShieldType, value, 0, 15);

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
			else if (StrEqual(key, "ShieldColor", false) || StrEqual(key, "Shield Color", false) || StrEqual(key, "Shield_Color", false) || StrEqual(key, "color", false))
			{
				static char sSet[4][4], sValue[16];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));
				for (int iPos = 0; iPos < sizeof(sSet); iPos++)
				{
					if (sSet[iPos][0] == '\0')
					{
						continue;
					}

					g_esAbility[type].g_iShieldColor[iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
				}
			}
			else if (StrEqual(key, "ShieldHealthCharacters", false) || StrEqual(key, "Shield Health Characters", false) || StrEqual(key, "Shield_Characters", false) || StrEqual(key, "hpchars", false))
			{
				strcopy(g_esAbility[type].g_sShieldHealthChars, sizeof(esAbility::g_sShieldHealthChars), value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	vGetSettingValue(apply, bHuman, g_esCache[tank].g_sShieldHealthChars, sizeof(esCache::g_sShieldHealthChars), g_esPlayer[tank].g_sShieldHealthChars, g_esAbility[type].g_sShieldHealthChars);
	g_esCache[tank].g_flShieldChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flShieldChance, g_esAbility[type].g_flShieldChance);
	g_esCache[tank].g_flShieldHealth = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flShieldHealth, g_esAbility[type].g_flShieldHealth);
	g_esCache[tank].g_flShieldThrowChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flShieldThrowChance, g_esAbility[type].g_flShieldThrowChance);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanDuration, g_esAbility[type].g_iHumanDuration);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iShieldAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShieldAbility, g_esAbility[type].g_iShieldAbility);
	g_esCache[tank].g_iShieldDelay = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShieldDelay, g_esAbility[type].g_iShieldDelay);
	g_esCache[tank].g_iShieldDisplayHP = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShieldDisplayHP, g_esAbility[type].g_iShieldDisplayHP);
	g_esCache[tank].g_iShieldDisplayHPType = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShieldDisplayHPType, g_esAbility[type].g_iShieldDisplayHPType);
	g_esCache[tank].g_iShieldGlow = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShieldGlow, g_esAbility[type].g_iShieldGlow);
	g_esCache[tank].g_iShieldMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShieldMessage, g_esAbility[type].g_iShieldMessage);
	g_esCache[tank].g_iShieldType = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShieldType, g_esAbility[type].g_iShieldType);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;

	for (int iPos = 0; iPos < sizeof(esCache::g_iShieldColor); iPos++)
	{
		g_esCache[tank].g_iShieldColor[iPos] = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iShieldColor[iPos], g_esAbility[type].g_iShieldColor[iPos], 1);
	}
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveShield(oldTank);
	}
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iTank].g_bActivated)
		{
			vRemoveShield(iTank);
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
			vRemoveShield(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveShield(iTank);
		}
	}
	else if (StrEqual(name, "player_incapacitated") || StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveShield(iTank);
			vReset2(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vReset();
	}
}

public void MT_OnRewardSurvivor(int survivor, int tank, int type, int priority, float duration, bool apply)
{
	if (bIsSurvivor(survivor))
	{
		if (type & MT_REWARD_DAMAGEBOOST)
		{
			g_esPlayer[survivor].g_bRewarded = apply;
		}

		if (type & MT_REWARD_GODMODE)
		{
			g_esPlayer[survivor].g_bRewarded2 = apply;
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if ((MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)) || bIsPlayerIncapacitated(tank))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iShieldAbility == 1 && g_esCache[tank].g_iComboAbility == 0 && !g_esPlayer[tank].g_bActivated)
	{
		vShieldAbility(tank, true);
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

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iShieldAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vShieldAbility(tank, true);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman4", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esPlayer[tank].g_bActivated = true;
								g_esPlayer[tank].g_iAmmoCount++;

								g_esPlayer[tank].g_iShield = CreateEntityByName("prop_dynamic");
								if (bIsValidEntity(g_esPlayer[tank].g_iShield))
								{
									vShield(tank);
								}

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				g_esPlayer[tank].g_bActivated = false;

				vRemoveShield(tank);
				vReset3(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		vRemoveShield(tank);
	}

	vReset2(tank);
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iShieldAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flShieldThrowChance && ((g_esCache[tank].g_iShieldType & MT_SHIELD_EXPLOSIVE) || (g_esCache[tank].g_iShieldType & MT_SHIELD_FIRE)))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		DataPack dpShieldThrow;
		CreateDataTimer(0.1, tTimerShieldThrow, dpShieldThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShieldThrow.WriteCell(EntIndexToEntRef(rock));
		dpShieldThrow.WriteCell(GetClientUserId(tank));
		dpShieldThrow.WriteCell(g_esPlayer[tank].g_iTankType);
	}
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vRemoveShield(int tank)
{
	if (bIsValidEntRef(g_esPlayer[tank].g_iShield))
	{
		g_esPlayer[tank].g_iShield = EntRefToEntIndex(g_esPlayer[tank].g_iShield);
		if (bIsValidEntity(g_esPlayer[tank].g_iShield))
		{
			vSetGlow(g_esPlayer[tank].g_iShield, 0, 0, 0, 0, 0);

			if (bIsValidClient(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_IsGlowEnabled(tank))
			{
				int iGlowColor[4];
				MT_GetTankColors(tank, 2, iGlowColor[0], iGlowColor[1], iGlowColor[2], iGlowColor[3]);
				vSetGlow(tank, iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]), (MT_IsGlowFlashing(tank) ? 1 : 0), MT_GetGlowRange(tank, false), MT_GetGlowRange(tank, true), (MT_GetGlowType(tank) == 1 ? 3 : 2));
			}

			MT_HideEntity(g_esPlayer[tank].g_iShield, false);
			RemoveEntity(g_esPlayer[tank].g_iShield);
		}
	}

	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iShield = INVALID_ENT_REFERENCE;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vShieldAbility(iPlayer, false);
			vReset2(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bRewarded = false;
	g_esPlayer[tank].g_bRewarded2 = false;
	g_esPlayer[tank].g_flHealth = 0.0;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCooldown2 = -1;
	g_esPlayer[tank].g_iDuration = -1;
	g_esPlayer[tank].g_iShield = INVALID_ENT_REFERENCE;
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static void vSetGlow(int entity, int color, int flashing, int min, int max, int type)
{
	if (!g_bSecondGame)
	{
		return;
	}

	SetEntProp(entity, Prop_Send, "m_glowColorOverride", color);
	SetEntProp(entity, Prop_Send, "m_bFlashing", flashing);
	SetEntProp(entity, Prop_Send, "m_nGlowRangeMin", min);
	SetEntProp(entity, Prop_Send, "m_nGlowRange", max);
	SetEntProp(entity, Prop_Send, "m_iGlowType", type);
}

static void vShield(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static float flOrigin[3];
	GetClientAbsOrigin(tank, flOrigin);
	flOrigin[2] -= 120.0;

	SetEntityModel(g_esPlayer[tank].g_iShield, MODEL_SHIELD);

	DispatchKeyValueVector(g_esPlayer[tank].g_iShield, "origin", flOrigin);
	DispatchSpawn(g_esPlayer[tank].g_iShield);
	vSetEntityParent(g_esPlayer[tank].g_iShield, tank, true);

	SetEntityRenderMode(g_esPlayer[tank].g_iShield, RENDER_TRANSTEXTURE);
	SetEntityRenderColor(g_esPlayer[tank].g_iShield, iGetRandomColor(g_esCache[tank].g_iShieldColor[0]), iGetRandomColor(g_esCache[tank].g_iShieldColor[1]), iGetRandomColor(g_esCache[tank].g_iShieldColor[2]), iGetRandomColor(g_esCache[tank].g_iShieldColor[3]));

	if (g_esCache[tank].g_iShieldGlow == 1)
	{
		vSetGlow(tank, 0, 0, 0, 0, 0);
		int iGlowColor[4];
		MT_GetTankColors(tank, 2, iGlowColor[0], iGlowColor[1], iGlowColor[2], iGlowColor[3]);
		vSetGlow(g_esPlayer[tank].g_iShield, iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]), (MT_IsGlowFlashing(tank) ? 1 : 0), MT_GetGlowRange(tank, false), MT_GetGlowRange(tank, true), (MT_GetGlowType(tank) == 1 ? 3 : 2));
	}

	SetEntProp(g_esPlayer[tank].g_iShield, Prop_Send, "m_CollisionGroup", 1);
	MT_HideEntity(g_esPlayer[tank].g_iShield, true);
	g_esPlayer[tank].g_iShield = EntIndexToEntRef(g_esPlayer[tank].g_iShield);
}

static void vShieldAbility(int tank, bool shield)
{
	static int iTime;
	iTime = GetTime();

	switch (shield)
	{
		case true:
		{
			if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || ((!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime))
			{
				return;
			}

			if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
			{
				if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flShieldChance)
				{
					g_esPlayer[tank].g_iShield = CreateEntityByName("prop_dynamic");
					if (bIsValidEntity(g_esPlayer[tank].g_iShield))
					{
						g_esPlayer[tank].g_bActivated = true;
						g_esPlayer[tank].g_iCooldown2 = -1;
						g_esPlayer[tank].g_flHealth = g_esCache[tank].g_flShieldHealth;

						vShield(tank);
						ExtinguishEntity(tank);

						if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
						{
							g_esPlayer[tank].g_iAmmoCount++;
							g_esPlayer[tank].g_iDuration = iTime + g_esPlayer[tank].g_iHumanDuration;

							vExternalView(tank, 1.5);
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
						}

						if (g_esCache[tank].g_iShieldMessage == 1)
						{
							static char sTankName[33];
							MT_GetTankName(tank, sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Shield", sTankName);
							MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Shield", LANG_SERVER, sTankName);
						}
					}
				}
				else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman2");
				}
			}
			else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldAmmo");
			}
		}
		case false:
		{
			g_esPlayer[tank].g_bActivated = false;
			g_esPlayer[tank].g_iDuration = -1;
			g_esPlayer[tank].g_flHealth = 0.0;

			vRemoveShield(tank);

			switch (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				case true:
				{
					vExternalView(tank, 1.5);
					vReset3(tank);
				}
				case false: g_esPlayer[tank].g_iCooldown2 = iTime + g_esCache[tank].g_iShieldDelay;
			}

			if (g_esCache[tank].g_iShieldMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Shield2", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Shield2", LANG_SERVER, sTankName);
			}
		}
	}
}

public Action tTimerCombo(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iShieldAbility == 0 || g_esPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	vShieldAbility(iTank, true);

	return Plugin_Continue;
}

public Action tTimerShieldThrow(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iRock;
	iRock = EntRefToEntIndex(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || g_esCache[iTank].g_iShieldAbility == 0 || !g_esPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	if (!(g_esCache[iTank].g_iShieldType & MT_SHIELD_EXPLOSIVE) && !(g_esCache[iTank].g_iShieldType & MT_SHIELD_FIRE))
	{
		return Plugin_Stop;
	}

	static float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);

	static float flVector;
	flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		static int iTypeCount, iTypes[4], iFlag;
		iTypeCount = 0;
		for (int iBit = 0; iBit < sizeof(iTypes); iBit++)
		{
			iFlag = (1 << iBit);
			if (!(g_esCache[iTank].g_iShieldType & iFlag))
			{
				continue;
			}

			iTypes[iTypeCount] = iFlag;
			iTypeCount++;
		}

		static int iChosen;
		iChosen = iTypes[GetRandomInt(0, iTypeCount - 1)];
		if (iChosen == 2 || iChosen == 4)
		{
			static int iThrowable;
			iThrowable = CreateEntityByName("prop_physics");
			if (bIsValidEntity(iThrowable))
			{
				switch (iChosen)
				{
					case 2: SetEntityModel(iThrowable, MODEL_PROPANETANK);
					case 4: SetEntityModel(iThrowable, MODEL_GASCAN);
				}

				static float flPos[3];
				GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
				RemoveEntity(iRock);

				NormalizeVector(flVelocity, flVelocity);
				ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

				TeleportEntity(iThrowable, flPos, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(iThrowable);
				TeleportEntity(iThrowable, NULL_VECTOR, NULL_VECTOR, flVelocity);
			}
		}

		return Plugin_Stop;
	}

	return Plugin_Continue;
}