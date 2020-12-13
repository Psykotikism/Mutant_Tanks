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
	name = "[MT] Witch Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank converts nearby common infected into Witch minions.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Witch Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_CONFIG_SECTION "witchability"
#define MT_CONFIG_SECTION2 "witch ability"
#define MT_CONFIG_SECTION3 "witch_ability"
#define MT_CONFIG_SECTION4 "witch"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_WITCH "Witch Ability"

enum struct esPlayer
{
	float g_flOpenAreasOnly;
	float g_flWitchChance;
	float g_flWitchDamage;
	float g_flWitchLifetime;
	float g_flWitchRange;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iWitchAbility;
	int g_iWitchAmount;
	int g_iWitchMessage;
	int g_iWitchRemove;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flOpenAreasOnly;
	float g_flWitchChance;
	float g_flWitchDamage;
	float g_flWitchLifetime;
	float g_flWitchRange;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iWitchAbility;
	int g_iWitchAmount;
	int g_iWitchMessage;
	int g_iWitchRemove;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flOpenAreasOnly;
	float g_flWitchChance;
	float g_flWitchDamage;
	float g_flWitchLifetime;
	float g_flWitchRange;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iWitchAbility;
	int g_iWitchAmount;
	int g_iWitchMessage;
	int g_iWitchRemove;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_witch", cmdWitchInfo, "View information about the Witch ability.");

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

	vRemoveWitch(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveWitch(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdWitchInfo(int client, int args)
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
		case false: vWitchMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vWitchMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iWitchMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Witch Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iWitchMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iWitchAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons3");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "WitchDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vWitchMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pWitch = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "WitchMenu", param1);
			pWitch.SetTitle(sMenuTitle);
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
	menu.AddItem(MT_MENU_WITCH, MT_MENU_WITCH);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_WITCH, false))
	{
		vWitchMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_WITCH, false))
	{
		FormatEx(buffer, size, "%T", "WitchMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsWitch(attacker) && bIsSurvivor(victim) && !bIsPlayerDisabled(victim) && damage >= 0.5)
	{
		static int iTank;
		iTank = HasEntProp(attacker, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(attacker, Prop_Send, "m_hOwnerEntity") : 0;
		if (MT_IsTankSupported(iTank) && MT_IsCustomTankSupported(iTank) && g_esCache[iTank].g_iWitchAbility == 1)
		{
			if ((!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || MT_IsAdminImmune(victim, iTank) || bIsAdminImmune(victim, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Handled;
			}

			static float flDamage;
			flDamage = (g_esAbility[g_esPlayer[iTank].g_iTankType].g_iComboPosition != -1) ? MT_GetCombinationSetting(iTank, 2, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iComboPosition) : g_esCache[iTank].g_flWitchDamage;
			damage = MT_GetScaledDamage(flDamage);

			return Plugin_Changed;
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
		g_esAbility[g_esPlayer[tank].g_iTankType].g_iComboPosition = -1;

		return;
	}

	g_esAbility[g_esPlayer[tank].g_iTankType].g_iComboPosition = -1;

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION4);
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esCache[tank].g_iWitchAbility == 1 && g_esCache[tank].g_iComboAbility == 1)
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
						g_esAbility[g_esPlayer[tank].g_iTankType].g_iComboPosition = iPos;

						switch (flDelay)
						{
							case 0.0: vWitch(tank, iPos);
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
				g_esAbility[iIndex].g_iComboPosition = -1;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iWitchAbility = 0;
				g_esAbility[iIndex].g_iWitchMessage = 0;
				g_esAbility[iIndex].g_iWitchAmount = 3;
				g_esAbility[iIndex].g_flWitchChance = 33.3;
				g_esAbility[iIndex].g_flWitchDamage = 5.0;
				g_esAbility[iIndex].g_flWitchLifetime = 0.0;
				g_esAbility[iIndex].g_flWitchRange = 500.0;
				g_esAbility[iIndex].g_iWitchRemove = 1;
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
					g_esPlayer[iPlayer].g_iWitchAbility = 0;
					g_esPlayer[iPlayer].g_iWitchMessage = 0;
					g_esPlayer[iPlayer].g_iWitchAmount = 0;
					g_esPlayer[iPlayer].g_flWitchChance = 0.0;
					g_esPlayer[iPlayer].g_flWitchDamage = 0.0;
					g_esPlayer[iPlayer].g_flWitchLifetime = 0.0;
					g_esPlayer[iPlayer].g_flWitchRange = 0.0;
					g_esPlayer[iPlayer].g_iWitchRemove = 0;
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
		g_esPlayer[admin].g_iWitchAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iWitchAbility, value, 0, 1);
		g_esPlayer[admin].g_iWitchMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iWitchMessage, value, 0, 1);
		g_esPlayer[admin].g_iWitchAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchAmount", "Witch Amount", "Witch_Amount", "amount", g_esPlayer[admin].g_iWitchAmount, value, 1, 25);
		g_esPlayer[admin].g_flWitchChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchChance", "Witch Chance", "Witch_Chance", "chance", g_esPlayer[admin].g_flWitchChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flWitchDamage = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchDamage", "Witch Damage", "Witch_Damage", "damage", g_esPlayer[admin].g_flWitchDamage, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flWitchLifetime = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchLifetime", "Witch Lifetime", "Witch_Lifetime", "lifetime", g_esPlayer[admin].g_flWitchLifetime, value, 0.0, 999999.0);
		g_esPlayer[admin].g_flWitchRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchRange", "Witch Range", "Witch_Range", "range", g_esPlayer[admin].g_flWitchRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iWitchRemove = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchRemove", "Witch Remove", "Witch_Remove", "remove", g_esPlayer[admin].g_iWitchRemove, value, 0, 1);

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
		g_esAbility[type].g_iWitchAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iWitchAbility, value, 0, 1);
		g_esAbility[type].g_iWitchMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iWitchMessage, value, 0, 1);
		g_esAbility[type].g_iWitchAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchAmount", "Witch Amount", "Witch_Amount", "amount", g_esAbility[type].g_iWitchAmount, value, 1, 25);
		g_esAbility[type].g_flWitchChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchChance", "Witch Chance", "Witch_Chance", "chance", g_esAbility[type].g_flWitchChance, value, 0.0, 100.0);
		g_esAbility[type].g_flWitchDamage = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchDamage", "Witch Damage", "Witch_Damage", "damage", g_esAbility[type].g_flWitchDamage, value, 1.0, 999999.0);
		g_esAbility[type].g_flWitchLifetime = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchLifetime", "Witch Lifetime", "Witch_Lifetime", "lifetime", g_esAbility[type].g_flWitchLifetime, value, 0.0, 999999.0);
		g_esAbility[type].g_flWitchRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchRange", "Witch Range", "Witch_Range", "range", g_esAbility[type].g_flWitchRange, value, 1.0, 999999.0);
		g_esAbility[type].g_iWitchRemove = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "WitchRemove", "Witch Remove", "Witch_Remove", "remove", g_esAbility[type].g_iWitchRemove, value, 0, 1);

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
	g_esCache[tank].g_flWitchChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWitchChance, g_esAbility[type].g_flWitchChance);
	g_esCache[tank].g_flWitchDamage = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWitchDamage, g_esAbility[type].g_flWitchDamage);
	g_esCache[tank].g_flWitchLifetime = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWitchLifetime, g_esAbility[type].g_flWitchLifetime);
	g_esCache[tank].g_flWitchRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWitchRange, g_esAbility[type].g_flWitchRange);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iWitchAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWitchAbility, g_esAbility[type].g_iWitchAbility);
	g_esCache[tank].g_iWitchAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWitchAmount, g_esAbility[type].g_iWitchAmount);
	g_esCache[tank].g_iWitchMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWitchMessage, g_esAbility[type].g_iWitchMessage);
	g_esCache[tank].g_iWitchRemove = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWitchRemove, g_esAbility[type].g_iWitchRemove);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveWitch(oldTank);
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
			vRemoveWitch(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveWitch(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			switch (g_esCache[iTank].g_iWitchRemove)
			{
				case 0: vWitchRange(iTank);
				case 1:
				{
					int iWitch = -1;
					while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
					{
						if (HasEntProp(iWitch, Prop_Send, "m_hOwnerEntity") && GetEntPropEnt(iWitch, Prop_Send, "m_hOwnerEntity") == iTank)
						{
							RemoveEntity(iWitch);
						}
					}
				}
			}

			vRemoveWitch(iTank);
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

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iWitchAbility == 1 && g_esCache[tank].g_iComboAbility == 0)
	{
		vWitchAbility(tank);
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

		if (button & MT_SPECIAL_KEY)
		{
			if (g_esCache[tank].g_iWitchAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vWitchAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveWitch(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	vWitchRange(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vRemoveWitch(int tank)
{
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveWitch(iPlayer);
		}
	}
}

static void vWitch(int tank, int pos = -1)
{
	static bool bConverted;
	bConverted = false;
	static float flTankPos[3], flInfectedPos[3], flInfectedAngles[3], flRange;
	flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esCache[tank].g_flWitchRange;
	static int iInfected;
	iInfected = -1;
	while ((iInfected = FindEntityByClassname(iInfected, "infected")) != INVALID_ENT_REFERENCE)
	{
		if (iGetWitchCount() < g_esCache[tank].g_iWitchAmount)
		{
			GetClientAbsOrigin(tank, flTankPos);
			GetEntPropVector(iInfected, Prop_Send, "m_vecOrigin", flInfectedPos);
			GetEntPropVector(iInfected, Prop_Send, "m_angRotation", flInfectedAngles);
			if (GetVectorDistance(flInfectedPos, flTankPos) <= flRange)
			{
				bConverted = true;

				RemoveEntity(iInfected);
				vWitch2(tank, flInfectedPos, flInfectedAngles);
			}
		}
	}

	if (bConverted)
	{
		static int iTime;
		iTime = GetTime();
		if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
		{
			g_esPlayer[tank].g_iAmmoCount++;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);

			g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
			if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchHuman4", g_esPlayer[tank].g_iCooldown - iTime);
			}
		}

		if (g_esCache[tank].g_iWitchMessage == 1)
		{
			static char sTankName[33];
			MT_GetTankName(tank, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Witch", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Witch", LANG_SERVER, sTankName);
		}
	}
}

static void vWitch2(int tank, float pos[3], float angles[3])
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static int iWitch;
	iWitch = CreateEntityByName("witch");
	if (bIsValidEntity(iWitch))
	{
		SetEntPropEnt(iWitch, Prop_Send, "m_hOwnerEntity", tank);
		TeleportEntity(iWitch, pos, angles, NULL_VECTOR);
		DispatchSpawn(iWitch);
		ActivateEntity(iWitch);

		if (g_esCache[tank].g_flWitchLifetime > 0.0)
		{
			CreateTimer(g_esCache[tank].g_flWitchLifetime, tTimerKillWitch, EntIndexToEntRef(iWitch), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

static void vWitchAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flWitchChance)
		{
			vWitch(tank);
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchAmmo");
	}
}

static void vWitchRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iWitchAbility == 1)
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		static float flTankPos[3], flTankAngles[3];
		GetClientAbsOrigin(tank, flTankPos);
		GetClientAbsAngles(tank, flTankAngles);
		vWitch2(tank, flTankPos, flTankAngles);
	}
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iWitchAbility == 0)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vWitch(iTank, iPos);

	return Plugin_Continue;
}

public Action tTimerKillWitch(Handle timer, int ref)
{
	int iWitch = EntRefToEntIndex(ref);
	if (iWitch == INVALID_ENT_REFERENCE || !bIsValidEntity(iWitch) || !bIsWitch(iWitch))
	{
		return Plugin_Stop;
	}

	RemoveEntity(iWitch);

	return Plugin_Continue;
}