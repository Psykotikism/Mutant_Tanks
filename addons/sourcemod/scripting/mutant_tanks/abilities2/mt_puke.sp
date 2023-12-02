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

#define MT_PUKE_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_PUKE_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Puke Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank pukes on survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Puke Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_VOMIT "boomer_vomit"
#else
	#if MT_PUKE_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_PUKE_SECTION "pukeability"
#define MT_PUKE_SECTION2 "puke ability"
#define MT_PUKE_SECTION3 "puke_ability"
#define MT_PUKE_SECTION4 "puke"

#define MT_MENU_PUKE "Puke Ability"

enum struct esPukePlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPukeChance;
	float g_flPukeDeathChance;
	float g_flPukeDeathRange;
	float g_flPukeRange;
	float g_flPukeRangeChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iPukeAbility;
	int g_iPukeCooldown;
	int g_iPukeDeath;
	int g_iPukeEffect;
	int g_iPukeHit;
	int g_iPukeHitMode;
	int g_iPukeMessage;
	int g_iPukeRangeCooldown;
	int g_iPukeSight;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esPukePlayer g_esPukePlayer[MAXPLAYERS + 1];

enum struct esPukeTeammate
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPukeChance;
	float g_flPukeDeathChance;
	float g_flPukeDeathRange;
	float g_flPukeRange;
	float g_flPukeRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iPukeAbility;
	int g_iPukeCooldown;
	int g_iPukeDeath;
	int g_iPukeEffect;
	int g_iPukeHit;
	int g_iPukeHitMode;
	int g_iPukeMessage;
	int g_iPukeRangeCooldown;
	int g_iPukeSight;
	int g_iRequiresHumans;
}

esPukeTeammate g_esPukeTeammate[MAXPLAYERS + 1];

enum struct esPukeAbility
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPukeChance;
	float g_flPukeDeathChance;
	float g_flPukeDeathRange;
	float g_flPukeRange;
	float g_flPukeRangeChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iPukeAbility;
	int g_iPukeCooldown;
	int g_iPukeDeath;
	int g_iPukeEffect;
	int g_iPukeHit;
	int g_iPukeHitMode;
	int g_iPukeMessage;
	int g_iPukeRangeCooldown;
	int g_iPukeSight;
	int g_iRequiresHumans;
}

esPukeAbility g_esPukeAbility[MT_MAXTYPES + 1];

enum struct esPukeSpecial
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPukeChance;
	float g_flPukeDeathChance;
	float g_flPukeDeathRange;
	float g_flPukeRange;
	float g_flPukeRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iPukeAbility;
	int g_iPukeCooldown;
	int g_iPukeDeath;
	int g_iPukeEffect;
	int g_iPukeHit;
	int g_iPukeHitMode;
	int g_iPukeMessage;
	int g_iPukeRangeCooldown;
	int g_iPukeSight;
	int g_iRequiresHumans;
}

esPukeSpecial g_esPukeSpecial[MT_MAXTYPES + 1];

enum struct esPukeCache
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flPukeChance;
	float g_flPukeDeathChance;
	float g_flPukeDeathRange;
	float g_flPukeRange;
	float g_flPukeRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iPukeAbility;
	int g_iPukeCooldown;
	int g_iPukeDeath;
	int g_iPukeEffect;
	int g_iPukeHit;
	int g_iPukeHitMode;
	int g_iPukeMessage;
	int g_iPukeRangeCooldown;
	int g_iPukeSight;
	int g_iRequiresHumans;
}

esPukeCache g_esPukeCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_puke", cmdPukeInfo, "View information about the Puke ability.");

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

#if defined MT_ABILITIES_MAIN2
void vPukeMapStart()
#else
public void OnMapStart()
#endif
{
	iPrecacheParticle(PARTICLE_BLOOD);
	iPrecacheParticle(PARTICLE_VOMIT);

	vPukeReset();
}

#if defined MT_ABILITIES_MAIN2
void vPukeClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnPukeTakeDamage);
	vRemovePuke(client);
}

#if defined MT_ABILITIES_MAIN2
void vPukeClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemovePuke(client);
}

#if defined MT_ABILITIES_MAIN2
void vPukeMapEnd()
#else
public void OnMapEnd()
#endif
{
	vPukeReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdPukeInfo(int client, int args)
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
		case false: vPukeMenu(client, MT_PUKE_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vPukeMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_PUKE_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iPukeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Puke Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iPukeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esPukeCache[param1].g_iPukeAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esPukeCache[param1].g_iHumanAmmo - g_esPukePlayer[param1].g_iAmmoCount), g_esPukeCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esPukeCache[param1].g_iHumanAbility == 1) ? g_esPukeCache[param1].g_iHumanCooldown : g_esPukeCache[param1].g_iPukeCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "PukeDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esPukeCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esPukeCache[param1].g_iHumanAbility == 1) ? g_esPukeCache[param1].g_iHumanRangeCooldown : g_esPukeCache[param1].g_iPukeRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vPukeMenu(param1, MT_PUKE_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pPuke = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "PukeMenu", param1);
			pPuke.SetTitle(sMenuTitle);
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

#if defined MT_ABILITIES_MAIN2
void vPukeDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_PUKE, MT_MENU_PUKE);
}

#if defined MT_ABILITIES_MAIN2
void vPukeMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_PUKE, false))
	{
		vPukeMenu(client, MT_PUKE_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vPukeMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_PUKE, false))
	{
		FormatEx(buffer, size, "%T", "PukeMenu2", client);
	}
}

Action OnPukeTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esPukeCache[attacker].g_iPukeHitMode == 0 || g_esPukeCache[attacker].g_iPukeHitMode == 1) && bIsSurvivor(victim) && g_esPukeCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esPukeAbility[g_esPukePlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPukePlayer[attacker].g_iTankType, g_esPukeAbility[g_esPukePlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esPukePlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPukeHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esPukeCache[attacker].g_flPukeChance, g_esPukeCache[attacker].g_iPukeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esPukeCache[victim].g_iPukeHitMode == 0 || g_esPukeCache[victim].g_iPukeHitMode == 2) && bIsSurvivor(attacker) && g_esPukeCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esPukeAbility[g_esPukePlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPukePlayer[victim].g_iTankType, g_esPukeAbility[g_esPukePlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esPukePlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vPukeHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esPukeCache[victim].g_flPukeChance, g_esPukeCache[victim].g_iPukeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vPukePluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_PUKE);
}

#if defined MT_ABILITIES_MAIN2
void vPukeAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_PUKE_SECTION);
	list2.PushString(MT_PUKE_SECTION2);
	list3.PushString(MT_PUKE_SECTION3);
	list4.PushString(MT_PUKE_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vPukeCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPukeCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_PUKE_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_PUKE_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_PUKE_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_PUKE_SECTION4);
	if (g_esPukeCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_PUKE_SECTION, false) || StrEqual(sSubset[iPos], MT_PUKE_SECTION2, false) || StrEqual(sSubset[iPos], MT_PUKE_SECTION3, false) || StrEqual(sSubset[iPos], MT_PUKE_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esPukeCache[tank].g_iPukeAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vPukeAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerPukeCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
								if ((g_esPukeCache[tank].g_iPukeHitMode == 0 || g_esPukeCache[tank].g_iPukeHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vPukeHit(survivor, tank, random, flChance, g_esPukeCache[tank].g_iPukeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esPukeCache[tank].g_iPukeHitMode == 0 || g_esPukeCache[tank].g_iPukeHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vPukeHit(survivor, tank, random, flChance, g_esPukeCache[tank].g_iPukeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerPukeCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteCell(iPos);
								dpCombo.WriteString(classname);
							}
						}
					}
					case MT_COMBO_POSTSPAWN: vPukeRange(tank, 0, 2, random, iPos);
					case MT_COMBO_UPONDEATH: vPukeRange(tank, 0, 1, random, iPos);
				}

				break;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPukeConfigsLoad(int mode)
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
				g_esPukeAbility[iIndex].g_iAccessFlags = 0;
				g_esPukeAbility[iIndex].g_iImmunityFlags = 0;
				g_esPukeAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esPukeAbility[iIndex].g_iComboAbility = 0;
				g_esPukeAbility[iIndex].g_iHumanAbility = 0;
				g_esPukeAbility[iIndex].g_iHumanAmmo = 5;
				g_esPukeAbility[iIndex].g_iHumanCooldown = 0;
				g_esPukeAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esPukeAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esPukeAbility[iIndex].g_iRequiresHumans = 0;
				g_esPukeAbility[iIndex].g_iPukeAbility = 0;
				g_esPukeAbility[iIndex].g_iPukeEffect = 0;
				g_esPukeAbility[iIndex].g_iPukeMessage = 0;
				g_esPukeAbility[iIndex].g_flPukeChance = 33.3;
				g_esPukeAbility[iIndex].g_iPukeCooldown = 0;
				g_esPukeAbility[iIndex].g_iPukeDeath = 0;
				g_esPukeAbility[iIndex].g_flPukeDeathChance = 33.3;
				g_esPukeAbility[iIndex].g_flPukeDeathRange = 200.0;
				g_esPukeAbility[iIndex].g_iPukeHit = 0;
				g_esPukeAbility[iIndex].g_iPukeHitMode = 0;
				g_esPukeAbility[iIndex].g_flPukeRange = 150.0;
				g_esPukeAbility[iIndex].g_flPukeRangeChance = 15.0;
				g_esPukeAbility[iIndex].g_iPukeRangeCooldown = 0;
				g_esPukeAbility[iIndex].g_iPukeSight = 0;

				g_esPukeSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esPukeSpecial[iIndex].g_iComboAbility = -1;
				g_esPukeSpecial[iIndex].g_iHumanAbility = -1;
				g_esPukeSpecial[iIndex].g_iHumanAmmo = -1;
				g_esPukeSpecial[iIndex].g_iHumanCooldown = -1;
				g_esPukeSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esPukeSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esPukeSpecial[iIndex].g_iRequiresHumans = -1;
				g_esPukeSpecial[iIndex].g_iPukeAbility = -1;
				g_esPukeSpecial[iIndex].g_iPukeEffect = -1;
				g_esPukeSpecial[iIndex].g_iPukeMessage = -1;
				g_esPukeSpecial[iIndex].g_flPukeChance = -1.0;
				g_esPukeSpecial[iIndex].g_iPukeCooldown = -1;
				g_esPukeSpecial[iIndex].g_iPukeDeath = -1;
				g_esPukeSpecial[iIndex].g_flPukeDeathChance = -1.0;
				g_esPukeSpecial[iIndex].g_flPukeDeathRange = -1.0;
				g_esPukeSpecial[iIndex].g_iPukeHit = -1;
				g_esPukeSpecial[iIndex].g_iPukeHitMode = -1;
				g_esPukeSpecial[iIndex].g_flPukeRange = -1.0;
				g_esPukeSpecial[iIndex].g_flPukeRangeChance = -1.0;
				g_esPukeSpecial[iIndex].g_iPukeRangeCooldown = -1;
				g_esPukeSpecial[iIndex].g_iPukeSight = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esPukePlayer[iPlayer].g_iAccessFlags = -1;
				g_esPukePlayer[iPlayer].g_iImmunityFlags = -1;
				g_esPukePlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esPukePlayer[iPlayer].g_iComboAbility = -1;
				g_esPukePlayer[iPlayer].g_iHumanAbility = -1;
				g_esPukePlayer[iPlayer].g_iHumanAmmo = -1;
				g_esPukePlayer[iPlayer].g_iHumanCooldown = -1;
				g_esPukePlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esPukePlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esPukePlayer[iPlayer].g_iRequiresHumans = -1;
				g_esPukePlayer[iPlayer].g_iPukeAbility = -1;
				g_esPukePlayer[iPlayer].g_iPukeEffect = -1;
				g_esPukePlayer[iPlayer].g_iPukeMessage = -1;
				g_esPukePlayer[iPlayer].g_flPukeChance = -1.0;
				g_esPukePlayer[iPlayer].g_iPukeCooldown = -1;
				g_esPukePlayer[iPlayer].g_iPukeDeath = -1;
				g_esPukePlayer[iPlayer].g_flPukeDeathChance = -1.0;
				g_esPukePlayer[iPlayer].g_flPukeDeathRange = -1.0;
				g_esPukePlayer[iPlayer].g_iPukeHit = -1;
				g_esPukePlayer[iPlayer].g_iPukeHitMode = -1;
				g_esPukePlayer[iPlayer].g_flPukeRange = -1.0;
				g_esPukePlayer[iPlayer].g_flPukeRangeChance = -1.0;
				g_esPukePlayer[iPlayer].g_iPukeRangeCooldown = -1;
				g_esPukePlayer[iPlayer].g_iPukeSight = -1;

				g_esPukeTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esPukeTeammate[iPlayer].g_iComboAbility = -1;
				g_esPukeTeammate[iPlayer].g_iHumanAbility = -1;
				g_esPukeTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esPukeTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esPukeTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esPukeTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esPukeTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esPukeTeammate[iPlayer].g_iPukeAbility = -1;
				g_esPukeTeammate[iPlayer].g_iPukeEffect = -1;
				g_esPukeTeammate[iPlayer].g_iPukeMessage = -1;
				g_esPukeTeammate[iPlayer].g_flPukeChance = -1.0;
				g_esPukeTeammate[iPlayer].g_iPukeCooldown = -1;
				g_esPukeTeammate[iPlayer].g_iPukeDeath = -1;
				g_esPukeTeammate[iPlayer].g_flPukeDeathChance = -1.0;
				g_esPukeTeammate[iPlayer].g_flPukeDeathRange = -1.0;
				g_esPukeTeammate[iPlayer].g_iPukeHit = -1;
				g_esPukeTeammate[iPlayer].g_iPukeHitMode = -1;
				g_esPukeTeammate[iPlayer].g_flPukeRange = -1.0;
				g_esPukeTeammate[iPlayer].g_flPukeRangeChance = -1.0;
				g_esPukeTeammate[iPlayer].g_iPukeRangeCooldown = -1;
				g_esPukeTeammate[iPlayer].g_iPukeSight = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPukeConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esPukeTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esPukeTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esPukeTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPukeTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esPukeTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPukeTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esPukeTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPukeTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esPukeTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPukeTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esPukeTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esPukeTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esPukeTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPukeTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esPukeTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPukeTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esPukeTeammate[admin].g_iPukeAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPukeTeammate[admin].g_iPukeAbility, value, -1, 1);
			g_esPukeTeammate[admin].g_iPukeEffect = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPukeTeammate[admin].g_iPukeEffect, value, -1, 7);
			g_esPukeTeammate[admin].g_iPukeMessage = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPukeTeammate[admin].g_iPukeMessage, value, -1, 3);
			g_esPukeTeammate[admin].g_iPukeSight = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esPukeTeammate[admin].g_iPukeSight, value, -1, 5);
			g_esPukeTeammate[admin].g_flPukeChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeChance", "Puke Chance", "Puke_Chance", "chance", g_esPukeTeammate[admin].g_flPukeChance, value, -1.0, 100.0);
			g_esPukeTeammate[admin].g_iPukeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeCooldown", "Puke Cooldown", "Puke_Cooldown", "cooldown", g_esPukeTeammate[admin].g_iPukeCooldown, value, -1, 99999);
			g_esPukeTeammate[admin].g_iPukeDeath = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeath", "Puke Death", "Puke_Death", "death", g_esPukeTeammate[admin].g_iPukeDeath, value, -1, 3);
			g_esPukeTeammate[admin].g_flPukeDeathChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeathChance", "Puke Death Chance", "Puke_Death_Chance", "deathchance", g_esPukeTeammate[admin].g_flPukeDeathChance, value, -1.0, 100.0);
			g_esPukeTeammate[admin].g_flPukeDeathRange = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeathRange", "Puke Death Range", "Puke_Death_Range", "deathrange", g_esPukeTeammate[admin].g_flPukeDeathRange, value, -1.0, 99999.0);
			g_esPukeTeammate[admin].g_iPukeHit = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeHit", "Puke Hit", "Puke_Hit", "hit", g_esPukeTeammate[admin].g_iPukeHit, value, -1, 1);
			g_esPukeTeammate[admin].g_iPukeHitMode = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeHitMode", "Puke Hit Mode", "Puke_Hit_Mode", "hitmode", g_esPukeTeammate[admin].g_iPukeHitMode, value, -1, 2);
			g_esPukeTeammate[admin].g_flPukeRange = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRange", "Puke Range", "Puke_Range", "range", g_esPukeTeammate[admin].g_flPukeRange, value, -1.0, 99999.0);
			g_esPukeTeammate[admin].g_flPukeRangeChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRangeChance", "Puke Range Chance", "Puke_Range_Chance", "rangechance", g_esPukeTeammate[admin].g_flPukeRangeChance, value, -1.0, 100.0);
			g_esPukeTeammate[admin].g_iPukeRangeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRangeCooldown", "Puke Range Cooldown", "Puke_Range_Cooldown", "rangecooldown", g_esPukeTeammate[admin].g_iPukeRangeCooldown, value, -1, 99999);
		}
		else
		{
			g_esPukePlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esPukePlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esPukePlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPukePlayer[admin].g_iComboAbility, value, -1, 1);
			g_esPukePlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPukePlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esPukePlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPukePlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esPukePlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPukePlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esPukePlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esPukePlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esPukePlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPukePlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esPukePlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPukePlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esPukePlayer[admin].g_iPukeAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPukePlayer[admin].g_iPukeAbility, value, -1, 1);
			g_esPukePlayer[admin].g_iPukeEffect = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPukePlayer[admin].g_iPukeEffect, value, -1, 7);
			g_esPukePlayer[admin].g_iPukeMessage = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPukePlayer[admin].g_iPukeMessage, value, -1, 3);
			g_esPukePlayer[admin].g_iPukeSight = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esPukePlayer[admin].g_iPukeSight, value, -1, 5);
			g_esPukePlayer[admin].g_flPukeChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeChance", "Puke Chance", "Puke_Chance", "chance", g_esPukePlayer[admin].g_flPukeChance, value, -1.0, 100.0);
			g_esPukePlayer[admin].g_iPukeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeCooldown", "Puke Cooldown", "Puke_Cooldown", "cooldown", g_esPukePlayer[admin].g_iPukeCooldown, value, -1, 99999);
			g_esPukePlayer[admin].g_iPukeDeath = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeath", "Puke Death", "Puke_Death", "death", g_esPukePlayer[admin].g_iPukeDeath, value, -1, 3);
			g_esPukePlayer[admin].g_flPukeDeathChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeathChance", "Puke Death Chance", "Puke_Death_Chance", "deathchance", g_esPukePlayer[admin].g_flPukeDeathChance, value, -1.0, 100.0);
			g_esPukePlayer[admin].g_flPukeDeathRange = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeathRange", "Puke Death Range", "Puke_Death_Range", "deathrange", g_esPukePlayer[admin].g_flPukeDeathRange, value, -1.0, 99999.0);
			g_esPukePlayer[admin].g_iPukeHit = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeHit", "Puke Hit", "Puke_Hit", "hit", g_esPukePlayer[admin].g_iPukeHit, value, -1, 1);
			g_esPukePlayer[admin].g_iPukeHitMode = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeHitMode", "Puke Hit Mode", "Puke_Hit_Mode", "hitmode", g_esPukePlayer[admin].g_iPukeHitMode, value, -1, 2);
			g_esPukePlayer[admin].g_flPukeRange = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRange", "Puke Range", "Puke_Range", "range", g_esPukePlayer[admin].g_flPukeRange, value, -1.0, 99999.0);
			g_esPukePlayer[admin].g_flPukeRangeChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRangeChance", "Puke Range Chance", "Puke_Range_Chance", "rangechance", g_esPukePlayer[admin].g_flPukeRangeChance, value, -1.0, 100.0);
			g_esPukePlayer[admin].g_iPukeRangeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRangeCooldown", "Puke Range Cooldown", "Puke_Range_Cooldown", "rangecooldown", g_esPukePlayer[admin].g_iPukeRangeCooldown, value, -1, 99999);
			g_esPukePlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esPukePlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esPukeSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esPukeSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esPukeSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPukeSpecial[type].g_iComboAbility, value, -1, 1);
			g_esPukeSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPukeSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esPukeSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPukeSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esPukeSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPukeSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esPukeSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esPukeSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esPukeSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPukeSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esPukeSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPukeSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esPukeSpecial[type].g_iPukeAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPukeSpecial[type].g_iPukeAbility, value, -1, 1);
			g_esPukeSpecial[type].g_iPukeEffect = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPukeSpecial[type].g_iPukeEffect, value, -1, 7);
			g_esPukeSpecial[type].g_iPukeMessage = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPukeSpecial[type].g_iPukeMessage, value, -1, 3);
			g_esPukeSpecial[type].g_iPukeSight = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esPukeSpecial[type].g_iPukeSight, value, -1, 5);
			g_esPukeSpecial[type].g_flPukeChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeChance", "Puke Chance", "Puke_Chance", "chance", g_esPukeSpecial[type].g_flPukeChance, value, -1.0, 100.0);
			g_esPukeSpecial[type].g_iPukeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeCooldown", "Puke Cooldown", "Puke_Cooldown", "cooldown", g_esPukeSpecial[type].g_iPukeCooldown, value, -1, 99999);
			g_esPukeSpecial[type].g_iPukeDeath = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeath", "Puke Death", "Puke_Death", "death", g_esPukeSpecial[type].g_iPukeDeath, value, -1, 3);
			g_esPukeSpecial[type].g_flPukeDeathChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeathChance", "Puke Death Chance", "Puke_Death_Chance", "deathchance", g_esPukeSpecial[type].g_flPukeDeathChance, value, -1.0, 100.0);
			g_esPukeSpecial[type].g_flPukeDeathRange = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeathRange", "Puke Death Range", "Puke_Death_Range", "deathrange", g_esPukeSpecial[type].g_flPukeDeathRange, value, -1.0, 99999.0);
			g_esPukeSpecial[type].g_iPukeHit = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeHit", "Puke Hit", "Puke_Hit", "hit", g_esPukeSpecial[type].g_iPukeHit, value, -1, 1);
			g_esPukeSpecial[type].g_iPukeHitMode = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeHitMode", "Puke Hit Mode", "Puke_Hit_Mode", "hitmode", g_esPukeSpecial[type].g_iPukeHitMode, value, -1, 2);
			g_esPukeSpecial[type].g_flPukeRange = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRange", "Puke Range", "Puke_Range", "range", g_esPukeSpecial[type].g_flPukeRange, value, -1.0, 99999.0);
			g_esPukeSpecial[type].g_flPukeRangeChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRangeChance", "Puke Range Chance", "Puke_Range_Chance", "rangechance", g_esPukeSpecial[type].g_flPukeRangeChance, value, -1.0, 100.0);
			g_esPukeSpecial[type].g_iPukeRangeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRangeCooldown", "Puke Range Cooldown", "Puke_Range_Cooldown", "rangecooldown", g_esPukeSpecial[type].g_iPukeRangeCooldown, value, -1, 99999);
		}
		else
		{
			g_esPukeAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esPukeAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esPukeAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPukeAbility[type].g_iComboAbility, value, -1, 1);
			g_esPukeAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPukeAbility[type].g_iHumanAbility, value, -1, 2);
			g_esPukeAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPukeAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esPukeAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPukeAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esPukeAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esPukeAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esPukeAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPukeAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esPukeAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPukeAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esPukeAbility[type].g_iPukeAbility = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPukeAbility[type].g_iPukeAbility, value, -1, 1);
			g_esPukeAbility[type].g_iPukeEffect = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPukeAbility[type].g_iPukeEffect, value, -1, 7);
			g_esPukeAbility[type].g_iPukeMessage = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPukeAbility[type].g_iPukeMessage, value, -1, 3);
			g_esPukeAbility[type].g_iPukeSight = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esPukeAbility[type].g_iPukeSight, value, -1, 5);
			g_esPukeAbility[type].g_flPukeChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeChance", "Puke Chance", "Puke_Chance", "chance", g_esPukeAbility[type].g_flPukeChance, value, -1.0, 100.0);
			g_esPukeAbility[type].g_iPukeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeCooldown", "Puke Cooldown", "Puke_Cooldown", "cooldown", g_esPukeAbility[type].g_iPukeCooldown, value, -1, 99999);
			g_esPukeAbility[type].g_iPukeDeath = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeath", "Puke Death", "Puke_Death", "death", g_esPukeAbility[type].g_iPukeDeath, value, -1, 3);
			g_esPukeAbility[type].g_flPukeDeathChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeathChance", "Puke Death Chance", "Puke_Death_Chance", "deathchance", g_esPukeAbility[type].g_flPukeDeathChance, value, -1.0, 100.0);
			g_esPukeAbility[type].g_flPukeDeathRange = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeDeathRange", "Puke Death Range", "Puke_Death_Range", "deathrange", g_esPukeAbility[type].g_flPukeDeathRange, value, -1.0, 99999.0);
			g_esPukeAbility[type].g_iPukeHit = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeHit", "Puke Hit", "Puke_Hit", "hit", g_esPukeAbility[type].g_iPukeHit, value, -1, 1);
			g_esPukeAbility[type].g_iPukeHitMode = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeHitMode", "Puke Hit Mode", "Puke_Hit_Mode", "hitmode", g_esPukeAbility[type].g_iPukeHitMode, value, -1, 2);
			g_esPukeAbility[type].g_flPukeRange = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRange", "Puke Range", "Puke_Range", "range", g_esPukeAbility[type].g_flPukeRange, value, -1.0, 99999.0);
			g_esPukeAbility[type].g_flPukeRangeChance = flGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRangeChance", "Puke Range Chance", "Puke_Range_Chance", "rangechance", g_esPukeAbility[type].g_flPukeRangeChance, value, -1.0, 100.0);
			g_esPukeAbility[type].g_iPukeRangeCooldown = iGetKeyValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "PukeRangeCooldown", "Puke Range Cooldown", "Puke_Range_Cooldown", "rangecooldown", g_esPukeAbility[type].g_iPukeRangeCooldown, value, -1, 99999);
			g_esPukeAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esPukeAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_PUKE_SECTION, MT_PUKE_SECTION2, MT_PUKE_SECTION3, MT_PUKE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPukeSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esPukePlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esPukePlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esPukePlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esPukeCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_flCloseAreasOnly, g_esPukePlayer[tank].g_flCloseAreasOnly, g_esPukeSpecial[iType].g_flCloseAreasOnly, g_esPukeAbility[iType].g_flCloseAreasOnly, 1);
		g_esPukeCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iComboAbility, g_esPukePlayer[tank].g_iComboAbility, g_esPukeSpecial[iType].g_iComboAbility, g_esPukeAbility[iType].g_iComboAbility, 1);
		g_esPukeCache[tank].g_flPukeChance = flGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_flPukeChance, g_esPukePlayer[tank].g_flPukeChance, g_esPukeSpecial[iType].g_flPukeChance, g_esPukeAbility[iType].g_flPukeChance, 1);
		g_esPukeCache[tank].g_flPukeDeathChance = flGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_flPukeDeathChance, g_esPukePlayer[tank].g_flPukeDeathChance, g_esPukeSpecial[iType].g_flPukeDeathChance, g_esPukeAbility[iType].g_flPukeDeathChance, 1);
		g_esPukeCache[tank].g_flPukeDeathRange = flGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_flPukeDeathRange, g_esPukePlayer[tank].g_flPukeDeathRange, g_esPukeSpecial[iType].g_flPukeDeathRange, g_esPukeAbility[iType].g_flPukeDeathRange, 1);
		g_esPukeCache[tank].g_flPukeRange = flGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_flPukeRange, g_esPukePlayer[tank].g_flPukeRange, g_esPukeSpecial[iType].g_flPukeRange, g_esPukeAbility[iType].g_flPukeRange, 1);
		g_esPukeCache[tank].g_flPukeRangeChance = flGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_flPukeRangeChance, g_esPukePlayer[tank].g_flPukeRangeChance, g_esPukeSpecial[iType].g_flPukeRangeChance, g_esPukeAbility[iType].g_flPukeRangeChance, 1);
		g_esPukeCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iHumanAbility, g_esPukePlayer[tank].g_iHumanAbility, g_esPukeSpecial[iType].g_iHumanAbility, g_esPukeAbility[iType].g_iHumanAbility, 1);
		g_esPukeCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iHumanAmmo, g_esPukePlayer[tank].g_iHumanAmmo, g_esPukeSpecial[iType].g_iHumanAmmo, g_esPukeAbility[iType].g_iHumanAmmo, 1);
		g_esPukeCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iHumanCooldown, g_esPukePlayer[tank].g_iHumanCooldown, g_esPukeSpecial[iType].g_iHumanCooldown, g_esPukeAbility[iType].g_iHumanCooldown, 1);
		g_esPukeCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iHumanRangeCooldown, g_esPukePlayer[tank].g_iHumanRangeCooldown, g_esPukeSpecial[iType].g_iHumanRangeCooldown, g_esPukeAbility[iType].g_iHumanRangeCooldown, 1);
		g_esPukeCache[tank].g_iPukeAbility = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iPukeAbility, g_esPukePlayer[tank].g_iPukeAbility, g_esPukeSpecial[iType].g_iPukeAbility, g_esPukeAbility[iType].g_iPukeAbility, 1);
		g_esPukeCache[tank].g_iPukeCooldown = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iPukeCooldown, g_esPukePlayer[tank].g_iPukeCooldown, g_esPukeSpecial[iType].g_iPukeCooldown, g_esPukeAbility[iType].g_iPukeCooldown, 1);
		g_esPukeCache[tank].g_iPukeDeath = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iPukeDeath, g_esPukePlayer[tank].g_iPukeDeath, g_esPukeSpecial[iType].g_iPukeDeath, g_esPukeAbility[iType].g_iPukeDeath, 1);
		g_esPukeCache[tank].g_iPukeEffect = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iPukeEffect, g_esPukePlayer[tank].g_iPukeEffect, g_esPukeSpecial[iType].g_iPukeEffect, g_esPukeAbility[iType].g_iPukeEffect, 1);
		g_esPukeCache[tank].g_iPukeHit = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iPukeHit, g_esPukePlayer[tank].g_iPukeHit, g_esPukeSpecial[iType].g_iPukeHit, g_esPukeAbility[iType].g_iPukeHit, 1);
		g_esPukeCache[tank].g_iPukeHitMode = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iPukeHitMode, g_esPukePlayer[tank].g_iPukeHitMode, g_esPukeSpecial[iType].g_iPukeHitMode, g_esPukeAbility[iType].g_iPukeHitMode, 1);
		g_esPukeCache[tank].g_iPukeMessage = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iPukeMessage, g_esPukePlayer[tank].g_iPukeMessage, g_esPukeSpecial[iType].g_iPukeMessage, g_esPukeAbility[iType].g_iPukeMessage, 1);
		g_esPukeCache[tank].g_iPukeRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iPukeRangeCooldown, g_esPukePlayer[tank].g_iPukeRangeCooldown, g_esPukeSpecial[iType].g_iPukeRangeCooldown, g_esPukeAbility[iType].g_iPukeRangeCooldown, 1);
		g_esPukeCache[tank].g_iPukeSight = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iPukeSight, g_esPukePlayer[tank].g_iPukeSight, g_esPukeSpecial[iType].g_iPukeSight, g_esPukeAbility[iType].g_iPukeSight, 1);
		g_esPukeCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_flOpenAreasOnly, g_esPukePlayer[tank].g_flOpenAreasOnly, g_esPukeSpecial[iType].g_flOpenAreasOnly, g_esPukeAbility[iType].g_flOpenAreasOnly, 1);
		g_esPukeCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esPukeTeammate[tank].g_iRequiresHumans, g_esPukePlayer[tank].g_iRequiresHumans, g_esPukeSpecial[iType].g_iRequiresHumans, g_esPukeAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esPukeCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_flCloseAreasOnly, g_esPukeAbility[iType].g_flCloseAreasOnly, 1);
		g_esPukeCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iComboAbility, g_esPukeAbility[iType].g_iComboAbility, 1);
		g_esPukeCache[tank].g_flPukeChance = flGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_flPukeChance, g_esPukeAbility[iType].g_flPukeChance, 1);
		g_esPukeCache[tank].g_flPukeDeathChance = flGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_flPukeDeathChance, g_esPukeAbility[iType].g_flPukeDeathChance, 1);
		g_esPukeCache[tank].g_flPukeDeathRange = flGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_flPukeDeathRange, g_esPukeAbility[iType].g_flPukeDeathRange, 1);
		g_esPukeCache[tank].g_flPukeRange = flGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_flPukeRange, g_esPukeAbility[iType].g_flPukeRange, 1);
		g_esPukeCache[tank].g_flPukeRangeChance = flGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_flPukeRangeChance, g_esPukeAbility[iType].g_flPukeRangeChance, 1);
		g_esPukeCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iHumanAbility, g_esPukeAbility[iType].g_iHumanAbility, 1);
		g_esPukeCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iHumanAmmo, g_esPukeAbility[iType].g_iHumanAmmo, 1);
		g_esPukeCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iHumanCooldown, g_esPukeAbility[iType].g_iHumanCooldown, 1);
		g_esPukeCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iHumanRangeCooldown, g_esPukeAbility[iType].g_iHumanRangeCooldown, 1);
		g_esPukeCache[tank].g_iPukeAbility = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iPukeAbility, g_esPukeAbility[iType].g_iPukeAbility, 1);
		g_esPukeCache[tank].g_iPukeCooldown = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iPukeCooldown, g_esPukeAbility[iType].g_iPukeCooldown, 1);
		g_esPukeCache[tank].g_iPukeDeath = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iPukeDeath, g_esPukeAbility[iType].g_iPukeDeath, 1);
		g_esPukeCache[tank].g_iPukeEffect = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iPukeEffect, g_esPukeAbility[iType].g_iPukeEffect, 1);
		g_esPukeCache[tank].g_iPukeHit = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iPukeHit, g_esPukeAbility[iType].g_iPukeHit, 1);
		g_esPukeCache[tank].g_iPukeHitMode = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iPukeHitMode, g_esPukeAbility[iType].g_iPukeHitMode, 1);
		g_esPukeCache[tank].g_iPukeMessage = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iPukeMessage, g_esPukeAbility[iType].g_iPukeMessage, 1);
		g_esPukeCache[tank].g_iPukeRangeCooldown = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iPukeRangeCooldown, g_esPukeAbility[iType].g_iPukeRangeCooldown, 1);
		g_esPukeCache[tank].g_iPukeSight = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iPukeSight, g_esPukeAbility[iType].g_iPukeSight, 1);
		g_esPukeCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_flOpenAreasOnly, g_esPukeAbility[iType].g_flOpenAreasOnly, 1);
		g_esPukeCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPukePlayer[tank].g_iRequiresHumans, g_esPukeAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN2
void vPukeCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vPukeCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemovePuke(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vPukeEventFired(Event event, const char[] name)
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
			vPukeCopyStats2(iBot, iTank);
			vRemovePuke(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vPukeReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vPukeCopyStats2(iTank, iBot);
			vRemovePuke(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vPukeRange(iTank, 1, 1, GetRandomFloat(0.1, 100.0));
			vRemovePuke(iTank);
		}
	}
	else if (StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vPukeRange(iTank, 1, 2, GetRandomFloat(0.1, 100.0));
			vRemovePuke(iTank);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPukeAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPukeAbility[g_esPukePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[tank].g_iAccessFlags)) || g_esPukeCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esPukeCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esPukeCache[tank].g_iPukeAbility == 1 && g_esPukeCache[tank].g_iComboAbility == 0)
	{
		vPukeAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN2
void vPukeButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esPukeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esPukeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPukePlayer[tank].g_iTankType, tank) || (g_esPukeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPukeCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPukeAbility[g_esPukePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esPukeCache[tank].g_iPukeAbility == 1 && g_esPukeCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();

			switch (g_esPukePlayer[tank].g_iRangeCooldown == -1 || g_esPukePlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vPukeAbility(tank, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman3", (g_esPukePlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vPukeChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemovePuke(tank);
}

#if defined MT_ABILITIES_MAIN2
void vPukePostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	vPukeRange(tank, 1, 2, GetRandomFloat(0.1, 100.0));
}

void vPukeAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esPukeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esPukeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPukePlayer[tank].g_iTankType, tank) || (g_esPukeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPukeCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPukeAbility[g_esPukePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esPukePlayer[tank].g_iAmmoCount < g_esPukeCache[tank].g_iHumanAmmo && g_esPukeCache[tank].g_iHumanAmmo > 0))
	{
		g_esPukePlayer[tank].g_bFailed = false;
		g_esPukePlayer[tank].g_bNoAmmo = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		float flSurvivorPos[3],
			flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esPukeCache[tank].g_flPukeRange,
			flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esPukeCache[tank].g_flPukeRangeChance;
		int iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPukePlayer[tank].g_iTankType, g_esPukeAbility[g_esPukePlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esPukePlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esPukeCache[tank].g_iPukeSight, .range = flRange))
				{
					vPukeHit(iSurvivor, tank, random, flChance, g_esPukeCache[tank].g_iPukeAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPukeCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman4");
			}
		}
		else if (random <= flChance)
		{
			iCreateParticle(tank, PARTICLE_VOMIT, view_as<float>({0.0, 0.0, 70.0}), view_as<float>({-90.0, 0.0, 0.0}), 0.95, 1.0);
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPukeCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeAmmo");
	}
}

void vPukeHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esPukeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esPukeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPukePlayer[tank].g_iTankType, tank) || (g_esPukeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPukeCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPukeAbility[g_esPukePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPukePlayer[tank].g_iTankType, g_esPukeAbility[g_esPukePlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esPukePlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esPukePlayer[tank].g_iRangeCooldown != -1 && g_esPukePlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esPukePlayer[tank].g_iCooldown != -1 && g_esPukePlayer[tank].g_iCooldown >= iTime))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_GODMODE))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esPukePlayer[tank].g_iAmmoCount < g_esPukeCache[tank].g_iHumanAmmo && g_esPukeCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esPukeCache[tank].g_iPukeSight, .range = 100.0))
				{
					return;
				}

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esPukePlayer[tank].g_iRangeCooldown == -1 || g_esPukePlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPukeCache[tank].g_iHumanAbility == 1)
					{
						g_esPukePlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman", g_esPukePlayer[tank].g_iAmmoCount, g_esPukeCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esPukeCache[tank].g_iPukeRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPukeCache[tank].g_iHumanAbility == 1 && g_esPukePlayer[tank].g_iAmmoCount < g_esPukeCache[tank].g_iHumanAmmo && g_esPukeCache[tank].g_iHumanAmmo > 0) ? g_esPukeCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esPukePlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esPukePlayer[tank].g_iRangeCooldown != -1 && g_esPukePlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman5", (g_esPukePlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esPukePlayer[tank].g_iCooldown == -1 || g_esPukePlayer[tank].g_iCooldown <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esPukeCache[tank].g_iPukeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPukeCache[tank].g_iHumanAbility == 1) ? g_esPukeCache[tank].g_iHumanCooldown : iCooldown;
					g_esPukePlayer[tank].g_iCooldown = (iTime + iCooldown);
					if (g_esPukePlayer[tank].g_iCooldown != -1 && g_esPukePlayer[tank].g_iCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman5", (g_esPukePlayer[tank].g_iCooldown - iTime));
					}
				}

				if (flags & MT_ATTACK_RANGE)
				{
					DataPack dpPukeHit;
					CreateDataTimer(0.75, tTimerPukeHit, dpPukeHit, TIMER_FLAG_NO_MAPCHANGE);
					dpPukeHit.WriteCell(GetClientUserId(survivor));
					dpPukeHit.WriteCell(GetClientUserId(tank));
					dpPukeHit.WriteCell(flags);
				}
				else
				{
					MT_VomitPlayer(survivor, tank);
					vScreenEffect(survivor, tank, g_esPukeCache[tank].g_iPukeEffect, flags);
				}

				if (g_esPukeCache[tank].g_iPukeMessage & messages)
				{
					char sTankName[64];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Puke", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Puke", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPukePlayer[tank].g_iRangeCooldown == -1 || g_esPukePlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPukeCache[tank].g_iHumanAbility == 1 && !g_esPukePlayer[tank].g_bFailed)
				{
					g_esPukePlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeHuman2");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esPukeCache[tank].g_iHumanAbility == 1 && !g_esPukePlayer[tank].g_bNoAmmo)
		{
			g_esPukePlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "PukeAmmo");
		}
	}
}

void vPukeRange(int tank, int value, int bit, float random, int pos = -1)
{
	float flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 13, pos) : g_esPukeCache[tank].g_flPukeDeathChance;
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && (g_esPukeCache[tank].g_iPukeDeath & (1 << bit)) && random <= flChance)
	{
		if (g_esPukeCache[tank].g_iComboAbility == value || bIsAreaNarrow(tank, g_esPukeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esPukeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esPukePlayer[tank].g_iTankType, tank) || (g_esPukeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esPukeCache[tank].g_iRequiresHumans) || (bIsInfected(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esPukeAbility[g_esPukePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[tank].g_iAccessFlags)) || g_esPukeCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		vAttachParticle(tank, PARTICLE_BLOOD, 0.1);
		iCreateParticle(tank, PARTICLE_VOMIT, view_as<float>({0.0, 0.0, 70.0}), view_as<float>({-90.0, 0.0, 0.0}), 0.95, 1.0);

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 12, pos) : g_esPukeCache[tank].g_flPukeDeathRange;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPukePlayer[tank].g_iTankType, g_esPukeAbility[g_esPukePlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esPukePlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esPukeCache[tank].g_iPukeSight, .range = flRange))
				{
					DataPack dpPukeRange;
					CreateDataTimer(0.75, tTimerPukeRange, dpPukeRange, TIMER_FLAG_NO_MAPCHANGE);
					dpPukeRange.WriteCell(GetClientUserId(iSurvivor));
					dpPukeRange.WriteCell(GetClientUserId(tank));
				}
			}
		}
	}
}

void vPukeCopyStats2(int oldTank, int newTank)
{
	g_esPukePlayer[newTank].g_iAmmoCount = g_esPukePlayer[oldTank].g_iAmmoCount;
	g_esPukePlayer[newTank].g_iCooldown = g_esPukePlayer[oldTank].g_iCooldown;
	g_esPukePlayer[newTank].g_iRangeCooldown = g_esPukePlayer[oldTank].g_iRangeCooldown;
}

void vRemovePuke(int tank)
{
	g_esPukePlayer[tank].g_bFailed = false;
	g_esPukePlayer[tank].g_bNoAmmo = false;
	g_esPukePlayer[tank].g_iAmmoCount = 0;
	g_esPukePlayer[tank].g_iCooldown = -1;
	g_esPukePlayer[tank].g_iRangeCooldown = -1;
}

void vPukeReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemovePuke(iPlayer);
		}
	}
}

void tTimerPukeCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esPukeAbility[g_esPukePlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPukePlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esPukeCache[iTank].g_iPukeAbility == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vPukeAbility(iTank, flRandom, iPos);
}

void tTimerPukeCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esPukeAbility[g_esPukePlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPukePlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esPukeCache[iTank].g_iPukeHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esPukeCache[iTank].g_iPukeHitMode == 0 || g_esPukeCache[iTank].g_iPukeHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vPukeHit(iSurvivor, iTank, flRandom, flChance, g_esPukeCache[iTank].g_iPukeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esPukeCache[iTank].g_iPukeHitMode == 0 || g_esPukeCache[iTank].g_iPukeHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vPukeHit(iSurvivor, iTank, flRandom, flChance, g_esPukeCache[iTank].g_iPukeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}
}

void tTimerPukeHit(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esPukeAbility[g_esPukePlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esPukePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPukePlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esPukeCache[iTank].g_iPukeAbility == 0)
	{
		return;
	}

	int iFlags = pack.ReadCell();
	MT_VomitPlayer(iSurvivor, iTank);
	vScreenEffect(iSurvivor, iTank, g_esPukeCache[iTank].g_iPukeEffect, iFlags);
}

void tTimerPukeRange(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsValidClient(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		return;
	}

	MT_VomitPlayer(iSurvivor, iTank);
}