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

#define MT_SHAKE_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_SHAKE_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Shake Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank shakes the survivors' screens.",
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
			strcopy(error, err_max, "\"[MT] Shake Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_SMASH1 "player/tank/hit/hulk_punch_1.wav"
#define SOUND_SMASH2 "player/charger/hit/charger_smash_02.wav" // Only available in L4D2
#else
	#if MT_SHAKE_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_SHAKE_SECTION "shakeability"
#define MT_SHAKE_SECTION2 "shake ability"
#define MT_SHAKE_SECTION3 "shake_ability"
#define MT_SHAKE_SECTION4 "shake"

#define MT_MENU_SHAKE "Shake Ability"

enum struct esShakePlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flShakeChance;
	float g_flShakeDeathChance;
	float g_flShakeDeathRange;
	float g_flShakeInterval;
	float g_flShakeRange;
	float g_flShakeRangeChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iShakeAbility;
	int g_iShakeCooldown;
	int g_iShakeDeath;
	int g_iShakeDuration;
	int g_iShakeEffect;
	int g_iShakeHit;
	int g_iShakeHitMode;
	int g_iShakeMessage;
	int g_iShakeRangeCooldown;
	int g_iShakeSight;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esShakePlayer g_esShakePlayer[MAXPLAYERS + 1];

enum struct esShakeTeammate
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flShakeChance;
	float g_flShakeDeathChance;
	float g_flShakeDeathRange;
	float g_flShakeInterval;
	float g_flShakeRange;
	float g_flShakeRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
	int g_iShakeAbility;
	int g_iShakeCooldown;
	int g_iShakeDeath;
	int g_iShakeDuration;
	int g_iShakeEffect;
	int g_iShakeHit;
	int g_iShakeHitMode;
	int g_iShakeMessage;
	int g_iShakeRangeCooldown;
	int g_iShakeSight;
}

esShakeTeammate g_esShakeTeammate[MAXPLAYERS + 1];

enum struct esShakeAbility
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flShakeChance;
	float g_flShakeDeathChance;
	float g_flShakeDeathRange;
	float g_flShakeInterval;
	float g_flShakeRange;
	float g_flShakeRangeChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iShakeAbility;
	int g_iShakeCooldown;
	int g_iShakeDeath;
	int g_iShakeDuration;
	int g_iShakeEffect;
	int g_iShakeHit;
	int g_iShakeHitMode;
	int g_iShakeMessage;
	int g_iShakeRangeCooldown;
	int g_iShakeSight;
}

esShakeAbility g_esShakeAbility[MT_MAXTYPES + 1];

enum struct esShakeSpecial
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flShakeChance;
	float g_flShakeDeathChance;
	float g_flShakeDeathRange;
	float g_flShakeInterval;
	float g_flShakeRange;
	float g_flShakeRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
	int g_iShakeAbility;
	int g_iShakeCooldown;
	int g_iShakeDeath;
	int g_iShakeDuration;
	int g_iShakeEffect;
	int g_iShakeHit;
	int g_iShakeHitMode;
	int g_iShakeMessage;
	int g_iShakeRangeCooldown;
	int g_iShakeSight;
}

esShakeSpecial g_esShakeSpecial[MT_MAXTYPES + 1];

enum struct esShakeCache
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flShakeChance;
	float g_flShakeDeathChance;
	float g_flShakeDeathRange;
	float g_flShakeInterval;
	float g_flShakeRange;
	float g_flShakeRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
	int g_iShakeAbility;
	int g_iShakeCooldown;
	int g_iShakeDeath;
	int g_iShakeDuration;
	int g_iShakeEffect;
	int g_iShakeHit;
	int g_iShakeHitMode;
	int g_iShakeMessage;
	int g_iShakeRangeCooldown;
	int g_iShakeSight;
}

esShakeCache g_esShakeCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_shake", cmdShakeInfo, "View information about the Shake ability.");

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
void vShakeMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheSound((g_bSecondGame ? SOUND_SMASH2 : SOUND_SMASH1), true);

	vShakeReset();
}

#if defined MT_ABILITIES_MAIN2
void vShakeClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnShakeTakeDamage);
	vShakeReset3(client);
}

#if defined MT_ABILITIES_MAIN2
void vShakeClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vShakeReset3(client);
}

#if defined MT_ABILITIES_MAIN2
void vShakeMapEnd()
#else
public void OnMapEnd()
#endif
{
	vShakeReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdShakeInfo(int client, int args)
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
		case false: vShakeMenu(client, MT_SHAKE_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vShakeMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_SHAKE_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iShakeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Shake Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iShakeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esShakeCache[param1].g_iShakeAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esShakeCache[param1].g_iHumanAmmo - g_esShakePlayer[param1].g_iAmmoCount), g_esShakeCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esShakeCache[param1].g_iHumanAbility == 1) ? g_esShakeCache[param1].g_iHumanCooldown : g_esShakeCache[param1].g_iShakeCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ShakeDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esShakeCache[param1].g_iShakeDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esShakeCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esShakeCache[param1].g_iHumanAbility == 1) ? g_esShakeCache[param1].g_iHumanRangeCooldown : g_esShakeCache[param1].g_iShakeRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vShakeMenu(param1, MT_SHAKE_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pShake = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "ShakeMenu", param1);
			pShake.SetTitle(sMenuTitle);
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
					case 5: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Duration", param1);
					case 6: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
					case 7: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "RangeCooldown", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN2
void vShakeDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_SHAKE, MT_MENU_SHAKE);
}

#if defined MT_ABILITIES_MAIN2
void vShakeMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_SHAKE, false))
	{
		vShakeMenu(client, MT_SHAKE_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vShakeMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_SHAKE, false))
	{
		FormatEx(buffer, size, "%T", "ShakeMenu2", client);
	}
}

Action OnShakeTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esShakeCache[attacker].g_iShakeHitMode == 0 || g_esShakeCache[attacker].g_iShakeHitMode == 1) && bIsHumanSurvivor(victim) && g_esShakeCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esShakeAbility[g_esShakePlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esShakePlayer[attacker].g_iTankType, g_esShakeAbility[g_esShakePlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esShakePlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vShakeHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esShakeCache[attacker].g_flShakeChance, g_esShakeCache[attacker].g_iShakeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esShakeCache[victim].g_iShakeHitMode == 0 || g_esShakeCache[victim].g_iShakeHitMode == 2) && bIsHumanSurvivor(attacker) && g_esShakeCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esShakeAbility[g_esShakePlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esShakePlayer[victim].g_iTankType, g_esShakeAbility[g_esShakePlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esShakePlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vShakeHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esShakeCache[victim].g_flShakeChance, g_esShakeCache[victim].g_iShakeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vShakePluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_SHAKE);
}

#if defined MT_ABILITIES_MAIN2
void vShakeAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_SHAKE_SECTION);
	list2.PushString(MT_SHAKE_SECTION2);
	list3.PushString(MT_SHAKE_SECTION3);
	list4.PushString(MT_SHAKE_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vShakeCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esShakeCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_SHAKE_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_SHAKE_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_SHAKE_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_SHAKE_SECTION4);
	if (g_esShakeCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_SHAKE_SECTION, false) || StrEqual(sSubset[iPos], MT_SHAKE_SECTION2, false) || StrEqual(sSubset[iPos], MT_SHAKE_SECTION3, false) || StrEqual(sSubset[iPos], MT_SHAKE_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esShakeCache[tank].g_iShakeAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vShakeAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerShakeCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
								if ((g_esShakeCache[tank].g_iShakeHitMode == 0 || g_esShakeCache[tank].g_iShakeHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vShakeHit(survivor, tank, random, flChance, g_esShakeCache[tank].g_iShakeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esShakeCache[tank].g_iShakeHitMode == 0 || g_esShakeCache[tank].g_iShakeHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vShakeHit(survivor, tank, random, flChance, g_esShakeCache[tank].g_iShakeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerShakeCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteCell(iPos);
								dpCombo.WriteString(classname);
							}
						}
					}
					case MT_COMBO_POSTSPAWN: vShakeRange(tank, 0, 1, random, iPos);
					case MT_COMBO_UPONDEATH: vShakeRange(tank, 0, 0, random, iPos);
				}

				break;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vShakeConfigsLoad(int mode)
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
				g_esShakeAbility[iIndex].g_iAccessFlags = 0;
				g_esShakeAbility[iIndex].g_iImmunityFlags = 0;
				g_esShakeAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esShakeAbility[iIndex].g_iComboAbility = 0;
				g_esShakeAbility[iIndex].g_iHumanAbility = 0;
				g_esShakeAbility[iIndex].g_iHumanAmmo = 5;
				g_esShakeAbility[iIndex].g_iHumanCooldown = 0;
				g_esShakeAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esShakeAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esShakeAbility[iIndex].g_iRequiresHumans = 1;
				g_esShakeAbility[iIndex].g_iShakeAbility = 0;
				g_esShakeAbility[iIndex].g_iShakeEffect = 0;
				g_esShakeAbility[iIndex].g_iShakeMessage = 0;
				g_esShakeAbility[iIndex].g_flShakeChance = 33.3;
				g_esShakeAbility[iIndex].g_iShakeCooldown = 0;
				g_esShakeAbility[iIndex].g_iShakeDeath = 0;
				g_esShakeAbility[iIndex].g_flShakeDeathChance = 33.3;
				g_esShakeAbility[iIndex].g_flShakeDeathRange = 200.0;
				g_esShakeAbility[iIndex].g_iShakeDuration = 5;
				g_esShakeAbility[iIndex].g_iShakeHit = 0;
				g_esShakeAbility[iIndex].g_iShakeHitMode = 0;
				g_esShakeAbility[iIndex].g_flShakeInterval = 1.0;
				g_esShakeAbility[iIndex].g_flShakeRange = 150.0;
				g_esShakeAbility[iIndex].g_flShakeRangeChance = 15.0;
				g_esShakeAbility[iIndex].g_iShakeRangeCooldown = 0;
				g_esShakeAbility[iIndex].g_iShakeSight = 0;

				g_esShakeSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esShakeSpecial[iIndex].g_iComboAbility = -1;
				g_esShakeSpecial[iIndex].g_iHumanAbility = -1;
				g_esShakeSpecial[iIndex].g_iHumanAmmo = -1;
				g_esShakeSpecial[iIndex].g_iHumanCooldown = -1;
				g_esShakeSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esShakeSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esShakeSpecial[iIndex].g_iRequiresHumans = -1;
				g_esShakeSpecial[iIndex].g_iShakeAbility = -1;
				g_esShakeSpecial[iIndex].g_iShakeEffect = -1;
				g_esShakeSpecial[iIndex].g_iShakeMessage = -1;
				g_esShakeSpecial[iIndex].g_flShakeChance = -1.0;
				g_esShakeSpecial[iIndex].g_iShakeCooldown = -1;
				g_esShakeSpecial[iIndex].g_iShakeDeath = -1;
				g_esShakeSpecial[iIndex].g_flShakeDeathChance = -1.0;
				g_esShakeSpecial[iIndex].g_flShakeDeathRange = -1.0;
				g_esShakeSpecial[iIndex].g_iShakeDuration = -1;
				g_esShakeSpecial[iIndex].g_iShakeHit = -1;
				g_esShakeSpecial[iIndex].g_iShakeHitMode = -1;
				g_esShakeSpecial[iIndex].g_flShakeInterval = -1.0;
				g_esShakeSpecial[iIndex].g_flShakeRange = -1.0;
				g_esShakeSpecial[iIndex].g_flShakeRangeChance = -1.0;
				g_esShakeSpecial[iIndex].g_iShakeRangeCooldown = -1;
				g_esShakeSpecial[iIndex].g_iShakeSight = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esShakePlayer[iPlayer].g_iAccessFlags = -1;
				g_esShakePlayer[iPlayer].g_iImmunityFlags = -1;
				g_esShakePlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esShakePlayer[iPlayer].g_iComboAbility = -1;
				g_esShakePlayer[iPlayer].g_iHumanAbility = -1;
				g_esShakePlayer[iPlayer].g_iHumanAmmo = -1;
				g_esShakePlayer[iPlayer].g_iHumanCooldown = -1;
				g_esShakePlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esShakePlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esShakePlayer[iPlayer].g_iRequiresHumans = -1;
				g_esShakePlayer[iPlayer].g_iShakeAbility = -1;
				g_esShakePlayer[iPlayer].g_iShakeEffect = -1;
				g_esShakePlayer[iPlayer].g_iShakeMessage = -1;
				g_esShakePlayer[iPlayer].g_flShakeChance = -1.0;
				g_esShakePlayer[iPlayer].g_iShakeCooldown = -1;
				g_esShakePlayer[iPlayer].g_iShakeDeath = -1;
				g_esShakePlayer[iPlayer].g_flShakeDeathChance = -1.0;
				g_esShakePlayer[iPlayer].g_flShakeDeathRange = -1.0;
				g_esShakePlayer[iPlayer].g_iShakeDuration = -1;
				g_esShakePlayer[iPlayer].g_iShakeHit = -1;
				g_esShakePlayer[iPlayer].g_iShakeHitMode = -1;
				g_esShakePlayer[iPlayer].g_flShakeInterval = -1.0;
				g_esShakePlayer[iPlayer].g_flShakeRange = -1.0;
				g_esShakePlayer[iPlayer].g_flShakeRangeChance = -1.0;
				g_esShakePlayer[iPlayer].g_iShakeRangeCooldown = -1;
				g_esShakePlayer[iPlayer].g_iShakeSight = -1;

				g_esShakeTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esShakeTeammate[iPlayer].g_iComboAbility = -1;
				g_esShakeTeammate[iPlayer].g_iHumanAbility = -1;
				g_esShakeTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esShakeTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esShakeTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esShakeTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esShakeTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esShakeTeammate[iPlayer].g_iShakeAbility = -1;
				g_esShakeTeammate[iPlayer].g_iShakeEffect = -1;
				g_esShakeTeammate[iPlayer].g_iShakeMessage = -1;
				g_esShakeTeammate[iPlayer].g_flShakeChance = -1.0;
				g_esShakeTeammate[iPlayer].g_iShakeCooldown = -1;
				g_esShakeTeammate[iPlayer].g_iShakeDeath = -1;
				g_esShakeTeammate[iPlayer].g_flShakeDeathChance = -1.0;
				g_esShakeTeammate[iPlayer].g_flShakeDeathRange = -1.0;
				g_esShakeTeammate[iPlayer].g_iShakeDuration = -1;
				g_esShakeTeammate[iPlayer].g_iShakeHit = -1;
				g_esShakeTeammate[iPlayer].g_iShakeHitMode = -1;
				g_esShakeTeammate[iPlayer].g_flShakeInterval = -1.0;
				g_esShakeTeammate[iPlayer].g_flShakeRange = -1.0;
				g_esShakeTeammate[iPlayer].g_flShakeRangeChance = -1.0;
				g_esShakeTeammate[iPlayer].g_iShakeRangeCooldown = -1;
				g_esShakeTeammate[iPlayer].g_iShakeSight = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vShakeConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esShakeTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esShakeTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esShakeTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esShakeTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esShakeTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esShakeTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esShakeTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esShakeTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esShakeTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esShakeTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esShakeTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esShakeTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esShakeTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esShakeTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esShakeTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esShakeTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esShakeTeammate[admin].g_iShakeAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esShakeTeammate[admin].g_iShakeAbility, value, -1, 1);
			g_esShakeTeammate[admin].g_iShakeEffect = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esShakeTeammate[admin].g_iShakeEffect, value, -1, 7);
			g_esShakeTeammate[admin].g_iShakeMessage = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esShakeTeammate[admin].g_iShakeMessage, value, -1, 3);
			g_esShakeTeammate[admin].g_iShakeSight = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esShakeTeammate[admin].g_iShakeSight, value, -1, 5);
			g_esShakeTeammate[admin].g_flShakeChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeChance", "Shake Chance", "Shake_Chance", "chance", g_esShakeTeammate[admin].g_flShakeChance, value, -1.0, 100.0);
			g_esShakeTeammate[admin].g_iShakeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeCooldown", "Shake Cooldown", "Shake_Cooldown", "cooldown", g_esShakeTeammate[admin].g_iShakeCooldown, value, -1, 99999);
			g_esShakeTeammate[admin].g_iShakeDeath = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeath", "Shake Death", "Shake_Death", "death", g_esShakeTeammate[admin].g_iShakeDeath, value, -1, 3);
			g_esShakeTeammate[admin].g_flShakeDeathChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeathChance", "Shake Death Chance", "Shake_Death_Chance", "deathchance", g_esShakeTeammate[admin].g_flShakeDeathChance, value, -1.0, 100.0);
			g_esShakeTeammate[admin].g_flShakeDeathRange = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeathRange", "Shake Death Range", "Shake_Death_Range", "deathrange", g_esShakeTeammate[admin].g_flShakeDeathRange, value, -1.0, 99999.0);
			g_esShakeTeammate[admin].g_iShakeDuration = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDuration", "Shake Duration", "Shake_Duration", "duration", g_esShakeTeammate[admin].g_iShakeDuration, value, -1, 99999);
			g_esShakeTeammate[admin].g_iShakeHit = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeHit", "Shake Hit", "Shake_Hit", "hit", g_esShakeTeammate[admin].g_iShakeHit, value, -1, 1);
			g_esShakeTeammate[admin].g_iShakeHitMode = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeHitMode", "Shake Hit Mode", "Shake_Hit_Mode", "hitmode", g_esShakeTeammate[admin].g_iShakeHitMode, value, -1, 2);
			g_esShakeTeammate[admin].g_flShakeInterval = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeInterval", "Shake Interval", "Shake_Interval", "interval", g_esShakeTeammate[admin].g_flShakeInterval, value, -1.0, 99999.0);
			g_esShakeTeammate[admin].g_flShakeRange = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRange", "Shake Range", "Shake_Range", "range", g_esShakeTeammate[admin].g_flShakeRange, value, -1.0, 99999.0);
			g_esShakeTeammate[admin].g_flShakeRangeChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRangeChance", "Shake Range Chance", "Shake_Range_Chance", "rangechance", g_esShakeTeammate[admin].g_flShakeRangeChance, value, -1.0, 100.0);
			g_esShakeTeammate[admin].g_iShakeRangeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRangeCooldown", "Shake Range Cooldown", "Shake_Range_Cooldown", "rangecooldown", g_esShakeTeammate[admin].g_iShakeRangeCooldown, value, -1, 99999);
		}
		else
		{
			g_esShakePlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esShakePlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esShakePlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esShakePlayer[admin].g_iComboAbility, value, -1, 1);
			g_esShakePlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esShakePlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esShakePlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esShakePlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esShakePlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esShakePlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esShakePlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esShakePlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esShakePlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esShakePlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esShakePlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esShakePlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esShakePlayer[admin].g_iShakeAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esShakePlayer[admin].g_iShakeAbility, value, -1, 1);
			g_esShakePlayer[admin].g_iShakeEffect = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esShakePlayer[admin].g_iShakeEffect, value, -1, 7);
			g_esShakePlayer[admin].g_iShakeMessage = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esShakePlayer[admin].g_iShakeMessage, value, -1, 3);
			g_esShakePlayer[admin].g_iShakeSight = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esShakePlayer[admin].g_iShakeSight, value, -1, 5);
			g_esShakePlayer[admin].g_flShakeChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeChance", "Shake Chance", "Shake_Chance", "chance", g_esShakePlayer[admin].g_flShakeChance, value, -1.0, 100.0);
			g_esShakePlayer[admin].g_iShakeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeCooldown", "Shake Cooldown", "Shake_Cooldown", "cooldown", g_esShakePlayer[admin].g_iShakeCooldown, value, -1, 99999);
			g_esShakePlayer[admin].g_iShakeDeath = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeath", "Shake Death", "Shake_Death", "death", g_esShakePlayer[admin].g_iShakeDeath, value, -1, 3);
			g_esShakePlayer[admin].g_flShakeDeathChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeathChance", "Shake Death Chance", "Shake_Death_Chance", "deathchance", g_esShakePlayer[admin].g_flShakeDeathChance, value, -1.0, 100.0);
			g_esShakePlayer[admin].g_flShakeDeathRange = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeathRange", "Shake Death Range", "Shake_Death_Range", "deathrange", g_esShakePlayer[admin].g_flShakeDeathRange, value, -1.0, 99999.0);
			g_esShakePlayer[admin].g_iShakeDuration = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDuration", "Shake Duration", "Shake_Duration", "duration", g_esShakePlayer[admin].g_iShakeDuration, value, -1, 99999);
			g_esShakePlayer[admin].g_iShakeHit = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeHit", "Shake Hit", "Shake_Hit", "hit", g_esShakePlayer[admin].g_iShakeHit, value, -1, 1);
			g_esShakePlayer[admin].g_iShakeHitMode = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeHitMode", "Shake Hit Mode", "Shake_Hit_Mode", "hitmode", g_esShakePlayer[admin].g_iShakeHitMode, value, -1, 2);
			g_esShakePlayer[admin].g_flShakeInterval = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeInterval", "Shake Interval", "Shake_Interval", "interval", g_esShakePlayer[admin].g_flShakeInterval, value, -1.0, 99999.0);
			g_esShakePlayer[admin].g_flShakeRange = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRange", "Shake Range", "Shake_Range", "range", g_esShakePlayer[admin].g_flShakeRange, value, -1.0, 99999.0);
			g_esShakePlayer[admin].g_flShakeRangeChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRangeChance", "Shake Range Chance", "Shake_Range_Chance", "rangechance", g_esShakePlayer[admin].g_flShakeRangeChance, value, -1.0, 100.0);
			g_esShakePlayer[admin].g_iShakeRangeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRangeCooldown", "Shake Range Cooldown", "Shake_Range_Cooldown", "rangecooldown", g_esShakePlayer[admin].g_iShakeRangeCooldown, value, -1, 99999);
			g_esShakePlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esShakePlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esShakeSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esShakeSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esShakeSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esShakeSpecial[type].g_iComboAbility, value, -1, 1);
			g_esShakeSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esShakeSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esShakeSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esShakeSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esShakeSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esShakeSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esShakeSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esShakeSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esShakeSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esShakeSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esShakeSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esShakeSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esShakeSpecial[type].g_iShakeAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esShakeSpecial[type].g_iShakeAbility, value, -1, 1);
			g_esShakeSpecial[type].g_iShakeEffect = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esShakeSpecial[type].g_iShakeEffect, value, -1, 7);
			g_esShakeSpecial[type].g_iShakeMessage = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esShakeSpecial[type].g_iShakeMessage, value, -1, 3);
			g_esShakeSpecial[type].g_iShakeSight = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esShakeSpecial[type].g_iShakeSight, value, -1, 5);
			g_esShakeSpecial[type].g_flShakeChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeChance", "Shake Chance", "Shake_Chance", "chance", g_esShakeSpecial[type].g_flShakeChance, value, -1.0, 100.0);
			g_esShakeSpecial[type].g_iShakeDeath = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeath", "Shake Death", "Shake_Death", "death", g_esShakeSpecial[type].g_iShakeDeath, value, -1, 3);
			g_esShakeSpecial[type].g_iShakeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeCooldown", "Shake Cooldown", "Shake_Cooldown", "cooldown", g_esShakeSpecial[type].g_iShakeCooldown, value, -1, 99999);
			g_esShakeSpecial[type].g_flShakeDeathChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeathChance", "Shake Death Chance", "Shake_Death_Chance", "deathchance", g_esShakeSpecial[type].g_flShakeDeathChance, value, -1.0, 100.0);
			g_esShakeSpecial[type].g_flShakeDeathRange = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeathRange", "Shake Death Range", "Shake_Death_Range", "deathrange", g_esShakeSpecial[type].g_flShakeDeathRange, value, -1.0, 99999.0);
			g_esShakeSpecial[type].g_iShakeDuration = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDuration", "Shake Duration", "Shake_Duration", "duration", g_esShakeSpecial[type].g_iShakeDuration, value, -1, 99999);
			g_esShakeSpecial[type].g_iShakeHit = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeHit", "Shake Hit", "Shake_Hit", "hit", g_esShakeSpecial[type].g_iShakeHit, value, -1, 1);
			g_esShakeSpecial[type].g_iShakeHitMode = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeHitMode", "Shake Hit Mode", "Shake_Hit_Mode", "hitmode", g_esShakeSpecial[type].g_iShakeHitMode, value, -1, 2);
			g_esShakeSpecial[type].g_flShakeInterval = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeInterval", "Shake Interval", "Shake_Interval", "interval", g_esShakeSpecial[type].g_flShakeInterval, value, -1.0, 99999.0);
			g_esShakeSpecial[type].g_flShakeRange = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRange", "Shake Range", "Shake_Range", "range", g_esShakeSpecial[type].g_flShakeRange, value, -1.0, 99999.0);
			g_esShakeSpecial[type].g_flShakeRangeChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRangeChance", "Shake Range Chance", "Shake_Range_Chance", "rangechance", g_esShakeSpecial[type].g_flShakeRangeChance, value, -1.0, 100.0);
			g_esShakeSpecial[type].g_iShakeRangeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRangeCooldown", "Shake Range Cooldown", "Shake_Range_Cooldown", "rangecooldown", g_esShakeSpecial[type].g_iShakeRangeCooldown, value, -1, 99999);
		}
		else
		{
			g_esShakeAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esShakeAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esShakeAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esShakeAbility[type].g_iComboAbility, value, -1, 1);
			g_esShakeAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esShakeAbility[type].g_iHumanAbility, value, -1, 2);
			g_esShakeAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esShakeAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esShakeAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esShakeAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esShakeAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esShakeAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esShakeAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esShakeAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esShakeAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esShakeAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esShakeAbility[type].g_iShakeAbility = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esShakeAbility[type].g_iShakeAbility, value, -1, 1);
			g_esShakeAbility[type].g_iShakeEffect = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esShakeAbility[type].g_iShakeEffect, value, -1, 7);
			g_esShakeAbility[type].g_iShakeMessage = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esShakeAbility[type].g_iShakeMessage, value, -1, 3);
			g_esShakeAbility[type].g_iShakeSight = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esShakeAbility[type].g_iShakeSight, value, -1, 5);
			g_esShakeAbility[type].g_flShakeChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeChance", "Shake Chance", "Shake_Chance", "chance", g_esShakeAbility[type].g_flShakeChance, value, -1.0, 100.0);
			g_esShakeAbility[type].g_iShakeDeath = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeath", "Shake Death", "Shake_Death", "death", g_esShakeAbility[type].g_iShakeDeath, value, -1, 3);
			g_esShakeAbility[type].g_iShakeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeCooldown", "Shake Cooldown", "Shake_Cooldown", "cooldown", g_esShakeAbility[type].g_iShakeCooldown, value, -1, 99999);
			g_esShakeAbility[type].g_flShakeDeathChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeathChance", "Shake Death Chance", "Shake_Death_Chance", "deathchance", g_esShakeAbility[type].g_flShakeDeathChance, value, -1.0, 100.0);
			g_esShakeAbility[type].g_flShakeDeathRange = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDeathRange", "Shake Death Range", "Shake_Death_Range", "deathrange", g_esShakeAbility[type].g_flShakeDeathRange, value, -1.0, 99999.0);
			g_esShakeAbility[type].g_iShakeDuration = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeDuration", "Shake Duration", "Shake_Duration", "duration", g_esShakeAbility[type].g_iShakeDuration, value, -1, 99999);
			g_esShakeAbility[type].g_iShakeHit = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeHit", "Shake Hit", "Shake_Hit", "hit", g_esShakeAbility[type].g_iShakeHit, value, -1, 1);
			g_esShakeAbility[type].g_iShakeHitMode = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeHitMode", "Shake Hit Mode", "Shake_Hit_Mode", "hitmode", g_esShakeAbility[type].g_iShakeHitMode, value, -1, 2);
			g_esShakeAbility[type].g_flShakeInterval = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeInterval", "Shake Interval", "Shake_Interval", "interval", g_esShakeAbility[type].g_flShakeInterval, value, -1.0, 99999.0);
			g_esShakeAbility[type].g_flShakeRange = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRange", "Shake Range", "Shake_Range", "range", g_esShakeAbility[type].g_flShakeRange, value, -1.0, 99999.0);
			g_esShakeAbility[type].g_flShakeRangeChance = flGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRangeChance", "Shake Range Chance", "Shake_Range_Chance", "rangechance", g_esShakeAbility[type].g_flShakeRangeChance, value, -1.0, 100.0);
			g_esShakeAbility[type].g_iShakeRangeCooldown = iGetKeyValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ShakeRangeCooldown", "Shake Range Cooldown", "Shake_Range_Cooldown", "rangecooldown", g_esShakeAbility[type].g_iShakeRangeCooldown, value, -1, 99999);
			g_esShakeAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esShakeAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_SHAKE_SECTION, MT_SHAKE_SECTION2, MT_SHAKE_SECTION3, MT_SHAKE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vShakeSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esShakePlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esShakePlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esShakePlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esShakeCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_flCloseAreasOnly, g_esShakePlayer[tank].g_flCloseAreasOnly, g_esShakeSpecial[iType].g_flCloseAreasOnly, g_esShakeAbility[iType].g_flCloseAreasOnly, 1);
		g_esShakeCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iComboAbility, g_esShakePlayer[tank].g_iComboAbility, g_esShakeSpecial[iType].g_iComboAbility, g_esShakeAbility[iType].g_iComboAbility, 1);
		g_esShakeCache[tank].g_flShakeChance = flGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_flShakeChance, g_esShakePlayer[tank].g_flShakeChance, g_esShakeSpecial[iType].g_flShakeChance, g_esShakeAbility[iType].g_flShakeChance, 1);
		g_esShakeCache[tank].g_flShakeDeathChance = flGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_flShakeDeathChance, g_esShakePlayer[tank].g_flShakeDeathChance, g_esShakeSpecial[iType].g_flShakeDeathChance, g_esShakeAbility[iType].g_flShakeDeathChance, 1);
		g_esShakeCache[tank].g_flShakeDeathRange = flGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_flShakeDeathRange, g_esShakePlayer[tank].g_flShakeDeathRange, g_esShakeSpecial[iType].g_flShakeDeathRange, g_esShakeAbility[iType].g_flShakeDeathRange, 1);
		g_esShakeCache[tank].g_flShakeInterval = flGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_flShakeInterval, g_esShakePlayer[tank].g_flShakeInterval, g_esShakeSpecial[iType].g_flShakeInterval, g_esShakeAbility[iType].g_flShakeInterval, 1);
		g_esShakeCache[tank].g_flShakeRange = flGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_flShakeRange, g_esShakePlayer[tank].g_flShakeRange, g_esShakeSpecial[iType].g_flShakeRange, g_esShakeAbility[iType].g_flShakeRange, 1);
		g_esShakeCache[tank].g_flShakeRangeChance = flGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_flShakeRangeChance, g_esShakePlayer[tank].g_flShakeRangeChance, g_esShakeSpecial[iType].g_flShakeRangeChance, g_esShakeAbility[iType].g_flShakeRangeChance, 1);
		g_esShakeCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iHumanAbility, g_esShakePlayer[tank].g_iHumanAbility, g_esShakeSpecial[iType].g_iHumanAbility, g_esShakeAbility[iType].g_iHumanAbility, 1);
		g_esShakeCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iHumanAmmo, g_esShakePlayer[tank].g_iHumanAmmo, g_esShakeSpecial[iType].g_iHumanAmmo, g_esShakeAbility[iType].g_iHumanAmmo, 1);
		g_esShakeCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iHumanCooldown, g_esShakePlayer[tank].g_iHumanCooldown, g_esShakeSpecial[iType].g_iHumanCooldown, g_esShakeAbility[iType].g_iHumanCooldown, 1);
		g_esShakeCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iHumanRangeCooldown, g_esShakePlayer[tank].g_iHumanRangeCooldown, g_esShakeSpecial[iType].g_iHumanRangeCooldown, g_esShakeAbility[iType].g_iHumanRangeCooldown, 1);
		g_esShakeCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_flOpenAreasOnly, g_esShakePlayer[tank].g_flOpenAreasOnly, g_esShakeSpecial[iType].g_flOpenAreasOnly, g_esShakeAbility[iType].g_flOpenAreasOnly, 1);
		g_esShakeCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iRequiresHumans, g_esShakePlayer[tank].g_iRequiresHumans, g_esShakeSpecial[iType].g_iRequiresHumans, g_esShakeAbility[iType].g_iRequiresHumans, 1);
		g_esShakeCache[tank].g_iShakeAbility = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeAbility, g_esShakePlayer[tank].g_iShakeAbility, g_esShakeSpecial[iType].g_iShakeAbility, g_esShakeAbility[iType].g_iShakeAbility, 1);
		g_esShakeCache[tank].g_iShakeCooldown = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeCooldown, g_esShakePlayer[tank].g_iShakeCooldown, g_esShakeSpecial[iType].g_iShakeCooldown, g_esShakeAbility[iType].g_iShakeCooldown, 1);
		g_esShakeCache[tank].g_iShakeDeath = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeDeath, g_esShakePlayer[tank].g_iShakeDeath, g_esShakeSpecial[iType].g_iShakeDeath, g_esShakeAbility[iType].g_iShakeDeath, 1);
		g_esShakeCache[tank].g_iShakeDuration = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeDuration, g_esShakePlayer[tank].g_iShakeDuration, g_esShakeSpecial[iType].g_iShakeDuration, g_esShakeAbility[iType].g_iShakeDuration, 1);
		g_esShakeCache[tank].g_iShakeEffect = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeEffect, g_esShakePlayer[tank].g_iShakeEffect, g_esShakeSpecial[iType].g_iShakeEffect, g_esShakeAbility[iType].g_iShakeEffect, 1);
		g_esShakeCache[tank].g_iShakeHit = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeHit, g_esShakePlayer[tank].g_iShakeHit, g_esShakeSpecial[iType].g_iShakeHit, g_esShakeAbility[iType].g_iShakeHit, 1);
		g_esShakeCache[tank].g_iShakeHitMode = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeHitMode, g_esShakePlayer[tank].g_iShakeHitMode, g_esShakeSpecial[iType].g_iShakeHitMode, g_esShakeAbility[iType].g_iShakeHitMode, 1);
		g_esShakeCache[tank].g_iShakeMessage = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeMessage, g_esShakePlayer[tank].g_iShakeMessage, g_esShakeSpecial[iType].g_iShakeMessage, g_esShakeAbility[iType].g_iShakeMessage, 1);
		g_esShakeCache[tank].g_iShakeRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeRangeCooldown, g_esShakePlayer[tank].g_iShakeRangeCooldown, g_esShakeSpecial[iType].g_iShakeRangeCooldown, g_esShakeAbility[iType].g_iShakeRangeCooldown, 1);
		g_esShakeCache[tank].g_iShakeSight = iGetSubSettingValue(apply, bHuman, g_esShakeTeammate[tank].g_iShakeSight, g_esShakePlayer[tank].g_iShakeSight, g_esShakeSpecial[iType].g_iShakeSight, g_esShakeAbility[iType].g_iShakeSight, 1);
	}
	else
	{
		g_esShakeCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_flCloseAreasOnly, g_esShakeAbility[iType].g_flCloseAreasOnly, 1);
		g_esShakeCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iComboAbility, g_esShakeAbility[iType].g_iComboAbility, 1);
		g_esShakeCache[tank].g_flShakeChance = flGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_flShakeChance, g_esShakeAbility[iType].g_flShakeChance, 1);
		g_esShakeCache[tank].g_flShakeDeathChance = flGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_flShakeDeathChance, g_esShakeAbility[iType].g_flShakeDeathChance, 1);
		g_esShakeCache[tank].g_flShakeDeathRange = flGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_flShakeDeathRange, g_esShakeAbility[iType].g_flShakeDeathRange, 1);
		g_esShakeCache[tank].g_flShakeInterval = flGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_flShakeInterval, g_esShakeAbility[iType].g_flShakeInterval, 1);
		g_esShakeCache[tank].g_flShakeRange = flGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_flShakeRange, g_esShakeAbility[iType].g_flShakeRange, 1);
		g_esShakeCache[tank].g_flShakeRangeChance = flGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_flShakeRangeChance, g_esShakeAbility[iType].g_flShakeRangeChance, 1);
		g_esShakeCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iHumanAbility, g_esShakeAbility[iType].g_iHumanAbility, 1);
		g_esShakeCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iHumanAmmo, g_esShakeAbility[iType].g_iHumanAmmo, 1);
		g_esShakeCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iHumanCooldown, g_esShakeAbility[iType].g_iHumanCooldown, 1);
		g_esShakeCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iHumanRangeCooldown, g_esShakeAbility[iType].g_iHumanRangeCooldown, 1);
		g_esShakeCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_flOpenAreasOnly, g_esShakeAbility[iType].g_flOpenAreasOnly, 1);
		g_esShakeCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iRequiresHumans, g_esShakeAbility[iType].g_iRequiresHumans, 1);
		g_esShakeCache[tank].g_iShakeAbility = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeAbility, g_esShakeAbility[iType].g_iShakeAbility, 1);
		g_esShakeCache[tank].g_iShakeCooldown = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeCooldown, g_esShakeAbility[iType].g_iShakeCooldown, 1);
		g_esShakeCache[tank].g_iShakeDeath = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeDeath, g_esShakeAbility[iType].g_iShakeDeath, 1);
		g_esShakeCache[tank].g_iShakeDuration = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeDuration, g_esShakeAbility[iType].g_iShakeDuration, 1);
		g_esShakeCache[tank].g_iShakeEffect = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeEffect, g_esShakeAbility[iType].g_iShakeEffect, 1);
		g_esShakeCache[tank].g_iShakeHit = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeHit, g_esShakeAbility[iType].g_iShakeHit, 1);
		g_esShakeCache[tank].g_iShakeHitMode = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeHitMode, g_esShakeAbility[iType].g_iShakeHitMode, 1);
		g_esShakeCache[tank].g_iShakeMessage = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeMessage, g_esShakeAbility[iType].g_iShakeMessage, 1);
		g_esShakeCache[tank].g_iShakeRangeCooldown = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeRangeCooldown, g_esShakeAbility[iType].g_iShakeRangeCooldown, 1);
		g_esShakeCache[tank].g_iShakeSight = iGetSettingValue(apply, bHuman, g_esShakePlayer[tank].g_iShakeSight, g_esShakeAbility[iType].g_iShakeSight, 1);
	}
}

#if defined MT_ABILITIES_MAIN2
void vShakeCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vShakeCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveShake(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vShakeEventFired(Event event, const char[] name)
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
			vShakeCopyStats2(iBot, iTank);
			vRemoveShake(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vShakeReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vShakeCopyStats2(iTank, iBot);
			vRemoveShake(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vShakeRange(iTank, 1, 0, GetRandomFloat(0.1, 100.0));
			vRemoveShake(iTank);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vShakeHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esShakeCache[iBoomer].g_flShakeChance, g_esShakeCache[iBoomer].g_iShakeHit, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);
		}
	}
	else if (StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vShakeRange(iTank, 1, 1, GetRandomFloat(0.1, 100.0));
			vRemoveShake(iTank);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vShakeAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esShakeAbility[g_esShakePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[tank].g_iAccessFlags)) || g_esShakeCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esShakeCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esShakeCache[tank].g_iShakeAbility == 1 && g_esShakeCache[tank].g_iComboAbility == 0)
	{
		vShakeAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN2
void vShakeButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esShakeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esShakeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esShakePlayer[tank].g_iTankType, tank) || (g_esShakeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esShakeCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esShakeAbility[g_esShakePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esShakeCache[tank].g_iShakeAbility == 1 && g_esShakeCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();

			switch (g_esShakePlayer[tank].g_iRangeCooldown == -1 || g_esShakePlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vShakeAbility(tank, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShakeHuman3", (g_esShakePlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vShakeChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveShake(tank);
}

#if defined MT_ABILITIES_MAIN2
void vShakePostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	vShakeRange(tank, 1, 1, GetRandomFloat(0.1, 100.0));
}

void vShakeAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esShakeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esShakeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esShakePlayer[tank].g_iTankType, tank) || (g_esShakeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esShakeCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esShakeAbility[g_esShakePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esShakePlayer[tank].g_iAmmoCount < g_esShakeCache[tank].g_iHumanAmmo && g_esShakeCache[tank].g_iHumanAmmo > 0))
	{
		g_esShakePlayer[tank].g_bFailed = false;
		g_esShakePlayer[tank].g_bNoAmmo = false;

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esShakeCache[tank].g_flShakeRange,
			flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esShakeCache[tank].g_flShakeRangeChance;
		int iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esShakePlayer[tank].g_iTankType, g_esShakeAbility[g_esShakePlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esShakePlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esShakeCache[tank].g_iShakeSight, .range = flRange))
				{
					vShakeHit(iSurvivor, tank, random, flChance, g_esShakeCache[tank].g_iShakeAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esShakeCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShakeHuman4");
			}
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esShakeCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShakeAmmo");
	}
}

void vShakeHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esShakeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esShakeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esShakePlayer[tank].g_iTankType, tank) || (g_esShakeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esShakeCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esShakeAbility[g_esShakePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esShakePlayer[tank].g_iTankType, g_esShakeAbility[g_esShakePlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esShakePlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esShakePlayer[tank].g_iRangeCooldown != -1 && g_esShakePlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esShakePlayer[tank].g_iCooldown != -1 && g_esShakePlayer[tank].g_iCooldown >= iTime))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esShakePlayer[tank].g_iAmmoCount < g_esShakeCache[tank].g_iHumanAmmo && g_esShakeCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance && !g_esShakePlayer[survivor].g_bAffected)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esShakeCache[tank].g_iShakeSight, .range = 100.0))
				{
					return;
				}

				g_esShakePlayer[survivor].g_bAffected = true;
				g_esShakePlayer[survivor].g_iOwner = tank;

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esShakePlayer[tank].g_iRangeCooldown == -1 || g_esShakePlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esShakeCache[tank].g_iHumanAbility == 1)
					{
						g_esShakePlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShakeHuman", g_esShakePlayer[tank].g_iAmmoCount, g_esShakeCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esShakeCache[tank].g_iShakeRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esShakeCache[tank].g_iHumanAbility == 1 && g_esShakePlayer[tank].g_iAmmoCount < g_esShakeCache[tank].g_iHumanAmmo && g_esShakeCache[tank].g_iHumanAmmo > 0) ? g_esShakeCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esShakePlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esShakePlayer[tank].g_iRangeCooldown != -1 && g_esShakePlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShakeHuman5", (g_esShakePlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esShakePlayer[tank].g_iCooldown == -1 || g_esShakePlayer[tank].g_iCooldown <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esShakeCache[tank].g_iShakeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esShakeCache[tank].g_iHumanAbility == 1) ? g_esShakeCache[tank].g_iHumanCooldown : iCooldown;
					g_esShakePlayer[tank].g_iCooldown = (iTime + iCooldown);
					if (g_esShakePlayer[tank].g_iCooldown != -1 && g_esShakePlayer[tank].g_iCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShakeHuman5", (g_esShakePlayer[tank].g_iCooldown - iTime));
					}
				}

				float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 6, pos) : g_esShakeCache[tank].g_flShakeInterval;
				if (flInterval > 0.0)
				{
					DataPack dpShake;
					CreateDataTimer(flInterval, tTimerShake, dpShake, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					dpShake.WriteCell(GetClientUserId(survivor));
					dpShake.WriteCell(GetClientUserId(tank));
					dpShake.WriteCell(g_esShakePlayer[tank].g_iTankType);
					dpShake.WriteCell(messages);
					dpShake.WriteCell(enabled);
					dpShake.WriteCell(pos);
					dpShake.WriteCell(iTime);
				}

				vScreenEffect(survivor, tank, g_esShakeCache[tank].g_iShakeEffect, flags);
				EmitSoundToClient(survivor, (g_bSecondGame ? SOUND_SMASH2 : SOUND_SMASH1));

				if (g_esShakeCache[tank].g_iShakeMessage & messages)
				{
					char sTankName[64];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Shake", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Shake", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esShakePlayer[tank].g_iRangeCooldown == -1 || g_esShakePlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esShakeCache[tank].g_iHumanAbility == 1 && !g_esShakePlayer[tank].g_bFailed)
				{
					g_esShakePlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShakeHuman2");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esShakeCache[tank].g_iHumanAbility == 1 && !g_esShakePlayer[tank].g_bNoAmmo)
		{
			g_esShakePlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShakeAmmo");
		}
	}
}

void vShakeRange(int tank, int value, int bit, float random, int pos = -1)
{
	float flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 13, pos) : g_esShakeCache[tank].g_flShakeDeathChance;
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && (g_esShakeCache[tank].g_iShakeDeath & (1 << bit)) && random <= flChance)
	{
		if (g_esShakeCache[tank].g_iComboAbility == value || bIsAreaNarrow(tank, g_esShakeCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esShakeCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esShakePlayer[tank].g_iTankType, tank) || (g_esShakeCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esShakeCache[tank].g_iRequiresHumans) || (bIsInfected(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esShakeAbility[g_esShakePlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[tank].g_iAccessFlags)) || g_esShakeCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 12, pos) : g_esShakeCache[tank].g_flShakeDeathRange;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esShakePlayer[tank].g_iTankType, g_esShakeAbility[g_esShakePlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esShakePlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esShakeCache[tank].g_iShakeSight, .range = flRange))
				{
					vShakePlayerScreen(tank, 2.0);
				}
			}
		}
	}
}

void vShakeCopyStats2(int oldTank, int newTank)
{
	g_esShakePlayer[newTank].g_iAmmoCount = g_esShakePlayer[oldTank].g_iAmmoCount;
	g_esShakePlayer[newTank].g_iCooldown = g_esShakePlayer[oldTank].g_iCooldown;
	g_esShakePlayer[newTank].g_iRangeCooldown = g_esShakePlayer[oldTank].g_iRangeCooldown;
}

void vRemoveShake(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esShakePlayer[iSurvivor].g_bAffected && g_esShakePlayer[iSurvivor].g_iOwner == tank)
		{
			g_esShakePlayer[iSurvivor].g_bAffected = false;
			g_esShakePlayer[iSurvivor].g_iOwner = -1;
		}
	}

	vShakeReset3(tank);
}

void vShakeReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vShakeReset3(iPlayer);

			g_esShakePlayer[iPlayer].g_iOwner = -1;
		}
	}
}

void vShakeReset2(int survivor, int tank, int messages)
{
	g_esShakePlayer[survivor].g_bAffected = false;
	g_esShakePlayer[survivor].g_iOwner = -1;

	if (g_esShakeCache[tank].g_iShakeMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Shake2", survivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Shake2", LANG_SERVER, survivor);
	}
}

void vShakeReset3(int tank)
{
	g_esShakePlayer[tank].g_bAffected = false;
	g_esShakePlayer[tank].g_bFailed = false;
	g_esShakePlayer[tank].g_bNoAmmo = false;
	g_esShakePlayer[tank].g_iAmmoCount = 0;
	g_esShakePlayer[tank].g_iCooldown = -1;
	g_esShakePlayer[tank].g_iRangeCooldown = -1;
}

void tTimerShakeCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esShakeAbility[g_esShakePlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esShakePlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esShakeCache[iTank].g_iShakeAbility == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vShakeAbility(iTank, flRandom, iPos);
}

void tTimerShakeCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || g_esShakePlayer[iSurvivor].g_bAffected)
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esShakeAbility[g_esShakePlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esShakePlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esShakeCache[iTank].g_iShakeHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esShakeCache[iTank].g_iShakeHitMode == 0 || g_esShakeCache[iTank].g_iShakeHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vShakeHit(iSurvivor, iTank, flRandom, flChance, g_esShakeCache[iTank].g_iShakeHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esShakeCache[iTank].g_iShakeHitMode == 0 || g_esShakeCache[iTank].g_iShakeHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vShakeHit(iSurvivor, iTank, flRandom, flChance, g_esShakeCache[iTank].g_iShakeHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}
}

Action tTimerShake(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsHumanSurvivor(iSurvivor))
	{
		g_esShakePlayer[iSurvivor].g_bAffected = false;
		g_esShakePlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esShakeCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esShakeCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esShakePlayer[iTank].g_iTankType, iTank) || (g_esShakeCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esShakeCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esShakeAbility[g_esShakePlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esShakePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esShakePlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esShakePlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esShakePlayer[iTank].g_iTankType, g_esShakeAbility[g_esShakePlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esShakePlayer[iSurvivor].g_iImmunityFlags) || !g_esShakePlayer[iSurvivor].g_bAffected)
	{
		vShakeReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iShakeEnabled = pack.ReadCell(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : g_esShakeCache[iTank].g_iShakeDuration,
		iTime = pack.ReadCell();
	if (iShakeEnabled == 0 || (iTime + iDuration) <= GetTime())
	{
		vShakeReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	if (!bIsVisibleToPlayer(iSurvivor, iTank, g_esShakeCache[iTank].g_iShakeSight))
	{
		return Plugin_Continue;
	}

	vShakePlayerScreen(iSurvivor);

	return Plugin_Continue;
}