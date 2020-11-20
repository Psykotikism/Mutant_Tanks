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

//#file "Electric Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Electric Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank electrocutes survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Electric Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01"
#define PARTICLE_ELECTRICITY2 "electrical_arc_01_parent"
#define PARTICLE_ELECTRICITY3 "st_elmos_fire"
#define PARTICLE_ELECTRICITY4 "storm_lightning_02"
#define PARTICLE_ELECTRICITY5 "storm_lightning_01"
#define PARTICLE_ELECTRICITY6 "impact_ricochet_sparks"
#define PARTICLE_ELECTRICITY7 "railroad_wheel_sparks"

#define MT_CONFIG_SECTION "electricability"
#define MT_CONFIG_SECTION2 "electric ability"
#define MT_CONFIG_SECTION3 "electric_ability"
#define MT_CONFIG_SECTION4 "electric"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_ELECTRIC "Electric Ability"

char g_sZapSounds[8][26] = {"ambient/energy/zap1.wav", "ambient/energy/zap2.wav", "ambient/energy/zap3.wav", "ambient/energy/zap5.wav", "ambient/energy/zap6.wav", "ambient/energy/zap7.wav", "ambient/energy/zap8.wav", "ambient/energy/zap9.wav"};

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flElectricChance;
	float g_flElectricDamage;
	float g_flElectricInterval;
	float g_flElectricRange;
	float g_flElectricRangeChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iElectricAbility;
	int g_iElectricDuration;
	int g_iElectricEffect;
	int g_iElectricHit;
	int g_iElectricHitMode;
	int g_iElectricMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iOwner;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flElectricChance;
	float g_flElectricDamage;
	float g_flElectricInterval;
	float g_flElectricRange;
	float g_flElectricRangeChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iElectricAbility;
	int g_iElectricDuration;
	int g_iElectricEffect;
	int g_iElectricHit;
	int g_iElectricHitMode;
	int g_iElectricMessage;
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
	float g_flElectricChance;
	float g_flElectricDamage;
	float g_flElectricInterval;
	float g_flElectricRange;
	float g_flElectricRangeChance;

	int g_iComboAbility;
	int g_iElectricAbility;
	int g_iElectricDuration;
	int g_iElectricEffect;
	int g_iElectricHit;
	int g_iElectricHitMode;
	int g_iElectricMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_electric", cmdElectricInfo, "View information about the Electric ability.");

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
	iPrecacheParticle(PARTICLE_ELECTRICITY2);
	iPrecacheParticle(PARTICLE_ELECTRICITY3);

	switch (bIsValidGame())
	{
		case true:
		{
			iPrecacheParticle(PARTICLE_ELECTRICITY4);
			iPrecacheParticle(PARTICLE_ELECTRICITY5);
		}
		case false:
		{
			iPrecacheParticle(PARTICLE_ELECTRICITY6);
			iPrecacheParticle(PARTICLE_ELECTRICITY7);
		}
	}

	for (int iPos = 0; iPos < sizeof(g_sZapSounds); iPos++)
	{
		PrecacheSound(g_sZapSounds[iPos], true);
	}

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset3(client);
}

public void OnClientDisconnect_Post(int client)
{
	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdElectricInfo(int client, int args)
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
		case false: vElectricMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vElectricMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iElectricMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Electric Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iElectricMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iElectricAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ElectricDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iElectricDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vElectricMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "ElectricMenu", param1);
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
	menu.AddItem(MT_MENU_ELECTRIC, MT_MENU_ELECTRIC);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ELECTRIC, false))
	{
		vElectricMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_ELECTRIC, false))
	{
		FormatEx(buffer, size, "%T", "ElectricMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iElectricHitMode == 0 || g_esCache[attacker].g_iElectricHitMode == 1) && bIsSurvivor(victim) && g_esCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vElectricHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esCache[attacker].g_flElectricChance, g_esCache[attacker].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iElectricHitMode == 0 || g_esCache[victim].g_iElectricHitMode == 2) && bIsSurvivor(attacker) && g_esCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vElectricHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esCache[victim].g_flElectricChance, g_esCache[victim].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
						if (g_esCache[tank].g_iElectricAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vElectricAbility(tank, random, iPos);
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
								if ((g_esCache[tank].g_iElectricHitMode == 0 || g_esCache[tank].g_iElectricHitMode == 1) && (StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vElectricHit(survivor, tank, random, flChance, g_esCache[tank].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esCache[tank].g_iElectricHitMode == 0 || g_esCache[tank].g_iElectricHitMode == 2) && StrEqual(classname, "weapon_melee"))
								{
									vElectricHit(survivor, tank, random, flChance, g_esCache[tank].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
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
								dpCombo.WriteCell(iPos);
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
				g_esAbility[iIndex].g_iOpenAreasOnly = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iElectricAbility = 0;
				g_esAbility[iIndex].g_iElectricEffect = 0;
				g_esAbility[iIndex].g_iElectricMessage = 0;
				g_esAbility[iIndex].g_flElectricChance = 33.3;
				g_esAbility[iIndex].g_flElectricDamage = 1.0;
				g_esAbility[iIndex].g_iElectricDuration = 5;
				g_esAbility[iIndex].g_iElectricHit = 0;
				g_esAbility[iIndex].g_iElectricHitMode = 0;
				g_esAbility[iIndex].g_flElectricInterval = 1.0;
				g_esAbility[iIndex].g_flElectricRange = 150.0;
				g_esAbility[iIndex].g_flElectricRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iElectricAbility = 0;
					g_esPlayer[iPlayer].g_iElectricEffect = 0;
					g_esPlayer[iPlayer].g_iElectricMessage = 0;
					g_esPlayer[iPlayer].g_flElectricChance = 0.0;
					g_esPlayer[iPlayer].g_flElectricDamage = 0.0;
					g_esPlayer[iPlayer].g_iElectricDuration = 0;
					g_esPlayer[iPlayer].g_iElectricHit = 0;
					g_esPlayer[iPlayer].g_iElectricHitMode = 0;
					g_esPlayer[iPlayer].g_flElectricInterval = 0.0;
					g_esPlayer[iPlayer].g_flElectricRange = 0.0;
					g_esPlayer[iPlayer].g_flElectricRangeChance = 0.0;
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
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iElectricAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iElectricAbility, value, 0, 1);
		g_esPlayer[admin].g_iElectricEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iElectricEffect, value, 0, 7);
		g_esPlayer[admin].g_iElectricMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iElectricMessage, value, 0, 3);
		g_esPlayer[admin].g_flElectricChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricChance", "Electric Chance", "Electric_Chance", "chance", g_esPlayer[admin].g_flElectricChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flElectricDamage = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricDamage", "Electric Damage", "Electric_Damage", "damage", g_esPlayer[admin].g_flElectricDamage, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iElectricDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricDuration", "Electric Duration", "Electric_Duration", "duration", g_esPlayer[admin].g_iElectricDuration, value, 1, 999999);
		g_esPlayer[admin].g_iElectricHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricHit", "Electric Hit", "Electric_Hit", "hit", g_esPlayer[admin].g_iElectricHit, value, 0, 1);
		g_esPlayer[admin].g_iElectricHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricHitMode", "Electric Hit Mode", "Electric_Hit_Mode", "hitmode", g_esPlayer[admin].g_iElectricHitMode, value, 0, 2);
		g_esPlayer[admin].g_flElectricInterval = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricInterval", "Electric Interval", "Electric_Interval", "interval", g_esPlayer[admin].g_flElectricInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flElectricRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricRange", "Electric Range", "Electric_Range", "range", g_esPlayer[admin].g_flElectricRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flElectricRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricRangeChance", "Electric Range Chance", "Electric_Range_Chance", "rangechance", g_esPlayer[admin].g_flElectricRangeChance, value, 0.0, 100.0);

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
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iElectricAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iElectricAbility, value, 0, 1);
		g_esAbility[type].g_iElectricEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iElectricEffect, value, 0, 7);
		g_esAbility[type].g_iElectricMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iElectricMessage, value, 0, 3);
		g_esAbility[type].g_flElectricChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricChance", "Electric Chance", "Electric_Chance", "chance", g_esAbility[type].g_flElectricChance, value, 0.0, 100.0);
		g_esAbility[type].g_flElectricDamage = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricDamage", "Electric Damage", "Electric_Damage", "damage", g_esAbility[type].g_flElectricDamage, value, 1.0, 999999.0);
		g_esAbility[type].g_iElectricDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricDuration", "Electric Duration", "Electric_Duration", "duration", g_esAbility[type].g_iElectricDuration, value, 1, 999999);
		g_esAbility[type].g_iElectricHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricHit", "Electric Hit", "Electric_Hit", "hit", g_esAbility[type].g_iElectricHit, value, 0, 1);
		g_esAbility[type].g_iElectricHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricHitMode", "Electric Hit Mode", "Electric_Hit_Mode", "hitmode", g_esAbility[type].g_iElectricHitMode, value, 0, 2);
		g_esAbility[type].g_flElectricInterval = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricInterval", "Electric Interval", "Electric_Interval", "interval", g_esAbility[type].g_flElectricInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flElectricRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricRange", "Electric Range", "Electric_Range", "range", g_esAbility[type].g_flElectricRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flElectricRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ElectricRangeChance", "Electric Range Chance", "Electric_Range_Chance", "rangechance", g_esAbility[type].g_flElectricRangeChance, value, 0.0, 100.0);

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
	g_esCache[tank].g_flElectricChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flElectricChance, g_esAbility[type].g_flElectricChance);
	g_esCache[tank].g_flElectricDamage = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flElectricDamage, g_esAbility[type].g_flElectricDamage);
	g_esCache[tank].g_iElectricDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iElectricDuration, g_esAbility[type].g_iElectricDuration);
	g_esCache[tank].g_flElectricInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flElectricInterval, g_esAbility[type].g_flElectricInterval);
	g_esCache[tank].g_flElectricRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flElectricRange, g_esAbility[type].g_flElectricRange);
	g_esCache[tank].g_flElectricRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flElectricRangeChance, g_esAbility[type].g_flElectricRangeChance);
	g_esCache[tank].g_iElectricAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iElectricAbility, g_esAbility[type].g_iElectricAbility);
	g_esCache[tank].g_iElectricEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iElectricEffect, g_esAbility[type].g_iElectricEffect);
	g_esCache[tank].g_iElectricHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iElectricHit, g_esAbility[type].g_iElectricHit);
	g_esCache[tank].g_iElectricHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iElectricHitMode, g_esAbility[type].g_iElectricHitMode);
	g_esCache[tank].g_iElectricMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iElectricMessage, g_esAbility[type].g_iElectricMessage);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
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
		vRemoveElectric(oldTank);
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
			vRemoveElectric(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveElectric(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vElectricRange(iTank);
			vRemoveElectric(iTank);
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

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iElectricAbility == 1 && g_esCache[tank].g_iComboAbility == 0)
	{
		vElectricAbility(tank, GetRandomFloat(0.1, 100.0));
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

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iElectricAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vElectricAbility(tank, GetRandomFloat(0.1, 100.0));
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveElectric(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	vElectricRange(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vElectricAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		g_esPlayer[tank].g_bFailed = false;
		g_esPlayer[tank].g_bNoAmmo = false;

		static float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		static float flSurvivorPos[3], flDistance, flRange, flChance;
		flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esCache[tank].g_flElectricRange;
		flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esCache[tank].g_flElectricRangeChance;
		static int iSurvivorCount;
		iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRange)
				{
					vElectricHit(iSurvivor, tank, random, flChance, g_esCache[tank].g_iElectricAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricAmmo");
	}
}

static void vElectricHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (random <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				g_esPlayer[survivor].g_bAffected = true;
				g_esPlayer[survivor].g_iOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iAmmoCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static float flInterval;
				flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : g_esCache[tank].g_flElectricInterval;
				DataPack dpElectric;
				CreateDataTimer(flInterval, tTimerElectric, dpElectric, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpElectric.WriteCell(GetClientUserId(survivor));
				dpElectric.WriteCell(GetClientUserId(tank));
				dpElectric.WriteCell(g_esPlayer[tank].g_iTankType);
				dpElectric.WriteCell(messages);
				dpElectric.WriteCell(enabled);
				dpElectric.WriteCell(pos);
				dpElectric.WriteCell(GetTime());

				static char sEffect[32];
				vGetRandomParticle(sEffect, sizeof(sEffect));
				vAttachParticle(survivor, sEffect, 2.0, 30.0);

				vEffect(survivor, tank, g_esCache[tank].g_iElectricEffect, flags);

				if (g_esCache[tank].g_iElectricMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Electric", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Electric", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricAmmo");
		}
	}
}

static void vElectricRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iElectricAbility == 1)
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		static char sEffect[32];
		vGetRandomParticle(sEffect, sizeof(sEffect));
		vAttachParticle(tank, sEffect, 2.0, 30.0);
	}
}

static void vGetRandomParticle(char[] buffer, int size)
{
	switch (GetRandomInt(1, 7))
	{
		case 1: strcopy(buffer, size, PARTICLE_ELECTRICITY);
		case 2: strcopy(buffer, size, PARTICLE_ELECTRICITY2);
		case 3: strcopy(buffer, size, PARTICLE_ELECTRICITY3);
		case 4, 6: strcopy(buffer, size, (bIsValidGame() ? PARTICLE_ELECTRICITY4 : PARTICLE_ELECTRICITY6));
		case 5, 7: strcopy(buffer, size, (bIsValidGame() ? PARTICLE_ELECTRICITY5 : PARTICLE_ELECTRICITY7));
	}
}

static void vRemoveElectric(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vReset3(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_esPlayer[survivor].g_bAffected = false;
	g_esPlayer[survivor].g_iOwner = 0;

	if (g_esCache[tank].g_iElectricMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Electric2", survivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Electric2", LANG_SERVER, survivor);
	}
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iElectricAbility == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vElectricAbility(iTank, flRandom, iPos);

	return Plugin_Continue;
}

public Action tTimerCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_bAffected)
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iElectricHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof(sClassname));
	if ((g_esCache[iTank].g_iElectricHitMode == 0 || g_esCache[iTank].g_iElectricHitMode == 1) && (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vElectricHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esCache[iTank].g_iElectricHitMode == 0 || g_esCache[iTank].g_iElectricHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
	{
		vElectricHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}

	return Plugin_Continue;
}

public Action tTimerElectric(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iSurvivor;
	iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	static int iTank, iType, iMessage;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || !MT_HasAdminAccess(iTank) || !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static int iElectricEnabled, iPos, iDuration, iTime;
	iElectricEnabled = pack.ReadCell();
	iPos = pack.ReadCell();
	iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 4, iPos)) : g_esCache[iTank].g_iElectricDuration;
	iTime = pack.ReadCell();
	if (iElectricEnabled == 0 || (iTime + iDuration) < GetTime())
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	static float flDamage;
	flDamage = (iPos != -1) ? MT_GetCombinationSetting(iTank, 2, iPos) : g_esCache[iTank].g_flElectricDamage;
	vDamageEntity(iSurvivor, iTank, MT_GetScaledDamage(flDamage), "1024");

	static char sEffect[32];
	vGetRandomParticle(sEffect, sizeof(sEffect));
	vAttachParticle(iSurvivor, sEffect, 2.0, 30.0);

	EmitSoundToAll(g_sZapSounds[GetRandomInt(0, 7)], iSurvivor);

	return Plugin_Continue;
}