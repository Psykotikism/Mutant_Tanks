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

#define MT_RESTART_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_RESTART_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Restart Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank forces survivors to restart at the beginning of the map or near a teammate with a new loadout.",
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
			strcopy(error, err_max, "\"[MT] Restart Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_GAMEDATA "mutant_tanks"

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#else
	#if MT_RESTART_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_RESTART_SECTION "restartability"
#define MT_RESTART_SECTION2 "restart ability"
#define MT_RESTART_SECTION3 "restart_ability"
#define MT_RESTART_SECTION4 "restart"

#define MT_MENU_RESTART "Restart Ability"

enum struct esRestartGeneral
{
	Handle g_hSDKGetLastKnownArea;

	int g_iFlowOffset;
}

esRestartGeneral g_esRestartGeneral;

enum struct esRestartPlayer
{
	bool g_bCheckpoint;
	bool g_bFailed;
	bool g_bNoAmmo;
	bool g_bRecorded;

	char g_sRestartLoadout[325];

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;
	float g_flSpawnPosition[3];

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartCooldown;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
	int g_iRestartRangeCooldown;
	int g_iRestartSight;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esRestartPlayer g_esRestartPlayer[MAXPLAYERS + 1];

enum struct esRestartTeammate
{
	char g_sRestartLoadout[325];

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartCooldown;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
	int g_iRestartRangeCooldown;
	int g_iRestartSight;
}

esRestartTeammate g_esRestartTeammate[MAXPLAYERS + 1];

enum struct esRestartAbility
{
	char g_sRestartLoadout[325];

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartCooldown;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
	int g_iRestartRangeCooldown;
	int g_iRestartSight;
}

esRestartAbility g_esRestartAbility[MT_MAXTYPES + 1];

enum struct esRestartSpecial
{
	char g_sRestartLoadout[325];

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartCooldown;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
	int g_iRestartRangeCooldown;
	int g_iRestartSight;
}

esRestartSpecial g_esRestartSpecial[MT_MAXTYPES + 1];

enum struct esRestartCache
{
	char g_sRestartLoadout[325];

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartCooldown;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
	int g_iRestartRangeCooldown;
	int g_iRestartSight;
}

esRestartCache g_esRestartCache[MAXPLAYERS + 1];

#if defined MT_ABILITIES_MAIN2
void vRestartAllPluginsLoaded(GameData gdMutantTanks)
#else
public void OnAllPluginsLoaded()
#endif
{
#if !defined MT_ABILITIES_MAIN2
	GameData gdMutantTanks = new GameData(MT_GAMEDATA);
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"%s\" gamedata file.", MT_GAMEDATA);
	}
#endif
	g_esRestartGeneral.g_iFlowOffset = gdMutantTanks.GetOffset("CTerrorPlayer::GetFlowDistance::m_flow");
	if (g_esRestartGeneral.g_iFlowOffset == -1)
	{
#if defined MT_ABILITIES_MAIN2
		delete gdMutantTanks;

		LogError("%s Failed to load offset: CTerrorPlayer::GetFlowDistance::m_flow", MT_TAG);
#else
		SetFailState("Failed to load offset: CTerrorPlayer::GetFlowDistance::m_flow");
#endif
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CTerrorPlayer::GetLastKnownArea"))
	{
		delete gdMutantTanks;
#if defined MT_ABILITIES_MAIN2
		LogError("%s Failed to load offset: CTerrorPlayer::GetLastKnownArea", MT_TAG);
#else
		SetFailState("Failed to load offset: CTerrorPlayer::GetLastKnownArea");
#endif
	}
	else
	{
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		g_esRestartGeneral.g_hSDKGetLastKnownArea = EndPrepSDKCall();
		if (g_esRestartGeneral.g_hSDKGetLastKnownArea == null)
		{
#if defined MT_ABILITIES_MAIN2
			LogError("%s Your \"CTerrorPlayer::GetLastKnownArea\" offsets are outdated.", MT_TAG);
#else
			SetFailState("Your \"CTerrorPlayer::GetLastKnownArea\" offsets are outdated.");
#endif
		}
	}
#if !defined MT_ABILITIES_MAIN2
	delete gdMutantTanks;
#endif
}

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_restart", cmdRestartInfo, "View information about the Restart ability.");

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
void vRestartMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheSound(SOUND_ELECTRICITY, true);

	vRestartReset();
}

#if defined MT_ABILITIES_MAIN2
void vRestartClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnRestartTakeDamage);
	vRemoveRestart(client);
}

#if defined MT_ABILITIES_MAIN2
void vRestartClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveRestart(client);
}

#if defined MT_ABILITIES_MAIN2
void vRestartMapEnd()
#else
public void OnMapEnd()
#endif
{
	vRestartReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdRestartInfo(int client, int args)
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
		case false: vRestartMenu(client, MT_RESTART_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vRestartMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_RESTART_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iRestartMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Restart Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iRestartMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esRestartCache[param1].g_iRestartAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esRestartCache[param1].g_iHumanAmmo - g_esRestartPlayer[param1].g_iAmmoCount), g_esRestartCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esRestartCache[param1].g_iHumanAbility == 1) ? g_esRestartCache[param1].g_iHumanCooldown : g_esRestartCache[param1].g_iRestartCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RestartDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esRestartCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esRestartCache[param1].g_iHumanAbility == 1) ? g_esRestartCache[param1].g_iHumanRangeCooldown : g_esRestartCache[param1].g_iRestartRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vRestartMenu(param1, MT_RESTART_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pRestart = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "RestartMenu", param1);
			pRestart.SetTitle(sMenuTitle);
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
void vRestartDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_RESTART, MT_MENU_RESTART);
}

#if defined MT_ABILITIES_MAIN2
void vRestartMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_RESTART, false))
	{
		vRestartMenu(client, MT_RESTART_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRestartMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_RESTART, false))
	{
		FormatEx(buffer, size, "%T", "RestartMenu2", client);
	}
}

Action OnRestartTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esRestartCache[attacker].g_iRestartHitMode == 0 || g_esRestartCache[attacker].g_iRestartHitMode == 1) && bIsSurvivor(victim) && g_esRestartCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esRestartAbility[g_esRestartPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esRestartPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esRestartPlayer[attacker].g_iTankType, g_esRestartAbility[g_esRestartPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esRestartPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRestartHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esRestartCache[attacker].g_flRestartChance, g_esRestartCache[attacker].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esRestartCache[victim].g_iRestartHitMode == 0 || g_esRestartCache[victim].g_iRestartHitMode == 2) && bIsSurvivor(attacker) && g_esRestartCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esRestartAbility[g_esRestartPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esRestartPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esRestartPlayer[victim].g_iTankType, g_esRestartAbility[g_esRestartPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esRestartPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vRestartHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esRestartCache[victim].g_flRestartChance, g_esRestartCache[victim].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vRestartPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_RESTART);
}

#if defined MT_ABILITIES_MAIN2
void vRestartAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_RESTART_SECTION);
	list2.PushString(MT_RESTART_SECTION2);
	list3.PushString(MT_RESTART_SECTION3);
	list4.PushString(MT_RESTART_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vRestartCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_RESTART_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_RESTART_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_RESTART_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_RESTART_SECTION4);
	if (g_esRestartCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_RESTART_SECTION, false) || StrEqual(sSubset[iPos], MT_RESTART_SECTION2, false) || StrEqual(sSubset[iPos], MT_RESTART_SECTION3, false) || StrEqual(sSubset[iPos], MT_RESTART_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esRestartCache[tank].g_iRestartAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vRestartAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerRestartCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
								if ((g_esRestartCache[tank].g_iRestartHitMode == 0 || g_esRestartCache[tank].g_iRestartHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vRestartHit(survivor, tank, random, flChance, g_esRestartCache[tank].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esRestartCache[tank].g_iRestartHitMode == 0 || g_esRestartCache[tank].g_iRestartHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vRestartHit(survivor, tank, random, flChance, g_esRestartCache[tank].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerRestartCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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

#if defined MT_ABILITIES_MAIN2
void vRestartConfigsLoad(int mode)
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
				g_esRestartAbility[iIndex].g_iAccessFlags = 0;
				g_esRestartAbility[iIndex].g_iImmunityFlags = 0;
				g_esRestartAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esRestartAbility[iIndex].g_iComboAbility = 0;
				g_esRestartAbility[iIndex].g_iHumanAbility = 0;
				g_esRestartAbility[iIndex].g_iHumanAmmo = 5;
				g_esRestartAbility[iIndex].g_iHumanCooldown = 0;
				g_esRestartAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esRestartAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esRestartAbility[iIndex].g_iRequiresHumans = 0;
				g_esRestartAbility[iIndex].g_iRestartAbility = 0;
				g_esRestartAbility[iIndex].g_iRestartEffect = 0;
				g_esRestartAbility[iIndex].g_iRestartMessage = 0;
				g_esRestartAbility[iIndex].g_flRestartChance = 33.3;
				g_esRestartAbility[iIndex].g_iRestartCooldown = 0;
				g_esRestartAbility[iIndex].g_iRestartHit = 0;
				g_esRestartAbility[iIndex].g_iRestartHitMode = 0;
				g_esRestartAbility[iIndex].g_sRestartLoadout = "smg,pistol,pain_pills";
				g_esRestartAbility[iIndex].g_iRestartMode = 1;
				g_esRestartAbility[iIndex].g_flRestartRange = 150.0;
				g_esRestartAbility[iIndex].g_flRestartRangeChance = 15.0;
				g_esRestartAbility[iIndex].g_iRestartRangeCooldown = 0;
				g_esRestartAbility[iIndex].g_iRestartSight = 0;

				g_esRestartSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esRestartSpecial[iIndex].g_iComboAbility = -1;
				g_esRestartSpecial[iIndex].g_iHumanAbility = -1;
				g_esRestartSpecial[iIndex].g_iHumanAmmo = -1;
				g_esRestartSpecial[iIndex].g_iHumanCooldown = -1;
				g_esRestartSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esRestartSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esRestartSpecial[iIndex].g_iRequiresHumans = -1;
				g_esRestartSpecial[iIndex].g_iRestartAbility = -1;
				g_esRestartSpecial[iIndex].g_iRestartEffect = -1;
				g_esRestartSpecial[iIndex].g_iRestartMessage = -1;
				g_esRestartSpecial[iIndex].g_flRestartChance = -1.0;
				g_esRestartSpecial[iIndex].g_iRestartCooldown = -1;
				g_esRestartSpecial[iIndex].g_iRestartHit = -1;
				g_esRestartSpecial[iIndex].g_iRestartHitMode = -1;
				g_esRestartSpecial[iIndex].g_sRestartLoadout[0] = '\0';
				g_esRestartSpecial[iIndex].g_iRestartMode = -1;
				g_esRestartSpecial[iIndex].g_flRestartRange = -1.0;
				g_esRestartSpecial[iIndex].g_flRestartRangeChance = -1.0;
				g_esRestartSpecial[iIndex].g_iRestartRangeCooldown = -1;
				g_esRestartSpecial[iIndex].g_iRestartSight = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esRestartPlayer[iPlayer].g_iAccessFlags = -1;
				g_esRestartPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esRestartPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esRestartPlayer[iPlayer].g_iComboAbility = -1;
				g_esRestartPlayer[iPlayer].g_iHumanAbility = -1;
				g_esRestartPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esRestartPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esRestartPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esRestartPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esRestartPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esRestartPlayer[iPlayer].g_iRestartAbility = -1;
				g_esRestartPlayer[iPlayer].g_iRestartEffect = -1;
				g_esRestartPlayer[iPlayer].g_iRestartMessage = -1;
				g_esRestartPlayer[iPlayer].g_flRestartChance = -1.0;
				g_esRestartPlayer[iPlayer].g_iRestartCooldown = -1;
				g_esRestartPlayer[iPlayer].g_iRestartHit = -1;
				g_esRestartPlayer[iPlayer].g_iRestartHitMode = -1;
				g_esRestartPlayer[iPlayer].g_sRestartLoadout[0] = '\0';
				g_esRestartPlayer[iPlayer].g_iRestartMode = -1;
				g_esRestartPlayer[iPlayer].g_flRestartRange = -1.0;
				g_esRestartPlayer[iPlayer].g_flRestartRangeChance = -1.0;
				g_esRestartPlayer[iPlayer].g_iRestartRangeCooldown = -1;
				g_esRestartPlayer[iPlayer].g_iRestartSight = -1;

				g_esRestartTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esRestartTeammate[iPlayer].g_iComboAbility = -1;
				g_esRestartTeammate[iPlayer].g_iHumanAbility = -1;
				g_esRestartTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esRestartTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esRestartTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esRestartTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esRestartTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esRestartTeammate[iPlayer].g_iRestartAbility = -1;
				g_esRestartTeammate[iPlayer].g_iRestartEffect = -1;
				g_esRestartTeammate[iPlayer].g_iRestartMessage = -1;
				g_esRestartTeammate[iPlayer].g_flRestartChance = -1.0;
				g_esRestartTeammate[iPlayer].g_iRestartCooldown = -1;
				g_esRestartTeammate[iPlayer].g_iRestartHit = -1;
				g_esRestartTeammate[iPlayer].g_iRestartHitMode = -1;
				g_esRestartTeammate[iPlayer].g_sRestartLoadout[0] = '\0';
				g_esRestartTeammate[iPlayer].g_iRestartMode = -1;
				g_esRestartTeammate[iPlayer].g_flRestartRange = -1.0;
				g_esRestartTeammate[iPlayer].g_flRestartRangeChance = -1.0;
				g_esRestartTeammate[iPlayer].g_iRestartRangeCooldown = -1;
				g_esRestartTeammate[iPlayer].g_iRestartSight = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRestartConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esRestartTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRestartTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRestartTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRestartTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esRestartTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRestartTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esRestartTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRestartTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esRestartTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRestartTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esRestartTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esRestartTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esRestartTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRestartTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRestartTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRestartTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esRestartTeammate[admin].g_iRestartAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRestartTeammate[admin].g_iRestartAbility, value, -1, 1);
			g_esRestartTeammate[admin].g_iRestartEffect = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRestartTeammate[admin].g_iRestartEffect, value, -1, 7);
			g_esRestartTeammate[admin].g_iRestartMessage = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRestartTeammate[admin].g_iRestartMessage, value, -1, 3);
			g_esRestartTeammate[admin].g_iRestartSight = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRestartTeammate[admin].g_iRestartSight, value, -1, 5);
			g_esRestartTeammate[admin].g_flRestartChance = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartChance", "Restart Chance", "Restart_Chance", "chance", g_esRestartTeammate[admin].g_flRestartChance, value, -1.0, 100.0);
			g_esRestartTeammate[admin].g_iRestartCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartCooldown", "Restart Cooldown", "Restart_Cooldown", "cooldown", g_esRestartTeammate[admin].g_iRestartCooldown, value, -1, 99999);
			g_esRestartTeammate[admin].g_iRestartHit = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartHit", "Restart Hit", "Restart_Hit", "hit", g_esRestartTeammate[admin].g_iRestartHit, value, -1, 1);
			g_esRestartTeammate[admin].g_iRestartHitMode = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartHitMode", "Restart Hit Mode", "Restart_Hit_Mode", "hitmode", g_esRestartTeammate[admin].g_iRestartHitMode, value, -1, 2);
			g_esRestartTeammate[admin].g_iRestartMode = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartMode", "Restart Mode", "Restart_Mode", "mode", g_esRestartTeammate[admin].g_iRestartMode, value, -1, 1);
			g_esRestartTeammate[admin].g_flRestartRange = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRange", "Restart Range", "Restart_Range", "range", g_esRestartTeammate[admin].g_flRestartRange, value, -1.0, 99999.0);
			g_esRestartTeammate[admin].g_flRestartRangeChance = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRangeChance", "Restart Range Chance", "Restart_Range_Chance", "rangechance", g_esRestartTeammate[admin].g_flRestartRangeChance, value, -1.0, 100.0);
			g_esRestartTeammate[admin].g_iRestartRangeCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRangeCooldown", "Restart Range Cooldown", "Restart_Range_Cooldown", "rangecooldown", g_esRestartTeammate[admin].g_iRestartRangeCooldown, value, -1, 99999);

			vGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartLoadout", "Restart Loadout", "Restart_Loadout", "loadout", g_esRestartTeammate[admin].g_sRestartLoadout, sizeof esRestartTeammate::g_sRestartLoadout, value);
		}
		else
		{
			g_esRestartPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRestartPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRestartPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRestartPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esRestartPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRestartPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esRestartPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRestartPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esRestartPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRestartPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esRestartPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esRestartPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esRestartPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRestartPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRestartPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRestartPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esRestartPlayer[admin].g_iRestartAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRestartPlayer[admin].g_iRestartAbility, value, -1, 1);
			g_esRestartPlayer[admin].g_iRestartEffect = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRestartPlayer[admin].g_iRestartEffect, value, -1, 7);
			g_esRestartPlayer[admin].g_iRestartMessage = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRestartPlayer[admin].g_iRestartMessage, value, -1, 3);
			g_esRestartPlayer[admin].g_iRestartSight = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRestartPlayer[admin].g_iRestartSight, value, -1, 5);
			g_esRestartPlayer[admin].g_flRestartChance = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartChance", "Restart Chance", "Restart_Chance", "chance", g_esRestartPlayer[admin].g_flRestartChance, value, -1.0, 100.0);
			g_esRestartPlayer[admin].g_iRestartCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartCooldown", "Restart Cooldown", "Restart_Cooldown", "cooldown", g_esRestartPlayer[admin].g_iRestartCooldown, value, -1, 99999);
			g_esRestartPlayer[admin].g_iRestartHit = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartHit", "Restart Hit", "Restart_Hit", "hit", g_esRestartPlayer[admin].g_iRestartHit, value, -1, 1);
			g_esRestartPlayer[admin].g_iRestartHitMode = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartHitMode", "Restart Hit Mode", "Restart_Hit_Mode", "hitmode", g_esRestartPlayer[admin].g_iRestartHitMode, value, -1, 2);
			g_esRestartPlayer[admin].g_iRestartMode = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartMode", "Restart Mode", "Restart_Mode", "mode", g_esRestartPlayer[admin].g_iRestartMode, value, -1, 1);
			g_esRestartPlayer[admin].g_flRestartRange = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRange", "Restart Range", "Restart_Range", "range", g_esRestartPlayer[admin].g_flRestartRange, value, -1.0, 99999.0);
			g_esRestartPlayer[admin].g_flRestartRangeChance = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRangeChance", "Restart Range Chance", "Restart_Range_Chance", "rangechance", g_esRestartPlayer[admin].g_flRestartRangeChance, value, -1.0, 100.0);
			g_esRestartPlayer[admin].g_iRestartRangeCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRangeCooldown", "Restart Range Cooldown", "Restart_Range_Cooldown", "rangecooldown", g_esRestartPlayer[admin].g_iRestartRangeCooldown, value, -1, 99999);
			g_esRestartPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esRestartPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);

			vGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartLoadout", "Restart Loadout", "Restart_Loadout", "loadout", g_esRestartPlayer[admin].g_sRestartLoadout, sizeof esRestartPlayer::g_sRestartLoadout, value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esRestartSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRestartSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRestartSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRestartSpecial[type].g_iComboAbility, value, -1, 1);
			g_esRestartSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRestartSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esRestartSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRestartSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esRestartSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRestartSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esRestartSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esRestartSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esRestartSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRestartSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRestartSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRestartSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esRestartSpecial[type].g_iRestartAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRestartSpecial[type].g_iRestartAbility, value, -1, 1);
			g_esRestartSpecial[type].g_iRestartEffect = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRestartSpecial[type].g_iRestartEffect, value, -1, 7);
			g_esRestartSpecial[type].g_iRestartMessage = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRestartSpecial[type].g_iRestartMessage, value, -1, 3);
			g_esRestartSpecial[type].g_iRestartSight = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRestartSpecial[type].g_iRestartSight, value, -1, 5);
			g_esRestartSpecial[type].g_flRestartChance = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartChance", "Restart Chance", "Restart_Chance", "chance", g_esRestartSpecial[type].g_flRestartChance, value, -1.0, 100.0);
			g_esRestartSpecial[type].g_iRestartCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartCooldown", "Restart Cooldown", "Restart_Cooldown", "cooldown", g_esRestartSpecial[type].g_iRestartCooldown, value, -1, 99999);
			g_esRestartSpecial[type].g_iRestartHit = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartHit", "Restart Hit", "Restart_Hit", "hit", g_esRestartSpecial[type].g_iRestartHit, value, -1, 1);
			g_esRestartSpecial[type].g_iRestartHitMode = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartHitMode", "Restart Hit Mode", "Restart_Hit_Mode", "hitmode", g_esRestartSpecial[type].g_iRestartHitMode, value, -1, 2);
			g_esRestartSpecial[type].g_iRestartMode = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartMode", "Restart Mode", "Restart_Mode", "mode", g_esRestartSpecial[type].g_iRestartMode, value, -1, 1);
			g_esRestartSpecial[type].g_flRestartRange = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRange", "Restart Range", "Restart_Range", "range", g_esRestartSpecial[type].g_flRestartRange, value, -1.0, 99999.0);
			g_esRestartSpecial[type].g_flRestartRangeChance = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRangeChance", "Restart Range Chance", "Restart_Range_Chance", "rangechance", g_esRestartSpecial[type].g_flRestartRangeChance, value, -1.0, 100.0);
			g_esRestartSpecial[type].g_iRestartRangeCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRangeCooldown", "Restart Range Cooldown", "Restart_Range_Cooldown", "rangecooldown", g_esRestartSpecial[type].g_iRestartRangeCooldown, value, -1, 99999);

			vGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartLoadout", "Restart Loadout", "Restart_Loadout", "loadout", g_esRestartSpecial[type].g_sRestartLoadout, sizeof esRestartSpecial::g_sRestartLoadout, value);
		}
		else
		{
			g_esRestartAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRestartAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRestartAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRestartAbility[type].g_iComboAbility, value, -1, 1);
			g_esRestartAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRestartAbility[type].g_iHumanAbility, value, -1, 2);
			g_esRestartAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRestartAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esRestartAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRestartAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esRestartAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esRestartAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esRestartAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRestartAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRestartAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRestartAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esRestartAbility[type].g_iRestartAbility = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRestartAbility[type].g_iRestartAbility, value, -1, 1);
			g_esRestartAbility[type].g_iRestartEffect = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRestartAbility[type].g_iRestartEffect, value, -1, 7);
			g_esRestartAbility[type].g_iRestartMessage = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRestartAbility[type].g_iRestartMessage, value, -1, 3);
			g_esRestartAbility[type].g_iRestartSight = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRestartAbility[type].g_iRestartSight, value, -1, 5);
			g_esRestartAbility[type].g_flRestartChance = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartChance", "Restart Chance", "Restart_Chance", "chance", g_esRestartAbility[type].g_flRestartChance, value, -1.0, 100.0);
			g_esRestartAbility[type].g_iRestartCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartCooldown", "Restart Cooldown", "Restart_Cooldown", "cooldown", g_esRestartAbility[type].g_iRestartCooldown, value, -1, 99999);
			g_esRestartAbility[type].g_iRestartHit = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartHit", "Restart Hit", "Restart_Hit", "hit", g_esRestartAbility[type].g_iRestartHit, value, -1, 1);
			g_esRestartAbility[type].g_iRestartHitMode = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartHitMode", "Restart Hit Mode", "Restart_Hit_Mode", "hitmode", g_esRestartAbility[type].g_iRestartHitMode, value, -1, 2);
			g_esRestartAbility[type].g_iRestartMode = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartMode", "Restart Mode", "Restart_Mode", "mode", g_esRestartAbility[type].g_iRestartMode, value, -1, 1);
			g_esRestartAbility[type].g_flRestartRange = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRange", "Restart Range", "Restart_Range", "range", g_esRestartAbility[type].g_flRestartRange, value, -1.0, 99999.0);
			g_esRestartAbility[type].g_flRestartRangeChance = flGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRangeChance", "Restart Range Chance", "Restart_Range_Chance", "rangechance", g_esRestartAbility[type].g_flRestartRangeChance, value, -1.0, 100.0);
			g_esRestartAbility[type].g_iRestartRangeCooldown = iGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartRangeCooldown", "Restart Range Cooldown", "Restart_Range_Cooldown", "rangecooldown", g_esRestartAbility[type].g_iRestartRangeCooldown, value, -1, 99999);
			g_esRestartAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esRestartAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);

			vGetKeyValue(subsection, MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4, key, "RestartLoadout", "Restart Loadout", "Restart_Loadout", "loadout", g_esRestartAbility[type].g_sRestartLoadout, sizeof esRestartAbility::g_sRestartLoadout, value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRestartSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esRestartPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esRestartPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esRestartPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esRestartCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_flCloseAreasOnly, g_esRestartPlayer[tank].g_flCloseAreasOnly, g_esRestartSpecial[iType].g_flCloseAreasOnly, g_esRestartAbility[iType].g_flCloseAreasOnly, 1);
		g_esRestartCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iComboAbility, g_esRestartPlayer[tank].g_iComboAbility, g_esRestartSpecial[iType].g_iComboAbility, g_esRestartAbility[iType].g_iComboAbility, 1);
		g_esRestartCache[tank].g_flRestartChance = flGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_flRestartChance, g_esRestartPlayer[tank].g_flRestartChance, g_esRestartSpecial[iType].g_flRestartChance, g_esRestartAbility[iType].g_flRestartChance, 1);
		g_esRestartCache[tank].g_flRestartRange = flGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_flRestartRange, g_esRestartPlayer[tank].g_flRestartRange, g_esRestartSpecial[iType].g_flRestartRange, g_esRestartAbility[iType].g_flRestartRange, 1);
		g_esRestartCache[tank].g_flRestartRangeChance = flGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_flRestartRangeChance, g_esRestartPlayer[tank].g_flRestartRangeChance, g_esRestartSpecial[iType].g_flRestartRangeChance, g_esRestartAbility[iType].g_flRestartRangeChance, 1);
		g_esRestartCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iHumanAbility, g_esRestartPlayer[tank].g_iHumanAbility, g_esRestartSpecial[iType].g_iHumanAbility, g_esRestartAbility[iType].g_iHumanAbility, 1);
		g_esRestartCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iHumanAmmo, g_esRestartPlayer[tank].g_iHumanAmmo, g_esRestartSpecial[iType].g_iHumanAmmo, g_esRestartAbility[iType].g_iHumanAmmo, 1);
		g_esRestartCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iHumanCooldown, g_esRestartPlayer[tank].g_iHumanCooldown, g_esRestartSpecial[iType].g_iHumanCooldown, g_esRestartAbility[iType].g_iHumanCooldown, 1);
		g_esRestartCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iHumanRangeCooldown, g_esRestartPlayer[tank].g_iHumanRangeCooldown, g_esRestartSpecial[iType].g_iHumanRangeCooldown, g_esRestartAbility[iType].g_iHumanRangeCooldown, 1);
		g_esRestartCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_flOpenAreasOnly, g_esRestartPlayer[tank].g_flOpenAreasOnly, g_esRestartSpecial[iType].g_flOpenAreasOnly, g_esRestartAbility[iType].g_flOpenAreasOnly, 1);
		g_esRestartCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRequiresHumans, g_esRestartPlayer[tank].g_iRequiresHumans, g_esRestartSpecial[iType].g_iRequiresHumans, g_esRestartAbility[iType].g_iRequiresHumans, 1);
		g_esRestartCache[tank].g_iRestartAbility = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRestartAbility, g_esRestartPlayer[tank].g_iRestartAbility, g_esRestartSpecial[iType].g_iRestartAbility, g_esRestartAbility[iType].g_iRestartAbility, 1);
		g_esRestartCache[tank].g_iRestartCooldown = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRestartCooldown, g_esRestartPlayer[tank].g_iRestartCooldown, g_esRestartSpecial[iType].g_iRestartCooldown, g_esRestartAbility[iType].g_iRestartCooldown, 1);
		g_esRestartCache[tank].g_iRestartEffect = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRestartEffect, g_esRestartPlayer[tank].g_iRestartEffect, g_esRestartSpecial[iType].g_iRestartEffect, g_esRestartAbility[iType].g_iRestartEffect, 1);
		g_esRestartCache[tank].g_iRestartHit = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRestartHit, g_esRestartPlayer[tank].g_iRestartHit, g_esRestartSpecial[iType].g_iRestartHit, g_esRestartAbility[iType].g_iRestartHit, 1);
		g_esRestartCache[tank].g_iRestartHitMode = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRestartHitMode, g_esRestartPlayer[tank].g_iRestartHitMode, g_esRestartSpecial[iType].g_iRestartHitMode, g_esRestartAbility[iType].g_iRestartHitMode, 1);
		g_esRestartCache[tank].g_iRestartMessage = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRestartMessage, g_esRestartPlayer[tank].g_iRestartMessage, g_esRestartSpecial[iType].g_iRestartMessage, g_esRestartAbility[iType].g_iRestartMessage, 1);
		g_esRestartCache[tank].g_iRestartMode = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRestartMode, g_esRestartPlayer[tank].g_iRestartMode, g_esRestartSpecial[iType].g_iRestartMode, g_esRestartAbility[iType].g_iRestartMode, 1);
		g_esRestartCache[tank].g_iRestartRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRestartRangeCooldown, g_esRestartPlayer[tank].g_iRestartRangeCooldown, g_esRestartSpecial[iType].g_iRestartRangeCooldown, g_esRestartAbility[iType].g_iRestartRangeCooldown, 1);
		g_esRestartCache[tank].g_iRestartSight = iGetSubSettingValue(apply, bHuman, g_esRestartTeammate[tank].g_iRestartSight, g_esRestartPlayer[tank].g_iRestartSight, g_esRestartSpecial[iType].g_iRestartSight, g_esRestartAbility[iType].g_iRestartSight, 1);

		vGetSubSettingValue(apply, bHuman, g_esRestartCache[tank].g_sRestartLoadout, sizeof esRestartCache::g_sRestartLoadout, g_esRestartTeammate[tank].g_sRestartLoadout, g_esRestartPlayer[tank].g_sRestartLoadout, g_esRestartSpecial[iType].g_sRestartLoadout, g_esRestartAbility[iType].g_sRestartLoadout);
	}
	else
	{
		g_esRestartCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_flCloseAreasOnly, g_esRestartAbility[iType].g_flCloseAreasOnly, 1);
		g_esRestartCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iComboAbility, g_esRestartAbility[iType].g_iComboAbility, 1);
		g_esRestartCache[tank].g_flRestartChance = flGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_flRestartChance, g_esRestartAbility[iType].g_flRestartChance, 1);
		g_esRestartCache[tank].g_flRestartRange = flGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_flRestartRange, g_esRestartAbility[iType].g_flRestartRange, 1);
		g_esRestartCache[tank].g_flRestartRangeChance = flGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_flRestartRangeChance, g_esRestartAbility[iType].g_flRestartRangeChance, 1);
		g_esRestartCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iHumanAbility, g_esRestartAbility[iType].g_iHumanAbility, 1);
		g_esRestartCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iHumanAmmo, g_esRestartAbility[iType].g_iHumanAmmo, 1);
		g_esRestartCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iHumanCooldown, g_esRestartAbility[iType].g_iHumanCooldown, 1);
		g_esRestartCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iHumanRangeCooldown, g_esRestartAbility[iType].g_iHumanRangeCooldown, 1);
		g_esRestartCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_flOpenAreasOnly, g_esRestartAbility[iType].g_flOpenAreasOnly, 1);
		g_esRestartCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRequiresHumans, g_esRestartAbility[iType].g_iRequiresHumans, 1);
		g_esRestartCache[tank].g_iRestartAbility = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartAbility, g_esRestartAbility[iType].g_iRestartAbility, 1);
		g_esRestartCache[tank].g_iRestartCooldown = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartCooldown, g_esRestartAbility[iType].g_iRestartCooldown, 1);
		g_esRestartCache[tank].g_iRestartEffect = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartEffect, g_esRestartAbility[iType].g_iRestartEffect, 1);
		g_esRestartCache[tank].g_iRestartHit = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartHit, g_esRestartAbility[iType].g_iRestartHit, 1);
		g_esRestartCache[tank].g_iRestartHitMode = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartHitMode, g_esRestartAbility[iType].g_iRestartHitMode, 1);
		g_esRestartCache[tank].g_iRestartMessage = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartMessage, g_esRestartAbility[iType].g_iRestartMessage, 1);
		g_esRestartCache[tank].g_iRestartMode = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartMode, g_esRestartAbility[iType].g_iRestartMode, 1);
		g_esRestartCache[tank].g_iRestartRangeCooldown = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartRangeCooldown, g_esRestartAbility[iType].g_iRestartRangeCooldown, 1);
		g_esRestartCache[tank].g_iRestartSight = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartSight, g_esRestartAbility[iType].g_iRestartSight, 1);

		vGetSettingValue(apply, bHuman, g_esRestartCache[tank].g_sRestartLoadout, sizeof esRestartCache::g_sRestartLoadout, g_esRestartPlayer[tank].g_sRestartLoadout, g_esRestartAbility[iType].g_sRestartLoadout);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRestartCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vRestartCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveRestart(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vRestartHookEvent(bool hooked)
#else
public void MT_OnHookEvent(bool hooked)
#endif
{
	static bool bCheck[3];

	switch (hooked)
	{
		case true:
		{
			bCheck[0] = HookEventEx("player_entered_checkpoint", MT_OnEventFired);
			bCheck[1] = HookEventEx("player_left_checkpoint", MT_OnEventFired);

			if (!g_bSecondGame)
			{
				bCheck[2] = HookEventEx("player_entered_start_area", MT_OnEventFired);
			}
		}
		case false:
		{
			char sEvent[32];
			for (int iPos = 0; iPos < (sizeof bCheck); iPos++)
			{
				switch (iPos)
				{
					case 0: sEvent = "player_entered_checkpoint";
					case 1: sEvent = "player_left_checkpoint";
					case 2: sEvent = "player_entered_start_area";
				}

				if (bCheck[iPos])
				{
					if (g_bSecondGame && iPos == 2)
					{
						continue;
					}

					UnhookEvent(sEvent, MT_OnEventFired);
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRestartEventFired(Event event, const char[] name)
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
			vRestartCopyStats2(iBot, iTank);
			vRemoveRestart(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost"))
	{
		vRestartReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vRestartCopyStats2(iTank, iBot);
			vRemoveRestart(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveRestart(iTank);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vRestartHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esRestartCache[iBoomer].g_flRestartChance, g_esRestartCache[iBoomer].g_iRestartHit, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);
		}
	}
	else if (StrEqual(name, "player_spawn"))
	{
		int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
		if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveRestart(iPlayer);
		}
		else if (bIsSurvivor(iPlayer) && !g_esRestartPlayer[iPlayer].g_bRecorded && bIsSurvivorInCheckpoint(iPlayer, true))
		{
			g_esRestartPlayer[iPlayer].g_bRecorded = true;

			GetClientAbsOrigin(iPlayer, g_esRestartPlayer[iPlayer].g_flSpawnPosition);
		}
	}
	else if (StrEqual(name, "player_left_checkpoint"))
	{
		g_esRestartPlayer[GetClientOfUserId(event.GetInt("userid"))].g_bCheckpoint = false;
	}
	else if (StrEqual(name, "player_entered_checkpoint") || StrEqual(name, "player_entered_start_area"))
	{
		g_esRestartPlayer[GetClientOfUserId(event.GetInt("userid"))].g_bCheckpoint = true;
	}
	else if (StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vRestartReset();

		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++ )
		{
			switch (bIsSurvivor(iPlayer, MT_CHECK_INGAME))
			{
				case true: g_esRestartPlayer[iPlayer].g_bCheckpoint = true;
				case false: g_esRestartPlayer[iPlayer].g_bCheckpoint = false;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRestartAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRestartPlayer[tank].g_iAccessFlags)) || g_esRestartCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esRestartCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esRestartCache[tank].g_iRestartAbility == 1 && g_esRestartCache[tank].g_iComboAbility == 0)
	{
		vRestartAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN2
void vRestartButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esRestartCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRestartCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRestartPlayer[tank].g_iTankType, tank) || (g_esRestartCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRestartCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRestartPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esRestartCache[tank].g_iRestartAbility == 1 && g_esRestartCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();

			switch (g_esRestartPlayer[tank].g_iRangeCooldown == -1 || g_esRestartPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vRestartAbility(tank, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman3", (g_esRestartPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRestartChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveRestart(tank);
}

void vRestartAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esRestartCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRestartCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRestartPlayer[tank].g_iTankType, tank) || (g_esRestartCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRestartCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRestartPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esRestartPlayer[tank].g_iAmmoCount < g_esRestartCache[tank].g_iHumanAmmo && g_esRestartCache[tank].g_iHumanAmmo > 0))
	{
		g_esRestartPlayer[tank].g_bFailed = false;
		g_esRestartPlayer[tank].g_bNoAmmo = false;

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esRestartCache[tank].g_flRestartRange,
			flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esRestartCache[tank].g_flRestartRangeChance;
		int iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esRestartPlayer[tank].g_iTankType, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esRestartPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esRestartCache[tank].g_iRestartSight, .range = flRange))
				{
					vRestartHit(iSurvivor, tank, random, flChance, g_esRestartCache[tank].g_iRestartAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman4");
			}
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartAmmo");
	}
}

void vRestartHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esRestartCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRestartCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRestartPlayer[tank].g_iTankType, tank) || (g_esRestartCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRestartCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRestartPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esRestartPlayer[tank].g_iTankType, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esRestartPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esRestartPlayer[tank].g_iRangeCooldown != -1 && g_esRestartPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esRestartPlayer[tank].g_iCooldown != -1 && g_esRestartPlayer[tank].g_iCooldown >= iTime))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !bIsSurvivorDisabled(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_GODMODE))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esRestartPlayer[tank].g_iAmmoCount < g_esRestartCache[tank].g_iHumanAmmo && g_esRestartCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esRestartCache[tank].g_iRestartSight, .range = 100.0))
				{
					return;
				}

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esRestartPlayer[tank].g_iRangeCooldown == -1 || g_esRestartPlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1)
					{
						g_esRestartPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman", g_esRestartPlayer[tank].g_iAmmoCount, g_esRestartCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esRestartCache[tank].g_iRestartRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1 && g_esRestartPlayer[tank].g_iAmmoCount < g_esRestartCache[tank].g_iHumanAmmo && g_esRestartCache[tank].g_iHumanAmmo > 0) ? g_esRestartCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esRestartPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esRestartPlayer[tank].g_iRangeCooldown != -1 && g_esRestartPlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman5", (g_esRestartPlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esRestartPlayer[tank].g_iCooldown == -1 || g_esRestartPlayer[tank].g_iCooldown <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esRestartCache[tank].g_iRestartCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1) ? g_esRestartCache[tank].g_iHumanCooldown : iCooldown;
					g_esRestartPlayer[tank].g_iCooldown = (iTime + iCooldown);
					if (g_esRestartPlayer[tank].g_iCooldown != -1 && g_esRestartPlayer[tank].g_iCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman5", (g_esRestartPlayer[tank].g_iCooldown - iTime));
					}
				}

				char sItems[5][64];
				ReplaceString(g_esRestartCache[tank].g_sRestartLoadout, sizeof esRestartAbility::g_sRestartLoadout, " ", "");
				ExplodeString(g_esRestartCache[tank].g_sRestartLoadout, ",", sItems, sizeof sItems, sizeof sItems[]);
				MT_RespawnSurvivor(survivor);
				vRemoveWeapons(survivor);
				vAttachParticle(survivor, PARTICLE_ELECTRICITY, 1.0);
				EmitSoundToAll(SOUND_ELECTRICITY, survivor);

				for (int iItem = 0; iItem < (sizeof sItems); iItem++)
				{
					if (sItems[iItem][0] != '\0')
					{
						vCheatCommand(survivor, "give", sItems[iItem]);
					}
				}

				bool bTeleport = true;
				if (bIsFinalMap() || !g_esRestartPlayer[survivor].g_bRecorded || g_esRestartCache[tank].g_iRestartMode == 1)
				{
					float flOrigin[3], flAngles[3];
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bIsSurvivorDisabled(iSurvivor) && iSurvivor != survivor)
						{
							bTeleport = false;

							GetClientAbsOrigin(iSurvivor, flOrigin);
							GetClientEyeAngles(iSurvivor, flAngles);
							TeleportEntity(survivor, flOrigin, flAngles);
							vFixPlayerPosition(iSurvivor);

							break;
						}
					}

					if (bTeleport)
					{
						TeleportEntity(survivor, g_esRestartPlayer[survivor].g_flSpawnPosition);
						vFixPlayerPosition(survivor);
					}
				}
				else
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esRestartPlayer[iSurvivor].g_bRecorded)
						{
							bTeleport = false;

							TeleportEntity(survivor, g_esRestartPlayer[iSurvivor].g_flSpawnPosition);
							vFixPlayerPosition(survivor);

							break;
						}
					}

					if (bTeleport)
					{
						TeleportEntity(survivor, g_esRestartPlayer[survivor].g_flSpawnPosition);
						vFixPlayerPosition(survivor);
					}
				}

				vScreenEffect(survivor, tank, g_esRestartCache[tank].g_iRestartEffect, flags);

				if (g_esRestartCache[tank].g_iRestartMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Restart", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Restart", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esRestartPlayer[tank].g_iRangeCooldown == -1 || g_esRestartPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1 && !g_esRestartPlayer[tank].g_bFailed)
				{
					g_esRestartPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman2");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1 && !g_esRestartPlayer[tank].g_bNoAmmo)
		{
			g_esRestartPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartAmmo");
		}
	}
}

void vRestartCopyStats2(int oldTank, int newTank)
{
	g_esRestartPlayer[newTank].g_iAmmoCount = g_esRestartPlayer[oldTank].g_iAmmoCount;
	g_esRestartPlayer[newTank].g_iCooldown = g_esRestartPlayer[oldTank].g_iCooldown;
	g_esRestartPlayer[newTank].g_iRangeCooldown = g_esRestartPlayer[oldTank].g_iRangeCooldown;
}

void vRemoveRestart(int tank)
{
	g_esRestartPlayer[tank].g_bFailed = false;
	g_esRestartPlayer[tank].g_bNoAmmo = false;
	g_esRestartPlayer[tank].g_bRecorded = false;
	g_esRestartPlayer[tank].g_iAmmoCount = 0;
	g_esRestartPlayer[tank].g_iCooldown = -1;
	g_esRestartPlayer[tank].g_iRangeCooldown = -1;
}

void vRestartReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveRestart(iPlayer);
		}
	}
}

bool bIsSurvivorInCheckpoint(int survivor, bool start)
{
	bool bReturn = false;
	if (g_esRestartPlayer[survivor].g_bCheckpoint)
	{
		int iArea = SDKCall(g_esRestartGeneral.g_hSDKGetLastKnownArea, survivor);
		if (iArea)
		{
			float flFlow = view_as<float>(LoadFromAddress(view_as<Address>(iArea + g_esRestartGeneral.g_iFlowOffset), NumberType_Int32));
			bReturn = start ? (flFlow < 3000.0) : (flFlow > 3000.0);
		}
	}

	bool bReturn2 = start ? !!GetEntProp(survivor, Prop_Send, "m_isInMissionStartArea") : false;
	return bReturn || bReturn2;
}

void tTimerRestartCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esRestartAbility[g_esRestartPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esRestartPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esRestartPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esRestartCache[iTank].g_iRestartAbility == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vRestartAbility(iTank, flRandom, iPos);
}

void tTimerRestartCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esRestartAbility[g_esRestartPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esRestartPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esRestartPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esRestartCache[iTank].g_iRestartHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esRestartCache[iTank].g_iRestartHitMode == 0 || g_esRestartCache[iTank].g_iRestartHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vRestartHit(iSurvivor, iTank, flRandom, flChance, g_esRestartCache[iTank].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esRestartCache[iTank].g_iRestartHitMode == 0 || g_esRestartCache[iTank].g_iRestartHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vRestartHit(iSurvivor, iTank, flRandom, flChance, g_esRestartCache[iTank].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}
}