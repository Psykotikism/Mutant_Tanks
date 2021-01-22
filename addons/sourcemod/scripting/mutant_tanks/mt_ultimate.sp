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

public Plugin myinfo =
{
	name = "[MT] Ultimate Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank activates ultimate mode when low on health to gain temporary godmode and damage boost.",
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
			strcopy(error, err_max, "\"[MT] Ultimate Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_parent"

#define SOUND_ELECTRICITY "items/suitchargeok1.wav"
#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"
#define SOUND_GROWL1 "player/tank/voice/growl/hulk_growl_1.wav" //Only exists on L4D1
#define SOUND_GROWL2 "player/tank/voice/growl/tank_climb_01.wav" //Only exists on L4D2
#define SOUND_METAL "physics/metal/metal_solid_impact_hard5.wav"
#define SOUND_SMASH1 "player/tank/hit/hulk_punch_1.wav"
#define SOUND_SMASH2 "player/charger/hit/charger_smash_02.wav" //Only exists on L4D2

#define MT_CONFIG_SECTION "ultimateability"
#define MT_CONFIG_SECTION2 "ultimate ability"
#define MT_CONFIG_SECTION3 "ultimate_ability"
#define MT_CONFIG_SECTION4 "ultimate"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_ULTIMATE "Ultimate Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bQualified;

	float g_flDamage;
	float g_flOpenAreasOnly;
	float g_flUltimateChance;
	float g_flUltimateDamageBoost;
	float g_flUltimateDamageRequired;
	float g_flUltimateHealthPortion;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCount;
	int g_iDuration;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iUltimateAbility;
	int g_iUltimateAmount;
	int g_iUltimateDuration;
	int g_iUltimateHealthLimit;
	int g_iUltimateMessage;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flOpenAreasOnly;
	float g_flUltimateChance;
	float g_flUltimateDamageBoost;
	float g_flUltimateDamageRequired;
	float g_flUltimateHealthPortion;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iUltimateAbility;
	int g_iUltimateAmount;
	int g_iUltimateDuration;
	int g_iUltimateHealthLimit;
	int g_iUltimateMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flOpenAreasOnly;
	float g_flUltimateChance;
	float g_flUltimateDamageBoost;
	float g_flUltimateDamageRequired;
	float g_flUltimateHealthPortion;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iUltimateAbility;
	int g_iUltimateAmount;
	int g_iUltimateDuration;
	int g_iUltimateHealthLimit;
	int g_iUltimateMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_god", cmdUltimateInfo, "View information about the Ultimate ability.");

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
	iPrecacheParticle(PARTICLE_ELECTRICITY);

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_EXPLOSION, true);

	if (g_bSecondGame)
	{
		PrecacheSound(SOUND_GROWL2, true);
		PrecacheSound(SOUND_SMASH2, true);
	}
	else
	{
		PrecacheSound(SOUND_GROWL1, true);
		PrecacheSound(SOUND_SMASH1, true);
	}

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveUltimate(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveUltimate(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdUltimateInfo(int client, int args)
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
		case false: vUltimateMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vUltimateMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iUltimateMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Ultimate Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iUltimateMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iUltimateAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "UltimateDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iUltimateDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vUltimateMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pUltimate = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "UltimateMenu", param1);
			pUltimate.SetTitle(sMenuTitle);
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
					case 5: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					case 6: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_ULTIMATE, MT_MENU_ULTIMATE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ULTIMATE, false))
	{
		vUltimateMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_ULTIMATE, false))
	{
		FormatEx(buffer, size, "%T", "UltimateMenu2", client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(client) || !g_esPlayer[client].g_bActivated || g_esPlayer[client].g_iDuration == -1)
	{
		return Plugin_Continue;
	}

	static int iTime;
	iTime = GetTime();
	if (g_esPlayer[client].g_iDuration < iTime)
	{
		if (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(client) || bHasAdminAccess(client, g_esAbility[g_esPlayer[client].g_iTankType].g_iAccessFlags, g_esPlayer[client].g_iAccessFlags)) && g_esCache[client].g_iHumanAbility == 1 && (g_esPlayer[client].g_iCooldown == -1 || g_esPlayer[client].g_iCooldown < iTime))
		{
			g_esPlayer[client].g_iCooldown = (g_esPlayer[client].g_iCount < g_esCache[client].g_iHumanAmmo && g_esCache[client].g_iHumanAmmo > 0) ? (iTime + g_esCache[client].g_iHumanCooldown) : -1;
			if (g_esPlayer[client].g_iCooldown != -1 && g_esPlayer[client].g_iCooldown > iTime)
			{
				MT_PrintToChat(client, "%s %t", MT_TAG3, "UltimateHuman5", g_esPlayer[client].g_iCooldown - iTime);
			}
		}

		g_esPlayer[client].g_bQualified = false;
		g_esPlayer[client].g_bActivated = false;
		g_esPlayer[client].g_iDuration = -1;

		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);

		if (g_esCache[client].g_iUltimateMessage == 1)
		{
			static char sTankName[33];
			MT_GetTankName(client, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Ultimate2", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Ultimate2", LANG_SERVER, sTankName);
		}
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage >= 0.5)
	{
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && bIsSurvivor(victim))
		{
			if (bIsAreaNarrow(attacker, g_esCache[attacker].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[attacker].g_iTankType) || (g_esCache[attacker].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[attacker].g_iRequiresHumans) || (!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (g_esCache[attacker].g_iUltimateAbility == 1)
			{
				if (!g_esPlayer[attacker].g_bQualified)
				{
					g_esPlayer[attacker].g_flDamage += damage;

					if (MT_IsTankSupported(attacker, MT_CHECK_FAKECLIENT))
					{
						MT_PrintToChat(attacker, "%s %t", MT_TAG3, "Ultimate3", g_esPlayer[attacker].g_flDamage, g_esCache[attacker].g_flUltimateDamageRequired);
					}

					if (g_esPlayer[attacker].g_flDamage >= g_esCache[attacker].g_flUltimateDamageRequired)
					{
						g_esPlayer[attacker].g_bQualified = true;

						if (MT_IsTankSupported(attacker, MT_CHECK_FAKECLIENT))
						{
							MT_PrintToChat(attacker, "%s %t", MT_TAG3, "Ultimate4");
						}
					}
				}

				if (g_esPlayer[attacker].g_bActivated && (g_esPlayer[attacker].g_iCooldown == -1 || g_esPlayer[attacker].g_iCooldown < GetTime()))
				{
					damage *= g_esCache[attacker].g_flUltimateDamageBoost;
					damage = MT_GetScaledDamage(damage);

					return Plugin_Changed;
				}
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && bIsSurvivor(attacker) && !MT_IsAdminImmune(attacker, victim) && !bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags) && g_esPlayer[victim].g_bActivated)
		{
			EmitSoundToAll(SOUND_METAL, victim);

			if ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB))
			{
				static float flTankPos[3];
				GetClientAbsOrigin(victim, flTankPos);
				vPushNearbyEntities(victim, flTankPos);
			}

			return Plugin_Handled;
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
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esCache[tank].g_iUltimateAbility == 1 && g_esCache[tank].g_iComboAbility == 1 && !g_esPlayer[tank].g_bActivated)
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
							case 0.0: vUltimate(tank, iPos);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteCell(iPos);
							}
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
				g_esAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iUltimateAbility = 0;
				g_esAbility[iIndex].g_iUltimateMessage = 0;
				g_esAbility[iIndex].g_iUltimateAmount = 1;
				g_esAbility[iIndex].g_flUltimateChance = 33.3;
				g_esAbility[iIndex].g_flUltimateDamageBoost = 1.2;
				g_esAbility[iIndex].g_flUltimateDamageRequired = 200.0;
				g_esAbility[iIndex].g_iUltimateDuration = 5;
				g_esAbility[iIndex].g_iUltimateHealthLimit = 100;
				g_esAbility[iIndex].g_flUltimateHealthPortion = 0.5;
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
					g_esPlayer[iPlayer].g_iUltimateAbility = 0;
					g_esPlayer[iPlayer].g_iUltimateMessage = 0;
					g_esPlayer[iPlayer].g_iUltimateAmount = 0;
					g_esPlayer[iPlayer].g_flUltimateChance = 0.0;
					g_esPlayer[iPlayer].g_flUltimateDamageBoost = 0.0;
					g_esPlayer[iPlayer].g_flUltimateDamageRequired = 0.0;
					g_esPlayer[iPlayer].g_iUltimateDuration = 0;
					g_esPlayer[iPlayer].g_iUltimateHealthLimit = 0;
					g_esPlayer[iPlayer].g_flUltimateHealthPortion = 0.0;
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
		g_esPlayer[admin].g_iUltimateAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iUltimateAbility, value, 0, 1);
		g_esPlayer[admin].g_iUltimateMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iUltimateMessage, value, 0, 1);
		g_esPlayer[admin].g_iUltimateAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateAmount", "Ultimate Amount", "Ultimate_Amount", "amount", g_esPlayer[admin].g_iUltimateAmount, value, 1, 999999);
		g_esPlayer[admin].g_flUltimateChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateChance", "Ultimate Chance", "Ultimate_Chance", "chance", g_esPlayer[admin].g_flUltimateChance, value, 0.1, 100.0);
		g_esPlayer[admin].g_flUltimateDamageBoost = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateDamageBoost", "Ultimate Damage Boost", "Ultimate_Damage_Boost", "dmgboost", g_esPlayer[admin].g_flUltimateDamageBoost, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flUltimateDamageRequired = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateDamageRequired", "Ultimate Damage Required", "Ultimate_Damage_Required", "dmgrequired", g_esPlayer[admin].g_flUltimateDamageRequired, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iUltimateDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateDuration", "Ultimate Duration", "Ultimate_Duration", "duration", g_esPlayer[admin].g_iUltimateDuration, value, 1, 999999);
		g_esPlayer[admin].g_iUltimateHealthLimit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateHealthLimit", "Ultimate Health Limit", "Ultimate_Health_Limit", "healthlimit", g_esPlayer[admin].g_iUltimateHealthLimit, value, 1, MT_MAXHEALTH);
		g_esPlayer[admin].g_flUltimateHealthPortion = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateHealthPortion", "Ultimate Health Portion", "Ultimate_Health_Portion", "healthportion", g_esPlayer[admin].g_flUltimateHealthPortion, value, 0.1, 1.0);

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
		g_esAbility[type].g_iUltimateAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iUltimateAbility, value, 0, 1);
		g_esAbility[type].g_iUltimateMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iUltimateMessage, value, 0, 1);
		g_esAbility[type].g_iUltimateAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateAmount", "Ultimate Amount", "Ultimate_Amount", "amount", g_esAbility[type].g_iUltimateAmount, value, 1, 999999);
		g_esAbility[type].g_flUltimateChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateChance", "Ultimate Chance", "Ultimate_Chance", "chance", g_esAbility[type].g_flUltimateChance, value, 0.1, 100.0);
		g_esAbility[type].g_flUltimateDamageBoost = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateDamageBoost", "Ultimate Damage Boost", "Ultimate_Damage_Boost", "dmgboost", g_esAbility[type].g_flUltimateDamageBoost, value, 0.1, 999999.0);
		g_esAbility[type].g_flUltimateDamageRequired = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateDamageRequired", "Ultimate Damage Required", "Ultimate_Damage_Required", "dmgrequired", g_esAbility[type].g_flUltimateDamageRequired, value, 0.1, 999999.0);
		g_esAbility[type].g_iUltimateDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateDuration", "Ultimate Duration", "Ultimate_Duration", "duration", g_esAbility[type].g_iUltimateDuration, value, 1, 999999);
		g_esAbility[type].g_iUltimateHealthLimit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateHealthLimit", "Ultimate Health Limit", "Ultimate_Health_Limit", "healthlimit", g_esAbility[type].g_iUltimateHealthLimit, value, 1, MT_MAXHEALTH);
		g_esAbility[type].g_flUltimateHealthPortion = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "UltimateHealthPortion", "Ultimate Health Portion", "Ultimate_Health_Portion", "healthportion", g_esAbility[type].g_flUltimateHealthPortion, value, 0.1, 1.0);

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
	g_esCache[tank].g_flUltimateChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flUltimateChance, g_esAbility[type].g_flUltimateChance);
	g_esCache[tank].g_flUltimateDamageBoost = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flUltimateDamageBoost, g_esAbility[type].g_flUltimateDamageBoost);
	g_esCache[tank].g_flUltimateDamageRequired = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flUltimateDamageRequired, g_esAbility[type].g_flUltimateDamageRequired);
	g_esCache[tank].g_flUltimateHealthPortion = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flUltimateHealthPortion, g_esAbility[type].g_flUltimateHealthPortion);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iUltimateAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iUltimateAbility, g_esAbility[type].g_iUltimateAbility);
	g_esCache[tank].g_iUltimateAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iUltimateAmount, g_esAbility[type].g_iUltimateAmount);
	g_esCache[tank].g_iUltimateDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iUltimateDuration, g_esAbility[type].g_iUltimateDuration);
	g_esCache[tank].g_iUltimateHealthLimit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iUltimateHealthLimit, g_esAbility[type].g_iUltimateHealthLimit);
	g_esCache[tank].g_iUltimateMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iUltimateMessage, g_esAbility[type].g_iUltimateMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveUltimate(oldTank);
	}
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iTank].g_bActivated)
		{
			SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);
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
			vRemoveUltimate(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveUltimate(iTank);
		}
	}
	else if (StrEqual(name, "player_incapacitated") || StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveUltimate(iTank);
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

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iUltimateAbility == 1 && g_esCache[tank].g_iComboAbility == 0 && g_esPlayer[tank].g_bQualified && !g_esPlayer[tank].g_bActivated)
	{
		vUltimateAbility(tank);
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
			if (g_esCache[tank].g_iUltimateAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				if (!g_esPlayer[tank].g_bQualified)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman2");

					return;
				}

				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;
				if (!g_esPlayer[tank].g_bActivated && !bRecharging)
				{
					vUltimateAbility(tank);
				}
				else if (g_esPlayer[tank].g_bActivated)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman3");
				}
				else if (bRecharging)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman4", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveUltimate(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_bActivated = g_esPlayer[oldTank].g_bActivated;
	g_esPlayer[newTank].g_bQualified = g_esPlayer[oldTank].g_bQualified;
	g_esPlayer[newTank].g_flDamage = g_esPlayer[oldTank].g_flDamage;
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
	g_esPlayer[newTank].g_iCount = g_esPlayer[oldTank].g_iCount;
	g_esPlayer[newTank].g_iDuration = g_esPlayer[oldTank].g_iDuration;
}

static void vRemoveUltimate(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_bQualified = false;
	g_esPlayer[tank].g_flDamage = 0.0;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iDuration = -1;

	if (MT_IsTankSupported(tank))
	{
		SetEntProp(tank, Prop_Data, "m_takedamage", 2, 1);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveUltimate(iPlayer);
		}
	}
}

static void vUltimate(int tank, int pos = -1)
{
	if (g_esPlayer[tank].g_bQualified && g_esPlayer[tank].g_iCount < g_esCache[tank].g_iUltimateAmount)
	{
		static int iDuration;
		iDuration = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 4, pos)) : g_esCache[tank].g_iUltimateDuration;
		g_esPlayer[tank].g_bActivated = true;
		g_esPlayer[tank].g_iCount++;
		g_esPlayer[tank].g_flDamage = 0.0;
		g_esPlayer[tank].g_iDuration = GetTime() + iDuration;

		ExtinguishEntity(tank);
		vAttachParticle(tank, PARTICLE_ELECTRICITY, 2.0, 30.0);
		EmitSoundToAll(SOUND_ELECTRICITY, tank);
		EmitSoundToAll(SOUND_EXPLOSION, tank);

		if (g_bSecondGame)
		{
			EmitSoundToAll(SOUND_GROWL2, tank);
			EmitSoundToAll(SOUND_SMASH2, tank);
		}
		else
		{
			EmitSoundToAll(SOUND_GROWL1, tank);
			EmitSoundToAll(SOUND_SMASH1, tank);
		}

		static int iMaxHealth, iNewHealth;
		iMaxHealth = MT_TankMaxHealth(tank, 1);
		iNewHealth = RoundToNearest(GetEntProp(tank, Prop_Data, "m_iMaxHealth") * g_esCache[tank].g_flUltimateHealthPortion);
		MT_TankMaxHealth(tank, 3, iMaxHealth + iNewHealth);
		SetEntProp(tank, Prop_Data, "m_iHealth", iNewHealth);
		SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);

		if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			g_esPlayer[tank].g_iAmmoCount++;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
		}

		if (g_esCache[tank].g_iUltimateMessage == 1)
		{
			static char sTankName[33];
			MT_GetTankName(tank, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Ultimate", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Ultimate", LANG_SERVER, sTankName);
		}
	}
}

static void vUltimateAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (GetEntProp(tank, Prop_Data, "m_iHealth") <= g_esCache[tank].g_iUltimateHealthLimit && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flUltimateChance)
	{
		if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iUltimateAmount && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)))
		{
			vUltimate(tank);
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateAmmo");
		}
	}
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iUltimateAbility == 0 || g_esPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vUltimate(iTank, iPos);

	return Plugin_Continue;
}