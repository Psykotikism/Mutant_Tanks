/**
 * Mutant Tanks: A L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2017-2025  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_REGEN_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_REGEN_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Regen Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank leeches health off of survivors, regenerates health, gains health from hurting survivors, and can steal health from survivors and vice-versa.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad, g_bSecondGame;

int g_iGraphicsLevel;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Regen Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define SPRITE_LASER "sprites/laser.vmt"
#define SPRITE_LASERBEAM "sprites/laserbeam.vmt"
#else
	#if MT_REGEN_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_REGEN_SECTION "regenability"
#define MT_REGEN_SECTION2 "regen ability"
#define MT_REGEN_SECTION3 "regen_ability"
#define MT_REGEN_SECTION4 "regen"

#define MT_MENU_REGEN "Regen Ability"

enum struct esRegenPlayer
{
	bool g_bActivated;

	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRegenChance;
	float g_flRegenHealthMultiplier;
	float g_flRegenInterval;
	float g_flRegenRange;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRegenAbility;
	int g_iRegenCooldown;
	int g_iRegenDuration;
	int g_iRegenEffect;
	int g_iRegenHealth;
	int g_iRegenLimit;
	int g_iRegenMaxHealth;
	int g_iRegenMessage;
	int g_iRegenMode;
	int g_iRegenSight;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esRegenPlayer g_esRegenPlayer[MAXPLAYERS + 1];

enum struct esRegenTeammate
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRegenChance;
	float g_flRegenHealthMultiplier;
	float g_flRegenInterval;
	float g_flRegenRange;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRegenAbility;
	int g_iRegenCooldown;
	int g_iRegenDuration;
	int g_iRegenEffect;
	int g_iRegenHealth;
	int g_iRegenLimit;
	int g_iRegenMaxHealth;
	int g_iRegenMessage;
	int g_iRegenMode;
	int g_iRegenSight;
	int g_iRequiresHumans;
}

esRegenTeammate g_esRegenTeammate[MAXPLAYERS + 1];

enum struct esRegenAbility
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRegenChance;
	float g_flRegenHealthMultiplier;
	float g_flRegenInterval;
	float g_flRegenRange;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRegenAbility;
	int g_iRegenCooldown;
	int g_iRegenDuration;
	int g_iRegenEffect;
	int g_iRegenHealth;
	int g_iRegenLimit;
	int g_iRegenMaxHealth;
	int g_iRegenMessage;
	int g_iRegenMode;
	int g_iRegenSight;
	int g_iRequiresHumans;
}

esRegenAbility g_esRegenAbility[MT_MAXTYPES + 1];

enum struct esRegenSpecial
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRegenChance;
	float g_flRegenHealthMultiplier;
	float g_flRegenInterval;
	float g_flRegenRange;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRegenAbility;
	int g_iRegenCooldown;
	int g_iRegenDuration;
	int g_iRegenEffect;
	int g_iRegenHealth;
	int g_iRegenLimit;
	int g_iRegenMaxHealth;
	int g_iRegenMessage;
	int g_iRegenMode;
	int g_iRegenSight;
	int g_iRequiresHumans;
}

esRegenSpecial g_esRegenSpecial[MT_MAXTYPES + 1];

enum struct esRegenCache
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRegenChance;
	float g_flRegenHealthMultiplier;
	float g_flRegenInterval;
	float g_flRegenRange;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iRegenAbility;
	int g_iRegenCooldown;
	int g_iRegenDuration;
	int g_iRegenEffect;
	int g_iRegenHealth;
	int g_iRegenLimit;
	int g_iRegenMaxHealth;
	int g_iRegenMessage;
	int g_iRegenMode;
	int g_iRegenSight;
	int g_iRequiresHumans;
}

esRegenCache g_esRegenCache[MAXPLAYERS + 1];

int g_iRegenSprite = -1;

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_regen", cmdRegenInfo, "View information about the Regen ability.");

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
void vRegenMapStart()
#else
public void OnMapStart()
#endif
{
	switch (g_bSecondGame)
	{
		case true: g_iRegenSprite = PrecacheModel(SPRITE_LASERBEAM, true);
		case false: g_iRegenSprite = PrecacheModel(SPRITE_LASER, true);
	}

	vRegenReset();
}

#if defined MT_ABILITIES_MAIN2
void vRegenClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnRegenTakeDamage);
	vRemoveRegen(client);
}

#if defined MT_ABILITIES_MAIN2
void vRegenClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveRegen(client);
}

#if defined MT_ABILITIES_MAIN2
void vRegenMapEnd()
#else
public void OnMapEnd()
#endif
{
	vRegenReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdRegenInfo(int client, int args)
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
		case false: vRegenMenu(client, MT_REGEN_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vRegenMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_REGEN_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iRegenMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Regen Ability Information");
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

int iRegenMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esRegenCache[param1].g_iRegenAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esRegenCache[param1].g_iHumanAmmo - g_esRegenPlayer[param1].g_iAmmoCount), g_esRegenCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3:
				{
					switch (g_esRegenCache[param1].g_iHumanMode)
					{
						case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode1");
						case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode2");
						case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtonMode3");
					}
				}
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esRegenCache[param1].g_iHumanAbility == 1) ? g_esRegenCache[param1].g_iHumanCooldown : g_esRegenCache[param1].g_iRegenCooldown));
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RegenDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", ((g_esRegenCache[param1].g_iHumanAbility == 1) ? g_esRegenCache[param1].g_iHumanDuration : g_esRegenCache[param1].g_iRegenDuration));
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esRegenCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vRegenMenu(param1, MT_REGEN_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pRegen = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "RegenMenu", param1);
			pRegen.SetTitle(sMenuTitle);
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
void vRegenDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_REGEN, MT_MENU_REGEN);
}

#if defined MT_ABILITIES_MAIN2
void vRegenMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_REGEN, false))
	{
		vRegenMenu(client, MT_REGEN_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRegenMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_REGEN, false))
	{
		FormatEx(buffer, size, "%T", "RegenMenu2", client);
	}
}

Action OnRegenTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && !bIsPlayerIncapacitated(attacker) && g_esRegenCache[attacker].g_iRegenMode > 0 && GetRandomFloat(0.1, 100.0) <= g_esRegenCache[attacker].g_flRegenChance && bIsSurvivor(victim) && !bIsSurvivorDisabled(victim))
		{
			if (bIsAreaNarrow(attacker, g_esRegenCache[attacker].g_flOpenAreasOnly) || bIsAreaWide(attacker, g_esRegenCache[attacker].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRegenPlayer[attacker].g_iTankType, attacker) || (g_esRegenCache[attacker].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRegenCache[attacker].g_iRequiresHumans) || (!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esRegenAbility[g_esRegenPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esRegenPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esRegenPlayer[attacker].g_iTankType, g_esRegenAbility[g_esRegenPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esRegenPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((!bIsInfected(attacker, MT_CHECK_FAKECLIENT) || g_esRegenCache[attacker].g_iHumanAbility == 1) && ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
			{
				if (g_esRegenCache[attacker].g_iRegenMode == 1 || g_esRegenCache[attacker].g_iRegenMode == 3)
				{
					float flHealth = (g_esRegenCache[attacker].g_iRegenHealth > 0) ? float(g_esRegenCache[attacker].g_iRegenHealth) : damage;
					flHealth *= g_esRegenCache[attacker].g_flRegenHealthMultiplier;
					int iDamage = RoundToNearest(flHealth),
						iHealth = GetEntProp(attacker, Prop_Data, "m_iHealth"),
						iMaxHealth = MT_TankMaxHealth(attacker, 1),
						iNewHealth = (iHealth + iDamage),
						iLeftover = (iNewHealth > MT_MAXHEALTH) ? (iDamage - MT_MAXHEALTH) : iNewHealth,
						iFinalHealth = iClamp(iNewHealth, 1, MT_MAXHEALTH),
						iTotalHealth = (iNewHealth > MT_MAXHEALTH) ? iLeftover : iDamage;
					MT_TankMaxHealth(attacker, 3, (iMaxHealth + iTotalHealth));
					SetEntProp(attacker, Prop_Data, "m_iHealth", iFinalHealth);
					vScreenEffect(victim, attacker, g_esRegenCache[attacker].g_iRegenEffect, MT_ATTACK_CLAW);

					if (g_esRegenCache[attacker].g_iRegenMessage & MT_MESSAGE_MELEE)
					{
						char sTankName[64];
						MT_GetTankName(attacker, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Regen3", sTankName, victim);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Regen3", LANG_SERVER, sTankName, victim);
					}
				}

				if (g_esRegenCache[attacker].g_iRegenMode == 2 || g_esRegenCache[attacker].g_iRegenMode == 3)
				{
					vRegen3(attacker, victim, damage, true);
				}
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && !bIsPlayerIncapacitated(victim) && g_esRegenCache[victim].g_iRegenMode > 0 && GetRandomFloat(0.1, 100.0) <= g_esRegenCache[victim].g_flRegenChance && bIsSurvivor(attacker) && !bIsSurvivorDisabled(attacker) && (g_esRegenCache[victim].g_iRegenMode == 2 || g_esRegenCache[victim].g_iRegenMode == 3))
		{
			if (bIsAreaNarrow(victim, g_esRegenCache[victim].g_flOpenAreasOnly) || bIsAreaWide(victim, g_esRegenCache[victim].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRegenPlayer[victim].g_iTankType, victim) || (g_esRegenCache[victim].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRegenCache[victim].g_iRequiresHumans) || (!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esRegenAbility[g_esRegenPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esRegenPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esRegenPlayer[victim].g_iTankType, g_esRegenAbility[g_esRegenPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esRegenPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (!bIsInfected(victim, MT_CHECK_FAKECLIENT) || g_esRegenCache[victim].g_iHumanAbility == 1)
			{
				if (damagetype & DMG_BULLET)
				{
					damage /= 20.0;
				}
				else if ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA))
				{
					damage /= 20.0;
				}
				else if ((damagetype & DMG_BURN) || (damagetype & DMG_DIRECT))
				{
					damage /= 200.0;
				}
				else if ((damagetype & DMG_CRUSH) && bIsValidEntity(inflictor) && HasEntProp(inflictor, Prop_Send, "m_isCarryable"))
				{
					damage /= 20.0;
				}
				else if ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB))
				{
					damage /= 200.0;
				}

				vRegen3(attacker, victim, damage, false);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vRegenPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_REGEN);
}

#if defined MT_ABILITIES_MAIN2
void vRegenAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_REGEN_SECTION);
	list2.PushString(MT_REGEN_SECTION2);
	list3.PushString(MT_REGEN_SECTION3);
	list4.PushString(MT_REGEN_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vRegenCombineAbilities(int tank, int type, const float random, const char[] combo)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRegenCache[tank].g_iHumanAbility != 2)
	{
		g_esRegenAbility[g_esRegenPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

		return;
	}

	g_esRegenAbility[g_esRegenPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_REGEN_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_REGEN_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_REGEN_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_REGEN_SECTION4);
	if (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esRegenCache[tank].g_iRegenAbility == 1 && g_esRegenCache[tank].g_iComboAbility == 1 && !g_esRegenPlayer[tank].g_bActivated)
		{
			char sAbilities[320], sSubset[10][32];
			strcopy(sAbilities, sizeof sAbilities, combo);
			ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

			float flDelay = 0.0;
			for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_REGEN_SECTION, false) || StrEqual(sSubset[iPos], MT_REGEN_SECTION2, false) || StrEqual(sSubset[iPos], MT_REGEN_SECTION3, false) || StrEqual(sSubset[iPos], MT_REGEN_SECTION4, false))
				{
					g_esRegenAbility[g_esRegenPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = iPos;

					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						flDelay = MT_GetCombinationSetting(tank, 4, iPos);

						switch (flDelay)
						{
							case 0.0: vRegen(tank, iPos);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerRegenCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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

#if defined MT_ABILITIES_MAIN2
void vRegenConfigsLoad(int mode)
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
				g_esRegenAbility[iIndex].g_iAccessFlags = 0;
				g_esRegenAbility[iIndex].g_iImmunityFlags = 0;
				g_esRegenAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esRegenAbility[iIndex].g_iComboAbility = 0;
				g_esRegenAbility[iIndex].g_iComboPosition = -1;
				g_esRegenAbility[iIndex].g_iHumanAbility = 0;
				g_esRegenAbility[iIndex].g_iHumanAmmo = 5;
				g_esRegenAbility[iIndex].g_iHumanCooldown = 0;
				g_esRegenAbility[iIndex].g_iHumanDuration = 5;
				g_esRegenAbility[iIndex].g_iHumanMode = 1;
				g_esRegenAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esRegenAbility[iIndex].g_iRequiresHumans = 0;
				g_esRegenAbility[iIndex].g_iRegenAbility = 0;
				g_esRegenAbility[iIndex].g_iRegenEffect = 0;
				g_esRegenAbility[iIndex].g_iRegenMessage = 0;
				g_esRegenAbility[iIndex].g_flRegenChance = 33.3;
				g_esRegenAbility[iIndex].g_iRegenCooldown = 0;
				g_esRegenAbility[iIndex].g_iRegenDuration = 0;
				g_esRegenAbility[iIndex].g_iRegenHealth = 1;
				g_esRegenAbility[iIndex].g_flRegenHealthMultiplier = 1.0;
				g_esRegenAbility[iIndex].g_flRegenInterval = 1.0;
				g_esRegenAbility[iIndex].g_iRegenLimit = MT_MAXHEALTH;
				g_esRegenAbility[iIndex].g_iRegenMaxHealth = 100;
				g_esRegenAbility[iIndex].g_iRegenMode = 0;
				g_esRegenAbility[iIndex].g_flRegenRange = 150.0;
				g_esRegenAbility[iIndex].g_iRegenSight = 0;

				g_esRegenSpecial[iIndex].g_iComboAbility = -1;
				g_esRegenSpecial[iIndex].g_iHumanAbility = -1;
				g_esRegenSpecial[iIndex].g_iHumanAmmo = -1;
				g_esRegenSpecial[iIndex].g_iHumanCooldown = -1;
				g_esRegenSpecial[iIndex].g_iHumanDuration = -1;
				g_esRegenSpecial[iIndex].g_iHumanMode = -1;
				g_esRegenSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esRegenSpecial[iIndex].g_iRequiresHumans = -1;
				g_esRegenSpecial[iIndex].g_iRegenAbility = -1;
				g_esRegenSpecial[iIndex].g_iRegenEffect = -1;
				g_esRegenSpecial[iIndex].g_iRegenMessage = -1;
				g_esRegenSpecial[iIndex].g_flRegenChance = -1.0;
				g_esRegenSpecial[iIndex].g_iRegenCooldown = -1;
				g_esRegenSpecial[iIndex].g_iRegenDuration = -1;
				g_esRegenSpecial[iIndex].g_iRegenHealth = -1;
				g_esRegenSpecial[iIndex].g_flRegenHealthMultiplier = -1.0;
				g_esRegenSpecial[iIndex].g_flRegenInterval = -1.0;
				g_esRegenSpecial[iIndex].g_iRegenLimit = -1;
				g_esRegenSpecial[iIndex].g_iRegenMaxHealth = -1;
				g_esRegenSpecial[iIndex].g_iRegenMode = -1;
				g_esRegenSpecial[iIndex].g_flRegenRange = -1.0;
				g_esRegenSpecial[iIndex].g_iRegenSight = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esRegenPlayer[iPlayer].g_iAccessFlags = -1;
				g_esRegenPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esRegenPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esRegenPlayer[iPlayer].g_iComboAbility = -1;
				g_esRegenPlayer[iPlayer].g_iHumanAbility = -1;
				g_esRegenPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esRegenPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esRegenPlayer[iPlayer].g_iHumanDuration = -1;
				g_esRegenPlayer[iPlayer].g_iHumanMode = -1;
				g_esRegenPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esRegenPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esRegenPlayer[iPlayer].g_iRegenAbility = -1;
				g_esRegenPlayer[iPlayer].g_iRegenEffect = -1;
				g_esRegenPlayer[iPlayer].g_iRegenMessage = -1;
				g_esRegenPlayer[iPlayer].g_flRegenChance = -1.0;
				g_esRegenPlayer[iPlayer].g_iRegenCooldown = -1;
				g_esRegenPlayer[iPlayer].g_iRegenDuration = -1;
				g_esRegenPlayer[iPlayer].g_iRegenHealth = -1;
				g_esRegenPlayer[iPlayer].g_flRegenHealthMultiplier = -1.0;
				g_esRegenPlayer[iPlayer].g_flRegenInterval = -1.0;
				g_esRegenPlayer[iPlayer].g_iRegenLimit = -1;
				g_esRegenPlayer[iPlayer].g_iRegenMaxHealth = -1;
				g_esRegenPlayer[iPlayer].g_iRegenMode = -1;
				g_esRegenPlayer[iPlayer].g_flRegenRange = -1.0;
				g_esRegenPlayer[iPlayer].g_iRegenSight = -1;

				g_esRegenTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esRegenTeammate[iPlayer].g_iComboAbility = -1;
				g_esRegenTeammate[iPlayer].g_iHumanAbility = -1;
				g_esRegenTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esRegenTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esRegenTeammate[iPlayer].g_iHumanDuration = -1;
				g_esRegenTeammate[iPlayer].g_iHumanMode = -1;
				g_esRegenTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esRegenTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esRegenTeammate[iPlayer].g_iRegenAbility = -1;
				g_esRegenTeammate[iPlayer].g_iRegenEffect = -1;
				g_esRegenTeammate[iPlayer].g_iRegenMessage = -1;
				g_esRegenTeammate[iPlayer].g_flRegenChance = -1.0;
				g_esRegenTeammate[iPlayer].g_iRegenCooldown = -1;
				g_esRegenTeammate[iPlayer].g_iRegenDuration = -1;
				g_esRegenTeammate[iPlayer].g_iRegenHealth = -1;
				g_esRegenTeammate[iPlayer].g_flRegenHealthMultiplier = -1.0;
				g_esRegenTeammate[iPlayer].g_flRegenInterval = -1.0;
				g_esRegenTeammate[iPlayer].g_iRegenLimit = -1;
				g_esRegenTeammate[iPlayer].g_iRegenMaxHealth = -1;
				g_esRegenTeammate[iPlayer].g_iRegenMode = -1;
				g_esRegenTeammate[iPlayer].g_flRegenRange = -1.0;
				g_esRegenTeammate[iPlayer].g_iRegenSight = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRegenConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esRegenTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRegenTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRegenTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRegenTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esRegenTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRegenTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esRegenTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRegenTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esRegenTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRegenTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esRegenTeammate[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esRegenTeammate[admin].g_iHumanDuration, value, -1, 99999);
			g_esRegenTeammate[admin].g_iHumanMode = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esRegenTeammate[admin].g_iHumanMode, value, -1, 2);
			g_esRegenTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRegenTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRegenTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRegenTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esRegenTeammate[admin].g_iRegenAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRegenTeammate[admin].g_iRegenAbility, value, -1, 1);
			g_esRegenTeammate[admin].g_iRegenEffect = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRegenTeammate[admin].g_iRegenEffect, value, -1, 7);
			g_esRegenTeammate[admin].g_iRegenMessage = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRegenTeammate[admin].g_iRegenMessage, value, -1, 7);
			g_esRegenTeammate[admin].g_iRegenSight = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRegenTeammate[admin].g_iRegenSight, value, -1, 5);
			g_esRegenTeammate[admin].g_flRegenChance = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenChance", "Regen Chance", "Regen_Chance", "chance", g_esRegenTeammate[admin].g_flRegenChance, value, -1.0, 100.0);
			g_esRegenTeammate[admin].g_iRegenCooldown = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenCooldown", "Regen Cooldown", "Regen_Cooldown", "cooldown", g_esRegenTeammate[admin].g_iRegenCooldown, value, -1, 99999);
			g_esRegenTeammate[admin].g_iRegenDuration = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenDuration", "Regen Duration", "Regen_Duration", "duration", g_esRegenTeammate[admin].g_iRegenDuration, value, -1, 99999);
			g_esRegenTeammate[admin].g_iRegenHealth = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenHealth", "Regen Health", "Regen_Health", "health", g_esRegenTeammate[admin].g_iRegenHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esRegenTeammate[admin].g_flRegenHealthMultiplier = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenHealthMultiplier", "Regen Health Multiplier", "Regen_Health_Multiplier", "hpmulti", g_esRegenTeammate[admin].g_flRegenHealthMultiplier, value, -1.0, 99999.0);
			g_esRegenTeammate[admin].g_flRegenInterval = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenInterval", "Regen Interval", "Regen_Interval", "interval", g_esRegenTeammate[admin].g_flRegenInterval, value, -1.0, 99999.0);
			g_esRegenTeammate[admin].g_iRegenLimit = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenLimit", "Regen Limit", "Regen_Limit", "limit", g_esRegenTeammate[admin].g_iRegenLimit, value, -1, MT_MAXHEALTH);
			g_esRegenTeammate[admin].g_iRegenMaxHealth = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenMaxHealth", "Regen Max Health", "Regen_Max_Health", "maxhealth", g_esRegenTeammate[admin].g_iRegenMaxHealth, value, -1, MT_MAXHEALTH);
			g_esRegenTeammate[admin].g_iRegenMode = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenMode", "Regen Mode", "Regen_Mode", "mode", g_esRegenTeammate[admin].g_iRegenMode, value, -1, 3);
			g_esRegenTeammate[admin].g_flRegenRange = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenRange", "Regen Range", "Regen_Range", "range", g_esRegenTeammate[admin].g_flRegenRange, value, -1.0, 99999.0);
		}
		else
		{
			g_esRegenPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRegenPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRegenPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRegenPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esRegenPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRegenPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esRegenPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRegenPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esRegenPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRegenPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esRegenPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esRegenPlayer[admin].g_iHumanDuration, value, -1, 99999);
			g_esRegenPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esRegenPlayer[admin].g_iHumanMode, value, -1, 2);
			g_esRegenPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRegenPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRegenPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRegenPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esRegenPlayer[admin].g_iRegenAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRegenPlayer[admin].g_iRegenAbility, value, -1, 1);
			g_esRegenPlayer[admin].g_iRegenEffect = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRegenPlayer[admin].g_iRegenEffect, value, -1, 7);
			g_esRegenPlayer[admin].g_iRegenMessage = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRegenPlayer[admin].g_iRegenMessage, value, -1, 7);
			g_esRegenPlayer[admin].g_iRegenSight = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRegenPlayer[admin].g_iRegenSight, value, -1, 5);
			g_esRegenPlayer[admin].g_flRegenChance = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenChance", "Regen Chance", "Regen_Chance", "chance", g_esRegenPlayer[admin].g_flRegenChance, value, -1.0, 100.0);
			g_esRegenPlayer[admin].g_iRegenCooldown = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenCooldown", "Regen Cooldown", "Regen_Cooldown", "cooldown", g_esRegenPlayer[admin].g_iRegenCooldown, value, -1, 99999);
			g_esRegenPlayer[admin].g_iRegenDuration = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenDuration", "Regen Duration", "Regen_Duration", "duration", g_esRegenPlayer[admin].g_iRegenDuration, value, -1, 99999);
			g_esRegenPlayer[admin].g_iRegenHealth = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenHealth", "Regen Health", "Regen_Health", "health", g_esRegenPlayer[admin].g_iRegenHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esRegenPlayer[admin].g_flRegenHealthMultiplier = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenHealthMultiplier", "Regen Health Multiplier", "Regen_Health_Multiplier", "hpmulti", g_esRegenPlayer[admin].g_flRegenHealthMultiplier, value, -1.0, 99999.0);
			g_esRegenPlayer[admin].g_flRegenInterval = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenInterval", "Regen Interval", "Regen_Interval", "interval", g_esRegenPlayer[admin].g_flRegenInterval, value, -1.0, 99999.0);
			g_esRegenPlayer[admin].g_iRegenLimit = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenLimit", "Regen Limit", "Regen_Limit", "limit", g_esRegenPlayer[admin].g_iRegenLimit, value, -1, MT_MAXHEALTH);
			g_esRegenPlayer[admin].g_iRegenMaxHealth = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenMaxHealth", "Regen Max Health", "Regen_Max_Health", "maxhealth", g_esRegenPlayer[admin].g_iRegenMaxHealth, value, -1, MT_MAXHEALTH);
			g_esRegenPlayer[admin].g_iRegenMode = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenMode", "Regen Mode", "Regen_Mode", "mode", g_esRegenPlayer[admin].g_iRegenMode, value, -1, 3);
			g_esRegenPlayer[admin].g_flRegenRange = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenRange", "Regen Range", "Regen_Range", "range", g_esRegenPlayer[admin].g_flRegenRange, value, -1.0, 99999.0);
			g_esRegenPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esRegenPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "access", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esRegenSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRegenSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRegenSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRegenSpecial[type].g_iComboAbility, value, -1, 1);
			g_esRegenSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRegenSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esRegenSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRegenSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esRegenSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRegenSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esRegenSpecial[type].g_iHumanDuration = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esRegenSpecial[type].g_iHumanDuration, value, -1, 99999);
			g_esRegenSpecial[type].g_iHumanMode = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esRegenSpecial[type].g_iHumanMode, value, -1, 2);
			g_esRegenSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRegenSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRegenSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRegenSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esRegenSpecial[type].g_iRegenAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRegenSpecial[type].g_iRegenAbility, value, -1, 1);
			g_esRegenSpecial[type].g_iRegenEffect = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRegenSpecial[type].g_iRegenEffect, value, -1, 7);
			g_esRegenSpecial[type].g_iRegenMessage = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRegenSpecial[type].g_iRegenMessage, value, -1, 7);
			g_esRegenSpecial[type].g_iRegenSight = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRegenSpecial[type].g_iRegenSight, value, -1, 5);
			g_esRegenSpecial[type].g_flRegenChance = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenChance", "Regen Chance", "Regen_Chance", "chance", g_esRegenSpecial[type].g_flRegenChance, value, -1.0, 100.0);
			g_esRegenSpecial[type].g_iRegenCooldown = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenCooldown", "Regen Cooldown", "Regen_Cooldown", "cooldown", g_esRegenSpecial[type].g_iRegenCooldown, value, -1, 99999);
			g_esRegenSpecial[type].g_iRegenDuration = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenDuration", "Regen Duration", "Regen_Duration", "duration", g_esRegenSpecial[type].g_iRegenDuration, value, -1, 99999);
			g_esRegenSpecial[type].g_iRegenHealth = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenHealth", "Regen Health", "Regen_Health", "health", g_esRegenSpecial[type].g_iRegenHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esRegenSpecial[type].g_flRegenHealthMultiplier = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenHealthMultiplier", "Regen Health Multiplier", "Regen_Health_Multiplier", "hpmulti", g_esRegenSpecial[type].g_flRegenHealthMultiplier, value, -1.0, 99999.0);
			g_esRegenSpecial[type].g_flRegenInterval = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenInterval", "Regen Interval", "Regen_Interval", "interval", g_esRegenSpecial[type].g_flRegenInterval, value, -1.0, 99999.0);
			g_esRegenSpecial[type].g_iRegenLimit = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenLimit", "Regen Limit", "Regen_Limit", "limit", g_esRegenSpecial[type].g_iRegenLimit, value, -1, MT_MAXHEALTH);
			g_esRegenSpecial[type].g_iRegenMaxHealth = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenMaxHealth", "Regen Max Health", "Regen_Max_Health", "maxhealth", g_esRegenSpecial[type].g_iRegenMaxHealth, value, -1, MT_MAXHEALTH);
			g_esRegenSpecial[type].g_iRegenMode = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenMode", "Regen Mode", "Regen_Mode", "mode", g_esRegenSpecial[type].g_iRegenMode, value, -1, 3);
			g_esRegenSpecial[type].g_flRegenRange = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenRange", "Regen Range", "Regen_Range", "range", g_esRegenSpecial[type].g_flRegenRange, value, -1.0, 99999.0);
		}
		else
		{
			g_esRegenAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRegenAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRegenAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRegenAbility[type].g_iComboAbility, value, -1, 1);
			g_esRegenAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRegenAbility[type].g_iHumanAbility, value, -1, 2);
			g_esRegenAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRegenAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esRegenAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRegenAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esRegenAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esRegenAbility[type].g_iHumanDuration, value, -1, 99999);
			g_esRegenAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esRegenAbility[type].g_iHumanMode, value, -1, 2);
			g_esRegenAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRegenAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRegenAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRegenAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esRegenAbility[type].g_iRegenAbility = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRegenAbility[type].g_iRegenAbility, value, -1, 1);
			g_esRegenAbility[type].g_iRegenEffect = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRegenAbility[type].g_iRegenEffect, value, -1, 7);
			g_esRegenAbility[type].g_iRegenMessage = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRegenAbility[type].g_iRegenMessage, value, -1, 7);
			g_esRegenAbility[type].g_iRegenSight = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esRegenAbility[type].g_iRegenSight, value, -1, 5);
			g_esRegenAbility[type].g_flRegenChance = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenChance", "Regen Chance", "Regen_Chance", "chance", g_esRegenAbility[type].g_flRegenChance, value, -1.0, 100.0);
			g_esRegenAbility[type].g_iRegenCooldown = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenCooldown", "Regen Cooldown", "Regen_Cooldown", "cooldown", g_esRegenAbility[type].g_iRegenCooldown, value, -1, 99999);
			g_esRegenAbility[type].g_iRegenDuration = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenDuration", "Regen Duration", "Regen_Duration", "duration", g_esRegenAbility[type].g_iRegenDuration, value, -1, 99999);
			g_esRegenAbility[type].g_iRegenHealth = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenHealth", "Regen Health", "Regen_Health", "health", g_esRegenAbility[type].g_iRegenHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
			g_esRegenAbility[type].g_flRegenHealthMultiplier = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenHealthMultiplier", "Regen Health Multiplier", "Regen_Health_Multiplier", "hpmulti", g_esRegenAbility[type].g_flRegenHealthMultiplier, value, -1.0, 99999.0);
			g_esRegenAbility[type].g_flRegenInterval = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenInterval", "Regen Interval", "Regen_Interval", "interval", g_esRegenAbility[type].g_flRegenInterval, value, -1.0, 99999.0);
			g_esRegenAbility[type].g_iRegenLimit = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenLimit", "Regen Limit", "Regen_Limit", "limit", g_esRegenAbility[type].g_iRegenLimit, value, -1, MT_MAXHEALTH);
			g_esRegenAbility[type].g_iRegenMaxHealth = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenMaxHealth", "Regen Max Health", "Regen_Max_Health", "maxhealth", g_esRegenAbility[type].g_iRegenMaxHealth, value, -1, MT_MAXHEALTH);
			g_esRegenAbility[type].g_iRegenMode = iGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenMode", "Regen Mode", "Regen_Mode", "mode", g_esRegenAbility[type].g_iRegenMode, value, -1, 3);
			g_esRegenAbility[type].g_flRegenRange = flGetKeyValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "RegenRange", "Regen Range", "Regen_Range", "range", g_esRegenAbility[type].g_flRegenRange, value, -1.0, 99999.0);
			g_esRegenAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esRegenAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_REGEN_SECTION, MT_REGEN_SECTION2, MT_REGEN_SECTION3, MT_REGEN_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "access", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRegenSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esRegenPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esRegenPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esRegenPlayer[tank].g_iTankTypeRecorded;
#if !defined MT_ABILITIES_MAIN2
	g_iGraphicsLevel = MT_GetGraphicsLevel();
#endif
	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esRegenCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_flCloseAreasOnly, g_esRegenPlayer[tank].g_flCloseAreasOnly, g_esRegenSpecial[iType].g_flCloseAreasOnly, g_esRegenAbility[iType].g_flCloseAreasOnly, 1);
		g_esRegenCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iComboAbility, g_esRegenPlayer[tank].g_iComboAbility, g_esRegenSpecial[iType].g_iComboAbility, g_esRegenAbility[iType].g_iComboAbility, 1);
		g_esRegenCache[tank].g_flRegenChance = flGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_flRegenChance, g_esRegenPlayer[tank].g_flRegenChance, g_esRegenSpecial[iType].g_flRegenChance, g_esRegenAbility[iType].g_flRegenChance, 1);
		g_esRegenCache[tank].g_flRegenHealthMultiplier = flGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_flRegenHealthMultiplier, g_esRegenPlayer[tank].g_flRegenHealthMultiplier, g_esRegenSpecial[iType].g_flRegenHealthMultiplier, g_esRegenAbility[iType].g_flRegenHealthMultiplier, 1);
		g_esRegenCache[tank].g_flRegenInterval = flGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_flRegenInterval, g_esRegenPlayer[tank].g_flRegenInterval, g_esRegenSpecial[iType].g_flRegenInterval, g_esRegenAbility[iType].g_flRegenInterval, 1);
		g_esRegenCache[tank].g_flRegenRange = flGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_flRegenRange, g_esRegenPlayer[tank].g_flRegenRange, g_esRegenSpecial[iType].g_flRegenRange, g_esRegenAbility[iType].g_flRegenRange, 1);
		g_esRegenCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iHumanAbility, g_esRegenPlayer[tank].g_iHumanAbility, g_esRegenSpecial[iType].g_iHumanAbility, g_esRegenAbility[iType].g_iHumanAbility, 1);
		g_esRegenCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iHumanAmmo, g_esRegenPlayer[tank].g_iHumanAmmo, g_esRegenSpecial[iType].g_iHumanAmmo, g_esRegenAbility[iType].g_iHumanAmmo, 1);
		g_esRegenCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iHumanCooldown, g_esRegenPlayer[tank].g_iHumanCooldown, g_esRegenSpecial[iType].g_iHumanCooldown, g_esRegenAbility[iType].g_iHumanCooldown, 1);
		g_esRegenCache[tank].g_iHumanDuration = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iHumanDuration, g_esRegenPlayer[tank].g_iHumanDuration, g_esRegenSpecial[iType].g_iHumanDuration, g_esRegenAbility[iType].g_iHumanDuration, 1);
		g_esRegenCache[tank].g_iHumanMode = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iHumanMode, g_esRegenPlayer[tank].g_iHumanMode, g_esRegenSpecial[iType].g_iHumanMode, g_esRegenAbility[iType].g_iHumanMode, 1);
		g_esRegenCache[tank].g_iRegenAbility = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRegenAbility, g_esRegenPlayer[tank].g_iRegenAbility, g_esRegenSpecial[iType].g_iRegenAbility, g_esRegenAbility[iType].g_iRegenAbility, 1);
		g_esRegenCache[tank].g_iRegenCooldown = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRegenCooldown, g_esRegenPlayer[tank].g_iRegenCooldown, g_esRegenSpecial[iType].g_iRegenCooldown, g_esRegenAbility[iType].g_iRegenCooldown, 1);
		g_esRegenCache[tank].g_iRegenDuration = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRegenDuration, g_esRegenPlayer[tank].g_iRegenDuration, g_esRegenSpecial[iType].g_iRegenDuration, g_esRegenAbility[iType].g_iRegenDuration, 1);
		g_esRegenCache[tank].g_iRegenEffect = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRegenEffect, g_esRegenPlayer[tank].g_iRegenEffect, g_esRegenSpecial[iType].g_iRegenEffect, g_esRegenAbility[iType].g_iRegenEffect, 1);
		g_esRegenCache[tank].g_iRegenHealth = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRegenHealth, g_esRegenPlayer[tank].g_iRegenHealth, g_esRegenSpecial[iType].g_iRegenHealth, g_esRegenAbility[iType].g_iRegenHealth, 2, -1);
		g_esRegenCache[tank].g_iRegenLimit = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRegenLimit, g_esRegenPlayer[tank].g_iRegenLimit, g_esRegenSpecial[iType].g_iRegenLimit, g_esRegenAbility[iType].g_iRegenLimit, 1);
		g_esRegenCache[tank].g_iRegenMessage = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRegenMessage, g_esRegenPlayer[tank].g_iRegenMessage, g_esRegenSpecial[iType].g_iRegenMessage, g_esRegenAbility[iType].g_iRegenMessage, 1);
		g_esRegenCache[tank].g_iRegenMode = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRegenMode, g_esRegenPlayer[tank].g_iRegenMode, g_esRegenSpecial[iType].g_iRegenMode, g_esRegenAbility[iType].g_iRegenMode, 1);
		g_esRegenCache[tank].g_iRegenSight = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRegenSight, g_esRegenPlayer[tank].g_iRegenSight, g_esRegenSpecial[iType].g_iRegenSight, g_esRegenAbility[iType].g_iRegenSight, 1);
		g_esRegenCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_flOpenAreasOnly, g_esRegenPlayer[tank].g_flOpenAreasOnly, g_esRegenSpecial[iType].g_flOpenAreasOnly, g_esRegenAbility[iType].g_flOpenAreasOnly, 1);
		g_esRegenCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esRegenTeammate[tank].g_iRequiresHumans, g_esRegenPlayer[tank].g_iRequiresHumans, g_esRegenSpecial[iType].g_iRequiresHumans, g_esRegenAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esRegenCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_flCloseAreasOnly, g_esRegenAbility[iType].g_flCloseAreasOnly, 1);
		g_esRegenCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iComboAbility, g_esRegenAbility[iType].g_iComboAbility, 1);
		g_esRegenCache[tank].g_flRegenChance = flGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_flRegenChance, g_esRegenAbility[iType].g_flRegenChance, 1);
		g_esRegenCache[tank].g_flRegenHealthMultiplier = flGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_flRegenHealthMultiplier, g_esRegenAbility[iType].g_flRegenHealthMultiplier, 1);
		g_esRegenCache[tank].g_flRegenInterval = flGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_flRegenInterval, g_esRegenAbility[iType].g_flRegenInterval, 1);
		g_esRegenCache[tank].g_flRegenRange = flGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_flRegenRange, g_esRegenAbility[iType].g_flRegenRange, 1);
		g_esRegenCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iHumanAbility, g_esRegenAbility[iType].g_iHumanAbility, 1);
		g_esRegenCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iHumanAmmo, g_esRegenAbility[iType].g_iHumanAmmo, 1);
		g_esRegenCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iHumanCooldown, g_esRegenAbility[iType].g_iHumanCooldown, 1);
		g_esRegenCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iHumanDuration, g_esRegenAbility[iType].g_iHumanDuration, 1);
		g_esRegenCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iHumanMode, g_esRegenAbility[iType].g_iHumanMode, 1);
		g_esRegenCache[tank].g_iRegenAbility = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRegenAbility, g_esRegenAbility[iType].g_iRegenAbility, 1);
		g_esRegenCache[tank].g_iRegenCooldown = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRegenCooldown, g_esRegenAbility[iType].g_iRegenCooldown, 1);
		g_esRegenCache[tank].g_iRegenDuration = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRegenDuration, g_esRegenAbility[iType].g_iRegenDuration, 1);
		g_esRegenCache[tank].g_iRegenEffect = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRegenEffect, g_esRegenAbility[iType].g_iRegenEffect, 1);
		g_esRegenCache[tank].g_iRegenHealth = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRegenHealth, g_esRegenAbility[iType].g_iRegenHealth, 2, -1);
		g_esRegenCache[tank].g_iRegenLimit = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRegenLimit, g_esRegenAbility[iType].g_iRegenLimit, 1);
		g_esRegenCache[tank].g_iRegenMessage = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRegenMessage, g_esRegenAbility[iType].g_iRegenMessage, 1);
		g_esRegenCache[tank].g_iRegenMode = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRegenMode, g_esRegenAbility[iType].g_iRegenMode, 1);
		g_esRegenCache[tank].g_iRegenSight = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRegenSight, g_esRegenAbility[iType].g_iRegenSight, 1);
		g_esRegenCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_flOpenAreasOnly, g_esRegenAbility[iType].g_flOpenAreasOnly, 1);
		g_esRegenCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esRegenPlayer[tank].g_iRequiresHumans, g_esRegenAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRegenCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vRegenCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveRegen(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vRegenEventFired(Event event, const char[] name)
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
			vRegenCopyStats2(iBot, iTank);
			vRemoveRegen(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vRegenReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vRegenCopyStats2(iTank, iBot);
			vRemoveRegen(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveRegen(iTank);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRegenAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRegenAbility[g_esRegenPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRegenPlayer[tank].g_iAccessFlags)) || g_esRegenCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esRegenCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esRegenCache[tank].g_iRegenAbility == 1 && g_esRegenCache[tank].g_iComboAbility == 0 && !g_esRegenPlayer[tank].g_bActivated)
	{
		vRegenAbility(tank);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRegenButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esRegenCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRegenCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRegenPlayer[tank].g_iTankType, tank) || (g_esRegenCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRegenCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRegenAbility[g_esRegenPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRegenPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_MAIN_KEY) && g_esRegenCache[tank].g_iRegenAbility == 1 && g_esRegenCache[tank].g_iHumanAbility == 1)
		{
			int iHumanMode = g_esRegenCache[tank].g_iHumanMode, iTime = GetTime();
			bool bRecharging = g_esRegenPlayer[tank].g_iCooldown != -1 && g_esRegenPlayer[tank].g_iCooldown >= iTime;

			switch (iHumanMode)
			{
				case 0:
				{
					if (!g_esRegenPlayer[tank].g_bActivated && !bRecharging)
					{
						vRegenAbility(tank);
					}
					else if (g_esRegenPlayer[tank].g_bActivated)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RegenHuman3");
					}
					else if (bRecharging)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RegenHuman4", (g_esRegenPlayer[tank].g_iCooldown - iTime));
					}
				}
				case 1, 2:
				{
					if ((iHumanMode == 2 && g_esRegenPlayer[tank].g_bActivated) || (g_esRegenPlayer[tank].g_iAmmoCount < g_esRegenCache[tank].g_iHumanAmmo && g_esRegenCache[tank].g_iHumanAmmo > 0))
					{
						if (!g_esRegenPlayer[tank].g_bActivated && !bRecharging)
						{
							g_esRegenPlayer[tank].g_bActivated = true;
							g_esRegenPlayer[tank].g_iAmmoCount++;

							vRegen2(tank);
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RegenHuman", g_esRegenPlayer[tank].g_iAmmoCount, g_esRegenCache[tank].g_iHumanAmmo);
						}
						else if (g_esRegenPlayer[tank].g_bActivated)
						{
							switch (iHumanMode)
							{
								case 1: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RegenHuman3");
								case 2:
								{
									vRegenReset2(tank);
									vRegenReset3(tank);
								}
							}
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RegenHuman4", (g_esRegenPlayer[tank].g_iCooldown - iTime));
						}
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RegenAmmo");
					}
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRegenButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esRegenCache[tank].g_iHumanAbility == 1)
	{
		if ((button & MT_MAIN_KEY) && g_esRegenCache[tank].g_iHumanMode == 1 && g_esRegenPlayer[tank].g_bActivated && (g_esRegenPlayer[tank].g_iCooldown == -1 || g_esRegenPlayer[tank].g_iCooldown <= GetTime()))
		{
			vRegenReset2(tank);
			vRegenReset3(tank);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRegenChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveRegen(tank);
}

void vRegen(int tank, int pos = -1)
{
	if (g_esRegenPlayer[tank].g_iCooldown != -1 && g_esRegenPlayer[tank].g_iCooldown >= GetTime())
	{
		return;
	}

	g_esRegenPlayer[tank].g_bActivated = true;

	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRegenCache[tank].g_iHumanAbility == 1)
	{
		g_esRegenPlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RegenHuman", g_esRegenPlayer[tank].g_iAmmoCount, g_esRegenCache[tank].g_iHumanAmmo);
	}

	vRegen2(tank, pos);

	if (g_esRegenCache[tank].g_iRegenMessage & MT_MESSAGE_RANGE)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Regen", sTankName, g_esRegenCache[tank].g_flRegenInterval);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Regen", LANG_SERVER, sTankName, g_esRegenCache[tank].g_flRegenInterval);
	}
}

void vRegen2(int tank, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esRegenCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRegenCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRegenPlayer[tank].g_iTankType, tank) || (g_esRegenCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRegenCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRegenAbility[g_esRegenPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRegenPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 6, pos) : g_esRegenCache[tank].g_flRegenInterval;
	if (flInterval > 0.0)
	{
		DataPack dpRegen;
		CreateDataTimer(flInterval, tTimerRegen, dpRegen, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRegen.WriteCell(GetClientUserId(tank));
		dpRegen.WriteCell(g_esRegenPlayer[tank].g_iTankType);
		dpRegen.WriteCell(GetTime());
		dpRegen.WriteCell(pos);
	}
}

void vRegen3(int attacker, int victim, float damage, bool tank)
{
	int iTank = tank ? attacker : victim,
		iDamage = (damage < 1.0) ? 1 : RoundToNearest(damage),
		iHealth = GetEntProp(attacker, Prop_Data, "m_iHealth"),
		iMaxHealth = tank ? MT_MAXHEALTH : g_esRegenCache[iTank].g_iRegenMaxHealth,
		iNewHealth = (iHealth + iDamage), iLeftover = 0, iFinalHealth = 0, iTotalHealth = 0;
	iMaxHealth = (!tank && g_esRegenCache[iTank].g_iRegenMaxHealth == 0) ? GetEntProp(attacker, Prop_Data, "m_iMaxHealth") : iMaxHealth;
	iLeftover = (iNewHealth > iMaxHealth) ? (iNewHealth - iMaxHealth) : iNewHealth;
	iFinalHealth = iClamp(iNewHealth, 1, iMaxHealth);
	iTotalHealth = (iNewHealth > iMaxHealth) ? iLeftover : iDamage;
	SetEntProp(attacker, Prop_Data, "m_iHealth", iFinalHealth);

	if (tank)
	{
		MT_TankMaxHealth(attacker, 3, (MT_TankMaxHealth(attacker, 1) + iTotalHealth));
	}

	int iSurvivor = tank ? victim : attacker, iFlag = tank ? MT_ATTACK_CLAW : MT_ATTACK_MELEE;
	vScreenEffect(iSurvivor, iTank, g_esRegenCache[iTank].g_iRegenEffect, iFlag);

	iFlag = tank ? MT_MESSAGE_MELEE : MT_MESSAGE_RANGE;
	if (g_esRegenCache[iTank].g_iRegenMessage & iFlag)
	{
		char sTankName[64];
		MT_GetTankName(iTank, sTankName);

		switch (tank)
		{
			case true:
			{
				MT_PrintToChatAll("%s %t", MT_TAG2, "Regen3", sTankName, victim);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Regen3", LANG_SERVER, sTankName, victim);
			}
			case false:
			{
				MT_PrintToChatAll("%s %t", MT_TAG2, "Regen4", attacker, sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Regen4", LANG_SERVER, attacker, sTankName);
			}
		}
	}
}

void vRegenAbility(int tank)
{
	if ((g_esRegenPlayer[tank].g_iCooldown != -1 && g_esRegenPlayer[tank].g_iCooldown >= GetTime()) || bIsAreaNarrow(tank, g_esRegenCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRegenCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRegenPlayer[tank].g_iTankType, tank) || (g_esRegenCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRegenCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRegenAbility[g_esRegenPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRegenPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esRegenPlayer[tank].g_iAmmoCount < g_esRegenCache[tank].g_iHumanAmmo && g_esRegenCache[tank].g_iHumanAmmo > 0))
	{
		vRegen(tank);
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRegenCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RegenAmmo");
	}
}

void vRegenCopyStats2(int oldTank, int newTank)
{
	g_esRegenPlayer[newTank].g_iAmmoCount = g_esRegenPlayer[oldTank].g_iAmmoCount;
	g_esRegenPlayer[newTank].g_iCooldown = g_esRegenPlayer[oldTank].g_iCooldown;
}

void vRemoveRegen(int tank)
{
	g_esRegenPlayer[tank].g_bActivated = false;
	g_esRegenPlayer[tank].g_iAmmoCount = 0;
	g_esRegenPlayer[tank].g_iCooldown = -1;
}

void vRegenReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveRegen(iPlayer);
		}
	}
}

void vRegenReset2(int tank)
{
	g_esRegenPlayer[tank].g_bActivated = false;

	if (g_esRegenCache[tank].g_iRegenMessage & MT_MESSAGE_RANGE)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Regen2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Regen2", LANG_SERVER, sTankName);
	}
}

void vRegenReset3(int tank)
{
	int iTime = GetTime(), iPos = g_esRegenAbility[g_esRegenPlayer[tank].g_iTankTypeRecorded].g_iComboPosition, iCooldown = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, iPos)) : g_esRegenCache[tank].g_iRegenCooldown;
	iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRegenCache[tank].g_iHumanAbility == 1 && g_esRegenCache[tank].g_iHumanMode == 0 && g_esRegenPlayer[tank].g_iAmmoCount < g_esRegenCache[tank].g_iHumanAmmo && g_esRegenCache[tank].g_iHumanAmmo > 0) ? g_esRegenCache[tank].g_iHumanCooldown : iCooldown;
	g_esRegenPlayer[tank].g_iCooldown = (iTime + iCooldown);
	if (g_esRegenPlayer[tank].g_iCooldown != -1 && g_esRegenPlayer[tank].g_iCooldown >= iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RegenHuman5", (g_esRegenPlayer[tank].g_iCooldown - iTime));
	}
}

Action tTimerRegenCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esRegenAbility[g_esRegenPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esRegenPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esRegenPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esRegenCache[iTank].g_iRegenAbility == 0 || g_esRegenPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vRegen(iTank, iPos);

	return Plugin_Continue;
}

Action tTimerRegen(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsPlayerIncapacitated(iTank) || bIsAreaNarrow(iTank, g_esRegenCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esRegenCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRegenPlayer[iTank].g_iTankType, iTank) || (g_esRegenCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRegenCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esRegenAbility[g_esRegenPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esRegenPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esRegenPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esRegenPlayer[iTank].g_iTankType || g_esRegenCache[iTank].g_iRegenAbility == 0 || !g_esRegenPlayer[iTank].g_bActivated)
	{
		vRegenReset2(iTank);

		return Plugin_Stop;
	}

	bool bHuman = bIsInfected(iTank, MT_CHECK_FAKECLIENT);
	int iTime = pack.ReadCell(), iCurrentTime = GetTime(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : g_esRegenCache[iTank].g_iRegenDuration;
	iDuration = (bHuman && g_esRegenCache[iTank].g_iHumanAbility == 1) ? g_esRegenCache[iTank].g_iHumanDuration : iDuration;
	if (iDuration > 0 && (!bHuman || (bHuman && g_esRegenCache[iTank].g_iHumanAbility == 1 && g_esRegenCache[iTank].g_iHumanMode == 0)) && (iTime + iDuration) < iCurrentTime && (g_esRegenPlayer[iTank].g_iCooldown == -1 || g_esRegenPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vRegenReset2(iTank);
		vRegenReset3(iTank);

		return Plugin_Stop;
	}

	float flTankPos[3], flSurvivorPos[3];
	GetClientAbsOrigin(iTank, flTankPos);
	flTankPos[2] += 40.0;
	float flInterval = (iPos != -1) ? MT_GetCombinationSetting(iTank, 6, iPos) : g_esRegenCache[iTank].g_flRegenInterval,
		flRange = (iPos != -1) ? MT_GetCombinationSetting(iTank, 9, iPos) : g_esRegenCache[iTank].g_flRegenRange;
	int iColor[4], iMultiplier = 0;
	MT_GetPropColors(iTank, 8, iColor[0], iColor[1], iColor[2], iColor[3]);
	iColor[3] = 150;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, iTank) && !bIsAdminImmune(iSurvivor, g_esRegenPlayer[iTank].g_iTankType, g_esRegenAbility[g_esRegenPlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esRegenPlayer[iSurvivor].g_iImmunityFlags))
		{
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);
			flSurvivorPos[2] += 40.0;
			if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(iTank, iSurvivor, g_esRegenCache[iTank].g_iRegenSight, .range = flRange))
			{
				iMultiplier++;

				vDamagePlayer(iSurvivor, iTank, MT_GetScaledDamage(float(g_esRegenCache[iTank].g_iRegenHealth)), "128");
				vScreenEffect(iSurvivor, iTank, g_esRegenCache[iTank].g_iRegenEffect, MT_ATTACK_RANGE);

				if (g_iGraphicsLevel > 2)
				{
					TE_SetupBeamPoints(flTankPos, flSurvivorPos, g_iRegenSprite, 0, 0, 0, flInterval, 5.0, 5.0, 1, 0.0, iColor, 0);
					TE_SendToAll();
				}
			}
		}
	}

	int iLeech = g_esRegenCache[iTank].g_iRegenHealth + (g_esRegenCache[iTank].g_iRegenHealth * iMultiplier),
		iHealth = GetEntProp(iTank, Prop_Data, "m_iHealth"),
		iExtraHealth = iHealth + iLeech,
		iMaxHealth = MT_TankMaxHealth(iTank, 1),
		iLeftover = (iExtraHealth > MT_MAXHEALTH) ? (iExtraHealth - MT_MAXHEALTH) : iExtraHealth,
		iNewHealth = iClamp(iExtraHealth, 1, MT_MAXHEALTH),
		iNewHealth2 = (iExtraHealth <= 1) ? iHealth : iExtraHealth,
		iRealHealth = (iLeech >= 1) ? iNewHealth : iNewHealth2,
		iFinalHealth = (iLeech >= 1 && iRealHealth >= g_esRegenCache[iTank].g_iRegenLimit) ? g_esRegenCache[iTank].g_iRegenLimit : iRealHealth,
		iTotalHealth = (iExtraHealth > MT_MAXHEALTH) ? iLeftover : iLeech;

	MT_TankMaxHealth(iTank, 3, (iMaxHealth + iTotalHealth));
	SetEntProp(iTank, Prop_Data, "m_iHealth", iFinalHealth);

	return Plugin_Continue;
}