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

#define MT_VISION_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_VISION_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Vision Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank blinds survivors, shakes the survivors' screens, splatters the survivors' screens, and changes the survivors' field of view.",
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
			strcopy(error, err_max, "\"[MT] Vision Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BASHED "screen_bashed"

#define SOUND_GROAN1 "ambient/random_amb_sfx/metalscrapeverb08.wav"
#define SOUND_GROAN2 "ambient/random_amb_sounds/randbridgegroan_03.wav" // Only available in L4D2
#define SOUND_SMASH1 "player/tank/hit/hulk_punch_1.wav"
#define SOUND_SMASH2 "player/charger/hit/charger_smash_02.wav" // Only available in L4D2
#else
	#if MT_VISION_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_VISION_SECTION "visionability"
#define MT_VISION_SECTION2 "vision ability"
#define MT_VISION_SECTION3 "vision_ability"
#define MT_VISION_SECTION4 "vision"

#define MT_VISION_BLIND (1 << 0) // blind
#define MT_VISION_FLASHBANG (1 << 1) // flashbang
#define MT_VISION_SHAKE (1 << 2) // shake
#define MT_VISION_SPLATTER (1 << 3) // splatter
#define MT_VISION_VIEW (1 << 4) // view

#define MT_MENU_VISION "Vision Ability"

char g_sParticles[][] =
{
	"screen_adrenaline",
	"screen_adrenaline_b",
	"screen_hurt",
	"screen_hurt_b",
	"screen_blood_splatter",
	"screen_blood_splatter_a",
	"screen_blood_splatter_b",
	"screen_blood_splatter_melee_b",
	"screen_blood_splatter_melee",
	"screen_blood_splatter_melee_blunt",
	"smoker_screen_effect",
	"smoker_screen_effect_b",
	"screen_mud_splatter",
	"screen_mud_splatter_a",
	"screen_bashed",
	"screen_bashed_b",
	"screen_bashed_d",
	"burning_character_screen",
	"storm_lightning_screenglow"
};

enum struct esVisionPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flVisionChance;
	float g_flVisionDeathChance;
	float g_flVisionDeathRange;
	float g_flVisionDuration;
	float g_flVisionInterval;
	float g_flVisionRange;
	float g_flVisionRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iVisionAbility;
	int g_iVisionCooldown;
	int g_iVisionDeath;
	int g_iVisionEffect;
	int g_iVisionFOV;
	int g_iVisionHit;
	int g_iVisionHitMode;
	int g_iVisionIntensity;
	int g_iVisionMessage;
	int g_iVisionMode;
	int g_iVisionRangeCooldown;
	int g_iVisionSight;
	int g_iVisionStagger;
	int g_iVisionType;
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
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esVisionPlayer g_esVisionPlayer[MAXPLAYERS + 1];

enum struct esVisionTeammate
{
	float g_flVisionChance;
	float g_flVisionDeathChance;
	float g_flVisionDeathRange;
	float g_flVisionDuration;
	float g_flVisionInterval;
	float g_flVisionRange;
	float g_flVisionRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iVisionAbility;
	int g_iVisionCooldown;
	int g_iVisionDeath;
	int g_iVisionEffect;
	int g_iVisionFOV;
	int g_iVisionHit;
	int g_iVisionHitMode;
	int g_iVisionIntensity;
	int g_iVisionMessage;
	int g_iVisionMode;
	int g_iVisionRangeCooldown;
	int g_iVisionSight;
	int g_iVisionStagger;
	int g_iVisionType;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esVisionTeammate g_esVisionTeammate[MAXPLAYERS + 1];

enum struct esVisionAbility
{
	float g_flVisionChance;
	float g_flVisionDeathChance;
	float g_flVisionDeathRange;
	float g_flVisionDuration;
	float g_flVisionInterval;
	float g_flVisionRange;
	float g_flVisionRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iVisionAbility;
	int g_iVisionCooldown;
	int g_iVisionDeath;
	int g_iVisionEffect;
	int g_iVisionFOV;
	int g_iVisionHit;
	int g_iVisionHitMode;
	int g_iVisionIntensity;
	int g_iVisionMessage;
	int g_iVisionMode;
	int g_iVisionRangeCooldown;
	int g_iVisionSight;
	int g_iVisionStagger;
	int g_iVisionType;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esVisionAbility g_esVisionAbility[MT_MAXTYPES + 1];

enum struct esVisionSpecial
{
	float g_flVisionChance;
	float g_flVisionDeathChance;
	float g_flVisionDeathRange;
	float g_flVisionDuration;
	float g_flVisionInterval;
	float g_flVisionRange;
	float g_flVisionRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iVisionAbility;
	int g_iVisionCooldown;
	int g_iVisionDeath;
	int g_iVisionEffect;
	int g_iVisionFOV;
	int g_iVisionHit;
	int g_iVisionHitMode;
	int g_iVisionIntensity;
	int g_iVisionMessage;
	int g_iVisionMode;
	int g_iVisionRangeCooldown;
	int g_iVisionSight;
	int g_iVisionStagger;
	int g_iVisionType;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esVisionSpecial g_esVisionSpecial[MT_MAXTYPES + 1];

enum struct esVisionCache
{
	float g_flVisionChance;
	float g_flVisionDeathChance;
	float g_flVisionDeathRange;
	float g_flVisionDuration;
	float g_flVisionInterval;
	float g_flVisionRange;
	float g_flVisionRangeChance;
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;

	int g_iVisionAbility;
	int g_iVisionCooldown;
	int g_iVisionDeath;
	int g_iVisionEffect;
	int g_iVisionFOV;
	int g_iVisionHit;
	int g_iVisionHitMode;
	int g_iVisionIntensity;
	int g_iVisionMessage;
	int g_iVisionMode;
	int g_iVisionRangeCooldown;
	int g_iVisionSight;
	int g_iVisionStagger;
	int g_iVisionType;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esVisionCache g_esVisionCache[MAXPLAYERS + 1];

int g_iBashedParticle = -1;

UserMsg g_umVisionFade;

#if defined MT_ABILITIES_MAIN2
void vVisionPluginStart()
#else
public void OnPluginStart()
#endif
{
	g_umVisionFade = GetUserMessageId("Fade");
#if !defined MT_ABILITIES_MAIN2
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_vision", cmdVisionInfo, "View information about the Vision ability.");

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
void vVisionMapStart()
#else
public void OnMapStart()
#endif
{
	g_iBashedParticle = iPrecacheParticle(PARTICLE_BASHED);

	switch (g_bSecondGame)
	{
		case true:
		{
			for (int iPos = 0; iPos < (sizeof g_sParticles); iPos++)
			{
				iPrecacheParticle(g_sParticles[iPos]);
			}

			PrecacheSound(SOUND_GROAN2, true);
			PrecacheSound(SOUND_SMASH2, true);
		}
		case false:
		{
			PrecacheSound(SOUND_GROAN1, true);
			PrecacheSound(SOUND_SMASH1, true);
		}
	}

	vVisionReset();
}

#if defined MT_ABILITIES_MAIN2
void vVisionClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnVisionTakeDamage);
	vVisionReset3(client);
}

#if defined MT_ABILITIES_MAIN2
void vVisionClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vVisionReset3(client);
}

#if defined MT_ABILITIES_MAIN2
void vVisionMapEnd()
#else
public void OnMapEnd()
#endif
{
	vVisionReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdVisionInfo(int client, int args)
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
		case false: vVisionMenu(client, MT_VISION_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vVisionMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_VISION_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iVisionMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Vision Ability Information");
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

int iVisionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esVisionCache[param1].g_iVisionAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esVisionCache[param1].g_iHumanAmmo - g_esVisionPlayer[param1].g_iAmmoCount), g_esVisionCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esVisionCache[param1].g_iHumanAbility == 1) ? g_esVisionCache[param1].g_iHumanCooldown : g_esVisionCache[param1].g_iVisionCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "VisionDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esVisionCache[param1].g_flVisionDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esVisionCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esVisionCache[param1].g_iHumanAbility == 1) ? g_esVisionCache[param1].g_iHumanRangeCooldown : g_esVisionCache[param1].g_iVisionRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vVisionMenu(param1, MT_VISION_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pVision = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "VisionMenu", param1);
			pVision.SetTitle(sMenuTitle);
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
void vVisionDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_VISION, MT_MENU_VISION);
}

#if defined MT_ABILITIES_MAIN2
void vVisionMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_VISION, false))
	{
		vVisionMenu(client, MT_VISION_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vVisionMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_VISION, false))
	{
		FormatEx(buffer, size, "%T", "VisionMenu2", client);
	}
}

Action OnVisionTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esVisionCache[attacker].g_iVisionHitMode == 0 || g_esVisionCache[attacker].g_iVisionHitMode == 1) && bIsSurvivor(victim) && g_esVisionCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esVisionAbility[g_esVisionPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esVisionPlayer[attacker].g_iTankType, g_esVisionAbility[g_esVisionPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esVisionPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vVisionHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esVisionCache[attacker].g_flVisionChance, g_esVisionCache[attacker].g_iVisionHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esVisionCache[victim].g_iVisionHitMode == 0 || g_esVisionCache[victim].g_iVisionHitMode == 2) && bIsSurvivor(attacker) && g_esVisionCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esVisionAbility[g_esVisionPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esVisionPlayer[victim].g_iTankType, g_esVisionAbility[g_esVisionPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esVisionPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vVisionHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esVisionCache[victim].g_flVisionChance, g_esVisionCache[victim].g_iVisionHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vVisionPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_VISION);
}

#if defined MT_ABILITIES_MAIN2
void vVisionAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_VISION_SECTION);
	list2.PushString(MT_VISION_SECTION2);
	list3.PushString(MT_VISION_SECTION3);
	list4.PushString(MT_VISION_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vVisionCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esVisionCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_VISION_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_VISION_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_VISION_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_VISION_SECTION4);
	if (g_esVisionCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_VISION_SECTION, false) || StrEqual(sSubset[iPos], MT_VISION_SECTION2, false) || StrEqual(sSubset[iPos], MT_VISION_SECTION3, false) || StrEqual(sSubset[iPos], MT_VISION_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esVisionCache[tank].g_iVisionAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vVisionAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerVisionCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
								if ((g_esVisionCache[tank].g_iVisionHitMode == 0 || g_esVisionCache[tank].g_iVisionHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vVisionHit(survivor, tank, random, flChance, g_esVisionCache[tank].g_iVisionHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esVisionCache[tank].g_iVisionHitMode == 0 || g_esVisionCache[tank].g_iVisionHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vVisionHit(survivor, tank, random, flChance, g_esVisionCache[tank].g_iVisionHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerVisionCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteCell(iPos);
								dpCombo.WriteString(classname);
							}
						}
					}
					case MT_COMBO_POSTSPAWN: vVisionRange(tank, 0, 1, random, iPos);
					case MT_COMBO_UPONDEATH: vVisionRange(tank, 0, 0, random, iPos);
				}

				break;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vVisionConfigsLoad(int mode)
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
				g_esVisionAbility[iIndex].g_iAccessFlags = 0;
				g_esVisionAbility[iIndex].g_iImmunityFlags = 0;
				g_esVisionAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esVisionAbility[iIndex].g_iComboAbility = 0;
				g_esVisionAbility[iIndex].g_iHumanAbility = 0;
				g_esVisionAbility[iIndex].g_iHumanAmmo = 5;
				g_esVisionAbility[iIndex].g_iHumanCooldown = 0;
				g_esVisionAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esVisionAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esVisionAbility[iIndex].g_iRequiresHumans = 1;
				g_esVisionAbility[iIndex].g_iVisionAbility = 0;
				g_esVisionAbility[iIndex].g_iVisionEffect = 0;
				g_esVisionAbility[iIndex].g_iVisionMessage = 0;
				g_esVisionAbility[iIndex].g_flVisionChance = 33.3;
				g_esVisionAbility[iIndex].g_iVisionCooldown = 0;
				g_esVisionAbility[iIndex].g_iVisionDeath = 0;
				g_esVisionAbility[iIndex].g_flVisionDeathChance = 33.3;
				g_esVisionAbility[iIndex].g_flVisionDeathRange = 200.0;
				g_esVisionAbility[iIndex].g_flVisionDuration = 5.0;
				g_esVisionAbility[iIndex].g_iVisionFOV = 160;
				g_esVisionAbility[iIndex].g_iVisionHit = 0;
				g_esVisionAbility[iIndex].g_iVisionHitMode = 0;
				g_esVisionAbility[iIndex].g_iVisionIntensity = 255;
				g_esVisionAbility[iIndex].g_flVisionInterval = 1.0;
				g_esVisionAbility[iIndex].g_iVisionMode = 0;
				g_esVisionAbility[iIndex].g_flVisionRange = 150.0;
				g_esVisionAbility[iIndex].g_flVisionRangeChance = 15.0;
				g_esVisionAbility[iIndex].g_iVisionRangeCooldown = 0;
				g_esVisionAbility[iIndex].g_iVisionSight = 0;
				g_esVisionAbility[iIndex].g_iVisionStagger = 3;
				g_esVisionAbility[iIndex].g_iVisionType = 0;

				g_esVisionSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esVisionSpecial[iIndex].g_iComboAbility = -1;
				g_esVisionSpecial[iIndex].g_iHumanAbility = -1;
				g_esVisionSpecial[iIndex].g_iHumanAmmo = -1;
				g_esVisionSpecial[iIndex].g_iHumanCooldown = -1;
				g_esVisionSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esVisionSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esVisionSpecial[iIndex].g_iRequiresHumans = -1;
				g_esVisionSpecial[iIndex].g_iVisionAbility = -1;
				g_esVisionSpecial[iIndex].g_iVisionEffect = -1;
				g_esVisionSpecial[iIndex].g_iVisionMessage = -1;
				g_esVisionSpecial[iIndex].g_flVisionChance = -1.0;
				g_esVisionSpecial[iIndex].g_iVisionCooldown = -1;
				g_esVisionSpecial[iIndex].g_iVisionDeath = -1;
				g_esVisionSpecial[iIndex].g_flVisionDeathChance = -1.0;
				g_esVisionSpecial[iIndex].g_flVisionDeathRange = -1.0;
				g_esVisionSpecial[iIndex].g_flVisionDuration = -1.0;
				g_esVisionSpecial[iIndex].g_iVisionFOV = -1;
				g_esVisionSpecial[iIndex].g_iVisionHit = -1;
				g_esVisionSpecial[iIndex].g_iVisionHitMode = -1;
				g_esVisionSpecial[iIndex].g_iVisionIntensity = -1;
				g_esVisionSpecial[iIndex].g_flVisionInterval = -1.0;
				g_esVisionSpecial[iIndex].g_iVisionMode = -1;
				g_esVisionSpecial[iIndex].g_flVisionRange = -1.0;
				g_esVisionSpecial[iIndex].g_flVisionRangeChance = -1.0;
				g_esVisionSpecial[iIndex].g_iVisionRangeCooldown = -1;
				g_esVisionSpecial[iIndex].g_iVisionSight = -1;
				g_esVisionSpecial[iIndex].g_iVisionStagger = -1;
				g_esVisionSpecial[iIndex].g_iVisionType = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esVisionPlayer[iPlayer].g_iAccessFlags = -1;
				g_esVisionPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esVisionPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esVisionPlayer[iPlayer].g_iComboAbility = -1;
				g_esVisionPlayer[iPlayer].g_iHumanAbility = -1;
				g_esVisionPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esVisionPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esVisionPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esVisionPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esVisionPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esVisionPlayer[iPlayer].g_iVisionAbility = -1;
				g_esVisionPlayer[iPlayer].g_iVisionEffect = -1;
				g_esVisionPlayer[iPlayer].g_iVisionMessage = -1;
				g_esVisionPlayer[iPlayer].g_flVisionChance = -1.0;
				g_esVisionPlayer[iPlayer].g_iVisionCooldown = -1;
				g_esVisionPlayer[iPlayer].g_iVisionDeath = -1;
				g_esVisionPlayer[iPlayer].g_flVisionDeathChance = -1.0;
				g_esVisionPlayer[iPlayer].g_flVisionDeathRange = -1.0;
				g_esVisionPlayer[iPlayer].g_flVisionDuration = -1.0;
				g_esVisionPlayer[iPlayer].g_iVisionFOV = -1;
				g_esVisionPlayer[iPlayer].g_iVisionHit = -1;
				g_esVisionPlayer[iPlayer].g_iVisionHitMode = -1;
				g_esVisionPlayer[iPlayer].g_iVisionIntensity = -1;
				g_esVisionPlayer[iPlayer].g_flVisionInterval = -1.0;
				g_esVisionPlayer[iPlayer].g_iVisionMode = -1;
				g_esVisionPlayer[iPlayer].g_flVisionRange = -1.0;
				g_esVisionPlayer[iPlayer].g_flVisionRangeChance = -1.0;
				g_esVisionPlayer[iPlayer].g_iVisionRangeCooldown = -1;
				g_esVisionPlayer[iPlayer].g_iVisionSight = -1;
				g_esVisionPlayer[iPlayer].g_iVisionStagger = -1;
				g_esVisionPlayer[iPlayer].g_iVisionType = -1;

				g_esVisionTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esVisionTeammate[iPlayer].g_iComboAbility = -1;
				g_esVisionTeammate[iPlayer].g_iHumanAbility = -1;
				g_esVisionTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esVisionTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esVisionTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esVisionTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esVisionTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esVisionTeammate[iPlayer].g_iVisionAbility = -1;
				g_esVisionTeammate[iPlayer].g_iVisionEffect = -1;
				g_esVisionTeammate[iPlayer].g_iVisionMessage = -1;
				g_esVisionTeammate[iPlayer].g_flVisionChance = -1.0;
				g_esVisionTeammate[iPlayer].g_iVisionCooldown = -1;
				g_esVisionTeammate[iPlayer].g_iVisionDeath = -1;
				g_esVisionTeammate[iPlayer].g_flVisionDeathChance = -1.0;
				g_esVisionTeammate[iPlayer].g_flVisionDeathRange = -1.0;
				g_esVisionTeammate[iPlayer].g_flVisionDuration = -1.0;
				g_esVisionTeammate[iPlayer].g_iVisionFOV = -1;
				g_esVisionTeammate[iPlayer].g_iVisionHit = -1;
				g_esVisionTeammate[iPlayer].g_iVisionHitMode = -1;
				g_esVisionTeammate[iPlayer].g_iVisionIntensity = -1;
				g_esVisionTeammate[iPlayer].g_flVisionInterval = -1.0;
				g_esVisionTeammate[iPlayer].g_iVisionMode = -1;
				g_esVisionTeammate[iPlayer].g_flVisionRange = -1.0;
				g_esVisionTeammate[iPlayer].g_flVisionRangeChance = -1.0;
				g_esVisionTeammate[iPlayer].g_iVisionRangeCooldown = -1;
				g_esVisionTeammate[iPlayer].g_iVisionSight = -1;
				g_esVisionTeammate[iPlayer].g_iVisionStagger = -1;
				g_esVisionTeammate[iPlayer].g_iVisionType = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vVisionConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esVisionTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esVisionTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esVisionTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esVisionTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esVisionTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esVisionTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esVisionTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esVisionTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esVisionTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esVisionTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esVisionTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esVisionTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esVisionTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esVisionTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esVisionTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esVisionTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esVisionTeammate[admin].g_iVisionAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esVisionTeammate[admin].g_iVisionAbility, value, -1, 1);
			g_esVisionTeammate[admin].g_iVisionEffect = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esVisionTeammate[admin].g_iVisionEffect, value, -1, 7);
			g_esVisionTeammate[admin].g_iVisionMessage = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esVisionTeammate[admin].g_iVisionMessage, value, -1, 3);
			g_esVisionTeammate[admin].g_iVisionSight = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esVisionTeammate[admin].g_iVisionSight, value, -1, 5);
			g_esVisionTeammate[admin].g_flVisionChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionChance", "Vision Chance", "Vision_Chance", "chance", g_esVisionTeammate[admin].g_flVisionChance, value, -1.0, 100.0);
			g_esVisionTeammate[admin].g_iVisionCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionCooldown", "Vision Cooldown", "Vision_Cooldown", "cooldown", g_esVisionTeammate[admin].g_iVisionCooldown, value, -1, 99999);
			g_esVisionTeammate[admin].g_iVisionDeath = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeath", "Vision Death", "Vision_Death", "death", g_esVisionTeammate[admin].g_iVisionDeath, value, -1, 3);
			g_esVisionTeammate[admin].g_flVisionDeathChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeathChance", "Vision Death Chance", "Vision_Death_Chance", "deathchance", g_esVisionTeammate[admin].g_flVisionDeathChance, value, -1.0, 100.0);
			g_esVisionTeammate[admin].g_flVisionDeathRange = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeathRange", "Vision Death Range", "Vision_Death_Range", "deathrange", g_esVisionTeammate[admin].g_flVisionDeathRange, value, -1.0, 99999.0);
			g_esVisionTeammate[admin].g_flVisionDuration = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDuration", "Vision Duration", "Vision_Duration", "duration", g_esVisionTeammate[admin].g_flVisionDuration, value, -1.0, 99999.0);
			g_esVisionTeammate[admin].g_iVisionFOV = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionFOV", "Vision FOV", "Vision_FOV", "fov", g_esVisionTeammate[admin].g_iVisionFOV, value, -1, 160);
			g_esVisionTeammate[admin].g_iVisionHit = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionHit", "Vision Hit", "Vision_Hit", "hit", g_esVisionTeammate[admin].g_iVisionHit, value, -1, 1);
			g_esVisionTeammate[admin].g_iVisionHitMode = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionHitMode", "Vision Hit Mode", "Vision_Hit_Mode", "hitmode", g_esVisionTeammate[admin].g_iVisionHitMode, value, -1, 2);
			g_esVisionTeammate[admin].g_iVisionIntensity = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionIntensity", "Vision Intensity", "Vision_Intensity", "intensity", g_esVisionTeammate[admin].g_iVisionIntensity, value, -1, 255);
			g_esVisionTeammate[admin].g_flVisionInterval = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionInterval", "Vision Interval", "Vision_Interval", "interval", g_esVisionTeammate[admin].g_flVisionInterval, value, -1.0, 99999.0);
			g_esVisionTeammate[admin].g_iVisionMode = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionMode", "Vision Mode", "Vision_Mode", "mode", g_esVisionTeammate[admin].g_iVisionMode, value, -1, 31);
			g_esVisionTeammate[admin].g_flVisionRange = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRange", "Vision Range", "Vision_Range", "range", g_esVisionTeammate[admin].g_flVisionRange, value, -1.0, 99999.0);
			g_esVisionTeammate[admin].g_flVisionRangeChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRangeChance", "Vision Range Chance", "Vision_Range_Chance", "rangechance", g_esVisionTeammate[admin].g_flVisionRangeChance, value, -1.0, 100.0);
			g_esVisionTeammate[admin].g_iVisionRangeCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRangeCooldown", "Vision Range Cooldown", "Vision_Range_Cooldown", "rangecooldown", g_esVisionTeammate[admin].g_iVisionRangeCooldown, value, -1, 99999);
			g_esVisionTeammate[admin].g_iVisionStagger = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionStagger", "Vision Stagger", "Vision_Stagger", "stagger", g_esVisionTeammate[admin].g_iVisionStagger, value, -1, 3);
			g_esVisionTeammate[admin].g_iVisionType = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionType", "Vision Type", "Vision_Type", "type", g_esVisionTeammate[admin].g_iVisionType, value, -1, sizeof g_sParticles);
		}
		else
		{
			g_esVisionPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esVisionPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esVisionPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esVisionPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esVisionPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esVisionPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esVisionPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esVisionPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esVisionPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esVisionPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esVisionPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esVisionPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esVisionPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esVisionPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esVisionPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esVisionPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esVisionPlayer[admin].g_iVisionAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esVisionPlayer[admin].g_iVisionAbility, value, -1, 1);
			g_esVisionPlayer[admin].g_iVisionEffect = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esVisionPlayer[admin].g_iVisionEffect, value, -1, 7);
			g_esVisionPlayer[admin].g_iVisionMessage = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esVisionPlayer[admin].g_iVisionMessage, value, -1, 3);
			g_esVisionPlayer[admin].g_iVisionSight = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esVisionPlayer[admin].g_iVisionSight, value, -1, 5);
			g_esVisionPlayer[admin].g_flVisionChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionChance", "Vision Chance", "Vision_Chance", "chance", g_esVisionPlayer[admin].g_flVisionChance, value, -1.0, 100.0);
			g_esVisionPlayer[admin].g_iVisionCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionCooldown", "Vision Cooldown", "Vision_Cooldown", "cooldown", g_esVisionPlayer[admin].g_iVisionCooldown, value, -1, 99999);
			g_esVisionPlayer[admin].g_iVisionDeath = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeath", "Vision Death", "Vision_Death", "death", g_esVisionPlayer[admin].g_iVisionDeath, value, -1, 3);
			g_esVisionPlayer[admin].g_flVisionDeathChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeathChance", "Vision Death Chance", "Vision_Death_Chance", "deathchance", g_esVisionPlayer[admin].g_flVisionDeathChance, value, -1.0, 100.0);
			g_esVisionPlayer[admin].g_flVisionDeathRange = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeathRange", "Vision Death Range", "Vision_Death_Range", "deathrange", g_esVisionPlayer[admin].g_flVisionDeathRange, value, -1.0, 99999.0);
			g_esVisionPlayer[admin].g_flVisionDuration = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDuration", "Vision Duration", "Vision_Duration", "duration", g_esVisionPlayer[admin].g_flVisionDuration, value, -1.0, 99999.0);
			g_esVisionPlayer[admin].g_iVisionFOV = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionFOV", "Vision FOV", "Vision_FOV", "fov", g_esVisionPlayer[admin].g_iVisionFOV, value, -1, 160);
			g_esVisionPlayer[admin].g_iVisionHit = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionHit", "Vision Hit", "Vision_Hit", "hit", g_esVisionPlayer[admin].g_iVisionHit, value, -1, 1);
			g_esVisionPlayer[admin].g_iVisionHitMode = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionHitMode", "Vision Hit Mode", "Vision_Hit_Mode", "hitmode", g_esVisionPlayer[admin].g_iVisionHitMode, value, -1, 2);
			g_esVisionPlayer[admin].g_iVisionIntensity = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionIntensity", "Vision Intensity", "Vision_Intensity", "intensity", g_esVisionPlayer[admin].g_iVisionIntensity, value, -1, 255);
			g_esVisionPlayer[admin].g_flVisionInterval = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionInterval", "Vision Interval", "Vision_Interval", "interval", g_esVisionPlayer[admin].g_flVisionInterval, value, -1.0, 99999.0);
			g_esVisionPlayer[admin].g_iVisionMode = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionMode", "Vision Mode", "Vision_Mode", "mode", g_esVisionPlayer[admin].g_iVisionMode, value, -1, 31);
			g_esVisionPlayer[admin].g_flVisionRange = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRange", "Vision Range", "Vision_Range", "range", g_esVisionPlayer[admin].g_flVisionRange, value, -1.0, 99999.0);
			g_esVisionPlayer[admin].g_flVisionRangeChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRangeChance", "Vision Range Chance", "Vision_Range_Chance", "rangechance", g_esVisionPlayer[admin].g_flVisionRangeChance, value, -1.0, 100.0);
			g_esVisionPlayer[admin].g_iVisionRangeCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRangeCooldown", "Vision Range Cooldown", "Vision_Range_Cooldown", "rangecooldown", g_esVisionPlayer[admin].g_iVisionRangeCooldown, value, -1, 99999);
			g_esVisionPlayer[admin].g_iVisionStagger = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionStagger", "Vision Stagger", "Vision_Stagger", "stagger", g_esVisionPlayer[admin].g_iVisionStagger, value, -1, 3);
			g_esVisionPlayer[admin].g_iVisionType = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionType", "Vision Type", "Vision_Type", "type", g_esVisionPlayer[admin].g_iVisionType, value, -1, sizeof g_sParticles);
			g_esVisionPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esVisionPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esVisionSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "openareas", g_esVisionSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esVisionSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esVisionSpecial[type].g_iComboAbility, value, -1, 1);
			g_esVisionSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esVisionSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esVisionSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esVisionSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esVisionSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esVisionSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esVisionSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esVisionSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esVisionSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esVisionSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esVisionSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esVisionSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esVisionSpecial[type].g_iVisionAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esVisionSpecial[type].g_iVisionAbility, value, -1, 1);
			g_esVisionSpecial[type].g_iVisionEffect = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esVisionSpecial[type].g_iVisionEffect, value, -1, 7);
			g_esVisionSpecial[type].g_iVisionMessage = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esVisionSpecial[type].g_iVisionMessage, value, -1, 3);
			g_esVisionSpecial[type].g_iVisionSight = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esVisionSpecial[type].g_iVisionSight, value, -1, 5);
			g_esVisionSpecial[type].g_flVisionChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionChance", "Vision Chance", "Vision_Chance", "chance", g_esVisionSpecial[type].g_flVisionChance, value, -1.0, 100.0);
			g_esVisionSpecial[type].g_iVisionCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionCooldown", "Vision Cooldown", "Vision_Cooldown", "cooldown", g_esVisionSpecial[type].g_iVisionCooldown, value, -1, 99999);
			g_esVisionSpecial[type].g_iVisionDeath = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeath", "Vision Death", "Vision_Death", "death", g_esVisionSpecial[type].g_iVisionDeath, value, -1, 3);
			g_esVisionSpecial[type].g_flVisionDeathChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeathChance", "Vision Death Chance", "Vision_Death_Chance", "deathchance", g_esVisionSpecial[type].g_flVisionDeathChance, value, -1.0, 100.0);
			g_esVisionSpecial[type].g_flVisionDeathRange = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeathRange", "Vision Death Range", "Vision_Death_Range", "deathrange", g_esVisionSpecial[type].g_flVisionDeathRange, value, -1.0, 99999.0);
			g_esVisionSpecial[type].g_flVisionDuration = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDuration", "Vision Duration", "Vision_Duration", "duration", g_esVisionSpecial[type].g_flVisionDuration, value, -1.0, 99999.0);
			g_esVisionSpecial[type].g_iVisionFOV = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionFOV", "Vision FOV", "Vision_FOV", "fov", g_esVisionSpecial[type].g_iVisionFOV, value, -1, 160);
			g_esVisionSpecial[type].g_iVisionHit = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionHit", "Vision Hit", "Vision_Hit", "hit", g_esVisionSpecial[type].g_iVisionHit, value, -1, 1);
			g_esVisionSpecial[type].g_iVisionHitMode = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionHitMode", "Vision Hit Mode", "Vision_Hit_Mode", "hitmode", g_esVisionSpecial[type].g_iVisionHitMode, value, -1, 2);
			g_esVisionSpecial[type].g_iVisionIntensity = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionIntensity", "Vision Intensity", "Vision_Intensity", "intensity", g_esVisionSpecial[type].g_iVisionIntensity, value, -1, 255);
			g_esVisionSpecial[type].g_flVisionInterval = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionInterval", "Vision Interval", "Vision_Interval", "interval", g_esVisionSpecial[type].g_flVisionInterval, value, -1.0, 99999.0);
			g_esVisionSpecial[type].g_iVisionMode = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionMode", "Vision Mode", "Vision_Mode", "mode", g_esVisionSpecial[type].g_iVisionMode, value, -1, 31);
			g_esVisionSpecial[type].g_flVisionRange = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRange", "Vision Range", "Vision_Range", "range", g_esVisionSpecial[type].g_flVisionRange, value, -1.0, 99999.0);
			g_esVisionSpecial[type].g_flVisionRangeChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRangeChance", "Vision Range Chance", "Vision_Range_Chance", "rangechance", g_esVisionSpecial[type].g_flVisionRangeChance, value, -1.0, 100.0);
			g_esVisionSpecial[type].g_iVisionRangeCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRangeCooldown", "Vision Range Cooldown", "Vision_Range_Cooldown", "rangecooldown", g_esVisionSpecial[type].g_iVisionRangeCooldown, value, -1, 99999);
			g_esVisionSpecial[type].g_iVisionStagger = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionStagger", "Vision Stagger", "Vision_Stagger", "stagger", g_esVisionSpecial[type].g_iVisionStagger, value, -1, 3);
			g_esVisionSpecial[type].g_iVisionType = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionType", "Vision Type", "Vision_Type", "type", g_esVisionSpecial[type].g_iVisionType, value, -1, sizeof g_sParticles);
		}
		else
		{
			g_esVisionAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "openareas", g_esVisionAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esVisionAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esVisionAbility[type].g_iComboAbility, value, -1, 1);
			g_esVisionAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esVisionAbility[type].g_iHumanAbility, value, -1, 2);
			g_esVisionAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esVisionAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esVisionAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esVisionAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esVisionAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esVisionAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esVisionAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esVisionAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esVisionAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esVisionAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esVisionAbility[type].g_iVisionAbility = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esVisionAbility[type].g_iVisionAbility, value, -1, 1);
			g_esVisionAbility[type].g_iVisionEffect = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esVisionAbility[type].g_iVisionEffect, value, -1, 7);
			g_esVisionAbility[type].g_iVisionMessage = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esVisionAbility[type].g_iVisionMessage, value, -1, 3);
			g_esVisionAbility[type].g_iVisionSight = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esVisionAbility[type].g_iVisionSight, value, -1, 5);
			g_esVisionAbility[type].g_flVisionChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionChance", "Vision Chance", "Vision_Chance", "chance", g_esVisionAbility[type].g_flVisionChance, value, -1.0, 100.0);
			g_esVisionAbility[type].g_iVisionCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionCooldown", "Vision Cooldown", "Vision_Cooldown", "cooldown", g_esVisionAbility[type].g_iVisionCooldown, value, -1, 99999);
			g_esVisionAbility[type].g_iVisionDeath = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeath", "Vision Death", "Vision_Death", "death", g_esVisionAbility[type].g_iVisionDeath, value, -1, 3);
			g_esVisionAbility[type].g_flVisionDeathChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeathChance", "Vision Death Chance", "Vision_Death_Chance", "deathchance", g_esVisionAbility[type].g_flVisionDeathChance, value, -1.0, 100.0);
			g_esVisionAbility[type].g_flVisionDeathRange = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDeathRange", "Vision Death Range", "Vision_Death_Range", "deathrange", g_esVisionAbility[type].g_flVisionDeathRange, value, -1.0, 99999.0);
			g_esVisionAbility[type].g_flVisionDuration = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionDuration", "Vision Duration", "Vision_Duration", "duration", g_esVisionAbility[type].g_flVisionDuration, value, -1.0, 99999.0);
			g_esVisionAbility[type].g_iVisionFOV = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionFOV", "Vision FOV", "Vision_FOV", "fov", g_esVisionAbility[type].g_iVisionFOV, value, -1, 160);
			g_esVisionAbility[type].g_iVisionHit = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionHit", "Vision Hit", "Vision_Hit", "hit", g_esVisionAbility[type].g_iVisionHit, value, -1, 1);
			g_esVisionAbility[type].g_iVisionHitMode = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionHitMode", "Vision Hit Mode", "Vision_Hit_Mode", "hitmode", g_esVisionAbility[type].g_iVisionHitMode, value, -1, 2);
			g_esVisionAbility[type].g_iVisionIntensity = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionIntensity", "Vision Intensity", "Vision_Intensity", "intensity", g_esVisionAbility[type].g_iVisionIntensity, value, -1, 255);
			g_esVisionAbility[type].g_flVisionInterval = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionInterval", "Vision Interval", "Vision_Interval", "interval", g_esVisionAbility[type].g_flVisionInterval, value, -1.0, 99999.0);
			g_esVisionAbility[type].g_iVisionMode = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionMode", "Vision Mode", "Vision_Mode", "mode", g_esVisionAbility[type].g_iVisionMode, value, -1, 31);
			g_esVisionAbility[type].g_flVisionRange = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRange", "Vision Range", "Vision_Range", "range", g_esVisionAbility[type].g_flVisionRange, value, -1.0, 99999.0);
			g_esVisionAbility[type].g_flVisionRangeChance = flGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRangeChance", "Vision Range Chance", "Vision_Range_Chance", "rangechance", g_esVisionAbility[type].g_flVisionRangeChance, value, -1.0, 100.0);
			g_esVisionAbility[type].g_iVisionRangeCooldown = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionRangeCooldown", "Vision Range Cooldown", "Vision_Range_Cooldown", "rangecooldown", g_esVisionAbility[type].g_iVisionRangeCooldown, value, -1, 99999);
			g_esVisionAbility[type].g_iVisionStagger = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionStagger", "Vision Stagger", "Vision_Stagger", "stagger", g_esVisionAbility[type].g_iVisionStagger, value, -1, 3);
			g_esVisionAbility[type].g_iVisionType = iGetKeyValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "VisionType", "Vision Type", "Vision_Type", "type", g_esVisionAbility[type].g_iVisionType, value, -1, sizeof g_sParticles);
			g_esVisionAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esVisionAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_VISION_SECTION, MT_VISION_SECTION2, MT_VISION_SECTION3, MT_VISION_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vVisionSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esVisionPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esVisionPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esVisionPlayer[tank].g_iTankTypeRecorded;
#if !defined MT_ABILITIES_MAIN2
	g_iGraphicsLevel = MT_GetGraphicsLevel();
#endif
	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esVisionCache[tank].g_flVisionChance = flGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_flVisionChance, g_esVisionPlayer[tank].g_flVisionChance, g_esVisionSpecial[iType].g_flVisionChance, g_esVisionAbility[iType].g_flVisionChance, 1);
		g_esVisionCache[tank].g_flVisionDeathChance = flGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_flVisionDeathChance, g_esVisionPlayer[tank].g_flVisionDeathChance, g_esVisionSpecial[iType].g_flVisionDeathChance, g_esVisionAbility[iType].g_flVisionDeathChance, 1);
		g_esVisionCache[tank].g_flVisionDeathRange = flGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_flVisionDeathRange, g_esVisionPlayer[tank].g_flVisionDeathRange, g_esVisionSpecial[iType].g_flVisionDeathRange, g_esVisionAbility[iType].g_flVisionDeathRange, 1);
		g_esVisionCache[tank].g_flVisionDuration = flGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_flVisionDuration, g_esVisionPlayer[tank].g_flVisionDuration, g_esVisionSpecial[iType].g_flVisionDuration, g_esVisionAbility[iType].g_flVisionDuration, 1);
		g_esVisionCache[tank].g_flVisionInterval = flGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_flVisionInterval, g_esVisionPlayer[tank].g_flVisionInterval, g_esVisionSpecial[iType].g_flVisionInterval, g_esVisionAbility[iType].g_flVisionInterval, 1);
		g_esVisionCache[tank].g_flVisionRange = flGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_flVisionRange, g_esVisionPlayer[tank].g_flVisionRange, g_esVisionSpecial[iType].g_flVisionRange, g_esVisionAbility[iType].g_flVisionRange, 1);
		g_esVisionCache[tank].g_flVisionRangeChance = flGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_flVisionRangeChance, g_esVisionPlayer[tank].g_flVisionRangeChance, g_esVisionSpecial[iType].g_flVisionRangeChance, g_esVisionAbility[iType].g_flVisionRangeChance, 1);
		g_esVisionCache[tank].g_iVisionAbility = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionAbility, g_esVisionPlayer[tank].g_iVisionAbility, g_esVisionSpecial[iType].g_iVisionAbility, g_esVisionAbility[iType].g_iVisionAbility, 1);
		g_esVisionCache[tank].g_iVisionCooldown = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionCooldown, g_esVisionPlayer[tank].g_iVisionCooldown, g_esVisionSpecial[iType].g_iVisionCooldown, g_esVisionAbility[iType].g_iVisionCooldown, 1);
		g_esVisionCache[tank].g_iVisionDeath = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionDeath, g_esVisionPlayer[tank].g_iVisionDeath, g_esVisionSpecial[iType].g_iVisionDeath, g_esVisionAbility[iType].g_iVisionDeath, 1);
		g_esVisionCache[tank].g_iVisionEffect = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionEffect, g_esVisionPlayer[tank].g_iVisionEffect, g_esVisionSpecial[iType].g_iVisionEffect, g_esVisionAbility[iType].g_iVisionEffect, 1);
		g_esVisionCache[tank].g_iVisionFOV = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionFOV, g_esVisionPlayer[tank].g_iVisionFOV, g_esVisionSpecial[iType].g_iVisionFOV, g_esVisionAbility[iType].g_iVisionFOV, 1);
		g_esVisionCache[tank].g_iVisionHit = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionHit, g_esVisionPlayer[tank].g_iVisionHit, g_esVisionSpecial[iType].g_iVisionHit, g_esVisionAbility[iType].g_iVisionHit, 1);
		g_esVisionCache[tank].g_iVisionHitMode = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionHitMode, g_esVisionPlayer[tank].g_iVisionHitMode, g_esVisionSpecial[iType].g_iVisionHitMode, g_esVisionAbility[iType].g_iVisionHitMode, 1);
		g_esVisionCache[tank].g_iVisionIntensity = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionIntensity, g_esVisionPlayer[tank].g_iVisionIntensity, g_esVisionSpecial[iType].g_iVisionIntensity, g_esVisionAbility[iType].g_iVisionIntensity, 1);
		g_esVisionCache[tank].g_iVisionMessage = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionMessage, g_esVisionPlayer[tank].g_iVisionMessage, g_esVisionSpecial[iType].g_iVisionMessage, g_esVisionAbility[iType].g_iVisionMessage, 1);
		g_esVisionCache[tank].g_iVisionMode = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionMode, g_esVisionPlayer[tank].g_iVisionMode, g_esVisionSpecial[iType].g_iVisionMode, g_esVisionAbility[iType].g_iVisionMode, 1);
		g_esVisionCache[tank].g_iVisionRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionRangeCooldown, g_esVisionPlayer[tank].g_iVisionRangeCooldown, g_esVisionSpecial[iType].g_iVisionRangeCooldown, g_esVisionAbility[iType].g_iVisionRangeCooldown, 1);
		g_esVisionCache[tank].g_iVisionSight = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionSight, g_esVisionPlayer[tank].g_iVisionSight, g_esVisionSpecial[iType].g_iVisionSight, g_esVisionAbility[iType].g_iVisionSight, 1);
		g_esVisionCache[tank].g_iVisionStagger = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionStagger, g_esVisionPlayer[tank].g_iVisionStagger, g_esVisionSpecial[iType].g_iVisionStagger, g_esVisionAbility[iType].g_iVisionStagger, 1);
		g_esVisionCache[tank].g_iVisionType = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iVisionType, g_esVisionPlayer[tank].g_iVisionType, g_esVisionSpecial[iType].g_iVisionType, g_esVisionAbility[iType].g_iVisionType, 1);
		g_esVisionCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_flCloseAreasOnly, g_esVisionPlayer[tank].g_flCloseAreasOnly, g_esVisionSpecial[iType].g_flCloseAreasOnly, g_esVisionAbility[iType].g_flCloseAreasOnly, 1);
		g_esVisionCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iComboAbility, g_esVisionPlayer[tank].g_iComboAbility, g_esVisionSpecial[iType].g_iComboAbility, g_esVisionAbility[iType].g_iComboAbility, 1);
		g_esVisionCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iHumanAbility, g_esVisionPlayer[tank].g_iHumanAbility, g_esVisionSpecial[iType].g_iHumanAbility, g_esVisionAbility[iType].g_iHumanAbility, 1);
		g_esVisionCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iHumanAmmo, g_esVisionPlayer[tank].g_iHumanAmmo, g_esVisionSpecial[iType].g_iHumanAmmo, g_esVisionAbility[iType].g_iHumanAmmo, 1);
		g_esVisionCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iHumanCooldown, g_esVisionPlayer[tank].g_iHumanCooldown, g_esVisionSpecial[iType].g_iHumanCooldown, g_esVisionAbility[iType].g_iHumanCooldown, 1);
		g_esVisionCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iHumanRangeCooldown, g_esVisionPlayer[tank].g_iHumanRangeCooldown, g_esVisionSpecial[iType].g_iHumanRangeCooldown, g_esVisionAbility[iType].g_iHumanRangeCooldown, 1);
		g_esVisionCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_flOpenAreasOnly, g_esVisionPlayer[tank].g_flOpenAreasOnly, g_esVisionSpecial[iType].g_flOpenAreasOnly, g_esVisionAbility[iType].g_flOpenAreasOnly, 1);
		g_esVisionCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esVisionTeammate[tank].g_iRequiresHumans, g_esVisionPlayer[tank].g_iRequiresHumans, g_esVisionSpecial[iType].g_iRequiresHumans, g_esVisionAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esVisionCache[tank].g_flVisionChance = flGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_flVisionChance, g_esVisionAbility[iType].g_flVisionChance, 1);
		g_esVisionCache[tank].g_flVisionDeathChance = flGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_flVisionDeathChance, g_esVisionAbility[iType].g_flVisionDeathChance, 1);
		g_esVisionCache[tank].g_flVisionDeathRange = flGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_flVisionDeathRange, g_esVisionAbility[iType].g_flVisionDeathRange, 1);
		g_esVisionCache[tank].g_flVisionDuration = flGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_flVisionDuration, g_esVisionAbility[iType].g_flVisionDuration, 1);
		g_esVisionCache[tank].g_flVisionInterval = flGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_flVisionInterval, g_esVisionAbility[iType].g_flVisionInterval, 1);
		g_esVisionCache[tank].g_flVisionRange = flGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_flVisionRange, g_esVisionAbility[iType].g_flVisionRange, 1);
		g_esVisionCache[tank].g_flVisionRangeChance = flGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_flVisionRangeChance, g_esVisionAbility[iType].g_flVisionRangeChance, 1);
		g_esVisionCache[tank].g_iVisionAbility = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionAbility, g_esVisionAbility[iType].g_iVisionAbility, 1);
		g_esVisionCache[tank].g_iVisionCooldown = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionCooldown, g_esVisionAbility[iType].g_iVisionCooldown, 1);
		g_esVisionCache[tank].g_iVisionDeath = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionDeath, g_esVisionAbility[iType].g_iVisionDeath, 1);
		g_esVisionCache[tank].g_iVisionEffect = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionEffect, g_esVisionAbility[iType].g_iVisionEffect, 1);
		g_esVisionCache[tank].g_iVisionFOV = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionFOV, g_esVisionAbility[iType].g_iVisionFOV, 1);
		g_esVisionCache[tank].g_iVisionHit = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionHit, g_esVisionAbility[iType].g_iVisionHit, 1);
		g_esVisionCache[tank].g_iVisionHitMode = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionHitMode, g_esVisionAbility[iType].g_iVisionHitMode, 1);
		g_esVisionCache[tank].g_iVisionIntensity = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionIntensity, g_esVisionAbility[iType].g_iVisionIntensity, 1);
		g_esVisionCache[tank].g_iVisionMessage = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionMessage, g_esVisionAbility[iType].g_iVisionMessage, 1);
		g_esVisionCache[tank].g_iVisionMode = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionMode, g_esVisionAbility[iType].g_iVisionMode, 1);
		g_esVisionCache[tank].g_iVisionRangeCooldown = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionRangeCooldown, g_esVisionAbility[iType].g_iVisionRangeCooldown, 1);
		g_esVisionCache[tank].g_iVisionSight = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionSight, g_esVisionAbility[iType].g_iVisionSight, 1);
		g_esVisionCache[tank].g_iVisionStagger = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionStagger, g_esVisionAbility[iType].g_iVisionStagger, 1);
		g_esVisionCache[tank].g_iVisionType = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iVisionType, g_esVisionAbility[iType].g_iVisionType, 1);
		g_esVisionCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_flCloseAreasOnly, g_esVisionAbility[iType].g_flCloseAreasOnly, 1);
		g_esVisionCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iComboAbility, g_esVisionAbility[iType].g_iComboAbility, 1);
		g_esVisionCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iHumanAbility, g_esVisionAbility[iType].g_iHumanAbility, 1);
		g_esVisionCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iHumanAmmo, g_esVisionAbility[iType].g_iHumanAmmo, 1);
		g_esVisionCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iHumanCooldown, g_esVisionAbility[iType].g_iHumanCooldown, 1);
		g_esVisionCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iHumanRangeCooldown, g_esVisionAbility[iType].g_iHumanRangeCooldown, 1);
		g_esVisionCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_flOpenAreasOnly, g_esVisionAbility[iType].g_flOpenAreasOnly, 1);
		g_esVisionCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esVisionPlayer[tank].g_iRequiresHumans, g_esVisionAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN2
void vVisionCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vVisionCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveVision(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vVisionPluginEnd()
#else
public void MT_OnPluginEnd()
#endif
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			vRemoveVision(iPlayer);
		}
		else if (bIsHumanSurvivor(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esVisionPlayer[iPlayer].g_bAffected)
		{
			SetEntProp(iPlayer, Prop_Send, "m_iFOV", 90);
			SetEntProp(iPlayer, Prop_Send, "m_iDefaultFOV", 90);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vVisionEventFired(Event event, const char[] name)
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
			vVisionCopyStats2(iBot, iTank);
			vRemoveVision(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vVisionReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vVisionCopyStats2(iTank, iBot);
			vRemoveVision(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
		if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vVisionRange(iPlayer, 1, 0, GetRandomFloat(0.1, 100.0));
			vRemoveVision(iPlayer);
		}
		else if (bIsHumanSurvivor(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vVision(iPlayer, 0);
			vStopVision(iPlayer);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vVisionHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esVisionCache[iBoomer].g_flVisionChance, g_esVisionCache[iBoomer].g_iVisionHit, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);
		}
	}
	else if (StrEqual(name, "player_spawn"))
	{
		int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
		if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vVisionRange(iPlayer, 1, 1, GetRandomFloat(0.1, 100.0));
			vRemoveVision(iPlayer);
		}
		else if (bIsHumanSurvivor(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vVision(iPlayer, 0);
			vStopVision(iPlayer);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vVisionAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esVisionAbility[g_esVisionPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[tank].g_iAccessFlags)) || g_esVisionCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esVisionCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esVisionCache[tank].g_iVisionAbility == 1 && g_esVisionCache[tank].g_iComboAbility == 0)
	{
		vVisionAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN2
void vVisionButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esVisionCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esVisionCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esVisionPlayer[tank].g_iTankType, tank) || (g_esVisionCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esVisionCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esVisionAbility[g_esVisionPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esVisionCache[tank].g_iVisionAbility == 1 && g_esVisionCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();

			switch (g_esVisionPlayer[tank].g_iRangeCooldown == -1 || g_esVisionPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vVisionAbility(tank, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman3", (g_esVisionPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vVisionChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveVision(tank);
}

#if defined MT_ABILITIES_MAIN2
void vVisionPostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	vVisionRange(tank, 1, 1, GetRandomFloat(0.1, 100.0));
}

void vVision(int survivor, int intensity)
{
	int iTargets[1], iFlags = (intensity == 0) ? (MT_FADE_IN|MT_FADE_PURGE) : (MT_FADE_OUT|MT_FADE_STAYOUT), iColor[4] = {0, 0, 0, 0};
	iTargets[0] = survivor;
	iColor[3] = intensity;

	Handle hMessage = StartMessageEx(g_umVisionFade, iTargets, 1);
	if (hMessage != null)
	{
		BfWrite bfWrite = UserMessageToBfWrite(hMessage);
		bfWrite.WriteShort(1536);
		bfWrite.WriteShort(1536);
		bfWrite.WriteShort(iFlags);

		for (int iPos = 0; iPos < (sizeof iColor); iPos++)
		{
			bfWrite.WriteByte(iColor[iPos]);
		}

		EndMessage();
	}
}

void vVision2(int survivor, int red = 255, int green = 255, int blue = 255, int alpha = 255)
{
	if (g_iGraphicsLevel > 0)
	{
		int iTargets[2];
		iTargets[0] = survivor;

		Handle hMessage = StartMessageEx(g_umVisionFade, iTargets, 1);
		if (hMessage != null)
		{
			BfWrite bfWrite = UserMessageToBfWrite(hMessage);
			bfWrite.WriteShort(3000);
			bfWrite.WriteShort(100);
			bfWrite.WriteShort(MT_FADE_IN);
			bfWrite.WriteByte(red);
			bfWrite.WriteByte(green);
			bfWrite.WriteByte(blue);
			bfWrite.WriteByte(alpha);

			EndMessage();
		}
	}

	if (g_iGraphicsLevel > 2)
	{
		MT_TE_CreateParticle(.particle = g_iBashedParticle, .all = false);
		TE_SendToClient(survivor);
	}
}

void vVisionAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esVisionCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esVisionCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esVisionPlayer[tank].g_iTankType, tank) || (g_esVisionCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esVisionCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esVisionAbility[g_esVisionPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esVisionPlayer[tank].g_iAmmoCount < g_esVisionCache[tank].g_iHumanAmmo && g_esVisionCache[tank].g_iHumanAmmo > 0))
	{
		g_esVisionPlayer[tank].g_bFailed = false;
		g_esVisionPlayer[tank].g_bNoAmmo = false;

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esVisionCache[tank].g_flVisionRange,
			flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esVisionCache[tank].g_flVisionRangeChance;
		int iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esVisionPlayer[tank].g_iTankType, g_esVisionAbility[g_esVisionPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esVisionPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esVisionCache[tank].g_iVisionSight, .range = flRange))
				{
					vVisionHit(iSurvivor, tank, random, flChance, g_esVisionCache[tank].g_iVisionAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esVisionCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman4");
			}
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esVisionCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionAmmo");
	}
}

void vVisionHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esVisionCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esVisionCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esVisionPlayer[tank].g_iTankType, tank) || (g_esVisionCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esVisionCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esVisionAbility[g_esVisionPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esVisionPlayer[tank].g_iTankType, g_esVisionAbility[g_esVisionPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esVisionPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esVisionPlayer[tank].g_iRangeCooldown != -1 && g_esVisionPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esVisionPlayer[tank].g_iCooldown != -1 && g_esVisionPlayer[tank].g_iCooldown >= iTime))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esVisionPlayer[tank].g_iAmmoCount < g_esVisionCache[tank].g_iHumanAmmo && g_esVisionCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance && !g_esVisionPlayer[survivor].g_bAffected)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esVisionCache[tank].g_iVisionSight, .range = 100.0))
				{
					return;
				}

				g_esVisionPlayer[survivor].g_bAffected = true;
				g_esVisionPlayer[survivor].g_iOwner = tank;

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esVisionPlayer[tank].g_iRangeCooldown == -1 || g_esVisionPlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esVisionCache[tank].g_iHumanAbility == 1)
					{
						g_esVisionPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman", g_esVisionPlayer[tank].g_iAmmoCount, g_esVisionCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esVisionCache[tank].g_iVisionRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esVisionCache[tank].g_iHumanAbility == 1 && g_esVisionPlayer[tank].g_iAmmoCount < g_esVisionCache[tank].g_iHumanAmmo && g_esVisionCache[tank].g_iHumanAmmo > 0) ? g_esVisionCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esVisionPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esVisionPlayer[tank].g_iRangeCooldown != -1 && g_esVisionPlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman5", (g_esVisionPlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esVisionPlayer[tank].g_iCooldown == -1 || g_esVisionPlayer[tank].g_iCooldown <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esVisionCache[tank].g_iVisionCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esVisionCache[tank].g_iHumanAbility == 1) ? g_esVisionCache[tank].g_iHumanCooldown : iCooldown;
					g_esVisionPlayer[tank].g_iCooldown = (iTime + iCooldown);
					if (g_esVisionPlayer[tank].g_iCooldown != -1 && g_esVisionPlayer[tank].g_iCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman5", (g_esVisionPlayer[tank].g_iCooldown - iTime));
					}
				}

				bool bHuman = bIsValidClient(survivor, MT_CHECK_FAKECLIENT);
				if ((g_esVisionCache[tank].g_iVisionMode & MT_VISION_BLIND) && bHuman)
				{
					int iSurvivorId = GetClientUserId(survivor), iTankId = GetClientUserId(tank);
					DataPack dpVision;
					CreateDataTimer(1.0, tTimerVision, dpVision, TIMER_FLAG_NO_MAPCHANGE);
					dpVision.WriteCell(iSurvivorId);
					dpVision.WriteCell(iTankId);
					dpVision.WriteCell(g_esVisionPlayer[tank].g_iTankType);
					dpVision.WriteCell(enabled);

					float flDuration = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : g_esVisionCache[tank].g_flVisionDuration;
					if (flDuration > 0.0)
					{
						DataPack dpStopVision;
						CreateDataTimer(0.1, tTimerStopVision, dpStopVision, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpStopVision.WriteCell(iSurvivorId);
						dpStopVision.WriteCell(iTankId);
						dpStopVision.WriteFloat(GetGameTime());
						dpStopVision.WriteFloat(flDuration + 1.0);
						dpStopVision.WriteCell(messages);
					}

					switch (g_bSecondGame)
					{
						case true: EmitSoundToAll(SOUND_GROAN2, survivor);
						case false: EmitSoundToAll(SOUND_GROAN1, survivor);
					}
				}

				if (g_esVisionCache[tank].g_iVisionMode & MT_VISION_FLASHBANG)
				{
					g_esVisionPlayer[survivor].g_bAffected = false;
					g_esVisionPlayer[survivor].g_iOwner = -1;

					vVision2(survivor, .alpha = 240);
					vShakePlayerScreen(survivor);
					MT_DeafenPlayer(survivor);

					int iStagger = g_esVisionCache[tank].g_iVisionStagger;
					if (iStagger > 0)
					{
						float flTankOrigin[3];
						GetClientAbsOrigin(tank, flTankOrigin);
						if (iStagger == 1 || iStagger == 3)
						{
							MT_StaggerPlayer(survivor, tank, flTankOrigin);
						}

						if (iStagger == 2 || iStagger == 3)
						{
							float flSurvivorOrigin[3], flDirection[3];
							GetClientAbsOrigin(survivor, flSurvivorOrigin);
							MakeVectorFromPoints(flSurvivorOrigin, flTankOrigin, flDirection);
							NormalizeVector(flDirection, flDirection);
							MT_ShoveBySurvivor(tank, survivor, flDirection);
							SetEntPropFloat(tank, Prop_Send, "m_flVelocityModifier", 0.4);
						}
					}
				}
				else if (!(g_esVisionCache[tank].g_iVisionMode & MT_VISION_FLASHBANG))
				{
					vScreenEffect(survivor, tank, g_esVisionCache[tank].g_iVisionEffect, flags);
				}

				if ((g_esVisionCache[tank].g_iVisionMode & MT_VISION_SHAKE) && bHuman)
				{
					EmitSoundToClient(survivor, (g_bSecondGame ? SOUND_SMASH2 : SOUND_SMASH1));
				}

				if (((g_esVisionCache[tank].g_iVisionMode & MT_VISION_SHAKE) || (g_esVisionCache[tank].g_iVisionMode & MT_VISION_SPLATTER)) && bHuman)
				{
					float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 6, pos) : g_esVisionCache[tank].g_flVisionInterval;
					if (flInterval > 0.0)
					{
						DataPack dpVision;
						CreateDataTimer(flInterval, tTimerVision2, dpVision, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpVision.WriteCell(GetClientUserId(survivor));
						dpVision.WriteCell(GetClientUserId(tank));
						dpVision.WriteCell(g_esVisionPlayer[tank].g_iTankType);
						dpVision.WriteCell(messages);
						dpVision.WriteCell(enabled);
						dpVision.WriteCell(pos);
						dpVision.WriteCell(iTime);
					}
				}

				if ((g_esVisionCache[tank].g_iVisionMode & MT_VISION_VIEW) && bHuman)
				{
					DataPack dpVision;
					CreateDataTimer(0.1, tTimerVision2, dpVision, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					dpVision.WriteCell(GetClientUserId(survivor));
					dpVision.WriteCell(GetClientUserId(tank));
					dpVision.WriteCell(g_esVisionPlayer[tank].g_iTankType);
					dpVision.WriteCell(messages);
					dpVision.WriteCell(enabled);
					dpVision.WriteCell(pos);
					dpVision.WriteCell(iTime);
				}

				if (g_esVisionCache[tank].g_iVisionMessage & messages)
				{
					char sTankName[64];
					MT_GetTankName(tank, sTankName);
					if (((g_esVisionCache[tank].g_iVisionMode & MT_VISION_BLIND) && bHuman) || (g_esVisionCache[tank].g_iVisionMode & MT_VISION_FLASHBANG))
					{
						MT_PrintToChatAll("%s %t", MT_TAG2, "Vision", sTankName, survivor);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Vision", LANG_SERVER, sTankName, survivor);
					}

					if ((g_esVisionCache[tank].g_iVisionMode & MT_VISION_SHAKE) && bHuman)
					{
						MT_PrintToChatAll("%s %t", MT_TAG2, "Vision3", sTankName, survivor);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Vision3", LANG_SERVER, sTankName, survivor);
					}

					if ((g_esVisionCache[tank].g_iVisionMode & MT_VISION_SPLATTER) && bHuman)
					{
						MT_PrintToChatAll("%s %t", MT_TAG2, "Vision5", sTankName, survivor);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Vision5", LANG_SERVER, sTankName, survivor);
					}

					if ((g_esVisionCache[tank].g_iVisionMode & MT_VISION_VIEW) && bHuman)
					{
						MT_PrintToChatAll("%s %t", MT_TAG2, "Vision7", sTankName, survivor, g_esVisionCache[tank].g_iVisionFOV);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Vision7", LANG_SERVER, sTankName, survivor, g_esVisionCache[tank].g_iVisionFOV);
					}
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esVisionPlayer[tank].g_iRangeCooldown == -1 || g_esVisionPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esVisionCache[tank].g_iHumanAbility == 1 && !g_esVisionPlayer[tank].g_bFailed)
				{
					g_esVisionPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionHuman2");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esVisionCache[tank].g_iHumanAbility == 1 && !g_esVisionPlayer[tank].g_bNoAmmo)
		{
			g_esVisionPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "VisionAmmo");
		}
	}
}

void vVisionRange(int tank, int value, int bit, float random, int pos = -1)
{
	float flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 13, pos) : g_esVisionCache[tank].g_flVisionDeathChance;
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && (g_esVisionCache[tank].g_iVisionDeath & (1 << bit)) && random <= flChance)
	{
		if (g_esVisionCache[tank].g_iComboAbility == value || bIsAreaNarrow(tank, g_esVisionCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esVisionCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esVisionPlayer[tank].g_iTankType, tank) || (g_esVisionCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esVisionCache[tank].g_iRequiresHumans) || (bIsInfected(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esVisionAbility[g_esVisionPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[tank].g_iAccessFlags)) || g_esVisionCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 12, pos) : g_esVisionCache[tank].g_flVisionDeathRange;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esVisionPlayer[tank].g_iTankType, g_esVisionAbility[g_esVisionPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esVisionPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esVisionCache[tank].g_iVisionSight, .range = flRange))
				{
					vShakePlayerScreen(tank, 2.0);
				}
			}
		}
	}
}

void vVisionCopyStats2(int oldTank, int newTank)
{
	g_esVisionPlayer[newTank].g_iAmmoCount = g_esVisionPlayer[oldTank].g_iAmmoCount;
	g_esVisionPlayer[newTank].g_iCooldown = g_esVisionPlayer[oldTank].g_iCooldown;
	g_esVisionPlayer[newTank].g_iRangeCooldown = g_esVisionPlayer[oldTank].g_iRangeCooldown;
}

void vRemoveVision(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esVisionPlayer[iSurvivor].g_bAffected && g_esVisionPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esVisionPlayer[iSurvivor].g_bAffected = false;
			g_esVisionPlayer[iSurvivor].g_iOwner = -1;

			vVision(iSurvivor, 0);
			vStopVision(iSurvivor);
		}
	}

	vVisionReset3(tank);
}

void vVisionReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vVisionReset3(iPlayer);

			g_esVisionPlayer[iPlayer].g_iOwner = -1;
		}
	}
}

void vVisionReset2(int survivor, int tank, int messages)
{
	g_esVisionPlayer[survivor].g_bAffected = false;
	g_esVisionPlayer[survivor].g_iOwner = -1;

	vVision(survivor, 0);
	vStopVision(survivor);
	SetEntProp(survivor, Prop_Send, "m_iFOV", 90);
	SetEntProp(survivor, Prop_Send, "m_iDefaultFOV", 90);

	if (g_esVisionCache[tank].g_iVisionMessage & messages)
	{
		if ((g_esVisionCache[tank].g_iVisionMode & MT_VISION_BLIND) || (g_esVisionCache[tank].g_iVisionMode & MT_VISION_FLASHBANG))
		{
			MT_PrintToChatAll("%s %t", MT_TAG2, "Vision2", survivor);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Vision2", LANG_SERVER, survivor);
		}

		if (g_esVisionCache[tank].g_iVisionMode & MT_VISION_SHAKE)
		{
			MT_PrintToChatAll("%s %t", MT_TAG2, "Vision4", survivor);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Vision4", LANG_SERVER, survivor);
		}

		if (g_esVisionCache[tank].g_iVisionMode & MT_VISION_SPLATTER)
		{
			MT_PrintToChatAll("%s %t", MT_TAG2, "Vision6", survivor);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Vision6", LANG_SERVER, survivor);
		}

		if (g_esVisionCache[tank].g_iVisionMode & MT_VISION_VIEW)
		{
			MT_PrintToChatAll("%s %t", MT_TAG2, "Vision8", survivor, 90);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Vision8", LANG_SERVER, survivor, 90);
		}
	}
}

void vVisionReset3(int tank)
{
	g_esVisionPlayer[tank].g_bAffected = false;
	g_esVisionPlayer[tank].g_bFailed = false;
	g_esVisionPlayer[tank].g_bNoAmmo = false;
	g_esVisionPlayer[tank].g_iAmmoCount = 0;
	g_esVisionPlayer[tank].g_iCooldown = -1;
	g_esVisionPlayer[tank].g_iRangeCooldown = -1;
}

void vStopVision(int survivor)
{
	MT_TE_SetupStopAllParticles(survivor);
	TE_SendToClient(survivor);
}

Action tTimerVision(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsHumanSurvivor(iSurvivor) || !g_esVisionPlayer[iSurvivor].g_bAffected)
	{
		g_esVisionPlayer[iSurvivor].g_bAffected = false;
		g_esVisionPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()),
		iType = pack.ReadCell(),
		iVisionEnabled = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esVisionCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esVisionCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esVisionPlayer[iTank].g_iTankType, iTank) || (g_esVisionCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esVisionCache[iTank].g_iRequiresHumans) || !MT_HasAdminAccess(iTank) || !bHasAdminAccess(iTank, g_esVisionAbility[g_esVisionPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[iTank].g_iAccessFlags) || !MT_IsTypeEnabled(g_esVisionPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esVisionPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esVisionPlayer[iTank].g_iTankType, g_esVisionAbility[g_esVisionPlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esVisionPlayer[iSurvivor].g_iImmunityFlags) || iVisionEnabled == 0)
	{
		g_esVisionPlayer[iSurvivor].g_bAffected = false;
		g_esVisionPlayer[iSurvivor].g_iOwner = -1;

		vVision(iSurvivor, 0);

		return Plugin_Stop;
	}

	vVision(iSurvivor, g_esVisionCache[iTank].g_iVisionIntensity);

	return Plugin_Continue;
}

Action tTimerVision2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsHumanSurvivor(iSurvivor))
	{
		g_esVisionPlayer[iSurvivor].g_bAffected = false;
		g_esVisionPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esVisionCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esVisionCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esVisionPlayer[iTank].g_iTankType, iTank) || (g_esVisionCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esVisionCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esVisionAbility[g_esVisionPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esVisionPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esVisionPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esVisionPlayer[iTank].g_iTankType, g_esVisionAbility[g_esVisionPlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esVisionPlayer[iSurvivor].g_iImmunityFlags) || !g_esVisionPlayer[iSurvivor].g_bAffected)
	{
		vVisionReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iVisionEnabled = pack.ReadCell(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : RoundToNearest(g_esVisionCache[iTank].g_flVisionDuration),
		iTime = pack.ReadCell();
	if (iVisionEnabled == 0 || (iTime + iDuration) <= GetTime())
	{
		vVisionReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	if (!bIsVisibleToPlayer(iSurvivor, iTank, g_esVisionCache[iTank].g_iVisionSight))
	{
		return Plugin_Continue;
	}

	if (g_esVisionCache[iTank].g_iVisionMode & MT_VISION_SHAKE)
	{
		vShakePlayerScreen(iSurvivor);
	}

	if ((g_esVisionCache[iTank].g_iVisionMode & MT_VISION_SPLATTER) && g_iGraphicsLevel > 2)
	{
		int iIndex = (g_esVisionCache[iTank].g_iVisionType > 0) ? (g_esVisionCache[iTank].g_iVisionType - 1) : MT_GetRandomInt(0, (sizeof g_sParticles - 1)),
			iParticle = MT_GetParticleIndex(g_sParticles[iIndex]);
		if (iParticle != INVALID_STRING_INDEX)
		{
			MT_TE_SetupParticleAttachment(iParticle, 1, iSurvivor, true);
			TE_SendToClient(iSurvivor);
		}
	}

	if (g_esVisionCache[iTank].g_iVisionMode & MT_VISION_VIEW)
	{
		SetEntProp(iSurvivor, Prop_Send, "m_iFOV", g_esVisionCache[iTank].g_iVisionFOV);
		SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", g_esVisionCache[iTank].g_iVisionFOV);
	}

	return Plugin_Continue;
}

Action tTimerVisionCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esVisionAbility[g_esVisionPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esVisionPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esVisionCache[iTank].g_iVisionAbility == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vVisionAbility(iTank, flRandom, iPos);

	return Plugin_Continue;
}

Action tTimerVisionCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor) || g_esVisionPlayer[iSurvivor].g_bAffected)
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esVisionAbility[g_esVisionPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esVisionPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esVisionPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esVisionCache[iTank].g_iVisionHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esVisionCache[iTank].g_iVisionHitMode == 0 || g_esVisionCache[iTank].g_iVisionHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vVisionHit(iSurvivor, iTank, flRandom, flChance, g_esVisionCache[iTank].g_iVisionHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esVisionCache[iTank].g_iVisionHitMode == 0 || g_esVisionCache[iTank].g_iVisionHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vVisionHit(iSurvivor, iTank, flRandom, flChance, g_esVisionCache[iTank].g_iVisionHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}

	return Plugin_Continue;
}

Action tTimerStopVision(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor))
	{
		g_esVisionPlayer[iSurvivor].g_bAffected = false;
		g_esVisionPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	float flCurrentTime = pack.ReadFloat(), flDuration = pack.ReadFloat();
	int iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || !MT_IsCustomTankSupported(iTank) || !g_esVisionPlayer[iSurvivor].g_bAffected)
	{
		vVisionReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	if ((flCurrentTime + flDuration) < GetGameTime())
	{
		vVisionReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	switch (bIsVisibleToPlayer(iTank, iSurvivor, g_esVisionCache[iTank].g_iVisionSight))
	{
		case true: vVision(iSurvivor, g_esVisionCache[iTank].g_iVisionIntensity);
		case false: vVision(iSurvivor, 0);
	}

	return Plugin_Continue;
}