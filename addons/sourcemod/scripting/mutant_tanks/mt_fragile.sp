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

//#file "Fragile Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Fragile Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank takes more damage.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Fragile Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_CONFIG_SECTION "fragileability"
#define MT_CONFIG_SECTION2 "fragile ability"
#define MT_CONFIG_SECTION3 "fragile_ability"
#define MT_CONFIG_SECTION4 "fragile"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_FRAGILE "Fragile Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flFragileBulletMultiplier;
	float g_flFragileChance;
	float g_flFragileDamageBoost;
	float g_flFragileExplosiveMultiplier;
	float g_flFragileFireMultiplier;
	float g_flFragileMeleeMultiplier;
	float g_flFragileSpeedBoost;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iDuration;
	int g_iFragileAbility;
	int g_iFragileDuration;
	int g_iFragileMessage;
	int g_iFragileMode;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flFragileBulletMultiplier;
	float g_flFragileChance;
	float g_flFragileDamageBoost;
	float g_flFragileExplosiveMultiplier;
	float g_flFragileFireMultiplier;
	float g_flFragileMeleeMultiplier;
	float g_flFragileSpeedBoost;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iFragileAbility;
	int g_iFragileDuration;
	int g_iFragileMessage;
	int g_iFragileMode;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flFragileBulletMultiplier;
	float g_flFragileChance;
	float g_flFragileDamageBoost;
	float g_flFragileExplosiveMultiplier;
	float g_flFragileFireMultiplier;
	float g_flFragileMeleeMultiplier;
	float g_flFragileSpeedBoost;

	int g_iComboAbility;
	int g_iFragileAbility;
	int g_iFragileDuration;
	int g_iFragileMessage;
	int g_iFragileMode;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_fragile", cmdFragileInfo, "View information about the Fragile ability.");

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

	vRemoveFragile(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveFragile(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFragileInfo(int client, int args)
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
		case false: vFragileMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFragileMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFragileMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fragile Ability Information");
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

public int iFragileMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iFragileAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "FragileDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iFragileDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vFragileMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "FragileMenu", param1);
			panel.SetTitle(sMenuTitle);
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
	menu.AddItem(MT_MENU_FRAGILE, MT_MENU_FRAGILE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_FRAGILE, false))
	{
		vFragileMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_FRAGILE, false))
	{
		FormatEx(buffer, size, "%T", "FragileMenu2", client);
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
		if (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(client) || bHasAdminAccess(client, g_esAbility[g_esPlayer[client].g_iTankType].g_iAccessFlags, g_esPlayer[client].g_iAccessFlags)) && g_esCache[client].g_iHumanAbility == 1 && (g_esPlayer[client].g_iCooldown == -1 || g_esPlayer[client].g_iCooldown < iTime))
		{
			vReset3(client);
		}

		vReset2(client);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage >= 0.5)
	{
		if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && g_esPlayer[victim].g_bActivated && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			switch (g_esCache[victim].g_iFragileMode)
			{
				case 0: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(victim) + g_esCache[victim].g_flFragileSpeedBoost);
				case 1: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", g_esCache[victim].g_flFragileSpeedBoost);
			}

			if (damagetype & DMG_BULLET)
			{
				damage *= g_esCache[victim].g_flFragileBulletMultiplier;
			}
			else if ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA))
			{
				damage *= g_esCache[victim].g_flFragileExplosiveMultiplier;
			}
			else if (damagetype & DMG_BURN)
			{
				damage *= g_esCache[victim].g_flFragileFireMultiplier;
			}
			else if (damagetype & DMG_SLASH || (damagetype & DMG_CLUB))
			{
				damage *= g_esCache[victim].g_flFragileMeleeMultiplier;
			}

			return Plugin_Changed;
		}
		else if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && g_esPlayer[attacker].g_bActivated && bIsSurvivor(victim))
		{
			static char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				switch (g_esCache[attacker].g_iFragileMode)
				{
					case 0:
					{
						damage += g_esCache[attacker].g_flFragileDamageBoost;
						damage = MT_GetScaledDamage(damage);
					}
					case 1: damage = MT_GetScaledDamage(g_esCache[attacker].g_flFragileDamageBoost);
				}

				return Plugin_Changed;
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
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esCache[tank].g_iFragileAbility == 1 && g_esCache[tank].g_iComboAbility == 1 && !g_esPlayer[tank].g_bActivated)
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
							case 0.0: vFragile(tank, iPos);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteCell(iPos);
							}
						}
					}

					break;
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
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iOpenAreasOnly = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iFragileAbility = 0;
				g_esAbility[iIndex].g_iFragileMessage = 0;
				g_esAbility[iIndex].g_flFragileBulletMultiplier = 5.0;
				g_esAbility[iIndex].g_flFragileChance = 33.3;
				g_esAbility[iIndex].g_flFragileDamageBoost = 5.0;
				g_esAbility[iIndex].g_iFragileDuration = 5;
				g_esAbility[iIndex].g_flFragileExplosiveMultiplier = 5.0;
				g_esAbility[iIndex].g_flFragileFireMultiplier = 3.0;
				g_esAbility[iIndex].g_flFragileMeleeMultiplier = 1.5;
				g_esAbility[iIndex].g_iFragileMode = 0;
				g_esAbility[iIndex].g_flFragileSpeedBoost = 1.0;
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
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iFragileAbility = 0;
					g_esPlayer[iPlayer].g_iFragileMessage = 0;
					g_esPlayer[iPlayer].g_flFragileBulletMultiplier = 0.0;
					g_esPlayer[iPlayer].g_flFragileChance = 0.0;
					g_esPlayer[iPlayer].g_flFragileDamageBoost = 0.0;
					g_esPlayer[iPlayer].g_iFragileDuration = 0;
					g_esPlayer[iPlayer].g_flFragileExplosiveMultiplier = 0.0;
					g_esPlayer[iPlayer].g_flFragileFireMultiplier = 0.0;
					g_esPlayer[iPlayer].g_flFragileMeleeMultiplier = 0.0;
					g_esPlayer[iPlayer].g_iFragileMode = 0;
					g_esPlayer[iPlayer].g_flFragileSpeedBoost = 0.0;
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
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iFragileAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iFragileAbility, value, 0, 1);
		g_esPlayer[admin].g_iFragileMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iFragileMessage, value, 0, 1);
		g_esPlayer[admin].g_flFragileBulletMultiplier = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileBulletMultiplier", "Fragile Bullet Multiplier", "Fragile_Bullet_Multiplier", "bullet", g_esPlayer[admin].g_flFragileBulletMultiplier, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flFragileChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileChance", "Fragile Chance", "Fragile_Chance", "chance", g_esPlayer[admin].g_flFragileChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flFragileDamageBoost = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileDamageBoost", "Fragile Damage Boost", "Fragile_Damage_Boost", "dmgboost", g_esPlayer[admin].g_flFragileDamageBoost, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iFragileDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileDuration", "Fragile Duration", "Fragile_Duration", "duration", g_esPlayer[admin].g_iFragileDuration, value, 1, 999999);
		g_esPlayer[admin].g_flFragileExplosiveMultiplier = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileExplosiveMultiplier", "Fragile Explosive Multiplier", "Fragile_Explosive_Multiplier", "explosive", g_esPlayer[admin].g_flFragileExplosiveMultiplier, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flFragileFireMultiplier = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileFireMultiplier", "Fragile Fire Multiplier", "Fragile_Fire_Multiplier", "fire", g_esPlayer[admin].g_flFragileFireMultiplier, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flFragileMeleeMultiplier = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileMeleeMultiplier", "Fragile Melee Multiplier", "Fragile_Melee_Multiplier", "melee", g_esPlayer[admin].g_flFragileMeleeMultiplier, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iFragileMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileMode", "Fragile Mode", "Fragile_Mode", "mode", g_esPlayer[admin].g_iFragileMode, value, 0, 1);
		g_esPlayer[admin].g_flFragileSpeedBoost = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileSpeedBoost", "Fragile Speed Boost", "Fragile_Speed_Boost", "speedboost", g_esPlayer[admin].g_flFragileSpeedBoost, value, 0.1, 3.0);

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
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iFragileAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iFragileAbility, value, 0, 1);
		g_esAbility[type].g_iFragileMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iFragileMessage, value, 0, 1);
		g_esAbility[type].g_flFragileBulletMultiplier = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileBulletMultiplier", "Fragile Bullet Multiplier", "Fragile_Bullet_Multiplier", "bullet", g_esAbility[type].g_flFragileBulletMultiplier, value, 1.0, 999999.0);
		g_esAbility[type].g_flFragileChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileChance", "Fragile Chance", "Fragile_Chance", "chance", g_esAbility[type].g_flFragileChance, value, 0.0, 100.0);
		g_esAbility[type].g_flFragileDamageBoost = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileDamageBoost", "Fragile Damage Boost", "Fragile_Damage_Boost", "dmgboost", g_esAbility[type].g_flFragileDamageBoost, value, 0.1, 999999.0);
		g_esAbility[type].g_iFragileDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileDuration", "Fragile Duration", "Fragile_Duration", "duration", g_esAbility[type].g_iFragileDuration, value, 1, 999999);
		g_esAbility[type].g_flFragileExplosiveMultiplier = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileExplosiveMultiplier", "Fragile Explosive Multiplier", "Fragile_Explosive_Multiplier", "explosive", g_esAbility[type].g_flFragileExplosiveMultiplier, value, 1.0, 999999.0);
		g_esAbility[type].g_flFragileFireMultiplier = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileFireMultiplier", "Fragile Fire Multiplier", "Fragile_Fire_Multiplier", "fire", g_esAbility[type].g_flFragileFireMultiplier, value, 1.0, 999999.0);
		g_esAbility[type].g_flFragileMeleeMultiplier = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileMeleeMultiplier", "Fragile Melee Multiplier", "Fragile_Melee_Multiplier", "melee", g_esAbility[type].g_flFragileMeleeMultiplier, value, 1.0, 999999.0);
		g_esAbility[type].g_iFragileMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileMode", "Fragile Mode", "Fragile_Mode", "mode", g_esAbility[type].g_iFragileMode, value, 0, 1);
		g_esAbility[type].g_flFragileSpeedBoost = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "FragileSpeedBoost", "Fragile Speed Boost", "Fragile_Speed_Boost", "speedboost", g_esAbility[type].g_flFragileSpeedBoost, value, 0.1, 3.0);

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
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_flFragileBulletMultiplier = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFragileBulletMultiplier, g_esAbility[type].g_flFragileBulletMultiplier);
	g_esCache[tank].g_flFragileChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFragileChance, g_esAbility[type].g_flFragileChance);
	g_esCache[tank].g_flFragileDamageBoost = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFragileDamageBoost, g_esAbility[type].g_flFragileDamageBoost);
	g_esCache[tank].g_flFragileExplosiveMultiplier = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFragileExplosiveMultiplier, g_esAbility[type].g_flFragileExplosiveMultiplier);
	g_esCache[tank].g_flFragileFireMultiplier = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFragileFireMultiplier, g_esAbility[type].g_flFragileFireMultiplier);
	g_esCache[tank].g_flFragileMeleeMultiplier = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFragileMeleeMultiplier, g_esAbility[type].g_flFragileMeleeMultiplier);
	g_esCache[tank].g_iFragileAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFragileAbility, g_esAbility[type].g_iFragileAbility);
	g_esCache[tank].g_iFragileDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFragileDuration, g_esAbility[type].g_iFragileDuration);
	g_esCache[tank].g_iFragileMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFragileMessage, g_esAbility[type].g_iFragileMessage);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveFragile(oldTank);
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
			vRemoveFragile(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveFragile(iTank);
		}
	}
	else if (StrEqual(name, "player_incapacitated") || StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveFragile(iTank);
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

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iFragileAbility == 1 && g_esCache[tank].g_iComboAbility == 0 && !g_esPlayer[tank].g_bActivated)
	{
		vFragileAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iFragileAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
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
							vFragileAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman4", g_esPlayer[tank].g_iCooldown - iTime);
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

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileAmmo");
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
				vReset2(tank);
				vReset3(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveFragile(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vFragile(int tank, int pos = -1)
{
	static int iDuration;
	iDuration = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 4, pos)) : g_esCache[tank].g_iFragileDuration;
	g_esPlayer[tank].g_bActivated = true;
	g_esPlayer[tank].g_iDuration = GetTime() + iDuration;

	if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		g_esPlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
	}

	if (g_esCache[tank].g_iFragileMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Fragile", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Fragile", LANG_SERVER, sTankName);
	}
}

static void vFragileAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flFragileChance)
		{
			vFragile(tank);
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileAmmo");
	}
}

static void vRemoveFragile(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iDuration = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveFragile(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iDuration = -1;

	if (g_esCache[tank].g_iFragileMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Fragile2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Fragile2", LANG_SERVER, sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FragileHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iFragileAbility == 0 || g_esPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vFragile(iTank, iPos);

	return Plugin_Continue;
}