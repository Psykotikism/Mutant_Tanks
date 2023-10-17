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

#define MT_KAMIKAZE_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_KAMIKAZE_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Kamikaze Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank kills itself along with a survivor victim.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad, g_bSecondGame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Kamikaze Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}
#else
	#if MT_KAMIKAZE_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_GROWL2 "player/tank/voice/growl/tank_climb_01.wav" // Only available in L4D2
#define SOUND_GROWL1 "player/tank/voice/growl/hulk_growl_1.wav" // Only available in L4D1
#define SOUND_SMASH2 "player/charger/hit/charger_smash_02.wav" // Only available in L4D2
#define SOUND_SMASH1 "player/tank/hit/hulk_punch_1.wav"

#define MT_KAMIKAZE_SECTION "kamikazeability"
#define MT_KAMIKAZE_SECTION2 "kamikaze ability"
#define MT_KAMIKAZE_SECTION3 "kamikaze_ability"
#define MT_KAMIKAZE_SECTION4 "kamikaze"

#define MT_MENU_KAMIKAZE "Kamikaze Ability"

enum struct esKamikazePlayer
{
	bool g_bFailed;

	float g_flCloseAreasOnly;
	float g_flDamage;
	float g_flKamikazeChance;
	float g_flKamikazeMeter;
	float g_flKamikazeRange;
	float g_flKamikazeRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iKamikazeAbility;
	int g_iKamikazeBody;
	int g_iKamikazeEffect;
	int g_iKamikazeHit;
	int g_iKamikazeHitMode;
	int g_iKamikazeMessage;
	int g_iKamikazeMode;
	int g_iKamikazeSight;
	int g_iRequiresHumans;
	int g_iTankType;
}

esKamikazePlayer g_esKamikazePlayer[MAXPLAYERS + 1];

enum struct esKamikazeTeammate
{
	float g_flCloseAreasOnly;
	float g_flKamikazeChance;
	float g_flKamikazeMeter;
	float g_flKamikazeRange;
	float g_flKamikazeRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iKamikazeAbility;
	int g_iKamikazeBody;
	int g_iKamikazeEffect;
	int g_iKamikazeHit;
	int g_iKamikazeHitMode;
	int g_iKamikazeMessage;
	int g_iKamikazeMode;
	int g_iKamikazeSight;
	int g_iRequiresHumans;
}

esKamikazeTeammate g_esKamikazeTeammate[MAXPLAYERS + 1];

enum struct esKamikazeAbility
{
	float g_flCloseAreasOnly;
	float g_flKamikazeChance;
	float g_flKamikazeMeter;
	float g_flKamikazeRange;
	float g_flKamikazeRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iKamikazeAbility;
	int g_iKamikazeBody;
	int g_iKamikazeEffect;
	int g_iKamikazeHit;
	int g_iKamikazeHitMode;
	int g_iKamikazeMessage;
	int g_iKamikazeMode;
	int g_iKamikazeSight;
	int g_iRequiresHumans;
}

esKamikazeAbility g_esKamikazeAbility[MT_MAXTYPES + 1];

enum struct esKamikazeSpecial
{
	float g_flCloseAreasOnly;
	float g_flKamikazeChance;
	float g_flKamikazeMeter;
	float g_flKamikazeRange;
	float g_flKamikazeRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iKamikazeAbility;
	int g_iKamikazeBody;
	int g_iKamikazeEffect;
	int g_iKamikazeHit;
	int g_iKamikazeHitMode;
	int g_iKamikazeMessage;
	int g_iKamikazeMode;
	int g_iKamikazeSight;
	int g_iRequiresHumans;
}

esKamikazeSpecial g_esKamikazeSpecial[MT_MAXTYPES + 1];

enum struct esKamikazeCache
{
	float g_flCloseAreasOnly;
	float g_flKamikazeChance;
	float g_flKamikazeMeter;
	float g_flKamikazeRange;
	float g_flKamikazeRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iKamikazeAbility;
	int g_iKamikazeBody;
	int g_iKamikazeEffect;
	int g_iKamikazeHit;
	int g_iKamikazeHitMode;
	int g_iKamikazeMessage;
	int g_iKamikazeMode;
	int g_iKamikazeSight;
	int g_iRequiresHumans;
}

esKamikazeCache g_esKamikazeCache[MAXPLAYERS + 1];

int g_iKamikazeDeathModelOwner = 0;

#if !defined MT_ABILITIES_MAIN
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_kamikaze", cmdKamikazeInfo, "View information about the Kamikaze ability.");

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
void vKamikazeMapStart()
#else
public void OnMapStart()
#endif
{
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

	vKamikazeReset();
}

#if defined MT_ABILITIES_MAIN
void vKamikazeClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	g_esKamikazePlayer[client].g_bFailed = false;
	g_esKamikazePlayer[client].g_flDamage = 0.0;

	SDKHook(client, SDKHook_OnTakeDamage, OnKamikazeTakeDamage);
}

#if defined MT_ABILITIES_MAIN
void vKamikazeClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	g_esKamikazePlayer[client].g_bFailed = false;
	g_esKamikazePlayer[client].g_flDamage = 0.0;
}

#if defined MT_ABILITIES_MAIN
void vKamikazeMapEnd()
#else
public void OnMapEnd()
#endif
{
	vKamikazeReset();
}

#if !defined MT_ABILITIES_MAIN
Action cmdKamikazeInfo(int client, int args)
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
		case false: vKamikazeMenu(client, MT_KAMIKAZE_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vKamikazeMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_KAMIKAZE_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iKamikazeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Kamikaze Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iKamikazeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esKamikazeCache[param1].g_iKamikazeAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "KamikazeDetails");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esKamikazeCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vKamikazeMenu(param1, MT_KAMIKAZE_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pKamikaze = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "KamikazeMenu", param1);
			pKamikaze.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Buttons", param1);
					case 2: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Details", param1);
					case 3: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN
void vKamikazeDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_KAMIKAZE, MT_MENU_KAMIKAZE);
}

#if defined MT_ABILITIES_MAIN
void vKamikazeMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_KAMIKAZE, false))
	{
		vKamikazeMenu(client, MT_KAMIKAZE_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vKamikazeMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_KAMIKAZE, false))
	{
		FormatEx(buffer, size, "%T", "KamikazeMenu2", client);
	}
}

#if defined MT_ABILITIES_MAIN
void vKamikazeEntityCreated(int entity, const char[] classname)
#else
public void OnEntityCreated(int entity, const char[] classname)
#endif
{
	if (bIsValidEntity(entity) && StrEqual(classname, "survivor_death_model"))
	{
		int iOwner = GetClientOfUserId(g_iKamikazeDeathModelOwner);
		if (bIsValidClient(iOwner))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnKamikazeModelSpawnPost);
		}

		g_iKamikazeDeathModelOwner = 0;
	}
}

void OnKamikazeModelSpawnPost(int model)
{
	g_iKamikazeDeathModelOwner = 0;

	SDKUnhook(model, SDKHook_SpawnPost, OnKamikazeModelSpawnPost);

	if (!bIsValidEntity(model))
	{
		return;
	}

	RemoveEntity(model);
}

Action OnKamikazeTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esKamikazeAbility[g_esKamikazePlayer[attacker].g_iTankType].g_iAccessFlags, g_esKamikazePlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esKamikazePlayer[attacker].g_iTankType, g_esKamikazeAbility[g_esKamikazePlayer[attacker].g_iTankType].g_iImmunityFlags, g_esKamikazePlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (g_esKamikazeCache[attacker].g_flKamikazeMeter > 0.0 && g_esKamikazePlayer[attacker].g_flDamage < g_esKamikazeCache[attacker].g_flKamikazeMeter)
			{
				g_esKamikazePlayer[attacker].g_flDamage += damage;
			}

			if ((g_esKamikazeCache[attacker].g_iKamikazeHitMode == 0 || g_esKamikazeCache[attacker].g_iKamikazeHitMode == 1) && g_esKamikazeCache[attacker].g_iComboAbility == 0)
			{
				bool bCaught = bIsSurvivorCaught(victim);
				if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
				{
					vKamikazeHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esKamikazeCache[attacker].g_flKamikazeChance, g_esKamikazeCache[attacker].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
				}
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esKamikazeCache[victim].g_iKamikazeHitMode == 0 || g_esKamikazeCache[victim].g_iKamikazeHitMode == 2) && bIsSurvivor(attacker) && g_esKamikazeCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esKamikazeAbility[g_esKamikazePlayer[victim].g_iTankType].g_iAccessFlags, g_esKamikazePlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esKamikazePlayer[victim].g_iTankType, g_esKamikazeAbility[g_esKamikazePlayer[victim].g_iTankType].g_iImmunityFlags, g_esKamikazePlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vKamikazeHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esKamikazeCache[victim].g_flKamikazeChance, g_esKamikazeCache[victim].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vKamikazePluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_KAMIKAZE);
}

#if defined MT_ABILITIES_MAIN
void vKamikazeAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_KAMIKAZE_SECTION);
	list2.PushString(MT_KAMIKAZE_SECTION2);
	list3.PushString(MT_KAMIKAZE_SECTION3);
	list4.PushString(MT_KAMIKAZE_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vKamikazeCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esKamikazeCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_KAMIKAZE_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_KAMIKAZE_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_KAMIKAZE_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_KAMIKAZE_SECTION4);
	if (g_esKamikazeCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_KAMIKAZE_SECTION, false) || StrEqual(sSubset[iPos], MT_KAMIKAZE_SECTION2, false) || StrEqual(sSubset[iPos], MT_KAMIKAZE_SECTION3, false) || StrEqual(sSubset[iPos], MT_KAMIKAZE_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esKamikazeCache[tank].g_iKamikazeAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vKamikazeAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerKamikazeCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
								if ((g_esKamikazeCache[tank].g_iKamikazeHitMode == 0 || g_esKamikazeCache[tank].g_iKamikazeHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vKamikazeHit(survivor, tank, random, flChance, g_esKamikazeCache[tank].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esKamikazeCache[tank].g_iKamikazeHitMode == 0 || g_esKamikazeCache[tank].g_iKamikazeHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vKamikazeHit(survivor, tank, random, flChance, g_esKamikazeCache[tank].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerKamikazeCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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

#if defined MT_ABILITIES_MAIN
void vKamikazeConfigsLoad(int mode)
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
				g_esKamikazeAbility[iIndex].g_iAccessFlags = 0;
				g_esKamikazeAbility[iIndex].g_iImmunityFlags = 0;
				g_esKamikazeAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esKamikazeAbility[iIndex].g_iComboAbility = 0;
				g_esKamikazeAbility[iIndex].g_iHumanAbility = 0;
				g_esKamikazeAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esKamikazeAbility[iIndex].g_iRequiresHumans = 0;
				g_esKamikazeAbility[iIndex].g_iKamikazeAbility = 0;
				g_esKamikazeAbility[iIndex].g_iKamikazeEffect = 0;
				g_esKamikazeAbility[iIndex].g_iKamikazeMessage = 0;
				g_esKamikazeAbility[iIndex].g_iKamikazeBody = 1;
				g_esKamikazeAbility[iIndex].g_flKamikazeChance = 33.3;
				g_esKamikazeAbility[iIndex].g_iKamikazeHit = 0;
				g_esKamikazeAbility[iIndex].g_iKamikazeHitMode = 0;
				g_esKamikazeAbility[iIndex].g_flKamikazeMeter = 0.0;
				g_esKamikazeAbility[iIndex].g_iKamikazeMode = 1;
				g_esKamikazeAbility[iIndex].g_flKamikazeRange = 150.0;
				g_esKamikazeAbility[iIndex].g_flKamikazeRangeChance = 15.0;
				g_esKamikazeAbility[iIndex].g_iKamikazeSight = 0;

				g_esKamikazeSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esKamikazeSpecial[iIndex].g_iComboAbility = -1;
				g_esKamikazeSpecial[iIndex].g_iHumanAbility = -1;
				g_esKamikazeSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esKamikazeSpecial[iIndex].g_iRequiresHumans = -1;
				g_esKamikazeSpecial[iIndex].g_iKamikazeAbility = -1;
				g_esKamikazeSpecial[iIndex].g_iKamikazeEffect = -1;
				g_esKamikazeSpecial[iIndex].g_iKamikazeMessage = -1;
				g_esKamikazeSpecial[iIndex].g_iKamikazeBody = -1;
				g_esKamikazeSpecial[iIndex].g_flKamikazeChance = -1.0;
				g_esKamikazeSpecial[iIndex].g_iKamikazeHit = -1;
				g_esKamikazeSpecial[iIndex].g_iKamikazeHitMode = -1;
				g_esKamikazeSpecial[iIndex].g_flKamikazeMeter = -1.0;
				g_esKamikazeSpecial[iIndex].g_iKamikazeMode = -1;
				g_esKamikazeSpecial[iIndex].g_flKamikazeRange = -1.0;
				g_esKamikazeSpecial[iIndex].g_flKamikazeRangeChance = -1.0;
				g_esKamikazeSpecial[iIndex].g_iKamikazeSight = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esKamikazePlayer[iPlayer].g_iAccessFlags = -1;
				g_esKamikazePlayer[iPlayer].g_iImmunityFlags = -1;
				g_esKamikazePlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esKamikazePlayer[iPlayer].g_iComboAbility = -1;
				g_esKamikazePlayer[iPlayer].g_iHumanAbility = -1;
				g_esKamikazePlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esKamikazePlayer[iPlayer].g_iRequiresHumans = -1;
				g_esKamikazePlayer[iPlayer].g_iKamikazeAbility = -1;
				g_esKamikazePlayer[iPlayer].g_iKamikazeEffect = -1;
				g_esKamikazePlayer[iPlayer].g_iKamikazeMessage = -1;
				g_esKamikazePlayer[iPlayer].g_iKamikazeBody = -1;
				g_esKamikazePlayer[iPlayer].g_flKamikazeChance = -1.0;
				g_esKamikazePlayer[iPlayer].g_iKamikazeHit = -1;
				g_esKamikazePlayer[iPlayer].g_iKamikazeHitMode = -1;
				g_esKamikazePlayer[iPlayer].g_flKamikazeMeter = -1.0;
				g_esKamikazePlayer[iPlayer].g_iKamikazeMode = -1;
				g_esKamikazePlayer[iPlayer].g_flKamikazeRange = -1.0;
				g_esKamikazePlayer[iPlayer].g_flKamikazeRangeChance = -1.0;
				g_esKamikazePlayer[iPlayer].g_iKamikazeSight = -1;

				g_esKamikazeTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esKamikazeTeammate[iPlayer].g_iComboAbility = -1;
				g_esKamikazeTeammate[iPlayer].g_iHumanAbility = -1;
				g_esKamikazeTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esKamikazeTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esKamikazeTeammate[iPlayer].g_iKamikazeAbility = -1;
				g_esKamikazeTeammate[iPlayer].g_iKamikazeEffect = -1;
				g_esKamikazeTeammate[iPlayer].g_iKamikazeMessage = -1;
				g_esKamikazeTeammate[iPlayer].g_iKamikazeBody = -1;
				g_esKamikazeTeammate[iPlayer].g_flKamikazeChance = -1.0;
				g_esKamikazeTeammate[iPlayer].g_iKamikazeHit = -1;
				g_esKamikazeTeammate[iPlayer].g_iKamikazeHitMode = -1;
				g_esKamikazeTeammate[iPlayer].g_flKamikazeMeter = -1.0;
				g_esKamikazeTeammate[iPlayer].g_iKamikazeMode = -1;
				g_esKamikazeTeammate[iPlayer].g_flKamikazeRange = -1.0;
				g_esKamikazeTeammate[iPlayer].g_flKamikazeRangeChance = -1.0;
				g_esKamikazeTeammate[iPlayer].g_iKamikazeSight = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vKamikazeConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esKamikazeTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esKamikazeTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esKamikazeTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esKamikazeTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esKamikazeTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esKamikazeTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esKamikazeTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esKamikazeTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esKamikazeTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esKamikazeTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esKamikazeTeammate[admin].g_iKamikazeAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esKamikazeTeammate[admin].g_iKamikazeAbility, value, -1, 1);
			g_esKamikazeTeammate[admin].g_iKamikazeEffect = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esKamikazeTeammate[admin].g_iKamikazeEffect, value, -1, 7);
			g_esKamikazeTeammate[admin].g_iKamikazeMessage = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esKamikazeTeammate[admin].g_iKamikazeMessage, value, -1, 3);
			g_esKamikazeTeammate[admin].g_iKamikazeSight = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esKamikazeTeammate[admin].g_iKamikazeSight, value, -1, 2);
			g_esKamikazeTeammate[admin].g_iKamikazeBody = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeBody", "Kamikaze Body", "Kamikaze_Body", "body", g_esKamikazeTeammate[admin].g_iKamikazeBody, value, -1, 1);
			g_esKamikazeTeammate[admin].g_flKamikazeChance = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeChance", "Kamikaze Chance", "Kamikaze_Chance", "chance", g_esKamikazeTeammate[admin].g_flKamikazeChance, value, -1.0, 100.0);
			g_esKamikazeTeammate[admin].g_iKamikazeHit = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeHit", "Kamikaze Hit", "Kamikaze_Hit", "hit", g_esKamikazeTeammate[admin].g_iKamikazeHit, value, -1, 1);
			g_esKamikazeTeammate[admin].g_iKamikazeHitMode = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeHitMode", "Kamikaze Hit Mode", "Kamikaze_Hit_Mode", "hitmode", g_esKamikazeTeammate[admin].g_iKamikazeHitMode, value, -1, 2);
			g_esKamikazeTeammate[admin].g_flKamikazeMeter = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeMeter", "Kamikaze Meter", "Kamikaze_Meter", "meter", g_esKamikazeTeammate[admin].g_flKamikazeMeter, value, -1.0, 99999.0);
			g_esKamikazeTeammate[admin].g_iKamikazeMode = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeMode", "Kamikaze Mode", "Kamikaze_Mode", "mode", g_esKamikazeTeammate[admin].g_iKamikazeMode, value, -1, 3);
			g_esKamikazeTeammate[admin].g_flKamikazeRange = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeRange", "Kamikaze Range", "Kamikaze_Range", "range", g_esKamikazeTeammate[admin].g_flKamikazeRange, value, -1.0, 99999.0);
			g_esKamikazeTeammate[admin].g_flKamikazeRangeChance = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeRangeChance", "Kamikaze Range Chance", "Kamikaze_Range_Chance", "rangechance", g_esKamikazeTeammate[admin].g_flKamikazeRangeChance, value, -1.0, 100.0);
		}
		else
		{
			g_esKamikazePlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esKamikazePlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esKamikazePlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esKamikazePlayer[admin].g_iComboAbility, value, -1, 1);
			g_esKamikazePlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esKamikazePlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esKamikazePlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esKamikazePlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esKamikazePlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esKamikazePlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esKamikazePlayer[admin].g_iKamikazeAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esKamikazePlayer[admin].g_iKamikazeAbility, value, -1, 1);
			g_esKamikazePlayer[admin].g_iKamikazeEffect = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esKamikazePlayer[admin].g_iKamikazeEffect, value, -1, 7);
			g_esKamikazePlayer[admin].g_iKamikazeMessage = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esKamikazePlayer[admin].g_iKamikazeMessage, value, -1, 3);
			g_esKamikazePlayer[admin].g_iKamikazeSight = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esKamikazePlayer[admin].g_iKamikazeSight, value, -1, 2);
			g_esKamikazePlayer[admin].g_iKamikazeBody = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeBody", "Kamikaze Body", "Kamikaze_Body", "body", g_esKamikazePlayer[admin].g_iKamikazeBody, value, -1, 1);
			g_esKamikazePlayer[admin].g_flKamikazeChance = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeChance", "Kamikaze Chance", "Kamikaze_Chance", "chance", g_esKamikazePlayer[admin].g_flKamikazeChance, value, -1.0, 100.0);
			g_esKamikazePlayer[admin].g_iKamikazeHit = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeHit", "Kamikaze Hit", "Kamikaze_Hit", "hit", g_esKamikazePlayer[admin].g_iKamikazeHit, value, -1, 1);
			g_esKamikazePlayer[admin].g_iKamikazeHitMode = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeHitMode", "Kamikaze Hit Mode", "Kamikaze_Hit_Mode", "hitmode", g_esKamikazePlayer[admin].g_iKamikazeHitMode, value, -1, 2);
			g_esKamikazePlayer[admin].g_flKamikazeMeter = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeMeter", "Kamikaze Meter", "Kamikaze_Meter", "meter", g_esKamikazePlayer[admin].g_flKamikazeMeter, value, -1.0, 99999.0);
			g_esKamikazePlayer[admin].g_iKamikazeMode = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeMode", "Kamikaze Mode", "Kamikaze_Mode", "mode", g_esKamikazePlayer[admin].g_iKamikazeMode, value, -1, 3);
			g_esKamikazePlayer[admin].g_flKamikazeRange = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeRange", "Kamikaze Range", "Kamikaze_Range", "range", g_esKamikazePlayer[admin].g_flKamikazeRange, value, -1.0, 99999.0);
			g_esKamikazePlayer[admin].g_flKamikazeRangeChance = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeRangeChance", "Kamikaze Range Chance", "Kamikaze_Range_Chance", "rangechance", g_esKamikazePlayer[admin].g_flKamikazeRangeChance, value, -1.0, 100.0);
			g_esKamikazePlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esKamikazePlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esKamikazeSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esKamikazeSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esKamikazeSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esKamikazeSpecial[type].g_iComboAbility, value, -1, 1);
			g_esKamikazeSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esKamikazeSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esKamikazeSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esKamikazeSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esKamikazeSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esKamikazeSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esKamikazeSpecial[type].g_iKamikazeAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esKamikazeSpecial[type].g_iKamikazeAbility, value, -1, 1);
			g_esKamikazeSpecial[type].g_iKamikazeEffect = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esKamikazeSpecial[type].g_iKamikazeEffect, value, -1, 7);
			g_esKamikazeSpecial[type].g_iKamikazeMessage = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esKamikazeSpecial[type].g_iKamikazeMessage, value, -1, 3);
			g_esKamikazeSpecial[type].g_iKamikazeSight = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esKamikazeSpecial[type].g_iKamikazeSight, value, -1, 2);
			g_esKamikazeSpecial[type].g_iKamikazeBody = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeBody", "Kamikaze Body", "Kamikaze_Body", "body", g_esKamikazeSpecial[type].g_iKamikazeBody, value, -1, 1);
			g_esKamikazeSpecial[type].g_flKamikazeChance = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeChance", "Kamikaze Chance", "Kamikaze_Chance", "chance", g_esKamikazeSpecial[type].g_flKamikazeChance, value, -1.0, 100.0);
			g_esKamikazeSpecial[type].g_iKamikazeHit = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeHit", "Kamikaze Hit", "Kamikaze_Hit", "hit", g_esKamikazeSpecial[type].g_iKamikazeHit, value, -1, 1);
			g_esKamikazeSpecial[type].g_iKamikazeHitMode = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeHitMode", "Kamikaze Hit Mode", "Kamikaze_Hit_Mode", "hitmode", g_esKamikazeSpecial[type].g_iKamikazeHitMode, value, -1, 2);
			g_esKamikazeSpecial[type].g_flKamikazeMeter = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeMeter", "Kamikaze Meter", "Kamikaze_Meter", "meter", g_esKamikazeSpecial[type].g_flKamikazeMeter, value, -1.0, 99999.0);
			g_esKamikazeSpecial[type].g_iKamikazeMode = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeMode", "Kamikaze Mode", "Kamikaze_Mode", "mode", g_esKamikazeSpecial[type].g_iKamikazeMode, value, -1, 3);
			g_esKamikazeSpecial[type].g_flKamikazeRange = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeRange", "Kamikaze Range", "Kamikaze_Range", "range", g_esKamikazeSpecial[type].g_flKamikazeRange, value, -1.0, 99999.0);
			g_esKamikazeSpecial[type].g_flKamikazeRangeChance = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeRangeChance", "Kamikaze Range Chance", "Kamikaze_Range_Chance", "rangechance", g_esKamikazeSpecial[type].g_flKamikazeRangeChance, value, -1.0, 100.0);
		}
		else
		{
			g_esKamikazeAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esKamikazeAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esKamikazeAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esKamikazeAbility[type].g_iComboAbility, value, -1, 1);
			g_esKamikazeAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esKamikazeAbility[type].g_iHumanAbility, value, -1, 2);
			g_esKamikazeAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esKamikazeAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esKamikazeAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esKamikazeAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esKamikazeAbility[type].g_iKamikazeAbility = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esKamikazeAbility[type].g_iKamikazeAbility, value, -1, 1);
			g_esKamikazeAbility[type].g_iKamikazeEffect = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esKamikazeAbility[type].g_iKamikazeEffect, value, -1, 7);
			g_esKamikazeAbility[type].g_iKamikazeMessage = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esKamikazeAbility[type].g_iKamikazeMessage, value, -1, 3);
			g_esKamikazeAbility[type].g_iKamikazeSight = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esKamikazeAbility[type].g_iKamikazeSight, value, -1, 2);
			g_esKamikazeAbility[type].g_iKamikazeBody = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeBody", "Kamikaze Body", "Kamikaze_Body", "body", g_esKamikazeAbility[type].g_iKamikazeBody, value, -1, 1);
			g_esKamikazeAbility[type].g_flKamikazeChance = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeChance", "Kamikaze Chance", "Kamikaze_Chance", "chance", g_esKamikazeAbility[type].g_flKamikazeChance, value, -1.0, 100.0);
			g_esKamikazeAbility[type].g_iKamikazeHit = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeHit", "Kamikaze Hit", "Kamikaze_Hit", "hit", g_esKamikazeAbility[type].g_iKamikazeHit, value, -1, 1);
			g_esKamikazeAbility[type].g_iKamikazeHitMode = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeHitMode", "Kamikaze Hit Mode", "Kamikaze_Hit_Mode", "hitmode", g_esKamikazeAbility[type].g_iKamikazeHitMode, value, -1, 2);
			g_esKamikazeAbility[type].g_flKamikazeMeter = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeMeter", "Kamikaze Meter", "Kamikaze_Meter", "meter", g_esKamikazeAbility[type].g_flKamikazeMeter, value, -1.0, 99999.0);
			g_esKamikazeAbility[type].g_iKamikazeMode = iGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeMode", "Kamikaze Mode", "Kamikaze_Mode", "mode", g_esKamikazeAbility[type].g_iKamikazeMode, value, -1, 3);
			g_esKamikazeAbility[type].g_flKamikazeRange = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeRange", "Kamikaze Range", "Kamikaze_Range", "range", g_esKamikazeAbility[type].g_flKamikazeRange, value, -1.0, 99999.0);
			g_esKamikazeAbility[type].g_flKamikazeRangeChance = flGetKeyValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "KamikazeRangeChance", "Kamikaze Range Chance", "Kamikaze_Range_Chance", "rangechance", g_esKamikazeAbility[type].g_flKamikazeRangeChance, value, -1.0, 100.0);
			g_esKamikazeAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esKamikazeAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_KAMIKAZE_SECTION, MT_KAMIKAZE_SECTION2, MT_KAMIKAZE_SECTION3, MT_KAMIKAZE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vKamikazeSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esKamikazePlayer[tank].g_iTankType = apply ? type : 0;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esKamikazeCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_flCloseAreasOnly, g_esKamikazePlayer[tank].g_flCloseAreasOnly, g_esKamikazeSpecial[type].g_flCloseAreasOnly, g_esKamikazeAbility[type].g_flCloseAreasOnly, 1);
		g_esKamikazeCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iComboAbility, g_esKamikazePlayer[tank].g_iComboAbility, g_esKamikazeSpecial[type].g_iComboAbility, g_esKamikazeAbility[type].g_iComboAbility, 1);
		g_esKamikazeCache[tank].g_flKamikazeChance = flGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_flKamikazeChance, g_esKamikazePlayer[tank].g_flKamikazeChance, g_esKamikazeSpecial[type].g_flKamikazeChance, g_esKamikazeAbility[type].g_flKamikazeChance, 1);
		g_esKamikazeCache[tank].g_flKamikazeMeter = flGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_flKamikazeMeter, g_esKamikazePlayer[tank].g_flKamikazeMeter, g_esKamikazeSpecial[type].g_flKamikazeMeter, g_esKamikazeAbility[type].g_flKamikazeMeter, 1);
		g_esKamikazeCache[tank].g_flKamikazeRange = flGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_flKamikazeRange, g_esKamikazePlayer[tank].g_flKamikazeRange, g_esKamikazeSpecial[type].g_flKamikazeRange, g_esKamikazeAbility[type].g_flKamikazeRange, 1);
		g_esKamikazeCache[tank].g_flKamikazeRangeChance = flGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_flKamikazeRangeChance, g_esKamikazePlayer[tank].g_flKamikazeRangeChance, g_esKamikazeSpecial[type].g_flKamikazeRangeChance, g_esKamikazeAbility[type].g_flKamikazeRangeChance, 1);
		g_esKamikazeCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iHumanAbility, g_esKamikazePlayer[tank].g_iHumanAbility, g_esKamikazeSpecial[type].g_iHumanAbility, g_esKamikazeAbility[type].g_iHumanAbility, 1);
		g_esKamikazeCache[tank].g_iKamikazeAbility = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iKamikazeAbility, g_esKamikazePlayer[tank].g_iKamikazeAbility, g_esKamikazeSpecial[type].g_iKamikazeAbility, g_esKamikazeAbility[type].g_iKamikazeAbility, 1);
		g_esKamikazeCache[tank].g_iKamikazeEffect = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iKamikazeEffect, g_esKamikazePlayer[tank].g_iKamikazeEffect, g_esKamikazeSpecial[type].g_iKamikazeEffect, g_esKamikazeAbility[type].g_iKamikazeEffect, 1);
		g_esKamikazeCache[tank].g_iKamikazeBody = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iKamikazeBody, g_esKamikazePlayer[tank].g_iKamikazeBody, g_esKamikazeSpecial[type].g_iKamikazeBody, g_esKamikazeAbility[type].g_iKamikazeBody, 1);
		g_esKamikazeCache[tank].g_iKamikazeHit = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iKamikazeHit, g_esKamikazePlayer[tank].g_iKamikazeHit, g_esKamikazeSpecial[type].g_iKamikazeHit, g_esKamikazeAbility[type].g_iKamikazeHit, 1);
		g_esKamikazeCache[tank].g_iKamikazeHitMode = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iKamikazeHitMode, g_esKamikazePlayer[tank].g_iKamikazeHitMode, g_esKamikazeSpecial[type].g_iKamikazeHitMode, g_esKamikazeAbility[type].g_iKamikazeHitMode, 1);
		g_esKamikazeCache[tank].g_iKamikazeMessage = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iKamikazeMessage, g_esKamikazePlayer[tank].g_iKamikazeMessage, g_esKamikazeSpecial[type].g_iKamikazeMessage, g_esKamikazeAbility[type].g_iKamikazeMessage, 1);
		g_esKamikazeCache[tank].g_iKamikazeMode = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iKamikazeMode, g_esKamikazePlayer[tank].g_iKamikazeMode, g_esKamikazeSpecial[type].g_iKamikazeMode, g_esKamikazeAbility[type].g_iKamikazeMode, 1);
		g_esKamikazeCache[tank].g_iKamikazeSight = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iKamikazeSight, g_esKamikazePlayer[tank].g_iKamikazeSight, g_esKamikazeSpecial[type].g_iKamikazeSight, g_esKamikazeAbility[type].g_iKamikazeSight, 1);
		g_esKamikazeCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_flOpenAreasOnly, g_esKamikazePlayer[tank].g_flOpenAreasOnly, g_esKamikazeSpecial[type].g_flOpenAreasOnly, g_esKamikazeAbility[type].g_flOpenAreasOnly, 1);
		g_esKamikazeCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esKamikazeTeammate[tank].g_iRequiresHumans, g_esKamikazePlayer[tank].g_iRequiresHumans, g_esKamikazeSpecial[type].g_iRequiresHumans, g_esKamikazeAbility[type].g_iRequiresHumans, 1);
	}
	else
	{
		g_esKamikazeCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_flCloseAreasOnly, g_esKamikazeAbility[type].g_flCloseAreasOnly, 1);
		g_esKamikazeCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iComboAbility, g_esKamikazeAbility[type].g_iComboAbility, 1);
		g_esKamikazeCache[tank].g_flKamikazeChance = flGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_flKamikazeChance, g_esKamikazeAbility[type].g_flKamikazeChance, 1);
		g_esKamikazeCache[tank].g_flKamikazeMeter = flGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_flKamikazeMeter, g_esKamikazeAbility[type].g_flKamikazeMeter, 1);
		g_esKamikazeCache[tank].g_flKamikazeRange = flGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_flKamikazeRange, g_esKamikazeAbility[type].g_flKamikazeRange, 1);
		g_esKamikazeCache[tank].g_flKamikazeRangeChance = flGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_flKamikazeRangeChance, g_esKamikazeAbility[type].g_flKamikazeRangeChance, 1);
		g_esKamikazeCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iHumanAbility, g_esKamikazeAbility[type].g_iHumanAbility, 1);
		g_esKamikazeCache[tank].g_iKamikazeAbility = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iKamikazeAbility, g_esKamikazeAbility[type].g_iKamikazeAbility, 1);
		g_esKamikazeCache[tank].g_iKamikazeEffect = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iKamikazeEffect, g_esKamikazeAbility[type].g_iKamikazeEffect, 1);
		g_esKamikazeCache[tank].g_iKamikazeBody = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iKamikazeBody, g_esKamikazeAbility[type].g_iKamikazeBody, 1);
		g_esKamikazeCache[tank].g_iKamikazeHit = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iKamikazeHit, g_esKamikazeAbility[type].g_iKamikazeHit, 1);
		g_esKamikazeCache[tank].g_iKamikazeHitMode = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iKamikazeHitMode, g_esKamikazeAbility[type].g_iKamikazeHitMode, 1);
		g_esKamikazeCache[tank].g_iKamikazeMessage = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iKamikazeMessage, g_esKamikazeAbility[type].g_iKamikazeMessage, 1);
		g_esKamikazeCache[tank].g_iKamikazeMode = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iKamikazeMode, g_esKamikazeAbility[type].g_iKamikazeMode, 1);
		g_esKamikazeCache[tank].g_iKamikazeSight = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iKamikazeSight, g_esKamikazeAbility[type].g_iKamikazeSight, 1);
		g_esKamikazeCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_flOpenAreasOnly, g_esKamikazeAbility[type].g_flOpenAreasOnly, 1);
		g_esKamikazeCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esKamikazePlayer[tank].g_iRequiresHumans, g_esKamikazeAbility[type].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN
void vKamikazeCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	g_esKamikazePlayer[newTank].g_flDamage = g_esKamikazePlayer[oldTank].g_flDamage;

	if (oldTank != newTank)
	{
		g_esKamikazePlayer[oldTank].g_bFailed = false;
		g_esKamikazePlayer[oldTank].g_flDamage = 0.0;
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vKamikazeEventFired(Event event, const char[] name)
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
			g_esKamikazePlayer[iBot].g_bFailed = false;
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vKamikazeReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			g_esKamikazePlayer[iTank].g_bFailed = false;
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			g_esKamikazePlayer[iTank].g_bFailed = false;
			g_esKamikazePlayer[iTank].g_flDamage = 0.0;
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vKamikazeHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esKamikazeCache[iBoomer].g_flKamikazeChance, g_esKamikazeCache[iBoomer].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vKamikazePlayerEventKilled(int victim, int attacker)
#else
public void MT_OnPlayerEventKilled(int victim, int attacker)
#endif
{
	if (bIsSurvivor(victim, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsTankSupported(attacker, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(attacker) && g_esKamikazeCache[attacker].g_iKamikazeAbility == 1 && g_esKamikazeCache[attacker].g_iKamikazeBody == 1)
	{
		g_iKamikazeDeathModelOwner = GetClientUserId(victim);
	}
}

#if defined MT_ABILITIES_MAIN
void vKamikazeAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esKamikazeAbility[g_esKamikazePlayer[tank].g_iTankType].g_iAccessFlags, g_esKamikazePlayer[tank].g_iAccessFlags)) || g_esKamikazeCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esKamikazeCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esKamikazeCache[tank].g_iKamikazeAbility == 1 && g_esKamikazeCache[tank].g_iComboAbility == 0)
	{
		vKamikazeAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN
void vKamikazeButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esKamikazeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esKamikazeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esKamikazePlayer[tank].g_iTankType, tank) || (g_esKamikazeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esKamikazeCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esKamikazeAbility[g_esKamikazePlayer[tank].g_iTankType].g_iAccessFlags, g_esKamikazePlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esKamikazeCache[tank].g_iKamikazeAbility == 1 && g_esKamikazeCache[tank].g_iHumanAbility == 1)
		{
			vKamikazeAbility(tank, GetRandomFloat(0.1, 100.0));
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vKamikazeChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	g_esKamikazePlayer[tank].g_bFailed = false;
	g_esKamikazePlayer[tank].g_flDamage = 0.0;
}

void vKamikazeAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esKamikazeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esKamikazeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esKamikazePlayer[tank].g_iTankType, tank) || (g_esKamikazeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esKamikazeCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esKamikazeAbility[g_esKamikazePlayer[tank].g_iTankType].g_iAccessFlags, g_esKamikazePlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	g_esKamikazePlayer[tank].g_bFailed = false;

	float flTankPos[3], flSurvivorPos[3];
	GetClientAbsOrigin(tank, flTankPos);
	float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esKamikazeCache[tank].g_flKamikazeRange,
		flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esKamikazeCache[tank].g_flKamikazeRangeChance;
	int iSurvivorCount = 0;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esKamikazePlayer[tank].g_iTankType, g_esKamikazeAbility[g_esKamikazePlayer[tank].g_iTankType].g_iImmunityFlags, g_esKamikazePlayer[iSurvivor].g_iImmunityFlags))
		{
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);
			if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esKamikazeCache[tank].g_iKamikazeSight, .range = flRange))
			{
				vKamikazeHit(iSurvivor, tank, random, flChance, g_esKamikazeCache[tank].g_iKamikazeAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

				iSurvivorCount++;
			}
		}
	}

	if (iSurvivorCount == 0)
	{
		if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esKamikazeCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "KamikazeHuman3");
		}
	}
}

void vKamikazeHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esKamikazeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esKamikazeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esKamikazePlayer[tank].g_iTankType, tank) || (g_esKamikazeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esKamikazeCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esKamikazeAbility[g_esKamikazePlayer[tank].g_iTankType].g_iAccessFlags, g_esKamikazePlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esKamikazePlayer[tank].g_iTankType, g_esKamikazeAbility[g_esKamikazePlayer[tank].g_iTankType].g_iImmunityFlags, g_esKamikazePlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_GODMODE))
	{
		if (random <= chance)
		{
			if (g_esKamikazeCache[tank].g_flKamikazeMeter <= 0.0 || (0.0 < g_esKamikazeCache[tank].g_flKamikazeMeter <= g_esKamikazePlayer[tank].g_flDamage))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esKamikazeCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE))
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "KamikazeHuman");
				}

				vAttachParticle(survivor, PARTICLE_BLOOD, 0.1);
				EmitSoundToAll((g_bSecondGame ? SOUND_SMASH2 : SOUND_SMASH1), survivor);

				switch (g_esKamikazeCache[tank].g_iKamikazeMode)
				{
					case 0, 3:
					{
						switch (MT_GetRandomInt(1, 2))
						{
							case 1: ForcePlayerSuicide(survivor);
							case 2: vDamagePlayer(survivor, tank, float(GetEntProp(survivor, Prop_Data, "m_iHealth")));
						}
					}
					case 1: ForcePlayerSuicide(survivor);
					case 2: vDamagePlayer(survivor, tank, float(GetEntProp(survivor, Prop_Data, "m_iHealth")));
				}

				vAttachParticle(tank, PARTICLE_BLOOD, 0.1);
				EmitSoundToAll((g_bSecondGame ? SOUND_GROWL2 : SOUND_GROWL1), tank);
				ForcePlayerSuicide(tank);
				vScreenEffect(survivor, tank, g_esKamikazeCache[tank].g_iKamikazeEffect, flags);

				if (g_esKamikazeCache[tank].g_iKamikazeMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Kamikaze", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Kamikaze", LANG_SERVER, sTankName, survivor);
				}
			}
		}
		else if ((flags & MT_ATTACK_RANGE))
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esKamikazeCache[tank].g_iHumanAbility == 1 && !g_esKamikazePlayer[tank].g_bFailed)
			{
				g_esKamikazePlayer[tank].g_bFailed = true;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "KamikazeHuman2");
			}
		}
	}
}

void vKamikazeReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			g_esKamikazePlayer[iPlayer].g_bFailed = false;
			g_esKamikazePlayer[iPlayer].g_flDamage = 0.0;
		}
	}
}

void tTimerKamikazeCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esKamikazeAbility[g_esKamikazePlayer[iTank].g_iTankType].g_iAccessFlags, g_esKamikazePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esKamikazePlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esKamikazeCache[iTank].g_iKamikazeAbility == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vKamikazeAbility(iTank, flRandom, iPos);
}

void tTimerKamikazeCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esKamikazeAbility[g_esKamikazePlayer[iTank].g_iTankType].g_iAccessFlags, g_esKamikazePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esKamikazePlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esKamikazeCache[iTank].g_iKamikazeHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esKamikazeCache[iTank].g_iKamikazeHitMode == 0 || g_esKamikazeCache[iTank].g_iKamikazeHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vKamikazeHit(iSurvivor, iTank, flRandom, flChance, g_esKamikazeCache[iTank].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esKamikazeCache[iTank].g_iKamikazeHitMode == 0 || g_esKamikazeCache[iTank].g_iKamikazeHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vKamikazeHit(iSurvivor, iTank, flRandom, flChance, g_esKamikazeCache[iTank].g_iKamikazeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}
}