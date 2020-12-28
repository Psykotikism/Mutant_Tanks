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
	name = "[MT] Throw Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank throws cars, special infected, Witches, or itself.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Throw Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"

#define MT_CONFIG_SECTION "throwability"
#define MT_CONFIG_SECTION2 "throw ability"
#define MT_CONFIG_SECTION3 "throw_ability"
#define MT_CONFIG_SECTION4 "throw"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_THROW_CAR (1 << 0) // car throw
#define MT_THROW_SPECIAL (1 << 1) // special infected throw
#define MT_THROW_SELF (1 << 2) // self throw
#define MT_THROW_WITCH (1 << 3) // witch throw

#define MT_MENU_THROW "Throw Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bThrown;

	float g_flOpenAreasOnly;
	float g_flThrowCarLifetime;
	float g_flThrowChance;
	float g_flThrowInfectedLifetime;
	float g_flThrowWitchDamage;
	float g_flThrowWitchLifetime;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iThrowAbility;
	int g_iThrowCarOptions;
	int g_iThrowInfectedAmount;
	int g_iThrowInfectedOptions;
	int g_iThrowInfectedRemove;
	int g_iThrowMessage;
	int g_iThrowWitchAmount;
	int g_iThrowWitchRemove;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flOpenAreasOnly;
	float g_flThrowCarLifetime;
	float g_flThrowChance;
	float g_flThrowInfectedLifetime;
	float g_flThrowWitchDamage;
	float g_flThrowWitchLifetime;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iThrowAbility;
	int g_iThrowCarOptions;
	int g_iThrowInfectedAmount;
	int g_iThrowInfectedOptions;
	int g_iThrowInfectedRemove;
	int g_iThrowMessage;
	int g_iThrowWitchAmount;
	int g_iThrowWitchRemove;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flOpenAreasOnly;
	float g_flThrowCarLifetime;
	float g_flThrowChance;
	float g_flThrowInfectedLifetime;
	float g_flThrowWitchDamage;
	float g_flThrowWitchLifetime;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iThrowAbility;
	int g_iThrowCarOptions;
	int g_iThrowInfectedAmount;
	int g_iThrowInfectedOptions;
	int g_iThrowInfectedRemove;
	int g_iThrowMessage;
	int g_iThrowWitchAmount;
	int g_iThrowWitchRemove;
}

esCache g_esCache[MAXPLAYERS + 1];

ConVar g_cvMTTankThrowForce;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_throw", cmdThrowInfo, "View information about the Throw ability.");

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
	PrecacheModel(MODEL_CAR, true);
	PrecacheModel(MODEL_CAR2, true);
	PrecacheModel(MODEL_CAR3, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveThrow(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveThrow(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdThrowInfo(int client, int args)
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
		case false: vThrowMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vThrowMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iThrowMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Throw Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iThrowMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iThrowAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				}
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons3");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ThrowDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vThrowMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pThrow = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "ThrowMenu", param1);
			pThrow.SetTitle(sMenuTitle);
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
	menu.AddItem(MT_MENU_THROW, MT_MENU_THROW);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_THROW, false))
	{
		vThrowMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_THROW, false))
	{
		FormatEx(buffer, size, "%T", "ThrowMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsSurvivor(victim) && !bIsPlayerDisabled(victim) && damage >= 0.5)
	{
		if (bIsInfected(attacker) && g_esPlayer[attacker].g_bThrown)
		{
			static int iTank;
			iTank = g_esPlayer[attacker].g_iOwner;
			if (MT_IsTankSupported(iTank) && MT_IsCustomTankSupported(iTank) && (g_esCache[iTank].g_iThrowAbility & MT_THROW_SPECIAL))
			{
				if ((!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || MT_IsAdminImmune(victim, iTank) || bIsAdminImmune(victim, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
				{
					return Plugin_Handled;
				}
			}
		}
		else if (bIsWitch(attacker))
		{
			static int iTank;
			iTank = HasEntProp(attacker, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(attacker, Prop_Send, "m_hOwnerEntity") : 0;
			if (MT_IsTankSupported(iTank) && MT_IsCustomTankSupported(iTank) && (g_esCache[iTank].g_iThrowAbility & MT_THROW_WITCH))
			{
				if ((!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || MT_IsAdminImmune(victim, iTank) || bIsAdminImmune(victim, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
				{
					return Plugin_Handled;
				}

				static float flDamage;
				flDamage = (g_esAbility[g_esPlayer[iTank].g_iTankType].g_iComboPosition != -1) ? MT_GetCombinationSetting(iTank, 2, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iComboPosition) : g_esCache[iTank].g_flThrowWitchDamage;
				damage = MT_GetScaledDamage(flDamage);

				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
}

public Action StartTouch(int thrown, int other)
{
	TeleportEntity(thrown, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
	SDKUnhook(thrown, SDKHook_StartTouch, StartTouch);
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
		if (type == MT_COMBO_ROCKTHROW && g_esCache[tank].g_iThrowAbility > 0 && g_esCache[tank].g_iComboAbility == 1 && bIsValidEntity(weapon))
		{
			static char sSubset[10][32];
			ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
			for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_CONFIG_SECTION, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION2, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION3, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION4, false))
				{
					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						g_esAbility[g_esPlayer[tank].g_iTankType].g_iComboPosition = iPos;

						vThrow(tank, weapon);

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
				g_esAbility[iIndex].g_flOpenAreasOnly = 500.0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iThrowAbility = 0;
				g_esAbility[iIndex].g_iThrowMessage = 0;
				g_esAbility[iIndex].g_flThrowCarLifetime = 10.0;
				g_esAbility[iIndex].g_iThrowCarOptions = 0;
				g_esAbility[iIndex].g_flThrowChance = 33.3;
				g_esAbility[iIndex].g_iThrowInfectedAmount = 2;
				g_esAbility[iIndex].g_flThrowInfectedLifetime = 0.0;
				g_esAbility[iIndex].g_iThrowInfectedOptions = 0;
				g_esAbility[iIndex].g_iThrowInfectedRemove = 1;
				g_esAbility[iIndex].g_iThrowWitchAmount = 3;
				g_esAbility[iIndex].g_flThrowWitchDamage = 5.0;
				g_esAbility[iIndex].g_flThrowWitchLifetime = 0.0;
				g_esAbility[iIndex].g_iThrowWitchRemove = 1;
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
					g_esPlayer[iPlayer].g_iThrowAbility = 0;
					g_esPlayer[iPlayer].g_iThrowMessage = 0;
					g_esPlayer[iPlayer].g_flThrowCarLifetime = 0.0;
					g_esPlayer[iPlayer].g_iThrowCarOptions = 0;
					g_esPlayer[iPlayer].g_flThrowChance = 0.0;
					g_esPlayer[iPlayer].g_iThrowInfectedAmount = 0;
					g_esPlayer[iPlayer].g_flThrowInfectedLifetime = 0.0;
					g_esPlayer[iPlayer].g_iThrowInfectedOptions = 0;
					g_esPlayer[iPlayer].g_iThrowInfectedRemove = 0;
					g_esPlayer[iPlayer].g_iThrowWitchAmount = 0;
					g_esPlayer[iPlayer].g_flThrowWitchDamage = 0.0;
					g_esPlayer[iPlayer].g_flThrowWitchLifetime = 0.0;
					g_esPlayer[iPlayer].g_iThrowWitchRemove = 0;
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
		g_esPlayer[admin].g_iThrowAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iThrowAbility, value, 0, 15);
		g_esPlayer[admin].g_iThrowMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iThrowMessage, value, 0, 15);
		g_esPlayer[admin].g_flThrowCarLifetime = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowCarLifetime", "Throw Car Lifetime", "Throw_Car_Lifetime", "carlifetime", g_esPlayer[admin].g_flThrowCarLifetime, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iThrowCarOptions = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowCarOptions", "Throw Car Options", "Throw_Car_Options", "caroptions", g_esPlayer[admin].g_iThrowCarOptions, value, 0, 7);
		g_esPlayer[admin].g_flThrowChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowChance", "Throw Chance", "Throw_Chance", "chance", g_esPlayer[admin].g_flThrowChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iThrowInfectedAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowInfectedAmount", "Throw Infected Amount", "Throw_Infected_Amount", "infamount", g_esPlayer[admin].g_iThrowInfectedAmount, value, 1, 32);
		g_esPlayer[admin].g_flThrowInfectedLifetime = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowInfectedLifetime", "Throw Infected Lifetime", "Throw_Infected_Lifetime", "inflifetime", g_esPlayer[admin].g_flThrowInfectedLifetime, value, 0.0, 999999.0);
		g_esPlayer[admin].g_iThrowInfectedOptions = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowInfectedOptions", "Throw Infected Options", "Throw_Infected_Options", "infoptions", g_esPlayer[admin].g_iThrowInfectedOptions, value, 0, 127);
		g_esPlayer[admin].g_iThrowInfectedRemove = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowInfectedRemove", "Throw Infected Remove", "Throw_Infected_Remove", "infremove", g_esPlayer[admin].g_iThrowInfectedRemove, value, 0, 1);
		g_esPlayer[admin].g_iThrowWitchAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowWitchAmount", "Throw Witch Amount", "Throw_Witch_Amount", "witchamount", g_esPlayer[admin].g_iThrowWitchAmount, value, 1, 25);
		g_esPlayer[admin].g_flThrowWitchDamage = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowWitchDamage", "Throw Witch Damage", "Throw_Witch_Damage", "witchdmg", g_esPlayer[admin].g_flThrowWitchDamage, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flThrowWitchLifetime = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowWitchLifetime", "Throw Witch Lifetime", "Throw_Witch_Lifetime", "witchlifetime", g_esPlayer[admin].g_flThrowWitchLifetime, value, 0.0, 999999.0);
		g_esPlayer[admin].g_iThrowWitchRemove = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowWitchRemove", "Throw Witch Remove", "Throw_Witch_Remove", "witchremove", g_esPlayer[admin].g_iThrowWitchRemove, value, 0, 1);

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
		g_esAbility[type].g_iThrowAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iThrowAbility, value, 0, 15);
		g_esAbility[type].g_iThrowMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iThrowMessage, value, 0, 15);
		g_esAbility[type].g_flThrowCarLifetime = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowCarLifetime", "Throw Car Lifetime", "Throw_Car_Lifetime", "carlifetime", g_esAbility[type].g_flThrowCarLifetime, value, 0.1, 999999.0);
		g_esAbility[type].g_iThrowCarOptions = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowCarOptions", "Throw Car Options", "Throw_Car_Options", "caroptions", g_esAbility[type].g_iThrowCarOptions, value, 0, 7);
		g_esAbility[type].g_flThrowChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowChance", "Throw Chance", "Throw_Chance", "chance", g_esAbility[type].g_flThrowChance, value, 0.0, 100.0);
		g_esAbility[type].g_iThrowInfectedAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowInfectedAmount", "Throw Infected Amount", "Throw_Infected_Amount", "infamount", g_esAbility[type].g_iThrowInfectedAmount, value, 1, 32);
		g_esAbility[type].g_flThrowInfectedLifetime = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowInfectedLifetime", "Throw Infected Lifetime", "Throw_Infected_Lifetime", "inflifetime", g_esAbility[type].g_flThrowInfectedLifetime, value, 0.0, 999999.0);
		g_esAbility[type].g_iThrowInfectedOptions = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowInfectedOptions", "Throw Infected Options", "Throw_Infected_Options", "infoptions", g_esAbility[type].g_iThrowInfectedOptions, value, 0, 127);
		g_esAbility[type].g_iThrowInfectedRemove = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowInfectedRemove", "Throw Infected Remove", "Throw_Infected_Remove", "infremove", g_esAbility[type].g_iThrowInfectedRemove, value, 0, 1);
		g_esAbility[type].g_iThrowWitchAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowWitchAmount", "Throw Witch Amount", "Throw_Witch_Amount", "witchamount", g_esAbility[type].g_iThrowWitchAmount, value, 1, 25);
		g_esAbility[type].g_flThrowWitchDamage = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowWitchDamage", "Throw Witch Damage", "Throw_Witch_Damage", "witchdmg", g_esAbility[type].g_flThrowWitchDamage, value, 1.0, 999999.0);
		g_esAbility[type].g_flThrowWitchLifetime = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowWitchLifetime", "Throw Witch Lifetime", "Throw_Witch_Lifetime", "witchlifetime", g_esAbility[type].g_flThrowWitchLifetime, value, 0.0, 999999.0);
		g_esAbility[type].g_iThrowWitchRemove = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ThrowWitchRemove", "Throw Witch Remove", "Throw_Witch_Remove", "witchremove", g_esAbility[type].g_iThrowWitchRemove, value, 0, 1);

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
	g_esCache[tank].g_flThrowCarLifetime = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flThrowCarLifetime, g_esAbility[type].g_flThrowCarLifetime);
	g_esCache[tank].g_flThrowChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flThrowChance, g_esAbility[type].g_flThrowChance);
	g_esCache[tank].g_flThrowInfectedLifetime = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flThrowInfectedLifetime, g_esAbility[type].g_flThrowInfectedLifetime);
	g_esCache[tank].g_flThrowWitchDamage = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flThrowWitchDamage, g_esAbility[type].g_flThrowWitchDamage);
	g_esCache[tank].g_flThrowWitchLifetime = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flThrowWitchLifetime, g_esAbility[type].g_flThrowWitchLifetime);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iThrowAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowAbility, g_esAbility[type].g_iThrowAbility);
	g_esCache[tank].g_iThrowCarOptions = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowCarOptions, g_esAbility[type].g_iThrowCarOptions);
	g_esCache[tank].g_iThrowInfectedAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowInfectedAmount, g_esAbility[type].g_iThrowInfectedAmount);
	g_esCache[tank].g_iThrowInfectedOptions = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowInfectedOptions, g_esAbility[type].g_iThrowInfectedOptions);
	g_esCache[tank].g_iThrowInfectedRemove = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowInfectedRemove, g_esAbility[type].g_iThrowInfectedRemove);
	g_esCache[tank].g_iThrowMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowMessage, g_esAbility[type].g_iThrowMessage);
	g_esCache[tank].g_iThrowWitchAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowWitchAmount, g_esAbility[type].g_iThrowWitchAmount);
	g_esCache[tank].g_iThrowWitchRemove = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowWitchRemove, g_esAbility[type].g_iThrowWitchRemove);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveThrow(oldTank);
	}
}

public void MT_OnPluginEnd()
{
	for (int iSpecial = 1; iSpecial <= MaxClients; iSpecial++)
	{
		if (bIsInfected(iSpecial, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iSpecial].g_bThrown)
		{
			ForcePlayerSuicide(iSpecial);
		}
	}

	int iWitch = -1;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		if (HasEntProp(iWitch, Prop_Send, "m_hOwnerEntity") && GetEntPropEnt(iWitch, Prop_Send, "m_hOwnerEntity") > 0)
		{
			RemoveEntity(iWitch);
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
			vRemoveThrow(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveThrow(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iInfectedId = event.GetInt("userid"), iInfected = GetClientOfUserId(iInfectedId);
		if (MT_IsTankSupported(iInfected, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			for (int iSpecial = 1; iSpecial <= MaxClients; iSpecial++)
			{
				if (g_esPlayer[iSpecial].g_iOwner == iInfected)
				{
					g_esPlayer[iSpecial].g_iOwner = 0;

					if (g_esPlayer[iSpecial].g_bThrown && g_esCache[iInfected].g_iThrowInfectedRemove == 1 && bIsValidClient(iSpecial, MT_CHECK_INGAME|MT_CHECK_ALIVE))
					{
						g_esPlayer[iSpecial].g_bThrown = false;

						ForcePlayerSuicide(iSpecial);
					}
				}
			}

			if (g_esCache[iInfected].g_iThrowWitchRemove == 1)
			{
				int iWitch = -1;
				while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
				{
					if (HasEntProp(iWitch, Prop_Send, "m_hOwnerEntity") && GetEntPropEnt(iWitch, Prop_Send, "m_hOwnerEntity") == iInfected)
					{
						RemoveEntity(iWitch);
					}
				}
			}

			vRemoveThrow(iInfected);
		}
		else if (bIsSpecialInfected(iInfected) && g_esPlayer[iInfected].g_bThrown)
		{
			g_esPlayer[iInfected].g_bThrown = false;
			g_esPlayer[iInfected].g_iOwner = 0;
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vReset();
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
			if (g_esCache[tank].g_iThrowAbility == 0 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;
				if (!g_esPlayer[tank].g_bActivated && !bRecharging)
				{
					switch (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
					{
						case true:
						{
							g_esPlayer[tank].g_bActivated = true;
							g_esPlayer[tank].g_iAmmoCount++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
						}
						case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowAmmo");
					}
				}
				else if (g_esPlayer[tank].g_bActivated)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowHuman2");
				}
				else if (bRecharging)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveThrow(tank);
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iThrowAbility > 0 && g_esCache[tank].g_iComboAbility == 0 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flThrowChance)
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		vThrow(tank, rock);
	}
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vRemoveThrow(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_bThrown = false;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iOwner = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveThrow(iPlayer);
		}
	}
}

static void vThrow(int tank, int rock)
{
	if ((!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && !g_esPlayer[tank].g_bActivated)
	{
		g_esPlayer[tank].g_bActivated = true;
	}

	DataPack dpThrow;
	CreateDataTimer(0.1, tTimerThrow, dpThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpThrow.WriteCell(EntIndexToEntRef(rock));
	dpThrow.WriteCell(GetClientUserId(tank));
	dpThrow.WriteCell(g_esPlayer[tank].g_iTankType);
}

static int iGetThrownInfectedCount(int tank)
{
	static int iInfectedCount;
	iInfectedCount = 0;
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsInfected(iInfected) && g_esPlayer[iInfected].g_bThrown && g_esPlayer[iInfected].g_iOwner == tank)
		{
			iInfectedCount++;
		}
	}

	return iInfectedCount;
}

static int iGetThrownWitchCount(int tank)
{
	static int iWitch, iWitchCount;
	iWitch = -1, iWitchCount = 0;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		if (HasEntProp(iWitch, Prop_Send, "m_hOwnerEntity") && GetEntPropEnt(iWitch, Prop_Send, "m_hOwnerEntity") == tank)
		{
			iWitchCount++;
		}
	}

	return iWitchCount;
}

public Action tTimerKillInfected(Handle timer, int userid)
{
	int iSpecial = GetClientOfUserId(userid);
	if (!bIsInfected(iSpecial) || !g_esPlayer[iSpecial].g_bThrown)
	{
		return Plugin_Stop;
	}

	ForcePlayerSuicide(iSpecial);

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

public Action tTimerThrow(Handle timer, DataPack pack)
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
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || g_esCache[iTank].g_iThrowAbility == 0 || !g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	static float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);

	static float flVector;
	flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		static int iAbilityCount, iAbilities[4], iAbilityFlag;
		iAbilityCount = 0;
		for (int iBit = 0; iBit < sizeof(iAbilities); iBit++)
		{
			iAbilityFlag = (1 << iBit);
			if (!(g_esCache[iTank].g_iThrowAbility & iAbilityFlag))
			{
				continue;
			}

			iAbilities[iAbilityCount] = iAbilityFlag;
			iAbilityCount++;
		}

		if (iAbilityCount > 0)
		{
			switch (iAbilities[GetRandomInt(0, iAbilityCount - 1)])
			{
				case 1:
				{
					static int iCar;
					iCar = CreateEntityByName("prop_physics");
					if (bIsValidEntity(iCar))
					{
						static int iOptionCount, iOptions[3], iFlag;
						iOptionCount = 0;
						for (int iBit = 0; iBit < sizeof(iOptions); iBit++)
						{
							iFlag = (1 << iBit);
							if (!(g_esCache[iTank].g_iThrowCarOptions & iFlag))
							{
								continue;
							}

							iOptions[iOptionCount] = iFlag;
							iOptionCount++;
						}

						switch (iOptions[GetRandomInt(0, iOptionCount - 1)])
						{
							case 1: SetEntityModel(iCar, MODEL_CAR);
							case 2: SetEntityModel(iCar, MODEL_CAR2);
							case 4: SetEntityModel(iCar, MODEL_CAR3);
							default:
							{
								switch (GetRandomInt(1, sizeof(iOptions)))
								{
									case 1: SetEntityModel(iCar, MODEL_CAR);
									case 2: SetEntityModel(iCar, MODEL_CAR2);
									case 3: SetEntityModel(iCar, MODEL_CAR3);
								}
							}
						}

						static int iCarColor[3];
						for (int iPos = 0; iPos < sizeof(iCarColor); iPos++)
						{
							iCarColor[iPos] = GetRandomInt(0, 255);
						}

						SetEntityRenderColor(iCar, iCarColor[0], iCarColor[1], iCarColor[2], 255);

						static float flPos[3];
						GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
						RemoveEntity(iRock);

						NormalizeVector(flVelocity, flVelocity);
						ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

						TeleportEntity(iCar, flPos, NULL_VECTOR, NULL_VECTOR);
						DispatchSpawn(iCar);
						TeleportEntity(iCar, NULL_VECTOR, NULL_VECTOR, flVelocity);

						SDKHook(iCar, SDKHook_StartTouch, StartTouch);

						iCar = EntIndexToEntRef(iCar);
						vDeleteEntity(iCar, g_esCache[iTank].g_flThrowCarLifetime);

						if (g_esCache[iTank].g_iThrowMessage & MT_MESSAGE_MELEE)
						{
							static char sTankName[33];
							MT_GetTankName(iTank, sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Throw", sTankName);
							MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Throw", LANG_SERVER, sTankName);
						}
					}
				}
				case 2:
				{
					if (iGetThrownInfectedCount(iTank) < g_esCache[iTank].g_iThrowInfectedAmount)
					{
						bool[] bExists = new bool[MaxClients + 1];
						for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
						{
							bExists[iPlayer] = false;
							if (bIsInfected(iPlayer, MT_CHECK_INGAME))
							{
								bExists[iPlayer] = true;
							}
						}

						static int iOptionCount, iOptions[7], iFlag;
						iOptionCount = 0;
						for (int iBit = 0; iBit < sizeof(iOptions); iBit++)
						{
							iFlag = (1 << iBit);
							if (!(g_esCache[iTank].g_iThrowInfectedOptions & iFlag))
							{
								continue;
							}

							iOptions[iOptionCount] = iFlag;
							iOptionCount++;
						}

						switch (iOptions[GetRandomInt(0, iOptionCount - 1)])
						{
							case 1: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "smoker");
							case 2: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "boomer");
							case 4: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "hunter");
							case 8: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "spitter" : "boomer");
							case 16: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "jockey" : "hunter");
							case 32: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "charger" : "smoker");
							case 64: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "tank");
							default:
							{
								switch (GetRandomInt(1, sizeof(iOptions)))
								{
									case 1: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "smoker");
									case 2: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "boomer");
									case 3: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "hunter");
									case 4: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "spitter" : "boomer");
									case 5: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "jockey" : "hunter");
									case 6: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "charger" : "smoker");
									case 7: vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "tank");
								}
							}
						}

						static int iSpecial;
						iSpecial = 0;
						for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
						{
							if (bIsInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bExists[iPlayer])
							{
								iSpecial = iPlayer;

								break;
							}
						}

						if (bIsInfected(iSpecial))
						{
							static float flPos[3];
							GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
							RemoveEntity(iRock);

							g_esPlayer[iSpecial].g_bThrown = true;
							g_esPlayer[iSpecial].g_iOwner = iTank;

							if (g_esCache[iTank].g_flThrowInfectedLifetime > 0.0)
							{
								CreateTimer(g_esCache[iTank].g_flThrowInfectedLifetime, tTimerKillInfected, GetClientUserId(iSpecial), TIMER_FLAG_NO_MAPCHANGE);
							}

							NormalizeVector(flVelocity, flVelocity);
							ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);
							TeleportEntity(iSpecial, flPos, NULL_VECTOR, flVelocity);

							if (g_esCache[iTank].g_iThrowMessage & MT_MESSAGE_RANGE)
							{
								static char sTankName[33];
								MT_GetTankName(iTank, sTankName);
								MT_PrintToChatAll("%s %t", MT_TAG2, "Throw2", sTankName);
								MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Throw2", LANG_SERVER, sTankName);
							}
						}
					}
				}
				case 4:
				{
					static float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					RemoveEntity(iRock);

					NormalizeVector(flVelocity, flVelocity);
					ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);
					TeleportEntity(iTank, flPos, NULL_VECTOR, flVelocity);

					if (g_esCache[iTank].g_iThrowMessage & MT_MESSAGE_SPECIAL)
					{
						static char sTankName[33];
						MT_GetTankName(iTank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Throw3", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Throw3", LANG_SERVER, sTankName);
					}
				}
				case 8:
				{
					if (iGetThrownWitchCount(iTank) < g_esCache[iTank].g_iThrowWitchAmount)
					{
						static int iWitch;
						iWitch = CreateEntityByName("witch");
						if (bIsValidEntity(iWitch))
						{
							static float flPos[3];
							GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
							RemoveEntity(iRock);

							NormalizeVector(flVelocity, flVelocity);
							ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

							SetEntPropEnt(iWitch, Prop_Send, "m_hOwnerEntity", iTank);
							TeleportEntity(iWitch, flPos, NULL_VECTOR, NULL_VECTOR);
							DispatchSpawn(iWitch);
							TeleportEntity(iWitch, NULL_VECTOR, NULL_VECTOR, flVelocity);
							ActivateEntity(iWitch);

							SDKHook(iWitch, SDKHook_StartTouch, StartTouch);

							if (g_esCache[iTank].g_flThrowWitchLifetime > 0.0)
							{
								CreateTimer(g_esCache[iTank].g_flThrowWitchLifetime, tTimerKillWitch, EntIndexToEntRef(iWitch), TIMER_FLAG_NO_MAPCHANGE);
							}

							if (g_esCache[iTank].g_iThrowMessage & MT_MESSAGE_SPECIAL2)
							{
								static char sTankName[33];
								MT_GetTankName(iTank, sTankName);
								MT_PrintToChatAll("%s %t", MT_TAG2, "Throw4", sTankName);
								MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Throw4", LANG_SERVER, sTankName);
							}
						}
					}
				}
			}
		}

		g_esPlayer[iTank].g_bActivated = false;

		static int iTime;
		iTime = GetTime();
		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iTime))
		{
			g_esPlayer[iTank].g_iCooldown = (g_esPlayer[iTank].g_iAmmoCount < g_esCache[iTank].g_iHumanAmmo && g_esCache[iTank].g_iHumanAmmo > 0) ? (iTime + g_esCache[iTank].g_iHumanCooldown) : -1;
			if (g_esPlayer[iTank].g_iCooldown != -1 && g_esPlayer[iTank].g_iCooldown > iTime)
			{
				MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ThrowHuman4", g_esPlayer[iTank].g_iCooldown - iTime);
			}
		}

		return Plugin_Stop;
	}

	return Plugin_Continue;
}