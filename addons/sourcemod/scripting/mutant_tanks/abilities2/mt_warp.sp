/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2022  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_WARP_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_WARP_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Warp Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank warps to survivors and warps survivors to random teammates.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Warp Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}
#else
	#if MT_WARP_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define PARTICLE_WARP "electrical_arc_01_system"

#define SOUND_WARP "ambient/energy/zap5.wav"
#define SOUND_WARP2 "ambient/energy/zap7.wav"

#define MT_WARP_SECTION "warpability"
#define MT_WARP_SECTION2 "warp ability"
#define MT_WARP_SECTION3 "warp_ability"
#define MT_WARP_SECTION4 "warp"

#define MT_MENU_WARP "Warp Ability"

enum struct esWarpGeneral
{
	Handle g_hSDKGetLastKnownArea;

	int g_iAttributeFlagsOffset;
}

esWarpGeneral g_esWarpGeneral;

enum struct esWarpPlayer
{
	bool g_bActivated;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flOpenAreasOnly;
	float g_flWarpChance;
	float g_flWarpInterval;
	float g_flWarpRange;
	float g_flWarpRangeChance;
	float g_flWarpRockChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iAmmoCount2;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iWarpAbility;
	int g_iWarpEffect;
	int g_iWarpHit;
	int g_iWarpHitMode;
	int g_iWarpMessage;
	int g_iWarpMode;
	int g_iWarpRockBreak;
}

esWarpPlayer g_esWarpPlayer[MAXPLAYERS + 1];

enum struct esWarpAbility
{
	float g_flOpenAreasOnly;
	float g_flWarpChance;
	float g_flWarpInterval;
	float g_flWarpRange;
	float g_flWarpRangeChance;
	float g_flWarpRockChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iWarpAbility;
	int g_iWarpEffect;
	int g_iWarpHit;
	int g_iWarpHitMode;
	int g_iWarpMessage;
	int g_iWarpMode;
	int g_iWarpRockBreak;
}

esWarpAbility g_esWarpAbility[MT_MAXTYPES + 1];

enum struct esWarpCache
{
	float g_flOpenAreasOnly;
	float g_flWarpChance;
	float g_flWarpInterval;
	float g_flWarpRange;
	float g_flWarpRangeChance;
	float g_flWarpRockChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRequiresHumans;
	int g_iWarpAbility;
	int g_iWarpEffect;
	int g_iWarpHit;
	int g_iWarpHitMode;
	int g_iWarpMessage;
	int g_iWarpMode;
	int g_iWarpRockBreak;
}

esWarpCache g_esWarpCache[MAXPLAYERS + 1];

#if defined MT_ABILITIES_MAIN2
void vWarpPluginStart()
#else
public void OnPluginStart()
#endif
{
	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");
	}

	g_esWarpGeneral.g_iAttributeFlagsOffset = gdMutantTanks.GetOffset("WitchLocomotion::IsAreaTraversable::m_attributeFlags");
	if (g_esWarpGeneral.g_iAttributeFlagsOffset == -1)
	{
		delete gdMutantTanks;

		SetFailState("Failed to load offset: WitchLocomotion::IsAreaTraversable::m_attributeFlags");
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CTerrorPlayer::GetLastKnownArea"))
	{
		delete gdMutantTanks;

		SetFailState("Failed to load offset: CTerrorPlayer::GetLastKnownArea");
	}

	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_esWarpGeneral.g_hSDKGetLastKnownArea = EndPrepSDKCall();
	if (g_esWarpGeneral.g_hSDKGetLastKnownArea == null)
	{
		LogError("%s Your \"CTerrorPlayer::GetLastKnownArea\" offsets are outdated.", MT_TAG);
	}

	delete gdMutantTanks;
#if !defined MT_ABILITIES_MAIN2
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_warp", cmdWarpInfo, "View information about the Warp ability.");

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
#endif
}

#if defined MT_ABILITIES_MAIN2
void vWarpMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheSound(SOUND_WARP, true);
	PrecacheSound(SOUND_WARP2, true);

	vWarpReset();
}

#if defined MT_ABILITIES_MAIN2
void vWarpClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnWarpTakeDamage);
	vRemoveWarp(client);
}

#if defined MT_ABILITIES_MAIN2
void vWarpClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveWarp(client);
}

#if defined MT_ABILITIES_MAIN2
void vWarpMapEnd()
#else
public void OnMapEnd()
#endif
{
	vWarpReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdWarpInfo(int client, int args)
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
		case false: vWarpMenu(client, MT_WARP_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vWarpMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_WARP_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iWarpMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Warp Ability Information");
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

int iWarpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esWarpCache[param1].g_iWarpAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esWarpCache[param1].g_iHumanAmmo - g_esWarpPlayer[param1].g_iAmmoCount), g_esWarpCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", (g_esWarpCache[param1].g_iHumanAmmo - g_esWarpPlayer[param1].g_iAmmoCount2), g_esWarpCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esWarpCache[param1].g_iHumanMode == 0) ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esWarpCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "WarpDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esWarpCache[param1].g_iHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esWarpCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vWarpMenu(param1, MT_WARP_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pWarp = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "WarpMenu", param1);
			pWarp.SetTitle(sMenuTitle);
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
					case 3: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "ButtonMode", param1);
					case 4: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Cooldown", param1);
					case 5: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Details", param1);
					case 6: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Duration", param1);
					case 7: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN2
void vWarpDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_WARP, MT_MENU_WARP);
}

#if defined MT_ABILITIES_MAIN2
void vWarpMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_WARP, false))
	{
		vWarpMenu(client, MT_WARP_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vWarpMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_WARP, false))
	{
		FormatEx(buffer, size, "%T", "WarpMenu2", client);
	}
}

Action OnWarpTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsValidEntity(inflictor) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esWarpCache[attacker].g_iWarpHitMode == 0 || g_esWarpCache[attacker].g_iWarpHitMode == 1) && bIsSurvivor(victim) && g_esWarpCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esWarpAbility[g_esWarpPlayer[attacker].g_iTankType].g_iAccessFlags, g_esWarpPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esWarpPlayer[attacker].g_iTankType, g_esWarpAbility[g_esWarpPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esWarpPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWarpHit(victim, attacker, MT_GetRandomFloat(0.1, 100.0), g_esWarpCache[attacker].g_flWarpChance, g_esWarpCache[attacker].g_iWarpHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esWarpCache[victim].g_iWarpHitMode == 0 || g_esWarpCache[victim].g_iWarpHitMode == 2) && bIsSurvivor(attacker) && g_esWarpCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esWarpAbility[g_esWarpPlayer[victim].g_iTankType].g_iAccessFlags, g_esWarpPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esWarpPlayer[victim].g_iTankType, g_esWarpAbility[g_esWarpPlayer[victim].g_iTankType].g_iImmunityFlags, g_esWarpPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vWarpHit(attacker, victim, MT_GetRandomFloat(0.1, 100.0), g_esWarpCache[victim].g_flWarpChance, g_esWarpCache[victim].g_iWarpHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vWarpPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_WARP);
}

#if defined MT_ABILITIES_MAIN2
void vWarpAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_WARP_SECTION);
	list2.PushString(MT_WARP_SECTION2);
	list3.PushString(MT_WARP_SECTION3);
	list4.PushString(MT_WARP_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vWarpCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esWarpCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof sAbilities, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_WARP_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_WARP_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_WARP_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_WARP_SECTION4);
	if (g_esWarpCache[tank].g_iComboAbility == 1 && (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1))
	{
		char sSubset[10][32];
		ExplodeString(combo, ",", sSubset, sizeof sSubset, sizeof sSubset[]);
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_WARP_SECTION, false) || StrEqual(sSubset[iPos], MT_WARP_SECTION2, false) || StrEqual(sSubset[iPos], MT_WARP_SECTION3, false) || StrEqual(sSubset[iPos], MT_WARP_SECTION4, false))
			{
				float flDelay = MT_GetCombinationSetting(tank, 3, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esWarpCache[tank].g_iWarpAbility == 1 || g_esWarpCache[tank].g_iWarpAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vWarpAbility(tank, true, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerWarpCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}
						else if (g_esWarpCache[tank].g_iWarpAbility == 2 || g_esWarpCache[tank].g_iWarpAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vWarpAbility(tank, false, .pos = iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerWarpCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteCell(iPos);
								}
							}
						}
					}
					case MT_COMBO_MELEEHIT:
					{
						float flChance = MT_GetCombinationSetting(tank, 1, iPos);

						switch (flDelay)
						{
							case 0.0:
							{
								if ((g_esWarpCache[tank].g_iWarpHitMode == 0 || g_esWarpCache[tank].g_iWarpHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vWarpHit(survivor, tank, random, flChance, g_esWarpCache[tank].g_iWarpHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esWarpCache[tank].g_iWarpHitMode == 0 || g_esWarpCache[tank].g_iWarpHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vWarpHit(survivor, tank, random, flChance, g_esWarpCache[tank].g_iWarpHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerWarpCombo3, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteString(classname);
							}
						}
					}
					case MT_COMBO_ROCKBREAK:
					{
						if (g_esWarpCache[tank].g_iWarpRockBreak == 1 && bIsValidEntity(weapon))
						{
							vWarpRockBreak2(tank, weapon, random, iPos);
						}
					}
				}

				break;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vWarpConfigsLoad(int mode)
#else
public void MT_OnConfigsLoad(int mode)
#endif
{
	switch (mode)
	{
		case 1:
		{
			int iMaxType = MT_GetMaxType();
			for (int iIndex = MT_GetMinType(); iIndex <= iMaxType; iIndex++)
			{
				g_esWarpAbility[iIndex].g_iAccessFlags = 0;
				g_esWarpAbility[iIndex].g_iImmunityFlags = 0;
				g_esWarpAbility[iIndex].g_iComboAbility = 0;
				g_esWarpAbility[iIndex].g_iHumanAbility = 0;
				g_esWarpAbility[iIndex].g_iHumanAmmo = 5;
				g_esWarpAbility[iIndex].g_iHumanCooldown = 30;
				g_esWarpAbility[iIndex].g_iHumanDuration = 5;
				g_esWarpAbility[iIndex].g_iHumanMode = 1;
				g_esWarpAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esWarpAbility[iIndex].g_iRequiresHumans = 0;
				g_esWarpAbility[iIndex].g_iWarpAbility = 0;
				g_esWarpAbility[iIndex].g_iWarpEffect = 0;
				g_esWarpAbility[iIndex].g_iWarpMessage = 0;
				g_esWarpAbility[iIndex].g_flWarpChance = 33.3;
				g_esWarpAbility[iIndex].g_iWarpHit = 0;
				g_esWarpAbility[iIndex].g_iWarpHitMode = 0;
				g_esWarpAbility[iIndex].g_flWarpInterval = 5.0;
				g_esWarpAbility[iIndex].g_iWarpMode = 0;
				g_esWarpAbility[iIndex].g_flWarpRange = 150.0;
				g_esWarpAbility[iIndex].g_flWarpRangeChance = 15.0;
				g_esWarpAbility[iIndex].g_iWarpRockBreak = 0;
				g_esWarpAbility[iIndex].g_flWarpRockChance = 33.3;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esWarpPlayer[iPlayer].g_iAccessFlags = 0;
					g_esWarpPlayer[iPlayer].g_iImmunityFlags = 0;
					g_esWarpPlayer[iPlayer].g_iComboAbility = 0;
					g_esWarpPlayer[iPlayer].g_iHumanAbility = 0;
					g_esWarpPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esWarpPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esWarpPlayer[iPlayer].g_iHumanDuration = 0;
					g_esWarpPlayer[iPlayer].g_iHumanMode = 0;
					g_esWarpPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esWarpPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esWarpPlayer[iPlayer].g_iWarpAbility = 0;
					g_esWarpPlayer[iPlayer].g_iWarpEffect = 0;
					g_esWarpPlayer[iPlayer].g_iWarpMessage = 0;
					g_esWarpPlayer[iPlayer].g_flWarpChance = 0.0;
					g_esWarpPlayer[iPlayer].g_iWarpHit = 0;
					g_esWarpPlayer[iPlayer].g_iWarpHitMode = 0;
					g_esWarpPlayer[iPlayer].g_flWarpInterval = 0.0;
					g_esWarpPlayer[iPlayer].g_iWarpMode = 0;
					g_esWarpPlayer[iPlayer].g_flWarpRange = 0.0;
					g_esWarpPlayer[iPlayer].g_flWarpRangeChance = 0.0;
					g_esWarpPlayer[iPlayer].g_iWarpRockBreak = 0;
					g_esWarpPlayer[iPlayer].g_flWarpRockChance = 0.0;
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vWarpConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
#endif
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esWarpPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esWarpPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esWarpPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esWarpPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esWarpPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esWarpPlayer[admin].g_iHumanAmmo, value, 0, 99999);
		g_esWarpPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esWarpPlayer[admin].g_iHumanCooldown, value, 0, 99999);
		g_esWarpPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esWarpPlayer[admin].g_iHumanDuration, value, 1, 99999);
		g_esWarpPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esWarpPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esWarpPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esWarpPlayer[admin].g_flOpenAreasOnly, value, 0.0, 99999.0);
		g_esWarpPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esWarpPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esWarpPlayer[admin].g_iWarpAbility = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esWarpPlayer[admin].g_iWarpAbility, value, 0, 3);
		g_esWarpPlayer[admin].g_iWarpEffect = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esWarpPlayer[admin].g_iWarpEffect, value, 0, 7);
		g_esWarpPlayer[admin].g_iWarpMessage = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esWarpPlayer[admin].g_iWarpMessage, value, 0, 7);
		g_esWarpPlayer[admin].g_flWarpChance = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpChance", "Warp Chance", "Warp_Chance", "chance", g_esWarpPlayer[admin].g_flWarpChance, value, 0.0, 100.0);
		g_esWarpPlayer[admin].g_iWarpHit = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpHit", "Warp Hit", "Warp_Hit", "hit", g_esWarpPlayer[admin].g_iWarpHit, value, 0, 1);
		g_esWarpPlayer[admin].g_iWarpHitMode = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpHitMode", "Warp Hit Mode", "Warp_Hit_Mode", "hitmode", g_esWarpPlayer[admin].g_iWarpHitMode, value, 0, 2);
		g_esWarpPlayer[admin].g_flWarpInterval = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpInterval", "Warp Interval", "Warp_Interval", "interval", g_esWarpPlayer[admin].g_flWarpInterval, value, 0.1, 99999.0);
		g_esWarpPlayer[admin].g_iWarpMode = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpMode", "Warp Mode", "Warp_Mode", "mode", g_esWarpPlayer[admin].g_iWarpMode, value, 0, 3);
		g_esWarpPlayer[admin].g_flWarpRange = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpRange", "Warp Range", "Warp_Range", "range", g_esWarpPlayer[admin].g_flWarpRange, value, 1.0, 99999.0);
		g_esWarpPlayer[admin].g_flWarpRangeChance = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpRangeChance", "Warp Range Chance", "Warp_Range_Chance", "rangechance", g_esWarpPlayer[admin].g_flWarpRangeChance, value, 0.0, 100.0);
		g_esWarpPlayer[admin].g_iWarpRockBreak = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpRockBreak", "Warp Rock Break", "Warp_Rock_Break", "rock", g_esWarpPlayer[admin].g_iWarpRockBreak, value, 0, 1);
		g_esWarpPlayer[admin].g_flWarpRockChance = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpRockChance", "Warp Rock Chance", "Warp_Rock_Chance", "rockchance", g_esWarpPlayer[admin].g_flWarpRockChance, value, 0.0, 100.0);
		g_esWarpPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		g_esWarpPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
	}

	if (mode < 3 && type > 0)
	{
		g_esWarpAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esWarpAbility[type].g_iComboAbility, value, 0, 1);
		g_esWarpAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esWarpAbility[type].g_iHumanAbility, value, 0, 2);
		g_esWarpAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esWarpAbility[type].g_iHumanAmmo, value, 0, 99999);
		g_esWarpAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esWarpAbility[type].g_iHumanCooldown, value, 0, 99999);
		g_esWarpAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esWarpAbility[type].g_iHumanDuration, value, 1, 99999);
		g_esWarpAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esWarpAbility[type].g_iHumanMode, value, 0, 1);
		g_esWarpAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esWarpAbility[type].g_flOpenAreasOnly, value, 0.0, 99999.0);
		g_esWarpAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esWarpAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esWarpAbility[type].g_iWarpAbility = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esWarpAbility[type].g_iWarpAbility, value, 0, 3);
		g_esWarpAbility[type].g_iWarpEffect = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esWarpAbility[type].g_iWarpEffect, value, 0, 7);
		g_esWarpAbility[type].g_iWarpMessage = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esWarpAbility[type].g_iWarpMessage, value, 0, 7);
		g_esWarpAbility[type].g_flWarpChance = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpChance", "Warp Chance", "Warp_Chance", "chance", g_esWarpAbility[type].g_flWarpChance, value, 0.0, 100.0);
		g_esWarpAbility[type].g_iWarpHit = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpHit", "Warp Hit", "Warp_Hit", "hit", g_esWarpAbility[type].g_iWarpHit, value, 0, 1);
		g_esWarpAbility[type].g_iWarpHitMode = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpHitMode", "Warp Hit Mode", "Warp_Hit_Mode", "hitmode", g_esWarpAbility[type].g_iWarpHitMode, value, 0, 2);
		g_esWarpAbility[type].g_flWarpInterval = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpInterval", "Warp Interval", "Warp_Interval", "interval", g_esWarpAbility[type].g_flWarpInterval, value, 0.1, 99999.0);
		g_esWarpAbility[type].g_iWarpMode = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpMode", "Warp Mode", "Warp_Mode", "mode", g_esWarpAbility[type].g_iWarpMode, value, 0, 3);
		g_esWarpAbility[type].g_flWarpRange = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpRange", "Warp Range", "Warp_Range", "range", g_esWarpAbility[type].g_flWarpRange, value, 1.0, 99999.0);
		g_esWarpAbility[type].g_flWarpRangeChance = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpRangeChance", "Warp Range Chance", "Warp_Range_Chance", "rangechance", g_esWarpAbility[type].g_flWarpRangeChance, value, 0.0, 100.0);
		g_esWarpAbility[type].g_iWarpRockBreak = iGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpRockBreak", "Warp Rock Break", "Warp_Rock_Break", "rock", g_esWarpAbility[type].g_iWarpRockBreak, value, 0, 1);
		g_esWarpAbility[type].g_flWarpRockChance = flGetKeyValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "WarpRockChance", "Warp Rock Chance", "Warp_Rock_Chance", "rockchance", g_esWarpAbility[type].g_flWarpRockChance, value, 0.0, 100.0);
		g_esWarpAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		g_esWarpAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_WARP_SECTION, MT_WARP_SECTION2, MT_WARP_SECTION3, MT_WARP_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
	}
}

#if defined MT_ABILITIES_MAIN2
void vWarpSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	g_esWarpCache[tank].g_flWarpChance = flGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_flWarpChance, g_esWarpAbility[type].g_flWarpChance);
	g_esWarpCache[tank].g_flWarpInterval = flGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_flWarpInterval, g_esWarpAbility[type].g_flWarpInterval);
	g_esWarpCache[tank].g_flWarpRange = flGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_flWarpRange, g_esWarpAbility[type].g_flWarpRange);
	g_esWarpCache[tank].g_flWarpRangeChance = flGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_flWarpRangeChance, g_esWarpAbility[type].g_flWarpRangeChance);
	g_esWarpCache[tank].g_flWarpRockChance = flGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_flWarpRockChance, g_esWarpAbility[type].g_flWarpRockChance);
	g_esWarpCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iComboAbility, g_esWarpAbility[type].g_iComboAbility);
	g_esWarpCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iHumanAbility, g_esWarpAbility[type].g_iHumanAbility);
	g_esWarpCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iHumanAmmo, g_esWarpAbility[type].g_iHumanAmmo);
	g_esWarpCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iHumanCooldown, g_esWarpAbility[type].g_iHumanCooldown);
	g_esWarpCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iHumanDuration, g_esWarpAbility[type].g_iHumanDuration);
	g_esWarpCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iHumanMode, g_esWarpAbility[type].g_iHumanMode);
	g_esWarpCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_flOpenAreasOnly, g_esWarpAbility[type].g_flOpenAreasOnly);
	g_esWarpCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iRequiresHumans, g_esWarpAbility[type].g_iRequiresHumans);
	g_esWarpCache[tank].g_iWarpAbility = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iWarpAbility, g_esWarpAbility[type].g_iWarpAbility);
	g_esWarpCache[tank].g_iWarpEffect = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iWarpEffect, g_esWarpAbility[type].g_iWarpEffect);
	g_esWarpCache[tank].g_iWarpHit = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iWarpHit, g_esWarpAbility[type].g_iWarpHit);
	g_esWarpCache[tank].g_iWarpHitMode = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iWarpHitMode, g_esWarpAbility[type].g_iWarpHitMode);
	g_esWarpCache[tank].g_iWarpMessage = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iWarpMessage, g_esWarpAbility[type].g_iWarpMessage);
	g_esWarpCache[tank].g_iWarpMode = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iWarpMode, g_esWarpAbility[type].g_iWarpMode);
	g_esWarpCache[tank].g_iWarpRockBreak = iGetSettingValue(apply, bHuman, g_esWarpPlayer[tank].g_iWarpRockBreak, g_esWarpAbility[type].g_iWarpRockBreak);
	g_esWarpPlayer[tank].g_iTankType = apply ? type : 0;
}

#if defined MT_ABILITIES_MAIN2
void vWarpCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vWarpCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveWarp(oldTank);
	}
}

#if defined MT_ABILITIES_MAIN2
void vWarpEventFired(Event event, const char[] name)
#else
public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
#endif
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vWarpCopyStats2(iBot, iTank);
			vRemoveWarp(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vWarpCopyStats2(iTank, iBot);
			vRemoveWarp(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vWarpRange(iTank);
			vRemoveWarp(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vWarpReset();
	}
}

#if defined MT_ABILITIES_MAIN2
void vWarpAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[tank].g_iAccessFlags)) || g_esWarpCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esWarpCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esWarpCache[tank].g_iWarpAbility > 0 && g_esWarpCache[tank].g_iComboAbility == 0)
	{
		vWarpAbility(tank, false);
		vWarpAbility(tank, true, MT_GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN2
void vWarpButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esWarpCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esWarpPlayer[tank].g_iTankType) || (g_esWarpCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esWarpCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		int iTime = GetTime();
		if (button & MT_MAIN_KEY)
		{
			if ((g_esWarpCache[tank].g_iWarpAbility == 2 || g_esWarpCache[tank].g_iWarpAbility == 3) && g_esWarpCache[tank].g_iHumanAbility == 1)
			{
				bool bRecharging = g_esWarpPlayer[tank].g_iCooldown != -1 && g_esWarpPlayer[tank].g_iCooldown > iTime;

				switch (g_esWarpCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esWarpPlayer[tank].g_bActivated && !bRecharging)
						{
							vWarpAbility(tank, false);
						}
						else if (g_esWarpPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman4");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman5", (g_esWarpPlayer[tank].g_iCooldown - iTime));
						}
					}
					case 1:
					{
						if (g_esWarpPlayer[tank].g_iAmmoCount < g_esWarpCache[tank].g_iHumanAmmo && g_esWarpCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esWarpPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esWarpPlayer[tank].g_bActivated = true;
								g_esWarpPlayer[tank].g_iAmmoCount++;

								vWarp(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman", g_esWarpPlayer[tank].g_iAmmoCount, g_esWarpCache[tank].g_iHumanAmmo);
							}
							else if (g_esWarpPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman4");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman5", (g_esWarpPlayer[tank].g_iCooldown - iTime));
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SUB_KEY)
		{
			if ((g_esWarpCache[tank].g_iWarpAbility == 1 || g_esWarpCache[tank].g_iWarpAbility == 3) && g_esWarpCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esWarpPlayer[tank].g_iCooldown2 != -1 && g_esWarpPlayer[tank].g_iCooldown2 > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman6", (g_esWarpPlayer[tank].g_iCooldown2 - iTime));
					case false: vWarpAbility(tank, true, MT_GetRandomFloat(0.1, 100.0));
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vWarpButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esWarpCache[tank].g_iHumanAbility == 1)
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esWarpCache[tank].g_iHumanMode == 1 && g_esWarpPlayer[tank].g_bActivated && (g_esWarpPlayer[tank].g_iCooldown == -1 || g_esWarpPlayer[tank].g_iCooldown < GetTime()))
			{
				vWarpReset2(tank);
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vWarpChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveWarp(tank);
}

#if defined MT_ABILITIES_MAIN2
void vWarpPostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	vWarpRange(tank);
}

#if defined MT_ABILITIES_MAIN2
void vWarpRockBreak(int tank, int rock)
#else
public void MT_OnRockBreak(int tank, int rock)
#endif
{
	if (bIsAreaNarrow(tank, g_esWarpCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esWarpPlayer[tank].g_iTankType) || (g_esWarpCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esWarpCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[tank].g_iAccessFlags)) || g_esWarpCache[tank].g_iHumanAbility == 0)))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && g_esWarpCache[tank].g_iWarpRockBreak == 1 && g_esWarpCache[tank].g_iComboAbility == 0)
	{
		vWarpRockBreak2(tank, rock, MT_GetRandomFloat(0.1, 100.0));
	}
}

void vWarpCopyStats2(int oldTank, int newTank)
{
	g_esWarpPlayer[newTank].g_iAmmoCount = g_esWarpPlayer[oldTank].g_iAmmoCount;
	g_esWarpPlayer[newTank].g_iAmmoCount2 = g_esWarpPlayer[oldTank].g_iAmmoCount2;
	g_esWarpPlayer[newTank].g_iCooldown = g_esWarpPlayer[oldTank].g_iCooldown;
	g_esWarpPlayer[newTank].g_iCooldown2 = g_esWarpPlayer[oldTank].g_iCooldown2;
}

void vRemoveWarp(int tank)
{
	g_esWarpPlayer[tank].g_bActivated = false;
	g_esWarpPlayer[tank].g_bFailed = false;
	g_esWarpPlayer[tank].g_bNoAmmo = false;
	g_esWarpPlayer[tank].g_iAmmoCount = 0;
	g_esWarpPlayer[tank].g_iAmmoCount2 = 0;
	g_esWarpPlayer[tank].g_iCooldown = -1;
	g_esWarpPlayer[tank].g_iCooldown2 = -1;
}

void vWarpReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveWarp(iPlayer);
		}
	}
}

void vWarpReset2(int tank)
{
	g_esWarpPlayer[tank].g_bActivated = false;

	int iTime = GetTime();
	g_esWarpPlayer[tank].g_iCooldown = (g_esWarpPlayer[tank].g_iAmmoCount < g_esWarpCache[tank].g_iHumanAmmo && g_esWarpCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esWarpCache[tank].g_iHumanCooldown) : -1;
	if (g_esWarpPlayer[tank].g_iCooldown != -1 && g_esWarpPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman8", (g_esWarpPlayer[tank].g_iCooldown - iTime));
	}
}

void vWarp(int tank, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esWarpCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esWarpPlayer[tank].g_iTankType) || (g_esWarpCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esWarpCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : g_esWarpCache[tank].g_flWarpInterval;
	DataPack dpWarp;
	CreateDataTimer(flInterval, tTimerWarp, dpWarp, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpWarp.WriteCell(GetClientUserId(tank));
	dpWarp.WriteCell(g_esWarpPlayer[tank].g_iTankType);
	dpWarp.WriteCell(GetTime());
}

void vWarp2(int tank, int other)
{
	if (bIsAreaNarrow(tank, g_esWarpCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esWarpPlayer[tank].g_iTankType) || (g_esWarpCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esWarpCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	float flTankOrigin[3], flTankAngles[3];
	GetClientAbsOrigin(tank, flTankOrigin);
	GetClientAbsAngles(tank, flTankAngles);

	float flOtherOrigin[3], flOtherAngles[3];
	GetClientAbsOrigin(other, flOtherOrigin);
	GetClientAbsAngles(other, flOtherAngles);
	flOtherOrigin[2] += 50.0;

	vAttachParticle(tank, PARTICLE_WARP, 1.0);
	EmitSoundToAll(SOUND_WARP, tank);
	TeleportEntity(tank, flOtherOrigin, flOtherAngles, view_as<float>({0.0, 0.0, 0.0}));

	if (g_esWarpCache[tank].g_iWarpMode == 1 || g_esWarpCache[tank].g_iWarpMode == 3)
	{
		vAttachParticle(other, PARTICLE_WARP, 1.0);
		EmitSoundToAll(SOUND_WARP2, other);
		TeleportEntity(other, flTankOrigin, flTankAngles, view_as<float>({0.0, 0.0, 0.0}));
	}

	if (g_esWarpCache[tank].g_iWarpMessage & MT_MESSAGE_SPECIAL)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Warp3", sTankName, other);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Warp3", LANG_SERVER, sTankName, other);
	}
}

void vWarpAbility(int tank, bool main, float random = 0.0, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esWarpCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esWarpPlayer[tank].g_iTankType) || (g_esWarpCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esWarpCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esWarpCache[tank].g_iWarpAbility == 1 || g_esWarpCache[tank].g_iWarpAbility == 3)
			{
				if (g_esWarpPlayer[tank].g_iAmmoCount2 < g_esWarpCache[tank].g_iHumanAmmo && g_esWarpCache[tank].g_iHumanAmmo > 0)
				{
					g_esWarpPlayer[tank].g_bFailed = false;
					g_esWarpPlayer[tank].g_bNoAmmo = false;

					float flTankPos[3], flSurvivorPos[3];
					GetClientAbsOrigin(tank, flTankPos);
					float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esWarpCache[tank].g_flWarpRange,
						flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esWarpCache[tank].g_flWarpRangeChance;
					int iSurvivorCount = 0;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esWarpPlayer[tank].g_iTankType, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iImmunityFlags, g_esWarpPlayer[iSurvivor].g_iImmunityFlags))
						{
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);
							if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange)
							{
								vWarpHit(iSurvivor, tank, random, flChance, g_esWarpCache[tank].g_iWarpAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esWarpCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman7");
						}
					}
				}
				else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esWarpCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpAmmo");
				}
			}
		}
		case false:
		{
			if ((g_esWarpCache[tank].g_iWarpAbility == 2 || g_esWarpCache[tank].g_iWarpAbility == 3) && !g_esWarpPlayer[tank].g_bActivated)
			{
				if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esWarpPlayer[tank].g_iAmmoCount < g_esWarpCache[tank].g_iHumanAmmo && g_esWarpCache[tank].g_iHumanAmmo > 0))
				{
					g_esWarpPlayer[tank].g_bActivated = true;

					vWarp(tank, pos);

					if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esWarpCache[tank].g_iHumanAbility == 1)
					{
						g_esWarpPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman", g_esWarpPlayer[tank].g_iAmmoCount, g_esWarpCache[tank].g_iHumanAmmo);
					}

					if (g_esWarpCache[tank].g_iWarpMessage & MT_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Warp2", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Warp2", LANG_SERVER, sTankName);
					}
				}
				else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esWarpCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpAmmo");
				}
			}
		}
	}
}

void vWarpHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esWarpCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esWarpPlayer[tank].g_iTankType) || (g_esWarpCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esWarpCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esWarpPlayer[tank].g_iTankType, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iImmunityFlags, g_esWarpPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor) && !bIsSurvivorDisabled(survivor))
	{
		if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esWarpPlayer[tank].g_iAmmoCount2 < g_esWarpCache[tank].g_iHumanAmmo && g_esWarpCache[tank].g_iHumanAmmo > 0))
		{
			int iTime = GetTime();
			if (random <= chance)
			{
				char sTankName[33];
				float flCurrentOrigin[3], flCurrentAngles[3];
				for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
				{
					if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bIsSurvivorDisabled(iSurvivor) && iSurvivor != survivor)
					{
						if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esWarpCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esWarpPlayer[tank].g_iCooldown2 == -1 || g_esWarpPlayer[tank].g_iCooldown2 < iTime))
						{
							g_esWarpPlayer[tank].g_iAmmoCount2++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman2", g_esWarpPlayer[tank].g_iAmmoCount2, g_esWarpCache[tank].g_iHumanAmmo);

							g_esWarpPlayer[tank].g_iCooldown2 = (g_esWarpPlayer[tank].g_iAmmoCount2 < g_esWarpCache[tank].g_iHumanAmmo && g_esWarpCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esWarpCache[tank].g_iHumanCooldown) : -1;
							if (g_esWarpPlayer[tank].g_iCooldown2 != -1 && g_esWarpPlayer[tank].g_iCooldown2 > iTime)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman9", (g_esWarpPlayer[tank].g_iCooldown2 - iTime));
							}
						}

						GetClientAbsOrigin(iSurvivor, flCurrentOrigin);
						GetClientEyeAngles(iSurvivor, flCurrentAngles);
						TeleportEntity(survivor, flCurrentOrigin, flCurrentAngles, view_as<float>({0.0, 0.0, 0.0}));

						if (g_esWarpCache[tank].g_iWarpMessage & messages)
						{
							MT_GetTankName(tank, sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Warp", sTankName, survivor, iSurvivor);
							MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Warp", LANG_SERVER, sTankName, survivor, iSurvivor);
						}

						break;
					}
				}

				vScreenEffect(survivor, tank, g_esWarpCache[tank].g_iWarpEffect, flags);
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esWarpPlayer[tank].g_iCooldown2 == -1 || g_esWarpPlayer[tank].g_iCooldown2 < iTime))
			{
				if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esWarpCache[tank].g_iHumanAbility == 1 && !g_esWarpPlayer[tank].g_bFailed)
				{
					g_esWarpPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpHuman3");
				}
			}
		}
		else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esWarpCache[tank].g_iHumanAbility == 1 && !g_esWarpPlayer[tank].g_bNoAmmo)
		{
			g_esWarpPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "WarpAmmo2");
		}
	}
}

void vWarpRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && g_esWarpCache[tank].g_iWarpAbility == 1)
	{
		if (bIsAreaNarrow(tank, g_esWarpCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esWarpPlayer[tank].g_iTankType) || (g_esWarpCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esWarpCache[tank].g_iRequiresHumans) || (bIsTank(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esWarpAbility[g_esWarpPlayer[tank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[tank].g_iAccessFlags)) || g_esWarpCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		vAttachParticle(tank, PARTICLE_WARP, 1.0);
		EmitSoundToAll(SOUND_WARP, tank);
	}
}

void vWarpRockBreak2(int tank, int rock, float random, int pos = -1)
{
	int iLauncher = GetEntPropEnt(rock, Prop_Data, "m_hOwnerEntity");
	if (bIsValidEntity(iLauncher))
	{
		int iThrower = GetEntPropEnt(iLauncher, Prop_Data, "m_hOwnerEntity");
		if (bIsTank(iThrower) && iThrower == tank)
		{
			return;
		}
	}

	float flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 12, pos) : g_esWarpCache[tank].g_flWarpRockChance;
	if (random <= flChance)
	{
		float flTankPos[3], flTankAngles[3];
		GetClientAbsOrigin(tank, flTankPos);
		GetClientAbsAngles(tank, flTankAngles);

		float flRockPos[3], flRockAngles[3];
		GetEntPropVector(rock, Prop_Data, "m_vecOrigin", flRockPos);
		GetEntPropVector(rock, Prop_Data, "m_angRotation", flRockAngles);

		vAttachParticle(tank, PARTICLE_WARP, 1.0);
		EmitSoundToAll(SOUND_WARP, tank);
		TeleportEntity(tank, flRockPos, flRockAngles, view_as<float>({0.0, 0.0, 0.0}));

		if (g_esWarpCache[tank].g_iWarpMessage & MT_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			MT_GetTankName(tank, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Warp4", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Warp4", LANG_SERVER, sTankName);
		}
	}
}

bool bIsInsideSaferoom(int survivor)
{
	int iArea = SDKCall(g_esWarpGeneral.g_hSDKGetLastKnownArea, survivor);
	if (iArea)
	{
		int iAttributeFlags = LoadFromAddress(view_as<Address>(iArea + g_esWarpGeneral.g_iAttributeFlagsOffset), NumberType_Int32);
		if ((iAttributeFlags & 2048))
		{
			return true;
		}
	}

	return false;
}

Action tTimerWarpCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esWarpAbility[g_esWarpPlayer[iTank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esWarpPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esWarpCache[iTank].g_iWarpAbility == 0 || g_esWarpCache[iTank].g_iWarpAbility == 2)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vWarpAbility(iTank, true, flRandom, iPos);

	return Plugin_Continue;
}

Action tTimerWarpCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esWarpAbility[g_esWarpPlayer[iTank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esWarpPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esWarpCache[iTank].g_iWarpAbility == 0 || g_esWarpCache[iTank].g_iWarpAbility == 1)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vWarpAbility(iTank, false, .pos = iPos);

	return Plugin_Continue;
}

Action tTimerWarpCombo3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esWarpAbility[g_esWarpPlayer[iTank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esWarpPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esWarpCache[iTank].g_iWarpHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esWarpCache[iTank].g_iWarpHitMode == 0 || g_esWarpCache[iTank].g_iWarpHitMode == 1) && (StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vWarpHit(iSurvivor, iTank, flRandom, flChance, g_esWarpCache[iTank].g_iWarpHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esWarpCache[iTank].g_iWarpHitMode == 0 || g_esWarpCache[iTank].g_iWarpHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vWarpHit(iSurvivor, iTank, flRandom, flChance, g_esWarpCache[iTank].g_iWarpHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}

	return Plugin_Continue;
}

Action tTimerWarp(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esWarpCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esWarpPlayer[iTank].g_iTankType) || (g_esWarpCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esWarpCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esWarpAbility[g_esWarpPlayer[iTank].g_iTankType].g_iAccessFlags, g_esWarpPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esWarpPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esWarpPlayer[iTank].g_iTankType || (g_esWarpCache[iTank].g_iWarpAbility != 2 && g_esWarpCache[iTank].g_iWarpAbility != 3) || !g_esWarpPlayer[iTank].g_bActivated)
	{
		g_esWarpPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	int iTime = pack.ReadCell(), iCurrentTime = GetTime();
	if (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_esWarpCache[iTank].g_iHumanAbility == 1 && g_esWarpCache[iTank].g_iHumanMode == 0 && (iTime + g_esWarpCache[iTank].g_iHumanDuration) < iCurrentTime && (g_esWarpPlayer[iTank].g_iCooldown == -1 || g_esWarpPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vWarpReset2(iTank);

		return Plugin_Stop;
	}

	switch (g_esWarpCache[iTank].g_iWarpMode)
	{
		case 0, 1:
		{
			int iSurvivor = iGetRandomSurvivor(iTank);
			if (bIsSurvivor(iSurvivor) && !bIsSurvivorDisabled(iSurvivor) && !bIsInsideSaferoom(iSurvivor))
			{
				vWarp2(iTank, iSurvivor);
			}
		}
		case 2, 3:
		{
			int iTank2 = iGetRandomTank(iTank);
			if (bIsTank(iTank2))
			{
				vWarp2(iTank, iTank2);
			}
		}
	}

	return Plugin_Continue;
}