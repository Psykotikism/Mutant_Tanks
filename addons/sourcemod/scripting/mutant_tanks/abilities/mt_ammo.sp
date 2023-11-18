/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2023  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_AMMO_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_AMMO_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Ammo Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank takes away survivors' ammunition.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Ammo Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}
#else
	#if MT_AMMO_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_AMMO_SECTION "ammoability"
#define MT_AMMO_SECTION2 "ammo ability"
#define MT_AMMO_SECTION3 "ammo_ability"
#define MT_AMMO_SECTION4 "ammo"

#define MT_AMMO_MAGAZINE (1 << 0) // magazine
#define MT_AMMO_RESERVED (1 << 1) // reserved ammo

#define MT_MENU_AMMO "Ammo Ability"

enum struct esAmmoPlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flAmmoChance;
	float g_flAmmoRange;
	float g_flAmmoRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoAbility;
	int g_iAmmoAmount;
	int g_iAmmoCooldown;
	int g_iAmmoCount;
	int g_iAmmoEffect;
	int g_iAmmoHit;
	int g_iAmmoHitMode;
	int g_iAmmoMessage;
	int g_iAmmoRangeCooldown;
	int g_iAmmoSight;
	int g_iAmmoType;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esAmmoPlayer g_esAmmoPlayer[MAXPLAYERS + 1];

enum struct esAmmoTeammate
{
	float g_flAmmoChance;
	float g_flAmmoRange;
	float g_flAmmoRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iAmmoAbility;
	int g_iAmmoAmount;
	int g_iAmmoCooldown;
	int g_iAmmoEffect;
	int g_iAmmoHit;
	int g_iAmmoHitMode;
	int g_iAmmoMessage;
	int g_iAmmoRangeCooldown;
	int g_iAmmoSight;
	int g_iAmmoType;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esAmmoTeammate g_esAmmoTeammate[MAXPLAYERS + 1];

enum struct esAmmoAbility
{
	float g_flAmmoChance;
	float g_flAmmoRange;
	float g_flAmmoRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoAbility;
	int g_iAmmoAmount;
	int g_iAmmoCooldown;
	int g_iAmmoEffect;
	int g_iAmmoHit;
	int g_iAmmoHitMode;
	int g_iAmmoMessage;
	int g_iAmmoRangeCooldown;
	int g_iAmmoSight;
	int g_iAmmoType;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAmmoAbility g_esAmmoAbility[MT_MAXTYPES + 1];

enum struct esAmmoSpecial
{
	float g_flAmmoChance;
	float g_flAmmoRange;
	float g_flAmmoRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iAmmoAbility;
	int g_iAmmoAmount;
	int g_iAmmoCooldown;
	int g_iAmmoEffect;
	int g_iAmmoHit;
	int g_iAmmoHitMode;
	int g_iAmmoMessage;
	int g_iAmmoRangeCooldown;
	int g_iAmmoSight;
	int g_iAmmoType;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esAmmoSpecial g_esAmmoSpecial[MT_MAXTYPES + 1];

enum struct esAmmoCache
{
	float g_flAmmoChance;
	float g_flAmmoRange;
	float g_flAmmoRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iAmmoAbility;
	int g_iAmmoAmount;
	int g_iAmmoCooldown;
	int g_iAmmoEffect;
	int g_iAmmoHit;
	int g_iAmmoHitMode;
	int g_iAmmoMessage;
	int g_iAmmoRangeCooldown;
	int g_iAmmoSight;
	int g_iAmmoType;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esAmmoCache g_esAmmoCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_ammo", cmdAmmoInfo, "View information about the Ammo ability.");

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
#endif

#if defined MT_ABILITIES_MAIN
void vAmmoMapStart()
#else
public void OnMapStart()
#endif
{
	vAmmoReset();
}

#if defined MT_ABILITIES_MAIN
void vAmmoClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnAmmoTakeDamage);
	vRemoveAmmo(client);
}

#if defined MT_ABILITIES_MAIN
void vAmmoClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveAmmo(client);
}

#if defined MT_ABILITIES_MAIN
void vAmmoMapEnd()
#else
public void OnMapEnd()
#endif
{
	vAmmoReset();
}

#if !defined MT_ABILITIES_MAIN
Action cmdAmmoInfo(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG5, "PluginDisabled");

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
		case false: vAmmoMenu(client, MT_AMMO_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vAmmoMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_AMMO_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iAmmoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Ammo Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iAmmoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esAmmoCache[param1].g_iAmmoAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esAmmoCache[param1].g_iHumanAmmo - g_esAmmoPlayer[param1].g_iAmmoCount), g_esAmmoCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esAmmoCache[param1].g_iHumanAbility == 1) ? g_esAmmoCache[param1].g_iHumanCooldown : g_esAmmoCache[param1].g_iAmmoCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AmmoDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esAmmoCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esAmmoCache[param1].g_iHumanAbility == 1) ? g_esAmmoCache[param1].g_iHumanRangeCooldown : g_esAmmoCache[param1].g_iAmmoRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vAmmoMenu(param1, MT_AMMO_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pAmmo = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "AmmoMenu", param1);
			pAmmo.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Ammunition", param1);
					case 2: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Buttons", param1);
					case 3: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Cooldown", param1);
					case 4: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Details", param1);
					case 5: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
					case 6: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "RangeCooldown", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN
void vAmmoDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_AMMO, MT_MENU_AMMO);
}

#if defined MT_ABILITIES_MAIN
void vAmmoMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_AMMO, false))
	{
		vAmmoMenu(client, MT_AMMO_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vAmmoMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_AMMO, false))
	{
		FormatEx(buffer, size, "%T", "AmmoMenu2", client);
	}
}

Action OnAmmoTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esAmmoCache[attacker].g_iAmmoHitMode == 0 || g_esAmmoCache[attacker].g_iAmmoHitMode == 1) && bIsSurvivor(victim) && g_esAmmoCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAmmoAbility[g_esAmmoPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esAmmoPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esAmmoPlayer[attacker].g_iTankType, g_esAmmoAbility[g_esAmmoPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esAmmoPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAmmoHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esAmmoCache[attacker].g_flAmmoChance, g_esAmmoCache[attacker].g_iAmmoHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esAmmoCache[victim].g_iAmmoHitMode == 0 || g_esAmmoCache[victim].g_iAmmoHitMode == 2) && bIsSurvivor(attacker) && g_esAmmoCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAmmoAbility[g_esAmmoPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esAmmoPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esAmmoPlayer[victim].g_iTankType, g_esAmmoAbility[g_esAmmoPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esAmmoPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vAmmoHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esAmmoCache[victim].g_flAmmoChance, g_esAmmoCache[victim].g_iAmmoHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vAmmoPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_AMMO);
}

#if defined MT_ABILITIES_MAIN
void vAmmoAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_AMMO_SECTION);
	list2.PushString(MT_AMMO_SECTION2);
	list3.PushString(MT_AMMO_SECTION3);
	list4.PushString(MT_AMMO_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vAmmoCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esAmmoCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_AMMO_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_AMMO_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_AMMO_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_AMMO_SECTION4);
	if (g_esAmmoCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_AMMO_SECTION, false) || StrEqual(sSubset[iPos], MT_AMMO_SECTION2, false) || StrEqual(sSubset[iPos], MT_AMMO_SECTION3, false) || StrEqual(sSubset[iPos], MT_AMMO_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esAmmoCache[tank].g_iAmmoAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vAmmoAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerAmmoCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}
					}
					case MT_COMBO_MELEEHIT:
					{
						flChance = MT_GetCombinationSetting(tank, 1, iPos);

						switch (flDelay)
						{
							case 0.0:
							{
								if ((g_esAmmoCache[tank].g_iAmmoHitMode == 0 || g_esAmmoCache[tank].g_iAmmoHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vAmmoHit(survivor, tank, random, flChance, g_esAmmoCache[tank].g_iAmmoHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esAmmoCache[tank].g_iAmmoHitMode == 0 || g_esAmmoCache[tank].g_iAmmoHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vAmmoHit(survivor, tank, random, flChance, g_esAmmoCache[tank].g_iAmmoHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerAmmoCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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

#if defined MT_ABILITIES_MAIN
void vAmmoConfigsLoad(int mode)
#else
public void MT_OnConfigsLoad(int mode)
#endif
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esAmmoAbility[iIndex].g_iAccessFlags = 0;
				g_esAmmoAbility[iIndex].g_iImmunityFlags = 0;
				g_esAmmoAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esAmmoAbility[iIndex].g_iComboAbility = 0;
				g_esAmmoAbility[iIndex].g_iHumanAbility = 0;
				g_esAmmoAbility[iIndex].g_iHumanAmmo = 5;
				g_esAmmoAbility[iIndex].g_iHumanCooldown = 0;
				g_esAmmoAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esAmmoAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAmmoAbility[iIndex].g_iRequiresHumans = 1;
				g_esAmmoAbility[iIndex].g_iAmmoAbility = 0;
				g_esAmmoAbility[iIndex].g_iAmmoEffect = 0;
				g_esAmmoAbility[iIndex].g_iAmmoMessage = 0;
				g_esAmmoAbility[iIndex].g_iAmmoAmount = 0;
				g_esAmmoAbility[iIndex].g_flAmmoChance = 33.3;
				g_esAmmoAbility[iIndex].g_iAmmoCooldown = 0;
				g_esAmmoAbility[iIndex].g_iAmmoHit = 0;
				g_esAmmoAbility[iIndex].g_iAmmoHitMode = 0;
				g_esAmmoAbility[iIndex].g_flAmmoRange = 150.0;
				g_esAmmoAbility[iIndex].g_flAmmoRangeChance = 15.0;
				g_esAmmoAbility[iIndex].g_iAmmoRangeCooldown = 0;
				g_esAmmoAbility[iIndex].g_iAmmoSight = 0;
				g_esAmmoAbility[iIndex].g_iAmmoType = 3;

				g_esAmmoSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esAmmoSpecial[iIndex].g_iComboAbility = -1;
				g_esAmmoSpecial[iIndex].g_iHumanAbility = -1;
				g_esAmmoSpecial[iIndex].g_iHumanAmmo = -1;
				g_esAmmoSpecial[iIndex].g_iHumanCooldown = -1;
				g_esAmmoSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esAmmoSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esAmmoSpecial[iIndex].g_iRequiresHumans = -1;
				g_esAmmoSpecial[iIndex].g_iAmmoAbility = -1;
				g_esAmmoSpecial[iIndex].g_iAmmoEffect = -1;
				g_esAmmoSpecial[iIndex].g_iAmmoMessage = -1;
				g_esAmmoSpecial[iIndex].g_iAmmoAmount = -1;
				g_esAmmoSpecial[iIndex].g_flAmmoChance = -1.0;
				g_esAmmoSpecial[iIndex].g_iAmmoCooldown = -1;
				g_esAmmoSpecial[iIndex].g_iAmmoHit = -1;
				g_esAmmoSpecial[iIndex].g_iAmmoHitMode = -1;
				g_esAmmoSpecial[iIndex].g_flAmmoRange = -1.0;
				g_esAmmoSpecial[iIndex].g_flAmmoRangeChance = -1.0;
				g_esAmmoSpecial[iIndex].g_iAmmoRangeCooldown = -1;
				g_esAmmoSpecial[iIndex].g_iAmmoSight = -1;
				g_esAmmoSpecial[iIndex].g_iAmmoType = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esAmmoPlayer[iPlayer].g_iAccessFlags = -1;
				g_esAmmoPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esAmmoPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esAmmoPlayer[iPlayer].g_iComboAbility = -1;
				g_esAmmoPlayer[iPlayer].g_iHumanAbility = -1;
				g_esAmmoPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esAmmoPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esAmmoPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esAmmoPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esAmmoPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esAmmoPlayer[iPlayer].g_iAmmoAbility = -1;
				g_esAmmoPlayer[iPlayer].g_iAmmoEffect = -1;
				g_esAmmoPlayer[iPlayer].g_iAmmoMessage = -1;
				g_esAmmoPlayer[iPlayer].g_iAmmoAmount = -1;
				g_esAmmoPlayer[iPlayer].g_flAmmoChance = -1.0;
				g_esAmmoPlayer[iPlayer].g_iAmmoCooldown = -1;
				g_esAmmoPlayer[iPlayer].g_iAmmoHit = -1;
				g_esAmmoPlayer[iPlayer].g_iAmmoHitMode = -1;
				g_esAmmoPlayer[iPlayer].g_flAmmoRange = -1.0;
				g_esAmmoPlayer[iPlayer].g_flAmmoRangeChance = -1.0;
				g_esAmmoPlayer[iPlayer].g_iAmmoRangeCooldown = -1;
				g_esAmmoPlayer[iPlayer].g_iAmmoSight = -1;
				g_esAmmoPlayer[iPlayer].g_iAmmoType = -1;

				g_esAmmoTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esAmmoTeammate[iPlayer].g_iComboAbility = -1;
				g_esAmmoTeammate[iPlayer].g_iHumanAbility = -1;
				g_esAmmoTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esAmmoTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esAmmoTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esAmmoTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esAmmoTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esAmmoTeammate[iPlayer].g_iAmmoAbility = -1;
				g_esAmmoTeammate[iPlayer].g_iAmmoEffect = -1;
				g_esAmmoTeammate[iPlayer].g_iAmmoMessage = -1;
				g_esAmmoTeammate[iPlayer].g_iAmmoAmount = -1;
				g_esAmmoTeammate[iPlayer].g_flAmmoChance = -1.0;
				g_esAmmoTeammate[iPlayer].g_iAmmoCooldown = -1;
				g_esAmmoTeammate[iPlayer].g_iAmmoHit = -1;
				g_esAmmoTeammate[iPlayer].g_iAmmoHitMode = -1;
				g_esAmmoTeammate[iPlayer].g_flAmmoRange = -1.0;
				g_esAmmoTeammate[iPlayer].g_flAmmoRangeChance = -1.0;
				g_esAmmoTeammate[iPlayer].g_iAmmoRangeCooldown = -1;
				g_esAmmoTeammate[iPlayer].g_iAmmoSight = -1;
				g_esAmmoTeammate[iPlayer].g_iAmmoType = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vAmmoConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esAmmoTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esAmmoTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esAmmoTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAmmoTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esAmmoTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAmmoTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esAmmoTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAmmoTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esAmmoTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAmmoTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esAmmoTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esAmmoTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esAmmoTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAmmoTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esAmmoTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAmmoTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esAmmoTeammate[admin].g_iAmmoAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAmmoTeammate[admin].g_iAmmoAbility, value, -1, 1);
			g_esAmmoTeammate[admin].g_iAmmoEffect = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAmmoTeammate[admin].g_iAmmoEffect, value, -1, 7);
			g_esAmmoTeammate[admin].g_iAmmoMessage = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAmmoTeammate[admin].g_iAmmoMessage, value, -1, 3);
			g_esAmmoTeammate[admin].g_iAmmoSight = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esAmmoTeammate[admin].g_iAmmoSight, value, -1, 5);
			g_esAmmoTeammate[admin].g_iAmmoAmount = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoCount", "Ammo Count", "Ammo_Count", "count", g_esAmmoTeammate[admin].g_iAmmoAmount, value, -1, 100);
			g_esAmmoTeammate[admin].g_flAmmoChance = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoChance", "Ammo Chance", "Ammo_Chance", "chance", g_esAmmoTeammate[admin].g_flAmmoChance, value, -1.0, 100.0);
			g_esAmmoTeammate[admin].g_iAmmoCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoCooldown", "Ammo Cooldown", "Ammo_Cooldown", "cooldown", g_esAmmoTeammate[admin].g_iAmmoCooldown, value, -1, 99999);
			g_esAmmoTeammate[admin].g_iAmmoHit = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoHit", "Ammo Hit", "Ammo_Hit", "hit", g_esAmmoTeammate[admin].g_iAmmoHit, value, -1, 1);
			g_esAmmoTeammate[admin].g_iAmmoHitMode = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoHitMode", "Ammo Hit Mode", "Ammo_Hit_Mode", "hitmode", g_esAmmoTeammate[admin].g_iAmmoHitMode, value, -1, 2);
			g_esAmmoTeammate[admin].g_flAmmoRange = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRange", "Ammo Range", "Ammo_Range", "range", g_esAmmoTeammate[admin].g_flAmmoRange, value, -1.0, 99999.0);
			g_esAmmoTeammate[admin].g_flAmmoRangeChance = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRangeChance", "Ammo Range Chance", "Ammo_Range_Chance", "rangechance", g_esAmmoTeammate[admin].g_flAmmoRangeChance, value, -1.0, 100.0);
			g_esAmmoTeammate[admin].g_iAmmoRangeCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRangeCooldown", "Ammo Range Cooldown", "Ammo_Range_Cooldown", "rangecooldown", g_esAmmoTeammate[admin].g_iAmmoRangeCooldown, value, -1, 99999);
			g_esAmmoTeammate[admin].g_iAmmoType = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoType", "Ammo Type", "Ammo_Type", "type", g_esAmmoTeammate[admin].g_iAmmoType, value, -1, 3);
		}
		else
		{
			g_esAmmoPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esAmmoPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esAmmoPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAmmoPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esAmmoPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAmmoPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esAmmoPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAmmoPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esAmmoPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAmmoPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esAmmoPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esAmmoPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esAmmoPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAmmoPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esAmmoPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAmmoPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esAmmoPlayer[admin].g_iAmmoAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAmmoPlayer[admin].g_iAmmoAbility, value, -1, 1);
			g_esAmmoPlayer[admin].g_iAmmoEffect = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAmmoPlayer[admin].g_iAmmoEffect, value, -1, 7);
			g_esAmmoPlayer[admin].g_iAmmoMessage = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAmmoPlayer[admin].g_iAmmoMessage, value, -1, 3);
			g_esAmmoPlayer[admin].g_iAmmoSight = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esAmmoPlayer[admin].g_iAmmoSight, value, -1, 5);
			g_esAmmoPlayer[admin].g_iAmmoAmount = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoCount", "Ammo Count", "Ammo_Count", "count", g_esAmmoPlayer[admin].g_iAmmoAmount, value, -1, 100);
			g_esAmmoPlayer[admin].g_flAmmoChance = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoChance", "Ammo Chance", "Ammo_Chance", "chance", g_esAmmoPlayer[admin].g_flAmmoChance, value, -1.0, 100.0);
			g_esAmmoPlayer[admin].g_iAmmoCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoCooldown", "Ammo Cooldown", "Ammo_Cooldown", "cooldown", g_esAmmoPlayer[admin].g_iAmmoCooldown, value, -1, 99999);
			g_esAmmoPlayer[admin].g_iAmmoHit = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoHit", "Ammo Hit", "Ammo_Hit", "hit", g_esAmmoPlayer[admin].g_iAmmoHit, value, -1, 1);
			g_esAmmoPlayer[admin].g_iAmmoHitMode = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoHitMode", "Ammo Hit Mode", "Ammo_Hit_Mode", "hitmode", g_esAmmoPlayer[admin].g_iAmmoHitMode, value, -1, 2);
			g_esAmmoPlayer[admin].g_flAmmoRange = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRange", "Ammo Range", "Ammo_Range", "range", g_esAmmoPlayer[admin].g_flAmmoRange, value, -1.0, 99999.0);
			g_esAmmoPlayer[admin].g_flAmmoRangeChance = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRangeChance", "Ammo Range Chance", "Ammo_Range_Chance", "rangechance", g_esAmmoPlayer[admin].g_flAmmoRangeChance, value, -1.0, 100.0);
			g_esAmmoPlayer[admin].g_iAmmoRangeCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRangeCooldown", "Ammo Range Cooldown", "Ammo_Range_Cooldown", "rangecooldown", g_esAmmoPlayer[admin].g_iAmmoRangeCooldown, value, -1, 99999);
			g_esAmmoPlayer[admin].g_iAmmoType = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoType", "Ammo Type", "Ammo_Type", "type", g_esAmmoPlayer[admin].g_iAmmoType, value, -1, 3);
			g_esAmmoPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esAmmoPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esAmmoSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esAmmoSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esAmmoSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAmmoSpecial[type].g_iComboAbility, value, -1, 1);
			g_esAmmoSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAmmoSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esAmmoSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAmmoSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esAmmoSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAmmoSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esAmmoSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esAmmoSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esAmmoSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAmmoSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esAmmoSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAmmoSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esAmmoSpecial[type].g_iAmmoAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAmmoSpecial[type].g_iAmmoAbility, value, -1, 1);
			g_esAmmoSpecial[type].g_iAmmoEffect = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAmmoSpecial[type].g_iAmmoEffect, value, -1, 7);
			g_esAmmoSpecial[type].g_iAmmoMessage = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAmmoSpecial[type].g_iAmmoMessage, value, -1, 3);
			g_esAmmoSpecial[type].g_iAmmoSight = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esAmmoSpecial[type].g_iAmmoSight, value, -1, 5);
			g_esAmmoSpecial[type].g_iAmmoAmount = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoCount", "Ammo Count", "Ammo_Count", "count", g_esAmmoSpecial[type].g_iAmmoAmount, value, -1, 100);
			g_esAmmoSpecial[type].g_flAmmoChance = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoChance", "Ammo Chance", "Ammo_Chance", "chance", g_esAmmoSpecial[type].g_flAmmoChance, value, -1.0, 100.0);
			g_esAmmoSpecial[type].g_iAmmoCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoCooldown", "Ammo Cooldown", "Ammo_Cooldown", "cooldown", g_esAmmoSpecial[type].g_iAmmoCooldown, value, -1, 99999);
			g_esAmmoSpecial[type].g_iAmmoHit = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoHit", "Ammo Hit", "Ammo_Hit", "hit", g_esAmmoSpecial[type].g_iAmmoHit, value, -1, 1);
			g_esAmmoSpecial[type].g_iAmmoHitMode = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoHitMode", "Ammo Hit Mode", "Ammo_Hit_Mode", "hitmode", g_esAmmoSpecial[type].g_iAmmoHitMode, value, -1, 2);
			g_esAmmoSpecial[type].g_flAmmoRange = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRange", "Ammo Range", "Ammo_Range", "range", g_esAmmoSpecial[type].g_flAmmoRange, value, -1.0, 99999.0);
			g_esAmmoSpecial[type].g_flAmmoRangeChance = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRangeChance", "Ammo Range Chance", "Ammo_Range_Chance", "rangechance", g_esAmmoSpecial[type].g_flAmmoRangeChance, value, -1.0, 100.0);
			g_esAmmoSpecial[type].g_iAmmoRangeCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRangeCooldown", "Ammo Range Cooldown", "Ammo_Range_Cooldown", "rangecooldown", g_esAmmoSpecial[type].g_iAmmoRangeCooldown, value, -1, 99999);
			g_esAmmoSpecial[type].g_iAmmoType = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoType", "Ammo Type", "Ammo_Type", "type", g_esAmmoSpecial[type].g_iAmmoType, value, -1, 3);
		}
		else
		{
			g_esAmmoAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esAmmoAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esAmmoAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAmmoAbility[type].g_iComboAbility, value, -1, 1);
			g_esAmmoAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAmmoAbility[type].g_iHumanAbility, value, -1, 2);
			g_esAmmoAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAmmoAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esAmmoAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAmmoAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esAmmoAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esAmmoAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esAmmoAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAmmoAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esAmmoAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAmmoAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esAmmoAbility[type].g_iAmmoAbility = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAmmoAbility[type].g_iAmmoAbility, value, -1, 1);
			g_esAmmoAbility[type].g_iAmmoEffect = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAmmoAbility[type].g_iAmmoEffect, value, -1, 7);
			g_esAmmoAbility[type].g_iAmmoMessage = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAmmoAbility[type].g_iAmmoMessage, value, -1, 3);
			g_esAmmoAbility[type].g_iAmmoSight = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esAmmoAbility[type].g_iAmmoSight, value, -1, 5);
			g_esAmmoAbility[type].g_iAmmoAmount = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoCount", "Ammo Count", "Ammo_Count", "count", g_esAmmoAbility[type].g_iAmmoAmount, value, -1, 100);
			g_esAmmoAbility[type].g_flAmmoChance = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoChance", "Ammo Chance", "Ammo_Chance", "chance", g_esAmmoAbility[type].g_flAmmoChance, value, -1.0, 100.0);
			g_esAmmoAbility[type].g_iAmmoCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoCooldown", "Ammo Cooldown", "Ammo_Cooldown", "cooldown", g_esAmmoAbility[type].g_iAmmoCooldown, value, -1, 99999);
			g_esAmmoAbility[type].g_iAmmoHit = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoHit", "Ammo Hit", "Ammo_Hit", "hit", g_esAmmoAbility[type].g_iAmmoHit, value, -1, 1);
			g_esAmmoAbility[type].g_iAmmoHitMode = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoHitMode", "Ammo Hit Mode", "Ammo_Hit_Mode", "hitmode", g_esAmmoAbility[type].g_iAmmoHitMode, value, -1, 2);
			g_esAmmoAbility[type].g_flAmmoRange = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRange", "Ammo Range", "Ammo_Range", "range", g_esAmmoAbility[type].g_flAmmoRange, value, -1.0, 99999.0);
			g_esAmmoAbility[type].g_flAmmoRangeChance = flGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRangeChance", "Ammo Range Chance", "Ammo_Range_Chance", "rangechance", g_esAmmoAbility[type].g_flAmmoRangeChance, value, -1.0, 100.0);
			g_esAmmoAbility[type].g_iAmmoRangeCooldown = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoRangeCooldown", "Ammo Range Cooldown", "Ammo_Range_Cooldown", "rangecooldown", g_esAmmoAbility[type].g_iAmmoRangeCooldown, value, -1, 99999);
			g_esAmmoAbility[type].g_iAmmoType = iGetKeyValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AmmoType", "Ammo Type", "Ammo_Type", "type", g_esAmmoAbility[type].g_iAmmoType, value, -1, 3);
			g_esAmmoAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esAmmoAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_AMMO_SECTION, MT_AMMO_SECTION2, MT_AMMO_SECTION3, MT_AMMO_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vAmmoSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esAmmoPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esAmmoPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esAmmoPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esAmmoCache[tank].g_flAmmoChance = flGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_flAmmoChance, g_esAmmoPlayer[tank].g_flAmmoChance, g_esAmmoSpecial[iType].g_flAmmoChance, g_esAmmoAbility[iType].g_flAmmoChance, 1);
		g_esAmmoCache[tank].g_flAmmoRange = flGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_flAmmoRange, g_esAmmoPlayer[tank].g_flAmmoRange, g_esAmmoSpecial[iType].g_flAmmoRange, g_esAmmoAbility[iType].g_flAmmoRange, 1);
		g_esAmmoCache[tank].g_flAmmoRangeChance = flGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_flAmmoRangeChance, g_esAmmoPlayer[tank].g_flAmmoRangeChance, g_esAmmoSpecial[iType].g_flAmmoRangeChance, g_esAmmoAbility[iType].g_flAmmoRangeChance, 1);
		g_esAmmoCache[tank].g_iAmmoAbility = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoAbility, g_esAmmoPlayer[tank].g_iAmmoAbility, g_esAmmoSpecial[iType].g_iAmmoAbility, g_esAmmoAbility[iType].g_iAmmoAbility, 1);
		g_esAmmoCache[tank].g_iAmmoAmount = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoAmount, g_esAmmoPlayer[tank].g_iAmmoAmount, g_esAmmoSpecial[iType].g_iAmmoAmount, g_esAmmoAbility[iType].g_iAmmoAmount, 1);
		g_esAmmoCache[tank].g_iAmmoCooldown = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoCooldown, g_esAmmoPlayer[tank].g_iAmmoCooldown, g_esAmmoSpecial[iType].g_iAmmoCooldown, g_esAmmoAbility[iType].g_iAmmoCooldown, 1);
		g_esAmmoCache[tank].g_iAmmoEffect = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoEffect, g_esAmmoPlayer[tank].g_iAmmoEffect, g_esAmmoSpecial[iType].g_iAmmoEffect, g_esAmmoAbility[iType].g_iAmmoEffect, 1);
		g_esAmmoCache[tank].g_iAmmoHit = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoHit, g_esAmmoPlayer[tank].g_iAmmoHit, g_esAmmoSpecial[iType].g_iAmmoHit, g_esAmmoAbility[iType].g_iAmmoHit, 1);
		g_esAmmoCache[tank].g_iAmmoHitMode = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoHitMode, g_esAmmoPlayer[tank].g_iAmmoHitMode, g_esAmmoSpecial[iType].g_iAmmoHitMode, g_esAmmoAbility[iType].g_iAmmoHitMode, 1);
		g_esAmmoCache[tank].g_iAmmoMessage = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoMessage, g_esAmmoPlayer[tank].g_iAmmoMessage, g_esAmmoSpecial[iType].g_iAmmoMessage, g_esAmmoAbility[iType].g_iAmmoMessage, 1);
		g_esAmmoCache[tank].g_iAmmoRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoRangeCooldown, g_esAmmoPlayer[tank].g_iAmmoRangeCooldown, g_esAmmoSpecial[iType].g_iAmmoRangeCooldown, g_esAmmoAbility[iType].g_iAmmoRangeCooldown, 1);
		g_esAmmoCache[tank].g_iAmmoSight = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoSight, g_esAmmoPlayer[tank].g_iAmmoSight, g_esAmmoSpecial[iType].g_iAmmoSight, g_esAmmoAbility[iType].g_iAmmoSight, 1);
		g_esAmmoCache[tank].g_iAmmoType = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iAmmoType, g_esAmmoPlayer[tank].g_iAmmoType, g_esAmmoSpecial[iType].g_iAmmoType, g_esAmmoAbility[iType].g_iAmmoType, 1);
		g_esAmmoCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_flCloseAreasOnly, g_esAmmoPlayer[tank].g_flCloseAreasOnly, g_esAmmoSpecial[iType].g_flCloseAreasOnly, g_esAmmoAbility[iType].g_flCloseAreasOnly, 1);
		g_esAmmoCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iComboAbility, g_esAmmoPlayer[tank].g_iComboAbility, g_esAmmoSpecial[iType].g_iComboAbility, g_esAmmoAbility[iType].g_iComboAbility, 1);
		g_esAmmoCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iHumanAbility, g_esAmmoPlayer[tank].g_iHumanAbility, g_esAmmoSpecial[iType].g_iHumanAbility, g_esAmmoAbility[iType].g_iHumanAbility, 1);
		g_esAmmoCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iHumanAmmo, g_esAmmoPlayer[tank].g_iHumanAmmo, g_esAmmoSpecial[iType].g_iHumanAmmo, g_esAmmoAbility[iType].g_iHumanAmmo, 1);
		g_esAmmoCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iHumanCooldown, g_esAmmoPlayer[tank].g_iHumanCooldown, g_esAmmoSpecial[iType].g_iHumanCooldown, g_esAmmoAbility[iType].g_iHumanCooldown, 1);
		g_esAmmoCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iHumanRangeCooldown, g_esAmmoPlayer[tank].g_iHumanRangeCooldown, g_esAmmoSpecial[iType].g_iHumanRangeCooldown, g_esAmmoAbility[iType].g_iHumanRangeCooldown, 1);
		g_esAmmoCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_flOpenAreasOnly, g_esAmmoPlayer[tank].g_flOpenAreasOnly, g_esAmmoSpecial[iType].g_flOpenAreasOnly, g_esAmmoAbility[iType].g_flOpenAreasOnly, 1);
		g_esAmmoCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esAmmoTeammate[tank].g_iRequiresHumans, g_esAmmoPlayer[tank].g_iRequiresHumans, g_esAmmoSpecial[iType].g_iRequiresHumans, g_esAmmoAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esAmmoCache[tank].g_flAmmoChance = flGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_flAmmoChance, g_esAmmoAbility[iType].g_flAmmoChance, 1);
		g_esAmmoCache[tank].g_flAmmoRange = flGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_flAmmoRange, g_esAmmoAbility[iType].g_flAmmoRange, 1);
		g_esAmmoCache[tank].g_flAmmoRangeChance = flGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_flAmmoRangeChance, g_esAmmoAbility[iType].g_flAmmoRangeChance, 1);
		g_esAmmoCache[tank].g_iAmmoAbility = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoAbility, g_esAmmoAbility[iType].g_iAmmoAbility, 1);
		g_esAmmoCache[tank].g_iAmmoAmount = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoAmount, g_esAmmoAbility[iType].g_iAmmoAmount, 1);
		g_esAmmoCache[tank].g_iAmmoCooldown = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoCooldown, g_esAmmoAbility[iType].g_iAmmoCooldown, 1);
		g_esAmmoCache[tank].g_iAmmoEffect = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoEffect, g_esAmmoAbility[iType].g_iAmmoEffect, 1);
		g_esAmmoCache[tank].g_iAmmoHit = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoHit, g_esAmmoAbility[iType].g_iAmmoHit, 1);
		g_esAmmoCache[tank].g_iAmmoHitMode = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoHitMode, g_esAmmoAbility[iType].g_iAmmoHitMode, 1);
		g_esAmmoCache[tank].g_iAmmoMessage = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoMessage, g_esAmmoAbility[iType].g_iAmmoMessage, 1);
		g_esAmmoCache[tank].g_iAmmoRangeCooldown = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoRangeCooldown, g_esAmmoAbility[iType].g_iAmmoRangeCooldown, 1);
		g_esAmmoCache[tank].g_iAmmoSight = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoSight, g_esAmmoAbility[iType].g_iAmmoSight, 1);
		g_esAmmoCache[tank].g_iAmmoType = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iAmmoType, g_esAmmoAbility[iType].g_iAmmoType, 1);
		g_esAmmoCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_flCloseAreasOnly, g_esAmmoAbility[iType].g_flCloseAreasOnly, 1);
		g_esAmmoCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iComboAbility, g_esAmmoAbility[iType].g_iComboAbility, 1);
		g_esAmmoCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iHumanAbility, g_esAmmoAbility[iType].g_iHumanAbility, 1);
		g_esAmmoCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iHumanAmmo, g_esAmmoAbility[iType].g_iHumanAmmo, 1);
		g_esAmmoCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iHumanCooldown, g_esAmmoAbility[iType].g_iHumanCooldown, 1);
		g_esAmmoCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iHumanRangeCooldown, g_esAmmoAbility[iType].g_iHumanRangeCooldown, 1);
		g_esAmmoCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_flOpenAreasOnly, g_esAmmoAbility[iType].g_flOpenAreasOnly, 1);
		g_esAmmoCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esAmmoPlayer[tank].g_iRequiresHumans, g_esAmmoAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN
void vAmmoCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vAmmoCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveAmmo(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vAmmoEventFired(Event event, const char[] name)
#else
public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
#endif
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsInfected(iTank))
		{
			vAmmoCopyStats2(iBot, iTank);
			vRemoveAmmo(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vAmmoReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vAmmoCopyStats2(iTank, iBot);
			vRemoveAmmo(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveAmmo(iTank);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vAmmoHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esAmmoCache[iBoomer].g_flAmmoChance, g_esAmmoCache[iBoomer].g_iAmmoHit, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vAmmoAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAmmoAbility[g_esAmmoPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esAmmoPlayer[tank].g_iAccessFlags)) || g_esAmmoCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esAmmoCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esAmmoCache[tank].g_iAmmoAbility == 1 && g_esAmmoCache[tank].g_iComboAbility == 0)
	{
		vAmmoAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN
void vAmmoButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esAmmoCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esAmmoCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esAmmoPlayer[tank].g_iTankType, tank) || (g_esAmmoCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esAmmoCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAmmoAbility[g_esAmmoPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esAmmoPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esAmmoCache[tank].g_iAmmoAbility == 1 && g_esAmmoCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();

			switch (g_esAmmoPlayer[tank].g_iRangeCooldown == -1 || g_esAmmoPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vAmmoAbility(tank, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman3", (g_esAmmoPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vAmmoChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveAmmo(tank);
}

void vAmmoAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esAmmoCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esAmmoCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esAmmoPlayer[tank].g_iTankType, tank) || (g_esAmmoCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esAmmoCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAmmoAbility[g_esAmmoPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esAmmoPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esAmmoPlayer[tank].g_iAmmoCount < g_esAmmoCache[tank].g_iHumanAmmo && g_esAmmoCache[tank].g_iHumanAmmo > 0))
	{
		g_esAmmoPlayer[tank].g_bFailed = false;
		g_esAmmoPlayer[tank].g_bNoAmmo = false;

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esAmmoCache[tank].g_flAmmoRange,
			flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esAmmoCache[tank].g_flAmmoRangeChance;
		int iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esAmmoPlayer[tank].g_iTankType, g_esAmmoAbility[g_esAmmoPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esAmmoPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esAmmoCache[tank].g_iAmmoSight, .range = flRange))
				{
					vAmmoHit(iSurvivor, tank, random, flChance, g_esAmmoCache[tank].g_iAmmoAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esAmmoCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman4");
			}
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esAmmoCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoAmmo");
	}
}

void vAmmoHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esAmmoCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esAmmoCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esAmmoPlayer[tank].g_iTankType, tank) || (g_esAmmoCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esAmmoCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAmmoAbility[g_esAmmoPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esAmmoPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esAmmoPlayer[tank].g_iTankType, g_esAmmoAbility[g_esAmmoPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esAmmoPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iSlot = GetPlayerWeaponSlot(survivor, 0), iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esAmmoPlayer[tank].g_iRangeCooldown != -1 && g_esAmmoPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esAmmoPlayer[tank].g_iCooldown != -1 && g_esAmmoPlayer[tank].g_iCooldown >= iTime))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_GODMODE) && iSlot > MaxClients && (GetEntProp(survivor, Prop_Send, "m_iAmmo", .element = iGetWeaponOffset(iSlot)) > 0 || GetEntProp(iSlot, Prop_Send, "m_iClip1") > 0))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esAmmoPlayer[tank].g_iAmmoCount < g_esAmmoCache[tank].g_iHumanAmmo && g_esAmmoCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esAmmoCache[tank].g_iAmmoSight, .range = 100.0))
				{
					return;
				}

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esAmmoPlayer[tank].g_iRangeCooldown == -1 || g_esAmmoPlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esAmmoCache[tank].g_iHumanAbility == 1)
					{
						g_esAmmoPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman", g_esAmmoPlayer[tank].g_iAmmoCount, g_esAmmoCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esAmmoCache[tank].g_iAmmoRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esAmmoCache[tank].g_iHumanAbility == 1 && g_esAmmoPlayer[tank].g_iAmmoCount < g_esAmmoCache[tank].g_iHumanAmmo && g_esAmmoCache[tank].g_iHumanAmmo > 0) ? g_esAmmoCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esAmmoPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esAmmoPlayer[tank].g_iRangeCooldown != -1 && g_esAmmoPlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman5", (g_esAmmoPlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esAmmoPlayer[tank].g_iCooldown == -1 || g_esAmmoPlayer[tank].g_iCooldown <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esAmmoCache[tank].g_iAmmoCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esAmmoCache[tank].g_iHumanAbility == 1) ? g_esAmmoCache[tank].g_iHumanCooldown : iCooldown;
					g_esAmmoPlayer[tank].g_iCooldown = (iTime + iCooldown);
					if (g_esAmmoPlayer[tank].g_iCooldown != -1 && g_esAmmoPlayer[tank].g_iCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman5", (g_esAmmoPlayer[tank].g_iCooldown - iTime));
					}
				}

				int iCurrentAmmo = GetEntProp(survivor, Prop_Send, "m_iAmmo", .element = iGetWeaponOffset(iSlot)), iCurrentClip = GetEntProp(iSlot, Prop_Send, "m_iClip1"),
					iNewAmmo = iClamp((iCurrentAmmo - g_esAmmoCache[tank].g_iAmmoAmount), 0, iCurrentAmmo), iNewClip = iClamp((iCurrentClip - g_esAmmoCache[tank].g_iAmmoAmount), 0, iCurrentClip);
				if (g_esAmmoCache[tank].g_iAmmoType & MT_AMMO_MAGAZINE)
				{
					SetEntProp(iSlot, Prop_Send, "m_iClip1", iNewClip);
				}

				if (g_esAmmoCache[tank].g_iAmmoType & MT_AMMO_RESERVED)
				{
					SetEntProp(survivor, Prop_Send, "m_iAmmo", iNewAmmo, .element = iGetWeaponOffset(iSlot));
				}

				vScreenEffect(survivor, tank, g_esAmmoCache[tank].g_iAmmoEffect, flags);

				if (g_esAmmoCache[tank].g_iAmmoMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Ammo", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Ammo", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esAmmoPlayer[tank].g_iRangeCooldown == -1 || g_esAmmoPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esAmmoCache[tank].g_iHumanAbility == 1 && !g_esAmmoPlayer[tank].g_bFailed)
				{
					g_esAmmoPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoHuman2");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esAmmoCache[tank].g_iHumanAbility == 1 && !g_esAmmoPlayer[tank].g_bNoAmmo)
		{
			g_esAmmoPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "AmmoAmmo");
		}
	}
}

void vAmmoCopyStats2(int oldTank, int newTank)
{
	g_esAmmoPlayer[newTank].g_iAmmoCount = g_esAmmoPlayer[oldTank].g_iAmmoCount;
	g_esAmmoPlayer[newTank].g_iCooldown = g_esAmmoPlayer[oldTank].g_iCooldown;
	g_esAmmoPlayer[newTank].g_iRangeCooldown = g_esAmmoPlayer[oldTank].g_iRangeCooldown;
}

void vRemoveAmmo(int tank)
{
	g_esAmmoPlayer[tank].g_bFailed = false;
	g_esAmmoPlayer[tank].g_bNoAmmo = false;
	g_esAmmoPlayer[tank].g_iAmmoCount = 0;
	g_esAmmoPlayer[tank].g_iCooldown = -1;
	g_esAmmoPlayer[tank].g_iRangeCooldown = -1;
}

void vAmmoReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveAmmo(iPlayer);
		}
	}
}

void tTimerAmmoCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAmmoAbility[g_esAmmoPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esAmmoPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esAmmoPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esAmmoCache[iTank].g_iAmmoAbility == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vAmmoAbility(iTank, flRandom, iPos);
}

void tTimerAmmoCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAmmoAbility[g_esAmmoPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esAmmoPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esAmmoPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esAmmoCache[iTank].g_iAmmoHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esAmmoCache[iTank].g_iAmmoHitMode == 0 || g_esAmmoCache[iTank].g_iAmmoHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vAmmoHit(iSurvivor, iTank, flRandom, flChance, g_esAmmoCache[iTank].g_iAmmoHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esAmmoCache[iTank].g_iAmmoHitMode == 0 || g_esAmmoCache[iTank].g_iAmmoHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vAmmoHit(iSurvivor, iTank, flRandom, flChance, g_esAmmoCache[iTank].g_iAmmoHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}
}